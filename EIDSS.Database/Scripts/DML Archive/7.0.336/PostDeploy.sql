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


:r .\Scripts\Current\Update-ffParameter-idfsEditor-5457.sql
:r .\Scripts\Current\Insert.tauColumn_LaboratoryModuleDataAudit.sql
:r .\Scripts\Current\Insert-trtStringTranslation-5616.sql
:r .\Scripts\Current\Rebuild tlbxSiteDocumentMap Table.sql
:r .\Scripts\Current\Update-ASSpeciesType-5525.sql
:r .\Scripts\Current\Update-DashboardItems.sql
:r .\Scripts\Current\Update.trtBaseReference-5531.sql
:r .\Scripts\Current\Insert-trtResourceTranslation-5526.sql
:r .\Scripts\Current\Update_ZooEntomologist.sql
:r .\Scripts\Current\Insert.tauColumn_OrganizationDataAudit.sql
:r .\Scripts\Current\Update-FarmOwnerTypes.sql