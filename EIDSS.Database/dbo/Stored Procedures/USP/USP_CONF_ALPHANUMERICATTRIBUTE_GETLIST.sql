-- =============================================================================================================================
-- NAME: USP_CONF_ALPHANUMERICATTRIBUTE_GETLIST
-- DESCRIPTION: Returns the list of alphanumeric and numeric attribute types
-- AUTHOR: Ricky Moss
--
-- HISTORY OF CHANGES
-- Name						Date		Description of Change
-- -----------------------------------------------------------------------------------------------------------------------------
-- Ricky Moss				07/10/2019	Initial Release

-- EXEC USP_CONF_ALPHANUMERICATTRIBUTE_GETLIST
-- =============================================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_ALPHANUMERICATTRIBUTE_GETLIST]
AS
BEGIN
	BEGIN TRY
		SELECT idfAttributeType, strAttributeTypeName FROM trtAttributeType WHERE strAttributeTypeName  IN ('Alphanumeric','Numeric') ORDER BY strAttributeTypeName
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
