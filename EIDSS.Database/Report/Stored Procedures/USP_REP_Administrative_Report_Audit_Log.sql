


--********************************************************************************************************
-- Name 				: USP_REP_Administrative_Report_Audit_Log
-- Description			: This procedure returns resultset for Administrative Report Audit Log
--          
-- Author               : Srini Goli
-- Revision History
--		Name		Date			Change Detail
--		Srini Goli	9/19/2022		Added Distinct Clause

/*
 EXEC report.USP_REP_Administrative_Report_Audit_Log 
 'ALL', 
  'parker',
  NULL,
  NULL,
 '2020-10-18',
 '2020-11-18'
 
  EXEC report.USP_REP_Administrative_Report_Audit_Log 
	 'WHO Report on Measles and Rubella,Main indicators of AFP surveillance', 
	  NULL,
	  NULL,
	  NULL,
	 '2020-10-18',
	 '2020-11-18'
*/ 
--********************************************************************************************************
CREATE PROCEDURE [Report].[USP_REP_Administrative_Report_Audit_Log]
 (
	 @ReportName   AS NVARCHAR(MAX),
	 @UserFirstName  AS NVARCHAR(256) = NULL,
	 @UserLastName  AS NVARCHAR(256) = NULL,
	 @UserMiddleName  AS NVARCHAR(256) = NULL,
	 @FromDate  AS DATETIME,
	 @ToDate  AS DATETIME
 )
 as	
	SET NOCOUNT ON
 	DECLARE 
 	     @strReportName NVARCHAR(MAX),
 	     @strUserFirstName NVARCHAR(256),
 	     @strUserLastName NVARCHAR(256),
 	     @strUserMiddleName NVARCHAR(256),
 		 @SDDate DATETIME,
 		 @EDDate DATETIME
 		 
	SELECT  @strReportName = CASE WHEN SUBSTRING(LTRIM(@ReportName),1,3)='ALL'  THEN 'ALL' ELSE RTRIM(LTRIM(@ReportName)) END,
	        @strUserFirstName = CASE WHEN LTRIM(@UserFirstName)='' OR ISNULL(@UserFirstName,'')='' THEN '' ELSE RTRIM(LTRIM(@UserFirstName)) END,
			@strUserLastName = CASE WHEN LTRIM(@UserLastName)='' OR ISNULL(@UserLastName,'')='' THEN '' ELSE RTRIM(LTRIM(@UserLastName)) END,
			@strUserMiddleName = CASE WHEN LTRIM(@UserMiddleName)='' OR ISNULL(@UserMiddleName,'')='' THEN '' ELSE RTRIM(LTRIM(@UserMiddleName)) END,
			@SDDate = @FromDate,
			@EDDate = @ToDate

 	SELECT DISTINCT 
		   [idfReportAudit]
		  ,[idfUserID]
		  ,[FirstName]
		  ,[MiddleName]
		  ,[LastName]
		  ,[UserRole]
		  ,[Organization]
		  ,[ReportName]
		  ,[IsSignatureIncluded]
		  ,[GeneratedDate]
    FROM [dbo].[tlbReportAudit]
    WHERE ('ALL' = @strReportName OR [ReportName] IN (SELECT lTRIM(VALUE) AS ReportName
													 FROM string_split(@strReportName,',')))
		AND ('' = @strUserFirstName OR [FirstName] =  @strUserFirstName)
		AND ('' = @strUserLastName OR [LastName] =  @strUserLastName)
		AND ('' = @strUserMiddleName OR [MiddleName] =  @strUserMiddleName)
		AND ([GeneratedDate] BETWEEN @SDDate AND @EDDate)
