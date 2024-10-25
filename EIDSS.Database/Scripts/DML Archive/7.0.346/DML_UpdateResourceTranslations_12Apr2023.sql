--------------------------------------------------------------------------------------------------------------------------------
-- 03_Create_ResourceTranslation_Refresh.sql
-- 
-- 
--
-- This script will create a temp table to be used to refresh Resource translations. 
-- It should be executed on a database with known good translation values. The Temp
-- table will be used as a baseline to be pushed to other environments.  
--
-- After this script has been executed successfully, run a data compare between this table and an empty one in the target DB
-- to generate insert script.
--
-- Revision History:
-- Name             Date		Change Detail
-- ---------------- ----------	-------------------------------------------------------------------
-- Mark Wilson      12-Apr-2023 Initial release.
--
--------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZZZ_Resources12Apr2023]') AND type IN (N'U'))
DROP TABLE [dbo].[ZZZ_Resources12Apr2023]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ZZZ_Resources12Apr2023](
	[en-US] [NVARCHAR](255) NULL,
	[ka-GE] [NVARCHAR](255) NULL,
	[ru-RU] [NVARCHAR](255) NULL
) ON [PRIMARY]
GO

PRINT(N'Add rows to [dbo].[ZZZ_Resources12Apr2023]')
INSERT INTO [dbo].[ZZZ_Resources12Apr2023] ([en-US], [ka-GE], [ru-RU]) VALUES (N'Click to add a test result to the selected records.', N'დააწკაპუნეთ იმისათვის, რომ შერჩეულ ჩანაწერებს დაუმატოთ ტესტის შედეგი', N'нажмите,чтобы добавить в выбранные записи результаты теста')
INSERT INTO [dbo].[ZZZ_Resources12Apr2023] ([en-US], [ka-GE], [ru-RU]) VALUES (N'Click to approve the selected records.', N'დააწკაპუნეთ შერჩეული ჩანაწერების დასამტკიცებლად.', N'нажмите,чтобы подтвердить выбранные записи')
INSERT INTO [dbo].[ZZZ_Resources12Apr2023] ([en-US], [ka-GE], [ru-RU]) VALUES (N'Click to cancel the selected transfers.', N'დააწკაპუნეთ იმისათვის, რომ გააუქმოთ შერჩეული ტრანსფერი', N'нажмите,чтобы отменить выбранный трансфер')
INSERT INTO [dbo].[ZZZ_Resources12Apr2023] ([en-US], [ka-GE], [ru-RU]) VALUES (N'Click to delete all alerts.', N'დააწკაპუნეთ ყველა გაფრთხილების წასაშლელად.', N'нажмите,чтобы удалить все предупреждения')
INSERT INTO [dbo].[ZZZ_Resources12Apr2023] ([en-US], [ka-GE], [ru-RU]) VALUES (N'Click to display the accession in popup.', N'დააწკაპუნეთ იმისათვის, რომ ნიმუშის მიღება გამოისახოს პოპ აპ ფანჯარაში.', N'нажмите,чтобы отобразить образцы в поп ап окне')
INSERT INTO [dbo].[ZZZ_Resources12Apr2023] ([en-US], [ka-GE], [ru-RU]) VALUES (N'Click to display the assign test popup.', N'დააწკაპუნეთ იმისათვის, რომ გამოისახოს დანიშნულის ტესტის პოპ აპ ფანჯარა.', N'нажмите,чтобы отобразить назначенное тестовое окно')
INSERT INTO [dbo].[ZZZ_Resources12Apr2023] ([en-US], [ka-GE], [ru-RU]) VALUES (N'Click to display the batch popup.', N'დააწკაპუნეთ იმისათვის, რომ გამოისახოს პარტიის პოპ აპ ფანჯარა', N'нажмите,чтобы отобразить поп ап окно партии')
INSERT INTO [dbo].[ZZZ_Resources12Apr2023] ([en-US], [ka-GE], [ru-RU]) VALUES (N'Click to display the selected transfers report for printing.', N'დააწკაპუნეთ იმისათვის, რომ გამოისახოს შერჩეული ტრანსფერის დასაბეჭდი ანგარიში', N'нажмите,чтобы отобразить отчет для печати соответствующего трансфера')
INSERT INTO [dbo].[ZZZ_Resources12Apr2023] ([en-US], [ka-GE], [ru-RU]) VALUES (N'Click to mark the alert as read.', N'დააწკაპუნეთ იმისათვის, რომ გართხილება მოინიშნოს წაკითხულად', N'нажмите,чтобы прудупреждение отметить как прочитанное')
INSERT INTO [dbo].[ZZZ_Resources12Apr2023] ([en-US], [ka-GE], [ru-RU]) VALUES (N'Click to reject the selected records.', N'დააწკაპუნეთ იმისათვის, რომ მოხდეს შერჩეული ჩანაწერების უკუგდება', N'нажмите,чтобы обеспечить отмену выбранной записи')
INSERT INTO [dbo].[ZZZ_Resources12Apr2023] ([en-US], [ka-GE], [ru-RU]) VALUES (N'Click to remove the selected samples from the batch.', N'დააწკაპუნეთ იმისათვის, რომ პარტიიდან ამოშალოთ  შერჩეული ნიმუშები', N'нажмите,чтобы удалить выбранные образцы из партии')
INSERT INTO [dbo].[ZZZ_Resources12Apr2023] ([en-US], [ka-GE], [ru-RU]) VALUES (N'Click to show the record on the My Favorites tab.', N'დააწკაპუნეთ იმისათვის. რომ ჩანაწერი გამოჩნდეს ჩემი ფავორიტების ჩანართში', N'нажмите,чтобы отобразить запись в списке моих фаворитов во вкладке')
PRINT(N'Operation applied to 12 rows out of 12')

