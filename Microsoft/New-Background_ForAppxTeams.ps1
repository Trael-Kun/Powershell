<#
.SYNOPSIS
   Resizes and renames images for use as Teams backgrounds

.DESCRIPTION
    Automate MS Teams Backgrounds;
    - create large & small copies
    - generate GUID name
    - copy to %LOCALAPPDATA%\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\Backgrounds\Uploads

.NOTES
    Written by Bill Wilson (https://github.com/Trael-Kun)
    Date 04/05/2025
    References;
        https://smbtothecloud.com/deploy-custom-backgrounds-to-new-teams-with-remediations/
        https://gist.github.com/someshinyobject/617bf00556bc43af87cd
#>

##Variables
$FileTypes = "jpeg","jpg","png","bmp"
#Thumbnail size (pixels)
$Width     = 250
$Height    = 158
#Directory where original images are stored (Change $BackgroundsDir to your location)
$BackgroundsDir     = "$env:USERPROFILE\Pictures\TeamsBackground"
#Directory to new files (default is New Teams custom background folder)
$RenamedBackgrounds = "$env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\Backgrounds\Uploads"

##############
##SCRIPT START

# Get images
$Images = @() #set up empty array for file list

foreach ($File in $FileTypes) {
    $Images =+ (Get-ChildItem -Path "$BackgroundsDir\*" -Filter "*.$File")
}

#----------------
## Process images
foreach ($Image in $Images.FullName) {
    # Set new image names
    $Uid = New-Guid                                             #create new name based on GUID
    Write-Host "New GUID is $Uid"
    $Dot = $Image.LastIndexOf(".")                              #count characters before file extension
    $Ext = $Image.Substring($Dot,$Image.Length - $Dot)          #get file extension
    
    # Build new filenames
    $FileName = $Uid + $Ext                                                     #build primary file name
    $ThumbName = "$Uid" + "_thumb" + $Path.Substring($Dot,$Path.Length - $Dot)  #build thumbnail name
    Write-Host "New Primary file is $FileName"
    Write-Host "New Thumbnail is $Thumbnail"

    # Set new file paths
    $NewNameDest = Join-Path -Path $RenamedBackgrounds -ChildPath $FileName  #set primary file path
    $ThumbDest   = Join-Path -Path $RenamedBackgrounds -ChildPath $ThumbName #set thumbnail path
    
    #------------------------
    ## Create thumbnail image

    # Get original image
    $OldImage = New-Object -TypeName System.Drawing.Bitmap -ArgumentList $Image          
    
    # Process image
    $Bitmap   = New-Object -TypeName System.Drawing.Bitmap -ArgumentList $Width, $Height
    $NewImage = [System.Drawing.Graphics]::FromImage($Bitmap)                            

    # Retrieve best quality
    $NewImage.SmoothingMode = $SmoothingMode
    $NewImage.InterpolationMode = $InterpolationMode
    $NewImage.PixelOffsetMode = $PixelOffsetMode
    $NewImage.DrawImage($OldImage, $(New-Object -TypeName System.Drawing.Rectangle -ArgumentList 0, 0, $Width, $Height))

    #-------------------------------
    # Send new images to destination
    Copy-Item -Path $Image.FullName -Destination $NewNameDest  #copy primary file
    $Bitmap.Save($ThumbDest)                                   #save thunbnail

    # Clean up before processing next image
    $Bitmap.Dispose()
    $NewImage.Dispose()
    $OldImage.Dispose()
}

############
##END SCRIPT
