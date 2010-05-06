#!/bin/bash

# sugar-desktop connecté sur 192.168.0.12

## Variables
# identité : id
# jour : "$(date +%F-%a)log"
# memoire libre sur hd er ram ( à vérifier toutes les heures ) : free
# Répertoire de log
replog=/home/$(logname)/.wifimap
# Pour éviter de d'essayer de créer replog en boucle
stopexit=2
# Variable de temporisation
tp = 0


rep_log () {
# créer un dossier de conf/log automatiquement si il n'est pas présent : .wifimap/
# cd
#if [[ !(-d $replog || -w $replog) ]] then 	
if [[ !(-d $replog) ]]
# si le dossier n'existe pas , on rentre dans la fonction de vérif/création
then

	if [[ !(-d $replog || $stopexit > 0) ]]
	then
		echo "Création du répertoire $replog."
		mkdir $replog
		((stopexit-=1))
		rep_log()

	elif [[ !(-w $replog) ]]
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

echo "Répertoire $replog en place."
echo "Prêt à logger"
}
# dev : essayer de faire une version avec tous les test au début et case après.

testintrusion () {
# verification de non intrusion

}


scanwifi () {
# scanne le réseau local à la recherche d'intrus connecté en wifi
nmap -sP 192.168.0.10,11,13-19


}

display_intrusion () {

}

logscan () {
# stocke 
}
