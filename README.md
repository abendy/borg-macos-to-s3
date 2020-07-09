# Backup macOS to S3

## Install

### Clone this repository, install virtualenv, init a virtual env and activate it

```sh
git clone git@github.com:abendy/macos-to-s3.git
cd macos-to-s3

python3 -m pip install --user virtualenv
virtualenv venv
. venv/bin/activate

pip3 install -r requirements.txt
```

### Create directories for cache and security

```sh
mkdir -p /usr/local/var/lib/borg/{cache,security}
```

## Key

```sh
mkdir -p keys

sudo ssh-keygen -t ed25519 -C "Borg" -f keys/id_ed25519

sudo chmod 0600 keys/*
sudo chmod 0644 keys/*.pub
```

## Config

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

You could source this from your shell run commands config

```sh
source <path_to>/.env
```

### Setup GPG and Password Store

```sh
brew cask install gpg-suite
brew install pass

pass init <gpg_id>
pass generate borg
pass show borg
```

### Configure AWS CLI with some admin credentials

```sh
aws configure
```


[Repository URLs](https://borgbackup.readthedocs.io/en/stable/usage/general.html#repository-urls)

```sh
mkdir -p <repo_location>

sudo -E borg init --encryption=repokey-blake2 --storage-quota=<size>G <repo_location>
```

## Backup

```sh
sudo -E ./borg-backup.sh
```

## List all archives in the repository:

```sh
sudo -E borg list <repo_location>

sudo -E borg list <repo_location>::<archive_name>
```

## Mount an archive

```sh
sudo -E borg mount <repo_location>::<archive_name> <extract_path>
```

## Restore an archive

```sh
sudo -E borg extract <repo_location>::<archive_name>
```

## Delete an archive

```sh
sudo -E borg delete <repo_location>::<archive_name>
```

***

### Thanks

[SES code](https://github.com/baturorkun/aws-ses-sender)
