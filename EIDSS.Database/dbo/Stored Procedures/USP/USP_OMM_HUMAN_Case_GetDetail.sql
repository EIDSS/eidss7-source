-- ================================================================================================
-- Name: [USP_OMM_Case_GetDetail]
--
-- Description: Gets details on a human outbreak case record.
--
-- Author: Doug Albanese
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Doug Albanese	05/02/2022 New SP to separate request from common case details of 
--                             USP_OMM_Case_GetDetail
-- Doug Albanese	05/03/2022 Added disease id
-- Doug Albanese	05/04/2022 Adding "Text" version for Offices and Persons, for Select2 popuation
-- Doug Albanese	05/04/2022 Changed over to Location Hierarchy
-- Doug Albanese	05/04/2022 idfHumanCase added for reference within the shared HDR View Component
-- Doug Albanese	05/05/2022 Added Text for Select2 objects in Outbreak Investigation 
--                             (Organization/Person)
-- Doug Albanese	05/05/2022 Added Text for Outbreak Case Classification
-- Doug Albanese	05/05/2022 Corrected some Flex Form observations, and cleaned up output fields
-- Doug Albanese	05/06/2022 Added location information for Editing purposes
-- Doug Albanese	05/09/2022 Added OutbreakTypeId for Flex Form identification
-- Doug Albanese    10/25/2022 Swapped tlbHumanCase.idfEpiObservation with OutbreakCaseReport.
--                             OutbreakCaseObservationID
-- Stephen Long     05/17/2023 Fix for item 5584.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_OMM_HUMAN_Case_GetDetail]
(
    @LangID NVARCHAR(50),
    @OutbreakCaseReportUID BIGINT = -1
)
AS
BEGIN
    DECLARE @returnCode INT = 0;
    DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS';
    BEGIN TRY
        DECLARE @Antimicrobials NVARCHAR(MAX);
        DECLARE @Vaccinations NVARCHAR(MAX);
        DECLARE @Contacts NVARCHAR(MAX);
        DECLARE @Samples NVARCHAR(MAX);
        DECLARE @Tests NVARCHAR(MAX);
        DECLARE @CaseMonitorings NVARCHAR(MAX);
        DECLARE @idfHumanCase BIGINT;
        DECLARE @RelatedToIdentifiers TABLE
        (
            ID BIGINT NOT NULL,
            ReportID NVARCHAR(200) NOT NULL
        );
        SELECT @idfHumanCase = idfHumanCase
        FROM dbo.OutbreakCaseReport
        WHERE OutbreakCaseReportUID = @OutbreakCaseReportUID; --Obtain listing of Vaccinations for Json object

        DECLARE @CaseOutbreakSessionImportedIndicator INT = (
                                                                 SELECT CASE
                                                                            WHEN idfOutbreak IS NOT NULL
                                                                                 AND (strCaseID IS NOT NULL OR LegacyCaseID IS NOT NULL) THEN
                                                                                1
                                                                            ELSE
                                                                                0
                                                                        END
                                                                 FROM dbo.tlbHumanCase
                                                                 WHERE idfHumanCase = @idfHumanCase
                                                             );

        IF @CaseOutbreakSessionImportedIndicator = 1
        BEGIN
            DECLARE @RelatedToDiseaseReportID BIGINT = @idfHumanCase,
                    @ConnectedDiseaseReportID BIGINT;

            INSERT INTO @RelatedToIdentifiers
            SELECT idfHumanCase,
                   strCaseID
            FROM dbo.tlbHumanCase
            WHERE idfHumanCase = @idfHumanCase;

            WHILE EXISTS
        (
            SELECT *
            FROM dbo.HumanDiseaseReportRelationship
            WHERE HumanDiseaseReportID = @RelatedToDiseaseReportID
        )
            BEGIN
                INSERT INTO @RelatedToIdentifiers
                SELECT RelateToHumanDiseaseReportID,
                       strCaseID
                FROM dbo.HumanDiseaseReportRelationship
                    INNER JOIN dbo.tlbHumanCase
                        ON idfHumanCase = RelateToHumanDiseaseReportID
                WHERE HumanDiseaseReportID = @RelatedToDiseaseReportID;

                SET @RelatedToDiseaseReportID =
                (
                    SELECT RelateToHumanDiseaseReportID
                    FROM dbo.HumanDiseaseReportRelationship
                    WHERE HumanDiseaseReportID = @RelatedToDiseaseReportID
                );
            END
        END

        SET @Antimicrobials =
        (
            SELECT idfAntimicrobialTherapy,
                   datFirstAdministeredDate AS FirstAdministeredDate,
                   strAntimicrobialTherapyName AS AntimicrobialName,
                   strDosage AS AntimicrobialDose
            FROM dbo.tlbAntimicrobialTherapy
            WHERE intRowStatus = 0
                  AND idfHumanCase = @idfHumanCase
            FOR JSON PATH
        );

        --Obtain listing of Vaccinations for Json object
        SET @Vaccinations =
        (
            SELECT HumanDiseaseReportVaccinationUID,
                   VaccinationName,
                   VaccinationDate
            FROM dbo.HumanDiseaseReportVaccination
            WHERE intRowStatus = 0
                  AND idfHumanCase = @idfHumanCase
            FOR JSON PATH
        );

        --Obtain listing of Contacts for Json object
        SET @Contacts =
        (
            SELECT CCP.idfContactedCasePerson,                          --tlbContactedCasePerson Identity
                   OCC.OutbreakCaseContactUID,                          --OutbreakCaseContact Identity
                   OCC.OutBreakCaseReportUID,                           --(OutbreakCaseReport Identity) OutBreakCaseReport: OutBreakCaseReportUID
                   H.strFirstName + ' ' + H.strLastName AS ContactName, --tlbContactedCasePerson
                   OCC.ContactTypeID,                                   --"Contact Type" OutbreakCaseContact: ContactTypeID
                   CT.Name As ContactType,                              --"Contact Type" Text only for display
                   OCC.ContactRelationshipTypeID,                       --"Relation" OutbreakCaseContact: ContactRelationshipTypeID
                   CCP.idfsPersonContactType,                           --"Relation" tlbContactedCasePerson: idfsPersonContactType
                   Relation.Name AS Relation,                           --"Relation" Text only for display
                   OCC.DateOfLastContact AS datDateOfLastContact,       --"Date of Last Contact" OutbreakCaseContact: DateOfLastContact
                   OCC.PlaceOfLastContact AS strPlaceInfo,              --"Place of Last Contact" tlbContactedCasePerson: strPlaceInfo
                   OCC.ContactStatusID,                                 --"Contact Status" OutbreakCaseContact: ContactStatusID
                   CS.name AS ContactStatus,                            --"Contact Status" Text only for display
                   OCC.CommentText AS strComments,                      --"Comments" tlbContactedCasePerson: strComments
                   H.idfHumanActual,                                    --(Human Actual Identity) tlbHumanActual: idfHumanActual
                   OCC.ContactTracingObservationId AS idfObservation,   --Flex Form Observation Id
                   ft.idfsFormType
            FROM dbo.OutbreakCaseContact OCC
                LEFT JOIN dbo.tlbHuman H
                    ON H.idfHuman = OCC.idfHuman
                LEFT JOIN dbo.tlbContactedCasePerson CCP
                    ON CCP.idfContactedCasePerson = OCC.ContactedHumanCasePersonID
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000014) Relation
                    ON Relation.idfsReference = OCC.ContactRelationshipTypeID
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000517) CS
                    ON CS.idfsReference = OCC.ContactStatusID
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000516) CT
                    ON CT.idfsReference = OCC.ContactTypeID
                LEFT JOIN dbo.tlbObservation o
                    ON o.idfObservation = occ.ContactTracingObservationID
                LEFT JOIN dbo.ffFormTemplate ft
                    ON ft.idfsFormTemplate = o.idfsFormTemplate
            WHERE OutBreakCaseReportUID = @OutbreakCaseReportUID
                  AND OCC.intRowStatus = 0
            FOR JSON PATH
        );

        --Obtain listing of Samples for Json Object
        SET @Samples =
        (
            SELECT m.idfMaterial,
                   m.idfsSampleType,
                   R.Name AS SampleType,
                   m.strFieldBarcode,
                   m.datFieldCollectionDate,
                   Coalesce(m.idfFieldCollectedByOffice, -1) AS idfFieldCollectedByOffice,
                   CO.name As CollectedByOffice,
                   --Coalesce(m.idfFieldCollectedByPerson,-1) AS idfFieldCollectedByPerson,
                   m.idfFieldCollectedByPerson,
                   Coalesce(prb.strFirstName + ' ' + prb.strFamilyName, '') As CollectedByPerson,
                   Coalesce(m.idfSendToOffice, -1) AS idfSendToOffice,
                   SO.name As SentToOffice,
                   Coalesce(m.strNote, '') AS strNote,
                   m.datFieldSentDate
            FROM dbo.OutbreakCaseReport ocr
                LEFT JOIN dbo.tlbHumanCase hc
                    ON hc.idfHumanCase = ocr.idfHumanCase
                LEFT JOIN dbo.tlbMaterial m
                    ON m.idfHumanCase = hc.idfHumanCase
                LEFT JOIN dbo.tlbOffice rbo
                    ON rbo.idfOffice = m.idfFieldCollectedByOffice
                LEFT JOIN dbo.tlbOffice rbo2
                    ON rbo2.idfOffice = m.idfSendToOffice
                LEFT JOIN dbo.tlbPerson prb
                    ON prb.idfPerson = m.idfFieldCollectedByPerson
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000046) CO
                    ON CO.idfsReference = rbo.idfsOfficeName
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000046) SO
                    ON SO.idfsReference = rbo2.idfsOfficeName
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000087) R
                    ON R.idfsReference = m.idfsSampleType
            WHERE ocr.OutBreakCaseReportUID = @OutbreakCaseReportUID
                  AND m.intRowStatus = 0
            FOR JSON PATH
        );

        SET @Tests =
        (
            SELECT t.idfTesting,
                   m.idfMaterial,
                   m.idfsSampleType,
                   m.strFieldBarcode,
                   m.strBarcode,
                   t.idfsTestName,
                   t.idfsTestResult,
                   t.idfsTestStatus,
                   t.datConcludedDate,
                   t.idfsTestCategory,
                   tv.idfsInterpretedStatus,
                   tv.strInterpretedComment,
                   tv.datInterpretationDate,
                   tv.idfInterpretedByPerson,
                   case tv.blnValidateStatus
                       when 1 then
                           1
                       else
                           0
                   end as blnValidateStatus,
                   tv.strValidateComment,
                   tv.datValidationDate,
                   tv.idfValidatedByPerson,
                   ST.name AS SampleType,
                   TN.name AS TestName,
                   TR.name AS TestResult,
                   TS.name AS TestStatus,
                   TC.name AS TestCategory,
                   ITS.name AS InterpretedStatus,
                   Coalesce(ibp.strFirstName + ' ' + ibp.strFamilyName, '') As InterpretedByPerson,
                   Coalesce(vbp.strFirstName + ' ' + vbp.strFamilyName, '') As ValidatedByPerson
            FROM dbo.OutbreakCaseReport OCR
                LEFT JOIN dbo.tlbHumanCase hc
                    ON hc.idfHumanCase = ocr.idfHumanCase
                LEFT JOIN dbo.tlbMaterial m
                    ON m.idfHumanCase = hc.idfHumanCase
                LEFT JOIN dbo.tlbTesting t
                    ON t.idfMaterial = m.idfMaterial
                LEFT JOIN dbo.tlbTestValidation tv
                    ON tv.idfTesting = t.idfTesting
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000087) ST
                    ON ST.idfsReference = m.idfsSampleType
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000097) TN
                    ON TN.idfsReference = t.idfsTestName
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000096) TR
                    ON TR.idfsReference = t.idfsTestResult
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000001) TS
                    ON TS.idfsReference = t.idfsTestStatus
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000095) TC
                    ON TC.idfsReference = t.idfsTestCategory
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000106) ITS
                    ON ITS.idfsReference = tv.idfsInterpretedStatus
                LEFT JOIN dbo.tlbPerson ibp
                    ON ibp.idfPerson = tv.idfInterpretedByPerson
                LEFT JOIN dbo.tlbPerson vbp
                    ON vbp.idfPerson = tv.idfValidatedByPerson
            WHERE OCR.OutBreakCaseReportUID = @OutBreakCaseReportUID
                  AND t.intRowStatus = 0
            FOR JSON PATH
        );

        SET @CaseMonitorings =
        (
            SELECT ocm.idfOutbreakCaseMonitoring,
                   ocm.idfObservation,
                   ocm.datMonitoringdate,
                   ocm.idfInvestigatedByOffice,
                   fcboName.name AS InvestigatedByOffice,
                   ocm.idfInvestigatedByPerson,
                   CONCAT(P.strFirstName, ' ', P.strFamilyName) AS InvestigatedByPerson,
                   ocm.strAdditionalComments,
                   ocm.intRowStatus,
                   ft.idfsFormType
            FROM dbo.tlbOutbreakCaseMonitoring ocm
                LEFT JOIN dbo.tlbOffice o
                    ON o.idfOffice = ocm.idfInvestigatedByOffice
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000045) fcboName
                    ON fcboName.idfsReference = o.idfsOfficeName
                LEFT JOIN dbo.tlbPerson P
                    ON P.idfPerson = ocm.idfInvestigatedByPerson
                LEFT JOIN dbo.tlbObservation OB
                    ON OB.idfObservation = ocm.idfObservation
                LEFT JOIN dbo.ffFormTemplate ft
                    ON ft.idfsFormTemplate = OB.idfsFormTemplate
            WHERE idfHumanCase = @idfHumanCase
                  AND ocm.intRowStatus = 0
            FOR JSON PATH
        );

        SELECT DISTINCT
            --General
            ocr.idfOutbreak,
            h.idfHumanActual,
            --Notification
            hc.datNotificationDate,
            hc.idfSentByOffice,
            SentByOffice.name AS SentByOffice,
            hc.idfSentByPerson,
            SentByPerson.strFirstName + ' ' + SentByPerson.strFamilyName AS SentByPerson,
            hc.idfReceivedByOffice,
            ReceivedByOffice.name AS ReceivedByOffice,
            hc.idfReceivedByPerson,
            ReceivedByPerson.strFirstName + ' ' + ReceivedByPerson.strFamilyName AS ReceivedByPerson,
            --Case Locatiton
            geo.idfGeoLocation,
            geo.idfsLocation,
            lh.AdminLevel1ID AS AdminLevel0Value,
            lh.AdminLevel2ID AS AdminLevel1Value,
            lh.AdminLevel2Name AS AdminLevel1Text,
            lh.AdminLevel3ID AS AdminLevel2Value,
            lh.AdminLevel3Name AS AdminLevel2Text,
            lh.AdminLevel4ID AS AdminLevel3Value,
            lh.AdminLevel4Name AS AdminLevel3Text,
            geo.strStreetName,
            geo.strPostCode,
            geo.strBuilding,
            geo.strHouse,
            geo.strApartment,
            geo.dblLatitude,
            geo.dblLongitude,
            --Clinical Information
            ocr.OutbreakCaseStatusID,
            OutbreakCaseStatus.Name AS OutbreakCaseStatusName,
            hc.datOnSetDate,
            hc.datFinalDiagnosisDate,
            hc.idfHospital,
            hc.strHospitalizationPlace,
            hc.datHospitalizationDate,
            hc.datDischargeDate,
            hc.strClinicalNotes,
            hc.strNote,
            @Antimicrobials AS Antimicrobials,
            @Vaccinations AS Vaccinations,
            --Outbreak Investigation
            hc.idfInvestigatedByOffice,
            InvestigatedByOffice.name AS InvestigatedByOffice,
            hc.idfInvestigatedByPerson,
            InvestigatedByPerson.strFirstName + ' ' + InvestigatedByPerson.strFamilyName AS InvestigatedByPerson,
            hc.datInvestigationStartDate,
            OCR.OutbreakCaseClassificationID,
            OutbreakClassification.name AS OutbreakCaseClassificationName,
            OCR.IsPrimaryCaseFlag,
            --Case Monitoring
            @CaseMonitorings AS CaseMonitorings,
            --Contacts
            @Contacts AS Contacts,
            --Samples
            hc.idfsYNSpecimenCollected,
            @Samples AS Samples,
            --Tests
            hc.idfsYNTestsConducted,
            @Tests AS Tests,
            hc.idfsYNAntimicrobialTherapy,
            hc.idfsYNHospitalization,
            hc.idfsYNSpecificVaccinationAdministered,
            --Outbreak Flex Forms
            OCR.OutbreakCaseObservationID,
            OCOFT.idfsFormType AS OutbreakCaseObservationFormType,
            OCR.CaseEPIObservationID,
            OCMFT.idfsFormType AS CaseEPIObservationFormType,
            ocr.OutbreakCaseObservationID AS idfEpiObservation,
            hc.idfCSObservation,
            o.idfsDiagnosisOrDiagnosisGroup,
            ocr.idfHumanCase,
            o.OutbreakTypeID,
            (SELECT STRING_AGG(ID, ', ') WITHIN GROUP (ORDER BY ReportID) AS Result
            FROM @RelatedToIdentifiers) AS RelatedToIdentifiers,
            (SELECT STRING_AGG(ReportID, ', ') WITHIN GROUP (ORDER BY ReportID) AS Result
            FROM @RelatedToIdentifiers) AS RelatedToReportIdentifiers
        FROM dbo.OutbreakCaseReport ocr
            LEFT JOIN dbo.tlbHumanCase hc
                ON hc.idfHumanCase = ocr.idfHumanCase
            LEFT JOIN dbo.tlbHuman h
                ON h.idfHuman = hc.idfHuman
            LEFT JOIN dbo.tlbHumanActual ha
                ON ha.idfHumanActual = h.idfHumanActual
            LEFT JOIN dbo.HumanActualAddlInfo haai
                ON haai.HumanActualAddlInfoUID = ha.idfHumanActual
            LEFT JOIN dbo.tlbOutbreak o
                ON o.idfOutbreak = OCR.idfOutbreak
            LEFT JOIN dbo.tlbGeoLocation geo
                ON h.idfCurrentResidenceAddress = geo.idfGeoLocation
            LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) lh
                ON lh.idfsLocation = geo.idfsLocation
            LEFT JOIN dbo.tlbAntimicrobialTherapy amt
                ON amt.idfHumanCase = ocr.idfHumanCase
            LEFT JOIN dbo.HumanDiseaseReportVaccination hdrv
                ON hdrv.idfHumanCase = ocr.idfHumanCase
            LEFT JOIN dbo.tlbObservation OCO
                ON OCO.idfObservation = OCR.OutbreakCaseObservationID
            LEFT JOIN dbo.tlbObservation CMO
                ON CMO.idfObservation = OCR.CaseEPIObservationID
            LEFT JOIN dbo.ffFormTemplate OCOFT
                ON OCOFT.idfsFormTemplate = OCO.idfsFormTemplate
            LEFT JOIN dbo.ffFormTemplate OCMFT
                ON OCMFT.idfsFormTemplate = CMO.idfsFormTemplate
            LEFT JOIN dbo.tlbOffice SBO
                ON SBO.idfOffice = hc.idfSentByOffice
            LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000046) SentByOffice
                ON SentByOffice.idfsReference = SBO.idfsOfficeName
            LEFT JOIN dbo.tlbOffice RBO
                ON RBO.idfOffice = hc.idfReceivedByOffice
            LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000046) ReceivedByOffice
                ON ReceivedByOffice.idfsReference = RBO.idfsOfficeName
            LEFT JOIN dbo.tlbPerson SentByPerson
                ON SentByPerson.idfPerson = hc.idfSentByPerson
            LEFT JOIN dbo.tlbPerson ReceivedByPerson
                ON ReceivedByPerson.idfPerson = hc.idfReceivedByPerson
            LEFT JOIN dbo.tlbOffice IBO
                ON IBO.idfOffice = hc.idfInvestigatedByOffice
            LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000046) InvestigatedByOffice
                ON InvestigatedByOffice.idfsReference = IBO.idfsOfficeName
            LEFT JOIN dbo.tlbPerson InvestigatedByPerson
                ON InvestigatedByPerson.idfPerson = hc.idfInvestigatedByPerson
            LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000011) OutbreakClassification
                ON OutbreakClassification.idfsReference = ocr.OutbreakCaseClassificationID
            LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000520) OutbreakCaseStatus
                ON OutbreakCaseStatus.idfsReference = ocr.OutbreakCaseStatusID
        WHERE OCR.OutBreakCaseReportUID = @OutbreakCaseReportUID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT = 1
            ROLLBACK;
        THROW;
    END CATCH
END
