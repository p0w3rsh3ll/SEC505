# This script requires PowerShell 5.1 or later and 
# the PSDscResources module version 2.7.0.0 or later.


Configuration ServerTemplate
{
    Param ( [String[]] $ComputerName = 'LocalHost' )
 
    Import-DscResource -ModuleName PSDscResources -Name Service 

    Node $ComputerName
    { 
        Service Disable-AxInstSV { Name = 'AxInstSV'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-tzautoupdate { Name = 'tzautoupdate'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-bthserv { Name = 'bthserv'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-CDPUserSvc { Name = 'CDPUserSvc'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-Browser { Name = 'Browser'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-PimIndexMaintenanceSvc { Name = 'PimIndexMaintenanceSvc'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-dmwappushservice { Name = 'dmwappushservice'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-MapsBroker { Name = 'MapsBroker'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-lfsvc { Name = 'lfsvc'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-SharedAccess { Name = 'SharedAccess'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-lltdsvc { Name = 'lltdsvc'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-wlidsvc { Name = 'wlidsvc'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-AppVClient { Name = 'AppVClient'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-NgcSvc { Name = 'NgcSvc'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-NgcCtnrSvc { Name = 'NgcCtnrSvc'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-NetTcpPortSharing { Name = 'NetTcpPortSharing'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-NcbService { Name = 'NcbService'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-CscService { Name = 'CscService'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-PhoneSvc { Name = 'PhoneSvc'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-PrintNotify { Name = 'PrintNotify'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-PcaSvc { Name = 'PcaSvc'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-QWAVE { Name = 'QWAVE'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-RmSvc { Name = 'RmSvc'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-RemoteAccess { Name = 'RemoteAccess'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-SensorDataService { Name = 'SensorDataService'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-SensrSvc { Name = 'SensrSvc'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-SensorService { Name = 'SensorService'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-ShellHWDetection { Name = 'ShellHWDetection'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-SCardSvr { Name = 'SCardSvr'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-ScDeviceEnum { Name = 'ScDeviceEnum'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-SSDPSRV { Name = 'SSDPSRV'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-WiaRpc { Name = 'WiaRpc'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-OneSyncSvc { Name = 'OneSyncSvc'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-TabletInputService { Name = 'TabletInputService'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-upnphost { Name = 'upnphost'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-UserDataSvc { Name = 'UserDataSvc'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-UnistoreSvc { Name = 'UnistoreSvc'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-UevAgentService { Name = 'UevAgentService'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-WalletService { Name = 'WalletService'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-Audiosrv { Name = 'Audiosrv'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-AudioEndpointBuilder { Name = 'AudioEndpointBuilder'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-FrameServer { Name = 'FrameServer'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-stisvc { Name = 'stisvc'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-wisvc { Name = 'wisvc'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-icssvc { Name = 'icssvc'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-WpnService { Name = 'WpnService'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-WpnUserService { Name = 'WpnUserService'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-WSearch { Name = 'WSearch'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-XblAuthManager { Name = 'XblAuthManager'; StartupType = 'Disabled'; State = 'Stopped' }
        Service Disable-XblGameSave { Name = 'XblGameSave'; StartupType = 'Disabled'; State = 'Stopped' } 
        Service Auto-AppReadiness { Name = 'AppReadiness'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-BrokerInfrastructure { Name = 'BrokerInfrastructure'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-BFE { Name = 'BFE'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-EventSystem { Name = 'EventSystem'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-CDPSvc { Name = 'CDPSvc'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-DiagTrack { Name = 'DiagTrack'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-CoreMessagingRegistrar { Name = 'CoreMessagingRegistrar'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-CryptSvc { Name = 'CryptSvc'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-DcomLaunch { Name = 'DcomLaunch'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-Dhcp { Name = 'Dhcp'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-DPS { Name = 'DPS'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-TrkWks { Name = 'TrkWks'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-MSDTC { Name = 'MSDTC'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-Dnscache { Name = 'Dnscache'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-gpsvc { Name = 'gpsvc'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-HvHost { Name = 'HvHost'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-vmickvpexchange { Name = 'vmickvpexchange'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-vmicguestinterface { Name = 'vmicguestinterface'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-vmicshutdown { Name = 'vmicshutdown'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-vmicheartbeat { Name = 'vmicheartbeat'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-vmicvmsession { Name = 'vmicvmsession'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-vmicrdv { Name = 'vmicrdv'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-vmictimesync { Name = 'vmictimesync'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-vmicvss { Name = 'vmicvss'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-iphlpsvc { Name = 'iphlpsvc'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-LSM { Name = 'LSM'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-MSiSCSI { Name = 'MSiSCSI'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-smphost { Name = 'smphost'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-NlaSvc { Name = 'NlaSvc'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-nsi { Name = 'nsi'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-Power { Name = 'Power'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-Spooler { Name = 'Spooler'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-SessionEnv { Name = 'SessionEnv'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-TermService { Name = 'TermService'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-UmRdpService { Name = 'UmRdpService'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-RpcSs { Name = 'RpcSs'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-RemoteRegistry { Name = 'RemoteRegistry'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-RpcEptMapper { Name = 'RpcEptMapper'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-SstpSvc { Name = 'SstpSvc'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-SamSs { Name = 'SamSs'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-LanmanServer { Name = 'LanmanServer'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-sppsvc { Name = 'sppsvc'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-SENS { Name = 'SENS'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-SystemEventsBroker { Name = 'SystemEventsBroker'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-Schedule { Name = 'Schedule'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-TapiSrv { Name = 'TapiSrv'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-Themes { Name = 'Themes'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-tiledatamodelsvc { Name = 'tiledatamodelsvc'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-TimeBrokerSvc { Name = 'TimeBrokerSvc'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-UsoSvc { Name = 'UsoSvc'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-UALSVC { Name = 'UALSVC'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-UserManager { Name = 'UserManager'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-ProfSvc { Name = 'ProfSvc'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-Wcmsvc { Name = 'Wcmsvc'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-WinDefend { Name = 'WinDefend'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-WerSvc { Name = 'WerSvc'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-Wecsvc { Name = 'Wecsvc'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-EventLog { Name = 'EventLog'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-MpsSvc { Name = 'MpsSvc'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-FontCache { Name = 'FontCache'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-Winmgmt { Name = 'Winmgmt'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-WinRM { Name = 'WinRM'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-W32Time { Name = 'W32Time'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-WinHttpAutoProxySvc { Name = 'WinHttpAutoProxySvc'; StartupType = 'Automatic'; State = 'Running' }
        Service Auto-LanmanWorkstation { Name = 'LanmanWorkstation'; StartupType = 'Automatic'; State = 'Running' }
        Service Manual-AJRouter { Name = 'AJRouter'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-AppIDSvc { Name = 'AppIDSvc'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-Appinfo { Name = 'Appinfo'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-ALG { Name = 'ALG'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-AppMgmt { Name = 'AppMgmt'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-AppXSvc { Name = 'AppXSvc'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-BITS { Name = 'BITS'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-CertPropSvc { Name = 'CertPropSvc'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-ClipSVC { Name = 'ClipSVC'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-KeyIso { Name = 'KeyIso'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-COMSysApp { Name = 'COMSysApp'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-VaultSvc { Name = 'VaultSvc'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-DsSvc { Name = 'DsSvc'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-DcpSvc { Name = 'DcpSvc'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-DeviceAssociationService { Name = 'DeviceAssociationService'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-DeviceInstall { Name = 'DeviceInstall'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-DmEnrollmentSvc { Name = 'DmEnrollmentSvc'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-DsmSvc { Name = 'DsmSvc'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-DevQueryBroker { Name = 'DevQueryBroker'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-WdiServiceHost { Name = 'WdiServiceHost'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-WdiSystemHost { Name = 'WdiSystemHost'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-embeddedmode { Name = 'embeddedmode'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-EFS { Name = 'EFS'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-EntAppSvc { Name = 'EntAppSvc'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-EapHost { Name = 'EapHost'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-fdPHost { Name = 'fdPHost'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-FDResPub { Name = 'FDResPub'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-hidserv { Name = 'hidserv'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-IKEEXT { Name = 'IKEEXT'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-UI0Detect { Name = 'UI0Detect'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-PolicyAgent { Name = 'PolicyAgent'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-KPSSVC { Name = 'KPSSVC'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-KtmRm { Name = 'KtmRm'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-diagnosticshub.standardcollector.service { Name = 'diagnosticshub.standardcollector.service'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-swprv { Name = 'swprv'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-Netlogon { Name = 'Netlogon'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-Netman { Name = 'Netman'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-NcaSvc { Name = 'NcaSvc'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-netprofm { Name = 'netprofm'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-NetSetupSvc { Name = 'NetSetupSvc'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-defragsvc { Name = 'defragsvc'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-PerfHost { Name = 'PerfHost'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-pla { Name = 'pla'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-PlugPlay { Name = 'PlugPlay'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-WPDBusEnum { Name = 'WPDBusEnum'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-wercplsupport { Name = 'wercplsupport'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-RasAuto { Name = 'RasAuto'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-RasMan { Name = 'RasMan'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-RpcLocator { Name = 'RpcLocator'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-RSoPProv { Name = 'RSoPProv'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-seclogon { Name = 'seclogon'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-SCPolicySvc { Name = 'SCPolicySvc'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-SNMPTRAP { Name = 'SNMPTRAP'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-sacsvr { Name = 'sacsvr'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-svsvc { Name = 'svsvc'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-StateRepository { Name = 'StateRepository'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-StorSvc { Name = 'StorSvc'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-TieringEngineService { Name = 'TieringEngineService'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-SysMain { Name = 'SysMain'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-lmhosts { Name = 'lmhosts'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-vds { Name = 'vds'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-VSS { Name = 'VSS'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-WbioSrvc { Name = 'WbioSrvc'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-WdNisSvc { Name = 'WdNisSvc'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-wudfsvc { Name = 'wudfsvc'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-WEPHOSTSVC { Name = 'WEPHOSTSVC'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-msiserver { Name = 'msiserver'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-LicenseManager { Name = 'LicenseManager'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-TrustedInstaller { Name = 'TrustedInstaller'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-wuauserv { Name = 'wuauserv'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-dot3svc { Name = 'dot3svc'; StartupType = 'Manual'; State = 'Ignore' }
        Service Manual-wmiApSrv { Name = 'wmiApSrv'; StartupType = 'Manual'; State = 'Ignore' } 
    }
}




# Create the MOF from the above function and save to the MOF share:

ServerTemplate -ComputerName $env:COMPUTERNAME -OutputPath "\\$env:COMPUTERNAME\MOF\ServerTemplate" 



# Apply the MOF to the target computer:

Start-DscConfiguration -ComputerName $env:COMPUTERNAME -Path "\\$env:COMPUTERNAME\MOF\ServerTemplate" -Force -Verbose -Wait 


