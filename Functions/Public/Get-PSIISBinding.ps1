#Region Get-PSIISBinding

<#
.SYNOPSIS
    Returns information about IIS web site bindings
.DESCRIPTION
    Takes a list of IIS servers and returns all the web site bindings

    Requires administrator permissions.
.PARAMETER ComputerName
    A string or string array of server names.
.PARAMETER Port
    The port number to use for the connection.
.PARAMETER Credential
    The credentials to use for the connection. If not specified the connection will use the current user.
    You can provide a PSCredential object, or use `New-PSIISSession` to create a PSCredential object that lives for the current powershell session.

    See `Get-Help New-PSIISSession` for more details.
.EXAMPLE
    Get-WebSiteBinding MY_SERVER_NAME

    Description
    -----------
    Returns all the web site bindings for the specified server.
.EXAMPLE
    Get-WebSiteBinding MY_SERVER_NAME1, MY_SERVER_NAME2

    Description
    -----------
    Returns all the web site bindings for the specified servers.
.EXAMPLE
    "MY_SERVER_NAME" | Get-WebSiteBinding

    Description
    -----------
    Returns all the web site bindings for the specified server.
.EXAMPLE
    @("MY_SERVER_NAME1", "MY_SERVER_NAME2") | Get-WebSiteBinding

    Description
    -----------
    Returns all the web site bindings for the specified servers.
.EXAMPLE
    Get-Content myServerNames.txt | Get-WebSiteBinding
.EXAMPLE
    Get-WebSiteBinding -ComputerName "MY_SERVER_NAME" -Port 1234 -Credential $PSCredential

    Description
    -----------
    Returns all the web site bindings for the specified server, using the specified credential.

.NOTES
    Author: Matthewjdegarmo
    GitHub: https://github.com/matthewjdegarmo
    Sponsor: https://github.com/sponsors/matthewjdegarmo
#>
function Get-PSIISBinding() {
    [CmdletBinding()]
    Param (
        [Parameter(
            ValueFromPipeline
        )]
        [System.String[]] $ComputerName = $env:COMPUTERNAME,

        [Parameter()]
        [System.String] $Port = '*',

        [PSCredential]$Credential = $script:PSIISCredential
    )

    Begin {

        Write-Verbose -Message "Starting Get-PSIISBinding"
        
        $scriptBlock = {
            [CmdletBinding()]
            Param(
                [System.String] $Port
            )
            Import-Module WebAdministration;
            $sites = Get-ChildItem -path IIS:\Sites
            foreach ($Site in $sites) {
                foreach ($Bind in (Get-WebBinding $Site.Name)) {
                    foreach ($bindinfo in ($Bind | Select-Object -ExpandProperty bindingInformation)) {
                        $bindingInformation = @($bindinfo -split ':')
                        if ('*' -ne $Port) {
                            If ($Port -ne $bindingInformation[1]) {
                                continue
                            }
                        }
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
        Switch($Port) {
            'HTTP' {$Port = '80'}
            'HTTPS' {$Port = '443'}
            DEFAULT {}
        }
        $ComputerName | Foreach-Object {
            Write-Verbose "Retrieving IIS information from $_"
            If (IsLocal $_) {
                Write-Verbose "$($MyInvocation.MyCommand.Name): Running on local computer: $env:COMPUTERNAME"
                & $scriptBlock -Port $Port -Verbose:$VerbosePreference | Select-Object -ExcludeProperty PSComputerName, RunspaceID, PSShowComputerName
            } Else {
                Write-Verbose "$($MyInvocation.MyCommand.Name): Running on remote computer: $_"
                $InvokeCommandSplat = @{
                    ComputerName = $_
                    ScriptBlock = $ScriptBlock
                    ArgumentList = @($Port)
                }
                If ($null -ne $Credential) { $InvokeCommandSplat['Credential'] = $Credential }
                Invoke-Command @InvokeCommandSplat | Select-Object * -ExcludeProperty RunspaceID, PSShowComputerName
            }
        }
    }
}
#EndRegion Get-PSIISBinding
