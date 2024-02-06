

/*
Run this script on:

100.104.1.167,49650\NGSQLDEV2.EIDSS7_MSTR_Reference_Compare3    -  This database will be modified

to synchronize it with:

100.104.1.189,57355\NGSQLTEST1.EIDSS7_GG

You are recommended to back up your database before running this script

Script created by SQL Data Compare version 14.4.4.16824 from Red Gate Software Ltd at 12/22/2022 12:31:40 PM

*/
		
--SET NUMERIC_ROUNDABORT OFF
--GO
--SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS, NOCOUNT ON
--GO
--SET DATEFORMAT YMD
--GO
--SET XACT_ABORT ON
--GO
--SET TRANSACTION ISOLATION LEVEL Serializable
--GO
--BEGIN TRANSACTION

--PRINT(N'Drop constraints from [dbo].[LkupEIDSSAppObject]')
--ALTER TABLE [dbo].[LkupEIDSSAppObject] NOCHECK CONSTRAINT [FK_AppObj_EIDSSMenu_MenuID]
--ALTER TABLE [dbo].[LkupEIDSSAppObject] NOCHECK CONSTRAINT [FK_AppObj_ObjName]
--ALTER TABLE [dbo].[LkupEIDSSAppObject] NOCHECK CONSTRAINT [FK_AppObj_ObjType]
--ALTER TABLE [dbo].[LkupEIDSSAppObject] NOCHECK CONSTRAINT [FK_AppObj_PageToolTip]
--ALTER TABLE [dbo].[LkupEIDSSAppObject] NOCHECK CONSTRAINT [FK_LkupEIDSSAppObject_trtBaseReference_SourceSystemNameID]

PRINT(N'Update rows in [dbo].[LkupEIDSSAppObject]')
UPDATE [dbo].[LkupEIDSSAppObject] SET [intRowStatus]=0 WHERE [AppObjectNameID] = 10506022
UPDATE [dbo].[LkupEIDSSAppObject] SET [intRowStatus]=0 WHERE [AppObjectNameID] = 10506062
UPDATE [dbo].[LkupEIDSSAppObject] SET [intRowStatus]=0 WHERE [AppObjectNameID] = 10506063
UPDATE [dbo].[LkupEIDSSAppObject] SET [PageLink]=N'' WHERE [AppObjectNameID] = 10506216
UPDATE [dbo].[LkupEIDSSAppObject] SET [PageLink]=N'' WHERE [AppObjectNameID] = 10506217
UPDATE [dbo].[LkupEIDSSAppObject] SET [PageLink]=N'' WHERE [AppObjectNameID] = 10506218
PRINT(N'Operation applied to 6 rows out of 6')

--PRINT(N'Add constraints to [dbo].[LkupEIDSSAppObject]')
--COMMIT TRANSACTION
--GO
