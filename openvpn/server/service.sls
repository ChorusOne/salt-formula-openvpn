{% from "openvpn/map.jinja" import server with context %}
{%- if server.enabled %}

include:
- openvpn.common

net.ipv4.ip_forward:
  sysctl.present:
  - value: 1

/etc/openvpn/server.conf:
  file.managed:
  - source: salt://openvpn/files/server.conf
  - template: jinja
  - mode: 600
  - require:
    - pkg: openvpn_packages
  - watch_in:
    - service: openvpn_service

/etc/openvpn/ipp.txt:
  file.managed:
  - source: salt://openvpn/files/ipp.txt
  - template: jinja
  - mode: 600
  - require:
    - pkg: openvpn_packages
  - require_in:
    - service: openvpn_service

{%- if tunnel.ssl.get('engine', 'default') == 'default' %}

/etc/openvpn/ssl/server.crt:
  file.managed:
  - source: salt://{{ server.pkipath }}/{{ server.ssl.authority }}/certs/{{ server.ssl.certificate }}.cert.pem
  - require:
    - file: openvpn_ssl_dir
  - watch_in:
    - service: openvpn_service

/etc/openvpn/ssl/server.key:
  file.managed:
  - source: salt://{{ server.pkipath }}/{{ server.ssl.authority }}/certs/{{ server.ssl.certificate }}.key.pem
  - require:
    - file: openvpn_ssl_dir
  - watch_in:
    - service: openvpn_service

/etc/openvpn/ssl/ca.crt:
  file.managed:
  - source: salt://{{ server.pkipath }}/{{ server.ssl.authority }}/{{ server.ssl.authority }}-chain.cert.pem
  - require:
    - file: openvpn_ssl_dir
  - watch_in:
    - service: openvpn_service

{%- endif %}

openvpn_generate_dhparams:
  cmd.run:
  - name: openssl dhparam -out /etc/ssl/dhparams.pem 2048
  - creates: /etc/ssl/dhparams.pem
  - require:
    - pkg: nginx_packages
  - watch_in:
    - service: openvpn_service

{%- endif %}
