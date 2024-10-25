
GO
ALTER TABLE [dbo].[trtReferenceType] DROP CONSTRAINT [FK_trtReferenceType_trtBaseReference_SourceSystemNameID];


GO
PRINT N'Altering Table [dbo].[trtReferenceType]...';


GO
ALTER TABLE [dbo].[trtReferenceType]
    ADD [EditorSettings] BIGINT NULL;


GO
PRINT N'Creating Foreign Key [dbo].[FK_trtReferenceType_trtBaseReference_SourceSystemNameID]...';


GO
ALTER TABLE [dbo].[trtReferenceType] WITH NOCHECK
    ADD CONSTRAINT [FK_trtReferenceType_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]);


GO
PRINT N'Altering Trigger [dbo].[TR_trtReferenceType_A_Update]...';


GO
ENABLE TRIGGER [dbo].[TR_trtReferenceType_A_Update]
    ON [dbo].[trtReferenceType];


GO
PRINT N'Altering Trigger [dbo].[TR_trtReferenceType_I_Delete]...';


GO
ENABLE TRIGGER [dbo].[TR_trtReferenceType_I_Delete]
    ON [dbo].[trtReferenceType];




GO
PRINT N'Altering Procedure [dbo].[USP_GBL_BASE_REFERENCE_GETList]...';


GO
--*************************************************************************************************
-- Name: USP_GBL_BASE_REFERENCE_GETList
--
-- Description: List filered values from tlbBaseReference table.
--          
-- Revision History:
-- Name							Date		Change Detail
-- ---------------				----------	--------------------------------------------------------------------
-- Stephen Long					06/29/2019	Initial release.
-- Manickandan Govindarajan		11/24/2020	The IF query is getting the intHACode from basereference table but the
--											IntHACode is 0 for multiple records ex: 19000040 refrencetype
--											Updated the code to get intHACode from trtHACodeList table. It will help to filter in the app
--
-- Mark Wilson					12/16/2020  Updated to accept null HACode (when HACode is unnecessary)
-- Steven Verner				10/21/2022	Removed duplicate base reference types where there currently is an editor for those types
--											Like Age Group, Case Classification,etc.
--											This change fixes bugs 3865,4757,4756,4755,4750...
-- Doug Albanese				9/15/2023	Adding "Editor Settings" to the result of data.

--
-- @intHACode Code List
-- 0	None
-- 2	Human
-- 4	Exophyte
-- 8	Plant
-- 16	Soil
-- 32	Livestock
-- 64	Avian
-- 128	Vector
-- 256	Syndromic
-- 510	All	
--
-- Testing code:
/*
	Exec USP_GBL_BASE_REFERENCE_GETList 'EN', 'Nationality List', 0
	Exec USP_GBL_BASE_REFERENCE_GETList 'EN', 'Case Status', 64
	Exec USP_GBL_BASE_REFERENCE_GETList 'EN', 'Diagnosis', 2
	EXEC USP_GBL_BASE_REFERENCE_GETList 'en','Personal ID Type', 0
	EXEC USP_GBL_BASE_REFERENCE_GETList 'en','Patient Location Type', 2
	EXEC USP_GBL_BASE_REFERENCE_GETList 'en','Organization Type', 482
	EXEC USP_GBL_BASE_REFERENCE_GETList 'en','Human Age Type', 2

*/
-- ************************************************************************************************
ALTER PROCEDURE [dbo].[USP_GBL_BASE_REFERENCE_GETList] 
(
	@LangID	NVARCHAR(50),
	@ReferenceTypeName VARCHAR(400) = NULL,
	@intHACode	BIGINT = NULL 
)
AS
	DECLARE @HACodeMax BIGINT = 510;
	DECLARE @ReturnMsg VARCHAR(MAX) = 'Success';
	DECLARE @ReturnCode BIGINT = 0;
	DECLARE @HAList TABLE(
		intHACode INT

	)

	IF @intHACode IS NOT NULL
	INSERT INTO @HAList
	(
	    intHACode
	)
	SELECT intHACode FROM dbo.FN_GBL_SplitHACode(@intHACode, @HACodeMax)

	BEGIN TRY

		SELECT 
			br.idfsBaseReference,
			br.idfsReferenceType,
			br.strBaseReferenceCode,
			br.strDefault,
			ISNULL(s.strTextString, br.strDefault) AS [name],
			br.intHACode,
			br.intOrder,
			br.intRowStatus,
			br.blnSystem,
			rt.intDefaultHACode,
			CASE WHEN ISNULL(@intHACode,0) = 0 THEN NULL ELSE dbo.FN_GBL_SPLITHACODEASSTRING(br.intHACode, 510) END AS strHACode,
			EditorSettings
		FROM dbo.trtBaseReference br
		INNER JOIN dbo.trtReferenceType AS rt ON rt.idfsReferenceType = br.idfsReferenceType
		LEFT JOIN dbo.trtStringNameTranslation AS s ON br.idfsBaseReference = s.idfsBaseReference AND s.idfsLanguage = dbo.FN_GBL_LanguageCode_Get(@LangID)
		LEFT JOIN dbo.trtHACodeList HA ON HA.intHACode = br.intHACode
		LEFT JOIN dbo.trtBaseReference HAR ON HAR.idfsBaseReference = HA.idfsCodeName
		
		WHERE 
			br.idfsBaseReference NOT IN (19000146,19000011,19000019,19000537,19000529,19000530,19000531,19000532,19000533,19000534,19000535,19000125,19000123,19000122,
												 19000143,19000050,19000126,19000121,19000075,19000124,19000012,19000164,19000019,19000503,19000530,19000510,19000506,19000505,
												 19000509,19000511,19000508,19000507,19000022,19000131,19000070,19000066,19000071,19000069,19000029,19000032,19000101,19000525,
												 19000033,19000532,19000534,19000533,19000152,19000056,19000060,19000109,19000062,19000045,19000046,19000516,19000074,19000147,
												 19000130,19000535,19000531,19000087,19000079,19000529,19000119,19000524,19000084,19000519,19000166,19000086,19000090,19000141,
												 19000140)
			AND	
			br.intRowStatus = 0	
			AND
		((EXISTS 
				(SELECT intHACode FROM dbo.FN_GBL_SplitHACode(@intHACode, @HACodeMax) 
				INTERSECT 
				SELECT intHACode FROM dbo.FN_GBL_SplitHACode(br.intHACode, @HACodeMax)) 
				OR @intHACode IS NULL OR @intHACode = 0 OR br.intHACode = @intHACode))
		AND rt.strReferenceTypeName = IIF(@ReferenceTypeName IS NOT NULL, @ReferenceTypeName, rt.strReferenceTypeName )
		
		ORDER BY 
			br.intOrder,
			[name]

	END TRY  

	BEGIN CATCH 

		THROW;

	END CATCH;
GO
PRINT N'Refreshing Procedure [dbo].[USP_GBL_LKUP_Diseases_BY_IDS_GETLIST_Paged]...';


GO
ALTER TABLE [dbo].[trtReferenceType] WITH CHECK CHECK CONSTRAINT [FK_trtReferenceType_trtBaseReference_SourceSystemNameID];


GO
PRINT N'Update complete.';


GO


GO
ALTER   FUNCTION [dbo].[fnGetAttributesFromFormattedString]
(    @AttrString    nvarchar(max),            --##PARAM @AttrString Formatted string of attributes; expected format of the string: N'intAttrInd:1,strAttr:AttrName1,strVal:AttrVal1;intAttrInd:2,strAttr:AttrName2,strVal:AttrVal2;...'
    @AttrName    nvarchar(100) = null    --##PARAM @AttrName Optional parameter to retrieve only one attribute
)
returns @ResTable table
(
    strAttr varchar(100) collate Cyrillic_General_CI_AS not null primary key,
    strVal nvarchar(max) collate Cyrillic_General_CI_AS null
)
as
begin





   ;
    with cte
    (    intId,
        attrLineNum,
        attrPartNum,
        strVal
    )
    as
    (    select        (attrLine.[num]-1) * 100 + (attrPart.[num]-1) * 2 + attrNameValPair.[num] as intId,
                    attrLine.[num] as attrLineNum,
                    attrPart.[num] as attrPartNum,
                    cast(attrNameValPair.[Value] as nvarchar(max)) as strVal
        from        dbo.fnsysSplitList(@AttrString, 0, N';') attrLine
        outer apply    dbo.fnsysSplitList(cast(attrLine.[Value] as nvarchar(max)), 0, N',') attrPart
        outer apply    dbo.fnsysSplitList(cast(attrPart.[Value] as nvarchar(max)), 0, N':') attrNameValPair
    )




   insert into    @ResTable (strAttr, strVal)
    select        cast(left(attrName.strVal, 100) as varchar(100)) as strAttr, attrVal.strVal as strVal
    from        cte as attrName
    inner join    cte as attrNamePrevPart
    on            attrNamePrevPart.attrLineNum = attrName.attrLineNum
                and attrNamePrevPart.attrPartNum = attrName.attrPartNum
                and attrNamePrevPart.intId = attrName.intId - 1
                and attrNamePrevPart.strVal = N'strAttr' collate Cyrillic_General_CI_AS




   left join    cte as attrVal
        inner join    cte as attrValPrevPart
        on            attrValPrevPart.attrLineNum = attrVal.attrLineNum
                    and attrValPrevPart.attrPartNum = attrVal.attrPartNum
                    and attrValPrevPart.intId = attrVal.intId - 1
                    and attrValPrevPart.strVal = N'strVal' collate Cyrillic_General_CI_AS
    on            attrVal.attrLineNum = attrName.attrLineNum
    where    attrName.strVal is not null
            and (@AttrName is null or (@AttrName is not null and attrName.strVal = @AttrName collate Cyrillic_General_CI_AS))




   return
end
GO
PRINT N'Altering Procedure [dbo].[USP_GBL_BASE_REFERENCE_GETList]...';


GO

PRINT N'Altering Procedure [dbo].[USP_ADMIN_UserListGetForUtility]...';


GO
-- =============================================
-- Author:		Steven Verner
-- Create date: 02/15/2023
-- Description:	Gets a list of tlbuserTable users.  An ASPNetUser record will be created for all those accounts
-- where none exists.
-- =============================================
ALTER PROCEDURE [dbo].[USP_ADMIN_UserListGetForUtility] 
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
PRINT N'Altering Procedure [dbo].[USP_GBL_Languages_GETList]...';


