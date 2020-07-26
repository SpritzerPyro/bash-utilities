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
git submodule init

# Update submodules
git submodule update --remote --merge
```

## Create a new script

To create a new script with some default configuration, call `bin/touched` followed by the type of script you want to create and the path to the new file.

During the creation you are prompted for a description and whether you want to include some information into the file header.

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

Creates a library file including an example library function and its function comment.

Libraries are not executable.

_Libraries must have a `.sh` extension. The script automatically adds one if not declared._

## Utilities

### chalk.sh

The script `lib/chalk.sh` includes some functions to use the `echo` command using different colors.

```bash
butils::use chalk
```

#### chalk

The `chalk` command writes the specified text. The optional `-l LEVEL` flag specified the used log level.

Possible levels and its according colors are discribed in the [logging table](#logging).

Output can also be piped into the `chalk` command.

```bash
chalk "Lorem ipsum dolor sit amet"
chalk -l warn "Lorem ipsum dolor sit amet"
echo "Oh snap!" | chalk -l error
```

For color configuration options see [color environment variables](#colors).

### checks.sh

The file `lib/checks.sh` includes utilities to use as an expression in statements.

```bash
butils::use checks
```

#### check::email

The function `check::email` can be used to very basically check whether a string is a valid email. It only checks if the string includes the `@` and does not contain whitespaces.

Returns `0` (truthy) if the passed argument is considered valid and `1` (falsy) if not.

```bash
check::email "test@example"      # 0 (truthy)
check::email "test@example.org"  # 0 (truthy)
check::email "test.foo@example"  # 0 (truthy)

check::email " test@example"     # 1 (falsy)
check::email "testexample "      # 1 (falsy)
check::email "test@exam ple"     # 1 (falsy)

# Do not forget to quote the argument
email="test@exam ple"

# Correct usage, "test@exam ple" is validated
check::email "${email}" # 1 (falsy)

# Wrong usage because only "test@exam" is validated
check::email $email # 0 (truthy)
```

#### check::false

Returns `0` (truthy) if the passed argument equals `false` or `0`.

```bash
check::false 0       # 0 (truthy)
check::false false   # 0 (truthy)
check::false "0"     # 0 (truthy)
check::false "false" # 0 (truthy)

check::false ""      # 1 (falsy)
check::false foo     # 1 (falsy)
```

#### check::true

Returns `0` (truthy) if the passed argument equals `true` or `1`.

```bash
check::true 1       # 0 (truthy)
check::true true    # 0 (truthy)
check::true "1"     # 0 (truthy)
check::true "true"  # 0 (truthy)

check::true ""      # 1 (falsy)
check::true foo     # 1 (falsy)
```

### docker.sh

The file `lib/docker.sh` contains utilities for docker and docker-compose.

```bash
butils::use docker
```

#### docker::pid

Returns the pid of a docker container.

| flag | usage              | description                          |
| ---- | ------------------ | ------------------------------------ |
| s    | `-s CONTAINER`     | Specifies the target container       |
| t    | `-t CONTAINER`     | Alternative to the `-s` flag         |
| w    | `-w /path/to/file` | Writes the pid to the specified file |

```bash
docker::pid TARGET
docker::pid -t TARGET
docker::pid -w /path/to/file TARGET
```

#### docker_compose::id

Returns the id of a docker-compose service.

| flag | usage                   | description                         |
| ---- | ----------------------- | ----------------------------------- |
| f    | `-f docker-compose.yml` | Specifies the docker-compose file   |
| s    | `-s CONTAINER`          | Specifies the target service        |
| t    | `-t CONTAINER`          | Alternative to the `-s` flag        |
| w    | `-w /path/to/file`      | Writes the id to the specified file |

```bash
docker_compose::id SERVICE
docker_compose::id -s SERVICE
docker_compose::id -f compose.yml -w /path/to/file SERVICE
```

#### docker_compose::pid

Returns the pid of a docker-compose service.

| flag | usage                   | description                          |
| ---- | ----------------------- | ------------------------------------ |
| f    | `-f docker-compose.yml` | Specifies the docker-compose file    |
| s    | `-s CONTAINER`          | Specifies the target service         |
| t    | `-t CONTAINER`          | Alternative to the `-s` flag         |
| w    | `-w /path/to/file`      | Writes the pid to the specified file |

```bash
docker_compose::pid SERVICE
docker_compose::pid -s SERVICE
docker_compose::pid -f compose.yml -w /path/to/file SERVICE
```

### dotenv.sh

In the script `lib/dotenv.sh` utilities to deal with dotenv files can be found.

```bash
butils::use dotenv
```

#### dotenv::grep

| flag | usage        | description                           |
| ---- | ------------ | ------------------------------------- |
| i    | `-i`         | Ignore case                           |
| s    | `-s`         | No messages (silent)                  |
| v    | `-v MY.*VAR` | Additional regex for the grep command |

```bash
dotenv::grep my.env
dotenv::grep -i -s -v MY_VAR my.env your.env
```

#### dotenv::source

| flag | usage        | description                                      |
| ---- | ------------ | ------------------------------------------------ |
| a    | `-a`         | Exports all sourced variables to the environment |
| i    | `-i`         | Ignore case                                      |
| s    | `-s`         | No messages (silent)                             |
| v    | `-v MY.*VAR` | Additional regex for the grep command            |

```bash
dotenv::grep my.env
dotenv::grep -a -i -s -v MY_VAR my.env your.env
```

### input.sh

In the library `input.sh` some functions to read user input are available.

#### query

`query` prompts the user with the as argument specified question and writes the answer to a variable passed via the `-v` flag or to the `input` variable.

| flag | usage       | description                                                    |
| ---- | ----------- | -------------------------------------------------------------- |
| d    | `-d value`  | Sets an default value for an empty input                       |
| e    | `-e`        | Checks if the input is a valid email address                   |
| o    | `-o`        | Optional. Allows an empty answer                               |
| p    | `-p`        | Resolves `~` to the user's home directory                      |
| v    | `-v my_var` | Writes the answer to the specified variable instead of `input` |

```bash
query "Prompt for input"
echo "${input}"

