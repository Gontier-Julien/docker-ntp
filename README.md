## About this container

[![Docker Pulls](https://img.shields.io/docker/pulls/snowy68/ntp.svg?logo=docker&label=pulls&style=for-the-badge&color=0099ff&logoColor=ffffff)](https://hub.docker.com/r/snowy68/ntp/)
[![Docker Stars](https://img.shields.io/docker/stars/snowy68/ntp.svg?logo=docker&label=stars&style=for-the-badge&color=0099ff&logoColor=ffffff)](https://hub.docker.com/r/snowy68/ntp/)
[![GitHub Stars](https://img.shields.io/github/stars/gontier-julien/docker-ntp.svg?logo=github&label=stars&style=for-the-badge&color=0099ff&logoColor=ffffff)](https://github.com/gontier-julien/docker-ntp)
[![Apache licensed](https://img.shields.io/badge/license-Apache-blue.svg?logo=apache&style=for-the-badge&color=0099ff&logoColor=ffffff)](https://raw.githubusercontent.com/gontier-julien/docker-ntp/master/LICENSE)

This container runs [chrony](https://chrony.tuxfamily.org/) on [Alpine Linux](https://alpinelinux.org/).
>This container is a fork of [cturra docker-ntp](https://github.com/cturra/docker-ntp), but that allow you to configure chrony with a config file and rtcsync.

[chrony](https://chrony.tuxfamily.org) is a versatile implementation of the Network Time Protocol (NTP). It can synchronise the system clock with NTP servers, reference clocks (e.g. GPS receiver), and manual input using wristwatch and keyboard. It can also operate as an NTPv4 (RFC 5905) server and peer to provide a time service to other computers in the network.


## Supported Architectures

Architectures officially supported by this Docker container. Simply pulling this container from [Docker Hub](https://hub.docker.com/r/snowy68/ntp) should retrieve the correct image for your architecture.

![Linux x86-64](https://img.shields.io/badge/linux/amd64-green?style=flat-square)
![ARMv8 64-bit](https://img.shields.io/badge/linux/arm64-red?style=flat-square)


## How to Run this container

### With the Docker CLI

Pull and run -- it's this simple.

```
# pull from docker hub
$> docker pull snowy68/ntp

# run ntp
$> docker run --name=ntp            \
              --restart=always      \
              --detach              \
              --publish=123:123/udp \
              --cap-add=SYS_TIME    \
              snowy68/ntp

# OR run ntp with higher security
$> docker run --name=ntp                           \
              --restart=always                     \
              --detach                             \
              --publish=123:123/udp                \
              --cap-add=SYS_TIME                   \
              --read-only                          \
              --tmpfs=/etc/chrony:rw,mode=1750     \
              --tmpfs=/run/chrony:rw,mode=1750     \
              --tmpfs=/var/lib/chrony:rw,mode=1750 \
              snowy68/ntp
```


### With Docker Compose

Using the docker-compose.yml file included in this git repo, you can build the container yourself (should you choose to).
*Note: this docker-compose files uses the `3.9` compose format, which requires Docker Engine release 19.03.0+

```
# run ntp
$> docker compose up -d ntp

# (optional) check the ntp logs
$> docker compose logs ntp
```

### From a Local command line

Using the vars file in this git repo, you can update any of the variables to reflect your
environment. Once updated, simply execute the build then run scripts.

```
# build ntp
$> ./build.sh

# run ntp
$> ./run.sh
```


## Info on NTP Servers

By default, this container uses CloudFlare's (time.cloudflare.com), SIDN Labs (ntppool1.time.nl,ntppool2.time.nl) and Netnod (nts.netnod.se).
They all use NTS by default for security. And i highly encourage to use NTS NTP servers when possible.

## Chronyd Options

### No Client Log (noclientlog)

This is optional and not enabled by default. If you remove the hash sign (`#`) before the `noclientlog` option, in the chrony.conf fill then it will be configured to:

> Specifies that client accesses are not to be logged. Normally they are logged, allowing statistics to
> be reported using the clients command in chronyc. This option also effectively disables server support
> for the NTP interleaved mode.


## Logging

By default, this project logs informational messages to stdout, which can be helpful when running the
ntp service. If you'd like to change the level of log verbosity, pass the `LOG_LEVEL` environment
variable to the container, specifying the level (`#`) when you first start it. This option matches
the chrony `-L` option, which support the following levels can to specified: 0 (informational), 1
(warning), 2 (non-fatal error), and 3 (fatal error).

Feel free to check out the project documentation for more information at:

 * https://chrony.tuxfamily.org/doc/4.1/chronyd.html


## Setting your timezone

By default the UTC timezone is used, however if you'd like to adjust your NTP server to be running in your
local timezone, all you need to do is provide a `TZ` environment variable following the standard TZ data format.
As an example, using `docker-compose.yaml`, that would be look like this if you were located in Vancouver, Canada:

```yaml
  ...
  environment:
    - TZ=America/Vancouver
    ...
```

## Testing your NTP Container

From any machine that has `ntpdate` you can query your new NTP container with the follow
command:

```
$> ntpdate -q <DOCKER_HOST_IP>
```


Here is a sample output from my environment:

```
$> ntpdate -q 10.13.13.9
server 10.13.1.109, stratum 4, offset 0.000642, delay 0.02805
14 Mar 19:21:29 ntpdate[26834]: adjust time server 10.13.13.109 offset 0.000642 sec
```


If you see a message, like the following, it's likely the clock is not yet synchronized.
You should see this go away if you wait a bit longer and query again.
```
$> ntpdate -q 10.13.13.9
server 10.13.13.9, stratum 16, offset 0.005689, delay 0.02837
11 Dec 09:47:53 ntpdate[26030]: no server suitable for synchronization found
```

To see details on the ntp status of your container, you can check with the command below
on your docker host:
```
$> docker exec ntp chronyc tracking
Reference ID    : D8EF2300 (time1.google.com)
Stratum         : 2
Ref time (UTC)  : Sun Mar 15 04:33:30 2020
System time     : 0.000054161 seconds slow of NTP time
Last offset     : -0.000015060 seconds
RMS offset      : 0.000206534 seconds
Frequency       : 5.626 ppm fast
Residual freq   : -0.001 ppm
Skew            : 0.118 ppm
Root delay      : 0.022015510 seconds
Root dispersion : 0.001476757 seconds
Update interval : 1025.2 seconds
Leap status     : Normal
```


Here is how you can see a peer list to verify the state of each ntp source configured:
```
$> docker exec ntp chronyc sources
210 Number of sources = 2
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^+ time.cloudflare.com           3  10   377   404   -623us[ -623us] +/-   24ms
^* time1.google.com              1  10   377  1023   +259us[ +244us] +/-   11ms
```


Finally, if you'd like to see statistics about the collected measurements of each ntp
source configured:
```
$> docker exec ntp chronyc sourcestats
210 Number of sources = 2
Name/IP Address            NP  NR  Span  Frequency  Freq Skew  Offset  Std Dev
==============================================================================
time.cloudflare.com        35  18  139m     +0.014      0.141   -662us   530us
time1.google.com           33  13  128m     -0.007      0.138   +318us   460us
```


Are you seeing messages like these and wondering what is going on?
```
$ docker logs -f ntps
[...]
2021-05-25T18:41:40Z System clock wrong by -2.535004 seconds
2021-05-25T18:41:40Z Could not step system clock
2021-05-25T18:42:47Z System clock wrong by -2.541034 seconds
2021-05-25T18:42:47Z Could not step system clock
```

---
Buy the original creator of this project a Coffee!
<a href="https://www.buymeacoffee.com/cturra" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-yellow.png" alt="Buy Me A Coffee" height="41" width="174"></a>
