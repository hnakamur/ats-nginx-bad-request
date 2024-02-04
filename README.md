# ats-nginx-bad-request

```
$ sed -n '/^Status code distribution:$/,/^$/p' hey.log
Status code distribution:
  [400] 1 responses
  [405] 2047 responses

```

```
$ grep status:400 access.log
time:2024-02-03T02:14:30+00:00	msec:1706926470.271	host:localhost	http_host:-	scheme:http	remote_addr:172.18.0.3	remote_port:59166	remote_user:-	pid:11	conn:16	request:789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef	request_length:0	status:400	bytes_sent:309	body_bytes_sent:157	http_referer:-	http_x_forwarded_for:-	http_x_real_ip:-	realip_remote_addr:172.18.0.3	realip_remote_port:59166	request_time:0.001	ssl_server_name:-	x_request_id:-	request_id:e48e4cdbc8bdf4a1db9a0f485c16dbab	ua:-
```

```
$ grep -E '(x_request_id:94b2dc2ede5892895245185f6fe69ea6|s2:400)' proxy.ltsv.log
timestamp:1706926468.371	host:172.18.0.4	user:-	time:03/Feb/2024:02:14:28 -0000	req:PUT http://nginx/ http/1.1	s1:405	c1:157	s2:405	c2:157	h1:184	h2:211	h3:321	h4:205	xt:0	route:DIRECT	pfs:FIN	ss:FIN	crc:TCP_MISS	chm:MISS	cwr:-	referer:-	psh_via:-	host_header:nginx	x_forwarded_for:-	x_forwarded_proto:-	stms:0	stmsf:0.000  sca:3  surc:0  ssrc:0 	sstc:0	shn:nginx	shi:172.18.0.2	ttms:28	ttmsf:0.028	phn:45f7837f9d75	phi:172.18.0.3	phr:DIRECT	cache_control:-	pqsi:172.18.0.3  pqsp:59166	x_request_id:17ff8deded34353604e41d634866cad6	ua:hey/0.0.1
timestamp:1706926470.239	host:172.18.0.4	user:-	time:03/Feb/2024:02:14:30 -0000	req:PUT http://nginx/ http/1.1	s1:405	c1:157	s2:405	c2:157	h1:184	h2:206	h3:321	h4:205	xt:0	route:DIRECT	pfs:FIN	ss:FIN	crc:TCP_MISS	chm:MISS	cwr:-	referer:-	psh_via:-	host_header:nginx	x_forwarded_for:-	x_forwarded_proto:-	stms:0	stmsf:0.000  sca:3  surc:0  ssrc:0 	sstc:65	shn:nginx	shi:172.18.0.2	ttms:0	ttmsf:0.000	phn:45f7837f9d75	phi:172.18.0.3	phr:DIRECT	cache_control:-	pqsi:0  pqsp:0	x_request_id:94b2dc2ede5892895245185f6fe69ea6	ua:hey/0.0.1
timestamp:1706926470.269	host:172.18.0.4	user:-	time:03/Feb/2024:02:14:30 -0000	req:PUT http://nginx/ http/1.1	s1:400	c1:157	s2:400	c2:157	h1:184	h2:163	h3:321	h4:152	xt:0	route:DIRECT	pfs:FIN	ss:FIN	crc:TCP_MISS	chm:MISS	cwr:-	referer:-	psh_via:-	host_header:nginx	x_forwarded_for:-	x_forwarded_proto:-	stms:1	stmsf:0.001  sca:3  surc:0  ssrc:0 	sstc:66	shn:nginx	shi:172.18.0.2	ttms:1	ttmsf:0.001	phn:45f7837f9d75	phi:172.18.0.3	phr:DIRECT	cache_control:-	pqsi:0  pqsp:0	x_request_id:db4ee38db81471edc253dc6ec130a0ba	ua:hey/0.0.1
```

