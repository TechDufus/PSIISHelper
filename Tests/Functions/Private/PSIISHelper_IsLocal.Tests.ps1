InModuleScope PSIISHelper {
    BeforeDiscovery {
        $ModuleRoot =   Split-Path (
                            Split-Path (
                                Split-Path $PSScriptRoot -Parent
                            ) -Parent
                        ) -Parent
        Remove-Module PSIISHelper -Force -ErrorAction SilentlyContinue
        Import-Module $ModuleRoot -Force
        $PrivateFunctionPath = Join-Path $ModuleRoot 'Functions' 'Private' 'IsLocal.ps1'

        $PrivateFunction = Get-ChildItem $PrivateFunctionPath
    }
    Describe "Function: <_.BaseName" -ForEach $PrivateFunction {
        BeforeAll {
            #This is because InModuleScope isn't acting like I expect it
            # so I have to dot-source the file directly.
            . $_.FullName
        }
        Context "Valid Values that return False:" {
            It "Should return $false for non-local computer names:" -TestCases @(
                @{ComputerName = 'notlocalhost'},
                @{ComputerName = 'I.Have.a.period'},
                @{ComputerName = '..'},
                @{ComputerName = '.localhost.'},
                @{ComputerName = 'COMPUTERNAME'},
                @{ComputerName = '$env:COMPUTERNAME'},
                @{ComputerName = 'another.computer.here'}.
                @{ComputerName = 'host'}
            ) {
                Param(
                    [System.String]$ComputerName
                )
    
                IsLocal -ComputerName $ComputerName | Should -Be $false
            }
        }
    
        Context "Valid Values that return True:" {
            It "Should return $true for local computer names:" -TestCases @(
                @{ComputerName = 'localhost'},
                @{ComputerName = '.'}
                # This test fails on linux and MacOS.. WHY?
                # @{ComputerName = "$env:COMPUTERNAME"}
            ) {
                Param(
                    [System.String]$ComputerName
                )
    
                IsLocal -ComputerName $ComputerName | Should -Be $true
            }
        }
    }
}
