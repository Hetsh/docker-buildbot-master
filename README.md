# Buildbot Master
Super small and easy to set up Buildbot Master.

## Running the server
```bash
docker run --detach --name --publish 8010:8010/tcp --publish 9989:9989/tcp buildbot-master hetsh/buildbot-master
```

## Stopping the container
```bash
docker stop buildbot-master
```

## Creating persistent storage
```bash
MP="/path/to/storage"
mkdir -p "$MP"
chown -R 1381:1381 "$MP"
```
`1381` is the numerical id of the user running the server (see Dockerfile).
Start the server with the additional mount flag:
```bash
docker run --mount type=bind,source=/path/to/storage,target=/buildbot-master ...
```

## Configuration
Create an initial configuration file by running:
```bash
docker run ... hetsh/buildbot-master create-master
```
Stick to [Buildbot's documentation](https://docs.buildbot.net/current/manual) for further configuration.

## Automate startup and shutdown via systemd
The systemd unit can be found in my GitHub [repository](https://github.com/Hetsh/docker-buildbot-master).
```bash
systemctl enable buildbot-master.service --now
```
By default, the systemd service assumes `/apps/buildbot/master` for persistent storage and `/etc/localtime` for timezone.
Since this is a personal systemd unit file, you might need to adjust some parameters to suit your setup.

## Fork Me!
This is an open project (visit [GitHub](https://github.com/Hetsh/docker-buildbot-master)).
Please feel free to ask questions, file an issue or contribute to it.