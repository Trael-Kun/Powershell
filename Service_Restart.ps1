<# Service Restart
-------------------------
Purpose:  Restarts Adobe FRL service 
Author:   Bill Wilson
Created:  24/11/2022
-------------------------
Modified 24/11/22   Bill      ;Changed method from Get-WmiObject to Get-Service
                              ;Added variables for easy maintainence
                              ;Added Restart-Service & Commented out Stop/Start-Service
#>

$PCname = "AdobeFRL01"
$Srv = "FRL Online Proxy"

## Get Service Info
$service = Get-Service -ComputerName $PCname -Name $Srv
$service
<#$service | Get-Member -Type Method

## Stop Service
Stop-Service -InputObject $service -Verbose
$service.Refresh()

## Start Service
Start-Service -InputObject $service -Verbose
$service.Refresh()
#>

## Restart Service
Restart-Service -InputObject $service -Verbose
$service.Refresh()
$service
