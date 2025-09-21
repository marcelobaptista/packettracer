#!/bin/bash

# Obrigado ao  Filip Komárek (https://github.com/filip2cz) pela ótima ideia para esta seção do script
# Thanks to  Filip Komárek (https://github.com/filip2cz) for the great idea to this section of the script
if [[ $LANG == "pt_PT.UTF-8" || $LANG == "pt_BR.UTF-8" ]]; then
    # Mensagens em português
    requires_root="Requer privilégio de root. Execute o script com 'sudo' "
    extracting_files="Extraindo os arquivos..."
    copying_files="Copiando os arquivos..."
    creating_shortcuts="Criando atalhos..."
    updating_icons="Atualizando ícones e a associação de arquivos..."
    creating_symbolic_link="Criando link simbólico para PacketTracer..."
    fixing_permissions="Corrigindo permissões..."
    removing_temp_files="Removendo arquivos temporários..."
    installation_complete="Instalação concluída com sucesso!"
    error_copying_file="Erro ao copiar o arquivo"
else
    # English messages
    requires_root="Requires root privileges. Run the script with 'sudo' "
    extracting_files="Extracting files..."
    copying_files="Copying files..."
    creating_shortcuts="Creating shortcuts..."
    updating_icons="Updating icons and file association..."
    creating_symbolic_link="Creating symbolic link for PacketTracer..."
    fixing_permissions="Fixing permissions..."
    removing_temp_files="Removing temporary files..."
    installation_complete="Installation completed successfully!"
    error_copying_file="Error copying file"
fi

# Verificando o UID do usuário que executou o script
# Checking the user's UID
if [ $UID -ne 0 ]; then
    echo "${requires_root}"
    exit 1
fi

# Diretório temporário usado na instalação
# Temporary directory used during installation
temp_dir="/tmp/PacketTracer/"
arquivo="./Packet_Tracer822_amd64_signed.deb"

# Checa se já existe o diretório /tmp/PacketTracer/ e acessa o mesmo
# Check if the /tmp/PacketTracer/ directory exists and access it
if [ -d "${temp_dir}" ]; then
    rm -rf "${temp_dir}"
fi

# Copia o arquivo .deb para o diretório temporário
# Copy the .deb file to the temporary directory
mkdir -p "${temp_dir}"
cp -f "${arquivo}" "${temp_dir}" || {
    printf "\n%s\n" "${error_copying_file} ${arquivo}!"
    exit 1
}
cd "${temp_dir}" || exit 1

# Trata os erros de download
# Handle download errors
trap 'rm -rf "${temp_dir}"' ERR

# Extrai os arquivos do .deb
# Extract files from the .deb
printf "\n%s\n" "${extracting_files}"
ar -xv "${arquivo}" > /dev/null 2>&1
mkdir ./data && tar -C data -Jxf data.tar.xz
cd data || exit 1

# Remove a instalação anterior do PacketTracer (normalmente instalado em /opt/pt)
# Remove previous PacketTracer installation (typically installed in /opt/pt)
xdg-desktop-menu uninstall /usr/share/applications/cisco-*.desktop &&
    update-mime-database /usr/share/mime
gtk-update-icon-cache --force /usr/share/icons/* > /dev/null 2>&1
rm -rf /opt/pt &&
    rm -f /usr/local/bin/packettracer

# Copia os arquivos do PacketTracer 8.2.2
# Copy PacketTracer 8.2.2 files
printf "\n%s\n" "${copying_files}"
cp -rf usr opt /

# Criação de atalhos
# Create shortcuts
printf "\n%s\n" "${creating_shortcuts}"
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
# Update icons and file association
printf "\n%s\n" "${updating_icons}"
xdg-desktop-menu install /usr/share/applications/cisco-pt822.desktop
xdg-desktop-menu install /usr/share/applications/cisco-ptsa822.desktop
update-mime-database /usr/share/mime
gtk-update-icon-cache --force /usr/share/icons/* > /dev/null 2>&1
xdg-mime default cisco-ptsa821.desktop x-scheme-handler/pttp

# Link simbólico para PacketTracer
# Create symbolic link for PacketTracer
printf "\n%s\n" "${creating_symbolic_link}"
ln -sf /opt/pt/packettracer /usr/local/bin/packettracer

# Corrige permissões
# Fix permissions
printf "\n%s\n" "${fixing_permissions}"
chown root:root /opt/pt/bin/updatepttp &&
    chmod 4755 /opt/pt/bin/updatepttp

# Remove arquivos utilizados durante a instalação
# Remove files used during installation
printf "\n%s\n" "${removing_temp_files}"
rm -rf "${temp_dir}"

# Sai do script
# Exit the script
printf "\n%s\n" "${installation_complete}"
