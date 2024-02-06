


--PRINT(N'Update rows in [dbo].[trtBaseReference]')
IF  EXISTS (SELECT 1 FROM dbo.[trtBaseReference] WHERE   [idfsBaseReference] = 10017065 AND idfsReferenceType = 19000017)
BEGIN
    UPDATE [dbo].[trtBaseReference] SET [intRowStatus]=1 WHERE [idfsBaseReference] = 10017065 AND (idfsReferenceType = 19000017)
END
IF  EXISTS (SELECT 1 FROM dbo.[trtBaseReference] WHERE   [idfsBaseReference] = 10017066 AND idfsReferenceType = 19000017)
BEGIN
    UPDATE [dbo].[trtBaseReference] SET [intRowStatus]=1 WHERE [idfsBaseReference] = 10017066 AND (idfsReferenceType = 19000017)
END
--PRINT(N'Operation applied to 2 rows out of 2')



--PRINT(N'Add rows to [dbo].[trtBaseReference]')
IF NOT  EXISTS (SELECT 1 FROM dbo.[trtBaseReference] WHERE   [idfsBaseReference] = 10017061 AND idfsReferenceType = 19000017)
BEGIN
    INSERT INTO [dbo].[trtBaseReference] ([idfsBaseReference], [idfsReferenceType], [strBaseReferenceCode], [strDefault], [intHACode], [intOrder], [blnSystem], [intRowStatus], [rowguid]) VALUES (10017061, 19000017, N'daoHumActSurvCamp', N'Human Active Surveillance Campaign', NULL, NULL, 0, 0, '2e28c7c4-a5db-4a5d-a01e-92df4c06c95b')
END
IF NOT  EXISTS (SELECT 1 FROM dbo.[trtBaseReference] WHERE   [idfsBaseReference] = 10017062 AND idfsReferenceType = 19000017)
BEGIN
    INSERT INTO [dbo].[trtBaseReference] ([idfsBaseReference], [idfsReferenceType], [strBaseReferenceCode], [strDefault], [intHACode], [intOrder], [blnSystem], [intRowStatus], [rowguid]) VALUES (10017062, 19000017, N'daoVetActSurvSess', N'Veterinary Active Surveillance Session', NULL, NULL, 0, 0, 'fcfa965c-5017-48cd-a255-fafb335d26a9')
END
IF NOT  EXISTS (SELECT 1 FROM dbo.[trtBaseReference] WHERE   [idfsBaseReference] = 10017063 AND idfsReferenceType = 19000017)
BEGIN
INSERT INTO [dbo].[trtBaseReference] ([idfsBaseReference], [idfsReferenceType], [strBaseReferenceCode], [strDefault], [intHACode], [intOrder], [blnSystem], [intRowStatus], [rowguid]) VALUES (10017063, 19000017, N'daoHumActSurvSess', N'Human Active Surveillance Session', NULL, NULL, 0, 0, 'a0d5ceaf-43fc-4417-953c-f67097858aad')
END
IF NOT  EXISTS (SELECT 1 FROM dbo.[trtBaseReference] WHERE   [idfsBaseReference] = 10017073 AND idfsReferenceType = 19000017)
BEGIN
    INSERT INTO [dbo].[trtBaseReference] ([idfsBaseReference], [idfsReferenceType], [strBaseReferenceCode], [strDefault], [intHACode], [intOrder], [blnSystem], [intRowStatus], [rowguid]) VALUES (10017073, 19000017, N'daoVetActSurvCamp', N'Veterinary Active Surveillance Campaign', NULL, NULL, 0, 0, 'c7cf7d9c-6406-4e80-bc9a-bd9b73bc9ef3')
END
IF NOT  EXISTS (SELECT 1 FROM dbo.[trtBaseReference] WHERE   [idfsBaseReference] = 10017074 AND idfsReferenceType = 19000017)
BEGIN
    INSERT INTO [dbo].[trtBaseReference] ([idfsBaseReference], [idfsReferenceType], [strBaseReferenceCode], [strDefault], [intHACode], [intOrder], [blnSystem], [intRowStatus], [rowguid]) VALUES (10017074, 19000017, N'daoWeeklyReportingForm', N'Weekly Reporting Form', NULL, NULL, NULL, 0, '228d6c61-0843-47a8-ac6f-e2b6bc1da894')
END
IF NOT  EXISTS (SELECT 1 FROM dbo.[trtBaseReference] WHERE   [idfsBaseReference] = 10017075 AND idfsReferenceType = 19000017)
BEGIN
    INSERT INTO [dbo].[trtBaseReference] ([idfsBaseReference], [idfsReferenceType], [strBaseReferenceCode], [strDefault], [intHACode], [intOrder], [blnSystem], [intRowStatus], [rowguid]) VALUES (10017075, 19000017, N'daoILIAggregateForm', N'ILI Aggregate Form', NULL, NULL, NULL, 0, '6831dd82-01c3-4e72-b1e9-207d396e5d31')
END
--PRINT(N'Operation applied to 6 rows out of 6')