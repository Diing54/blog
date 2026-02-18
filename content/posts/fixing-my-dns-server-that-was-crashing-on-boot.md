+++
date = '2026-02-18T20:21:44+03:00'
draft = false
title = 'Fixing My Dns Server That Was Crashing on Boot'
tags = ["homelab","linux","networking"]
+++

I recently ran into an issue while trying to ssh into my Raspberry Pi which is a dedicated DNS server for my homelab. The dnsmasq server is configured to listen to the Pi's IP for incoming DNS requests. If I restarted the service manually `systemctl restart dnsmasq`, it worked fine. But everytime I rebooted the Pi, the service failed to start. The Pi's IP is mapped into the name prod.homelab and with the DNS server failing to start, the command `ssh astro@prod.homelab` could not work since the client machine could not resolve the name `prod.homelab`. I had to ssh using the IP Address.

## The Problem
Checking the status with `systemctl status dnsmasq` showed this error;

```text
dnsmasq: failed to create listening socket for 192.168.100.56: Cannot assign requested address
FAILED to start up
systemd[1]: dnsmasq.service: Failed with result 'exit-code'.
```

This was when I noticed the issue was about a race condition between the networking system and the dnsmasq service.

My config for the dnsmasq service used `listen-address=192.168.100.56` and when the Pi boots, dnsmasq service starts immediately and tries to bind the IP address it has been instructed to. By this time, my Pi hasn't yet been assigned an IP by the router (I configured Router-based static IP assignment) and the dnsmasq service crashes. The IP assignment was slower than the dnsmasq service.

## The Fix
Instead of binding to a specific IP address which I used before (`listen-address=192.168.100.56`), the solution was to bind the interface and use the `bind-dynamic` directive. This tells the dnsmasq service to start up successfully even if the network isn't yet ready, and just wait for the interface to come online.

```dnsmasq
# OLD (Caused the crash)
# listen-address=127.0.0.1,192.168.100.56

# NEW (The Fix)
# Listen on local machine and the WiFi adapter
interface=lo
interface=wlan0

bind-dynamic
```

The service now starts successfully after a quick reboot.




### References
