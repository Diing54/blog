+++
date = '2026-04-14T11:48:47+03:00'
draft = false
title = 'Stop Running Docker Containers as Root'
tags = ["docker","security","linux"]
+++

You've probably been running containers the wrong way like me a while ago but still don't know it yet. Processes inside a container run as `root` user by default. Here is why this is a security risk and how to fix it.

## Shared Kernel
Unlike Virtual Machines, Docker containers share your host machine's kernel. The `root` user inside your container is basically the same `root` user on your actual computer.

If an attacker manages to exploit a vulnerability in your containerized app and escapes the container, they land on your host system with `root` permissions.

I have containerized a program called [yt-dlp](https://github.com/yt-dlp/yt-dlp) which is a command line tool that is used to download YouTube videos. Initially, I ran the container as `root`. This can be seen from the Dockerfile I used to build its image;

```YAML
FROM ubuntu:24.04

WORKDIR /mydir

RUN apt-get update && apt-get install -y curl python3 ffmpeg
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
RUN chmod a+x /usr/local/bin/yt-dlp

ENTRYPOINT ["/usr/local/bin/yt-dlp"]
```
> If someone injects a bad code in one of yt-dlp packages, the blast radius includes my machine. A malicious process can modify files in my computer especially if there are bind mounts.

## The Fix
Instead of letting our container run as `root` by default, we need to bake an uprevileged user directly into the image. Here is the new Dockerfile;

```YAML
FROM ubuntu:24.04
WORKDIR /mydir

RUN apt-get update && apt-get install -y curl python3 ffmpeg
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
RUN chmod a+x /usr/local/bin/yt-dlp

# 1. Create a standard, restricted user
RUN useradd -m appuser

# 2. Switch to the new user
USER appuser

# 3. Execute the app
ENTRYPOINT ["/usr/local/bin/yt-dlp"]
```
- After the line `USER appuser`, all root privileges are dropped. Any command that follows, including `ENTRYPOINT` that actually runs the application, will be executed by the restricted `appuser`.



### References
- https://medium.com/@tanmayrane209/why-you-should-never-run-containers-as-root-07d1fa1127d5
