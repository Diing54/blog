+++
date = '2026-04-25T11:31:26+03:00'
draft = false
title = 'Scaling My Homelab'
tags = ["Homelab", "Devops", "Docker", "GitOps"]
+++
In my last post, I wrote how I containerized this blog application. Previously, I used GitHub pages to serve it but now it exists as an artifact and needs a container runtime for it to run. I decided to deploy it on my Raspberry Pi. To expose it to the internet, I registered a domain via Cloudflare and configured a [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/) which routes traffic down to my infrastructure securely without exposing any ports.

Now, I have deployed 2 self-hosted applications directly to the Pi. The first one is [**Linkding**](https://github.com/sissbruecker/linkding), a bookmark manager to keep track of resources I come across online, and [**Homepage**](https://github.com/gethomepage/homepage), a customizable dashboard plugged to the Docker daemon for me to view the live metrics of apps running in my homelab. These apps are also exposed to the internet via the same Cloudflare tunnel and registered using subdomains from cloudiing.com. I can now access what is running in my homelab remotely with proper authentication required. Below is my current homepage;

![Homepage](/images/homepage.png)

The goal for this homelab is for it to be **GitOps purposed**.

> **GitOps** is a set of practices for managing infrastructure and application configurations using Git repositories as the single source of truth. --- Red Hat.

I am not there yet fully GitOps but I have started implementing it. I discovered [**Renovate**](https://docs.renovatebot.com/), an automated dependency update tool that scans code repos and automatically creates PRs for outdated images for apps running in my homelab. Instead of manually looking for software updates, the bot does this automatically and opens a Pull Request in my homelab repo. I then read the release notes and I can choose to merge and pull down the new code to the Pi.

I have found self-hosting to be actually a hobby. It's fun running and managing apps in your own hardware sitting on your desk. I hope to push this homelab further to the point where I will be simulating enterprise-grade infrastructure using Kubernetes and learn more from it.



### References
