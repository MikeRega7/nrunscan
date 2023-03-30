#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

trap ctrl_c INT

# Ctrl+C
function ctrl_c(){
  echo -e "\n\n${yellowColour}[*]${endColour}${grayColour} Exiting...\n${endCOlour}"
  tput cnorm && exit 1
}

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Use: ./nrunscan.sh${endColour}"
  echo -e "\n${yellowColour}i)${endColour}${grayColour} start the script to run the scan${endColour}"
}

function extractPorts(){
	ports="$(cat $1 | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
	ip_address="$(cat $1 | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u | head -n 1)"
	echo -e "\n${purpleColour}[*] Extracting information...\n${endColour}" > extractPorts.tmp
	echo -e "\t${purpleColour}[*] IP Target: ${endColour}${redColour}$ip_address${endColour}"  >> extractPorts.tmp
	echo -e "\t${purpleColour}[*] Open Ports: ${endColour} ${redColour}$ports${endColour}\n"  >> extractPorts.tmp
	echo $ports | tr -d '\n' | xclip -sel clip
	echo -e "${purpleColour}[*] Ports copied to clipboard\n${endColour}"  >> extractPorts.tmp
	cat extractPorts.tmp; rm extractPorts.tmp
}

function scan(){
  if ! dpkg -s xclip >/dev/null 2>&1; then
  echo -e "\n${yellowColour}xclip is not install in your system...${endColour}"
  echo -e "\n${yellowColour}Installing xclip in your system...${endColour}"
  sudo apt-get install -y xclip
  fi
  echo -en ${blueColour} Give me the IP target: ${endColour}
  read ip
  echo -e "\n${turquoiseColour}Starting the scan with nmap${endColour}"
  sudo nmap -p- --open -sS --min-rate 5000 -vvv -n -Pn $ip -oG allPorts
  extractPorts allPorts
  echo -e "\n${turquoiseColour}Escaning the services and technologies in the ports${endColour}"
  sudo nmap -sCV -p $ports $ip -oN targeted
  if [[ $(cat targeted | grep -i '80/tcp.*open') ]] || [[ $(cat targeted | grep -i '8080/tcp.*open') ]]; then
    echo -e "${yellowColour}[*] Port 80 or 8080 is open, running http-enum script...\n${endColour}"
    nmap --script http-enum -p80,8080 $ip -oN webScan
    echo -e "\n${blueColour}Thanks for using the script! Happy Hacking${endColour}"
  else
    echo -e "\n${redColour}[+]...If another port run a http server you can use the script http-enum of nmap${endColour}"
    echo -e "\n${redColour}[+]...Example nmap --script http-enum -p {ports} {ip}${endColour}"
    echo -e "\n${yellowColour}[*] Port 80 and 8080 are not open, exiting...\n${endColour}"
    echo -e "\n${yellowColour}Thanks for using the script! Happy Hacking${endColour}"
  fi
}


#menu
declare -i parameter_counter=0
while getopts "ih" arg; do
  case $arg in
    i) ip="$OPTARG"; let parameter_counter+=1;;
    h);;
  esac
done

if [ "$parameter_counter" = 1 ]; then
  scan $i
else
  helpPanel
fi
