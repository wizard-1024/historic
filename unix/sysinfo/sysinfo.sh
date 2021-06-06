#!/bin/sh

#
# System hardware and software information 
# for FreeBSD 
#
# Copyright (c) 2001-2004 Dmitry Stefankov
#
# $Id: sysinfo.sh,v 1.12 2004-12-20 14:44:20+03 dstef Exp root $
#

#
# 3rd-party packages that can be used
# DMIDECODE v2.4+  (WWW: http://www.nongnu.org/dmidecode)
#

UNAME=/usr/bin/uname
HOSTNAME=/bin/hostname
CAT=/bin/cat
IFCONFIG=/sbin/ifconfig
DF=/bin/df
NETSTAT=/usr/bin/netstat
PKG_INFO=/usr/sbin/pkg_info
ECHO=/bin/echo
SORT=/usr/bin/sort
FIND=/usr/bin/find
UNIQ=/usr/bin/uniq
RM=/bin/rm
GREP=/usr/bin/grep
COMM=/usr/bin/comm
SWAPINFO=/usr/sbin/swapinfo
LASTLOGIN=/usr/sbin/lastlogin
PCICONF=/usr/sbin/pciconf
AWK=/usr/bin/awk
CRONTAB=/usr/bin/crontab
SYSCTL=/sbin/sysctl
QUOT=/usr/sbin/quot
LDCONFIG=/sbin/ldconfig
USBDEVS=/usr/sbin/usbdevs
PNPINFO=/usr/sbin/pnpinfo
VIDCONTROL=/usr/sbin/vidcontrol
KLDSTAT=/sbin/kldstat
IPFW=/sbin/ipfw
SOCKSTAT=/usr/bin/sockstat
WC=/usr/bin/wc
TR=/usr/bin/tr
LS=/bin/ls
DATE=/bin/date
UPTIME=/usr/bin/uptime
MPTABLE=/usr/sbin/mptable
IPCS=/usr/bin/ipcs
PAGESIZE=/usr/bin/pagesize
TAIL=/usr/bin/tail
ATACONTROL=/sbin/atacontrol
DMIDECODE=/usr/local/sbin/dmidecode
BIOSDECODE=/usr/local/sbin/biosdecode


# Variables
TMPF1=/tmp/tmp1.$$
TMPF2=/tmp/tmp2.$$


# Flags
show_uptime_info=1
show_date_info=1
show_host_info=1
show_boot_info=1
show_filesys_info=1
show_quota_info=1
show_rc_conf_info=1
show_rc_local_info=1
show_inetif_info=1
show_netroutes_info=1
show_ipfw_info=1
show_packages_info=1
show_local_packs_info=1
show_all_users_info=1
show_logins_info=1
show_system_cron_info=1
show_user_cron_info=1
show_sysctl_info=1
show_pcibus_info=1
show_usbdevs_info=1
show_pnpinfo_info=1
show_vidctrl_info=0
show_kldstat_info=1
show_ldconf_info=1
show_hosts_info=1
show_host_conf_info=1
show_hosts_allow_info=1
show_resolv_conf_info=1
show_syslog_conf_info=1
show_newsyslog_conf_info=1
show_login_access_info=1
show_inetd_conf_info=1
show_pam_conf_info=1
show_ftpusers_info=1
show_sockstat_info=1
show_mail_hosts_info=1
show_mail_aliases_info=1
show_mail_relays_info=1
show_named_conf_info=1
show_local_daemons_info=1
show_ssh_config_info=1
show_system_programs_versions=1
show_sysconf_info=1
show_inet6_sysctl=0
show_smp_info=0
show_ipc_info=1
show_system_os_software_hardware_info=1
show_ata_info=1
show_dmi_info=1
show_bios_info=1


# Supplemental
os_version=`$SYSCTL kern.osrelease| $AWK '{print $2}'| $TR -dc "[:digit:]"`

PCI_CONF_FLAGS=-l
if [ $os_version -gt 44 ]; then
  PCI_CONF_FLAGS=-lv
