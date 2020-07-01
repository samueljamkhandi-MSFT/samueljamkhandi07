$inputfile = New-Item -Path . -Name "InputFile.csv" -ItemType "file"
$outputfile = New-Item -Path . -Name "ServerEndPoints.csv" -ItemType "file"

#fetch ResourceGroupName,StorageSyncServiceName,SyncGroupName and store in CSV and this is will passed as input later
Get-AzStorageSyncService | Foreach {
Get-AzStorageSyncGroup -ResourceGroupName $_.ResourceGroupName -StorageSyncServiceName $_.StorageSyncServiceName | Select-Object ResourceGroupName,StorageSyncServiceName,SyncGroupName | Export-Csv $inputfile -Append -NoTypeInformation
}
#select excel file you want to read
$file = $inputfile
$sheetName = "InputFile"

#create new excel COM object
$excel = New-Object -com Excel.Application

#open excel file
$wb = $excel.workbooks.open($file)

#select excel sheet to read data
$sheet = $wb.Worksheets.Item($sheetname)

#select total rows
$rowMax = ($sheet.UsedRange.Rows).Count

#create new object with ResourceGroupName, StorageSyncServiceName, SyncGroupName properties.
$myData = New-Object -TypeName psobject
$myData | Add-Member -MemberType NoteProperty -Name ResourceGroupName -Value $null
$myData | Add-Member -MemberType NoteProperty -Name StorageSyncServiceName -Value $null
$myData | Add-Member -MemberType NoteProperty -Name SyncGroupName -Value $null

#create empty arraylist
$myArray = @()

for ($i = 2; $i -le $rowMax; $i++)
{
    $objTemp = $myData | Select-Object *
   
    #read data from each cell
    $objTemp.ResourceGroupName = $sheet.Cells.Item($i,1).Text
    $objTemp.StorageSyncServiceName = $sheet.Cells.Item($i,2).Text
    $objTemp.SyncGroupName = $sheet.Cells.Item($i,3).Text
  
    $myArray += $objTemp
}
#print $myarry object
#$myArray
#print $myarry object with foreach loop
foreach ($x in $myArray)
{
    Get-AzStorageSyncServerEndpoint -ResourceGroupName $x.ResourceGroupName -StorageSyncServiceName $x.StorageSyncServiceName -SyncGroupName $x.SyncGroupName | Select-Object ResourceGroupName, SyncGroupName, StorageSyncServiceName, ServerEndpointName, ServerLocalPath, ProvisioningState | Export-Csv $outputfile -Append -NoTypeInformation
}

$excel.Quit()

#force stop Excel process
Stop-Process -Name EXCEL -Force