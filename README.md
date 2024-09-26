# cronan
Cronan the schedularian: run a job in a container as simply as possible

## A baseline container

Cronan is available as an 8MB container image based on Alpine Linux.
You can use it as the baseline for a timed job.

## Environment

The container running Cronan recognizes these environment variables:

<dl>
<dt>CRONAN_COMMAND</dt>
<dd>(Required)

The command to run. This should be a real command, not a shell builtin,
but you are free to run a quoted command with the shell such as "sh -c ..."

If you require other shells or specific software, you are encouraged
to install it in your downstream images.
</dd>

<dt>CRONAN_TIME_SPEC</dt>
<dd>(Optional; default "0 1 * * *" _i.e._ 1:00am UTC)

A crontab-format time specification in the usual 5-field format. 

A [reference](https://www.man7.org/linux/man-pages/man5/crontab.5.html) may help.
</dd>

<dt>CRONAN_SPLAY</dt>
<dd>(Optional; default 0)

This sets a random interval in seconds. Cronan chooses a random
number between 0 and `$CRONAN_SPLAY`. It will wait this many seconds
after the scheduled time to run the command.

The random number is remembered from the moment the container starts up,
so the job always waits the same interval until the container is replaced.

Use this to prevent "thundering herd" situations when your jobs on multiple
devices all run at the exact same time.

Example: Your backup jobs on multiple devices all run after 2am. To prevent
them all from running at exactly the same time, set:

    CRONAN_TIME_SPEC="0 2 * * *"
    CRONAN_SPLAY=3600

These jobs will then start between 2am and 3am, randomly chosen on
each machine. On a particular device, if the backup job runs at 2:21am
the first time, it will continue to run at 2:21 every day until the
container is replaced.
</dd>


