

----------------------------------------------------------------------------------------------------------
--
-- delete empty or null translation records.
--
----------------------------------------------------------------------------------------------------------

ALTER TABLE [dbo].[trtStringNameTranslation] DISABLE TRIGGER [TR_trtStringNameTranslation_I_Delete]

DELETE 
FROM dbo.trtStringNameTranslation 
WHERE strTextString IS NULL
OR LTRIM(RTRIM(strTextString)) = ''

ALTER TABLE [dbo].[trtStringNameTranslation] ENABLE TRIGGER [TR_trtStringNameTranslation_I_Delete]



ALTER TABLE [dbo].[trtResourceTranslation] DISABLE TRIGGER [TR_trtResourceTranslation_I_Delete]

DELETE 
FROM dbo.trtResourceTranslation 
WHERE strResourceString IS NULL
OR LTRIM(RTRIM(strResourceString)) = ''

DELETE FROM dbo.trtResourceTranslation WHERE strResourceString = '[TBD]'

ALTER TABLE [dbo].[trtResourceTranslation] ENABLE TRIGGER [TR_trtResourceTranslation_I_Delete]


ALTER TABLE [dbo].[trtResourceSetTranslation] DISABLE TRIGGER [TR_trtResourceSetTranslation_I_Delete]

DELETE 
FROM dbo.trtResourceSetTranslation 
WHERE strTextString IS NULL
OR LTRIM(RTRIM(strTextString)) = ''

ALTER TABLE [dbo].[trtResourceSetTranslation] ENABLE TRIGGER [TR_trtResourceSetTranslation_I_Delete]
