--*************************************************************************************************
-- Name 				: USP_GBL_LKUP_ORG_GETList
-- Description			: Returns list of organizations with our without sites.
--          
-- Author               : Mandar Kulkarni
-- Revision History:
-- Name              Date       Change Detail
-- ----------------- ---------- ------------------------------------------------------------------
-- Minal             09/21/2021 Added introwstatus=0 for tstsite
-- Stephen Long      09/24/2021 Added accessory code and organization type parameters. Added group 
--                              by to remove duplicate organizations from returning.
-- Stephen Long      10/29/2021 Corrected site join to use idfOffice orgead of the organization's 
--                              site ID as the site set no longer stores site ID in tlbOffice.
-- Stephen Long      11/02/2021 Changed site ID to use the site's ID orgead of the one on 
--                              tlbOffice. 
-- Minal Shah        11/05/2021	Changed a join for idfssite
-- Mark Wilson       11/09/2021	Changed to check tstSite for idfsSite values
-- Mark Wilson       02/01/2022	Changed to use INTERSECT
-- Mark Wilson       03/15/2022	updated to account for null intHACode
-- Stephen Long      05/16/2022 Added row status parameter and where criteria; defaulted to null.
-- Mike Kornegay	 06/15/2022 Added idfsLocation as return field and parameter for filtering by location.
-- Stephen Long      05/05/2023 Corrected the joins for the abbreviated and full organization names.
--
-- Testing code:
/*
--Example of a call of procedure:

EXEC USP_GBL_LKUP_ORG_GETList 'en-US', 0, NULL, NULL, NULL --Orgs associated with a Site
EXEC USP_GBL_LKUP_ORG_GETList 'en-US', 1, NULL, NULL, NULL --Orgs without a site
EXEC USP_GBL_LKUP_ORG_GETList 'ka-GE', 2, NULL, NULL, NULL --All orgs irrespective of site
EXEC USP_GBL_LKUP_ORG_GETList 'en-US', 2, 64, NULL, NULL -- All orgs with HACode = 64 irrespective of site 
EXEC USP_GBL_LKUP_ORG_GETList 'en-US', 2, 96, NULL, NULL, NULL, 155575840002421 --All orgs with a specific location
*/
--*************************************************************************************************
CREATE or ALTER PROCEDURE [dbo].[USP_GBL_LKUP_ORG_GETList]
(
    @LangID NVARCHAR(50),
    @SiteFlag INT = 0,
    @AccessoryCode INT = NULL,
    @OrganizationTypeID BIGINT = NULL,
    @AdvancedSearch NVARCHAR(200),
    @RowStatus INT = NULL,
	@LocationID BIGINT = NULL
)
AS
BEGIN
    DECLARE @returnMsg VARCHAR(MAX) = 'Success',
            @returnCode INT = 0;

    BEGIN TRY
        SELECT org.idfOffice,
               org.idfsOfficeName,
               fullName.strDefault AS EnglishFullName,
               org.idfsOfficeAbbreviation,
               abbreviatedName.strDefault AS EnglishName,
               fullName.LongName AS FullName,
               abbreviatedName.name AS name,
               org.intHACode,
               S.idfsSite,
               S.strSiteName,
			   org.idfLocation
		FROM dbo.tlbOffice org
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000046) fullName ON fullName.idfsReference = org.idfsOfficeName
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000045) abbreviatedName ON abbreviatedName.idfsReference = org.idfsOfficeAbbreviation
			LEFT JOIN dbo.tlbGeoLocationShared gls
                    ON org.idfLocation = gls.idfGeoLocationShared
            LEFT JOIN dbo.tstSite S
                ON S.idfOffice = org.idfOffice
                   AND S.intRowStatus = 0
        WHERE (org.intRowStatus = @RowStatus OR @RowStatus IS NULL)
			  AND (org.idfLocation = @LocationID OR @LocationID IS NULL)
              AND (
                  (
                      @SiteFlag = 0
                      AND S.idfsSite IS NOT NULL
                  )
                  OR (
                         @SiteFlag = 1
                         AND S.idfsSite IS NULL
                     )
                  OR (@SiteFlag = 2)
              )
        AND (EXISTS
        (
            SELECT *
            FROM dbo.FN_GBL_SplitHACode(@AccessoryCode, 510)
            INTERSECT
            SELECT *
            FROM dbo.FN_GBL_SplitHACode(ISNULL(org.intHACode, 1), 510)
        
		) OR @AccessoryCode IS NULL)
              AND (
                      org.OrganizationTypeID = @OrganizationTypeID
                      OR @OrganizationTypeID IS NULL
                  )
              AND (
                      @AdvancedSearch IS NOT NULL
                      AND (
                              abbreviatedName.name LIKE '%' + @AdvancedSearch + '%'
                              --OR fullName.name LIKE '%' + @AdvancedSearch + '%'
                              OR abbreviatedName.strDefault LIKE '%' + @AdvancedSearch + '%'
                              --OR fullName.strDefault LIKE '%' + @AdvancedSearch + '%'
                          ) -- Apply filter if advanced search string is passed.
                      OR @AdvancedSearch IS NULL
                  ) -- Apply no filter if advanced search string is NULL		
        ORDER BY abbreviatedName.name;
    END TRY
    BEGIN CATCH
        SET @returnCode = ERROR_NUMBER()
        SET @returnMsg
            = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: '
              + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE())
              + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: '
              + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE()
    END CATCH
END