GO
-- ================================================================================================
-- Name: USP_GBL_Language_GETList		
-- 
-- Description: Returns a list of languages.
--
-- Revision History:
--		
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     03/02/2021 Initial release.
-- Stephen Long     07/16/2021 Changed over to the base reference table and excluded WHO export.
-- Stephen Long     09/01/2021 Added intRowStatus check to the preference detail select on country 
--                             and startup language.
-- Stephen Long     05/15/2023 Added customization package to only list languages needed by the 
--                             installation.
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_GBL_Languages_GETList] (@LanguageID AS NVARCHAR(50))
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @StartupLanguage NVARCHAR(50) = (
				SELECT JSON_VALUE(PreferenceDetail, '$.StartupLanguage')
				FROM dbo.SystemPreference WHERE intRowStatus = 0
				);

		SELECT b.idfsBaseReference AS LanguageID
			,(
				SELECT JSON_VALUE(PreferenceDetail, '$.Country')
				FROM dbo.SystemPreference WHERE intRowStatus = 0
				) AS Country
			,strBaseReferenceCode AS CultureName
			,ISNULL(c.strTextString, b.strDefault) AS DisplayName
			,CONVERT(BIT, (
					CASE 
						WHEN @StartupLanguage = b.strBaseReferenceCode
							THEN 1
						ELSE 0
						END
					)) IsDefaultLanguage
		FROM dbo.trtBaseReference b
		LEFT JOIN dbo.trtStringNameTranslation c ON b.idfsBaseReference = c.idfsBaseReference
			AND c.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
		JOIN dbo.trtLanguageToCP ltc ON	c.idfsBaseReference = ltc.idfsLanguage
		WHERE b.idfsReferenceType = 19000049
			AND b.intRowStatus = 0
			AND ltc.idfCustomizationPackage = dbo.FN_GBL_CustomizationPackage_GET()
			AND b.idfsBaseReference <> 10049002;-- WHO Export
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
GO
PRINT N'Altering Procedure [dbo].[USP_HUM_SAMPLES_GetList]...';


GO
--*************************************************************
-- Name 				: USP_HUM_SAMPLES_GetList
-- Description			: List Human Disease Report Samples by hcid
--          
-- Author               : JWJ
-- Revision History
--		Name		Date       Change Detail
-- ---------------- ---------- --------------------------------
-- JWJ				201080603		created 

--Lamont Mitchell	02132020		Added join on tlbPerson to return strFieldCollectedByPerson
--Lamont Mitchell   12/11/2020		Updated Modified OfficeSendTo.FullName to OfficeSendTo.name to match v6
-- Ann Xiong		05/12/2023		Fixed the issue of strFieldCollectedByPerson return null when p.strFirstName or p.strSecondName or p.strFamilyName is null
-- 
-- Testing code:
-- EXEC USP_HUM_SAMPLES_GetList 'en', @idfHumanCase=25   --10
--*************************************************************
ALTER PROCEDURE [dbo].[USP_HUM_SAMPLES_GetList] 
	@LangID							NVARCHAR(50) , --##PARAM @LangID - language ID
	@idfHumanCase					BIGINT = NULL,
	@SearchDiagnosis 				BIGINT = NULL
AS
Begin
	DECLARE @returnMsg				VARCHAR(MAX) = 'Success';
	DECLARE @returnCode				BIGINT = 0;

BEGIN TRY  
		SELECT		
					Samples.idfHumanCase
					,Samples.idfMaterial 
					,Samples.strBarcode -- Lab sample ID
					,Samples.strFieldBarcode -- Local Sample ID
					,Samples.idfsSampleType
					,SampleType.name AS strSampleTypeName
					,Samples.datFieldCollectionDate
					,Samples.idfSendToOffice
					,OfficeSendTo.name as strSendToOffice
					,Samples.idfFieldCollectedByOffice
					,CollectedByOffice.name as strFieldCollectedByOffice
					,Samples.datFieldSentDate
					,Samples.strNote
					,Samples.datAccession			--verify this is date received
					,Samples.idfsAccessionCondition
					,acessionedCond.strDefault as strCondition
					,Location.idfsRegion as idfsRegion
					,ISNULL(Region.[name], Region.strDefault) AS [strRegionName]
					,Location.idfsRayon as idfsRayon
					,ISNULL(Rayon.[name], Rayon.strDefault) AS [strRayonName]
					,Samples.blnAccessioned
					,'' as RecordAction
					,Samples.idfsSampleKind
					,sampleKind.name AS SampleKindTypeName
					--find stridfsSampleKind
					--find strTestDiagnosis and it's id
					,Samples.idfsSampleStatus
					,sampleStatus.name AS SampleStatusTypeName
					,Samples.idfFieldCollectedByPerson  
					,ISNULL(p.strFirstName + ' ', '') + ISNULL(p.strSecondName, '') + ISNULL(p.strFamilyName + ' ', '') as 'strFieldCollectedByPerson'   --verify this is the employee
					,Samples.datSampleStatusDate   --verify this is the result date
					,Samples.rowGuid as sampleGuid
					,Samples.intRowStatus
					,Samples.idfsSite 
					--, t.idfTesting
					--, t.idfsTestName
					--, t.idfsTestCategory
					--, t.idfsTestResult
					--, t.idfsTestStatus
					--, t.idfsDiagnosis
					--, TestName.name
					  

		FROM		dbo.tlbMaterial Samples 
		INNER JOIN	dbo.tlbHumanCase as hc ON Samples.idfHumanCase  = hc.idfHumanCase 
		LEFT JOIN	dbo.tlbGeoLocation as Location	ON Location.idfGeoLocation = hc.idfPointGeoLocation
		LEFT JOIN	dbo.FN_GBL_REFERENCEREPAIR(@LangID,19000087) SampleType ON	SampleType.idfsReference = Samples.idfsSampleType
		LEFT JOIN	FN_GBL_GIS_Reference(@LangID,19000003) Region ON Region.idfsReference = Location.idfsRegion
		LEFT JOIN	FN_GBL_GIS_Reference(@LangID,19000002) Rayon ON	Rayon.idfsReference = Location.idfsRayon
		LEFT JOIN	tlbMaterial ParentSample ON	ParentSample.idfMaterial = Samples.idfParentMaterial AND ParentSample.intRowStatus = 0
		LEFT JOIN	dbo.FN_GBL_INSTITUTION(@LangID) AS CollectedByOffice ON CollectedByOffice.idfOffice = Samples.idfFieldCollectedByOffice
		LEFT JOIN	dbo.FN_GBL_INSTITUTION(@LangID) AS OfficeSendTo ON OfficeSendTo.idfOffice = Samples.idfSendToOffice
		LEFT JOIN	FN_GBL_ReferenceRepair(@LangID, 19000158) AS sampleKind	ON sampleKind.idfsReference = Samples.idfsSampleKind 
		LEFT JOIN	FN_GBL_ReferenceRepair(@LangID, 19000015) AS sampleStatus ON sampleStatus.idfsReference = Samples.idfsSampleStatus 
		LEFT JOIN	FN_GBL_ReferenceRepair(@LangID, 19000110) AS acessionedCond ON acessionedCond.idfsReference = Samples.idfsAccessionCondition 
		Left JOIN	dbo.tlbPerson p on p.idfPerson = Samples.idfFieldCollectedByPerson
		--LEFT JOIN	dbo.tlbTesting t ON t.idfMaterial = Samples.idfMaterial AND t.intRowStatus = 0
		--LEFT JOIN	dbo.FN_GBL_REFERENCEREPAIR(@LangID,19000097) TestName ON	TestName.idfsReference = t.idfsTestName

		
		WHERE		
		--Samples.blnShowInCaseOrSession = 1 
		--AND 
		Samples.idfHumanCase = @idfHumanCase
		AND	Samples.intRowStatus = 0
		--AND NOT	(ISNULL(Samples.idfsSampleKind,0) = 12675420000000/*derivative*/ 
		--AND (ISNULL(Samples.idfsSampleStatus,0) = 10015002 or ISNULL(Samples.idfsSampleStatus,0) = 10015008)/*deleted in lab module*/)
		--optional param, filter samples by diagnosis: @SearchDiagnosis
		--AND	((idfsFinalDiagnosis = @SearchDiagnosis) OR (@SearchDiagnosis is null))




		SELECT	@returnCode, @returnMsg;



	END TRY  

	BEGIN CATCH 
		BEGIN
			SET @returnCode = ERROR_NUMBER();
			SET @returnMsg = 
				'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) 
				+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY())
				+ ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE())
				+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '')
				+ ' ErrorLine: ' +  CONVERT(VARCHAR, ISNULL(ERROR_LINE(), ''))
				+ ' ErrorMessage: '+ ERROR_MESSAGE();

			SELECT @returnCode, @returnMsg;
		END
	END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_HUM_SAMPLES_GetList_With_Derivates]...';


GO
-- ================================================================================================
-- Name: USP_HUM_SAMPLES_GetList
--
-- Description: List Human Disease Report Samples by human disease report ID.
--          
-- Author: JWJ
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- JWJ				06/03/2018 created 
-- Lamont Mitchell	02/13/2020 Added join on tlbPerson to return strFieldCollectedByPerson
-- Mike Kornegay	10/19/2021 Removed @returnMsg and @returnCode
-- Stephen Long     08/02/2022 Removed site join; returing duplicate sample records, and 
--                             changed reference values to use the national name for translated 
--                             value.
-- Ann Xiong		05/12/2023 Fixed the issue of strFieldCollectedByPerson return null when p.strFirstName or p.strSecondName or p.strFamilyName is null
--
-- Testing code:
-- EXEC USP_HUM_SAMPLES_GetList 'en', @idfHumanCase=25   --10
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_HUM_SAMPLES_GetList_With_Derivates] 
	@LangID						NVARCHAR(50) , 
	@idfHumanCase			BIGINT = NULL,
	@SearchDiagnosis 		BIGINT = NULL
