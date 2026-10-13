+++
date = '2026-10-13T18:14:11+03:00'
draft = false
title = 'How I Engineered an Automated Event-Driven Deployment for My Homelab'
tags = ["DevOps", "Docker", "GitOps", "Homelab"]
+++

If you run a homelab long enough, you eventually hit a wall with manual repetitive work. My case was manual deployments. For a while, my workflow was standard: write code on my laptop, let GitHub Actions build and push container images to GHCR, SSH into my server, run `git pull` and manually restart the running containers to spin up new images.

It worked pretty well, but it wasn't cloud native. Since my homelab is a Docker Compose setup, I wanted a way to automate container restarts whenever the code changes. I know Kubernetes is built for this using tools like ArgoCD but I am not yet ready to migrate my setup to K8s.

I needed to think of a way to operate within the constraints of Docker Compose.

Here is how I built a secure, automated deployment pipeline using a custom webhook agent, a bash script and Cloudflare Tunnels.

## The Layout
The goal is simple: GitHub needs to tell my Raspberry Pi (server) to update affected applications/services whenever new code is pushed or merged.

![gitopswebhooklayout](/images/gitops_webhook.png)

## Setting Up GitHub Webhook
Everything starts here. In the repository settings under the Webhooks tab, I added a payload URL pointing to my Cloudflare Tunnel endpoint. A secret is required so that GitHub uses it to sign every payload sent, this prevents any random payloads from the internet reaching my server.

I configured the webhook to be triggered only on `push` events, this means whenever a new code is merged or pushed to my homelab repository.

## Ingress
My server sits behind a strict router with zero inbound ports. I have to get the GitHub payload inside and this is where Cloudflare Tunnels magic come into play. I set up `cloudflared` in my server such that when GitHub sends the HTTP POST request, Cloudflare routes it securely down the tunnel and directly to my homelab internal Docker network.

## Execution
The payload is then intercepted by a lightweight Go binary (`adnanh/webhook`) running inside a container in my server. It checks the sign on the payload, verifies it and runs the bash script.

The hardest part was writing this bash script. I encountered a few challenges and this is how I designed the logic:

### 1. Workspace Safety
If I have local changes directly in the server when the script gets executed, I would lose my work since the script pulls the current state of the remote repository. Instead, the script checks for any local changes and stashes them first:

```bash
if [ -n "$(git status --porcelain)" ]; then
    echo "Local uncommitted changes detected. Safely stashing them..."
    git stash push -m "Auto-stash before GitOps webhook sync"
    LOCAL_WORK_STASHED=true
fi
```
Then it pops this stash right back onto the filesystem at the end of the script.

### 2. Container Restart
The script then compares the local commit against the remote to figure out exactly which application's compose file changed:

```bash
CHANGED_APPS=$(git diff --name-only $LOCAL $REMOTE | grep '^apps/' | cut -d/ -f1,2 | sort -u || true)
```
Once it knows which app to deploy, it begins the pull process. Pulling massive images can result to HTTP timeouts either due to my network misbehaving and the affected app can go offline. To achieve zero-downtime, the script separates the pull command and wraps it in a retry loop:

```bash
until [ "$n" -ge 3 ]
do
   set +e
   docker compose pull -q
   PULL_STATUS=$?
   set -e
   
   if [ $PULL_STATUS -eq 0 ]; then
       break
   fi
   
   n=$((n+1))
   sleep 10
done
```
Only if the pull perfectly succeeds does it execute `docker compose up -d` to swap the containers.

### 3. Logging
I can`t blindly sit and trust the script while it is executing in the background. All the logs are piped to a file where I can monitor them in real time:

```bash
exec > >(tee -a /home/astro/homelab/gitops.log) 2>&1
```

## Conclusion
With this setup, my applications silently update themselves in the background matching their states on GitHub. The next step is moving this setup to K3s for true GitOps environment. Until then, everything is working smoothly.





### References
1. Check the bash script on my Homelab repo - [here](https://github.com/Diing54/homelab/blob/main/scripts/gitops-sync.sh)
