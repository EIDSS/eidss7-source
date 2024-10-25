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

:r .\Scripts\Current\Script.Update-LkupEIDSSAppObject-4383.sql
:r .\Scripts\Current\Script.Update-trtResourceTranslation-4463.sql
:r .\Scripts\Current\Script.Insert-trtResource-SAUC60PageHeading.sql
:r .\Scripts\Current\Script.Insert-trtResourceSetToResource-SAUC60PageHeading.sql
:r .\Scripts\Current\Script.Insert-trtResourceTranslation-SAUC60PageHeading.sql
:r .\Scripts\Current\Script.Insert-trtEventType-5189.sql
:r .\Scripts\Current\Script.Insert-trtEventType-4888.sql
:r .\Scripts\Current\Script.Update-EventSubscription-298.sql