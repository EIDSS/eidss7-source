-- ================================================================================================
-- Name: USP_ADMIN_SITE_ACTOR_GETList
--
-- Description:	Get actor list for a specific site.  Used in permissions for site filtration of the 
-- administration module - SAUC29.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     12/20/2022 Initial release.
-- Stephen Long     01/10/2023 Fix to null out employee group ID for an internal employee actor.
-- Stephen Long     01/17/2023 Added site ID to the model and removed employee group indicator 
--                             parameter.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_SITE_ACTOR_GETList]
(
    @LanguageID NVARCHAR(50),
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(30) = 'ActorName',
    @SortOrder NVARCHAR(4) = 'ASC',
    @SiteID BIGINT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @FirstRecord INT,
                @LastRecord INT,
                @TotalRowCount INT = 0;
        DECLARE @Results TABLE
        (
            ActorID BIGINT NOT NULL,
            ActorTypeID BIGINT NOT NULL,
            ActorTypeName VARCHAR(MAX) NOT NULL,
            ActorName NVARCHAR(MAX) NULL,
            SiteID BIGINT NOT NULL,
            ExternalActorIndicator BIT NOT NULL,
            DefaultEmployeeGroupIndicator BIT NOT NULL
        );

        DECLARE @FinalResults TABLE
        (
            ActorID BIGINT NOT NULL,
            ActorTypeID BIGINT NOT NULL,
            ActorTypeName VARCHAR(MAX) NOT NULL,
            ActorName NVARCHAR(MAX) NULL,
            SiteID BIGINT NOT NULL,
            ExternalActorIndicator BIT NOT NULL,
            DefaultEmployeeGroupIndicator BIT NOT NULL
        );

        -- External employee group actors
        INSERT INTO @Results
        SELECT oa.idfActor,
               10023001,
               actorType.name,
               employeeGroupName.name,
               eg.idfsSite,
               1,
               0
        FROM dbo.tstObjectAccess oa
            INNER JOIN dbo.tlbEmployeeGroup eg
                ON eg.idfEmployeeGroup = oa.idfActor
                   AND eg.intRowStatus = 0
            INNER JOIN dbo.tlbEmployee e
                ON eg.idfEmployeeGroup = e.idfEmployee
                   AND e.intRowStatus = 0
            INNER JOIN FN_GBL_ReferenceRepair(@LanguageID, 19000022) employeeGroupName
                ON employeeGroupName.idfsReference = eg.idfsEmployeeGroupName
            INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000023) actorType
                ON e.idfsEmployeeType = actorType.idfsReference
        WHERE oa.intRowStatus = 0
              AND oa.idfsObjectType = 10060011 -- Site
              AND eg.idfsSite <> @SiteID
              AND oa.idfsOnSite = @SiteID;

        -- External employee actors
        INSERT INTO @Results
        SELECT oa.idfActor,
               10023002,
               actorType.name,
               dbo.FN_GBL_ConcatFullName(p.strFamilyName, p.strFirstName, p.strSecondName),
               e.idfsSite,
               1 AS ExternalActorIndicator,
               0
        FROM dbo.tstObjectAccess oa
            INNER JOIN dbo.tlbEmployee e
                ON e.idfEmployee = oa.idfActor
                   AND e.intRowStatus = 0
            INNER JOIN dbo.tlbPerson p
                ON p.idfPerson = e.idfEmployee
                   AND p.intRowStatus = 0
            INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000023) actorType
                ON e.idfsEmployeeType = actorType.idfsReference
        WHERE oa.intRowStatus = 0
              AND oa.idfsObjectType = 10060011 -- Site
              AND e.idfsSite <> @SiteID
              AND e.idfsEmployeeType = 10023002 -- Employee
              AND oa.idfsOnSite = @SiteID;

        -- Internal employee group actors
        INSERT INTO @Results
        SELECT eg.idfEmployeeGroup,
               10023001,
               actorType.name,
               employeeGroupName.name,
               eg.idfsSite,
               0,
               CASE
                   WHEN br.blnSystem = 1 THEN
                       1
                   ELSE
                       0
               END
        FROM dbo.tstObjectAccess oa
            INNER JOIN dbo.tlbEmployeeGroup eg
                ON eg.idfEmployeeGroup = oa.idfActor
                   AND eg.intRowStatus = 0
            INNER JOIN dbo.tlbEmployee e
                ON e.idfEmployee = eg.idfEmployeeGroup
                   AND e.intRowStatus = 0
            INNER JOIN FN_GBL_ReferenceRepair(@LanguageID, 19000022) employeeGroupName
                ON employeeGroupName.idfsReference = eg.idfsEmployeeGroupName
            INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000023) actorType
                ON e.idfsEmployeeType = actorType.idfsReference
            INNER JOIN dbo.trtBaseReference br
                ON br.idfsBaseReference = eg.idfsEmployeeGroupName
                   AND br.intRowStatus = 0
        WHERE oa.intRowStatus = 0
              AND eg.idfsSite = @SiteID
              AND oa.idfsOnSite = @SiteID
              AND oa.idfsObjectType = 10060011; -- Site

        -- Internal employee actors
        INSERT INTO @Results
        SELECT e.idfEmployee,
               10023002,
               actorType.name,
               dbo.FN_GBL_ConcatFullName(p.strFamilyName, p.strFirstName, p.strSecondName),
               e.idfsSite,
               0,
               0
        FROM dbo.tstObjectAccess oa
            INNER JOIN dbo.tlbEmployee e
                ON e.idfEmployee = oa.idfActor
                   AND e.intRowStatus = 0
            INNER JOIN dbo.tlbPerson p
                ON p.idfPerson = e.idfEmployee
                   AND p.intRowStatus = 0
            INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000023) actorType
                ON e.idfsEmployeeType = actorType.idfsReference
        WHERE oa.intRowStatus = 0
              AND e.idfsSite = @SiteID
              AND oa.idfsOnSite = @SiteID
              AND oa.idfsObjectType = 10060011; -- Site

        INSERT INTO @FinalResults
        SELECT *
        FROM @Results
        GROUP BY ActorID,
                 ActorTypeID,
                 ActorTypeName,
                 ActorName,
                 SiteID,
                 ExternalActorIndicator,
                 DefaultEmployeeGroupIndicator;

        SET @FirstRecord = (@PageNumber - 1) * @PageSize;
        SET @LastRecord = (@PageNumber * @PageSize + 1);
        SET @TotalRowCount =
        (
            SELECT COUNT(*) FROM @FinalResults
        );

        SELECT ActorID,
               ActorTypeID,
               ActorTypeName,
               ActorName,
               SiteID,
               ExternalActorIndicator,
               DefaultEmployeeGroupIndicator,
               RowAction,
               [RowCount],
               TotalRowCount,
               CurrentPage,
               TotalPages
        FROM
        (
            SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @SortColumn = 'ActorName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       ActorName
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'ActorName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       ActorName
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'ActorTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       ActorTypeName
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'ActorTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       ActorTypeName
                                               END DESC
                                     ) AS RowNum,
                   ActorID,
                   ActorTypeID,
                   ActorTypeName,
                   ActorName,
                   SiteID,
                   ExternalActorIndicator,
                   DefaultEmployeeGroupIndicator,
                   0 AS RowAction,
                   COUNT(*) OVER () AS [RowCount],
                   @TotalRowCount AS TotalRowCount,
                   CurrentPage = @PageNumber,
                   TotalPages = (@TotalRowCount / @PageSize) + IIF(COUNT(*) % @PageSize > 0, 1, 0)
            FROM @FinalResults
            GROUP BY ActorID,
                     ActorTypeID,
                     ActorTypeName,
                     ActorName,
                     SiteID,
                     ExternalActorIndicator,
                     DefaultEmployeeGroupIndicator
        ) AS x
        WHERE RowNum > @FirstRecord
              AND RowNum < @LastRecord
        ORDER BY RowNum;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
