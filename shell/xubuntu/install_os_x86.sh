#!/bin/bash -e

# Auteur : darkpawn
# Date : 2013-08-15

# Definition des commandes
UPGRADE=$(apt-get update ; apt-get upgrade --force-yes -y ; apt-get dist-upgrade --force-yes)
INSTALL=$(apt-get install --force-yes -y )

# Acquisition des droits root
sudo -s

# Dépots Ubuntu Précise pour le client vmware view
echo "Ajout du dépots Ubuntu Précise ..."
sleep 1
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


# Depots Raring
echo "Ajout du dépots Ubuntu Raring ..."
sleep 1
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
sleep 1
cp -fva /etc/apt/sources.list.raring /etc/apt/sources.list

echo "Mise à jour du système ..."
sleep 1
$UPGRADE

echo "Installation du thème ..."
sleep 1
$INSTALL ubuntustudio-look ubuntustudio-icon-theme ubuntustudio-lightdm-theme ubuntustudio-menu ubuntustudio-look

echo "Arrêt de apport ..."
echo "enabled=0" > /etc/default/apport
/etc/init.d/apport stop

echo "Modification du splash screen ..."
sleep 1
update-alternatives --install /lib/plymouth/themes/default.plymouth default.plymouth /lib/plymouth/themes/ubuntustudio-logo/ubuntustudio-logo.plymouth 100
update-alternatives --config default.plymouth
update-initramfs -u

echo "Installation de paquets web ..."
sleep 1
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
$INSTALL flashplugin-installer openjdk-7-jdk openjdk-7-jre  icedtea-7-plugin google-chrome-stable

echo "Installation des utilitaires ..."
sleep 1
$INSTALL git

echo "Installation du client View ..."
sleep 1
cp -fva /etc/apt/sources.list.precise /etc/apt/sources.list
apt-get update
$INSTALL vmware-view-client
cp -fva /etc/apt/sources.list.raring /etc/apt/sources.list


