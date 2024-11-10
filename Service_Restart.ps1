<# Service Restart
-------------------------
Purpose:  Restarts Adobe FRL service 
Author:   Bill Wilson
Created:  24/11/2022
-------------------------
Modified 24/11/22   Bill      ;Changed method from Get-WmiObject to Get-Service
                              ;Added variables for easy maintainence
                              ;Added Restart-Service & Commented out Stop/Start-Service
Modified 11/11/24   Bill      ;Added parameters
                              ;Changed variable names clarity
#>

param (
  [Parameter(mandatory)]
  $Servername   # eg "AdobeFRL01"
  $ServiceName  #eg "FRL Online Proxy"
)

## Get Service Info
$service = Get-Service -ComputerName $Servername -Name $service
$service
<#
$service | Get-Member -Type Method

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
