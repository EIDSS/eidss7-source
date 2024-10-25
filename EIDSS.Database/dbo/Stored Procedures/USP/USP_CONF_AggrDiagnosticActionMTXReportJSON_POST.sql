/*******************************************************
NAME						: [USP_CONF_AggrDiagnosticActionMTXReportJSON_POST]


Description					: Saves Entries For Diagnostic Matrix Report FROM A JSON STRING

Author						: Lamont Mitchell

Revision History
		
			Name							Date								Change Detail
			Lamont Mitchell					3/04/19							Initial Created
*******************************************************/
CREATE PROCEDURE [dbo].[USP_CONF_AggrDiagnosticActionMTXReportJSON_POST]
	
@idfAggrDiagnosticActionMTX		BIGINT NULL,
@idfVersion						BIGINT NULL,
@inJsonString					VARCHAR(MAX) NULL

AS 

BEGIN

	DECLARE @returnMsg					VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode					BIGINT = 0;
	DECLARE @idfsReferenceType			BIGINT ;
	DECLARE @JsonString					VARCHAR(MAX); 
	SET NOCOUNT ON;

	BEGIN TRY

		SET @JsonString = @inJsonString;

		IF EXISTS (SELECT * FROM [dbo].[tlbAggrDiagnosticActionMTX] WHERE idfVersion = @idfVersion )
			BEGIN
				UPDATE [dbo].[tlbAggrDiagnosticActionMTX]
				SET
				[intRowStatus] = 1
				WHERE [idfVersion] = @idfVersion				
			END
			
		DECLARE @SupressSelect TABLE
		( 
			returnCode INT,
			returnMessage VARCHAR(200)
		)

		DECLARE @Disease TABLE
		( 
			tidfVersion BIGINT
			,tidfsDiagnosis BIGINT
			,tidfsSpeciesType BIGINT
			,tidfsDiagnosticAction BIGINT
			,tintNumRow INT
		)
		
		INSERT INTO @Disease (tidfVersion, tidfsDiagnosis,tidfsSpeciesType,tidfsDiagnosticAction, tintNumRow)
			SELECT idfVersion, idfsDiagnosis,idfsSpeciesType,idfsDiagnosticAction, intNumRow
			FROM OPENJSON(@JsonString)
				WITH (
				IdfVersion BIGINT,
				IdfsDiagnosis BIGINT, 
				IdfsSpeciesType BIGINT,
				IdfsDiagnosticAction BIGINT,
				IntNumRow INT
			)

		--SELECT * FROM @Disease;

		DECLARE @rowCount  INT = 0;
		SET  @rowCount =  (SELECT max(tintNumRow) FROM @Disease);
		PRINT @rowCount;
		DECLARE @_int  int = 0;

		-- Loop through the JSON temp table
		WHILE @_int <= @rowCount

		BEGIN
		
			IF EXISTS (SELECT * FROM [dbo].[tlbAggrDiagnosticActionMTX] WHERE idfVersion = @idfVersion 
			AND idfsDiagnosis = (Select tidfsDiagnosis from @Disease where tintNumRow = @_int)  AND intRowStatus in(0, 1)
			AND idfsSpeciesType = (Select tidfsSpeciesType from @Disease where tintNumRow = @_int)  AND intRowStatus in(0, 1)
			AND idfsDiagnosticAction = (Select tidfsDiagnosticAction from @Disease where tintNumRow = @_int)  AND intRowStatus in(0, 1))
				BEGIN
					
					DECLARE @aggHumanCaseMtxId BIGINT

					SET  @aggHumanCaseMtxId = (Select idfAggrDiagnosticActionMTX from  [dbo].tlbAggrDiagnosticActionMTX WHERE idfVersion = @idfVersion 
					AND idfsDiagnosis = (Select tidfsDiagnosis from @Disease where tintNumRow = @_int)
					AND idfsSpeciesType = (Select tidfsSpeciesType from @Disease where tintNumRow = @_int)
					AND idfsDiagnosticAction = (Select tidfsDiagnosticAction from @Disease where tintNumRow = @_int));
					
					UPDATE [tlbAggrDiagnosticActionMTX]
					SET 
						[intRowStatus] = 0,
						[intNumRow] = @_int
					WHERE 
						idfsDiagnosis = (Select tidfsDiagnosis from @Disease WHERE tintNumRow = @_int) AND
						idfsSpeciesType = (Select tidfsSpeciesType from @Disease WHERE tintNumRow = @_int) AND
						idfsDiagnosticAction = (Select tidfsDiagnosticAction from @Disease WHERE tintNumRow = @_int) AND
						idfVersion = (Select tidfVersion from @Disease WHERE tintNumRow = @_int) AND
						idfAggrDiagnosticActionMTX = @aggHumanCaseMtxId;

					PRINT 'Updated'
				END
			ELSE
				BEGIN
					PRINT 'Try Insert'
			
					IF EXISTS(SELECT * FROM @Disease WHERE tintNumRow = @_int)
						BEGIN
							PRINT 'Item is in Disease Table: ' + CONVERT(varchar(10), @_int);

							INSERT INTO @SupressSelect
							EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbAggrDiagnosticActionMTX', @idfAggrDiagnosticActionMTX OUTPUT;

							INSERT INTO [tlbAggrDiagnosticActionMTX]
							(
								idfAggrDiagnosticActionMTX
								,idfVersion
								,idfsDiagnosis
								,idfsSpeciesType
								,idfsDiagnosticAction
								,intNumRow
								,intRowStatus					   
							)
							SELECT	    
								@idfAggrDiagnosticActionMTX
								,@idfVersion
								,tidfsDiagnosis
								,tidfsSpeciesType
								,tidfsDiagnosticAction
								,tintNumRow
								,0
							FROM @Disease WHERE tintNumRow = @_int;
						END
					ELSE
						BEGIN
							PRINT 'Item not there at : ' + CONVERT(varchar(10), @_int);
						END
					END
			
					PRINT @_int;
					SET @_int = @_int + 1
				END
			
		SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage',@idfAggrDiagnosticActionMTX 'idfAggrDiagnosticActionMTX'

	END TRY
		
	BEGIN CATCH
		THROW;
	END CATCH

END
