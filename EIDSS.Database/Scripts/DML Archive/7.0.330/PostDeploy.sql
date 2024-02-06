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

:r .\Scripts\Current\Delete-trtResourceTranslation-Cleanup-Bad-idfsLanguage.sql
:r .\Scripts\Current\Insert.trtResourceSetToResource-5510.sql
:r .\Scripts\Current\DML_WeeklyReportingForm_translationUpdate.sql
:r .\Scripts\Current\DML_AccessRule_AllEnvironments.sql
:r .\Scripts\Current\DML_Update.OutbreakCaseReport_5430.sql
:r .\Scripts\Current\Insert.trtResrouce-5526.sql
:r .\Scripts\Current\Update.trtBaseReference-5531.sql
:r .\Scripts\Current\DML_Add_XSITE_Dashboard_Documents_for_GG-AZ.sql
:r .\Scripts\Current\InsertNewResource_AddRecordModel_3973.sql

/* Only run in UAT external to correct data migration issue */
:r .\Scripts\Current\Update-tlbFarmActual-tlbFarm-5496.sql


/* Only run in UAT external - already run in internal environments */
:r .\Scripts\Current\UAT_DML_Translation_Reference_Deploy20Jan.sql

/* Already run in Auto2 - just for reference.  No other runs necessary */
:r .\Scripts\Current\DML_SystemFunction_DeployToAuto2.sql