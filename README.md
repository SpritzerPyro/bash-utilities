# bash-utilities

A collection of some bash script utilities.

## Echo utilities

The script `lib/echo.sh` includes some functions to use the `echo` command using different colors.

For color configuration options see [color environment variables](#colors).

```bash
# Emphasized (default: blue)
echo_emph "Lorem ipsum dolor sit amet"

# Error (default: red)
echo_error "Lorem ipsum dolor sit amet"

# Info (default: default color)
echo_info "Lorem ipsum dolor sit amet"

# Success (default: green)
echo_success "Lorem ipsum dolor sit amet"

# Warning (default: orange)
echo_warn "Lorem ipsum dolor sit amet"
```

## Log utilities

**File logs are disabled by default. Set `BASH_UTILS_LOG_PATH` to enable them.**

The logging utilities located in `lib/log.sh` extend the echo utilties appending the output to a log file. They also use the same color settings.

To enable file logging, the `BASH_UTILS_LOG_PATH` environment variable has to be set (see [Environment](#environment)). An unset variable disables logging. Regardless of whether logging is set or not, the output will be written to stdout.

The log file rotates after reaching a size defined by `BASH_UTILS_MAX_LOG_SIZE`.

File logs additionally are prefixed by a timestamp and the type of log.

```bash
export BASH_UTILS_LOG_PATH=/path/to/file.log

log_emph "Lorem ipsum dolor sit amet"
[2020-01-01 13:00:38] emph    : Lorem ipsum dolor sit amet

log_error "Lorem ipsum dolor sit amet"
[2020-01-01 13:00:44] error   : Lorem ipsum dolor sit amet

log_info "Lorem ipsum dolor sit amet"
[2020-01-01 13:00:46] info    : Lorem ipsum dolor sit amet

log_success "Lorem ipsum dolor sit amet"
[2020-01-01 13:00:57] success : Lorem ipsum dolor sit amet

log_warn "Lorem ipsum dolor sit amet"
[2020-01-01 13:01:06] warning : Lorem ipsum dolor sit amet
```

## Config

The behaviour of the bash utilities can be configured by setting environment variables.

The utilities try to read a custom env file called `.bashutils.env` in the project root. If the file does not exists, the utilities also try to source the file from the parent directory, in case the repository is used as a git submodule. If no custom `.bashutils.env` exists, the utitlies will use the default config.

## Environment

### Colors

| Variables                  | Default    | Description                      |
| -------------------------- | ---------- | -------------------------------- |
| `BASH_UTILS_DEFAULT_COLOR` | \033[0m    | Color to reset after output      |
| `BASH_UTILS_EMPH_COLOR`    | \033[0;34m | Color used for emphasized output |
| `BASH_UTILS_ERROR_COLOR`   | \033[0;31m | Color used for error output      |
| `BASH_UTILS_INFO_COLOR`    | \033[0m    | Color used for info output       |
| `BASH_UTILS_PREFIX_COLOR`  | \033[0;90m | Color used for logging prefix    |
| `BASH_UTILS_SUCCESS_COLOR` | \033[0;32m | Color used for success output    |
| `BASH_UTILS_WARN_COLOR`    | \033[0;33m | Color used for warning output    |

## Log

| Variables                 | Default  | Description                                                            |
| ------------------------- | -------- | ---------------------------------------------------------------------- |
| `BASH_UTILS_LOG_PATH`     |          | File written to by logging utiltites. An empty value disables logging. |
| `BASH_UTILS_MAX_LOG_SIZE` | 20971520 | The maximum log file size                                              |
