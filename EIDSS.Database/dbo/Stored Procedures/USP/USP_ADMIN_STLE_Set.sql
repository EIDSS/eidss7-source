
--*************************************************************
-- Name 				: USP_ADMIN_STLE_Set
-- Description			: Insert/Update Settlement data
--          
-- Author               : Maheshwar D Deo
-- Revision History
--		Name       Date       Change Detail
-- Ricky Moss	  7/29/2019		Refactored to accommodate API Methods
-- Ricky Moss	  7/29/2019   Check for duplicate feature
--
-- Testing code:
--*************************************************************

CREATE PROCEDURE [dbo].[USP_ADMIN_STLE_Set]
(
	@idfsSettlementID					BIGINT			= NULL	--##PARAM @idfsSettlement - settlement ID
	,@strSettlementCode					NVARCHAR(200)	= NULL
	,@strEnglishName					NVARCHAR(200)	= NULL	--##PARAM @strEnglishName - settlement name in English
	,@idfsSettlementType				BIGINT			= NULL	--##PARAM @idfsSettlementType - settlement Type, reference to rftSettlementType (19000083)
	,@LocationUserControlidfsCountry	BIGINT			= NULL	--##PARAM @idfsCountry -  settlement country
	,@LocationUserControlidfsRegion		BIGINT			= NULL	--##PARAM @idfsRegion - settlement region
	,@LocationUserControlidfsRayon		BIGINT			= NULL	--##PARAM @idfsRayon - settlement rayon
	,@LocationUserControlstrLatitude	FLOAT			= NULL	--##PARAM @dblLatitude - settlement latitude
	,@LocationUserControlstrLongitude	FLOAT			= NULL	--##PARAM @dblLongitude - settlement longitude
	,@LocationUserControlstrElevation	INT				= NULL
	,@LangID							VARCHAR(50)		= NULL	--##PARAM @LangID - language ID
	,@strNationalName					NVARCHAR(200)	= NULL	--##PARAM @strNationalName - settlement name in language defined by @LangID
)
AS 
DECLARE @returnMsg VARCHAR(MAX) = 'SUCCESS'
DECLARE @returnCode BIGINT = 0
DECLARE @SupressSelect table
( 
	retrunCode INT,
	returnMessage VARCHAR(200)
)
DECLARE @existingDefault BIGINT
DECLARE @existingName BIGINT
BEGIN
	BEGIN TRY 
		BEGIN TRANSACTION
			SELECT @existingDefault = (SELECT DISTINCT gbr.idfsGISBaseReference from gisSettlement gl JOIN gisBaseReference gbr on gl.idfsSettlement = gbr.idfsGISBaseReference  WHERE idfsCountry= @LocationUserControlidfsCountry AND idfsRegion= @LocationUserControlidfsRegion AND idfsRayon = @LocationUserControlidfsRayon and strDefault = @strEnglishName AND idfsGISReferenceType = 19000004 and gbr.intRowStatus = 0)
			SELECT @existingName = (SELECT DISTINCT gbr.idfsGISBaseReference from gisSettlement gl JOIN gisBaseReference gbr on gl.idfsSettlement = gbr.idfsGISBaseReference JOIN gisStringNameTranslation gst on gbr.idfsGISBaseReference = gst.idfsGISBaseReference  WHERE idfsCountry=@LocationUserControlidfsCountry AND idfsRegion= @LocationUserControlidfsRegion AND idfsRayon = @LocationUserControlidfsRayon and strTextString = @strNationalName AND idfsGISReferenceType = 19000004 and gbr.intRowStatus = 0)
			
			IF (@existingDefault IS NOT NULL AND @idfsSettlementID IS NULL) OR (@existingName IS NOT NULL AND @idfsSettlementID IS NULL) OR 
				(@existingDefault IS NOT NULL AND @idfsSettlementID IS NOT NULL AND @existingDefault <> @idfsSettlementID) OR (@existingName IS NOT NULL AND @idfsSettlementID IS NOT NULL AND @existingName <> @idfsSettlementID)
			BEGIN
				IF @existingDefault IS NOT NULL 
					SELECT @idfsSettlementID = @existingDefault
				ELSE
					SELECT @idfsSettlementID = @existingName

				SELECT @returnMsg = 'DOES EXIST'
			END
			ELSE 
			BEGIN
			IF NOT EXISTS(SELECT idfsGISBaseReference FROM dbo.gisBaseReference WHERE idfsGISBaseReference = @idfsSettlementID)
			BEGIN
			  
			  INSERT INTO @SupressSelect
				EXEC dbo.USP_GBL_NEXTKEYID_GET 'gisBaseReference', @idfsSettlementID OUTPUT
				
  					INSERT 
					INTO dbo.gisBaseReference
						(
							idfsGISBaseReference
							,idfsGISReferenceType
							,strDefault
						)
					VALUES
						(
							@idfsSettlementID
							,19000004
							,@strEnglishName
						)

				IF NOT EXISTS(SELECT idfsSettlement FROM dbo.gisSettlement WHERE idfsSettlement = @idfsSettlementID)

						INSERT 
						INTO dbo.gisSettlement
							(
								idfsSettlement
								,strSettlementCode
								,idfsSettlementType 
								,idfsCountry
								,idfsRegion
								,idfsRayon 
								,dblLongitude
								,dblLatitude 
								,intElevation
							)
						VALUES 
							(
								@idfsSettlementID
								,@strSettlementCode
								,@idfsSettlementType
								,@LocationUserControlidfsCountry
								,@LocationUserControlidfsRegion
								,@LocationUserControlidfsRayon 
								,@LocationUserControlstrLongitude
								,@LocationUserControlstrLatitude 
								,@LocationUserControlstrElevation
							)

			END
		ELSE
			BEGIN
				BEGIN
					UPDATE	dbo.gisBaseReference
					SET		strDefault = @strEnglishName
					WHERE	idfsGISBaseReference = @idfsSettlementID
					AND		ISNULL(@strEnglishName,N'') <> ISNULL(strDefault,N'')
				END

				BEGIN
					UPDATE	dbo.gisSettlement
					SET		strSettlementCode = @strSettlementCode
							,idfsSettlementType = @idfsSettlementType
							,idfsCountry = @LocationUserControlidfsCountry
							,idfsRegion = @LocationUserControlidfsRegion
							,idfsRayon = @LocationUserControlidfsRayon
							,dblLongitude = @LocationUserControlstrLongitude
							,dblLatitude = @LocationUserControlstrLatitude
							,intElevation = @LocationUserControlstrElevation
					WHERE	idfsSettlement = @idfsSettlementID
				END
			END

			-- Insert/Updated gisStringNamme Translation for english name
			IF @strEnglishName IS NOT NULL AND NOT EXISTS(SELECT idfsGISBaseReference from dbo.gisStringNameTranslation WHERE idfsGISBaseReference = @idfsSettlementID AND idfsLanguage = dbo.FN_GBL_LANGUAGECODE_GET('en'))
				BEGIN
					INSERT 
					INTO dbo.gisStringNameTranslation
						(
							idfsGISBaseReference
							,idfsLanguage
							,strTextString
						)
					VALUES 
						(
							@idfsSettlementID
							,dbo.FN_GBL_LANGUAGECODE_GET('en')
							,@strEnglishName
						)
				END
			ELSE
				BEGIN
					UPDATE	dbo.gisStringNameTranslation
					SET		strTextString = @strEnglishName
					WHERE	idfsGISBaseReference = @idfsSettlementID 
					AND 	idfsLanguage = dbo.FN_GBL_LANGUAGECODE_GET('en')
					AND 	ISNULL(@strEnglishName,N'') <> ISNULL(strTextString,N'')
				END

			-- Insert/Updated gisStringNamme Translation for national name
			IF @strNationalName IS NOT NULL AND NOT EXISTS(SELECT idfsGISBaseReference from dbo.gisStringNameTranslation WHERE idfsGISBaseReference = @idfsSettlementID AND idfsLanguage = dbo.FN_GBL_LANGUAGECODE_GET(@LangID))
				BEGIN
					INSERT 
					INTO dbo.gisStringNameTranslation
						(
							idfsGISBaseReference
							,idfsLanguage
							,strTextString
						)
					VALUES 
						(
							@idfsSettlementID
							,dbo.FN_GBL_LANGUAGECODE_GET(@LangID)
							,@strNationalName
						)	
				END
			ELSE
				BEGIN
					UPDATE	dbo.gisStringNameTranslation
					SET		strTextString = @strNationalName
					WHERE	idfsGISBaseReference = @idfsSettlementID 
					AND 	idfsLanguage = dbo.FN_GBL_LANGUAGECODE_GET(@LangID)
					AND 	ISNULL(@strNationalName,N'') <> ISNULL(strTextString,N'')
				END


		IF @@TRANCOUNT > 0 		
			COMMIT  
			END
		SELECT @returnCode 'returnCode', @returnMsg 'returnMessage', @idfsSettlementID 'idfsSettlementID'
	END TRY  

	BEGIN CATCH  

		IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK

				SET @returnMsg = 
				'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER() ) 
				+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY() )
				+ ' ErrorState: ' + CONVERT(VARCHAR,ERROR_STATE())
				+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE() ,'')
				+ ' ErrorLine: ' +  CONVERT(VARCHAR,ISNULL(ERROR_LINE() ,''))
				+ ' ErrorMessage: '+ ERROR_MESSAGE()
				SELECT @returnCode 'returnCode', @returnMsg 'returnMessage', @idfsSettlementID 'idfsSettlementID'
			END

	END CATCH; 
END



