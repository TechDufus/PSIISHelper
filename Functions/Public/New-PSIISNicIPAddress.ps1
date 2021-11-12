#Region New-PSIISNicIPAddress

<#
.SYNOPSIS
    Create a new ip address on the NIC card.
.DESCRIPTION
    This function will create a new IP Address on a NIC Card. This can be ran against the local machine (default) or a remote computer.
.PARAMETER ComputerName
    Specify a remote computer to run against.
.PARAMETER IPAddress
    Specify the IP Address to add.
.PARAMETER InterfaceAlias
    Specify the name of the interface to add to.
.PARAMETER SubnetMask
    Specify the subnet mask for the added IP Address. You may either supply a subnet mask OR the CIDR notation value.
.PARAMETER CIDR
    Specify the CIDR Notation value for the added IP Address. You may either supply a subnet mask OR the CIDR notation value.
.PARAMETER AdminIP
    IP's on a NIC are either labeled the AsSource IP or not. The AsSource IP is the 'master' IP address for the NIC, and the rest of the IPs are bindings for sites and such.
    You shouldn't need to set this unless you are adding / changing the AdminIP on the server.
.PARAMETER Session
    Specify the PSSession to use for the remote computer if a connection is already created.
.EXAMPLE
    PS> New-PSIISNicIPAddress -IPAddress 192.168.139.139 -CIDR 24

    Description
    -----------
    This will create the IPAddress '192.168.139.139' with subnet mask '255.255.255.0' on the Ethernet adapter.
.NOTES
    Author:  Matthew.DeGarmo
    Github:  https://github.com/matthewjdegarmo
    Sponsor: https://github.com/sponsors/matthewjdegarmo

    This function requires the AdminToolkit PSGallery module for the CIDR / Subnet Mask conversions.
#>
Function New-PSIISNicIPAddress() {
    [CmdletBinding()]
    Param(
        [System.String] $ComputerName,
        $Session,
        [IPAddress] $IPAddress,
        [System.String] $InterfaceAlias = 'Ethernet',

        [Parameter(
            ParameterSetName = 'Mask'
        )]
        [IPAddress] $SubnetMask,

        [Parameter(
            ParameterSetName = 'CIDR'
        )]
        [int] $CIDR,

        [Switch] $AdminIP = $false
    )

    Begin {
        # Needed for the Get-CIDRNotationBySubnetMask command in AdminToolkit.
        if (-Not(Get-Module AdminToolkit -ListAvailable)) {
            Install-Module AdminToolkit -Force
        }
    }

    Process {
        $AddressFamily = Switch($IPAddress.AddressFamily) {
            'InterNetwork' {Write-Output 'IPv4'}
            'InterNetworkV6' {Write-Output 'IPv6'}
            DEFAULT {}
        }

        $PrefixLength = Switch($true) {
             $PSBoundParameters.ContainsKey('SubnetMask') {
                 Write-Output (Get-CIDRNotationBySubnetMask -SubnetMask $SubnetMask)
             }
             $PSBoundParameters.ContainsKey('CIDR') {
                 Write-Output $CIDR
             }
             DEFAULT {}
        }

        $NetIPParams = @{
            IPAddress      = $IPAddress
            InterfaceAlias = $InterfaceAlias
            SkipAsSource   = $AdminIP
            Type           = 'UniCast'
            AddressFamily  = $AddressFamily
            PrefixLength   = $PrefixLength
        }
        if ($Session) {
            Invoke-Command -Session $Session -ScriptBlock {
                New-NetIPAddress @using:NetIPParams
            }
        } elseif ($ComputerName) {
            Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                New-NetIPAddress @using:NetIPParams
            }
        } else {
            New-NetIPAddress @NetIPParams
        }
    }
}
#EndRegion New-PSIISNicIPAddress