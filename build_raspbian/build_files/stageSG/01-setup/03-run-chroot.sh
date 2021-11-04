#! /bin/bash -e
#
# Fix-up SSH
#


# Re-enables older keys for auth to support existing sensorgnome.org keys
echo "    PubkeyAcceptedKeyTypes +ssh-dss" >/etc/ssh/ssh_config

# Install keys for pi user to be able to register with sensorgnome.org
cd /home/pi
mkdir -p .ssh
chmod 700 .ssh
cd .ssh

# Key used to register SG with sensorgnome.org
cat <<'EOF' >id_dsa_factory
-----BEGIN DSA PRIVATE KEY-----
MIIBugIBAAKBgQCv+XPXC3ifNKxqEKg5ndkbGeg4qCzCgteQ+EFd+vtchgGm6F/q
0rhYYDT2/GGwh/Mie9wbS2ALpMkLd/qdO/FAZnJjJ+FgqivV3hhgSw5Ks9uDrXS2
vjDOv+c0RSa3qjfTuNNzVOIcYRoKBNIq1jkSDaXhAGlSZwOqcXqe2vebrwIVAPKA
YswqJuY19R6iha0JQDgp4vkhAoGAA1UfH3XZg8JmR1Ti+b8l0qyM6JPvFXgkcwbP
ty56fg2bSYM5PaO8ypHQcC8dezpJwEdHjBA4IPIAQ43J0WzGmITOmiYY1gLHSkJb
cDt0UGsa+WP8vE8GVyEbON0G42e+YgHtrX6iOIa/YXDM7IVQ3FiioKDJ0ttMH8rT
GBLa9fACgYAHGGYFBmuaYlHCO48EPAmoVBrJsjxWQa5K5MOSJNv6Kh1yW9r21bGw
1K3RWBG4chPN8Grwp3PHDXBcLS+PZbfBEzK8C63ONH+ZpOckHWtQJcGn0N0d6TGq
qgeg+9aSCy/TLUSkcj78wuzfxlIGZ9poYIoelaUD+ykIDXwwbrXiowIUUCKMK4iZ
2RikNPsyiRw5QoHD6mw=
-----END DSA PRIVATE KEY-----
EOF
cat <<'EOF' >id_dsa_factory.pub
ssh-dss AAAAB3NzaC1kc3MAAACBAK/5c9cLeJ80rGoQqDmd2RsZ6DioLMKC15D4QV36+1yGAaboX+rSuFhgNPb8YbCH8yJ73BtLYAukyQt3+p078UBmcmMn4WCqK9XeGGBLDkqz24OtdLa+MM6/5zRFJreqN9O403NU4hxhGgoE0irWORINpeEAaVJnA6pxep7a95uvAAAAFQDygGLMKibmNfUeooWtCUA4KeL5IQAAAIADVR8fddmDwmZHVOL5vyXSrIzok+8VeCRzBs+3Lnp+DZtJgzk9o7zKkdBwLx17OknAR0eMEDgg8gBDjcnRbMaYhM6aJhjWAsdKQltwO3RQaxr5Y/y8TwZXIRs43QbjZ75iAe2tfqI4hr9hcMzshVDcWKKgoMnS20wfytMYEtr18AAAAIAHGGYFBmuaYlHCO48EPAmoVBrJsjxWQa5K5MOSJNv6Kh1yW9r21bGw1K3RWBG4chPN8Grwp3PHDXBcLS+PZbfBEzK8C63ONH+ZpOckHWtQJcGn0N0d6TGqqgeg+9aSCy/TLUSkcj78wuzfxlIGZ9poYIoelaUD+ykIDXwwbrXiow== sg_remote@sensorgnome
EOF

# Add sensorgnome.org to known hosts
cat <<'EOF' >>known_hosts
|1|/dljOHnAaZgOQrHXlcLehforbbo=|HNmWyIsJhgZm5oUhM6CVCTRBQPQ= ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGOjnWXyV0snRoBUV9cMrqZNZMOAzy3BWZbJ7xJLlM8bOt7ZZ7cFpZErWBROUPzOMO1bQAvU9YMwH6fxxEMry+TpHWEBCuMNAxvDsnHJpXTl2pU1FnbgaLpWVMBoqFpmMOIF/+J1G/dEyRTk4n9ZvUvV1Niz0DE5woYiWKGobMixVoT5+IYnpKUNxSykoQM4/5h4xwvvcxvWe1Xw7XWVIAWpYLb6EDcwYjd0OMSepE5o2ZIYYf61RQHJEarXlndXteQK0RDIpvzmiAw0TdCWseF1z6plJ1lf+eCPEf5De3kNBzEsc0dL3TtiOVboRN57rm2hPL3dtnrcFRWkltwAMn
|1|s+ake6Uf9kozcyRl3D6ELSrqrbY=|p5wvi+8ZY+qKqFmarsJI3aMga90= ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGOjnWXyV0snRoBUV9cMrqZNZMOAzy3BWZbJ7xJLlM8bOt7ZZ7cFpZErWBROUPzOMO1bQAvU9YMwH6fxxEMry+TpHWEBCuMNAxvDsnHJpXTl2pU1FnbgaLpWVMBoqFpmMOIF/+J1G/dEyRTk4n9ZvUvV1Niz0DE5woYiWKGobMixVoT5+IYnpKUNxSykoQM4/5h4xwvvcxvWe1Xw7XWVIAWpYLb6EDcwYjd0OMSepE5o2ZIYYf61RQHJEarXlndXteQK0RDIpvzmiAw0TdCWseF1z6plJ1lf+eCPEf5De3kNBzEsc0dL3TtiOVboRN57rm2hPL3dtnrcFRWkltwAMn
EOF

chmod 600 *