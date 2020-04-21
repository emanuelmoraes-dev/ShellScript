# Lista de comandos para Shell Script

* Autor
  * Emanuel Moraes
* Email
  * emanuelmoraes297@gmail.com

## Buscar programa pelo terminal (( p/ Ubuntu e derivados ))

```sh
sudo apt-cache search <programa>
```

## Buscar programa pelo terminal (( p/ fedora e derivados ))

```sh
sudo dnf search <programa>
```

## Buscar programa pelo termin al (( p/ Arch Linux e derivados ))

```sh
sudo pacman -Ss <programa>
```

## Instalar programa pelo terminal (( p/ Ubuntu e derivados ))

```sh
sudo apt-get update
```

```sh
sudo apt-get install <programa>
```

## Instalar programa pelo terminal (( p/ fedora e derivados ))

```sh
sudo dnf install <programa>
```

## instalar programa pelo termin al (( p/ Arch Linux e derivados ))

```sh
sudo pacman -Sy <programa>
```

## Instalar pacote deb

```sh
sudo dpkg -i <pacote>.deb
```

```sh
sudo apt-get install -f
```

## Instalar pacote e dependências automaticamente de um rpm

```sh
sudo dnf install --nogpgcheck <pacote>
```

## Instalar pacote tar.pkg

```sh
sudo pacman -U <pacote>.tar.pkg
```

## Instalar pacote AUR

```sh
git clone <repositorio_do_aur>
```

```sh
cd <pasta_criada>
```

```sh
makepkg -cis
```

## Instalar programa de código fonte

```sh
cat readme* | less # ler as instruções se houver
```

```sh
./configure # se houver
```

```sh
make
```

```sh
sudo make install
```

## INSTALAR DRIVER DE WIFI PARA PLACAS RTL8723BE
```sh
lspci
```

```sh
sudo apt-get install linux-headers-generic build-essentialgit dkms # p/ Ubuntu e derivados
```

```sh
sudo dnf install kernel-devel-$(uname -r) git # p/ derivados de rpm
```

```sh
sudo pacman -S base-devel git linux-headers iw rfkill wireless_tools net-tools # p/ Arch Linux
```

```sh
git clone http://github.com/lwfinger/rtlwifi_new.git
```

```sh
cd rtlwifi_new && make
```

```sh
sudo make install
```

```sh
make clean
```

```sh
sudo nano /etc/modprobe.d/rtl8723be.conf # Escrever "options rtl8723be fwlps=0 swlps=0"
```

## VERIFICAR SE EXT GLOB (EX DO EXT GLOB: rm !(*.zip|*.iso)) ESTÁ ATIVADO

```sh
shopt extglob
```

## ATIVA EXT GLOB

```sh
shopt -s extglob
```

## DESLIGAR WEBCAM

```sh
sudo modprobe -r uvcvideo
```

## LIGAR WEBCAM

```sh
sudo modprobe uvcvideo
```

## MUDAR ORDEM DE GRUB

```sh
sudo nano /etc/default/grub
```

```sh
sudo update-grub # p/ Ubuntu e derivados
```

```sh
sudo grub-mkconfig -o /boot/grub/grub.cfg # p/ linux em geral
```

## ALTERAR SENHA ROOT

```sh
sudo passwd root
```

## CRIAR LANÇADOR DE APLICATIVO NO MENU

```sh
su
```

```sh
cd /usr/share/applications
```

```sh
echo \
"[Desktop Entry]
Encoding=UTF-8
Type=Application
Terminal=true
Name=<Nome de exibição da aplicação>
Exec=<Comando para executar aplicação>
Icon=<Ícone da aplicação>
Categories=<Categoria 1>;<Categoria 1>
" >> <arquivo>.desktop
```

## MONTAR ISO

```sh
mount -o loop <sua_Imagem.iso> /media/diretorio_ISO
```

## PERMITIR ACESSO ROOT AO VLC

```sh
sudo sed -i 's/geteuid/getppid/' /usr/bin/vlc
```

## REMOVER CONTA DE CONVIDADO

```sh
sudo nano /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf # Escrever "allow-guest=false"
```

## Dar permissão para usuário usar a impressora

```sh
sudo gpasswd -a <seu usuario> lp
```

