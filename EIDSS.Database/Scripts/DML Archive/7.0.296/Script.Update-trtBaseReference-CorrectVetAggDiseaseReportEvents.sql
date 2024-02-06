/*
Author:			Mike Kornegay
Date:			09/28/2022
Description:	Correcting the event wording for Veterinary Aggregate Disease Report events
Note:           -Be sure to wrap your insert statements in "IF NOT EXISTS" in case deploy must be run twice
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

BEGIN
    UPDATE trtBaseReference 
    SET strDefault = N'New veterinary aggregate disease report was created at your site'
    WHERE idfsBaseReference = 10025101
END
GO

BEGIN
    UPDATE trtBaseReference 
    SET strDefault = N'New veterinary aggregate disease report was received from another site'
    WHERE idfsBaseReference = 10025102
END
GO

BEGIN
    UPDATE trtBaseReference 
    SET strDefault = N'Veterinary aggregate disease report was changed at your site'
    WHERE idfsBaseReference = 10025103
END
GO

BEGIN
    UPDATE trtBaseReference 
    SET strDefault = N'Veterinary aggregate disease report was changed at your neighboring site'
    WHERE idfsBaseReference = 10025104
END
GO
