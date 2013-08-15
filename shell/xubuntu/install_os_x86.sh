#!/bin/bash -e

# Auteur : darkpawn
# Date : 2013-08-15
# Description : scripts d'installation d'un pc de bureautique

# Definition des commandes
UPGRADE=$(apt-get update ; apt-get upgrade --force-yes -y ; apt-get dist-upgrade --force-yes)
INSTALL=$(apt-get install --force-yes -y )
USER="darkpawn"
ROOT_EMAIL=my-account@gmail.com

# Acquisition des droits root
sudo -s

########################
#### DEPOTS PRECISE ####
########################
# Dépots Ubuntu Précise pour le client vmware view
echo "Ajout du dépots Ubuntu Précise ..."
echo -e "#### Dépots Ubuntu ####

# Classique
deb http://fr.archive.ubuntu.com/ubuntu/ precise main restricted
deb-src http://fr.archive.ubuntu.com/ubuntu/ precise main restricted
deb http://fr.archive.ubuntu.com/ubuntu/ precise-updates main restricted
deb-src http://fr.archive.ubuntu.com/ubuntu/ precise-updates main restricted

# Universe
deb http://fr.archive.ubuntu.com/ubuntu/ precise universe
deb-src http://fr.archive.ubuntu.com/ubuntu/ precise universe
deb http://fr.archive.ubuntu.com/ubuntu/ precise-updates universe
deb-src http://fr.archive.ubuntu.com/ubuntu/ precise-updates universe

# Multiverse
deb http://fr.archive.ubuntu.com/ubuntu/ precise multiverse
deb-src http://fr.archive.ubuntu.com/ubuntu/ precise multiverse
deb http://fr.archive.ubuntu.com/ubuntu/ precise-updates multiverse
deb-src http://fr.archive.ubuntu.com/ubuntu/ precise-updates multiverse

# Partner
deb http://archive.canonical.com/ubuntu precise partner
deb-src http://archive.canonical.com/ubuntu precise partner

# Extras
deb http://extras.ubuntu.com/ubuntu precise main
deb-src http://extras.ubuntu.com/ubuntu precise main" > /etc/apt/sources.list.precise

#######################
#### Depots Raring ####
#######################
echo "Ajout du dépots Ubuntu Raring ..."
echo -e "#### Dépots Ubuntu ####

# Classique
deb http://fr.archive.ubuntu.com/ubuntu/ raring main restricted
deb-src http://fr.archive.ubuntu.com/ubuntu/ raring main restricted
deb http://fr.archive.ubuntu.com/ubuntu/ raring-updates main restricted
deb-src http://fr.archive.ubuntu.com/ubuntu/ raring-updates main restricted

# Universe
deb http://fr.archive.ubuntu.com/ubuntu/ raring universe
deb-src http://fr.archive.ubuntu.com/ubuntu/ raring universe
deb http://fr.archive.ubuntu.com/ubuntu/ raring-updates universe
deb-src http://fr.archive.ubuntu.com/ubuntu/ raring-updates universe

# Multiverse
deb http://fr.archive.ubuntu.com/ubuntu/ raring multiverse
deb-src http://fr.archive.ubuntu.com/ubuntu/ raring multiverse
deb http://fr.archive.ubuntu.com/ubuntu/ raring-updates multiverse
deb-src http://fr.archive.ubuntu.com/ubuntu/ raring-updates multiverse

# Partner
deb http://archive.canonical.com/ubuntu raring partner
deb-src http://archive.canonical.com/ubuntu raring partner

# Extras
deb http://extras.ubuntu.com/ubuntu raring main
deb-src http://extras.ubuntu.com/ubuntu raring main" > /etc/apt/sources.list.raring

echo "Application du dépots Ubuntu raring ..."
cp -fva /etc/apt/sources.list.raring /etc/apt/sources.list

#########################
#### UPGRADE DE L'OS ####
#########################
echo "Mise à jour du système ..."
$UPGRADE

echo "Arrêt de apport ..."
echo "enabled=0" > /etc/default/apport
/etc/init.d/apport stop

################
#### THEMES ####
################
echo "Installation du thème ..."
$INSTALL ubuntustudio-look ubuntustudio-icon-theme ubuntustudio-lightdm-theme ubuntustudio-menu ubuntustudio-look

