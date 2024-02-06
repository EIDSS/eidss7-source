--*************************************************************
-- Name 				: USP_VCTS_VECT_GetDetail
-- Description			: Get Vector Surveillance Vector Details
--          
-- Author               : Mandar Kulkarni
-- Revision History
--		Name       Date       Change Detail
--LAMONT Mitchell   12/14/21  Removed --SELECT @returnCode, @returnMsg LINE 72.  sP RETURNED 2 RECORD sETS
--Lamont Mitchell	12/14/21 added location hierarchy
--
-- Testing code:
/*
--Example of a call of procedure:
declare	@idfVector	bigint

select @idfVector = MAX(idfVector) from dbo.tlbVector

execute	dbo.USP_VCTS_VECT_GetDetail @idfVectorSurveillanceSession
*/
--*************************************************************
CREATE PROCEDURE[dbo].[USP_VCTS_VECT_GetDetail]
(		
	@idfVectorSurveillanceSession BIGINT,--##PARAM @idfVectorSurveillanceSession - AS session ID
	@LangID AS NVARCHAR(50),--##PARAM @LangID - language ID
	@bitCollectionByPool BIT = NULL,
	@SortColumn NVARCHAR(30) = NULL,
	@SortOrder NVARCHAR(4) = NULL,
	@PageNumber INT = 1,
	@PageSize INT = 10
)
AS
BEGIN
	DECLARE @returnMsg VARCHAR(MAX) = 'Success'
	DECLARE @returnCode BIGINT = 0

	BEGIN TRY  	
	DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
						idfVector BIGINT,
						idfVectorSurveillanceSession BIGINT, 
						strSessionID VARCHAR(2000),
						idfsVectorType BIGINT, 
						strVectorType VARCHAR(2000),
						strSpecies VARCHAR(2000),
						idfsSex BIGINT,	
						strSex VARCHAR(2000), 
						idfsVectorSubType BIGINT, 
						strVectorID VARCHAR(2000), 
						strFieldVectorID VARCHAR(2000),
						intCollectionEffort INT,
						datCollectionDateTime DATETIME,
						strRegion VARCHAR(2000),
						strRayon VARCHAR(2000),
						strComment VARCHAR(2000),
						AdminLevel0Value BIGINT,
						AdminLevel0Text NVARCHAR(2000),
						AdminLevel1Value BIGINT,
						AdminLevel1Text NVARCHAR(2000),
						AdminLevel2Value BIGINT,
						AdminLevel2Text NVARCHAR(2000),
						AdminLevel3Value BIGINT,
						AdminLevel3Text NVARCHAR(2000),
						AdminLevel4Value BIGINT,
						AdminLevel4Text NVARCHAR(2000),
						AdminLevel5Value BIGINT,
						AdminLevel5Text NVARCHAR(2000),
						AdminLevel6Value BIGINT,
						AdminLevel6Text NVARCHAR(2000),
						bitCollectionByPool BIT
					)
	
		SET @firstRec = (@PageNumber-1)* @pagesize
		SET @lastRec = (@PageNumber*@PageSize+1)
		INSERT INTO @T
			SELECT 	V.idfVector,
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
					V.datCollectionDateTime,
					gil.AdminLevel2Name AS strRegion,
					gil.AdminLevel3Name AS strRayon,
					strComment,
					gil.AdminLevel1ID   AdminLevel0Value,
					gil.AdminLevel1Name  AS AdminLevel0Text,
					gil.AdminLevel2ID   AS AdminLevel1Value,
					gil.AdminLevel2Name  AS AdminLevel1Text,
					gil.AdminLevel3ID   AS AdminLevel2Value,
					gil.AdminLevel3Name AS AdminLevel2Text,
					gil.AdminLevel4ID   AS AdminLevel3Value,
					gil.AdminLevel4Name  AS AdminLevel3Text,
					gil.AdminLevel5ID   AS AdminLevel4Value,
					gil.AdminLevel5Name  AS AdminLevel4Text,
					gil.AdminLevel6ID   AS AdminLevel5Value,
					gil.AdminLevel6Name  AS AdminLevel5Text,
					gil.AdminLevel7ID   AS AdminLevel6Value,
					gil.AdminLevel7Name  AS AdminLevel6Text,
					trtVectorType.bitCollectionByPool
		FROM		dbo.tlbVector V
		INNER JOIN	dbo.tlbVectorSurveillanceSession VS ON V.idfVectorSurveillanceSession = VS.idfVectorSurveillanceSession
		JOIN		dbo.FN_GBL_REFERENCEREPAIR(@LangId,19000141) VectorSubType
		ON			VectorSubType.idfsReference = V.idfsVectorSubType
		JOIN		dbo.FN_GBL_REFERENCEREPAIR(@LangId,19000140) VectorType
		ON			VectorType.idfsReference = V.idfsVectorType
		JOIN		dbo.trtVectorType trtVectorType 
		ON			trtVectorType.idfsVectorType = VectorType.idfsReference
		LEFT JOIN	dbo.FN_GBL_REFERENCEREPAIR(@LangId,19000043) Sex
		ON			Sex.idfsReference = V.idfsSex
		LEFT JOIN	dbo.tlbGeoLocation gl
		ON			gl.idfGeoLocation = V.idfLocation 
		LEFT JOIN   fn_gbl_locationHierarchy_Flattened(@LangID)  gil ON gil.idfsLocation = gl.idfsLocation
		WHERE		v.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
		AND			v.intRowStatus = 0  
		AND			(@bitCollectionByPool IS NULL OR trtVectorType.bitCollectionByPool  = @bitCollectionByPool);
		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER (Order by 
				CASE WHEN @sortColumn = 'idfVector' AND @SortOrder = 'asc' THEN idfVector END ASC,
				CASE WHEN @sortColumn = 'idfVector' AND @SortOrder = 'desc' THEN idfVector END DESC
				 )
			AS ROWNUM,
			COUNT(*) OVER () AS 
			TotalRowCount,
			idfVector ,
			idfVectorSurveillanceSession,
			strSessionID ,
			idfsVectorType , 
			strVectorType ,
			strSpecies ,
			idfsSex ,	
			strSex , 
			idfsVectorSubType,
			strVectorID , 
			strFieldVectorID ,
			intCollectionEffort ,
			datCollectionDateTime ,
			strRegion ,
			strRayon ,
			strComment ,
			AdminLevel0Value ,
			AdminLevel0Text ,
			AdminLevel1Value ,
			AdminLevel1Text ,
			AdminLevel2Value ,
			AdminLevel2Text ,
			AdminLevel3Value ,
			AdminLevel3Text ,
			AdminLevel4Value ,
			AdminLevel4Text ,
			AdminLevel5Value ,
			AdminLevel5Text ,
			AdminLevel6Value ,
			AdminLevel6Text ,
			bitCollectionByPool 
			FROM @T
		)
		SELECT
				TotalRowCount,
				idfVector,
				idfVectorSurveillanceSession,
				strSessionID,
				idfsVectorType , 
				strVectorType ,
				strSpecies ,
				idfsSex ,	
				strSex , 
				idfsVectorSubType,
				strVectorID , 
				strFieldVectorID ,
				intCollectionEffort ,
				datCollectionDateTime ,
				strRegion ,
				strRayon ,
				strComment ,
				AdminLevel0Value ,
				AdminLevel0Text ,
				AdminLevel1Value ,
				AdminLevel1Text ,
				AdminLevel2Value ,
				AdminLevel2Text ,
				AdminLevel3Value ,
				AdminLevel3Text ,
				AdminLevel4Value ,
				AdminLevel4Text ,
				AdminLevel5Value ,
				AdminLevel5Text ,
				AdminLevel6Value ,
				AdminLevel6Text ,
				bitCollectionByPool,
				TotalPages = (TotalRowCount/@PageSize)+IIF(TotalRowCount%@PageSize>0,1,0),
				CurrentPage = @PageNumber 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 	
	END TRY  

	BEGIN CATCH
		THROW;
	END CATCH;
		
END

