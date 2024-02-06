/*
Author:			Mark Wilson
Date:			11/1/2022
Description:	Update menu options
*/

UPDATE dbo.trtBaseReference SET intRowStatus = 1 WHERE idfsBaseReference IN (10506171,10506206)
UPDATE dbo.LkupEIDSSAppObject SET intRowStatus = 1 WHERE AppObjectNameID IN (10506171,10506206)
UPDATE dbo.LkupEIDSSMenu SET intRowStatus = 1 WHERE EIDSSMenuID IN (10506171,10506206)
UPDATE dbo.trtBaseReference SET intOrder = 60 WHERE idfsBaseReference = 10506212
