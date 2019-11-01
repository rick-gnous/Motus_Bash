#!/bin/bash
#set -x


#************************#
#         motus          #
#         v1.0b          #
#                        #
#   motus mais en bash   #
#************************#
correct=0   # permet de savoir lorsque le joueur a trouvé le mot

mot="null"  # le mot à deviner, généré par pickRandom

# genere le tableau verif
for((i=1;i<7;i++)); do
    verif[$i]=0
done


############################
# Déclaration des couleurs #
############################
blanc='\033[0m'
bleu='\033[34m'
rouge='\033[31m'
jaune='\033[33m'


############################
#  Déclaration du tableau  #
############################

declare -A tableauMot
num_rows=6
num_columns=6

for ((r=1;r<=num_rows;r++)) do
    for ((c=1;c<=num_columns;c++)) do
        tableauMot[$c,$r]=_
    done
done


# --------------------------------------------- #
# recupIndex ()                                 #
# récupère la ligne où se trouve les lettres    # 
# --------------------------------------------- #
recupIndex () {
    j=1
    while [ "${tableauMot[$((j+1)),1]}" != _ ]; do
        j=$(( j+1 ))
    done
    return $j
}


# ------------------------------------ #
# pickRandom ()                        #
# Choisi un mot au hasard              #
# ------------------------------------ #
pickRandom () {
    temp=$(wc -w data/dic.txt | cut -d\  -f1)   #nombre de ligne du dico
    mot=$(sed -n "$(( (RANDOM%$temp) + 1 ))p" data/dic.txt)   # choisi aléatoirement une ligne dans le fichier
}


# ------------------------------------------------------------------------- #
# affichageReponse ()                                                       #
# Affiche la réponse de l’utilisateur avec la couleur et le son             #
# ------------------------------------------------------------------------- #
affichageReponse () {
    nbLettresBonnes=0   # permet de savoir le nombre de bonnes lettres 
    recupIndex
    j=$?
    for i in `seq 1 ${#mot}`; do     # pour les lettres du mot
        lettre=${tableauMot[$j,$i]}     # on prend la lettre du tableau
        case "${verif[i]}" in
            1)      # bonne lettrei
                nbLettresBonnes=$(( nbLettresBonnes+1 ))
                echo -en $rouge $lettre $blanc
                paplay data/sound/bon.ogg
                tableauMot[$((j+1)),$i]=$lettre     # on met la lettre dans la case suivante
            ;;
            2)      # lettre présente dans le mot
                echo -en $jaune $lettre $blanc
                paplay data/sound/moyen.ogg
            ;;
            *)      # lettre absente
                echo -en $bleu $lettre $blanc
                paplay data/sound/mauvais.ogg
            ;;
        esac
    done
    if [ $nbLettresBonnes -eq 6 ]; then
        correct=1
    fi
    echo ""
    }


# -------------------------------------- #
# affichagePrec ()                       #
# Affiche les lettres bonnes             #
# -------------------------------------- #
affichagePrec () {
    for i in `seq 1 ${#mot}`; do     # pour les lettres du mot
        lettre=${tableauMot[$compteur,$i]}     # on prend la lettre du tableau
        echo -n "" $lettre "" 
    done
    echo ""
}


# ------------------------------------------------------------------------------- #
# check ()                                                                        #
# Vérifie si les lettres sont à la bonne position ou présente dans le mot         #
# Return : le tableau verif avec 1 si correct, 2 si présent dans le mot           #
# ------------------------------------------------------------------------------- #
check () {
    recupIndex
    j=$?
    for i in `seq 1 ${#mot}`; do
        lettre=${tableauMot[$j,$i]}     #on récupère la lettre du tableau
        if [ "$lettre" = "${mot:$((i-1)):1}" ]; then       #si elle est à son emplacement, on met 1
            verif[$i]=1
        elif [[ "$lettre" =~ [$mot] ]]; then        #si elle est dans le mot, on met 2
            verif[$i]=2
        else
            verif[$i]=0
        fi
        i=$(( i+1 ))
    done
}


# ----------------------------------------------------------------------- #
# entree ()                                                               #
# Fait entrer un mot à l’utilisateur et l’insère dans le tableau          #
# ----------------------------------------------------------------------- #
entree () {
    read motEntre
    while [ "${#motEntre}" -ne 6 ]; do
        read motEntre
    done
    recupIndex
    j=$?
    # on met le mot dans le tableau
    for i in `seq 1 ${#motEntre}`; do
        tableauMot[$j,$i]=${motEntre:$((i-1)):1}
        i=$(( i+1 ))
    done
}


#  main

compteur=1      # nombre de coups

pickRandom

while [ $compteur -le ${#mot} ]; do
    if [ $correct -eq 1 ]; then
        break
    else
        affichagePrec
        entree
        check
        affichageReponse
        compteur=$((compteur+1))
    fi
done

if [ $correct -eq 1 ]; then
    echo "Victoire !"
else
    echo "Défaite :("
fi