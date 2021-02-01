#!/bin/bash
#
#Baixando e desempacotando o arquivo .deb
#
echo ""
echo "Downloading: PacketTracer_800_amd64_build212_final.deb..." && curl --progress-bar --remote-name --location "https://archive.org/download/packet-tracer-800-amd-64-build-212-final/PacketTracer_800_amd64_build212_final.deb"
DIR="/tmp/PacketTracer/"
if [ -d "$DIR" ]; then
	rm -rf "$DIR"
else
	mkdir /tmp/PacketTracer/
fi
mv PacketTracer_800_amd64_build212_final.deb /tmp/PacketTracer/PacketTracer_800_amd64_build212_final.deb
cd /tmp/PacketTracer/
ar -xv PacketTracer_800_amd64_build212_final.deb
mkdir control
tar -C control -Jxf control.tar.xz
mkdir data
tar -C data -Jxf data.tar.xz
cd data
#
#Remove a instalação atual do PacketTracer (geralmente instalado em /opt/pt)
#
rm -rf /opt/pt
rm -rf /usr/share/applications/cisco-pt7.desktop
rm -rf /usr/share/applications/cisco-ptsa7.desktop
rm -rf /usr/share/icons/hicolor/48x48/apps/pt7.png
#
#Copia arquivos do PacketTracer
#
yes | cp -r usr /
yes | cp -r opt /
#
#Link simbólico para uma biblioteca necessária
#
ln -s /usr/lib64/libdouble-conversion.so.3.1.5 /usr/lib64/libdouble-conversion.so.1
#
#Atualiza o ícone e a associação de arquivos
#
xdg-desktop-menu install /usr/share/applications/cisco-pt.desktop
xdg-desktop-menu install /usr/share/applications/cisco-ptsa.desktop
update-mime-database /usr/share/mime
gtk-update-icon-cache --force --ignore-theme-index /usr/share/icons/gnome
xdg-mime default cisco-ptsa.desktop x-scheme-handler/pttp
#
#Link simbólico para PacketTracer
#
ln -sf /opt/pt/packettracer /usr/local/bin/packettracer
#
#Configura variáveis de ambiente
#
cat << "EOF">> /etc/profile.local
PTHOME=/opt/pt
export PTHOME
QT_DEVICE_PIXEL_RATIO=auto
export QT_DEVICE_PIXEL_RATIO
EOF
#
#Remove arquivos utilizados durante a instalação
#
rm -rf /tmp/PacketTracer
#
#Sai do script
echo ""
echo "Aperte <ENTER> para continuar..."
echo ""
read 
echo "Bye!Bye!"
echo ""
echo ""