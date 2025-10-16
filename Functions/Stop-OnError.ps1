function Stop-OnError {
    <#
        .SYNOPSIS
         $ErrorActionPreference = "Stop on a specific error type"
        .DESCRIPTION
         Stops script if the last error is of the category specified
        .PARAMETER Category
         Specifies the category of error that will stop the script. Accepts only error categories mentioned 
         in https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.errorcategory
        .EXAMPLE
         C:\PS> Stop-OnError -Category ObjectNotFound
         Stops the script if the category of the error immediately preceding the function is "ObjectNotFound"

    #>
    param (
    [ValidateSet(
        'NotSpecified',`
        'OpenError',`
        'CloseError',`
        'DeviceError',`
        'DeadlockDetected',`
        'InvalidArgument',`
        'InvalidData',`
        'InvalidOperation',`
        'InvalidResult',`
        'InvalidType',`
        'MetadataError',`
        'NotImplemented',`
        'NotInstalled',`
        'ObjectNotFound',`
        'OperationStopped',`
        'OperationTimeout',`
        'SyntaxError',`
        'ParserError',`
        'PermissionDenied',`
        'ResourceBusy',`
        'ResourceExists',`
        'ResourceUnavailable',`
        'ReadError',`
        'WriteError',`
        'FromStdErr',`
        'SecurityError',`
        'ProtocolError',`
        'ConnectionError',`
        'AuthenticationError',`
        'LimitsExceeded',`
        'QuotaExceeded',`
        'NotEnabled'`
        )] [string]$Category
    )
    if ($error[0].CategoryInfo.Category -eq $Cat) {
        Write-Host $($error[0].Exception).Message -ForegroundColor Red
        Exit 1
    }
}
