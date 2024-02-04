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

Running this experiment repeatedly, sometimes you get "400 Bad request" responses:

```
$ sed -n '/^Status code distribution:$/,/^$/p' hey.log
Status code distribution:
  [400]	8 responses
  [405]	248 responses

```

The total count of sent requests is 256:

```
$ echo '32 * 8' | bc
256
$ echo '8 + 248' | bc
256
```

From nginx access.log, it seems nginx treats the middle (not beginning) part of the request body as the request line:

```
$ grep status:400 access.log
time:2024-02-04T03:46:39+00:00	msec:1707018399.270	host:localhost	http_host:-	scheme:http	remote_addr:172.18.0.3	remote_port:45732	remote_user:-	pid:10	conn:14	request:789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef	request_length:0	status:400	bytes_sent:309	body_bytes_sent:157	http_referer:-	http_x_forwarded_for:-	http_x_real_ip:-	realip_remote_addr:172.18.0.3	realip_remote_port:45732	request_time:0.013	ssl_server_name:-	x_request_id:-	request_id:c077fc9a8ffa200f33d57242e5205c62	ua:-
time:2024-02-04T03:46:39+00:00	msec:1707018399.270	host:localhost	http_host:-	scheme:http	remote_addr:172.18.0.3	remote_port:45812	remote_user:-	pid:10	conn:20	request:789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef	request_length:0	status:400	bytes_sent:309	body_bytes_sent:157	http_referer:-	http_x_forwarded_for:-	http_x_real_ip:-	realip_remote_addr:172.18.0.3	realip_remote_port:45812	request_time:0.010	ssl_server_name:-	x_request_id:-	request_id:b6291fa615a0d3e0a1257811cfb0cce4	ua:-
time:2024-02-04T03:46:39+00:00	msec:1707018399.272	host:localhost	http_host:-	scheme:http	remote_addr:172.18.0.3	remote_port:45718	remote_user:-	pid:10	conn:12	request:789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef	request_length:0	status:400	bytes_sent:309	body_bytes_sent:157	http_referer:-	http_x_forwarded_for:-	http_x_real_ip:-	realip_remote_addr:172.18.0.3	realip_remote_port:45718	request_time:0.011	ssl_server_name:-	x_request_id:-	request_id:231e418159830e7ab438bb6220f31c0c	ua:-
time:2024-02-04T03:46:39+00:00	msec:1707018399.273	host:localhost	http_host:-	scheme:http	remote_addr:172.18.0.3	remote_port:45742	remote_user:-	pid:10	conn:15	request:789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef	request_length:0	status:400	bytes_sent:309	body_bytes_sent:157	http_referer:-	http_x_forwarded_for:-	http_x_real_ip:-	realip_remote_addr:172.18.0.3	realip_remote_port:45742	request_time:0.010	ssl_server_name:-	x_request_id:-	request_id:5970dbbce3c903ebefba389fe8998149	ua:-
time:2024-02-04T03:46:39+00:00	msec:1707018399.275	host:localhost	http_host:-	scheme:http	remote_addr:172.18.0.3	remote_port:45820	remote_user:-	pid:10	conn:21	request:789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef	request_length:0	status:400	bytes_sent:309	body_bytes_sent:157	http_referer:-	http_x_forwarded_for:-	http_x_real_ip:-	realip_remote_addr:172.18.0.3	realip_remote_port:45820	request_time:0.011	ssl_server_name:-	x_request_id:-	request_id:0bda5af4a1d6409ac82b41f99f6720f4	ua:-
time:2024-02-04T03:46:39+00:00	msec:1707018399.275	host:localhost	http_host:-	scheme:http	remote_addr:172.18.0.3	remote_port:45690	remote_user:-	pid:11	conn:8	request:789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef	request_length:0	status:400	bytes_sent:309	body_bytes_sent:157	http_referer:-	http_x_forwarded_for:-	http_x_real_ip:-	realip_remote_addr:172.18.0.3	realip_remote_port:45690	request_time:0.006	ssl_server_name:-	x_request_id:-	request_id:8581cefdd505195122dce44c18f7556a	ua:-
time:2024-02-04T03:46:39+00:00	msec:1707018399.275	host:localhost	http_host:-	scheme:http	remote_addr:172.18.0.3	remote_port:45674	remote_user:-	pid:10	conn:3	request:789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef	request_length:0	status:400	bytes_sent:309	body_bytes_sent:157	http_referer:-	http_x_forwarded_for:-	http_x_real_ip:-	realip_remote_addr:172.18.0.3	realip_remote_port:45674	request_time:0.005	ssl_server_name:-	x_request_id:-	request_id:275071060c5f7cde514f1a02a3b374cc	ua:-
time:2024-02-04T03:46:39+00:00	msec:1707018399.275	host:localhost	http_host:-	scheme:http	remote_addr:172.18.0.3	remote_port:45684	remote_user:-	pid:10	conn:5	request:789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef	request_length:0	status:400	bytes_sent:309	body_bytes_sent:157	http_referer:-	http_x_forwarded_for:-	http_x_real_ip:-	realip_remote_addr:172.18.0.3	realip_remote_port:45684	request_time:0.011	ssl_server_name:-	x_request_id:-	request_id:f21b6abb999a981f86c263b249913f71	ua:-
```

