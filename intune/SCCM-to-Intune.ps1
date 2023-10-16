[CmdletBinding(DefaultParameterSetName = 'Default')]
param(
	[Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,Position=0)][alias("DNSHostName","ComputerName","Computer")] [String[]] $Name = @("localhost"),
	[Parameter(Mandatory=$False)] [String] $OutputFile = "\\Server01\Autopilot\Autopilot.csv", 
	[Parameter(Mandatory=$False)] [String] $GroupTag = "AutoPilot"
)

Begin
{
	# Initialize empty list
	$computers = @()
}
Process
{
	foreach ($comp in $Name)
	{
		$bad = $false

		# Get a CIM session
		$session = New-CimSession

		# Get the common properties.
		Write-Verbose "Checking $comp"
		$serial = (Get-CimInstance -CimSession $session -Class Win32_BIOS).SerialNumber

		# Get the hash (if available)
		$devDetail = (Get-CimInstance -CimSession $session -Namespace root/cimv2/mdm/dmmap -Class MDM_DevDetail_Ext01 -Filter "InstanceID='Ext' AND ParentID='./DevDetail'")
		if ($devDetail -and (-not $Force))
		{
			$hash = $devDetail.DeviceHardwareData
		}
		else
		{
			$bad = $true
			$hash = ""
		}


			$make = ""
			$model = ""

		# Getting the PKID is generally problematic for anyone other than OEMs, so let's skip it here
		$product = ""


			# Create a pipeline object
			$c = New-Object psobject -Property @{
				"Device Serial Number" = $serial
				"Windows Product ID" = $product
				"Hardware Hash" = $hash
			}
			
			if ($GroupTag -ne "")
			{
				Add-Member -InputObject $c -NotePropertyName "Group Tag" -NotePropertyValue $GroupTag
			}

		# Write the object to the pipeline or array
		if ($bad)
		{
			# Report an error when the hash isn't available
			Write-Error -Message "Unable to retrieve device hardware data (hash) from computer $comp" -Category DeviceError
		}
		elseif ($OutputFile -eq "")
		{
			$c
		}
		else
		{
			$computers += $c
			Write-Host "Gathered details for device with serial number: $serial"
		}

		Remove-CimSession $session
	}
}


End
{
	if (Test-Path $OutputFile)
		{
		    $computers += Import-CSV -Path $OutputFile
		}
            $computers | Select-Object "Device Serial Number", "Windows Product ID", "Hardware Hash", "Group Tag" | ConvertTo-CSV -NoTypeInformation | ForEach-Object {$_ -replace '"',''} | Out-File $OutputFile
    
}
