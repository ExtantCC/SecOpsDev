## ----------------------------------------- ##
# @Author: WeiyiGeek
# @Description:  Windows Server ��ȫ���ò��Ի��߼ӹ̽ű�
# @Create Time:  2019��5��6�� 11:04:42
# @Last Modified time: 2021��11��17�� 16:02:36
# @E-mail: master@weiyigeek.top
# @Blog: https://www.weiyigeek.top
# @wechat: WeiyiGeeker
# @Github: https://github.com/WeiyiGeek/SecOpsDev/tree/master/OperatingSystem/Security/Windows
# @Version: 1.9
# @Runtime: Server 2019 / Windows 10
## ----------------------------------------- ##
# �ű���Ҫ����˵��:
# (1) Windows ϵͳ��ȫ������ػ�������
# (2) Windows Ĭ�Ϲ���رա���������ʱʱ���Լ�WSUS�������¡�
# (3) Windows �ȱ����������ȫ�ӹ�����
## ----------------------------------------- ##

# * �ļ����Ĭ��ΪUTF-8��ʽ
# $PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$WUSUServer="http://wusu.weiyigeek.top"

<#
.SYNOPSIS
Windows Server ��ȫ���ò��Ի��߼ӹ̽ű� ���ű�������Github�ϳ������£�

.DESCRIPTION
Windows Server ����ϵͳ���ò��� (���ϵȱ�3���Ĺؼ������)
- ϵͳ�˺Ų��� 
- ϵͳ�¼���˲���
- ϵͳ����԰�ȫѡ�����
- ע�����ذ�ȫ����
- ����ǽ������ذ�ȫ����
- �����ϵͳ���ް취ͨ��ע����Լ���������õİ�ȫ�ӹ���

.EXAMPLE
WindowsSecurityReinforce.ps1

.NOTES
ע��:��ͬ�İ汾����ϵͳ����ĳЩ�ؼ�����ܻ᲻���ڻ���һЩ����(��Ҫ����ύissue����ͬ���)��
#>

# - ϵͳ�˺Ų��� - #
$SysAccountPolicy = @{
  # + �������������
  "MinimumPasswordAge" = @{operator="eq";value=1;msg="�������������"}
  # + �����������
  "MaximumPasswordAge" = @{operator="eq";value=90;msg="�����������"}
  # + ���볤����Сֵ
  "MinimumPasswordLength" = @{operator="ge";value=14;msg="���볤����Сֵ"}
  # + ���������ϸ�����Ҫ��
  "PasswordComplexity" = @{operator="eq";value=1;msg="����������ϸ�����Ҫ�����"}
  # + ǿ��������ʷ N����ס������
  "PasswordHistorySize" = @{operator="ge";value=3;msg="ǿ��������ʷN����ס������"}
  # + �˻���¼ʧ��������ֵN����
  "LockoutBadCount" = @{operator="eq";value=6;msg="�˻���¼ʧ��������ֵ����"}
  # + �˻�����ʱ��(����)
  "ResetLockoutCount" = @{operator="ge";value=15;msg="�˻�����ʱ��(����)"}
  # + ��λ�˻�����������ʱ��(����)
  "LockoutDuration" = @{operator="ge";value=15;msg="��λ�˻�����������ʱ��(����)"}
  # + �´ε�¼�����������
  "RequireLogonToChangePassword" = @{operator="eq";value=0;msg="�´ε�¼�����������"}
  # + ǿ�ƹ���
  "ForceLogoffWhenHourExpire" = @{operator="eq";value=1;msg="ǿ�ƹ���"}
  # + ��ǰ�����˺ŵ�½����
  "NewAdministratorName" = @{operator="ne";value='"Admin"';msg="���ĵ�ǰϵͳ�����˺ŵ�½����ΪAdmin����"}
  # + ��ǰ�����û���½����
  "NewGuestName" = @{operator="ne";value='"Guester"';msg="���ĵ�ǰϵͳ�����û���½����ΪGuester����"}
  # + ����Ա�Ƿ�����
  "EnableAdminAccount" = @{operator="eq";value=1;msg="����Ա�˻�ͣ�������ò���"}
  # + �����û��Ƿ�����
  "EnableGuestAccount" = @{operator="eq";value=0;msg="�����˻�ͣ�������ò���"}
  # + ָʾ�Ƿ�ʹ�ÿ���������洢����һ�����(����Ӧ�ó���Ҫ�󳬹�����������Ϣ����Ҫ)
  "ClearTextPassword" = @{operator="eq";value=0;msg="ָʾ�Ƿ�ʹ�ÿ���������洢���� (����Ӧ�ó���Ҫ�󳬹�����������Ϣ����Ҫ)"}
  # + ����ʱ���������������û���ѯ����LSA����(0�ر�)
  "LSAAnonymousNameLookup" = @{operator="eq";value=0;msg="����ʱ���������������û���ѯ����LSA���� (0�ر�)"}
}

