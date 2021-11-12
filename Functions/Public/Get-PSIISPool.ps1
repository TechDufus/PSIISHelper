#Region Get-PSIISPool

<#
.SYNOPSIS
    Get application pool information.
.DESCRIPTION
    Query one or multiple remote servers for their application pools and other information.
.PARAMETER ComputerName
    Specify a remote computer to run against.
.PARAMETER Name
    Specify the name of the Application Pool to search for.
.PARAMETER State
    Specify the state of the application pool to query
.EXAMPLE
    PS> Get-PSIISPool -ComputerName some-remote-pc1

    Description
    -----------
    Query 'some-remote-pc1' for all started app pools.
.EXAMPLE
    PS> Get-PSIISPool -ComputerName WebServer01 -Name SiteAppPool_01

    Description
    -----------
    This will get the single app pool SiteAppPool_01 from WebServer01
.EXAMPLE
    PS> Get-PSIISPool -ComputerName WebServer01 -State Stopped

    Description
    -----------
    Get all stopped app pools from WebServer01
.EXAMPLE
    PS> Get-PSIISPool WebServer01,WebServer02 -State *

    Description
    -----------
    Search for all app pools (all states) from WebServer01 and WebServer02
.OUTPUTS
    [PSCustomObject]@{
        Name            # Name of Application Pool
        State           # State of Application Pool
        Applications    # Site Names that are in this Application Pool
        PSComputerName  # ComputerName that the Application Pool lives on.
    }
.NOTES
    Author:  Matthew.DeGarmo
    Github:  https://github.com/matthewjdegarmo
    Sponsor: https://github.com/sponsors/matthewjdegarmo
#>
Function Get-PSIISPool() {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Server', 'PSComputerName')]
        [System.String[]] $ComputerName = $env:COMPUTERNAME,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('ApplicationPool')]
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
        if ($_ -is [System.Object]) {
            $Pool = @{
                # The below If Else statements are version of these Turnary commands. 
                # Windows PowerShell can't handle turnary operators. Leaving these here for reference to the below logic.
                
                # ComputerName = ($_.Server) ? $_.Server : (($_.ComputerName) ? $_.ComputerName : $_.PSComputerName)
                # Name         = ($_.ApplicationPool) ? $_.ApplicationPool : $_.Name
            }

            If ($_.Server) {
                $Pool['ComputerName'] = $_.Server
            } Else {
                If ($_.ComputerName) {
                    $Pool['ComputerName'] = $_.ComputerName
                } Else {
                    $Pool['ComputerName'] = $_.PSComputerName
                }
            }

            If ($_.ApplicationPool) {
                $Pool['Name'] = $_.ApplicationPool
            } Else {
                $Pool['Name'] = $_.Name
            }
            
        } else {
            $Pool = @{
                ComputerName = $ComputerName
                Name         = $Name
            }
        }

        $ScriptBlock = {
            Param(
                $InputObject,
                [System.String]$State
            )
            Write-Verbose "$($COMPUTERNAME)`: Retrieving pool information..."
            Import-Module WebAdministration
            $Pools = Get-ChildItem 'IIS:\AppPools' | Where-Object { ($_.State -like $State) -and ($_.Name -match $InputObject.Name) }
            $Sites = Get-ChildItem 'IIS:\Sites'

            $Pools | Foreach-Object {
                $Pool = $_
                [PSCustomObject] @{
                    Name = $Pool.Name
                    State = $Pool.State
                    Applications = ($Sites | Where-Object {$_.applicationPool -eq $Pool.Name}).Name
                    ComputerName = $env:COMPUTERNAME
                }
            }
        }

        $Pool.ComputerName | Foreach-Object {
            If (IsLocal $_) {
                & $ScriptBlock -InputObject $Pool -State $State
            } Else {
                Invoke-Command -ComputerName $_ -ScriptBlock $ScriptBlock -ArgumentList $_, $State | Select-Object * -ExcludeProperty RunspaceID
            }
        }
    }

    End {
        $global:FormatEnumerationLimit = $OriginalFormatEnumerationLimit
    }
}
#EndRegion Get-PSIISPool