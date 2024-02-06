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

:r .\Scripts\Current\Insert.tauTable-tlbReportForm.sql
:r .\Scripts\Current\Insert.tauColumn-tlbReportForm.sql
:r .\Scripts\Current\Updates-Report_translations_5107.sql
:r .\Scripts\Current\Insert.tauTable-MonitoringSessionToSampleType.sql
:r .\Scripts\Current\Insert.tauColumn-MonitoringSessionToSampleType.sql
:r .\Scripts\Current\Insert.tauTable-tlbMonitoringSessionToMaterial.sql
:r .\Scripts\Current\Insert.tauColumn-tlbMonitoringSessionToMaterial.sql
:r .\Scripts\Current\Insert.trtResourceSetToResource-CSID.sql
:r .\Scripts\Current\dbo.update-trtResourceTranslation.sql
:r .\Scripts\Current\Updates-ffParameter_HEI Acute Viral Hepatitis A.sql
:r .\Scripts\Current\Updates-ffParameter_HEI Acute Viral Hepatitis E.sql
:r .\Scripts\Current\Updates-ffParameter_Patient younger than 12 months.sql
:r .\Scripts\Current\Updates-ffParameter_Anthrax Pulmonary.sql
:r .\Scripts\Current\Updates-ffParameter_HEI Bacteraemia NOS Sepsis.sql
:r .\Scripts\Current\Updates-ffParameter_Anti-botulinum serum.sql
:r .\Scripts\Current\Updates-ffParameter_Brucellosis Abortus.sql
:r .\Scripts\Current\Updates-ffParameter_Type of contacted sick animal.sql
:r .\Scripts\Current\DML_ResourceUpdates_06Dec2022.sql
:r .\Scripts\Current\Updates_Human_ILI_AggregateForm_3973.sql
:r .\Scripts\Current\Insert_Active_Surveillance_Campaign_4288.sql
:r .\Scripts\Current\Insert-HelpFile-Script.sql
:r .\Scripts\Current\Insert.tauTable-VetDiseaseReportRelationship.sql
:r .\Scripts\Current\Lab Calculated Case ID Update for Migrated Data.sql
:r .\Scripts\Current\Lab Calculated Human Name Update for Migrated Data.sql
:r .\Scripts\Current\Lab Disease ID Populate.sql
:r .\Scripts\Current\GG_SpecificRoles.sql
