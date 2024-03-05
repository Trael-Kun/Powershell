if ($False -in (Get-NetAdapterBinding -ComponentID ms_tcpip6).enabled) {
    Exit 1
} else {
   Exit 0
}