# - ϵͳ�¼���˲��� - #
$SysEventAuditPolicy  = @{
  # + ���ϵͳ�¼�(0) [�ɹ�(1)��ʧ��(2)] (3)
  AuditSystemEvents = @{operator="eq";value=3;msg="���ϵͳ�¼�"}
  # + ��˵�¼�¼� �ɹ���ʧ��
  AuditLogonEvents = @{operator="eq";value=3;msg="��˵�¼�¼�"}
  # + ��˶������ �ɹ���ʧ��
  AuditObjectAccess = @{operator="eq";value=3;msg="��˶������"}
  # + �����Ȩʹ�� ʧ��
  AuditPrivilegeUse = @{operator="ge";value=2;msg="�����Ȩʹ��"}
  # + ��˲��Ը��� �ɹ���ʧ��
  AuditPolicyChange = @{operator="eq";value=3;msg="��˲��Ը���"}
  # + ����˻����� �ɹ���ʧ��
  AuditAccountManage = @{operator="eq";value=3;msg="����˻�����"}
  # + ��˹���׷�� ʧ��
  AuditProcessTracking = @{operator="ge";value=2;msg="��˹���׷��"}
  # + ���Ŀ¼������� ʧ��
  AuditDSAccess = @{operator="ge";value=2;msg="���Ŀ¼�������"}
  # + ����˻���¼�¼� �ɹ���ʧ��
  AuditAccountLogon = @{operator="eq";value=3;msg="����˻���¼�¼�"}
}

# - ϵͳ����԰�ȫѡ����� - #
$SysSecurityOptionPolicy = @{
  # - �ʻ�:ʹ�ÿ�����ı����ʻ�ֻ������п���̨��¼(����),ע������ò�Ӱ��ʹ�����ʻ��ĵ�¼��(0����|1����)
  LimitBlankPasswordUse = @{operator="eq";value="MACHINE\System\CurrentControlSet\Control\Lsa\LimitBlankPasswordUse=4,1";msg="�ʻ�-ʹ�ÿ�����ı����ʻ�ֻ������п���̨��¼(����)"}
  # - ����ʽ��¼: ����ʾ�ϴε�¼�û���ֵ(����)
  DontDisplayLastUserName = @{operator="eq";value="MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\DontDisplayLastUserName=4,1";msg="����ʽ��¼-����ʾ�ϴε�¼�û���ֵ(����)"}
  # - ����ʽ��¼: ��¼ʱ����ʾ�û���
  DontDisplayUserName = @{operator="eq";value="MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\DontDisplayUserName=4,1";msg="����ʽ��¼: ��¼ʱ����ʾ�û���"}
  # - ����ʽ��¼: �����Ựʱ��ʾ�û���Ϣ(����ʾ�κ���Ϣ)
  DontDisplayLockedUserId = @{operator="eq";value="MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\DontDisplayLockedUserId=4,3";msg="����ʽ��¼: �����Ựʱ��ʾ�û���Ϣ(����ʾ�κ���Ϣ)"}
  # - ����ʽ��¼: ���谴 CTRL+ALT+DEL(����)
  DisableCAD = @{operator="eq";value="MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\DisableCAD=4,0";msg="����ʽ��¼-���谴CTRL+ALT+DELֵ(����)"}
  # - ����ʽ��¼��������������ֵΪ600������
  InactivityTimeoutSecs = @{operator="eq";value="MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\InactivityTimeoutSecs=4,600";msg="����ʽ��¼-������������ֵΪ600������"}
  # - ����ʽ��¼: ������ʻ���ֵ�˲�������ȷ���ɵ��¼����������ʧ�ܵ�¼���Դ���
  MaxDevicePasswordFailedAttempts = @{operator="le";value="MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\MaxDevicePasswordFailedAttempts=4,10";msg="����ʽ��¼: �˲�������ȷ���ɵ��¼����������ʧ�ܵ�¼���Դ���"}
  # - ����ʽ��¼: ��ͼ��¼���û�����Ϣ����
  LegalNoticeCaption = @{operator="eq";value='MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\LegalNoticeCaption=1,"��ȫ��½"';msg="����ʽ��¼: ��ͼ��¼���û�����Ϣ����"}
  # - ����ʽ��¼: ��ͼ��¼���û�����Ϣ�ı�
  LegalNoticeText = @{operator="eq";value='MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\LegalNoticeText=7,������Ĳ���������������,�����в���������¼���';msg="����ʽ��¼: ��ͼ��¼���û�����Ϣ�ı�"}
  
  # - Microsoft����ͻ���: ��δ���ܵ����뷢�͵������� SMB ������(����)
  EnablePlainTextPassword = @{operator="eq";value="MACHINE\System\CurrentControlSet\Services\LanmanWorkstation\Parameters\EnablePlainTextPassword=4,0";msg="Microsoft����ͻ���-��δ���ܵ����뷢�͵������� SMB ������(����)"}
  # - Microsoft�������������ͣ�Ựǰ����Ŀ���ʱ������ֵΪ15���ӻ���ٵ���Ϊ0
  AutoDisconnect = @{operator="15";value="MACHINE\System\CurrentControlSet\Services\LanManServer\Parameters\AutoDisconnect=4,15";msg="Microsoft���������-��ͣ�Ựǰ����Ŀ���ʱ������ֵΪ15����"}
  
  # - ���簲ȫ: ����һ�θı�����ʱ���洢LAN��������ϣֵ(����)
  NoLMHash = @{operator="eq";value="MACHINE\System\CurrentControlSet\Control\Lsa\NoLMHash=4,1";msg="���簲ȫ-����һ�θı�����ʱ���洢LAN��������ϣֵ(����)"}
  
  # - �������: ������SAM�˻�������ö��ֵΪ(����)
  RestrictAnonymousSAM = @{operator="eq";value="MACHINE\System\CurrentControlSet\Control\Lsa\RestrictAnonymousSAM=4,1";msg="�������-������SAM�˻�������ö��ֵΪ(����)"}
  # - �������:������SAM�˻��͹��������ö��ֵΪ(����)
  RestrictAnonymous = @{operator="eq";value="MACHINE\System\CurrentControlSet\Control\Lsa\RestrictAnonymous=4,1";msg="�������-������SAM�˻��͹��������ö��ֵΪ(����)"}
  
  # - �ػ�:����ȷ���Ƿ�����������¼ Windows ������¹رռ����(����)
  ClearPageFileAtShutdown = @{operator="eq";value="MACHINE\System\CurrentControlSet\Control\Session Manager\Memory Management\ClearPageFileAtShutdown=4,0";msg="�ػ�-����ȷ���Ƿ�����������¼ Windows ������¹رռ����(����)"}
}

