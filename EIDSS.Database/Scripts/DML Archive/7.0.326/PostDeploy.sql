/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

/* Include a script from another file 
    - add your DML scripts here 
    - be sure you are in SQLCMD mode when you add the line
*/

:r .\Scripts\Current\Insert-AdminUnits-Resources.sql
:r .\Scripts\Current\Insert-trtResourceToResourceSet-WeeklyReportingForm.sql
:r .\Scripts\Current\Update-trtBaseReference-UserGroupDashboardIcons.sql
:r .\Scripts\Current\Update-ffParameters.sql
:r .\Scripts\Current\DML_Populate_gisWHOMap.sql

/* run in UAT only */
:r .\Scripts\Current\DML_UAT_ResourceReference_Update.sql
:r .\Scripts\Current\DML_UAT_LKUPEIDSSAppObject_Update.sql
:r .\Scripts\Current\Insert-HelpFile-Script.sql
