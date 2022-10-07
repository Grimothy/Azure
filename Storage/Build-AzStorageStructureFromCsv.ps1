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
   $resourcegroup = "rg-catus-demostorageservices"


#FileShare Quota in GB
   [int]$FSQuota = 100

#Storage Sync Service name
   $StorageSyncServiceName ="SS-Catus-05"
#Sharename csv path
   $FSListPath = ".\shares.csv"
   #Import CSV to get pre-defined sharenames
   $FSList = Import-Csv -Path $FSListPath
 
##############################################################################################################################################################
#Begin Script

Write-Progress -Activity "Creating Azure File and Sync Server Structure" -Status "Running..." -CurrentOperation "Prepairing" -PercentComplete 5 -Id 1

#Convert variables to lowercase to confirm with naming conventions required by certain azure services
$name = $name.ToLower()
$StorageSyncServiceName =$StorageSyncServiceName.ToLower()

#Create $resourcegroup for storage account
Write-Progress -Activity "Building the resourge group - $resourcegroup" -CurrentOperation "Processing resource group $resourcegroup creation" -PercentComplete 50 -Id 2 -ParentId 1
    New-AzResourceGroup `
      -Force `
      -Name $resourcegroup `
      -Location $location `
      -Verbose 
   Write-Progress -Activity "Building the resourge group - $resourcegroup" -Completed  -PercentComplete 100 -Id 2 -ParentId 1
   Write-Progress -Activity "Creating Azure File and Sync Server Structure" -Status "Running..." -PercentComplete 25 -Id 1
   
#Create Storage Account
Write-Progress -Activity "Building the resourge group - $resourcegroup" -CurrentOperation "Processing storage account $name creation" -PercentComplete 50 -Id 3 -ParentId 1
   New-AzStorageAccount `
      -Name $name `
      -Location $location `
      -ResourceGroupName $resourcegroup `
      -Kind $kind `
      -StorageAccountType $StorageType `
      -AccessTier $tier `
      -Verbose 
Write-Progress -Activity "Building the resourge group - $resourcegroup" -Completed -PercentComplete 100 -Id 3 -ParentId 1
Write-Progress -Activity "Creating Azure File and Sync Server Structure" -Status "Running..." -PercentComplete 25 -Id 1

$progress = 1
foreach ($sharename in $FSList.sharename)
   {
      $sharename = $sharename.ToLower()
      Write-Progress -Activity "Building Azure file shares under storage account $name" -CurrentOperation "Processing share share-$sharename" -PercentComplete ($progress/$FSList.count*100) -Id 4 -ParentId 1
      New-AzRmStorageShare `
         -StorageAccount $(Get-AzStorageAccount -ResourceGroupName $resourcegroup -Name $name) `
         -Name "share-$sharename" `
         -EnabledProtocol SMB `
         -QuotaGiB $FSQuota `
         -verbose 
         #-WhatIf `
      $progress++
   }
   Write-Progress -Activity "Building Azure file shares under storage account $name" -Completed -PercentComplete 100 -Id 4 -ParentId 1
   Write-Progress -Activity "Creating Azure File and Sync Server Structure" -Status "Running..." -PercentComplete 50 -Id 1

#create Storage Sync Service
Write-Progress -Activity "Building Storage Sync Service - $StorageSyncServiceName"  -PercentComplete 50 -Id 5 -ParentId 1
   New-AzStorageSyncService `
      -Name $StorageSyncServiceName `
      -Location $location `
      -ResourceGroupName $resourcegroup `
      -Verbose 
     # -WhatIf 
     Write-Progress -Activity "Building Storage Sync Service - $StorageSyncServiceName" -Completed  -PercentComplete 100 -Id 5 -ParentId 1
     Write-Progress -Activity "Creating Azure File and Sync Server Structure" -Status "Running..." -PercentComplete 75 -Id 1

     #create storage sync service objects
$progress = 1
write-host -ForegroundColor Green
   foreach ($sharename  in $FSList.sharename) 
   {
      $sharename = $sharename.ToLower()
      Write-Progress -Activity "Building Azure storage Sync group share-$sharename" -CurrentOperation "Processing Sync group share-$sharename" -PercentComplete ($progress/$FSList.count*100) -Id 6 -ParentId 1
      New-AzStorageSyncGroup -ResourceGroupName $resourcegroup `
         -Name "share-$sharename" `
         -StorageSyncServiceName $StorageSyncServiceName `
         -Verbose 
         $progress++
   }
   Write-Progress -Activity "Building Azure storage Sync group share-$sharename" -Completed  -PercentComplete 100 -Id 6 -ParentId 1
   Write-Progress -Activity "Creating Azure File and Sync Server Structure" -Completed -PercentComplete 100 -Id 1
   
   
   
  
   
   $progress = 1
   foreach ($sharename  in $FSList.sharename) 
   {
      $sharename = $sharename.ToLower()
      Write-Progress -Activity "Building Azure storage sync CloudEndpoint" -CurrentOperation "Processing CloudEndpoint $name-share-$sharename for syncgroup share-$sharename " -PercentComplete ($progress/$FSList.count*100) -Id 6 -ParentId 1   
      New-AzStorageSyncCloudEndpoint `
         -Name "$name-share-$sharename" `
         -ResourceGroupName $resourcegroup `
         -StorageAccountResourceId $(Get-AzStorageAccount -ResourceGroupName $resourcegroup -Name $name).Id `
         -AzureFileShareName "share-$sharename" `
         -StorageSyncServiceName $StorageSyncServiceName `
         -SyncGroupName "share-$sharename" 
      #-Verbos
      $progress++

      }
   #>
<#

    #Clean up old resources
      foreach ($sharename in $FSList.sharename)
      {

         Get-AzStorageSyncCloudEndpoint -ResourceGroupName $resourcegroup -StorageSyncServiceName $StorageSyncServiceName -SyncGroupName "share-$sharename" |Remove-AzStorageSyncCloudEndpoint -Verbose -Force
         Get-AzStorageSyncGroup -ResourceGroupName $resourcegroup -StorageSyncServiceName $StorageSyncServiceName -Name "share-$sharename" | Remove-AzStorageSyncGroup -Verbose -Force
      }
      Get-AzStorageSyncService -ResourceGroupName $resourcegroup -Name $StorageSyncServiceName | Remove-AzStorageSyncService -Verbose -Force
      Get-AzResourceGroup -ResourceGroupName $resourcegroup | Remove-AzResource -Force


#>
Write-Host -ForegroundColor Magenta "If an error has occured during the cloudendpoint creation phase, you may need to run the script again. You do NOT need to delete any deployed resources"