The misinterpreted "request line" lengths are:

```
$ grep status:400 access.log | awk -F '\t' '{sub(/request:/, "", $11); print length($11)}'
665
665
665
665
665
665
665
665
```

We focus the first 400 Bad Request response. Its remote port was 45732.
The previous request with remote port 45732 was processed correctly with status 405:

```
$ grep remote_port:45732 access.log | grep -B 1 status:400
time:2024-02-04T03:46:39+00:00	msec:1707018399.257	host:nginx	http_host:nginx	scheme:http	remote_addr:172.18.0.3	remote_port:45732	remote_user:-	pid:10	conn:14	request:PUT / HTTP/1.1	request_length:321	status:405	bytes_sent:362	body_bytes_sent:157	http_referer:-	http_x_forwarded_for:172.18.0.4	http_x_real_ip:-	realip_remote_addr:172.18.0.3	realip_remote_port:45732	request_time:0.117	ssl_server_name:-	x_request_id:066a1a44a1e961068d479205d489ab85	request_id:85dacb407316c0a50b18234f2dfa46b6	ua:hey/0.0.1
time:2024-02-04T03:46:39+00:00	msec:1707018399.270	host:localhost	http_host:-	scheme:http	remote_addr:172.18.0.3	remote_port:45732	remote_user:-	pid:10	conn:14	request:789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef	request_length:0	status:400	bytes_sent:309	body_bytes_sent:157	http_referer:-	http_x_forwarded_for:-	http_x_real_ip:-	realip_remote_addr:172.18.0.3	realip_remote_port:45732	request_time:0.013	ssl_server_name:-	x_request_id:-	request_id:c077fc9a8ffa200f33d57242e5205c62	ua:-
```

traffic server access log:

