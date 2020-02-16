# bash-utilities

A collection of some bash script utilities.

## Installation

You have several options on how to use the `bash-utitilies`. The easiest way is to simply clone the repository.

```bash
git clone https://github.com/SpritzerPyro/bash-utilities.git
```

For projects using node, you can add the `bash-utilities` GitHub package. Therefore you first have to add the GitHub package registry. Afterward, you can call `touch` using npm or yarn to create a new file.

```bash
echo "@spritzerpyro:registry=https://npm.pkg.github.com" >> .npmrc

# yarn
yarn add @spritzerpyro/bash-utilities
yarn run touch -x path/to/file

# npm
npm install @spritzerpyro/bash-utilities
npm run touch -x path/to/file
```

For projects not using node, you also can add the repository as submodule.

```bash
git submodule add https://github.com/SpritzerPyro/bash-utilities.git

# Update submodules
git submodule update --remote --merge
```

## Create a new script

To create a new script with some default configuration, call `bin/touched` followed by the type of script you want to create and the path to the new file.

```bash
./bin/touch -h
Usage: touch [OPTIONS] /path/to/file

Selecting a filetype like executable or library is mandatory!

Options:
  -e, -x  Create executable script
  -h      Show this information
  -l      Create library file
```

### Executable file

**Option:** `-e` or `-x`

An executable includes some basic variables and initially sources the `lib/log_exit_error.sh` script.

The created file is executable.

_Executables should have no extension. If a `.sh` extension is declared, the script asks you to remove it. Of course, you can keep the extension if you want to._

### Library file

**Option:** `-l`

A library just includes the `shebang` and `set -eo pipefail` although both are not needed.

Libraries are not executable.

_Libraries must have a `.sh` extension. The script automatically adds one if not declared._

## Utilities

### chalk.sh

The script `lib/chalk.sh` includes some functions to use the `echo` command using different colors.

The color is defined by the specified level.

| Level   | Description       | Default color |
| ------- | ----------------- | ------------- |
| emph    | Emphasized        | blue          |
| error   | Indicates errors  | red           |
| info    | Normal text       | default       |
| success | Indicates success | green         |
| warn    | Warning text      | yellow        |

