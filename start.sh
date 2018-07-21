#!/bin/bash

CRON_OPT="* * * * *"


if [[ -n $CRONTAB ]]; then
    CRON_OPT="${CRONTAB}"
fi



if [ "$1" == "cron_backup" ]; then
    shift
    args="$@"
    echo "${CRON_OPT//\"/} root \
	KEY=$KEY \
	URL=$URL \
	REPO_PATH=REPO_$PATH \
	/start.sh backup $args >> /var/log/cron.log 2>&1" > /etc/cron.d/backup
    chmod 0644 /etc/cron.d/backup
    touch /var/log/cron.log
    cron && tail -f /var/log/cron.log;
fi


if [ "$1" == "backup" ]; then
    mkdir -p $REPO_PATH
    cd $REPO_PATH
    git add *
    git -key=$KEY commit $URL
    echo `date` > /status/backup
elif [ "$1" == "restore" ]; then
    cd $REPO_PATH
    echo $KEY >> $REPO_PATH/key
    git clone $URL -key $REPO_PATH/key
    echo `date` > /status/restore
else
    >&2 echo "You must provide either backup or restore to run this container"
    exit 64
fi
