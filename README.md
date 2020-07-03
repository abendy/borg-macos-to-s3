# Backup macOS to S3

## Install tooling

```sh
python3 -m pip install --user virtualenv

virtualenv venv
. venv/bin/activate

pip3 install -r requirements.txt

aws configure
```

## Borg

### Install Borg

```sh
. venv/bin/activate

pip3 install -r borg/requirements.txt

git clone git@github.com:abendy/macos-to-s3.git
cd macos-to-s3

mkdir -p /usr/local/var/lib/borg/{cache,security}
```

### Install on remote (remote destination)

```sh
sudo add-apt-repository ppa:costamagnagianfranco/borgbackup
sudo apt update
sudo apt install borgbackup
```

### Key

```sh
mkdir -p keys

sudo ssh-keygen -t ed25519 -C "Borg" -f keys/id_ed25519

sudo chmod 0600 keys/*
sudo chmod 0644 keys/*.pub
```

### Config

[Includes & excludes](https://borgbackup.readthedocs.io/en/stable/usage/help.html#borg-help-patterns)

```sh
cp etc/backup.includes.sample etc/backup.includes

vi etc/backup.includes

cp etc/backup.excludes.sample etc/backup.excludes

vi etc/backup.excludes
```

[Environment variables](https://borgbackup.readthedocs.io/en/stable/usage/general.html#environment-variables)

```sh
cp .env.sample .env

vi .env
```

### Repo (local destination)

[Repository URLs](https://borgbackup.readthedocs.io/en/stable/usage/general.html#repository-urls)

```sh
mkdir -p <repo_location>

borg init --encryption=repokey-blake2 --storage-quota=<size>G <repo_location>
```

### Repo (remote destination)

[Repository URLs](https://borgbackup.readthedocs.io/en/stable/usage/general.html#repository-urls)

```sh
sudo ssh-copy-id -i keys/id_ed25519.pub user@<aws-ec2-instance>.amazonaws.com

borg init --encryption=keyfile-blake2 --storage-quota=<size>G user@<aws-ec2-instance>.amazonaws.com
```

### Backup

```sh
./borg/borg-backup.sh
```

### List all archives in the repository:

```sh
borg list <repo_location>

borg list <repo_location>::<archive_name>
```

### Mount an archive

```sh
borg mount <repo_location>::<archive_name> <extract_path>
```

### Restore an archive

```sh
borg extract <repo_location>::<archive_name>
```

### Delete an archive

```sh
borg delete <repo_location>::<archive_name>
```

***

### Thanks

[SES code](https://github.com/baturorkun/aws-ses-sender)
