#!/bin/bash
######################################
# linux主机系统初始化
# copyright by changgeyun
# date:2021-03-17
######################################

set -eu
LINE=""
#CentOS系列系统
IPADDR=10.0.0.6
PREFIX=24
GATEWAY=10.0.0.2
DNS1=114.114.114.114

#Ubuntu系列系统
U_ADDR=[10.0.0.6/24]
U_DNS=[114.114.114.114]
U_GATEWAY4=10.0.0.2


# 设置返回状态
color () {
	COUNT=60
	SETCOLOR_COUNT="echo -en \\E[${COUNT}G"
	SETCOLOR_SUCCESS="echo -en \\E[1;32m"
	SETCOLOR_FAILED="echo -en \\E[1;31m"
	SETCOLOR_WARNING="echo -en \\E[1;33m"
	SETCOLOR_END="echo -en \\E[0m"
	echo -en "$1" && ${SETCOLOR_COUNT}
	echo -en "["
	if [ $2 = "0" -o $2 = "success" ] ;then
		${SETCOLOR_SUCCESS}
		echo -n " OK "
	elif [ $2 = "1" ] ;then
		${SETCOLOR_FAILED}
		echo -n " FAILED "
	else
		${SETCOLOR_WARNING}
		echo -n " WARNING "
	fi
	${SETCOLOR_END}
	echo -en "]"
	echo
}

#修改.vimrc
initial_vimrc(){
color "开始配置vimrc" 0
#local OS=`whoami`
cat > /root/.vimrc <<-EOF
"设置tab建的格数
set ts=4
set paste

autocmd BufNewFile *.py,*.cc,*.sh,*.java exec ":call SetTitle()"
func SetTitle()
    if expand("%:e") == 'sh'
        call setline(1, "#!/bin/bash")
        call setline(2, "##############################################")
        call setline(3, "#File Name: ".expand("%"))
        call setline(4, "#Version: V1.0")
        call setline(5, "#Author: ")
        call setline(6, "#Created Time: ".strftime("%F %T"))
        call setline(7, "#Description: ")
        call setline(8, "##############################################")
        call setline(9, "")
    endif
endfunc

"新建文件后，自动定位到文件末尾 
autocmd BufNewFile * normal G
EOF
color "完成" 0
echo
}

# 判断操作系统类型
os_type () {
	awk -F'[ |"]' '/^NAME/{print $2}' /etc/os-release
}

# 操作系统版本
os_version () {
	awk -F'[ |.|"]' '/^VERSION_ID/{print $2}' /etc/os-release
}


#仓库源
pool_src () {
	color "开始配置仓库源" 0
	ping -c1 www.baidu.com &> /dev/null || { color "网络不通" 1 ;exit; }
	if [ `os_type` == "Ubuntu" -a `os_version` == '18' ];then
		sudo tee > /etc/apt/sources.list <<-EOF
		deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
		deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
		
		deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
		deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
		
		deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
		deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
		
		deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
		deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
		
		deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
		deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
		EOF
	
		apt update
	elif [ `os_type` == "Ubuntu" -a `os_version` == '16' ];then
		sudo tee > /etc/apt/sources.list <<-EOF
		deb http://mirrors.aliyun.com/ubuntu/ xenial main
		deb-src http://mirrors.aliyun.com/ubuntu/ xenial main
		
		deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main
		deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main
		
		deb http://mirrors.aliyun.com/ubuntu/ xenial universe
		deb-src http://mirrors.aliyun.com/ubuntu/ xenial universe
		deb http://mirrors.aliyun.com/ubuntu/ xenial-updates universe
		deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates universe
		
		deb http://mirrors.aliyun.com/ubuntu/ xenial-security main
		deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main
		deb http://mirrors.aliyun.com/ubuntu/ xenial-security universe
		deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security universe
		EOF
		apt update
	elif [ `os_type` == "Ubuntu" -a `os_version` == '20' ];then
		sudo tee > /etc/apt/sources.list <<-EOF
		deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
		deb-src http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
		
		deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
		deb-src http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
		
		deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
		deb-src http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
		
		deb http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse
		deb-src http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse
		
		deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
		deb-src http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
		EOF
	
	elif [ `os_type` == "CentOS" -a `os_version` == '8' ];then
		rm -rf /etc/yum.repos.d/CentOS*
		curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo
		yum clean all && yum makecache
	elif [ `os_type` == "CentOS" -a `os_version` == '7' ];then
		rm -rf /etc/yum.repos.d/CentOS*
		curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
		yum clean all && yum makecache
	
	elif [ `os_type` == "Rocky" ];then
		sed -i.bak -e 's|^mirrorlist=|#mirrorlist=|g' -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g' /etc/yum.repos.d/Rocky-*.repo
		dnf makecache
	elif [ `os_type` == "Debian" ];then
		sudo tee > /etc/apt/sources.list <<-EOF
		deb [by-hash=force] http://mirrors.aliyun.com/deepin apricot main contrib non-free
		EOF
		
	else
		color "仓库源配置失败" 1
	fi
	color "完成" 0
}


