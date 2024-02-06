-- ================================================================================================
-- Name: USP_LAB_FREEZER_SUBDIVISION_GETList
--
-- Description:	Get freezer subdivision list (shelf, rack, box) for a specific freezer.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     01/19/2019 Initial release.
-- Stephen Long     03/01/2019 Added return code and return message.
-- Stephen Long     01/06/2021 Updated where criteria on site ID to look at freezer site ID only.
-- Leo Tracchia     09/15/2020 Removed return message and return code and change on joins
-- Srini Goli		10/03/2020 Used function fn_NoOfLocationsWithFreezerLocations to disply occupied Freezers
-- ================================================================================================
CREATE PROCEDURE [Report].[USP_LAB_FREEZER_SUBDIVISION_GETList] (
	@LanguageID NVARCHAR(50)
	,@FreezerID BIGINT = NULL
	,@SiteID BIGINT = NULL
	)
AS
BEGIN
	DECLARE @ReturnCode INT = 0;
	DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';

	BEGIN TRY
		SET NOCOUNT ON;

		SELECT fs.idfSubdivision AS FreezerSubdivisionID
			,fs.idfsSubdivisionType AS SubdivisionTypeID
			,subdivisionType.name AS SubdivisionTypeName
			,fs.idfFreezer AS FreezerID
			,f.strFreezerName AS FreezerName
			,f.LocBuildingName AS Building
			,f.strNote AS FreezerNote
			,f.idfsStorageType AS StorageTypeID
			,f.strBarcode AS FreezerBarCode
			,f.LocRoom AS Room
			,fs.idfParentSubdivision AS ParentFreezerSubdivisionID
			,fs.idfsSite AS OrganizationID
			,fs.strBarcode AS EIDSSFreezerSubdivisionID
			,fs.strNameChars AS FreezerSubdivisionName
			,fs.strNote AS SubdivisionNote
			,fs.intCapacity AS NumberOfLocations
			,fs.BoxSizeID AS BoxSizeTypeID
			,boxSizeType.name AS BoxSizeTypeName
			,fs.BoxPlaceAvailability
			,(
				SELECT COUNT(m.idfMaterial)
				FROM dbo.tlbMaterial m
				WHERE m.idfSubdivision = fs.idfSubdivision
					AND m.intRowStatus = 0
					AND (
						m.idfsSampleStatus <> 10015008
						AND m.idfsSampleStatus <> 10015009
						)
				) AS SampleCount
			,fs.intRowStatus AS RowStatus
			,'R' AS RowAction into #temp
		FROM dbo.tlbFreezerSubdivision fs
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000093) AS subdivisionType ON fs.idfsSubdivisionType = subdivisionType.idfsReference AND subdivisionType.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000512) AS boxSizeType ON fs.BoxSizeID = boxSizeType.idfsReference  AND boxSizeType.intRowStatus = 0
		LEFT JOIN dbo.tlbFreezer AS f ON f.idfFreezer = fs.idfFreezer AND f.intRowStatus = 0
		WHERE (
				(@FreezerID IS NOT NULL AND fs.idfFreezer = @FreezerID)
				OR (@FreezerID IS NULL)
				)
			AND (
				(@SiteID IS NOT NULL AND f.idfsSite = @SiteID)
				OR (@SiteID IS NULL)
				)
			AND fs.intRowStatus = 0
		ORDER BY fs.idfParentSubdivision;


WITH  cte1 AS (
  SELECT    FreezerSubdivisionID,
        SubdivisionTypeName,
		FreezerName,
		Building,
		Room,
		FreezerBarCode,
		FreezerNote,
		FreezerSubdivisionName,
		EIDSSFreezerSubdivisionID,
		NumberOfLocations,
		BoxSizeTypeName,
		CAST(FreezerSubdivisionID AS VARCHAR(255)) AS PATH,
        1 As LEVEL
  FROM #temp
  WHERE ParentFreezerSubdivisionID IS NULL
     
  UNION ALL
     
  SELECT    t.FreezerSubdivisionID,
            t.SubdivisionTypeName,
			t.FreezerName,
			t.Building,
			t.Room,
			t.FreezerBarCode,
			t.FreezerNote,
			t.FreezerSubdivisionName,
			t.EIDSSFreezerSubdivisionID,
			t.NumberOfLocations,
			t.BoxSizeTypeName,
			CAST(PATH + '.' + CAST(t.FreezerSubdivisionID AS VARCHAR(255)) AS VARCHAR(255)),
            --t.ParentFreezerSubdivisionID + '.'+t.FreezerSubdivisionID,
            th.LEVEL+1
  FROM #temp t
  INNER JOIN cte1 th
  ON th.FreezerSubdivisionID = t.ParentFreezerSubdivisionID
  WHERE t.ParentFreezerSubdivisionID IS NOT NULL
)
SELECT    FreezerSubdivisionID,
        SubdivisionTypeName,
		FreezerName,
		Building,
		Room,
		FreezerBarCode,
		FreezerNote,
		FreezerSubdivisionName,
		EIDSSFreezerSubdivisionID,
		IIF(LEVEL=3,Report.FN_REP_NoOfLocationsWithFreezerLocations(NumberOfLocations,FreezerSubdivisionID),CAST(NumberOfLocations AS VARCHAR)) AS NumberOfLocations,
		BoxSizeTypeName,
		PATH,
        LEVEL,
		IIF(CHARINDEX('.',PATH)=0,PATH,SUBSTRING(PATH,0,CHARINDEX('.',PATH))) as ReportGroup
FROM cte1 ORDER BY ReportGroup,Level;

	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;

	--SELECT @ReturnCode
	--	,@ReturnMessage;
END;
GO


