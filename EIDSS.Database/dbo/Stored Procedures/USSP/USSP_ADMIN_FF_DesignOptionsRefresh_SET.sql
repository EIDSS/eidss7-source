-- ================================================================================================
--	Name: USSP_ADMIN_FF_ParameterOrder_SET
--
--	Description:	Re-Orders the "intOrder" field to ensure that any data, that lacks order information, will have numbers to work with
--	This is very evident with migrated data, where "0's" show up for intOrder and prevents the application from changing parameter placements.
--
--	Revision History:
--	Name             Date       Change Detail
--	---------------- ---------- -------------------------------------------------------------------
--	Doug Albanese	03/15/2022	Initial release.
--	Doug Albanese	03/16/2022	Renamed to have "SET"
--  Doug Albanese   04/18/2023	Swapped out fnGetLanguageCode for dbo.FN_GBL_LanguageCode_GET(@LangID);	
--  Doug Albanese	07/10/2023	Added the language Id for collecting up on existing design options.
--
--	Example
--	EXEC USSP_ADMIN_FF_DesignOptionsRefresh @LangID = 'en-us', @idfsFormTemplate = 9872520000000, @User = 'Doug'
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_ADMIN_FF_DesignOptionsRefresh_SET]
(
	@LangID								VARCHAR(50),
    @idfsFormTemplate					BIGINT,
	@User								NVARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @IncrementSize				INT = 100
	DECLARE @langid_int					BIGINT
	DECLARE @idfsParameter				BIGINT
	DECLARE @idfsSection				BIGINT
	DECLARE	@idfParameterDesignOption	BIGINT
	DECLARE	@idfSectionDesignOption		BIGINT

	DECLARE @MissingDesignParameters TABLE (
		idfsParameter	BIGINT
	)

	DECLARE @MissingDesignSections TABLE (
		idfsSection		BIGINT
	)

	DECLARE @Parameters TABLE (
		NewOrderID		INT,
		idfsParameter	BIGINT
	)

	DECLARE @Sections TABLE (
		NewOrderID		INT,
		idfsSection		BIGINT
	)

	SET @langid_int = dbo.FN_GBL_LanguageCode_GET(@LangID);	

    BEGIN TRY

		--Discover any missing Design Options for parameters associated with the given template
		INSERT INTO @MissingDesignParameters (idfsParameter)
		SELECT
			PFT.idfsParameter
		FROM
			ffParameterForTemplate PFT
		WHERE
			PFT.idfsFormTemplate = @idfsFormTemplate
			AND idfsParameter NOT IN (SELECT idfsParameter FROM ffParameterDesignOption WHERE idfsFormTemplate = @idfsFormTemplate AND idfsLanguage = @langid_int AND intRowStatus = 0)

		--Enumerate through these parameters and add them to the design options table.
		WHILE EXISTS (SELECT * FROM @MissingDesignParameters)
			BEGIN
				SELECT
					TOP 1 @idfsParameter = idfsParameter
				FROM
					@MissingDesignParameters

				EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableNAme = 'ffParameterDesignOption', @idfsKey = @idfParameterDesignOption OUTPUT;

				INSERT INTO ffParameterDesignOption (
					idfParameterDesignOption,
					idfsParameter, 
					idfsLanguage, 
					idfsFormTemplate, 
					intLeft, 
					intTop, 
					intWidth, 
					intHeight, 
					intScheme, 
					intLabelSize, 
					intOrder, 
					intRowStatus, 
					rowguid, 
					AuditCreateuser, 
					AuditCreateDTM
				)
				VALUES (
					@idfParameterDesignOption,
					@idfsParameter,
					@langid_int,
					@idfsFormTemplate,
					0, 
					0, 
					0, 
					0, 
					0, 
					0, 
					0, 
					0, 
					NEWID(), 
					@User, 
					GETDATE()
				)

				DELETE FROM @MissingDesignParameters
				WHERE idfsParameter = @idfsParameter
			END

		
		--Discover any missing Design Options for sections associated with the given template
		INSERT INTO @MissingDesignSections (idfsSection)
		SELECT
			SFT.idfsSection
		FROM
			ffSectionForTemplate SFT
		WHERE
			SFT.idfsFormTemplate = @idfsFormTemplate
			AND idfsSection NOT IN (SELECT idfsSection FROM ffSectionDesignOption WHERE idfsFormTemplate = @idfsFormTemplate AND idfsLanguage = @langid_int AND intRowStatus = 0)
			
		--Enumerate through these sections and add them to the design options table.
		WHILE EXISTS (SELECT * FROM @MissingDesignSections)
			BEGIN
				SELECT
					TOP 1 @idfsSection = idfsSection
				FROM
					@MissingDesignSections

				EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableNAme = 'ffSectionDesignOption', @idfsKey = @idfSectionDesignOption OUTPUT;

				INSERT INTO ffSectionDesignOption (
					idfSectionDesignOption,
					idfsSection, 
					idfsLanguage, 
					idfsFormTemplate, 
					intLeft, 
					intTop, 
					intWidth, 
					intHeight, 
					intOrder, 
					intRowStatus, 
					rowguid, 
					AuditCreateuser, 
					AuditCreateDTM
				)
				VALUES (
					@idfSectionDesignOption,
					@idfsSection,
					@langid_int,
					@idfsFormTemplate,
					0, 
					0, 
					0, 
					0, 
					0, 
					0, 
					NEWID(), 
					@User, 
					GETDATE()
				)

				DELETE FROM @MissingDesignSections
				WHERE idfsSection = @idfsSection
			END

		--Now that all design options exist, we can refresh the ordering to have numbers that will always work with the FFD

		--Collect Parameter ordering information
		INSERT INTO @Parameters
        SELECT 
			@IncrementSize * ROW_NUMBER() OVER(Order By intOrder ASC) AS NewOrderID,
			idfsParameter
		FROM
			ffParameterDesignOption
		WHERE
			idfsFormTemplate = @idfsFormTemplate and
			idfsLanguage = @langid_int
		ORDER BY
			intOrder

		--Collect Section ordering information
		INSERT INTO @Sections
        SELECT 
			@IncrementSize * ROW_NUMBER() OVER(Order By intOrder ASC) AS NewOrderID,
			idfsSection
		FROM
			ffSectionDesignOption
		WHERE
			idfsFormTemplate = @idfsFormTemplate and
			idfsLanguage = @langid_int
		ORDER BY
			intOrder

		--Refresh Parameters with new updated ordering information
		UPDATE Parameter
		SET
			Parameter.intOrder = [@Parameters].NewOrderID
		FROM 
			ffParameterDesignOption Parameter
		INNER JOIN @Parameters ON Parameter.idfsParameter = [@Parameters].idfsParameter
		WHERE
			Parameter.idfsFormTemplate = @idfsFormTemplate

		--Refresh Sections with new updated ordering information
		UPDATE Section
		SET
			Section.intOrder = [@Sections].NewOrderID
		FROM 
			ffSectionDesignOption Section
		INNER JOIN @Sections ON Section.idfsSection = [@Sections].idfsSection
		WHERE
			Section.idfsFormTemplate = @idfsFormTemplate
			
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
