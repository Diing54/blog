+++
date = '2026-04-19T14:04:35+03:00'
draft = false
title = 'Dockerized My Blog Setup'
tags = ["devops", "docker", "ci/cd", "blog"]
+++

After finishing a comprehensive Docker course, I felt comfortable with container primitives and the security practices around it.

But tutorials only get you so far. To internalize these concepts and deepen my understanding, I decided to containerize my personal blog.

My blog is already built with [Hugo](https://github.com/gohugoio/hugo) and uses the Papermod theme. Before, I just relied on a standard GitHub Action that compiled the static site and deployed it directly to GitHub Pages and it worked perfectly fine.

I wanted to transition from this static deployment to a fully containerized artifact. By packaging the blog into a Docker image and storing it to a [Registry](https://www.redhat.com/en/topics/cloud-native-apps/what-is-a-container-registry), I achieve a few things;

1. **Environment Agnosticism:** The container runs exactly the same on my laptop or any other machine whether it's my homelab server or in a cloud VPS.
2. **Immutability:** Every version of my blog application is tagged and stored.
3. **Practice:** I wanted to experiment with this application container fundamentals, starting from the Dockerfile multi-stage builds, security practices (non-root containers) to CI/CD automation.

### How I Implemented this
#### 1. Dockerfile
I created a Dockerfile at the root directory of my blog repository. To keep the final image lightweight and secure, I used a **multi-stage** build;

```dockerfile
FROM hugomods/hugo:debian-exts AS builder

ARG HUGO_BASEURL="http://localhost:8080/"

WORKDIR /app

COPY . .

RUN hugo --minify -b ${HUGO_BASEURL}

FROM nginxinc/nginx-unprivileged:alpine

COPY default.conf /etc/nginx/conf.d/default.conf

COPY --from=builder /app/public /usr/share/nginx/html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
```
- **Stage 1:** Uses the official `hugomods/hugo:debian-exts` image to compile the Markdown files into HTML by runnig `hugo --minify`.
- **Stage 2:** Uses an unprivileged Nginx image to serve the HTML content. This image drops root permissions and runs the container safely.

#### 2. Nginx Configuration
Hugo generates "pretty URLs" (where `/posts/my-post/` maps to an `index.html` file) and custom `404.html` pages. Out of the box, Nginx doesn't know how to route these properly. I wrote a custom `default.conf` to handle the routing gracefully:

```nginx
server {
    
    listen 8080;
    server_name localhost;

    root /usr/share/nginx/html;
    index index.html index.htm;

    # Handle Hugo's pretty URLs
    location / {
        try_files $uri $uri/ =404;
    }

    error_page 404 /404.html;
    location = /404.html {
        internal;
    }
}
```
#### 3. CI/CD Pipeline
I replaced my old GitHub Pages workflow with a Docker release pipeline. On every merge to `main`, or whenever I push a semantic version tag like `v1.0.0`, a GitHub Action spins up. It checks code, logs into GHCR, extracts metadata for tagging, builds and pushes the image.

I also added a `.dockerignore` file, basically a `.gitignore` for the Docker daemon, which prevents bloated local directories like `.git` from slowing down the build context.

When I was testing the image locally, I ran into a problem. Nginx was serving raw the HTML files without any styling and I found the issue. I never knew the Papermod theme was being tracked as a [submodule](https://github.blog/open-source/git/working-with-submodules/). By default, the directories where submodules are attached are always empty when the repo is cloned. All these months I had an empty folder locally for the Papermod theme. My blog application worked fine since the GitHub Actions runner fetched the theme and deployed it to GitHub Pages;

```YAML
steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          submodules: recursive
```
> A `git clone` command leaves submodule directories completely empty to save bandwidth. To get them instantly, you run `git submodule update --init --recursive`.


### References
1. https://github.com/Diing54/blog
