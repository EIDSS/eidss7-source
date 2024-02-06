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
:r .\Scripts\Current\DML_UAT_blnSystem_Update.sql
:r .\Scripts\Current\Update.Default_Employee_Group_Activate.sql
:r .\Scripts\Current\DML_Add_XSITE_Dashboard_Documents_for_GG-AZ.sql
:r .\Scripts\Current\Update-trtResourceTranslation-intRowStatus.sql