# - ����ϵͳ������û�Ȩ�޹������ - #
$SysUserPrivilegePolicy = @{
  # + ����ϵͳ���عػ����԰�ȫ
  SeShutdownPrivilege = @{operator="eq";value='*S-1-5-32-544';msg="����ϵͳ���عػ�����"}
  # + ����ϵͳԶ�̹ػ����԰�ȫ
  SeRemoteShutdownPrivilege = @{operator="eq";value='*S-1-5-32-544';msg="����ϵͳԶ�̹ػ�����"}
  # + ȡ���ļ����������������Ȩ�޲���
  SeProfileSingleProcessPrivilege = @{operator="eq";value='*S-1-5-32-544';msg="ȡ���ļ����������������Ȩ�޲���"}
  # + ��������ʴ˼��������
  SeNetworkLogonRight = @{operator="eq";value='*S-1-5-32-544,*S-1-5-32-545,*S-1-5-32-551';msg="��������ʴ˼��������"}
}

# - ע�����ذ�ȫ����  -
$SysRegistryPolicy = @{
  # + ��Ļ�Զ���������
  ScreenSaveActive = @{reg="HKEY_CURRENT_USER\Control Panel\Desktop";name="ScreenSaveActive";regtype="String";value=1;operator="eq";msg="������Ļ�Զ������������"}
  # + ��Ļ�ָ�ʱʹ�����뱣��
  ScreenSaverIsSecure = @{reg="HKEY_CURRENT_USER\Control Panel\Desktop";name="ScreenSaverIsSecure";regtype="String";value=1;operator="eq";msg="������Ļ�ָ�ʱʹ�����뱣������"}
  # + ��Ļ������������ʱ��
  ScreenSaveTimeOut = @{reg="HKEY_CURRENT_USER\Control Panel\Desktop";name="ScreenSaveTimeOut";regtype="String";value=600;operator="le";msg="������Ļ������������ʱ�����"}
  
  # + ��ֹȫ���������Զ�����
  DisableAutoplay  = @{reg="HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";name="DisableAutoplay";regtype="DWord";operator="eq";value=1;msg="��ֹȫ���������Զ�����"}
  NoDriveTypeAutoRun = @{reg="HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";name="NoDriveTypeAutoRun";regtype="DWord";operator="eq";value=255;msg="��ֹȫ���������Զ�����"}
  
  # + ����IPC����(��ֹSAM�ʻ��͹��������ö��)
  restrictanonymous = @{reg="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa";name="restrictanonymous";regtype="DWord";operator="eq";value=1;msg="������SAM�˻��͹��������ö��ֵΪ(����)"}
  restrictanonymoussam = @{reg="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa";name="restrictanonymoussam";regtype="DWord";operator="eq";value=1;msg="������SAM�˻�������ö��ֵΪ(����)"}

  # + ���ô��̹���(SMB����)
  SMBDeviceEnabled = @{reg="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\NetBT\Parameters";name="SMBDeviceEnabled";regtype="QWord";operator="eq";value=0;msg="�رս���SMB�������"}
  AutoShareWks = @{reg="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters";name="AutoShareWks";regtype="DWord";operator="eq";value=0;msg="�رս���Ĭ�Ϲ������-Server2012"}
  AutoShareServer = @{reg="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters";name="AutoShareServer";regtype="DWord";operator="eq";value=0;msg="�رս���Ĭ�Ϲ������-Server2012"}

  # + ϵͳ��Ӧ�á���ȫ��PS��־�鿴����С(��λ�ֽ�)����(�˴�����Ĭ�ϵ���������-����һ��ͨ����־�ɼ�ƽ̨�ɼ�ϵͳ��־����ELK)
  EventlogSystemMaxSize = @{reg="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\System";name="MaxSize";regtype="DWord";operator="ge";value=41943040;msg="ϵͳ����־��˲�-ϵͳ��־�鿴����С���ò���"}
  EventlogApplicationMaxSize = @{reg="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\Application";name="MaxSize";regtype="DWord";operator="ge";value=41943040;msg="ϵͳ��־����˲�-Ӧ����־�鿴����С���ò���"}
  EventlogSecurityMaxSize = @{reg="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\Security";name="MaxSize";regtype="DWord";operator="ge";value=41943040;msg="ϵͳ��־����˲�-��ȫ��־�鿴����С���ò���"}
  EventlogPSMaxSize = @{reg="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\Windows PowerShell";name="MaxSize";regtype="DWord";operator="ge";value=31457280;msg="ϵͳ��־����˲�-PS��־�鿴����С���ò���"}

  # + Զ�����濪����ر�
  fDenyTSConnections = @{reg='HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Terminal Server';name='fDenyTSConnections';regtype="DWord";operator="eq";value=0;msg="�Ƿ����Զ���������-1��Ϊ����"}
  UserAuthentication = @{reg='HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp';name='UserAuthentication ';regtype="DWord";operator="eq";value=1;msg="ֻ�������д����缶�����֤��Զ������ļ��������"}
  RDPTcpPortNumber = @{reg='HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp';name='PortNumber';regtype="DWord";operator="eq";value=39393;msg="Զ���������˿�RDP-Tcp��3389"}
  TDSTcpPortNumber = @{reg='HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\Wds\rdpwd\Tds\tcp';name='PortNumber';regtype="DWord";operator="eq";value=39393;msg="Զ���������˿�TDS-Tcp��3389"}

  # + ����ǽ��ز������ã�������Э�顢����
  DomainEnableFirewall  = @{reg='HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile';name='EnableFirewall';regtype="DWord";operator="eq";value=1;msg="�������������ǽ"}
  StandardEnableFirewall = @{reg='HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SharedAccess\Parameters\FirewallPolicy\StandardProfile';name='EnableFirewall';regtype="DWord";operator="eq";value=1;msg="����ר���������ǽ"}
  PPEnableFirewall = @{reg='HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SharedAccess\Parameters\FirewallPolicy\PublicProfile';name='EnableFirewall';regtype="DWord";operator="eq";value=1;msg="���������������ǽ"}

  # + Դ·����ƭ����
  DisableIPSourceRouting = @{reg='HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Tcpip\Parameters';name='DisableIPSourceRouting';regtype="DWord";operator="eq";value=2;msg="Դ·����ƭ����"}

  # + ��Ƭ��������
  EnablePMTUDiscovery = @{reg='HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Tcpip\Parameters';name='EnablePMTUDiscovery';regtype="DWord";operator="eq";value=1;msg="��Ƭ��������"}

  # ��TCP/IP Э��ջ�ĵ������ܻ�����ĳЩ���ܵ����ޣ�����ԱӦ���ڽ��г���˽�Ͳ��Ե�ǰ���½��д������
  # + ��SYN��ˮ����: 
  # SynAttackProtect = @{reg='HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters';name='EnablePMTUDiscovery';regtype="DWord";operator="eq";value=1;msg="���÷�syn��ˮ����"}
  # TcpMaxHalfOpen = @{reg='HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters';name='TcpMaxHalfOpen';regtype="DWord";operator="eq";value=500;msg="��������뿪������"}
  # TcpMaxHalfOpenRetried = @{reg='HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters';name='TcpMaxHalfOpenRetried';regtype="DWord";operator="eq";value=400;msg="���������ѷ���һ���ش��� SYN_RCVD ״̬�е�TCP������"}
  # + ��ֹDDOS�������� 
  # EnableICMPRedirect = @{reg='HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Tcpip\Parameters';name='EnableICMPRedirect';regtype="DWord";operator="eq";value=0;msg="��ֹDDOS��������,������ ICMP �ض���"}

  # + ���ò���ȷ����WSUS���Զ���WSUS��ַ������ (һ���д���ҵ�������Լ���WSUS����������)������Ҫ������http://wsus.weiyigeek.top��Ϊ��ҵ���Խ��ĵ�ַ
  # ���ò����顰�����Զ����¡�
  AUOptions = @{reg="HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU";name="AUOptions";regtype="DWord";operator="eq";value=3;msg="�Զ����ز��ƻ���װ(4)-��������3�Զ����ز�֪ͨ��װ"}
  AutomaticMaintenanceEnabled = @{reg="HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU";name="AutomaticMaintenanceEnabled";regtype="DWord";operator="eq";value=1;msg="�����Զ�ά��"}
  NoAutoUpdate = @{reg="HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU";name="NoAutoUpdate";regtype="DWord";operator="eq";value=0;msg="�ر����Զ���������"}
  ScheduledInstallDay = @{reg="HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU";name="ScheduledInstallDay";regtype="DWord";operator="eq";value=7;msg="�ƻ���װ����Ϊÿ����"}
  ScheduledInstallTime = @{reg="HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU";name="ScheduledInstallTime";regtype="DWord";operator="eq";value=1;msg="�ƻ���װʱ��Ϊ�賿1��"}
  # ���ò����飨ָ��Intranet Microsoft���·���λ�ã�
  UseWUServer = @{reg="HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU";name="UseWUServer";regtype="DWord";operator="eq";value=1;msg="ָ��Intranet Microsoft���·��񲹶�������"}
  WUServer = @{reg="HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate";name="WUServer";regtype="String";value="$WUSUServer";operator="eq";msg="���ü����µ�intranet���·���"}
  WUStatusServer = @{reg="HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate";name="WUStatusServer";regtype="String";value="$WUSUServer";operator="eq";msg="����Intranetͳ�Ʒ�����"}
  # UpdateServiceUrlAlternate = @{reg="HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate";name="UpdateServiceUrlAlternate";regtype="String";value="http://wsus.weiyigeek.top";operator="eq";msg="���ñ������ط�����"}
}



