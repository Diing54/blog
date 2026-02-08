+++
date = '2026-02-08T23:44:04+03:00'
draft = false
title = 'Https'
tags = ["security","web"]
+++

I've always assumed HTTPS as "encryption" or "securing" data in a network like many of devopers out there but that's just half of the story.

HTTPS is actually two things combined:
1. Encryption - Securing data so that other people can't read it.
2. Authentication - Proving that the intended server is really who it claims to be. This is the major part of HTTPS according to my experience when I just set up HTTPS in my homelab.

Here is a simple high-level explanation on how HTTPS works.

Lets say I want to login to my facebook page on my browser, I will need to visit https://www.facebook.com/. The server that wants to serve the login page will need to prove that it is the actual facebook server and not someone pretending. The only way to prove this is by using a Certificate. Certificates are are signed and issued by Certificate Authorities that are trusted by most browsers by default. For a server to prove its identity, it shares back its Certificate back to the browser. The browser checks if this Certificate was signed by a trusted Certificate Authority,if yes, trust is earned and a secure tunnel to the server is established. I can now type in my email and password for my facebook page and this data will be encrypted and sent to the facebook servers securely.


### References
- https://diing54.github.io/devops/docs/httphttpsssltls-and-ca/