```
$ grep -E '(x_request_id:066a1a44a1e961068d479205d489ab85|s2:400)' proxy.ltsv.log
timestamp:1707018399.104	host:172.18.0.4	user:-	time:04/Feb/2024:03:46:39 -0000	req:PUT http://nginx/ http/1.1	s1:405	c1:157	s2:405	c2:157	h1:184	h2:206	h3:321	h4:205	xt:0	route:DIRECT	pfs:FIN	ss:FIN	crc:TCP_MISS	chm:MISS	cwr:-	referer:-	psh_via:-	host_header:nginx	x_forwarded_for:-	x_forwarded_proto:-	stms:7	stmsf:0.007  sca:3  surc:0  ssrc:0 	sstc:3	shn:nginx	shi:172.18.0.2	ttms:41	ttmsf:0.041	phn:808deb000372	phi:172.18.0.3	phr:DIRECT	cache_control:-	pqsi:0  pqsp:0	x_request_id:066a1a44a1e961068d479205d489ab85	ua:hey/0.0.1
timestamp:1707018399.231	host:172.18.0.4	user:-	time:04/Feb/2024:03:46:39 -0000	req:PUT http://nginx/ http/1.1	s1:400	c1:157	s2:400	c2:157	h1:184	h2:163	h3:321	h4:152	xt:0	route:DIRECT	pfs:FIN	ss:FIN	crc:TCP_MISS	chm:MISS	cwr:-	referer:-	psh_via:-	host_header:nginx	x_forwarded_for:-	x_forwarded_proto:-	stms:12	stmsf:0.012  sca:3  surc:0  ssrc:0 	sstc:4	shn:nginx	shi:172.18.0.2	ttms:38	ttmsf:0.038	phn:808deb000372	phi:172.18.0.3	phr:DIRECT	cache_control:-	pqsi:0  pqsp:0	x_request_id:371df78553b367dd7b5dc699b920029c	ua:hey/0.0.1
timestamp:1707018399.230	host:172.18.0.4	user:-	time:04/Feb/2024:03:46:39 -0000	req:PUT http://nginx/ http/1.1	s1:400	c1:157	s2:400	c2:157	h1:184	h2:163	h3:321	h4:152	xt:0	route:DIRECT	pfs:FIN	ss:FIN	crc:TCP_MISS	chm:MISS	cwr:-	referer:-	psh_via:-	host_header:nginx	x_forwarded_for:-	x_forwarded_proto:-	stms:13	stmsf:0.013  sca:3  surc:0  ssrc:0 	sstc:4	shn:nginx	shi:172.18.0.2	ttms:40	ttmsf:0.040	phn:808deb000372	phi:172.18.0.3	phr:DIRECT	cache_control:-	pqsi:0  pqsp:0	x_request_id:8ff43075ad0740fba00429aaba8b2efa	ua:hey/0.0.1
timestamp:1707018399.232	host:172.18.0.4	user:-	time:04/Feb/2024:03:46:39 -0000	req:PUT http://nginx/ http/1.1	s1:400	c1:157	s2:400	c2:157	h1:184	h2:163	h3:321	h4:152	xt:0	route:DIRECT	pfs:FIN	ss:FIN	crc:TCP_MISS	chm:MISS	cwr:-	referer:-	psh_via:-	host_header:nginx	x_forwarded_for:-	x_forwarded_proto:-	stms:14	stmsf:0.014  sca:3  surc:0  ssrc:0 	sstc:4	shn:nginx	shi:172.18.0.2	ttms:41	ttmsf:0.041	phn:808deb000372	phi:172.18.0.3	phr:DIRECT	cache_control:-	pqsi:0  pqsp:0	x_request_id:101bfc98d6f27f12f2160054f98ff330	ua:hey/0.0.1
timestamp:1707018399.230	host:172.18.0.4	user:-	time:04/Feb/2024:03:46:39 -0000	req:PUT http://nginx/ http/1.1	s1:400	c1:157	s2:400	c2:157	h1:184	h2:163	h3:321	h4:152	xt:0	route:DIRECT	pfs:FIN	ss:FIN	crc:TCP_MISS	chm:MISS	cwr:-	referer:-	psh_via:-	host_header:nginx	x_forwarded_for:-	x_forwarded_proto:-	stms:14	stmsf:0.014  sca:3  surc:0  ssrc:0 	sstc:4	shn:nginx	shi:172.18.0.2	ttms:42	ttmsf:0.042	phn:808deb000372	phi:172.18.0.3	phr:DIRECT	cache_control:-	pqsi:0  pqsp:0	x_request_id:bf8f269c26916c740447c89db5b2635f	ua:hey/0.0.1
timestamp:1707018399.231	host:172.18.0.4	user:-	time:04/Feb/2024:03:46:39 -0000	req:PUT http://nginx/ http/1.1	s1:400	c1:157	s2:400	c2:157	h1:184	h2:163	h3:321	h4:152	xt:0	route:DIRECT	pfs:FIN	ss:FIN	crc:TCP_MISS	chm:MISS	cwr:-	referer:-	psh_via:-	host_header:nginx	x_forwarded_for:-	x_forwarded_proto:-	stms:16	stmsf:0.016  sca:3  surc:0  ssrc:0 	sstc:4	shn:nginx	shi:172.18.0.2	ttms:44	ttmsf:0.044	phn:808deb000372	phi:172.18.0.3	phr:DIRECT	cache_control:-	pqsi:0  pqsp:0	x_request_id:6bbc8ae1638c566467ae7d17e607b022	ua:hey/0.0.1
timestamp:1707018399.233	host:172.18.0.4	user:-	time:04/Feb/2024:03:46:39 -0000	req:PUT http://nginx/ http/1.1	s1:400	c1:157	s2:400	c2:157	h1:184	h2:163	h3:321	h4:152	xt:0	route:DIRECT	pfs:FIN	ss:FIN	crc:TCP_MISS	chm:MISS	cwr:-	referer:-	psh_via:-	host_header:nginx	x_forwarded_for:-	x_forwarded_proto:-	stms:11	stmsf:0.011  sca:3  surc:0  ssrc:0 	sstc:4	shn:nginx	shi:172.18.0.2	ttms:42	ttmsf:0.042	phn:808deb000372	phi:172.18.0.3	phr:DIRECT	cache_control:-	pqsi:0  pqsp:0	x_request_id:95a88775cbc69a909b322ed804854aee	ua:hey/0.0.1
timestamp:1707018399.231	host:172.18.0.4	user:-	time:04/Feb/2024:03:46:39 -0000	req:PUT http://nginx/ http/1.1	s1:400	c1:157	s2:400	c2:157	h1:184	h2:163	h3:321	h4:152	xt:0	route:DIRECT	pfs:FIN	ss:FIN	crc:TCP_MISS	chm:MISS	cwr:-	referer:-	psh_via:-	host_header:nginx	x_forwarded_for:-	x_forwarded_proto:-	stms:13	stmsf:0.013  sca:3  surc:0  ssrc:0 	sstc:4	shn:nginx	shi:172.18.0.2	ttms:44	ttmsf:0.044	phn:808deb000372	phi:172.18.0.3	phr:DIRECT	cache_control:-	pqsi:0  pqsp:0	x_request_id:fc9931caa275d25668070fbeb6c4b2ce	ua:hey/0.0.1
timestamp:1707018399.231	host:172.18.0.4	user:-	time:04/Feb/2024:03:46:39 -0000	req:PUT http://nginx/ http/1.1	s1:400	c1:157	s2:400	c2:157	h1:184	h2:163	h3:321	h4:152	xt:0	route:DIRECT	pfs:FIN	ss:FIN	crc:TCP_MISS	chm:MISS	cwr:-	referer:-	psh_via:-	host_header:nginx	x_forwarded_for:-	x_forwarded_proto:-	stms:16	stmsf:0.016  sca:3  surc:0  ssrc:0 	sstc:4	shn:nginx	shi:172.18.0.2	ttms:44	ttmsf:0.044	phn:808deb000372	phi:172.18.0.3	phr:DIRECT	cache_control:-	pqsi:0  pqsp:0	x_request_id:6eeb7f6acf5e4fea06090e97b7bfa33d	ua:hey/0.0.1
```

