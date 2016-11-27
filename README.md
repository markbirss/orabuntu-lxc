# Orabuntu-LXC

To install the software:

(1) First unzip the distribution

(2) If running on Oracle Linux 7:  Navigate to orabuntu-lxc-master/uekulele/uekulele-services-0.sh and run that script to create the "ubuntu" user on Oracle Linux 7.  Note that the "ubuntu" user is an administrative user with wheel privilege via "sudo".  The uekulele-services-0.sh script must be run as root.

If running on Ubuntu 16.04 similar procedure but the steps to grant root wheel privileges to the "ubuntu" user might be slightly different.  When I was developing I simply created my VM with the install user chosen as "ubuntu" so it got "wheel" automatically, but of course it's very straightforward to just created an ubuntu user and grant it admin sudo privs.  The software is designed to be installed under the "ubuntu" user on either distro Ubuntu or Oracle Linux.  That's just the way I designed it (for good reasons).

(3) Now move the distribution to the /home/ubuntu/Downloads and chmod -R ubuntu:ubuntu the distribution.

(4) To run the software:  /home/ubuntu/Downloads/anylinux/anylinux-services.sh

(5) If you want to set the installation parameters you can pass them in at the command line, or, you can edit the anylinux-services.sh script (recommended method) near the end of the script where default values are set.  You can set two domain names, the name of the DNS DHCP nameserver that is created, etc.

That's it.  The scripts will run and when done you will have however many containers you specified in the parameters of whatever Oracle Linux release specified (supports Oracle Linux 5, 6 and 7) and you will have them running on an OpenvSwith network and will also have a container which is the dynamic DNS DHCP provider for the containers.

This software is "Oracle-centric" in that only Oracle Linux 5, 6 and 7 containers are supported.  The containers are built with all the required prerequisites for installing Oracle database 12c, Oracle EBS, etc. and you can customize the prerequisites in uekulele-services-3.sh if you are installing an Oracle software product that needs some prerequisites that are different from the usual database 12c settings.

The software creates Oracle Linux containers on either Oracle Linux 7 (UEK3, UEK4, OL RHCC kernels) or on Ubuntu 16.04. The containers include by default Oracle GNS configuration in the DNS (gns1.yourdomainname.com) at 10.207.39.3 which you can use as your GNS provider when you install a 12c RAC GNS ASM Flex cluster.  I've installed the 12c RAC GNS ASM Flex cluster into the OL containers on both the Ubuntu 16.04 baremetal LXC host and of course on the Oracle Linux 7 LXC bare metal host and they both work great.

You can easily put VM's on your OpenvSwitch network as well simply by choosing bridged mode for example in the VirtualBox GUI and choosing one of the "s1" ports from the dropdown.  

The system is actually highly configurable and I will be creating extensive documentation in the coming weeks.

If you have any questions or want to request enhancements, reach me at "gilstanden@hotmail.com"
