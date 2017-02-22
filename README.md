# DeployVHD
PowerShell script to deploy newVHD(X) file with unattend information from Windows Server/Desktop image file ISO/WIM.

##Background


##Objectives

Agile and easy way to deploy VHD to physical server (NativeBoot) or VM from Windows Server/Desktop iteration builds with unattend configurations.
For a passionate user who frequently validates the Windows Server/Windows Desktop fresh builds, or IT administrator who needs to generate virtual disks with multiple editions of Windows Server/Windows Desktop, this script will help you out. 

The script is also a pal of "Windows Server CCEP" program and "Windows 10 Insider" program participants.



##Features

Generally, the script works in following 3 scenarios:
- Generate new VHD(X) file (MBR or GPT partition) and apply Windows Server OS from ISO/WIM as template file for both virtual machine and physical machine (boot from VHD).
- Customize unattend options (into Unattend.xml), and apply it to VHD(X).
- Enable boot from VHD (NativeBoot) in physical server (auto restart if enabled).  

So the following features are supported:

1. Generate VHD(X) file from Windows Server ISO/WIM file.
2. Customize folloing unattend configurations to the VHD(X) files:
   - a. Enable Windows Firewall rules of "Remote Desktop" and "File and Printer Sharing".
   b. Enable automatic logon after Windows boots up, and set automatic logon count.
   c. Set local administrator password for Windows Server editions.
   d. Add additional local administrator account and set its password for Windows Desktop editions.
   e. Enable "Remote Desktop" option.
   f. Set system locale to en-US.
   g. Set computer name or use same computer name which runs the script (for creating native boot vhd of physical machine).
   h. Hide EULA and OOBE pages on first booting up.
   i. Set time zone to "Pacific Time" by default, or set to China time. 
   j. Set register owner and organization of Windows. 
3. Unattend options can be disabled if not necessary.
4. Enable NativeBoot with Restart option for physical machine.
5. Create MBR or GUID partition of VHD(X) files.
6. VHD(X) file can be used on both physical machine and Hyper-V virtual machine.
7. Select different Edition of Windows Server/Windows Desktop.
8. Set VHD(X) file size and partition format (MBR or GUID).
9. Install Hyper-V role for Windows Server. It will not be installed for Windows Desktop edition.
10. Apply update packages or drivers when generating the VHD(X) files. 


 
##Supportability
###VHD(X) OS:  
- Windows Server 2016 
- Windows Server 2012 R2 
- Windows 10
- Windows 8.1 
- Windows 7 (x86 only for GUID partition)
 
###System Requirements
- Windows Server 2016
- Windows Server 2012 R2 (Not for Windows Server 2016 and Windows 10 VHD file)
- Windows 10
- PowerShell 4 or above 

##Usage
Put the script and all other files under a folder. Run PowerShell command window in "Elevated" mode. Then go to the folder to run it. 

###EXAMPLE1
Create a 30GB dynamically expanding Datacenter edition VHDX in the current folder from D:\foo\install.wim. File name is WinServer2016.VHDX. 

Unattend.xml will be applied with default settings:
- Computer Name:  Same as host
- AutoLogon: Disabled
- RemoteDesktop: Enabled
- Firewall: Opened
   ```PowerShell
        .\Deploy-VHD.ps1 -VHDPath WinServer2016.VHDX -SourcePath D:\foo\install.wim 
   ```


    ##EXAMPLE
    ```PowerShell
        .\Deploy-VHD.ps1 -VHDPath WinServer2016.VHDX -SourcePath D:\foo\Win2016.iso 
    ```
        This command will parse the ISO file D:\foo\Win2016.iso and try to locate
        \sources\install.wim.  If that file is found, it will be used to create a 
        dynamically-expanding 30GB VHDX containing the Datacenter SKU, and will be 
        named WinServer2016.vhdx
        Unattend.xml will be applied with default settings:
            Computer Name:  Same as host
            AutoLogon: Disabled
            RemoteDesktop: Enabled
            Firewall: Opened

    ##EXAMPLE
    ```PowerShell
        .\Deploy-VHD.ps1 -VHDPath WinServer2016.VHDX -SourceVHD D:\foo\Win2016-Template.vhdx 
    ```
        This command will use VHDX file D:\foo\Win2016-Template.vhdx and copy as 
        WinServer2016.VHDX.
        Unattend.xml will be applied with default settings:
            Computer Name:  Same as host
            AutoLogon: Disabled
            RemoteDesktop: Enabled
            Firewall: Opened

    ##EXAMPLE
    ```PowerShell
        .\Deploy-VHD.ps1 -VHDPath WinServer2016.VHDX  
    ```
        This command will edit WinServer2016.VHDX directly.
        Unattend.xml will be applied with default settings:
            Computer Name:  Same as host
            AutoLogon: Disabled
            RemoteDesktop: Enabled
            Firewall: Opened

    ##EXAMPLE
    ```PowerShell
        .\Deploy-VHD.ps1 -VHDPath WinServer2016.VHDX  -ComputerName Test-01 -AutoLogon
    ```
        This command will edit WinServer2016.VHDX directly.
        Unattend.xml will be applied with following settings:
            Computer Name:  Test-01
            AutoLogon: Enabled
            RemoteDesktop: Enabled
            Firewall: Opened

    ##EXAMPLE
    ```PowerShell
        .\Deploy-VHD.ps1 -VHDPath WinServer2016.VHDX  -EnableNativeBoot -Restart
    ```
        This command will edit WinServer2016.VHDX directly.
        Unattend.xml will be applied with default settings:
            Computer Name:  Same as host
            AutoLogon: Disabled
            RemoteDesktop: Enabled
            Firewall: Opened
        Native boot will be enabled and system restarts in 30 seconds. 

    ##EXAMPLE
    ```PowerShell
        .\Deploy-VHD.ps1 -SourcePath D:\foo\Win2016.iso -CreateTemplate
    ```
        This command will parse the ISO file D:\foo\Win2016.iso and try to locate
        \sources\install.wim.  If that file is found, it will be used to create a 
        dynamically-expanding 30GB VHDX containing the Datacenter SKU, and will be 
        named WinServer2016-Template.vhdx



##Help
The script aligns with standard PowerShell help format. To get the help of the script, just run command:  

```PowerShell

Help .\Deploy-VHD.PS1 -Detailed
 
```

##Dependency
The script depends on the script 'Convert-WindowsImage.ps1' from Microsoft. The script 'Convert-WindowsImage.ps1' provides basic functions to convert ISO or WIM image to VHD(X) files. 

'DeployVHD' includes version "10.0.9000.0.fbl_core1_hyp_dev(mikekol).141224-3000.amd64fre". 

Latest version can be found at:
http://gallery.technet.microsoft.com/scriptcenter/Convert-WindowsImageps1-0fe23a8f
