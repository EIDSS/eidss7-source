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

:r .\Scripts\Current\Update.trtBaseReference-5531_change_.sql
:r .\Scripts\Current\Insert.trtResource-SAUC31.sql

/* Run in all environments, and add to the master script for migration */
:r .\Scripts\Current\Update.trtBaseReference-5480.sql

/* Run in all environments */
:r .\Scripts\Current\Update.tlbMaterial-5430-3.sql



