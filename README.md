# bash-utilities

A collection of some bash script utilities.

## Create new script

To create a new script with some default configuration call `bin/createscript` followed by the path to the new file.

```bash
./bin/createscript path/to/file
```

## Utilities

### checks.sh

The file `lib/checks.sh` includes utilities to use as an expression in statements.

### docker.sh

The file `lib/docker.sh` contains utilities for docker and docker-compose.

#### docker_compose_export_pid

Writes the process id of a specified docker-compose service to the specified file. Optionally the path to the docker-compose.yml can be specified as third argument.

```bash
docker_compose_export_pid app /path/to/pidfile
docker_compose_export_pid app /path/to/pidfile /path/to/docker-compose.yml
```

#### docker_compose_service_id

Returns the container id of a specified docker-compose service. Optionally the path to the docker-compose.yml can be specified as second argument.

```bash
docker_compose_service_id app
docker_compose_service_id app /path/to/docker-compose.yml
```

#### docker_compose_service_pid

Returns the process id of a specified docker-compose service. Optionally the path to the docker-compose.yml can be specified as second argument.

```bash
docker_compose_service_pid app
docker_compose_service_pid app /path/to/docker-compose.yml
```

#### is_true

Returns `0` (truthy) if the passed argument equals `true` or `1`.

```bash
is_true 1       # 0 (truthy)
is_true true    # 0 (truthy)
is_true "1"     # 0 (truthy)
is_true "true"  # 0 (truthy)

is_true ""      # 1 (falsy)
is_true foo     # 1 (falsy)
```

#### is_false

Returns `0` (truthy) if the passed argument equals `false` or `0`.

```bash
is_false 0       # 0 (truthy)
is_false false   # 0 (truthy)
is_false "0"     # 0 (truthy)
is_false "false" # 0 (truthy)

is_false ""      # 1 (falsy)
is_false foo     # 1 (falsy)
```

### echo.sh

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

### log.sh

**File logs are disabled by default. Set `BASH_UTILS_LOG_PATH` to enable them.**

The logging utilities located in `lib/log.sh` extend the echo utilities appending the output to a log file. They also use the same color settings.

To enable file logging, the `BASH_UTILS_LOG_PATH` environment variable has to be set (see [Environment](#environment)). An unset variable disables logging. Regardless of whether logging is set or not, the output will be written to stdout.

The log file rotates after reaching a size defined by `BASH_UTILS_MAX_LOG_SIZE`.

File logs additionally are prefixed with a custom string and the type of log. The prefix can be set via the `BASH_UTILS_LOG_PREFIX` variable and defaults to the current timestamp.

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

### log_exit_error.sh

Including the `lib/log_exit_error.sh` script enables fundamental error handling including logging. All errors are appended to the log file specified via `BASH_UTILS_LOG_PATH`. The script also sets `errexit` and `pipefail`.

If an error occurs, the error is appended to the log file and the script exits immediately. Also, the exit code and the name of the script is logged in the log file.

Because the `stderr` output is read and again written to the `stdout` and the log file, the order of the output may get lost.

Remember to set the `BASH_UTILS_LOG_PATH` variable to enable logging.

## Config

The behavior of the bash utilities can be configured by setting environment variables.

The utilities try to read a custom env file called `.bashutils.env` in the project root. If the file does not exist, the utilities also try to source the file from the parent directory, in case the repository is used as a git submodule. If no custom `.bashutils.env` exists, the utilities will use the default config.

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

| Variables                 | Default            | Description                                                            |
| ------------------------- | ------------------ | ---------------------------------------------------------------------- |
| `BASH_UTILS_LOG_PATH`     |                    | File written to by logging utilities. An empty value disables logging. |
| `BASH_UTILS_LOG_PREFIX`   | [$(date "+%F %T")] | Prefix used for log file entries.                                      |
| `BASH_UTILS_MAX_LOG_SIZE` | 20971520           | The maximum log file size                                              |
