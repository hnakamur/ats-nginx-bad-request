# ats-nginx-bad-request

## What is this?

According to the document at [this link](https://docs.trafficserver.apache.org/en/latest/admin-guide/logging/formatting.en.html#network-addresses-ports-and-interfaces), it states that "Cache hits will yield a value of 0".

However, during my experiments with using Traffic Server as a reverse proxy, I have noticed that Traffic Server occasionally sets the values of log fields pqsi and pqsp to 0 for cache miss requests.

This repository is a reproduction of this issue.

The requests were sent like below:

```
hey (HTTP client) -> Apache Traffic Server -> nginx
```

## Prerequisite

Install Docker and make, and make sure you can run docker compose.

## How to run this experiment

```
$ make
```

## Analyze logs

In this experiment, my custom version of [hey](https://github.com/rakyll/hey) is executed with the following command:

```
/go/bin/hey -c 32 -q 8 -z 1s -m PUT -D /src/hex-1KiB.dat -random-request-id http://ats
```

The flags used in the above command are:

-c: concurrency
-q: request rate limit (req/s)
-z: duration
-m: HTTP method
-D: request body file
-random-request-id: add random ID request header X-Request-Id
                    (https://github.com/hnakamur/hey/tree/random_request_id)

The total count of sent requests is 256:

```
$ echo '32 * 8' | bc
256
```

In access logs of nginx and traffic server, the 256 requests were logged.

```
$ wc -l access.log
256 access.log
$ wc -l proxy.ltsv.log
256 proxy.ltsv.log
```

All requests were cache miss according to Via response header values.

```
$ grep -F 'psh_via:http/1.1 traffic_server (ApacheTrafficServer/10.0.0 [uScMs f p eN:t cCMp sS])' proxy.ltsv.log | wc -l
256
```

However, 213 out of 256 requests, the values of `pqsi` and `pqsp` were `0`:

```
$ grep -F 'pqsi:0  pqsp:0' proxy.ltsv.log | wc -l
213
```
