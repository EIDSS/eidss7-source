/*******************************************************
NAME						: [USP_CONF_AggrSanitaryActionMTXReportJSON_POST]


Description					: Saves Entries For Sanitary Matrix Report FROM A JSON STRING

Author						: Lamont Mitchell

Revision History
		
			Name							Date								Change Detail
			Lamont Mitchell					3/04/19							Initial Created
*******************************************************/
CREATE PROCEDURE [dbo].[USP_CONF_AggrSanitaryActionMTXReportJSON_POST]
	
@idfAggrSanitaryActionMTX		BIGINT NULL,
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
		IF EXISTS (SELECT * FROM [dbo].[tlbAggrSanitaryActionMTX] WHERE idfVersion = @idfVersion )
			BEGIN
				UPDATE [dbo].[tlbAggrSanitaryActionMTX]
				SET
				[intRowStatus] =		1
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
			,tidfsSanitaryAction BIGINT
			,tintNumRow INT

		)
		
		INSERT INTO @Disease (tidfVersion, tidfsSanitaryAction, tintNumRow)
		SELECT @idfVersion, idfsSanitaryAction, intNumRow
		FROM OPENJSON(@JsonString)
		 WITH (
			IdfVersion BIGINT,
			IdfsSanitaryAction BIGINT,
			IntNumRow INT
		)
		
		--Select * from @Disease;

	  DECLARE @rowCount  INT = 0;
	  set  @rowCount =  (SELECT max(tintNumRow) from @Disease);
	  print @rowCount;
	  DECLARE @_int  int = 0;
	  WHILE @_int <= @rowCount
			BEGIN
		
				IF EXISTS (SELECT * FROM [dbo].[tlbAggrSanitaryActionMTX] WHERE idfVersion = @idfVersion 
				AND idfsSanitaryAction = (Select tidfsSanitaryAction from @Disease where tintNumRow = @_int)  AND intRowStatus in(0, 1))
				BEGIN
					
					DECLARE @aggHumanCaseMtxId BIGINT
					SET  @aggHumanCaseMtxId = (Select idfAggrSanitaryActionMTX from  [dbo].tlbAggrSanitaryActionMTX WHERE idfVersion = @idfVersion 
					AND idfsSanitaryAction = (Select tidfsSanitaryAction from @Disease where tintNumRow = @_int));

					UPDATE [tlbAggrSanitaryActionMTX]
					SET 
					[intRowStatus] = 0,
					[intNumRow] = @_int
					WHERE 
					idfsSanitaryAction = (Select tidfsSanitaryAction from @Disease WHERE tintNumRow = @_int) AND
					idfVersion = (Select tidfVersion from @Disease WHERE tintNumRow = @_int) AND
					idfAggrSanitaryActionMTX = @aggHumanCaseMtxId;
					Print 'Updated'
				END
				ELSE
				BEGIN
				Print 'Try Insert'

			
				IF EXISTS(Select * from @Disease where tintNumRow = @_int)
					BEGIN
					Print 'Item is in Disease Table: ' + CONVERT(varchar(10), @_int);

					INSERT INTO @SupressSelect
					EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbAggrSanitaryActionMTX', @idfAggrSanitaryActionMTX OUTPUT;
						INSERT INTO [tlbAggrSanitaryActionMTX]
					   (
								idfAggrSanitaryActionMTX
							   ,idfVersion
							   ,idfsSanitaryAction
							   ,intNumRow
							   ,intRowStatus
					   
						)
						SELECT	    
								@idfAggrSanitaryActionMTX
								,tidfVersion
								,tidfsSanitaryAction
								,tintNumRow
								,0
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
			SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage',@idfAggrSanitaryActionMTX 'idfAggrSanitaryActionMTX'
		END TRY
		
		BEGIN CATCH
				THROW;
		END CATCH
END
