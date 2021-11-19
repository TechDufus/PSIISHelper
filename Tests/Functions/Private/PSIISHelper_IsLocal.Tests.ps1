InModuleScope PSIISHelper {
    Describe "Function: IsLocal" {
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
                @{ComputerName = '.'},
                @{ComputerName = "$env:COMPUTERNAME"}
            ) {
                Param(
                    [System.String]$ComputerName
                )

                IsLocal -ComputerName $ComputerName | Should -Be $true
            }
        }
    }
}
