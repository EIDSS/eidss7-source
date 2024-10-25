-- ================================================================================================
-- Name: USP_AGG_CASE_SET
--
-- Description: Inserts and updates human and veterinary aggregate disease reports, and veterinary 
-- aggregate action report records.
--          
-- Author: Maheshwar Deo
-- Revision History:
--
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Arnold Kennedy  05/02/2018 Change idfVersion to output parm for NEXTKEYID_GET proc
-- Arnold Kennedy  05/03/2018 Insert matrix value  into tlbAggrMatrixVersionHeader table
-- Arnold Kennedy  05/08/2018 Add next key for tbleAggrMatrixVersionHeader
-- Arnold Kennedy  05/09/2018 Retrieve the idfsMatrixType(prepopulated) and idfversion before 
--                            inserting in tlbAggrCase
-- Arnold Kennedy  06/07/2018 Retrieve the idfversion before update
-- Arnold Kennedy  01/07/2019 Added Return Code and Return Message for API
-- Arnold Kennedy/Mark Wilson 01/29/19 Changed SELECT @idfVersion = (SELECT MAX(idfVersion)
-- Daryl Constable 03/27/2019 Changed the following from Human Aggregate Case to Human Aggregate 
--                            Disease Report from Vet Aggregate Case to Vet Aggregate Disease Report
-- Stephen Long    08/13/2019 Removed entered by fields from the update statement.  Cleaned up 
--                            revision history.
-- Stephen Long    04/29/2020 Added orgnization statistical area type.
-- Mark Wilson     05/26/2020 Commented out those getting a new version script
-- Stephen Long    09/18/2020 Commented out update of strCaseID; only used on insert.
-- Stephen Long    12/04/2020 Add site ID as a new parameter.
--
-- Testing code:
--
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_AGG_CASE_SET] @idfAggrCase BIGINT = NULL
	,@strCaseID NVARCHAR(200) = NULL
	,@idfsAggrCaseType BIGINT
	,@GeographicalAdministrativeUnitID BIGINT = NULL -- Country, Region, Rayon and Settlement Statistical Area Types
	,@OrganizationalAdministrativeUnitID BIGINT = NULL -- Organization Statistical Area Type
	,@idfReceivedByOffice BIGINT
	,@idfReceivedByPerson BIGINT
	,@idfSentByOffice BIGINT
	,@idfSentByPerson BIGINT
	,@idfEnteredByOffice BIGINT
	,@idfEnteredByPerson BIGINT
	,@idfCaseObservation BIGINT = NULL
	,@idfsCaseObservationFormTemplate BIGINT = NULL
	,@idfDiagnosticObservation BIGINT = NULL
	,@idfsDiagnosticObservationFormTemplate BIGINT = NULL
	,@idfProphylacticObservation BIGINT = NULL
	,@idfsProphylacticObservationFormTemplate BIGINT = NULL
	,@idfSanitaryObservation BIGINT = NULL
	,@idfVersion BIGINT = NULL
	,@idfDiagnosticVersion BIGINT = NULL
	,@idfProphylacticVersion BIGINT = NULL
	,@idfSanitaryVersion BIGINT = NULL
	,@idfsSanitaryObservationFormTemplate BIGINT = NULL
	,@datReceivedByDate DATETIME
	,@datSentByDate DATETIME
	,@datEnteredByDate DATETIME
	,@datStartDate DATETIME
	,@datFinishDate DATETIME
	,@datModificationForArchiveDate DATETIME = NULL
	,@SiteID BIGINT
AS
DECLARE @ReturnCode INT = 0;
DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
DECLARE @SuppressSelect TABLE (
	ReturnCode INT
	,ReturnMessage VARCHAR(200)
	);

BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

		IF EXISTS (
				SELECT *
				FROM dbo.tlbAggrCase
				WHERE idfAggrCase = @idfAggrCase
				)
		BEGIN
			IF NOT @idfCaseObservation IS NULL
				EXEC dbo.USP_AGG_OBSERVATION_SET @idfCaseObservation
					,@idfsCaseObservationFormTemplate;

			IF NOT @idfDiagnosticObservation IS NULL
				EXEC dbo.USP_AGG_OBSERVATION_SET @idfDiagnosticObservation
					,@idfsDiagnosticObservationFormTemplate;

			IF NOT @idfProphylacticObservation IS NULL
				EXEC dbo.USP_AGG_OBSERVATION_SET @idfProphylacticObservation
					,@idfsProphylacticObservationFormTemplate;

			IF NOT @idfSanitaryObservation IS NULL
				EXEC dbo.USP_AGG_OBSERVATION_SET @idfSanitaryObservation
					,@idfsSanitaryObservationFormTemplate;

			/*SET @idfVersion = (
					SELECT idfVersion
					FROM dbo.tlbAggrCase
					WHERE idfAggrCase = @idfAggrCase
					);
			*/-- this value is passed and should be required
			UPDATE dbo.tlbAggrCase
			SET idfsAggrCaseType = @idfsAggrCaseType
				,idfsAdministrativeUnit = @GeographicalAdministrativeUnitID
				,idfOffice = @OrganizationalAdministrativeUnitID
				,idfReceivedByOffice = @idfReceivedByOffice
				,idfReceivedByPerson = @idfReceivedByPerson
				,idfSentByOffice = @idfSentByOffice
				,idfSentByPerson = @idfSentByPerson
				,idfCaseObservation = @idfCaseObservation
				,idfDiagnosticObservation = @idfDiagnosticObservation
				,idfProphylacticObservation = @idfProphylacticObservation
				,idfSanitaryObservation = @idfSanitaryObservation
				,idfVersion = @idfVersion
				,idfDiagnosticVersion = @idfDiagnosticVersion
				,idfProphylacticVersion = @idfProphylacticVersion
				,idfSanitaryVersion = @idfSanitaryVersion
				,datReceivedByDate = @datReceivedByDate
				,datSentByDate = @datSentByDate
				,datStartDate = @datStartDate
				,datFinishDate = @datFinishDate
				,datModificationForArchiveDate = GETDATE()
				,idfsSite = @SiteID
			WHERE idfAggrCase = @idfAggrCase;
		END
		ELSE
		BEGIN
			--In previous implementation, the primary key was generated based on case type
			--In new implementation it is based on table tlbAggrCase
			--DECLARE @NextNumberType BIGINT
			--SET @NextNumberType =	CASE @idfsAggrCaseType 
			--						WHEN 10102001 /*AggregateCase*/ THEN 10057001
			--						WHEN 10102002 /*VetAggregateCase*/ THEN 10057003
			--						WHEN 10102003 /*VetAggregateAction*/ THEN 10057002
			--						END
			INSERT INTO @SuppressSelect
			EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbAggrCase'
				,@idfAggrCase OUTPUT;

			IF ISNULL(@strCaseID, N'') = N''
				OR LEFT(ISNULL(@strCaseID, N''), 4) = '(new'
			BEGIN
				DECLARE @ObjectName NVARCHAR(600);

				SET @ObjectName = CASE @idfsAggrCaseType
						WHEN 10102001 /*AggregateCase*/
							THEN 'Human Aggregate Disease Report' --tstNextNumbers.idfsNumberName = 10057001
						WHEN 10102002 /*VetAggregateCase*/
							THEN 'Vet Aggregate Disease Report' --tstNextNumbers.idfsNumberName = 10057003
						WHEN 10102003 /*VetAggregateAction*/
							THEN 'Vet Aggregate Action' --tstNextNumbers.idfsNumberName = 10057002
						END;

				INSERT INTO @SuppressSelect
				EXEC dbo.USP_GBL_NextNumber_GET @ObjectName
					,@strCaseID OUTPUT
					,NULL;
			END

			IF NOT @idfCaseObservation IS NULL
				EXEC dbo.USP_AGG_OBSERVATION_SET @idfCaseObservation
					,@idfsCaseObservationFormTemplate;

			IF NOT @idfDiagnosticObservation IS NULL
				EXEC dbo.USP_AGG_OBSERVATION_SET @idfDiagnosticObservation
					,@idfsDiagnosticObservationFormTemplate;

			IF NOT @idfProphylacticObservation IS NULL
				EXEC dbo.USP_AGG_OBSERVATION_SET @idfProphylacticObservation
					,@idfsProphylacticObservationFormTemplate;

			IF NOT @idfSanitaryObservation IS NULL
				EXEC dbo.USP_AGG_OBSERVATION_SET @idfSanitaryObservation
					,@idfsSanitaryObservationFormTemplate;

			/*			INSERT INTO @SuppressSelect
			EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbAggrMatrixVersionHeader',
				@idfVersion OUTPUT;
*/-- This value is passed and should be required
			DECLARE @idfsMatrixType BIGINT;

			SET @idfsMatrixType = CASE @idfsAggrCaseType
					WHEN 10102001 /*AggregateCase*/
						THEN 71190000000 --tstNextNumbers.idfsNumberName = 10057001
					WHEN 10102002 /*VetAggregateCase*/
						THEN 71090000000 --tstNextNumbers.idfsNumberName = 10057003
					END;

			/*
			SELECT @idfVersion = (
					SELECT MAX(idfVersion)
					FROM dbo.tlbAggrMatrixVersionHeader
					WHERE idfsMatrixType = @idfsMatrixType
					);
*/-- This value is passed and should be required
			INSERT INTO dbo.tlbAggrCase (
				idfAggrCase
				,idfsAggrCaseType
				,idfsAdministrativeUnit
				,idfOffice
				,idfReceivedByOffice
				,idfReceivedByPerson
				,idfSentByOffice
				,idfSentByPerson
				,idfEnteredByOffice
				,idfEnteredByPerson
				,idfCaseObservation
				,idfDiagnosticObservation
				,idfProphylacticObservation
				,idfSanitaryObservation
				,idfVersion
				,idfDiagnosticVersion
				,idfProphylacticVersion
				,idfSanitaryVersion
				,datReceivedByDate
				,datSentByDate
				,datEnteredByDate
				,datStartDate
				,datFinishDate
				,strCaseID
				,datModificationForArchiveDate
				,idfsSite
				)
			VALUES (
				@idfAggrCase
				,@idfsAggrCaseType
				,@GeographicalAdministrativeUnitID
				,@OrganizationalAdministrativeUnitID
				,@idfReceivedByOffice
				,@idfReceivedByPerson
				,@idfSentByOffice
				,@idfSentByPerson
				,@idfEnteredByOffice
				,@idfEnteredByPerson
				,@idfCaseObservation
				,@idfDiagnosticObservation
				,@idfProphylacticObservation
				,@idfSanitaryObservation
				,@idfVersion
				,@idfDiagnosticVersion
				,@idfProphylacticVersion
				,@idfSanitaryVersion
				,@datReceivedByDate
				,@datSentByDate
				,@datEnteredByDate
				,@datStartDate
				,@datFinishDate
				,@strCaseID
				,GETDATE()
				,@SiteID
				);
		END

		IF @@TRANCOUNT > 0
			COMMIT;

		SELECT @ReturnCode 'ReturnCode'
			,@ReturnMessage 'ReturnMessage'
			,@idfAggrCase 'idfAggrCase'
			,@idfVersion 'idfVersion'
			,@strCaseID 'strCaseID';
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;

		THROW;
	END CATCH
END
