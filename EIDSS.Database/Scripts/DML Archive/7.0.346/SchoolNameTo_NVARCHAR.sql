
-----------------------------------------------------------------------------
--
-- convert SchoolName to NVARCHAR
--
----------------------------------------------------------------------------
ALTER TABLE [dbo].[HumanActualAddlInfo]
ALTER COLUMN [SchoolName] nvarchar(200) COLLATE Cyrillic_General_CI_AS


ALTER TABLE [dbo].[HumanAddlInfo]
ALTER COLUMN [SchoolName] nvarchar(200) COLLATE Cyrillic_General_CI_AS

