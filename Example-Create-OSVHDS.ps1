
# 
# Copyright 2017- Wei Luo
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of this software and associated documentation files (the "Software"), to deal 
# in the Software without restriction, including without limitation the rights 
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
# SOFTWARE.
#
#
# SCRIPT_VERSION: 1.0.100.Main.20170218.1818.0.Release
#


<#
    .NOTES
        THE SAMPLE SOURCE CODE IS PROVIDED "AS IS", WITH NO WARRANTIES.
        THE SAMPLE SOURCE CODE IS UNDER THE MIT LICENSE.
        Developed by Wei Luo.
    
    .SYNOPSIS
        This script is used to create multiple Windows Server/Desktop OS VHD(X) 
        at one running time from the source ISO. Software update packages will 
        be applied if provided.

        It depends on the script "Deploy-VHD.ps1". It can be considered as 
        sample script of "Deploy-VHD.ps1".

   .PARAMETER NewVHDPath
        The name and path of the Virtual Hard Disk from which is boot. 

   .PARAMETER TestMode
        Boot entry will not be added and restart will not happen. 

    .DESCRIPTION
        The script will create multiple VHD(X) files with different 
        configurations and apply updates if provided.         


    .EXAMPLE
        .\Create-OSVHDs.ps1 -ServerISO C:\ISO\WinServer2016.ISO -PackagePath C:\Packages 

        This command will create DataCenter and DataCenter Core edition VHD(X) 
        files.

    .EXAMPLE
        .\Create-OSVHDs.ps1 -ClientISO C:\ISO\Windows10.ISO -PackagePath C:\Packages -Edition Professional

        This command will create Prefessional edition Windows 10 VHD(X) 
        files.

    .EXAMPLE
        .\Create-OSVHDs.ps1 -ServerISO C:\ISO\WinServer2016.ISO -ClientISO C:\ISO\Windows10.ISO -Pacages C:\Packages

        This command will create both Windows Server (DataCenter and Datacenter 
        Core) and Windows 10 VHD(X) (Enterprise) files. 

    .OUTPUTS
        System.IO.FileInfo

  #>

[CmdletBinding(DefaultParametersetName="EditVHD")]
Param(
    [Parameter(Mandatory=$False)]
    [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
    [string]$ServerISO,

    [Parameter(Mandatory=$False)]
    [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
    [string]$ClientISO,

    [Parameter(Mandatory=$False)]
    [ValidateScript({Test-Path $_})]
    [string]$PackagePath,

    [Parameter(Mandatory=$False)]
    [ValidateSet("Enterprise", "Ultimate", "Professional")]     
    [string]$Edition
    )


$registerOwner = 'User'
$registerOrganization = 'Organization'



If($serverISO)
{

    if($PackagePath)
    {
        #DataCenter Edition
        Deploy-VHD.PS1 -CreateVHDTemplate -SourcePath $ServerISO -VHDPath .\ -DisableHyperV -RegisteredOwner $registerOwner -RegisteredOrganization $registerOrganization -Package $PackagePath -Verbose
        Deploy-VHD.PS1 -CreateVHDTemplate -SourcePath $ServerISO -VHDPath .\ -DisableHyperV -MBRPartition -RegisteredOwner $registerOwner -RegisteredOrganization $registerOrganization -Package $PackagePath -Verbose
        Deploy-VHD.PS1 -CreateVHDTemplate -SourcePath $ServerISO -VHDPath .\ -RegisteredOwner $registerOwner -RegisteredOrganization $registerOrganization -Package $PackagePath -Verbose

        #DataCenter Core Edition
        Deploy-VHD.PS1 -CreateVHDTemplate -SourcePath $ServerISO -VHDPath .\ -DisableHyperV -Edition ServerDataCenterCore -RegisteredOwner $registerOwner -RegisteredOrganization $registerOrganization -Package $PackagePath -Verbose
        Deploy-VHD.PS1 -CreateVHDTemplate -SourcePath $ServerISO -VHDPath .\ -DisableHyperV -Edition ServerDataCenterCore -MBRPartition -RegisteredOwner $registerOwner -RegisteredOrganization $registerOrganization -Package $PackagePath -Verbose
        Deploy-VHD.PS1 -CreateVHDTemplate -SourcePath $ServerISO -VHDPath .\ -Edition ServerDataCenterCore -RegisteredOwner $registerOwner -RegisteredOrganization $registerOrganization -Package $PackagePath -Verbose
    }
    else
    {
        #DataCenter Edition
        Deploy-VHD.PS1 -CreateVHDTemplate -SourcePath $ServerISO -VHDPath .\ -DisableHyperV -RegisteredOwner $registerOwner -RegisteredOrganization $registerOrganization -Verbose
        Deploy-VHD.PS1 -CreateVHDTemplate -SourcePath $ServerISO -VHDPath .\ -DisableHyperV -MBRPartition -RegisteredOwner $registerOwner -RegisteredOrganization $registerOrganization -Verbose
        Deploy-VHD.PS1 -CreateVHDTemplate -SourcePath $ServerISO -VHDPath .\ -RegisteredOwner $registerOwner -RegisteredOrganization $registerOrganization -Verbose

        #DataCenter Core Edition
        Deploy-VHD.PS1 -CreateVHDTemplate -SourcePath $ServerISO -VHDPath .\ -DisableHyperV -Edition ServerDataCenterCore -RegisteredOwner $registerOwner -RegisteredOrganization $registerOrganization -Verbose
        Deploy-VHD.PS1 -CreateVHDTemplate -SourcePath $ServerISO -VHDPath .\ -DisableHyperV -Edition ServerDataCenterCore -MBRPartition -RegisteredOwner $registerOwner -RegisteredOrganization $registerOrganization -Verbose
        Deploy-VHD.PS1 -CreateVHDTemplate -SourcePath $ServerISO -VHDPath .\ -Edition ServerDataCenterCore -RegisteredOwner $registerOwner -RegisteredOrganization $registerOrganization -Verbose
    }
}


If($ClientISO)
{
If(!$Edition)
{
    $Edition = 'Enterprise'
    
}
    if($PackagePath)
    {
        Deploy-VHD.PS1 -CreateVHDTemplate -SourcePath $ClientISO -VHDPath .\ -DisableHyperV -RegisteredOwner $registerOwner -RegisteredOrganization $registerOrganization -Edition $Edition -Package $PackagePath -Verbose
        Deploy-VHD.PS1 -CreateVHDTemplate -SourcePath $ClientISO -VHDPath .\ -DisableHyperV -MBRPartition -RegisteredOwner $registerOwner -RegisteredOrganization $registerOrganization -Edition $Edition -Package $PackagePath -Verbose
    }
    else
    {
        Deploy-VHD.PS1 -CreateVHDTemplate -SourcePath $ClientISO -VHDPath .\ -DisableHyperV -RegisteredOwner $registerOwner -RegisteredOrganization $registerOrganization -Edition $Edition -Verbose
        Deploy-VHD.PS1 -CreateVHDTemplate -SourcePath $ClientISO -VHDPath .\ -DisableHyperV -MBRPartition -RegisteredOwner $registerOwner -RegisteredOrganization $registerOrganization -Edition $Edition  -Verbose
    }
}