################################################################################################################################
# **********************#
# * ȫ�ֹ��ù�����������  *  
# **********************#
function F_Logging {
<#
.SYNOPSIS
F_Logging ����ȫ�ֹ���
.DESCRIPTION
��������ű�ִ�н�������ղ�ͬ����־�ȼ������ʾ���ͻ��ն��ϡ�
.EXAMPLE
F_Logging -Level [Info|Warning|Error] -Msg "��������ַ���"
#>
  param (
    [Parameter(Mandatory=$true)]$Msg,
    [ValidateSet("Info","Warning","Error")]$Level
  )

  switch ($Level) {
    Info { 
      Write-Host "[INFO] ${Msg}" -ForegroundColor Green;
    }
    Warning {
      Write-Host "[WARN] ${Msg}" -ForegroundColor Yellow;
    }
    Error { 
      Write-Host "[ERROR] ${Msg}" -ForegroundColor Red;
    }
    Default {
      Write-Host "[*] F_Logging ��־ Level �ȼ�����`n Useage�� F_Logging -Level [Info|Warning|Error] -Msg '��������ַ���'" -ForegroundColor Red;
    }
  }
}


Function F_IsCurrentUserAdmin
{ 
<#
.SYNOPSIS
F_IsCurrentUserAdmin ������ȫ�ֹ��ù���������
.DESCRIPTION
�жϵ�ǰ���е�powershell�ն��Ƿ����Աִ��,����ֵ true ���� false
.EXAMPLE
F_IsCurrentUserAdmin
#>
  $user = [Security.Principal.WindowsIdentity]::GetCurrent(); 
  (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) 
} 


