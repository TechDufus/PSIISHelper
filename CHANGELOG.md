# Changelog for PSIISHelper

## v0.0.3

`New Functions`:

+ `New-PSIISSession`
  + This function will create a new session credential that all PSIIS cmdlets will reference for the life of the session (or until the credential is removed, see `Remove-PSIISSession`).
+ `Remove-PSIISSession`
  + This function will remove a session credential created by `New-PSIISSession`.

`Current Function Changes`:

Each PSIIS command has been updated to accept a `-Credential` `[PSCredential]` object (with the exception of `Remove-PSIISSession`).
You are now able to manually provide your own credential to each cmdlet, or invoke `New-PSIISSession` to create a session credential that all cmdlets will reference for the life of the session.

`Additional Test Coverage`:

+ Adding additional test coverage, ensuring compatibility with Pester v5+.
+ Additional tests to ensure all public files are exported in the module manifest.

`BUG Fixes`:

+ [Issue #2](https://github.com/matthewjdegarmo/PSIISHelper/issues/2)
  + Fixed function returning `True` when a `-ComputerName` contained a period (eg. FQDNs)

`Closed Issues`:

+ [Issue #2](https://github.com/matthewjdegarmo/PSIISHelper/issues/2)
  + Fixed function returning `True` when a `-ComputerName` contained a period (eg. FQDNs)
+ [Issue #3](https://github.com/matthewjdegarmo/PSIISHelper/issues/3)
  + Cmdlets now accept credentials using `-Credential` or `New-PSIISSession`.

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