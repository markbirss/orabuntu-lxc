#!/bin/bash

#    Copyright 2015-2018 Gilbert Standen
#    This file is part of Orabuntu-LXC.

#    Orabuntu-LXC is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    Orabuntu-LXC is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with Orabuntu-LXC.  If not, see <http://www.gnu.org/licenses/>.

#    v2.4 		GLS 20151224
#    v2.8 		GLS 20151231
#    v3.0 		GLS 20160710 Updates for Ubuntu 16.04
#    v4.0 		GLS 20161025 DNS DHCP services moved into an LXC container
#    v5.0 		GLS 20170909 Orabuntu-LXC Multi-Host
#    v6.0-AMIDE-beta	GLS 20180106 Orabuntu-LXC AmazonS3 Multi-Host Docker Enterprise Edition (AMIDE)

#    Note that this software builds a containerized DNS DHCP solution (bind9 / isc-dhcp-server).
#    The nameserver should NOT be the name of an EXISTING nameserver but an arbitrary name because this software is CREATING a new LXC-containerized nameserver.
#    The domain names can be arbitrary fictional names or they can be a domain that you actually own and operate.
#    There are two domains and two networks because the "seed" LXC containers are on a separate network from the production LXC containers.
#    If the domain is an actual domain, you will need to change the subnet using the subnets feature of Orabuntu-LXC
#
#!/bin/bash

clear

MajorRelease=$1
OracleRelease=$1$2
OracleVersion=$1.$2
NumCon=$3
NameServer=$4
MultiHost=$5
DistDir=$6