AS
BEGIN
	BEGIN TRY  
		SELECT		
					Samples.idfHumanCase
					,Samples.idfMaterial 
					,Samples.strBarcode -- Lab sample ID
					,Samples.strFieldBarcode -- Local Sample ID
					,Samples.idfsSampleType
					,SampleType.name AS strSampleTypeName
					,Samples.datFieldCollectionDate
					,Samples.idfSendToOffice
					,OfficeSendTo.name AS strSendToOffice
					,Samples.idfFieldCollectedByOffice
					,CollectedByOffice.name AS strFieldCollectedByOffice
					,Samples.datFieldSentDate
					,Samples.strNote
					,Samples.datAccession			--verify this is date received
					,Samples.idfsAccessionCondition
					,acessionedCond.name AS strCondition
					,Location.idfsRegion AS idfsRegion
					,ISNULL(Region.[name], Region.strDefault) AS [strRegionName]
					,Location.idfsRayon AS idfsRayon
					,ISNULL(Rayon.[name], Rayon.strDefault) AS [strRayonName]
					,Samples.blnAccessioned
					,'' as RecordAction
					,Samples.idfsSampleKind
					,sampleKind.name AS SampleKindTypeName
					,Samples.idfsSampleStatus
					,sampleStatus.name AS SampleStatusTypeName
					,Samples.idfFieldCollectedByPerson  
					,ISNULL(p.strFirstName + ' ', '') + ISNULL(p.strSecondName, '') + ISNULL(p.strFamilyName + ' ', '') as 'strFieldCollectedByPerson'   --verify this is the employee
					,Samples.datSampleStatusDate   --verify this is the result date
					,Samples.rowGuid as sampleGuid
					,Samples.intRowStatus
					,Samples.idfsSite AS idfsSite
					,Samples.idfInDepartment as FunctionalAreaID
					,functionalArea.name as FunctionalAreaName
		FROM		dbo.tlbMaterial Samples 
		INNER JOIN	dbo.tlbHumanCase as hc ON Samples.idfHumanCase  = hc.idfHumanCase 
		LEFT JOIN	dbo.tlbGeoLocation as Location	ON Location.idfGeoLocation = hc.idfPointGeoLocation
		LEFT JOIN dbo.tlbDepartment d ON d.idfDepartment = Samples.idfInDepartment
			AND d.intRowStatus = 0
		LEFT JOIN	dbo.FN_GBL_REFERENCEREPAIR(@LangID,19000087) SampleType ON	SampleType.idfsReference = Samples.idfsSampleType
		LEFT JOIN	FN_GBL_GIS_Reference(@LangID,19000003) Region ON Region.idfsReference = Location.idfsRegion
		LEFT JOIN	FN_GBL_GIS_Reference(@LangID,19000002) Rayon ON	Rayon.idfsReference = Location.idfsRayon
		LEFT JOIN	tlbMaterial ParentSample ON	ParentSample.idfMaterial = Samples.idfParentMaterial AND ParentSample.intRowStatus = 0
		LEFT JOIN	dbo.FN_GBL_INSTITUTION(@LangID) AS CollectedByOffice ON CollectedByOffice.idfOffice = Samples.idfFieldCollectedByOffice
		LEFT JOIN	dbo.FN_GBL_INSTITUTION(@LangID) AS OfficeSendTo ON OfficeSendTo.idfOffice = Samples.idfSendToOffice
		LEFT JOIN	FN_GBL_ReferenceRepair(@LangID, 19000158) AS sampleKind	ON sampleKind.idfsReference = Samples.idfsSampleKind 
		LEFT JOIN	FN_GBL_ReferenceRepair(@LangID, 19000015) AS sampleStatus ON sampleStatus.idfsReference = Samples.idfsSampleStatus 
		LEFT JOIN	FN_GBL_ReferenceRepair(@LangID, 19000110) AS acessionedCond ON acessionedCond.idfsReference = Samples.idfsAccessionCondition 
		LEFT JOIN   FN_GBL_Repair(@LangID, 19000164) functionalArea ON functionalArea.idfsReference = d.idfsDepartmentName
		Left JOIN	dbo.tlbPerson p on p.idfPerson = Samples.idfFieldCollectedByPerson	
		--LEFT JOIN   dbo.tstSite S ON samples.idfSendToOffice = S.idfOffice AND S.intRowStatus = 0
		WHERE		
		Samples.idfHumanCase = @idfHumanCase
		AND	Samples.intRowStatus = 0
	END TRY  

	BEGIN CATCH 
		THROW
	END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_VET_DISEASE_REPORT_GETList_AVR]...';