echo "Modification du splash screen ..."
sleep 1
update-alternatives --install /lib/plymouth/themes/default.plymouth default.plymouth /lib/plymouth/themes/ubuntustudio-logo/ubuntustudio-logo.plymouth 100
update-alternatives --config default.plymouth
update-initramfs -u

##################
#### SECURITE ####
##################

## FIREWALL ##
mkdir /root/tools
echo -e "#!/bin/bash
# Auteur : darkpawn
# Date : 2013-08-15
# Script de firewalling

# Vider les tables actuelles
iptables -t filter -F

# Vider les règles personnelles
iptables -t filter -X

# Interdire toute connexion entrante
iptables -t filter -P INPUT DROP
iptables -t filter -P FORWARD ACCEPT
iptables -t filter -P OUTPUT ACCEPT

# Ne pas casser les connexions etablies
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Autoriser loopback
iptables -t filter -A INPUT -i lo -j ACCEPT
iptables -t filter -A OUTPUT -o lo -j ACCEPT

# ICMP (Ping)
iptables -t filter -A INPUT -p icmp -j ACCEPT
iptables -t filter -A OUTPUT -p icmp -j ACCEPT

# SSH In
iptables -t filter -A INPUT -p tcp --dport 2222 -j ACCEPT" > /root/tools/firewall

chmod -v 700 /root/tools/firewall
echo -e "#### FIREWALL ####
@reboot /root/tools/firewall 2>/dev/null 1>/dev/null" >> /var/spool/cron/crontabs/root

## NETTOYAGE ##
echo -e "#!/bin/bash
# Auteur : darkpawn
# Date : 2013-08-15
# Script de nettoyage

USERS=$(darkpawn)

clear

echo "Mise à jour du système ..."
apt-get update
apt-get upgrade --force-yes -y
apt-get dist-upgrade --force-yes -y
apt-get autoclean
apt-get autoremove
apt-get autoclean

echo "Applications des bons droits ..."
chown -R root:root /root
chown -R $USERS:$USERS /home/$USERS
chmod -R 700 /root /home/$USERS
chmod 711 /home

echo "Mise à jour de la base de données des fichiers ..."
updatedb

echo "Analyse antivirale ..."
sleep 1
freshclam
chkrootkit
rkhunter --update
rkhunter -c --sk
rkhunter --propupd

echo "Serveurs blacklistés ..."
cat /etc/hosts.deny" > /root/tools/nettoyage
chmod -v 700 /root/tools/nettoyage


echo "Installation des paquets de paquets de sécurisation ..."
$INSTALL rkhunter chkrootkit clamav denyhosts fail2ban lynis logwatch cron-apt

/bin/sed -i -e "s/^\\(root:\\).*\$/\\1 ${ROOT_EMAIL}/" \
         /etc/aliases

## CONFIGURATION FAIL2BAN ##
echo "Configuration de fail2ban ..."
/bin/sed -i -e '/\[ssh-ddos\]/, /filter/ {0,/^enabled.*/ s//enabled = true/ }' /etc/fail2ban/jail.conf
/bin/sed -i -e '/\[pam-generic\]/, /filter/ {0,/^enabled.*/ s//enabled = true/ }' /etc/fail2ban/jail.conf

## CONFIGURATION DENYHOSTS ..."
echo "Configuration de denyhosts ..."
echo -e "SECURE_LOG = /var/log/auth.log
HOSTS_DENY = /etc/hosts.deny

PURGE_DENY = 

BLOCK_SERVICE  = all

DENY_THRESHOLD_INVALID = 3
DENY_THRESHOLD_VALID = 5
DENY_THRESHOLD_ROOT = 1

DENY_THRESHOLD_RESTRICTED = 1

WORK_DIR = /var/lib/denyhosts
SUSPICIOUS_LOGIN_REPORT_ALLOWED_HOSTS=YES
HOSTNAME_LOOKUP=YES

LOCK_FILE = /run/denyhosts.pid

ADMIN_EMAIL = root@localhost
SMTP_HOST = localhost
SMTP_PORT = 25
SMTP_FROM = DenyHosts <nobody@localhost>
SMTP_SUBJECT = DenyHosts Report

AGE_RESET_VALID=25d
AGE_RESET_ROOT=50d
AGE_RESET_RESTRICTED=50d
AGE_RESET_INVALID=20d

DAEMON_LOG = /var/log/denyhosts
DAEMON_SLEEP = 30s
DAEMON_PURGE = 1h" > /etc/denyhosts.conf