function F_Detection {
<#
.SYNOPSIS
F_Detection ����: ȫ�ֹ��ù���������
.DESCRIPTION
�������ڼ�� config.cfg �ؼ����Ƿ�ƥ�䲢������Ӧ�Ľ��������ֵ 1 ���� 0��
.EXAMPLE
F_Detection -Value $Value -Operator $Operator -DefaultValue $DefaultValue
#>
  param (
    [Parameter(Mandatory=$true)]$Value,
    [Parameter(Mandatory=$true)]$Operator,
    [Parameter(Mandatory=$true)]$DefaultValue  
  )
  if ( $Operator -eq "eq" ) {
    if ( $Value -eq "$DefaultValue" ) {return 1;} else { return 0;}
  } elseif ($Operator -eq  "ne" ) {
    if ( $Value -ne $DefaultValue ) {return 1;} else { return 0;}
  } elseif ($Operator -eq  "le") {
    if ( $Value -le $DefaultValue ) {return 1;} else { return 0;}
  } elseif ($Operator -eq "ge") {
    if ( $Value -ge $DefaultValue ) {return 1;} else { return 0;}
  }
}


function F_GetRegPropertyValue {
<#
.SYNOPSIS
F_GetRegPropertyValue ����: ȫ�ֹ��ù�������������
.DESCRIPTION
�������ڻ�ȡָ������ֵ����Ԥ����Ľ��жԱȣ��������ؽ��Ϊ1����0��������������򷵻�NotExist��
.EXAMPLE
An example
#>
  param (
    [Parameter(Mandatory=$true)][String]$Key,
    [Parameter(Mandatory=$true)][String]$Name,
    [Parameter(Mandatory=$true)][String]$Operator,
    [Parameter(Mandatory=$true)]$DefaultValue
  )

  try {
    $Value = Get-ItemPropertyValue -Path "Registry::$Key" -Name $Name -ErrorAction Ignore -WarningAction Ignore 
    $Result = F_Detection -Value $Value -Operator $Operator -DefaultValue $DefaultValue
    return $Result
  } catch {
    F_Logging -Level Warning -Msg "[*] $Key - $Name - NotExist"
    return 'NotExist'
  }
}



