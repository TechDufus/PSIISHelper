#Region Remove-PSIISSession

<#
.SYNOPSIS
    This function is used to remove the session credential for PSIISHelper.
.DESCRIPTION
    This function is used to remove stored session credential that the PSIISHelper commands use.
.EXAMPLE
    Remove-PSIISSession

    Description
    -----------
    This function removes the stored session credential that the PSIISHelper commands use.
.NOTES
    Author:  matthewjdegarmo
    GitHub:  https://github.com/matthewjdegarmo
    Sponsor: https://github.com/sponsors/matthewjdegarmo
#>
Function Remove-PSIISSession() {
    [CmdletBinding()]
    Param()

    Begin {}

    Process {
        Try {
            Get-Variable PSIISCredential -ErrorAction SilentlyContinue | Remove-Variable
        } Catch {
            Throw $_
        }
    }

    End {}
}
#EndRegion Remove-PSIISSession