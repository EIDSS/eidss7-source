-- ============================================================================
-- Name: [USP_GBL_SecurityEventLog_GetList]
-- Get Security Event Log List for SAUC61
--                      
-- Author: Manickandadn Govindarajan
-- Revision History:
-- Name						 Date        Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Manickandan Govindarajan 07/11/2022  Initial Release
-- ============================================================================

CREATE  PROCEDURE [dbo].[USP_GBL_SecurityEventLog_GetList]
		@LangID as nvarchar(50),
		@ActionStartDate as DateTime =NULL,
		@ActionEndDate as DateTime =NULL,
		@Action as bigint= null,
		@ProcessType as bigint =NULL,
		@ResultType as bigint =NULL,
		@ObjectId as bigint =NULL,
		@UserId as bigint =NULL,
		@ErrorText as NVARCHAR(255)= NULL,
		@ProcessId as  NVARCHAR(255) =NULL,
		@Description as  NVARCHAR(255) =NULL,
		@SortColumn NVARCHAR(30) = 'ActionDate',
		@SortOrder NVARCHAR(4) = 'DESC',
		@Page INT = 1,
		@PageSize INT = 10

AS
 BEGIN

	SET NOCOUNT ON;

	DECLARE @firstRec INT;
	DECLARE @lastRec INT;

	BEGIN TRY
		SET @firstRec = (@Page-1)* @PageSize
		SET @lastRec = (@Page*@PageSize+1);


		
		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY
			CASE WHEN @sortColumn = 'strActionDate' AND @SortOrder = 'ASC' THEN sa.datActionDate END ASC,
			CASE WHEN @sortColumn = 'strActionDate' AND @SortOrder = 'DESC' THEN sa.datActionDate END DESC,
			CASE WHEN @sortColumn = 'ProcessType' AND @SortOrder = 'ASC' THEN sa.idfsProcessType END ASC,
			CASE WHEN @sortColumn = 'ProcessType' AND @SortOrder = 'DESC' THEN sa.idfsProcessType END DESC,
			CASE WHEN @sortColumn = 'strActionDefaultName' AND @SortOrder = 'ASC' THEN sa.idfsAction END ASC,
			CASE WHEN @sortColumn = 'strActionDefaultName' AND @SortOrder = 'DESC' THEN sa.idfsAction END DESC,
			CASE WHEN @sortColumn = 'strResultDefaultName' AND @SortOrder = 'ASC' THEN sa.idfsResult END ASC,
			CASE WHEN @sortColumn = 'strResultDefaultName' AND @SortOrder = 'DESC' THEN sa.idfsResult END DESC,
			CASE WHEN @sortColumn = 'strProcessTypeDefaultName' AND @SortOrder = 'ASC' THEN sa.idfObjectID END ASC,
			CASE WHEN @sortColumn = 'strProcessTypeDefaultName' AND @SortOrder = 'DESC' THEN sa.idfObjectID END DESC,
			CASE WHEN @sortColumn = 'strPersonName' AND @SortOrder = 'ASC' THEN dbo.fnConcatFullName(strFamilyName, strFirstName, strSecondName) END ASC,
			CASE WHEN @sortColumn = 'strPersonName' AND @SortOrder = 'DESC' THEN dbo.fnConcatFullName(strFamilyName, strFirstName, strSecondName) END DESC,
			CASE WHEN @sortColumn = 'strErrorText' AND @SortOrder = 'ASC' THEN sa.strErrorText END ASC,
			CASE WHEN @sortColumn = 'strErrorText' AND @SortOrder = 'DESC' THEN sa.strErrorText END DESC,
			CASE WHEN @sortColumn = 'strProcessID' AND @SortOrder = 'ASC' THEN sa.strProcessID END ASC,
			CASE WHEN @sortColumn = 'strProcessID' AND @SortOrder = 'DESC' THEN sa.strProcessID END DESC,
			CASE WHEN @sortColumn = 'Description' AND @SortOrder = 'ASC' THEN sa.strDescription END ASC,
			CASE WHEN @sortColumn = 'Description' AND @SortOrder = 'DESC' THEN sa.strDescription END DESC
			)  AS ROWNUM,
				 sa.idfSecurityAudit
				,sa.idfsAction
				,Act.strDefault As strActionDefaultName
				,Act.LongName As strActionNationalName
				,sa.[idfsResult]
				,Res.strDefault As strResultDefaultName
				,Res.LongName As strResultNationalName
				,sa.idfsProcessType
				,ProcessType.strDefault As strProcessTypeDefaultName
				,ProcessType.LongName As strProcessTypeNationalName
				,sa.idfAffectedObjectType
				,sa.idfObjectID
				,sa.idfUserID
				,P.idfPerson
				,UT.strAccountName
				,dbo.fnConcatFullName(strFamilyName, strFirstName, strSecondName)  AS strPersonName
				,sa.idfDataAuditEvent
				,sa.datActionDate
				,sa.strErrorText
				,sa.strProcessID
				,sa.strDescription
				,p.strFirstName
				,COUNT(*) OVER () AS TotalRowCount
			  From [dbo].[tstSecurityAudit] SA
			  left  OUTER Join dbo.fnReferenceRepair(@LangID, 19000112) Act On SA.idfsAction = Act.idfsReference
			  LEFT OUTER JOIN dbo.fnReferenceRepair(@LangID, 19000113) Res On SA.idfsResult = Res.idfsReference
			  LEFT OUTER JOIN dbo.fnReferenceRepair(@LangID, 19000114) ProcessType On SA.idfsProcessType = ProcessType.idfsReference
			  LEFT OUTER JOIN	tstUserTable UT ON	UT.idfUserID = SA.idfUserID
			  INNER JOIN	tlbPerson P ON		P.idfPerson = UT.idfPerson
				WHERE 
						( 
							 CAST( sa.datActionDate as DATE) >= cast(@ActionStartDate as date)
							OR @ActionStartDate is NULL
						)
					AND
						( 
							cast(sa.datActionDate as date) <= cast(@ActionEndDate as date)
							OR @ActionEndDate is NULL
						)
					AND (sa.idfsProcessType =@ProcessType OR @ProcessType IS NULL)
					AND (sa.idfsResult =@ResultType OR @ResultType IS NULL)
					AND (sa.idfObjectID =@ObjectId OR @ObjectId IS NULL)
					AND (sa.idfObjectID =@ObjectId OR @ObjectId IS NULL)
					AND (sa.idfUserID =@UserId OR @UserId IS NULL)
					AND (sa.strErrorText =@ErrorText OR @ErrorText IS NULL)
					AND (sa.strProcessID =@ProcessId OR @ProcessId IS NULL)
					AND (sa.strDescription =@Description OR @Description IS NULL)
					AND (sa.idfsAction =@Action OR @Action IS NULL)
			)

	-- select * from CTEResults

	 Select 
	  idfSecurityAudit
      ,idfsAction
      ,strActionDefaultName
      ,strActionNationalName
      ,idfsResult
      ,strResultDefaultName
      ,strResultNationalName
      ,idfsProcessType
      ,strProcessTypeDefaultName
      ,strProcessTypeNationalName
      ,idfAffectedObjectType
      ,idfObjectID
      ,idfUserID
	  ,idfPerson
      ,strAccountName
	  ,strPersonName
      ,idfDataAuditEvent
      ,datActionDate
      ,strErrorText
      ,strProcessID
      ,strDescription
	  ,TotalRowCount,
			TotalPages = (TotalRowCount/@PageSize)+IIF(TotalRowCount%@PageSize>0,1,0),
			CurrentPage = @Page
		FROM CTEResults WHERE RowNum > @firstRec AND RowNum < @lastRec
		ORDER BY
			CASE WHEN @sortColumn = 'strActionDate' AND @SortOrder = 'ASC' THEN datActionDate END ASC,
			CASE WHEN @sortColumn = 'strActionDate' AND @SortOrder = 'DESC' THEN datActionDate END DESC,
			CASE WHEN @sortColumn = 'strProcessType' AND @SortOrder = 'ASC' THEN idfsProcessType END ASC,
			CASE WHEN @sortColumn = 'strProcessType' AND @SortOrder = 'DESC' THEN idfsProcessType END DESC,
			CASE WHEN @sortColumn = 'strActionDefaultName' AND @SortOrder = 'ASC' THEN idfsAction END ASC,
			CASE WHEN @sortColumn = 'strActionDefaultName' AND @SortOrder = 'DESC' THEN idfsAction END DESC,
			CASE WHEN @sortColumn = 'strResultDefaultName' AND @SortOrder = 'ASC' THEN idfsResult END ASC,
			CASE WHEN @sortColumn = 'strResultDefaultName' AND @SortOrder = 'DESC' THEN idfsResult END DESC,
			CASE WHEN @sortColumn = 'strProcessTypeDefaultName' AND @SortOrder = 'ASC' THEN idfObjectID END ASC,
			CASE WHEN @sortColumn = 'strProcessTypeDefaultName' AND @SortOrder = 'DESC' THEN idfObjectID END DESC,
			CASE WHEN @sortColumn = 'strPersonName' AND @SortOrder = 'ASC' THEN strPersonName END ASC,
			CASE WHEN @sortColumn = 'strPersonName' AND @SortOrder = 'DESC' THEN strPersonName END DESC,
			CASE WHEN @sortColumn = 'strErrorText' AND @SortOrder = 'ASC' THEN strErrorText END ASC,
			CASE WHEN @sortColumn = 'strErrorText' AND @SortOrder = 'DESC' THEN strErrorText END DESC,
			CASE WHEN @sortColumn = 'strProcessID' AND @SortOrder = 'ASC' THEN strProcessID END ASC,
			CASE WHEN @sortColumn = 'strProcessID' AND @SortOrder = 'DESC' THEN strProcessID END DESC,
			CASE WHEN @sortColumn = 'Description' AND @SortOrder = 'ASC' THEN strDescription END ASC,
			CASE WHEN @sortColumn = 'Description' AND @SortOrder = 'DESC' THEN strDescription END DESC
 END TRY

	BEGIN CATCH
		
		THROW;
	END CATCH;

	
END