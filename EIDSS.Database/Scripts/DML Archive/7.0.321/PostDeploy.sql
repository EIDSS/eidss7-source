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
:r .\Scripts\Current\Update-trtResourceTranslation-idfsResource929-Georgian.sql
:r .\Scripts\Current\Update-trtStringNameTranslation_5365.sql
:r .\Scripts\Current\Update-WHOExportMenu.sql
:r .\Scripts\Current\13Dec2022_DML.sql
:r .\Scripts\Current\Update-SQLServerDeploymentLog.sql