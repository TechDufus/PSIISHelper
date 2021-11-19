# Changelog for PSIISHelper

## v0.0.3

`Additional Test Coverage`:

+ Adding additional test coverage, ensuring compatibility with Pester v5+.

`BUG Fixes`:

+ [Issue #2](https://github.com/matthewjdegarmo/PSIISHelper/issues/2)
  + Fixed function returning `True` when a `-ComputerName` contained a period (eg. FQDNs)

## v0.0.2

`New-Functions`:

+ `Get-PSIISPool`
+ `Get-PSIISPoolWPRequests`
+ `Get-PSIISSite`
+ `New-PSIISBinding`
+ `New-PSIISNicIPAddress`
+ `Restart-PSIISPool`
+ `Restart-PSIISSite`
+ `Start-PSIISPool`
+ `Start-PSIISSite`
+ `Stop-PSIISPool`

## v0.0.1

Reserving the module name on the powershell gallery.

`New-Functions`:

+ `Get-PSIISBinding`:
  + Get all iis binding information on a given computer.