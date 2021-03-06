#!/bin/bash
#
# CloudIt.sh <Application> [CompilerOptions] [QemuOptions]
#
# Example: CloudIt.sh ToroHello "-dEnableDebug -dDebugProcess" "vnc :0"
#
# Copyright (c) 2003-2020 Matias Vara <matiasevara@gmail.com>
# All Rights Reserved
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

app="$1";
appsrc="$app.pas";
qemufile="qemu.args";
compileropt="$2";
export KERNEL_HEAD=$(git rev-parse HEAD|cut -c1-7)

# check parameters
if [ "$#" -lt 1 ]; then
   echo "Usage: CloudIt.sh ApplicationName [CompilerOptions] [QemuOptions]"
   echo "Example: CloudIt.sh ToroHello \"-dEnableDebug -dDebugProcess\" \"vnc :0\""
   exit 1
fi

# get the qemu parameters
if [ -f $qemufile ]; then
   qemuparams=`cat $qemufile`
else
   # parameters by default
   qemuparams="-enable-kvm -M microvm,pic=off,pit=off,rtc=off -cpu host -m 16 -smp 1 -nographic -D qemu.log -d guest_errors -no-reboot"
fi

# remove all compiled files
rm -f ../../rtl/*.o ../../rtl/*.ppu ../../rtl/drivers/*.o ../../rtl/drivers/*.ppu

# remove the application
rm -f $app "$app.o"

if [ -f $appsrc ]; then
   fpc $compileropt -Xm -Si -TLinux -O2 $appsrc -o$app -Fu../../rtl/ -Fu../../rtl/drivers -MObjfpc
   ~/qemulast/build/x86_64-softmmu/qemu-system-x86_64 -kernel $app $qemuparams $3
else
   echo "$appsrc does not exist, exiting"
   exit 1
fi
