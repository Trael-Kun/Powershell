<#
Detects SSDs, selects the smallest capacity and sets it as the OS Disk.

Be sure Format & Partition step is set to:
"Variable name to store disk number: OSDiskIndex"

"Borrowed" from https://learn.microsoft.com/en-us/answers/questions/384014/configuration-manager-osd-ensure-the-os-always-dep
#>

#default value
$disk_idx = 0

#retrieve SSD
$ssd_disk = get-physicaldisk | where mediatype -like 'ssd'

#multiple SSD
if (@($ssd_disk).count -gt 1)  {
	#multiple nvme SSD, choose the smallest one
	if (@($ssd_disk | where bustype -like 'nvme').count -gt 1) {
		$disk_idx = $ssd_disk | Sort-Object -Property Size | Select-Object -ExpandProperty DeviceID -First 1
 	}
	elseif (@($ssd_disk | where bustype -like 'nvme').count -eq 1) {
		$disk_idx = ($ssd_disk | where bustype -like 'nvme').deviceid
	}
}

#single SSD
elseif (@($ssd_disk).count -eq 1) {

#multiple physical disks, choose SSD
if (@(get-physicaldisk).count -gt 1) {
	$disk_idx = ($ssd_disk).deviceid
	}

 #single pysical disks
	else {
	$disk_idx = 0
	}
}

#Write-Host "disk selected: $disk_idx"
(New-Object -COMObject Microsoft.SMS.TSEnvironment).Value('OSDDiskIndex') = $disk_idx
