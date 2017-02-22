# DeployVHD
Readme: [English](https://github.com/wellsluo/DeployVHD/blob/master/README.md) | [中文](https://github.com/wellsluo/DeployVHD/blob/master/README-CN.md)

PowerShell script to deploy new VHD(X) file with un-attend information from Windows Server/Desktop image file ISO/WIM.

##Motivation

Windows 10 insider program should be most popular program which attracts thousands of participants.  As Windows Server,  there is similar program like "Continuous Customer Engagement Program" for enterprise IT administrators.  The both programs will issue new product build ISO periodically, like weekly.  For each build, it will be time consuming for user to setup Windows Server/Windows Desktop from scratch, and so does for different editions.  

So I created the project to develop the PowerShell script, which can help user to deploy the new build to VHD(X) file very quickly and with un-attend features to lower down user tasks and time. 


##Objectives

Agile and easy way to deploy VHD to physical server (NativeBoot) or VM from Windows Server/Desktop iteration builds with un-attend configurations.
For a passionate user who frequently validates the Windows Server/Windows Desktop fresh builds, or IT administrator who needs to generate virtual disks with multiple editions of Windows Server/Windows Desktop, this script will help you out. 

The script is also a pal of "Windows Server CCEP" program and "Windows 10 Insider" program participants.

#License

This project is licensed under the MIT License - see the LICENSE.md file for details

##Features

Generally, the script works in following 3 scenarios:
- Generate new VHD(X) file (MBR or GPT partition) and apply Windows Server OS from ISO/WIM as template file for both virtual machine and physical machine (boot from VHD).
- Customize un-attend options (into Unattend.xml), and apply it to VHD(X).
- Enable boot from VHD (NativeBoot) in physical server (auto restart if enabled).  

So the following features are supported:


- Generate VHD(X) file from Windows Server ISO/WIM image file.
	+ Create MBR or GUID partition of VHD(X) files.
	+ Set VHD(X) file size and partition format (MBR or GUID).
	+ Select different Edition of Windows Server/Windows Desktop.


- On the first boot, OS will setup automatically without user actions.  Customize following un-attend configurations to the VHD(X) files:
	+ Enable Windows Firewall rules of "Remote Desktop" and "File and Printer Sharing". 
	+ Enable automatic logon after Windows boots up, and set automatic logon count. 
	+ Set local administrator password for Windows Server editions.   
	+ Add additional local administrator account and set its password for Windows Desktop editions. 
	+ Enable "Remote Desktop" option. 
	+ Set system locale to en-US.  
	+ Set computer name or use same computer name which runs the script (for creating native boot VHD of physical machine). 
	+ Hide EULA and OOBE pages on first booting up. 
	+ Set time zone to "Pacific Standard Time" by default, or set to "China Standard Time". 
	+ Set register owner and organization of Windows.
	+ Un-attend options can be disabled if not necessary.

- Physical Machine:
	+ Use same computer name as current OS. 
	+ Enable NativeBoot
	+ Restart in 30 seconds after enabling NativeBoot


- Role installed:
	+ Install Hyper-V role for Windows Server by default.
	+ It can be disabled if Hyper-V server is not used or for virtual machines (Windows 10 1511 or above supports nested virtualization).
	+ Provides test mode if you don't want to add the boot entry and restart physical machine.  

- VHD(X) file can be used on both physical machine and Hyper-V virtual machine.

- Apply update packages or drivers when generating the VHD(X) files.

*If you also need features that to create multiple similar virtual machines very quickly, such as a demo lab, another PowerShell project will be created, stay tuned.*

**Note: No any Windows Server/Windows Desktop product keys or licenses are included.  User needs to have your own licenses to use Windows Server/Windows Desktop in production environment.**

 
##Supportability
###VHD(X) OS
You can generate the VHD(X) files from ISO with following OS versions:
- Windows Server 2016 
- Windows Server 2012 R2 
- Windows 10
- Windows 8.1 
- Windows 7 (x86 only for GUID partition)
 
###System Requirements
You can run the script on following OS versions and PowerShell version:
- Windows Server 2016
- Windows Server 2012 R2 (Not for Windows Server 2016 and Windows 10 VHD file)
- Windows 10
- PowerShell 4 or above 

##Usage
Put the script and all other files under a folder. Run PowerShell command window in "Elevated" mode. Then go to the folder to run it. 

###EXAMPLE
Create a 30GB dynamically expanding Datacenter edition VHDX in the current folder from D:\foo\install.wim. File name is WinServer2016.VHDX. 

Unattend.xml will be applied with default settings:
- Computer Name:  Same as host
- AutoLogon: Disabled
- RemoteDesktop: Enabled
- Firewall: Opened



```PowerShell
    .\Deploy-VHD.ps1 -VHDPath WinServer2016.VHDX -SourcePath D:\foo\install.wim 
```

###EXAMPLE

```PowerShell
    .\Deploy-VHD.ps1 -VHDPath WinServer2016.VHDX -SourcePath D:\foo\Win2016.iso 
```

This command will parse the ISO file D:\foo\Win2016.iso and try to locate \sources\install.wim.  If that file is found, it will be used to create a dynamically-expanding 30GB VHDX containing the Datacenter SKU, and will be named WinServer2016.vhdx

###EXAMPLE

```PowerShell
    .\Deploy-VHD.ps1 -VHDPath WinServer2016.VHDX -SourceVHD D:\foo\Win2016-Template.vhdx 
```

This command will use VHDX file D:\foo\Win2016-Template.vhdx and copy as WinServer2016.VHDX.
Unattend.xml will be applied with default configurations:
   Computer Name:  Same as host
   AutoLogon: Disabled
   RemoteDesktop: Enabled
   Firewall: Opened

###EXAMPLE

```PowerShell
    .\Deploy-VHD.ps1 -VHDPath WinServer2016.VHDX  
```

This command will edit WinServer2016.VHDX directly with default un-attend configurations.

###EXAMPLE

```PowerShell
    .\Deploy-VHD.ps1 -VHDPath WinServer2016.VHDX  -ComputerName Test-01 -AutoLogon
```

This command will edit WinServer2016.VHDX, set the computer name to 'Test-01', and enable Autologon.


###EXAMPLE

```PowerShell
    .\Deploy-VHD.ps1 -VHDPath WinServer2016.VHDX  -EnableNativeBoot -Restart
```

This command will edit WinServer2016.VHDX file, and enable boot from VHD, then system restarts in 30 seconds. 

###EXAMPLE

```PowerShell
    .\Deploy-VHD.ps1 -SourcePath D:\foo\Win2016.iso -CreateTemplate
```

This command will parse the ISO file D:\foo\Win2016.iso and try to locate \sources\install.wim.  If that file is found, it will be used to create a 300GB dynamically-expanding  VHDX containing the Datacenter SKU, and will be named WinServer2016-Template.vhdx. Computer name will be generated randomly on first booting up.



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
