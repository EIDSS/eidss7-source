/*
Run this script on:

192.255.54.29\EIDSS7,58845.EIDSS7_GAT_Main    -  This database will be modified

to synchronize it with:

100.104.1.189,57355\NGSQLTEST1.EIDSS7_GG

You are recommended to back up your database before running this script

Script created by SQL Data Compare version 14.4.4.16824 from Red Gate Software Ltd at 1/24/2023 9:57:25 AM

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

--PRINT(N'Drop constraint FK_trtStringNameTranslationToCP_trtStringNameTranslation__idfsBaseReference_idfsLanguage from [dbo].[trtStringNameTranslationToCP]')
--ALTER TABLE [dbo].[trtStringNameTranslationToCP] NOCHECK CONSTRAINT [FK_trtStringNameTranslationToCP_trtStringNameTranslation__idfsBaseReference_idfsLanguage]

PRINT(N'Update rows in [dbo].[trtStringNameTranslation]')
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'დანომრვის უნიკალურ სქემაზე წვდომა' WHERE [idfsBaseReference] = 10094021 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'ადამიანთა დაავადების შემთხვევების მონაცემებთან  წვდომა' WHERE [idfsBaseReference] = 10094027 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'ლაბორატორიულ ტესტებზე წვდომა' WHERE [idfsBaseReference] = 10094030 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'დზეის-ის საიტების ჩამონათვაის წვდომა (სხვასაიტებიდან მონაცემების მარტვის წვდომა)' WHERE [idfsBaseReference] = 10094031 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'აქტიური ზედამხედველობის კამპანიაზე წვდომა' WHERE [idfsBaseReference] = 10094041 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'აქტიური ზედამხედველობის სესიაზე წვდომა' WHERE [idfsBaseReference] = 10094042 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'ვექტორული ზედამხედველობის სესიაზე წვდომა' WHERE [idfsBaseReference] = 10094044 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'წვდომა საყრდენი ბაზებით სინდრომული ზედამხედველობის მოდულზე' WHERE [idfsBaseReference] = 10094051 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'ადამიანთა დაავადების აგრეგირებულ ანგარიშებზე  წვდომა' WHERE [idfsBaseReference] = 10094052 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'წვდომა ვეტერინარული დაავადების აგრეგირებულ ქმედებებზე' WHERE [idfsBaseReference] = 10094054 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'შესაძლებელია ლაბორატორიული ტესტის დასრულება' WHERE [idfsBaseReference] = 10094057 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'ადამიანის დაავადების შემთხვევის გამარტივებული ფორმის გამოყენება' WHERE [idfsBaseReference] = 10094058 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'ადამიანის დაავადების ანგარიშის შემთხვევის გამოკვლევაზე წვდომა ' WHERE [idfsBaseReference] = 10094507 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'ადამიანის დაავადების ანგარიშის კლინიკური ინფორმაციის სექციაზე წვდომა ' WHERE [idfsBaseReference] = 10094508 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'ადამიანის დაავადების ანგარიშის კონტაქტების ჩამონათვალის სექციაზე წვდომა ' WHERE [idfsBaseReference] = 10094509 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'ადამიანის დაავადების ანგარიშის მონაცემებზე წვდომა' WHERE [idfsBaseReference] = 10094510 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'ადამიანის დაავადების ანგარიშის საბოლოო გამოსავალის სექციაზე წვდომა' WHERE [idfsBaseReference] = 10094511 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'ადამიანის დაავადების ანგარიშის შეტყობინების სექციაზე წვდომა' WHERE [idfsBaseReference] = 10094512 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'ადამიანის დაავადების ანგარიშის  შემაჯამებელ  სექციაზე წვდომა' WHERE [idfsBaseReference] = 10094513 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'ადამიანის სტანდარტულ ანგარიშებზე წვდომა' WHERE [idfsBaseReference] = 10094514 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'ადამიანის დაავადების სინდრომულ ჩამონათვალზე წვდომა' WHERE [idfsBaseReference] = 10094515 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'წვდომა ლაბორატორიულ სტანდარტულ ანგარიშებზე' WHERE [idfsBaseReference] = 10094516 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'ვეტერინარულ დაავადების  სტანდარტულ ანგარიშებზე წვდომა' WHERE [idfsBaseReference] = 10094519 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
UPDATE [dbo].[trtStringNameTranslation] SET [strTextString]=N'ადამიანის დაავადების შემთხვევის გამარტივებული ფორმის გამოყენება' WHERE [idfsBaseReference] = 10094524 AND [idfsLanguage] = 10049004 AND (idfsBaseReference IN
(SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000094))
PRINT(N'Operation applied to 24 rows out of 24')

PRINT(N'Add rows to [dbo].[trtStringNameTranslation]')
INSERT INTO [dbo].[trtStringNameTranslation] ([idfsBaseReference], [idfsLanguage], [strTextString], [intRowStatus]) VALUES (10094546, 10049004, N'გმდ აგრეგირებულ ფორმის მონაცემებზე წვდომა', 0)
INSERT INTO [dbo].[trtStringNameTranslation] ([idfsBaseReference], [idfsLanguage], [strTextString], [intRowStatus]) VALUES (10094547, 10049004, N'წვდომა ადამიანის დაავადების  ეპიდაფეთქების შემთხვევის მონაცემეზე', 0)
INSERT INTO [dbo].[trtStringNameTranslation] ([idfsBaseReference], [idfsLanguage], [strTextString], [intRowStatus]) VALUES (10094548, 10049004, N'წვდომა ეპიდაფეთქების ვეტერინარული დაავადების შემთხვევის მონაცემებზე', 0)
INSERT INTO [dbo].[trtStringNameTranslation] ([idfsBaseReference], [idfsLanguage], [strTextString], [intRowStatus]) VALUES (10094553, 10049004, N'წვდომა ეპიდაფეთქების ვექტორის მონაცემებზე', 0)
INSERT INTO [dbo].[trtStringNameTranslation] ([idfsBaseReference], [idfsLanguage], [strTextString], [intRowStatus]) VALUES (10094556, 10049004, N'წვდომა ვეტერინარული დაავადების აბერაციის ანალიზის ანგარიშებზე', 0)
INSERT INTO [dbo].[trtStringNameTranslation] ([idfsBaseReference], [idfsLanguage], [strTextString], [intRowStatus]) VALUES (10094557, 10049004, N'გმდ აბერაციის ანალიზის ანგარიშებზე წვდომა', 0)
INSERT INTO [dbo].[trtStringNameTranslation] ([idfsBaseReference], [idfsLanguage], [strTextString], [intRowStatus]) VALUES (10094558, 10049004, N'წვდომა ლაბორატორიიდან გაგზავნილ ნიმუშებზე', 0)
INSERT INTO [dbo].[trtStringNameTranslation] ([idfsBaseReference], [idfsLanguage], [strTextString], [intRowStatus]) VALUES (10094559, 10049004, N'წვდომა ლაბორატორიულ დამტკიცებებზე', 0)
INSERT INTO [dbo].[trtStringNameTranslation] ([idfsBaseReference], [idfsLanguage], [strTextString], [intRowStatus]) VALUES (10094560, 10049004, N'წვდომა ლაბორატორიულ ჩანაწერებზე', 0)
INSERT INTO [dbo].[trtStringNameTranslation] ([idfsBaseReference], [idfsLanguage], [strTextString], [intRowStatus]) VALUES (10094561, 10049004, N'ინტერფეისის რედაქტორზე წვდომა', 0)
INSERT INTO [dbo].[trtStringNameTranslation] ([idfsBaseReference], [idfsLanguage], [strTextString], [intRowStatus]) VALUES (10094562, 10049004, N'წვდომა ქაღალდის ფორმებზე', 0)
INSERT INTO [dbo].[trtStringNameTranslation] ([idfsBaseReference], [idfsLanguage], [strTextString], [intRowStatus]) VALUES (10094564, 10049004, N'შესაძლებელია ვეტერინარული შემთხვევის/სესიის ტესტის შედეგის დამატება', 0)
INSERT INTO [dbo].[trtStringNameTranslation] ([idfsBaseReference], [idfsLanguage], [strTextString], [intRowStatus]) VALUES (10094565, 10049004, N'შესაძლებელია დახურული ვეტერინარული დაავადების ანგარიშის/სესიის ხელახლა გახსნა', 0)
INSERT INTO [dbo].[trtStringNameTranslation] ([idfsBaseReference], [idfsLanguage], [strTextString], [intRowStatus]) VALUES (10094566, 10049004, N'შესაძლებელია ვეტერინარული დაავადების ტესტის შედეგის ინტერპრეტაციის მართვა', 0)
INSERT INTO [dbo].[trtStringNameTranslation] ([idfsBaseReference], [idfsLanguage], [strTextString], [intRowStatus]) VALUES (10094567, 10049004, N'შესაძლებელია ვეტერინარული დაავადების ტესტის შედეგის ინტერპრეტაცია', 0)
INSERT INTO [dbo].[trtStringNameTranslation] ([idfsBaseReference], [idfsLanguage], [strTextString], [intRowStatus]) VALUES (10094568, 10049004, N'შესაძლებელია დახურული ეპიდაფეთქების სესიის ხელახლა გახსნა', 0)
INSERT INTO [dbo].[trtStringNameTranslation] ([idfsBaseReference], [idfsLanguage], [strTextString], [intRowStatus]) VALUES (10094569, 10049004, N'ნიმუშების გადაცემის განხორციელების შესაძლებლობა', 0)
PRINT(N'Operation applied to 17 rows out of 17')

--PRINT(N'Add constraints to [dbo].[trtStringNameTranslation]')
--ALTER TABLE [dbo].[trtStringNameTranslation] CHECK CONSTRAINT [FK_trtStringNameTranslation_trtBaseReference__idfsBaseReference_R_385]
--ALTER TABLE [dbo].[trtStringNameTranslation] CHECK CONSTRAINT [FK_trtStringNameTranslation_trtBaseReference__idfsLanguage_R_1584]
--ALTER TABLE [dbo].[trtStringNameTranslation] CHECK CONSTRAINT [FK_trtStringNameTranslation_trtBaseReference_SourceSystemNameID]
--ALTER TABLE [dbo].[trtStringNameTranslationToCP] CHECK CONSTRAINT [FK_trtStringNameTranslationToCP_trtStringNameTranslation__idfsBaseReference_idfsLanguage]
--COMMIT TRANSACTION
--GO