fi

if [ $os_version -lt 46 ]; then
  show_ata_info=0
fi


# Header
$ECHO ""
$ECHO "------ Unix system information ----"
$ECHO ""
$ECHO ""

# Date/Time identification
if [ $show_date_info -eq 1 ]; then
  $ECHO "***[ Date/Time/Localisation ]***"
  $ECHO "Current date:   `(LANG="";$DATE)`"
  RC_CONF=/etc/rc.conf
  if [ -f $RC_CONF  ]; then
    CONF_LANG=`$GREP -v "^#" $RC_CONF|$GREP keymap|$TAIL -1|$AWK '{i=index($0,"="); if (i!=0) print substr($0,i+1) }'`
  fi
  $ECHO "Locale:         $CONF_LANG"
  if [ $show_uptime_info -eq 1 ]; then
    $ECHO "Uptime:         `(LANG=""; $UPTIME|$AWK '{i=index($0,",");if (i!=0){s=substr($0,1,i-1);print s}}')`"
  fi
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# Host identification
if [ $show_host_info -eq 1 ]; then
  $ECHO "***[ Host ]***"
  $ECHO "Hostname: `$HOSTNAME`"
  $ECHO "Architecture: `$UNAME -m`"
  $ECHO "OS: `$UNAME -sr`"
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# Boot information
if [ $show_boot_info -eq 1 ]; then
  DMESG_BOOT=/var/run/dmesg.boot
  $ECHO "***[ Boot information ]***"
  $ECHO ""
  if [ -f $DMESG_BOOT ]; then
    $CAT $DMESG_BOOT
  fi
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# SMP kernel
if [ $show_smp_info -eq 1 ]; then
   if [ -x $MPTABLE ]; then
     $ECHO "***[ MP configuration table ]***"
     $ECHO ""
     $MPTABLE -verbose
     $ECHO ""
     $ECHO ""
     $ECHO ""
   fi
fi

# PCI bus information
if [ $show_pcibus_info -eq 1 ]; then
   if [ -x $PCICONF ]; then
     $ECHO "***[ PCI bus information ]***"
     $ECHO ""
     $PCICONF $PCI_CONF_FLAGS
     $ECHO ""
     $ECHO ""
     $ECHO ""
   fi
fi

# USB bus devices
if [ $show_usbdevs_info -eq 1 ]; then
   if [ -x $USBDEVS ]; then
     $ECHO "***[ USB bus devices ]***"
     $ECHO ""
     $USBDEVS -v
     $ECHO ""
     $ECHO ""
     $ECHO ""
   fi
fi

# PNP information for ISA bus devices
if [ $show_pnpinfo_info -eq 1 ]; then
   if [ -x $PNPINFO ]; then
     $ECHO "***[ PNP ISA bus devices ]***"
     $ECHO ""
     $PNPINFO
     $ECHO ""
     $ECHO ""
     $ECHO ""
   fi
fi

# DMI information for system board
if [ $show_dmi_info -eq 1 ]; then
   if [ -x $DMIDECODE ]; then
     $ECHO "***[ Desktop Management Interface (DMI) info ]***"
     $ECHO ""
     $DMIDECODE
     $ECHO ""
     $ECHO ""
     $ECHO ""
   fi
fi

# BIOS information for system board
if [ $show_bios_info -eq 1 ]; then
   if [ -x $BIOSDECODE ]; then
     $ECHO "***[ Basic Input/Output System (BIOS) info ]***"
     $ECHO ""
     $BIOSDECODE
     $ECHO ""
     $ECHO ""
     $ECHO ""
   fi
fi

