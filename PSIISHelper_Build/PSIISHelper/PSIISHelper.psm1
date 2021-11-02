#Region Get-PSIISBinding

<#
.SYNOPSIS
    Returns information about IIS web site bindings
.DESCRIPTION
    Takes a list of IIS servers and returns all the web site bindings

    Requires administrator permissions.
.PARAMETER ComputerName
    A string or string array of server names
.EXAMPLE
    Get-WebSiteBinding MY_SERVER_NAME
.EXAMPLE
    Get-WebSiteBinding MY_SERVER_NAME1, MY_SERVER_NAME2
.EXAMPLE
    "MY_SERVER_NAME" | Get-WebSiteBinding
.EXAMPLE
    @("MY_SERVER_NAME1", "MY_SERVER_NAME2") | Get-WebSiteBinding
.EXAMPLE
    Get-Content myServerNames.txt | Get-WebSiteBinding

.NOTES
    Author: Matthewjdegarmo
    GitHub: https://github.com/matthewjdegarmo
#>
function Get-PSIISBinding() {
    [CmdletBinding()]
    Param (
        [Parameter(
            ValueFromPipeline
        )]
        [System.String[]] $ComputerName
    )

    Begin {

        Write-Verbose -Message "Starting Get-PSIISBinding"
        
        $scriptBlock = {
            Import-Module WebAdministration;
            $sites = Get-ChildItem -path IIS:\Sites
            foreach ($Site in $sites) {
                foreach ($Bind in (Get-WebBinding $Site.Name)) {
                    foreach ($bindinfo in ($Bind | Select-Object -ExpandProperty bindingInformation)) {
                        $bindingInformation = @($bindinfo -split ':')

                        [pscustomobject]@{
                            Server          = $env:COMPUTERNAME
                            Sitename        = $Site.name
                            Id              = $Site.id
                            State           = $Site.State
                            PhysicalPath    = $Site.physicalPath
                            ApplicationPool = $Site.applicationPool
                            Protocol        = $Bind.Protocol
                            SslFlags        = $Bind.sslFlags
                            IpAddress       = $bindingInformation[0]
                            Port            = $bindingInformation[1]
                            HostName        = $bindingInformation[2]
                        }
                    }
                }
            }
        }
    }

    Process {
        Write-Verbose "Retrieving IIS information from $ComputerName"
        Invoke-Command -ComputerName $ComputerName -ScriptBlock  $scriptBlock | Select-Object -ExcludeProperty PSComputerName, RunspaceID, PSShowComputerName
    }
}
#EndRegion Get-PSIISBinding

