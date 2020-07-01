# Backup macOS to S3

## Install tooling

```sh
python3 -m pip install --user virtualenv

virtualenv venv
. venv/bin/activate

pip3 install -r requirements.txt

aws configure
```

***

### Thanks

[SES code](https://github.com/baturorkun/aws-ses-sender)
