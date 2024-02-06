--*************************************************************************************************
-- Name: USP_GBL_LKUP_DISEASE_GETList
--
-- Description: Returns a list of diseases filtered by a user's filtration permissions as defined 
-- per use case SAUC62.
--          
-- Author: Stephen Long
--
-- Revision History:
-- Name              Date       Change Detail
-- ----------------- ---------- ------------------------------------------------------------------
-- Stephen Long      09/29/2021 Initial release
-- Mike Kornegay	 11/03/2021 Added bitwise to where for Accessory Codes
-- Stephen Long      01/24/2022 Added ICD10 and OIE code to the query.
-- Mani				 03/10/2022	Added intHACode as return parameter
-- Leo Tracchia	     11/17/2022 Added distinct to remove possible duplicates from return
-- Mike Kornegay	 12/20/2022 Added idfsUsingType as return field.
-- Mike Kornegay     04/27/2023 Rolled back changes that were made incorrectly in commit f021eb276bcbfb3905255d4ed4fd8b23da5dbdae
--                              (set back to 12/20/2022 version that was correct)
--
-- Testing code:
/*
-- Human standard diseases
EXEC USP_GBL_LKUP_DISEASE_GETList 'en-US', 2, 10020001, NULL, 420664190000873
-- Avian aggregate diseases
EXEC USP_GBL_LKUP_DISEASE_GETList 'en-US', 96, null, NULL, 155568340001295
-- Livestock standard diseases wildcard matching advanced search term.
EXEC USP_GBL_LKUP_DISEASE_GETList 'en-US', 32, 10020001, 'Bru', 420664190000873
*/
--*************************************************************************************************
CREATE PROCEDURE [dbo].[USP_GBL_LKUP_DISEASE_GETList]
(
    @LanguageID NVARCHAR(50),
    @AccessoryCode INT = NULL,         -- Human, Avian, Livestock, Vector, etc.
    @UsingType BIGINT = NULL,          -- Aggregate or standard disease types
    @AdvancedSearchTerm NVARCHAR(200), -- String passed to filter disease names. If nothing is passed in, no filter is applied.
    @UserEmployeeID BIGINT
)
AS
BEGIN
    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator BIT NOT NULL,
        AccessToPersonalDataPermissionIndicator BIT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
        WritePermissionIndicator BIT NOT NULL,
        DeletePermissionIndicator BIT NOT NULL
    );

    BEGIN TRY
        INSERT INTO @Results
        SELECT d.idfsDiagnosis,
               1,
               1,
               1,
               1,
               1
        FROM dbo.trtDiagnosis d
            INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                ON disease.idfsReference = d.idfsDiagnosis
        WHERE d.intRowStatus = 0
              AND (
                      (disease.intHACode & @AccessoryCode) > 0 --IN (SELECT * FROM dbo.FN_GBL_SplitHACode(@AccessoryCode, 510))
                      OR @AccessoryCode IS NULL
                  )
              AND (
                      d.idfsUsingType = @UsingType
                      OR @UsingType IS NULL
                  )
              AND (
                      disease.name LIKE '%' + @AdvancedSearchTerm + '%'
                      OR @AdvancedSearchTerm IS NULL
                  );

        -- =======================================================================================
        -- DISEASE FILTRATION RULES
        --
        -- Apply disease filtration rules from use case SAUC62.
        -- =======================================================================================
        -- 
        -- Apply level 0 disease filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without site filtration rules applied.
        --
        DELETE FROM @Results
        WHERE ID IN (
                        SELECT d.idfsDiagnosis
                        FROM dbo.trtDiagnosis d
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = d.idfsDiagnosis
                                   AND oa.intRowStatus = 0
                        WHERE oa.intPermission = 1
                              AND oa.idfsObjectType = 10060001 -- Disease
                              AND oa.idfActor = -506 -- Default role
                    );

        --
        -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        INSERT INTO @Results
        SELECT d.idfsDiagnosis,
               1,
               1,
               1,
               1,
               1
        FROM dbo.trtDiagnosis d
            INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                ON disease.idfsReference = d.idfsDiagnosis
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = d.idfsDiagnosis
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND d.intRowStatus = 0
              AND (
                      d.idfsUsingType = @UsingType
                      OR @UsingType IS NULL
                  )
              AND (
                      disease.intHACode = @AccessoryCode
                      OR @AccessoryCode IS NULL
                  )
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup
              AND (
                      disease.name LIKE '%' + @AdvancedSearchTerm + '%'
                      OR @AdvancedSearchTerm IS NULL
                  );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = res.ID
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 1
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup;

        --
        -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT d.idfsDiagnosis,
               1,
               1,
               1,
               1,
               1
        FROM dbo.trtDiagnosis d
            INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                ON disease.idfsReference = d.idfsDiagnosis
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = d.idfsDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND d.intRowStatus = 0
              AND (
                      d.idfsUsingType = @UsingType
                      OR @UsingType IS NULL
                  )
              AND (
                      disease.intHACode = @AccessoryCode
                      OR @AccessoryCode IS NULL
                  )
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = @UserEmployeeID
              AND (
                      disease.name LIKE '%' + @AdvancedSearchTerm + '%'
                      OR @AdvancedSearchTerm IS NULL
                  );

        DELETE FROM @Results
        WHERE ID IN (
                        SELECT d.idfsDiagnosis
                        FROM dbo.trtDiagnosis d
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = ID
                                   AND oa.intRowStatus = 0
                        WHERE intPermission = 1 -- Deny permission
                              AND oa.idfsObjectType = 10060001 -- Disease
                              AND idfActor = @UserEmployeeID
                    );

        SELECT distinct ID AS DiseaseID,
			   disease.intHACode,
               disease.name AS DiseaseName,			   
               diagnosis.strIDC10 AS IDC10,
               diagnosis.strOIECode AS OIECode,
			   disease.intOrder,
			   diagnosis.idfsUsingType AS UsingType 
        FROM @Results
            INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                ON disease.idfsReference = ID
            LEFT JOIN dbo.trtDiagnosis diagnosis
                ON diagnosis.idfsDiagnosis = ID
        ORDER BY disease.intOrder,
                 disease.name;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
