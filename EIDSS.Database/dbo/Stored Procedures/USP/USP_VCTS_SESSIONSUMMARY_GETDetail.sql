


--*************************************************************
-- Name 				: USP_VCTS_VecSessionSummary_GETDetail
-- Description			: Get Vector Surveillance Summary Details
--          
-- Author               : MANDar Kulkarni
-- Revision History
--	Name			Date		Change Detail
--  Harold Pryor	05/08/2018  Updated to return idfsGroundType, dblDistance, and dblDirection columns 
--  Harold Pryor	6/12/2018   Updated to return idfsGeoLocationType
--	Doug Albanese	11/20/2020	Altered a field to reflect the true direction, which is dblAlignment
--	Doug Albanese	11/20/2020	Added Description for the location
--	Doug Albanese	12/11/2020	Added strForeignAddress
--	Doug Albanese	11/09/2021	Refactored for EF generation, and included new adminlevel location hierarchy
-- Testing code:
/*
--Example of a call of procedure:
execute	dbo.USP_VCTS_VecSessionSummary_GETDetail @idfVectorSurveillanceSession
*/
CREATE PROCEDURE [dbo].[USP_VCTS_SESSIONSUMMARY_GETDetail]
(
	@idfsVSSessionSummary           BIGINT--##PARAM idfsVSSessionSummary  - session summary ID
	,@idfVectorSurveillanceSession	BIGINT--##PARAM @idfVectorSurveillanceSession - session ID
	,@LangID						NVARCHAR(50)--##PARAM @LangID - language ID
)
AS
BEGIN	
	DECLARE @ReturnMessage VARCHAR(MAX) = 'Success'
	DECLARE @ReturnCode BIGINT = 0

	BEGIN TRY  		
			SELECT 
				Vss.[idfsVSSessionSummary]
				,Vss.[idfVectorSurveillanceSession]
				,Vss.[strVSSessionSummaryID] -- RecordID
				,Vss.[idfGeoLocation]
				,ISNULL(idfsGeoLocationType,10036003) AS idfsGeoLocationType,
				adminLevel0.idfsReference AS AdminLevel0Value,
				adminLevel0.name AS AdminLevel0Text,
				adminLevel1.idfsReference AS AdminLevel1Value,
				adminLevel1.name AS AdminLevel1Text,
				adminLevel2.idfsReference AS AdminLevel2Value,
				adminLevel2.name AS AdminLevel2Text,
				adminLevel3.idfsReference AS AdminLevel3Value,
				adminLevel3.name AS AdminLevel3Text,
				pc.idfPostalCode AS PostalCodeID,
				gl.strPostCode AS PostalCode,
				st.idfStreet AS StreetID,
				gl.strStreetName AS StreetName,
				gl.strHouse AS House,
				gl.strBuilding AS Building,
				gl.strApartment AS Apartment,
				gl.dblLongitude,
				gl.dblLatitude
				,Vss.[datCollectionDateTime]
				,Vst.idfsVectorType
				,VectorType.name AS [strVectorType]
				,Vss.[idfsVectorSubType]
				,VectorSubType.name AS [strVectorSubType]
				,Vss.[idfsSex]
				,Sex.name AS [strSex]	
				,Vss.[intQuantity]
				,Vss.[intRowStatus]
				,gl.idfsGroundType
				,gl.dblDistance 
				,gl.dblAlignment AS dblDirection
				,gl.strDescription
				,gl.strForeignAddress 
			FROM 
				dbo.tlbVectorSurveillanceSessionSummary Vss
			INNER JOIN	dbo.trtVectorSubType Vst											ON Vss.idfsVectorSubType = Vst.idfsVectorSubType AND Vst.intRowStatus = 0
			INNER JOIN	dbo.FN_GBL_REFERENCEREPAIR(@LangID,19000140) VectorType				ON VectorType.idfsReference = Vst.idfsVectorType
			INNER JOIN	dbo.FN_GBL_REFERENCEREPAIR(@LangID,19000141) VectorSubType			ON VectorSubType.idfsReference = Vss.idfsVectorSubType
			LEFT JOIN	dbo.FN_GBL_REFERENCEREPAIR(@LangID,19000007) Sex					ON Sex.idfsReference = Vss.idfsSex
			LEFT JOIN	dbo.tlbGeoLocation gl												ON Vss.idfGeoLocation = gl.idfGeoLocation
			LEFT JOIN	dbo.gisLocation g													ON g.idfsLocation = gl.idfsLocation
			LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001) adminLevel0	ON g.node.IsDescendantOf(AdminLevel0.node) = 1
			LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) adminLevel1	ON g.node.IsDescendantOf(AdminLevel1.node) = 1
			LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) adminLevel2	ON g.node.IsDescendantOf(AdminLevel2.node) = 1
			LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000004) adminLevel3	ON g.node.IsDescendantOf(AdminLevel3.node) = 1
			LEFT JOIN	dbo.tlbStreet st													ON st.idfsLocation = gl.idfsLocation AND st.strStreetName = gl.strStreetName
			LEFT JOIN	dbo.tlbPostalCode pc												ON pc.idfsLocation = gl.idfsLocation AND pc.strPostCode = gl.strPostCode
			WHERE 
				Vss.idfsVSSessionSummary = @idfsVSSessionSummary 
				AND Vss.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
				AND		Vss.intRowStatus = 0

	END TRY  
	BEGIN CATCH 

	END CATCH; 
END
