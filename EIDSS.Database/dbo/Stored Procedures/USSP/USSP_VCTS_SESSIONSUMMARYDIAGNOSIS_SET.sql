

--*************************************************************
-- Name 				: USSP_VCTS_SESSIONSUMMARYDIAGNOSIS_SET
-- Description			: Vector Sessions Summary Diagnosis Insert & Update
--          
-- Author               : Mark Wilson/Steven Verner
-- Revision History
--		Name		Date		Change Detail
-- Mike Kornegay	04/21/2022	Added RowStatus for inactivating diagnosis items.
-- Mike Kornegay	05/12/2022	Removed return selects.
--
-- Testing code:
--*************************************************************

CREATE PROCEDURE [dbo].[USSP_VCTS_SESSIONSUMMARYDIAGNOSIS_SET]
(
     @idfsVSSessionSummaryDiagnosis BIGINT OUTPUT,
	 @idfsVSSessionSummary BIGINT,
	 @idfsDiagnosis BIGINT,
	 @intPositiveQuantity BIGINT,
	 @RowStatus INT,
	 @AuditUser NVARCHAR(100)
)
AS
DECLARE @returnCode					INT = 0 
DECLARE	@returnMsg					NVARCHAR(MAX) = 'SUCCESS' 
BEGIN
	BEGIN TRY

		IF NOT EXISTS (	SELECT idfsVSSessionSummaryDiagnosis FROM [dbo].[tlbVectorSurveillanceSessionSummaryDiagnosis]
						WHERE idfsVSSessionSummaryDiagnosis = @idfsVSSessionSummaryDiagnosis
						)
			BEGIN
				EXEC dbo.USP_GBL_NEXTKEYID_GET 
					@tableName = 'tlbVectorSurveillanceSessionSummaryDiagnosis', 
					@idfsKey = @idfsVSSessionSummaryDiagnosis OUTPUT
	
				INSERT 
				INTO	dbo.tlbVectorSurveillanceSessionSummaryDiagnosis
				(
				    idfsVSSessionSummaryDiagnosis,
				    idfsVSSessionSummary,
				    idfsDiagnosis,
				    intPositiveQuantity,
				    intRowStatus,
				    rowguid,
				    strMaintenanceFlag,
				    strReservedAttribute,
				    SourceSystemNameID,
				    SourceSystemKeyValue,
				    AuditCreateUser,
				    AuditCreateDTM,
				    AuditUpdateUser,
				    AuditUpdateDTM
				)
				VALUES
				(   
					@idfsVSSessionSummaryDiagnosis,
					@idfsVSSessionSummary,
					@idfsDiagnosis ,
					@intPositiveQuantity,
					0,
					NEWID(),
					NULL,
					NULL,
					10519001,
					'[{"idfsVSSessionSummaryDiagnosis":' + CAST(@idfsVSSessionSummaryDiagnosis AS NVARCHAR(300)) + '}]',
					@AuditUser,
					GETDATE(),
					@AuditUser,
					GETDATE()

			    )

			END
		ELSE 
			BEGIN
				UPDATE	dbo.tlbVectorSurveillanceSessionSummaryDiagnosis
				SET idfsVSSessionSummary = @idfsVSSessionSummary,
					idfsDiagnosis = @idfsDiagnosis,
					intPositiveQuantity = @intPositiveQuantity,
					intRowStatus = @RowStatus,
					AuditUpdateUser = @AuditUser,
					AuditUpdateDTM = GETDATE()
				WHERE idfsVSSessionSummaryDiagnosis = @idfsVSSessionSummaryDiagnosis

			END

	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
