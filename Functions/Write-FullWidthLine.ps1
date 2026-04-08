function Write-FullWidthLine {
    param(
        [string]$Character = '-'
    )

    $Width = $Host.UI.RawUI.WindowSize.Width
    Write-Output ($Character * $width)
}