```
$ grep remote_port:59166 access.log | grep -B 1 status:400
time:2024-02-03T02:14:30+00:00	msec:1706926470.270	host:nginx	http_host:nginx	scheme:http	remote_addr:172.18.0.3	remote_port:59166	remote_user:-	pid:11	conn:16	request:PUT / HTTP/1.1	request_length:321	status:405	bytes_sent:362	body_bytes_sent:157	http_referer:-	http_x_forwarded_for:172.18.0.4	http_x_real_ip:-	realip_remote_addr:172.18.0.3	realip_remote_port:59166	request_time:0.031	ssl_server_name:-	x_request_id:94b2dc2ede5892895245185f6fe69ea6	request_id:e5400d5575ffa5971701868f4d88d48b	ua:hey/0.0.1
time:2024-02-03T02:14:30+00:00	msec:1706926470.271	host:localhost	http_host:-	scheme:http	remote_addr:172.18.0.3	remote_port:59166	remote_user:-	pid:11	conn:16	request:789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef	request_length:0	status:400	bytes_sent:309	body_bytes_sent:157	http_referer:-	http_x_forwarded_for:-	http_x_real_ip:-	realip_remote_addr:172.18.0.3	realip_remote_port:59166	request_time:0.001	ssl_server_name:-	x_request_id:-	request_id:e48e4cdbc8bdf4a1db9a0f485c16dbab	ua:-
```

```
$ grep x_request_id:17ff8deded34353604e41d634866cad6 access.log
time:2024-02-03T02:14:28+00:00	msec:1706926468.399	host:nginx	http_host:nginx	scheme:http	remote_addr:172.18.0.3	remote_port:59166	remote_user:-	pid:11	conn:16	request:PUT / HTTP/1.1	request_length:321	status:405	bytes_sent:362	body_bytes_sent:157	http_referer:-	http_x_forwarded_for:172.18.0.4	http_x_real_ip:-	realip_remote_addr:172.18.0.3	realip_remote_port:59166	request_time:0.000	ssl_server_name:-	x_request_id:17ff8deded34353604e41d634866cad6	request_id:1313cbcd2c9b8fa8132ae6f1fcfade31	ua:hey/0.0.1
```


