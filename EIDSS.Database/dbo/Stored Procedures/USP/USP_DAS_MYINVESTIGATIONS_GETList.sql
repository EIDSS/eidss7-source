﻿-- ================================================================================================
-- Name: USP_DAS_MYINVESTIGATIONS_GETList
--
-- Description: Returns a list of veterinary disease reports based on the language and filtered by
-- user.
--
-- Author: Ricky Moss
-- 
-- Revision History:
-- Name               Date       Change Detail
-- ------------------ ---------- -----------------------------------------------------------------
-- Ricky Moss         11/20/2018 Initial Release
-- Ricky Moss         11/30/2018 Removed reference type id variables and return code
-- Ricky Moss         12/03/2018 Rename fields to accommodate standards
-- Ricky Moss         12/13/2018 Added the status criteria
-- Ricky Moss         05/16/2018 Added Pagination
-- Stephen Long       12/26/2019 Replaced 'en' with @LangID on reference call.
-- Stephen Long       01/24/2020 Corrected active row status check.
-- Stephen Long       08/14/2020 Added case type to indicate which page (avian or livestock) to 
--                               redirect to from the dashboard.    
-- Leo Tracchia		  02/18/2022 Added pagination logic for radzen components
-- Leo Tracchia			02/28/2022 Added HACode field in return 
-- Testing Code:
-- exec USP_DAS_MYINVESTIGATIONS_GETList 'en', 55423100000000, 1, 10, 10
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_DAS_MYINVESTIGATIONS_GETList] (
	@LanguageID NVARCHAR(50),
	@PersonID BIGINT,
	--@PaginationSet INT = 1,
	--@PageSize INT = 10,
	--@MaxPagesPerFetch INT = 10
	@pageNo INT = 1,
	@pageSize INT = 10 ,
	@sortColumn NVARCHAR(30) = 'DateEntered',
	@sortOrder NVARCHAR(4) = 'asc'  
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
		@ReturnCode BIGINT = 0;

	DECLARE @firstRec INT
    DECLARE @lastRec INT

	DECLARE @tempInv TABLE( 
		VetCaseID bigint,
		FarmID bigint,
		ReportID  nvarchar(2000),
		DateEntered datetime,
		Species nvarchar(2000),
		SpeciesTypeID bigint,
		HACode int,
		DateInvestigation datetime,
		DiseaseName nvarchar(2000), 				
		[Classification] nvarchar(2000),
		[Address] nvarchar(2000)	
	)

     SET @firstRec = (@pageNo-1)* @pagesize
     SET @lastRec = (@pageNo*@pageSize+1)

	BEGIN TRY

		INSERT INTO @tempInv

		SELECT vc.idfVetCase as 'VetCaseID',
			f.idfFarm as 'FarmID',
			vc.strCaseID  as 'ReportID',
			vc.datEnteredDate as 'DateEntered',
			Species = STUFF((
					SELECT ', ' + speciesType.name
					FROM dbo.tlbSpecies s
					INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000086) AS speciesType
						ON speciesType.idfsReference = s.idfsSpeciesType
					INNER JOIN dbo.tlbHerd AS h
						ON h.idfHerd = s.idfHerd
					INNER JOIN dbo.tlbFarm AS f2
						ON h.idfFarm = f2.idfFarm
					WHERE f2.idfFarm = f.idfFarm
					GROUP BY speciesType.name
					FOR XML PATH(''),
						TYPE
					).value('.[1]', 'NVARCHAR(MAX)'), 1, 2, ''),
			vc.idfsCaseType AS 'SpeciesTypeID', 
			HACode = (SELECT TOP 1 speciesType.intHACode
							FROM dbo.tlbSpecies s
						INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000086) AS speciesType
							ON speciesType.idfsReference = s.idfsSpeciesType
						INNER JOIN dbo.tlbHerd AS h
							ON h.idfHerd = s.idfHerd
						INNER JOIN dbo.tlbFarm AS f2
							ON h.idfFarm = f2.idfFarm
						WHERE f2.idfFarm = f.idfFarm),
			vc.datInvestigationDate AS 'DateInvestigation',
			finalDiagnosis.Name AS 'DiseaseName',
			caseClassification.name AS 'Classification',
			(
				IIF(glFarm.strForeignAddress IS NULL, (
						(
							CASE 
								WHEN glFarm.strStreetName IS NULL
									THEN ''
								WHEN glFarm.strStreetName = ''
									THEN ''
								ELSE glFarm.strStreetName
								END
							) + IIF(glFarm.strBuilding = '', '', ', Bld ' + glFarm.strBuilding) + IIF(glFarm.strApartment = '', '', ', Apt ' + glFarm.strApartment) + IIF(glFarm.strHouse = '', '', ', ' + glFarm.strHouse) + IIF(glFarm.idfsSettlement IS NULL, '', ', ' + settlement.name) + (
							CASE 
								WHEN glFarm.strPostCode IS NULL
									THEN ''
								WHEN glFarm.strPostCode = ''
									THEN ''
								ELSE ', ' + glFarm.strPostCode
								END
							) + IIF(glFarm.idfsRayon IS NULL, '', ', ' + rayon.name) + IIF(glFarm.idfsRegion IS NULL, '', ', ' + region.name) + IIF(glFarm.idfsCountry IS NULL, '', ', ' + country.name)
						), glFarm.strForeignAddress)
				) AS 'Address'
		FROM dbo.tlbVetCase vc
		INNER JOIN dbo.tlbFarm AS f
			ON f.idfFarm = vc.idfFarm
		LEFT JOIN dbo.tlbGeoLocation AS glFarm
			ON glFarm.idfGeoLocation = f.idfFarmAddress
				AND glFarm.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000001) AS country
			ON country.idfsReference = glFarm.idfsCountry
		LEFT JOIN dbo.FN_GBL_GIS_REFERENCE(@LanguageID, 19000002) AS rayon
			ON rayon.idfsReference = glFarm.idfsRayon
		LEFT JOIN dbo.FN_GBL_GIS_REFERENCE(@LanguageID, 19000003) AS region
			ON region.idfsReference = glFarm.idfsRegion
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000004) AS settlement
			ON settlement.idfsReference = glFarm.idfsSettlement
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) AS finalDiagnosis
			ON finalDiagnosis.idfsReference = vc.idfsFinalDiagnosis
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000011) AS caseClassification
			ON caseClassification.idfsReference = vc.idfsCaseClassification
		WHERE vc.intRowStatus = 0 
			AND vc.idfPersonEnteredBy = @PersonID
			AND vc.idfsCaseProgressStatus = 10109001; --In Process
		--ORDER BY strCaseID OFFSET(@PageSize * @MaxPagesPerFetch) * (@PaginationSet - 1) ROWS

		--FETCH NEXT (@PageSize * @MaxPagesPerFetch) ROWS ONLY;

		--SELECT @ReturnCode,
		--	@ReturnMessage;

		WITH CTEResults as
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'VetCaseID' AND @SortOrder = 'asc' THEN VetCaseID END ASC,
				CASE WHEN @sortColumn = 'VetCaseID' AND @SortOrder = 'desc' THEN VetCaseID END DESC,

				CASE WHEN @sortColumn = 'FarmID' AND @SortOrder = 'asc' THEN FarmID END ASC,
				CASE WHEN @sortColumn = 'FarmID' AND @SortOrder = 'desc' THEN FarmID END DESC,

				CASE WHEN @sortColumn = 'ReportID' AND @SortOrder = 'asc' THEN ReportID END ASC,
				CASE WHEN @sortColumn = 'ReportID' AND @SortOrder = 'desc' THEN ReportID END DESC,

				CASE WHEN @sortColumn = 'DateEntered' AND @SortOrder = 'asc' THEN DateEntered END ASC,
				CASE WHEN @sortColumn = 'DateEntered' AND @SortOrder = 'desc' THEN DateEntered END DESC,

				CASE WHEN @sortColumn = 'Species' AND @SortOrder = 'asc' THEN Species END ASC,
				CASE WHEN @sortColumn = 'Species' AND @SortOrder = 'desc' THEN Species END DESC,

				CASE WHEN @sortColumn = 'SpeciesTypeID' AND @SortOrder = 'asc' THEN SpeciesTypeID END ASC,
				CASE WHEN @sortColumn = 'SpeciesTypeID' AND @SortOrder = 'desc' THEN SpeciesTypeID END DESC,

				CASE WHEN @sortColumn = 'DateInvestigation' AND @SortOrder = 'asc' THEN DateInvestigation END ASC,
				CASE WHEN @sortColumn = 'DateInvestigation' AND @SortOrder = 'desc' THEN DateInvestigation END DESC,

				CASE WHEN @sortColumn = 'DiseaseName' AND @SortOrder = 'asc' THEN DiseaseName END ASC,
				CASE WHEN @sortColumn = 'DiseaseName' AND @SortOrder = 'desc' THEN DiseaseName END DESC,

				CASE WHEN @sortColumn = 'Classification' AND @SortOrder = 'desc' THEN [Classification] END DESC,
				CASE WHEN @sortColumn = 'Classification' AND @SortOrder = 'asc' THEN [Classification] END ASC,				

				CASE WHEN @sortColumn = 'Address' AND @SortOrder = 'asc' THEN [Address] END ASC,
				CASE WHEN @sortColumn = 'Address' AND @SortOrder = 'desc' THEN [Address] END DESC				
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount,
				VetCaseID,
				FarmID,
				ReportID,
				DateEntered,
				Species,
				SpeciesTypeID,
				HACode,
				DateInvestigation,
				DiseaseName,								
				[Classification],
				[Address]			
			FROM @tempInv
		)	
			SELECT
			TotalRowCount,
			VetCaseID,
			FarmID,
			ReportID,
			DateEntered,
			Species,
			SpeciesTypeID,
			HACode,
			DateInvestigation,	
			DiseaseName,					
			[Classification],
			[Address]		
			,TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0)
			,CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 

		OPTION (RECOMPILE);

	END TRY

	BEGIN CATCH
		--SET @ReturnCode = ERROR_NUMBER();
		--SET @ReturnMessage = ERROR_MESSAGE();

		--SELECT @ReturnCode,
		--	@ReturnMessage;

		THROW;
	END CATCH;
END
