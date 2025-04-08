# ==== DOCUMENTATION ===========================================================

# Inscrire un étudiant: Enable-ADAccount -Identity USERNAME
# Désinscrire un étudiant: Disable-ADAccount -Identity USERNAME

# ==== DÉFINIR PARAMÈTRES ======================================================

param(

  # Créer un ficher qui contient la liste des utilisateurs à inscrire et à désinscrire (-diff)
  [Parameter(Mandatory = $false)]
  [switch]$diff,

  # Créer un fichier avec avec les utilisateurs qui devraient être désactivés mais sans réellement les désactiver (-nodesac)
  [Parameter(Mandatory = $false)]
  [switch]$nodesac, 

  # Créer les utilisateurs sans leur envoyer un courriel de confirmation (-nomail)
  [Parameter(Mandatory = $false)]
  [switch]$nomail
)

# ==== IMPORTER MODULES ========================================================

Import-Module ActiveDirectory
Get-Module ActiveDirectory

# ==== COLLECT ENTRÉES UTILISATEUR =============================================


# Demander et vérifier le chemin complet d'où se retrouve le fichier CSV
while ($true) {
  $fichierCSV = Read-Host "Entez le chemain absolu de votre ficher CSV"
  if (Test-Path "$fichierCSV"){
    Write-Output "$fichierCSV exists"
    Write-Output ""

    $importedCSV = Import-CSV -Path $fichierCSV
    break
  }

  Write-Output "Erreur: $fichierCSV n'existe pas ou n'est pas le bon."
  Write-Output ""
}

$sender = Read-Host "Entrez l'addresse courriel source qui va envoyer les courriels de confirmation" 
$smtpServer = "smtp.gmail.com"
$smtpPort = 587
$appPassword = Read-Host "Entrez l'app password de votre courriel source qui va envoyer les courriels de confirmation"
$secureAppPassword = ConvertTo-SecureString $appPassword -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential ($sender, $secureAppPassword)

# ==== DÉFINIR FONCTIONS =======================================================

Function createUser{

  # Vérification si compte existe déjà et créer le compte AD si il ne existe pas
  try {

    Get-ADUser -Filter { Name -eq $nomComplet } -Properties SamAcccountName, DistinguishedName

    Write-Output "Un utilisateur pour $nomComplet existe déjà."
    Write-Output ""

  } catch {

    $count = 1
    while ($true) {

      try {

        $userCheck = Get-ADUser -Identity $nomUtilisateur -ErrorAction Stop

        Write-Output "$nomUtilisateur exist deja"
        Write-Output ""
        $nomUtilisateur=$prenom+$nom+$count
        $count++
         
      } catch {

        $nomUtilisateur=$prenom+$nom+$count
        $count++

        Write-Output "$nomUtilisateur est disponible"
        Write-Output ""

        break

      }
    }

    Write-Output "Creating $nomUtilisateur"
    Write-Output ""

    Write-Output "New-ADUser -SamAccountName $nomUtilisateur -Name "$nomComplet" -GivenName $prenom -Surname $nom -DisplayName $nomUtilisateur -Country $pays -State $region -City $ville -PostalCode $codePostal -EmailAddress $addresseCourriel -OfficePhone $numeroTelephone -Path CN=Users,DC=infocrosemont,DC=qc,DC=ca -AccountPassword (ConvertTo-SecureString V1ct1mAdm1n! -AsPlainText -Force) -UserPrincipalName $nomUtilisateur -ChangePasswordAtLogon $true -Enabled $true -Verbose"
    New-ADUser -SamAccountName $nomUtilisateur -Name $nomComplet -GivenName $prenom -Surname $nom -DisplayName $nomUtilisateur -Country "CA" -State $region -City $ville -PostalCode $codePostal -EmailAddress $addresseCourriel -OfficePhone "123456789" -Path "CN=Users,DC=infocrosemont,DC=qc,DC=ca" -AccountPassword (ConvertTo-SecureString "V1ct1mAdm1n!" -AsPlainText -Force) -UserPrincipalName $addresseCourrielr -ChangePasswordAtLogon $true -Enabled $true -Verbose

    Write-Output "$nomUtilisateur was successfully created"
    Write-Output ""
  }
}
#}

Function enableUser{
  New-Item -Path ./usersToEnable.txt -ItemType File
}

Function disableUser{
  New-Item -Path ./usersToDisable.txt -ItemType File
}

Function sendConfirmationEmail{

  Write-Output "Send confirmation email to $addresseCourriel"
  Write-Output ""

  Send-MailMessage -From $sender -To $addresseCourriel `-Body "Test" -SmtpServer $smtpServer -Credential $credentials -Port $smtpPort -UseSsl
}

# ==== CRÉER COMPTE AD =========================================================

foreach ($user in $importedCSV){

  Write-Output $user 

  $nomComplet = $user.name                            # tmp
  Write-Output $nomComplet

  $prenom = $nomComplet.substring(0,1).ToLower()      # tmp
  Write-Output $prenom
  
  $nom = $nomComplet.split(" ")[1].ToLower()          # tmp
  Write-Output $nom
  
  $dateNaissance = $user.birthday                     # tmp
  Write-Output $dateNaissance
  
  $numeroTelephone = $user.phone                      # tmp
  Write-Output $numeroTelephone
  
  $addresseCourriel = $user.email                     # tmp
  Write-Output $addresseCourriel
  
  $pays = $user.country                               # tmp
  Write-Output $pays
  
  $region = $user.region                              # tmp
  Write-Output $region
  
  $ville = $user.city                                 # tmp
  Write-Output $ville
  
  $addresse = $user.address                           # tmp
  Write-Output $addresse
  
  $codePostal = $user.postalZip                       # tmp
  Write-Output $codePostal
  
  $nomUtilisateur=$prenom+$nom                        # tmp
  Write-Output $nomUtilisateur

  Write-Output ""

  # Crée compte AD
  createUser

  # Envoyer courriel de confirmation
  sendConfirmationEmail
} 
