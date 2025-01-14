#!/bin/bash

# Script pour la création d'un utilisateur avec des paramètres personnalisés

# Vérifier que le script est exécuté avec des privilèges root
if [[ $EUID -ne 0 ]]; then
    echo "Ce script doit être exécuté en tant que root."
    exit 1
fi

# Vérifier le nombre d'arguments
if [[ $# -ne 5 ]]; then
    echo "Usage : $0 user_name comment shell validité_en_jours quota_en_mo"
    exit 1
fi

# Récupérer les arguments
NOM_UTILISATEUR=$1
COMMENTAIRE=$2
SHELL_UTILISATEUR=$3
VALIDITE_JOURS=$4
QUOTA_DISQUE_MO=$5

# Définir le mot de passe par défaut
MOT_DE_PASSE="inf3611"

# Créer l'utilisateur avec le commentaire et le shell par défaut
useradd -m -s "$SHELL_UTILISATEUR" -c "$COMMENTAIRE" "$NOM_UTILISATEUR"
if [[ $? -ne 0 ]]; then
    echo "Erreur lors de la création de l'utilisateur."
    exit 1
fi

# Configurer le mot de passe de l'utilisateur et forcer le changement au premier login
echo "$NOM_UTILISATEUR:$MOT_DE_PASSE" | chpasswd
passwd --expire "$NOM_UTILISATEUR"

# Définir la durée de validité du compte (en jours)
chage -E $(date -d "+$VALIDITE_JOURS days" +%Y-%m-%d) "$NOM_UTILISATEUR"

# Configurer le quota disque (en Mo)
setquota -u "$NOM_UTILISATEUR" $((QUOTA_DISQUE_MO * 1024)) $((QUOTA_DISQUE_MO * 1024)) 0 0 -a
if [[ $? -ne 0 ]]; then
    echo "Erreur lors de la configuration du quota disque. Assurez-vous que les quotas sont activés."
    exit 1
fi

# Configurer les plages horaires de connexion via PAM
PAM_FILE="/etc/security/time.conf"
if ! grep -q "$NOM_UTILISATEUR" "$PAM_FILE"; then
    echo "*;*;$NOM_UTILISATEUR;Al0800-1800" >> "$PAM_FILE"
fi

# Activer PAM pour restreindre les plages horaires
if ! grep -q "pam_time.so" /etc/pam.d/common-auth; then
    echo "auth required pam_time.so" >> /etc/pam.d/common-auth
fi

# Message de confirmation
cat <<EOF
L'utilisateur $NOM_UTILISATEUR a été créé avec succès avec les caractéristiques suivantes :
- Commentaire : $COMMENTAIRE
- Shell par défaut : $SHELL_UTILISATEUR
- Durée de validité : $VALIDITE_JOURS jours
- Quota disque : ${QUOTA_DISQUE_MO}Mo
- Plage horaire autorisée : 08h00 à 18h00
EOF

exit 0

