# Apollo — Hardware / Power-Loss Incident

**Date:** September 2026
**Host:** Apollo
**Role:** Proxmox virtualization / homelab node
**Status:** Operational

### Incident Summary

Apollo experienced abnormal behavior following an unexpected AC power interruption. After power was restored, the system initially became difficult to reach over the normal LAN connection. Tailscale connectivity was intermittently available, but the host did not behave normally.

A complete power-off followed by another power-on eventually restored normal LAN connectivity.

During subsequent troubleshooting, a reboot into the motherboard firmware produced **no display output** and the motherboard's **VGA EZ Debug LED** was illuminated. The GTX 1660 SUPER was physically reseated. After reseating, the system successfully displayed the MSI BIOS and subsequently booted Proxmox normally.

This established a strong correlation between the post-power-loss issue and GPU/PCIe initialization, although it does **not** establish a failed GPU, PSU, or motherboard.

### Hardware

| Component       | Details                                                 |
| --------------- | ------------------------------------------------------- |
| Motherboard     | MSI X570-A PRO                                          |
| CPU             | AMD Ryzen 7 3700X — 8C/16T                              |
| GPU             | MSI GTX 1660 SUPER — 6 GB                               |
| RAM             | 16 GB DDR4-3200                                         |
| PSU             | Cooler Master MWE 750 White 230V V2 — MPE-7501-ACABW-IN |
| BIOS            | E7C37AMS.HA0 — 2020-09-07                               |
| Hypervisor      | Proxmox VE                                              |
| CPU GPU support | No integrated GPU; display depends on discrete GPU      |

### PCIe Findings

The GTX 1660 SUPER is connected directly through the AMD X570 CPU PCIe root port:

```text
AMD X570 / Ryzen
└── 00:03.1 AMD Starship/Matisse GPP Bridge
    └── 2d:00.0 NVIDIA GTX 1660 SUPER
```

The GPU supports:

```text
PCIe Gen3 x16
8 GT/s
```

The motherboard/root port supports higher speeds, but the negotiated link is currently:

```text
PCIe Gen1 x16
2.5 GT/s
```

Both the GPU and root port report:

```text
Target Link Speed: 8 GT/s
Actual Link Speed: 2.5 GT/s
Width: x16
```

The BIOS `PCI_E1 - Max Link Speed` setting was temporarily changed from `Auto` to `Gen3` for testing. The link still negotiated at Gen1, indicating that the issue is not simply the BIOS being configured to Auto.

The setting should therefore be returned to **Auto** unless further GPU/PCIe testing is required.

### PCIe Error Status

No active PCIe AER errors were found.

The root port reported:

```text
CorrErr-
NonFatalErr-
FatalErr-
ERR_COR: 0000
ERR_FATAL/NONFATAL: 0000
```

No corresponding PCIe AER error events were observed in the kernel logs.

Therefore, the Gen1 link should currently be treated as a **hardware/link-training anomaly**, not evidence of an active PCIe failure.

### Other Diagnostics

No evidence was found for:

* CPU Machine Check Errors
* RAM/EDAC errors
* Kernel panic
* Kernel OOPS
* Soft lockup
* Hard lockup
* Hung task
* Proxmox kernel crash
* Persistent crash dump in pstore

The Proxmox host currently boots and operates normally.

### Separate Issues Observed

The following were observed during investigation but are considered separate from the GPU/POST incident:

* `amd_pstate` initialization failures on all logical CPUs, resulting in fallback behavior.
* Temporary USB/Wi-Fi initialization failures.
* `apollo-firewall.service` failures.
* Prometheus metrics connection-refused messages.
* NVIDIA UCSI/I²C timeout messages associated with the GPU's USB-C/UCSI function.

These should be investigated independently rather than treated as the cause of the original power-loss incident.

### Current State

**Apollo is operational.**

The GPU is detected and usable by Linux, the Proxmox host is running normally, networking is functional, and no active PCIe hardware errors are being reported.

The remaining hardware anomaly is:

> **GTX 1660 SUPER ↔ X570 PCIe link consistently operating at Gen1 x16 instead of the expected Gen3 x16.**

Because the server is currently stable and the GPU is not being used for a workload requiring high PCIe bandwidth, this is being **left unresolved for now** rather than introducing additional changes.

### Future Investigation

If GPU-intensive workloads, PCIe passthrough, CUDA, or other GPU workloads are introduced, investigate the Gen1 link further.

Potential future investigation areas, in controlled order:

1. Verify behavior with BIOS PCIe settings.
2. Check GPU PCIe power connection/cable.
3. Test the GPU in another compatible PCIe slot if practical.
4. Test another known-good GPU if available.
5. Investigate motherboard BIOS/firmware updates.
6. Consider PSU/power-delivery behavior if additional hardware symptoms appear.

**Current decision:** Do not perform further hardware changes solely because of the Gen1 link. Monitor Apollo for recurrence of the original post-power-loss symptoms.

## Record provenance

Operator-supplied September 2026 incident account, incorporated on 2026-10-09 from `update.txt`. The exact incident day is not supplied. Diagnostic results describe that investigation; no new hardware checks were performed during documentation work. Returning the BIOS setting to Auto is a recommendation in the account, not a confirmed completed change.
