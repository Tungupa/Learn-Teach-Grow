
$Name = Read-Host "Enter both First and Last name of user"

while($Name -ne "y"){
#Get the Name



#Get the Identity (SamAccountName)

$SamAccountName =Get-ADUser -Filter  "CN -eq '$Name'" -SearchBase "DC=companyName,DC=com"  | Select-Object -ExpandProperty SamAccountName


# Gets the Camera Groups
$Groups = Get-ADPrincipalGroupMembership  -Identity $SamAccountName  | select Name | Sort Name |Where-Object { $_.name -like '*TextToSearch*'} | Sort

$Groups | Format-Table

Write-Host " "

$Name = Read-Host "Enter the next name or y to exit "

Write-Host " "

}
