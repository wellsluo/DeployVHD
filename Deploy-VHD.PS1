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
# SCRIPT_VERSION: 2.0.102.Main.20180418.2137.0.RC
#


<#
    .NOTES
        THE SAMPLE SOURCE CODE IS PROVIDED "AS IS", WITH NO WARRANTIES.
        THE SAMPLE SOURCE CODE IS UNDER THE MIT LICENSE.
        Developed by Wei Luo.
    
    .SYNOPSIS
        Creates a bootable VHD(X) based on Windows Server/Cllient installation 
        media image (ISO/WIM).

    .DESCRIPTION
        Creates a bootable VHD(X) based on Windows OS installation media image 
        (ISO/WIM). 
        
        Script to:
            1. Generate VHDX file from Windows Server ISO/WIM file.
            2. Customize settings with Unattend.xml file and apply to VHDX 
               file. 
            3. Enable NativeBoot
            4. Enable AutoLogon. Enabled by default for Windows Desktop.
            5. Create MBR partition of VHDX
            6. Hyper-V role and management tools are installed in VHD(X) 
               by default for Windows Server. 

               Note: this feature needs the Dism servicing version is same or 
                    higherr thn the target OS. Which means it doesn't support 
                    this feature in Windows Server 2012 R2 to generate Windows 
                    Server 2016 VHD(X) file with Hyper-V role. 

        Script can be run at:
            Windows Server 2016
            Windows Server 2012 R2 (create Windows Server 2012 R2 image only)
            Windows 10 x64

        The following OS image supported:
            Windows Server 2016
            Windows Server 2012 R2
            *Windows 10  x64
            *Windows 8.1 x64
            *Windows 8   x64
            *windows 7   x64 (MBR partition only for virtual machine)
            
   .PARAMETER VHDPath
        The name and path of the Virtual Hard Disk to create or edit. The 
        parameter is must have when creating, editing, copying VHD(X) file, 
        and should be the file name with parent path.

        When creating the VHD(X) file as template (with "CreateVHDTemplate" 
        switch), it should be the parnet path, not the file name. Omitting 
        this parameter will create the VHD(X) in the current directory, and 
        will automatically name the file in the following format:

        SourcePath.[Hyper-V].VHDSize.VHDPartitionStyle.VHDFormat

    .PARAMETER SourcePath
        The complete path to the WIM or ISO file that will be converted to a 
        Virtual Hard Disk. The ISO file must be valid Windows installation 
        media to be recognized successfully. And the product type of ISO file 
        will be checked. 

            "WinNT" for Windwos Desktop.
            "ServerNT" for Windows Server.

    .PARAMETER CreateVHDTemplate
        Set the VHD(X) file as template file. Source image file name will be 
        used to generate template VHD(X) file name, with Hyper-V features, 
        partition type and disk size. 

    .PARAMETER DisableUnattend
        Unattend.xml file will not be insert to the VHD(X) file. Used when 
        "CreateVHDTemplate" is enabled.

    .PARAMETER Edition
        The name or image index of the image to apply from the WIM. Detault 
        value is "ServerDatacenter" for Server OS, "Enterprise" for client OS.

    .PARAMETER IsDesktop
        If the OS is Windows Desktop, enable this switch to do:
        //- Enable "AutoLogon" to enable local administrator account.
        - Disable Hyper-V feature installation.
        - Set Computer Name to default computer name when using "CreateVHDTemplate" 
          switch. 

    .PARAMETER SourceVHD
        The complete path to the VHD(X) template file that will be copied to a 
        Virtual Hard Disk. Used only in "Copy" mode.
        
    .PARAMETER VHDSize
        The size of the Virtual Hard Disk to create. Size range is 15GB-64TB. 
        The default value is 100GB.

    .PARAMETER VHDFormat
        Specifies whether to create a VHD or VHDX formatted Virtual Hard Disk.
        The default is VHD.

    .PARAMETER ComputerName
        Unattend setting. Set the computer name for the system inside VHD(X) file.
        If this parameter is not provided, the local computer name will be used. 
        This is typical sceanrio when creating a new VHD(X) file for local 
        machine to enable "boot from VHD". 

    .PARAMETER LocalAdminAccount
        Unattend setting. Set the additional local admin account for Windows 
        Desktop (with "IsDesktop" switch).

        It is ignored with Windows Server OS.

    .PARAMETER AdminPassword
        Unattend setting. 
        1. Set the default local administrator account password.
        2. Set the additional local admin account password  for Windows Desktop 
           (with "IsDesktop" switch).

    .PARAMETER EnableAutoLogon
        Unattend setting. Enable "AutoLogon" feature in Unattend.xml.

    .PARAMETER AutoLogonCount
        Unattend setting. If "AutoLogon" feature is enabled, then set the autlogon 
        count in Unattend.xml. Default value is 1.

    .PARAMETER DisableHyperV
        Setting for create new VHD(X) file from ISO.  By default, Hyper-V role 
        and management tools will be installed in to VHD(X) file. By using this swith, 
        Hyper-V role will not be installed to VHD(X) file. 

    .PARAMETER MBRPartition
        Create the MBR partition when creating VHD(X) file. By default, GPT partition 
        will be created.

    .PARAMETER Driver
        Full path to driver(s) (.inf files) to install to the OS inside the VHD(x).
        
    .PARAMETER Package
        Install specified Windows Package(s). Accepts path to either a directory 
        or individual CAB or MSU file.        

    .PARAMETER EnableNativeBoot
        Set the BCD entry for the VHD(X) file in local host. VHDPath cannot be 
        network path.

    .PARAMETER Restart
        Restart local host in 30 seconds. Must work with "-EnableNativeBoot".
        
    .EXAMPLE
        .\Deploy-VHD.ps1 -SourcePath D:\ISO\Win2016.iso -CreateVHDTemplate

        This command will create a dynamically-expanding 100GB VHDX file as 
        template, containing the Windows Server 2016 Datacenter SKU from image 
        file D:\ISO\Win2016.iso. The template file will be named as 
        "WinServer2016.Hyper-V.100GB.GUID.VHDX".  

        Unattend.xml will be applied with default settings:
            Computer Name:  Random name on first booting
            AutoLogon:      Disabled
            RemoteDesktop:  Enabled
            Firewall:       Opened


    .EXAMPLE
        .\Deploy-VHD.ps1 -VHDPath .\WinServer2016.VHDX -SourcePath 
        D:\WIM\install.wim 

        This command will create a 100GB dynamically expanding VHDX in the 
        current folder.

        The VHDX will be based on the Datacenter edition from 
        D:\WIM\install.wim, and will be named WinServer2016.VHDX.

        Unattend.xml will be applied with default settings:
            Computer Name:  Same as host
            AutoLogon:      Disabled
            RemoteDesktop:  Enabled
            Firewall:       Opened

    .EXAMPLE
        .\Deploy-VHD.ps1 -VHDPath .\WinServer2016.VHDX -SourcePath D:\ISO\Win2016.iso 

        This command will create a dynamically-expanding 100GB VHDX containing 
        the Windows Server 2016 Datacenter SKU, and will be named as 
        WinServer2016.vhdx.
        
        Unattend.xml will be applied with default settings:
            Computer Name:  Same as host
            AutoLogon: Disabled
            RemoteDesktop: Enabled
            Firewall: Opened

    .EXAMPLE
        .\Deploy-VHD.ps1 -VHDPath .\WinServer2016.VHDX -SourceVHD D:\VHD\Win2016-Template.vhdx 

        This command will copy VHDX file D:\VHD\Win2016-Template.vhdx as 
        WinServer2016.VHDX.
        
        Unattend.xml will be applied with default settings:
            Computer Name:  Same as host
            AutoLogon:      Disabled
            RemoteDesktop:  Enabled
            Firewall:       Opened

    .EXAMPLE
        .\Deploy-VHD.ps1 -VHDPath .\WinServer2016.VHDX  

        This command will edit WinServer2016.VHDX directly.

        Unattend.xml will be applied with default settings:
            Computer Name:  Same as host
            AutoLogon:      Disabled
            RemoteDesktop:  Enabled
            Firewall:       Opened

    .EXAMPLE
        .\Deploy-VHD.ps1 -VHDPath .\WinServer2016.VHDX  -ComputerName Test-01 -AutoLogon

        This command will edit WinServer2016.VHDX directly, set the computer 
        name to "Test-01".

        Unattend.xml will be applied with following settings:
            Computer Name:  Test-01
            AutoLogon:      Enabled
            RemoteDesktop:  Enabled
            Firewall:       Opened

    .EXAMPLE
        .\Deploy-VHD.ps1 -VHDPath WinServer2016.VHDX  -EnableNativeBoot -Restart

        This command will edit WinServer2016.VHDX directly, and enable boot from 
        VHD.

        Unattend.xml will be applied with default settings:
            Computer Name:  Same as host
            AutoLogon:      Disabled
            RemoteDesktop:  Enabled
            Firewall:       Opened

        System restarts in 30 seconds. 

    .LINK 
    https://github.com/wellsluo/DeployVHD

  #>