function F_SeceditReinforce() {
<#
.SYNOPSIS
F_SeceditReinforce ������ʵ��ϵͳ������������ԱȺ��޸ġ�
.DESCRIPTION
��� config.cfg ��ȫ��������м�Ⲣ�޸ģ���Ҫ�漰ϵͳ�˺Ų������á�ϵͳ�¼���˲������á�ϵͳ����԰�ȫѡ�����á�����ϵͳ���û�Ȩ�޹����������
.EXAMPLE
F_SeceditReinforce
#>
  # - ϵͳ�˺Ų�������
  $Hash = $SysAccountPolicy.Clone()
  foreach ( $Name in $Hash.keys ) {
    $Flag = $Config | Select-String -AllMatches -Pattern "^$($Name.toString())"
    if ($Flag) {
      F_Logging -Level Info -Msg "[*] Update - $Name"
      $Line = $Flag -split " = "
      $Result = F_Detection -Value $Line[1] -Operator $SysAccountPolicy["$($Line[0])"].operator -DefaultValue $SysAccountPolicy["$($Line[0])"].value
      $NewLine = $Line[0] + " = " + $SysAccountPolicy["$($Line[0])"].value
      # - �ڲ�ƥ��ʱ���йؼ����滻����
      if ( -not($Result) -or $Line[0] -eq "NewGuestName" -or $Line[0] -eq "NewAdministratorName" ) {
	      write-host "    $Flag -->> $NewLine"
        # �˴������������ƥ��ϵͳ�˺Ų��������,��ֹ����
        $SecConfig = $SecConfig -replace "$Flag", "$NewLine" 
      }
    } else {
      F_Logging -Level Info -Msg "[+] Insert - $Name"
      $NewLine = $Name + " = " + $SysAccountPolicy["$Name"].value
      Write-Host "    $NewLine "
      # - �ڲ����ڸ�������ʱ���в���
      $SecConfig = $SecConfig -replace "\[System Access\]", "[System Access]`n$NewLine"
    }
  }

  # - ϵͳ�¼���˲�������
  $Hash = $SysEventAuditPolicy.Clone()
  foreach ( $Name in $Hash.keys ) {
    $Flag = $Config | Select-String $Name.toString()
    if ($Flag) {
      F_Logging -Level Info -Msg "[*] Update - $Name"
      $Line = $Flag -split " = "
      $Result = F_Detection -Value $Line[1] -Operator $SysEventAuditPolicy["$($Line[0])"].operator -DefaultValue $SysEventAuditPolicy["$($Line[0])"].value
      $NewLine = $Line[0] + " = " + $SysEventAuditPolicy["$($Line[0])"].value
      # - �ڲ�ƥ��ʱ���йؼ����滻����
      if (-not($Result)) {
        $SecConfig = $SecConfig -replace "$Flag", "$NewLine" 
      }
    } else {
      F_Logging -Level Info -Msg "[+] Insert - $Name"
      $NewLine = $Name + " = " + $SysEventAuditPolicy["$Name"].value
      Write-Host "  $NewLine"
      # - �ڲ����ڸ�������ʱ���в���
      $SecConfig = $SecConfig -replace "\[Event Audit\]", "[Event Audit] `n$NewLine"
    }
  }

  # - ϵͳ����԰�ȫѡ������ - #
  $Hash = $SysSecurityOptionPolicy.Clone()
  foreach ( $Name in $Hash.keys ) {
    $Flag = $Config | Select-String $Name.toString()
    if ($Flag) {
      F_Logging -Level Info -Msg "[*] Update - $Name"
      # Դ�ַ���
      $Line = $Flag -split "="
      # Ŀ���ַ���
      $Value = $SysSecurityOptionPolicy["$($Name)"].value -split "="
      $Result = F_Detection -Value $Line[1] -Operator $SysSecurityOptionPolicy["$($Name)"].operator -DefaultValue $Value[1] 
      $NewLine = $Line[0] + "=" + $Value[1]
      if (-not($Result)) {
        $SecConfig = $SecConfig -Replace ([Regex]::Escape("$Flag")),"$NewLine" 
      }
    } else {
      F_Logging -Level Info -Msg "[+] Insert - $Name"
      $NewLine = $SysSecurityOptionPolicy["$Name"].value
      Write-Host "   $NewLine"
      # ����������ƥ��ԭ�ַ���(ֵ��ѧϰ)
      $SecConfig = $SecConfig -Replace ([Regex]::Escape("[Registry Values]")),"[Registry Values]`n$NewLine"
    }
  }

  # - ����ϵͳ���û�Ȩ�޹����������
  $Hash = $SysUserPrivilegePolicy.Clone()
  foreach ( $Name in $Hash.keys ) {
    $Flag = $Config | Select-String $Name.toString()
    if ($Flag) {
      F_Logging -Level Info -Msg "[*] Update - $Name"
      $Line = $Flag -split " = "
      $Result = F_Detection -Value $Line[1] -Operator $SysUserPrivilegePolicy["$($Line[0])"].operator -DefaultValue $SysUserPrivilegePolicy["$($Line[0])"].value
      $NewLine = $Line[0] + " = " + $SysUserPrivilegePolicy["$($Line[0])"].value
      if (-not($Result)) {
        $SecConfig = $SecConfig -Replace ([Regex]::Escape("$Flag")), "$NewLine" 
      }
    } else {
      F_Logging -Level Info -Msg "[+] Insert - $Name"
      $NewLine = $Name + " = " + $SysUserPrivilegePolicy["$Name"].value
      Write-Host "    $NewLine"
      $SecConfig = $SecConfig -Replace ([Regex]::Escape("[Privilege Rights]")),"[Privilege Rights]`n$NewLine"
    }
  }
   # �����ɵı��ذ�ȫ����������䵽`secconfig.cfg`,���ӡ��ǳ�ע���ļ������ʽΪUTF16-LE,��ʱ��Ҫ���-Encoding������ָ��Ϊstring
   $SecConfig | Out-File secconfig.cfg -Encoding string
}


function F_SysRegistryReinforce()  {
<#
.SYNOPSIS
F_SysRegistryReinforce ���������ע�����ϵͳ������á�
.DESCRIPTION
��Բ���ϵͳע���ȫ��������SysRegistryPolicy��ϣ��ļ�ֵ���м�������á�
.EXAMPLE
F_SysRegistryReinforce 
#>
  # - ����ȼ�������ػ�������
  $Hash = $SysRegistryPolicy.Clone()
  foreach ( $Name in $Hash.keys ) {
    $Result = F_GetRegPropertyValue -Key $SysRegistryPolicy.$Name.reg -Name $SysRegistryPolicy.$Name.name -Operator $SysRegistryPolicy.$Name.operator -DefaultValue $SysRegistryPolicy.$Name.value
    F_Logging -Level Info -Msg "Get-ItemProperty -Path Registry::$($SysRegistryPolicy.$Name.reg)"
    if ( $Result -eq 'NotExist' ){
      # - �ж�ע������Ƿ���ڲ������򴴽�
      if (-not(Test-Path -Path "Registry::$($SysRegistryPolicy.$Name.reg)")){
        F_Logging -Level Info -Msg "���ڴ��� $($SysRegistryPolicy.$Name.reg) ע�����......"
        New-Item -Path "registry::$($SysRegistryPolicy.$Name.reg)" -Force
      }
      # - ���ܵ�ö��ֵ����"String��ExpandString��Binary��DWord��MultiString��QWord��Unknown"
      New-ItemProperty -Path "Registry::$($SysRegistryPolicy.$Name.reg)" -Name $SysRegistryPolicy.$Name.name -PropertyType $SysRegistryPolicy.$Name.regtype -Value $SysRegistryPolicy.$Name.value
    } elseif ( $Result -eq 0 ) {
      Set-ItemProperty -Path "Registry::$($SysRegistryPolicy.$Name.reg)" -Name $SysRegistryPolicy.$Name.name -Value $SysRegistryPolicy.$Name.value
    }
  }
}


