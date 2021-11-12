#Region IsLocal

<#
.SYNOPSIS

.DESCRIPTION

.NOTES
    Author: matthewjdegarmo
    GitHub: https://github.com/matthewjdegarmo
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
            $LocalValues.Contains($ComputerName)
        } Catch {
            Throw $_
        }
    }

    End {}
}
#EndRegion IsLocal