--=====================================================================================================
-- Name: USP_CONF_CUSTOMREPORT_GETLIST
-- Description:	Returns list of custom disease reports
--							
-- Author:		Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss		03/21/2018 Initial Release
-- Ann Xiong        04/26/2021 Added paging and idfsUsingType to the return list
-- Mandar Kulkarni  08/02/2021 Fixed the issue of Custom Report Row sorting records by "Name" is not 
--                             working
-- Mike Kornegay	08/17/2021 Added intRowOrder to stored proc to implement sort by specific order
-- Stephen Long     04/13/2023 Added dbo prefix.
--
-- Test Code:
-- exec USP_CONF_CUSTOMREPORT_GETLIST 'en', 55540680000323 
-- exec USP_CONF_CUSTOMREPORT_GETLIST 'en', 55540680000324
--=====================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_CUSTOMREPORT_GETLIST]
(
    @langId NVARCHAR(10),
    @idfsCustomReportType BIGINT,
    @pageNo INT = 1,
    @pageSize INT = 10,
    @sortColumn NVARCHAR(50) = 'intRowOrder',
    @sortOrder NVARCHAR(4) = 'asc'
)
AS
BEGIN
    BEGIN TRY
        DECLARE @firstRec INT = (@pageNo - 1) * @pagesize,
                @lastRec INT = (@pageNo * @pageSize + 1);
        DECLARE @t TABLE
        (
            idfReportRows BIGINT,
            idfsCustomReportType BIGINT,
            strCustomReportType NVARCHAR(2000),
            idfsDiagnosisOrDiagnosisGroup BIGINT,
            strDiagnosisOrDiagnosisGroupName NVARCHAR(2000),
            strDiseaseOrReportDiseaseGroup NVARCHAR(2000),
            idfsUsingType BIGINT,
            strUsingType NVARCHAR(2000),
            idfsReportAdditionalText BIGINT,
            strAdditionalReportText NVARCHAR(2000),
            idfsICDReportAdditionalText BIGINT,
            strICDReportAdditionalText NVARCHAR(2000),
            intRowOrder INT
        );

        INSERT INTO @T
        SELECT rr.idfReportRows,
               rr.idfsCustomReportType,
               crtbr.name as strCustomReportType,
               d.idfsDiagnosisOrDiagnosisGroup,
               d.strDiagnosisOrDiagnosisGroupName AS strDiagnosisOrDiagnosisGroupName,
               d.strDiseaseOrReportDiseaseGroup AS strDiseaseOrReportDiseaseGroup,
               d.idfsUsingType,
               d.strUsingType,
               rr.idfsReportAdditionalText,
               artbr.name AS strAdditionalReportText,
               rr.idfsICDReportAdditionalText,
               icdbr.name as strICDReportAdditionalText,
               rr.intRowOrder
        FROM dbo.trtReportRows rr
            INNER JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000129) crtbr
                ON rr.idfsCustomReportType = crtbr.idfsReference
            INNER JOIN
            (
                SELECT dbr.idfsReference AS idfsDiagnosisOrDiagnosisGroup,
                       dbr.name AS strDiagnosisOrDiagnosisGroupName,
                       rtbr.name AS strDiseaseOrReportDiseaseGroup,
                       d.idfsUsingType,
                       utbr.name AS strUsingType
                FROM dbo.trtDiagnosis d
                    JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000019) dbr
                        ON d.idfsDiagnosis = dbr.idfsReference
                    JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000076) rtbr
                        ON dbr.idfsReferenceType = rtbr.idfsReference
                    JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000020) utbr
                        ON d.idfsUsingType = utbr.idfsReference
                UNION
                SELECT rdgbr.idfsReference AS idfsDiagnosisOrDiagnosisGroup,
                       rdgbr.name AS strDiagnosisOrDiagnosisGroupName,
                       rtbr.name AS strDiseaseOrReportDiseaseGroup,
                       null AS idfsUsingType,
                       null AS strUsingType
                FROM dbo.FN_GBL_Reference_GETList(@langId, 19000130) rdgbr
                    JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000076) rtbr
                        ON rdgbr.idfsReferenceType = rtbr.idfsReference
            ) d
                ON d.idfsDiagnosisOrDiagnosisGroup = rr.idfsDiagnosisOrReportDiagnosisGroup
            LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000132) artbr
                ON rr.idfsReportAdditionalText = artbr.idfsReference
            LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000132) icdbr
                ON rr.idfsICDReportAdditionalText = icdbr.idfsReference
        WHERE rr.intRowStatus = 0
              AND rr.idfsCustomReportType = @idfsCustomReportType;
        WITH CTEResults
        AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @sortColumn = 'idfReportRows'
                                                        AND @SortOrder = 'asc' THEN
                                                       idfReportRows
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'idfReportRows'
                                                        AND @SortOrder = 'desc' THEN
                                                       idfsCustomReportType
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'idfsCustomReportType'
                                                        AND @SortOrder = 'asc' THEN
                                                       idfsCustomReportType
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'idfsCustomReportType'
                                                        AND @SortOrder = 'desc' THEN
                                                       idfsCustomReportType
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strCustomReportType'
                                                        AND @SortOrder = 'asc' THEN
                                                       strCustomReportType
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strCustomReportType'
                                                        AND @SortOrder = 'desc' THEN
                                                       strCustomReportType
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'idfsDiagnosisOrDiagnosisGroup'
                                                        AND @SortOrder = 'asc' THEN
                                                       idfsDiagnosisOrDiagnosisGroup
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'idfsDiagnosisOrDiagnosisGroup'
                                                        AND @SortOrder = 'desc' THEN
                                                       idfsDiagnosisOrDiagnosisGroup
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strDiagnosisOrDiagnosisGroupName'
                                                        AND @SortOrder = 'asc' THEN
                                                       strDiagnosisOrDiagnosisGroupName
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strDiagnosisOrDiagnosisGroupName'
                                                        AND @SortOrder = 'desc' THEN
                                                       strDiagnosisOrDiagnosisGroupName
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strDiseaseOrReportDiseaseGroup'
                                                        AND @SortOrder = 'asc' THEN
                                                       strDiseaseOrReportDiseaseGroup
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strDiseaseOrReportDiseaseGroup'
                                                        AND @SortOrder = 'desc' THEN
                                                       strDiseaseOrReportDiseaseGroup
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
                                                   WHEN @sortColumn = 'idfsReportAdditionalText'
                                                        AND @SortOrder = 'asc' THEN
                                                       idfsReportAdditionalText
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'idfsReportAdditionalText'
                                                        AND @SortOrder = 'desc' THEN
                                                       idfsReportAdditionalText
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strAdditionalReportText'
                                                        AND @SortOrder = 'asc' THEN
                                                       strAdditionalReportText
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strAdditionalReportText'
                                                        AND @SortOrder = 'desc' THEN
                                                       strAdditionalReportText
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'idfsICDReportAdditionalText'
                                                        AND @SortOrder = 'asc' THEN
                                                       idfsICDReportAdditionalText
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'idfsICDReportAdditionalText'
                                                        AND @SortOrder = 'desc' THEN
                                                       idfsICDReportAdditionalText
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strICDReportAdditionalText'
                                                        AND @SortOrder = 'asc' THEN
                                                       strICDReportAdditionalText
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strICDReportAdditionalText'
                                                        AND @SortOrder = 'desc' THEN
                                                       strICDReportAdditionalText
                                               END DESC,
                                               intRowOrder ASC
                                     ) AS ROWNUM,
                   COUNT(*) OVER () AS TotalRowCount,
                   idfReportRows,
                   idfsCustomReportType,
                   strCustomReportType,
                   idfsDiagnosisOrDiagnosisGroup,
                   strDiagnosisOrDiagnosisGroupName,
                   strDiseaseOrReportDiseaseGroup,
                   idfsUsingType,
                   strUsingType,
                   idfsReportAdditionalText,
                   strAdditionalReportText,
                   idfsICDReportAdditionalText,
                   strICDReportAdditionalText,
                   intRowOrder
            FROM @T
           )
        SELECT TotalRowCount,
               idfReportRows,
               idfsCustomReportType,
               strCustomReportType,
               idfsDiagnosisOrDiagnosisGroup,
               strDiagnosisOrDiagnosisGroupName,
               strDiseaseOrReportDiseaseGroup,
               idfsUsingType,
               strUsingType,
               idfsReportAdditionalText,
               strAdditionalReportText,
               idfsICDReportAdditionalText,
               strICDReportAdditionalText,
               intRowOrder,
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