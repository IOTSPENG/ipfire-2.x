#!/bin/bash
############################################################################
#                                                                          #
# This file is part of the IPFire Firewall.                                #
#                                                                          #
# IPFire is free software; you can redistribute it and/or modify           #
# it under the terms of the GNU General Public License as published by     #
# the Free Software Foundation; either version 3 of the License, or        #
# (at your option) any later version.                                      #
#                                                                          #
# IPFire is distributed in the hope that it will be useful,                #
# but WITHOUT ANY WARRANTY; without even the implied warranty of           #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
# GNU General Public License for more details.                             #
#                                                                          #
# You should have received a copy of the GNU General Public License        #
# along with IPFire; if not, write to the Free Software                    #
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA #
#                                                                          #
# Copyright (C) 2012 IPFire-Team <info@ipfire.org>.                        #
#                                                                          #
############################################################################
#
. /opt/pakfire/lib/functions.sh
/usr/local/bin/backupctrl exclude >/dev/null 2>&1

#
# Remove old core updates from pakfire cache to save space...
core=65
for (( i=1; i<=$core; i++ ))
do
	rm -f /var/cache/pakfire/core-upgrade-*-$i.ipfire
done

#
#Stop services

#
#Extract files
extract_files

#
#Start services

#
#Update Language cache
perl -e "require '/var/ipfire/lang.pl'; &Lang::BuildCacheLang"

# Convert OpenVPN RW connections.
/usr/sbin/ovpn-ccd-convert

# Update crontab.
sed -i /var/spool/cron/root.orig \
	-e 's@^.*fcron.weekly.*$@\&nice(10),bootrun 47 2 \* \* 1\ttest -x /usr/local/bin/run-parts \&\& /usr/local/bin/run-parts /etc/fcron.weekly@'
fcrontab -z &>/dev/null

# Reload apache configuration.
/etc/init.d/apache reload &>/dev/null

#Rebuild module dep's
#arch=`uname -m`
#if [ ${arch::3} == "arm" ]; then
#	depmod -a 2.6.32.45-ipfire-versatile >/dev/null 2>&1
#	depmod -a 2.6.32.45-ipfire-kirkwood >/dev/null 2>&1
#else
#	depmod -a 2.6.32.45-ipfire     >/dev/null 2>&1
#	depmod -a 2.6.32.45-ipfire-pae >/dev/null 2>&1
#	depmod -a 2.6.32.45-ipfire-xen >/dev/null 2>&1
#fi


#Rebuild initrd's because some compat-wireless modules are inside
#/sbin/dracut --force --verbose /boot/ipfirerd-2.6.32.45.img 2.6.32.45-ipfire
#if [ -e /boot/ipfirerd-2.6.32.45-pae.img ]; then
#/sbin/dracut --force --verbose /boot/ipfirerd-2.6.32.45-pae.img 2.6.32.45-ipfire-pae
#fi
#if [ -e /boot/ipfirerd-2.6.32.45-xen.img ]; then
#/sbin/dracut --force --verbose /boot/ipfirerd-2.6.32.45-xen.img 2.6.32.45-ipfire-xen
#fi

sync

# This update need a reboot...
#touch /var/run/need_reboot

#
#Finish
/etc/init.d/fireinfo start
sendprofile
#Don't report the exitcode last command
exit 0
