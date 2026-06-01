# 🗺️ HomeLab System Architecture

This document provides a comprehensive technical blueprint of the headless homelab infrastructure. It charts network pathways, virtualization boundaries, and security perimeters to ensure reliable remote administration from a hostel or external network.

---

## 📐 Conceptual Topography Diagram

The diagram below outlines the secure connection path from the remote administration laptop (Artemis), across the encrypted Tailscale mesh network, directly into the virtualized application layers running on the Proxmox VE hypervisor host.

```mermaid
graph TD
	%% Nodes & Devices
	subgraph Remote Host [Hostel / Remote Network]
		Artemis[💻 Artemis: Arch Linux Laptop]
	end

	subgraph Encrypted Transport [Tailscale Mesh Network]
		TS_Tunnel{{"🔒 WireGuard-Based Mesh (100.x.x.x)"}}
	end

	subgraph Home Network [Local Infrastructure]
		Router["📟 Home Router (DHCP / NAT)"]
        
		subgraph Proxmox_Host [🖥️ Proxmox VE Hypervisor Host]
			PVE_UI["🌐 Web UI (Port 8006)"]
            
			subgraph Ubuntu_VM [🐧 Ubuntu Server VM]
				TS_Client["📡 Tailscale Service Daemon"]
                
				subgraph Docker_Engine [🐋 Docker Container Engine]
					Homepage["🏠 Homepage Dashboard (Port 3000)"]
					Portainer["⚓ Portainer CE (Port 9443)"]
					Prometheus["⏱️ Prometheus Core (Port 9090)"]
					Grafana["📊 Grafana Dashboard (Port 3000)"]
					LocalStack["☁️ LocalStack Sandbox (Port 4566)"]
				end
			end
		end
	end

	%% Network Flow Connections
	Artemis ===>|1. Authentication & Mesh Discovery| TS_Tunnel
	TS_Tunnel ===>|2. Encrypted Overlay Routing| TS_Client
    
	%% Local Server Boundaries
	Router --->|Physical Ethernet| Proxmox_Host
	TS_Client --->|Internal Bridge Network| Docker_Engine
    
	%% Target Access Pathways
	Artemis -.->|Direct Admin Access| PVE_UI
	TS_Client -.->|Proxy Endpoint Route| Homepage
	TS_Client -.->|Telemetry Pipeline| Grafana
	TS_Client -.->|IaC Redirection Pipeline| LocalStack

```

---

## 🔌 System Port Matrix

| Service Component | Host Network Binding | Protocol / Security Profile | Core Purpose |
| --- | --- | --- | --- |
| **Proxmox Web UI** | `https://<pve-ip>:8006` | HTTPS (TLS Secured) | Hypervisor cluster management & VM provisioning |
| **Homepage** | `http://100.117.35.70:3000` | HTTP (Tailnet Bound) | Unified navigation entry-point dashboard |
| **Portainer CE** | `https://100.117.35.70:9443` | HTTPS (Self-Signed) | Visual container cluster orchestration |
| **Prometheus** | `http://100.117.35.70:9090` | HTTP (Internal) | Time-series engine tracking hardware nodes |
| **Grafana** | `http://100.117.35.70:3000` | HTTP (Tailnet Bound) | Visualization suite for system performance graphs |
| **LocalStack API** | `http://100.117.35.70:4566` | HTTP (Dev Sandbox) | Emulated AWS cloud services interface (S3/DynamoDB) |

```

*Save and exit the file by typing **`:wq`** and pressing **`Enter`**.*

---


