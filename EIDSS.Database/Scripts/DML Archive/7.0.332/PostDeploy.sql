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

:r .\Scripts\Current\Insert-HumanAddlinfo-5457.sql
:r .\Scripts\Current\Update.tlbMaterial_5430.sql
:r .\Scripts\Current\Update-trtBaseReference-5559.sql
:r .\Scripts\Current\Update.tlbMaterial_ReadOnlyFixForLabSource.sql
:r .\Scripts\Current\Update-trtBaseReferencePIN-5594.sql
:r .\Scripts\Current\Update-tlbVetCase-NoDiagnosis-5368.sql
:r .\Scripts\Current\Update.tlbMaterial_LabDiseasePopulate.sql
:r .\Scripts\Current\insert.Populate_Custom_Roles_For_AllSites.sql
:r .\Scripts\Current\Insert.trtResource-HumanCaseReport.sql