```sh
sudo gpasswd -a <seu usuario> sys
```

```sh
sudo gpasswd -a <seu usuario> scanner
```

## Instalar driver HP (( p/ Ubuntu e derivados ))

```sh
sudo apt-get install cups python-imaging ghostscript hplip
```

```sh
sudo apt-get install cups-filters ghostscript gsfonts
```

```sh
sudo apt-get install simple-scan python-pillow
```

```sh
sudo /etc/init.d/cups start
```

## Instalar driver hp (( p/ Arch Linux ))

```sh
sudo pacman -S cups python-imaging ghostscript hplip
```

```sh
sudo pacman -S cups-filters ghostscript gsfonts
```

```sh
sudo pacman -S simple-scan python-pillow
```

```sh
systemctl enable org.cups.cupsd.service
```

```sh
systemctl daemon-reload
```

```sh
systemctl start org.cups.cupsd.service
```

```sh
sudo hp-setup -i
```

## Instalar impressora HP

```sh
hp-setup # Se nao funcionar tente instalar modo texto com o comando "hp-setup -i"
```

## Instalar pacotes no arch linux

```sh
makepkg -cis
```

## Instalar chave pública

```sh
gpg --recv-keys <chave>
```

## Arch inserir linguagens
```sh
nano /etc/locale.gen # Descomente a linguagem desejada. Recomenda-se fortemente deixar também o ingles
```

```sh
sudo locale-gen
```

## Substituir texto em multiplos arquivos

```sh
find <pasta> -iname <nome do arquivo> -type f -print0 | xargs -0 sed -i 's/<texto1>/<texto2>/g'
```

## Substituir texto em multiplos arquivos com confirmação

```sh
find ./ -name <arquivo> -exec vim '+%s/<texto>/<texto da substitução>/gc' {} \;
```

## Substituir texto em multiplos arquivos com confirmação sem recursao

```sh
find ./ -maxdepth 1 -name <arquivo> -exec vim '+%s/<texto>/<texto da subistituicao>/gc' {} \;
```

## Busca as linhas dos arquivos que comtem uma string especificada

```sh
find ./ -type f -name <arquivo> -exec grep -l -i <texto> {} \;
```

## Alterar ação do fechamento da tampa (( Gnome ))

```sh
sudo nano /etc/systemd/logind.conf # procurar/inserir o texto "HandleLidSwitch='ops'" ops: "ignore" "poweroff" "reboot" "suspend" "hibernate" "lock"
```

```sh
systemctl restart systemd-logind
```

## Encerrar Sessão (( Gnome ))

```sh
gnome-session-quit
```

## Encerrar Sessão

```sh
sudo pkill -9 -u username
```

## Conectar a cabo de internet 

```sh
ifconfig -a
```

```sh
dhcpcd <interface> # Opção 1
```


```sh
dhclient <interface> # Opção 2
```

## Conectar a cabo de internet Arch Linux

```sh
Systemctl start dhcpcd
```

## Conectar a wifi

```sh
iwconfig
```

```sh
iwlist scan # se nao funcionar antes digite ifup <interface> ctrl + c
```

### Rede aberta (OPN)

```sh
iwconfig <interface> essid <nome da rede>
```

```sh
dhclient <interface>
```

### Rede encriptada (WEP)

```sh
iwconfig <interface> mode managed key <senha>
```

```sh
iwconfig <interface> essid <nome da rede>
```

```sh
dhclient <interface>
```

### Rede encriptada 2 - A Vingança :) (WPA/WPA2)

```sh
wpa_passphrase <nome da rede> > /<caminho do arquivo>.conf
```

```sh
wpa_supplicant -Dwext -i<interface> -c /<caminho do arquivo>.conf # se der certo de ctrl + c
```

```sh
wpa_supplicant -Dwext -i<interface> -c /<caminho do arquivo>.conf -B
```

```sh
dhclient -r
```

```sh
dhclient <interface>
```

## Create Binary by file

```sh
od -An -vtx1 <arquivo> > <arquivo>.txt
```

## Command Create file by binary

```sh
LC_ALL=C tr -cd 0-9a-fA-F < <arquivo>.txt | xxd -r -p > <arquivo>
```

## Create Live Usb Bootable

```sh
sudo dd if=<path>.iso of=/dev/sd<X> bs=<8M> status=progress oflag=direct
```