# 关闭防火墙SELINUX
close_firewall_selinux_soft () {
	color "防火墙SELINU关闭,软件初始化" 0
	if [ `os_type` == "CentOS" -o `os_type` == "Rocky" -o `os_type` == "RedHat" ];then
		systemctl disable firewalld.service && systemctl stop firewalld.service
		sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
		setenforce 0
		yum -y install vim-enhanced tcpdump lrzsz tree telnet bash-completion net-tools wget bzip2 lsof tmux man-pages zip unzip nfs-utils gcc make gcc-c++ glibc glibc-devel pcre pcre-devel openssl  openssl-devel systemd-devel zlib-devel expect dos2unix
		echo 'PS1="[\[\e[1;31m\]\t \[\e[1;35m\]\u@\h \[\e[1;30m\]\w\[\e[0m\]]\\$ "' > /etc/profile.d/env.sh
	elif [ `os_type` == "Ubuntu" -o `os_type` == "Debian" ];then
		apt purge -y ufw lxd lxd-client lxcfs liblxc-common
		
		apt install -y iproute2 ntpdate tcpdump telnet traceroute \
		nfs-kernel-server nfs-common lrzsz tree openssl libssl-dev \
		libpcre3 libpcre3-dev zlib1g-dev gcc iotop \
		unzip zip network-manager
		echo 'PS1="[\[\e[1;31m\]\t \[\e[1;35m\]\u@\h \[\e[1;30m\]\w\[\e[0m\]]\\$ "' > /etc/profile.d/env.sh
	else
		color "系统版本是$(os_type) $(os_version) 请修改脚本"  2
		exit
	fi
	color "完成" 0
	echo 
}

# 修改网卡名
change_network () {
	color "开始修改网卡名" 0
	if [ `os_type` == "CentOS" -o `os_type` == "Rocky" -o `os_type` == "RedHat" ];then
		sed -ri 's/^(GRUB_CMDLINE_LINUX=.*)(")$/\1 net.ifnames=0\2/' /etc/default/grub
		grub2-mkconfig -o /boot/grub2/grub.cfg
		cat > /etc/sysconfig/network-scripts/ifcfg-eth0 <<-EOF
		NAME=eth0
		DEVICE=eth0
		BOOTPROTO=static
		IPADDR=${IPADDR}
		PREFIX=${PREFIX}
		GATEWAY=${GATEWAY}
		DNS1=${DNS1}
		ONBOOT=yes
		EOF
		
	elif [ `os_type` == "Ubuntu" -o `os_type` == "Debian" ];then
		sed -ri 's/^(GRUB_CMDLINE_LINUX=")(.*)(")$/\1net.ifnames=0 biosdevname=0\3/' /etc/default/grub
		update-grub
		apt install network-manager -y
		sed -ri 's/^managed=false/managed=true/' /etc/NetworkManager/NetworkManager.conf
		sudo systemctl restart network-manager.service
		sudo cat >/etc/netplan/01-netcfg.yaml <<-EOF
		network:
		version: 2
		renderer: networkd
		ethernets:
			eth0:
			dhcp4: no
			dhcp6: no
			addresses: ${U_ADDR}
			gateway4: ${U_GATEWAY4}
			nameservers:
				addresses: ${U_DNS}
		EOF
		sed -i.bak 's/renderer: networkd/renderer: NetworkManager/' /etc/netplan/01-netcfg.yaml
		sudo netplan apply
		
	else
		color "系统版本是$(os_type) $(os_version) 请修改脚本"  2
		exit
	fi
	color "完成" 0
	echo
}

# 如果为CentOS系列操作系统
main () {
	pool_src
	initial_vimrc
	close_firewall_selinux_soft
	change_network
}
main
