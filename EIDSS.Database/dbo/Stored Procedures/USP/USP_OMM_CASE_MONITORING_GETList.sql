-- ================================================================================================
-- Name: USP_OMM_CASE_MONITORING_GETList
--
-- Description:	Get case monitoring list for human and veterinary outbreak case enter and edit 
-- use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     02/21/2022 Initial release.
-- Stephen Long     06/02/2022 Corrected spelling on investigated by person ID.
-- Stephen Long     06/22/2022 Added observation identifier to the model.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_OMM_CASE_MONITORING_GETList]
(
    @LanguageId NVARCHAR(50),
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(30) = 'MonitoringDate',
    @SortOrder NVARCHAR(4) = 'DESC',
    @CaseId BIGINT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @FirstRec INT = (@PageNumber - 1) * @PageSize,
                @LastRec INT = (@PageNumber * @PageSize + 1),
                @TotalRowCount INT = (
                                         SELECT COUNT(*)
                                         FROM dbo.tlbOutbreakCaseMonitoring cm
                                         WHERE cm.intRowStatus = 0
                                               AND (
                                                       cm.idfHumanCase = @CaseId
                                                       OR cm.idfVetCase = @CaseId
                                                   )
                                     );

        SELECT CaseMonitoringId,
               HumanCaseId,
               VeterinaryCaseId,
               InvestigatedByOrganizationId,
               InvestigatedByOrganizationName,
               InvestigatedByPersonId,
               InvestigatedByPersonName,
               MonitoringDate,
               ObservationId, 
               AdditionalComments,
               RowAction,
               [RowCount],
               TotalRowCount,
               CurrentPage,
               TotalPages
        FROM
        (
            SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @SortColumn = 'InvestigatedByOrganizationName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       o.AbbreviatedName
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'InvestigatedByOrganizationName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       o.AbbreviatedName
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'InvestigatedByPersonName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       ISNULL(p.strFamilyName, N'')
                                                       + ISNULL(', ' + p.strFirstName, N'')
                                                       + ISNULL(' ' + p.strSecondName, N'')
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'InvestigatedByPersonName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       ISNULL(p.strFamilyName, N'')
                                                       + ISNULL(', ' + p.strFirstName, N'')
                                                       + ISNULL(' ' + p.strSecondName, N'')
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'MonitoringDate'
                                                        AND @SortOrder = 'ASC' THEN
                                                       cm.datMonitoringDate
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'MonitoringDate'
                                                        AND @SortOrder = 'DESC' THEN
                                                       cm.datMonitoringDate
                                               END DESC
                                     ) AS RowNum,
                   cm.idfOutbreakCaseMonitoring AS CaseMonitoringId,
                   cm.idfHumanCase AS HumanCaseId,
                   cm.idfVetCase AS VeterinaryCaseId,
                   cm.idfInvestigatedByOffice AS InvestigatedByOrganizationId,
                   o.AbbreviatedName AS InvestigatedByOrganizationName,
                   cm.idfInvestigatedByPerson AS InvestigatedByPersonId,
                   ISNULL(p.strFamilyName, N'') + ISNULL(', ' + p.strFirstName, N'')
                   + ISNULL(' ' + p.strSecondName, N'') AS InvestigatedByPersonName,
                   cm.datMonitoringDate AS MonitoringDate,
                   cm.idfObservation AS ObservationId,
                   cm.strAdditionalComments AS AdditionalComments,
                   0 AS RowAction,
                   COUNT(*) OVER () AS [RowCount],
                   @TotalRowCount AS TotalRowCount,
                   CurrentPage = @PageNumber,
                   TotalPages = (@TotalRowCount / @PageSize) + IIF(COUNT(*) % @PageSize > 0, 1, 0)
            FROM dbo.tlbOutbreakCaseMonitoring cm
                LEFT JOIN dbo.FN_GBL_Institution_Min(@LanguageId) o
                    ON o.idfOffice = cm.idfInvestigatedByOffice
                LEFT JOIN dbo.tlbPerson p
                    ON p.idfPerson = cm.idfInvestigatedByPerson
                       AND p.intRowStatus = 0
            WHERE cm.intRowStatus = 0
                  AND (
                          cm.idfHumanCase = @CaseId
                          OR cm.idfVetCase = @CaseId
                      )
            GROUP BY cm.idfOutbreakCaseMonitoring,
                     cm.idfHumanCase,
                     cm.idfVetCase,
                     cm.idfInvestigatedByOffice,
                     o.AbbreviatedName,
                     cm.idfInvestigatedByPerson,
                     p.strFamilyName,
                     p.strFirstName,
                     p.strSecondName,
                     cm.datMonitoringDate,
                     cm.idfObservation,
                     cm.strAdditionalComments
        ) AS x
        WHERE RowNum > @FirstRec
              AND RowNum < @LastRec
        ORDER BY RowNum;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
