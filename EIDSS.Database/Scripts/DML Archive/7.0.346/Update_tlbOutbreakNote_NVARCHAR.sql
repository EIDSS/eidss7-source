-----------------------------------------------------------------------------
--
-- convert UploadFileName and UploadFileDescription to NVARCHAR
--
----------------------------------------------------------------------------
ALTER TABLE dbo.tlbOutbreakNote
ALTER COLUMN UploadFileName nvarchar(200) COLLATE Cyrillic_General_CI_AS


ALTER TABLE dbo.tlbOutbreakNote
ALTER COLUMN UploadFileDescription nvarchar(200) COLLATE Cyrillic_General_CI_AS

ALTER TABLE dbo.tlbOutbreakNote
ALTER COLUMN UpdateRecordTitle nvarchar(200) COLLATE Cyrillic_General_CI_AS

