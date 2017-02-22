# DeployVHD
README: [English](https://github.com/wellsluo/DeployVHD/blob/master/README.md) | [中文](https://github.com/wellsluo/DeployVHD/blob/master/README-CN.md)

本项目是开发 PowerShell 脚本，用于从 Windows Server/Windows Desktop 的 ISO/WIM 安装镜像快速部署新的Windows Server/Windows Desktop操作系统的 VHD(X) 文件，或者编辑现有的 VHD(X)文件，并配置无人值守安装选项。

##缘起
Windows 10 insider program 应该是吸引了成千上万用户、具有最广泛用户参与的软件验证项目了。针对 Windows Server，也有类似的项目，如针对关键企业用户的 "Continuous Customer Engagement Program" 项目。 两个项目都会定期发布产品新的ISO镜像，比如可能是每周会有。如此频繁的镜像发布，对于用户来说要跟上步伐去全新安装每次发布的不同版本的 build 是一件很耗时耗力的事情，当然也很 boring。 

于是我开发了相应的 PowerShell 脚本，以帮助用户可以非常快速、并且无需用户手工参与地部署新操作系统 build 的 VHD(X) 文件，从而节省繁琐的安装任务和时间。


##目标
敏捷且方便地将新的 Windows Server/Windows Desktop 迭代 build 部署到物理计算机或者虚拟机中，并在 Windows 首次启动的时候无需手工干预。

对于非常有热情验证 Windows Server/Windows Desktop 新鲜 build 的新特性的发烧友们，或者希望方便地生成多个版本的 Windows Server/Windows Desktop 的系统虚拟磁盘的企业 IT 管理员，这个脚本将会极大地帮助你们。

当然，这个脚本也是 "Windows Server CCEP" 和 "Windows 10 Insider" 项目参与者的好伙伴。


##授权
此项目采用 MIT 授权协议，具体请参考 LICENSE.md 文件。

##特性
通常来说，这个脚本适用于以下比较典型的场景：
- 从 ISO/WIM 镜像生成新的 Windows Server/Windows Desktop 系统虚拟磁盘（MBR 或者 GUID 分区）文件作为在物理计算机或者虚拟机中使用的虚拟磁盘模板。
- 将定制化的无人值守选项（通过Unattend.xml文件）应用到 VHD(X) 虚拟磁盘文件中。
- 作为虚拟机的虚拟磁盘来运行虚拟机。
- 在物理计算机上启用 "从 VHD 启动" 的功能（启用后，系统在30秒后自动重新启动到相应的 VHD(X) 虚拟磁盘中）。  

脚本支持以下一些特性：

- 从Windows Server ISO/WIM 镜像文件产生 VHD(X) 文件。
	+ 建立 MBR 或者 GUID 分区。
    + 制定 VHD(X) 文件磁盘的容量。
    + 选择 Windows Server/Windows Desktop ISO/WIM 镜像文件中系统的不同版本。


- 系统首次启动时将根据无人值守文件中的配置进行自动设置，无需用户手工干预。可定制的无人值守配置选项包括：
	+ 启用 Windows 防火墙规则以打开 "远程桌面" 和 "文件与打印机共享" 功能的相应端口。 
	+ 启动自动登录功能，并可以指定自动登录的次数。 
	+ 设定 Windows Server 的本地本地管理员账户的密码。 
	+ 为 Windows Desktop 系统添加额外的管理员账户并设定相应密码。
	+ 启用 "远程桌面" 功能。 
	+ 设定系统地域信息为 en-US。 
	+ 指定计算机名称，或者使用运行脚本的本地计算机名称作为新系统计算机名称（针对在物理服务器上使用 Boot from VHD 的场景）。
    + 系统首次启动时略过最终用户许可协议和开箱即用的设置页面。 
    + 默认指定系统时区为 "Pacific Standard Time" ，可以指定为 "China Standard Time"。
    + 设定注册用户名称和组织名称。
    + 可以禁用所有无人值守的选项。

- 针对物理计算机：
    + 使用与运行脚本的计算机相同的计算机名称。 
    + 启用从 VHD 启动的功能。
        + 系统 30 秒后自动重新启动到 VHD 虚拟磁盘中的系统。


- 角色安装：	
    + 在 Windows Server 版中默认安装 Hyper-V 角色。
    + 如果不需要 Hyper-V 角色，可以禁用自动安装角色。附注：在 Windows 10 1511 版及以上已经支持嵌套的虚拟化功能，所以即便带有 HyperV 角色的 VHD(X)用于虚拟机也是可以运行的）。
        + 如果不希望立刻添加系统启动项和自动重新启动，可以使用测试模式。  

- VHD(X) 文件既可以用在物理计算机上，也可以用在和虚拟机上。

- 可以指定安装补丁文件或者驱动文件。

*如果您还希望可以快速建立、管理多个相似功能的虚拟机并使用上述功能的 VHD(X) 文件的特性，比如建立一个演示的 Lab 系列虚拟机，我会建立另一个 PowerShell 脚本项目来完成，敬请期待.*

**特别注意: 脚本中不会包括任何使用 Windows Server/Windows Desktop 的产品安装秘钥或者使用授权。如果必要，用户需要自己准备相应的授权来使用 Windows Server/Windows Desktop 系统，特别是在生产环境中使用。**

 
##可支持性

###VHD(X) 中的系统
您可以从 ISO/WIM 镜像中生成以下操作系统版本：
- Windows Server 2016 
- Windows Server 2012 R2 
- Windows 10
- Windows 8.1 
- Windows 7 (x86 only for GUID partition)
 
###系统运行需求
要运行脚本，您需要以下操作系统版本和 PowerShell 版本：
- Windows Server 2016
- Windows Server 2012 R2 (Not for Windows Server 2016 and Windows 10 VHD file)
- Windows 10
- PowerShell 4 or above 

##使用方式
将所有文件复制到同一个文件夹，然后以管理员方式启动 PowerShell 控制台窗口，转到脚本的目录下，运行即可。 

###例子

```PowerShell
    .\Deploy-VHD.ps1 -VHDPath WinServer2016.VHDX -SourcePath D:\foo\install.wim 
```

Create a 30GB dynamically expanding Datacenter edition VHDX in the current folder from D:\foo\install.wim. File name is WinServer2016.VHDX. 

Unattend.xml will be applied with default settings:
- Computer Name:  Same as host
- AutoLogon: Disabled
- RemoteDesktop: Enabled
- Firewall: Opened


###例子

```PowerShell
    .\Deploy-VHD.ps1 -VHDPath WinServer2016.VHDX -SourcePath D:\foo\Win2016.iso 
```

This command will parse the ISO file D:\foo\Win2016.iso and try to locate \sources\install.wim.  If that file is found, it will be used to create a dynamically-expanding 30GB VHDX containing the Datacenter SKU, and will be named WinServer2016.vhdx

###例子

```PowerShell
    .\Deploy-VHD.ps1 -VHDPath WinServer2016.VHDX -SourceVHD D:\foo\Win2016-Template.vhdx 
```

This command will use VHDX file D:\foo\Win2016-Template.vhdx and copy as WinServer2016.VHDX.
Unattend.xml will be applied with default configurations:
   Computer Name:  Same as host
   AutoLogon: Disabled
   RemoteDesktop: Enabled
   Firewall: Opened

###例子

```PowerShell
    .\Deploy-VHD.ps1 -VHDPath WinServer2016.VHDX  
```

This command will edit WinServer2016.VHDX directly with default un-attend configurations.

###例子

```PowerShell
    .\Deploy-VHD.ps1 -VHDPath WinServer2016.VHDX  -ComputerName Test-01 -AutoLogon
```

This command will edit WinServer2016.VHDX, set the computer name to 'Test-01', and enable Autologon.


###例子

```PowerShell
    .\Deploy-VHD.ps1 -VHDPath WinServer2016.VHDX  -EnableNativeBoot -Restart
```

This command will edit WinServer2016.VHDX file, and enable boot from VHD, then system restarts in 30 seconds. 

###例子

```PowerShell
    .\Deploy-VHD.ps1 -SourcePath D:\foo\Win2016.iso -CreateTemplate
```

This command will parse the ISO file D:\foo\Win2016.iso and try to locate \sources\install.wim.  If that file is found, it will be used to create a 300GB dynamically-expanding  VHDX containing the Datacenter SKU, and will be named WinServer2016-Template.vhdx. Computer name will be generated randomly on first booting up.



##帮助
本脚本遵循 PowerShell 标准的帮助方式。可运行以下命令来获取帮助：  

```PowerShell

Help .\Deploy-VHD.PS1 -Detailed
 
```

##依赖性
本脚本需要调用 'Convert-WindowsImage.ps1' 中所提供的的功能。'Convert-WindowsImage.ps1' 是Microsoft 提供的示例代码，用于从 ISO/WIM 镜像生成 VHD(X) 文件。本脚本的系统生成功能本使用了其中的部分特性。

'DeployVHD' 中包含了版本为 "10.0.9000.0.fbl_core1_hyp_dev(mikekol).141224-3000.amd64fre" 的文件。

其最新信息和更新，请您参考：
http://gallery.technet.microsoft.com/scriptcenter/Convert-WindowsImageps1-0fe23a8f
