<#
	.SYNOPSIS

	Uploads new reports and updates existing reports to the specified SSRS folder.

	
	.PARAMETER username

	A domain user that can administer SSRS reports.  Specify NULL to use the currently logged in user's credentials.

	
	.PARAMETER password

	The account password.  Specify NULL to use the currently logged in user's credentials.

	
	.PARAMETER url

	The uri to the SSRS reporting services web service.

	
	.PARAMETER ssrsfoldername

	The SSRS folder where reportings will be placed when uploaded.  If the folder exists, it will be deleted along with any reports currently within the folder.

	
	.PARAMETER sourcefolderpath

	Path to folder which contains the reports to upload.

	
	.PARAMETER newdspath

	.The SSRS datasource folder and datasource name that will be assigned to each report after upload.

	
	.EXAMPLE

	.\UploadReports.ps1 -username domain\user -password pword -url http://reportserver/reportserver -ssrsfoldername GG -sourcefolderpath d:\reports -newdspath "/Data Sources/EIDSS7_RPT_DT"

	Description:
	------------
	Upload all reports in the d:\reports directory and places them into the /GG ssrs report folder and assigns the "Data Sources/EIDSS7_RPT_DT" datasource to each report.
	

	.EXAMPLE

	.\UploadReports.ps1 -username domain\user -password pword -url http://reportserver/reportserver -ssrsfoldername GG_ARCHIVE -sourcefolderpath d:\reports -newdspath "/Data Sources/EIDSS7_RPT_ARCHIVE_DT"

	Description:
	------------
	Upload all reports in the d:\reports directory and places them into the /GG_ARCHIVE ssrs report folder and assigns the "Data Sources/EIDSS7_RPT_ARCHIVE_DT" datasource to each report.


	.NOTES

	This script relies on the ReportingServicesTools API found on GitHub. https://github.com/microsoft/ReportingServicesTools

	Check the Install section for installation instructions.

	If none of these options work, follow the instructions below:

	In case the previous installation fails, following the steps below to install manually:
	
	1. Determine the install path.  You can determine where to install your module using one of the paths stored in the $ENV: PSModulePath variable. To do this, open a PowerShell window and run the command:  $Env: PSModulePath.
	2. The output displays the following path as shown in Figure 3.0 below:

		C:\Users\Administrator\Documents\WindowsPowerShell\Modules
		C:\Program Files\WindowsPowerShell\Modules
		C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules\

	Use the first path if you want the module to be available for a specific user account on the computer. Use the second path if you’re going to make the module available for all users on the computer. The third path is the path Windows uses for built-in modules already installed with the Windows OS. Microsoft recommends you avoid using this location. So you are left with the first or second path.

	Using one of these paths means that PowerShell can automatically find and load your module when a user calls it in their code. However, you may also wish to add your paths but stick with the first two paths unless necessary. If you store your module somewhere else, you can explicitly let PowerShell know by passing in the location of your module as a parameter when you call Install-Module. If you see other paths listed in your environment variable, it may be from your installed applications. Some applications install PowerShell commands and automatically add those to the variable. Now that we know where to put new modules let’s proceed to the next step.

	3. Copy the new module to the path: Now download the PowerShell module from your preferred site and copy it into one of the two paths identified in step 1 above. In this example, we will make it available to all users on the computer to copy it to the directory C:\Program Files\WindowsPowerShell\Modules. Once completed, you can check if the new module is listed as available to PowerShell by running the command: Get-Module -ListAvailable.

#>

param([String]$username, [String]$password, [String]$url, [String]$ssrsfoldername, [String]$sourcefolderpath, [string]$newdspath)

try{
	$secstr = New-Object -TypeName System.Security.SecureString
	$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
	$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr

	Connect-RsReportServer -ReportServerUri $url -Credential $cred

	try{
		#Upload the reports to the server...
		Write-RsFolderContent -ReportServerUri $url -Path $sourcefolderpath -RsFolder /$ssrsfoldername -Verbose | Where-Object TypeName -eq Report

	}
	catch{
		# if we got an error stating that the report foder couldn't be found, then create it and try the operation again.'
		if (($_.Exception.Message) -like '*cannot be found*')
		{
			Write-Output "$ssrsfoldername wasn't found, creating..."
			New-RsFolder -ReportServerUri $url -Path / -Name $ssrsfoldername -Verbose 
			Write-RsFolderContent -ReportServerUri $url -Path $sourcefolderpath -RsFolder /$ssrsfoldername -Verbose | Where-Object TypeName -eq Report
		}
	}
	
	$counter = 0

	Write-Output "Getting folder content..."
	#Enumerate all reports in the folder and change their datasource reference.
	$reports = Get-RsFolderContent -ReportServerUri $url -rsFolder /$ssrsfoldername | Where-Object TypeName -eq Report
	foreach( $report in $reports)
	{
		$rptds = Get-RsItemDataSource -RsItem $report.Path -Verbose
		Set-RsDataSourceReference -Path $report.Path -DatasourceName $rptds.Name -DatasourcePath $newdspath -Verbose
		$counter++
	}
	Write-Output "Uploaded $counter reports."
	Write-Host "Finished executing script."
}
catch{
	Write-Host ($_.Exception.Message)
	Write-Output "Script did not complete.  See error above."
}
finally{
}