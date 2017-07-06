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
1. Set `ISONAME` environment variable (defaults to `CentOS-7-x86_64-DVD.iso`.
2. Run `build-cdn-iso.sh` to build a bootable ISO for the CDN.
3. Boot CDN machine using custom ISO.
2. Transfer `MIRRORPATH` content onto your CDN server.
3. Build Foreman server using `ks-foreman.cfg` kickstart.
4. Run Foreman setup scripts in order.
