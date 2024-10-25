-- ================================================================================================
-- Name: USP_ADMIN_FF_Copy_Observation
-- Description: Copies the answers of a flex form (observation) to another observation.
--          
-- Revision History:
-- Name            Date			Change
-- --------------- ----------	--------------------------------------------------------------------
-- Doug Albanese   5/6/2020		Initial release for new API.
-- Stephen Long    05/21/2022   Removed suppress select call as it is throwing a nested insert-exec
--                              exception via SQL.  Removed rollback transaction as there is no 
--                              transaction begun.
--	Doug Albanese	07/01/2022	Change the reception of @varValue to be NVARCHAR(MAX)
--  Doug Albanese   09/22/2022  Ending Select statement is not needed, since this SP is called from other SPs only.
-- Doug Albanese  12/30/2022	 the "answer" begin passed to USP_ADMIN_FF_ActivityParameters_Set needed to be set as JSON
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_Copy_Observation]
(
    @idfObservation BIGINT OUTPUT,
    @User NVARCHAR(50),
    @idfsSite BIGINT = NULL
)
AS
BEGIN
    DECLARE @returnCode				   INT = 0;
    DECLARE @returnMsg				   NVARCHAR(MAX) = 'SUCCESS';

    DECLARE @idfsParameter			   BIGINT
    DECLARE @idfActivityParameters	   BIGINT
    DECLARE @varValue				   NVARCHAR(4000)
    DECLARE @idfsFormTemplate		   BIGINT
    DECLARE @newidfObservation		   BIGINT
    DECLARE @newidfActivityParameters  BIGINT
	DECLARE @idfsEditor				   BIGINT
	DECLARE	@idfRow					   BIGINT
	
   DECLARE @answers TABLE  (
		 idfsParameter	 BIGINT,
		 idfsEditor		 BIGINT,
		 answer			 NVARCHAR(4000),
		 idfRow			 BIGINT
   )

   DECLARE @JSONAnswers NVARCHAR(MAX)

    Declare @SupressSelect TABLE
    (
        retrunCode int,
        returnMessage varchar(200)
    )

    DECLARE @ParameterAnswers TABLE
    (
        idfActivityParameters	 BIGINT,
        idfsParameter			 BIGINT,
        varValue				 NVARCHAR(4000),
		idfsEditor				 BIGINT,
		idfRow					 BIGINT
    )

    BEGIN TRY
        SELECT @idfsFormTemplate = idfsFormTemplate
        FROM tlbObservation
        WHERE idfObservation = @idfObservation

        INSERT INTO @ParameterAnswers
        SELECT CONVERT(BIGINT, AP.idfActivityParameters),
               CONVERT(BIGINT, AP.idfsParameter),
               CONVERT(NVARCHAR(4000), AP.varValue),
			   CONVERT(BIGINT, P.idfsEditor),
			   CONVERT(BIGINT, AP.idfRow)
        FROM dbo.tlbActivityParameters AP
		INNER JOIN ffParameter P
		ON P.idfsParameter = AP.idfsParameter
        WHERE idfObservation = @idfObservation

        --INSERT INTO @SupressSelect
        EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbObservation', @newidfObservation OUTPUT

        INSERT INTO dbo.tlbObservation
        (
            idfObservation,
            idfsFormTemplate,
            intRowStatus,
            idfsSite,
            AuditCreateUser,
            AuditCreateDTM
        )
        VALUES
        (
			@newidfObservation, 
			@idfsFormTemplate, 
			0, 
			@idfsSite, 
			@User, 
			GETDATE()
		)

        WHILE EXISTS (SELECT TOP 1 idfActivityParameters FROM @ParameterAnswers)
			BEGIN
				SELECT TOP 1
					@idfActivityParameters = idfActivityParameters,
					@idfsParameter = idfsParameter,
					@varValue = CAST(varValue AS NVARCHAR),
					@idfsEditor = idfsEditor,
					@idfRow = idfRow
				FROM @ParameterAnswers
				
				INSERT INTO @answers (idfsParameter, idfsEditor, answer, idfRow)
				VALUES (@idfsParameter, @idfsEditor, @varValue, @idfRow)
				
				SET ROWCOUNT 1
				DELETE FROM @ParameterAnswers
				SET ROWCOUNT 0
			END

		 SET @JSONAnswers = (SELECT * FROM @answers FOR JSON AUTO)
				
		 --EXEC dbo.USP_ADMIN_FF_ActivityParametersForCopy_Set @idfObservation = @newidfObservation,
			--										  @idfsFormTemplate = @idfsFormTemplate,
			--										  @answers = @JSONAnswers,
			--										  @User = @User

        SET @idfObservation = @newidfObservation
        
    END TRY
    BEGIN CATCH
        SET @returnCode = ERROR_NUMBER();
        SET @returnMsg
            = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: '
              + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE())
              + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: '
              + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();;

        THROW;
    END CATCH
END
