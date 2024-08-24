#!/bin/bash

set -e

piuser=$1
pigroup=$2

[[ -z $pigroup ]] && pigroup="$piuser"
cat >/etc/systemd/system/bacnet_client.service <<EOF
[Unit]
Description=The Bacnet client queries the device's network interfaces for bacnet network data.
After=multi-user.target syslog.target network.target
StartLimitIntervalSec=0

[Service]
Restart=on-failure
RestartSec=60
User=${piuser}
Group=${pigroup}
WorkingDirectory=/nuk/.local/lib/python3.10/site-packages/bacnet_client/
ExecStart=/usr/bin/python3.10 -m bacnet_client --respath /nuk/.packages/bacnet_client/dist/res/
Nice=10
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF

chown -R "$piuser:$piuser" /nuk
chmod 644 /etc/systemd/system/bacnet_client.service
systemctl daemon-reload
systemctl enable bacnet_client.service
systemctl start bacnet_client.service
