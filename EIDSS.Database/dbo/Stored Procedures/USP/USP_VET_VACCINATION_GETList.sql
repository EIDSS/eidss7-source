-- ================================================================================================
-- Name: USP_VET_VACCINATION_GETList
--
-- Description:	Get vaccination list for the avian and livestock veterinary disease enter and edit 
-- use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/02/2018 Initial release.
-- Stephen Long     04/17/2019 Updates for API.
-- Ann Xiong		11/21/2019 Added Species to select list.
-- Ann Xiong		12/16/2019 Updated Species for both Livestock and Avian.
-- Stephen Long     12/29/2020 Changed functions for reference types to handle inactive data.
-- Stephen Long     11/24/2021 Added pagination and sorting.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VET_VACCINATION_GETList] (
	@LanguageID NVARCHAR(50)
	,@PageNumber INT = 1
	,@PageSize INT = 10
	,@SortColumn NVARCHAR(30) = 'TestNameTypeName'
	,@SortOrder NVARCHAR(4) = 'ASC'
	,@DiseaseReportID BIGINT = NULL
	,@SpeciesID BIGINT = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @FirstRec INT = (@PageNumber - 1) * @PageSize
			,@LastRec INT = (@PageNumber * @PageSize + 1)
			,@TotalRowCount INT = (
				SELECT COUNT(*)
				FROM dbo.tlbVaccination v
				LEFT JOIN dbo.tlbVetCase AS vc ON vc.idfVetCase = v.idfVetCase
					AND vc.intRowStatus = 0
				LEFT JOIN dbo.tlbSpecies AS s ON s.idfSpecies = v.idfSpecies
					AND s.intRowStatus = 0
				WHERE v.intRowStatus = 0
					AND (
						v.idfVetCase = @DiseaseReportID
						OR @DiseaseReportID IS NULL
						)
					AND (
						v.idfSpecies = @SpeciesID
						OR @SpeciesID IS NULL
						)
				);

		SELECT VaccinationID
			,DiseaseReportID
			,SpeciesID
			,SpeciesTypeName
			,Species
			,VaccinationTypeID
			,VaccinationTypeName
			,RouteTypeID
			,RouteTypeName
			,DiseaseID
			,DiseaseName
			,IDC10Code
			,OIECode
			,VaccinationDate
			,Manufacturer
			,LotNumber
			,NumberVaccinated
			,Comments
			,RowStatus
			,RowAction
			,[RowCount]
			,TotalRowCount
			,CurrentPage
			,TotalPages
		FROM (
			SELECT ROW_NUMBER() OVER (
					ORDER BY CASE 
							WHEN @SortColumn = 'DiseaseName'
								AND @SortOrder = 'ASC'
								THEN disease.name
							END ASC
						,CASE 
							WHEN @SortColumn = 'DiseaseName'
								AND @SortOrder = 'DESC'
								THEN disease.name
							END DESC
						,CASE 
							WHEN @SortColumn = 'VaccinationDate'
								AND @SortOrder = 'ASC'
								THEN v.datVaccinationDate
							END ASC
						,CASE 
							WHEN @SortColumn = 'VaccinationDate'
								AND @SortOrder = 'DESC'
								THEN v.datVaccinationDate
							END DESC
						,CASE 
							WHEN @SortColumn = 'Species'
								AND @SortOrder = 'ASC'
								THEN (
										CASE 
											WHEN vc.idfsCaseType = '10012003'
												THEN 'Herd ' + h.strHerdCode + ' - ' + speciesType.name
											ELSE 'Flock ' + h.strHerdCode + ' - ' + speciesType.name
											END
										)
							END ASC
						,CASE 
							WHEN @SortColumn = 'Species'
								AND @SortOrder = 'DESC'
								THEN (
										CASE 
											WHEN vc.idfsCaseType = '10012003'
												THEN 'Herd ' + h.strHerdCode + ' - ' + speciesType.name
											ELSE 'Flock ' + h.strHerdCode + ' - ' + speciesType.name
											END
										)
							END DESC
						,CASE 
							WHEN @SortColumn = 'NumberVaccinated'
								AND @SortOrder = 'ASC'
								THEN v.intNumberVaccinated
							END ASC
						,CASE 
							WHEN @SortColumn = 'NumberVaccinated'
								AND @SortOrder = 'DESC'
								THEN v.intNumberVaccinated
							END DESC
					) AS RowNum
				,v.idfVaccination AS VaccinationID
				,v.idfVetCase AS DiseaseReportID
				,v.idfSpecies AS SpeciesID
				,speciesType.name AS SpeciesTypeName
				,(
					CASE 
						WHEN vc.idfsCaseType = '10012003'
							THEN 'Herd ' + h.strHerdCode + ' - ' + speciesType.name
						ELSE 'Flock ' + h.strHerdCode + ' - ' + speciesType.name
						END
					) AS Species
				,v.idfsVaccinationType AS VaccinationTypeID
				,vaccinationType.name AS VaccinationTypeName
				,v.idfsVaccinationRoute AS RouteTypeID
				,routeType.name AS RouteTypeName
				,v.idfsDiagnosis AS DiseaseID
				,disease.name AS DiseaseName
				,d.strIDC10 AS IDC10Code
				,d.strOIECode AS OIECode
				,v.datVaccinationDate AS VaccinationDate
				,v.strManufacturer AS Manufacturer
				,v.strLotNumber AS LotNumber
				,v.intNumberVaccinated AS NumberVaccinated
				,v.strNote AS Comments
				,v.intRowStatus AS RowStatus
				,0 AS RowAction
				,COUNT(*) OVER () AS [RowCount]
				,@TotalRowCount AS TotalRowCount
				,CurrentPage = @PageNumber
				,TotalPages = (@TotalRowCount / @PageSize) + IIF(COUNT(*) % @PageSize > 0, 1, 0)
			FROM dbo.tlbVaccination v
			LEFT JOIN dbo.tlbVetCase vc ON vc.idfVetCase = v.idfVetCase
				AND vc.intRowStatus = 0
			LEFT JOIN dbo.tlbSpecies s ON s.idfSpecies = v.idfSpecies
				AND s.intRowStatus = 0
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000086) speciesType ON speciesType.idfsReference = s.idfsSpeciesType
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000099) vaccinationType ON vaccinationType.idfsReference = v.idfsVaccinationType
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000098) routeType ON routeType.idfsReference = v.idfsVaccinationRoute
			LEFT JOIN dbo.trtDiagnosis d ON d.idfsDiagnosis = v.idfsDiagnosis
				AND d.intRowStatus = 0
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease ON disease.idfsReference = d.idfsDiagnosis
			LEFT JOIN dbo.tlbHerd h ON h.idfHerd = s.idfHerd
				AND h.intRowStatus = 0
			WHERE v.intRowStatus = 0
				AND (
					v.idfVetCase = @DiseaseReportID
					OR @DiseaseReportID IS NULL
					)
				AND (
					v.idfSpecies = @SpeciesID
					OR @SpeciesID IS NULL
					)
			GROUP BY v.idfVaccination
				,v.idfVetCase
				,v.idfSpecies
				,speciesType.name
				,v.idfsVaccinationType
				,vaccinationType.name
				,v.idfsVaccinationRoute
				,routeType.name
				,v.idfsDiagnosis
				,disease.name
				,d.strIDC10
				,d.strOIECode
				,v.datVaccinationDate
				,v.strManufacturer
				,v.strLotNumber
				,v.intNumberVaccinated
				,v.strNote
				,v.intRowStatus
				,h.strHerdCode
				,vc.idfsCaseType
			) AS x
		WHERE RowNum > @FirstRec
			AND RowNum < @LastRec
		ORDER BY RowNum;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
