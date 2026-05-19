+++
date = '2026-05-19T20:08:40+03:00'
draft = false
title = 'Thinking About Podman (My Docker Daemon Crashed)'
tags = ["homelab", "docker", "podman"]
+++
A couple of days ago, my homelab infrastructure went down. Running `docker ps` and seeing nothing. This happened on my Raspberry Pi that was running 11 containers that crashed with exit code 139. At this exact moment, I assumed a reboot or an Out-of-Memory (OOM) might have caused the issue. I checked the uptime of the hardware and there were no reboots at the time the containers crashed. Ram usage was normal too.

### The Problem
I then checked the `journalctl logs` of the docker service and found the issue:

```bash
May 17 15:35:29 prod dockerd[1087]: SIGSEGV: segmentation violation
May 17 15:35:29 prod dockerd[1087]: PC=0xaaaab3b59970 m=8 sigcode=1 addr=0x3ffc3d33a0
May 17 15:35:29 prod dockerd[1087]: runtime.adjustpointers(...)
May 17 15:35:29 prod dockerd[1087]: runtime.copystack(...)
```
Docker is written in Go and uses a background process, `dockerd`, to manage containers. The above logs show that the linux kernel threw a [Segmentation Fault(SIGSEGV)](https://oneuptime.com/blog/post/2026-02-08-how-to-fix-docker-container-immediately-exiting-with-code-139/view) which happens when a process tries to read or write to a memory address that has not been allocated to it and most of the times, it's a bug in Go's runtime. The Segmentation Fault killed the Docker Daemon.

Docker operates on a client-server architecture and the containers are dependent on that daemon. When `dockerd` crashes, it drags down every single container running.

### Solution
I researched about this issue and I found that you can mitigate this by adding `"live-restore": true` to `daemon.json` file, which tells Docker to leave containers running if the daemon restarts.

### Podman Switch ?
Dealing with this crash made me think about **Podman**. For now, atleast I have surface-level knowledge about it. It is daemonless so there is no single point of failure like in Docker. Podman talks to the Linux kernel directly to spin up container processes. Podman also runs containers rootless by default which is a great security feature.

This daemonless setup is appealing to me, but I need to learn more about it.

### Conclusion
My homelab is back online under Docker and the incident was a reminder of how single points of failure behave in production. Docker is a great tool but I will likely start experimenting my self-hosted applications with Podman and see the results.



### References
1. https://oneuptime.com/blog/post/2026-02-08-how-to-fix-docker-container-immediately-exiting-with-code-139/view
