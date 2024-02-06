-- ************************************************************************************************
-- Name: USP_GBL_LKUP_PERSON_GETList
--
-- Description: Selects data for person lookup tables
--          
-- Author: Mandar Kulkarni
--
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Stephen Long    01/10/2022 Added advanced search parameter.
-- Stephen Long    05/05/2023 Changed from institution repair to institution min.
--
-- Testing code:
/*
exec  USP_GBL_LKUP_PERSON_GETList 'en-US', NULL, NULL, 1, NULL, NULL
*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[USP_GBL_LKUP_PERSON_GETList]
(
    @LangID NVARCHAR(50),    --##PARAM @LangID - language ID
    @OfficeID BIGINT = NULL, --##PARAM @OfficeID - person office, if not NULL only persons related with this office are selected
    @ID BIGINT = NULL,       --##PARAM @ID - person ID, if NOT NULL only person with this ID IS selected.
    @ShowUsersOnly BIT = NULL,
    @intHACode INT = NULL,
    @AdvancedSearch NVARCHAR(200) = NULL
)
AS
BEGIN
    BEGIN TRY
        IF @ShowUsersOnly = 1
        BEGIN
            SELECT p.idfPerson,
                   ISNULL(p.strFamilyName, N'') + ISNULL(' ' + p.strFirstName, '') + ISNULL(' ' + p.strSecondName, '') AS FullName,
                   p.strFamilyName,
                   p.strFirstName,
                   organization.AbbreviatedName AS Organization,
                   organization.idfOffice,
                   position.name AS Position,
                   e.intRowStatus,
                   organization.intHACode,
                   CAST(CASE
                            WHEN (organization.intHACode & 2) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnHuman,
                   CAST(CASE
                            WHEN (organization.intHACode & 96) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnVet,
                   CAST(CASE
                            WHEN (organization.intHACode & 32) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnLivestock,
                   CAST(CASE
                            WHEN (organization.intHACode & 64) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnAvian,
                   CAST(CASE
                            WHEN (organization.intHACode & 128) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnVector,
                   CAST(CASE
                            WHEN (organization.intHACode & 256) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnSyndromic
            FROM dbo.tlbPerson p
                INNER JOIN dbo.tlbEmployee e
                    ON p.idfPerson = e.idfEmployee
                LEFT OUTER JOIN dbo.FN_GBL_Institution_Min(@LangID) organization
                    ON p.idfInstitution = organization.idfOffice
                LEFT OUTER JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000073) position
                    ON p.idfsStaffPosition = position.idfsReference
            WHERE idfOffice = ISNULL(NULLIF(@OfficeID, 0), idfOffice)
                  AND (
                          @ID IS NULL
                          OR @ID = p.idfPerson
                      )
                  AND (
                          @intHACode = 0
                          OR @intHACode IS NULL
                          OR (organization.intHACode & @intHACode) > 0
                      )
                  --intRowStatus IS not used here because we want to show in lookups all users including deleted ones
                  AND (
                          @AdvancedSearch IS NOT NULL
                          AND (
                                  p.strFamilyName LIKE '%' + @AdvancedSearch + '%'
                                  OR p.strFirstName LIKE '%' + @AdvancedSearch + '%'
                              )
                          OR @AdvancedSearch IS NULL
                      )
                  AND EXISTS
            (
                SELECT *
                FROM dbo.tstUserTable
                WHERE dbo.tstUserTable.idfPerson = p.idfPerson
                      and dbo.tstUserTable.intRowStatus = 0
            )   --Show only employees that have/had logins
                  AND p.intRowStatus = 0
                  and e.intRowStatus = 0
            ORDER BY FullName,
                     organization.AbbreviatedName,
                     position.name;
        END
        ELSE
        BEGIN
            SELECT p.idfPerson,
                   ISNULL(p.strFamilyName, N'') + ISNULL(' ' + p.strFirstName, '') + ISNULL(' ' + p.strSecondName, '') AS FullName,
                   p.strFamilyName,
                   p.strFirstName,
                   organization.AbbreviatedName AS Organization,
                   organization.idfOffice,
                   position.name AS Position,
                   e.intRowStatus,
                   organization.intHACode,
                   CAST(CASE
                            WHEN (organization.intHACode & 2) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnHuman,
                   CAST(CASE
                            WHEN (organization.intHACode & 96) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnVet,
                   CAST(CASE
                            WHEN (organization.intHACode & 32) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnLivestock,
                   CAST(CASE
                            WHEN (organization.intHACode & 64) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnAvian,
                   CAST(CASE
                            WHEN (organization.intHACode & 128) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnVector,
                   CAST(CASE
                            WHEN (organization.intHACode & 256) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnSyndromic
            FROM dbo.tlbPerson p
                INNER JOIN dbo.tlbEmployee e
                    ON p.idfPerson = e.idfEmployee
                LEFT OUTER JOIN dbo.FN_GBL_Institution_Min(@LangID) organization
                    ON p.idfInstitution = organization.idfOffice
                LEFT OUTER JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000073) position
                    ON p.idfsStaffPosition = position.idfsReference
            WHERE idfOffice = ISNULL(NULLIF(@OfficeID, 0), idfOffice)
                  AND (
                          @ID IS NULL
                          OR @ID = idfPerson
                      )
                  AND (
                          @intHACode = 0
                          OR @intHACode IS NULL
                          OR (organization.intHACode & @intHACode) > 0
                      )
                  AND (
                          @AdvancedSearch IS NOT NULL
                          AND (
                                  p.strFamilyName LIKE '%' + @AdvancedSearch + '%'
                                  OR p.strFirstName LIKE '%' + @AdvancedSearch + '%'
                              )
                          OR @AdvancedSearch IS NULL
                      )
                  AND p.intRowStatus = 0
                  and e.intRowStatus = 0
            ORDER BY FullName,
                     organization.intOrder,
                     organization.AbbreviatedName,
                     position.name;
        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
