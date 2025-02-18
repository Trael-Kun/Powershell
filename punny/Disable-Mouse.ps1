function Disable-Mouse {
    while ($true) {
        $Mouses = Get-PnpDevice -Class Mouse
        foreach ($Mouse in $Mouses) {
            if ($Mouse.Status -eq 'OK' )
            Disable-PnpDevice -InstanceId $Mouse -Confirm $false
        }
    }
}