filter access log and tcpdump results with the port 45732:

```
$ ./filter-port.sh 45732
```

According to the following packets captured by tcpdump, it seems that trafficserver sent request line, headers, and body correctly,
but nginx responded with a 400 Bad Request response.

```
$ sed -n '/^12:46:39\.183005/,/^<\/html>$/p' tcpdump-nginx.port45732.log
12:46:39.183005 ?     In  IP (tos 0x0, ttl 64, id 32963, offset 0, flags [DF], proto TCP (6), length 52)
    172.18.0.3.45732 > 172.18.0.2.80: Flags [.], cksum 0x5850 (incorrect -> 0x792f), seq 4701, ack 1449, win 501, options [nop,nop,TS val 948481165 ecr 2789766305], length 0
E..4..@.@.a............P.J.nu.%.....XP.....
8....Ht.
12:46:39.256214 ?     In  IP (tos 0x0, ttl 64, id 32964, offset 0, flags [DF], proto TCP (6), length 373)
    172.18.0.3.45732 > 172.18.0.2.80: Flags [P.], cksum 0x5991 (incorrect -> 0x5c94), seq 4701:5022, ack 1449, win 501, options [nop,nop,TS val 948481238 ecr 2789766305], length 321: HTTP, length: 321
	PUT / HTTP/1.1
	Host: nginx
	User-Agent: hey/0.0.1
	Content-Length: 1024
	Content-Type: text/html
	X-Request-Id: 371df78553b367dd7b5dc699b920029c
	Accept-Encoding: gzip
	Client-ip: 172.18.0.4
	X-Forwarded-For: 172.18.0.4
	Via: http/1.1 traffic_server[8e38d2ba-96f3-40ca-8974-a0df3c1575f3] (ApacheTrafficServer/10.0.0)
	
E..u..@.@.`............P.J.nu.%.....Y......
8....Ht.PUT / HTTP/1.1
Host: nginx
User-Agent: hey/0.0.1
Content-Length: 1024
Content-Type: text/html
X-Request-Id: 371df78553b367dd7b5dc699b920029c
Accept-Encoding: gzip
Client-ip: 172.18.0.4
X-Forwarded-For: 172.18.0.4
Via: http/1.1 traffic_server[8e38d2ba-96f3-40ca-8974-a0df3c1575f3] (ApacheTrafficServer/10.0.0)