# Information for ATA/ATAPI devices
if [ $show_ata_info -eq 1 ]; then
   show_ata_master_channel_0=1
   show_ata_master_channel_1=1
   show_ata_master_channel_2=0
   show_ata_master_channel_3=0
   show_ata_slave_channel_0=1
   show_ata_slave_channel_1=0
   show_ata_slave_channel_2=0
   show_ata_slave_channel_3=0
   if [ -x $ATACONTROL ]; then
     $ECHO "***[ ATA/ATAPI devices info ]***"
     $ECHO ""
     $ATACONTROL list
     $ECHO ""
     if [ $show_ata_master_channel_0 -eq 1 -o $show_ata_slave_channel_0 -eq 1 ]; then
       $ECHO "Current transfer modes on channel 0"
       $ATACONTROL mode 0
       $ECHO ""
     fi
     if [ $show_ata_master_channel_1 -eq 1 -o $show_ata_slave_channel_1 -eq 1 ]; then
       $ECHO "Current transfer modes on channel 1"
       $ATACONTROL mode 1
       $ECHO ""
     fi
     if [ $show_ata_master_channel_2 -eq 1 -o $show_ata_slave_channel_2 -eq 1 ]; then
       $ECHO "Current transfer modes on channel 2"
       $ATACONTROL mode 2
       $ECHO ""
     fi
     if [ $show_ata_master_channel_3 -eq 1 -o $show_ata_slave_channel_3 -eq 1 ]; then
       $ECHO "Current transfer modes on channel 3"
       $ATACONTROL mode 3
       $ECHO ""
     fi
     if [ $show_ata_master_channel_0 -eq 1 ]; then
       $ECHO "Device 0 on channel 0"
       $ATACONTROL enclosure 0 0
       $ECHO ""
       $ATACONTROL cap 0 0
       $ECHO ""
     fi
     if [ $show_ata_slave_channel_0 -eq 1 ]; then
       $ECHO "Device 1 on channel 0"
       $ATACONTROL enclosure 0 1
       $ECHO ""
       $ATACONTROL cap 0 1
       $ECHO ""
     fi
     if [ $show_ata_master_channel_1 -eq 1 ]; then
       $ECHO "Device 0 on channel 1"
       $ATACONTROL enclosure 1 0
       $ECHO ""
       $ATACONTROL cap 1 0
       $ECHO ""
     fi
     if [ $show_ata_slave_channel_1 -eq 1 ]; then
       $ECHO "Device 1 on channel 1"
       $ATACONTROL enclosure 1 1
       $ECHO ""
       $ATACONTROL cap 1 1
       $ECHO ""
     fi
     if [ $show_ata_master_channel_2 -eq 1 ]; then
       $ECHO "Device 0 on channel 2"
       $ATACONTROL enclosure 2 0
       $ECHO ""
       $ATACONTROL cap 2 0
       $ECHO ""
     fi
     if [ $show_ata_slave_channel_2 -eq 1 ]; then
       $ECHO "Device 1 on channel 2"
       $ATACONTROL enclosure 2 1
       $ECHO ""
       $ATACONTROL cap 2 1
       $ECHO ""
     fi
     if [ $show_ata_master_channel_3 -eq 1 ]; then
       $ECHO "Device 0 on channel 3"
       $ATACONTROL enclosure 3 0
       $ECHO ""
       $ATACONTROL cap 3 0
       $ECHO ""
     fi
     if [ $show_ata_slave_channel_3 -eq 1 ]; then
       $ECHO "Device 1 on channel 3"
       $ATACONTROL enclosure 3 1
       $ECHO ""
       $ATACONTROL cap 3 1
       $ECHO ""
     fi
     $ECHO ""
     $ECHO ""
     $ECHO ""
   fi
fi

# Get video system control information
if [ $show_vidctrl_info -eq 1 ]; then
   if [ -x $VIDCONTROL ]; then
     $ECHO "***[ System console control info ]***"
     $ECHO ""
     $VIDCONTROL -i adapter
     $ECHO ""
     $ECHO ""
     $ECHO ""
   fi
fi

