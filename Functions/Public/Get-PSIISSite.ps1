#Region Get-PSIISSite

<#
.SYNOPSIS
    Get IIS Site information.
.DESCRIPTION
    Get IIS Site information.
.PARAMETER ComputerName
    Specify a remote computer to run against.
.PARAMETER Name
    Specify the name of the Application Pool to search for.
.PARAMETER State
    Specify the state of the application pool to query.
.EXAMPLE
    Get-PSIISSite -ComputerName "localhost" -Name "DefaultSite"
.NOTES
    Author: matthewjdegarmo
    GitHub: https://github.com/matthewjdegarmo
#>
Function Get-PSIISSite() {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Server', 'PSComputerName')]
        [System.String[]] $ComputerName = $env:COMPUTERNAME,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Site')]
        [System.String] $Name,

        [Parameter()]
        [ValidateSet('Started','Stopped', '*')]
        [System.String] $State = '*'
    )

    Begin {
        $OriginalFormatEnumerationLimit = $FormatEnumerationLimit
        $global:FormatEnumerationLimit = -1
    }

    Process {

        $ScriptBlock = {
            Param(
                [System.String]$Name,
                [System.String]$State
            )
            Write-Verbose "$($COMPUTERNAME)`: Retrieving Site information..."
            Import-Module WebAdministration
            $WhereList = New-Object System.Collections.ArrayList
            $Where = $null

            If ($Name) {[void]$WhereList.Add('$_.Name -like $Name')}
            If ($State) {[void]$WhereList.Add('$_.State -like $State')}
            $Where = [scriptblock]::Create($WhereList -join " -and ")

            Get-ChildItem 'IIS:\Sites' | Where-Object $Where | Foreach-Object {
                [PSCustomObject] @{
                    Name = $_.Name
                    State = $_.State
                    ApplicationPool = $_.ApplicationPool
                    ComputerName = $env:COMPUTERNAME
                }
            }
        }

        $ComputerName | Foreach-Object {
            If (IsLocal $_) {
                & $ScriptBlock -Name $Name -State $State
            } Else {
                Invoke-Command -ComputerName $_ -ScriptBlock $ScriptBlock -ArgumentList $Name, $State | Select-Object * -ExcludeProperty RunspaceID
            }
        }
    }

    End {
        $global:FormatEnumerationLimit = $OriginalFormatEnumerationLimit
    }
}
#EndRegion Get-PSIISSite