GO
-- ================================================================================================
-- Name: USP_VET_DISEASE_REPORT_GETList
--
-- Description:	Get disease list for the farm edit/enter and other use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     03/25/2018 Initial release.
-- Stephen Long     11/09/2018 Added FarmOwnerID and FarmOwnerName for lab use case 10.
-- Stephen Long     11/25/2018 Updated for the new API.
-- Stephen Long     12/31/2018 Added pagination logic.
-- Stephen Long     04/24/2019 Added advanced search parameters to sync up with use case VUC10.
-- Stephen Long     04/29/2019 Added related to veterinary disease report fields for use case VUC11 
--                             and VUC12.
-- Stephen Long     06/14/2019 Adjusted date from's and to's to be cast as just dates with no time.
-- Stephen Long     06/22/2019 Fix to the farm address logic (building, apartment, house IIF's 
--                             to case statements).
-- Stephen Long     06/25/2019 Add group by for joins with multiple records (such as samples).
-- Stephen Long     07/20/2019 Changed farm inventory counts to ISNULL.
-- Stephen Long     09/03/2019 Add active status check on species list.
-- Ann Xiong		12/05/2019 Added EIDSSPersonID to select list and replaced "ON 
--                             caseType.idfsReference = vc.idfsCaseReportType" with 
--                             "caseType.idfsReference = vc.idfsCaseType".
-- Ann Xiong		12/10/2019 Added a parameter @PersonID NVARCHAR(200) = NULL.
-- Ann Xiong		12/19/2019 Added EIDSSFarmID to select list
-- Stephen Long     01/22/2020 Added site list parameter for site filtration.
-- Stephen Long     01/28/2020 Added non-configurable filtration rules, and legacy report ID.
-- Stephen Long     02/03/2020 Added dbo prefix and changed non-configurable filtration comments.
-- Stephen Long     02/16/2020 Removed group by and pagination applied on final query.
-- Stephen Long     02/26/2020 Added data entry site ID parameter and where clause.
-- Stephen Long     03/04/2020 Corrected where clause on total count for null species type.
-- Stephen Long     03/17/2020 Corrected farm owner ID to use idfHuman instead of idfHumanActual.
-- Stephen Long     03/25/2020 Added if/else for first-level and second-level site types to bypass 
--                             non-configurable rules.
-- Stephen Long     05/18/2020 Added disease filtration rules from use case SAUC62.
-- Stephen Long     06/18/2020 Added where criteria to the query when no site filtration is 
--                             required.
-- Stephen Long     07/07/2020 Added trim to the EIDSS identifier like criteria.
-- Stephen Long     07/08/2020 Replaced common table experssion; was not working well with POCO.
-- Stephen Long     09/24/2020 Update address fields returned (settlement, rayon and region only).
-- Stephen Long     11/18/2020 Added site ID to the query.
-- Stephen Long     11/23/2020 Added configurable site filtration rules.
-- Stephen Long     11/25/2020 Modified for new permission fields on the AccessRule table.
-- Stephen Long     11/28/2020 Add index to table variable primary key.
-- Stephen Long     12/02/2020 Remove primary key from table variable IDs.
-- Stephen Long     12/13/2020 Added apply configurable filtration indicator parameter.
-- Stephen Long     12/23/2020 Added EIDSS session ID parameter and where clause criteria.
-- Stephen Long     12/24/2020 Modified join on disease filtration default role rule.
-- Stephen Long     12/29/2020 Changed function call on reference data for inactive records.
-- Stephen Long     01/04/2021 Added option recompile due to number of optional parameters for 
--                             better execution plan.
-- Stephen Long     01/05/2021 Removed species list sub-query due to performance.  New stored 
--                             procedure added to get species list when user expands disease 
--                             report row in search.
-- Stephen Long     01/06/2021 Added string aggregate function on species list and parameter to 
--                             include.
-- Stephen Long     01/25/2021 Added order by parameter to handle when a user selected a specific 
--                             column to sort by.
-- Stephen Long     01/27/2021 Fix for order by; alias will not work on order by with case.
-- Stephen Long     04/02/2021 Added updated pagination and location hierarchy.
-- Stephen Long     01/11/2022 Added farm owner (idfHuman) ID to the query and updated location 
--                             hierarchy.
-- Mike Kornegay	01/26/2022 Changed RecordCount to TotalRowCount to match BaseModel.
-- Stephen Long     03/29/2022 Added disease ID to the model for laboratory module, and corrected 
--                             site filtration.
-- Ann Xiong		04/25/2022 Added f.idfFarm to select list for Veterinary Disease Report 
--                             Deduplication.
-- Stephen Long     05/10/2022 Added report category type ID to the query.
-- Stephen Long     06/03/2022 Updated to point default access rules to base reference.
-- Mike Kornegay	08/28/2022 Changed FarmAddress to FarmLocation and added FarmLocation.
-- Mike Kornegay    08/31/2022 Corrected sort by adding order by to final query.
-- Stephen Long     09/22/2022 Add check for "0" page size.  If "0", then set to 1.
-- Doug Albanese    01/11/2023 Modifying so that the same SP can bring back Ou
-- Stephen Long     01/13/2023 Updated for site filtration queries.
-- Edgard Torres & Keith   05/09/2023 Modified version of USP_VET_DISEASE_REPORT_GETList to return comma delimeted SiteIDs 
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_VET_DISEASE_REPORT_GETList_AVR]
	@LanguageID NVARCHAR(50)
	,@ReportKey BIGINT = NULL
	,@ReportID NVARCHAR(200) = NULL
	,@LegacyReportID NVARCHAR(200) = NULL
	,@SessionKey BIGINT = NULL
	,@FarmMasterID BIGINT = NULL
	,@DiseaseID BIGINT = NULL
	,@ReportStatusTypeID BIGINT = NULL
	,@AdministrativeLevelID BIGINT = NULL
	,@DateEnteredFrom DATE = NULL
	,@DateEnteredTo DATE = NULL
	,@ClassificationTypeID BIGINT = NULL
	,@PersonID NVARCHAR(200) = NULL
	,@ReportTypeID BIGINT = NULL
	,@SpeciesTypeID BIGINT = NULL
	,@OutbreakCasesIndicator BIT = 0
	,@DiagnosisDateFrom DATE = NULL
	,@DiagnosisDateTo DATE = NULL
	,@InvestigationDateFrom DATE = NULL
	,@InvestigationDateTo DATE = NULL
	,@LocalOrFieldSampleID NVARCHAR(200) = NULL
	,@TotalAnimalQuantityFrom INT = NULL
	,@TotalAnimalQuantityTo INT = NULL
	,@SessionID NVARCHAR(200) = NULL
	,@DataEntrySiteID BIGINT = NULL
	,@UserSiteID BIGINT
	,@UserOrganizationID BIGINT
	,@UserEmployeeID BIGINT
	,@ApplySiteFiltrationIndicator BIT = 0
	,@IncludeSpeciesListIndicator BIT = 0
	,@SortColumn NVARCHAR(30) = 'ReportID'
	,@SortOrder NVARCHAR(4) = 'DESC'
	,@PageNumber INT = 1
	,@PageSize INT = 10
	,@OutbreakCaseReportOnly INT = 0
	,@SiteIDs NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @firstRec INT;
    DECLARE @lastRec INT;

    SET @firstRec = (@PageNumber - 1) * @PageSize;
    SET @lastRec = (@PageNumber * @PageSize + 1);

	DECLARE @AdministrativeLevelNode AS HIERARCHYID;
    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL, INDEX IDX_ID (ID
                                                             ));
    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @UserSitePermissions TABLE
    (
        SiteID BIGINT NOT NULL,
        PermissionTypeID BIGINT NOT NULL,
        Permission INT NOT NULL
    );
    DECLARE @UserGroupSitePermissions TABLE
    (
        SiteID BIGINT NOT NULL,
        PermissionTypeID BIGINT NOT NULL,
        Permission INT NOT NULL
    );

	BEGIN TRY
	        INSERT INTO @UserGroupSitePermissions
        SELECT oa.idfsOnSite,
               oa.idfsObjectOperation,
               CASE
                   WHEN oa.intPermission = 2 THEN
                       3
                   ELSE
                       2
               END
        FROM dbo.tstObjectAccess oa
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE oa.intRowStatus = 0
              AND oa.idfsObjectType = 10060011 -- Site
              AND oa.idfActor = egm.idfEmployeeGroup;

        INSERT INTO @UserSitePermissions
        SELECT oa.idfsOnSite,
               oa.idfsObjectOperation,
               CASE
                   WHEN oa.intPermission = 2 THEN
                       5
                   ELSE
                       4
               END
        FROM dbo.tstObjectAccess oa
        WHERE oa.intRowStatus = 0
              AND oa.idfsObjectType = 10060011 -- Site
              AND oa.idfActor = @UserEmployeeID;

	    IF @PageSize = 0
        BEGIN
            SET @PageSize = 1;
        END

		IF @AdministrativeLevelID IS NOT NULL
		BEGIN
			SELECT @AdministrativeLevelNode = node
			FROM dbo.gisLocation
			WHERE idfsLocation = @AdministrativeLevelID;
		END;

        -- ========================================================================================
        -- NO CONFIGURABLE FILTRATION RULES APPLIED
        --
        -- For first and second level sites, do not apply any site filtration rules.
        -- ========================================================================================
		IF @ApplySiteFiltrationIndicator = 0
		BEGIN
			INSERT INTO @Results
			SELECT v.idfVetCase
				,1
				,1
				,1
				,1
				,1
			FROM dbo.tlbVetCase v
			INNER JOIN dbo.tlbFarm f ON f.idfFarm = v.idfFarm
			LEFT JOIN dbo.tlbHuman h ON h.idfHuman = f.idfHuman
			LEFT JOIN dbo.HumanActualAddlInfo haai ON haai.HumanActualAddlInfoUID = h.idfHumanActual
			LEFT JOIN dbo.tlbGeoLocation gl ON gl.idfGeoLocation = f.idfFarmAddress
			LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gl.idfsLocation
			LEFT JOIN dbo.tlbMaterial m ON m.idfVetCase = v.idfVetCase
			LEFT JOIN dbo.tlbMonitoringSession ms ON ms.idfMonitoringSession = v.idfParentMonitoringSession
			WHERE v.intRowStatus = 0
				AND (
					f.idfFarmActual = @FarmMasterID
					OR @FarmMasterID IS NULL
					)
				AND (
					v.idfVetCase = @ReportKey
					OR @ReportKey IS NULL
					)
				AND (
					v.idfParentMonitoringSession = @SessionKey
					OR @SessionKey IS NULL
					)
				AND (
					g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
					OR @AdministrativeLevelID IS NULL
					)
				AND (
					v.idfsFinalDiagnosis = @DiseaseID
					OR @DiseaseID IS NULL
					)
				AND (
					v.idfsCaseClassification = @ClassificationTypeID
					OR @ClassificationTypeID IS NULL
					)
				AND (
					v.idfsCaseProgressStatus = @ReportStatusTypeID
					OR @ReportStatusTypeID IS NULL
					)
				AND (
					(
						CAST(v.datEnteredDate AS DATE) BETWEEN @DateEnteredFrom
							AND @DateEnteredTo
						)
					OR (
						@DateEnteredFrom IS NULL
						OR @DateEnteredTo IS NULL
						)
					)
				AND (
					v.idfsCaseReportType = @ReportTypeID
					OR @ReportTypeID IS NULL
					)
				AND (
					v.idfsCaseType = @SpeciesTypeID
					OR @SpeciesTypeID IS NULL
					)
				AND (
					(
						CAST(v.datFinalDiagnosisDate AS DATE) BETWEEN @DiagnosisDateFrom
							AND @DiagnosisDateTo
						)
					OR (
						@DiagnosisDateFrom IS NULL
						OR @DiagnosisDateTo IS NULL
						)
					)
				AND (
					(
						CAST(v.datInvestigationDate AS DATE) BETWEEN @InvestigationDateFrom
							AND @InvestigationDateTo
						)
					OR (
						@InvestigationDateFrom IS NULL
						OR @InvestigationDateTo IS NULL
						)
					)
				AND (
					(
						(
							f.intAvianTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
								AND @TotalAnimalQuantityTo
							)
						OR (
							f.intLivestockTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
								AND @TotalAnimalQuantityTo
							)
						)
					OR (
						@TotalAnimalQuantityFrom IS NULL
						OR @TotalAnimalQuantityTo IS NULL
						)
					)
				AND (
					(
						v.idfOutbreak IS NULL
						AND @OutbreakCasesIndicator = 0
						)
					OR (
						v.idfOutbreak IS NOT NULL
						AND @OutbreakCasesIndicator = 1
						)
					OR (@OutbreakCasesIndicator IS NULL)
					)
				AND (
					v.idfsSite = @DataEntrySiteID
					OR @DataEntrySiteID IS NULL
					)
				AND (
					v.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
					OR @ReportID IS NULL
					)
				AND (
					v.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
					OR @LegacyReportID IS NULL
					)
				AND (
					haai.EIDSSPersonID LIKE '%' + TRIM(@PersonID) + '%'
					OR @PersonID IS NULL
					)
				AND (
					m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
					OR @LocalOrFieldSampleID IS NULL
					)
				AND (
					ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
					OR @SessionID IS NULL
					)
			GROUP BY v.idfVetCase;
		END
		ELSE
		BEGIN
		INSERT INTO @Results
			SELECT v.idfVetCase
				,1
				,1
				,1
				,1
				,1
			FROM dbo.tlbVetCase v
			INNER JOIN dbo.tlbFarm f ON f.idfFarm = v.idfFarm
			LEFT JOIN dbo.tlbHuman h ON h.idfHuman = f.idfHuman
			LEFT JOIN dbo.HumanActualAddlInfo haai ON haai.HumanActualAddlInfoUID = h.idfHumanActual
			LEFT JOIN dbo.tlbGeoLocation gl ON gl.idfGeoLocation = f.idfFarmAddress
			LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gl.idfsLocation
			LEFT JOIN dbo.tlbMaterial m ON m.idfVetCase = v.idfVetCase
			LEFT JOIN dbo.tlbMonitoringSession ms ON ms.idfMonitoringSession = v.idfParentMonitoringSession
			WHERE v.intRowStatus = 0
				AND v.idfsSite = @UserSiteID 
				AND (
					f.idfFarmActual = @FarmMasterID
					OR @FarmMasterID IS NULL
					)
				AND (
					v.idfVetCase = @ReportKey
					OR @ReportKey IS NULL
					)
				AND (
					v.idfParentMonitoringSession = @SessionKey
					OR @SessionKey IS NULL
					)
				AND (
					g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
					OR @AdministrativeLevelID IS NULL
					)
				AND (
					v.idfsFinalDiagnosis = @DiseaseID
					OR @DiseaseID IS NULL
					)
				AND (
					v.idfsCaseClassification = @ClassificationTypeID
					OR @ClassificationTypeID IS NULL
					)
				AND (
					v.idfsCaseProgressStatus = @ReportStatusTypeID
					OR @ReportStatusTypeID IS NULL
					)
				AND (
					(
						CAST(v.datEnteredDate AS DATE) BETWEEN @DateEnteredFrom
							AND @DateEnteredTo
						)
					OR (
						@DateEnteredFrom IS NULL
						OR @DateEnteredTo IS NULL
						)
					)
				AND (
					v.idfsCaseReportType = @ReportTypeID
					OR @ReportTypeID IS NULL
					)
				AND (
					v.idfsCaseType = @SpeciesTypeID
					OR @SpeciesTypeID IS NULL
					)
				AND (
					(
						CAST(v.datFinalDiagnosisDate AS DATE) BETWEEN @DiagnosisDateFrom
							AND @DiagnosisDateTo
						)
					OR (
						@DiagnosisDateFrom IS NULL
						OR @DiagnosisDateTo IS NULL
						)
					)
				AND (
					(
						CAST(v.datInvestigationDate AS DATE) BETWEEN @InvestigationDateFrom
							AND @InvestigationDateTo
						)
					OR (
						@InvestigationDateFrom IS NULL
						OR @InvestigationDateTo IS NULL
						)
					)
				AND (
					(
						(
							f.intAvianTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
								AND @TotalAnimalQuantityTo
							)
						OR (
							f.intLivestockTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
								AND @TotalAnimalQuantityTo
							)
						)
					OR (
						@TotalAnimalQuantityFrom IS NULL
						OR @TotalAnimalQuantityTo IS NULL
						)
					)
				AND (
					(
						v.idfOutbreak IS NULL
						AND @OutbreakCasesIndicator = 0
						)
					OR (
						v.idfOutbreak IS NOT NULL
						AND @OutbreakCasesIndicator = 1
						)
					OR (@OutbreakCasesIndicator IS NULL)
					)
				AND (
					v.idfsSite = @DataEntrySiteID
					OR @DataEntrySiteID IS NULL
					)
				AND (
					v.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
					OR @ReportID IS NULL
					)
				AND (
					v.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
					OR @LegacyReportID IS NULL
					)
				AND (
					haai.EIDSSPersonID LIKE '%' + TRIM(@PersonID) + '%'
					OR @PersonID IS NULL
					)
				AND (
					m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
					OR @LocalOrFieldSampleID IS NULL
					)
				AND (
					ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
					OR @SessionID IS NULL
					)
			GROUP BY v.idfVetCase;

			DECLARE @FilteredResults TABLE (
				ID BIGINT NOT NULL
				,ReadPermissionIndicator INT NOT NULL
				,AccessToPersonalDataPermissionIndicator INT NOT NULL
				,AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL
				,WritePermissionIndicator INT NOT NULL
				,DeletePermissionIndicator INT NOT NULL
				,INDEX IDX_ID(ID)
				);

            -- =======================================================================================
            -- DEFAULT CONFIGURABLE FILTRATION RULES
            --
            -- Apply active default filtration rules for third level sites.
            -- =======================================================================================
			DECLARE @RuleActiveStatus INT = 0;
			DECLARE @AdministrativeLevelTypeID INT;
			DECLARE @OrganizationAdministrativeLevelNode HIERARCHYID;
			DECLARE @DefaultAccessRules TABLE (
				AccessRuleID BIGINT NOT NULL,
				ActiveIndicator INT NOT NULL
				,ReadPermissionIndicator INT NOT NULL
				,AccessToPersonalDataPermissionIndicator INT NOT NULL
				,AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL
				,WritePermissionIndicator INT NOT NULL
				,DeletePermissionIndicator INT NOT NULL
				,AdministrativeLevelTypeID INT NULL
				);

			INSERT INTO @DefaultAccessRules
			SELECT AccessRuleID
			    ,a.intRowStatus
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
				,a.AdministrativeLevelTypeID
			FROM dbo.AccessRule a
			WHERE DefaultRuleIndicator = 1;

			--
			-- Report data shall be available to all sites of the same administrative level 
			-- specified in the rule.
			--
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
			WHERE AccessRuleID = 10537009;

			IF @RuleActiveStatus = 0
			BEGIN
				SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
				FROM @DefaultAccessRules
				WHERE AccessRuleID = 10537009;

				SELECT @OrganizationAdministrativeLevelNode = g.node.GetAncestor(g.node.GetLevel() - @AdministrativeLevelTypeID)
				FROM dbo.tlbOffice o
				INNER JOIN dbo.tlbGeoLocationShared l ON l.idfGeoLocationShared = o.idfLocation
				INNER JOIN dbo.gisLocation g ON g.idfsLocation = l.idfsLocation
				WHERE o.idfOffice = @UserOrganizationID
					AND g.node.GetLevel() >= @AdministrativeLevelTypeID;

				-- Administrative level specified in the rule of the site where the report was created.
				INSERT INTO @FilteredResults
				SELECT v.idfVetCase
					,a.ReadPermissionIndicator
					,a.AccessToPersonalDataPermissionIndicator
					,a.AccessToGenderAndAgeDataPermissionIndicator
					,a.WritePermissionIndicator
					,a.DeletePermissionIndicator
				FROM dbo.tlbVetCase v
				INNER JOIN dbo.tstSite s ON v.idfsSite = s.idfsSite
				INNER JOIN dbo.tlbOffice o ON o.idfOffice = s.idfOffice
				INNER JOIN dbo.tlbGeoLocationShared l ON l.idfGeoLocationShared = o.idfLocation
				INNER JOIN dbo.gisLocation g ON g.idfsLocation = l.idfsLocation
				INNER JOIN @DefaultAccessRules a ON a.AccessRuleID = 10537009
				WHERE v.intRowStatus = 0
					AND (
						v.idfsCaseType = @SpeciesTypeID
						OR @SpeciesTypeID IS NULL
						)
					AND (
						(
							CAST(v.datEnteredDate AS DATE) BETWEEN @DateEnteredFrom
								AND @DateEnteredTo
							)
						OR (
							@DateEnteredFrom IS NULL
							OR @DateEnteredTo IS NULL
							)
						)
					AND g.node.IsDescendantOf(@OrganizationAdministrativeLevelNode) = 1;

				-- Administrative level specified in the rule of the farm address.
				INSERT INTO @FilteredResults
				SELECT v.idfVetCase
					,a.ReadPermissionIndicator
					,a.AccessToPersonalDataPermissionIndicator
					,a.AccessToGenderAndAgeDataPermissionIndicator
					,a.WritePermissionIndicator
					,a.DeletePermissionIndicator
				FROM dbo.tlbVetCase v
				INNER JOIN dbo.tlbFarm f ON f.idfFarm = v.idfFarm
				INNER JOIN dbo.tlbGeoLocation l ON l.idfGeoLocation = f.idfFarmAddress
				INNER JOIN dbo.gisLocation g ON g.idfsLocation = l.idfsLocation
				INNER JOIN @DefaultAccessRules a ON a.AccessRuleID = 10537009
				WHERE v.intRowStatus = 0
					AND (
						v.idfsCaseType = @SpeciesTypeID
						OR @SpeciesTypeID IS NULL
						)
					AND (
						(
							CAST(v.datEnteredDate AS DATE) BETWEEN @DateEnteredFrom
								AND @DateEnteredTo
							)
						OR (
							@DateEnteredFrom IS NULL
							OR @DateEnteredTo IS NULL
							)
						)
					AND g.node.IsDescendantOf(@OrganizationAdministrativeLevelNode) = 1;
			END;

			--
			-- Report data shall be available to all sites' organizations connected to the particular report.
			--
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
			WHERE AccessRuleID = 10537010;

			IF @RuleActiveStatus = 0
			BEGIN
				-- Investigated and reported by organizations
				INSERT INTO @FilteredResults
				SELECT v.idfVetCase
					,a.ReadPermissionIndicator
					,a.AccessToPersonalDataPermissionIndicator
					,a.AccessToGenderAndAgeDataPermissionIndicator
					,a.WritePermissionIndicator
					,a.DeletePermissionIndicator
				FROM dbo.tlbVetCase v
				INNER JOIN @DefaultAccessRules a ON a.AccessRuleID = 10537010
				WHERE (v.intRowStatus = 0)
					AND (
						v.idfInvestigatedByOffice = @UserOrganizationID
						OR v.idfReportedByOffice = @UserOrganizationID
						);

				-- Sample collected by and sent to organizations
				INSERT INTO @FilteredResults
				SELECT MAX(m.idfVetCase)
					,a.ReadPermissionIndicator
					,a.AccessToPersonalDataPermissionIndicator
					,a.AccessToGenderAndAgeDataPermissionIndicator
					,a.WritePermissionIndicator
					,a.DeletePermissionIndicator
				FROM dbo.tlbMaterial m
				INNER JOIN dbo.tlbVetCase v ON v.idfVetCase = m.idfVetCase
					AND v.intRowStatus = 0
				INNER JOIN @DefaultAccessRules a ON a.AccessRuleID = 10537010
				WHERE m.intRowStatus = 0
					AND (
						m.idfFieldCollectedByOffice = @UserOrganizationID
						OR m.idfSendToOffice = @UserOrganizationID
						)
				GROUP BY m.idfVetCase
					,a.ReadPermissionIndicator
					,a.AccessToPersonalDataPermissionIndicator
					,a.AccessToGenderAndAgeDataPermissionIndicator
					,a.WritePermissionIndicator
					,a.DeletePermissionIndicator;

				-- Sample transferred to organizations
				INSERT INTO @FilteredResults
				SELECT MAX(m.idfVetCase)
					,a.ReadPermissionIndicator
					,a.AccessToPersonalDataPermissionIndicator
					,a.AccessToGenderAndAgeDataPermissionIndicator
					,a.WritePermissionIndicator
					,a.DeletePermissionIndicator
				FROM dbo.tlbMaterial m
				INNER JOIN dbo.tlbVetCase v ON v.idfVetCase = m.idfVetCase
					AND v.intRowStatus = 0
				INNER JOIN dbo.tlbTransferOutMaterial tom ON m.idfMaterial = tom.idfMaterial
					AND tom.intRowStatus = 0
				INNER JOIN dbo.tlbTransferOUT t ON tom.idfTransferOut = t.idfTransferOut
					AND t.intRowStatus = 0
				INNER JOIN @DefaultAccessRules a ON a.AccessRuleID = 10537010
				WHERE m.intRowStatus = 0
					AND t.idfSendToOffice = @UserOrganizationID
				GROUP BY m.idfVetCase
					,a.ReadPermissionIndicator
					,a.AccessToPersonalDataPermissionIndicator
					,a.AccessToGenderAndAgeDataPermissionIndicator
					,a.WritePermissionIndicator
					,a.DeletePermissionIndicator;
			END;

			--
			-- Report data shall be available to the sites with the connected outbreak, if the report 
			-- is the primary report/session for an outbreak.
			--
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
			WHERE AccessRuleID = 10537011;

			IF @RuleActiveStatus = 0
			BEGIN
				INSERT INTO @FilteredResults
				SELECT v.idfVetCase
					,a.ReadPermissionIndicator
					,a.AccessToPersonalDataPermissionIndicator
					,a.AccessToGenderAndAgeDataPermissionIndicator
					,a.WritePermissionIndicator
					,a.DeletePermissionIndicator
				FROM dbo.tlbVetCase v
				INNER JOIN dbo.tlbOutbreak o ON v.idfVetCase = o.idfPrimaryCaseOrSession
					AND o.intRowStatus = 0
				INNER JOIN @DefaultAccessRules a ON a.AccessRuleID = 10537011
				WHERE v.intRowStatus = 0
					AND o.idfsSite = @UserSiteID
			END;

            -- =======================================================================================
            -- CONFIGURABLE FILTRATION RULES
            -- 
            -- Apply configurable filtration rules for use case SAUC34. Some of these rules may 
            -- overlap the default rules.
            -- =======================================================================================
			--
			-- Apply at the user's site group level, granted by a site group.
			--
			INSERT INTO @FilteredResults
			SELECT v.idfVetCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbVetCase v
			INNER JOIN dbo.tflSiteToSiteGroup grantingSGS ON grantingSGS.idfsSite = v.idfsSite
			INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup ON userSiteGroup.idfsSite = @UserSiteID
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE v.intRowStatus = 0
				AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

			--
			-- Apply at the user's site level, granted by a site group.
			--
			INSERT INTO @FilteredResults
			SELECT v.idfVetCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbVetCase v
			INNER JOIN dbo.tflSiteToSiteGroup grantingSGS ON grantingSGS.idfsSite = v.idfsSite
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorSiteID = @UserSiteID
				AND ara.ActorEmployeeGroupID IS NULL
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE v.intRowStatus = 0
				AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

			-- 
			-- Apply at the user's employee group level, granted by a site group.
			--
			INSERT INTO @FilteredResults
			SELECT v.idfVetCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbVetCase v
			INNER JOIN dbo.tflSiteToSiteGroup grantingSGS ON grantingSGS.idfsSite = v.idfsSite
			INNER JOIN dbo.tlbEmployeeGroupMember egm ON egm.idfEmployee = @UserEmployeeID
				AND egm.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE v.intRowStatus = 0
				AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

			-- 
			-- Apply at the user's ID level, granted by a site group.
			--
			INSERT INTO @FilteredResults
			SELECT v.idfVetCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbVetCase v
			INNER JOIN dbo.tflSiteToSiteGroup grantingSGS ON grantingSGS.idfsSite = v.idfsSite
			INNER JOIN dbo.tstUserTable u ON u.idfPerson = @UserEmployeeID
				AND u.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorUserID = u.idfUserID
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE v.intRowStatus = 0
				AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

			--
			-- Apply at the user's site group level, granted by a site.
			--
			INSERT INTO @FilteredResults
			SELECT v.idfVetCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbVetCase v
			INNER JOIN dbo.tflSiteToSiteGroup sgs ON sgs.idfsSite = @UserSiteID
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorSiteGroupID = sgs.idfSiteGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE v.intRowStatus = 0
				AND sgs.idfsSite = v.idfsSite;

			-- 
			-- Apply at the user's site level, granted by a site.
			--
			INSERT INTO @FilteredResults
			SELECT v.idfVetCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbVetCase v
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorSiteID = @UserSiteID
				AND ara.ActorEmployeeGroupID IS NULL
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE v.intRowStatus = 0
				AND a.GrantingActorSiteID = v.idfsSite;

			-- 
			-- Apply at the user's employee group level, granted by a site.
			--
			INSERT INTO @FilteredResults
			SELECT v.idfVetCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbVetCase v
			INNER JOIN dbo.tlbEmployeeGroupMember egm ON egm.idfEmployee = @UserEmployeeID
				AND egm.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE v.intRowStatus = 0
				AND a.GrantingActorSiteID = v.idfsSite;

			-- 
			-- Apply at the user's ID level, granted by a site.
			--
			INSERT INTO @FilteredResults
			SELECT v.idfVetCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbVetCase v
			INNER JOIN dbo.tstUserTable u ON u.idfPerson = @UserEmployeeID
				AND u.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorUserID = u.idfUserID
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE v.intRowStatus = 0
				AND a.GrantingActorSiteID = v.idfsSite;

			-- Copy filtered results to results and use search criteria
			INSERT INTO @Results
			SELECT ID
				,ReadPermissionIndicator
				,AccessToPersonalDataPermissionIndicator
				,AccessToGenderAndAgeDataPermissionIndicator
				,WritePermissionIndicator
				,DeletePermissionIndicator
			FROM @FilteredResults
			INNER JOIN dbo.tlbVetCase v ON v.idfVetCase = ID
			INNER JOIN dbo.tlbFarm f ON f.idfFarm = v.idfFarm
			LEFT JOIN dbo.tlbHuman h ON h.idfHuman = f.idfHuman
			LEFT JOIN dbo.HumanActualAddlInfo haai ON haai.HumanActualAddlInfoUID = h.idfHumanActual
			LEFT JOIN dbo.tlbGeoLocation gl ON gl.idfGeoLocation = f.idfFarmAddress
			LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gl.idfsLocation
			LEFT JOIN dbo.tlbMaterial m ON m.idfVetCase = v.idfVetCase
			LEFT JOIN dbo.tlbMonitoringSession ms ON ms.idfMonitoringSession = v.idfParentMonitoringSession
			WHERE v.intRowStatus = 0
				AND (
					f.idfFarmActual = @FarmMasterID
					OR @FarmMasterID IS NULL
					)
				AND (
					v.idfVetCase = @ReportKey
					OR @ReportKey IS NULL
					)
				AND (
					v.idfParentMonitoringSession = @SessionKey
					OR @SessionKey IS NULL
					)
				AND (
					g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
					OR @AdministrativeLevelID IS NULL
					)
				AND (
					v.idfsFinalDiagnosis = @DiseaseID
					OR @DiseaseID IS NULL
					)
				AND (
					v.idfsCaseClassification = @ClassificationTypeID
					OR @ClassificationTypeID IS NULL
					)
				AND (
					v.idfsCaseProgressStatus = @ReportStatusTypeID
					OR @ReportStatusTypeID IS NULL
					)
				AND (
					(
						CAST(v.datEnteredDate AS DATE) BETWEEN @DateEnteredFrom
							AND @DateEnteredTo
						)
					OR (
						@DateEnteredFrom IS NULL
						OR @DateEnteredTo IS NULL
						)
					)
				AND (
					v.idfsCaseReportType = @ReportTypeID
					OR @ReportTypeID IS NULL
					)
				AND (
					v.idfsCaseType = @SpeciesTypeID
					OR @SpeciesTypeID IS NULL
					)
				AND (
					(
						CAST(v.datFinalDiagnosisDate AS DATE) BETWEEN @DiagnosisDateFrom
							AND @DiagnosisDateTo
						)
					OR (
						@DiagnosisDateFrom IS NULL
						OR @DiagnosisDateTo IS NULL
						)
					)
				AND (
					(
						CAST(v.datInvestigationDate AS DATE) BETWEEN @InvestigationDateFrom
							AND @InvestigationDateTo
						)
					OR (
						@InvestigationDateFrom IS NULL
						OR @InvestigationDateTo IS NULL
						)
					)
				AND (
					(
						(
							f.intAvianTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
								AND @TotalAnimalQuantityTo
							)
						OR (
							f.intLivestockTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
								AND @TotalAnimalQuantityTo
							)
						)
					OR (
						@TotalAnimalQuantityFrom IS NULL
						OR @TotalAnimalQuantityTo IS NULL
						)
					)
				AND (
					(
						v.idfOutbreak IS NULL
						AND @OutbreakCasesIndicator = 0
						)
					OR (
						v.idfOutbreak IS NOT NULL
						AND @OutbreakCasesIndicator = 1
						)
					OR (@OutbreakCasesIndicator IS NULL)
					)
				AND (
					v.idfsSite = @DataEntrySiteID
					OR @DataEntrySiteID IS NULL
					)
				AND (
					v.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
					OR @ReportID IS NULL
					)
				AND (
					v.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
					OR @LegacyReportID IS NULL
					)
				AND (
					haai.EIDSSPersonID LIKE '%' + TRIM(@PersonID) + '%'
					OR @PersonID IS NULL
					)
				AND (
					m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
					OR @LocalOrFieldSampleID IS NULL
					)
				AND (
					ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
					OR @SessionID IS NULL
					)
			GROUP BY ID
				,ReadPermissionIndicator
				,AccessToPersonalDataPermissionIndicator
				,AccessToGenderAndAgeDataPermissionIndicator
				,WritePermissionIndicator
				,DeletePermissionIndicator;
		END;

		-- =======================================================================================
		-- DISEASE FILTRATION RULES
		--
		-- Apply disease filtration rules from use case SAUC62.
		-- =======================================================================================
		-- 
		-- Apply level 0 disease filtration rules for the employee default user group - Denies ONLY
		-- as all records have been pulled above with or without site filtration rules applied.
		--
		DELETE
		FROM @Results
		WHERE ID IN (
				SELECT v.idfVetCase
				FROM dbo.tlbVetCase v
				INNER JOIN dbo.tstObjectAccess oa ON oa.idfsObjectID = v.idfsFinalDiagnosis
					AND oa.intRowStatus = 0
				WHERE oa.intPermission = 1
					AND oa.idfActor = - 506 -- Default role
				);

		--
		-- Apply level 1 disease filtration rules for an employee's associated user group(s).  
		-- Allows and denies will supersede level 0.
		--
		INSERT INTO @Results
		SELECT v.idfVetCase
			,1
			,1
			,1
			,1
			,1
		FROM dbo.tlbVetCase v
		INNER JOIN dbo.tstObjectAccess oa ON oa.idfsObjectID = v.idfsFinalDiagnosis
			AND oa.intRowStatus = 0
		INNER JOIN dbo.tlbEmployeeGroupMember egm ON egm.idfEmployee = @UserEmployeeID
			AND egm.intRowStatus = 0
		INNER JOIN dbo.tlbFarm f ON f.idfFarm = v.idfFarm
		LEFT JOIN dbo.tlbHuman h ON h.idfHuman = f.idfHuman
		LEFT JOIN dbo.HumanActualAddlInfo haai ON haai.HumanActualAddlInfoUID = h.idfHumanActual
		LEFT JOIN dbo.tlbGeoLocation gl ON gl.idfGeoLocation = f.idfFarmAddress
		LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gl.idfsLocation
		LEFT JOIN dbo.tlbMaterial m ON m.idfVetCase = v.idfVetCase
			AND m.intRowStatus = 0
		LEFT JOIN dbo.tlbMonitoringSession ms ON ms.idfMonitoringSession = v.idfParentMonitoringSession
			AND ms.intRowStatus = 0
		WHERE oa.intPermission = 2 -- Allow permission
			AND v.intRowStatus = 0
			AND oa.idfActor = egm.idfEmployeeGroup
			AND (
				f.idfFarmActual = @FarmMasterID
				OR @FarmMasterID IS NULL
				)
			AND (
				v.idfVetCase = @ReportKey
				OR @ReportKey IS NULL
				)
			AND (
				v.idfParentMonitoringSession = @SessionKey
				OR @SessionKey IS NULL
				)
			AND (
				g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
				OR @AdministrativeLevelID IS NULL
				)
			AND (
				v.idfsFinalDiagnosis = @DiseaseID
				OR @DiseaseID IS NULL
				)
			AND (
				v.idfsCaseClassification = @ClassificationTypeID
				OR @ClassificationTypeID IS NULL
				)
			AND (
				v.idfsCaseProgressStatus = @ReportStatusTypeID
				OR @ReportStatusTypeID IS NULL
				)
			AND (
				(
					CAST(v.datEnteredDate AS DATE) BETWEEN @DateEnteredFrom
						AND @DateEnteredTo
					)
				OR (
					@DateEnteredFrom IS NULL
					OR @DateEnteredTo IS NULL
					)
				)
			AND (
				v.idfsCaseReportType = @ReportTypeID
				OR @ReportTypeID IS NULL
				)
			AND (
				v.idfsCaseType = @SpeciesTypeID
				OR @SpeciesTypeID IS NULL
				)
			AND (
				(
					CAST(v.datFinalDiagnosisDate AS DATE) BETWEEN @DiagnosisDateFrom
						AND @DiagnosisDateTo
					)
				OR (
					@DiagnosisDateFrom IS NULL
					OR @DiagnosisDateTo IS NULL
					)
				)
			AND (
				(
					CAST(v.datInvestigationDate AS DATE) BETWEEN @InvestigationDateFrom
						AND @InvestigationDateTo
					)
				OR (
					@InvestigationDateFrom IS NULL
					OR @InvestigationDateTo IS NULL
					)
				)
			AND (
				(
					(
						f.intAvianTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
							AND @TotalAnimalQuantityTo
						)
					OR (
						f.intLivestockTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
							AND @TotalAnimalQuantityTo
						)
					)
				OR (
					@TotalAnimalQuantityFrom IS NULL
					OR @TotalAnimalQuantityTo IS NULL
					)
				)
			AND (
				(
					v.idfOutbreak IS NULL
					AND @OutbreakCasesIndicator = 0
					)
				OR (
					v.idfOutbreak IS NOT NULL
					AND @OutbreakCasesIndicator = 1
					)
				OR (@OutbreakCasesIndicator IS NULL)
				)
			AND (
				v.idfsSite = @DataEntrySiteID
				OR @DataEntrySiteID IS NULL
				)
			AND (
				v.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
				OR @ReportID IS NULL
				)
			AND (
				v.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
				OR @LegacyReportID IS NULL
				)
			AND (
				haai.EIDSSPersonID LIKE '%' + TRIM(@PersonID) + '%'
				OR @PersonID IS NULL
				)
			AND (
				m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
				OR @LocalOrFieldSampleID IS NULL
				)
			AND (
				ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
				OR @SessionID IS NULL
				)
		GROUP BY v.idfVetCase;

		DELETE res
		FROM @Results res
		INNER JOIN dbo.tlbVetCase v ON v.idfVetCase = res.ID
		INNER JOIN dbo.tlbEmployeeGroupMember egm ON egm.idfEmployee = @UserEmployeeID
			AND egm.intRowStatus = 0
		INNER JOIN dbo.tstObjectAccess oa ON oa.idfsObjectID = v.idfsFinalDiagnosis
			AND oa.intRowStatus = 0
		WHERE oa.intPermission = 1
			AND oa.idfsObjectType = 10060001 -- Disease
			AND oa.idfActor = egm.idfEmployeeGroup;

		--
		-- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
		-- will supersede level 1.
		--
		INSERT INTO @Results
		SELECT v.idfVetCase
			,1
			,1
			,1
			,1
			,1
		FROM dbo.tlbVetCase v
		INNER JOIN dbo.tstObjectAccess oa ON oa.idfsObjectID = v.idfsFinalDiagnosis
			AND oa.intRowStatus = 0
		INNER JOIN dbo.tlbFarm f ON f.idfFarm = v.idfFarm
		LEFT JOIN dbo.tlbHuman h ON h.idfHuman = f.idfHuman
		LEFT JOIN dbo.HumanActualAddlInfo haai ON haai.HumanActualAddlInfoUID = h.idfHumanActual
		LEFT JOIN dbo.tlbGeoLocation gl ON gl.idfGeoLocation = f.idfFarmAddress
		LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gl.idfsLocation
		LEFT JOIN dbo.tlbMaterial m ON m.idfVetCase = v.idfVetCase
			AND m.intRowStatus = 0
		LEFT JOIN dbo.tlbMonitoringSession ms ON ms.idfMonitoringSession = v.idfParentMonitoringSession
			AND ms.intRowStatus = 0
		WHERE oa.intPermission = 2 -- Allow permission
			AND v.intRowStatus = 0
			AND oa.idfsObjectType = 10060001 -- Disease
			AND oa.idfActor = @UserEmployeeID
			AND (
				f.idfFarmActual = @FarmMasterID
				OR @FarmMasterID IS NULL
				)
			AND (
				v.idfVetCase = @ReportKey
				OR @ReportKey IS NULL
				)
			AND (
				v.idfParentMonitoringSession = @SessionKey
				OR @SessionKey IS NULL
				)
			AND (
				g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
				OR @AdministrativeLevelID IS NULL
				)
			AND (
				v.idfsFinalDiagnosis = @DiseaseID
				OR @DiseaseID IS NULL
				)
			AND (
				v.idfsCaseClassification = @ClassificationTypeID
				OR @ClassificationTypeID IS NULL
				)
			AND (
				v.idfsCaseProgressStatus = @ReportStatusTypeID
				OR @ReportStatusTypeID IS NULL
				)
			AND (
				(
					CAST(v.datEnteredDate AS DATE) BETWEEN @DateEnteredFrom
						AND @DateEnteredTo
					)
				OR (
					@DateEnteredFrom IS NULL
					OR @DateEnteredTo IS NULL
					)
				)
			AND (
				v.idfsCaseReportType = @ReportTypeID
				OR @ReportTypeID IS NULL
				)
			AND (
				v.idfsCaseType = @SpeciesTypeID
				OR @SpeciesTypeID IS NULL
				)
			AND (
				(
					CAST(v.datFinalDiagnosisDate AS DATE) BETWEEN @DiagnosisDateFrom
						AND @DiagnosisDateTo
					)
				OR (
					@DiagnosisDateFrom IS NULL
					OR @DiagnosisDateTo IS NULL
					)
				)
			AND (
				(
					CAST(v.datInvestigationDate AS DATE) BETWEEN @InvestigationDateFrom
						AND @InvestigationDateTo
					)
				OR (
					@InvestigationDateFrom IS NULL
					OR @InvestigationDateTo IS NULL
					)
				)
			AND (
				(
					(
						f.intAvianTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
							AND @TotalAnimalQuantityTo
						)
					OR (
						f.intLivestockTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
							AND @TotalAnimalQuantityTo
						)
					)
				OR (
					@TotalAnimalQuantityFrom IS NULL
					OR @TotalAnimalQuantityTo IS NULL
					)
				)
			AND (
				(
					v.idfOutbreak IS NULL
					AND @OutbreakCasesIndicator = 0
					)
				OR (
					v.idfOutbreak IS NOT NULL
					AND @OutbreakCasesIndicator = 1
					)
				OR (@OutbreakCasesIndicator IS NULL)
				)
			AND (
				v.idfsSite = @DataEntrySiteID
				OR @DataEntrySiteID IS NULL
				)
			AND (
				v.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
				OR @ReportID IS NULL
				)
			AND (
				v.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
				OR @LegacyReportID IS NULL
				)
			AND (
				haai.EIDSSPersonID LIKE '%' + TRIM(@PersonID) + '%'
				OR @PersonID IS NULL
				)
			AND (
				m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
				OR @LocalOrFieldSampleID IS NULL
				)
			AND (
				ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
				OR @SessionID IS NULL
				)
		GROUP BY v.idfVetCase;

		DELETE
		FROM @Results
		WHERE ID IN (
				SELECT v.idfVetCase
				FROM dbo.tlbVetCase v
				INNER JOIN dbo.tstObjectAccess oa ON oa.idfsObjectID = v.idfsFinalDiagnosis
					AND oa.intRowStatus = 0
				WHERE oa.intPermission = 1 -- Deny permission
					AND oa.idfsObjectType = 10060001 -- Disease
					AND oa.idfActor = @UserEmployeeID
				);

        -- =======================================================================================
        -- SITE FILTRATION RULES
        --
        -- Apply site filtration rules from use case SAUC29.
        -- =======================================================================================
        -- 
        -- Apply level 0 site filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without site filtration rules applied.
        --
        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT vc.idfVetCase
            FROM dbo.tlbVetCase vc
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = vc.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE vc.intRowStatus = 0
                  AND oa.idfsObjectOperation = 10059003 -- Read permission
                  AND oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060011 -- Site
                  AND oa.idfActor = eg.idfEmployeeGroup
        );

        --
        -- Apply level 1 site filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        INSERT INTO @Results
        SELECT vc.idfVetCase,
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbVetCase vc
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = vc.idfsSite
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE vc.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = vc.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbVetCase vc
                ON vc.idfVetCase = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = vc.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT vc.idfVetCase,
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbVetCase vc
        WHERE vc.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = vc.idfsSite
        );

        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT vc.idfVetCase
            FROM dbo.tlbVetCase vc
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = vc.idfsSite
            WHERE usp.Permission = 4 -- Deny permission
                  AND usp.PermissionTypeID = 10059003 -- Read permission
        );

		-- ========================================================================================
		-- FINAL QUERY, PAGINATION AND COUNTS
		-- ========================================================================================
		INSERT INTO @FinalResults
        SELECT ID,
               MAX(res.ReadPermissionIndicator),
               MAX(res.AccessToPersonalDataPermissionIndicator),
               MAX(res.AccessToGenderAndAgeDataPermissionIndicator),
               MAX(res.WritePermissionIndicator),
               MAX(res.DeletePermissionIndicator)
        FROM @Results res
		    INNER JOIN dbo.tlbVetCase v 
			    ON v.idfVetCase = res.ID 
				INNER JOIN dbo.tlbFarm f ON f.idfFarm = v.idfFarm
		LEFT JOIN dbo.tlbHuman h ON h.idfHuman = f.idfHuman
		LEFT JOIN dbo.HumanActualAddlInfo haai ON haai.HumanActualAddlInfoUID = h.idfHumanActual
		LEFT JOIN dbo.tlbGeoLocation gl ON gl.idfGeoLocation = f.idfFarmAddress
		LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gl.idfsLocation
		LEFT JOIN dbo.tlbMaterial m ON m.idfVetCase = v.idfVetCase
			AND m.intRowStatus = 0
		LEFT JOIN dbo.tlbMonitoringSession ms ON ms.idfMonitoringSession = v.idfParentMonitoringSession
			AND ms.intRowStatus = 0
        WHERE res.ReadPermissionIndicator IN ( 1, 3, 5 )
					AND (
				f.idfFarmActual = @FarmMasterID
				OR @FarmMasterID IS NULL
				)
			AND (
				v.idfVetCase = @ReportKey
				OR @ReportKey IS NULL
				)
			AND (
				v.idfParentMonitoringSession = @SessionKey
				OR @SessionKey IS NULL
				)
			AND (
				g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
				OR @AdministrativeLevelID IS NULL
				)
			AND (
				v.idfsFinalDiagnosis = @DiseaseID
				OR @DiseaseID IS NULL
				)
			AND (
				v.idfsCaseClassification = @ClassificationTypeID
				OR @ClassificationTypeID IS NULL
				)
			AND (
				v.idfsCaseProgressStatus = @ReportStatusTypeID
				OR @ReportStatusTypeID IS NULL
				)
			AND (
				(
					CAST(v.datEnteredDate AS DATE) BETWEEN @DateEnteredFrom
						AND @DateEnteredTo
					)
				OR (
					@DateEnteredFrom IS NULL
					OR @DateEnteredTo IS NULL
					)
				)
			AND (
				v.idfsCaseReportType = @ReportTypeID
				OR @ReportTypeID IS NULL
				)
			AND (
				v.idfsCaseType = @SpeciesTypeID
				OR @SpeciesTypeID IS NULL
				)
			AND (
				(
					CAST(v.datFinalDiagnosisDate AS DATE) BETWEEN @DiagnosisDateFrom
						AND @DiagnosisDateTo
					)
				OR (
					@DiagnosisDateFrom IS NULL
					OR @DiagnosisDateTo IS NULL
					)
				)
			AND (
				(
					CAST(v.datInvestigationDate AS DATE) BETWEEN @InvestigationDateFrom
						AND @InvestigationDateTo
					)
				OR (
					@InvestigationDateFrom IS NULL
					OR @InvestigationDateTo IS NULL
					)
				)
			AND (
				(
					(
						f.intAvianTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
							AND @TotalAnimalQuantityTo
						)
					OR (
						f.intLivestockTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
							AND @TotalAnimalQuantityTo
						)
					)
				OR (
					@TotalAnimalQuantityFrom IS NULL
					OR @TotalAnimalQuantityTo IS NULL
					)
				)
			AND (
				(
					v.idfOutbreak IS NULL
					AND @OutbreakCasesIndicator = 0
					)
				OR (
					v.idfOutbreak IS NOT NULL
					AND @OutbreakCasesIndicator = 1
					)
				OR (@OutbreakCasesIndicator IS NULL)
				)
			AND (
				v.idfsSite = @DataEntrySiteID
				OR @DataEntrySiteID IS NULL
				)
			AND (
				v.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
				OR @ReportID IS NULL
				)
			AND (
				v.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
				OR @LegacyReportID IS NULL
				)
			AND (
				haai.EIDSSPersonID LIKE '%' + TRIM(@PersonID) + '%'
				OR @PersonID IS NULL
				)
			AND (
				m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
				OR @LocalOrFieldSampleID IS NULL
				)
			AND (
				ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
				OR @SessionID IS NULL
				)
        GROUP BY ID;

		WITH paging
		AS (SELECT 
				ID,
				c = COUNT(*) OVER()
			FROM @FinalResults res
			INNER JOIN dbo.tlbVetCase v ON v.idfVetCase = res.ID
			INNER JOIN dbo.tlbFarm f ON f.idfFarm = v.idfFarm
			LEFT JOIN dbo.tlbGeoLocation gl ON gl.idfGeoLocation = f.idfFarmAddress
			LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gl.idfsLocation
			LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh ON lh.idfsLocation = g.idfsLocation
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease ON disease.idfsReference = v.idfsFinalDiagnosis
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) caseClassification ON caseClassification.idfsReference = v.idfsCaseClassification
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000111) reportStatus ON reportStatus.idfsReference = v.idfsCaseProgressStatus
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000144) reportType ON reportType.idfsReference = v.idfsCaseReportType
			ORDER BY 
				CASE WHEN @SortColumn = 'ReportID' AND @SortOrder = 'ASC' THEN v.strCaseID END ASC,
				CASE WHEN @SortColumn = 'ReportID' AND @SortOrder = 'DESC' THEN v.strCaseID END DESC,
				CASE WHEN @SortColumn = 'EnteredDate' AND @SortOrder = 'ASC' THEN v.datEnteredDate END ASC,
				CASE WHEN @SortColumn = 'EnteredDate' AND @SortOrder = 'DESC' THEN v.datEnteredDate END DESC,
				CASE WHEN @SortColumn = 'DiseaseName' AND @SortOrder = 'ASC' THEN disease.name END ASC,
				CASE WHEN @SortColumn = 'DiseaseName' AND @SortOrder = 'DESC' THEN disease.name END DESC,
				CASE WHEN @SortColumn = 'FarmName' AND @SortOrder = 'ASC' THEN f.strNationalName END ASC,
				CASE WHEN @SortColumn = 'FarmName' AND @SortOrder = 'DESC' THEN f.strNationalName END DESC,
				CASE WHEN @SortColumn = 'FarmAddress' AND @SortOrder = 'ASC' THEN (lh.AdminLevel1Name + ', ' + lh.AdminLevel2Name) END ASC,
				CASE WHEN @SortColumn = 'FarmAddress' AND @SortOrder = 'DESC' THEN (lh.AdminLevel1Name + ', ' + lh.AdminLevel2Name) END DESC,
				CASE WHEN @SortColumn = 'ClassificationTypeName' AND @SortOrder = 'ASC' THEN caseClassification.name END ASC,
				CASE WHEN @SortColumn = 'ClassificationTypeName' AND @SortOrder = 'DESC' THEN caseClassification.name END DESC,
				CASE WHEN @SortColumn = 'ReportStatusTypeName' AND @SortOrder = 'ASC' THEN reportStatus.name END ASC,
				CASE WHEN @SortColumn = 'ReportStatusTypeName' AND @SortOrder = 'DESC' THEN reportStatus.name END DESC,
				CASE WHEN @SortColumn = 'ReportTypeName' AND @SortOrder = 'ASC' THEN reportType.name END ASC,
				CASE WHEN @SortColumn = 'ReportTypeName' AND @SortOrder = 'DESC' THEN reportType.name END DESC
				OFFSET @PageSize * (@PageNumber - 1) ROWS FETCH NEXT @PageSize ROWS ONLY),
		SITEID AS
		(
		SELECT DISTINCT v.idfsSite AS SiteKey
		FROM paging 
			INNER JOIN @FinalResults res ON res.ID = paging.ID
			INNER JOIN dbo.tlbVetCase v ON v.idfVetCase = res.ID
			INNER JOIN dbo.tlbFarm f ON f.idfFarm = v.idfFarm
			LEFT JOIN dbo.tlbHuman h ON h.idfHuman = f.idfHuman
			LEFT JOIN dbo.HumanActualAddlInfo haai ON haai.HumanActualAddlInfoUID = h.idfHumanActual
			LEFT JOIN dbo.tlbPerson personInvestigatedBy ON personInvestigatedBy.idfPerson = v.idfPersonInvestigatedBy
			LEFT JOIN dbo.tlbPerson personEnteredBy ON personEnteredBy.idfPerson = v.idfPersonEnteredBy
			LEFT JOIN dbo.tlbPerson personReportedBy ON personReportedBy.idfPerson = v.idfPersonReportedBy
			LEFT JOIN dbo.tlbGeoLocation gl ON gl.idfGeoLocation = f.idfFarmAddress
			LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gl.idfsLocation
			LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh ON lh.idfsLocation = g.idfsLocation
			LEFT JOIN dbo.tlbOutbreak o ON o.idfOutbreak = v.idfOutbreak
				AND o.intRowStatus = 0
			LEFT JOIN dbo.OutbreakCaseReport ocr ON ocr.idfOutbreak = v.idfOutbreak 
			   AND ocr.idfVetCase IS NOT NULL 	
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) finalDiagnosis ON finalDiagnosis.idfsReference = v.idfsFinalDiagnosis
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) caseClassification ON caseClassification.idfsReference = v.idfsCaseClassification
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000111) reportStatus ON reportStatus.idfsReference = v.idfsCaseProgressStatus
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000144) reportType ON reportType.idfsReference = v.idfsCaseReportType
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000012) caseType ON caseType.idfsReference = v.idfsCaseType
		 WHERE 
			(v.strCaseID IS NOT NULL AND @OutbreakCaseReportOnly = 0) OR
			(ocr.strOutbreakCaseID IS NOT NULL AND @OutbreakCaseReportOnly = 1)

		
		--ORDER BY 
		--	CASE WHEN @SortColumn = 'ReportID' AND @SortOrder = 'ASC' THEN v.strCaseID END ASC,
		--	CASE WHEN @SortColumn = 'ReportID' AND @SortOrder = 'DESC' THEN v.strCaseID END DESC,
		--	CASE WHEN @SortColumn = 'EnteredDate' AND @SortOrder = 'ASC' THEN v.datEnteredDate END ASC,
		--	CASE WHEN @SortColumn = 'EnteredDate' AND @SortOrder = 'DESC' THEN v.datEnteredDate END DESC,
		--	CASE WHEN @SortColumn = 'DiseaseName' AND @SortOrder = 'ASC' THEN finalDiagnosis.name END ASC,
		--	CASE WHEN @SortColumn = 'DiseaseName' AND @SortOrder = 'DESC' THEN finalDiagnosis.name END DESC,
		--	CASE WHEN @SortColumn = 'FarmName' AND @SortOrder = 'ASC' THEN f.strNationalName END ASC,
		--	CASE WHEN @SortColumn = 'FarmName' AND @SortOrder = 'DESC' THEN f.strNationalName END DESC,
		--	CASE WHEN @SortColumn = 'FarmAddress' AND @SortOrder = 'ASC' THEN (lh.AdminLevel1Name + ', ' + lh.AdminLevel2Name) END ASC,
		--	CASE WHEN @SortColumn = 'FarmAddress' AND @SortOrder = 'DESC' THEN (lh.AdminLevel1Name + ', ' + lh.AdminLevel2Name) END DESC,
		--	CASE WHEN @SortColumn = 'ClassificationTypeName' AND @SortOrder = 'ASC' THEN caseClassification.name END ASC,
		--	CASE WHEN @SortColumn = 'ClassificationTypeName' AND @SortOrder = 'DESC' THEN caseClassification.name END DESC,
		--	CASE WHEN @SortColumn = 'ReportStatusTypeName' AND @SortOrder = 'ASC' THEN reportStatus.name END ASC,
		--	CASE WHEN @SortColumn = 'ReportStatusTypeName' AND @SortOrder = 'DESC' THEN reportStatus.name END DESC,
		--	CASE WHEN @SortColumn = 'ReportTypeName' AND @SortOrder = 'ASC' THEN reportType.name END ASC,
		--	CASE WHEN @SortColumn = 'ReportTypeName' AND @SortOrder = 'DESC' THEN reportType.name END DESC;
			)

		SELECT @SiteIDs = STRING_AGG(CAST(SiteKey AS NVARCHAR(24)), ',') 
		FROM SITEID
		
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END;
GO
PRINT N'Refreshing Procedure [dbo].[USP_GBL_LKUP_Diseases_BY_IDS_GETLIST_Paged]...';


GO
