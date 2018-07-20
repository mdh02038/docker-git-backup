# docker-git-backup

Container that backs up files by commiting them to git archives. 


There is an existing image available on the public registry at [raquette/docker-git-backup](https://registry.hub.docker.com/u/raquette/docker-git-backup/).
## Directory to backup

The directory to backup can be changed to point to an attached volume

## Backing up

To backup run once:

    $ docker run -e KEY=ssh-private-key -e URL=git-repo-url -e PATH=directory_path raquette/docker-git-backup backup

To backup run periodically:

    $ docker run -e KEY=ssh-private-key -e URL=git-repo-url -e PATH=directory_path -e CRONTAB="* * * * *" raquette/docker-git-backup backup

## Restoring

To restore an existing backup run:

    $ docker run -e KEY=ssh-private-key -e URL=git-repo-url -e PATH=directory_path raquette/docker-git-backup restore
    
It is important to note that if this database already exists on your server, this process will update it.

By default the container will wait for the mysql server to be up. To disable this set the env variable WAIT_FOR_SERVER=no .

## Configuration 

The container can be customized with these environment variables:

Name | Default Value | Description
--- | --- | ---
KEY | `blank` | ssh private key for git repo
URL | `blank` | url pointing to repo
PATH | /repo | directory to back up
CRONTAB | `* * * * *` | crontab schedule 

