#!/bin/bash

# Verificando o UID do usuário que executou o script
if [ $UID -ne 0 ]; then
	echo "Requer privilégio de root. Execute o script com 'sudo' "
	exit 1
fi

# Diretório temporário usado na instalação
temp_dir="/tmp/PacketTracer/"
arquivo="Packet_Tracer822_amd64_signed.deb"
url="https://archive.org/download/packet-tracer-822-amd-64"

# Checa se já existe o diretório /tmp/PacketTracer/ e acessa o mesmo
if [ -d "${temp_dir}" ]; then
	rm -rf "${temp_dir}"
fi

# Cria o diretório temporário
mkdir -p "${temp_dir}"
cd "${temp_dir}" || exit 1

# Trata os erros de download
trap 'rm -rf "${temp_dir}"' ERR

# Baixa o arquivo .deb do Cisco Packet Tracer
printf "\nFazendo o download do arquivo %s...\n" "${arquivo}"
curl --progress-bar -OL "${url}/${arquivo}" || {
	echo "Erro ao baixar o arquivo ${arquivo}!"
	exit 1
}

# Extrai os arquivos do .deb
printf "\nExtraindo os arquivos...\n"
ar -xv "${arquivo}" > /dev/null 2>&1
mkdir data && tar -C data -Jxf data.tar.xz
cd data || exit 1

# Remove a instalação anterior do PacketTracer (normalmente instalado em /opt/pt)
xdg-desktop-menu uninstall /usr/share/applications/cisco-*.desktop &&
	update-mime-database /usr/share/mime
gtk-update-icon-cache --force /usr/share/icons/* > /dev/null 2>&1
rm -rf /opt/pt &&
	rm -f /usr/local/bin/packettracer

# Copia os arquivos do PacketTracer 8.2.2
printf "\nCopiando os arquivos...\n"
cp -rf usr opt /

# Criação de atalhos
printf "\nCriando atalhos...\n"
cat <<EOF > /usr/share/applications/cisco-pt822.desktop
[Desktop Entry]
Type=Application
Exec=/opt/pt/packettracer %f
Name=Packet Tracer 8.2.2
Icon=/opt/pt/art/app.png
Terminal=false
StartupNotify=true
MimeType=application/x-pkt;application/x-pka;application/x-pkz;application/x-pks;application/x-pksz;
EOF

cat <<EOF > /usr/share/applications/cisco-ptsa822.desktop
[Desktop Entry]
Type=Application
Exec=/opt/pt/packettracer -uri=%u
Name=Packet Tracer 8.2.2
Icon=/opt/pt/art/app.png
Terminal=false
StartupNotify=true
NoDisplay=true
MimeType=x-scheme-handler/pttp;
EOF

# Atualiza o ícone e a associação de arquivos
printf "\nAtualizando ícones e a associação de arquivos...\n"
xdg-desktop-menu install /usr/share/applications/cisco-pt822.desktop
xdg-desktop-menu install /usr/share/applications/cisco-ptsa822.desktop
update-mime-database /usr/share/mime
gtk-update-icon-cache --force /usr/share/icons/* > /dev/null 2>&1
xdg-mime default cisco-ptsa821.desktop x-scheme-handler/pttp

# Link simbólico para PacketTracer
printf "\nCriando link simbólico para PacketTracer...\n"
ln -sf /opt/pt/packettracer /usr/local/bin/packettracer

# Corrige permissões
printf "\nCorrigindo permissões...\n"
chown root:root /opt/pt/bin/updatepttp &&
	chmod 4755 /opt/pt/bin/updatepttp

# Remove arquivos utilizados durante a instalação
printf "\nRemovendo arquivos temporários...\n"
rm -rf "${temp_dir}"

# Sai do script
printf "\nInstalação concluída com sucesso!\n"
