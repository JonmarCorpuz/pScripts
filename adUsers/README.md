# Projet Windows Apercu

Le département d'informatique héberge toute une variété de services offerts à ses étudiants (GitLab, Nextcloud, Progression, courriels, etc…). Pour faciliter la gestion de ses utilisateurs, le département se sert d'un serveur Active Directory pour son annuaire LDAP. Cependant avec plusieurs centaines d'utilisateurs qui débutent et finissent leur formation chaque session, il est devenu impossible de créer et supprimer les comptes des étudiants à la main.  
Le département vous mandate donc pour créer un script qui automatise un certain nombre de tâches présentement exécutées à la main. 

- [ ] Le script permet d'inscrire et désinscrire les étudiants à Active Directory à partir d'un fichier fourni par le registrariat. 
- [ ] Le script devra envoyer un courriel pour avertir les utilisateurs de la création et la désactivation de leur compte. 

Votre script devra respecter le cahier des charges suivant :  

- [X] ~~Vous devez utiliser un serveur Active Directory pour l'annuaire LDAP~~
- [X] ~~Vous devez utiliser un serveur SMTP de votre choix pour les courriels à envoyer. (Vous pouvez utiliser powershell pour envoyer des courriels. Vous pouvez aussi utiliser un serveur SMTP public reconnu pour envoyer des courriels. Cela permet de limiter les potentiels problèmes de “SPAM”)~~
- [X] ~~Votre domaine sera infocrosemont.qc.ca~~  
- [ ] À chaque action que vous effectuez, vous devez "logguer" les informations dans l’observateur d’événements de Windows dans la rubrique Application avec le nom AD_<Date>. 
- [X] ~~Vous devez utiliser les fichiers CSV qui vous sont fournis. De plus, chaque fichier comporte le nom de l'utilisateur, mais aussi des informations supplémentaires comme le téléphone, ou l'âge. Vous devez conserver toutes les informations supplémentaires dans l'AD.~~  
- [X] ~~Si l'utilisateur n'existe pas, vous devez lui créer son compte AD et lui envoyer un courriel de confirmation.~~
- [X] ~~Vous devez créer un nom d'utilisateur utilisant le modèle première lettre du prénom suivi du nom de famille.~~ 
- [X] ~~Pour chaque nouvel utilisateur, vous devez vous assurer qu'il devra changer son mot de passe à la prochaine connexion.~~  
- [ ] Si l'utilisateur vient d'être désinscrit, vous désactivez son compte et lui envoyer un courriel d’avertissement.  
- [ ] Si un utilisateur existe déjà et qu'il est encore inscrit, aucune action n'est requise.  
- [ ] L’option -diff permet d’effectuer une “Dry run”, c'est-à-dire écrire dans un fichier la liste des utilisateurs à inscrire et des utilisateurs à désinscrire. Cette option sera utilisée pour s’assurer que votre comparatif d'inscription est fonctionnel.  
- [ ] L’option -nodesac crée un fichier avec les utilisateurs qui devrait être désactivé mais sans réellement les désactiver. 
- [ ] L’option -nomail permet de créer les utilisateurs sans leur envoyer de courriel de confirmation.  

Précisions : 

* Le registraire fournit chaque session un fichier qui contient les étudiants inscrits en technique informatique, si le nom d'un étudiant n'apparaît plus dans la nouvelle liste c'est qu'il n'est plus inscrit. 
* Dans le cadre du projet, vous devez vous assurer que vous envoyez des courriels professionnels qui expliquent la situation.  
* Vous n’avez pas besoin d’utiliser un serveur Exchange pour cet exercice.  

En tant qu’administrateur réseau/système, votre futur travail vous amènera à manipuler un grand nombre de scripts. Comme pour un projet de développement d’application, la gestion du code source, son partage et la collaboration associée à son écriture, représente un immense enjeu. Pour remédier à ces différentes difficultés, l’outil Git, associé à des services de forges 
logicielles, est l’outil idéal. C’est pour cela que dans le cadre de ce cours, vous devez utiliser Git le GitLab du département pour collaborer, partager et sauvegarder votre travail.  

Vous serez évalué en deux partie :  

1. Ce que vous devez remettre : 
  * Votre plan de travail de l'équipe qui m’indique les étapes de votre projet et les responsabilités de chaque coéquipier en utilisant le modèle suivant. 
  * Une documentation professionnelle expliquant comment utiliser votre script de création de comptes. 
  * Votre script annoté et commenté professionnellement. Les commentaires serviront à expliquer le fonctionnement et les étapes d'exécution de votre script. Votre enseignant évaluera aussi les commentaires.  

2. Et tous autres fichiers nécessaires pour l'exécution de votre script (fichiers de configurations, listes, etc…). 
  * Une évaluation personnelle à remplir sur Moodle.  
  * Une évaluation des autres membre de l’équipe à remplir sur Moodle. 
  * Ce que vous devez présenter: 
  * Une mise en situation qui permettra de prouver que votre travail est robuste et utilisable dans en situation réelle.
