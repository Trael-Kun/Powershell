<# Set Timezone by IP
compiled by Bill #>

#set timezone variables
$SYD = 'AUS Eastern Standard Time'
$TAS = 'Tasmania Standard Time'
$DAR = 'AUS Central Standard Time'
$ADE = 'Cen. Australia Standard Time'
$PER = 'W. Australia Standard Time'
$BRIS = 'E. Australia Standard Time'
$UTC = 'UTC'

##set IP variables
#WA (1) IP
$PerIP1 = '10.0.0.1'
#WA (2) IP
$PerIP2 = '10.0.0.2'
#Hobart IP
$TasIP = '10.0.0.3'
#Darwin IP
$DarIP = '10.0.0.4'
#QLD IP
$BrisIP = '10.0.0.5'
#SA (Adelaide) IP
$AdeIP = '10.0.0.6'
#ACT (1) IP
$CbrIP1 = '10.0.0.7'
#ACT (2) IP
$CbrIP2 = '10.0.0.8'
#NSW (1) IP
$SydIP = '10.0.0.9'
#VIC (1) IP
$VicIP1 = '10.0.0.10'
#VIC (2) IP
$VicIP2 = '10.0.0.11'

#find web IP
$IP = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content


    if ($IP.IPv4Address -eq $PerIP1) {
        Set-TimeZone -Name $PER
    }
    elseif ($IP.IPv4Address -eq $PerIP2) {
        Set-TimeZone -Name $PER
    }
    elseif ($IP.IPv4Address -eq $TasIP) {
        Set-TimeZone -Name $TAS
    }
    elseif ($IP.IPv4Address -eq $DarIP) {
        Set-TimeZone -Name $DAR
    }
    elseif ($IP.IPv4Address -eq $BrisIP) {
        Set-TimeZone -Name $Bris
    }
    elseif ($IP.IPv4Address -eq $AdeIP) {
        Set-TimeZone -Name $ADE
    }
    elseif ($IP.IPv4Address -eq $CbrIP1) {
        Set-TimeZone -Name $SYD
    }
    elseif ($IP.IPv4Address -eq $CbrIP2) {
        Set-TimeZone -Name $SYD
    }
    elseif ($IP.IPv4Address -eq $SydIP) {
        Set-TimeZone -Name $SYD
    }
    elseif ($IP.IPv4Address -eq $VicIP1) {
        Set-TimeZone -Name $SYD
    }
    elseif ($IP.IPv4Address -eq $VicIP2) {
        Set-TimeZone -Name $SYD
    }
    else {
        Set-TimeZone -Name $UTC
    }