----------------------------------------------------------------------------------------------------------------------------------------
--
-- declare variables for cursor
--
----------------------------------------------------------------------------------------------------------------------------------------
DECLARE @idfsResource BIGINT
DECLARE @strGG NVARCHAR(255)
DECLARE @strRU NVARCHAR(255)
DECLARE @SourceSystemNameID BIGINT
DECLARE @SourceSystemKeyValue_GG NVARCHAR(MAX)
DECLARE @SourceSystemKeyValue_RU NVARCHAR(MAX)

DECLARE Cursor_ResourceTranslation
CURSOR FOR
SELECT 
	R.idfsResource,
	S.[ka-GE],
	S.[ru-RU],
	R.SourceSystemNameID,
	N'[{"idfsResource":' + CAST(R.idfsResource AS NVARCHAR(24)) + ',"idfsLanguage":10049004}]',
	N'[{"idfsResource":' + CAST(R.idfsResource AS NVARCHAR(24)) + ',"idfsLanguage":10049006}]'


FROM dbo.ZZZ_Resources12Apr2023 S
INNER JOIN dbo.trtResource R ON R.strResourceName = S.[en-US]

OPEN Cursor_ResourceTranslation
FETCH NEXT FROM Cursor_ResourceTranslation
INTO
	@idfsResource,
	@strGG,
	@strRU,
	@SourceSystemNameID,
	@SourceSystemKeyValue_GG,
	@SourceSystemKeyValue_RU

WHILE @@FETCH_STATUS = 0
BEGIN
	IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = @idfsResource AND idfsLanguage = 10049004) -- check Georgian
	BEGIN
		INSERT INTO dbo.trtResourceTranslation
		(
		    idfsResource,
		    idfsLanguage,
		    strResourceString,
		    intRowStatus,
		    rowguid,
		    SourceSystemNameID,
		    SourceSystemKeyValue,
		    AuditCreateUser,
		    AuditCreateDTM
		)

		SELECT
			@idfsResource,
			10049004,
			@strGG,
			0,
			NEWID(),
			@SourceSystemNameID,
			@SourceSystemKeyValue_GG,
			N'System',
			GETDATE()

	END
	ELSE
	BEGIN
		UPDATE dbo.trtResourceTranslation
		SET strResourceString = @strGG,
			AuditUpdateUser = N'System',
			AuditUpdateDTM = GETDATE()

		WHERE idfsResource = @idfsResource 
		AND idfsLanguage = 10049004

	END

	IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = @idfsResource AND idfsLanguage = 10049006) -- check Russian
	BEGIN
		INSERT INTO dbo.trtResourceTranslation
		(
		    idfsResource,
		    idfsLanguage,
		    strResourceString,
		    intRowStatus,
		    rowguid,
		    SourceSystemNameID,
		    SourceSystemKeyValue,
		    AuditCreateUser,
		    AuditCreateDTM
		)

		SELECT
			@idfsResource,
			10049006,
			@strRU,
			0,
			NEWID(),
			@SourceSystemNameID,
			@SourceSystemKeyValue_RU,
			N'System',
			GETDATE()

	END
	ELSE
	BEGIN
		UPDATE dbo.trtResourceTranslation
		SET strResourceString = @strRU,
			AuditUpdateUser = N'System',
			AuditUpdateDTM = GETDATE()

		WHERE idfsResource = @idfsResource 
		AND idfsLanguage = 10049006

	END

	FETCH NEXT FROM Cursor_ResourceTranslation
INTO
	@idfsResource,
	@strGG,
	@strRU,
	@SourceSystemNameID,
	@SourceSystemKeyValue_GG,
	@SourceSystemKeyValue_RU

END

GO
PRINT N'Close and deallocate Cursor_StringNameTranslation'
CLOSE Cursor_ResourceTranslation
DEALLOCATE Cursor_ResourceTranslation

GO
PRINT N'DROPPING [dbo].[ZZZ_Resources12Apr2023]'
GO
DROP TABLE IF EXISTS [dbo].[ZZZ_Resources12Apr2023]
