#!/bin/bash

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
#                                                     #
#   SCRIPT PARA IMPLANTACAO DE INFRAESTRUTURA DE TI   #
#                                                     #
#            Autor: Sandro Dias                       #
#            Contato: ti3@altasports.com.br           #
#            Empresa: Alta Sports                     #
#            Versão: 2.2.22                           #
#            Lançamento: 02/02/2022                   #
#                                                     #
#                                                     #
#            SCRIPT: instala-infra.sh                 #
#                                                     #
#                                                     #
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#


#-1------------ Teste de Conectividade ---------------#
clear

GW=`/sbin/ip route | awk '/default/ { print $3 }'`
CheckDNS=`cat /etc/resolv.conf | awk '/nameserver/ {print $2}' | awk 'NR == 1 {print; exit}'`
CheckSite=www.google.com
GWoff="Sem comunicação com gateway, verifique a rede física..."
DNSok="O DNS ($CheckDNS) respondeu ao ping."
DNSoff="O DNS ($CheckDNS) não conseguiu responder, verifique se o IP do DNS está correto."
SiteOK="O site ($CheckSite) respondeu ao ping."
SiteOff="O site ($CheckSite) não respondeu ao ping, internet com falhas."
PortaOK="Teste OK, a porta ($PortaSite) está disponível em ($CheckSite)"
PortaOff="Falha no teste não consegui acessar a porta ($PortaSite) em ($CheckSite)"
PortaSite=80
Interfaces=`ip -brief token | wc -l`
Interface=`ip -brief token | sed '2d'`
Interface1=`echo $Interface | awk '{print $NF}'`
IP_Address_Externo=`dig @ns1-1.akamaitech.net ANY whoami.akamai.net +short`
IP_Address_Interno=`ip -4 addr show dev $Interface1 | grep inet | tr -s " " | cut -d" " -f3 | head -n 1`

function pingdns
{
  tput setaf 6; echo && echo "Pingando 4x no primeiro DNS do resolv.conf ($CheckDNS) ..." && echo; tput sgr0;
  tput setaf 6; ping $CheckDNS -c 4
    if [ $? -eq 0 ]
    then

      tput setaf 6; echo && echo $DNSok ; tput sgr0;
      #Insert any command you like here
    else
      tput setaf 9; echo && echo $DNSoff >&2
      #altere aqui o resolv.conf
     exit 1
  fi
}

function pingnet
{
  tput setaf 10; echo && echo "Pingando 4x no site $CheckSite ." && echo; tput sgr0;
  tput setaf 10; ping $CheckSite -c 4

  if [ $? -eq 0 ]
    then
      tput setaf 10; echo && echo $SiteOK && echo ; tput sgr0;
      #Insert any command you like here
    else
      tput setaf 9; echo && echo $SiteOff >&2
      #Insert any command you like here
      exit 1
  fi
}

function portscan
{
  tput setaf 6; echo && echo "Tentando acessar a porta 80 em $CheckSite"; tput sgr0;
  if nc -zw1 $CheckSite  $PortaSite; then
    tput setaf 10; echo $PortaOK; 
  else
    tput setaf 9; echo $PortaOff;
  fi
}

tput setaf 7; echo && echo "Pingando 4x no gateway ($GW) para testar comunicação de rede interna (LAN)" && echo; tput sgr0;
if [ "$GW" = "" ]; then
    tput setaf 9; echo $GWoff && echo ""; tput sgr0;
    exit 1
fi

ping $GW -c 4

if [ $? -eq 0 ]
then
  tput setaf 7; echo && echo "O Gateway ($GW) está pingando.";
  pingdns
  pingnet
  sleep 5

#  portscan

  exit 0

else
  tput setaf 9; echo && echo "Algo está errado com a LAN (Gateway $GW inacessível)"
  pingdns
  pingnet

clear
echo -e "\n            RELATORIO DO TESTE DE CONECTIVIDADE\n \n Este host não está navegando na internet!\n"
  
  exit 1
fi
#-1.1------------ Executar se Teste OK ---------------#
clear
apt install -y figlet neofetch
clear

figlet "  Alta   Sports"
count=0
total=33
pstr="[================================================]"

while [ $count -lt $total ]; do
  sleep 0.015 # this is work
  count=$(( $count + 1 ))
  pd=$(( $count * 73 / $total ))
  printf "\r%3d.%1d%% %.${pd}s" $(( $count * 100 / $total )) $(( ($count * 1000 / $total) % 10 )) $pstr
done


echo -e "\n            RELATORIO DO TESTE DE CONECTIVIDADE\n \n            Este host está navegando na internet!\n"