12:46:39.258000 ?     In  IP (tos 0x0, ttl 64, id 32965, offset 0, flags [DF], proto TCP (6), length 1076)
    172.18.0.3.45732 > 172.18.0.2.80: Flags [P.], cksum 0x5c50 (incorrect -> 0xa5cf), seq 5022:6046, ack 1449, win 501, options [nop,nop,TS val 948481240 ecr 2789766305], length 1024: HTTP
E..4..@.@.]............P.J..u.%.....\P.....
8....Ht.0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
12:46:39.258026 ?     Out IP (tos 0x0, ttl 64, id 3204, offset 0, flags [DF], proto TCP (6), length 52)
    172.18.0.2.80 > 172.18.0.3.45732: Flags [.], cksum 0x5850 (incorrect -> 0x7330), seq 1449, ack 6046, win 501, options [nop,nop,TS val 2789766422 ecr 948481238], length 0
E..4..@.@............P..u.%..J......XP.....
.Hu.8...
12:46:39.259312 ?     Out IP (tos 0x0, ttl 64, id 3205, offset 0, flags [DF], proto TCP (6), length 361)
    172.18.0.2.80 > 172.18.0.3.45732: Flags [P.], cksum 0x5985 (incorrect -> 0xc5ec), seq 1449:1758, ack 6046, win 501, options [nop,nop,TS val 2789766423 ecr 948481238], length 309: HTTP, length: 309
	HTTP/1.1 400 Bad Request
	Server: nginx/1.25.3
	Date: Sun, 04 Feb 2024 03:46:39 GMT
	Content-Type: text/html
	Content-Length: 157
	Connection: close
	
	<html>
	<head><title>400 Bad Request</title></head>
	<body>
	<center><h1>400 Bad Request</h1></center>
	<hr><center>nginx/1.25.3</center>
	</body>
	</html>
E..i..@.@............P..u.%..J......Y......
.Hu.8...HTTP/1.1 400 Bad Request
Server: nginx/1.25.3
Date: Sun, 04 Feb 2024 03:46:39 GMT
Content-Type: text/html
Content-Length: 157
Connection: close

