#!/usr/bin/env bash
apt-get update
apt-get install -y mysql-server
systemctl start mysql
systemctl enable mysql
