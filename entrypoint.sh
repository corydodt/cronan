#!/bin/sh

set -eu

deterministic_splay=$(( $RANDOM * ${CRONAN_SPLAY} / 32767 ))

# The command we get passed may need cron escaping, so it's simplest
# to just put it into its own shell script and run that with no escaping.
printf "\
#!/bin/sh\n\
splay=%s
if [[ \$splay != 0 ]]; then\n\
    echo INFO: cronan sleep \$splay seconds before run\n\
    sleep \$splay
fi\n\
\n\
exec %s\n" \
    $deterministic_splay "${CRONAN_COMMAND}" > /cronan_command.sh
chmod +x /cronan_command.sh

printf "${CRONAN_TIME_EXPR} /cronan_command.sh\n" > crontab.tmp
crontab crontab.tmp
shred -zu crontab.tmp

exec /usr/sbin/crond -f -d 0
