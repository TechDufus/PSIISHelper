#Region New-PSIISBinding

<#
.SYNOPSIS
    Create a new site binding on a web server.
.DESCRIPTION
    This will create the binding for a site on a web server.
.PARAMETER InputObject
    Supply a structured object
.PARAMETER ComputerName
    Specify a remote computer to create a binding on. Default is the local machine.
.PARAMETER Port
    Specify the port to bind to. Default is 80.
.PARAMETER Protocol
    Specify the protocol to use. Default is http.
.EXAMPLE
    PS> Import-Csv .\Port80bindings.csv | New-PSIISBinding
.EXAMPLE
Server,Sitename,Protocol,IpAddress,Port,HostName
    PS> $80Site = @{
            SiteName  = 'SomeSite'
            IPAddress = 10.10.10.10
            HostName  = 'Someurl.matthewjdegarmo.com'
            Port      = 80
    }
    PS> New-PSIISPort80Binding -InputObject $80Site

    Description
    -----------
    In this example, we are creating the site object in the hashtable `$80Site` which has all of the values needed.
.NOTES
    Author:  Matthew.DeGarmo
    Github:  https://github.com/matthewjdegarmo
    Sponsor: https://github.com/sponsors/matthewjdegarmo
#>
Function New-PSIISBinding() {
    [CmdletBinding(
        DefaultParameterSetName = 'Pipeline'
    )]
    param(
        [Parameter(
            Mandatory,
            ParameterSetName = 'Pipeline',
            ValueFromPipeline
        )]
        [PSCustomObject] $InputObject,

        [System.String[]] $ComputerName = $env:COMPUTERNAME,

        [System.String] $Port = '80',

        [System.String] $Protocol = 'http'
    )
    
    Begin {
        $OriginalVerbosePreference = $VerbosePreference
    }

    Process {
        Try {
            If ($_ -is [System.Object]) {
                $Binding = $_
            } else {
                $Binding = $InputObject
                #Write-Error "Input not of valid format. See ``Get-Help New-PSIISPort80Binding -Examples`` for more information on how to use this cmdlet."
            }

            $ScriptBlock = {
                [CmdletBinding()]
                Param(

                )
                $bindingParams = @{
                    Protocol   = $Protocol
                    Name       = $Binding.Sitename
                    Port       = $Port
                    IPAddress  = $Binding.IpAddress
                    HostHeader = $Binding.Hostname
                    Verbose    = $VerbosePreference
                }
            }

            Invoke-Command -ComputerName $ComputerName -ScriptBlock {New-WebBinding @Using:bindingParams}
        } Catch {
            Write-Error "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
        }
    }
    
    End {
        $VerbosePreference = $OriginalVerbosePreference
    }
}
#EndRegion New-PSIISPort80Binding
