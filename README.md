# What is Orabuntu-LXC v6.0-beta AMIDE Edition ?

Orabuntu-LXC v6.0-beta AMIDE Edition stands for "Amazon Mult-I-host Docker Enterprise" Edition.  Orabuntu-LXC is turnkey software for building an entire next-generation enterprise infrastructure, including LXC Linux Containers, Docker containers, VM's, and physical hosts, all running on OpenvSwitch Software Defined Networks (SDNs), all networked to each other, and with container friendly block devices storage (SCST Linux SAN) direct-attached to the LXC Linux containers with everything running at bare-metal performance of network, CPU, and storage.  Orabuntu-LXC builds a complete production or development container environment complete with networking, DNS/DHCP services, and a SAN.  Orabuntu-LXC BUILDS EVERYTHING itself for the currently supported distros {Oracle Linux, Ubuntu, CentOS, RedHat, Fedora}.  

* Automatically detects your OS and branches to the appropriate build pathway
* Builds OpenvSwitch from source as RPM or DEB packages
* Builds the OpenvSwitch Network
* Configures VLANs on the OpenvSwitch Network
* Connects the OpenvSwitch network physical host interfaces using iptables rules
* Builds LXC from source as RPM or DEB packages
* Creates an LXC-containerized DNS/DHCP container for the systems running bind9 and isc-dhcp-server
* Replicates the LXC-containerized DNS/DHCP container to all Orabuntu-LXC physical GRE-connected hosts
* Updates the LXC-containerized DNS/DHCP container replicas with the latest zone and lease updates every x minutes.
* Builds the LXC containers
* Configures gold copy LXC containers (on a separate network) according to your specifications
* Creates clones of the gold copy LXC containers
* Builds SCST Linux SAN from source code as RPM or DKMS-enabled DEB packages
* Creates the target, group, and LUNs according to your specifications
* Creates the multipath.conf file and configures multipath
* Presents LUNs in 3 locations, including a container-friendly non-symlink location under /dev/containername
* Preseent LUNs to containers directly, only the LUNs for that container, at full bare-metal storage performance.

Orabuntu-LXC does all of this and much more by setting just 5 required parameters and kicking off the anylinux-services.HUB.HOST.sh script.  The Orabuntu-LXC installer can simply be downloaded and started easy button, while on the other hand, for expert customized usage, Orabuntu-LXC is highly-flexible and configurable using the parameters in the anylinux-services.sh file, including support for any two separate user-selectable IP subnet ranges, and 2 domain names, and much much more.  One network, for example the "seed" network can also be used as an out-of-band maintenance network.

# Installing Orabuntu-LXC v6.0-beta AMIDE Edition

An administrative non-root user account is required (such as the install account). The user needs to have "sudo ALL" privilege.

On a Debian-family Linux, such as Ubuntu, this would be membership in the "sudo" group, e.g.
```
orabuntu@UL-1710-S:~$ id orabuntu
uid=1001(orabuntu) gid=1001(orabuntu) groups=1001(orabuntu),27(sudo)
orabuntu@UL-1710-S:~$ cat /etc/lsb-release 
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=17.10
DISTRIB_CODENAME=artful
DISTRIB_DESCRIPTION="Ubuntu 17.10"
orabuntu@UL-1710-S:~$ 
```
On a RedHat-family Linux, such as Fedora, this would be membership in the "wheel" group, e.g.
```
[orabuntu@fedora27 archives]$ id orabuntu
uid=1000(orabuntu) gid=1000(orabuntu) groups=1000(orabuntu),10(wheel)
[orabuntu@fedora27 archives]$ cat /etc/fedora-release 
Fedora release 27 (Twenty Seven)
[orabuntu@fedora27 archives]$
```
For Debian-family Linuxes the following script can be used to create the required administrative install user.
```
orabuntu-services-0.sh
```
For RedHat-family Linuxes the follwoing script can be used to create the required administative isntall user.
```
uekulele-services-0.sh
```
The first Orabuntu-LXC install is always the "HUB" host install. Install the Orabuntu-LXC HUB host as shown below.
```
cd /home/username/Downloads/orabuntu-lxc-master/anylinux
./anylinux-services.HUB.HOST.sh new
```
That's all. This one command will do the following:

    * Install required packages
    * Install or build LXC from source 
    * Install or build OpenvSwitch from source
    * Build Oracle Linux LXC containers
    * Build the OpenvSwitch networks (with VLANs)
    * Configure the IP subnets and domains specified in the anylinux-services.sh file
    * Put the LXC containers on the OvS networks
    * Build a DNS/DHCP LXC container
    * Configure the containers according to specifications in the "product" subdirectory.
    * Clone the number of containers specified in the anylinux-services.sh file
    * Install Docker and a sample network-tools Docker container

