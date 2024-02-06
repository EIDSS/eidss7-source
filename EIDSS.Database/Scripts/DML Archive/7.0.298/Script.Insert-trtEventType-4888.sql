/*
Author:			Mike Kornegay
Date:			10/07/2022
Description:	Insert record in trtEventType for Veterinary Aggregate Disease Report new report site alert.
Note:           -Be sure the record exists in table.  TODO - Need to check on trtStringNameTranslation.
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

IF NOT EXISTS (SELECT 1 FROM trtEventType WHERE idfsEventTypeID = 10025101)
BEGIN
    INSERT INTO [dbo].[trtEventType]
           ([idfsEventTypeID]
           ,[rowguid]
           ,[intRowStatus]
           ,[blnSubscription]
           ,[blnDisplayInLog]
           ,[idfsEventSubscription]
           ,[strMaintenanceFlag]
           ,[strReservedAttribute]
           ,[SourceSystemNameID]
           ,[SourceSystemKeyValue]
           ,[AuditCreateUser]
           ,[AuditCreateDTM]
           ,[AuditUpdateUser]
           ,[AuditUpdateDTM])
     VALUES
           (10025101
           ,newid()
           ,0
           ,1
           ,1
           ,12666330000000
           ,NULL
		   ,NULL
		   ,10519001
           ,'[{"idfsEventTypeID":12666330000000}]'
           ,'mkornegay'
           ,GETDATE()
           ,NULL
           ,NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM trtEventType WHERE idfsEventTypeID = 10025102)
BEGIN
    INSERT INTO [dbo].[trtEventType]
           ([idfsEventTypeID]
           ,[rowguid]
           ,[intRowStatus]
           ,[blnSubscription]
           ,[blnDisplayInLog]
           ,[idfsEventSubscription]
           ,[strMaintenanceFlag]
           ,[strReservedAttribute]
           ,[SourceSystemNameID]
           ,[SourceSystemKeyValue]
           ,[AuditCreateUser]
           ,[AuditCreateDTM]
           ,[AuditUpdateUser]
           ,[AuditUpdateDTM])
     VALUES
           (10025102
           ,newid()
           ,0
           ,1
           ,1
           ,12666340000000
           ,NULL
		   ,NULL
		   ,10519001
           ,'[{"idfsEventTypeID":12666340000000}]'
           ,'mkornegay'
           ,GETDATE()
           ,NULL
           ,NULL)
END
GO