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

### dotenv.sh

In the script `lib/dotenv.sh` utilities to deal with dotenv files can be found.

#### dotenv_is_valid

The function reads the specified file and returns `0` (`true`) if it is a valid dotenv file. Else the function returns `1` (`false`).

A valid dotenv file only includes lines in the format `KEY=VALUE` or comments (`# My comment`).

```bash
dotenv_is_valid my.env # 0 or 1
```

#### export_dotenv

The specified file is sourced and the variables are exported to the current environment.

If the file does not exist, or it is an invalid dotenv file, the function writes to `stdout` and returns `1`.

```bash
export_dotenv my.env
```

#### export_dotenvs

The function accepts a list of files and calls [export_dotenv](#exportdotenv) for each file. Globbing patterns are allowed as well.

```bash
export_dotenvs *.env .env myfile
```

#### export_to_env

Reads all lines in the form `export KEY=VALUE` from the specified file and transform them to `KEY=VALUE`. Can be used to write them to a dotenv file.

```bash
export_to_env myscript > new.env
```

#### source_dotenv

Sources the specified dotenv file. The function writes to stderr and returns `1` if the file does not exist or is an invalid dotenv file.

```bash
source_dotenv my.env
```

#### source_dotenvs

The function accepts a list of files and calls [source_dotenv](#sourcedotenv) for each file. Globbing patterns are allowed as well.

```bash
source_dotenvs *.env .env myfile
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

Logging `stderr` output to the log file can be diabled by setting `BASH_UTILS_LOG_STDERR` to `false` or `0`.

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
| `BASH_UTILS_LOG_STDERR`   |                    | Disables logging of stderr output.                                     |
| `BASH_UTILS_MAX_LOG_SIZE` | 20971520           | The maximum log file size                                              |
