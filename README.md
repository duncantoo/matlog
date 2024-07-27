# matlog

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![View matlog on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://uk.mathworks.com/matlabcentral/fileexchange/156642-matlog)

Use `matlog` for customisable logging within MATLAB styled on the Python module [`logging`](https://docs.python.org/3/library/logging.html).

## Setup
Download and place the `+matlog` folder in your project or library.

The parent folder must be in your MATLAB path, as explained [here](https://uk.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html#brfynt_-3).

## Quickstart

Use `logging.basicConfig` for simple configuration.

### Set log level
```matlab
import matlog.logging
logging.basicConfig('level', 'INFO');
logger = logging.getLogger();
logger.info('hello world!');
```
⏎
```
2023-12-19 12:37:12.430 - root - INFO    - hello world!
```

### Customise the logging format

Use format-strings with field names in parentheses to control how your messages are represented.
```matlab
import matlog.logging
logging.basicConfig('format', '%(level)s ~ PID %(process)06d ~ %(message)s');
logger = logging.getLogger();
logger.warning('The quick brown fox');
```
⏎
```
WARNING ~ PID 016181 ~ The quick brown fox
```

You can inspect valid fields with `logging.formatFields`.

### Log to file

Specify the `logfile` to create or overwrite the target path.
```matlab
import matlog.logging
logging.basicConfig('logfile', 'example.log');
logger = logging.getLogger();
logger.warning('hello world!');
```
⏎
`example.log`
```
2023-12-19 12:37:12.430 - root - WARNING - hello world!
```
This will also log to the console output.

### Clean up

Use `logging.clear()` to stop any future logging from existing `Logger` instances.

## Special characters

To log certain escape characters such as `'%'` and `'\'` you should follow advice from
[MATLAB Operators and Special Characters](https://uk.mathworks.com/help/matlab/matlab_prog/matlab-operators-and-special-characters.html)
, entering them as `'%%'` and `'\\'` respectively.

For example, to log `'100% complete'`, enter instead
```matlab
import matlog.logging
logging.basicConfig('level', 'INFO');
logger = logging.getLogger();
logger.info('100%% complete');
```
⏎
```
2023-12-19 12:37:12.430 - root - INFO - 100% complete
```

You can alternatively make use of string formatting using:
```matlab
logger.info('%s', '100% complete');
```

## Advanced features

### `LogHandler`

The `LogHandler` gives access to:
- Formatting logs
- Formatting datetimes
- Logging to stdout or stderr
- Logging to multiple places simultaneously

Earlier we saw enabling the `logfile` in `basicConfig` results in messages being logged to two places.

`basicConfig` created two `LogHandler`s for the logger: a `StreamHandler` for the console output, and a `FileHandler` for the file.

The `LogHandler`s are responsible for formatting and handling the messages. By creating them manually we can control behaviour more closely.

```matlab
import matlog.logging matlog.StreamHandler
logger = logging.getLogger();
% Initially there aren't any handlers and so the log messages will not go
% anywhere.
logger.error("This message won't be seen because there are no handlers");
% Set IO stream 2 for stderr
handler1 = StreamHandler(2);
logger.addHandler(handler1);
logger.error("Now we have a logger we can see the message");
% We can add another logger with a different format. You can even change how
% the time is represented.
% The handlers have their own log level filter which operate in addition to the
% logger's level. By default they allow all levels.
% By default StreamHandlers log to stdout.
handler2 = StreamHandler('format', '%(asctime)s %(level)s: %(message)s',...
    'dateFormat', 'yyyy MMM dd - HHmmss', 'level', 'ERROR');
logger.addHandler(handler2);
logger.error("You should see this twice");
logger.warning("This priority will only be logged by one handler");
```
⏎ `console` (leading dashes are for markdown colouring only to distinguish stderr from stdout)
```diff
- 2023-12-19 13:17:27.175 - root - ERROR   - Now we have a logger we can see the message
- 2023-12-19 13:17:27.188 - root - ERROR   - You should see this twice
  2023 Dec 19 - 131727 ERROR: You should see this twice
- 2023-12-19 13:17:27.196 - root - WARNING - This priority will only be logged by one handler
```

### `Logger`

`Loggers` allow you to log differently across your codebase, including
- Controlling the name attached to logs
- Setting different levels
- Send logs to different places

We can have several loggers at the same time. A logger may have any number of
handlers, including 0.
Any logs of sufficient level will be passed to their handlers, and then onto
their parent.

The hierarchy is determined by the name property, passed to `getLogger()`.
If you don't specify a name, the root logger is returned. This is in the
ancestry tree of all loggers.

Generations of loggers are dot-separated. A name of "some.logger" is the
parent to "some.logger.child".

We create a hierarchy of loggers with different levels.

```matlab
import matlog.logging matlog.StreamHandler matlog.LogLevel
% basicConfig configures the root logger only.
rootLogger = logging.getLogger();
rootLogger.level = LogLevel.WARNING;

fatherLogger = logging.getLogger('father');
fatherLogger.level = LogLevel.INFO;

daughterLogger = logging.getLogger('father.daughter');
daughterLogger.level = LogLevel.ALL;

% root logs to stderr and the others to stdout.
rootLogger.addHandler(StreamHandler(2));
fatherLogger.addHandler(StreamHandler());
daughterLogger.addHandler(StreamHandler());

% Log different levels to demonstrate the filtering effect of the hierarchy.
% Notice the logger name in each log message.
daughterLogger.warning("This message is logged by all loggers");
daughterLogger.info("This message is logged by only father and daughter");
daughterLogger.debug("This message is logged by only daughter");
```
⏎ `console`
```diff
  2023-12-19 13:30:25.401 - father.daughter - WARNING - This message is logged by all loggers
  2023-12-19 13:30:25.401 - father - WARNING - This message is logged by all loggers
- 2023-12-19 13:30:25.401 - root - WARNING - This message is logged by all loggers
  2023-12-19 13:30:25.414 - father.daughter - INFO    - This message is logged by only father and daughter
  2023-12-19 13:30:25.414 - father - INFO    - This message is logged by only father and daughter
  2023-12-19 13:30:25.421 - father.daughter - DEBUG   - This message is logged by only daughter
```

<img src="logo.png" alt="image" width="400" height="auto">
