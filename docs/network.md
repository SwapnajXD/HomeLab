# Network

## Purpose

Track the real IP addresses, routing, and remote-access details for the homelab here.

## Current Network Layout

### Proxmox Host

- Host name: `apollo`
- Proxmox web UI: `https://192.168.1.150:8006`
- Host access: available on the local Wi-Fi network
- Purpose: routes traffic for the VM network through a custom NAT bridge

### NAT Bridge

- Bridge IP / gateway: `10.10.10.1/24`
- Subnet: `10.10.10.0/24`
- Role: Proxmox NAT and masquerade layer for the Ubuntu VM network
- Routing: the Proxmox host translates traffic between the VM subnet and the home Wi-Fi network

### Ubuntu VM

- Internal IP: `10.10.10.10`
- Gateway: `10.10.10.1`
- Role: Ubuntu Docker host and main development sandbox
- Network path: the VM reaches the internet through the Proxmox NAT bridge

### Remote Access

- Primary access method: Tailscale only
- Remote workstation: my Arch laptop
- Tailscale address: use the permanent `100.x.x.x` IP assigned to the VM or host as needed
- SSH and administration: connect through the Tailscale tunnel instead of exposing router ports

## Notes to Remember

- The Proxmox host does not use a normal Ethernet bridge for the VM network in this setup.
- The VM is on a private NAT subnet, not the home LAN.
- If the Tailscale IP changes, update this file immediately.
- Keep the Proxmox web UI address and the VM gateway here so I do not have to rediscover them later.
