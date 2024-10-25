param([String]$username, [String]$password, [String]$url, [String]$ssrsfoldername)

$secstr = New-Object -TypeName System.Security.SecureString
$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr

#robocopy /e /xo "$env:Temp\ReportingServicesTools" "$env:Windir\System32\WindowsPowerShell\v1.0\Modules\ReportingServicesTools" 
#Import-Module -Name ReportingServicesTools -Global -Force

Write-Output "Connecting to SSRS Server..."
Connect-RsReportServer -ReportServerUri $url -Credential $cred

#Output ALL Catalog items to file system
Write-Output "Download Reports..."
Out-RsFolderContent  -RsFolder $ssrsfoldername -Destination 'C:\SSRS_Out' -Recurse

Write-Output "Finished"

