# Homelab Post-Mortem - 2026-06-01

Today I finished the first full pass of the homelab setup and cleared a few network and VM issues along the way. This note records what went wrong, what I changed, and what the setup looks like now.

## What I Ran Into

### 1. Ubuntu storage was not using the full disk

The Ubuntu Server installer left part of the virtual disk unassigned. If I had left it alone, the VM would have run into disk space problems as soon as I started pulling Docker images.

### Fix

I went back to the storage summary during install, opened the LVM settings, and expanded `ubuntu-lv` to use the full available disk space.

### Result

The VM now uses 100% of its allocated storage.

---

### 2. Wi-Fi bridging on Proxmox did not work

When I tried to apply a static IP inside the VM, networking failed and SSH could not reach the guest from my laptop.

### Root Cause

The Proxmox host is connected to the router over Wi-Fi instead of Ethernet. Standard bridging does not behave well in that setup because the access point rejects virtual MAC addresses that never completed the wireless handshake.

### Fix

I moved away from the broken bridge setup and turned the Proxmox host into a NAT gateway. I updated the host network config in `/etc/network/interfaces`, detached the Wi-Fi interface from the bridge, and added forwarding and masquerade rules so the host can safely share its authenticated Wi-Fi connection with the VM.

### Result

The Proxmox host now routes internet traffic through NAT, and the VM can reach the outside network reliably.

---

### 3. The VM was marked as disconnected in Proxmox

After updating the Ubuntu network settings for the new NAT layout, the VM booted into a network wait state and hung while waiting for connectivity.

### Fix

I found that the Proxmox Hardware setting had the virtual network device marked as disconnected. Unchecking that box reattached the virtual cable and allowed the VM to bring networking up normally.

### Result

The VM now boots cleanly and can ping external addresses.

---

### 4. SSH failed because of a username mismatch

My first SSH attempt from my laptop was rejected with a permission error.

### Fix

The login username had to match the exact lowercase Linux username created during setup. Once I used the correct case, SSH worked immediately.

### Result

I now have remote terminal access through Tailscale.

## Current State

- Proxmox is routing internet traffic through NAT over Wi-Fi.
- The Ubuntu VM is using all of its allocated storage.
- I have full terminal access from my laptop through Tailscale.
- The environment is isolated, remote-friendly, and ready for the next layer of services.

## Follow-Up Notes

- Record the final network settings in `docs/network.md`.
- Keep this incident log updated whenever I change the host networking model again.
- If I add more VMs later, use the same NAT pattern unless I move the host to wired Ethernet.
