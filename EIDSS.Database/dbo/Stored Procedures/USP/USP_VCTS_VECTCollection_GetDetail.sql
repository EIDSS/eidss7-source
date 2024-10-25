



--*************************************************************
-- Name 				: USP_VCTS_VECTCollection_GetDetail
-- Description			: Get Vector Surveillance Vector Details
--          
-- Author               : Mandar Kulkarni
-- Revision History
--	Name			Date		Change Detail
--  Harold Pryor	5/20/2018   Updated to properly return idfsCollectionMethod value
--  Harold Pryor	6/12/2018   Updated to return idfsGeoLocationType
--  Mark Wilson		11/05/2020	updated issues with Office names
--	Doug Albanese	11-20-2020	Alter return to show dblAlignment (Direction)
--	Mike Kornegay	05/09/2022	Added strPostCode and idfHostVector
--
-- Testing code:
/*
--Example of a call of procedure:
declare	@idfVector	bigint

select @idfVector = MAX(idfVector) from dbo.tlbVector

execute	dbo.USP_VCTS_VECTCollection_GetDetail
	@idfVector = 85, 
	@idfVectorSurveillanceSession = 123, 
	@LangID = 'en-US' 

	execute	dbo.USP_VCTS_VECTCollection_GetDetail
	@idfVector = 106, 
	@idfVectorSurveillanceSession = 131, 
	@LangID = 'en-US' 

*/
--*************************************************************
CREATE PROCEDURE[dbo].[USP_VCTS_VECTCollection_GetDetail]
(		
	@idfVector BIGINT,--##PARAM @idfVector - AS vector ID
	@idfVectorSurveillanceSession BIGINT,--##PARAM @idfVectorSurveillanceSession - AS session ID
	@LangID AS NVARCHAR(50)--##PARAM @LangID - language ID
)
AS
BEGIN
	DECLARE @returnMsg VARCHAR(MAX) = 'Success'
	DECLARE @returnCode BIGINT = 0

	BEGIN TRY  	
		DECLARE @t TABLE( idfsReference BIGINT PRIMARY KEY, name NVARCHAR(255), idfsReferenceType BIGINT, intHACode INT, strDefault NVARCHAR(255), LongName NVARCHAR(255), intOrder INT, intRowStatus INT )
		INSERT INTO @t 
		SELECT * FROM dbo.FN_GBL_REFERENCEREPAIRSPLIT(@LangID,'19000141,19000140,19000043,19000038,19000137,19000045,19000136,19000135,19000007') 
		SELECT 	
			V.idfVector,
			V.idfVectorSurveillanceSession, 
			VS.strSessionID,
			V.idfsVectorType, 
			VectorType.name	AS [strVectorType],
			VectorSubType.name AS [strSpecies],
			V.idfsSex,	
			Sex.name AS [strSex],
			V.idfsVectorSubType, 
			V.strVectorID, 
			V.strFieldVectorID,
			Vs.intCollectionEffort,
			tgl.strForeignAddress,
			groundType.idfsReference AS idfsGroundType,
			groundType.Name AS strGroundType,
			tgl.dblDistance,
			tgl.strDescription,
			V.intElevation,
			V.idfsSurrounding,
			surrounding.name AS  strSurrounding,
			V.strGEOReferenceSources,
			V.idfsBasisOfRecord,
			basisOfRecord.name AS strBasisOfRecord,
			V.idfCollectedByOffice,
			CollectedByOffice.Name  AS CollectedByOfffice,
			V.idfCollectedByPerson, 
			dbo.FN_GBL_ConcatFullName(CollectedByPerson.strFamilyName, CollectedByPerson.strFirstName, CollectedByPerson.strSecondName) AS [strCollectedByPerson],
			V.datCollectionDateTime,
			V.idfsDayPeriod,
			DayPeriod.name AS DayPeriod,
			V.idfsCollectionMethod,
			CollectionMethod.name AS strCollectionMethod,
			V.idfsEctoparasitesCollected,
			EctoParasitesCollected.name AS strEctoParasitesCollected,
			V.intQuantity,
			V.idfIdentifiedByOffice,
			IdentifiedByOffice.Name  AS IdentifiedByOfffice,
			V.idfIdentifiedByPerson,
			v.idfHostVector,
			dbo.FN_GBL_ConcatFullName(IdentifiedByPerson.strFamilyName, IdentifiedByPerson.strFirstName, IdentifiedByPerson.strSecondName) AS [strIdentifiedByPerson],
			V.idfLocation,
			CASE WHEN tgl.idfsGeoLocationType IS NULL THEN tgl.idfsGeoLocationType ELSE 10036003 END AS idfsGeoLocationType,
			g.AdminLevel1ID   AdminLevel0Value,
			g.AdminLevel1Name  AS AdminLevel0Text,
			g.AdminLevel2ID   AS AdminLevel1Value,
			g.AdminLevel2Name  AS AdminLevel1Text,
			g.AdminLevel3ID   AS AdminLevel2Value,
			g.AdminLevel3Name AS AdminLevel2Text,
			g.AdminLevel4ID   AS AdminLevel3Value,
			g.AdminLevel4Name  AS AdminLevel3Text,
			g.AdminLevel5ID   AS AdminLevel4Value,
			g.AdminLevel5Name  AS AdminLevel4Text,
			g.AdminLevel6ID   AS AdminLevel5Value,
			g.AdminLevel6Name  AS AdminLevel5Text,
			g.AdminLevel7ID   AS AdminLevel6Value,
			g.AdminLevel7Name  AS AdminLevel6Text,
			tgl.dblLatitude,
			tgl.dblLongitude,
			tgl.strStreetName,
			tgl.strBuilding,
			tgl.strHouse,
			tgl.strApartment,
			V.idfsIdentificationMethod,
			V.datIdentifiedDateTime,
			V.idfObservation,
			tgl.idfsGroundType AS idfsGeolocationGroundType,
			tgl.dblAlignment AS dblDirection,
			tgl.strPostCode,
			v.strComment
		FROM dbo.tlbVector V
		JOIN dbo.tlbVectorSurveillanceSession VS ON V.idfVectorSurveillanceSession = VS.idfVectorSurveillanceSession
		LEFT JOIN @t VectorSubType ON VectorSubType.idfsReference = V.idfsVectorSubType
		LEFT JOIN @t VectorType ON VectorType.idfsReference = V.idfsVectorType
		LEFT JOIN @t Sex ON Sex.idfsReference = V.idfsSex
		INNER JOIN dbo.tlbGeoLocation tgl ON V.idfLocation = tgl.idfGeolocation
		INNER JOIN dbo.FN_GBL_locationHierarchy_Flattened(@LangID) g	ON g.idfsLocation = tgl.idfsLocation

		LEFT JOIN @t groundType ON groundType.idfsReference = tgl.idfsGroundType
		LEFT JOIN @t surrounding ON surrounding.idfsReference = V.idfsSurrounding
		LEFT JOIN @t basisOfRecord ON basisOfRecord.idfsReference = V.idfsBasisOfRecord

		LEFT JOIN dbo.tlbOffice O_CollectedBy ON O_CollectedBy.idfOffice = V.idfCollectedByOffice
		LEFT JOIN @t CollectedByOffice ON CollectedByOffice.idfsReference = O_CollectedBy.idfsOfficeAbbreviation 

		LEFT JOIN dbo.tlbPerson CollectedByPerson ON CollectedByPerson.idfPerson = V.idfCollectedByPerson 
		LEFT JOIN dbo.tlbOffice O_IdentifiedBy ON O_IdentifiedBy.idfOffice = V.idfIdentifiedByOffice
		LEFT JOIN @t IdentifiedByOffice	ON IdentifiedByOffice.idfsReference = O_IdentifiedBy.idfsOfficeAbbreviation	 
		LEFT JOIN dbo.tlbPerson IdentifiedByPerson ON IdentifiedByPerson.idfPerson = V.idfIdentifiedByPerson
		LEFT JOIN @t DayPeriod ON DayPeriod.idfsReference = V.idfsDayPeriod
		LEFT JOIN @t CollectionMethod ON CollectionMethod.idfsReference = V.idfsCollectionMethod
		LEFT JOIN @t EctoParasitesCollected ON EctoParasitesCollected.idfsReference = V.idfsEctoparasitesCollected
		WHERE v.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
		AND v.intRowStatus = 0
		AND v.idfVector = @idfVector

	END TRY  

	BEGIN CATCH 
	THROW;
	END CATCH; 
		
END