For color configuration options see [color environment variables](#colors).

#### chalk

The `chalk` command writes the specified text. The optional `-l LEVEL` flag uses a different color as described [above](#chalsh).

Output can also be piped into the `chalk` command.

```bash
chalk "Lorem ipsum dolor sit amet"
chalk -l emph "Lorem ipsum dolor sit amet"
echo "Oh snap!" | chalk -l error
```

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

Writes the process id of a specified docker-compose service to the specified file. Optionally the path to the docker-compose.yml can be specified as the third argument.

```bash
docker_compose_export_pid app /path/to/pidfile
docker_compose_export_pid app /path/to/pidfile /path/to/docker-compose.yml
```

#### docker_compose_service_id

Returns the container id of a specified docker-compose service. Optionally the path to the docker-compose.yml can be specified as a second argument.

```bash
docker_compose_service_id app
docker_compose_service_id app /path/to/docker-compose.yml
```

#### docker_compose_service_pid

Returns the process id of a specified docker-compose service. Optionally the path to the docker-compose.yml can be specified as a second argument.

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

Reads all lines in the form `export KEY=VALUE` from the specified file and transform them into `KEY=VALUE`. The function can be used to write them to a dotenv file.

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

### input.sh

In the library `input.sh` some functions to read user input are available.

#### query

`query` prompts the user with the as first argument specified question and writes the answer to a variable passed as the second argument.

Normally, the user is questioned until an answer is given. With the `-e` flag an empty input can be allowed explicitly.

With the `-d` option, a default value can be specified, which is taken when the user accepts an empty line.

The `-p` option, which stands for "path", also resolves `~` to the user home directory.

```bash
source $bash_utils_lib_dir/input.sh

query "Prompt for input" data1
query -d "foo" "With default value" data2
query -p "Prompt for a path" data3
query -e "Allow empty input" data4

echo "Result1: $data1"
echo "Result2: $data2"
echo "Result3: $data3"
echo "Result4: $data4"

# Output
Prompt for input: bar
With default value (foo):
Prompt for a path: ~/foo
Allow empty input:
Result1: bar
Result2: foo
Result3: /home/user/foo
Result4:
```

#### query_yes_no

The `query_yes_no` function prompts the user for a yes or no question. The answer directly can be used as a boolean condition or stored into a variable.

The first argument of the function is the question, the user is asked. An optional second argument is a variable the answer is written to (`yes` or `no`). If the second argument is omitted, the function returns with `0 (truthy)` for yes and `1 (falsy)` for no.

```bash
source $bash_utils_lib_dir/input.sh

if query_yes_no "Make a decision" ; then
  echo "In the 'yes' block"
else
  echo "In the 'no' block"
fi

query_yes_no "Fill 'foo' variable" data

echo "Answer: $data"

# Output for answer 'y'
Make a decision [y|n]: y
In the 'yes' block
Fill some variable [y|n]: y
Answer: yes

# Output for answer 'n'
Make a decision [y|n]: n
In the 'no' block
Fill some variable [y|n]: n
Answer: no
```

The function also takes default values with the options `-y` for yes and `-n` for no.

```bash
query_yes_no -y "Default yes" data1
query_yes_no -n "Default no" data2

echo "Answer '-y': $data1"
echo "Answer '-n': $data2"

# Output
Default yes [y|n] (y):
Default no [y|n] (n):
Answer '-y': yes
Answer '-n': no
```

### log.sh

**File logs are disabled by default. Set `BASH_UTILS_LOG_PATH` to enable them.**

The logging utilities located in `lib/log.sh` extend the echo utilities appending the output to a log file. They also use the same color or level settings.

To enable file logging, the `BASH_UTILS_LOG_PATH` environment variable has to be set (see [Environment](#environment)). An unset variable disables logging, else the output is logged into the specified file or to a space-separated list of files. Regardless of whether logging is set or not, the output will be written to stdout.

```bash
BASH_UTILS_LOG_PATH=/var/log/foo.log
BASH_UTILS_LOG_PATH=/var/log/foo.log\ /var/log/bar.log
```

The log file rotates after reaching a size defined by `BASH_UTILS_LOG_MAX_SIZE`.

File logs additionally are prefixed with a custom string and the type of log. The prefix can be set via the `BASH_UTILS_LOG_PREFIX` variable and defaults to the current timestamp.

#### log

The `log` command "chalks" and writes to `BASH_UTILS_LOG_PATH`.

**Usage:** `log [OPTIONS] TEXT`

| flag | meaning | description                                |
| ---- | ------- | ------------------------------------------ |
| -c   | chalk   | Only chalks but does not write to log file |
| -l   | level   | Log level [(see chalk)](#chalksh)          |
| -s   | silent  | Writes to the log file but does not chalk  |

Output can also be piped into the `log` command.

```bash
export BASH_UTILS_LOG_PATH=/path/to/file.log

log "Lorem ipsum dolor sit amet"
[2020-01-01 13:00:46] info    : Lorem ipsum dolor sit amet

log -l emph "Lorem ipsum dolor sit amet"
[2020-01-01 13:00:38] emph    : Lorem ipsum dolor sit amet

log -l error "Lorem ipsum dolor sit amet"
[2020-01-01 13:00:44] error   : Lorem ipsum dolor sit amet

log -l info "Lorem ipsum dolor sit amet"
[2020-01-01 13:00:46] info    : Lorem ipsum dolor sit amet

log -l success "Lorem ipsum dolor sit amet"
[2020-01-01 13:00:57] success : Lorem ipsum dolor sit amet

log -l warn "Lorem ipsum dolor sit amet"
[2020-01-01 13:01:06] warning : Lorem ipsum dolor sit amet

echo "Lorem ipsum dolor sit amet" | log -l warn
[2020-01-01 13:01:06] warning : Lorem ipsum dolor sit amet
```

#### log_native

Some commands like `docker-compose up -d` create output not working properly using the standard log command.

If you run into such a problem, the `log_native` command uses `tee` to natively add the output to the log file. This output then is not prefixed in the log file. To log some prefixed information, a `Run command` and `Finished command` information also is logged before and after the command is executed. This information also is customizable by passing a string as an argument to `log_native`.

_Notice the use of `|&` because docker-compose writes to `stderr`._

```bash
docker-compose up -d |& log_native "Up test docker"
# Log file:
# [2020-01-26 09:53:36] info    : Run 'Up test docker'
# Creating network "bash-utilities_default" with the default driver
# Creating bash-utilities_test_1 ... done
# [2020-01-26 09:53:36] info    : Finished 'Up test docker'

docker-compose down |& log_native
# Log file:
# [2020-01-26 09:53:36] info    : Run command
# Removing bash-utilities_test_1 ... done
# Removing network bash-utilities_default
# [2020-01-26 09:53:36] info    : Finished command
```

### log_exit_error.sh

Including the `lib/log_exit_error.sh` script enables fundamental error handling including logging. All errors are appended to the log file specified via `BASH_UTILS_LOG_PATH`. The script also sets `errexit` and `pipefail`.

If an error occurs, the error is appended to the log file and the script exits immediately. Also, the exit code and the name of the script is logged in the log file.

Because the `stderr` output is read and again written to the `stdout` and the log file, the order of the output may get lost.

Logging `stderr` output to the log file can be disabled by setting `BASH_UTILS_LOG_STDERR` to `false` or `0`.

Remember to set the `BASH_UTILS_LOG_PATH` variable to enable logging.

## Config

The behavior of the bash utilities can be configured by setting environment variables.

The utilities try to read custom environment variables located either in `.env` or a file called `.bashutils.env`, located in the project root or its parent directory, in case the repository is used as a git submodule. If no custom env file exists, the utilities will use the default config.

## Environment

### Colors

| Variables                  | Default    | Description                      |
| -------------------------- | ---------- | -------------------------------- |
| `BASH_UTILS_COLOR_DEFAULT` | \033[0m    | Color to reset after output      |
| `BASH_UTILS_COLOR_EMPH`    | \033[0;34m | Color used for emphasized output |
| `BASH_UTILS_COLOR_ERROR`   | \033[0;31m | Color used for error output      |
| `BASH_UTILS_COLOR_INFO`    | \033[0m    | Color used for info output       |
| `BASH_UTILS_COLOR_PREFIX`  | \033[0;90m | Color used for logging prefix    |
| `BASH_UTILS_COLOR_SUCCESS` | \033[0;32m | Color used for success output    |
| `BASH_UTILS_COLOR_WARN`    | \033[0;33m | Color used for warning output    |

## Log

| Variables                 | Default            | Description                                                                                                                              |
| ------------------------- | ------------------ | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `BASH_UTILS_LOG_MAX_SIZE` | 20971520           | The maximum log file size                                                                                                                |
| `BASH_UTILS_LOG_PATH`     |                    | File written to by logging utilities. To log to multiple files a space-separated list can be specified. An empty value disables logging. |
| `BASH_UTILS_LOG_PREFIX`   | [$(date "+%F %T")] | Prefix used for log file entries.                                                                                                        |
| `BASH_UTILS_LOG_STDERR`   |                    | Disables logging of stderr output.                                                                                                       |
