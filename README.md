# Borg

## Install

```sh
brew install borg
brew cask install borgbackup
```

## Key

```sh
mkdir -p /usr/local/etc/borg/keys

sudo ssh-keygen -t ed25519 -C "Borg" -f /usr/local/etc/borg/keys/id_ed25519

sudo chmod 0600 /usr/local/etc/borg/keys/*
sudo chmod 0644 /usr/local/etc/borg/keys/*.pub
```

## Config

```sh
mkdir -p /usr/local/var/lib/borg/{cache,security}
```

## Repo

```sh
mkdir -p <location>

borg init --encryption=repokey-blake2
```

## Backup

```sh
/usr/local/bin/borg-backup
```
