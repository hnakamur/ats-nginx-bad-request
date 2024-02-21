# ats-nginx-bad-request

## What is this?

In my experiment of rate limit of nginx, I found that nginx sometimes sends "400 Bad Request" responses
for seemingly correct requests.

```
hey (HTTP client) -> Apache Traffic Server -> nginx
```

This repository is a repro for this problem.

## Prerequisite

Install Docker and make, and make sure you can run docker compose.

## How to run this experiment

```
$ make
```
