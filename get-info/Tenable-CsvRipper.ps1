<#
 .SYNOPSIS
    extracts the useful values from .csv files (dnsName, IP & file paths)
 .DESCRIPTION
    extracts values from .csv files (specifically Tenable reports);
     Machine dns name
     Machine IP address
     (Otional filter) CVE number
    and matches them up with the file path of the affected file in the "pluginText" column.

    Written specifically to extract the file path of .jar files affected by CVE-2021-44228
    from .csv output by Tenable. 
    CSV format is like;
    
        firstSeenDate,lastSeenDate,lastFixedDate,pluginID,pluginName,dnsName,ip,operatingSystem,cve,pluginText,solution    
        21/04/2023,18/11/2024,,000000,Apache Log4j < 2.15.0 Remote Code Execution (Windows),server01.domain,10.10.10.xx,Microsoft Windows Server 20xx Standard Build xxx,CVE-2021-44228,"<plugin_output>
        Path              : C:\Program Files (x86)\xxx\xxx\lib\log4j-core-2.6.2.jar
        Installed version : 1
        Fixed version     : 2
        Path              : C:\Program Files (x86)\xxx\xxx\lib\log4j-core-2.11.0.jar
        Installed version : 3
        Fixed version     : 4
        Path              : C:\Program Files (x86)\xxx\xxx\bin\lib\log4j-core-2.5.jar
        Installed version : 5
        Fixed version     : 6
        </plugin_output>","Upgrade to Apache Log4j version 2.3.1 / 2.12.3 / 2.15.0 or later, or apply the vendor mitigation.
    
    This script will pull the filepaths out & match them with the dnsName and IP address earlier in the file
 .NOTES
    Author: Bill Wilson (https://github.com/Trael-Kun)
    Date:   29/11/2024
#>
param (
    [Parameter(Mandatory)]
    [string]$InputCsv,
    [string]$OutputCsv,
    [Parameter(Mandatory=$false)]
    [string]$Cve
)

#set an empty array
$Paths = @()

#this is the regex filter that will extract the filepath from everything else
$filePathRegex = "([a-zA-Z]:\\[^<>:""/\\|?*]+(?:\\[^<>:""/\\|?*]+)*)"
#don't ask me how regex works, ask https://www.regular-expressions.info

$Csv = Import-Csv -Path $InputCsv                                                                                               #get the .csv data

foreach ($Row in $Csv) {
    $Name   = $Row.DnsName                                                                                                      #get the DNS Name
    $IP     = $Row.Ip                                                                                                           #get the IP
    $CveNo  = $Row.Cve
    $Path   = ([regex]::Matches($Row.PlugInText,$filePathRegex).value).replace("
    `   Installed version",'')                                                                                                  #get the file paths
    $Drive   = Split-Path -Path $File -Qualifier
    $JarFile = Split-Path -Path $File -Leaf

    if ($Cve) {
        foreach ($File in $Path) {
            if ($CveNo -eq $Cve) {
                $Info = [pscustomobject]@{DnsNameName=$Name; IP=$ip; CVE=$CveNo; Path=$File; Drive=$Drive; JarFile=$JarFile}    #organise data
                $Paths += $Info
            }
        }
    } else {
        foreach ($File in $Path) {                                              
            $Info = [pscustomobject]@{DnsNameName=$Name; IP=$ip; Path=$File; Drive=$Drive; JarFile=$JarFile}                    #organise data
            $Paths += $Info                                                                                                     #collate data
        }
    }
}
$Paths | Export-Csv -Path $OutputCsv -Append -Force                                                     #export data
