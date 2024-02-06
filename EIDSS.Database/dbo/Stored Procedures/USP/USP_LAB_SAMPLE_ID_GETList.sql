-- ================================================================================================
-- Name: USP_LAB_SAMPLE_ID_GETList
--
-- Description:	Gets a list of EIDSS laboratory sample ID's from next number get for samples that
-- intend to be accessioned.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     09/03/2020 Initial release.
-- Stephen Long     09/25/2021 Removed return code and message from the catch portion to work with 
--                             POCO.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_LAB_SAMPLE_ID_GETList] (@Samples NVARCHAR(MAX) = NULL)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnCode INT = 0
		,@ReturnMessage VARCHAR(MAX)
		,@SampleID BIGINT
		,@EIDSSLaboratorySampleID NVARCHAR(200) = NULL;
	DECLARE @SuppressSelect TABLE (
		ReturnCode INT
		,ReturnMessage NVARCHAR(MAX)
		,ID BIGINT
		);
	DECLARE @SamplesTemp TABLE (
		SampleID BIGINT NOT NULL
		,EIDSSLaboratorySampleID NVARCHAR(200) NULL
		,ProcessedIndicator BIT
		);

	BEGIN TRY
		BEGIN TRANSACTION;

		INSERT INTO @SamplesTemp
		SELECT *
		FROM OPENJSON(@Samples) WITH (
				SampleID BIGINT
				,EIDSSLaboratorySampleID NVARCHAR(200)
				,ProcessedIndicator BIT
				);

		WHILE (
				SELECT COUNT(*)
				FROM @SamplesTemp
				WHERE ProcessedIndicator = 0
				) > 0
		BEGIN
			SELECT TOP 1 @SampleID = SampleID
			FROM @SamplesTemp
			WHERE ProcessedIndicator = 0

			INSERT INTO @SuppressSelect
			EXECUTE dbo.USP_GBL_NextNumber_GET @ObjectName = N'Sample'
				,@NextNumberValue = @EIDSSLaboratorySampleID OUTPUT
				,@InstallationSite = NULL;

			UPDATE @SamplesTemp
			SET EIDSSLaboratorySampleID = @EIDSSLaboratorySampleID
				,ProcessedIndicator = 1
			WHERE SampleID = @SampleID;
		END;

		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;

		SELECT SampleID
			,EIDSSLaboratorySampleID
			,ProcessedIndicator
		FROM @SamplesTemp;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH;
END;
