-- ================================================================================================
-- Name: USP_GBL_ORGANIZATION_BY_TYPE_GETList
--
-- Description: Selects list of organizations (ID and name only) for drop down lists.
--          
-- Revision History:
-- Name		       Date		  Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Stephen Long    01/14/2019 Initial release.
-- Stephen Long    02/24/2019 Added site ID, return code and return message.
-- Stephen Long    05/11/2020 Added intRowStatus check.
--
-- Testing Code:
-- EXEC USP_GBL_ORGANIZATION_BY_TYPE_GETList 'en', 10504001
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_ORGANIZATION_BY_TYPE_GETList] (
	@LanguageID NVARCHAR(50),
	@OrganizationTypeID BIGINT
	)
AS
BEGIN
    DECLARE @ReturnCode				INT = 0;
    DECLARE @ReturnMessage				NVARCHAR(MAX) = 'SUCCESS';

	BEGIN TRY
		SET NOCOUNT ON;

		SELECT idfOffice AS OrganizationID,
			[FullName] AS OrganizationName, 
			idfsSite AS SiteID
		FROM dbo.FN_GBL_INSTITUTION(@LanguageID)
		WHERE (OrganizationTypeID = @OrganizationTypeID)
		AND intRowStatus = 0 
		ORDER BY FullName;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH

	SELECT @ReturnCode, @ReturnMessage;
END
