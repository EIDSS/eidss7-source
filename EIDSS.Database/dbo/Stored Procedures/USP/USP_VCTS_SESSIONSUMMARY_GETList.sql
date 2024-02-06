
--*************************************************************
-- Name 				: USP_VCTS_SESSIONSUMMARY_GETList
-- Description			: Get Vector Surveillance Summary List
--          
-- Author               : MANDar Kulkarni
-- Revision History
--	Name			Date		Change Detail
--	Doug Albanese	12/14/2020	Added Positive Quanity to the return list
--	Lamont Mitchell				Fixed To Run With Poco by removing duplcated selects
--	Steven Verner	01/14/2022	Changed to point to gisLocationDenormalized to get location info.
--	Mike Kornegay	05/02/2022	Added TotalRowCount
--	Mike Kornegay	05/11/2022	Corrected TotalRowCount to be partition by 1.
--	Mike Kornegay	06/11/2022	Changed intPositiveQuantity output to be PositiveDiseasesList.
--  Mike Kornegay	07/20/2022	Changed inner join on sex to left join.
--
-- Testing code:
/*
--Example of a call of procedure:
execute	dbo.USP_VCTS_SESSIONSUMMARY_GETList @idfVectorSurveillanceSession=118, @langId ='en-US'
*/
CREATE PROCEDURE [dbo].[USP_VCTS_SESSIONSUMMARY_GETList]
(
	@idfVectorSurveillanceSession	BIGINT
	,@LangID						NVARCHAR(50)
)
AS
BEGIN	
	DECLARE @returnMsg					VARCHAR(MAX) = 'Success'
	DECLARE @returnCode					BIGINT = 0
	DECLARE @DiseaseList				NVARCHAR(MAX)

	DECLARE @GetList TABLE (
		idfsVSSessionSummary			BIGINT,
		idfVectorSurveillanceSession	BIGINT,
		strVSSessionSummaryID			NVARCHAR(200),
		idfGeoLocation					BIGINT,
		Country							NVARCHAR(200),
		Region							NVARCHAR(200),
		Rayon							NVARCHAR(200),
		Settlement						NVARCHAR(200),
		datCollectionDateTime			DATETIME,
		idfsVectorType					BIGINT,
		strVectorType					NVARCHAR(200),
		idfsVectorSubType				BIGINT,
		strVectorSubType				NVARCHAR(200),
		idfsSex							BIGINT,
		strSex							NVARCHAR(200),
		intQuantity						BIGINT,
		intRowStatus					INT,
		idfsDiagnosis					BIGINT,
		strDiagnosis					NVARCHAR(MAX),
		intPositiveQuantity				BIGINT
		
	)

	BEGIN TRY  	

		DECLARE @t TABLE( idfsReference BIGINT, name NVARCHAR(255), idfsReferenceType BIGINT, intHACode INT, strDefault NVARCHAR(255), LongName NVARCHAR(255), intOrder INT, intRowStatus INT )

		INSERT INTO @t 
		SELECT * FROM FN_GBL_REFERENCEREPAIR(@LangID,19000140) 
		INSERT INTO @t	
		SELECT * FROM dbo.FN_GBL_REFERENCEREPAIR(@LangID,19000141)
	
		INSERT INTO @t
		SELECT * FROM dbo.FN_GBL_REFERENCEREPAIR(@LangID,19000007)

		INSERT INTO @GetList
		SELECT 
				Vss.[idfsVSSessionSummary]
				,Vss.[idfVectorSurveillanceSession]
				,Vss.[strVSSessionSummaryID] -- RecordID
				,Vss.[idfGeoLocation]
				,ld.AdminLevel1Name Country
				,ld.AdminLevel2Name Region
				,ld.AdminLevel3Name Rayon
				,ld.AdminLevel4Name Settlement
				,Vss.[datCollectionDateTime]
				,Vst.idfsVectorType
				,vt.name As [strVectorType]
				,Vss.[idfsVectorSubType]
				,Vsut.name As [strVectorSubType]
				,Vss.[idfsSex]
				,Sex.name As [strSex]	
				,Vss.[intQuantity]
				,Vss.[intRowStatus]
				,Vssd.idfsDiagnosis
				,Disease.name As strDiagnosis
				,Vssd.intPositiveQuantity
		FROM dbo.tlbVectorSurveillanceSessionSummary Vss
		INNER JOIN dbo.trtVectorSubType Vst ON Vss.idfsVectorSubType = Vst.idfsVectorSubType And Vst.intRowStatus = 0
		INNER JOIN @t vt ON vt.idfsReference  =vst.idfsVectorType
		INNER JOIN @t vsut ON vsut.idfsReference = vss.idfsVectorSubType
		LEFT JOIN @t sex ON sex.idfsReference = vss.idfsSex
		LEFT JOIN dbo.tlbGeoLocation tgl ON tgl.idfGeoLocation = Vss.idfGeoLocation
		LEFT JOIN dbo.gisLocation gl ON gl.idfsLocation = tgl.idfsLocation
		LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened( @LangID) ld on ld.idfsLocation = gl.idfsLocation
		LEFT JOIN tlbVectorSurveillanceSessionSummaryDiagnosis Vssd 
			ON Vssd.idfsVSSessionSummary = Vss.idfsVSSessionSummary 
			AND Vssd.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID,19000019) Disease ON	Disease.idfsReference = Vssd.idfsDiagnosis
		WHERE 	Vss.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
		AND		Vss.intRowStatus = 0

		SELECT
			DISTINCT
			GL2.idfsVSSessionSummary,
			GL2.idfVectorSurveillanceSession,
			GL2.strVSSessionSummaryID,
			GL2.idfGeoLocation,
			GL2.Country,
			GL2.Region,
			GL2.Rayon,
			GL2.Settlement,
			GL2.datCollectionDateTime,
			GL2.idfsVectorType,
			GL2.strVectorType,
			GL2.idfsVectorSubType,
			GL2.strVectorSubType,
			GL2.idfsSex,
			GL2.strSex,
			GL2.intQuantity,
			GL2.intRowStatus,
			COUNT(*) OVER(PARTITION BY 1) AS TotalRowCount,
			(SELECT 
				DISTINCT GL1.strDiagnosis + '(' + CAST(intPositiveQuantity AS NVARCHAR(50)) + ')' + '; '
			FROM 
				@GetList GL1
			WHERE 
				GL1.idfsVSSessionSummary = GL2.idfsVSSessionSummary
			FOR XML PATH('')) PositiveDiseasesList
		FROM @GetList GL2
		GROUP BY 			
			GL2.idfsVSSessionSummary,
			GL2.idfVectorSurveillanceSession,
			GL2.strVSSessionSummaryID,
			GL2.idfGeoLocation,
			GL2.Country,
			GL2.Region,
			GL2.Rayon,
			GL2.Settlement,
			GL2.datCollectionDateTime,
			GL2.idfsVectorType,
			GL2.strVectorType,
			GL2.idfsVectorSubType,
			GL2.strVectorSubType,
			GL2.idfsSex,
			GL2.strSex,
			GL2.intQuantity,
			GL2.intRowStatus
		
	END TRY  

	BEGIN CATCH 
		THROW;
	END CATCH; 
END
