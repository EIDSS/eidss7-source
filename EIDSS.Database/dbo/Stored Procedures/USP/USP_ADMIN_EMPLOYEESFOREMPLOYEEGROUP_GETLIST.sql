-- ================================================================================================
-- Name: USP_ADMIN_EMPLOYEESFOREMPLOYEEGROUP_GETLIST
--
-- Description: Returns a list of employees in an employee group
--
-- Author: Ricky Moss
--
-- Revision History:
-- Name					Date       Change
-- -------------------- ---------- --------------------------------------------------------------
-- Ricky Moss			12/05/2019 Initial Release
-- Doug Albanese		09/09/2020 Added Type and Description
-- Mani					12/29/2020 Added AspNetUser and tstUserTable tables to get username and 
--                                 idfuserId.
-- Mani					02/08/2021 Added intRowStatus
-- Ann Xiong			05/20/2021 Modified to return a list of employee (user) groups and 
--                                 persons.
-- Ann Xiong			06/16/2021 Added RowStatus and RowAction to the select
-- Ann Xiong			06/18/2021 Added filtered by @idfsSite when @idfEmployeeGroup IS NULL
-- Ann Xiong			07/06/2021 Changed two INNER JOIN to LEFT JOIN when @idfEmployeeGroup IS 
--                                 NULL
-- Ann Xiong			07/16/2021 Changed to exclude existing members from the Person/Employee 
--                                 Group search result
-- Ann Xiong			07/19/2021 Changed two INNER JOIN to LEFT JOIN and INNER JOIN 
--                                 tlbEmployeeGroupMember on e.idfEmployee instead of p.idfPerson, 
--                                 etc. when @user != 'Search'
-- Ann Xiong			07/21/2021 Fixed an issue when add a new user group
-- Ann Xiong			03/21/2021 Excluded a Person if this Person is already assigned to one 
--                                 User Group.
-- Stephen Long         03/17/2023 Fix on like query leading wildcards, and cleaned up formatting.
-- Ann Xiong			03/22/2023 Modified to allow search by FamilyName, FirstName or SecondName 
--                                 or full name (FamilyName FirstName SecondName) if type is Person
-- Ann Xiong			03/30/2023 Modified to return persons without any User Group
-- 
-- USP_ADMIN_EMPLOYEESFOREMPLOYEEGROUP_GETLIST -501, 'en', null
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EMPLOYEESFOREMPLOYEEGROUP_GETLIST]
(
    @idfEmployeeGroup BIGINT,
    @langId NVARCHAR(50),
    @Type AS BIGINT = NULL, -- Person, Employee Group
    @Name AS NVARCHAR(200) = NULL,
    @Organization AS NVARCHAR(200) = NULL,
    @Description AS NVARCHAR(200) = NULL,
    @pageNo INT = 1,
    @pageSize INT = 10,
    @SortColumn NVARCHAR(30) = 'Name',
    @SortOrder NVARCHAR(4) = 'ASC',
    @user NVARCHAR(50),
    @idfsSite BIGINT = NULL
)
AS
BEGIN
    BEGIN TRY
        DECLARE @firstRec INT = (@pageNo - 1) * @pagesize,
                @lastRec INT = (@pageNo * @pageSize + 1);
        DECLARE @T TABLE
        (
            idfEmployeeGroup BIGINT,
            idfEmployee BIGINT,
            TypeID BIGINT NOT NULL,
            TypeName NVARCHAR(2000),
            Name NVARCHAR(2000),
            Organization NVARCHAR(2000),
            Description NVARCHAR(2000),
            idfUserID BIGINT NULL,
            UserName NVARCHAR(2000),
            RowStatus INT,
            RowAction CHAR(1)
        );

		DECLARE @FamilyName VARCHAR(200), @FirstName VARCHAR(200), @SecondName VARCHAR(200);
        IF (@Type = 10023002)
        BEGIN
			DECLARE @tempValues TABLE  (num INT, Value VARCHAR(200))
			INSERT INTO @tempValues 
			SELECT num, CAST([Value] AS VARCHAR(200)) FROM report.FN_GBL_SYS_SplitList(@Name, 0, ' ')

			SELECT @FamilyName = Value
			FROM @tempValues
			WHERE num = 1

			SELECT @FirstName = Value
			FROM @tempValues
			WHERE num = 2

			SELECT @SecondName = Value
			FROM @tempValues
			WHERE num = 3
        END

        IF (@user = 'Search')
        BEGIN
            INSERT INTO @T
            SELECT eg.idfEmployeeGroup,
                   e.idfEmployee,
                   e.idfsEmployeeType AS TypeID,
                   actorType.name AS TypeName,
                   (CASE
                        WHEN e.idfsEmployeeType = 10023001 THEN
                            eg.strName
                        ELSE
                            dbo.FN_GBL_ConcatFullName(p.strFamilyName, p.strFirstName, p.strSecondName)
                    END
                   ) AS Name,
                   (CASE
                        WHEN e.idfsEmployeeType = 10023001 THEN
                            NULL
                        ELSE
                            organizationName.name
                    END
                   ) AS Organization,
                   eg.strDescription AS Description,
                   a.idfUserID,
                   a.UserName,
                   e.intRowStatus AS RowStatus,
                   'R' AS RowAction
            FROM dbo.tlbEmployee e
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@langId, 19000023) AS actorType
                    ON e.idfsEmployeeType = actorType.idfsReference
                LEFT JOIN dbo.tlbPerson AS p
                    ON p.idfPerson = e.idfEmployee
                       AND p.intRowStatus = 0
                LEFT JOIN dbo.tstUserTable AS u
                    ON u.idfPerson = p.idfPerson
                       AND u.intRowStatus = 0
                LEFT JOIN dbo.AspNetUsers a
                    on a.idfUserID = u.idfUserID
                LEFT JOIN dbo.FN_GBL_Institution(@langId) organizationName
                    ON p.idfInstitution = organizationName.idfOffice
                LEFT JOIN dbo.tlbEmployeeGroup AS eg
                    ON e.idfEmployee = eg.idfEmployeeGroup
                       AND eg.intRowStatus = 0
                LEFT JOIN dbo.tstSite AS employeeSite
                    ON employeeSite.idfsSite = e.idfsSite
                       AND employeeSite.intRowStatus = 0
                LEFT JOIN dbo.tstSite AS employeeGroupSite
                    ON employeeGroupSite.idfsSite = eg.idfsSite
                       AND employeeGroupSite.intRowStatus = 0
            WHERE e.intRowStatus = 0
                  AND e.idfsSite = @idfsSite
                  AND (
                          (
                              -- Person
                              e.idfsEmployeeCategory = 10526001
                              AND e.idfsEmployeeType = 10023002
                          )
                          OR (
                                 -- Employee Group
                                 e.idfsEmployeeCategory = 10526002
                                 AND e.idfsEmployeeType = 10023001
                                 AND eg.intRowStatus = 0
                             )
                      )
                  AND (e.idfEmployee NOT IN (
                                                SELECT idfEmployee
                                                FROM dbo.tlbEmployeeGroupMember egm
                                                WHERE idfEmployeeGroup = @idfEmployeeGroup
                                                      AND intRowStatus = 0
                                            )
                      )
                  --AND (e.idfEmployee NOT IN (
                  --                              SELECT idfEmployee
                  --                              FROM dbo.tlbEmployeeGroupMember egm
                  --                              WHERE e.idfsEmployeeType = 10023002
                  --                                    AND intRowStatus = 0
                  --                          )
                  --    )
                  AND (
                          (e.idfEmployee != @idfEmployeeGroup)
                          OR (@idfEmployeeGroup IS NULL)
                      )
                  AND (
                          (idfsEmployeeType = @Type)
                          OR (@Type IS NULL)
                      )
                  AND (
                          (
                              (@Type = 10023002)
                              AND ISNULL(p.strFamilyName, '') LIKE IIF(@FamilyName IS NOT NULL,
                                                                       @FamilyName + '%',
                                                                       ISNULL(p.strFamilyName, ''))
                          )
                          AND (
                              (@Type = 10023002)
                              AND ISNULL(p.strFirstName, '') LIKE IIF(@FirstName IS NOT NULL,
                                                                       @FirstName + '%',
                                                                       ISNULL(p.strFirstName, ''))
                          )
                          AND (
                              (@Type = 10023002)
                              AND ISNULL(p.strSecondName, '') LIKE IIF(@SecondName IS NOT NULL,
                                                                       @SecondName + '%',
                                                                       ISNULL(p.strSecondName, ''))
                          )
                          OR (
                              (@Type = 10023002)
                              AND ISNULL(p.strFamilyName, '') LIKE IIF(@Name IS NOT NULL,
                                                                       @Name + '%',
                                                                       ISNULL(p.strFamilyName, ''))
                          )
                          OR (
                              (@Type = 10023002)
                              AND ISNULL(p.strFirstName, '') LIKE IIF(@Name IS NOT NULL,
                                                                       @Name + '%',
                                                                       ISNULL(p.strFirstName, ''))
                          )
                          OR (
                              (@Type = 10023002)
                              AND ISNULL(p.strSecondName, '') LIKE IIF(@Name IS NOT NULL,
                                                                       @Name + '%',
                                                                       ISNULL(p.strSecondName, ''))
                          )
                          OR (
                                 (@Type = 10023001)
                                 AND ISNULL(eg.strName, '') LIKE IIF(@Name IS NOT NULL,
                                                                     @Name + '%',
                                                                     ISNULL(eg.strName, ''))
                             )
                          OR (
                                 (@Type IS NULL)
                                 AND (
                                         ISNULL(p.strFamilyName, '') LIKE IIF(@Name IS NOT NULL,
                                                                              @Name + '%',
                                                                              ISNULL(p.strFamilyName, ''))
                                         OR ISNULL(p.strFirstName, '') LIKE IIF(@Name IS NOT NULL,
                                                                              @Name + '%',
                                                                              ISNULL(p.strFirstName, ''))
                                         OR ISNULL(p.strSecondName, '') LIKE IIF(@Name IS NOT NULL,
                                                                              @Name + '%',
                                                                              ISNULL(p.strSecondName, ''))
                                         OR ISNULL(eg.strName, '') LIKE IIF(@Name IS NOT NULL,
                                                                            @Name + '%',
                                                                            ISNULL(eg.strName, ''))
                                     )
                             )
                      )
                  AND ISNULL(organizationName.name, '') LIKE IIF(@Organization IS NOT NULL,
                                                                 '%' + @Organization + '%',
                                                                 ISNULL(organizationName.name, ''))
                  AND ISNULL(eg.strDescription, '') LIKE IIF(@Description IS NOT NULL,
                                                             @Description + '%',
                                                             ISNULL(eg.strDescription, ''));
        END
        ELSE
        BEGIN
            INSERT INTO @T
            SELECT egm.idfEmployeeGroup,
                   e.idfEmployee,
                   e.idfsEmployeeType AS TypeID,
                   actorType.name AS TypeName,
                   (CASE
                        WHEN e.idfsEmployeeType = 10023001 THEN
                            eg.strName
                        ELSE
                            dbo.FN_GBL_ConcatFullName(p.strFamilyName, p.strFirstName, p.strSecondName)
                    END
                   ) AS Name,
                   (CASE
                        WHEN e.idfsEmployeeType = 10023001 THEN
                            NULL
                        ELSE
                            organization.name
                    END
                   ) AS Organization,
                   eg.strDescription AS Description,
                   a.idfUserID,
                   a.UserName,
                   e.intRowStatus AS RowStatus,
                   'R' AS RowAction
            FROM dbo.tlbEmployee e
                INNER JOIN dbo.FN_GBL_ReferenceRepair(@langId, 19000023) AS actorType
                    ON e.idfsEmployeeType = actorType.idfsReference
                LEFT JOIN dbo.tlbPerson AS p
                    ON p.idfPerson = e.idfEmployee
                       AND p.intRowStatus = 0
                LEFT JOIN dbo.tstUserTable AS u
                    ON u.idfPerson = p.idfPerson
                       AND u.intRowStatus = 0
                LEFT JOIN dbo.AspNetUsers a
                    on a.idfUserID = u.idfUserID
                LEFT JOIN dbo.FN_GBL_Institution(@langId) organization
                    ON p.idfInstitution = organization.idfOffice
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON e.idfEmployee = egm.idfEmployee
                       and egm.intRowStatus = 0
                LEFT JOIN dbo.tlbEmployeeGroup AS eg
                    ON e.idfEmployee = eg.idfEmployeeGroup
                       AND eg.intRowStatus = 0
            WHERE e.intRowStatus = 0
                  and egm.idfEmployeeGroup = @idfEmployeeGroup
                  AND e.idfsSite = @idfsSite
                  AND (
                          (
                              -- User
                              e.idfsEmployeeCategory = 10526001
                              AND e.idfsEmployeeType = 10023002
                          )
                          OR (
                                 -- User Group
                                 e.idfsEmployeeCategory = 10526002
                                 AND e.idfsEmployeeType = 10023001
                                 AND eg.intRowStatus = 0
                             )
                      )
                  AND (
                          (idfsEmployeeType = @Type)
                          OR (@Type IS NULL)
                      )
                  AND (
                          (p.strFamilyName = @Name)
                          OR (@Name IS NULL)
                      )
                  AND (
                          (p.strFirstName = @Name)
                          OR (@Name IS NULL)
                      )
                  AND (
                          (p.strSecondName = @Name)
                          OR (@Name IS NULL)
                      )
                  AND (
                          (eg.strName = @Name)
                          OR (@Name IS NULL)
                      )
                  AND (
                          (organization.name = @Organization)
                          OR @Organization IS NULL
                      )
                  AND (
                          (eg.strDescription = @Description)
                          OR (@Description IS NULL)
                      );
        END;
        WITH CTEResults
        as (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @sortColumn = 'idfEmployeeGroup'
                                                        AND @SortOrder = 'asc' THEN
                                                       idfEmployeeGroup
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'idfEmployeeGroup'
                                                        AND @SortOrder = 'desc' THEN
                                                       idfEmployeeGroup
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'idfEmployee'
                                                        AND @SortOrder = 'asc' THEN
                                                       idfEmployee
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'idfEmployee'
                                                        AND @SortOrder = 'desc' THEN
                                                       idfEmployee
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'TypeID'
                                                        AND @SortOrder = 'asc' THEN
                                                       TypeID
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'TypeID'
                                                        AND @SortOrder = 'desc' THEN
                                                       TypeID
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'TypeName'
                                                        AND @SortOrder = 'asc' THEN
                                                       TypeName
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'TypeName'
                                                        AND @SortOrder = 'desc' THEN
                                                       TypeName
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'Name'
                                                        AND @SortOrder = 'asc' THEN
                                                       Name
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'Name'
                                                        AND @SortOrder = 'desc' THEN
                                                       Name
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'Organization'
                                                        AND @SortOrder = 'asc' THEN
                                                       Organization
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'Organization'
                                                        AND @SortOrder = 'desc' THEN
                                                       Organization
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'Description'
                                                        AND @SortOrder = 'asc' THEN
                                                       Description
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'Description'
                                                        AND @SortOrder = 'desc' THEN
                                                       Description
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'idfUserID'
                                                        AND @SortOrder = 'asc' THEN
                                                       idfUserID
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'idfUserID'
                                                        AND @SortOrder = 'desc' THEN
                                                       idfUserID
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'UserName'
                                                        AND @SortOrder = 'asc' THEN
                                                       UserName
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'UserName'
                                                        AND @SortOrder = 'desc' THEN
                                                       UserName
                                               END DESC
                                     ) AS ROWNUM,
                   COUNT(*) OVER () AS TotalRowCount,
                   idfEmployeeGroup,
                   idfEmployee,
                   TypeID,
                   TypeName,
                   Name,
                   Organization,
                   Description,
                   idfUserID,
                   UserName,
                   RowStatus,
                   RowAction
            FROM @T
           )
        SELECT TotalRowCount,
               idfEmployeeGroup,
               idfEmployee,
               TypeID,
               TypeName,
               Name,
               Organization,
               Description,
               idfUserID,
               UserName,
               RowStatus,
               RowAction,
               TotalPages = (TotalRowCount / @pageSize) + IIF(TotalRowCount % @pageSize > 0, 1, 0),
               CurrentPage = @pageNo
        FROM CTEResults
        WHERE RowNum > @firstRec
              AND RowNum < @lastRec;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
