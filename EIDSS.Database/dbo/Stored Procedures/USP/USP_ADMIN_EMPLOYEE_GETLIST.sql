-- ================================================================================================
-- Name: USP_ADMIN_EMPLOYEE_GETLIST
--
-- Description:	Get a list of employees for the various EIDSS use cases.
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     02/09/2019 Initial release for new API.
-- Stephen Long     06/20/2019 Fixed where clause to be and's instead of or's.
-- Stephen Long     09/29/2020 Removed employee group join.
-- Mandar Kulkarni  03/22/2022 Removed join for tstUserTable for non-user employee category
-- Ann Xiong		11/07/2022 Changed FirstOrGivenName, SecondName, LastOrSurName, ContactPhone of @t 
--								from nvarchar(100) to nvarchar(200) to fix the error "String or binary data would be truncated."
-- Leo Tracchia     11/08/2022 added change for better performance (using FN_GBL_Institution_Min)
-- Ann Xiong		02/02/2023 Changed OrganizationAbbreviatedName, OrganizationFullName, PositionTypeName, EmployeeCategory of @t 
--								from nvarchar(100) to nvarchar(2000) to fix the error "String or binary data would be truncated."
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EMPLOYEE_GETLIST] (
	@LanguageID AS NVARCHAR(50),
	@EmployeeID AS BIGINT = NULL,
	@FirstOrGivenName AS NVARCHAR(100) = NULL,
	@SecondName AS NVARCHAR(100) = NULL,
	@LastOrSurName AS NVARCHAR(100) = NULL,
	@ContactPhone AS NVARCHAR(100) = NULL,
	@EIDSSOrganizationID AS NVARCHAR(100) = NULL,
	@OrganizationID AS BIGINT = NULL,
	@PositionTypeID AS BIGINT = NULL,
	@EmployeeCategoryID AS BIGINT = NULL,
	@AccountState AS BIGINT = NULL,
	@PersonalIdType AS BIGINT = NULL,
	@PersonalIDValue  AS NVARCHAR(100) = NULL,
	@pageNo INT = 1,
	@pageSize INT = 10 ,
	@sortColumn NVARCHAR(30) = 'EmployeeID',
	@sortOrder NVARCHAR(4) = 'asc'  
	)