[CmdletBinding(DefaultParametersetName="Info")]
Param(

    [Parameter(Mandatory=$False,ParameterSetName='Info')]
    [switch]$GetVersion,

    [Parameter(Mandatory=$False,ParameterSetName='Info')]
    [switch]$GetUsage,

    [Parameter(Mandatory=$True,ParameterSetName='EditVHD')]
    [Parameter(Mandatory=$True,ParameterSetName='NewVHD')]
    [Parameter(Mandatory=$False, ParameterSetName='NewVHDTemplate')]
    [Parameter(Mandatory=$True,ParameterSetName='CopyVHD')]
    [string]$VHDPath=$PSScriptRoot,

    [Parameter(Mandatory=$True, ParameterSetName='NewVHD')]
    [Parameter(Mandatory=$True, ParameterSetName='NewVHDTemplate')]
    [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
    [string]$SourcePath,

    [Parameter(Mandatory=$True, ParameterSetName='NewVHDTemplate')]
    [switch]$CreateVHDTemplate,
        
    [Parameter(Mandatory=$false, ParameterSetName='NewVHDTemplate')]
    [switch]$DisableUnattend,

    [Parameter(Mandatory=$False, ParameterSetName='NewVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='EditVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='CopyVHD')]
    [Parameter(Mandatory=$False, ParameterSetName='NewVHDTemplate')]
    [switch]$IsDesktop,

    [Parameter(Mandatory=$False, ParameterSetName='NewVHD')]
    [Parameter(Mandatory=$False, ParameterSetName='NewVHDTemplate')]
    [ValidateSet("ServerDataCenter","ServerDataCenterCore", "ServerDataCenterNano", `
                 "ServerStandard", "ServerStandardCore", "ServerStandardNano",`
                 "Enterprise", "Professional","Ultimate")] 
    [string]$Edition="ServerDataCenter",

    [Parameter(Mandatory=$False, ParameterSetName='NewVHD')]
    [Parameter(Mandatory=$False, ParameterSetName='NewVHDTemplate')]
    [ValidateNotNullOrEmpty()]
    [ValidateRange(15GB, 64TB)]
    [UInt64]$VHDSize=100GB,

    [Parameter(Mandatory=$False, ParameterSetName='NewVHD')]
    [Parameter(Mandatory=$False, ParameterSetName='NewVHDTemplate')]
    [ValidateSet("VHDX","VHD")] 
    [string]$VHDFormat="VHDX",

    [Parameter(Mandatory=$False, ParameterSetName='NewVHD')]
    [Parameter(Mandatory=$False, ParameterSetName='NewVHDTemplate')]
    [Alias("MBR")]
    [switch]$MBRPartition,

    [Parameter(Mandatory=$False, ParameterSetName='NewVHD')]
    [Parameter(Mandatory=$False, ParameterSetName='NewVHDTemplate')]
    [switch]$DisableHyperV,

    [Parameter(Mandatory=$True, ParameterSetName='CopyVHD')]
    [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
    [string]$SourceVHD,

    [Parameter(Mandatory=$False, ParameterSetName='EditVHD')]
    [switch]$Edit,

    [Parameter(Mandatory=$False,ParameterSetName='NewVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='EditVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='CopyVHD')]
    #$env:COMPUTERNAME  only gives the computer name up to 15 characters (NetBIOS name limit).
    #So stop to use it and use function to get local host name if $ComputerName is not provided from parameter.
    #[string]$ComputerName=$env:COMPUTERNAME,    
    [string]$ComputerName,

    [Parameter(Mandatory=$False,ParameterSetName='NewVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='EditVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='CopyVHD')]
    [string]$LocalAdminAccount="Ladmin",

    [Parameter(Mandatory=$False, ParameterSetName='NewVHD')] 
    [Parameter(Mandatory=$False,ParameterSetName='EditVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='CopyVHD')]
    [string]$AdminPassword='Local@123',
    
    [Parameter(Mandatory=$False,ParameterSetName='NewVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='EditVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='CopyVHD')]
    [switch]$EnableAutoLogon,

    [Parameter(Mandatory=$False,ParameterSetName='NewVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='EditVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='CopyVHD')]
    [UInt32]$AutoLogonCount=1,
    
    [Parameter(Mandatory=$False,ParameterSetName='NewVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='EditVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='CopyVHD')]
    [Parameter(Mandatory=$False, ParameterSetName='NewVHDTemplate')]
    [string]$RegisteredOwner="User",

    [Parameter(Mandatory=$False,ParameterSetName='NewVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='EditVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='CopyVHD')]
    [Parameter(Mandatory=$False, ParameterSetName='NewVHDTemplate')]
    [string]$RegisteredOrganization="Organization",

    [Parameter(Mandatory=$False,ParameterSetName='NewVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='EditVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='CopyVHD')]
    [switch]$ChinaTime,

    [Parameter(Mandatory=$False,ParameterSetName='NewVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='EditVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='CopyVHD')]
    [Parameter(Mandatory=$False, ParameterSetName='NewVHDTemplate')]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string[]]$Driver,

    [Parameter(Mandatory=$False,ParameterSetName='NewVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='EditVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='CopyVHD')]
    [Parameter(Mandatory=$False, ParameterSetName='NewVHDTemplate')]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string[]]$Package,

    [Parameter(Mandatory=$False,ParameterSetName='NewVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='EditVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='CopyVHD')]
    [switch]$EnableNativeBoot,

    [Parameter(Mandatory=$False,ParameterSetName='NewVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='EditVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='CopyVHD')]
    [switch]$Restart,

    [Parameter(Mandatory=$False,ParameterSetName='NewVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='EditVHD')]
    [Parameter(Mandatory=$False,ParameterSetName='CopyVHD')]
    [switch]$TestMode
   )

##########################################################################################

#write script message
Function Write-Message 
{  
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $False, ValueFromPipeline = $false)]
        [ValidateSet("Info","Warn", "Err", "Trace", "Debug", "TEXT")]
        #[ValidateNotNullOrEmpty()]
        [string]$category='INFO',

        [Parameter(Mandatory = $False, ValueFromPipeline = $false)]
        [string]
        [ValidateNotNullOrEmpty()]
        $text
    )

    $CurrentTime = Get-Date -UFormat '%H:%M:%S'   

    Switch ($category.ToUpper())
    {
        'INFO'
        {
            If ( $text )
            {
                $text = "$CurrentTime INFO   : $text" 
                Write-Output $text #-ForegroundColor White
            }
            Else
            {
                Write-Output ""
            }
        }

        'TEXT'
        {
            Write-Output $text 
        }

        'WARN'
        {
            $text = "$CurrentTime WARN   : $text"
            Write-Warning $text #-ForegroundColor Yellow
        }

        'ERR'
        {
            $text = "$CurrentTime ERROR  : $text"
            #Write-Host $text -ForegroundColor Red
            Write-Error $text
        }

        'TRACE'
        {
            Write-Verbose "$CurrentTime TRACE  : $text"
        }

        'DEBUG'
        {
            Write-Debug "$CurrentTime DEBUG  : $text"
        }        

        Default
        {
            Write-Output ""
        }
    }
}


#Start PowerShell Console in elevated mode.
Function Start-PSConsoleAsAdmin
{
	Start-Process powershell.exe "-NoExit -ExecutionPolicy Bypass" -Verb RunAs 
}

#check if PowerShell console is running at Elevated mode.
Function Test-PSConsoleRunAsAdmin
{
   return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}


#Base64 encode
function ConvertTo-Base64 ($plainString) {
    $encodedString = [System.Convert]::ToBase64String([System.Text.Encoding]::UNICODE.GetBytes($plainString))
    return $encodedString
}
<#
#Base64 decode
function ConvertFrom-Base64($encodedString) {
	$decodedString =  [System.Text.Encoding]::UNICODE.GetString([System.Convert]::FromBase64String($encodedString))
	return $decodedString ;
}
#>

#Get local host name
Function Get-LocalHostName
{
    return [System.Net.Dns]::GetHostName()

}


#process the information of Unattend.xml file.
function ProcessUnattend  
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkSpaceName,

        [Parameter(Mandatory = $True, ValueFromPipeline = $false)]
        [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
        [string]$VHDPath,

        [Parameter(Mandatory = $True, ValueFromPipeline = $false)]
        [string]$UnattendTemplate,

        [Parameter(Mandatory = $True, ValueFromPipeline = $false)]
        [string]$EnableAutoLogon,

        [Parameter(Mandatory = $True, ValueFromPipeline = $false)]
        [string]$AutologonCount,

        [Parameter(Mandatory = $True, ValueFromPipeline = $false)]
        [string]$LocalAdminAccount,                       

        [Parameter(Mandatory = $True, ValueFromPipeline = $false)]
        [string]$AdminPassword,  

        [Parameter(Mandatory = $True, ValueFromPipeline = $false)]
        [string]$ComputerName,

        [Parameter(Mandatory = $True, ValueFromPipeline = $false)]
        [string]$RegisteredOrganization,  

        [Parameter(Mandatory = $True, ValueFromPipeline = $false)]
        [string]$RegisteredOwner,   

        [Parameter(Mandatory = $True, ValueFromPipeline = $false)]
        [string]$TimeZone,

        [Parameter(Mandatory = $False, ValueFromPipeline = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string[]]$Driver,

        [Parameter(Mandatory = $False, ValueFromPipeline = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string[]]$Package                           
                            
    )

    ###############################################################################################
    # prepare unattend file content. 

    Write-Message "Debug"  ("Enter Function: ProcessUnattend")

    #Image Mount directory
    Set-Variable -Name MountSubFolder -Value "MountDir" -Option Constant

    #Unattend.xml file put path
    Set-Variable -Name UnattendWindowsFolder -Value ("Windows\panther") -Option Constant
    Set-Variable -Name UnattendFileName -Value "Unattend.xml" -Option Constant

    #unattend keyword
    Set-Variable -Name AutoLogonKeyword -Value "%AUTOLOGON%" -Option Constant
    Set-Variable -Name AutoLogonCountKeyword -Value "%LOGONCOUNT%" -Option Constant
    Set-Variable -Name ComputerNameKeyword -Value "%COMPUTERNAME%" -Option Constant
    Set-Variable -Name RegisteredOwnerKeyword -Value "%REGISTEREDOWNER%" -Option Constant
    Set-Variable -Name RegisteredOrganizationKeyword -Value "%REGISTEREDORGANIZATION%" -Option Constant
    Set-Variable -Name TimeZoneKeyword -Value "%TIMEZONE%" -Option Constant
    
    #default administrator password keyword
    Set-Variable -Name AdminPasswordKeyword -Value "%ADMINPASSWORD%" -Option Constant
    #Client, additional local admin account name
    Set-Variable -Name LocalAdminAccountKeyword -Value "%LOCALADMIN%" -Option Constant
    #Autologon account/additional admin account (for Windows client) password
    Set-Variable -Name AccountPasswordKeyword -Value "%ACCOUNTPASSWORD%" -Option Constant
    

    #Create Unattendworkspace to support multiple instances
<#    
    try {
        $WorkSpaceName = New-Guid   #Only works in PowerShell version 5 and above.
    }
    catch {
        $WorkSpaceName = [Guid]::NewGuid().ToString() 
    }
    
#>    
    $UnattendWorkSpace = Join-Path $PSScriptRoot  $WorkSpaceName
    mkdir $UnattendWorkSpace  -Force  | Out-Null

    #Write trace information
    Write-Message "Trace"  ("VHD(X) name:                   $($VHDPath)")
    Write-Message "Trace"  ("Computer name:                 $($ComputerName)")
    Write-Message "Trace"  ("Unattend file target path:     $($UnattendWindowsFolder)")
    Write-Message "Trace"  ("Unattend template:             $($UnattendTemplate)")
    Write-Message "Trace"  ("Enable auto logon:             $($EnableAutoLogon.ToString())")
    Write-Message "Trace"  ("Autologon count:               $($AutologonCount)")
    Write-Message "Trace"  ("Additional local admin account: $($LocalAdminAccount)")
    Write-Message "Trace"  ("Registered organization:       $($RegisteredOrganization)")
    Write-Message "Trace"  ("Registered owner:              $($RegisteredOwner)")
    Write-Message "Trace"  ("Time Zone:                     $($TimeZone)")

    #Generate unattend.xml file and put the computer name
    $UnattendFile = Join-Path $UnattendWorkSpace $UnattendFileName
    Write-Message "Trace"  ("Unattend file:                 $($UnattendFile)")
    Write-Message "Info" ("Generating the $($UnattendFileName) file ...")

    #remove the old one if existing.
    Remove-Item -Path $UnattendFile  -Force -ErrorAction SilentlyContinue
    
    #Check if the unattend template existes
    If(!(Test-Path $UnattendTemplate))
    {
        Write-Message "ERR" "Error: $($UnattendTemplate) file doesn't exist."
        Exit -1
    }


    $UnattendContent = Get-Content -Path $UnattendTemplate
    #write the computer name to Unattend file.
    $UnattendContent = Foreach-Object {$UnattendContent -replace $ComputerNameKeyword, $ComputerName}
    #write AutoLogon option
    $UnattendContent = Foreach-Object {$UnattendContent -replace $AutoLogonKeyword, $($EnableAutoLogon.ToString().ToLower())} # $AutoLogonValue}
    $UnattendContent = Foreach-Object {$UnattendContent -replace $AutoLogonCountKeyword, $AutoLogonCount}
    #Write account information
    $UnattendContent = Foreach-Object {$UnattendContent -replace $LocalAdminAccountKeyword, $LocalAdminAccount}
    #write registration  
    $UnattendContent = Foreach-Object {$UnattendContent -replace $RegisteredOwnerKeyword, $RegisteredOwner}
    $UnattendContent = Foreach-Object {$UnattendContent -replace $RegisteredOrganizationKeyword, $RegisteredOrganization}
    #time zone
    $UnattendContent = Foreach-Object {$UnattendContent -replace $TimeZoneKeyword, $TimeZone}
	#Password
    $encryptedAdminPwd = ConvertTo-Base64("$($AdminPassword)Password")
    $encryptedDefaultAdminAccountPwd = ConvertTo-Base64("$($AdminPassword)AdministratorPassword")
    $UnattendContent = Foreach-Object {$UnattendContent -replace $AdminPasswordKeyword, $encryptedDefaultAdminAccountPwd}
    $UnattendContent = Foreach-Object {$UnattendContent -replace $AccountPasswordKeyword, $encryptedAdminPwd}

    #Write Unattend.xml file
    Set-Content -Path $UnattendFile -Force -Value $UnattendContent

    Write-Message "Debug" "$($UnattendContent)"
    ###############################################################################################
    # Put unattend file. 
    #

    #Mount VHD file
    Write-Message "Info" ("Mount VHD file $($VHDPath) and put file $($UnattendFileName).")
    $MountFolder = Join-Path $UnattendWorkSpace $MountSubFolder
    If (Test-Path $MountFolder)
    {
        Write-Message "Trace"  ("Clean mount folder $($MountFolder).")
        Remove-Item ("$MountFolder\*") -Force -Recurse -ErrorAction Stop    #mount dir is not empty and cannot be removed
    }
    else
    {
        Write-Message "Trace"  ("Mount folder $($MountFolder) doesn't exist, create it.")
        mkdir $MountFolder  -Force  | Out-Null
    }

    Write-Message "Trace"  ("Mounting VHD $($VHDPath) to folder $($MountFolder) ...")
    Mount-WindowsImage -ImagePath $VHDPath -Index 1 -Path $MountFolder  | Out-Null 

    $UnattendFileTargetPath = Join-Path $MountFolder $UnattendWindowsFolder
    mkdir $UnattendFileTargetPath -force -ErrorAction SilentlyContinue  | Out-Null 
    copy-item $UnattendFile $UnattendFileTargetPath  -Force

    #add drivers
    if ( $Driver ) {

        Write-Message "Info" "Adding Drivers to the image..."

        $Driver | ForEach-Object -Process {

            Write-Message "Trace" "Driver path: $PSItem"
            $Dism = Add-WindowsDriver -Path $MountFolder -Recurse -Driver $PSItem
        }
    }

    #add .CAB or .MSU packages
    if ( $Package ) {
        Write-Message "Info" "Adding Windows Packages to the image..."
        $Package | ForEach-Object -Process {
            Write-Message "Trace" "Package path: $PSItem"
            $Dism = Add-WindowsPackage -Path $MountFolder -PackagePath $PSItem
        }
    }

    Write-Message "Trace"  ("Dismounting $($VHDPath) and commit change.")
    Dismount-WindowsImage -Path $MountFolder -Save  | Out-Null

    #clean up
    Start-Sleep 1
    #RD  $MountFolder -Force -Recurse | Out-Null
    #Del $UnattendFile -Force | Out-Null
    Remove-Item  $UnattendWorkSpace -Force -Recurse | Out-Null    
}


#get machine manufacturer and model from WMI
Function Get-MachineMM
{
    try 
    {
        $property = Get-WmiObject -Class Win32_ComputerSystem -ComputerName . -ErrorAction Stop `
                    |Select-Object -Property Manufacturer,Model
    }
    catch
    {
        Write-Message "Err" "$($Error[0])"
        $model = $null
    }

    return $property
}


Function IsVirtualMachine 
{
	Param
	(
		[Parameter(Mandatory=$False)]
		[string]$model
	)
	
	If (! $model)
	{
		$model = (Get-MachineMM).Model
	}
	
	$bVirtualMachine = $False
	If($model)
	{
		$bVirtualMachine = $model.ToUpper().Contains("VIRTUAL")
	}
	
	Return $bVirtualMachine
}

#Enable the boot from VHD feature
function EnableNativeBoot  
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $false)]
        [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
        [string]$VHDPath,

        [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
        [switch]$Restart,

        [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
        [switch]$TestMode   
    )

    #check if script is running at physical machine.
    $machineMM = Get-MachineMM
    if(IsVirtualMachine($machineMM.Model))
    {
        Write-Message "Warn" "Script is running at virtual machine, ignore native boot setting."
        Write-Message "Trace" "Machine manufacturer-model: $($machineMM.Manufacturer) - $($machineMM.Model)"
        return
    }
    
    #mount VHD as drive. The cmdlet "Mount-VHD" needs Hyper-V role, it cannot be used to anywhere. 
    #So it is deprecated since it needs Hyper-V to be installed. 

    # Convert-WindowsImage.PS1 create 3 paritions when creating new VHD:
    #
    #       Size Type
    #       ---- ----
    #     128 MB Reserved
    #     100 MB System
    #     99.78 GB Basic
    # Note: the size of "Basic" is assumed to be 100G.
    #
    # When mounting the VHD disk, the "System" partition may also be mounted and assgined drive letter. 
    # In this case, the "System" partition will be the first drive and "Basic" partition will be second drive.
    # Update the code to get only the "Basic" partition and get the drive letter. 

    $VHDDisk = (Mount-DiskImage -ImagePath $VHDPath -PassThru | Get-DiskImage | Get-Disk)
    $VHDWinPartition = Get-Partition -Disk $VHDDisk | Where-Object {$_.Type -eq "Basic"}
    $VHDMountDrive =  $VHDWinPartition.AccessPaths[0]
    Write-Message "Trace"  ("VHD(X) was mounted to drive $($VHDMountDrive).")

    #run BCDBoot to add the VHD to system boot ment
    $CommandNativeBoot = "BCDBOOT  $($VHDMountDrive)Windows"
    Write-Message "Trace" ("Running command: $($CommandNativeBoot) ...")
    If ($TestMode)
    {
        Write-Message "Trace"  "Running in Test Mode, BCDBoot will not run."
    }
    Else
    {
        Write-Message "Trace"  "Run BCDboot command to add boot entry..."
        Invoke-Expression -Command $CommandNativeBoot
    }
    

    if ($Restart)
    {
        Write-Message "Trace" ("System restart option was enabled. Computer will be restarted in 30 seconds...")

        If ($TestMode)
        {
            Write-Message "Trace"  "Running in Test Mode, system will not restart."

            Invoke-Expression -Command "BCDEdit"
        }
        Else
        {
            Write-Message "Trace"  "Not test mode, restart computer in 30 seconds..."
            #Show count down progress bar
            for ($i = $RestartTimeOut; $i -ge 0; $i-- )
            {
                $Counter = [decimal]::round(($i/$RestartTimeOut)*100)
                Write-Progress -activity "Restart counting down..." -status "$($i) second(s) to restart" -percentcomplete $Counter
                Start-Sleep 1
            }            
            Restart-Computer -Force
        }
    }
    else
    {
        #Dismount the VHD file
        If (! $TestMode)
        {
            Write-Message "Info" "Please restart the computer manually!"
        }
        Invoke-Expression -Command "BCDEdit"
    } 
    
    Write-Message "Trace"  "Dismount VHD drive."
    Dismount-DiskImage -ImagePath $VHDPath  

}


#Get Windows Image informtion 
<# return information like following:
ImageIndex       : 1
ImageName        : 
ImageDescription : 
ImageSize        : 8,124,366,848 bytes
Architecture     : x64
Hal              : 
Version          : 10.0.14300.1000
SPBuild          : 1000
SPLevel          : 0
EditionId        : Enterprise
InstallationType : Client
ProductType      : WinNT
ProductSuite     : Terminal Server
SystemRoot       : Windows
Languages        : en-US (Default)
#>
function Get-WindowsImageInfo 
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $false)]
        [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
        [string]$ImagePath,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]
        [UInt32]$ImageIndex
    )

    #get the image file extension to identify the type: ISO or WIM
    $imageFile = Get-Item $ImagePath
    $imageType = $imageFile.Extension

    switch -Wildcard ($imageType.ToUpper()) {
        ".ISO" 
        {  
            #Mount ISO. Get-Volume can get the voume object directly from Mount-DiskImage (mount ISO file, not VHD file).
            $mountISOVolume =  (Mount-DiskImage -ImagePath $ImagePath -PassThru | Get-Volume)
            $ISOMountDrive = $mountISOVolume.DriveLetter + ":"
            $imageWIMPath = Join-Path $ISOMountDrive "Sources\Install.WIM" 
        }

        ".WIM"
        {
            #doesn't need to mount the image
            $imageWIMPath = $ImagePath
        }

        ".VHD*"
        {
            #doesn't need to mount the image
            $imageWIMPath = $ImagePath
        }
<#
        ".VHDX"
        {
            #doesn't need to mount the image
            $imageWIMPath = $imagePath
        }
        
#>
        Default 
        {
            Write-Message "Err" "Unrecognized image type: $imageType"
            return $null
        }
    }

    try 
    {
        $images = Get-WindowsImage -ImagePath $imageWIMPath -ErrorAction Stop
        $imageAllIndex = @()
        foreach ($imageItem in $images) 
        {
            $imageAllIndex += $imageItem.ImageIndex
        }
        
        #if the ImageIndex is in the image, then select it.
        #if not, use the first one.
        if ($imageAllIndex -contains $ImageIndex) 
        {
            $ImageIndex = $ImageIndex
        }
        else {
            $ImageIndex = $images[0].ImageIndex
        }

        $imageInfo = Get-WindowsImage -ImagePath $imageWIMPath -Index $imageIndex

    }
    catch {
        Write-Message "Err" "$($Error[0])"
        $imageInfo = $null
    }
    finally 
    {
        #dismount the ISO if mounted.
        if($mountISOVolume)
        {
            Dismount-DiskImage -ImagePath $ImagePath
        }
    }

    return $imageInfo
}


#Get OS type from image
function Get-OSType ($imagePath) 
{
    $productType = "UNKNOWN"        #default return value

    #if the image doesn't exist, return default value.
    if (!(Test-Path $imagePath)) 
    {
        Write-Message "Err" "Cannot find the image: $($imagePath)"
        return $productType
    }
    
    #get image information and get the producty tpye.
    $imageInfo = Get-WindowsImageInfo  -ImagePath  $imagePath -ImageIndex 0
    if ($imageInfo) 
    {
        $productType = $imageInfo.ProductType
    }

    return $productType
}

#check if OS is client.
function IsDesktopOS ($OSType) {
    return ($OSType.Toupper() -eq "WINNT")
}

#check if OS is server.
function IsServerOS ($OSType) {
    
    return ($OSType.Toupper() -eq "SERVERNT")
}

#if the image is Windows image based on the OS type from function Get-OSType
function IsWindowsImage ($OSType) {

    if ($OSType -eq $null) {
        return $False
    }
    if (($OSType.ToUpper() -ne "SERVERNT") -and ($OSType.ToUpper() -ne "WINNT")) 
    {
        return $False
    }

    return $True
}


#stop script log
function Stop-ScriptLog ($isTranscripting) {
    if ($isTranscripting) 
    {
        Stop-Transcript | Out-Null
    }
}

##########################################################################################


##########################################################################################
# Main
##########################################################################################



#Declare constant 

Set-Variable -Name SCRIPT_VERSION -Value "2.0.102.Main.20180418.2137.0.RC" -Option Constant
Set-Variable -Name ScriptName -Value $MyInvocation.MyCommand.Name  -Option Constant

#unattend
Set-Variable -Name UnattendTemplate_AMD64_Server -Value $(Join-Path $PSScriptRoot "unattend_amd64_Server.xml") -Option Constant
Set-Variable -Name UnattendTemplate_AMD64_Client -Value $(Join-Path $PSScriptRoot "unattend_amd64_Client.xml") -Option Constant

#default vault in unattend
Set-Variable -Name DefaultComputerName -Value "*" -Option Constant  #random computer name
Set-Variable -Name DEFAULT_ADMIN_PASSWORD  -Value  "Local@123"

#default time zone value
Set-Variable -Name DEFAULT_TIME_ZONE -Value "Pacific Standard Time" -Option Constant
Set-Variable -Name CHINA_TIME_ZONE -Value "China Standard Time" -Option Constant

#restart timeout to 30 seconds when enable native boot and enable restart switch
Set-Variable -Name RestartTimeOut -Value 30 -Option Constant

#Log
Set-Variable -Name LogFileFolderName       -Value "LogFiles"    -Option Constant


#Generate workspace name
try 
{
    $WorkSpaceName = New-Guid   #Only works in PowerShell version 5 and above.
}
catch 
{
    $WorkSpaceName = [Guid]::NewGuid().ToString() 
}

#Enable transcripting as Log file
$isTranscripting = $False  #transcripting has not been started at the begining.

$LogFolder          = Join-Path $PSScriptRoot $LogFileFolderName
$LogFilePathCurrent = Join-Path $LogFolder "$($ScriptName.Split('.')[-2]).$(Get-Date -UFormat "%Y%m%d%H%M%S").$($WorkSpaceName).Log"


if (Test-Path $LogFolder) {
    #check the log file size, remove oldest one if currnt log size is larger than 3MB
}
else {
    mkdir $LogFolder -Force | Out-Null
}

# Start transcripting and set the indicator.  If it's already running, we'll get an exception and swallow it.
Try 
{
    Start-Transcript -Path $LogFilePathCurrent -Force -ErrorAction SilentlyContinue | Out-Null
    $isTranscripting = $true
} 
Catch 
{
    Write-Message "Trace" "Transcripting is already running."
    $isTranscripting = $false
}


# Banner text displayed during each run.
$banner = '='*80
$ScriptHeader    = @"
$banner
VHD(X) Deployment for Windows(R) Server 2016. Developed by Wei Luo

THE SAMPLE SOURCE CODE IS PROVIDED "AS IS", WITH NO WARRANTIES.
Version $SCRIPT_VERSION
$banner

"@

Write-Message "TEXT" $ScriptHeader

$StartTime= Get-Date -UFormat "%Y-%m-%d %H:%M:%S" #-Format yyyy-MM-dd/HH:MM:SS

Write-Message "Info" "Script $ScriptName starts at $StartTime. Version: $($SCRIPT_VERSION)"
$LocalHostName = Get-LocalHostName
Write-Message "Info" "Script is running at computer $($LocalHostName)."

# Check if PowerShell console is running at elevated mode.
If (!(Test-PSConsoleRunAsAdmin))
{
	Write-Message "Info" "Console is not running as Administrator, restrting it..."
    Start-PSConsoleAsAdmin
    Stop-ScriptLog $isTranscripting
	exit
}

Write-Message "Trace" "Workspace name: $($WorkSpaceName)"

##########################################################################################
#process parameters
#

#Computer name for Unattend. Set it as local host name if no value from parameter. 
If(! $ComputerName)
{
    $ComputerName = $LocalHostName
}

#Warning if enable Hyper-V feature or apply packages
if (($PSCmdlet.ParameterSetName -ne 'Info') -and ((! $DisableHyperV) -or ($Package)))
{
    Write-Message "Warn" "The feature to install Hyper-V role or apply packages need latest servicing command.`
                  Make sure same or higher version servicing command is using than source image file."    
}

#Time zone for unattend
$TimeZone = $DEFAULT_TIME_ZONE
if ($ChinaTime) {
    $TimeZone = $CHINA_TIME_ZONE    
}
Write-Message "Trace" "VHD(X) Time zone: $($TimeZone)"

#Get the partition style
$VHDPartitionStyle = 'GPT'
If ($MBRPartition)
{
    $VHDPartitionStyle = 'MBR'
}

# Check if VHD(X) file exists. 
$bVHDExisted = Test-Path $VHDPath
Write-Message "Trace" "$($VHDPath) existence: $($bVHDExisted.toString())"

#handle the parameter set
Switch -Wildcard($PSCmdlet.ParameterSetName)
{
    #Create new VHD from media (ISO, WIM) to use or as template .
    "NewVHD*"
    {
        If ($CreateVHDTemplate)
        {
            Write-Message "Info" "Creating virtual disk template..."
        }
        else {
            Write-Message "Info" "Creating new $($VHDFormat) file..."
        }

        #check the OS type and edition 
        Write-Message "Info" "Source file: $($SourcePath)"
        $imageInfo = Get-WindowsImageInfo -ImagePath $SourcePath -ImageIndex 0

        $OSType = $imageInfo.ProductType #Get-OSType($SourcePath)
        $bWindowsImage = IsWindowsImage($OSType)
        if (! $bWindowsImage) 
        {
            Write-Message "Err" "The source file is not valid Windows image file. Please check it."
            Stop-ScriptLog $isTranscripting
            Exit -1
        }

        #if not Server OS, then force swith IsDesktop and disable Hyper-V
        $IsDesktop = IsDesktopOS($OSType)
        if ($IsDesktop) 
        {
            Write-Message "Info" "Source file is Windows Desktop installation media."
            $DisableHyperV = $True

            #check if the Edition is correct.
            if (($Edition -ne "Enterprise") -and ($Edition -ne "Professional") -and ($Edition -ne "Ultimate")) 
            {
                $Edition = $imageInfo.EditionId
            }
        }
        else {
            Write-Message "Info" "Source file is Windows Server installation media."
        }

        #Check if the target path exists. If not, then create it.
        if (! $bVHDExisted) {
            mkdir  $VHDPath  -Force -ErrorAction SilentlyContinue | Out-Null
        }

        # Generate VHD(X) file name if CreateVHDTemplate is enabled.
        # Name convention: SourcePath.[Hyper-V].VHDSize.VHDPartitionStyle.VHDFormat
        If ($CreateVHDTemplate)
        {
            If ($DisableHyperV)
            {
                $VHDPath = Join-Path $VHDPath "$([io.path]::GetFileNameWithoutExtension($SourcePath)).$($Edition.ToUpper()).$($VHDSize/1GB)GB.$($VHDPartitionStyle).$($VHDFormat)"    
            }
            Else
            {
                $VHDPath = Join-Path $VHDPath "$([io.path]::GetFileNameWithoutExtension($SourcePath)).$($Edition.ToUpper()).Hyper-V.$($VHDSize/1GB)GB.$($VHDPartitionStyle).$($VHDFormat)"    
            }
        }

        If(Test-Path $VHDPath)
        {
            Write-Message "Err" "VHD(X) file $($VHDPath) already exists. Plesae rename the existed template file and try again.Script quits."
            Stop-ScriptLog $isTranscripting
            Exit -1
        }
        Write-Message "Info"  "Creating file $($VHDPath)..."
        
        #trace parameters
        Write-Message "Trace" "Target VHD(X) file:      $($VHDPath)"
        Write-Message "Trace" "Source image path:       $($SourcePath)"
        Write-Message "Trace" "VHD(X) partition type:   $($VHDPartitionStyle)"
        Write-Message "Trace" "VHD(X) Size:             $($VHDSize/1GB)GB"
        Write-Message "Trace" "VHD(X) Format:           $($VHDFormat)"
        Write-Message "Trace" "OS edition:              $($Edition)"
        Write-Message "Trace" "Disable Hyper-V feature: $($DisableHyperV.ToString())"

        [System.Collections.ArrayList] $Features = @(
                            "Microsoft-Hyper-V" 
                            "Microsoft-Hyper-V-Management-Clients"
                            "Microsoft-Hyper-V-Management-PowerShell"
                    ) 
        #To support Server core, cannot install management tools
        if ($Edition.ToUpper().Contains("CORE")) 
        {
            $Features.Remove("Microsoft-Hyper-V-Management-Clients")
        }

        # splatting
        $ConvertWindowsImageParam = @{  
            SourcePath          = $SourcePath  
            VHDPath             = $VHDPath
            RemoteDesktopEnable = $True  
            Passthru            = $True  
            Edition             = $Edition  #"ServerDataCenter"
            SizeBytes           = $VHDSize
            VHDPartitionStyle   = $VHDPartitionStyle 
            VHDFormat           = $VHDFormat
            ExpandOnNativeBoot  = $false
            Feature             = $Features 
        }                       
        if ($DisableHyperV)
        {
            $ConvertWindowsImageParam.Remove("Feature")
        }

        # Load (aka "dot-source"") the Function 
        $libraryFile = Join-Path $PSScriptRoot 'Convert-WindowsImage.ps1'
        .  $libraryFile

        # Create the VHD image 
        Write-Message "Info"  "Run Convert-WindowsImage to create new VHD(X) and apply OS image..."

        Try 
        {
            $vhd = Convert-WindowsImage @ConvertWindowsImageParam -ErrorAction Stop
        }
        Catch {
            Write-Message "Err" "Failed to create new VHD(X) file $($VHDPath)."
            Write-Message "Err" "$($Error[0])"

            Stop-ScriptLog $isTranscripting
            Exit -1
        }

        #Don't remove following code since the Dism error (in WS2012 R2) cannot be caught by Try/Catch
        If (!$vhd)
        {
            Write-Message "Err" "Failed to create new VHD(X) file $($VHDPath)."
            Stop-ScriptLog $isTranscripting
            Exit -1
        }

        If($CreateVHDTemplate)
        {
            Write-Message "Info" "VHD(X) template file $($VHDPath) was created."
            
            $ComputerName = $DefaultComputerName
            Write-Message "Trace" "Set computer name to random in unattend.xml file: $($ComputerName)."
        }
        else {
            Write-Message "Info" "VHD(X) file $($VHDPath) was created."
        }
        #then go to common tasks
    }

    #Use VHD(X) template to copy a new VHD(X)
    "CopyVHD"
    {
        If($bVHDExisted)
        {
            Write-Message "ERR" "VHD(X) file $($VHDPath) already exists. Please input a new name."
            Stop-ScriptLog $isTranscripting
            Exit -1
        }

        Write-Message "Trace"  "Source VHD(X): $($SourceVHD)"
        Write-Message "Info" "Copy VHD(X) file to $($VHDPath)..."

        $SourceVHDSizeMB = (Get-Item $SourceVHD).Length / 1MB
        Write-Message "Trace"  "Source VHD(X) file size: $($SourceVHDSizeMB) MB"

        Copy-Item -Path $($SourceVHD) -Destination $($VHDPath)
        
        #then go to common tasks
    }

    #Edit provided VHD(X) file 
    "EditVHD"
    {
        Write-Message "Trace"  "Script will edit current VHD(X) file $($VHDPath)."
        If(!$bVHDExisted)
        {
            Write-Message "ERR" "VHD(X) file $($VHDPath) doesn't exists."
            Stop-ScriptLog $isTranscripting
            Exit -1
        }
        #then go to common tasks
    }



    "Info"
    {
        Write-Message 'Trace' "Get script information. Parameter count: $($PSBoundParameters.Count)"
        if ($GetVersion) {
            Write-Message "Info" "Script version: $($SCRIPT_VERSION)"
        }

        if ($GetUsage -or $VerbosePreference) {
            Invoke-Command  {Help $PSCommandPath -Detailed}
        }

        if($PSBoundParameters.Count -eq 0)
        {
            Invoke-Command  {Help $PSCommandPath}
        }

        Stop-ScriptLog $isTranscripting
        exit 0
    }
}

#Commn tasks...
#0. check if VHD(X) includes Windows Destkop or Server.
#1. Process unattend
#2. Enable native boot


# check if VHD(X) file Windows edition and producty type.
# set IsDesktop if it is Windows client.
if (! $CreateVHDTemplate)
{
    $imageInfo = Get-WindowsImageInfo -ImagePath $VHDPath -ImageIndex 0
    $WindowsInfo = "Windows.$($imageInfo.InstallationType).$($imageInfo.EditionID).$($imageInfo.Version)"
    Write-Message "Info" "Windows image information: $($WindowsInfo) `n`t $($imageInfo.ProductName)"

    #if not Server OS, then force swith IsDesktop and disable Hyper-V
    $IsDesktop = IsDesktopOS($imageInfo.ProductType)
}


# Customize unattend file, install drivers and packages if provided from parameter
If(! $DisableUnattend)
{

    $UnattendTemplate = $UnattendTemplate_AMD64_Server
    If($IsDesktop)
    {
        $UnattendTemplate = $UnattendTemplate_AMD64_Client
    }
    
    #prepare the parameter for unattend processing
    $UnattendPara = @{
        WorkSpaceName           = $WorkSpaceName
        VHDPath                 = $VHDPath
#        UnattendFile            = $UnattendFile
        UnattendTemplate        = $UnattendTemplate
#        UnattendWindowsFolder   = $UnattendWindowsFolder
        EnableAutoLogon         = $EnableAutoLogon
        AutologonCount          = $AutoLogonCount
        LocalAdminAccount       = $LocalAdminAccount
        AdminPassword           = $AdminPassword
        ComputerName            = $ComputerName
        RegisteredOrganization  = $RegisteredOrganization
        RegisteredOwner         = $RegisteredOwner
        TimeZone                = $TimeZone
        Driver                  = $Driver
        Package                 = $Package
    }    

    if (! $Driver) {
        $UnattendPara.Remove("Driver")
    }

    if (! $Package) {
        $UnattendPara.Remove("Package")
    }

    Write-Message "Info"  ("Proceed the Unattend.xml file...")
    ProcessUnattend @UnattendPara
}

# Enable Native Boot
if ($EnableNativeBoot)
{
    Write-Message "Info"  "Native boot option was enabled. Proceed NativeBoot..."

    # Get VHD(X) file full path, native boot only use file full path.
    $VHDPath = (get-item $VHDPath).FullName
    $NativeBootPara = @{
        VHDPath = $VHDPath
        Restart = $Restart
        TestMode = $TestMode
    }
    EnableNativeBoot @NativeBootPara
}

Write-Message

$EndTime= Get-Date -UFormat "%Y-%m-%d %H:%M:%S" #-Format yyyy-MM-dd/HH:MM:SS
Write-Message "Info" "Script $ScriptName completed at $EndTime. Started at $StartTime."


# End the transcript
Stop-ScriptLog $isTranscripting
