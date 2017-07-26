---
kind: article
created_at: 2016-10-20 21:03:20 +0000
title: "Controlling a GPIO through an ESP8266-based web server"
tags:
  - electronics
---

It's very hot and humid in our office, and I'd like to be able to turn on the A/C remotely half
a hour before I get there, and do it in a reasonably safe way, viz. without exposing the internal
network to whoever discovers an RCE in the IoT Fad Device of the Week.

I've done this using [ESP8266][] and [MicroPython][] (primarily to avoid dealing with the awkward
Xtensa native code toolchain as well as to avoid parsing HTTP in C).

[esp8266]: https://espressif.com/en/products/hardware/esp8266ex/overview
[micropython]: https://docs.micropython.org/en/latest/esp8266/

The code is as follows:

<%= highlight_code 'python', '/files/esp8266-gpio-ctrl.py' %>

It defines three endpoints: `GET /` that returns status, `POST /on` and `POST /off` that change
the status. All of the endpoints accept an arbitrary query string, and the generated HTML
propagates it to other endpoints, which makes it easy to add authentication using e.g. [Nginx][].

[nginx]: https://nginx.org/

It can be flashed to an ESP8266 module with MicroPython already installed using the following
(very dirty) script:

<% highlight_code 'python', 'flash.py' do %>
#!/usr/bin/env python
# usage: ./flash.py firmware.py
import os, sys
os.system("stty -F /dev/ttyUSB0 115200")
with open(sys.argv[1]) as f:
   code = f.read()
with open('/dev/ttyUSB0', 'w') as f:
   f.write('with open("/main.py", "w") as f: f.write('+repr(code)+')\r\n\r\n')
<% end %>

After verifying that it works, Nginx can be configured such that only requests using a pre-shared
key inside the query string would be passed to the device:

<% highlight_code 'text', 'esp8266-gpio-ctrl.conf' do %>
upstream esp8266-gpio-ctrl {
  server 192.168.1.XXX;
}

server {
  listen [::];
  server_name esp8266-gpio-ctrl.shadycorp.com;
  location / {
    if ($args !~ "[redacted]") {
      return 403;
    }
    proxy_pass http://esp8266-gpio-ctrl;
  }
}
<% end %>

This way, the code running on ESP8266 never sees any untrusted input, and even for requests
with the valid pre-shared key, it ensures that the HTTP requests are well-formed. Nginx can
also provide IPv6 as well as SSL termination; the built-in SSL library on ESP8266 does not
perform certificate validation and is thus useless.
