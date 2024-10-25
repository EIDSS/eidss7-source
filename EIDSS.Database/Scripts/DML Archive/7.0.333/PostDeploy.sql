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



:r .\Scripts\Current\Insert-trtResource-5491.sql
:r .\Scripts\Current\Insert.tauTable_5408.sql
:r .\Scripts\Current\Insert.tauColumn_5408.sql
:r .\Scripts\Current\Insert.OutbreakSpeciesParameter_5584_Human.sql
:r .\Scripts\Current\Insert.OutbreakCaseReport_5584.sql
:r .\Scripts\Current\Insert.Resource_PINMessages.sql
:r .\Scripts\Current\Update-ffParameterTypes-5457.sql
:r .\Scripts\Current\Update-tlbTestingAndtlbHumanCase-5457.sql
:r .\Scripts\Current\Insert.trtResource-OutbreakContactsList.sql
:r .\Scripts\Current\Insert.trtResoruce_5526.sql
:r .\Scripts\Current\Update-ffParameter-CheckboxEditorType-5457.sql
