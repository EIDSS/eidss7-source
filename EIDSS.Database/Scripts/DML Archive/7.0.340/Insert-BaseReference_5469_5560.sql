/*
	Author: Doug Albanese

	New entry for Flex Form Designer and Display Control to have a "statement" object created.

	Update to all existing DB and master
*/

declare @idfsBaseReference BIGINT;

IF NOT EXISTS (SELECT 1 FROM trtBaseReference WHERE strBaseReferenceCode = 'parStatement' AND idfsReferenceType = 19000071)
   BEGIN
      EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'trtBaseReference',
                                    @idfsKey = @idfsBaseReference OUTPUT;

	  INSERT INTO trtBaseReference (idfsBaseReference, idfsReferenceType, strBaseReferenceCode, strDefault, intHACode, intOrder, blnSystem, intRowStatus, rowguid, strMaintenanceFlag, strReservedAttribute, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM)
	  VALUES (@idfsBaseReference, 19000071, 'parStatement', 'Statement', 226, 0, 0, 0, NEWID(), NULL, NULL, 10519001, CONCAT('[{"idfsBaseReference":', @idfsBaseReference, '}]'), 'system', GETDATE())

	  
	  INSERT INTO dbo.ffParameterType
			(
			   [idfsParameterType]
			   ,[idfsReferenceType]
			   ,strMaintenanceFlag
			   ,SourceSystemNameID
			   ,SourceSystemKeyValue
			   ,AuditCreateDTM
			   ,AuditCreateUser
			)
	  VALUES
			(
			   @idfsBaseReference
			   ,NULL
			   ,NULL
			   ,10519001
			   ,'[{"idfsParameterType":'+ convert(nvarchar(20), @idfsBaseReference) + '}]'
			   ,GETDATE()
			   ,'system'
			)

   END

IF NOT EXISTS (SELECT 1 FROM trtBaseReference WHERE strBaseReferenceCode = 'editStatement' AND idfsReferenceType = 19000067)
   BEGIN
	  
      EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'trtBaseReference',
                                    @idfsKey = @idfsBaseReference OUTPUT;

	  INSERT INTO trtBaseReference (idfsBaseReference, idfsReferenceType, strBaseReferenceCode, strDefault, intHACode, intOrder, blnSystem, intRowStatus, rowguid, strMaintenanceFlag, strReservedAttribute, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM)
	  VALUES (@idfsBaseReference, 19000067, 'editStatement', 'Statement', NULL, 0, 0, 0, NEWID(), NULL, NULL, 10519001, CONCAT('[{"idfsBaseReference":', @idfsBaseReference, '}]'), 'system', GETDATE())
   END

