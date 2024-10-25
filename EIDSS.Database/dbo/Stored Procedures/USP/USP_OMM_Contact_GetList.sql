-- ================================================================================================
-- Name: USP_OMM_Contact_GetList
--
-- Description: Gets a list of contacts for a given outbreak case.
--          
-- Author: Doug Albanese
-- Revision History:
--	Name				Date		Change Detail
--	---------------	----------	--------------------------------------------------------------------
--	Doug Albanese	02/20/2019	Added Procedure to obtain list of contacts for given case
--	Doug Albanese	06/08/2020	Added phone number to the data return
--	Stephen Long	04/08/2022	Added new pagination and sorting parameters and logic.
--	Stephen Long	04/29/2022	Updated parameter names and corrected contact relationship type join.
--	Stephen Long	05/01/2022	Added age and citizenship type name fields and join.
--	Stephen Long	05/03/2022	Added additional rules for removing when today's followups is 
--								checked.
--	Doug Albanese	08/15/2022	Changed ContactStatusTypeID to ContactStatusID, and ContactStatusTypeName to ContactStatusName
--  Stephen Long    10/25/2022  Added additional criteria for outbreak species type eliminate 
--                              duplicates on outbreak sessions with multiple species checked.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_OMM_Contact_GetList]
(
    @LanguageID NVARCHAR(50),
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(30) = 'ContactName',
    @SortOrder NVARCHAR(4) = 'ASC',
    @CaseID BIGINT = NULL,
    @OutbreakID BIGINT = NULL,
    @SearchTerm NVARCHAR(100) = NULL,
    @TodaysFollowUpsIndicator BIT = NULL
)
AS
BEGIN
    DECLARE @ReturnCode INT = 0;
    DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
    DECLARE @FirstRec INT = (@PageNumber - 1) * @PageSize,
            @LastRec INT = (@PageNumber * @PageSize + 1),
            @TotalRowCount INT;

    DECLARE @Contacts AS TABLE
    (
        TotalRowCount BIGINT NULL,
        CaseContactID BIGINT NULL,
        CaseID BIGINT NULL, 
        OutbreakTypeID BIGINT, 
        DiseaseID BIGINT, 
        ContactedHumanCasePersonID BIGINT NULL,
        PersonalIDTypeID BIGINT NULL, 
        PersonalID NVARCHAR(200) NULL, 
        FirstName NVARCHAR(200) NULL, 
        SecondName NVARCHAR(200) NULL, 
        LastName NVARCHAR(200) NULL, 
        ContactName NVARCHAR(200) NULL,
        DateOfBirth DATETIME NULL, 
        Age INT NULL, 
        GenderTypeID BIGINT NULL, 
        GenderTypeName NVARCHAR(200) NULL,
        CitizenshipTypeID BIGINT NULL, 
        CitizenshipTypeName NVARCHAR(200) NULL, 
        AddressID BIGINT NULL, 
        LocationID BIGINT NULL, 
        AdministrativeLevel0ID BIGINT NULL, 
        AdministrativeLevel1ID BIGINT NULL, 
        AdministrativeLevel2ID BIGINT NULL, 
        SettlementTypeID BIGINT NULL, 
        SettlementID BIGINT NULL, 
        Apartment NVARCHAR(200) NULL, 
        Building NVARCHAR(200) NULL, 
        House NVARCHAR(200) NULL, 
        StreetID BIGINT NULL, 
        Street NVARCHAR(200) NULL,
        PostalCodeID BIGINT NULL, 
        PostalCode NVARCHAR(200) NULL,
        ForeignAddressString NVARCHAR(200) NULL, 
        DateOfLastContact DATETIME NULL,
        PlaceOfLastContact NVARCHAR(200) NULL,
        Comment NVARCHAR(500) NULL,
        ContactTypeID BIGINT NULL,
        ContactTypeName NVARCHAR(200) NULL,
        ContactStatusID BIGINT NULL,
        ContactStatusName NVARCHAR(200) NULL,
        ContactRelationshipTypeID BIGINT NULL,
        ContactRelationshipTypeName NVARCHAR(200) NULL,
        CurrentLocation NVARCHAR(200) NULL,
        ContactTracingObservationID BIGINT NULL,
        ContactTracingDuration INT NULL,
        ContactTracingFrequency INT NULL,
        VeterinaryDiseaseReportTypeID BIGINT NULL, 
        EIDSSPersonID NVARCHAR(50),
        HumanID BIGINT NULL, 
        HumanMasterID BIGINT,
        FarmMasterID BIGINT NULL, 
        ContactPhoneTypeID BIGINT NULL, 
        ContactPhoneCountryCode INT NULL, 
        ContactPhone NVARCHAR(50) NULL
    );

    DECLARE @OutbreakCaseReportUIDs AS TABLE (OutbreakCaseReportUID BIGINT);

    IF COALESCE(@OutbreakID, 0) > 0
    BEGIN
        INSERT INTO @OutbreakCaseReportUIDs
        SELECT OutbreakCaseReportUID
        FROM dbo.OutbreakCaseReport
        WHERE idfOutbreak = @OutbreakId;
    END

    IF COALESCE(@CaseID, 0) > 0
    BEGIN
        INSERT INTO @OutbreakCaseReportUIDs
        SELECT @CaseID;
    END

    IF @TodaysFollowUpsIndicator = 1 
    BEGIN
        SET @SortColumn = 'DateOfLastContact';
        SET @SortOrder = 'ASC';
    END

    BEGIN TRY
        IF COALESCE(@SearchTerm, '') = ''
        BEGIN
            --Get the count of records for pagination
            SELECT @TotalRowCount = COUNT(DISTINCT OutbreakCaseContactUID)
            FROM dbo.OutbreakCaseContact occ
                INNER JOIN @OutbreakCaseReportUIDs ocr
                    ON ocr.OutbreakCaseReportUID = occ.OutBreakCaseReportUID
            WHERE occ.intRowStatus = 0;

            INSERT INTO @Contacts
            (
                TotalRowCount,
                CaseContactID,
                CaseID,
                OutbreakTypeID, 
                DiseaseID, 
                ContactedHumanCasePersonID,
                PersonalIDTypeID,
                PersonalID, 
                FirstName, 
                SecondName, 
                LastName, 
                ContactName,
                DateOfBirth, 
                Age, 
                GenderTypeID,
                GenderTypeName,
                CitizenshipTypeID,
                CitizenshipTypeName, 
                AddressID, 
                LocationID, 
                AdministrativeLevel0ID, 
                AdministrativeLevel1ID, 
                AdministrativeLevel2ID,
                SettlementTypeID, 
                SettlementID, 
                Apartment, 
                Building, 
                House, 
                StreetID, 
                Street, 
                PostalCodeID, 
                PostalCode,
                ForeignAddressString, 
                DateOfLastContact,
                PlaceOfLastContact,
                Comment,
                ContactTypeID,
                ContactTypeName,
                ContactStatusID,
                ContactStatusName,
                ContactRelationshipTypeID,
                ContactRelationshipTypeName,
                CurrentLocation,
                ContactTracingObservationID, 
                ContactTracingDuration,
                ContactTracingFrequency,
                VeterinaryDiseaseReportTypeID, 
                EIDSSPersonID,
                HumanID, 
                HumanMasterID,
                FarmMasterID, 
                ContactPhoneTypeID, 
                ContactPhoneCountryCode,
                ContactPhone
            )
            SELECT 
                @TotalRowCount,
                occ.OutbreakCaseContactUID,
                occ.OutBreakCaseReportUID,
                o.OutbreakTypeID, 
                o.idfsDiagnosisOrDiagnosisGroup, 
                occ.ContactedHumanCasePersonID,
                h.idfsPersonIDType, 
                h.strPersonID, 
                h.strFirstName, 
                h.strSecondName, 
                h.strLastName, 
                h.strLastName + ', ' + h.strFirstName,
                h.datDateofBirth,
                haai.ReportedAge,
                h.idfsHumanGender,
                gender.name,
                h.idfsNationality,
                citizenshipType.name, 
                h.idfCurrentResidenceAddress, 
                geo.idfsLocation, 
                lh.AdminLevel1ID, 
                lh.AdminLevel2ID, 
                lh.AdminLevel3ID, 
                settlement.idfsType, 
                settlement.idfsLocation,
                geo.strApartment, 
                geo.strBuilding, 
                geo.strHouse, 
                st.idfStreet, 
                geo.strStreetName, 
                pc.idfPostalCode,
                geo.strPostCode, 
                geo.strForeignAddress, 
                occ.DateOfLastContact,
                occ.PlaceOfLastContact,
                occ.CommentText,
                occ.ContactTypeID,
                contactType.name,
                occ.ContactStatusID,
                contactStatusType.name,
                occ.ContactRelationshipTypeID,
                contactRelationshipType.name,
                lh.AdminLevel2Name + ' ' + lh.AdminLevel3Name,
                occ.ContactTracingObservationID, 
                osp.ContactTracingDuration,
                osp.ContactTracingFrequency,
                vc.idfsCaseType,
                haai.EIDSSPersonID,
                h.idfHuman, 
                h.idfHumanActual,
                f.idfFarmActual, 
                haai.ContactPhoneNbrTypeID, 
                haai.ContactPhoneCountryCode, 
                haai.ContactPhoneNbr
            FROM dbo.OutbreakCaseContact occ
                LEFT JOIN dbo.OutbreakCaseReport ocr
                    ON ocr.OutBreakCaseReportUID = occ.OutBreakCaseReportUID
                INNER JOIN dbo.tlbOutbreak o 
                    ON o.idfOutbreak = ocr.idfOutbreak
                LEFT JOIN dbo.tlbVetCase vc 
                    ON vc.idfVetCase = ocr.idfVetCase
                LEFT JOIN dbo.OutbreakSpeciesParameter osp
                    ON osp.idfOutbreak = ocr.idfOutbreak 
                LEFT JOIN dbo.tlbHuman h
                    ON h.idfHuman = occ.idfHuman
                LEFT JOIN dbo.HumanActualAddlInfo haai
                    ON haai.HumanActualAddlInfoUID = h.idfHumanActual
                LEFT JOIN dbo.tlbFarm f 
                    ON f.idfHuman = occ.idfHuman 
                LEFT JOIN dbo.FN_GBL_Reference_GetList(@LanguageID, 19000043) gender
                    ON gender.idfsReference = h.idfsHumanGender
                LEFT JOIN dbo.FN_GBL_Reference_GetList(@LanguageID, 19000054) citizenshipType
                    ON citizenshipType.idfsReference = h.idfsNationality
                LEFT JOIN dbo.tlbGeoLocation geo
                    ON h.idfCurrentResidenceAddress = geo.idfGeoLocation
                LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                    ON lh.idfsLocation = geo.idfsLocation
                LEFT JOIN dbo.gisLocation settlement
                    ON settlement.idfsLocation = geo.idfsLocation AND settlement.idfsType IS NOT NULL
                LEFT JOIN dbo.tlbStreet st
                    ON st.strStreetName = geo.strStreetName
                LEFT JOIN dbo.tlbPostalCode pc
                    ON pc.strPostCode = geo.strPostCode
                LEFT JOIN dbo.FN_GBL_Reference_GetList(@LanguageID, 19000516) contactType
                    ON contactType.idfsReference = occ.ContactTypeID
                LEFT JOIN dbo.FN_GBL_Reference_GetList(@LanguageID, 19000517) contactStatusType
                    ON contactStatusType.idfsReference = occ.ContactStatusID
                LEFT JOIN dbo.FN_GBL_Reference_GetList(@LanguageID, 19000014) contactRelationshipType
                    ON contactRelationshipType.idfsReference = occ.ContactRelationshipTypeID
                INNER JOIN @OutbreakCaseReportUIDs ocru
                    ON ocru.OutbreakCaseReportUID = occ.OutBreakCaseReportUID
            WHERE occ.intRowStatus = 0
            AND ((ocr.idfVetCase IS NOT NULL AND (
                          vc.idfsCaseType = 10012004
                          AND osp.OutbreakSpeciesTypeID = 10514002
                      )
                  OR (
                         vc.idfsCaseType = 10012003
                         AND osp.OutbreakSpeciesTypeID = 10514003
                     ))
                  OR osp.OutbreakSpeciesTypeID = 10514001 AND ocr.idfHumanCase IS NOT NULL
                     );
        END
        ELSE
        BEGIN
            SELECT @TotalRowCount = COUNT(DISTINCT OutbreakCaseContactUID)
            FROM dbo.OutbreakCaseContact occ
                LEFT JOIN dbo.OutbreakCaseReport ocr
                    ON ocr.OutBreakCaseReportUID = occ.OutBreakCaseReportUID
                LEFT JOIN dbo.OutbreakSpeciesParameter osp
                    ON osp.idfOutbreak = ocr.idfOutbreak
                LEFT JOIN dbo.tlbVetCase vc 
                    ON vc.idfVetCase = ocr.idfVetCase
                LEFT JOIN dbo.tlbHuman h
                    ON h.idfHuman = occ.idfHuman
                LEFT JOIN dbo.FN_GBL_Reference_GetList(@LanguageID, 19000043) gender
                    ON gender.idfsReference = h.idfsHumanGender
                LEFT JOIN dbo.FN_GBL_Reference_GetList(@LanguageID, 19000054) citizenshipType
                    ON citizenshipType.idfsReference = h.idfsNationality
                LEFT JOIN dbo.tlbGeoLocation geo
                    ON h.idfCurrentResidenceAddress = geo.idfGeoLocation
                LEFT JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                    ON lh.idfsLocation = geo.idfsLocation
                LEFT JOIN dbo.FN_GBL_Reference_GetList(@LanguageID, 19000517) contactStatusType
                    ON contactStatusType.idfsReference = occ.ContactStatusID
                INNER JOIN @OutbreakCaseReportUIDs ocru
                    ON ocru.OutbreakCaseReportUID = occ.OutBreakCaseReportUID
            WHERE occ.intRowStatus = 0
                        AND ((ocr.idfVetCase IS NOT NULL AND (
                          vc.idfsCaseType = 10012004
                          AND osp.OutbreakSpeciesTypeID = 10514002
                      )
                  OR (
                         vc.idfsCaseType = 10012003
                         AND osp.OutbreakSpeciesTypeID = 10514003
                     ))
                  OR osp.OutbreakSpeciesTypeID = 10514001 AND ocr.idfHumanCase IS NOT NULL
                     )
                  AND (
                          occ.OutbreakCaseContactUID LIKE '%' + @SearchTerm + '%'
                          OR occ.ContactedHumanCasePersonID LIKE '%' + @SearchTerm + '%'
                          OR h.strLastName LIKE '%' + @SearchTerm + '%'
                          OR h.strFirstName LIKE '%' + @SearchTerm + '%'
                          OR occ.DateOfLastContact LIKE '%' + @SearchTerm + '%'
                          OR contactStatusType.name LIKE '%' + @SearchTerm + '%'
                          OR lh.AdminLevel2Name LIKE '%' + @SearchTerm + '%'
                          OR lh.AdminLevel3Name LIKE '%' + @SearchTerm + '%'
                          OR lh.AdminLevel4Name LIKE '%' + @SearchTerm + '%'
                          OR lh.AdminLevel5Name LIKE '%' + @SearchTerm + '%'
                          OR lh.AdminLevel6Name LIKE '%' + @SearchTerm + '%'
                          OR lh.AdminLevel7Name LIKE '%' + @SearchTerm + '%'
                          OR gender.name LIKE '%' + @SearchTerm + '%'
                      );

            INSERT INTO @Contacts
            (
                TotalRowCount,
                CaseContactID,
                CaseID,
                OutbreakTypeID, 
                DiseaseID, 
                ContactedHumanCasePersonID,
                PersonalIDTypeID, 
                PersonalID, 
                FirstName, 
                SecondName, 
                LastName, 
                ContactName,
                DateOfBirth, 
                Age, 
                GenderTypeID,
                GenderTypeName,
                CitizenshipTypeID,
                CitizenshipTypeName, 
                AddressID, 
                LocationID, 
                AdministrativeLevel0ID, 
                AdministrativeLevel1ID, 
                AdministrativeLevel2ID, 
                SettlementTypeID, 
                SettlementID, 
                Apartment, 
                Building, 
                House, 
                StreetID, 
                Street, 
                PostalCodeID, 
                PostalCode,
                ForeignAddressString, 
                DateOfLastContact,
                PlaceOfLastContact,
                Comment,
                ContactTypeID,
                ContactTypeName,
                ContactStatusID,
                ContactStatusName,
                ContactRelationshipTypeID,
                ContactRelationshipTypeName,
                CurrentLocation,
                ContactTracingObservationID, 
                ContactTracingDuration,
                ContactTracingFrequency,
                VeterinaryDiseaseReportTypeID, 
                EIDSSPersonID,
                HumanID, 
                HumanMasterID,
                FarmMasterID, 
                ContactPhoneTypeID, 
                ContactPhoneCountryCode,
                ContactPhone
            )
            SELECT DISTINCT
                @TotalRowCount,
                occ.OutbreakCaseContactUID,
                occ.OutBreakCaseReportUID,
                o.OutbreakTypeID, 
                o.idfsDiagnosisOrDiagnosisGroup, 
                occ.ContactedHumanCasePersonID,
                h.idfsPersonIDType, 
                h.strPersonID, 
                h.strFirstName, 
                h.strSecondName, 
                h.strLastName, 
                h.strLastName + ', ' + h.strFirstName,
                h.datDateofBirth,
                haai.ReportedAge, 
                h.idfsHumanGender,
                gender.name,
                h.idfsNationality,
                citizenshipType.name,
                h.idfCurrentResidenceAddress, 
                geo.idfsLocation, 
                lh.AdminLevel1ID, 
                lh.AdminLevel2ID, 
                lh.AdminLevel3ID, 
                settlement.idfsType, 
                settlement.idfsLocation,
                geo.strApartment, 
                geo.strBuilding, 
                geo.strHouse, 
                st.idfStreet, 
                geo.strStreetName, 
                pc.idfPostalCode, 
                geo.strPostCode, 
                geo.strForeignAddress, 
                occ.DateOfLastContact,
                occ.PlaceOfLastContact,
                occ.CommentText,
                occ.ContactTypeID,
                contactType.name,
                occ.ContactStatusID,
                contactStatusType.name,
                occ.ContactRelationshipTypeID,
                contactRelationshipType.name,
                lh.AdminLevel2Name + ' ' + lh.AdminLevel3Name,
                occ.ContactTracingObservationID, 
                osp.ContactTracingDuration,
                osp.ContactTracingFrequency,
                vc.idfsCaseType,
                haai.EIDSSPersonID,
                h.idfHuman, 
                h.idfHumanActual,
                f.idfFarmActual, 
                haai.ContactPhoneNbrTypeID, 
                haai.ContactPhoneCountryCode, 
                haai.ContactPhoneNbr
            FROM dbo.OutbreakCaseContact occ
                LEFT JOIN dbo.OutbreakCaseReport ocr
                    ON ocr.OutBreakCaseReportUID = occ.OutBreakCaseReportUID
                LEFT JOIN dbo.tlbVetCase vc 
                    ON vc.idfVetCase = ocr.idfVetCase
                INNER JOIN dbo.tlbOutbreak o 
                    ON o.idfOutbreak = ocr.idfOutbreak
                LEFT JOIN dbo.OutbreakSpeciesParameter osp
                    ON osp.idfOutbreak = ocr.idfOutbreak
                LEFT JOIN dbo.tlbHuman h
                    ON h.idfHuman = occ.idfHuman
                LEFT JOIN dbo.HumanActualAddlInfo haai
                    ON haai.HumanActualAddlInfoUID = h.idfHumanActual
                LEFT JOIN dbo.tlbFarm f 
                    ON f.idfHuman = occ.idfHuman 
                LEFT JOIN dbo.FN_GBL_Reference_GetList(@LanguageID, 19000043) gender
                    ON gender.idfsReference = h.idfsHumanGender
                LEFT JOIN dbo.FN_GBL_Reference_GetList(@LanguageID, 19000054) citizenshipType
                    ON citizenshipType.idfsReference = h.idfsNationality
                LEFT JOIN dbo.tlbGeoLocation geo
                    ON h.idfCurrentResidenceAddress = geo.idfGeoLocation
                LEFT JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                    ON lh.idfsLocation = geo.idfsLocation
                LEFT JOIN dbo.gisLocation settlement
                    ON settlement.idfsLocation = geo.idfsLocation AND settlement.idfsType IS NOT NULL
                LEFT JOIN dbo.tlbStreet st
                    ON st.strStreetName = geo.strStreetName
                LEFT JOIN dbo.tlbPostalCode pc
                    ON pc.strPostCode = geo.strPostCode
                LEFT JOIN dbo.FN_GBL_Reference_GetList(@LanguageID, 19000516) contactType
                    ON contactType.idfsReference = occ.ContactTypeID
                LEFT JOIN dbo.FN_GBL_Reference_GetList(@LanguageID, 19000517) contactStatusType
                    ON contactStatusType.idfsReference = occ.ContactStatusID
                LEFT JOIN dbo.FN_GBL_Reference_GetList(@LanguageID, 19000014) contactRelationshipType
                    ON contactRelationshipType.idfsReference = occ.ContactRelationshipTypeID
                INNER JOIN @OutbreakCaseReportUIDs ocru
                    ON ocru.OutbreakCaseReportUID = occ.OutBreakCaseReportUID
            WHERE occ.intRowStatus = 0
                        AND ((ocr.idfVetCase IS NOT NULL AND (
                          vc.idfsCaseType = 10012004
                          AND osp.OutbreakSpeciesTypeID = 10514002
                      )
                  OR (
                         vc.idfsCaseType = 10012003
                         AND osp.OutbreakSpeciesTypeID = 10514003
                     ))
                  OR osp.OutbreakSpeciesTypeID = 10514001 AND ocr.idfHumanCase IS NOT NULL
                     )
                  AND (
                          occ.OutbreakCaseContactUID LIKE '%' + @SearchTerm + '%'
                          OR occ.ContactedHumanCasePersonID LIKE '%' + @SearchTerm + '%'
                          OR h.strLastName LIKE '%' + @SearchTerm + '%'
                          OR h.strFirstName LIKE '%' + @SearchTerm + '%'
                          OR gender.name LIKE '%' + @SearchTerm + '%'
                          OR occ.DateOfLastContact LIKE '%' + @SearchTerm + '%'
                          OR contactStatusType.name LIKE '%' + @SearchTerm + '%'
                          OR lh.AdminLevel2Name LIKE '%' + @SearchTerm + '%'
                          OR lh.AdminLevel3Name LIKE '%' + @SearchTerm + '%'
                          OR lh.AdminLevel4Name LIKE '%' + @SearchTerm + '%'
                          OR lh.AdminLevel5Name LIKE '%' + @SearchTerm + '%'
                          OR lh.AdminLevel6Name LIKE '%' + @SearchTerm + '%'
                          OR lh.AdminLevel7Name LIKE '%' + @SearchTerm + '%'
                      );
        END

        IF @TodaysFollowUpsIndicator = 1
        BEGIN
            DELETE FROM @Contacts
            WHERE ContactTracingFrequency IS NULL
                  OR ContactTracingDuration IS NULL
                  OR ContactStatusID IN (10517002, 10517003, 10517004, 10517005);

            DELETE FROM @Contacts
            WHERE CaseContactID NOT IN (
                                                    SELECT CaseContactID
                                                    FROM @Contacts
                                                    WHERE (
                                                              DateOfLastContact > DATEADD(
                                                                                             DAY,
                                                                                             -ContactTracingDuration,
                                                                                             GETDATE()
                                                                                         )
                                                              AND DATEDIFF(DAY, DateOfLastContact, GETDATE())
                                                                  % ContactTracingFrequency = 0
                                                          )
                                                          OR ContactTracingFrequency IS NULL
                                                );
        END

        SELECT CaseContactID,
            CaseID, 
            OutbreakTypeID, 
            DiseaseID, 
            ContactedHumanCasePersonID,
            PersonalIDTypeID, 
            PersonalID, 
            FirstName, 
            SecondName, 
            LastName, 
            ContactName,
            DateOfBirth, 
            Age, 
            GenderTypeID,
            GenderTypeName,
            CitizenshipTypeID,
            CitizenshipTypeName, 
            AddressID, 
            LocationID, 
            AdministrativeLevel0ID, 
            AdministrativeLevel1ID, 
            AdministrativeLevel2ID,
            SettlementTypeID, 
            SettlementID, 
            Apartment, 
            Building, 
            House, 
            StreetID, 
            Street, 
            PostalCodeID, 
            PostalCode,
            ForeignAddressString, 
            DateOfLastContact,
            PlaceOfLastContact,
            Comment,
            ContactTypeID,
            ContactTypeName,
            ContactStatusID,
            ContactStatusName,
            ContactRelationshipTypeID,
            ContactRelationshipTypeName,
            CurrentLocation,
            ContactTracingObservationID, 
            ContactTracingDuration,
            ContactTracingFrequency,
            VeterinaryDiseaseReportTypeID, 
            EIDSSPersonID,
            HumanID, 
            HumanMasterID,
            FarmMasterID, 
            ContactPhoneTypeID, 
            ContactPhoneCountryCode,
            ContactPhone,
            RowAction,
            [RowCount],
            TotalRowCount,
            CurrentPage,
            TotalPages
        FROM
        (
            SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @SortColumn = 'ContactTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       ContactTypeName
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'ContactTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       ContactTypeName
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'ContactName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       ContactName
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'ContactName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       ContactName
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'ContactRelationTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       ContactRelationshipTypeName
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'ContactRelationTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       ContactRelationshipTypeName
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'DateOfLastContact'
                                                        AND @SortOrder = 'ASC' THEN
                                                       DateOfLastContact
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'DateOfLastContact'
                                                        AND @SortOrder = 'DESC' THEN
                                                       DateOfLastContact
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'PlaceOfLastContact'
                                                        AND @SortOrder = 'ASC' THEN
                                                       PlaceOfLastContact
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'PlaceOfLastContact'
                                                        AND @SortOrder = 'DESC' THEN
                                                       PlaceOfLastContact
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'CurrentLocation'
                                                        AND @SortOrder = 'ASC' THEN
                                                       CurrentLocation
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'CurrentLocation'
                                                        AND @SortOrder = 'DESC' THEN
                                                       CurrentLocation
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'Gender'
                                                        AND @SortOrder = 'ASC' THEN
                                                       GenderTypeName
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'Gender'
                                                        AND @SortOrder = 'DESC' THEN
                                                       GenderTypeName
                                               END DESC
                                     ) AS RowNum,
                   CaseContactID,
                   CaseID, 
                   OutbreakTypeID, 
                   DiseaseID, 
                   ContactedHumanCasePersonId,
                   PersonalIDTypeID, 
                   PersonalID, 
                   FirstName, 
                   SecondName, 
                   LastName, 
                   ContactName,
                   DateOfBirth, 
                   Age, 
                   GenderTypeID, 
                   GenderTypeName,
                   CitizenshipTypeID, 
                   CitizenshipTypeName, 
                   AddressID, 
                   LocationID, 
                   AdministrativeLevel0ID, 
                   AdministrativeLevel1ID, 
                   AdministrativeLevel2ID,
                   SettlementTypeID, 
                   SettlementID, 
                   Apartment, 
                   Building, 
                   House,
                   StreetID, 
                   Street, 
                   PostalCodeID, 
                   PostalCode, 
                   ForeignAddressString, 
                   DateOfLastContact,
                   PlaceOfLastContact,
                   Comment,
                   ContactTypeID,
                   ContactTypeName,
                   ContactStatusID,
                   ContactStatusName,
                   ContactRelationshipTypeID,
                   ContactRelationshipTypeName,
                   CurrentLocation,
                   ContactTracingObservationID, 
                   ContactTracingDuration,
                   ContactTracingFrequency,
                   VeterinaryDiseaseReportTypeID, 
                   EIDSSPersonID,
                   HumanID, 
                   HumanMasterID,
                   FarmMasterID, 
                   ContactPhoneTypeID, 
                   ContactPhoneCountryCode, 
                   ContactPhone,
                   0 AS RowAction,
                   COUNT(*) OVER () AS [RowCount],
                   @TotalRowCount AS TotalRowCount,
                   CurrentPage = @PageNumber,
                   TotalPages = (@TotalRowCount / @PageSize) + IIF(COUNT(*) % @PageSize > 0, 1, 0)
            FROM @Contacts
            GROUP BY CaseContactID,
                   CaseID,
                   OutbreakTypeID, 
                   DiseaseID, 
                   ContactedHumanCasePersonID,
                   PersonalIDTypeID, 
                   PersonalID, 
                   FirstName, 
                   SecondName, 
                   LastName, 
                   ContactName,
                   DateOfBirth, 
                   Age, 
                   GenderTypeID, 
                   GenderTypeName,
                   CitizenshipTypeID, 
                   CitizenshipTypeName, 
                   AddressID, 
                   LocationID, 
                   AdministrativeLevel0ID, 
                   AdministrativeLevel1ID, 
                   AdministrativeLevel2ID,
                   SettlementTypeID, 
                   SettlementID, 
                   Apartment, 
                   Building, 
                   House, 
                   StreetID, 
                   Street, 
                   PostalCodeID, 
                   PostalCode, 
                   ForeignAddressString, 
                   DateOfLastContact,
                   PlaceOfLastContact,
                   Comment,
                   ContactTypeID,
                   ContactTypeName,
                   ContactStatusID,
                   ContactStatusName,
                   ContactRelationshipTypeID,
                   ContactRelationshipTypeName,
                   CurrentLocation,
                   ContactTracingObservationID, 
                   ContactTracingDuration,
                   ContactTracingFrequency,
                   VeterinaryDiseaseReportTypeID, 
                   EIDSSPersonID,
                   HumanID, 
                   HumanMasterID,
                   FarmMasterID, 
                   ContactPhoneTypeID, 
                   ContactPhoneCountryCode, 
                   ContactPhone
        ) AS x
        WHERE RowNum > @FirstRec
              AND RowNum < @LastRec
        ORDER BY RowNum;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT = 1
            ROLLBACK;
        throw;
    END CATCH;

END;
