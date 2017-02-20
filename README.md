# DeployVHD
PowerShell script to deploy newVHD(X) file with unattend information from Windows Server/Desktop image file ISO/WIM.

Objectives
==========
Agile and easy way deploy VHD to physical server (NativeBoot) or VM from Windows Server/Desktop iteration builds with unattend settings.
 
Features
========
 
1. Generate VHD(X) file from Windows Server ISO/WIM file.
2. Customize settings(Enable AutoLogon, Inject computer name) with Unattend.xml file and apply to VHD(X) file. 
3. Enable NativeBoot with Restart option
4. Create MBR partition of VHD(X) 
5. VHD(X) works in NativeBoot or VM. 
 
Supportability
=============
VHD(X) OS:  Windows Server 2016, Windows Server 2012 R2, Windows 10, Windows 8.1, Windows 7
 
System Requirement
=================
Windows Server 2016
Windows Server 2012 R2 (Not for Windows Server 2016 and Windows 10 VHD file)
Windows 10
 
 
Usage
======
Run command:  Help .\Deploy-VHD.PS1 -Detailed
 
Generally, the script works in following 3 scenarios:
•	Generate new VHD(X) file (MBR or GPT partition) and apply Windows Server OS from ISO/WIM.
•	Customize computer name and AutoLogon option (into Unattend.xml) file, and apply it to VHD(X).
•	Enable NativeBoot in physical server (auto restart if enabled).  

Dependency
============
The script depends on the script 'Convert-WindowsImage.ps1' from Microsoft. The script 'Convert-WindowsImage.ps1' provides basic functions to convert ISO or WIM image to VHD(X) files. 

'DeployVHD' uses version "10.0.9000.0.fbl_core1_hyp_dev(mikekol).141224-3000.amd64fre". 


Latest version can be found at:
http://gallery.technet.microsoft.com/scriptcenter/Convert-WindowsImageps1-0fe23a8f
