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

:r .\Scripts\Current\Update-trtStringNameTranslation_5365.sql
:r .\Scripts\Current\Update-trtStringNameTranslation_5372.sql
:r .\Scripts\Current\13Dec2022_DML.sql
:r .\Scripts\Current\Insert-ResourceSet445.sql
:r .\Scripts\Current\Insert-trtResourceSetToResource_WHOExport.sql
:r .\Scripts\Current\Update-trtBaseReference_FF_NumericTypes.sql
:r .\Scripts\Current\Update-trtResourceTranslation-5373.sql
:r .\Scripts\Current\Update-trtResourceTranslation-5374.sql
:r .\Scripts\Current\Insert-trtResourceTranslation-idfsResource4648-GGAJ.sql
:r .\Scripts\Current\Update-SQLServerDeploymentLog.sql
:r .\Scripts\Current\Update-SystemAndSecurityLogMenus.sql
:r .\Scripts\Current\Update-trtResourceTranslation-idfsResource937-GGAJ.sql
:r .\Scripts\Current\Update-WHOExportMenu.sql