Note that although the software is unpacked at /home/username/Downloads, nothing is actually installed there. The installation actuall takes place at /opt/olxc/home/username/Downloads which is where the installer puts all installation files. The distribution at /home/username/Downloads remains static during the install.

The install is customized and configured in the "anylinux-services.sh" file. Search for {pgroup1, pgroup2, pgroup3} to see the configurable settings. When first trying out Orabuntu-LXC, the simplest approach is probably to just build a VM of one of a supported vanilla Linux distro (Oracle Linux, Ubuntu, CentOS, Fedora, or Red Hat) and then just download and run as described above "./anylinux-services.HUB.HOST.sh new" and then after install study the setup to see how the configurations in "anylinux-services.sh" affect the deployment.

To add additional physical hosts you use
```
./anylinux-services.GRE.HOST.sh new
```
This script requires configuring the parameters

    * SPOKEIP
    * HUBIP
    * HubUserAct
    * HubSudoPwd
    * Product

Note that the subnet ranges chosen in the anylinux-services.HUB.HOST.sh install must be used unchanged when running anylinux-services.GRE.HOST.sh so that the multi-host networking works correctly.

To put VM's on the Orabuntu-LXC OpenvSwitch network, on either a HUB physical host or a GRE phyical host, use the following scripts, respectively.
```
anylinux-services.VM.ON.HUB.HOST.1500.sh new
```
or
```
anylinux-services.VM.ON.GRE.HOST.1420.sh new
```
In this case again it is necessary to configure the variables:

    * SPOKEIP
    * HUBIP
    * HubUserAct
    * HubSudoPwd
    * Product

To add Oracle Linux container versions (e.g. add some Oracle Linux 7.3 LXC containers to a deployment of Oracle Linux 6.9 LXC containers) use either

```
anylinux-services.ADD.RELEASE.ON.HUB.HOST.1500.sh
```
or
```
anylinux-services.ADD.RELEASE.ON.GRE.HOST.1420.sh
```
depending again on whether container versions are being add on an Orabuntu-LXC HUB host, or a GRE-tunnel-connected Orabuntu-LXC host, respectively.  In this case it is necessary to go into anylinux-services.sh file and edit the container version variables (MajorRelease, PointRelease) in pgroup2.

To add more clones of an already existing version, e.g. add more Oracle Linux 7.3 LXC containers to a set of existing Oracle Linux 7.3 LXC containers, use
```
anylinux-services.ADD.CLONES.sh
```
Note that Orabuntu-LXC also includes the default LXC Linux Bridge for that distro, e.g. for CentOS and Fedora
```
[orabuntu@fedora27 logs]$ ifconfig virbr0
virbr0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 192.168.122.1  netmask 255.255.255.0  broadcast 192.168.122.255
        ether 52:54:00:8b:e7:18  txqueuelen 1000  (Ethernet)
        RX packets 3189  bytes 187049 (182.6 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 4739  bytes 28087232 (26.7 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

[orabuntu@fedora27 logs]$ cat /etc/fedora-release 
Fedora release 27 (Twenty Seven)
[orabuntu@fedora27 logs]$ 
```
and for Oracle Linux, Ubuntu and Red Hat Linux:
```
lxcbr0
```
so to include containers other than Oracle Linux in your deployment, use the default LXC linux bridge to add non-Orabuntu-LXC LXC containers, and those containers will be able to talk to the containers on the OvS network right out of the box. In this way Ubuntu Linux LXC containers, Alpine Linux LXC containers, etc. can be added to the mix using the standard Linux Bridge (non-OVS).

# Why Oracle Linux

Why is Orabuntu-LXC built around Oracle Linux?  We chose Oracle Linux because it is the only free downloadable readily-available Red Hat-family Linux backed by the full power and credit of a major software vendor, actually one of the largest, namely Oracle Corporation. Oracle (unlike Red Hat) makes their production-grade Linux available for free (including free access to their public YUM servers) and because Oracle Linux is under the direction of it's current Product Management Director, Avi Miller, Oracle have made extensive and successful modifications to Oracle Linux to make it very container-friendly, extremely fast, and an outstanding platform for container deployments of all types.  Oracle Linux explicitly supports LXC and Docker containers, and since those are the core technologies supported by Orabuntu-LXC, we feel Oracle Linux is really the #1 choice for production-grade Linux container deployments where a Red Hat-family Linux is required, and we saw a need for a production-grade, industrial-strength container solution built around a Red Hat-family Linux backed by a major software vendor, and there is really only one credible choice that meets those requirements, and it's Oracle Linux.