query -d "~/Documents" -p -v data "A path with a default value" data2
echo "${data}"

query -e -o -v email "Prompt for an optional email"
echo "${email}"
```

#### query::email

Synonym for `query -e`.

#### query::path

Synonym for `query -p`.

#### query::polar

| flag | usage | description                                   |
| ---- | ----- | --------------------------------------------- |
| n    | `-n`  | Sets the default answer to 'no' or 1          |
| v    | `-v`  | Specifies a variable the answer is written to |
| y    | `-y`  | Sets the default answer to 'yes' or 0         |

The `query::polar` function prompts the user for a yes or no (polar) question. The answer directly can be used as a boolean condition or stored into a variable.

```bash
if query::polar "Make a decision" ; then
  echo "In the 'yes' block"
else
  echo "In the 'no' block"
fi

query_::polar -y -v data "Fill 'foo' variable"

echo "Answer: ${data}"
```

### log.sh

```bash
dotenv::use log
```

_The log levels and colors are described in the [logging](#logging) section._

The log file rotates after reaching a size defined by `BASH_UTILS_LOG_MAX_SIZE`.

File logs additionally are prefixed with a timestamp and the type of log. The format of the timestamp can be set via the `BASH_UTILS_LOG_TIME_FORMAT` variable and defaults to an ISO 8601 string. An empty value for `BASH_UTILS_TIME_FORMAT` disables using a timestamp.

To specify the files the logging should be written to first use `log::set`. To add files you can use `log::add`.

```bash
log::set foo.log bar.log
log::add bar.log
log::set # No argument resets the log files
log::add foo.bar

readonly files=(foo.log bar.log baz.log)

log::set "${files[@]}"
```

#### log

The `log` command "chalks" and writes to all specified log files.

Output can also be piped into the `log` command.

```bash
log::set /path/to/my.log

log "Lorem ipsum dolor sit amet"
[2020-01-01T13:00:46.123+02:00] INFO  : Lorem ipsum dolor sit amet

log -l emph "Lorem ipsum dolor sit amet"
[2020-01-01T13:00:38.123+02:00] INFO  : Lorem ipsum dolor sit amet

log -l error "Lorem ipsum dolor sit amet"
[2020-01-01T13:00:44.123+02:00] error : Lorem ipsum dolor sit amet

log -l info "Lorem ipsum dolor sit amet"
[2020-01-01T13:00:46.123+02:00] info  : Lorem ipsum dolor sit amet

log -l success "Lorem ipsum dolor sit amet"
[2020-01-01T13:00:57.123+02:00] INFO  : Lorem ipsum dolor sit amet

log -l warn "Lorem ipsum dolor sit amet"
[2020-01-01T13:01:06.123+02:00] WARN  : Lorem ipsum dolor sit amet

echo "Lorem ipsum dolor sit amet" | log -l warn
[2020-01-01T13:01:06.123+02:00] WARN  : Lorem ipsum dolor sit amet
```

#### log::native

Some commands like `docker-compose up -d` create output not working properly using the standard log command.

If you run into such a problem, the `log_native` command uses `tee` to natively add the output to the log files. This output then is not prefixed in the log file. To log some prefixed information, a `[Run] command` and `[Done] command` information also is logged before and after the command is executed. This information also is customizable by passing a string as an argument to `log::native "my test"`.

_Notice the use of `|&` because docker-compose writes to `stderr`._

```bash
docker-compose up -d |& log_native "Up test docker"
# Log file:
# [2020-01-26 09:53:36] info    : [Run] Up test docker
# Creating network "bash-utilities_default" with the default driver
# Creating bash-utilities_test_1 ... done
# [2020-01-26 09:53:36] info    : [Done] Up test docker

docker-compose down |& log_native
# Log file:
# [2020-01-26 09:53:36] info    : [Run] command
# Removing bash-utilities_test_1 ... done
# Removing network bash-utilities_default
# [2020-01-26 09:53:36] info    : [Done] command
```

## Config

The behavior of the bash utilities can be configured by setting environment variables.

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

| Variables                    | Default  | Description                                                                                                |
| ---------------------------- | -------- | ---------------------------------------------------------------------------------------------------------- |
| `BASH_UTILS_LOG_MAX_SIZE`    | 20971520 | The maximum log file size                                                                                  |
| `BASH_UTILS_LOG_TIME_FORMAT` | "%F %T"  | The format used for the log file timestamp (see `date --help`). An empty value disables using a timestamp. |

## Logging

The file output of logs is based on the [log4j pattern layout](https://logging.apache.org/log4j/2.x/manual/layouts.html#PatternLayout).

The level `off` prevents logs from being written into files.

| level   | keyword | color   | log4j key | log4j level | syslog key | syslog level |
| ------- | ------- | ------- | --------- | ----------- | ---------- | ------------ |
| off     |         | default | OFF       | 0           |            |              |
| error   | ERROR   | red     | ERROR     | 200         | err        | 3            |
| warn    | WARN    | yellow  | WARN      | 300         | warning    | 4            |
| info    | INFO    | default | INFO      | 400         | info       | 6            |
| emph    | INFO    | blue    | INFO      | 400         | info       | 6            |
| success | INFO    | green   | INFO      | 400         | info       | 6            |
| debug   | DEBUG   | cyan    | DEBUG     | 500         | debug      | 7            |
