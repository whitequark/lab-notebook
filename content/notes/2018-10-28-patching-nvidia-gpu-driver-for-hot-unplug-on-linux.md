---
kind: article
created_at: 2018-10-28 08:27:37 +0000
title: "Patching nVidia GPU driver for hot-unplug on Linux"
tags:
  - software
---

Recently, I've using an extremely cursed setup where my XPS 13 9360 laptop is connected to a Sonnet EchoExpress 2 box rewired for Thunderbolt 3 that has an nVidia Quadro 600 GPU, and Linux is set up for render offload to the eGPU and then frame transfer back to iGPU to be displayed on the laptop's integrated display, which (to my sheer surprise) not only works quire reliably, but even gives me higher FPS in Team Fortress 2 than the iGPU.

There's only really one downside: if the eGPU falls off the bus, either because someone™ pulled out the cable, or because the stars didn't align quite right this morning and it decided to enumerate seemingly at random (sometimes this is preceeded by whining from PCIe AER, sometimes not, I *think* it's some sort of hardware issue like a badly inserted PCIe card, but I'm not entirely sure), the nVidia driver... hangs. Hangs quite deliberately, as the sources to the kernel driver show. This leaves the Xorg instance bound to the eGPU hung forever (which confuses bumblebee, but is otherwise not especially bad), and also prevents any new ones from using the eGPU (which is bad).

Anyway, I was kind of annoyed of rebooting every time it happens, so I decided to reboot a few more dozen times instead while patching the driver. This has indeed worked, and left me with something similar to a functional hot-unplug, mildly crippled by the fact that nvidia-modeset is a completely opaque blob that keeps some internal state and tries to act on it, getting stuck when it tries to do something to the now-missing eGPU.

Turns out, there are only a few issues preventing functional hot-unplug.

  1. In `nvidia_remove`, the driver actually checks if anyone's still trying to use it, and if yes, it tries to just hang the removal process. This doesn't actually work, or rather, it mostly works by accident. It starts an infinite loop calling `os_schedule()` while having taken the `NV_LINUX_DEVICES` lock. While in the default configuration this indeed hangs any reentrant requests into the driver by virtue of `NV_CHECK_PCI_CONFIG_SPACE` taking the same lock (in `verify_pci_bars`, passing the `NVreg_CheckPCIConfigSpace=0` module option eliminates that accidental safety mechanism, and allows reentrant requests to proceed. They do not crash due to memory being deallocated in `nvidia_remove` (so you don't get an unhandled kernel page fault), but they still crash due to being unable to access the GPU.

  2. The NVKMS component (in the `nvidia-modeset` module) tries to maintain some state, and change it when e.g. the Xorg instance quits and closes the `/dev/nvidia-modeset` file. Unfortunately, it does not expect the GPU to go away, and first spews a few messages to `dmesg` similar to `nvidia-modeset: ERROR: GPU:0: Failed to query display engine channel state: 0x0000857d:0:0:0x0000000f`, after which it appears to hang somewhere inside the blob, which has been conveniently stripped of all symbols. This needs to be prevented, but...

  3. The NVKMS component effectively only exposes a single opaque ioctl, and all the communication, including communication of the GPU bus ID, happens out of band with regards to the open source parts of the `nvidia-modeset` module. Fortunately, NVKMS calls back into NVRM, and this allows us to associate each `/dev/nvidia-modeset` fd with the GPU bus ID.

  4. When unloading NVKMS, it also tries to act on its internal state and change the GPU state, which leads to the same hang.

All in all, this allows a patch to be written that detects when a GPU goes away, ignores all further NVKMS requests related to that specific GPU (and returns `-ENOENT` in response to ioctls, which Xorg appropriately interprets as a fault condition), correctly releases the resources by requesting NVRM, and improperly unloads NVKMS so it doesn't try to reset the GPU state. (All actual resources should be released by this point, and NVKMS doesn't have any resource allocation callbacks other than those we already intercept, so *in theory* this doesn't have any bad consequences. But I'm not working for nVidia, so this might be completely wrong.)

After the GPU is plugged back in, NVKMS will try to act on its internal state again; in this case, it doesn't hang, but it doesn't initialize the GPU correctly either, so the `nvidia-modeset` kernel module has to be (manually) reloaded. It's not easy to do this automatically because in a hypothetical system with more than one nVidia GPU the module would still be in use when one of them dies, and so just hard reloading NVKMS would have unfortunate consequences. (Though, I don't really know whether NVKMS would try to access the dead GPU in response to the request acting on the other GPU anyway. I decided to do it conservatively.) Once it's reloaded you're back in the game though!

Here's the patch, written against the `nvidia-legacy-390xx-390.87` Debian source package:

<%= highlight_code 'diff', '/files/nvidia-hot-gpu-on-gpu-unplug-action.patch' %>

Here's some handy scripts I was using while debugging it:

<% highlight_code 'sh', 'insmod.sh' do %>
#!/bin/sh -ex
modprobe acpi_ipmi
insmod nvidia.ko NVreg_ResmanDebugLevel=-1 NVreg_CheckPCIConfigSpace=0
insmod nvidia-modeset.ko
dmesg -w
<% end %>

<% highlight_code 'sh', 'rmmod.sh' do %>
#!/bin/sh
rmmod nvidia-modeset
rmmod nvidia
<% end %>

<% highlight_code 'sh', 'xorg.sh' do %>
#!/bin/sh
exec Xorg :8 -config /etc/bumblebee/xorg.conf.nvidia -configdir /etc/bumblebee/xorg.conf.d -sharevts -nolisten tcp -noreset -verbose 3 -isolateDevice PCI:06:00:0 -modulepath /usr/lib/nvidia/nvidia,/usr/lib/xorg/modules
<% end %>

And finally, here are the relevant kernel and Xorg log messages, showing what happens when a GPU is unplugged:

<% highlight_code 'text', 'dmesg.log' do %>
[  219.524218] NVRM: loading NVIDIA UNIX x86_64 Kernel Module  390.87  Tue Aug 21 12:33:05 PDT 2018 (using threaded interrupts)
[  219.527409] nvidia-modeset: Loading NVIDIA Kernel Mode Setting Driver for UNIX platforms  390.87  Tue Aug 21 16:16:14 PDT 2018
[  224.780721] nvidia-modeset: nvkms_open_gpu called with 00000600, pid 4560
[  224.807370] nvidia-modeset: detected gpu 00000600 open in nvkms_ioctl_common, pid 4560
[  239.061383] NVRM: GPU at PCI:0000:06:00: GPU-9fe1319c-8dd3-44e4-2b74-de93f8b02c6a
[  239.061387] NVRM: Xid (PCI:0000:06:00): 79, GPU has fallen off the bus.
[  239.061389] NVRM: GPU at 0000:06:00.0 has fallen off the bus.
[  239.061398] NVRM: A GPU crash dump has been created. If possible, please run
               NVRM: nvidia-bug-report.sh as root to collect this data before
               NVRM: the NVIDIA kernel module is unloaded.
[  240.209498] NVRM: Attempting to remove minor device 0 with non-zero usage count!
[  240.209501] NVRM: YOLO, waiting for usage count to drop to zero
[  241.433499] nvidia-modeset: *notices ur gpu is dead* owo whats this in nvkms_ioctl_common, pid 4560
[  241.433851] nvidia-modeset: awwww u need cleanup :3 in nvkms_close_common, pid 4560
[  241.433853] nvidia-modeset: nvkms_close_gpu called with 00000600, pid 4560
[  250.440498] NVRM: Usage count is now zero, proceeding to remove the GPU
[  250.440513] NVRM: This is not actually supposed to work lol. Hope it does tho 👍
[  250.440520] NVRM: You probably want to reload nvidia-modeset now if you want any of this to ever start up again, but like, man, that's your choice entirely
[  250.440870] pci 0000:06:00.1: Dropping the link to 0000:06:00.0
[  250.440950] pci_bus 0000:06: busn_res: [bus 06] is released
[  250.440982] pci_bus 0000:07: busn_res: [bus 07-38] is released
[  250.441012] pci_bus 0000:05: busn_res: [bus 05-38] is released
[  251.000794] pci_bus 0000:02: Allocating resources
[  251.001324] pci_bus 0000:02: Allocating resources
[  253.765953] pcieport 0000:00:1c.0: AER: Corrected error received: 0000:00:1c.0
[  253.765969] pcieport 0000:00:1c.0: PCIe Bus Error: severity=Corrected, type=Physical Layer, (Receiver ID)
[  253.765976] pcieport 0000:00:1c.0:   device [8086:9d10] error status/mask=00002001/00002000
[  253.765982] pcieport 0000:00:1c.0:    [ 0] Receiver Error         (First)
[  253.841064] pcieport 0000:02:02.0: Refused to change power state, currently in D3
[  253.843882] pcieport 0000:02:00.0: Refused to change power state, currently in D3
[  253.846177] pci_bus 0000:03: busn_res: [bus 03] is released
[  253.846248] pci_bus 0000:04: busn_res: [bus 04-38] is released
[  253.846300] pci_bus 0000:39: busn_res: [bus 39] is released
[  253.846348] pci_bus 0000:02: busn_res: [bus 02-39] is released
[  353.369487] nvidia-modeset: im just gonna leak all the kms junk ok? haha nvm wasnt a question. in nvkms_exit
[  357.600350] nvidia-modeset: Loading NVIDIA Kernel Mode Setting Driver for UNIX platforms  390.87  Tue Aug 21 16:16:14 PDT 2018
<% end %>

<% highlight_code 'text', 'Xorg.8.log' do %>
[   244.798] (EE) NVIDIA(GPU-0): WAIT (2, 8, 0x8000, 0x000011f4, 0x00001210)
<% end %>