```
$ sed -n '4514,4642p' tcpdump-nginx.port59166.log
11:14:30.239841 ?     In  IP (tos 0x0, ttl 64, id 32015, offset 0, flags [DF], proto TCP (6), length 373)
    172.18.0.3.59166 > 172.18.0.2.80: Flags [P.], cksum 0x5991 (incorrect -> 0x77a5), seq 87426:87747, ack 23531, win 501, options [nop,nop,TS val 856552221 ecr 2697837403], length 321: HTTP, length: 321
	PUT / HTTP/1.1
	Host: nginx
	User-Agent: hey/0.0.1
	Content-Length: 1024
	Content-Type: text/html
	X-Request-Id: 94b2dc2ede5892895245185f6fe69ea6
	Accept-Encoding: gzip
	Client-ip: 172.18.0.4
	X-Forwarded-For: 172.18.0.4
	Via: http/1.1 traffic_server[6a63287b-2805-4b50-9c5c-1b1e53df1e38] (ApacheTrafficServer/10.0.0)
	
E..u}.@.@.dJ...........P..i&........Y......
3......[PUT / HTTP/1.1
Host: nginx
User-Agent: hey/0.0.1
Content-Length: 1024
Content-Type: text/html
X-Request-Id: 94b2dc2ede5892895245185f6fe69ea6
Accept-Encoding: gzip
Client-ip: 172.18.0.4
X-Forwarded-For: 172.18.0.4
Via: http/1.1 traffic_server[6a63287b-2805-4b50-9c5c-1b1e53df1e38] (ApacheTrafficServer/10.0.0)


11:14:30.239880 ?     Out IP (tos 0x0, ttl 64, id 17412, offset 0, flags [DF], proto TCP (6), length 414)
    172.18.0.2.80 > 172.18.0.3.59166: Flags [P.], cksum 0x59ba (incorrect -> 0x8313), seq 23531:23893, ack 87747, win 1338, options [nop,nop,TS val 2697837403 ecr 856552221], length 362: HTTP, length: 362
	HTTP/1.1 405 Not Allowed
	Server: nginx/1.25.3
	Date: Sat, 03 Feb 2024 02:14:30 GMT
	Content-Type: text/html
	Content-Length: 157
	Connection: keep-alive
	x_request_id: 94b2dc2ede5892895245185f6fe69ea6
	
	<html>
	<head><title>405 Not Allowed</title></head>
	<body>
	<center><h1>405 Not Allowed</h1></center>
	<hr><center>nginx/1.25.3</center>
	</body>
	</html>
E...D.@.@..,.........P........jg...:Y......
...[3...HTTP/1.1 405 Not Allowed
Server: nginx/1.25.3
Date: Sat, 03 Feb 2024 02:14:30 GMT
Content-Type: text/html
Content-Length: 157
Connection: keep-alive
x_request_id: 94b2dc2ede5892895245185f6fe69ea6

<html>
<head><title>405 Not Allowed</title></head>
<body>
<center><h1>405 Not Allowed</h1></center>
<hr><center>nginx/1.25.3</center>
</body>
</html>

11:14:30.239899 ?     In  IP (tos 0x0, ttl 64, id 32016, offset 0, flags [DF], proto TCP (6), length 396)
    172.18.0.3.59166 > 172.18.0.2.80: Flags [P.], cksum 0x59a8 (incorrect -> 0x4372), seq 87747:88091, ack 23531, win 501, options [nop,nop,TS val 856552221 ecr 2697837403], length 344: HTTP
E...}.@.@.d2...........P..jg........Y......
3......[0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef01234567
11:14:30.270116 ?     In  IP (tos 0x0, ttl 64, id 32017, offset 0, flags [DF], proto TCP (6), length 373)
    172.18.0.3.59166 > 172.18.0.2.80: Flags [P.], cksum 0x5991 (incorrect -> 0x66d3), seq 88091:88412, ack 23893, win 501, options [nop,nop,TS val 856552252 ecr 2697837403], length 321: HTTP, length: 321
	PUT / HTTP/1.1
	Host: nginx
	User-Agent: hey/0.0.1
	Content-Length: 1024
	Content-Type: text/html
	X-Request-Id: db4ee38db81471edc253dc6ec130a0ba
	Accept-Encoding: gzip
	Client-ip: 172.18.0.4
	X-Forwarded-For: 172.18.0.4
	Via: http/1.1 traffic_server[6a63287b-2805-4b50-9c5c-1b1e53df1e38] (ApacheTrafficServer/10.0.0)
	
E..u}.@.@.dH...........P..k....T....Y......
3..<...[PUT / HTTP/1.1
Host: nginx
User-Agent: hey/0.0.1
Content-Length: 1024
Content-Type: text/html
X-Request-Id: db4ee38db81471edc253dc6ec130a0ba
Accept-Encoding: gzip
Client-ip: 172.18.0.4
X-Forwarded-For: 172.18.0.4
Via: http/1.1 traffic_server[6a63287b-2805-4b50-9c5c-1b1e53df1e38] (ApacheTrafficServer/10.0.0)


11:14:30.270188 ?     In  IP (tos 0x0, ttl 64, id 32018, offset 0, flags [DF], proto TCP (6), length 1076)
    172.18.0.3.59166 > 172.18.0.2.80: Flags [P.], cksum 0x5c50 (incorrect -> 0x1b34), seq 88412:89436, ack 23893, win 501, options [nop,nop,TS val 856552252 ecr 2697837403], length 1024: HTTP
E..4}.@.@.a............P..m....T....\P.....
3..<...[0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
11:14:30.270198 ?     Out IP (tos 0x0, ttl 64, id 17413, offset 0, flags [DF], proto TCP (6), length 52)
    172.18.0.2.80 > 172.18.0.3.59166: Flags [.], cksum 0x5850 (incorrect -> 0xe57e), seq 23893, ack 89436, win 1406, options [nop,nop,TS val 2697837434 ecr 856552221], length 0
E..4D.@.@............P.....T..q....~XP.....
...z3...
11:14:30.270955 ?     Out IP (tos 0x0, ttl 64, id 17414, offset 0, flags [DF], proto TCP (6), length 361)
    172.18.0.2.80 > 172.18.0.3.59166: Flags [P.], cksum 0x5985 (incorrect -> 0x4052), seq 23893:24202, ack 89436, win 1406, options [nop,nop,TS val 2697837434 ecr 856552221], length 309: HTTP, length: 309
	HTTP/1.1 400 Bad Request
	Server: nginx/1.25.3
	Date: Sat, 03 Feb 2024 02:14:30 GMT
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
E..iD.@.@.._.........P.....T..q....~Y......
...z3...HTTP/1.1 400 Bad Request
Server: nginx/1.25.3
Date: Sat, 03 Feb 2024 02:14:30 GMT
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
