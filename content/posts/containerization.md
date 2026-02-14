+++
date = '2026-02-14T21:27:43+03:00'
draft = false
title = 'Containerization'
tags = ["linux","docker"]
+++
It has been a few days so far learning about containers and I'm fascinated by the advances they bring in the tech industry. Containers revolutionalized the development, testing and deployment of applications.

Before containers, teams would develop applications locally on their machines and ship the application to the operations team. Developers needed to specify the dependancies together with their versions and environment configurations for this application to run successfully on other machines e.g the production servers. This would sometimes be a lot of work writing all the requirements needed for a specific application to run and on the other end, the operations team would make mistakes in configuring the environment and the app fails to run. This would lead to conflicts between the two teams with the developer saying "It was working on my end". With containers, teams utilize an image which is a portable package which has all the requirements required to run an application and it is spun up with a container.

## What is a Container
In my own technical terms, a container is just a linux process with a set of kernel features applied to it. These kernel features are restrictions of this process such as what it can see, what it can touch and what system resources it can use. These restrictions are enforced by;
1. Namespaces - What this process can see
2. cgroups - Managing or limiting the resource usage of this process
3. Filesystem Isolation - Its own filesystem which its child processes will reference to


If we strip off these restrictions, we remain with just a chroot - a shell command that changes the apparent root directory of the current running process and its children.

Docker just automates the development of a container and adds other features such images, portable packaging and a friendly interface for manipulating these containers.

I came through this post on X and its more accurate in some senses

![X post](/blog/images/screenshot-20260214-224654.png)

Docker containers therefore bring a standardized portable package/image that includes everything needed to run an application including the application code. 



### References

1. Read more abouth containers and docker from my Kasten (https://diing54.github.io/devops/docs/containerization-fundamentals/)
