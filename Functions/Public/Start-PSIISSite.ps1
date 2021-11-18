#Region Start-PSIISSite

<#
.SYNOPSIS

.DESCRIPTION

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

        [switch]$PassThru
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
                    Invoke-Command -ComputerName $_ -ScriptBlock $ScriptBlock -ArgumentList $Site, $PassThru | Select-Object -ExcludeProperty RunspaceId
                }
            }
        }
    }
}
#EndRegion Start-PSIISSite