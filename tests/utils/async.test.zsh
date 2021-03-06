#!/usr/bin/env zsh

# Setup

setopt shwordsplit
SHUNIT_PARENT=$0

typeset -gA created_lock
typeset -gA locked_lock
typeset -gA unlocked_lock

oneTimeSetUp() {
    source utils/async.zsh
    source mockz/mockz.zsh
}

setUp() {
    myJob() { echo job }
    mock myCallback
    mock lock_create
    mock lock_active
    mock lock_lock
    mock lock_unlock
    mock lock_exists
}

tearDown() {
    sleep 0.5
    rockall
    set +e
}

# Tests

test_saves_job_pid() {
    async_job myJob myCallback
    local myPid=$__async_jobs["myJob"]

    assertNotNull "$myPid"
}

test_kills_previous_job_when_running_the_same_job_again() {
    mock lock_active do "return 1"
    sleepyJob() {sleep 1}

    async_job sleepyJob myCallback
    local oldPid=$__async_jobs["sleepyJob"]
    sleep 0.1
    async_job sleepyJob myCallback
    local newPid=$__async_jobs["sleepyJob"]

    sleep 0.5

    assertFalse "kill -0 $oldPid"
    assertNotEquals "$oldPid" "$newPid"
}

test_fails_to_do_async_job_when_not_initialized() {
    mock lock_exists do 'return 1'

    async_job myJob myCallback

    assertEquals "1" "$?"
}

test_calls_all_required_lock_methods() {
    async_init

    __async myJob myCallback
    set +e
    sleep 0.5

    mock lock_create called 1
    mock lock_lock called 1
    mock lock_unlock called 1
}

test_does_not_call_lock_methods_when_killing_slow_process() {
    rm -f tmpfile
    touch tmpfile

    mock lock_active do "return 1"
    mock lock_lock do "echo 1 >> tmpfile"
    mock lock_unlock do "echo 1 >> tmpfile"

    async_init
    sleepyJob() {sleep 1}

    __async sleepyJob myCallback &
    process=$!

    sleep 0.5
    kill -s TERM $process

    calls=$(cat tmpfile | wc -l)
    rm -rf tmpfile

    mock lock_create called 1
    assertEquals "0" ${calls}
}

test_calls_all_lock_methods_if_killed_process_already_locked_resources() {
    rm -f tmpfile
    touch tmpfile

    mock lock_unlock do "echo 1 >> tmpfile"
    mock lock_lock do "echo 1 >> tmpfile"
    mock lock_active do "echo 1 >> tmpfile; return 1"
    mock zpty do "sleep 0.2; return 1"

    async_init

    __async myJob myCallback &
    process=$!

    sleep 0.1
    kill -s TERM $process

    sleep 0.2

    calls=$(cat tmpfile | wc -l)
    rm -rf tmpfile

    assertEquals "3" ${calls}
}

test_calls_async_handler_with_right_params() {
    mock zpty expect '-w asynced myCallback "myJob" "" "job"'
    mock kill

    __async myJob myCallback
    set +e

    sleep 0.5
}

test_handler_calls_callback_properly() {
    async_init

    mock mockFunction expect "output"

    zpty -w asynced "mockFunction output"
    __async_handler
}

test_concurrent_jobs() {
    function myJob_1() {echo "line"}
    function myJob_2() {echo "line"}
    function myJob_3() {echo "line"}
    function myJob_4() {echo "line"}
    function myJob_5() {echo "line"}
    function myJob_6() {echo "line"}
    function myJob_7() {echo "line"}
    function myJob_8() {echo "line"}
    function myJob_9() {echo "line"}
    function myJob_10() {echo "line"}
    function myCallback() {echo "something" >> tmpfile}

    rm -f tmpfile
    for i in $(seq 1 10); do
        async_job myJob_$i myCallback
    done
    set +e

    sleep 5

    local actual=$(cat tmpfile | wc -l | sed 's/ //g')

    assertEquals "10" "$actual"
    rm -f tmpfile
}

# Utilities

assertContains() {
    local output=$(echo "$1" | grep "$2" | wc -l)
    assertTrue "[ $output -ge 1 ]"
}

# Run

source "shunit2/shunit2"