AS
BEGIN
	DECLARE @OrganizationAbbreviatedName AS NVARCHAR(4000) = NULL
	DECLARE @OrganizationFullName AS NVARCHAR(4000) = NULL
	SET NOCOUNT ON;

	BEGIN TRY

	DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			EmployeeID BIGINT PRIMARY KEY, 
			FirstOrGivenName nvarchar(200)	INDEX IDX1 NONCLUSTERED(FirstOrGivenName),
			SecondName nvarchar(200),
			LastOrSurName nvarchar(200) INDEX IDX2 NONCLUSTERED(LastOrSurName), 
			EmployeeFullName nvarchar(100),
			ContactPhone nvarchar(200),
			OrganizationAbbreviatedName nvarchar(2000)INDEX IDX7 NONCLUSTERED(OrganizationAbbreviatedName),
			OrganizationFullName nvarchar(2000) INDEX IDX3 NONCLUSTERED(OrganizationFullName),
			EIDSSOrganizationID nvarchar(100) 	INDEX IDX4 NONCLUSTERED(EIDSSOrganizationID),
			OrganizationID bigint,
			PositionTypeName nvarchar(2000),
			PositionTypeID bigint,
			EmployeeCategoryID BIGINT INDEX IDX5 NONCLUSTERED(EmployeeCategoryID),
			EmployeeCategory nvarchar(2000),
			AccountDisabled nvarchar(100),
			AccountLocked nvarchar(100),
			PersonalIdType bigint,
			PersonalIDValue  nvarchar(100) INDEX IDX8 NONCLUSTERED(PersonalIDValue)
			)

		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)


		INSERT INTO @T

		SELECT p.idfPerson AS EmployeeID,
			p.strFirstName AS FirstOrGivenName,
			p.strSecondName AS SecondName,
			p.strFamilyName AS LastOrSurName,
			p.strContactPhone AS ContactPhone,
			'' AS EmployeeFullName,
			organization.AbbreviatedName AS OrganizationAbbreviatedName,
			organization.EnglishFullName AS OrganizationFullName,
			organization.strOrganizationID AS EIDSSOrganizationID,
			p.idfInstitution AS OrganizationID,
			positionType.[name] AS PositionTypeName,
			positionType.idfsReference AS PositionTypeID,
			employeeCategory.idfsReference AS EmployeeCategoryID,
			employeeCategory.[name] AS EmployeeCategory,
			CASE 
				WHEN u.blnDisabled = 1
				THEN 'Disabled'
				ELSE ''
			END AS 'AccountDisabled',
			CASE    
				WHEN dbo.FN_GBL_ISACCOUNTLOCKED(u.idfUserId) = 1 THEN 'AccountLocked'
                WHEN (u.LockoutEnabled = 1 and u.LockoutEnd IS NULL) OR (u.LockoutEnabled = 0 ) THEN ''
				ELSE ''
			END AS 'AccountLocked',
			p.PersonalIDTypeID AS PersonalIdType,
			p.PersonalIDValue AS PersonalIDValue
		FROM dbo.tlbPerson p
		INNER JOIN dbo.tlbEmployee AS e	ON e.idfEmployee = p.idfPerson AND e.intRowStatus = 0
		INNER JOIN dbo.FN_GBL_Institution_Min(@LanguageID) AS organization
			ON organization.idfOffice = p.idfInstitution
		INNER JOIN dbo.tstUserTable ut ON ut.idfPerson = p.idfPerson AND ut.intRowStatus = 0
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000526) AS employeeCategory ON e.idfsEmployeeCategory = employeeCategory.idfsReference
		INNER JOIN dbo.AspNetUsers u ON u.idfUserID = ut.idfUserID 
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000073) AS positionType
			ON p.idfsStaffPosition = positionType.idfsReference
		WHERE p.intRowStatus = 0
		AND e.idfsEmployeeCategory = 10526001
		AND ((u.LockoutEnabled = CASE @AccountState WHEN  10527001 THEN dbo.FN_GBL_ISACCOUNTLOCKED(u.idfUserID) ELSE 2 END) 
		OR (u.blnDisabled = CASE @AccountState WHEN  10527002 THEN 1 ELSE 2 END) OR @AccountState IS NULL)
	UNION
		SELECT p.idfPerson AS EmployeeID,
			p.strFirstName AS FirstOrGivenName,
			p.strSecondName AS SecondName,
			p.strFamilyName AS LastOrSurName,
			p.strContactPhone AS ContactPhone,
			'' AS EmployeeFullName,
			organization.AbbreviatedName AS OrganizationAbbreviatedName,
			organization.EnglishFullName AS OrganizationFullName,
			organization.strOrganizationID AS EIDSSOrganizationID,
			p.idfInstitution AS OrganizationID,
			positionType.[name] AS PositionTypeName,
			positionType.idfsReference AS PositionTypeID,
			employeeCategory.idfsReference AS EmployeeCategoryID,
			employeeCategory.[name] AS EmployeeCategory,
			''AS 'AccountDisabled',
			''AS 'AccountLocked',
			p.PersonalIDTypeID AS PersonalIdType,
			p.PersonalIDValue AS PersonalIDValue
		FROM dbo.tlbPerson p
		INNER JOIN dbo.tlbEmployee AS e	ON e.idfEmployee = p.idfPerson AND e.intRowStatus = 0
		INNER JOIN dbo.FN_GBL_Institution_Min(@LanguageID) AS organization
			ON organization.idfOffice = p.idfInstitution
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000526) AS employeeCategory ON e.idfsEmployeeCategory = employeeCategory.idfsReference 
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000073) AS positionType
			ON p.idfsStaffPosition = positionType.idfsReference
		WHERE p.intRowStatus = 0
		AND e.idfsEmployeeCategory = 10526002;

	WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'EmployeeID' AND @SortOrder = 'asc' THEN EmployeeID END ASC,
				CASE WHEN @sortColumn = 'EmployeeID' AND @SortOrder = 'desc' THEN EmployeeID END DESC,
				CASE WHEN @sortColumn = 'FirstOrGivenName' AND @SortOrder = 'asc' THEN FirstOrGivenName END ASC,
				CASE WHEN @sortColumn = 'FirstOrGivenName' AND @SortOrder = 'desc' THEN FirstOrGivenName END DESC,
				CASE WHEN @sortColumn = 'SecondName' AND @SortOrder = 'asc' THEN SecondName END ASC,
				CASE WHEN @sortColumn = 'SecondName' AND @SortOrder = 'desc' THEN SecondName END DESC,
				CASE WHEN @sortColumn = 'LastOrSurName' AND @SortOrder = 'asc' THEN LastOrSurName END ASC,
				CASE WHEN @sortColumn = 'LastOrSurName' AND @SortOrder = 'desc' THEN LastOrSurName END DESC,
				CASE WHEN @sortColumn = 'EmployeeFullName' AND @SortOrder = 'asc' THEN EmployeeFullName END ASC,
				CASE WHEN @sortColumn = 'EmployeeFullName' AND @SortOrder = 'desc' THEN EmployeeFullName END DESC,
				CASE WHEN @sortColumn = 'ContactPhone' AND @SortOrder = 'asc' THEN ContactPhone END ASC,
				CASE WHEN @sortColumn = 'ContactPhone' AND @SortOrder = 'desc' THEN ContactPhone END DESC,
				CASE WHEN @sortColumn = 'OrganizationAbbreviatedName' AND @SortOrder = 'asc' THEN OrganizationAbbreviatedName END ASC,
				CASE WHEN @sortColumn = 'OrganizationAbbreviatedName' AND @SortOrder = 'asc' THEN OrganizationAbbreviatedName END ASC,
				CASE WHEN @sortColumn = 'OrganizationFullName' AND @SortOrder = 'desc' THEN OrganizationFullName END DESC,
				CASE WHEN @sortColumn = 'OrganizationFullName' AND @SortOrder = 'asc' THEN OrganizationFullName END ASC,
				CASE WHEN @sortColumn = 'EIDSSOrganizationID' AND @SortOrder = 'asc' THEN EIDSSOrganizationID END ASC,
				CASE WHEN @sortColumn = 'EIDSSOrganizationID' AND @SortOrder = 'desc' THEN EIDSSOrganizationID END DESC,
				CASE WHEN @sortColumn = 'OrganizationID' AND @SortOrder = 'asc' THEN OrganizationID END ASC,
				CASE WHEN @sortColumn = 'OrganizationID' AND @SortOrder = 'desc' THEN OrganizationID END DESC,
				CASE WHEN @sortColumn = 'PositionTypeName' AND @SortOrder = 'asc' THEN PositionTypeName END ASC,
				CASE WHEN @sortColumn = 'PositionTypeName' AND @SortOrder = 'desc' THEN PositionTypeName END DESC,
				CASE WHEN @sortColumn = 'PositionTypeID' AND @SortOrder = 'asc' THEN PositionTypeID END ASC,
				CASE WHEN @sortColumn = 'PositionTypeID' AND @SortOrder = 'desc' THEN PositionTypeID END DESC,
				CASE WHEN @sortColumn = 'EmployeeCategory' AND @SortOrder = 'asc' THEN EmployeeCategory END ASC,
				CASE WHEN @sortColumn = 'EmployeeCategory' AND @SortOrder = 'desc' THEN EmployeeCategory END DESC,
				CASE WHEN @sortColumn = 'AccountDisabled' AND @SortOrder = 'asc' THEN AccountDisabled END DESC,
				CASE WHEN @sortColumn = 'AccountDisabled' AND @SortOrder = 'desc' THEN AccountDisabled END DESC,
				CASE WHEN @sortColumn = 'AccountLocked' AND @SortOrder = 'asc' THEN AccountLocked END DESC,
				CASE WHEN @sortColumn = 'AccountLocked' AND @SortOrder = 'desc' THEN AccountLocked END DESC,
				CASE WHEN @sortColumn = 'PersonalIdType' AND @SortOrder = 'asc' THEN PersonalIdType END ASC,
				CASE WHEN @sortColumn = 'PersonalIdType' AND @SortOrder = 'desc' THEN PersonalIdType END DESC,
				CASE WHEN @sortColumn = 'PersonalIDValue' AND @SortOrder = 'asc' THEN PersonalIDValue END ASC,
				CASE WHEN @sortColumn = 'PersonalIDValue' AND @SortOrder = 'desc' THEN PersonalIDValue END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount,
				EmployeeID,
				FirstOrGivenName,
				SecondName,
				LastOrSurName,
				dbo.FN_GBL_ConcatFullName(LastOrSurName,FirstOrGivenName,SecondName) AS EmployeeFullName,
				ContactPhone,
				OrganizationAbbreviatedName,
				OrganizationFullName,
				EIDSSOrganizationID,
				OrganizationID,
				PositionTypeName,
				PositionTypeID,
				EmployeeCategoryID,
				EmployeeCategory,
				AccountDisabled,
				AccountLocked,
				PersonalIdType,
				PersonalIdValue
			FROM @T
			WHERE (
					(
					(EmployeeID = @EmployeeID)
					OR (@EmployeeID IS NULL)
					)
				AND (
					(ContactPhone = @ContactPhone)
					OR (@ContactPhone IS NULL)
					)
				AND (
					(OrganizationID = @OrganizationID)
					OR (@OrganizationID IS NULL)
					)
				AND (
					(PersonalIDType = @PersonalIdType)
					OR (@PersonalIdType IS NULL)
					)
				AND (
					(PersonalIDValue = @PersonalIDValue)
					OR (@PersonalIDValue IS NULL)
					)
				AND (
					(PositionTypeID = @PositionTypeID)
					OR (@PositionTypeID IS NULL)
					)
				AND (
					(EmployeeCategoryID = @EmployeeCategoryID)
					OR (@EmployeeCategoryID IS NULL)
					)
				AND (
					(FirstOrGivenName LIKE '%' + @FirstOrGivenName + '%')
					OR (@FirstOrGivenName IS NULL)
					)
				AND (
					(SecondName LIKE '%' + @SecondName + '%')
					OR (@SecondName IS NULL)
					)
				AND (
					(LastOrSurName LIKE '%' + @LastOrSurName + '%')
					OR (@LastOrSurName IS NULL)
					)
				AND (
					(EIDSSOrganizationID LIKE '%' + @EIDSSOrganizationID + '%')
					OR (@EIDSSOrganizationID IS NULL)
					)
			)
		)	
			SELECT
			TotalRowCount,
			EmployeeID,
			FirstOrGivenName,
			SecondName,
			LastOrSurName,
			EmployeeFullName,
			ContactPhone,
			OrganizationAbbreviatedName,
			OrganizationFullName,
			EIDSSOrganizationID,
			OrganizationID,
			PositionTypeName,
			PositionTypeID,
			EmployeeCategoryID,
			EmployeeCategory,
			AccountDisabled,
			AccountLocked,
			PersonalIdType,
			PersonalIdValue
			,TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0)
			,CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 


		OPTION (RECOMPILE);

	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END;
