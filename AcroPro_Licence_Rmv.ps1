<#
Adobe Acrobat Machine Shared Licence Removal
Written by Bill Wilson 25/05/2023

For use removing serial licences for Standalone (non-Creative Cloud Packager deployments) of Adobe Acrobat Pro

.Description
Identifies product Licensing identifiers (LeID) and runs the Adobe Provisioning Toolkit Enterprise Edition (APTEE) tool 
"Adobe_prtk" to remove licences in preperation for Named User Licensing (NUL) deployment

.References
https://www.adobe.com/devnet-docs/acrobatetk/tools/AdminGuide/migratetonud.html#standalone-non-ccp-deployments
https://www.adobe.com/devnet-docs/acrobatetk/tools/AdminGuide/identify.html#identify
#>

#Variables
$regid = "regid.1986-12.com.adobe"
$SWIDDir = "$Env:ProgramData\$regid"
$IsSWID = Test-Path "$SWIDDir\$regid*.swidtag"

if ($IsSWID -eq $True) {
#Set LeIDs
    $LeID = @(
        'V7{}AcrobatETLA-12-Win-GM-MUL'
        'V7{}AcrobatESR-12-Win-GM-en_US'
        'V6{}AcrobatStd-AS2-Win-GM-MUL'
        'V7{}AcrobatESR-12-Win-GM-en_US'
        'V7{}AcrobatETLA-12-Win-GM-MUL'
        'V7{}AcrobatESR-12-Win-GM-MUL'
        'V6{}AcrobatPro-AS2-Win-GM-MUL'
        'V6{}AcrobatStd-AS2-Win-GM-MUL'
        'V7{}CreativeCloudEnt-1.0-Win-GM-MUL'
    )
    
    # Get Licence Details
    $SWIDTAG = Get-Childitem -Path "$SWIDDir" -Filter "$regid*.swidtag"
    
    if ($SWIDTAG.Name -like "*$LeID[0]*") {
        $Product = $LeID[0]
    }
    elseif  ($SWIDTAG.Name -like "*$LeID[1]*") {
        $Product = $LeID[1]
    }
    elseif  ($SWIDTAG.Name -like "*$LeID[2]*") {
        $Product = $LeID[2]
    }
    elseif  ($SWIDTAG.Name -like "*$LeID[3]*") {
        $Product = $LeID[3]
    }
    elseif  ($SWIDTAG.Name -like "*$LeID[4]*") {
        $Product = $LeID[4]
    }
    elseif  ($SWIDTAG.Name -like "*$LeID[5]*") {
        $Product = $LeID[5]
    }
    elseif  ($SWIDTAG.Name -like "*$LeID[6]*") {
        $Product = $LeID[6]
    }
    elseif  ($SWIDTAG.Name -like "*$LeID[7]*") {
        $Product = $LeID[7]
    }
    elseif  ($SWIDTAG.Name -like "*$LeID[8]*") {
        $Product = $LeID[8]
    }
    else {
        exit 1
    }

    #Run Licence removal
    cmd /c "%~dp0Adobe_prtk.exe –-tool=UnSerialize --leid=$Product --deactivate –-force"
}

else {
}
