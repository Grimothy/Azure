##############################################################################################################################################################
#-AccessTier Hot, Cool
   $tier = "Hot"
#-Kind Storage, StorageV2, BlobStorage, BlockBlobStorage, FileStorage
    $kind = "StorageV2"
#Location of the resources created
    $location = "Eastus"
#name of the storage account to be created or the existing storage account
    $name = "catussafiles01"
#-StorageAccountType Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS, Premium_ZRS, Standard_GZRS, Standard_RAGZRS
    $StorageType = "Standard_LRS"
#resourcegroup    
   $resourcegroup = "rg-catus-storageservices01"
#Sharename csv path
   $FSListPath = ".\shares.csv"

##Storage Sync Service name
$StorageSyncServiceName ="CatuslabSync"
 
##############################################################################################################################################################
#Create $resourcegroup for storage account
Write-Host -ForegroundColor Green "Creating resourcegroup" $resourcegroup
    New-AzResourceGroup `
      -Force `
      -Name $resourcegroup `
      -Location $location `
      -Verbose `
#Create Storage Account
   New-AzStorageAccount `
      -Name $name `
      -Location $location `
      -ResourceGroupName $resourcegroup `
      -Kind $kind `
      -StorageAccountType $StorageType `
      -AccessTier $tier `
      -Verbose 
#Import CSV to get pre-defined sharenames
   $FSList = Import-Csv -Path $FSListPath

    foreach ($sharename in $FSList.sharename )
   {
      Write-Host -ForegroundColor Magenta "Creating Files share Share-$sharename under storage account $name"
      New-AzRmStorageShare `
         -StorageAccount $(Get-AzStorageAccount -ResourceGroupName $resourcegroup -Name $name) `
         -Name "share-$sharename" `
         -EnabledProtocol SMB `
         -QuotaGiB 100 `
         -Verbose 
      Write-Host -ForegroundColor Green "share Share-$sharename has been created"
      Start-Sleep -Seconds 5
   }


#create Storage Sync Service
write-host -ForegroundColor Green "Createing Storage Sync Service - SS-$name"
   New-AzStorageSyncService `
      -Name "SS-$StorageSyncServiceName-01" `
      -Location $location `
      -ResourceGroupName $resourcegroup `
      -Verbose
