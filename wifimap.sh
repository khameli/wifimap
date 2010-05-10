#!/bin/bash

# sugar-desktop connecté sur 192.168.0.12

#####################################################################
# Variables
#####################################################################
# identité : id
# jour : "$(date +%F-%a)log"
#logfile=$(date +%F-%a)log
# memoire libre sur hd er ram ( à vérifier toutes les heures ) : free
# Répertoire de log
replog=/home/$(logname)/.wifimap
# Pour éviter de d'essayer de créer replog en boucle
stopexit=2
# Variable de temporisation

######################################################################
# Fonctions
######################################################################
rep_log () {
#créer un dossier de conf/log automatiquement si il n'est pas présent : .wifimap/
#cd
if [[ !(-d $replog || -w $replog) ]]	
#	if [[ !(-d $replog) ]]
# si le dossier n'existe pas , on rentre dans la fonction de vérif/création
then

	if [[ !(-d $replog || $stopexit > 0) ]]
	then
		echo "Création du répertoire $replog."
		mkdir $replog
		((stopexit-=1))
		rep_log
	
	elif [[ !(-w $replog) ]]
#	if [[ !(-w $replog) ]]
	then
		echo "Le dossier $replog n'est pas accessible."
		exit 2
	
	elif [ $stopexit -le 0 ]
	then
 		echo "Il n'est pas possible de créer le dossier de log."
		exit 2

	else
 		echo "Le dossier $replog n'existe pas et il n'est pas possible de le créer."
		exit 2
	fi
fi
echo "Répertoire $replog en place."
echo "Prêt à logger"
return 0
}
# dev : essayer de faire une version avec tous les test au début et case après.
# dev : utiliser $stopexit comme variable locale et la fournir la fonction en tant que paramètre


testintrusion () {
# verification de non intrusion
#awk -F'' $1
nbintrus=$(grep "Nmap done" $1 | cut -d '(' -f 2 | cut -d ' ' -f 1)
return $nbintrus
}

logscan () {
# stocke
typeset logfile=$(date +%F-%a)log
typeset scanfile=$replog/scan.$logfile
cat $1 >> $scanfile
}

tempfile1=/tmp/wifimap.tmp1
tempfile2=/tmp/wifimap.tmp2

scanwifi () {
# scanne le réseau local à la recherche d'intrus connecté en wifi
typeset logfile=$(date +%F-%a)log
typeset errorfile=$replog/error.$logfile
nmap -sP 192.168.0.10,11,13-19 1> $tempfile1 2>> $errorfile
logscan $tempfile1
testintrusion $tempfile1
return $?
}

infointrus () {
# Récupération d'information sur l'intrus
# Pour l'instant seulement un scan complet de réseau local
typeset logfile=$(date +%F-%a)log
typeset intrusionfile=$replog/intrusion.$logfile

nmap -A -T4 192.168.0.10,11,13-19 > $tempfile2 && cat $tempfile2 >> $intrusionfile
echo -e "\n#############################################" >> $intrusionfile
}
# dev : tenter d'obtenir des infos précises sur l'intrus en sélectionnant son ip

display_intrusion () {
# affiche une notification sur le bureau, si connecté, indiquant :
#	- adresse ip locale de l'intrus
#	- adresse mac
#	- os (par fingerprint)
#	- occupation (pages visitées)
#	- possibilités de réaction à l'intrusion

typeset logfile=$(date +%F-%a)log
typeset intrusionfile=$replog/intrusion.$logfile
typeset ipintrus=$(grep Host $tempfile1 | cut -d " " -f 2)

notify-send -t 2000 -u critical 'Intrusion dans le réseau local' "$(echo -e "\nIntrus: $ipintrus \n\n $(cat $tempfile2)")"
cat $tempfile2
}


########################################################################
# Programme principal
########################################################################


#rep_log
divi=5
while true
do
	
	tempo=300
	scanwifi
	if [[ $? > 0 ]]
	then
	 	infointrus
		display_intrusion
		tempo=$((tempo/$divi))
	fi
	sleep $tempo
done
