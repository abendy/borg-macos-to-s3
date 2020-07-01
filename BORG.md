# Borg

## Install Borg

```sh
brew install borg
brew cask install borgbackup

git clone git@github.com:abendy/macos-to-s3.git
cd macos-to-s3

mkdir -p /usr/local/var/lib/borg/{cache,security}
```

## Install on remote (remote destination)

```sh
sudo add-apt-repository ppa:costamagnagianfranco/borgbackup
sudo apt update
sudo apt install borgbackup
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
cp backup.includes.sample backup.includes

vi backup.includes

cp backup.excludes.sample backup.excludes

vi backup.excludes
```

[Environment variables](https://borgbackup.readthedocs.io/en/stable/usage/general.html#environment-variables)

```sh
cp .env.sample .env

vi .env
```

## Repo (local destination)

```sh
mkdir -p <location>

borg init --encryption=repokey-blake2
```

## Repo (remote destination)

```sh
sudo ssh-copy-id -i .keys/id_ed25519.pub ubuntu@ec2-52-87-179-253.compute-1.amazonaws.com

borg init --encryption=keyfile-blake2
```

## Backup

```sh
sudo borg-backup.sh
```
