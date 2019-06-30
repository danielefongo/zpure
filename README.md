# ZPURE

zpure is an extremely customizable prompt inspired by [indresorhus/pure](https://github.com/sindresorhus/pure).

## Getting started

To use zpure on zsh you can either clone the project and source or use antigen

### Cloning and sourcing

From terminal:

```
cd <MYPATH>
git clone https://github.com/danielefongo/zpure
```

Then, source zpure on `.zshrc`:

```
source <MYPATH>/zpure/zpure.zsh
```

### Antigen

Insert in `.zshrc`:

```
antigen bundle danielefongo/zpure
```

## Customization

Every element showed on the prompt can be customized by changing properties. You can do it by adding an assignment after the sourcing or the `antigen apply` command. The default properties that can be changed are the following:

```
PROMPT_LEFT_ELEMENTS=(last_command_elapsed_seconds prompt_dir prompt_arrow)
PROMPT_RIGHT_ELEMENTS=(async_git_position async_git_merging async_git_diffs async_git_branch)

ZPURE_LAST_COMMAND_ELAPSED_SECONDS_COLOR="yellow"
ZPURE_LAST_COMMAND_ELAPSED_SECONDS_BOLD=true

ZPURE_GIT_BRANCH_COLOR="white"
ZPURE_GIT_BRANCH_BOLD=true

ZPURE_GIT_AHEAD="+NUM"
ZPURE_GIT_AHEAD_COLOR="cyan"
ZPURE_GIT_AHEAD_BOLD=true

ZPURE_GIT_BEHIND="-NUM"
ZPURE_GIT_BEHIND_COLOR="cyan"
ZPURE_GIT_BEHIND_BOLD=true

ZPURE_GIT_DETATCHED="!"
ZPURE_GIT_DETATCHED_COLOR="red"
ZPURE_GIT_DETATCHED_BOLD=true

ZPURE_GIT_MERGING="x"
ZPURE_GIT_MERGING_COLOR="cyan"
ZPURE_GIT_MERGING_BOLD=true

ZPURE_GIT_DIFF_SYMBOL="-"
ZPURE_GIT_UNTRACKED_COLOR="red"
ZPURE_GIT_UNTRACKED_BOLD=true
ZPURE_GIT_MODIFIED_COLOR="blue"
ZPURE_GIT_MODIFIED_BOLD=true
ZPURE_GIT_STAGED_COLOR="green"
ZPURE_GIT_STAGED_BOLD=true

ZPURE_ARROW_OK_CHAR="❯"
ZPURE_ARROW_OK_COLOR="green"
ZPURE_ARROW_OK_CHAR_BOLD=true
ZPURE_ARROW_KO_CHAR="❯"
ZPURE_ARROW_KO_COLOR="red"
ZPURE_ARROW_KO_CHAR_BOLD=true

ZPURE_TRUNCATED_DIR_COLOR="blue"
ZPURE_TRUNCATED_DIR_BOLD=false
ZPURE_LAST_FOLDER_DIR_COLOR="blue"
ZPURE_LAST_FOLDER_DIR_BOLD=true
```

### Segment functions

As you can see, `PROMPT_LEFT_ELEMENTS` and `PROMPT_RIGHT_ELEMENTS` contain a list of elements: every element represents a `segment function` that will be evaluated to print data on the prompt. A PROMPT_LEFT_ELEMENTS segment function can print multiple lines using two or more `echo` (or similar command).

Functions starting with `async` are evaluated asynchronously so the prompt is not freezed while they are running; after the evaluation, the prompt will be refreshed automatically.

You can define custom segments functions and add them in one of the array showed above:

```zsh
# on .zshrc

# loading stuff...

function async_sleeping_function() {
  sleep 10 && echo "i was sleeping"
}

PROMPT_LEFT_ELEMENTS=(async_sleeping_function prompt_dir prompt_arrow)
```

### Colorize text

You can use the `colorize` function inside a segment function to echo a colorized text. The signature is the following:

```
colorize <text> <color> <bold>
```

You can also use `colorizeFromStatus` function inside a segment function to echo a colorized text based on the status of the last command. The signature is the following:

```
colorizeFromStatus <ok-text> <ok-color> <ok-bold> <ko-text> <ko-color> <ko-bold>
```

Where bold can be `true` or `false`.

### Themes

You can define your own custom theme by creating a repo on github with a file named `zpure.theme` in the root and containing all the customizations needed (see this [theme](https://github.com/danielefongo/fish-zpure) for example).

You can then import your theme by using the command `zpure-import <user>/<repo>`.

With the command `zpure-set [<user>/<repo>]` you set the theme as default. If the parameter is not passed, zpure will set the default theme. Remember that you can press TAB to show all the installed themes. If you are using antigen and you have problem with the auto-completion, just run `rm -rf ~/.zcompdump && antigen reset` and try again with a new shell.
