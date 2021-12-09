#Region New-PSIISSession

<#
.SYNOPSIS
    Create a new PSCredential to be used for the current session.
.DESCRIPTION
    This will store an environment credential for the current session for PSIISHelper commands.
.PARAMETER Credential
    The credentials to use for the connection. If not specified the connection will use the current user.
    You can provide a PSCredential object.
.PARAMETER PassThru
    If true, the credential will be passed through to the pipeline.
.EXAMPLE
    New-PSIISSession

    Description
    -----------
    Creates a new PSCredential object to be used for the current session.
.EXAMPLE
    New-PSIISSession -Credential $cred -PassThru

    Description
    -----------
    Passes a user-provided credential and creates a new PSCredential object to be used for the current session.
    The credential will be passed through to the pipeline using -PassThru.
.NOTES
    Author:  matthewjdegarmo
    GitHub:  https://github.com/matthewjdegarmo
    Sponsor: https://github.com/sponsors/matthewjdegarmo
#>
Function New-PSIISSession() {
    [CmdletBinding()]
    Param(
        [PSCredential]$Credential = (Get-Credential),
        [switch]$PassThru
    )

    Begin {}

    Process {
        Try {
            $script:PSIISCredential = $Credential
            If ($PassThru) {
                Write-Output $script:PSIISCredential
            }
        } Catch {
            Throw $_
        }
    }

    End {}
}
#EndRegion New-PSIISSession