
--=============================================================================================================
-- Created by:				Leo Tracchia
-- Last modified date:		6/23/22
-- Description:				Adds a new or updates an existing settlement type
--
-- Revision History:
--
-- Name					Date			Change Detail
-- ----------------		----------		-----------------------------------------------
-- Leo Tracchia			6/23/2022		initial creation
-- Leo Tracchia			6/27/2022		added intRowStatus and idfsGISReferenceType in duplication check

--=============================================================================================================


CREATE PROCEDURE [dbo].[usp_SettlementType_Set]
(
	@IdfsGISBaseReference bigint = null
	,@LangID nvarchar(50)
	,@StrDefault nvarchar(100)
	,@StrNationalName nvarchar(100)
	,@IntOrder int
	,@RowStatus int
	,@UserID nvarchar(100)
)

AS

BEGIN

	DECLARE @SourceSystemKeyValue NVARCHAR(MAX)		
	DECLARE @returnCode			INT = 0 
	DECLARE	@returnMsg			NVARCHAR(max) = 'SUCCESS'
	DECLARE @existingDefault	BIGINT

	BEGIN TRY
	
		SELECT @existingDefault = (SELECT TOP 1(idfsGISBaseReference) FROM dbo.gisBaseReference WHERE strDefault = @StrDefault and intRowStatus = 0 and idfsGISReferenceType = 19000005)

		IF (@existingDefault IS NOT NULL AND @existingDefault <> @IdfsGISBaseReference) OR
				(@existingDefault IS NOT NULL AND @IdfsGISBaseReference IS NULL)				
			BEGIN
				SELECT @returnMsg = 'DOES EXIST'
				IF @existingDefault IS NOT NULL
					SELECT @IdfsGISBaseReference = @existingDefault				
			END
		ELSE
			BEGIN
				IF EXISTS (
					SELECT idfsGISBaseReference
					FROM dbo.gisBaseReference
					WHERE idfsGISBaseReference = @IdfsGISBaseReference
						AND intRowStatus = 0
					)
					BEGIN

						UPDATE gisBaseReference SET
							strDefault = @StrDefault
							,intOrder = @IntOrder
							,intRowStatus = @RowStatus
							,AuditUpdateUser = @UserID
							,AuditUpdateDTM = GETDATE()
						WHERE idfsGISBaseReference = @IdfsGISBaseReference

						UPDATE dbo.gisStringNameTranslation SET
							strTextString = @StrNationalName
							,intRowStatus = @RowStatus				
							,AuditUpdateUser = @UserID
							,AuditUpdateDTM = GETDATE()
						WHERE idfsGISBaseReference = @IdfsGISBaseReference

					END
				ELSE
					BEGIN

						EXEC dbo.USP_GBL_NEXTKEYID_GET 'gisBaseReference', @IdfsGISBaseReference OUTPUT;
						SET @SourceSystemKeyValue = '[{"idfsGisBaseReference":' + CAST(@IdfsGISBaseReference AS NVARCHAR(MAX) )+'}]'
			 
						INSERT INTO gisBaseReference 
						(
							idfsGISBaseReference
							,idfsGISReferenceType
							,strBaseReferenceCode
							,strDefault
							,intOrder
							,rowguid
							,intRowStatus
							,strMaintenanceFlag
							,strReservedAttribute
							,SourceSystemNameID
							,SourceSystemKeyValue
							,AuditCreateUser
							,AuditCreateDTM
							,AuditUpdateUser
							,AuditUpdateDTM
						) 
						VALUES 
						(
							@IdfsGISBaseReference
							,19000005
							,'stt' + @StrDefault
							,@StrDefault
							,@IntOrder
							,newid()
							,0
							,null
							,null
							,10519001 
							,@SourceSystemKeyValue
							,@UserID
							,getdate()
							,null
							,null
						)

						INSERT INTO dbo.gisStringNameTranslation
						(
							idfsGISBaseReference,
							idfsLanguage,
							strTextString,
							rowguid,
							intRowStatus,
							SourceSystemNameID,
							SourceSystemKeyValue,
							AuditCreateUser,
							AuditCreateDTM,
							AuditUpdateUser,
							AuditUpdateDTM
						)
						VALUES
						(   
							@IdfsGISBaseReference,
							dbo.FN_GBL_LanguageCode_GET(@LangID),
							@strNationalName,
							NEWID(),
							0,
							10519001,
							'[{"idfsGISBaseReference":' + CAST(@IdfsGISBaseReference AS NVARCHAR(24)) + '}, "idfsLanguage":' + CAST(dbo.FN_GBL_LanguageCode_GET(@LangID) AS NVARCHAR(24)) + ']',
							@UserID,
							GETDATE(),
							null,
							null
						)

					END	   
			END

		SELECT @returnMsg 'ReturnMessage', @returnCode 'ReturnCode', @IdfsGISBaseReference 'idfsGISBaseReference'

	END TRY
	BEGIN CATCH
		THROW;
	END CATCH


END
