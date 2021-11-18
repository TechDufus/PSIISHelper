#Region Start-PSIISPool

<#
.SYNOPSIS
    Restart an application pool.
.DESCRIPTION
    Supply the web server and application pool to recycle.
.PARAMETER ComputerName
    Specify the remote server to run against.
.PARAMETER Name
    Specify the pool name to recycle.
.PARAMETER Sites
    Specify the site names that are tied to this pool. This parameter is meant to support Pipeline values, but is not required to specify manually.
    Example:

    $Pool | Restart-PSIISPool                             # $Pool will have Sites information and pass it through the pipeline.
    Restart-PSIISPool -ComputerName Server1 -Name Pool1   # No site information will be included..
.EXAMPLE
    PS> Restart-PSIISPool -ComputerName WebServer01 -Name DefaultSitePool

    Description
    -----------
    This will recycle the DefaultSitePool pool on WebServer01.
.EXAMPLE
    PS> Get-AppPool -ComputerName WebServer01 -Name DefaultSitePool | Restart-PSIISPool

    Description
    -----------
    This will recycle the DefaultSitePool pool on WebServer01.
.EXAMPLE
    PS> Get-AppPool -ComputerName WebServer01,WebServer02 | Restart-PSIISPool

    Description
    -----------
    CAUTION: This will recycle ALL app pools on WebServer01 and WebServer02.
.EXAMPLE
    PS> Get-WebsiteInformation url.matthewjdegarmo.com | Restart-PSIISPool

    Description
    -----------
    If url.matthewjdegarmo.com is found, this will prompt to recycle the app pool it is using.
    You should only do this if you KNOW that this is the only site on the found Application Pool.
.NOTES
    Author:  matthewjdegarmo
    GitHub:  https://github.com/matthewjdegarmo
    Sponsor: https://github.com/sponsors/matthewjdegarmo
#>
Function Start-PSIISPool() {
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = "High"
    )]
    Param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Server', 'PSComputerName')]
        [System.String[]] $ComputerName = $env:COMPUTERNAME,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('ApplicationPool')]
        [System.String] $Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Sitename', 'Applications')]
        [System.String[]] $Sites,

        [switch]$PassThru
    )

    Begin {}

    Process {
        #Region Dynamic Pipeline handling
        if ($_ -is [System.Object]) {
            $Pool = @{
                # The below If Else statements are version of these Turnary commands. 
                # Windows PowerShell can't handle turnary operators. Leaving these here for reference to the below logic.

                # ComputerName = ($_.Server) ? $_.Server : (($_.ComputerName) ? $_.ComputerName : $_.PSComputerName).ToUpper()
                # Name         = ($_.ApplicationPool) ? $_.ApplicationPool : $_.Name
                # Sites        = ($_.SiteName) ? $_.SiteName : (($_.Applications) ? $_.Applications : $_.Sites)
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

            If ($_.SiteName) {
                $Pool['Sites'] = $_.SiteName
            } Else {
                If ($_.Applications) {
                    $Pool['Sites'] = $_.Applications
                } Else {
                    $Pool['Sites'] = $_.Sites
                }
            }
        }
        else {
            $Pool = @{
                ComputerName = $ComputerName.ToUpper()
                Name         = $Name
            }
            If ($Sites) {
                $Pool['Sites'] = $Sites.ToUpper()
            }
            else {
                $Pool['Sites'] = (Get-PSIISPool -ComputerName $Pool.ComputerName -Name $Pool.Name).Applications
            }
        }
        #EndRegion Dynamic Pipeline handling

        if ($PSCmdlet.ShouldProcess($Pool.ComputerName, "Start $($Pool.Name) pool containing sites: $($Pool.Sites)")) {
            $ScriptBlock = {
                [CmdletBinding()]
                Param(
                    $Pool,
                    [switch]$PassThru
                )
                Write-Verbose "$($Pool.ComputerName): Starting Pool: $($Pool.Name)"
                Import-Module WebAdministration
                Start-WebAppPool -Name $Pool.Name -ErrorAction SilentlyContinue -PassThru:$PassThru
            }

            If (IsLocal $Pool.ComputerName) {
                & $ScriptBlock -Pool $Pool -PassThru:$PassThru
            } Else {
                Invoke-Command -ComputerName $Pool.ComputerName -ScriptBlock $ScriptBlock -ArgumentList $Pool, $PassThru
            }
        }
    }
}
#EndRegion Start-PSIISPool