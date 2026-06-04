#!/bin/bash

echo "========================"
echo "System Information"
echo "========================"

uptime

echo
echo "========================"
echo "Memory"
echo "========================"

free -h

echo
echo "========================"
echo "Disk"
echo "========================"

df -h

echo
echo "========================"
echo "Docker Containers"
echo "========================"

docker ps

echo
echo "========================"
echo "Tailscale"
echo "========================"

tailscale status
