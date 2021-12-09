#Requires -Modules @{ModuleName="Pester";ModuleVersion="5.0.0"}
BeforeDiscovery {
    $PublicFunctionsPath = [System.IO.Path]::Combine($PSScriptRoot, '..', 'Functions', 'Public', '*.ps1')
    $PublicFunctions = Get-ChildItem -Path $PublicFunctionsPath
    $ManifestPath = ([System.IO.Path]::Combine($PSScriptRoot, '..', 'PSIISHelper.psd1'))
    Remove-Module PSIISHelper -ErrorAction SilentlyContinue
    Import-Module ([System.IO.Path]::Combine($PSScriptRoot, '..', 'PSIISHelper.psd1')) -Force
}
Describe "PSIISHelper Module Public Tests" {
    Context "Public Function: <_.BaseName>" -ForEach $PublicFunctions {
        BeforeEach {
            $CurrentFunction = $_.BaseName
        }
        It "Should export function all public functions" {
            (Test-ModuleManifest ([System.IO.Path]::Combine($PSScriptRoot, '..', 'PSIISHelper.psd1'))).ExportedCommands.Values.Name | Should -Contain $CurrentFunction -Because "ExportedCommands should contain the function name"
        }
    }
    Context 'Aliases' {
        It 'should import successfully' {
            $AliasesPath = [System.IO.Path]::Combine($PSScriptRoot, '..', 'Functions', 'Public', 'Aliases.ps1')
            if (Test-Path $AliasesPath) {
                $ModuleAliases = (Get-Content $AliasesPath | Select-String "Set-Alias").Count
                $ActualAliases = (Get-Command -Module PSIISHelper -CommandType Alias).Count
            }
            else {
                $ModuleAliases = 0
                $ActualAliases = 0
            }
            $ActualAliases | Should -Match $ModuleAliases
        }
    }
    Context 'Files' {
        It 'LICENSE should exist' {
            $LicenseFile = [System.IO.Path]::Combine($PSScriptRoot, '..', 'LICENSE')
            $isLicense = Get-ChildItem $LicenseFile
            $isLicense | Should -Be $true
        }
        It 'CHANGELOG.md should exist' {
            $ChangelogFile = [System.IO.Path]::Combine($PSScriptRoot, '..', 'CHANGELOG.md')
            $isChangelog = Get-ChildItem $ChangelogFile
            $isChangelog | Should -Be $true
        }
    }
}


