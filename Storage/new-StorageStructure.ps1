##############################################################################################################################################################
#-AccessTier Hot, Cool
   $tier = "Hot"
#-Kind Storage, StorageV2, BlobStorage, BlockBlobStorage, FileStorage
    $kind = "StorageV2"
#Location of the resources created
    $location = "Eastus"
#name of the storage account to be created or the existing storage account
    $name = "catussafiles02"
#-StorageAccountType Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS, Premium_ZRS, Standard_GZRS, Standard_RAGZRS
    $StorageType = "Standard_LRS"
#resourcegroup    
   $resourcegroup = "rg-catus-storageservices02"
#Sharename csv path
   $FSListPath = ".\shares.csv"

#FileShare Quota in GB
   [int]$FSQuota = 100

##Storage Sync Service name
   $StorageSyncServiceName ="SS-CatuslabSync-02"

   #Import CSV to get pre-defined sharenames
   $FSList = Import-Csv -Path $FSListPath
 
##############################################################################################################################################################
#Create $resourcegroup for storage account
Write-Host -ForegroundColor Green "Creating resourcegroup" $resourcegroup
    New-AzResourceGroup `
      -Force `
      -Name $resourcegroup `
      -Location $location `
      -Verbose 
#Create Storage Account
   New-AzStorageAccount `
      -Name $name `
      -Location $location `
      -ResourceGroupName $resourcegroup `
      -Kind $kind `
      -StorageAccountType $StorageType `
      -AccessTier $tier `
      -Verbose 


    foreach ($sharename in $FSList.sharename )
   {
      Write-Host -ForegroundColor Magenta "Creating Files share Share-$sharename under storage account $name"
      New-AzRmStorageShare `
         -StorageAccount $(Get-AzStorageAccount -ResourceGroupName $resourcegroup -Name $name) `
         -Name "share-$sharename" `
         -EnabledProtocol SMB `
         -QuotaGiB $FSQuota `
         -verbose 
         #-WhatIf `
      Write-Host -ForegroundColor Green "share Share-$sharename has been created"
   }


#create Storage Sync Service
write-host -ForegroundColor Green "Creating Storage Sync Service - $StorageSyncServiceName"
   New-AzStorageSyncService `
      -Name $StorageSyncServiceName `
      -Location $location `
      -ResourceGroupName $resourcegroup `
      -Verbose 
     # -WhatIf 
#create storage sync service objects
<#
For ($i=0; $i -le 100; $i++) {
   Start-Sleep -Milliseconds 2000
   Write-Progress -Activity "Prepairing Storage Objects" -Status "Current %: $i" -PercentComplete $i -CurrentOperation "Prepairing ..."
}
#>
write-host -ForegroundColor Green
   foreach ($sharename  in $FSList.sharename) 
   {
      Write-Host -ForegroundColor Magenta "Creating storage Sync group share-$sharename for Storage Sync Service"
      New-AzStorageSyncGroup -ResourceGroupName $resourcegroup `
         -Name "share-$sharename" `
         -StorageSyncServiceName $StorageSyncServiceName `
         -Verbose 
   }
   
   foreach ($sharename  in $FSList.sharename) 
   {
     Write-Host -ForegroundColor Green "Storage sync group share-$sharename Created"
      
   New-AzStorageSyncCloudEndpoint `
      -Name "$name-share-$sharename" `
      -ResourceGroupName $resourcegroup `
      -StorageAccountResourceId $(Get-AzStorageAccount -ResourceGroupName $resourcegroup -Name $name).Id `
      -AzureFileShareName "share-$sharename" `
      -StorageSyncServiceName $StorageSyncServiceName `
      -SyncGroupName "share-$sharename" `
      -Verbos
      }
   

      #Clean up old resources
      foreach ($sharename in $FSList.sharename)
      {

         Get-AzStorageSyncCloudEndpoint -ResourceGroupName $resourcegroup -StorageSyncServiceName $StorageSyncServiceName -SyncGroupName "share-$sharename" |Remove-AzStorageSyncCloudEndpoint -Verbose -Force
         Get-AzStorageSyncGroup -ResourceGroupName $resourcegroup -StorageSyncServiceName $StorageSyncServiceName -Name "share-$sharename" | Remove-AzStorageSyncGroup -Verbose -Force
      }
      Get-AzStorageSyncService -ResourceGroupName $resourcegroup -Name $StorageSyncServiceName | Remove-AzStorageSyncService -Verbose -Force
      Get-AzResourceGroup -ResourceGroupName $resourcegroup | Remove-AzResource -Force