# install
sudo su -

yum install python3 -y

pip3 install pip -U
pip install gunicorn[gevent]
pip install vm-booking-app

mkdir -p /app/vm-booking-app/
cp wsgi.py /app/vm-booking-app/wsgi.py
cat << EOF | sudo tee /app/vm-booking-app/wsgi.py
from vm_booking_api import create_app

app = create_app()
EOF

cat << EOF | sudo tee /app/vm-booking-app/gunicorn.envfile
DB_USERNAME=`aws --region=us-west-1 ssm get-parameter --name "vm_booking_app.db_username" --output text --query Parameter.Value`
DB_PASSWORD=`aws --region=us-west-1 ssm get-parameter --name "vm_booking_app.db_password" --with-decryption --output text --query Parameter.Value`
DB_NAME='vm_booking'
DB_HOST=`aws --region=us-west-1 ssm get-parameter --name "vm_booking_app.db_host" --output text --query Parameter.Value`
DB_PORT='5432'
FLASK_ENV='production'
APP_VERSION=`pip show vm-booking-app | grep Version | cut -d " " -f 2`
EOF

cp gunicorn.service /etc/systemd/system/gunicorn.service

cat << EOF | sudo tee /etc/systemd/system/gunicorn.service
[Unit]
Description=gunicorn daemon
# Requires=gunicorn.socket
After=network.target

[Service]
Type=notify
# the specific user that our service will run as
User=ec2-user
Group=ec2-user
# another option for an even more restricted service is
# DynamicUser=yes
# see http://0pointer.net/blog/dynamic-users-with-systemd.html
RuntimeDirectory=gunicorn
WorkingDirectory=/app/vm-booking-app
ExecStart=/usr/local/bin/gunicorn --worker-class gevent --workers 2 --bind 0.0.0.0:5000 wsgi:app --max-requests 10000 --timeout 5 --keep-alive 5 --log-level 'info' --access-logfile '-' --log-syslog
EnvironmentFile=/app/vm-booking-app/gunicorn.envfile
ExecReload=/bin/kill -s HUP $MAINPID
KillMode=mixed
TimeoutStopSec=5
PrivateTmp=true
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=vm-booking

[Install]
WantedBy=multi-user.target
EOF

cat << EOF | sudo tee /etc/systemd/system/gunicorn.socket
Description=gunicorn socket

[Socket]
ListenStream=/run/gunicorn.sock
# Our service won't need permissions for the socket, since it
# inherits the file descriptor by socket activation
# only the nginx daemon will need access to the socket
SocketUser=ec2-user
# Optionally restrict the socket permissions even more.
# SocketMode=600

[Install]
WantedBy=sockets.target
EOF

systemctl daemon-reload

systemctl enable --now gunicorn.service
systemctl stop --now gunicorn.service
systemctl start --now gunicorn.service
systemctl status gunicorn.service
systemctl restart gunicorn.service

systemctl enable --now gunicorn.socket
systemctl disable --now gunicorn.socket
systemctl stop --now gunicorn.socket


sudo -u ec2-user curl --unix-socket /run/gunicorn.sock http


# update

pip install --no-cache-dir vm-booking-app -U
APP_VERSION=`pip show vm-booking-app | grep Version | cut -d " " -f 2`
sed -i -r "s/^(APP_VERSION=).*/\1$APP_VERSION/" /app/vm-booking-app/gunicorn.envfile
systemctl restart gunicorn.service