<html>
<head><title>400 Bad Request</title></head>
<body>
<center><h1>400 Bad Request</h1></center>
<hr><center>nginx/1.25.3</center>
</body>
</html>
```

filter nginx debug log with 'HTTP/1.1 400 Bad Request':

```
$ grep 'HTTP/1\.1 400 Bad Request' nginx-error.log
2024/02/04 03:46:39 [debug] 10#10: *14 HTTP/1.1 400 Bad Request
2024/02/04 03:46:39 [debug] 10#10: *20 HTTP/1.1 400 Bad Request
2024/02/04 03:46:39 [debug] 10#10: *12 HTTP/1.1 400 Bad Request
2024/02/04 03:46:39 [debug] 10#10: *15 HTTP/1.1 400 Bad Request
2024/02/04 03:46:39 [debug] 10#10: *21 HTTP/1.1 400 Bad Request
2024/02/04 03:46:39 [debug] 10#10: *5 HTTP/1.1 400 Bad Request
2024/02/04 03:46:39 [debug] 11#11: *8 HTTP/1.1 400 Bad Request
2024/02/04 03:46:39 [debug] 10#10: *3 HTTP/1.1 400 Bad Request
```

We focus the first 400 Bad Request and its pid is 10 and connection ID is 14.
See nginx debug log for that connection:

```
$ grep -F '10#10: *14' nginx-error.log | grep -B 30 'HTTP/1\.1 400 Bad Request'
2024/02/04 03:46:39 [debug] 10#10: *14 recv: eof:0, avail:-1
2024/02/04 03:46:39 [debug] 10#10: *14 recv: fd:17 680 of 680
2024/02/04 03:46:39 [debug] 10#10: *14 recv: avail:665
2024/02/04 03:46:39 [debug] 10#10: *14 http finalize request: -4, "/?" a:1, c:1
2024/02/04 03:46:39 [debug] 10#10: *14 set http keepalive handler
2024/02/04 03:46:39 [debug] 10#10: *14 http close request
2024/02/04 03:46:39 [debug] 10#10: *14 http log handler
2024/02/04 03:46:39 [debug] 10#10: *14 free: 00005611E7BD9A50, unused: 0
2024/02/04 03:46:39 [debug] 10#10: *14 free: 00005611E7BDAA60, unused: 1858
2024/02/04 03:46:39 [debug] 10#10: *14 free: 00005611E7B38490
2024/02/04 03:46:39 [debug] 10#10: *14 hc free: 0000000000000000
2024/02/04 03:46:39 [debug] 10#10: *14 hc busy: 0000000000000000 0
2024/02/04 03:46:39 [debug] 10#10: *14 reusable connection: 1
2024/02/04 03:46:39 [debug] 10#10: *14 event timer del: 17: 968372029
2024/02/04 03:46:39 [debug] 10#10: *14 event timer add: 17: 65000:968432146
2024/02/04 03:46:39 [debug] 10#10: *14 post event 00005611E7B9CC60
2024/02/04 03:46:39 [debug] 10#10: *14 delete posted event 00005611E7B9CC60
2024/02/04 03:46:39 [debug] 10#10: *14 http keepalive handler
2024/02/04 03:46:39 [debug] 10#10: *14 malloc: 00005611E7BDFEC0:1024
2024/02/04 03:46:39 [debug] 10#10: *14 recv: eof:0, avail:665
2024/02/04 03:46:39 [debug] 10#10: *14 recv: fd:17 665 of 1024
2024/02/04 03:46:39 [debug] 10#10: *14 recv: avail:0
2024/02/04 03:46:39 [debug] 10#10: *14 reusable connection: 0
2024/02/04 03:46:39 [debug] 10#10: *14 posix_memalign: 00005611E7BE02D0:4096 @16
2024/02/04 03:46:39 [debug] 10#10: *14 event timer del: 17: 968432146
2024/02/04 03:46:39 [debug] 10#10: *14 http process request line
2024/02/04 03:46:39 [info] 10#10: *14 client sent invalid method while reading client request line, client: 172.18.0.3, server: localhost, request: "789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
2024/02/04 03:46:39 [debug] 10#10: *14 http finalize request: 400, "?" a:1, c:1
2024/02/04 03:46:39 [debug] 10#10: *14 http special response: 400, "?"
2024/02/04 03:46:39 [debug] 10#10: *14 http set discard body
2024/02/04 03:46:39 [debug] 10#10: *14 HTTP/1.1 400 Bad Request
```
