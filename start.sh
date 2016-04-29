#!/bin/bash

EXCLUDE_OPT=
PASS_OPT=
CRON_OPT="* * * * *"

for i in "$@"; do
    case $i in
        --exclude=*)
        EXCLUDE_OPT="${i#*=}"
        shift
        ;;
        *)
            # unknown option
        ;;
    esac
done

if [[ ${WAIT_FOR_SERVER}x == "yesx" ]]; then
	MYSQL_HOST=$MYSQL_HOST \
	MYSQL_PORT=$MYSQL_PORT \
	MYSQL_USER=$MYSQL_USER \
	/wait.sh
fi

if [[ -n $MYSQL_PASSWORD ]]; then
    PASS_OPT="--password=${MYSQL_PASSWORD}"
fi

if [[ -n $EXCLUDE_OPT ]]; then
    EXCLUDE_OPT="| grep -Ev (${EXCLUDE_OPT//,/|})"
fi

if [ "$1" == "cron_backup" ]; then
    shift
    args="$@"
    echo "$CRON_OPT root \
	BB_ACCOUNT_ID=$BB_ACCOUNT_ID \
	BB_APPLICATION_KEY=$BB_APPLICATION_KEY \
	MYSQL_HOST=$MYSQL_HOST \
	MYSQL_PORT=$MYSQL_PORT \
	MYSQL_USER=$MYSQL_USER \
	MYSQL_PASSWORD=$MYSQL_PASSWORD \
	RESTORE_DB_CHARSET=$RESTORE_DB_CHARSET \
	RESTORE_DB_COLLATION=$RESTORE_DB_COLLATION \
	BB_BUCKET=$BB_BUCKET \
	BB_PATH=$BB_PATH \
	/start.sh backup $args >> /var/log/cron.log 2>&1" > /etc/cron.d/backup
    chmod 0644 /etc/cron.d/backup
    touch /var/log/cron.log
    cron && tail -f /var/log/cron.log;
fi



/usr/local/bin/b2 authorize_account $BB_ACCOUNT_ID $BB_APPLICATION_KEY 

if [ "$1" == "backup" ]; then
    if [ ${BACKUP_AFTER_RESTORE_ONLY}x == 'yesx' ]; then
	if [ ! -f /status/restore ]; then
            >&2 echo "skipping backup operation as container has never been restored"
            exit 64
	fi	
    fi

    if [ -n "$2" ]; then
        databases=$2
    else
        databases=`mysql --user=$MYSQL_USER --host=$MYSQL_HOST --port=$MYSQL_PORT ${PASS_OPT} -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)" ${EXCLUDE_OPT}`
    fi
 
    for db in $databases; do
        echo "dumping $db"

        mysqldump --force --opt --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USER --databases $db ${PASS_OPT} | gzip > "/tmp/$db.gz"

        if [ $? == 0 ]; then
	    /usr/local/bin/b2 upload_file $BB_BUCKET /tmp/$db.gz $BB_PATH/$db.gz

            if [ $? == 0 ]; then
                rm /tmp/$db.gz
            else
                >&2 echo "couldn't transfer $db.gz to S3"
            fi
        else
            >&2 echo "couldn't dump $db"
        fi
    done
    echo `date` > /status/backup
elif [ "$1" == "restore" ]; then
    if [ ${RESTORE_ONCE}x == 'yesx' ]; then
	if [ -f /status/restore ]; then
            >&2 echo "skipping restore operation as container has already been restored"
            exit 64
	fi	
    fi

    if [ -n "$2" ]; then
        archives=$2.gz
    else
        archives=`/usr/local/bin/b2 ls $BB_BUCKET $BB_PATH ${EXCLUDE_OPT}`
    fi

    mkdir -p /tmp/$BB_PATH
    for archive in $archives; do
        tmp=/tmp/$archive

        echo "restoring $archive"
        echo "...transferring"

        /usr/local/bin/b2 download_file_by_name $BB_BUCKET $archive $tmp


        if [ $? == 0 ]; then
            echo "...restoring"
            db=`basename --suffix=.gz $archive`

            if [ -n $MYSQL_PASSWORD ]; then
                yes | mysqladmin --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USER --password=$MYSQL_PASSWORD drop $db

                mysql --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USER --password=$MYSQL_PASSWORD -e "CREATE DATABASE $db CHARACTER SET $RESTORE_DB_CHARSET COLLATE $RESTORE_DB_COLLATION"
                gunzip -c $tmp | mysql --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USER --password=$MYSQL_PASSWORD $db
            else
                yes | mysqladmin --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USER drop $db

                mysql --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USER -e "CREATE DATABASE $db CHARACTER SET $RESTORE_DB_CHARSET COLLATE $RESTORE_DB_COLLATION"
                gunzip -c $tmp | mysql --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USER $db
            fi
        else
            rm $tmp
        fi
    done
    echo `date` > /status/restore
else
    >&2 echo "You must provide either backup or restore to run this container"
    exit 64
fi

/usr/local/bin/b2 clear_account
