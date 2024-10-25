-- ================================================================================================
-- Name: USP_DAS_USERS_GETList
--
-- Description: Returns a list of users in the system based on langauge and site list.
--
-- Author: Ricky Moss
-- 
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		11/16/2018 Initial Release
-- Ricky Moss		12/11/2018 Added idfsInstitution and idfsPosition fields and removed 
--                             identifier fields
-- Ricky Moss		05/06/2018 Added pagination set.
-- Stephen Long     01/26/2020 Added site list parameter for site filtration, and corrected table
--                             query was selecting from (tlbPerson to tstUserTable).
-- Leo Tracchia		03/02/2022  Added pagination logic for radzen components
-- Stephen Long     05/05/2023 Replaced institution with institution min.
--
-- Testing Code:
-- exec USP_DAS_USERS_GETList 'en', 1, 10, 10
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_DAS_USERS_GETList] (
	@LanguageID NVARCHAR(50),
	@SiteList VARCHAR(MAX) = NULL,
	@pageNo INT = 1,
	@pageSize INT = 10 ,
	@sortColumn NVARCHAR(30) = 'FamilyName',
	@sortOrder NVARCHAR(4) = 'asc'  
	)
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
	--	@ReturnCode BIGINT = 0;

	DECLARE @firstRec INT
    DECLARE @lastRec INT

	DECLARE @tempUsers TABLE( 
		EmployeeID BIGINT PRIMARY KEY NOT NULL,
		FirstName nvarchar(2000),
		FamilyName nvarchar(2000),
		SecondName nvarchar(2000),
		InstitutionID bigint,
		OrganizationName nvarchar(2000), 
		OrganizationFullName nvarchar(2000), 
		PositionID bigint,
		Position nvarchar(2000),
		DepartmentID bigint,
		DepartmentName nvarchar(2000)
	)

     SET @firstRec = (@pageNo-1)* @pagesize
     SET @lastRec = (@pageNo*@pageSize+1)

	BEGIN TRY
		INSERT INTO @tempUsers
		SELECT p.idfPerson AS 'EmployeeID',
			p.strFirstName as 'FirstName',
			p.strFamilyName as 'FamilyName',
			p.strSecondName as 'SecondName',
			p.idfInstitution as 'InstitutionID',
			organization.AbbreviatedName AS 'OrganizationName',
			organization.EnglishFullName AS 'OrganizationFullName',
			position.idfsReference AS 'PositionID',
			position.[name] AS 'Position',
			p.idfDepartment as 'DepartmentID',
			dept.[name] as 'DepartmentName'
		FROM dbo.tstUserTable u
		INNER JOIN dbo.tlbPerson p
			ON p.idfPerson = u.idfPerson
				AND p.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000073) position
			ON p.idfsStaffPosition = position.idfsReference
		LEFT JOIN dbo.tlbDepartment td ON p.idfDepartment = td.idfDepartment AND td.intRowStatus =0
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000164) dept
			ON td.idfsDepartmentName = dept.idfsReference	
		LEFT JOIN dbo.FN_GBL_Institution_Min(@LanguageID) organization
			ON organization.idfOffice = p.idfInstitution
		WHERE u.intRowStatus = 0
			AND (
				(
					u.idfsSite IN (
						SELECT CAST([Value] AS BIGINT)
						FROM dbo.FN_GBL_SYS_SplitList(@SiteList, NULL, ',')
						)
					)
				OR (@SiteList IS NULL)
				);

		WITH CTEResults as
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'EmployeeID' AND @SortOrder = 'asc' THEN EmployeeID END ASC,
				CASE WHEN @sortColumn = 'EmployeeID' AND @SortOrder = 'desc' THEN EmployeeID END DESC,

				CASE WHEN @sortColumn = 'FirstName' AND @SortOrder = 'asc' THEN FirstName END ASC,
				CASE WHEN @sortColumn = 'FirstName' AND @SortOrder = 'desc' THEN FirstName END DESC,

				CASE WHEN @sortColumn = 'FamilyName' AND @SortOrder = 'asc' THEN FamilyName END ASC,
				CASE WHEN @sortColumn = 'FamilyName' AND @SortOrder = 'desc' THEN FamilyName END DESC,

				CASE WHEN @sortColumn = 'SecondName' AND @SortOrder = 'asc' THEN SecondName END ASC,
				CASE WHEN @sortColumn = 'SecondName' AND @SortOrder = 'desc' THEN SecondName END DESC,

				CASE WHEN @sortColumn = 'InstitutionID' AND @SortOrder = 'asc' THEN InstitutionID END ASC,
				CASE WHEN @sortColumn = 'InstitutionID' AND @SortOrder = 'desc' THEN InstitutionID END DESC,

				CASE WHEN @sortColumn = 'OrganizationName' AND @SortOrder = 'asc' THEN OrganizationName END ASC,
				CASE WHEN @sortColumn = 'OrganizationName' AND @SortOrder = 'desc' THEN OrganizationName END DESC,

				CASE WHEN @sortColumn = 'OrganizationFullName' AND @SortOrder = 'asc' THEN OrganizationFullName END ASC,
				CASE WHEN @sortColumn = 'OrganizationFullName' AND @SortOrder = 'desc' THEN OrganizationFullName END DESC,

				CASE WHEN @sortColumn = 'PositionID' AND @SortOrder = 'asc' THEN PositionID END ASC,
				CASE WHEN @sortColumn = 'PositionID' AND @SortOrder = 'asc' THEN PositionID END ASC,

				CASE WHEN @sortColumn = 'Position' AND @SortOrder = 'desc' THEN Position END DESC,
				CASE WHEN @sortColumn = 'Position' AND @SortOrder = 'asc' THEN Position END ASC,

				CASE WHEN @sortColumn = 'DepartmentID' AND @SortOrder = 'desc' THEN DepartmentID END DESC,
				CASE WHEN @sortColumn = 'DepartmentID' AND @SortOrder = 'asc' THEN DepartmentID END ASC,

				CASE WHEN @sortColumn = 'DepartmentName' AND @SortOrder = 'desc' THEN DepartmentName END DESC,
				CASE WHEN @sortColumn = 'DepartmentName' AND @SortOrder = 'asc' THEN DepartmentName END ASC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount,
				EmployeeID,
				FirstName,
				FamilyName,
				SecondName,
				InstitutionID,
				OrganizationName,
				OrganizationFullName,
				PositionID,
				Position,
				DepartmentID,
				DepartmentName
			FROM @tempUsers
		)	
			SELECT
				TotalRowCount,
				EmployeeID,
				FirstName,
				FamilyName,
				SecondName,
				InstitutionID,
				OrganizationName,
				OrganizationFullName,
				PositionID,
				Position,
				DepartmentID,
				DepartmentName
				,TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0)
				,CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
