#Region Get-PSIISPoolWPRequests

<#
.SYNOPSIS
    Show Requests in an Application Pool Worker Process.
.DESCRIPTION
    Generate current Requests sitting in an Application Pools Worker Process.
.PARAMETER ComputerName
    Specify the remote computername to run against.
.PARAMETER Name
    Specify the Application Pool Name.
.EXAMPLE
    PS> Get-PSIISPoolWPRequests -ComputerName Some-Remote-Server01

    Description
    -----------
    Generate all Worker Process requests for Some-Remote-Server01
.EXAMPLE
    PS> Get-PSIISPoolWPRequests -ComputerName RemoteServ01 -Name Some_App_Pool01

    Description
    -----------
    Generate Worker PRocess requests on RemoteServ01 for pool Some_App_Pool01
.NOTES
    Author:  Matthew.DeGarmo
    Github:  https://github.com/matthewjdegarmo
    Sponsor: https://github.com/sponsors/matthewjdegarmo
#>
Function Get-PSIISPoolWPRequests() {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Server','PSComputerName')]
        [System.String[]] $ComputerName = $env:COMPUTERNAME,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('ApplicationPool')]
        [System.String] $Name
    )

    Begin {}

    Process {
        if ($_ -is [System.Object]) {
            $Site = @{
                # The below If Else statements are version of these Turnary commands. 
                # Windows PowerShell can't handle turnary operators. Leaving these here for reference to the below logic.
                
                # ComputerName = (($_.Server) ? $_.Server : (($_.ComputerName) ? $_.ComputerName : $_.PSComputerName)).ToUpper()
                # Name         = (($_.Sitename) ? $_.Sitename : (($_.Applications) ? $_.Applications : $_.Name)).ToUpper()
                ComputerName = (If ($_.Server) {
                                    $_.Server
                                } Else {
                                    If ($_.ComputerName) {
                                        $_.ComputerName
                                    } Else {
                                        $_.PSComputerName
                                    }
                                }
                ).ToUpper()

                Name         = (If ($_.Sitename) {
                                    $_.Sitename
                                } Else {
                                    If ($_.Applications) {
                                        $_.Applications
                                    } Else {
                                        $_.Name
                                    }
                                }
                ).ToUpper()
            }
        } else {
            $Site = @{
                ComputerName = $ComputerName.ToUpper()
                Name         = $Name ? $Name : '*'
            }
        }

        Invoke-command -ComputerName $Site.ComputerName -ScriptBlock {
            $CIMParams = @{
                NameSpace = 'root\WebAdministration'
                Class = 'WorkerProcess'
            }
            if ($using:Site.Name -ne '*') {
                $CIMParams['Filter'] = "AppPoolName='$($using:Site.Name)'"
            }
            Get-CimInstance @CIMParams | Foreach-Object {
                $Process = $_
                Invoke-CimMethod -InputObject $Process -Name GetExecutingRequests | Select-Object -ExpandProperty OutputElement | Foreach-Object {
                    [PSCustomObject]@{
                        AppPoolName     = $Process.AppPoolName
                        ProcessId       = $Process.ProcessId
                        ClientIPAddress = $_.ClientIPAddress
                        HostName        = $_.HostName
                        LocalIPAddress  = $_.LocalIPAddress
                        LocalPort       = $_.LocalPort
                        SiteId          = $_.SiteId
                        Url             = $_.Url
                        Verb            = $_.Verb
                        PSComputerName  = $Process.__SERVER
                    }
                }
            }
        } | Select-Object -ExcludeProperty RunspaceId
    }
}
#EndRegion Get-PSIISPoolWPRequests