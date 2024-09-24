FROM alpine:3.20

ENV CRONAN_COMMAND="/bin/echo boop"

# default: every day at 1am
ENV CRONAN_TIME_EXPR="0 1 * * *"

# This is a random interval in seconds 0<=s<=CRONAN_SPLAY; the
# job will sleep s seconds before running. s is chosen when
# the container starts and is stable until the container is
# removed.
# default: no splay (job runs exactly when scheduled).
ENV CRONAN_SPLAY=0

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
