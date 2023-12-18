%% Logging Example
% Learn how to create and use basic loggers.
% Your path will need to include the parent folder of +mlog.

%% Section 1a Simplest logger
% Create a logger, check the level, and then clear up.
% Configure the logger in the simplest way and then create our logger.
% The logging class contains the user interaction functions.

% Begin by importing the `mlog.logging` class. Now we can access it using just
% `logging`.
import mlog.logging

logging.basicConfig();
logger = mlog.logging.getLogger();
fprintf("Log level is %s\n", logger.level);
logger.error("This should be logged");
logger.info("This should not be logged");
% We finish by clearing up the logger using the logging access-point.
logging.clear();
% After using `clear` the loggers won't work any more.
logger.error("The logger has stopped logging.")

%% Section 1b Alternative to importing
% We can access the logging capability without importing by prefixing
% references with mlog.
mlog.logging.basicConfig();
logger = mlog.logging.getLogger();
fprintf("Log level is %s\n", logger.level);
logger.error("This should be logged");

mlog.logging.clear();

%% Section 2a Getting to know basicConfig
% We can set the level, enable logging to file, and set the log format.
% After running, check that a local file `example.log` has been created.
% Notice how the log messages have gone to two different places: the console
% and a file.
import mlog.logging
logging.basicConfig('level', 'INFO', 'logfile', 'example.log');
logger = logging.getLogger();
fprintf("Log level is %s\n", logger.level);
logger.error("This should be logged");
logger.info("This will now be logged too");

logging.clear();

%% Section 2b Getting to know basicConfig - formatting
% We can use basicConfig to control the formatting of the logs.
% There are many fields you can include in the format string. The format string
% describes the full text that appears in each log - fields, delimiters, and
% any extra content. The fields must be specified using the form `%(name)s`,
% where name is the case-sensitive name given to the field in LogRecord, and
% `s` in this case specifies the string-type formatting. (For numeric fields
% like line number, change this to `d`).
% Do not include anything in the form %(name) that isn't a valid field.
import mlog.logging
formatStr = '%(asctime)s ~ %(filename)s[%(lineno)d]';
logging.basicConfig('level', 'INFO', 'format', formatStr);
logger = logging.getLogger();
logger.warning("This message is not included");

logging.clear();

%% Section 3 LogHandler
% In Section 2 we saw that the log messages were sent to two places.
% This is possible because basicConfig configure the logger to have two
% `LogHandler`s:a StreamHandler for the console output, and a FileHandler for
% logging to file.
% We can set the loggers manually, too.
import mlog.logging mlog.StreamHandler
logger = logging.getLogger();
% Initially there aren't any handlers and so the log messages will not go
% anywhere.
display(logger.handlers);
logger.error("This message won't be seen because there are no handlers");
handler1 = StreamHandler();
logger.addhandler(handler1);
logger.error("Now we have a logger we can see the message");
% We can add another logger with a different format. You can even change how
% the time is represented.
% The handlers have their own log level filter which operate in addition to the
% logger's level. By default they allow all levels.
handler2 = StreamHandler('format', '%(asctime)s %(level)s: %(message)s',...
    'dateFormat', 'yyyy MMM dd - HHmmss', 'level', 'ERROR');
logger.addhandler(handler2);
logger.error("You should see this twice");
logger.warning("This priority will only be logged by one handler");

logging.clear();

%% Section 4 Logging hierarchy
% We can have several loggers at the same time. A logger may have any number of
% handlers, including 0.
% Any logs of sufficient level will be passed to their handlers, and then onto
% their parent.
% The hierarchy is determined by the name property, passed to getLogger().
% If you don't specify a name, the root logger is returned. This is in the
% ancestry tree of all loggers.
% Generations of loggers are dot-separated. A name of "some.logger" is the
% parent to "some.logger.child".
%
% We create a hierarchy of loggers with different levels.

import mlog.logging mlog.StreamHandler mlog.LogLevel
% basicConfig configures the root logger only.
logging.basicConfig('level', 'WARNING');
rootLogger = logging.getLogger();

fatherLogger = logging.getLogger('father');
fatherLogger.level = LogLevel.INFO;

daughterLogger = logging.getLogger('father.daughter');
daughterLogger.level = LogLevel.ALL;

% Check the names given to the loggers
display([rootLogger.name fatherLogger.name daughterLogger.name]);
display([rootLogger.parent fatherLogger.parent.name daughterLogger.parent.name]);

fatherLogger.addhandler(StreamHandler());
daughterLogger.addhandler(StreamHandler());

% Log different levels to demonstrate the filtering effect of the hierarchy.
% Notice the logger name in each log message.
daughterLogger.warning("This message is logged by all loggers");
daughterLogger.info("This message is logged by only father and daughter");
daughterLogger.debug("This message is logged by only daughter");

logging.clear();
