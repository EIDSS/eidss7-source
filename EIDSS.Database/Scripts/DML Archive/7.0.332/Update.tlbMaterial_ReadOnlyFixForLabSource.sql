/*
Author:			Stephen Long
Date:			02/02/2023
Description:	Update blnReadOnly to 0 where laboratory module created the samples; prior bug in the app.
Note:           -Be sure to wrap your insert statements in "IF NOT EXISTS" in case deploy must be run twice
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/
UPDATE dbo.tlbMaterial
SET blnReadOnly = 0
WHERE LabModuleSourceIndicator = 1 and blnReadOnly = 1