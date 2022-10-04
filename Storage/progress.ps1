#Sharename csv path
$FSListPath = ".\shares.csv"
#Import CSV to get pre-defined sharenames
$FSList = Import-Csv -Path $FSListPath

$progress = 1

foreach ($share in $FSList.sharename)
{
    Write-Progress -Activity "getting number of shares" -Status "Got Share name $share" -Id 1 -PercentComplete ($progress/$FSList.count*100)
    Start-Sleep -Milliseconds 10000
    $progress++
}