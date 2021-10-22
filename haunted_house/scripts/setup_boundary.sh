#!/bin/bash
# Installs the boundary as a service for systemd on linux
# Usage: ./install.sh <worker|controller>

TYPE=controller
NAME=boundary

cat << EOF > /tmp/${NAME}-${TYPE}.service
[Unit]
Description=${NAME} ${TYPE}

[Service]
ExecStart=/usr/bin/${NAME} server -config /etc/${NAME}-${TYPE}.hcl
User=boundary
Group=boundary
LimitMEMLOCK=infinity
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK

[Install]
WantedBy=multi-user.target
EOF

sudo cp /tmp/${NAME}-${TYPE}.service /etc/systemd/system/${NAME}-${TYPE}.service

# Add the boundary system user and group to ensure we have a no-login
# user capable of owning and running Boundary
sudo adduser --system --group boundary || true
sudo cp /tmp/${NAME}-${TYPE}.hcl /etc/${NAME}-${TYPE}.hcl
sudo chown boundary:boundary /etc/${NAME}-${TYPE}.hcl
sudo chown boundary:boundary /usr/bin/boundary

sudo mkdir -p /opt/boundary
sudo cp /tmp/boundary-controller.crt /opt/boundary/boundary-controller.crt
sudo cp /tmp/boundary-controller.key /opt/boundary/boundary-controller.key
sudo chown boundary:boundary -R /opt/boundary

# Make sure to initialize the DB before starting the service. This will result in
# a database already initialized warning if another controller or worker has done this
# already, making it a lazy, best effort initialization
if [ "${TYPE}" = "controller" ]; then
  sudo /usr/bin/boundary database init -config /etc/${NAME}-${TYPE}.hcl || true
fi

sudo chmod 664 /etc/systemd/system/${NAME}-${TYPE}.service

sudo systemctl daemon-reload
sudo systemctl enable ${NAME}-${TYPE}
sudo systemctl start ${NAME}-${TYPE}
