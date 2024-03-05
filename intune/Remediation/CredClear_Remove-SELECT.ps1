#Set Targets
$targets = @("office", "webproxy", "graph.microsoft")
#Set extranious text
$Replacer = '    Target: Domain:target='

foreach ($target in $targets) {
    # Get the list of stored credentials for the current target
    $credentials = cmdkey /list  | Select-String -Pattern $target

    # Remove each credential for the current target
    foreach ($credential in $credentials) {
        #Constrained Language Mode like this bit, throws errors without it (but still works)
        $credentialParts = $credential -split '     '
        $credentialTarget = $credentialParts.replace($Replacer,'')

        # Remove the credential using cmdkey
        cmdkey /delete:$credentialTarget
    }
}
Write-Host "Credentials for specified targets have been removed from Windows Credential Manager. Please reboot your Laptop."
