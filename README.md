# posh-winget

posh-winget is a PowerShell module for managing applications to be installed with winget.

As of 2021.11, winget does not allow you to specify installer options when importing in a configuration file. posh-winget solves it.

posh-winget will install only those applications listed in the configuration file that are not already installed. This makes it easy to manage applications in multiple environments.

posh-winget is a module until "winget import" supports the installer option. I am hoping the official version will support it soon.

# Install

Install it from the [PowerShell Gallery](https://www.powershellgallery.com/packages/posh-winget) as follows

```powershell
Install-Module posh-winget
```



# Configuration file

For example, create a YAML file such as winget.yml, and write the following

```yml
- id: Git.Git
- id: Microsoft.VisualStudioCode
  packageParameters: >-
    /VERYSILENT
    /NORESTART
    /MERGETASKS=!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath
```

You can specify any installer options in packageParameters.

# Import Application

Specify the configuration file and execute as follows

```powershell
Invoke-WingetImport winget.yml
```