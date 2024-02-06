--=================================================================================================
-- Name: USP_REF_DIAGNOSISREFERENCE_GETList
--
-- Description:	Returns list of diagnosis/disease references
--							
-- Author:  Philip Shaffer
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Philip Shaffer	09/25/2018 Initial Release
-- Ricky Moss		12/12/2018 Removes return codes and reference id variable
-- Ricky Moss		02/01/2019 Added Penside Test, Lab Test, Sample Type, and Syndrome fields
-- Ricky Moss		04/06/2020 Added the search parameter
-- Stephen Long     04/23/2020 Added accessory code parameter and where clause for proper
--                             filtration.
-- Lamont Mitchell	09/30/2020 Added diagnosis  to be a filter in the Or clause
-- Doug Albanese	06/07/2021 Corrected the default sort column to be intOrder
-- Doug Albanese	08/03/2021 Removed unneccesarry ording, and added a CTE expression to cover 
--                             for a second column of sorting on intOrder
-- Mark Wilson		08/26/2021 Updated to do a bitwise compare for haCode
-- Doug Albanese	12/11/2021 Corrected an "Empty" search issue that pulled all HA Codes, instead 
--                             of a particular requested one
-- Stephen Long     01/26/2023 Added disease filtration rules.
-- Leo Tracchia		04/25/2023 Added additional logic for returning only active records
--
-- Test Code:
-- exec USP_REF_DIAGNOSISREFERENCE_GETList 'en-us', NULL, NULL
-- exec USP_REF_DIAGNOSISREFERENCE_GETList 'en-us', 'Hu', NULL
-- exec USP_REF_DIAGNOSISREFERENCE_GETList 'en-us', NULL, 32
--=================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_DIAGNOSISREFERENCE_GETList]
    @LangID NVARCHAR(50),
    @search NVARCHAR(50),
    @AccessoryCode BIGINT = NULL,
    @pageNo INT = 1,
    @pageSize INT = 10,
    @sortColumn NVARCHAR(30) = 'intOrder',
    @sortOrder NVARCHAR(4) = 'ASC',
    @advancedSearch NVARCHAR(100) = NULL,
    @UserEmployeeID BIGINT
