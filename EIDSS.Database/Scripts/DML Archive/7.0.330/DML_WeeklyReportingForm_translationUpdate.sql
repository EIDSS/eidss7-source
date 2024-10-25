/*
Run this script on:

ALL Environments
to synchronize it with:

100.104.1.167,49501\NGSQLDEV1.EIDSS7_GG_DT

You are recommended to back up your database before running this script

Script created by SQL Data Compare version 14.4.4.16824 from Red Gate Software Ltd at 1/20/2023 1:40:46 PM

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

--PRINT(N'Drop constraints from [dbo].[trtResourceTranslation]')
--ALTER TABLE [dbo].[trtResourceTranslation] NOCHECK CONSTRAINT [FK_trtResourceTranslation_idfsLanguage]
--ALTER TABLE [dbo].[trtResourceTranslation] NOCHECK CONSTRAINT [FK_trtResourceTranslation_SourceSystemNameID]
--ALTER TABLE [dbo].[trtResourceTranslation] NOCHECK CONSTRAINT [FK_trtResourceTranslation_trtResource]

PRINT(N'Update row in [dbo].[trtResourceTranslation]')
UPDATE [dbo].[trtResourceTranslation] SET [strResourceString]=N'ყოველკვირეული ანგარიშგების ფორმა' WHERE [idfsResource] = 747 AND [idfsLanguage] = 10049004 AND (idfsResource IN (747))

--PRINT(N'Add constraints to [dbo].[trtResourceTranslation]')
--ALTER TABLE [dbo].[trtResourceTranslation] CHECK CONSTRAINT [FK_trtResourceTranslation_idfsLanguage]
--ALTER TABLE [dbo].[trtResourceTranslation] CHECK CONSTRAINT [FK_trtResourceTranslation_SourceSystemNameID]
--ALTER TABLE [dbo].[trtResourceTranslation] CHECK CONSTRAINT [FK_trtResourceTranslation_trtResource]
--COMMIT TRANSACTION
--GO
