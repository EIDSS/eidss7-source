-- ================================================================================================
-- Name: USP_ADMIN_Barcode_GETList
-- Description: Barcode Generator Module
--          
-- Author: Doug Albanese
-- 
-- Revision History:
-- Name				Date		Change Detail
-- ---------------- ----------	------------------------------------------------------------------
-- Doug Albanese	11/23/2020	Copy of USP_GBL_NextNumber_GET to be modified for the Barcode Generator Module
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_BarcodeNextNumber_GET] (
	@ObjectName							NVARCHAR(300),
	@NextNumberValue					NVARCHAR(200)	OUTPUT,
	@blnUsePrefix						BIT				= 0,
	@siteId								NVARCHAR(50)	= NULL,
	@blnUseYear							BIT				= 0
)
AS

	DECLARE @NextID						BIGINT
	DECLARE @Year						INT
	DECLARE @MinNumberLength			INT
	DECLARE @Suffix						NVARCHAR(50)
	DECLARE @Prefix						NVARCHAR(50)
	DECLARE @ShowPrefix					BIT
	DECLARE @ShowSiteID					BIT
	DECLARE @ShowYear					BIT
	DECLARE @ShowHASCCodeSite			BIT
	DECLARE @HASCCodeSite				NVARCHAR(200)
	DECLARE @strSiteID					NVARCHAR(10)
	DECLARE @ShowAlphaNumeric			BIT
	DECLARE @idfsNumberName				BIGINT
	DECLARE @returnCode					INT = 0
	DECLARE @returnMsg					NVARCHAR(MAX) = 'SUCCESS'
	DECLARE @CurrentID						BIGINT


	BEGIN
		IF @ObjectName IS NULL
			RETURN - 1

		IF @siteID IS NOT NULL
			BEGIN
				SELECT @HASCCodeSite = SUBSTRING(ISNULL(strHASCsiteID, N''), 3, 5),
					@strSiteID = strSiteID
				FROM tstSite
				WHERE idfsSite = @siteId
			END

		SET @HASCCodeSite = ISNULL(@HASCCodeSite, '')
		SET @strSiteID = ISNULL(@strSiteID, '')
		SET @Year = Year(getdate())

		SELECT @NextID = ISNULL(intPreviousNumberValue, 0),
			@CurrentID = ISNULL(intPreviousNumberValue, 0),
			@Suffix = ISNULL(strSuffix, N''),
			@Prefix = ISNULL(strPrefix, N''),
			@MinNumberLength = ISNULL(intMinNumberLength, 5),
			@ShowPrefix = ISNULL(blnUsePrefix, 0),
			@ShowSiteID = ISNULL(blnUseSiteID, 0),
			@ShowYear = ISNULL(blnUseYear, 0),
			@ShowHASCCodeSite = ISNULL(blnUseHACSCodeSite, 0),
			@ShowAlphaNumeric = ISNULL(blnUseAlphaNumericValue, 0),
			@idfsNumberName = ISNULL(idfsNumberName, 0)
		FROM dbo.tstNextNumbers a
		WHERE strDocumentName = @ObjectName

		IF @@ROWCOUNT = 0
		BEGIN
			SELECT @idfsNumberName = ISNULL(idfsBaseReference, 0)
			FROM dbo.trtBaseReference
			WHERE strDefault = @ObjectName

			IF @@ROWCOUNT = 0
			BEGIN
				SET @returnCode = - 1
				SET @returnMsg = 'Please have EIDSS Administrator generate a Unique Numbering Schema for ' + @ObjectName + '.'

				RETURN
			END
			ELSE
			BEGIN
				SET @Prefix = CASE 
						WHEN @ObjectName = 'Vet Aggregate Disease Report'
							THEN 'VAD'
						WHEN @ObjectName = 'Animal'
							THEN 'ANM'
						WHEN @ObjectName = 'Batch Test Barcode'
							THEN 'BTB'
						WHEN @ObjectName = 'Box Barcode'
							THEN 'BBC'
						WHEN @ObjectName = 'Farm'
							THEN 'FRM'
						WHEN @ObjectName = 'Freezer Barcode'
							THEN 'FBC'
						WHEN @ObjectName = 'Shelf Barcode'
							THEN 'SBC'
						WHEN @ObjectName = 'Rack Barcode'
							THEN 'RBC'
						WHEN @ObjectName = 'Animal Group'
							THEN 'AGP'
						WHEN @ObjectName = 'Human Disease Report'
							THEN 'HUM'
						WHEN @ObjectName = 'Outbreak Session'
							THEN 'OUT'
						WHEN @ObjectName = 'Sample Field Barcode'
							THEN 'SFB'
						WHEN @ObjectName = 'Sample'
							THEN 'SAD'
						WHEN @ObjectName = 'Pendide Test'
							THEN 'PEN'
						WHEN @ObjectName = 'Vet Disease Report'
							THEN 'VET'
						WHEN @ObjectName = 'Vet Case Field Accession Number'
							THEN 'VFN'
						WHEN @ObjectName = 'Sample Transfer Barcode'
							THEN 'STB'
						WHEN @ObjectName = 'Active Surveillance Campaign'
							THEN 'SCV'
						WHEN @ObjectName = 'Active Surveillance Session'
							THEN 'SSV'
						WHEN @ObjectName = 'Vector Surveillance Session'
							THEN 'VSS'
						WHEN @ObjectName = 'Vector Surveillance Vector'
							THEN 'VSR'
						WHEN @ObjectName = 'Vector Surveillance Summary Vector'
							THEN 'VSM'
						WHEN @ObjectName = 'Basic Syndromic Surveillance Form'
							THEN 'SSF'
						WHEN @ObjectName = 'Basic Syndromic Surveillance Aggregate Form'
							THEN 'SSA'
						WHEN @ObjectName = 'EIDSS Person'
							THEN 'PER'
						WHEN @ObjectName = 'Human Active Surveillance Campaign'
							THEN 'SCH'
						WHEN @ObjectName = 'Human Active Surveillance Session'
							THEN 'SSH'
						WHEN @ObjectName = 'Human Outbreak Case'
							THEN 'HOC'
						WHEN @ObjectName = 'Vet Outbreak Case'
							THEN 'VOC'
						WHEN @ObjectName = 'Weekly Reporting Form'
							THEN 'HWR'
						END

				EXECUTE dbo.USP_GBL_NextNumberInit_GET @idfsNumberName,
					@ObjectName,
					@Prefix,
					NULL,
					0,
					4,
					0

				SELECT @NextID= ISNULL(intPreviousNumberValue, 0),
			        @CurrentID = ISNULL(intNumberValue, 0),
					@Suffix = ISNULL(strSuffix, N''),
					@Prefix = ISNULL(strPrefix, N''),
					@MinNumberLength = ISNULL(intMinNumberLength, 5),
					@ShowPrefix = ISNULL(blnUsePrefix, 0),
					@ShowSiteID = ISNULL(blnUseSiteID, 0),
					@ShowYear = ISNULL(blnUseYear, 0),
					@ShowHASCCodeSite = ISNULL(blnUseHACSCodeSite, 0),
					@ShowAlphaNumeric = ISNULL(blnUseAlphaNumericValue, 0),
					@idfsNumberName = ISNULL(idfsNumberName, 0)
				FROM dbo.tstNextNumbers a
				WHERE strDocumentName = @ObjectName
			END
		END
		ELSE
		BEGIN
			--If system configuration is set to show, then check against the barcode module to see if it was requested to show as well
			IF @ShowYear = 1 AND @blnUseYear = 1
			BEGIN
				IF NOT EXISTS (
						SELECT *
						FROM dbo.tstNextNumbers
						WHERE idfsNumberName = @idfsNumberName
							AND intYear = @Year
						)
					UPDATE dbo.tstNextNumbers
					SET intNumberValue = 0,
						intPreviousNumberValue = 0,
						intYear = @Year
					WHERE idfsNumberName = @idfsNumberName
			END
		END

		BEGIN TRANSACTION

		BEGIN TRY
			RETRY:

			DECLARE @CheckNumber BIT
			DECLARE @AttemptCount INT

			SET @CheckNumber = 1
			SET @AttemptCount = 0

			SET @NextID = @NextID - 1

			--Restrict new unique next number search attempts by 1000 
			WHILE @CheckNumber = 1
				AND @AttemptCount < 1000
			BEGIN
				IF @AttemptCount = 0
					SET @NextID = @NextID + 1
				ELSE
					SET @NextID = @NextID + 100

				IF @ShowAlphaNumeric = 1
					SET @NextNumberValue = dbo.FN_GBL_AlphNumeric_GET(@NextID, @MinNumberLength)
				ELSE
					SET @NextNumberValue = CAST(@NextID AS VARCHAR(100))

				IF (@NextNumberValue IS NULL)
				BEGIN
					UPDATE dbo.tstNextNumbers
					SET intMinNumberLength = @MinNumberLength + 1,
						intNumberValue = 0
					WHERE idfsNumberName = @idfsNumberName

					SET @MinNumberLength = @MinNumberLength + 1
					SET @NextID = 0
					SET @CurrentID = 0


					GOTO retry
				END

				IF LEN(@NextNumberValue) > @MinNumberLength
				BEGIN
					SET @returnCode = - 1
					SET @returnMsg = 'Cannot generate new unique value.'

					RETURN
				END

				IF @MinNumberLength > 0
					AND LEN(@NextNumberValue) < @MinNumberLength
				BEGIN
					SET @NextNumberValue = REPLACE(SPACE(@MinNumberLength - LEN(@NextNumberValue)) + @NextNumberValue, N' ', 0)
				END

				SET @NextNumberValue = @NextNumberValue + @Suffix

				--If system configuration is set to show, then check against the barcode module to see if it was requested to show as well
				------------------------------START------------------------------
				IF @ShowYear = 1 AND @blnUseYear = 1
					BEGIN
						SET @NextNumberValue = RIGHT(@Year, 2) + @NextNumberValue
					END

				IF @ShowSiteID = 1 AND @siteId IS NOT NULL
					BEGIN
						IF @ShowHASCCodeSite = 1
							BEGIN
								SET @NextNumberValue = @HASCCodeSite + @NextNumberValue
							END
						ELSE
							BEGIN
								SET @NextNumberValue = @strSiteID + @NextNumberValue
							END
					END

				IF @ShowPrefix = 1 AND @blnUsePrefix = 1
					BEGIN
						SET @NextNumberValue = @Prefix + @NextNumberValue
					END
				------------------------------END------------------------------

				DECLARE @CNT INT

				----------------------- Specimen Field Barcode
				IF @idfsNumberName = 10057019
				BEGIN
					IF NOT EXISTS (
							SELECT idfMaterial
							FROM dbo.tlbMaterial
							WHERE strFieldBarcode = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbMaterial
				END
						----------------------- Container (specimen barcode is used for container)
				ELSE IF @idfsNumberName = 10057020
				BEGIN
					IF NOT EXISTS (
							SELECT idfMaterial
							FROM dbo.tlbMaterial
							WHERE strBarcode = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbMaterial
				END
						----------------------- Freezer
				ELSE IF @idfsNumberName = 10057011
				BEGIN
					IF NOT EXISTS (
							SELECT idfFreezer
							FROM dbo.tlbFreezer
							WHERE strBarcode = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbFreezer
				END
						----------------------- Freezer Box
				ELSE IF @idfsNumberName = 10057006
				BEGIN
					IF NOT EXISTS (
							SELECT idfSubdivision
							FROM dbo.tlbFreezerSubdivision
							WHERE strBarcode = @NextNumberValue
								AND idfsSubdivisionType = 39890000000
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbFreezerSubdivision
						WHERE idfsSubdivisionType = 39890000000
				END
						----------------------- Freezer Shelf
				ELSE IF @idfsNumberName = 10057012
				BEGIN
					IF NOT EXISTS (
							SELECT idfSubdivision
							FROM dbo.tlbFreezerSubdivision
							WHERE strBarcode = @NextNumberValue
								AND idfsSubdivisionType = 39900000000
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbFreezerSubdivision
						WHERE idfsSubdivisionType = 39900000000
				END
						----------------------- Freezer Rack
				ELSE IF @idfsNumberName = 10057039
				BEGIN
					IF NOT EXISTS (
							SELECT idfSubdivision
							FROM dbo.tlbFreezerSubdivision
							WHERE strBarcode = @NextNumberValue
								AND idfsSubdivisionType = 10093001
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbFreezerSubdivision
						WHERE idfsSubdivisionType = 10093001
				END
						----------------------- Human Disease Report
				ELSE IF @idfsNumberName = 10057014
				BEGIN
					IF NOT EXISTS (
							SELECT strCaseID
							FROM dbo.tlbHumanCase
							WHERE strCaseID = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbHumanCase
				END
						----------------------- Human Aggregate Disease Report
				ELSE IF @idfsNumberName = 10057001
				BEGIN
					IF NOT EXISTS (
							SELECT idfAggrCase
							FROM dbo.tlbAggrCase
							WHERE strCaseID = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbAggrCase
						WHERE idfsAggrCaseType = 0
				END
						----------------------- Veterinary Aggregate Action Report
				ELSE IF @idfsNumberName = 10057002
				BEGIN
					IF NOT EXISTS (
							SELECT idfAggrCase
							FROM dbo.tlbAggrCase
							WHERE strCaseID = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbAggrCase
						WHERE idfsAggrCaseType = 0
				END
						----------------------- Veterinary Aggregate Disease Report
				ELSE IF @idfsNumberName = 10057003
				BEGIN
					IF NOT EXISTS (
							SELECT idfAggrCase
							FROM dbo.tlbAggrCase
							WHERE strCaseID = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbAggrCase
						WHERE idfsAggrCaseType = 0
				END
						----------------------- Veterinary Disease Report
				ELSE IF @idfsNumberName = 10057024
				BEGIN
					IF NOT EXISTS (
							SELECT strCaseID
							FROM dbo.tlbVetCase
							WHERE strCaseID = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbVetCase
				END
						----------------------- Veterinary Disease Report Field Accession ID
				ELSE IF @idfsNumberName = 10057025
				BEGIN
					IF NOT EXISTS (
							SELECT idfVetCase
							FROM dbo.tlbVetCase
							WHERE strFieldAccessionID = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbVetCase
				END
						----------------------- Outbreak
				ELSE IF @idfsNumberName = 10057015
				BEGIN
					IF NOT EXISTS (
							SELECT idfOutbreak
							FROM dbo.tlbOutbreak
							WHERE strOutbreakID = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM tlbOutbreak
				END
						----------------------- Outbreak Case Report (Human)
				ELSE IF @idfsNumberName = 10057037
				BEGIN
					IF NOT EXISTS (
							SELECT OutBreakCaseReportUID
							FROM dbo.OutbreakCaseReport
							WHERE strOutbreakCaseID = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM OutbreakCaseReport
				END
						----------------------- Outbreak Case Report (Veterinary)
				ELSE IF @idfsNumberName = 10057038
				BEGIN
					IF NOT EXISTS (
							SELECT OutBreakCaseReportUID
							FROM dbo.OutbreakCaseReport
							WHERE strOutbreakCaseID = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM OutbreakCaseReport
				END
						----------------------- Farm
				ELSE IF @idfsNumberName = 10057010
				BEGIN
					IF NOT EXISTS (
							SELECT idfFarm
							FROM dbo.tlbFarm
							WHERE strFarmCode = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM tlbFarm
				END
						----------------------- Batch Test
				ELSE IF @idfsNumberName = 10057005
				BEGIN
					IF NOT EXISTS (
							SELECT idfBatchTest
							FROM dbo.tlbBatchTest
							WHERE strBarcode = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbBatchTest
				END
						----------------------- Herd/Flock
				ELSE IF @idfsNumberName = 10057013
				BEGIN
					IF NOT EXISTS (
							SELECT idfHerd
							FROM dbo.tlbHerd
							WHERE strHerdCode = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbHerd
				END
						----------------------- Animal
				ELSE IF @idfsNumberName = 10057004
				BEGIN
					IF NOT EXISTS (
							SELECT idfAnimal
							FROM dbo.tlbAnimal
							WHERE strAnimalCode = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbAnimal
				END
						----------------------- Sample Transfer
				ELSE IF @idfsNumberName = 10057026
				BEGIN
					IF NOT EXISTS (
							SELECT idfTransferOut
							FROM dbo.tlbTransferOUT
							WHERE strBarcode = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbTransferOUT
				END
						----------------------- Active Surveillance Campaign
				ELSE IF @idfsNumberName = 10057027
				BEGIN
					IF NOT EXISTS (
							SELECT idfCampaign
							FROM dbo.tlbCampaign
							WHERE strCampaignID = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbCampaign
				END
						----------------------- Active Surveillance Session
				ELSE IF @idfsNumberName = 10057028
				BEGIN
					IF NOT EXISTS (
							SELECT idfMonitoringSession
							FROM dbo.tlbMonitoringSession
							WHERE strMonitoringSessionID = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbMonitoringSession
				END
						----------------------- Vector Surveillance Session
				ELSE IF @idfsNumberName = 10057029
				BEGIN
					IF NOT EXISTS (
							SELECT idfVectorSurveillanceSession
							FROM dbo.tlbVectorSurveillanceSession
							WHERE strSessionID = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbVectorSurveillanceSession
				END
						----------------------- Vector Surveillance Vector
				ELSE IF @idfsNumberName = 10057030
				BEGIN
					IF NOT EXISTS (
							SELECT idfVector
							FROM dbo.tlbVector
							WHERE strVectorID = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbVector
				END
						----------------------- Vector Surveillance Summary Vector
				ELSE IF @idfsNumberName = 10057031
				BEGIN
					IF NOT EXISTS (
							SELECT idfsVSSessionSummary
							FROM dbo.tlbVectorSurveillanceSessionSummary
							WHERE strVSSessionSummaryID = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbVectorSurveillanceSessionSummary
				END
						----------------------- Basic Syndromic Surveillance Form
				ELSE IF @idfsNumberName = 10057032
				BEGIN
					IF NOT EXISTS (
							SELECT idfBasicSyndromicSurveillance
							FROM dbo.tlbBasicSyndromicSurveillance
							WHERE strFormID = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbBasicSyndromicSurveillance
				END
						----------------------- Basic Syndromic Surveillance Aggregate Form
				ELSE IF @idfsNumberName = 10057033
				BEGIN
					IF NOT EXISTS (
							SELECT idfAggregateHeader
							FROM dbo.tlbBasicSyndromicSurveillanceAggregateHeader
							WHERE strFormID = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbBasicSyndromicSurveillanceAggregateHeader
				END
						----------------------- EIDSS Person ID
				ELSE IF @idfsNumberName = 10057034
				BEGIN
					IF NOT EXISTS (
							SELECT EIDSSPersonID
							FROM dbo.HumanActualAddlInfo
							WHERE EIDSSPersonID = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.HumanActualAddlInfo
				END
				----------------------- Weekly Reporting Form
				ELSE IF @idfsNumberName = 10057040
				BEGIN
					IF NOT EXISTS (
							SELECT idfReportForm
							FROM dbo.tlbReportForm
							WHERE strReportFormID = @NextNumberValue
							)
						BREAK

					IF @AttemptCount = 0
						SELECT @CNT = COUNT(*)
						FROM dbo.tlbReportForm
				END
				ELSE
					SET @CheckNumber = 0

				IF @AttemptCount = 0
					AND NOT @CNT IS NULL
					SET @NextID = @CNT + 1
				SET @AttemptCount = @AttemptCount + 1
			END

			IF @AttemptCount < 1000
			BEGIN
				UPDATE dbo.tstNextNumbers
				SET intPreviousNumberValue = @NextID+1,
				intNumberValue = @CurrentID
				WHERE idfsNumberName = @idfsNumberName

				COMMIT TRAN

				RETURN
			END
		END TRY

		--
		BEGIN CATCH
			IF (XACT_STATE()) = - 1
			BEGIN
				PRINT N'The transaction is in an uncommittable state. ' + 'Rolling back transaction.'

				ROLLBACK TRAN;
			END
			ELSE IF (XACT_STATE()) = 1
			BEGIN
				IF @@TRANCOUNT < 2
					ROLLBACK TRAN
				ELSE
					COMMIT TRAN
			END

			IF @AttemptCount >= 100
			BEGIN
				SET @returnCode = - 1
				SET @returnMsg = 'Can''t generate new number'

				RETURN
			END
			ELSE
			BEGIN
				SET @returnCode = - 1
				SET @returnMsg = 'Unknown error during generating new number'

				RETURN
			END

			DECLARE @strNextNumberName AS VARCHAR(200)

			SET @strNextNumberName = CAST(@idfsNumberName AS VARCHAR)
			SET @returnCode = - 1
			SET @returnMsg = 'NumberType:%s'

			RETURN
		END CATCH
	END
