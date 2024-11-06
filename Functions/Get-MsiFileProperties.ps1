function Get-MsiFileProperties {
<#
  .SYNOPSIS
    Retreives MSI file properties
  .NOTES
  Author: "Grenade"
  Slightly messed about with by: Bill Wilson (https://github.com/Trael-Kun)
  Stolen Wholesale from:
    https://stackoverflow.com/questions/11251034/find-guid-from-msi-file/29938049#29938049
#>

  param (
    [Parameter(Mandatory=$true,
      HelpMessage='Path to MSI file.')]
    [ValidateNotNullOrEmpty()]
    [System.IO.FileInfo] $path,

    [string[]] $properties = @('ProductCode', 'ProductVersion', 'ProductName', 'Manufacturer', 'ProductLanguage')
  )
  begin {
    $windowsInstaller = (New-Object -ComObject WindowsInstaller.Installer)
  }
  process {
    if ($ExecutionContext.SessionState.LanguageMode -eq 'ConstrainedLanguage') {
      Write-Host 'This script will not run in constrained language mode.' -ForegroundColor Red
    }
    $table = @{}
    $msi = $windowsInstaller.GetType().InvokeMember('OpenDatabase', 'InvokeMethod', $null, $windowsInstaller, @($Path.FullName, 0))
    foreach ($property in $properties) {
      try {
        $view = $msi.GetType().InvokeMember('OpenView', 'InvokeMethod', $null, $msi, ("SELECT Value FROM Property WHERE Property = '$($property)'"))
        $view.GetType().InvokeMember('Execute', 'InvokeMethod', $null, $view, $null)
        $record = $view.GetType().InvokeMember('Fetch', 'InvokeMethod', $null, $view, $null)
        $table.add($property, $record.GetType().InvokeMember('StringData', 'GetProperty', $null, $record, 1))
      }
      catch {
        $table.add($property, $null)
      }
    }
    $msi.GetType().InvokeMember('Commit', 'InvokeMethod', $null, $msi, $null)
    $view.GetType().InvokeMember('Close', 'InvokeMethod', $null, $view, $null)
    $msi = $null
    $view = $null
    return $table
  }
  end {
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($windowsInstaller) | Out-Null
    [System.GC]::Collect()
  }
}
