# Borg

## Install Borg

```sh
brew install borg
brew cask install borgbackup


cp borg-backup.sh /usr/local/bin/
git clone git@github.com:abendy/macos-to-s3.git
cd macos-to-s3

mkdir -p /usr/local/var/lib/borg/{cache,security}
```

## Key

```sh
mkdir -p .keys

sudo ssh-keygen -t ed25519 -C "Borg" -f .keys/id_ed25519

sudo chmod 0600 .keys/*
sudo chmod 0644 .keys/*.pub
```

## Config

[Includes & excludes](https://borgbackup.readthedocs.io/en/stable/usage/help.html#borg-help-patterns)

```sh
cp backup.includes.sample /usr/local/etc/borg/backup.includes

vi /usr/local/etc/borg/backup.includes

cp backup.excludes.sample /usr/local/etc/borg/backup.excludes

vi /usr/local/etc/borg/backup.excludes
```

[Environment variables](https://borgbackup.readthedocs.io/en/stable/usage/general.html#environment-variables)

```sh
cp .env.sample /usr/local/etc/borg/.env

vi /usr/local/etc/borg/.env
```

## Repo

```sh
mkdir -p <location>

borg init --encryption=repokey-blake2
```

## Backup

```sh
sudo /usr/local/bin/borg-backup.sh
```

***

### Thanks

[SES code](https://github.com/baturorkun/aws-ses-sender)
