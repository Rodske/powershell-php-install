#Download the non-thread safe version of php from http://windows.php.net/download.
#Extract the zip file to a consistent folder for install.
$phpInstallMedia = "php-5.4.19"
#Specify PHP Version
$php_version = "5.4.19"
#Specify PHP install location (version specific subdirectory will be created)
$php_install = "d:\php"
#Specify PHP log location
$php_log = "d:\phplog"
#specify PHP temp location
$php_temp = "d:\phptemp"
#Download PHP manager from http://phpmanager.codeplex.com/
$phpmgrInstallMedia = "phpmanagerforiis-1.2.0-x64.msi /q"
#download WinCache from http://www.iis.net/downloads/microsoft/wincache-extension 
#and place it in the folder php_version
$wincacheDLL = "$php_version\php_wincache.dll"
#Specify desired Webroot location
$web_root = "d:\wwwsites"
#Specify desired weblogs location
$web_log = "d:\wwwlogs"

#Install IIS Components for PHP over FastCGI 
start-process "c:\windows\system32\pkgmgr.exe" -ArgumentList "/iu:IIS-WebServerRole;IIS-WebServer;IIS-CommonHttpFeatures;IIS-StaticContent;IIS-DefaultDocument;IIS-DirectoryBrowsing;IIS-HttpErrors;IIS-HealthAndDiagnostics;IIS-HttpLogging;IIS-LoggingLibraries;IIS-RequestMonitor;IIS-Security;IIS-RequestFiltering;IIS-HttpCompressionStatic;IIS-WebServerManagementTools;IIS-ManagementConsole;WAS-WindowsActivationService;WAS-ProcessModel;WAS-NetFxEnvironment;WAS-ConfigurationAPI;IIS-CGI" -Wait
#Set ACLs for PHP for IIS to process it appropriately
if ((Test-Path -path $php_install) -ne $True) {
    new-item -type directory -path $php_install
    $acl = get-acl $php_install
    $ar = new-object system.security.accesscontrol.filesystemaccessrule("IIS AppPool\DefaultAppPool", "ReadAndExecute", "ContainerInherit, ObjectInherit", "None","Allow")
    $acl.setaccessrule($ar)
    $ar = new-object system.security.accesscontrol.filesystemaccessrule("Users", "ReadAndExecute", "ContainerInherit, ObjectInherit", "None","Allow")
    $acl.setaccessrule($ar)
    set-acl $php_install $acl
}
copy-item $phpInstallMedia -destination "$php_install\$php_version" -recurse
if ((Test-Path -path $php_log) -ne $True) {
    new-item -type directory -path $php_log
    $acl = get-acl $php_log
    $ar = new-object system.security.accesscontrol.filesystemaccessrule("Users","Modify","Allow")
    $acl.setaccessrule($ar)
    $ar = new-object system.security.accesscontrol.filesystemaccessrule("IIS AppPool\DefaultAppPool", "Modify", "ContainerInherit, ObjectInherit", "None","Allow")
    $acl.setaccessrule($ar)
    set-acl $php_log $acl
}
if ((Test-Path -path $php_temp) -ne $True) {
    new-item -type directory -path $php_temp
    $acl = get-acl $php_temp
    $ar = new-object system.security.accesscontrol.filesystemaccessrule("Users","Modify","Allow")
    $acl.setaccessrule($ar)
    $ar = new-object system.security.accesscontrol.filesystemaccessrule("IIS AppPool\DefaultAppPool", "Modify", "ContainerInherit, ObjectInherit", "None","Allow")
    $acl.setaccessrule($ar)
    set-acl $php_temp $acl
}
#Install PHP Manager for IIS 
start-process "c:\windows\system32\msiexec.exe" -ArgumentList "/i $phpmgrInstallMedia /q" -Wait
if ( (Get-PSSnapin -Name PHPManagerSnapin -ErrorAction SilentlyContinue) -eq $null )
{
    Add-PsSnapin PHPManagerSnapin 
}
#Copy Wincache over to extensions directory 
copy-item $wincacheDLL "$php_install\$php_version\ext"
New-PHPVersion -ScriptProcessor "$php_install\$php_version\php-cgi.exe"
#Configure Home Office Settings
Set-PHPSetting -name date.timezone -value "America/Chicago"
Set-PHPSetting -name upload_max_filesize -value "10M"
#Move logging and temp space to e:
Set-PHPSetting -name upload_tmp_dir -value $php_temp
set-phpsetting -name session.save_path -value $php_temp
Set-PHPSetting -name error_log -value "$php_log\php-errors.log"
set-phpextension -name php_wincache.dll -status enabled

if ((Test-Path -path $web_root) -ne $True) {
    new-item -type directory -path $web_root
    $acl = get-acl $web_root
    $ar = new-object system.security.accesscontrol.filesystemaccessrule("Users", "ReadAndExecute", "ContainerInherit, ObjectInherit", "None","Allow")
    $acl.setaccessrule($ar)
    set-acl $web_root $acl
}

if ((Test-Path -path $web_log) -ne $True) {
    new-item -type directory -path $web_log
    $acl = get-acl $web_log
    $ar = new-object system.security.accesscontrol.filesystemaccessrule("Users", "ReadAndExecute", "ContainerInherit, ObjectInherit", "None","Allow")
    $acl.setaccessrule($ar)
    set-acl $web_log $acl
}
import-module WebAdministration
set-ItemProperty 'IIS:\Sites\Default Web Site\' -name physicalPath -value $web_root
set-ItemProperty 'IIS:\Sites\Default Web Site\' -name logFile.directory -value $web_log
stop-website 'Default Web Site' 
start-website 'Default Web Site'
