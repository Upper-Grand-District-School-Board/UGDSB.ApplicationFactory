# 0.6.0

- Added Changelog file
- Update PSADT template to log to C:\ProgramData\Microsoft\IntuneManagementExtension\Logs
- Fix to be able to download "Folders" from azure storage since no longer doing archive files
- Added function for extra files
- Added version support for PSADT scripts
- Added cmdlet to build new package versions
- Added links/badges if an application has a privacy or information url defined in GUI
- Added the ability to pause updating an application that we know the update is broken
- Allow install as user behavior applications
- Added test mode that does everything except upload and remove the temp files