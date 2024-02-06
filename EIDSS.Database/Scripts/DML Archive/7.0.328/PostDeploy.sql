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

:r .\Scripts\Current\Update.Activate_Default_Employee_Group_Correction.sql
:r .\Scripts\Current\Update.tlbMaterial_strCalculatedCaseID_5430.sql
:r .\Scripts\Current\Update.trtBaseReference_intHACode_5482.sql
:r .\Scripts\Current\INSERT.ffFormTemplate_DefaultOutbreakTemplates_5519.sql
:r .\Scripts\Current\Update-OutbreakStatusValues.sql
:r .\Scripts\Current\DML_Settlement_AdminLevelUpdates.sql