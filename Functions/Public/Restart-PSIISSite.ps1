#Region Restart-PSIISSite

<#
.SYNOPSIS
    Restart a Website.
.DESCRIPTION
    Supply the web server and website to restart.
.PARAMETER ComputerName
    Specify the remote server to run against.
.PARAMETER Name
    Specify the website name to restart.
.PARAMETER PassThru
    If true, the command will return the IIS information.
.PARAMETER Credential
    The credentials to use for the connection. If not specified the connection will use the current user.
    You can provide a PSCredential object, or use `New-PSIISSession` to create a PSCredential object that lives for the current powershell session.

    See `Get-Help New-PSIISSession` for more details.
.EXAMPLE
    PS> Restart-PSIISSite -ComputerName WebServer01 -Name DefaultSite

    Description
    -----------
    This will restart the website DefaultSite on WebServer01
.NOTES
    Author:  Matthew.DeGarmo
    Github:  https://github.com/matthewjdegarmo
    Sponsor: https://github.com/sponsors/matthewjdegarmo
#>
Function Restart-PSIISSite() {
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact="High"
    )]
    Param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Server','PSComputerName')]
        [System.String[]] $ComputerName = $env:COMPUTERNAME,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Sitename')]
        [System.String] $Name,

        [switch]$PassThru,

        [PSCredential]$Credential = $script:PSIISCredential
    )

    Begin {}

    Process {
        if ($_ -is [System.Object]) {
            $Site = @{
                # The below If Else statements are version of these Turnary commands. 
                # Windows PowerShell can't handle turnary operators. Leaving these here for reference to the below logic.
                
                # ComputerName = ($_.Server) ? $_.Server : (($_.ComputerName) ? $_.ComputerName : $_.PSComputerName)
                # Name         = ($_.Sitename) ? $_.Sitename : $_.Name
            }

            If ($_.Server) {
                $Site['ComputerName'] = $_.Server
            } Else {
                If ($_.ComputerName) {
                    $Site['ComputerName'] = $_.ComputerName
                } Else {
                    $Site['ComputerName'] = $_.PSComputerName
                }
            }

            If ($_.Sitename) {
                $Site['Name'] = $_.Sitename
            } Else {
                $Site['Name'] = $_.Name
            }
        } else {
            $Site = @{
                ComputerName = $ComputerName
                Name         = $Name
            }
        }

        if ($PSCmdlet.ShouldProcess($Site.ComputerName, "Restart site: $($Site.Name)")) {
            $ScriptBlock = {
                [CmdletBinding()]
                Param(
                    $Site,
                    [switch]$PassThru
                )
                Import-Module WebAdministration
                Stop-Website -Name $Site.Name -ErrorAction SilentlyContinue
                Start-Website -Name $Site.Name -ErrorAction SilentlyContinue -PassThru:$PassThru
            }
            $Site.ComputerName | FOreach-Object {
                If (IsLocal $_) {
                    & $ScriptBlock -Site $Site -PassThru:$PassThru
                } Else {
                    $InvokeCommandSplat = @{
                        ComputerName = $_
                        ScriptBlock = $ScriptBlock
                        ArgumentList = @($Site, $PassThru)
                    }
                    If ($null -ne $Credential) { $InvokeCommandSplat['Credential'] = $Credential }
                    Invoke-Command @InvokeCommandSplat | Select-Object * -ExcludeProperty RunspaceID
                }
            }
        }
    }
}
#EndRegion Restart-PSIISSite