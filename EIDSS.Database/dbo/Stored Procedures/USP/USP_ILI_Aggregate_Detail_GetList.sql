-- Name: USP_ILI_Aggregate_Detail_GetList
--
-- Description:	Get Hospital/Sentinel Station Name list for the human module ILI Aggregate edit/set up use cases.
--                      
-- Revision History:
-- Name             Date		Change Detail
-- ---------------- ----------	-----------------------------------------------
-- Ann Xiong		02/28/2020	Initial release
-- Leo Tracchia		09/06/2021	added logic to handle null @idfAggregateHeader
-- ============================================================================
CREATE PROCEDURE [dbo].[USP_ILI_Aggregate_Detail_GetList] (
	 @LanguageID NVARCHAR(50)
	,@idfAggregateHeader BIGINT = NULL
	,@FormID NVARCHAR(200) = NULL
	,@SortColumn NVARCHAR(30) = 'HospitalName'
	,@SortOrder NVARCHAR(4) = 'DESC'
	,@pageNo INT = 1
	,@PageSize INT = 10
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @T TABLE
			( 
				idfAggreGateDetail BIGINT,
				idfAggregateHeader BIGINT,
				idfHospital BIGINT,
				strHospitalName NVARCHAR(MAX),
				intAge0_4 INT,
				intAge5_14 INT,
				intAge15_29 INT,
				intAge30_64 INT,
				intAge65 INT,
				inTotalILI INT,
				intTotalAdmissions INT,
				intILISamples INT,
				strRowAction NVARCHAR(1),
				intRowStatus INT
			)

		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)

		IF ((@idfAggregateHeader IS NULL OR @idfAggregateHeader < 0) AND @FormID IS NOT NULL)
			BEGIN
				SELECT @idfAggregateHeader = idfAggregateHeader 
				FROM dbo.tlbBasicSyndromicSurveillanceAggregateHeader 
				WHERE strFormID = @FormID
			END

		INSERT INTO @T
		SELECT 	AD.idfAggregateDetail,
				AD.idfAggregateHeader,
				AD.idfHospital,
				HR.strDefault AS HospitalName,
				AD.intAge0_4,    
				AD.intAge5_14,
				AD.intAge15_29,
				AD.intAge30_64,
				AD.intAge65,
				AD.inTotalILI,
				AD.intTotalAdmissions,
				AD.intILISamples,
				'R' AS RowAction,
				AD.intRowStatus
		FROM	dbo.tlbBasicSyndromicSurveillanceAggregateDetail AD
				LEFT JOIN dbo.tlbOffice Hospital
				ON Hospital.idfOffice = AD.idfHospital
				LEFT JOIN dbo.trtBaseReference HR
				ON Hospital.idfsOfficeName = HR.idfsBaseReference
		WHERE	AD.idfAggregateHeader = @idfAggregateHeader
				AND AD.intRowStatus = 0;

		WITH CTEResults as
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'HospitalName' AND @SortOrder = 'asc' THEN strHospitalName END ASC,
				CASE WHEN @sortColumn = 'HospitalName' AND @SortOrder = 'desc' THEN strHospitalName END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount,
				idfAggregateDetail,
				idfAggregateHeader,
				idfHospital,
				strHospitalName AS HospitalName,
				intAge0_4,    
				intAge5_14,
				intAge15_29,
				intAge30_64,
				intAge65,
				inTotalILI,
				intTotalAdmissions,
				intILISamples,
				strRowAction AS RowAction,
				intRowStatus AS RowStatus
		FROM @T
		)	
		SELECT
				TotalRowCount,
				idfAggregateDetail,
				idfAggregateHeader,
				idfHospital,
				HospitalName AS HospitalName,
				intAge0_4,    
				intAge5_14,
				intAge15_29,
				intAge30_64,
				intAge65,
				inTotalILI,
				intTotalAdmissions,
				intILISamples,
				RowAction,
				RowStatus
				,TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0)
				,CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 

	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
