/*
	Mike Kornegay / Mark Wilson
	2/2/2023
	This script deactivates the duplicate PIN entry in base reference
	and fixes all foreign keys in tlbHuman and tlbHumanActual.

*/

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
GO

BEGIN TRANSACTION;
GO

DECLARE @OldPIN BIGINT = 10148501; 
DECLARE @NewPIN BIGINT = 58010200000000; -- EIDSS7 PIN

-- set all base reference 'PIN' entries to inactive unless it is the new PIN
UPDATE trtBaseReference SET intRowStatus = 1 WHERE strDefault = 'PIN' AND idfsReferenceType = 19000148 AND idfsBaseReference <> 58010200000000;

-- make sure the new PIN type exists
IF NOT EXISTS (SELECT * FROM dbo.trtBaseReference WHERE strDefault = 'PIN' AND idfsReferenceType = 19000148 AND idfsBaseReference = 58010200000000)
	BEGIN	
		INSERT INTO [dbo].[trtBaseReference]
			   ([idfsBaseReference]
			   ,[idfsReferenceType]
			   ,[strBaseReferenceCode]
			   ,[strDefault]
			   ,[intHACode]
			   ,[intOrder]
			   ,[blnSystem]
			   ,[intRowStatus]
			   ,[rowguid]
			   ,[strMaintenanceFlag]
			   ,[strReservedAttribute]
			   ,[SourceSystemNameID]
			   ,[SourceSystemKeyValue]
			   ,[AuditCreateUser]
			   ,[AuditCreateDTM]
			   ,[AuditUpdateUser]
			   ,[AuditUpdateDTM])
		 VALUES
			   (58010200000000
			   ,19000148
			   ,NULL
			   ,'PIN'
			   ,NULL
			   ,0
			   ,1
			   ,0
			   ,NEWID()
			   ,NULL
			   ,NULL
			   ,10519002
			   ,'[{"idfsBaseReference":58010200000000}]'
			   ,'system'
			   ,GETDATE()
			   ,'system'
			   ,GETDATE());
	END
ELSE
	BEGIN
		--if the new PIN type exists, make sure it is active
		UPDATE trtBaseReference SET intRowStatus = 0, blnSystem = 1 WHERE idfsBaseReference = 58010200000000
	END

UPDATE dbo.tlbHumanActual
SET idfsPersonIDType = @NewPIN
WHERE idfsPersonIDType = @OldPIN;

UPDATE dbo.tlbHuman
SET idfsPersonIDType = @NewPIN
WHERE idfsPersonIDType = @OldPIN;

COMMIT TRANSACTION;