function F_ServiceManager() {
<#
.SYNOPSIS
F_ServiceManager �����������ϵͳ����ط���������
.DESCRIPTION
��Ҫ��ϵͳ��ĳЩ�������ֹͣ����
.EXAMPLE
F_ServiceManager -Name server -Operator restart -StartType Automatic
#>
  param (
    [Parameter(Mandatory=$true)]$Name,
    [ValidateSet("Start","Stop","Restart")]$Operator,
    [ValidateSet("Automatic","Manual","Disabled","Boot","System")]$StartType
  )
  # - ��֤�����Ƿ����
  F_Logging -Level Info -Msg "���ڶ� $Name ������в�������......."
  $ServiceStatus = (Get-Service $Name -ErrorAction SilentlyContinue).Status
  if( -not($ServiceStatus.Length) ) {
    F_Logging -Level Error -Msg "$Name Service is not exsit with current system!!!!!!"
    return
  }

  # - ����$Operator��������������ֹͣ������
  switch ($Operator) {
    Start { 
      if ( "$ServiceStatus" -eq "Stopped" ) {
        F_Logging -Level Info -Msg "�������� $Name ����";Start-Service -Name $Name -Force
      }
    }
    Stop { 
      if ( "$ServiceStatus" -eq "Running" ) {
        F_Logging -Level Warning -Msg "����ֹͣ $Name ����";Stop-Service -Name $Name -Force
      }
    }
    Restart {
      F_Logging -Level Warning -Msg "�������� $Name ����";Restart-Service -Name $Name -Force
    }
    Default { F_Logging -Level Info -Msg "δ�� $Name �������κβ���!" }
  }
  

  # - ����$StartType���÷�����������
  switch ($StartType) {
    Automatic { Set-Service -Name $Name -StartupType Automatic}
    Manual { Set-Service -Name $Name -StartupType Manual }
    Disabled { Set-Service -Name $Name -StartupType Disabled}
    Boot { Set-Service -Name $Name -StartupType Boot}
    System {Set-Service -Name $Name -StartupType System }
    Default {F_Logging -Level Info -Msg "δ�� $Name �������κ��������ò���!"}
  }
}



Function F_ExtentionReinforce() {
<#
.SYNOPSIS
F_ExtentionReinforce �����������ϵͳ���ް취ͨ��ע����Լ���������õĽ��ڴ˴�ִ�С�
.DESCRIPTION
ִ��ϵͳ�ӹ̵����������б���PowerShell����cmd�������
.EXAMPLE
F_ExtentionReinforce 
#>

  # [+] ����135��139�˿�(���޲�ѯ������������йرգ�������֪����С��� Issue Ӵ)
  # 135 -> dcomcnfg -> ������� -> �ҵĵ��� -> ���� -> {Ĭ�����ԣ�ȡ�������ֲ�ʽCOM;Ĭ��Э�飬ɾ���������ӵ�TCP/IP}
  # HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Ole\EnableDCOM��ֵ��Ϊ��N��
  # HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Rpc\ClientProtocols ��ɾ����ncacn_ip_tcp��
  # 139 -> �������� -> ��̫������ -> TCP/IPV4���� -> �߼� -> Wins -> {ȡ������LMHOSTS������TCP/IP�ϵ�NETBIOS}

  # [+] ���ù�������Լ�ɾ����ǰ���������й���,���رռ���445�˿�
  F_ServiceManager -Name Spooler -Operator Stop -StartType Disabled             # Print Spooler: �÷����ں�ִ̨�д�ӡ��ҵ���������ӡ���Ľ�����
  F_ServiceManager -Name LanmanWorkstation -Operator Stop -StartType Disabled   # Workstation: ʹ�� SMB Э�鴴����ά���ͻ���������Զ�̷�����֮������ӡ�
  F_ServiceManager -Name LanmanServer -Operator Stop -StartType Disabled        # Server: ֧�ִ˼����ͨ��������ļ�����ӡ���������ܵ�����
  (gwmi -class win32_share).delete()                                            # ������ʽ (Get-WmiObject -class win32_share).delete()

  # [+] �������緢�ַ��� Function Discovery Resource Publication ,���رռ���5357�˿�
  F_ServiceManager -Name FDResPub -Operator Stop -StartType Disabled

  # [+] ����WindowsԶ�̹���(WinRM)���� Windows Remote Management (WS-Management) ,���رռ���5985�˿� ��ע���ڰ�װĳЩ���ʱ��Ҫ�����÷���
  F_ServiceManager -Name WinRM -Operator Stop -StartType Manual

  # [+] ���ò���ϵͳʱ��ͬ��
  F_ServiceManager -Name w32tm -Operator Start -StartType Automatic             # Windows Time ά���������ϵ����пͻ��˺ͷ�������ʱ�������ͬ��
  w32tm /config /syncfromflags:MANUAL /manualpeerlist:"192.168.12.254,0x08 192.168.10.254,0x08" /update
  w32tm /resync /rediscover
  w32tm /query /peers

  # [+] ����&�ر�windows����ǽ
  # �رշ���ǽnetsh advfirewall set allprofiles state off
  netsh advfirewall set allprofiles state on

  # [+] ϵͳ�������ǽ��ع�������
  # ���á����߽����ļ��ʹ�ӡ������(�������� - ICMPv4-In) �����������
  # Enable-NetFirewallRule -Name FPS-ICMP4-ERQ-In
  Disable-NetFirewallRule  -Name FPS-ICMP4-ERQ-In
  Get-NetFirewallRule -Name "CustomSecurity-Remote-Desktop-Port" -ErrorAction SilentlyContinue
  if (-not($?)) {
    # ���������������� Remote-Desktop-Port ��39393�˿ڡ�
    New-NetFirewallRule -Name "CustomSecurity-Remote-Desktop-Port" -DisplayName "CustomSecurity-Remote-Desktop-Port" -Description "CustomSecurity-Remote-Desktop-Port" -Direction Inbound -LocalPort 39393 -Protocol TCP -Action Allow -Enabled True
    New-NetFirewallRule -Name "CustomSecurity-Port" -DisplayName "CustomSecurity-Port" -Description "CustomSecurity-135-137-138-139-Port" -Direction Inbound -LocalPort 135,137,138,139 -Protocol TCP -Action Block -Enabled True
  }
}

