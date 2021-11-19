#Region IsLocal

<#
.SYNOPSIS
    Test to see if the provided computer name is the local computer.
.DESCRIPTION
    This function tests to see if the provided computer name is the local computer.
.PARAMETER ComputerName
    The computer name to test.
.EXAMPLE
    IsLocal "MyComputer"

    Description
    -----------
    This function tests to see if the provided computer name is the local computer.
.NOTES
    Author:  matthewjdegarmo
    GitHub:  https://github.com/matthewjdegarmo
    Sponsor: https://github.com/sponsors/matthewjdegarmo
#>
Function IsLocal() {
    [CmdletBinding()]
    [OutputType([bool])]
    Param(
        [System.String]$ComputerName
    )

    Begin {
        $LocalValues = @(
            'localhost',
            '.',
            $env:COMPUTERNAME
        )
    }

    Process {
        Try {
            $IsLocal = $LocalValues | Foreach-Object {
                if ($_ -eq $ComputerName) {
                    Write-Output $true
                    break
                }
            }

            [bool]$IsLocal
        } Catch {
            Throw $_
        }
    }

    End {}
}
#EndRegion IsLocal