If you run Oracle Linux as your LXC host, and Orabuntu-LXC Oracle Linux LXC containers, you have a 100% Oracle Corporation next-generation container infrastructure solution at no cost whether in development or in production, and, which can at any time be converted to paid support from Oracle Corporation, when and if the time comes for that.

# Docker

Orabuntu-LXC deployes docker for all of our supported platforms (Fedora, CentOS, Ubuntu, Oracle Linux, Red Hat) and the docker containers on docker0 by default can be accessed on their ports from the LXC Linux Containers, VMs, and physical hosts.  This provides out of the box a mechanism to put multilayer products into LXC containers and connect them to services prodvided from Docker Containers.

# Virtual Machines

VM's can now be directly attached to the Orabuntu-LXC OpenvSwitch VLAN networks easily using just the functionality in for example the Oracle VirtualBox GUI.  The VMs attached to OpenvSwitch will get IP addresses on the same subnet as the LXC containers and will have full out of the box networking between the LXC containers running on the physical host and the VMs.  But even beyond that, Orabuntu-LXC can be installed in the VM's that are already on the host OpenvSwitch network and the Orabuntu-LXC Linux containers inside the VMs will have full out of the box networking with all the VMs, and all the physical hosts (HUB or GRE), and all the LXC and Docker containers running on the physical hosts, and all of these VMs and containers will all be in DNS and will be accessible from each other via their DNS names, with full forward and reverse lookup services provided by the redundant and fault-tolerant new Orabunt-LXC DNS/DHCP LXC container replicas.

# Orabuntu-LXC DNS/DHCP Replication

Version 6.0-beta AMIDE edition includes near real-time replication of the LXC DNS/DHCP container that is on the OpenvSwitch networks.  On the Orabuntu-LXC HUB host is the primary DNS/DHCP LXC container which provides DNS/DHCP services to all GRE-connected physical hosts, VM's and LXC Containers, whether on physical host or in VM's.  

Every Orabuntu-LXC physical host when deployed automatically gets a replica of the DNS/DHCP LXC container from the HUB host.  This replica is installed in the down state and remains down while the HUB host LXC DNS/DHCP container is running.  However, every 5 minutes (or at an interval specified by the user) the LXC DNS/DHCP container on the HUB host checks for any DNS/DHCP zone updates and if it finds any, it propagates those changes to all the DNS/DHCP LXC container replicas on all GRE-connected Orabuntu-LXC physical hosts (which nevertheless are always not running during these updates - which is possible because the LXC container filesystem is available even when the container is not running).

If at any time DNS/DHCP services are needed, such as if the HUB DNS/DHCP goes down, or if a GRE-connected host needs to be detached from the network, the replica DNS/DHCP LXC container can be started on that local host, and will immediately apply all of the latest updates from the master DNS/DHCP LXC container on HUB host (using the "dns-sync" service), and will be able to resolve DNS and provide DHCP for all GRE-connected hosts and HUB host on the network. (Be sure that only one DNS/DHCP LXC replica is up at any given time).  A replica can be converted to master status simply by copying the list of customer GRE-connected physical hosts to the DNS/DHCP replica, since all replicas have all scripting on board to function as primary DNS/DHCP.  This can also be useful if a developer laptop is a GRE-replicated host which will provide the developer with full DNS/DHCP while disconnected from the network for all LXC containers installed locally on the developer laptop.

This functionality can be used with any HA monitoring solution such as HP Service Guard to monitor that at all times at least 1 DNS/DHCP LXC container on the network is up and running.

# OpenvSwitch

Orabuntu-LXC uses OpenvSwitch as it's core switch technology.  This means that all of the power of OpenvSwitch production-grade Software Defined Networking (SDN) is available in an Orabuntu-LXC deployment.  This includes a rich production-ready switch feature set http://www.openvswitch.org/ and other high performance features that can be added-on, such as OVS-DPDK https://software.intel.com/en-us/articles/open-vswitch-with-dpdk-overview.


Gilbert Standen
St. Louis, MO
March 4, 2018
gilbert@orabuntu-lxc.com
