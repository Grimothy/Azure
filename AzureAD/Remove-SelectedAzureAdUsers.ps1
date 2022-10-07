#Connect to Azure AD
Connect-AzAccount

#Prompt user for a list of AD users in Azure
$adusers = Get-AzureADUser | Out-GridView -PassThru -Title "Select users to remove"

 #Run a loop to delete the users select

 ForEach ($user in $adusers)
 {
    Write-Host -ForegroundColor Magenta "Performing delete operation on $user.displayname. You will be prompted to confirm deletion"
    Remove-AzureADUser -ObjectId $user.objectid -confirm   
 }
