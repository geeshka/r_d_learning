#!/usr/bin/env bash
apt-get update
apt-get install -y apache2
systemctl restart apache2
