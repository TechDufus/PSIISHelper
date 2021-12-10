#Region Start-PSIISSite

<#
.SYNOPSIS
    Start an IIS Site.
.DESCRIPTION
    Start an IIS Site.
.PARAMETER ComputerName
    Specify a remote computer to run against.
.PARAMETER Name
    Specify the name of the IIS Site to search for.
.PARAMETER PassThru
    If true, the command will return the IIS information.
.PARAMETER Credential
    The credentials to use for the connection. If not specified the connection will use the current user.
    You can provide a PSCredential object, or use `New-PSIISSession` to create a PSCredential object that lives for the current powershell session.

    See `Get-Help New-PSIISSession` for more details.
.EXAMPLE
    Start-PSIISSite -ComputerName localhost -Name MySite
.NOTES
    Author:  matthewjdegarmo
    GitHub:  https://github.com/matthewjdegarmo
    Sponsor: https://github.com/sponsors/matthewjdegarmo
#>
Function Start-PSIISSite() {
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

        if ($PSCmdlet.ShouldProcess($Site.ComputerName, "Start site: $($Site.Name)")) {
            $ScriptBlock = {
                [CmdletBinding()]
                Param(
                    $Site,
                    [switch]$PassThru
                )
                Import-Module WebAdministration
                Start-Website -Name $Site.Name -ErrorAction SilentlyContinue -PassThru:$PassThru
            }
            $Site.ComputerName | Foreach-Object {
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
#EndRegion Start-PSIISSite