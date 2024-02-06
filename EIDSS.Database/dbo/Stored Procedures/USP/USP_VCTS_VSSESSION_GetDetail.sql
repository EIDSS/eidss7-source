
--*************************************************************
-- Name 				: USP_VCTS_VSSESSION_GetDetail
-- Description			: Get Vector Surveillance Session data for session id
--          
-- Author               : Harold Pryor
-- Revision History
--		Name		Date       Change Detail
-- Harold Pryor	 4/23/2018	Initial Creation
-- Harold Pryor  6/7/2018   Updated to return idfsGeoLocationType
--
-- Doug Albanese	03-10-2020	Changes Defect 6212
-- Doug Albanese	10-16-2020	Added Outbreak's EIDSS ID
-- Doug Albanese	11-20-2020	Added dblAlignment (Direction)
-- Lamont Mitchell	11-11-2021	Added AdminLevels
-- Testing code:
-- EXEC USP_VCTS_VSSESSION_GetDetail(1, 'en')
--*************************************************************

CREATE PROCEDURE [dbo].[USP_VCTS_VSSESSION_GetDetail]
(
	@idfVectorSurveillanceSession AS BIGINT ,--##PARAM @idfVectorSurveillanceSession - AS session ID
	@LangID AS nvarchar(50)--##PARAM @LangID - language ID
)
AS
BEGIN
	DECLARE @ReturnMsg VARCHAR(MAX)
	SELECT	@ReturnMsg = ''
	DECLARE @ReturnCode BIGINT

	--BEGIN TRY  	
  SELECT		idfVectorSurveillanceSession,
				strSessionID,
				strVectors,  
				strVectorTypeIds,
				strDiagnoses,
				gl.strDescription,
				strFieldSessionID,
				strVSStatus,
				idfsVectorSurveillanceStatus,  
				intCollectionEffort,
				gl.idfsGeoLocationType,
				strCountry,
				gl.idfsCountry,
				strRegion,
				gl.idfsRegion,
				strRayon,
				gl.idfsSettlement,
				strSettlement,  
				gl.idfsRayon,
				gl.dblLatitude,
				gl.dblLongitude,
				datStartDate,
				datCloseDate,  
				idfOutbreak,
				idfLocation,
				gl.idfsSite,
				gl.strForeignAddress,
				gl.idfsGroundType,
				gl.dblDistance,
				LocationDescription,
				strOutbreakID,
				OutbreakStartDate,
				gl.dblAlignment As dblDirection,
				adminLevel0.idfsReference AS AdminLevel0Value,
				adminLevel1.idfsReference AS AdminLevel1Value,
				adminLevel1.name AS AdminLevel1Text,
				adminLevel2.idfsReference AS AdminLevel2Value,
				adminLevel2.name AS AdminLevel2Text,
				adminLevel3.idfsReference AS AdminLevel3Value,
				adminLevel3.name AS AdminLevel3Text
			
				
		FROM	dbo.FN_VCTS_VSSESSION_GetList(@LangID) Vss
			LEFT JOIN	dbo.tlbGeoLocation gl												ON Vss.idfLocation = gl.idfGeoLocation
			LEFT JOIN	dbo.gisLocation g													ON g.idfsLocation = gl.idfsLocation
			LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001) adminLevel0	ON g.node.IsDescendantOf(AdminLevel0.node) = 1
			LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) adminLevel1	ON g.node.IsDescendantOf(AdminLevel1.node) = 1
			LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) adminLevel2	ON g.node.IsDescendantOf(AdminLevel2.node) = 1
			LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000004) adminLevel3	ON g.node.IsDescendantOf(AdminLevel3.node) = 1
		WHERE	idfVectorSurveillanceSession = @idfVectorSurveillanceSession

	--END TRY  

	--BEGIN CATCH 

	--	BEGIN
	--		SET @ReturnCode = ERROR_NUMBER()
	--		SET @ReturnMsg = 
	--			'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER() ) 
	--			+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY() )
	--			+ ' ErrorState: ' + CONVERT(VARCHAR,ERROR_STATE())
	--			+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE() ,'')
	--			+ ' ErrorLine: ' +  CONVERT(VARCHAR,ISNULL(ERROR_LINE() ,''))
	--			+ ' ErrorMessage: '+ ERROR_MESSAGE()

	--		SELECT @returnCode, @ReturnMsg
	--	END

	--END CATCH
END