#-1.1a------------ Exibindo dados do Relatório ---------------#
echo -e "#-------------------------------------------------------#\n            HOSTNAME      : $HOSTNAME\n            INTERFACES    : $Interfaces\n        >
echo -e "   O gateway $GW conseguiu responder ao ping.\n   $SiteOK\n   $DNSok\n"
#-1.1a-FIM-#

echo -e "Agora que sabemos que este host está navegando na internet\n deseja instalar o Pacote de Scripts para Infraestrutura?"

while true; do
    read -p " --==>> (S de sim ou N de não): " sn0
    case $sn0 in
        [Ss]* ) echo Sim; break;;
        [Nn]* ) echo Não; exit;;
        * ) echo && echo "Por favor digite apenas (S) de Sim ou (N) de Não." && echo;;
    esac
done

#-1.1-FIM-#



echo -e "Agora que sabemos que este host está sem internet\n deseja configurar a Interface de rede?"
while true; do
    read -p " --==>> (S de sim ou N de não): " sn1
    case $sn1 in
        [Ss]* ) echo Sim; break;;
        [Nn]* ) echo Não; exit;;
        * ) echo && echo "Por favor digite apenas (S) de Sim ou (N) de Não." && echo;;
    esac
done

#-1-FIM-#

#-1------------ Criando Pastas da Infra --------------#
mkdir /etc/infraTI
mkdir /etc/infraTI/scripts
mkdir /etc/infraTI/logs
mkdir /etc/infraTI/backups
mkdir /etc/infraTI/gitclonado
chmod ugo+rw /etc/infraTI/ -R
#-1-FIM-#

#-2------------ Adiciona Pasta ao PATH ---------------#
echo 'export PATH=$PATH:/etc/infraTI/scripts' >> /etc/profile
#-2-FIM-#

#-3------------- Registro da Instalacao --------------#
date "+%d/%m/%Y - %T" > /etc/infraTI/logs/DateInstall.log
chmod ugo+rw /etc/infraTI/logs/DateInstall.log
DateInstall=$(cat /etc/infraTI/logs/DateInstall.log)
echo 0 > /etc/infraTI/logs/version.txt
chmod ugo+rw /etc/infraTI/logs/version.txt
Version=$(cat /etc/infraTI/logs/version.txt)
echo "#	Registro de todos os aquivos que foram backupeados desde a Instalação em $DateInstall" > /etc/infraTI/backups/ListaBackup.csv
echo "#	Data	" > /etc/infraTI/backups/ListaBackup.csv
#-3-FIM-#

#-4------- Instala o GIT e Sicroniza Projeto ---------#
apt update && apt install git
echo "Informe seu nome de usuário GIT: " ; read usernameGit
echo "Informe seu email GIT: " ; read usermailGit
git config --global user.name "$usernameGit"
git config --global user.mail "$usermailGit"
cd  /etc/infraTI/gitclonado
git clone https://github.com/ti3altasports/infraLinux
Version=$(cat /etc/infraTI/gitclonado/infraLinux/version.txt)
VersionUpdate=$(date "+%d/%m/%Y - %T")
echo "Versão $Version atualizada em $VersionUpdate" >> /etc/infraTI/logs/update.log
#-4-FIM-#

#-5--------------- Habilita Execução -----------------#
cp -v /etc/infraTI/gitclonado/infraLinux/*.sh /etc/infraTI/scripts/
chmod ugo+x /etc/infraTI/scripts/*.sh
#-5-FIM-#

#-6------------ Adiciona Pasta ao PATH ---------------#

#-6-FIM-#

#-7------------ Adiciona Pasta ao PATH ---------------#

#-7-FIM-#

#-8------------ Adiciona Pasta ao PATH ---------------#

#-8-FIM-#

#-9------------ Adiciona Pasta ao PATH ---------------#

#-9-FIM-#

#-10----------- Adiciona Pasta ao PATH ---------------#

#-10-FIM-#

#-11------------ Adiciona Pasta ao PATH ---------------#

#-11-FIM-#

#-12------------ Adiciona Pasta ao PATH ---------------#

#-12-FIM-#

#-13------------ Adiciona Pasta ao PATH ---------------#

#-13-FIM-#

#-14------------ Adiciona Pasta ao PATH ---------------#

#-14-FIM-#

#-15------------ Adiciona Pasta ao PATH ---------------#

#-15-FIM-#

#-16------------ Adiciona Pasta ao PATH ---------------#

#-17-FIM-#

#-18------------ Adiciona Pasta ao PATH ---------------#

#-18-FIM-#

#-19------------ Adiciona Pasta ao PATH ---------------#

#-19-FIM-#

#-20------------ Adiciona Pasta ao PATH ---------------#

#-20-FIM-#