# Get system/software control information
if [ $show_system_os_software_hardware_info -eq 1 ]; then
   if [ -x $PAGESIZE ]; then
     $ECHO "***[ System OS hardware/software miscellaneous info ]***"
     $ECHO ""
     $ECHO "System page size: `$PAGESIZE`"
     $ECHO ""
     $ECHO ""
     $ECHO ""
   fi
fi


# System configuration (rc.conf)
if [ $show_rc_conf_info -eq 1 ]; then
  RC_CONF=/etc/rc.conf
  $ECHO "***[ System configuration ($RC_CONF) ]***"
  $ECHO ""
  if [ -f $RC_CONF ]; then
    $CAT $RC_CONF | $AWK '{ if (length($0)!=0) print $0 }'
  fi
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# System configuration (rc.local)
if [ $show_rc_local_info -eq 1 ]; then
  RC_LOCAL=/etc/rc.local
  $ECHO "***[ System configuration ($RC_LOCAL) ]***"
  $ECHO ""
  if [ -f $RC_LOCAL ]; then
    $CAT $RC_LOCAL | $AWK '{ if (length($0)!=0) print $0 }'
  fi
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# File systems
if [ $show_filesys_info -eq 1 ]; then
  $ECHO "***[ File systems and disks ]***"
  $ECHO ""
  FSTAB=/etc/fstab
  if [ -f $FSTAB ]; then
    $CAT $FSTAB
  fi
  $ECHO ""
  $ECHO "***[ Free disk space ]***"
  $ECHO ""
  $DF
  $ECHO ""
  if [ -x $SWAPINFO ]; then
    $ECHO "***[ Swap space ]***"
    $ECHO ""
    $SWAPINFO
    $ECHO ""
    $ECHO ""
    $ECHO ""
  fi
fi

# Show occupied disk space for each user
if [ $show_quota_info -eq 1 ]; then
   $ECHO "***[ Disk space occupied by each user ]***"
   $ECHO ""
   $QUOT -a
   $ECHO ""
   $ECHO ""
   $ECHO ""
fi

# Display list of all users
if [ $show_all_users_info -eq 1 ]; then
   MASTER_PASSWD=/etc/master.passwd
   $ECHO "***[ Users with normal login (non-empty password) ]***"
   $ECHO ""
   if [ -f $MASTER_PASSWD ]; then
     $GREP -v "^#" $MASTER_PASSWD | $AWK -F: '{ if ((length($2) != 0) && ($2 != "*")) print $1,"\t\t",$8 }'
   fi
   $ECHO ""
   $ECHO "***[ Users without normal login (password='*') ]***"
   $ECHO ""
   if [ -f $MASTER_PASSWD ]; then
     $GREP -v "^#" $MASTER_PASSWD | $AWK -F: '{ if ($2 == "*") print $1,"\t\t",$8 }'
   fi
   $ECHO ""
   $ECHO "***[ Users with empty password ]***"
   $ECHO ""
   if [ -f $MASTER_PASSWD ]; then
     $GREP -v "^#" $MASTER_PASSWD | $AWK -F: '{ if (length($2) == 0) print $1,"\t\t",$8 }'
   fi
   $ECHO ""
   $ECHO "***[ User groups ]***"
   $ECHO ""
   GROUP=/etc/group
   if [ -f $GROUP ]; then
     $GREP -v "^#" $GROUP
   fi
   $ECHO ""
   $ECHO ""
fi

# Show user logins
if [ $show_logins_info -eq 1 ]; then
  if [ -x $LASTLOGIN ]; then
    $ECHO "***[ Last logins ]***"
    $ECHO ""
    $LASTLOGIN
    $ECHO ""
    $ECHO ""
    $ECHO ""
  fi
fi

