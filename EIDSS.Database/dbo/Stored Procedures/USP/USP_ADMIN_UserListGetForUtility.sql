-- =============================================
-- Author:		Steven Verner
-- Create date: 02/15/2023
-- Description:	Gets a list of tlbuserTable users.  An ASPNetUser record will be created for all those accounts
-- where none exists.
-- =============================================
CREATE PROCEDURE [dbo].[USP_ADMIN_UserListGetForUtility] 
	-- Add the parameters for the stored procedure here
	 @idfsSite BIGINT = NULL 
	,@idfInstitution BIGINT = NULL
	,@pageNo INT = 1
	,@pageSize INT = 10
	,@showUnconvertedOnly BIT = 0 -- by default show all accounts.
	,@advancedSearch NVARCHAR(100) = NULL
	,@sortColumn NVARCHAR(30) = 'b.strAccountName'
	,@sortOrder NVARCHAR(4) = 'asc'  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @firstRec INT
	DECLARE @lastRec INT
	
	SET @firstRec = (@pageNo-1)* @pagesize
	SET @lastRec = (@pageNo*@pageSize+1);
	DECLARE @T TABLE(
		 idfPerson BIGINT
		,strAccountName NVARCHAR(255)
		,strFirstName NVARCHAR(255)
		,strFamilyName NVARCHAR(255)
		,strSecondName NVARCHAR(255)
		,Institution NVARCHAR(255)
		,Site NVARCHAR(255)
		,idfUserID BIGINT
		,idfInstitution BIGINT
		,idfsSite BIGINT
		,DuplicateUserName BIT
		,Converted BIT 
	)
	IF( @advancedSearch IS NOT NULL)
	BEGIN
		INSERT INTO @T
		SELECT * FROM
		(
			SELECT
			 p.idfPerson
			,ISNULL(a.UserName,u.strAccountName) strAccountName
			,p.strFirstName
			,p.strFamilyName
			,p.strSecondName
			,b.strDefault Institution
			,s.strSiteName
			,u.idfUserID
			,p.idfInstitution
			,u.idfsSite
			,CAST( IIF((
			select top 1 idfPerson 
			from tstUserTable x 
			where --x.idfPerson != u.idfPerson and 
				x.strAccountName = u.strAccountName and 
				x.intRowStatus = 0 AND
				x.idfUserId != u.idfUserID) IS NULL, 0,1) AS BIT) AS DuplicateUsername
			,CAST(IIF(a.id IS NULL,0,1) AS BIT) AS Converted
		FROM tstUserTable u
		INNER JOIN tlbPerson p ON u.idfPerson  = p.idfPerson
		INNER join tlboffice o on o.idfOffice = p.idfInstitution
		INNER JOIN trtBaseReference b on b.idfsBaseReference = o.idfsOfficeName
		INNER JOIN tstSite s ON s.idfsSite = u.idfsSite
		LEFT JOIN aspnetusers a on a.idfUserID = u.idfUserID
		WHERE 
			u.intRowStatus =0 AND 
			p.intRowStatus=0 
		) AS s 
		WHERE (
			strAccountName LIKE '%' + @advancedSearch + '%' OR 
			strFirstName LIKE '%' + @advancedSearch + '%' OR 
			strFamilyName LIKE '%' + @advancedSearch + '%' OR 
			strSecondName LIKE '%' + @advancedSearch + '%' OR 
			Institution LIKE '%' + @advancedSearch + '%' OR
			s.strSiteName LIKE '%' + @advancedSearch + '%' 
		)
	END ELSE BEGIN
		INSERT INTO @T
			SELECT
			 p.idfPerson
			,ISNULL(a.UserName,u.strAccountName) strAccountName
			,p.strFirstName
			,p.strFamilyName
			,p.strSecondName
			,b.strDefault Institution
			,s.strSiteName
			,u.idfUserID
			,p.idfInstitution
			,u.idfsSite
			,CAST( IIF((select top 1 idfPerson from tstUserTable x 
				where x.idfPerson != u.idfPerson and 
				x.strAccountName = u.strAccountName and x.intRowStatus = 0 AND
				x.idfsSite != u.idfsSite) IS NULL, 0,1) AS BIT) AS DuplicateUsername
			,CAST(IIF(a.id IS NULL,0,1) AS BIT) AS Converted
		FROM tstUserTable u
		INNER JOIN tlbPerson p ON u.idfPerson  = p.idfPerson
		INNER join tlboffice o on o.idfOffice = p.idfInstitution
		INNER JOIN trtBaseReference b on b.idfsBaseReference = o.idfsOfficeName
		INNER JOIN tstSite s ON s.idfsSite = u.idfsSite
		LEFT JOIN aspnetusers a on a.idfUserID = u.idfUserID
		WHERE 
			u.intRowStatus =0 AND 
			p.intRowStatus=0 AND 
			--a.id is null AND
			u.idfsSite = IIF(@idfsSite IS NULL, u.idfsSite, @idfsSite) AND
			p.idfInstitution = IIF(@idfInstitution IS NULL, p.idfInstitution, @idfInstitution) 
	END;

	-- If we're only showing non converted users, then remove all converted users...
	IF( @showUnconvertedOnly = 1 )
		DELETE FROM @T WHERE Converted = 1;

	WITH CTEResults AS 
	(
		SELECT ROW_NUMBER() OVER 
			( ORDER BY 
				CASE WHEN @sortColumn = 'idfPerson' AND @sortOrder = 'asc' THEN t.idfPerson END ASC,
				CASE WHEN @sortColumn = 'Site' AND @sortOrder = 'asc' THEN t.Site END ASC,
				CASE WHEN @sortColumn = 'idfUserID' AND @sortOrder = 'asc' THEN t.idfUserID END ASC,
				CASE WHEN @sortColumn = 'idfInstitution' AND @sortOrder = 'asc' THEN t.idfInstitution END ASC,
				CASE WHEN @sortColumn = 'idfsSite' AND @sortOrder = 'asc' THEN t.idfsSite END ASC,
				CASE WHEN @sortColumn = 'DuplicateUserName' AND @sortOrder = 'asc' THEN t.DuplicateUserName END ASC,
				CASE WHEN @sortColumn = 'Converted' AND @sortOrder = 'asc' THEN t.Converted END ASC,
				CASE WHEN @sortColumn = 'strAccountName' AND @sortOrder = 'asc' THEN strAccountname END ASC,
				CASE WHEN @sortColumn = 'strFirstname' AND @sortorder = 'asc' THEN strFirstName END ASC,
				CASE WHEN @sortColumn = 'strFamilyName' AND @sortOrder = 'asc' THEN strFamilyName END ASC,
				CASE WHEN @sortColumn = 'strSecondName' AND @sortOrder = 'asc' THEN strSecondName END ASC,
				CASE WHEN @sortColumn = 'Institution' AND @sortOrder = 'asc' THEN Institution END ASC,
				CASE WHEN @sortColumn = 'idfPerson' AND @sortOrder = 'desc' THEN t.idfPerson END DESC,
				CASE WHEN @sortColumn = 'Site' AND @sortOrder = 'desc' THEN t.Site END DESC,
				CASE WHEN @sortColumn = 'idfUserID' AND @sortOrder = 'desc' THEN t.idfUserID END DESC,
				CASE WHEN @sortColumn = 'idfInstitution' AND @sortOrder = 'desc' THEN t.idfInstitution END DESC,
				CASE WHEN @sortColumn = 'idfsSite' AND @sortOrder = 'desc' THEN t.idfsSite END DESC,
				CASE WHEN @sortColumn = 'DuplicateUserName' AND @sortOrder = 'desc' THEN t.DuplicateUserName END DESC,
				CASE WHEN @sortColumn = 'Converted' AND @sortOrder = 'desc' THEN t.Converted END DESC,
				CASE WHEN @sortColumn = 'strAccountName' AND @sortOrder = 'desc' THEN strAccountname END DESC,
				CASE WHEN @sortColumn = 'strFirstname' AND @sortorder = 'desc' THEN strFirstName END DESC,
				CASE WHEN @sortColumn = 'strFamilyName' AND @sortOrder = 'desc' THEN strFamilyName END DESC,
				CASE WHEN @sortColumn = 'strSecondName' AND @sortOrder = 'desc' THEN strSecondName END DESC,
				CASE WHEN @sortColumn = 'Institution' AND @sortOrder = 'desc' THEN Institution END DESC
			) AS RowNum
			,COUNT(*) OVER () AS TotalCount
			,idfPerson
			,strAccountName
			,strFirstName
			,strFamilyName
			,strSecondName
			,Institution
			,Site
			,idfUserID
			,idfInstitution
			,idfsSite
			,DuplicateUserName
			,Converted
		FROM @T t
	)

	SELECT * 
	,TotalPages = (TotalCount/@pageSize)+IIF(TotalCount%@pageSize>0,1,0)
	,CurrentPage = @pageNo 
	FROM CTEResults
	WHERE CTEResults.RowNum > @firstRec AND CTEResults.RowNum < @lastRec
END
GO

