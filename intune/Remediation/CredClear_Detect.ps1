	#Set Targets
$targets = @("office", "webproxy", "graph.microsoft")

foreach ($target in $targets) {
    # Get the list of stored credentials for the current target
    $credentials = cmdkey /list  | Select-String -Pattern $target

    # Remove each credential for the current target
    foreach ($credential in $credentials) {
        if ($credential) {
            EXIT 1
        }
        else {
            EXIT 0
        }
    }
}