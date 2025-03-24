<#
Gets list of users with scheduled tasks
#>

$users = @()
$schtasks = Get-ScheduledTask
foreach ($Task in $schtasks) {
    $tskUser = $Task.Principal.UserId 
    switch ($Task.Principal.UserId) {
"NETWORK SERVICE" { $continue = "Skip User" }
"LOCAL SERVICE" { $continue = "Skip User" }
"SYSTEM" { $continue = "Skip User"}
"$null" { $continue = "Skip User" }
        default { $continue = "Report User" }
    }
    if ($continue -eq "Report User") {  
        $users += $tskUser
    }
}
$users | Get-Unique
