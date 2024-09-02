## Variables
# check which folder Pstream is installed to
if (!(Test-Path "${env:ProgramFiles(x86)}\fiScanner")) {
    $Pstream = (Get-ChildItem -Path "$env:SystemDrive\" -Filter 'PFU.PaperStream.Capture.exe' -Recurse -ErrorAction SilentlyContinue).DirectoryName
}
$FjiCube        = "$env:WinDir\twain_32\Fjicube"
$Ini            = "$Fjicube\icwReadThreadParam.ini"
$Sop            = "$Fjicube\SOP\FjLaunch.exe"
$StMenu         = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
$FiLnk          = "$StMenu\fi Series"
$PsLnk          = "$STMENU%\PaperStream Capture"

# Arrays
$Items = @(
    @{Path="$Pstream";                  Version='4.1.0'}
    @{Path="$Fjicube\SOP\FjLaunch.exe"; Version='4.29.0.1'}
)

$Paths = @(
    "$Fjicube\icwReadThreadParam.ini",
    "$Fjicube\SOP\FjLaunch.exe",
    "$StMenu\fi Series",
    "$PsLnk\Tools\Exporter.lnk",
    "$PsLnk\Tools\Importer.lnk",
    "$PsLnk\Administrator Tool.lnk",
    "$PsLnk\Readme.lnk",
    "$PsLnk\Use conditions.lnk'",
    $FiLnk
)
# check versions
foreach ($Item in $Items) {
    if (((Get-Item $Item.Path).VersionInfo).FileVersion -ne $Item.Version) {
        exit 1
    }
}
# check paths
foreach ($Path in $Paths) {
    if (!(Test-Path $Path)) {
        exit 1
    }
}

if (((Get-Item "$Pstream").VersionInfo).FileVersion -eq "$PstreamVer") {
    if ((((Get-Item "$Sop").VersionInfo).productversion.replace(" ","")) -eq $SopVer) {
        if ((Test-Path $Ini)) {
            if (!(Test-Path "$PsLnk\Tools\Exporter.lnk")) {
                if (!(Test-Path "$PsLnk\Tools\Importer.lnk")) {
                    if (!(Test-Path "$PsLnk\Administrator Tool.lnk")) {
                        if (!(Test-Path "$PsLnk\Readme.lnk")) {
                            if (!(Test-Path "$PsLnk\Use conditions.lnk'")) {
                                if (!(Test-Path "$FiLnk")) {
                                    if (!(Test-Path "$PsLnk")) {
                                        'Installed'
                                        exit 0
                                    } else { exit 1 }
                                } else { exit 1 }
                            } else { exit 1 }
                        } else { exit 1 }
                    } else { exit 1 }
                } else { exit 1 }
            }else { exit 1 }
        } else { exit 1 }
    } else { exit 1 }
}