echo -e "ALL: ALL" > /etc/hosts.deny

## MAJ AV ##
freshclam

## CONFIGURATION RKHUNTER ##
echo "Configuration de rkhunter ..."
echo -e "ROTATE_MIRRORS=1
UPDATE_MIRRORS=1

MIRRORS_MODE=0

MAIL-ON-WARNING=\"\"
MAIL_CMD=mail -s \"[rkhunter] Warnings found for ${HOST_NAME}\"

TMPDIR=/var/lib/rkhunter/tmp
DBDIR=/var/lib/rkhunter/db
SCRIPTDIR=/usr/share/rkhunter/scripts

UPDATE_LANG=\"\"
LOGFILE=/var/log/rkhunter.log
APPEND_LOG=0
COPY_LOG_ON_ERROR=0

COLOR_SET2=0
AUTO_X_DETECT=1
WHITELISTED_IS_WHITE=0

ALLOW_SSH_ROOT_USER=no
ALLOW_SSH_PROT_V1=0

ENABLE_TESTS=\"all\"
DISABLE_TESTS=\"suspscan hidden_procs deleted_files packet_cap_apps apps\"

SCRIPTWHITELIST=/bin/egrep
SCRIPTWHITELIST=/usr/bin/unhide.rb
SCRIPTWHITELIST=/bin/fgrep
SCRIPTWHITELIST=/bin/which
SCRIPTWHITELIST=/usr/bin/groups
SCRIPTWHITELIST=/usr/bin/ldd
SCRIPTWHITELIST=/usr/bin/lwp-request
SCRIPTWHITELIST=/usr/sbin/adduser
SCRIPTWHITELIST=/usr/sbin/prelink

IMMUTABLE_SET=0

ALLOWHIDDENDIR=\"/etc/.java\"
ALLOWHIDDENDIR=\"/dev/.udev\"

PHALANX2_DIRTEST=0
ALLOW_SYSLOG_REMOTE_LOGGING=0

SUSPSCAN_TEMP=/dev/shm
SUSPSCAN_MAXSIZE=10240000
SUSPSCAN_THRESH=200

USE_LOCKING=0
LOCK_TIMEOUT=300
SHOW_LOCK_MSGS=1

DISABLE_UNHIDE=1
INSTALLDIR=\"/usr\" " > /etc/rkhunter.conf

rkhunter --update
rkhunter --propupd

#####################
#### PAQUETS WEB ####
#####################
echo "Installation de paquets web ..."
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
$INSTALL flashplugin-installer openjdk-7-jdk openjdk-7-jre  icedtea-7-plugin google-chrome-stable skype

############################
#### PAQUETS MULTIMEDIA ####
############################
echo "Installation des paquets multimedia ..."
$INSTALL smplayer exaile gimp

########################
#### PAQUETS OFFICE ####
########################
echo "Installation des paquets office ..."
$INSTALL libreoffice libreoffice-l10n-fr

########################
#### PAQUETS UTILES ####
########################
echo "Installation des utilitaires ..."
$INSTALL git openvpn keepassx rdesktop wireshark glances iotop iftop tshark bwm-ng tmux homebank

#####################
#### VIEW CLIENT ####
#####################
echo "Installation du client View ..."
cp -fva /etc/apt/sources.list.precise /etc/apt/sources.list
apt-get update
$INSTALL vmware-view-client
cp -fva /etc/apt/sources.list.raring /etc/apt/sources.list

#######################
#### PAQUETS JEUX  ####
#######################
echo "Installation de JinChess ..."
cd /tmp/
wget "http://downloads.sourceforge.net/project/jin/jin/jin-2.14.1/jin-2.14.1-unix.tar.gz?r=http%3A%2F%2Fwww.jinchess.com%2Funix_download&ts=1376584748&use_mirror=heanet" -O jinchess.tar.gz
tar xzfv jinchess.tar.gz
mkdir -p /home/$USER/opt/jin
mv -v jin-*/* /home/$USER/opt/jin

echo -e "#!/bin/bash

# Auteur : darkpawn
# Date : 2013-08-15

cd $HOME/opt/jin/
java -jar ./jin.jar" > /home/$USER/opt/bin/jinchess

chown -R $USER:$USER /home/$USER/opt
chmod 700 /home/$USER/opt/bin/jinchess

