 $computers = Get-Content -Path "c:\temp\PClist.txt"
 foreach ($computer in $computers)
     {
     $ip = $computer.Split(" - ")[0]
     if (Test-Connection  $ip -Count 1 -ErrorAction SilentlyContinue){
         Write-Host "$ip is up"
         }
     else{
         Write-Host "$ip is down"
         }
     }
