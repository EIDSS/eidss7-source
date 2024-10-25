/*
	Author:		 Mike Kornegay
	Description: This script cleans up a bad reference translation in the trtResourceTranslation table
	that was entered as test data.

*/

PRINT N'Cleaning up incorrect idfsLanguage item if exists...';
GO

IF exists (select top 1 idfsLanguage from trtResourceTranslation where idfsLanguage = 389445040004159)
BEGIN   
    ALTER TABLE [dbo].[trtResourceTranslation] DISABLE TRIGGER [TR_trtResourceTranslation_I_Delete]
	DELETE from trtResourceTranslation where idfsLanguage = 389445040004159
	ALTER TABLE [dbo].[trtResourceTranslation] ENABLE TRIGGER [TR_trtResourceTranslation_I_Delete]
END
GO