powershell-php-install
======================

Powershell script to install PHP + WinCache on IIS

1.Download the required version of PHP from windows.php.net.  Make sure to use the non-thread-safe version, and pick the zip file rather than the installer.  Unzip the contents to a consistent directory accessible from the PowerShell script (for example, \php-5.4.19).

2.Modify the following PowerShell variable to point to the location from step 1: $phpInstallMedia

3.Modify the following PowerShell variable to indicate the PHP version: $php_version

4.Modify the following PowerShell variables to install PHP and configure logs and temp folders for your environment: $php_install, $php_log, $php_temp

5.Download the appropriate version of PHP Manager from http://phpmanager.codeplex.com.  Unzip it to a consistent directory accessible from the PowerShell script.

6.Modify the following PowerShell variable to indicate where the PHP Manager MSI is placed: $phpmgrInstallMedia

7.Download WinCache from http://www.iis.net/downloads/microsoft/wincache-extension, unzip it, and place it into a folder named the same as the PHP version above.

8.Modify the following PowerShell variables to configure default folders for IIS in your environment: $web_root, $web_log

After those variables are set to match your environment, the script should install PHP, WinCache, and reconfigure the default WWW root and WWW log folders.  If you get an error about execution policy, using set-executionpolicy in PowerShell to adjust the security parameters should resolve that easily.
