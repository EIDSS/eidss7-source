
-- ================================================================================================
-- NAME						: [USP_ADMIN_SYSTEMEVENTS_LOG_GetList]		
--
-- Description				: Get System Events Log
--
-- Author						: Mani
--
--Revision History

-- Testing code:
--
/*

EXECUTE [dbo].[USP_ADMIN_SYSTEMEVENTS_LOG_GetList] 
	
--*/

-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_SYSTEMEVENTS_LOG_GetList]
(
	@LangID	NVARCHAR(50),		
	@idfUserID BIGINT = NULL,
	@auditObjectID BIGINT = NULL,
	@StartDate AS DATETIME = NULL,
	@EndDate AS DATETIME = NULL,
	@SelectAllIndicator BIT = 0,
	@PaginationSet INT = 1,
	@PageSize INT = 10,
	@MaxPagesPerFetch INT = 10
)
AS
			
BEGIN

	SET NOCOUNT ON;

	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
		@ReturnCode BIGINT = 0;

	BEGIN TRY  


	IF @SelectAllIndicator = 1
		BEGIN
			SET @PageSize = 1000;
			SET @MaxPagesPerFetch = 1000;
		END;


	DECLARE @RecordCount AS INT = (
		SELECT COUNT(*) AS RecordCount	
		from AuditEventSystemLog ae
		join tstUserTable tu
			on ae.idfAppUserID =  tu.idfUserID
		join tlbPerson p
			on tu.idfPerson = p.idfPerson
		join trtBaseReference br
			on  ae.AuditObjectID = br.idfsBaseReference
		INNER JOIN dbo.trtReferenceType AS rt 
			ON rt.idfsReferenceType = br.idfsReferenceType
		LEFT JOIN dbo.trtStringNameTranslation AS s 
			ON (br.idfsBaseReference = s.idfsBaseReference 
				AND s.idfsLanguage = dbo.FN_GBL_LanguageCode_Get(@LangID))
			WHERE	
				ISNULL(br.intRowStatus, 0) = 0	
				AND 
				(	tu.idfUserID = @idfUserID
					OR (@idfUserID IS NULL)
				)
				AND 
				(
					dbo.FN_GBL_FormatDate(ae.AuditCreateDTM, 'mm/dd/yyyy')  >=  dbo.FN_GBL_FormatDate(@StartDate, 'mm/dd/yyyy')
					OR (@StartDate IS NULL)
				)
				AND 
				(
					dbo.FN_GBL_FormatDate(ae.AuditCreateDTM, 'mm/dd/yyyy')  <=  dbo.FN_GBL_FormatDate(@EndDate, 'mm/dd/yyyy')
					OR (@EndDate IS NULL)
				)
				AND (
				(ae.AuditCreateDTM <= @EndDate)
				OR (@EndDate IS NULL)
				)
			);

	select ae.AuditEventSystemLogUID as Id,
		dbo.FN_GBL_FormatDate(ae.AuditCreateDTM, 'mm/dd/yyyy') AS Date,
		tu.strAccountName as UserName,
		ISNULL(s.strTextString, br.strDefault) AS Description,
		'0' AS RowSelectionIndicator,
			@RecordCount AS RecordCount,
			(
				SELECT COUNT(*)
				FROM dbo.AuditEventSystemLog
				
				) AS TotalCount
	from AuditEventSystemLog ae
	join tstUserTable tu
		on ae.idfAppUserID =  tu.idfUserID
	join tlbPerson p
		on tu.idfPerson = p.idfPerson
	join trtBaseReference br
		on  ae.AuditObjectID = br.idfsBaseReference
	INNER JOIN dbo.trtReferenceType AS rt 
		ON rt.idfsReferenceType = br.idfsReferenceType
	LEFT JOIN dbo.trtStringNameTranslation AS s 
		ON (br.idfsBaseReference = s.idfsBaseReference 
			AND s.idfsLanguage = dbo.FN_GBL_LanguageCode_Get(@LangID))
		WHERE	
			ISNULL(br.intRowStatus, 0) = 0	
			AND 
			(	tu.idfUserID = @idfUserID
				OR (@idfUserID IS NULL)
			)
			AND 
			(	ae.AuditObjectID = @auditObjectID
				OR (@auditObjectID IS NULL)
			)
			AND 
			(dbo.FN_GBL_FormatDate(ae.AuditCreateDTM, 'mm/dd/yyyy')  >=  dbo.FN_GBL_FormatDate(@StartDate, 'mm/dd/yyyy')
			OR (@StartDate IS NULL)
			)
			AND 
			(dbo.FN_GBL_FormatDate(ae.AuditCreateDTM, 'mm/dd/yyyy')  <=  dbo.FN_GBL_FormatDate(@EndDate, 'mm/dd/yyyy')
			OR (@EndDate IS NULL)
			)
			ORDER BY ae.AuditCreateDTM,ae.AuditCreateUser
			OFFSET(@PageSize * @MaxPagesPerFetch) * (@PaginationSet - 1) ROWS

			FETCH NEXT (@PageSize * @MaxPagesPerFetch) ROWS ONLY;

	

		SELECT @ReturnCode,@ReturnMessage;


	END TRY

	BEGIN CATCH
		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();

		SELECT @ReturnCode,
			@ReturnMessage;

		THROW;
	END CATCH;
END
