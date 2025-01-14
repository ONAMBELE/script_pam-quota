-   **Activation des quotas dans un environnement Linux**

    -   **Étape 1 : Vérifier le type de système de fichiers**
    
    Les quotas doivent etre pris en charge par le système de fichiers. Assurez-vous que votre système utilise ext4/ext3.<br>
    Vérifier celà avec la commande: **df -T**

    -   **Étape 2 : Modifier /etc/fstab pour activer les quotas**
    Exemple de ligne modifiée :
    *UUID=xxxxx-xxxx-xxxx-xxxx / ext4 defaults,usrquota,grpquota 0 1*

    -   **Étape 3 : Activer les quotas**

        - 1- Remontez le système de fichiers pour appliquer les changements :
            -   **sudo mount -o remount /**
        
        - 2- Lancez une vérification de quota pour générer les fichiers nécessaires (aquota.user et aquota.group) :
            -   **sudo quotacheck -cum /**
        Cette commande creera directement les fichiers aquota.user et aquota.group si tout est bien configuré
        -   3- Activer les quotas
            -   **sudo quotaon -v /**
        -   4- Vérifiez que les quotas sont activés :
            -   **sudo quotaon -p /**
        