# Show system crontab
if [ $show_system_cron_info -eq 1 ]; then
  $ECHO "***[ Crontab for system ]***"
  $ECHO ""
  ETC_CRONTAB=/etc/crontab
  if [ -f $ETC_CRONTAB ]; then
    $GREP -v "^#" $ETC_CRONTAB | $AWK '{if (length($0)!=0) print $0 }'
  fi
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# Show users crontab
if [ $show_user_cron_info -eq 1 ]; then
  $ECHO "***[ Crontab for root ]***"
  $ECHO ""
  $CRONTAB -u root -l
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# System V IPC facilities status
if [ $show_ipc_info -eq 1 ]; then
  if [ -x $IPCS ]; then
    $ECHO "***[ System V IPC status ]***"
    $ECHO ""
    $IPCS -SQT
    $ECHO ""
    $ECHO ""
    $ECHO ""
  fi
fi

# Network interfaces
if [ $show_inetif_info -eq 1 ]; then
  $ECHO "***[ Network interfaces ]***"
  $ECHO ""
  $IFCONFIG -a
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# Network routes
if [ $show_netroutes_info -eq 1 ]; then
  $ECHO "***[ Network route table ]***"
  $ECHO ""
  $NETSTAT -rn
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

if [ $show_ipfw_info -eq 1 ]; then
  $ECHO "***[ IP firewall loaded rules ]***"
  $ECHO ""
  $IPFW -a l
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

if [ $show_sockstat_info -eq 1 ]; then
  $ECHO "***[ List listening sockets ]***"
  $ECHO ""
  $SOCKSTAT -l
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# System configuration (hosts)
if [ $show_hosts_info -eq 1 ]; then
  HOSTS=/etc/hosts
  $ECHO "***[ System configuration ($HOSTS) ]***"
  $ECHO ""
  if [ -f $HOSTS ]; then
    $GREP -v "^#" $HOSTS | $AWK '{if (length($0)!=0) print $0 }'
  fi
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# System configuration (host.conf)
if [ $show_host_conf_info -eq 1 ]; then
  HOST_CONF=/etc/host.conf
  $ECHO "***[ System configuration ($HOST_CONF) ]***"
  $ECHO ""
  if [ -f $HOST_CONF ]; then
    $GREP -v "^#" $HOST_CONF | $AWK '{if (length($0)!=0) print $0 }'
  fi
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# System configuration (resolv.conf)
if [ $show_resolv_conf_info -eq 1 ]; then
  RESOLV_CONF=/etc/resolv.conf
  $ECHO "***[ System configuration ($RESOLV_CONF) ]***"
  $ECHO ""
  if [ -f $RESOLV_CONF ]; then
    $CAT $RESOLV_CONF | $AWK '{if (length($0)!=0) print $0 }'
  fi
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# System configuration (hosts.allow)
if [ $show_hosts_allow_info -eq 1 ]; then
  HOSTS_ALLOW=/etc/hosts.allow
  $ECHO "***[ System configuration ($HOSTS_ALLOW) ]***"
  $ECHO ""
  if [ -f $HOSTS_ALLOW ]; then
    $GREP -v "^#" $HOSTS_ALLOW | $AWK '{if (length($0)!=0) print $0 }'
  fi
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# System configuration (inetd.conf)
if [ $show_inetd_conf_info -eq 1 ]; then
  INETD_CONF=/etc/inetd.conf
  $ECHO "***[ System configuration ($INETD_CONF) ]***"
  $ECHO ""
  if [ -f $INETD_CONF ]; then
    $GREP -v "^#" $INETD_CONF | $AWK '{if (length($0)!=0) print $0 }'
  fi
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# System configuration (syslog.conf)
if [ $show_syslog_conf_info -eq 1 ]; then
  SYSLOGD_CONF=/etc/syslog.conf
  $ECHO "***[ System configuration ($SYSLOGD_CONF) ]***"
  $ECHO ""
  if [ -f $SYSLOGD_CONF ]; then
    $GREP -v "^#" $SYSLOGD_CONF | $AWK '{if (length($0)!=0) print $0 }'
  fi
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# System configuration (newsyslog.conf)
if [ $show_newsyslog_conf_info -eq 1 ]; then
  NEWSYSLOG_CONF=/etc/newsyslog.conf
  $ECHO "***[ System configuration ($NEWSYSLOG_CONF) ]***"
  $ECHO ""
  if [ -f $NEWSYSLOG_CONF ]; then
    $GREP -v "^#" $NEWSYSLOG_CONF | $AWK '{if (length($0)!=0) print $0 }'
  fi
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# System configuration (pam.conf)
if [ $show_pam_conf_info -eq 1 ]; then
  PAM_CONF=/etc/pam.conf
  $ECHO "***[ System configuration ($PAM_CONF) ]***"
  $ECHO ""
  if [ -f $PAM_CONF ]; then
    $GREP -v "^#" $PAM_CONF | $AWK '{if (length($0)!=0) print $0 }'
  fi
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# System configuration (login.access)
if [ $show_login_access_info -eq 1 ]; then
  LOGIN_ACCESS=/etc/login.access
  $ECHO "***[ System configuration ($LOGIN_ACCESS) ]***"
  $ECHO ""
  if [ -f $LOGIN_ACCESS ]; then
    $GREP -v "^#" $LOGIN_ACCESS | $AWK '{if (length($0)!=0) print $0 }'
  fi
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# System configuration (ftpusers)
if [ $show_ftpusers_info -eq 1 ]; then
  FTPUSERS=/etc/ftpusers
  $ECHO "***[ System configuration ($FTPUSERS) ]***"
  $ECHO ""
  if [ -f $FTPUSERS ]; then
    $GREP -v "^#" $FTPUSERS | $AWK '{if (length($0)!=0) print $0 }'
  fi
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# System configuration (ssh)
if [ $show_ssh_config_info -eq 1 ]; then
  SSH_CONFIG=/etc/ssh/ssh_config
  $ECHO "***[ SSH client configuration ($SSH_CONFIG) ]***"
  $ECHO ""
  if [ -f $SSH_CONFIG ]; then
    $GREP -v "^#" $SSH_CONFIG | $AWK '{if (length($0)!=0) print $0 }'
  fi
  SSHD_CONFIG=/etc/ssh/sshd_config
  $ECHO ""
  $ECHO "***[ SSH server configuration ($SSHD_CONFIG) ]***"
  $ECHO ""
  if [ -f $SSHD_CONFIG ]; then
    $GREP -v "^#" $SSHD_CONFIG | $AWK '{if (length($0)!=0) print $0 }'
  fi
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# Mail configuration (hosts)
if [ $show_mail_hosts_info -eq 1 ]; then
  LOCAL_HOST_NAMES=/etc/mail/local-host-names
  if [ -f $LOCAL_HOST_NAMES ]; then
    $ECHO "***[ Mail configuration (LOCAL_HOST_NAMES) ]***"
    $ECHO ""
    $GREP -v "^#" $LOCAL_HOST_NAMES | $AWK '{if (length($0)!=0) print $0 }'
    $ECHO ""
    $ECHO ""
    $ECHO ""
  fi
