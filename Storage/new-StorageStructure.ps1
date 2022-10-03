 #-AccessTier Hot, Cool
     $tier = "Hot"
 #-Kind Storage, StorageV2, BlobStorage, BlockBlobStorage, FileStorage
    $kind = "StorageV2"
    $location = "Eastus"
    $name = "catussafiles01"
 #-	StorageAccountType Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS, Premium_ZRS, Standard_GZRS, Standard_RAGZRS
    $StorageType = "Standard_LRS"
    $resourcegroup = "rg-catus-safiles01"
 
New-AzResourceGroup `
    -Name $resourcegroup `
    -Location $location `

 New-AzStorageAccount `
    -Name $name `
    -Location $location `
    -ResourceGroupName $resourcegroup `
    -Kind $kind `
    -StorageAccountType $StorageType `
    -AccessTier $tier `


    $shareName = "myshare"

New-AzRmStorageShare `
    -StorageAccount $name `
    -Name "test1" `
    -EnabledProtocol SMB `
    -QuotaGiB 1024 | Out-Null