AS
BEGIN
    DECLARE @firstRec INT = (@pageNo - 1) * @pagesize,
            @lastRec INT = (@pageNo * @pageSize + 1),
            @returnMsg NVARCHAR(MAX) = 'SUCCESS',
            @returnCode BIGINT = 0;
    DECLARE @T TABLE
    (
        idfsDiagnosis bigint,
        strDefault nvarchar(2000),
        strName nvarchar(2000),
        strIDC10 nvarchar(200),
        strOIECode nvarchar(2000),
        strSampleType nvarchar(4000),
        strSampleTypeNames nvarchar(4000),
        strLabTest nvarchar(4000),
        strLabTestNames nvarchar(4000),
        strPensideTest nvarchar(4000),
        strPensideTestNames nvarchar(4000),
        strHACode nvarchar(4000),
        strHACodeNames nvarchar(4000),
        idfsUsingType bigint,
        strUsingType nvarchar(2000),
        intHACode int,
        intRowStatus int,
        blnZoonotic bit,
        blnSyndrome bit,
        intOrder int
    );
    DECLARE @FilteredResults TABLE
    (
        idfsDiagnosis bigint,
        strDefault nvarchar(2000),
        strName nvarchar(2000),
        strIDC10 nvarchar(200),
        strOIECode nvarchar(2000),
        strSampleType nvarchar(4000),
        strSampleTypeNames nvarchar(4000),
        strLabTest nvarchar(4000),
        strLabTestNames nvarchar(4000),
        strPensideTest nvarchar(4000),
        strPensideTestNames nvarchar(4000),
        strHACode nvarchar(4000),
        strHACodeNames nvarchar(4000),
        idfsUsingType bigint,
        strUsingType nvarchar(2000),
        intHACode int,
        intRowStatus int,
        blnZoonotic bit,
        blnSyndrome bit,
        intOrder int
    );

    IF @search = ''
        SET @search = NULL;

    BEGIN TRY
        IF (@advancedSearch IS NOT NULL)
        BEGIN
            INSERT INTO @T
            SELECT *
            FROM
            (
                SELECT d.idfsDiagnosis,
                       dbr.strDefault,
                       dbr.[name] AS strName,
                       d.strIDC10,
                       d.strOIECode,
                       dbo.FN_REF_SAMPLETYPETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleType,
                       dbo.FN_REF_SAMPLETYPENAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleTypeNames,
                       dbo.FN_REF_LABTESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTest,
                       dbo.FN_REF_LABTESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTestNames,
                       dbo.FN_REF_PENSIDETESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTest,
                       dbo.FN_REF_PENSIDETESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTestNames,
                       dbo.FN_GBL_HACode_ToCSV(@LangID, dbr.intHACode) AS strHACode,
                       dbo.FN_GBL_HACodeNames_ToCSV(@LangID, dbr.intHACode) AS strHACodeNames,
                       d.idfsUsingType,
                       ut.[name] AS strUsingType,
                       dbr.intHACode,
                       dbr.intRowStatus,
                       blnZoonotic,
                       d.blnSyndrome,
                       dbr.intOrder
                FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS dbr
                    INNER JOIN dbo.trtDiagnosis d
                        ON d.idfsDiagnosis = dbr.idfsReference
                    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000020) AS ut
                        ON d.idfsUsingType = ut.idfsReference
                    OUTER APPLY
                (
                    SELECT TOP 1
                        d_to_dg.idfsDiagnosisGroup,
                        dg.[name] AS strDiagnosesGroupName
                    FROM dbo.trtDiagnosisToDiagnosisGroup AS d_to_dg
                        INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000156) AS dg
                            ON d_to_dg.idfsDiagnosisGroup = dg.idfsReference
                    WHERE d_to_dg.intRowStatus = 0
                          AND d_to_dg.idfsDiagnosis = d.idfsDiagnosis
                ) AS diagnosesGroup
                WHERE (
                          dbr.intHACode IS NULL
                          OR dbr.intHACode > 0
                      )
                      AND d.intRowStatus = 0
                      AND dbr.intRowStatus = 0
            ) AS disease
            WHERE CAST(disease.idfsDiagnosis AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%'
                  OR disease.strDefault LIKE '%' + @advancedSearch + '%'
                  OR disease.strName LIKE '%' + @advancedSearch + '%'
                  OR disease.strIDC10 LIKE '%' + @advancedSearch + '%'
                  OR disease.strOIECode LIKE '%' + @advancedSearch + '%'
                  OR disease.strSampleType LIKE '%' + @advancedSearch + '%'
                  OR disease.strSampleTypeNames LIKE '%' + @advancedSearch + '%'
                  OR disease.strLabTest LIKE '%' + @advancedSearch + '%'
                  OR disease.strLabTestNames LIKE '%' + @advancedSearch + '%'
                  OR disease.strPensideTest LIKE '%' + @advancedSearch + '%'
                  OR disease.strPensideTestNames LIKE '%' + @advancedSearch + '%'
                  OR disease.strHACode LIKE '%' + @advancedSearch + '%'
                  OR disease.strHACodeNames LIKE '%' + @advancedSearch + '%'
                  OR CAST(disease.idfsUsingType AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%'
                  OR CAST(disease.intHACode AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%'
                  OR disease.strUsingType LIKE '%' + @advancedSearch + '%'
                  OR disease.idfsDiagnosis LIKE '%' + @advancedSearch + '%';

            -- =======================================================================================
            -- DISEASE FILTRATION RULES
            --
            -- Apply disease filtration rules from use case SAUC62.
            -- =======================================================================================
            -- 
            -- Apply level 0 disease filtration rules for the employee default user group - Denies ONLY
            -- as all records have been pulled above with or without disease filtration rules applied.
            --
            DELETE FROM @T
            WHERE EXISTS
            (
                SELECT idfsObjectID
                FROM dbo.tstObjectAccess oa
                    INNER JOIN dbo.tlbEmployee e
                        ON e.idfEmployee = @UserEmployeeID
                           AND e.intRowStatus = 0
                    INNER JOIN dbo.tlbEmployeeGroup eg
                        ON eg.idfsSite = e.idfsSite
                           AND eg.intRowStatus = 0
                    INNER JOIN dbo.trtBaseReference br
                        ON br.idfsBaseReference = eg.idfEmployeeGroup
                           AND br.intRowStatus = 0
                           AND br.blnSystem = 1
                WHERE oa.idfsObjectID = idfsDiagnosis
                      AND oa.intRowStatus = 0
                      AND oa.intPermission = 1 -- Deny permission
                      AND oa.idfsObjectType = 10060001 -- Disease
                      AND oa.idfActor = eg.idfEmployeeGroup
            );

            --
            -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
            -- Allows and denies will supersede level 0.
            --
            INSERT INTO @T
            SELECT disease.*
            FROM
            (
                SELECT d.idfsDiagnosis,
                       dbr.strDefault,
                       dbr.[name] AS strName,
                       d.strIDC10,
                       d.strOIECode,
                       dbo.FN_REF_SAMPLETYPETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleType,
                       dbo.FN_REF_SAMPLETYPENAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleTypeNames,
                       dbo.FN_REF_LABTESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTest,
                       dbo.FN_REF_LABTESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTestNames,
                       dbo.FN_REF_PENSIDETESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTest,
                       dbo.FN_REF_PENSIDETESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTestNames,
                       dbo.FN_GBL_HACode_ToCSV(@LangID, dbr.intHACode) AS strHACode,
                       dbo.FN_GBL_HACodeNames_ToCSV(@LangID, dbr.intHACode) AS strHACodeNames,
                       d.idfsUsingType,
                       ut.[name] AS strUsingType,
                       dbr.intHACode,
                       dbr.intRowStatus,
                       blnZoonotic,
                       d.blnSyndrome,
                       dbr.intOrder
                FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS dbr
                    INNER JOIN dbo.trtDiagnosis d
                        ON d.idfsDiagnosis = dbr.idfsReference
                    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000020) AS ut
                        ON d.idfsUsingType = ut.idfsReference
                    OUTER APPLY
                (
                    SELECT TOP 1
                        d_to_dg.idfsDiagnosisGroup,
                        dg.[name] AS strDiagnosesGroupName
                    FROM dbo.trtDiagnosisToDiagnosisGroup AS d_to_dg
                        INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000156) AS dg
                            ON d_to_dg.idfsDiagnosisGroup = dg.idfsReference
                    WHERE d_to_dg.intRowStatus = 0
                          AND d_to_dg.idfsDiagnosis = d.idfsDiagnosis
                ) AS diagnosesGroup
				WHERE d.intRowStatus = 0
                      AND dbr.intRowStatus = 0
            ) AS disease
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = disease.idfsDiagnosis
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
            WHERE oa.intPermission = 2 -- Allow permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = egm.idfEmployeeGroup
                  AND CAST(disease.idfsDiagnosis AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%'
                  OR disease.strDefault LIKE '%' + @advancedSearch + '%'
                  OR disease.strName LIKE '%' + @advancedSearch + '%'
                  OR disease.strIDC10 LIKE '%' + @advancedSearch + '%'
                  OR disease.strOIECode LIKE '%' + @advancedSearch + '%'
                  OR disease.strSampleType LIKE '%' + @advancedSearch + '%'
                  OR disease.strSampleTypeNames LIKE '%' + @advancedSearch + '%'
                  OR disease.strLabTest LIKE '%' + @advancedSearch + '%'
                  OR disease.strLabTestNames LIKE '%' + @advancedSearch + '%'
                  OR disease.strPensideTest LIKE '%' + @advancedSearch + '%'
                  OR disease.strPensideTestNames LIKE '%' + @advancedSearch + '%'
                  OR disease.strHACode LIKE '%' + @advancedSearch + '%'
                  OR disease.strHACodeNames LIKE '%' + @advancedSearch + '%'
                  OR CAST(disease.idfsUsingType AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%'
                  OR CAST(disease.intHACode AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%'
                  OR disease.strUsingType LIKE '%' + @advancedSearch + '%'
                  OR disease.idfsDiagnosis LIKE '%' + @advancedSearch + '%';

            DELETE res
            FROM @T res
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = res.idfsDiagnosis
                       AND oa.intRowStatus = 0
            WHERE oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = egm.idfEmployeeGroup;

            --
            -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
            -- will supersede level 1.
            --
            INSERT INTO @T
            SELECT disease.*
            FROM
            (
                SELECT d.idfsDiagnosis,
                       dbr.strDefault,
                       dbr.[name] AS strName,
                       d.strIDC10,
                       d.strOIECode,
                       dbo.FN_REF_SAMPLETYPETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleType,
                       dbo.FN_REF_SAMPLETYPENAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleTypeNames,
                       dbo.FN_REF_LABTESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTest,
                       dbo.FN_REF_LABTESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTestNames,
                       dbo.FN_REF_PENSIDETESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTest,
                       dbo.FN_REF_PENSIDETESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTestNames,
                       dbo.FN_GBL_HACode_ToCSV(@LangID, dbr.intHACode) AS strHACode,
                       dbo.FN_GBL_HACodeNames_ToCSV(@LangID, dbr.intHACode) AS strHACodeNames,
                       d.idfsUsingType,
                       ut.[name] AS strUsingType,
                       dbr.intHACode,
                       dbr.intRowStatus,
                       blnZoonotic,
                       d.blnSyndrome,
                       dbr.intOrder
                FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS dbr
                    INNER JOIN dbo.trtDiagnosis d
                        ON d.idfsDiagnosis = dbr.idfsReference
                    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000020) AS ut
                        ON d.idfsUsingType = ut.idfsReference
                    OUTER APPLY
                (
                    SELECT TOP 1
                        d_to_dg.idfsDiagnosisGroup,
                        dg.[name] AS strDiagnosesGroupName
                    FROM dbo.trtDiagnosisToDiagnosisGroup AS d_to_dg
                        INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000156) AS dg
                            ON d_to_dg.idfsDiagnosisGroup = dg.idfsReference
                    WHERE d_to_dg.intRowStatus = 0
                          AND d_to_dg.idfsDiagnosis = d.idfsDiagnosis
                ) AS diagnosesGroup
					WHERE d.intRowStatus = 0
                    AND dbr.intRowStatus = 0
            ) AS disease
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = disease.idfsDiagnosis
                       AND oa.intRowStatus = 0
            WHERE oa.intPermission = 2 -- Allow permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = @UserEmployeeID
                  AND CAST(disease.idfsDiagnosis AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%'
                  OR disease.strDefault LIKE '%' + @advancedSearch + '%'
                  OR disease.strName LIKE '%' + @advancedSearch + '%'
                  OR disease.strIDC10 LIKE '%' + @advancedSearch + '%'
                  OR disease.strOIECode LIKE '%' + @advancedSearch + '%'
                  OR disease.strSampleType LIKE '%' + @advancedSearch + '%'
                  OR disease.strSampleTypeNames LIKE '%' + @advancedSearch + '%'
                  OR disease.strLabTest LIKE '%' + @advancedSearch + '%'
                  OR disease.strLabTestNames LIKE '%' + @advancedSearch + '%'
                  OR disease.strPensideTest LIKE '%' + @advancedSearch + '%'
                  OR disease.strPensideTestNames LIKE '%' + @advancedSearch + '%'
                  OR disease.strHACode LIKE '%' + @advancedSearch + '%'
                  OR disease.strHACodeNames LIKE '%' + @advancedSearch + '%'
                  OR CAST(disease.idfsUsingType AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%'
                  OR CAST(disease.intHACode AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%'
                  OR disease.strUsingType LIKE '%' + @advancedSearch + '%'
                  OR disease.idfsDiagnosis LIKE '%' + @advancedSearch + '%';

            DELETE FROM @T
            WHERE EXISTS
            (
                SELECT idfsObjectID
                FROM dbo.tstObjectAccess oa
                WHERE oa.idfsObjectID = idfsDiagnosis
                      AND oa.intRowStatus = 0
                      AND oa.intPermission = 1 -- Deny permission
                      AND oa.idfsObjectType = 10060001 -- Disease
                      AND oa.idfActor = @UserEmployeeID
            );
        END
        ELSE IF (@search IS NOT NULL)
        BEGIN
            INSERT INTO @T
            SELECT *
            FROM
            (
                SELECT d.idfsDiagnosis,
                       dbr.strDefault,
                       dbr.[name] AS strName,
                       d.strIDC10,
                       d.strOIECode,
                       dbo.FN_REF_SAMPLETYPETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleType,
                       dbo.FN_REF_SAMPLETYPENAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleTypeNames,
                       dbo.FN_REF_LABTESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTest,
                       dbo.FN_REF_LABTESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTestNames,
                       dbo.FN_REF_PENSIDETESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTest,
                       dbo.FN_REF_PENSIDETESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTestNames,
                       dbo.FN_GBL_HACode_ToCSV(@LangID, dbr.intHACode) AS strHACode,
                       dbo.FN_GBL_HACodeNames_ToCSV(@LangID, dbr.intHACode) AS strHACodeNames,
                       d.idfsUsingType,
                       ut.[name] AS strUsingType,
                       dbr.intHACode,
                       dbr.intRowStatus,
                       blnZoonotic,
                       d.blnSyndrome,
                       dbr.intOrder
                FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS dbr
                    INNER JOIN dbo.trtDiagnosis d
                        ON d.idfsDiagnosis = dbr.idfsReference
                    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000020) AS ut
                        ON d.idfsUsingType = ut.idfsReference
                    OUTER APPLY
                (
                    SELECT TOP 1
                        d_to_dg.idfsDiagnosisGroup,
                        dg.[name] AS strDiagnosesGroupName
                    FROM dbo.trtDiagnosisToDiagnosisGroup AS d_to_dg
                        INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000156) AS dg
                            ON d_to_dg.idfsDiagnosisGroup = dg.idfsReference
                    WHERE d_to_dg.intRowStatus = 0
                          AND d_to_dg.idfsDiagnosis = d.idfsDiagnosis
                ) AS diagnosesGroup
                WHERE (
                          dbr.intHACode IS NULL
                          OR dbr.intHACode > 0
                      )
                      AND d.intRowStatus = 0
                      AND dbr.intRowStatus = 0
            ) AS disease
            WHERE disease.strDefault LIKE '%' + @search + '%'
                  OR disease.strName LIKE '%' + @search + '%'
                  OR disease.strIDC10 LIKE '%' + @search + '%'
                  OR disease.strOIECode LIKE '%' + @search + '%'
                  OR disease.strHACodeNames LIKE '%' + @search + '%'
                  OR disease.strLabTestNames LIKE '%' + @search + '%'
                  OR disease.strPensideTestNames LIKE '%' + @search + '%'
                  OR disease.strSampleTypeNames LIKE '%' + @search + '%'
                  OR disease.strUsingType LIKE '%' + @search + '%'
                  OR disease.idfsDiagnosis LIKE '%' + @search + '%';

            -- =======================================================================================
            -- DISEASE FILTRATION RULES
            --
            -- Apply disease filtration rules from use case SAUC62.
            -- =======================================================================================
            -- 
            -- Apply level 0 disease filtration rules for the employee default user group - Denies ONLY
            -- as all records have been pulled above with or without disease filtration rules applied.
            --
            DELETE FROM @T
            WHERE EXISTS
            (
                SELECT idfsObjectID
                FROM dbo.tstObjectAccess oa
                    INNER JOIN dbo.tlbEmployee e
                        ON e.idfEmployee = @UserEmployeeID
                           AND e.intRowStatus = 0
                    INNER JOIN dbo.tlbEmployeeGroup eg
                        ON eg.idfsSite = e.idfsSite
                           AND eg.intRowStatus = 0
                    INNER JOIN dbo.trtBaseReference br
                        ON br.idfsBaseReference = eg.idfEmployeeGroup
                           AND br.intRowStatus = 0
                           AND br.blnSystem = 1
                WHERE oa.idfsObjectID = idfsDiagnosis
                      AND oa.intRowStatus = 0
                      AND oa.intPermission = 1 -- Deny permission
                      AND oa.idfsObjectType = 10060001 -- Disease
                      AND oa.idfActor = eg.idfEmployeeGroup
            );

            --
            -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
            -- Allows and denies will supersede level 0.
            --
            INSERT INTO @T
            SELECT disease.*
            FROM
            (
                SELECT d.idfsDiagnosis,
                       dbr.strDefault,
                       dbr.[name] AS strName,
                       d.strIDC10,
                       d.strOIECode,
                       dbo.FN_REF_SAMPLETYPETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleType,
                       dbo.FN_REF_SAMPLETYPENAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleTypeNames,
                       dbo.FN_REF_LABTESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTest,
                       dbo.FN_REF_LABTESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTestNames,
                       dbo.FN_REF_PENSIDETESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTest,
                       dbo.FN_REF_PENSIDETESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTestNames,
                       dbo.FN_GBL_HACode_ToCSV(@LangID, dbr.intHACode) AS strHACode,
                       dbo.FN_GBL_HACodeNames_ToCSV(@LangID, dbr.intHACode) AS strHACodeNames,
                       d.idfsUsingType,
                       ut.[name] AS strUsingType,
                       dbr.intHACode,
                       dbr.intRowStatus,
                       blnZoonotic,
                       d.blnSyndrome,
                       dbr.intOrder
                FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS dbr
                    INNER JOIN dbo.trtDiagnosis d
                        ON d.idfsDiagnosis = dbr.idfsReference
                    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000020) AS ut
                        ON d.idfsUsingType = ut.idfsReference
                    OUTER APPLY
                (
                    SELECT TOP 1
                        d_to_dg.idfsDiagnosisGroup,
                        dg.[name] AS strDiagnosesGroupName
                    FROM dbo.trtDiagnosisToDiagnosisGroup AS d_to_dg
                        INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000156) AS dg
                            ON d_to_dg.idfsDiagnosisGroup = dg.idfsReference
                    WHERE d_to_dg.intRowStatus = 0
                          AND d_to_dg.idfsDiagnosis = d.idfsDiagnosis
                ) AS diagnosesGroup
				WHERE d.intRowStatus = 0
                      AND dbr.intRowStatus = 0
            ) AS disease
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = disease.idfsDiagnosis
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
            WHERE oa.intPermission = 2 -- Allow permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = egm.idfEmployeeGroup
                  AND disease.strDefault LIKE '%' + @search + '%'
                  OR disease.strName LIKE '%' + @search + '%'
                  OR disease.strIDC10 LIKE '%' + @search + '%'
                  OR disease.strOIECode LIKE '%' + @search + '%'
                  OR disease.strHACodeNames LIKE '%' + @search + '%'
                  OR disease.strLabTestNames LIKE '%' + @search + '%'
                  OR disease.strPensideTestNames LIKE '%' + @search + '%'
                  OR disease.strSampleTypeNames LIKE '%' + @search + '%'
                  OR disease.strUsingType LIKE '%' + @search + '%'
                  OR disease.idfsDiagnosis LIKE '%' + @search + '%';

            DELETE res
            FROM @T res
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = res.idfsDiagnosis
                       AND oa.intRowStatus = 0
            WHERE oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = egm.idfEmployeeGroup;

            --
            -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
            -- will supersede level 1.
            --
            INSERT INTO @T
            SELECT disease.*
            FROM
            (
                SELECT d.idfsDiagnosis,
                       dbr.strDefault,
                       dbr.[name] AS strName,
                       d.strIDC10,
                       d.strOIECode,
                       dbo.FN_REF_SAMPLETYPETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleType,
                       dbo.FN_REF_SAMPLETYPENAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleTypeNames,
                       dbo.FN_REF_LABTESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTest,
                       dbo.FN_REF_LABTESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTestNames,
                       dbo.FN_REF_PENSIDETESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTest,
                       dbo.FN_REF_PENSIDETESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTestNames,
                       dbo.FN_GBL_HACode_ToCSV(@LangID, dbr.intHACode) AS strHACode,
                       dbo.FN_GBL_HACodeNames_ToCSV(@LangID, dbr.intHACode) AS strHACodeNames,
                       d.idfsUsingType,
                       ut.[name] AS strUsingType,
                       dbr.intHACode,
                       dbr.intRowStatus,
                       blnZoonotic,
                       d.blnSyndrome,
                       dbr.intOrder
                FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS dbr
                    INNER JOIN dbo.trtDiagnosis d
                        ON d.idfsDiagnosis = dbr.idfsReference
                    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000020) AS ut
                        ON d.idfsUsingType = ut.idfsReference
                    OUTER APPLY
                (
                    SELECT TOP 1
                        d_to_dg.idfsDiagnosisGroup,
                        dg.[name] AS strDiagnosesGroupName
                    FROM dbo.trtDiagnosisToDiagnosisGroup AS d_to_dg
                        INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000156) AS dg
                            ON d_to_dg.idfsDiagnosisGroup = dg.idfsReference
                    WHERE d_to_dg.intRowStatus = 0
                          AND d_to_dg.idfsDiagnosis = d.idfsDiagnosis
                ) AS diagnosesGroup
					WHERE d.intRowStatus = 0
                    AND dbr.intRowStatus = 0
            ) AS disease
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = disease.idfsDiagnosis
                       AND oa.intRowStatus = 0
            WHERE oa.intPermission = 2 -- Allow permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = @UserEmployeeID
                  AND disease.strDefault LIKE '%' + @search + '%'
                  OR disease.strName LIKE '%' + @search + '%'
                  OR disease.strIDC10 LIKE '%' + @search + '%'
                  OR disease.strOIECode LIKE '%' + @search + '%'
                  OR disease.strHACodeNames LIKE '%' + @search + '%'
                  OR disease.strLabTestNames LIKE '%' + @search + '%'
                  OR disease.strPensideTestNames LIKE '%' + @search + '%'
                  OR disease.strSampleTypeNames LIKE '%' + @search + '%'
                  OR disease.strUsingType LIKE '%' + @search + '%'
                  OR disease.idfsDiagnosis LIKE '%' + @search + '%';

            DELETE FROM @T
            WHERE EXISTS
            (
                SELECT idfsObjectID
                FROM dbo.tstObjectAccess oa
                WHERE oa.idfsObjectID = idfsDiagnosis
                      AND oa.intRowStatus = 0
                      AND oa.intPermission = 1 -- Deny permission
                      AND oa.idfsObjectType = 10060001 -- Disease
                      AND oa.idfActor = @UserEmployeeID
            );
        END
        ELSE
        BEGIN
            INSERT INTO @T
            SELECT d.idfsDiagnosis,
                   dbr.strDefault,
                   dbr.[name] AS strName,
                   d.strIDC10,
                   d.strOIECode,
                   dbo.FN_REF_SAMPLETYPETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleType,
                   dbo.FN_REF_SAMPLETYPENAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleTypeNames,
                   dbo.FN_REF_LABTESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTest,
                   dbo.FN_REF_LABTESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTestNames,
                   dbo.FN_REF_PENSIDETESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTest,
                   dbo.FN_REF_PENSIDETESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTestNames,
                   dbo.FN_GBL_HACode_ToCSV(@LangID, dbr.intHACode) AS strHACode,
                   dbo.FN_GBL_HACodeNames_ToCSV(@LangID, dbr.intHACode) AS strHACodeNames,
                   d.idfsUsingType,
                   ut.[name] AS strUsingType,
                   dbr.intHACode,
                   dbr.intRowStatus,
                   blnZoonotic,
                   d.blnSyndrome,
                   dbr.intOrder
            FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS dbr
                INNER JOIN dbo.trtDiagnosis d
                    ON d.idfsDiagnosis = dbr.idfsReference
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000020) AS ut
                    ON d.idfsUsingType = ut.idfsReference
                OUTER APPLY
            (
                SELECT TOP 1
                    d_to_dg.idfsDiagnosisGroup,
                    dg.[name] AS strDiagnosesGroupName
                FROM dbo.trtDiagnosisToDiagnosisGroup AS d_to_dg
                    INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000156) AS dg
                        ON d_to_dg.idfsDiagnosisGroup = dg.idfsReference
                WHERE d_to_dg.intRowStatus = 0
                      AND d_to_dg.idfsDiagnosis = d.idfsDiagnosis
            ) AS diagnosesGroup
            WHERE (
                      dbr.intHACode IS NULL
                      OR dbr.intHACode > 0
                  )
                  AND d.intRowStatus = 0
                  AND dbr.intRowStatus = 0
                  AND (
                          ((@AccessoryCode & dbr.intHACode) > 0)
                          OR (@AccessoryCode IS NULL)
                      );

            -- =======================================================================================
            -- DISEASE FILTRATION RULES
            --
            -- Apply disease filtration rules from use case SAUC62.
            -- =======================================================================================
            -- 
            -- Apply level 0 disease filtration rules for the employee default user group - Denies ONLY
            -- as all records have been pulled above with or without disease filtration rules applied.
            --
            DELETE FROM @T
            WHERE EXISTS
            (
                SELECT idfsObjectID
                FROM dbo.tstObjectAccess oa
                    INNER JOIN dbo.tlbEmployee e
                        ON e.idfEmployee = @UserEmployeeID
                           AND e.intRowStatus = 0
                    INNER JOIN dbo.tlbEmployeeGroup eg
                        ON eg.idfsSite = e.idfsSite
                           AND eg.intRowStatus = 0
                    INNER JOIN dbo.trtBaseReference br
                        ON br.idfsBaseReference = eg.idfEmployeeGroup
                           AND br.intRowStatus = 0
                           AND br.blnSystem = 1
                WHERE oa.idfsObjectID = idfsDiagnosis
                      AND oa.intRowStatus = 0
                      AND oa.intPermission = 1 -- Deny permission
                      AND oa.idfsObjectType = 10060001 -- Disease
                      AND oa.idfActor = eg.idfEmployeeGroup
            );

            --
            -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
            -- Allows and denies will supersede level 0.
            --
            INSERT INTO @T
            SELECT d.idfsDiagnosis,
                   dbr.strDefault,
                   dbr.[name] AS strName,
                   d.strIDC10,
                   d.strOIECode,
                   dbo.FN_REF_SAMPLETYPETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleType,
                   dbo.FN_REF_SAMPLETYPENAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleTypeNames,
                   dbo.FN_REF_LABTESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTest,
                   dbo.FN_REF_LABTESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTestNames,
                   dbo.FN_REF_PENSIDETESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTest,
                   dbo.FN_REF_PENSIDETESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTestNames,
                   dbo.FN_GBL_HACode_ToCSV(@LangID, dbr.intHACode) AS strHACode,
                   dbo.FN_GBL_HACodeNames_ToCSV(@LangID, dbr.intHACode) AS strHACodeNames,
                   d.idfsUsingType,
                   ut.[name] AS strUsingType,
                   dbr.intHACode,
                   dbr.intRowStatus,
                   blnZoonotic,
                   d.blnSyndrome,
                   dbr.intOrder
            FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS dbr
                INNER JOIN dbo.trtDiagnosis d
                    ON d.idfsDiagnosis = dbr.idfsReference
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000020) AS ut
                    ON d.idfsUsingType = ut.idfsReference
                OUTER APPLY
            (
                SELECT TOP 1
                    d_to_dg.idfsDiagnosisGroup,
                    dg.[name] AS strDiagnosesGroupName
                FROM dbo.trtDiagnosisToDiagnosisGroup AS d_to_dg
                    INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000156) AS dg
                        ON d_to_dg.idfsDiagnosisGroup = dg.idfsReference
                WHERE d_to_dg.intRowStatus = 0
                      AND d_to_dg.idfsDiagnosis = d.idfsDiagnosis
            ) AS diagnosesGroup
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = dbr.idfsReference
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
            WHERE oa.intPermission = 2 -- Allow permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = egm.idfEmployeeGroup
                  AND (
                          dbr.intHACode IS NULL
                          OR dbr.intHACode > 0
                      )
                  AND d.intRowStatus = 0
                  AND dbr.intRowStatus = 0
                  AND (
                          ((@AccessoryCode & dbr.intHACode) > 0)
                          OR (@AccessoryCode IS NULL)
                      );

            DELETE res
            FROM @T res
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = res.idfsDiagnosis
                       AND oa.intRowStatus = 0
            WHERE oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = egm.idfEmployeeGroup;

            --
            -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
            -- will supersede level 1.
            --
            INSERT INTO @T
            SELECT d.idfsDiagnosis,
                   dbr.strDefault,
                   dbr.[name] AS strName,
                   d.strIDC10,
                   d.strOIECode,
                   dbo.FN_REF_SAMPLETYPETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleType,
                   dbo.FN_REF_SAMPLETYPENAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleTypeNames,
                   dbo.FN_REF_LABTESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTest,
                   dbo.FN_REF_LABTESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTestNames,
                   dbo.FN_REF_PENSIDETESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTest,
                   dbo.FN_REF_PENSIDETESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTestNames,
                   dbo.FN_GBL_HACode_ToCSV(@LangID, dbr.intHACode) AS strHACode,
                   dbo.FN_GBL_HACodeNames_ToCSV(@LangID, dbr.intHACode) AS strHACodeNames,
                   d.idfsUsingType,
                   ut.[name] AS strUsingType,
                   dbr.intHACode,
                   dbr.intRowStatus,
                   blnZoonotic,
                   d.blnSyndrome,
                   dbr.intOrder
            FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS dbr
                INNER JOIN dbo.trtDiagnosis d
                    ON d.idfsDiagnosis = dbr.idfsReference
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000020) AS ut
                    ON d.idfsUsingType = ut.idfsReference
                OUTER APPLY
            (
                SELECT TOP 1
                    d_to_dg.idfsDiagnosisGroup,
                    dg.[name] AS strDiagnosesGroupName
                FROM dbo.trtDiagnosisToDiagnosisGroup AS d_to_dg
                    INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000156) AS dg
                        ON d_to_dg.idfsDiagnosisGroup = dg.idfsReference
                WHERE d_to_dg.intRowStatus = 0
                      AND d_to_dg.idfsDiagnosis = d.idfsDiagnosis
            ) AS diagnosesGroup
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = dbr.idfsReference
                       AND oa.intRowStatus = 0
            WHERE oa.intPermission = 2 -- Allow permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = @UserEmployeeID
                  AND (
                          dbr.intHACode IS NULL
                          OR dbr.intHACode > 0
                      )
                  AND d.intRowStatus = 0
                  AND dbr.intRowStatus = 0
                  AND (
                          ((@AccessoryCode & dbr.intHACode) > 0)
                          OR (@AccessoryCode IS NULL)
                      );

            DELETE FROM @T
            WHERE EXISTS
            (
                SELECT idfsObjectID
                FROM dbo.tstObjectAccess oa
                WHERE oa.idfsObjectID = idfsDiagnosis
                      AND oa.intRowStatus = 0
                      AND oa.intPermission = 1 -- Deny permission
                      AND oa.idfsObjectType = 10060001 -- Disease
                      AND oa.idfActor = @UserEmployeeID
            );
        END;

        INSERT INTO @FilteredResults
        SELECT *
        FROM @T
        GROUP BY idfsDiagnosis,
                 strDefault,
                 strName,
                 strIDC10,
                 strOIECode,
                 strSampleType,
                 strSampleTypeNames,
                 strLabTest,
                 strLabTestNames,
                 strPensideTest,
                 strPensideTestNames,
                 strHACode,
                 strHACodeNames,
                 idfsUsingType,
                 strUsingType,
                 intHACode,
                 intRowStatus,
                 blnZoonotic,
                 blnSyndrome,
                 intOrder;

        WITH CTEResults
        AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @sortColumn = 'idfsDiagnosis'
                                                        AND @SortOrder = 'asc' THEN
                                                       idfsDiagnosis
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'idfsDiagnosis'
                                                        AND @SortOrder = 'desc' THEN
                                                       idfsDiagnosis
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strdefault'
                                                        AND @SortOrder = 'asc' THEN
                                                       strdefault
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strdefault'
                                                        AND @SortOrder = 'desc' THEN
                                                       strdefault
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strName'
                                                        AND @SortOrder = 'asc' THEN
                                                       strName
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strName'
                                                        AND @SortOrder = 'desc' THEN
                                                       strName
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strIDC10'
                                                        AND @SortOrder = 'asc' THEN
                                                       strIDC10
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strIDC10'
                                                        AND @SortOrder = 'desc' THEN
                                                       strIDC10
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strOIECode'
                                                        AND @SortOrder = 'asc' THEN
                                                       strOIECode
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strOIECode'
                                                        AND @SortOrder = 'desc' THEN
                                                       strOIECode
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strSampleType'
                                                        AND @SortOrder = 'asc' THEN
                                                       strSampleType
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strSampleType'
                                                        AND @SortOrder = 'desc' THEN
                                                       strSampleType
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strSampleTypeNames'
                                                        AND @SortOrder = 'asc' THEN
                                                       strSampleTypeNames
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strSampleTypeNames'
                                                        AND @SortOrder = 'desc' THEN
                                                       strSampleTypeNames
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strLabTest'
                                                        AND @SortOrder = 'asc' THEN
                                                       strLabTest
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strLabTest'
                                                        AND @SortOrder = 'desc' THEN
                                                       strLabTest
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strLabTestNames'
                                                        AND @SortOrder = 'asc' THEN
                                                       strLabTestNames
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strLabTestNames'
                                                        AND @SortOrder = 'desc' THEN
                                                       strLabTestNames
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strPensideTest'
                                                        AND @SortOrder = 'asc' THEN
                                                       strPensideTest
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strPensideTest'
                                                        AND @SortOrder = 'desc' THEN
                                                       strPensideTest
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strPensideTestNames'
                                                        AND @SortOrder = 'asc' THEN
                                                       strPensideTestNames
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strPensideTestNames'
                                                        AND @SortOrder = 'desc' THEN
                                                       strPensideTestNames
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strHACode'
                                                        AND @SortOrder = 'asc' THEN
                                                       strHACode
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strHACode'
                                                        AND @SortOrder = 'desc' THEN
                                                       strHACode
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strHACodeNames'
                                                        AND @SortOrder = 'asc' THEN
                                                       strHACodeNames
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strHACodeNames'
                                                        AND @SortOrder = 'desc' THEN
                                                       strHACodeNames
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'idfsUsingType'
                                                        AND @SortOrder = 'asc' THEN
                                                       idfsUsingType
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'idfsUsingType'
                                                        AND @SortOrder = 'desc' THEN
                                                       idfsUsingType
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strUsingType'
                                                        AND @SortOrder = 'asc' THEN
                                                       strUsingType
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strUsingType'
                                                        AND @SortOrder = 'desc' THEN
                                                       strUsingType
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'intHACode'
                                                        AND @SortOrder = 'asc' THEN
                                                       intHACode
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'intHACode'
                                                        AND @SortOrder = 'desc' THEN
                                                       intHACode
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'intRowStatus'
                                                        AND @SortOrder = 'asc' THEN
                                                       intRowStatus
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'intRowStatus'
                                                        AND @SortOrder = 'desc' THEN
                                                       intRowStatus
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'blnZoonotic'
                                                        AND @SortOrder = 'asc' THEN
                                                       blnZoonotic
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'blnZoonotic'
                                                        AND @SortOrder = 'desc' THEN
                                                       blnZoonotic
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'blnSyndrome'
                                                        AND @SortOrder = 'asc' THEN
                                                       blnSyndrome
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'blnSyndrome'
                                                        AND @SortOrder = 'desc' THEN
                                                       blnSyndrome
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'intOrder'
                                                        AND @SortOrder = 'asc' THEN
                                                       intOrder
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'intOrder'
                                                        AND @SortOrder = 'desc' THEN
                                                       intOrder
                                               END DESC,
                                               IIF(@sortColumn = 'intOrder', strName, NULL) ASC
                                     ) AS ROWNUM,
                   COUNT(*) OVER () AS TotalRowCount,
                   idfsDiagnosis,
                   strDefault,
                   strName,
                   strIDC10,
                   strOIECode,
                   strSampleType,
                   strSampleTypeNames,
                   strLabTest,
                   strLabTestNames,
                   strPensideTest,
                   strPensideTestNames,
                   strHACode,
                   strHACodeNames,
                   idfsUsingType,
                   strUsingType,
                   intHACode,
                   intRowStatus,
                   blnZoonotic,
                   blnSyndrome,
                   intOrder
            FROM @FilteredResults
           )
        SELECT TotalRowCount,
               idfsDiagnosis,
               strDefault,
               strName,
               strIDC10,
               strOIECode,
               strSampleType,
               strSampleTypeNames,
               strLabTest,
               strLabTestNames,
               strPensideTest,
               strPensideTestNames,
               strHACode,
               strHACodeNames,
               idfsUsingType,
               strUsingType,
               intHACode,
               intRowStatus,
               blnZoonotic,
               blnSyndrome,
               intOrder,
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
