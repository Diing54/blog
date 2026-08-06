+++
date = '2026-08-05T20:43:16+03:00'
draft = false
title = 'Current State of My Homelab: 17 Containers'
tags = ["homelab", "docker", "linux", "security", "containers"]
+++

Today, while doing my daily maintainance tasks for my homelab, I had to pause and reminisce how far I came running and managing my homelab. A year ago, this was just an idea and I was always reading about other people's blog about their homelabs. Today, I run my own and it has become a very important part of my digital life.

My setup isn't some massive server rack you would see on YouTube with some fancy RGB lighting. It's a single Raspberry Pi 5 (8GB variant), sitting on my desk running debian linux. Right now, it's spinning 17 containers and acting as the backbone for my digital life. It's not perfect, definitely not enterprise-grade, but it is my safe playing ground for learning cloud-native infrastructure.

Here is a peek of what I'm running, what my current workflows actually looks like, and the problems I've dealt with lately.

### The Stack
I am heavily focused on privacy, knowledge management and archiving since I'm always actively learning.

 - **Paperless-ngx:** This is the heaviest thing I'm running. It OCRs and indexes all my documents, backed by Postgres and Redis.
 - **DevOps Wiki:** These are my personal technical notes rendered by [Quartz](https://quartz.jzhao.xyz/), an open-source static-site generator that converts my Markdown files into a website. I love taking notes because I can later come back to them when I need to remember something or simply update them.
 - **Wallabag:** This is an app I use for saving long-form articles so I can read them later. It extracts all the contents from the web so it doesn't matter if the original source is deleted, I will still have my own copy locally.
 - **Crumbs:** This is a lightweight app I use for short note taking. It comes with a nice web interface for viewing all your short notes.
 - **Linkding:** A bookmark manager I use for saving links.
 - **DevLog:** This is a custom application I built from scratch. It's an activity tracker where I log my daily activities.
 - **Vaultwarden:** A password manager. Since it's self-hosted, it has forced me to take my infrastructure seriously. You don't wanna have someone break into your homelab and access this. I have proper security decisions around this app together with backup solutions which I will talk about in another blog.
 - **Blog:** My blog page [cloudiing.com](https://cloudiing.com/)
 - **PairDrop:** A tool I use frequently to share files across my devices.
 - **Homepage:** This is a nice dashboard where I view the entire state of my Homelab and everything running in it. I can access it from anywhere and be able to monitor my homelab remotely.

![Homepage2](/images/homepage2.png)

All applications and services are dockerized and sit behind a Cloudflare Tunnel. No forwarded ports from my router and the hardware doesn't listen on the public web. Cloudlfare does all the heavy lifting i.e handles the SSL and routes traffic straight into the Docker networks.

### Deployment Pipeline
If you look at my homelab repo, I have Renovate Bot that scans all my `docker-compose.yaml` files. Whenever a new image tag drops for any app or service running, Renovate automatically creates a Pull Request. I then manually review the changes and merge them into `main`. To actually deploy the update, I have to ssh into the hardware and navigate to my homelab directory, and run `git pull` to bring down the updated code to the raspberry pi. Then I run `docker compose down` on the affected apps and `docker compose up -d` to spin the containers backup with the new images.

My infrastructure is defined as code in a repo. The repo shows what is currently running on my desk, that is one step towards [GitOps](https://www.redhat.com/en/topics/devops/what-is-gitops).

### Challenges
Every homelabber must go through some problems along the way, no one escapes that. Here are some of the issues I faced recently:

#### Named Volume vs Bind Mount
When I first deployed the Crumbs container, I mapped the storage in my Docker Compose file using `crumbs_data:/data`. I expected a data folder to appear in the app's directory so I could see it and back it up. It didn't. I spent so much time looking for my database files and I even had to go through Crumb's official documentation before realizing the difference between a Docker Named Volume and a Bind Mount. Because I didn't use a relative path (./crumbs_data:data), Docker took control of the storage and buried it deep inside the root filesystem at `/var/lib/docker/volumes`. My obejctive was to not commit this data on GitHub and I noticed it was even untracked by git when this storage is managed by Docker. I just left it that way.

#### CI/CD
I wrote a GitHub Actions workflow to build the Docker image for my DevOps wiki. It was painfully slow. I eventually realized that because the Pi is ARM64, GitHub’s x86 runners were using QEMU to emulate an ARM processor during the npm build step. I had to rewrite the Dockerfile to force BuildKit to use the runner's native architecture (--platform=$BUILDPLATFORM), and only cross-compile the final Nginx layer. Build time was cut by 50% from 4 minutes to 2 minutes.

### What's Next
Right now I have just gotten into learning Kubernetes, specifically k3s. My next goal is to migrate from this Docker Compose set up to Kubernetes. For now my homelab just works fine.





### References
1. https://github.com/Diing54/homelab
