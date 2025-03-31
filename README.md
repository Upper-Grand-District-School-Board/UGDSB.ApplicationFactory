# NOTE
This is an early version of these functions, and still has some additional commenting and documentation to take care of. There are is still continued work on the process and scripts.

# Introduction 
These scripts are designed in two parts. The first part is for a central piece where it can automate packaging applications and keeping them up to date. It can use the PowerShell Evergreen Module (https://stealthpuppy.com/evergreen/), WinGet Repository, Local Storage, and an Azure Storage Container. It then will use the configuration files that are part of the scripts to generate the files to store in an Azure Storage Repository. The other side of the scripts are designed to be run, access the packaged files that are in the Azure Storage Repository and then generate intune packages in their own intune enviroment. It uses the PSADT version 4 for the application installers that are built.

# Credit Where Credit is Due
These scripts started from the Intune App Factory Project (https://msendpointmgr.com/intune-app-factory/) and then modified from using a single tenant pipeline to a central/edge set of scripts. Each of these sets of scripts could then be adapted to a pipeline in the future if needed. Other modifications of the base idea was also adding in the ability to use WIM files for large application installs. 