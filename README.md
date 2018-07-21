# docker-git-backup

Container that backs up files by commiting them to git archives. 


There is an existing image available on the public registry at [raquette/docker-git-backup](https://registry.hub.docker.com/u/raquette/docker-git-backup/).
## Directory to backup

The directory to backup can be changed to point to an attached volume

## Backing up

To backup run once:

    $ docker run -e KEY=auth-key -e URL=git-repo-url -e REPO_PATH=directory_path raquette/docker-git-backup backup

To backup periodically:

    $ docker run -e KEY=auth-key -e URL=git-repo-url -e REPO_PATH=directory_path -e CRONTAB="* * * * *" raquette/docker-git-backup cron_backup

## Restoring

To restore an existing backup run:

    $ docker run -e KEY=auth-key -e URL=git-repo-url -e REPO_PATH=directory_path raquette/docker-git-backup restore
    
It is important to note that if this repo already exists on your server, a restore will update it.

## Configuration 

The container can be customized with these environment variables:

Name | Default Value | Description
--- | --- | ---
KEY | `blank` | auth key for github
URL | `blank` | url pointing to repo
REPO_PATH | /repo | directory to back up
CRONTAB | `* * * * *` | crontab schedule 