function SoftwareVersion { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

function GetLXCVersion {
        lxc-create --version
}
LXCVersion=$(GetLXCVersion)

function GetMultiHostVar7 {
        echo $MultiHost | cut -f7 -d':'
}
MultiHostVar7=$(GetMultiHostVar7)

function GetMultiHostVar2 {
        echo $MultiHost | cut -f2 -d':'
}
MultiHostVar2=$(GetMultiHostVar2)

GetLinuxFlavors(){
if   [[ -e /etc/oracle-release ]]
then
        LinuxFlavors=$(cat /etc/oracle-release | cut -f1 -d' ')
elif [[ -e /etc/redhat-release ]]
then
        LinuxFlavors=$(cat /etc/redhat-release | cut -f1 -d' ')
elif [[ -e /usr/bin/lsb_release ]]
then
        LinuxFlavors=$(lsb_release -d | awk -F ':' '{print $2}' | cut -f1 -d' ')
elif [[ -e /etc/issue ]]
then
        LinuxFlavors=$(cat /etc/issue | cut -f1 -d' ')
else
        LinuxFlavors=$(cat /proc/version | cut -f1 -d' ')
fi
}
GetLinuxFlavors

function TrimLinuxFlavors {
echo $LinuxFlavors | sed 's/^[ \t]//;s/[ \t]$//'
}
LinuxFlavor=$(TrimLinuxFlavors)

if   [ $LinuxFlavor = 'Oracle' ]
then
	CutIndex=7
        function GetRedHatVersion {
                sudo cat /etc/redhat-release | cut -f"$CutIndex" -d' ' | cut -f1 -d'.'
        }
        RedHatVersion=$(GetRedHatVersion)
        function GetOracleDistroRelease {
                sudo cat /etc/oracle-release | cut -f5 -d' ' | cut -f1 -d'.'
        }
        OracleDistroRelease=$(GetOracleDistroRelease)
        Release=$OracleDistroRelease
        LF=$LinuxFlavor
        RL=$Release
elif [ $LinuxFlavor = 'Red' ] || [ $LinuxFlavor = 'CentOS' ]
then
        if   [ $LinuxFlavor = 'Red' ]
        then
                CutIndex=7
        elif [ $LinuxFlavor = 'CentOS' ]
        then
                CutIndex=4
        fi
        function GetRedHatVersion {
                sudo cat /etc/redhat-release | cut -f"$CutIndex" -d' ' | cut -f1 -d'.'
        }
        RedHatVersion=$(GetRedHatVersion)
        Release=$RedHatVersion
        LF=$LinuxFlavor
        RL=$Release
elif [ $LinuxFlavor = 'Fedora' ]
then
        CutIndex=3
        function GetRedHatVersion {
                sudo cat /etc/redhat-release | cut -f"$CutIndex" -d' ' | cut -f1 -d'.'
        }
        RedHatVersion=$(GetRedHatVersion)
        if [ $RedHatVersion -ge 19 ]
        then
                Release=7
        elif [ $RedHatVersion -ge 12 ] && [ $RedHatVersion -le 18 ]
        then
                Release=6
        fi
        LF=$LinuxFlavor
        RL=$Release
elif [ $LinuxFlavor = 'Ubuntu' ]
then
        function GetUbuntuVersion {
                cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -f2 -d'='
        }
        UbuntuVersion=$(GetUbuntuVersion)
        LF=$LinuxFlavor
        RL=$UbuntuVersion
        function GetUbuntuMajorVersion {
                cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -f2 -d'=' | cut -f1 -d'.'
        }
        UbuntuMajorVersion=$(GetUbuntuMajorVersion)
fi

echo ''
echo "=============================================="
echo "Script:  uekulele-services-4.sh NumCon        "
echo "=============================================="
echo ''
echo "=============================================="
echo "This script is re-runnable.                   "
echo "This script clones additional containers.     "
echo "=============================================="
echo ''
echo "=============================================="
echo "NumCon is the number of RAC nodes             "
echo "NumCon (small integer)                        "
echo "NumCon defaults to value '2'                  "
echo "=============================================="

if [ -z $3 ]
then
	NumCon=2
else
	NumCon=$3
fi

ContainerPrefix=ora$1$2c
CP=$ContainerPrefix

function GetSeedContainerName {
	sudo lxc-ls -f | grep oel$OracleRelease | cut -f1 -d' '
}
SeedContainerName=$(GetSeedContainerName)

echo ''
echo "=============================================="
echo "Number of LXC Container RAC Nodes = $NumCon   "
echo "=============================================="
echo ''
echo "=============================================="
echo "If wrong number of desired RAC nodes, then    "
echo "<ctrl>+c and restart script to set            "
echo "Sleeping 15 seconds...                        "
echo "=============================================="
echo ''
echo "=============================================="
echo "This script creates oracle-ready lxc clones   "
echo "for oracle-ready RAC container nodes          "
echo "=============================================="

sleep 5

clear

function GetMultiHostVar4 {
        echo $MultiHost | cut -f4 -d':'
}
MultiHostVar4=$(GetMultiHostVar4)

echo ''
echo "=============================================="
echo "Establish sudo privileges...                  "
echo "=============================================="
echo ''

echo $MultiHostVar4 | sudo -S date

echo ''
echo "=============================================="
echo "Privileges established.                       "
echo "=============================================="

sleep 5

clear

echo ''
echo "=============================================="
echo "Stopping $SeedContainerName seed container...  "
echo "(OEL 5 shutdown can take awhile...patience)   "
echo "(OEL 6 and OEL 7 are relatively fast shutdown)"
echo "=============================================="
echo ''

function CheckContainerUp {
sudo lxc-ls -f | grep $SeedContainerName | sed 's/  */ /g' | egrep 'RUNNING|STOPPED'  | cut -f2 -d' '
}
ContainerUp=$(CheckContainerUp)
sudo lxc-stop -n $SeedContainerName > /dev/null 2>&1

while [ "$ContainerUp" = 'RUNNING' ]
do
	sleep 1
	ContainerUp=$(CheckContainerUp)
done

sudo lxc-ls -f

echo ''
echo "=============================================="
echo "Seed container stopped.                       "
echo "=============================================="

sleep 5

clear

# echo ''
# echo "=============================================="
# echo "Configure Extra Networks (optional e.g. RAC)  "
# echo "=============================================="
# echo ''

# AddPrivateNetworks=Y
# # read -e -p "Add Extra Private Networks (e.g for Oracle RAC ASM Flex Cluster) [Y/N]   " -i "Y" AddPrivateNetworks

# if [ $AddPrivateNetworks = 'y' ] || [ $AddPrivateNetworks = 'Y' ]
# then
#         sudo bash -c "cat /var/lib/lxc/$SeedContainerName/config.oracle /var/lib/lxc/$SeedContainerName/config.asm.flex.cluster > /var/lib/lxc/$SeedContainerName/config"
#         sudo sed -i "s/ContainerName/$SeedContainerName/g" /var/lib/lxc/$SeedContainerName/config
#         OracleNonPublicNetworks='sw2 sw3 sw4 sw5 sw6 sw7 sw8 sw9'
#         for j in $OracleNonPublicNetworks
#         do
#                 echo 'nothing' > /dev/null 2>&1
#         done
# fi

# if [ $AddPrivateNetworks = 'n' ] || [ $AddPrivateNetworks = 'N' ]
# then
#         sudo cp -p /var/lib/lxc/$SeedContainerName/config.oracle /var/lib/lxc/$SeedContainerName/config
#         sudo sed -i "s/ContainerName/$SeedContainerName/g" /var/lib/lxc/$SeedContainerName/config
# fi

# echo ''
# echo "=============================================="
# echo "Configure extra private networks completed.   "
# echo "=============================================="

# sleep 5

# clear

if [ $MultiHostVar2 = 'Y' ]
then
	sudo sed -i "s/MtuSetting/$MultiHostVar7/g" /var/lib/lxc/$SeedContainerName/config
fi

echo ''
echo "=============================================="
echo "Clone $SeedContainerName to $NumCon containers"
echo "=============================================="
echo ''

sleep 5

clear

let CloneIndex=10
let CopyCompleted=0

while [ $CopyCompleted -lt $NumCon ]
do
	# GLS 20160707 updated to use lxc-copy instead of lxc-clone for Ubuntu 16.04
	# GLS 20160707 continues to use lxc-clone for Ubuntu 15.04 and 15.10

	RedHatVersion=$(GetRedHatVersion)

	function CheckDNSLookup {
		nslookup -timeout=1 $ContainerPrefix$CloneIndex | grep -v '#' | grep Address | grep '10\.207\.39' | wc -l
	}
	DNSLookup=$(CheckDNSLookup)

	if [ $Release -eq 7 ] || [ $Release -eq 6 ]
	then
		while [ $DNSLookup -eq 1 ]
		do
			CloneIndex=$((CloneIndex+1))
			DNSLookup=$(CheckDNSLookup)
		done
		if [ $DNSLookup -eq 0 ]
		then
			echo ''
			echo "=============================================="
			echo "Clone $SeedContainerName to $CP$CloneIndex    "
			echo "=============================================="
			echo ''

			echo "Clone Container Name = $ContainerPrefix$CloneIndex"

      			sudo lxc-copy -n $SeedContainerName -N $ContainerPrefix$CloneIndex

			if [ $MajorRelease -eq 7 ]
			then
                        	sudo sed -i "s/$SeedContainerName/$ContainerPrefix$CloneIndex/g"        /var/lib/lxc/$ContainerPrefix$CloneIndex/rootfs/etc/hostname
                        fi
			sudo sed -i "s/$SeedContainerName/$ContainerPrefix$CloneIndex/g"        /var/lib/lxc/$ContainerPrefix$CloneIndex/rootfs/etc/sysconfig/network-scripts/ifcfg-eth0
			sudo sed -i "s/HostName/$ContainerPrefix$CloneIndex/g"        		/var/lib/lxc/$ContainerPrefix$CloneIndex/rootfs/etc/sysconfig/network-scripts/ifcfg-eth0
                        sudo sed -i "s/$SeedContainerName/$ContainerPrefix$CloneIndex/g"        /var/lib/lxc/$ContainerPrefix$CloneIndex/rootfs/etc/sysconfig/network
                        sudo sed -i "s/$SeedContainerName/$ContainerPrefix$CloneIndex/g"        /var/lib/lxc/$ContainerPrefix$CloneIndex/rootfs/etc/hosts
		fi
	fi

	sudo sed -i "s/$SeedContainerName/$ContainerPrefix$CloneIndex/g" /var/lib/lxc/$ContainerPrefix$CloneIndex/config
	sudo sed -i "s/\.10/\.$CloneIndex/g" /var/lib/lxc/$ContainerPrefix$CloneIndex/config
	sudo sed -i 's/sx1/sw1/g' /var/lib/lxc/$ContainerPrefix$CloneIndex/config

	function GetHostName (){ echo $ContainerPrefix$CloneIndex\1; }
	HostName=$(GetHostName)

	sudo sed -i "s/$HostName/$ContainerPrefix$CloneIndex/" /var/lib/lxc/$ContainerPrefix$CloneIndex/rootfs/etc/sysconfig/network

	echo ''
	echo "=============================================="
	echo "Create $CP$CloneIndex Onboot Service...       "
	echo "=============================================="

	sudo sh -c "echo '#!/bin/bash'										>  /etc/network/openvswitch/strt_$ContainerPrefix$CloneIndex.sh"
	sudo sh -c "echo '#'											>> /etc/network/openvswitch/strt_$ContainerPrefix$CloneIndex.sh"
	sudo sh -c "echo '# Manage the Oracle RAC LXC containers'						>> /etc/network/openvswitch/strt_$ContainerPrefix$CloneIndex.sh"
	sudo sh -c "echo '#'											>> /etc/network/openvswitch/strt_$ContainerPrefix$CloneIndex.sh"
	sudo sh -c "echo 'start() {'										>> /etc/network/openvswitch/strt_$ContainerPrefix$CloneIndex.sh"
	sudo sh -c "echo '  exec lxc-start -n $ContainerPrefix$CloneIndex > /dev/null 2>&1'			>> /etc/network/openvswitch/strt_$ContainerPrefix$CloneIndex.sh"
	sudo sh -c "echo '}'											>> /etc/network/openvswitch/strt_$ContainerPrefix$CloneIndex.sh"
	sudo sh -c "echo ''											>> /etc/network/openvswitch/strt_$ContainerPrefix$CloneIndex.sh"
	sudo sh -c "echo 'stop() {'										>> /etc/network/openvswitch/strt_$ContainerPrefix$CloneIndex.sh"
	sudo sh -c "echo '  exec lxc-stop -n $ContainerPrefix$CloneIndex > /dev/null 2>&1'			>> /etc/network/openvswitch/strt_$ContainerPrefix$CloneIndex.sh"
	sudo sh -c "echo '}'											>> /etc/network/openvswitch/strt_$ContainerPrefix$CloneIndex.sh"
	sudo sh -c "echo ''											>> /etc/network/openvswitch/strt_$ContainerPrefix$CloneIndex.sh"
	sudo sh -c "echo 'case \$1 in'										>> /etc/network/openvswitch/strt_$ContainerPrefix$CloneIndex.sh"
	sudo sh -c "echo '  start|stop) \"\$1\" ;;'								>> /etc/network/openvswitch/strt_$ContainerPrefix$CloneIndex.sh"
	sudo sh -c "echo 'esac'											>> /etc/network/openvswitch/strt_$ContainerPrefix$CloneIndex.sh"

	sudo chmod +x /etc/network/openvswitch/strt_$ContainerPrefix$CloneIndex.sh
	
	sudo sh -c "echo '[Unit]'                                                        			>  /etc/systemd/system/$ContainerPrefix$CloneIndex.service"
	sudo sh -c "echo 'Description=$ContainerPrefix$CloneIndex Service'                               	>> /etc/systemd/system/$ContainerPrefix$CloneIndex.service"
	sudo sh -c "echo 'Wants=network-online.target sw1.service $NameServer.service'          		>> /etc/systemd/system/$ContainerPrefix$CloneIndex.service"
	sudo sh -c "echo 'After=network-online.target sw1.service $NameServer.service'          		>> /etc/systemd/system/$ContainerPrefix$CloneIndex.service"
	sudo sh -c "echo ''                                                             			>> /etc/systemd/system/$ContainerPrefix$CloneIndex.service"
	sudo sh -c "echo '[Service]'                                                    			>> /etc/systemd/system/$ContainerPrefix$CloneIndex.service"
	sudo sh -c "echo 'Type=oneshot'                                                 			>> /etc/systemd/system/$ContainerPrefix$CloneIndex.service"
	sudo sh -c "echo 'User=root'                                                    			>> /etc/systemd/system/$ContainerPrefix$CloneIndex.service"
	sudo sh -c "echo 'RemainAfterExit=yes'                                          			>> /etc/systemd/system/$ContainerPrefix$CloneIndex.service"
	sudo sh -c "echo 'ExecStart=/etc/network/openvswitch/strt_$ContainerPrefix$CloneIndex.sh start' 	>> /etc/systemd/system/$ContainerPrefix$CloneIndex.service"
	sudo sh -c "echo 'ExecStop=/etc/network/openvswitch/strt_$ContainerPrefix$CloneIndex.sh stop'   	>> /etc/systemd/system/$ContainerPrefix$CloneIndex.service"
	sudo sh -c "echo ''                                                             			>> /etc/systemd/system/$ContainerPrefix$CloneIndex.service"
	sudo sh -c "echo '[Install]'                                                    			>> /etc/systemd/system/$ContainerPrefix$CloneIndex.service"
	sudo sh -c "echo 'WantedBy=multi-user.target'                                   			>> /etc/systemd/system/$ContainerPrefix$CloneIndex.service"

	sudo chmod 644 /etc/systemd/system/$ContainerPrefix$CloneIndex.service
	
	echo ''
	sudo cat /etc/systemd/system/$ContainerPrefix$CloneIndex.service
	echo ''
	sudo systemctl enable $ContainerPrefix$CloneIndex
	
	echo ''
	echo "=============================================="
	echo "Created $CP$CloneIndex Onboot Service.        "
	echo "=============================================="
	echo ''

        if [ $(SoftwareVersion $LXCVersion) -ge $(SoftwareVersion "2.1.0") ]
        then
                sudo lxc-update-config -c /var/lib/lxc/$CP$CloneIndex/config
        fi

CopyCompleted=$((CopyCompleted+1))
CloneIndex=$((CloneIndex+1))

sleep 5

clear

done

echo ''
echo "=============================================="
echo "Container cloning completed.                  "
echo "=============================================="

sleep 5

clear

echo ''
echo "=============================================="
echo "Creating OpenvSwitch files ...                "
echo "=============================================="

sleep 5

# sudo /etc/network/openvswitch/create-ovs-sw-files-v2.sh $ContainerPrefix $NumCon $NewHighestContainerIndex $HighestContainerIndex
  sudo /etc/network/openvswitch/create-ovs-sw-files-v2.sh $ContainerPrefix $NumCon $CloneIndex

echo ''
echo "=============================================="
echo "Creating OpenvSwitch files complete.          "
echo "=============================================="

sleep 5

clear

# echo ''
# echo "=============================================="
# echo "   Reset config file for $SeedContainerName.  "
# echo "Removes ASM and RAC private network interfaces"
# echo "    from seed container $SeedContainerName    "
# echo "(cloned containers are not affected by reset) "
# echo "=============================================="
# echo ''

# ResetSingleDHCPInterface=Y
# # read -e -p "Reset Seed Container $SeedContainerName to single DHCP interface ? [Y/N]   " -i "Y" ResetSingleDHCPInterface

# if [ $ResetSingleDHCPInterface = 'y' ] || [ $ResetSingleDHCPInterface = 'Y' ]
# then
# sudo cp -p /var/lib/lxc/$SeedContainerName/config.oracle /var/lib/lxc/$SeedContainerName/config
# sudo sed -i "s/ContainerName/$SeedContainerName/g" /var/lib/lxc/$SeedContainerName/config
# sudo sed -i 's/sw1/sx1/g' /var/lib/lxc/$SeedContainerName/config
# fi

# echo ''
# echo "=============================================="
# echo "Config file reset successful.                 "
# echo "=============================================="

# sleep 5

# clear

if [ $(SoftwareVersion $LXCVersion) -ge $(SoftwareVersion "2.1.0") ]
then
        echo ''
        echo "=============================================="
        echo "Update config for LXC 2.1.0+                  "
        echo "=============================================="
        echo ''

        sudo lxc-update-config -c /var/lib/lxc/$SeedContainerName/config

	sleep 5

	clear

        echo ''
        echo "=============================================="
        echo "Done: Update config for LXC 2.1.0+            "
        echo "=============================================="
        echo ''
fi

sleep 5

clear

echo ''
echo "=============================================="
echo "Start Seed Container $SeedContainerName...    "
echo "=============================================="
echo ''

sudo lxc-start -n $SeedContainerName > /dev/null 2>&1
sleep 2
sudo lxc-ls -f

echo ''
echo "=============================================="
echo "Start Seed Container $SeedContainerName...    "
echo "=============================================="

sleep 5

clear

echo ''
echo "=============================================="
echo "Next script to run: uekulele-services-5.sh    "
echo "=============================================="

sleep 5
