# Borg

## Install

```sh
brew install borg
brew cask install borgbackup

git clone git@github.com:abendy/borg-macos-to-s3.git
cd borg-macos-to-s3

cp borg-backup.sh /usr/local/bin/

mkdir -p /usr/local/var/lib/borg/{cache,security}
```

## Key

```sh
mkdir -p /usr/local/etc/borg/{keys}

sudo ssh-keygen -t ed25519 -C "Borg" -f /usr/local/etc/borg/keys/id_ed25519

sudo chmod 0600 /usr/local/etc/borg/keys/*
sudo chmod 0644 /usr/local/etc/borg/keys/*.pub
```

## Config

[Excludes](https://borgbackup.readthedocs.io/en/stable/usage/help.html#borg-help-patterns)

[Environment variables](https://borgbackup.readthedocs.io/en/stable/usage/general.html#environment-variables)

```sh
cp backup.excludes.sample /usr/local/etc/borg/backup.excludes

vi /usr/local/etc/borg/backup.excludes

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
