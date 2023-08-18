#set variables
$status=cscript "c:\program files\Microsoft Office\Office16\OSPP.VBS" /dstatus
$licname='Office 19, Office19ProPlus2019VL_KMS_Client_AE edition'

#find if KMS
if (( $status | Select-String -Pattern $licname) -ne $null )
{
    Write-Host 'installed'
}