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
:r .\Scripts\Current\Insert-trtBaseReference-Defect5571.sql

/* ONLY RUN IN QA-GG ENV */
:r .\Scripts\DML Archive\7.0.329\QAGG_DML_Translation_ResourceReference_Deploy.sql

/* ONLY RUN IN INTERNAL UAT AND REGRESSION ENV - NOT NECESSARY IN COUNTRY, ALREADY RUN */
:r .\Scripts\DML Archive\7.0.329\UAT_DML_Translation_ResourceReference_Deploy.sql

/* ONLY RUN IN AUTO2 ENV */
:r .\Scripts\DML Archive\7.0.329\Auto2_DML_Translation_ResourceReference_Deploy.sql

/* ONLY RUN IN REGRESSION ENV */
:r .\Scripts\DML Archive\7.0.329\Regression_DML_Translation_ResourceReference_Deploy.sql