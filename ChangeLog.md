# 0.7.2
- Fix for the spelling of memory in the GUI
- Update process for ECNO to copy over detection script when it runs the update

# 0.7.1
- Bug fix for method not found in updating client app

# 0.7.0

- Moved some GUI functions from being directly in the GUI cmdlet to calling an API endpoint in PSU
- Added cmdlet to help with the application versions
- Added support for default client using PSU variable AppFactoryDefaultClientGUID
- Added requirement rule for memory and HDD
- Added requirement rule for memory and HDD to GUI
- Fix for info and privacy images not displaying in application list
- Added ability to run client in test mode that just checks and downloads files does not upload
- Added ability to run client with a specific app guid
- Added ability to run client with a force flag to update exisitng applications
- Fix for version field and default value
- Update Close App Logic for 4.1
- Update Service UI logic for 4.1
- Update Run as User Logic for 4.1
- Created cmdlet to update the app configs for 4.1 to remove service UI


# 0.6.3

- Added description field for the client UI
- Updated the wording for Available for enrolled devices:
- Changed order between Required and Available

# 0.6.2

- Moved the remove to the finally function instead of in the try so that it still removes in error

# 0.6.1

- Additional logic to prevent removing the wrong application on error

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
- Added functionality to allow to send email for the applications that were processed in the last x days. Does require app registration with correct permissions
- Additional bug fixes found in migration to production
- Hid output from azcopy and downloads from progress for cleaner console output