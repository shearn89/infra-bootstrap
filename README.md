# infra-bootstrap
Bootstrap an offline CentOS 7 build environment using Foreman/Puppet 4.

## What it does

This repo helps users set up an offline build environment. It's intended
 to allow you to be able to provision hosts in a short amount of time 
(not including mirror repo time, that could take hours depending on your 
internet connection...)

## How to use it

1. Set `MIRRORPATH` environment variable (defaults to `/var/mirror`).
1. Run `mirror-repos.sh` on an internet-connected Linux machine.
2. Transfer content onto your CDN server.
3. Build Foreman server using `ks-foreman.cfg` kickstart.
4. Run Foreman setup scripts in order.
