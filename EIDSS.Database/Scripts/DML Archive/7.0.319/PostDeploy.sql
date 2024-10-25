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

:r .\Scripts\Current\update.trtBaseReference-AbberationAnalysisMethod_4744_.sql
:r .\Scripts\Current\AuditTables_AddNewColumn.sql
:r .\Scripts\Current\Insert.tauTable-HumanDiseaseReportRelationship.sql
:r .\Scripts\Current\Insert.tauColumn-HumanDiseaseReportRelationship.sql
:r .\Scripts\Current\update.trtBaseReference-ParameterNameUpdates.sql
:r .\Scripts\Current\update.trtBaseReference-ReferenceUpdates.sql