fi

# Mail configuration (relays)
if [ $show_mail_relays_info -eq 1 ]; then
  RELAY_DOMAINS=/etc/mail/relay-domains
  if [ -f $RELAY_DOMAINS ]; then
    $ECHO "***[ Mail configuration (RELAY_DOMAINS) ]***"
    $ECHO ""
    $GREP -v "^#" $RELAY_DOMAINS | $AWK '{if (length($0)!=0) print $0 }'
    $ECHO ""
    $ECHO ""
    $ECHO ""
  fi
fi

# Mail configuration (aliases)
if [ $show_mail_aliases_info -eq 1 ]; then
  ALIASES=/etc/mail/aliases
  $ECHO "***[ Mail configuration ($ALIASES) ]***"
  $ECHO ""
  if [ -f $ALIASES ]; then
    $GREP -v "^#" $ALIASES | $AWK '{if (length($0)!=0) print $0 }'
  fi
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# Mail configuration (aliases)
if [ $show_named_conf_info -eq 1 ]; then
  NAMED_CONF=/etc/namedb/named.conf
  RC_CONF=/etc/rc.conf
  $ECHO "***[ BIND configuration ($NAMED_CONF) ]***"
  $ECHO ""
  if [ -f $RC_CONF ]; then
    res=`$GREP -v "^#" $RC_CONF|$GREP 'named_enable="YES"'|$WC -l|$TR -d " "`
    if [ $res -ge 1 ]; then
       $GREP -v "^#" $NAMED_CONF | $AWK '{if (length($0)!=0) print $0 }'
    fi
  fi
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# System configuration (local daemons)
if [ $show_local_daemons_info -eq 1 ]; then
  LOCAL_RC_D=/usr/local/etc/rc.d
  $ECHO "***[ System configuration () ]***"
  $ECHO ""
  if [ -d $LOCAL_RC_D ]; then
    $LS $LOCAL_RC_D/*.sh 2>/dev/null
  fi
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# System programs version
if [ $show_system_programs_versions -eq 1 ]; then
  LOCAL_RC_D=/usr/local/etc/rc.d
  $ECHO "***[ System configuration ($LOCAL_RC_D) ]***"
  SYS_BIND=/usr/sbin/named
  if [ -x $SYS_BIND ]; then
     $ECHO ""    
     $ECHO "$SYS_BIND"
     $SYS_BIND -v
  fi
  PKG_BIND=/usr/local/sbin/named
  if [ -x $PKG_BIND ]; then
     $ECHO ""
     $ECHO "$PKG_BIND"
     $PKG_BIND -v
  fi
  PKG_APACHE=/usr/local/sbin/httpd
  if [ -x $PKG_APACHE ]; then
     $ECHO ""
     $ECHO "$PKG_APACHE"
     $PKG_APACHE -v
  fi
  PKG_SENDMAIL_CF=/etc/mail/sendmail.cf
  PKG_SENDMAIL=/usr/sbin/sendmail
  if [ -f $PKG_SENDMAIL_CF ]; then
     $ECHO ""
     $ECHO "$PKG_SENDMAIL"
     sendmail_version=`$GREP ^DZ $PKG_SENDMAIL_CF|$TR -d "DZ"`
     $ECHO "version: $sendmail_version"
  fi
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi

# Software packages
if [ $show_packages_info -eq 1 ]; then
  if [ -x $PKG_INFO ]; then
    $ECHO "***[ Installed software packages ]***"
    $ECHO ""
    $PKG_INFO -Ia
    $ECHO ""
    $ECHO ""
    $ECHO ""
  fi
fi

# Scan local paths
if [ $show_local_packs_info -eq 1 ]; then
  if [ -x $PKG_INFO ]; then
    mypath=/usr/local/bin
    $ECHO "***[ Mismatched files on $mypath ]***"
    $ECHO ""
    $FIND $mypath -type f -print | $SORT | $UNIQ -u >$TMPF1
    $PKG_INFO -aL | $GREP $mypath | $SORT | $UNIQ -u >$TMPF2
    $COMM -23 $TMPF1 $TMPF2
    $ECHO ""
    $ECHO ""
    $ECHO ""

    mypath=/usr/local/sbin
    $ECHO "***[ Mismatched files on $mypath ]***"
    $ECHO ""
    $FIND $mypath -type f -print | $SORT | $UNIQ -u >$TMPF1
    $PKG_INFO -aL | $GREP $mypath | $SORT | $UNIQ -u >$TMPF2
    $COMM -23 $TMPF1 $TMPF2
    $ECHO ""
    $ECHO ""
    $ECHO ""

    mypath=/usr/local/libexec
    $ECHO "***[ Mismatched files on $mypath ]***"
    $ECHO ""
    $FIND $mypath -type f -print | $SORT | $UNIQ -u >$TMPF1
    $PKG_INFO -aL | $GREP $mypath | $SORT | $UNIQ -u >$TMPF2
    $COMM -23 $TMPF1 $TMPF2
    $ECHO ""
    $ECHO ""
    $ECHO ""
  fi
fi

# Show system configuration
if [ $show_sysctl_info -eq 1 ]; then
  SYSCONF=/usr/local/sbin/sysconf
  if [ -x $SYSCONF ]; then
    $ECHO "***[ System configuration parameters (Posix,libc) ]***"
    $ECHO ""
    $SYSCONF
    $ECHO ""
    $ECHO ""
    $ECHO ""
  fi
fi

# System kernel variables
if [ $show_sysctl_info -eq 1 ]; then
  SYSCTL_TMP_FILE=/tmp/systcl.out.$$
  $SYSCTL -Aa >$SYSCTL_TMP_FILE
  $ECHO "***[ Kernel general parameters ]***"
  $ECHO ""
  $GREP ^kern. $SYSCTL_TMP_FILE | grep -v ^kern.ipc
  $ECHO ""
  $ECHO "***[ Kernel IPC parameters ]***"
  $ECHO ""
  $GREP ^kern.ipc $SYSCTL_TMP_FILE
  $ECHO ""
  $ECHO "***[ Kernel MACH parameters ]***"
  $ECHO ""
  $GREP ^machdep. $SYSCTL_TMP_FILE
  $ECHO ""
  $ECHO "***[ Kernel hardware parameters ]***"
  $ECHO ""
  $GREP ^hw. $SYSCTL_TMP_FILE
  $ECHO ""
  $ECHO "***[ Virtual memory parameters ]***"
  $ECHO ""
  $GREP ^vm. $SYSCTL_TMP_FILE
  $ECHO ""
  $ECHO "***[ Virtual file system parameters ]***"
  $ECHO ""
  $GREP ^vfs. $SYSCTL_TMP_FILE
  $ECHO ""
  $ECHO "***[ Kernel debug parameters ]***"
  $ECHO ""
  $GREP ^debug. $SYSCTL_TMP_FILE
  $ECHO ""
  $ECHO "***[ Kernel networking parameters ]***"
  $ECHO ""
  $GREP ^net.local $SYSCTL_TMP_FILE
  $GREP ^net.inet $SYSCTL_TMP_FILE
  $GREP ^net.link $SYSCTL_TMP_FILE
  $GREP ^net.key $SYSCTL_TMP_FILE
  if [ $show_inet6_sysctl -eq 1 ]; then
    $GREP ^net.inet6 $SYSCTL_TMP_FILE
  fi
  $ECHO ""
  $ECHO "***[ Kernel user/Posix.2 parameters ]***"
  $ECHO ""
  $GREP ^user. $SYSCTL_TMP_FILE
  $ECHO ""
  $ECHO "***[ Kernel Posix 1003.1b parameters ]***"
  $ECHO ""
  $GREP ^p1003_1b. $SYSCTL_TMP_FILE
  $ECHO ""
  $ECHO "***[ Kernel Jail parameters ]***"
  $ECHO ""
  $GREP ^jail. $SYSCTL_TMP_FILE
  $ECHO ""
  $ECHO "***[ Kernel other OS compatibility parameters ]***"
  $ECHO ""
  $GREP ^compat. $SYSCTL_TMP_FILE
  $ECHO ""
  $ECHO ""
  $ECHO ""
  rm -f $SYSCTL_TMP_FILE
fi

# Dynamic kernel linker status
if [ $show_kldstat_info -eq 1 ]; then
   if [ -x $KLDSTAT ]; then
     $ECHO "***[ Dynamic kernel linker status ]***"
     $ECHO ""
     $KLDSTAT -v
     $ECHO ""
     $ECHO ""
     $ECHO ""
   fi
fi

# Dynamic libraries
if [ $show_ldconf_info -eq 1 ]; then
  $ECHO "***[ Shared library cache ]***"
  $ECHO ""
  $LDCONFIG -rv
  $ECHO ""
  $ECHO ""
  $ECHO ""
fi


# Delete temporary files
$RM -f $TMPF1 $TMPF2
