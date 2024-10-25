/*******************************************************
NAME						: [USP_CONFtlbAggrProphylacticActionMTXReportJSON_POST]


Description					: Saves Entries For Prophylactic Matrix Report FROM A JSON STRING

Author						: Lamont Mitchell

Revision History
		
			Name							Date								Change Detail
			Lamont Mitchell					3/04/19							Initial Created
*******************************************************/
CREATE PROCEDURE [dbo].[USP_CONFtlbAggrProphylacticActionMTXReportJSON_POST]
	

@idfAggrProphylacticActionMTX	BIGINT NULL,
@idfVersion						BIGINT NULL, 
@inJsonString					Varchar(Max) NULL


AS 
BEGIN
	DECLARE @returnMsg					VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode					BIGINT = 0;
	Declare @idfsReferenceType			BIGINT ;
	Declare @JsonString					Varchar(Max); 
	SET NOCOUNT ON;

	BEGIN TRY
	SET @JsonString = @inJsonString;
		IF EXISTS (SELECT * FROM [dbo].[tlbAggrProphylacticActionMTX] WHERE idfVersion = @idfVersion )
			BEGIN
				UPDATE [dbo].[tlbAggrProphylacticActionMTX]
				SET
				[intRowStatus] =		1
				,[AuditUpdateDTM] = GETDATE()
				WHERE [idfVersion] = @idfVersion
			END
			
	Declare @SupressSelect table
	( 
			returnCode int,
			returnMessage varchar(200)
	)
	Declare @Disease Table
		( 
			 tidfVersion BIGINT
			,tidfsDiagnosis BIGINT
			,tidfsSpeciesType BIGINT
			,tidfsProphilacticAction BIGINT
			,tintNumRow INT

		)
		
		INSERT INTO @Disease (tidfVersion, tidfsDiagnosis,tidfsSpeciesType,tidfsProphilacticAction, tintNumRow)
		SELECT @idfVersion, idfsDiagnosis,idfsSpeciesType,idfsProphilacticAction, intNumRow
		FROM OPENJSON(@JsonString)
		 WITH (
			IdfVersion BIGINT,
			IdfsDiagnosis BIGINT, 
			IdfsSpeciesType BIGINT,
			IdfsProphilacticAction BIGINT,
			IntNumRow INT
		)
	  
	  --Select * from @Disease;

	  DECLARE @rowCount  INT = 0;
	  set  @rowCount =  (SELECT max(tintNumRow) from @Disease);
	  print @rowCount;
	  DECLARE @_int  int = 0;
	  WHILE @_int <= @rowCount
			BEGIN
		
				IF EXISTS (SELECT * FROM [dbo].[tlbAggrProphylacticActionMTX] WHERE idfVersion = @idfVersion 
				AND idfsDiagnosis = (Select tidfsDiagnosis from @Disease where tintNumRow = @_int)  
				AND idfsSpeciesType = (Select tidfsSpeciesType from @Disease where tintNumRow = @_int)
				AND idfsProphilacticAction = (Select tidfsProphilacticAction from @Disease where tintNumRow = @_int)
				AND intRowStatus in(0, 1))

				BEGIN
					
					DECLARE @aggHumanCaseMtxId BIGINT
					SET  @aggHumanCaseMtxId = (Select idfAggrProphylacticActionMTX from  [dbo].tlbAggrProphylacticActionMTX WHERE idfVersion = @idfVersion 
					AND idfsDiagnosis = (Select tidfsDiagnosis from @Disease where tintNumRow = @_int)
					AND idfsSpeciesType = (Select tidfsSpeciesType from @Disease where tintNumRow = @_int)
					AND idfsProphilacticAction = (Select tidfsProphilacticAction from @Disease where tintNumRow = @_int)
					);
					
					

					UPDATE [tlbAggrProphylacticActionMTX]
					SET 
					[intRowStatus] = 0,
					[intNumRow] = @_int,
					[AuditUpdateDTM] = GETDATE()
					WHERE 
					idfsDiagnosis = (Select tidfsDiagnosis from @Disease WHERE tintNumRow = @_int) AND
					idfVersion = (Select tidfVersion from @Disease WHERE tintNumRow = @_int) 
					AND idfsSpeciesType = (Select tidfsSpeciesType from @Disease where tintNumRow = @_int)
					AND idfsProphilacticAction = (Select tidfsProphilacticAction from @Disease where tintNumRow = @_int)
					Print 'Updated'
				END
				ELSE
				BEGIN
				Print 'Try Insert'

			
				IF EXISTS(Select * from @Disease where tintNumRow = @_int)
					BEGIN
					Print 'Item is in Disease Table: ' + CONVERT(varchar(10), @_int);

					INSERT INTO @SupressSelect
					EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbAggrProphylacticActionMTX', @idfAggrProphylacticActionMTX OUTPUT;
						INSERT INTO [tlbAggrProphylacticActionMTX]
					   (
								idfAggrProphylacticActionMTX
							   ,idfVersion
							   ,idfsDiagnosis
							   ,idfsSpeciesType
							   ,idfsProphilacticAction
							   ,intNumRow
							   ,intRowStatus
							   ,AuditCreateDTM 
					   
						)
						SELECT	    
								@idfAggrProphylacticActionMTX
								,tidfVersion
								,tidfsDiagnosis
								,tidfsSpeciesType
								,tidfsProphilacticAction
								,tintNumRow
								,0
								,GetDate()
						FROM @Disease where tintNumRow = @_int;
					END
					ELSE
					BEGIN
					Print 'Item not there at : ' + CONVERT(varchar(10), @_int);
					END
				END
			
				Print @_int;
				Set @_int = @_int + 1
			END
			SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage',@idfAggrProphylacticActionMTX 'idfAggrProphylacticActionMTX'
		END TRY
		
		BEGIN CATCH
				THROW;
		END CATCH
END
