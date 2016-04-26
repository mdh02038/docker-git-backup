# docker-mysql-backup

Container that backs up MySQL databases to Backblaze. The container overwrites the same Backblaze object every time it is run, it is recommended you turn
versioning on to retain access to previous copies.

There is an existing image available on the public registry at [raquette/docker-mysql-backup](https://registry.hub.docker.com/u/raquette/docker-mysql-backup/).

## Backing up

To backup run once:

    $ docker run -e BB_ACCOUT_ID=accountId -e BB_APPLICATION_KEY=applicationKey -e BB_BUCKET=bucket -e MYSQL_HOST=127.0.0.1 -e MYSQL_USER=root -e MYSQL_PASSWORD=password raquette/docker-mysql-backup backup

You can provide an extra argument with a specific database to backup.

To backup run periodically:
:
    $ docker run -e BB_ACCOUT_ID=accountId -e BB_APPLICATION_KEY=applicationKey -e BB_BUCKET=bucket -e MYSQL_HOST=127.0.0.1 -e MYSQL_USER=root -e MYSQL_PASSWORD=password -e CRONTAB="* * * * *" raquette/docker-mysql-backup cron_backup

You can provide an extra argument with a specific database to backup.

## Restoring

To restore an existing backup run:

    $ docker run -e BB_ACCOUT_ID=accountId -e BB_APPLICATION_KEY=applicationKey -e BB_BUCKET=bucket -e MYSQL_HOST=127.0.0.1 -e MYSQL_USER=root -e MYSQL_PASSWORD=password raquette/docker-mysql-backup restore

It is important to note that if this database already exists on your server, this process will drop it first. You can also provide an extra argument with a specific database to restore.

## Excluding Databases

You can exclude databases from backup/restore by using --exclude.

For example:

	$ docker run -e BB_ACCOUT_ID=accountId -e BB_APPLICATION_KEY=applicationKey -e BB_BUCKET=bucket -e MYSQL_HOST=127.0.0.1 -e MYSQL_USER=root -e MYSQL_PASSWORD=password raquette/docker-mysql-backup --exclude=some_database,another_database restore

## Configuration 

The container can be customized with these environment variables:

Name | Default Value | Description
--- | --- | ---
BB_ACCOUNT_ID | `blank` | Your BackBlaze account Id
BB_APPLICATION_KEY | `blank` | Your BackBlaze application key
MYSQL_HOST | 127.0.0.1 | Address the MySQL server is accessible at
MYSQL_PORT | 3306 | Port the MySQL server is accessible on
MYSQL_USER | root | User to connect as
MYSQL_PASSWORD | `blank` | Password to use when connecting
RESTORE_DB_CHARSET | utf8 | Which charset to recreate the database with
RESTORE_DB_COLLATION | utf8_bin | Which collation to recreate the database with
BB_BUCKET | `blank` | The bucket to write the backup to
BB_PATH | `blank` | The path within the bucket
CRONTAB | `* * * * *` | crontab schedule 
WAIT_FOR_SERVER | `yes` | wait for server connect to be ready [yes,no]