# Function F_SensitiveFile() {
# <#
# .SYNOPSIS
# F_SensitiveFile �����������ϵͳ����ط���������ļ���⡣���������䣩
# .DESCRIPTION
# ��� config.cfg ��ȫ��������м�Ⲣ�޸�
# .EXAMPLE
# F_SensitiveFile 
# #>
#   $SensitiveFile = @("%systemroot%\system32\inetsrv\iisadmpwd")
#   if (Test-Path -Path $SensitiveFile[$i]) {
#     # 1.ɾ�������κ��ļ���չ�����ļ�
#     Remove-Item C:\Test\*.* # == Del C:\Test\*.*
#     Remove-Item -Path C:\Test\file.txt -Force 

#     # 2.ɾ�������������ļ�����Ŀ¼
#     Remove-Item -Path C:\temp\DeleteMe -Recurse # �ݹ�ɾ�����ļ����е��ļ�
#     }
# }

function Main {
<#
.SYNOPSIS
main ��������ִ�����
.DESCRIPTION
����������д����ؼ��ӹ̺���
.EXAMPLE
main
#>

F_Logging -Level Info -Msg "#################################################################################"
F_Logging -Level Info -Msg "- @Desc: Windows Server ��ȫ���ò��Ի��߼ӹ̽ű� [������Github�ϳ�������-star]"
F_Logging -Level Info -Msg "- @Author: WeiyiGeek"
F_Logging -Level Info -Msg "- @Blog: https://www.weiyigeek.top"
F_Logging -Level Info -Msg "- @Github: https://github.com/WeiyiGeek/SecOpsDev/tree/master/OS-����ϵͳ/Windows"
F_Logging -Level Info -Msg "#################################################################################`n"

$StartTime = Get-date -Format 'yyyy-M-d H:m:s'

# 1.��ǰϵͳ���������ļ����� (ע�����ϵͳ����ԱȨ������) 
F_Logging -Level Info -Msg "- ���ڼ�⵱ǰ���е�PowerShell�ն��Ƿ����ԱȨ��...`n"
$flag = F_IsCurrentUserAdmin
if (!($flag)) {
  F_Logging -Level Error -Msg "- �ű�ִ�з�������,��ʹ�ù���ԱȨ�����иýű�..����: Start-Process powershell -Verb runAs....`n"
  F_Logging -Level Warning -Msg "- �����˳�ִ�иýű�......`n"
  return
}

# 2.������ǰϵͳ���������ļ�����֤�ļ��Ƿ�����Լ�ԭʼ�����ļ����ݡ�
secedit /export /cfg config.cfg /quiet
start-sleep 3
if ( -not(Test-Path -Path config.cfg) ) {
  F_Logging -Level Error -Msg "- ��ǰϵͳ���������ļ� config.cfg ������,����......"
  F_Logging -Level Warning -Msg "- �����˳�ִ�иýű�......"
  return
} else { 
  Copy-Item -Path config.cfg -Destination config.cfg.bak -Force
}
$Config = Get-Content -path config.cfg
$SecConfig = $Config.Clone()


# 6.ϵͳ��չ������ð�ȫ�ӹ� (��ֹ����ǽ���ò���Ч)
F_ExtentionReinforce

# 3.����ϵͳ�������ð�ȫ�ӹ�
F_SeceditReinforce

# 4.��ϵͳ�������ð�ȫ�ӹ���ɺ����ɵ�secconfig.cfg�����ϵͳ�����С�
secedit /configure /db secconfig.sdb /cfg secconfig.cfg

# 5.����ϵͳע���������ð�ȫ�ӹ�
F_SysRegistryReinforce

# 7.����ִ�����
$EndTime = Get-date -Format 'yyyy-M-d H:m:s'
F_Logging -Level Info -Msg "- �ò���ϵͳ��ȫ�ӹ������......`n��ʼʱ�䣺${StartTime}`n���ʱ��: ${EndTime}"
}

Main