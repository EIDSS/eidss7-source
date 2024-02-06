/*
Run this script on:

100.104.1.176\NGSQLRPT1.EIDSS7_GG_UAT    -  This database will be modified

to synchronize it with:

100.104.1.167,49501\NGSQLDEV1.EIDSS7_GG_DT

You are recommended to back up your database before running this script

Script created by SQL Data Compare version 14.4.4.16824 from Red Gate Software Ltd at 1/20/2023 8:05:08 AM

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

--PRINT(N'Drop constraints from [dbo].[trtStringNameTranslation]')
--ALTER TABLE [dbo].[trtStringNameTranslation] NOCHECK CONSTRAINT [FK_trtStringNameTranslation_trtBaseReference__idfsBaseReference_R_385]
--ALTER TABLE [dbo].[trtStringNameTranslation] NOCHECK CONSTRAINT [FK_trtStringNameTranslation_trtBaseReference__idfsLanguage_R_1584]
--ALTER TABLE [dbo].[trtStringNameTranslation] NOCHECK CONSTRAINT [FK_trtStringNameTranslation_trtBaseReference_SourceSystemNameID]

PRINT(N'Update row in [dbo].[trtStringNameTranslation]')
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'არქივთან დაკავშირება ' WHERE [idfsBaseReference] = 10506049 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN (10506010,10506213,10506049)AND idfsLanguage = 10049004)

PRINT(N'Add row to [dbo].[trtStringNameTranslation]')
INSERT INTO [dbo].[trtStringNameTranslation] ([idfsBaseReference], [idfsLanguage], [strTextString], [intRowStatus]) VALUES (10506213, 10049004, N'არქივთან დაკავშირება ', 0)

PRINT(N'Add constraints to [dbo].[trtStringNameTranslation]')
--COMMIT TRANSACTION
--GO
