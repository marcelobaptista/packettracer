#!/bin/bash

# Verificando o UID do usuário que executou o script
if [ $UID -ne 0 ]; then
	echo "Requer privilégio de root. Execute o script com 'sudo' "
	exit 1
fi
#
#Diretório temporário usado na instalação
#
DIR="/tmp/PacketTracer/"
#
#Checa se já existe o diretório /tmp/PacketTracer/ e acessa o mesmo
#
if [ -d "$DIR" ]; then
	rm -rf "$DIR"
else
	mkdir /tmp/PacketTracer/
fi
cd /tmp/PacketTracer/
#
#Baixando e desempacotando o arquivo .deb
#
echo ""
echo "Fazendo o download do arquivo Cisco_Packet_Tracer_821_Ubuntu_64bit.deb..."
echo "" && curl --progress-bar \
	-OL "https://archive.org/download/cisco-packet-tracer-821-ubuntu-64bit_202304/Cisco_Packet_Tracer_821_Ubuntu_64bit.deb"
#
#Descompacta o pacote Cisco_Packet_Tracer_821_Ubuntu_64bit.deb e demais arquivos para a instalação
#
ar -xv Cisco_Packet_Tracer_821_Ubuntu_64bit.deb
mkdir data && tar -C data -Jxf data.tar.xz
cd data
#
#Remove a instalação anterior do PacketTracer (geralmente instalado em /opt/pt)
#
xdg-desktop-menu uninstall /usr/share/applications/cisco-*.desktop && update-mime-database /usr/share/mime
gtk-update-icon-cache --force /usr/share/icons/gnome
rm -rf /opt/pt && rm -f /usr/local/bin/packettracer
#
#Copia os arquivos do PacketTracer 8.2.1
#
yes | cp -r usr /
yes | cp -r opt /
#
#Criação de atalhos
#
cat <<EOF | tee /usr/share/applications/cisco-pt821.desktop
[Desktop Entry]
Type=Application
Exec=/opt/pt/packettracer %f
Name=Packet Tracer 8.2.1
Icon=/opt/pt/art/app.png
Terminal=false
StartupNotify=true
MimeType=application/x-pkt;application/x-pka;application/x-pkz;application/x-pks;application/x-pksz;
EOF
#
cat <<EOF | tee /usr/share/applications/cisco-ptsa821.desktop
[Desktop Entry]
Type=Application
Exec=/opt/pt/packettracer -uri=%u
Name=Packet Tracer 8.2.1
Icon=/opt/pt/art/app.png
Terminal=false
StartupNotify=true
NoDisplay=true
MimeType=x-scheme-handler/pttp;
EOF
#
#Atualiza o ícone e a associação de arquivos
#
xdg-desktop-menu install /usr/share/applications/cisco-pt821.desktop
xdg-desktop-menu install /usr/share/applications/cisco-ptsa821.desktop
update-mime-database /usr/share/mime
gtk-update-icon-cache --force /usr/share/icons/gnome
xdg-mime default cisco-ptsa821.desktop x-scheme-handler/pttp
#
#Link simbólico para PacketTracer
#
ln -sf /opt/pt/packettracer /usr/local/bin/packettracer
#
#Corrige permissões
#
chown root:root /opt/pt/bin/updatepttp && chmod 4755 /opt/pt/bin/updatepttp
#
#Remove arquivos utilizados durante a instalação
#
cd .. && rm -rf /tmp/PacketTracer
#
#Sai do script
echo ""
echo "Instalado com sucesso!!!"
echo ""
echo "Bye!Bye!"
echo ""
echo ""