## Criar ISO de arquivos

```sh
mkisofs -o <path>.iso <diretório de arquivos>
```

## Criar ISO de CD/DVD

```sh
dd if=/dev/<cdrom> of=<path>.iso
```

## Reinstalar drivers de som (( p/ Ubuntu e derivados ))

```sh
sudo apt-get remove alsa-utils
```

```sh
sudo apt-get remove alsamixer
```

```sh
sudo apt-get purge pulseaudio
```

```sh
sudo apt-get clean
```

```sh
sudo apt-get autoremove
```

```sh
rm -r ~/.pulse ~/.asound* ~/.pulse-cookie ~/.config/pulse
```

```sh
sudo apt-get install alsa-utils
```

```sh
sudo apt-get install alsamixer
```

```sh
sudo apt-get install pulseaudio
```

```sh
sudo alsa force-reload pavucontrol
```

## Descompactar arquivos compactados

### tar.gz

```sh
tar -xvzf <arquivo>.tar.gz -C <path destino>
```

### tar.bz2

```sh
tar -xvjf <arquivo>.tar.bz2 -C <path destino>
```

### tar.xz (( precisa do pacote xz-utils ))

```sh
tar -xvJf <arquivo>.tar.xz -C <path destino>
```

### zip

```sh
unzip <arquivo>.zip -d <path destino>
```

### rar

```sh
unrar e <arquivo>.rar <pathdestino> # Opção 1
```

```sh
unrar x <arquivo>.rar # Opção 2
```

## Compactar arquivos

### tar.gz - Opção 1

```sh
tar -cvzf <arquivo>.tar.gz <arquivo ou pasta a compactar>
```

### tar.gz - Opção 2

```sh
tar -cvf <arquivo>.tar <arquivo ou pasta a compactar>
```

```sh
gzip -9 <arquivo>.tar
```

### tar.bz2 - Opção 1

```sh
tar -cvjf <arquivo>.tar.bz2 <arquivo ou pasta a compactar>
```

### tar.bz2 - Opção 2

```sh
tar -cvf <arquivo>.tar <arquivo ou pasta a compactar>
```

```sh
bzip2 <arquivo>.tar
```

### tar.xz

```sh
tar -cvJf <arquivo>.tar.xz <arquivo ou pasta a compactar>
```

### zip

```sh
zip <arquivo>.zip <arquivo ou pasta a compactar> # Opção 1
```

```sh
zip -r <arquivo>.zip <arquivo ou pasta a compactar> # Opção 2
```

### rar

```sh
rar a <arquivo>.rar <arquivo ou pasta a compactar>
```

## Desativar temporariamente um dispositivo de entrada

```sh
xinput list # lista os dispositivos de entrada
```

```sh
xinput float <id> # Desativa temporariamente o dispositivo com o id informado
```

```sh
xinput reattach <id> <slave keyboard> # ativa o dispositivo com o id informado e com o numero slave keybord informado
```

## Desativar permanentemente um dispositivo de entrada

```sh
sudo cp /etc/default/grub /etc/default/grub.original # Cria um arquivo de backup para reverter o processo
```

```sh
sudo nano /etc/default/grub # Localize a linua 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"' e substitua por 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash i8042.nokbd"'
```

```sh
sudo update-grub
```

## Reverter o procedimento anterior

```sh
sudo cp /etc/default/grub.original /etc/default/grub
```

```sh
sudo update-grub
```

## Listar Processos Abertos

```sh
top
```

## Listar portas usadas no linux

```sh
netstat -antp
```

## Listar aplicações de uma porta expecífica

```sh
lsof -w -n -i tcp:<porta> # Opção 1
```

```sh
fuser -n tcp <porta> # Opção 2
```

```sh
netstat -anp | grep :<porta> # Opção 3
```

## Matar Processo com PID

```sh
kill -9 <pid>
```

## Matar Processo com nome

```sh
killall <nome do processo>
```

## Instalar flex e bison

```sh
sudo apt install flex bison
```

```sh
sudo apt install libfl2 libfl-dev
```

## Ver tamanho usado de pasta / arquivo

```sh
du -hs <arquivo>
```

## Ver Tamanho livre das partições

```sh
df -h
```
