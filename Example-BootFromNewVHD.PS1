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
        This script is used to deploy a VHD(X) file to enable boot from VHD in 
        physical machine. The machine will restart in 30 seconds, and automatic 
        logon on first time. 
        
        It depends on the script "Deploy-VHD.ps1". It can be considered as 
        sample script of the "Deploy-VHD.ps1".

   .PARAMETER NewVHDPath
        The name and path of the Virtual Hard Disk from which is boot. 

   .PARAMETER TestMode
        Boot entry will not be added and restart will not happen. 

    .DESCRIPTION
        The script deploys the VHD(X) file to the target path and enable boot
        from VHD function in physical machine. 

        Auto-restart can be enabled to restart the machine in 30 seconds.         


    .EXAMPLE
        .\BootFromNewVHD.ps1 -NewVHDPath C:\VHDBoot\WinServer2016.VHDX -TestMode 

        This command will edit new VHD file WinServer2016.VHDX in folder 
        C:\VHDBoot, and enable boot from VHD. 

    .OUTPUTS
        System.IO.FileInfo
  #>




[CmdletBinding(DefaultParametersetName="NewNativeBoot")]
Param(
    [Parameter(Mandatory=$True)]
    [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
    [string]$NewVHDPath,

    [Parameter(Mandatory=$False)]
    [switch]$TestMode
    )



$parameters = @{
    
    EnableNativeBoot = $True
    EnableAutoLogon  = $True
    VHDPath          = $NewVHDPath
    ChinaTime        = $True
    TestMode         = $True
    Restart          = $True
}



If ($TestMode)
{
    $parameters.Remove('Restart')

}
Else
{
    $parameters.Remove('TestMode')
}

.\Deploy-VHD.PS1 @parameters