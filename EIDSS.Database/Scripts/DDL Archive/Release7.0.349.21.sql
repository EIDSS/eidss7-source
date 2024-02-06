
GO
--##SUMMARY Returns correct filter condition, including correct operator and, if necessary, additional quotes to the value
--##SUMMARY depending on the Type of the field and a reference to the reference table.

--##REMARKS Author: Mirnaya O.
--##REMARKS Create date: 14.08.2010

--##REMARKS Updated by: Mirnaya O.
--##REMARKS Date: 14.12.2011

--##RETURNS Function returns correct filter condition, including correct operator and, if necessary, additional quotes.


/*
--Example of a call of function:
declare @idfsFieldType			bigint
declare @idfsReferenceType		bigint
declare @idfsGISReferenceType	bigint
declare @strField				nvarchar(2050)
declare @strOperator			nvarchar(200)
declare @intOperatorType		int
declare @blnUseNot				bit
declare @varValue				sql_variant

select	dbo.fnAsGetSearchCondition
		(	@idfsFieldType,
			@idfsReferenceType,
			@idfsGISReferenceType,
			@varValue
		)

*/


ALTER	function	[dbo].[fnAsGetSearchCondition]
(
	@idfsFieldType			bigint,			--##PARAM @idfsFieldType Id of the search field Type or parameter Type
	@idfsReferenceType		bigint,			--##PARAM @idfsReferenceType Id of the reference Type that should contain the specified value
	@idfsGISReferenceType	bigint,			--##PARAM @idfsGISReferenceType Id of the GIS reference Type that should contain the specified value
	@strLookupFunction		nvarchar(2100),	--##PARAM @strLookupFunction Name of Lookup Function that should return the specified value
	@strField				nvarchar(4000),	--##PARAM @strField Text of the search field included in filter condition
	@strOperator			nvarchar(200),	--##PARAM @strOperator The name of the operator Type (Unary or Binary)
	@intOperatorType		int,			--##PARAM @intOperatorType The number from the Operator Type enum for specified operator
	@blnUseNot				bit,			--##PARAM @blnUseNot The parameter that determines whether to use NOT for specified operator
	@varValue				sql_variant		--##PARAM @varValue The value to be converted to a string
)
returns nvarchar(MAX)
as
begin

declare	@Condition	nvarchar(MAX)
set	@Condition = N''

declare @Operator	varchar(2000)
set @Operator = ''

declare @strValue	nvarchar(MAX)
set @strValue = N''

declare @Not		bit
set	@Not = IsNull(@blnUseNot, 0)

if (@idfsReferenceType is not null or @idfsGISReferenceType is not null or len(ltrim(rtrim(isnull(@strLookupFunction, N'')))) > 0) and @strField not like '%_ID]'
begin
	set @strField = replace(@strField, N']', N'_ID]')
end

if (@strOperator = 'Binary')
begin
	if	((@intOperatorType = 0) and (@Not = 0))
		or ((@intOperatorType = 1) and (@Not = 1))
		set	@Operator = '='
	else if	((@intOperatorType = 1) and (@Not = 0))
			or ((@intOperatorType = 0) and (@Not = 1))
		set @Operator = '<>'
	else if	((@intOperatorType = 2) and (@Not = 0))
			or ((@intOperatorType = 4) and (@Not = 1))
		set @Operator = '>'
	else if	((@intOperatorType = 3) and (@Not = 0))
			or ((@intOperatorType = 5) and (@Not = 1))
		set @Operator = '<'
	else if	((@intOperatorType = 4) and (@Not = 0))
			or ((@intOperatorType = 2) and (@Not = 1))
		set @Operator = '<='
	else if	((@intOperatorType = 5) and (@Not = 0))
			or ((@intOperatorType = 3) and (@Not = 1))
		set @Operator = '>='
	else if	(@intOperatorType = 6) and (@Not = 0)
	begin
		if	@idfsFieldType not in	-- FF Field
				(	-- Search field Type
					10081001,	-- Bit
					10081004,	-- Float
					10081006,	-- Integer
					10081002,	-- Date
					10081004,	-- Float
					10081005,	-- ID
					10081007	-- String
				)
			set @strField = N'cast(' + @strField + N' as nvarchar)'
		set @Operator = 'like'
	end
	else if	(@intOperatorType = 6) and (@Not = 1)
	begin
		if	@idfsFieldType not in	-- FF Field
				(	-- Search field Type
					10081001,	-- Bit
					10081004,	-- Float
					10081006,	-- Integer
					10081002,	-- Date
					10081004,	-- Float
					10081005,	-- ID
					10081007	-- String
				)
			set @strField = N'cast(' + @strField + N' as nvarchar)'
		set @Operator = 'not like'
	end

	if	@varValue is not null
	begin
		if	@idfsReferenceType is not null 
			or @idfsGISReferenceType is not null
			or len(ltrim(rtrim(isnull(@strLookupFunction, N'')))) > 0
			or @idfsFieldType in
				(	-- Search field Type
					10081001,	-- Bit
					10081004,	-- Float
					10081006,	-- Integer
					-- FF parameter Type
					10071007,	-- Numeric
					10071025,	-- Boolean
					10071059,	-- Numeric Natural
					10071060,	-- Numeric Positive
					10071061	-- Numeric Integer
				)
		begin
				set	@strValue = cast(@varValue as nvarchar(MAX))
		end
		else begin
			if cast(SQL_VARIANT_PROPERTY(@varValue, 'BaseType')  as nvarchar) like N'%date%'
				set	@strValue = N' ' + 'N''' + 
					replace(replace(left(CONVERT(nvarchar, CAST(@varValue as datetime), 120), 10), N'-', N''), '''', '''''') + ''''
			else if @Operator in ('like', 'not like')
			begin
				set	@strValue = replace(cast(@varValue as nvarchar(MAX)), '''', '''''')
				set	@strValue = REPLACE(@strValue, N'*', N'%')
				if	@strValue not like N'[%]%'
					set	@strValue = N'%' + @strValue
				if	@strValue not like N'%[%]'
					set	@strValue = @strValue + N'%'
				set	@strValue = N' ' + 'N''' + @strValue + ''''
			end
			else
				set	@strValue = N' ' + 'N''' + replace(cast(@varValue as nvarchar(MAX)), '''', '''''') + ''''
		end
	end

	set	@Condition = IsNull(N'(' + @strField + N' ' + @Operator + N' ' + @strValue + N')', N'')
end
else if (@strOperator = 'Unary')
		or	(	@strOperator = 'OutlookInterval'
				and @intOperatorType = 4
			)
begin
	if (@intOperatorType = 4) and (@Not = 0)
		set	@Operator = 'is null'
	else if	(@intOperatorType = 4) and (@Not = 1)
		set @Operator = 'is not null'

	set	@Condition = IsNull(N'(' + @strField + N' ' + @Operator + N')', N'')
end
else if (	@strOperator = 'OutlookInterval'
			and @intOperatorType = 5
		)
begin
	if (@Not = 0)
		set	@Operator = '{x} is null or cast({x} as nvarchar) = N'''''
	else if (@Not = 1)
		set @Operator = '{x} is not null and cast({x} as nvarchar) <> N'''''

	set	@Condition = IsNull(N'(' + replace(@Operator, N'{x}', @strField) + N')', N'')
end
else if (	@strOperator = 'OutlookInterval'
			and @idfsReferenceType is null 
			and	@idfsGISReferenceType is null
			and len(ltrim(rtrim(isnull(@strLookupFunction, N'')))) = 0
			and	@idfsFieldType in
				(	-- Search field Type
					10081007,	-- String
					-- FF parameter Type
					10071045	-- String
				)
			and @varValue is not null
			and	@intOperatorType in
				(	46,			-- Begins with/Does not begin with
					47,			-- Ends with/Does not end with
					48			-- Contains/Does not contain
				)
		) 
begin
	set	@strValue = replace(cast(@varValue as nvarchar(MAX)), '''', '''''')
	set	@strValue = REPLACE(@strValue, N'*', N'%')
	
	if	(@intOperatorType = 46) and (@Not = 0)	-- Begins with
	begin
		set	@Operator = 'like'
		if	@strValue not like N'%[%]'
			set	@strValue = @strValue + N'%'
	end
	else if	(@intOperatorType = 46) and (@Not = 1)	-- Does not begin with
	begin
		set	@Operator = 'not like'
		if	@strValue not like N'%[%]'
			set	@strValue = @strValue + N'%'
	end
	else if	(@intOperatorType = 47) and (@Not = 0)	-- Ends with
	begin
		set	@Operator = 'like'
		if	@strValue not like N'[%]%'
			set	@strValue = N'%' + @strValue
	end
	else if	(@intOperatorType = 47) and (@Not = 1)	-- Does not end with
	begin
		set	@Operator = 'not like'
		if	@strValue not like N'[%]%'
			set	@strValue = N'%' + @strValue
	end
	else if	(@intOperatorType = 48) and (@Not = 0)	-- Contains
	begin
		set	@Operator = 'like'
		if	@strValue not like N'[%]%'
			set	@strValue = N'%' + @strValue
		if	@strValue not like N'%[%]'
			set	@strValue = @strValue + N'%'
	end
	else if	(@intOperatorType = 48) and (@Not = 1)	-- Does not contain
	begin
		set	@Operator = 'not like'
		if	@strValue not like N'[%]%'
			set	@strValue = N'%' + @strValue
		if	@strValue not like N'%[%]'
			set	@strValue = @strValue + N'%'
	end
	
	set	@strValue = N' ' + 'N''' + @strValue + ''''
	set	@Condition = IsNull(N'(' + @strField + N' ' + @Operator + N' ' + @strValue + N')', N'')
end
else if (@strOperator = 'OutlookInterval') 
		and (@idfsFieldType in	(10081002, 10071029, 10071030))	-- Field Date, Parameter Dste, Parameter DateTime
begin
--	set	@strField = N'cast(' + @strField + N' as date)'	
/*	if (@intOperatorType = 59) and (@Not = 0)	-- Is Interval Beyond This Year
		set	@Condition = IsNull(N'(year(' + @strField + N') <> year(getdate()))', N'')
	else if	(@intOperatorType = 59) and (@Not = 1) -- Is Interval Within This Year
		set	@Condition = IsNull(N'(year(' + @strField + N') = year(getdate()))', N'')
	
	else if (@intOperatorType = 60) and (@Not = 0)	-- Is Interval Later This Year
		set	@Condition = IsNull(N'(year(' + @strField + N') > year(getdate()))', N'')
	else if	(@intOperatorType = 60) and (@Not = 1) -- Is Interval Earlier Or Equal To This Year
		set	@Condition = IsNull(N'(year(' + @strField + N') <= year(getdate()))', N'')
	
	else if (@intOperatorType = 61) and (@Not = 0)	-- Is Interval Later This Month
		set	@Condition = IsNull(N'((month(' + @strField + N') > month(getdate()) ' +
									N'and year(' + @strField + N') = year(getdate())) ' +
								N'or (year(' + @strField + N') > year(getdate())))', N'')
	else if	(@intOperatorType = 61) and (@Not = 1) -- Is Interval Earlier Or Equal To This Month
		set	@Condition = IsNull(N'((month(' + @strField + N') <= month(getdate()) ' +
									N'and year(' + @strField + N') = year(getdate())) ' +
								N'or (year(' + @strField + N') < year(getdate())))', N'')

	else if (@intOperatorType = 62) and (@Not = 0)	-- Is Interval Next Week
		set	@Condition = IsNull(N'(' + @strField + N' > getdate() and datediff(ww, getdate(), ' + @strField + N') = 1)', N'')
	else if	(@intOperatorType = 62) and (@Not = 1) -- Is Interval Not Next Week
		set	@Condition = IsNull(N'((' + @strField + N' > getdate() and datediff(ww, getdate(), ' + @strField + N') <> 1)) ' + 
									N'or (' + @strField + N' <= getdate())', N'')

	else if (@intOperatorType = 63) and (@Not = 0)	-- Is Interval Later This Week
		set	@Condition = IsNull(N'((datepart(ww, ' + @strField + N') > datepart(ww, getdate()) ' +
									N'and year(' + @strField + N') = year(getdate())) ' +
								N'or (year(' + @strField + N') > year(getdate())))', N'')
	else if	(@intOperatorType = 63) and (@Not = 1) -- Is Interval Earlier Or Equal To This Week
		set	@Condition = IsNull(N'((datepart(ww, ' + @strField + N') <= datepart(ww, getdate()) ' +
									N'and year(' + @strField + N') = year(getdate())) ' +
								N'or (year(' + @strField + N') < year(getdate())))', N'')

	else if (@intOperatorType = 64) and (@Not = 0)	-- Is Interval Tomorrow
		set	@Condition = IsNull(N'(' + @strField + N' > getdate() and datediff(dd, getdate(), ' + @strField + N') = 1)', N'')
--		set	@Condition = IsNull(N'(' + @strField + N' = dateadd(dd, 1, getdate())', N'')
	else if	(@intOperatorType = 64) and (@Not = 1) -- Is Interval Not Tomorrow
		set	@Condition = IsNull(N'((' + @strField + N' > getdate() and datediff(dd, getdate(), ' + @strField + N') <> 1)) ' + 
									N'or (' + @strField + N' <= getdate())', N'')
--		set	@Condition = IsNull(N'(' + @strField + N' <> dateadd(dd, 1, getdate())', N'')

	else */if (@intOperatorType = 73) and (@Not = 0)	-- Is Interval Today
		--	IsOutlookIntervalToday, // Today <= x < Tomorrow
		set	@Condition = IsNull(N'((' + @strField + N' is not null) and (datediff(dd, ' + @strField + N', getdate()) = 0))', N'')

	else if	(@intOperatorType = 73) and (@Not = 1) -- Is Interval Not Today
		set	@Condition = IsNull(N'((' + @strField + N' is not null) and (datediff(dd, ' + @strField + N', getdate()) <> 0))', N'')

	else if (@intOperatorType = 74) and (@Not = 0)	-- Is Interval Yesterday
		--	IsOutlookIntervalYesterday, // Yesterday <= x < Today
		set	@Condition = IsNull(N'((' + @strField + N' is not null) and (' + @strField + N' < getdate()) and (datediff(dd, ' + @strField + N', getdate()) = 1))', N'')

	else if	(@intOperatorType = 74) and (@Not = 1) -- Is Interval Not Yesterday
		set	@Condition = IsNull(N'((' + @strField + N' is not null) and (((' + @strField + N' < getdate()) and (datediff(dd, ' + @strField + N', getdate()) <> 1)) ' + 
									N'or (' + @strField + N' >= getdate()))', N'')

	else if (@intOperatorType = 75) and (@Not = 0)	-- Is Interval Earlier This Week
		--	IsOutlookIntervalEarlierThisWeek, // ThisWeek <= x < Yesterday
		set	@Condition = IsNull(N'((' + @strField + N' is not null) and (' + @strField + N' < getdate()) and (datediff(dd, ' + @strField + N', getdate()) > 1) ' +
									N'and (dbo.fnWeekDatediff(' + @strField + N', getdate()) = 0))', N'')

	else if	(@intOperatorType = 75) and (@Not = 1) -- Is Interval Later Or Equal To This Week
		set	@Condition = IsNull(N'((' + @strField + N' is not null) and (((' + @strField + N' < getdate()) ' + 
									N'and ((datediff(dd, ' + @strField + N', getdate()) <= 1) ' + 
									N'or (dbo.fnWeekDatediff(' + @strField + N', getdate()) <> 0))) ' + 
									N'or (' + @strField + N' >= getdate())))', N'')

	else if (@intOperatorType = 76) and (@Not = 0)	-- Is Interval Last Week
		--	IsOutlookIntervalLastWeek, // LastWeek <= x < ThisWeek
		set	@Condition = IsNull(N'((' + @strField + N' is not null) and (' + @strField + N' < getdate()) and (dbo.fnWeekDatediff(' + @strField + N', getdate()) = 1))', N'')

	else if	(@intOperatorType = 76) and (@Not = 1) -- Is Interval Not Last Week
		set	@Condition = IsNull(N'((' + @strField + N' is not null) and (((' + @strField + N' < getdate()) and (dbo.fnWeekDatediff(' + @strField + N', getdate()) <> 1)) ' + 
									N'or (' + @strField + N' >= getdate()))', N'')

	else if (@intOperatorType = 77) and (@Not = 0)	-- Is Interval Earlier This Month
	--	IsOutlookIntervalEarlierThisMonth, // ThisMonth <= x < LastWeek
		set	@Condition = IsNull(N'((' + @strField + N' is not null) and (' + @strField + N' < getdate()) and (dbo.fnWeekDatediff(' + @strField + N', getdate()) > 1) ' +
									N'and (datediff(mm, ' + @strField + N', getdate()) = 0))', N'')

	else if	(@intOperatorType = 77) and (@Not = 1) -- Is Interval Later Or Equal To This Month
		set	@Condition = IsNull(N'((' + @strField + N' is not null) and (((' + @strField + N' < getdate()) ' + 
									N'and ((dbo.fnWeekDatediff(ww, ' + @strField + N', getdate()) <= 1) ' + 
									N'or (datediff(mm, ' + @strField + N', getdate()) <> 0))) ' + 
									N'or (' + @strField + N' >= getdate())))', N'')

	else if (@intOperatorType = 78) and (@Not = 0)	-- Is Interval Earlier This Year
		--	IsOutlookIntervalEarlierThisYear, // ThisYear <= x < ThisMonth
		set	@Condition = IsNull(N'((' + @strField + N' is not null) and (' + @strField + N' < getdate()) and (datediff(mm, ' + @strField + N', getdate()) >= 1) ' +
									N'and (datediff(yyyy, ' + @strField + N', getdate()) = 0))', N'')

	else if	(@intOperatorType = 78) and (@Not = 1) -- Is Interval Later Or Equal To This Year
		set	@Condition = IsNull(N'((' + @strField + N' is not null) and (((' + @strField + N' < getdate()) ' + 
									N'and ((datediff(mm, ' + @strField + N', getdate()) < 1) ' + 
									N'or (datediff(yyyy, ' + @strField + N', getdate()) <> 0))) ' + 
									N'or (' + @strField + N' >= getdate())))', N'')

	else if (@intOperatorType = 79) and (@Not = 0)	-- Is Interval Prior This Year
		--	IsOutlookIntervalPriorThisYear, // x < ThisYear
		set	@Condition = IsNull(N'((' + @strField + N' is not null) and (datediff(yyyy, ' + @strField + N', getdate()) >= 1))', N'')

	else if	(@intOperatorType = 79) and (@Not = 1) -- Is Interval Not Prior This Year
		set	@Condition = IsNull(N'((' + @strField + N' is not null) and (datediff(yyyy, ' + @strField + N', getdate()) < 1))', N'')
	
end

return @Condition
end
GO
PRINT N'Refreshing Function [dbo].[FN_VET_FARM_MASTER_GETList]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[FN_VET_FARM_MASTER_GETList]';


GO
PRINT N'Altering Function [dbo].[FN_GBL_Institution_Min]...';


GO
-- ================================================================================================
-- Name: FN_GBL_Institution_Min
--
-- Description: Returns the minimum fields needed for organization details 
--          
-- Author: Mandar Kulkarni
--
-- Revision History:
-- Name               Date       Change Detail
-- ------------------ ---------- -----------------------------------------------------------------
-- Jeff Johnson       06/11/2018 Added OrganizationTypeID
-- RYM                06/19/2019 Added OwnershipForm, LegalForm, and MainFormofActivity 
-- RYM                09/13/2019 Added auditcreatedate field
-- Stephen Long       02/10/2022 Added site ID.
-- Mark Wilson        11/08/2022 Added strOrganizationID.
-- Stephen Long       05/05/2023 Added intHaCode and intOrder.
--
-- Testing code:
-- SELECT * FROM [dbo].[FN_GBL_Institution_Min]('en-US')
-- ================================================================================================
ALTER FUNCTION [dbo].[FN_GBL_Institution_Min] (@LangID NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT Office.idfOffice,
           Org.[name] AS EnglishFullName,
           Org.strDefault AS EnglishName,
           Orgab.[name] AS AbbreviatedName,
           OrgAb.strDefault AS AbbreviatedEnglishName,
           Office.idfsOfficeName,
           Office.idfsOfficeAbbreviation,
           Office.idfsSite,
           Office.strOrganizationID,
           Office.intHACode,
           Office.intRowStatus,
           OrgAb.intOrder 
    FROM dbo.tlbOffice Office
        LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000046) Org
            ON Org.idfsReference = Office.idfsOfficeName
               AND Org.intRowStatus = 0
        LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000045) OrgAb
            ON OrgAb.idfsReference = Office.idfsOfficeAbbreviation
               AND Orgab.intRowStatus = 0
)
GO
PRINT N'Altering Function [dbo].[fnEvaluatePermissions]...';


GO
--================================================================================================
-- Author: Edgard Torres
-- Create date: 5/16/2022
-- Description:	Retrieve a list of Roles and Permissions for the given user from EIDSS7 to AVR user
-- 
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Edgard Torres    2/9/2023  Added mapping of EIDSS7 system functions to AVR system functions
-- Edgard Torres    5/16/2022 function modified
--

-- ================================================================================================

ALTER   FUNCTION [dbo].[fnEvaluatePermissions]
(	
	@idfEmployee bigint
)
RETURNS TABLE 
AS
RETURN 
(
select	(
		case SystemFunctionID
			when 10094510 then 10094027 -- permission to Human Disease Report >> Human Disease Report idfSystemFunction 10094027 (remap to object's idfSystemFunction in tasSearchObjectToSystemFunction table)
			when 10094546 then 10094051 -- permission to ILI Aggregate Form Data >> ILI Aggregate Form (10094051)
			else SystemFunctionID
		end
		) as idfsSystemFunction,
	strBaseReferenceCode, SystemFunctionOperationID as idfsObjectOperation, intPermission = 
	case LkupRoleSystemFunctionAccess.intRowStatus
		when 0 then 2
		when 1 then 1
	end
from LkupRoleSystemFunctionAccess
left join	trtBaseReference 
on			trtBaseReference.idfsBaseReference = LkupRoleSystemFunctionAccess.SystemFunctionID
where idfEmployee = @idfEmployee
)
GO
PRINT N'Altering Function [Report].[FN_UserOrganization_GET]...';


GO
--*************************************************************************
-- Name: report.FN_UserOrganization_GET
--
-- Description: Get the User Organization - For Comparative Report Footer
--          
-- Author: Srini Goli
--
-- Revision History:
-- Name			       Date       Change Detail
-- ------------------- ---------- ----------------------------------------
-- Stephen Long        05/08/2023 Changed from institution repair to min.
--
-- Testing code:
/*
SELECT report.FN_UserOrganization_GET('en')
SELECT report.FN_UserOrganization_GET('ru')
*/
ALTER FUNCTION [Report].[FN_UserOrganization_GET](@LangID AS NVARCHAR(50))
RETURNS VARCHAR(2000)
AS
BEGIN
	DECLARE @ret VARCHAR(2000);

	SELECT @ret = Organization.EnglishFullName
	FROM dbo.FN_GBL_Institution_Min(@LangID) Organization
	INNER JOIN dbo.tstLocalSiteOptions S 
			ON S.strName = 'SiteID' AND Organization.idfsSite = CAST(S.strValue AS BIGINT)
	WHERE Organization.intRowStatus = 0

	RETURN @ret
END
GO
PRINT N'Creating Function [dbo].[fnGetAttributesFromFormattedString]...';


GO
CREATE   FUNCTION [dbo].[fnGetAttributesFromFormattedString]
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
PRINT N'Altering Procedure [dbo].[USP_HUM_DISEASE_REPORT_GETList]...';


GO
-- ================================================================================================
-- Name: USP_HUM_DISEASE_REPORT_GETList
--
-- Description: Get a list of human disease reports for the human module.
--          
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mandar Kulkarni             Initial release.
-- Stephen Long     03/26/2018 Added the person reported by name for the farm use case.
-- JWJ	            04/17/2018 Added extra col to return:  tlbHuman.idfHumanActual. Added alias 
--                             for region rayon to make them unique in results added report status 
--                             to results 
-- Harold Pryor     10/22/2018 Added input search parameters SearchStrPersonFirstName, 
--                             SearchStrPersonMiddleName, and SearchStrPersonLastName
-- Harold Pryor     10/31/2018 Added input search parameters SearchLegacyCaseID and	
--                             added strLocation (region, rayon) field to list result set
-- Harold Pryor     11/12/2018 Changed @SearchLegacyCaseID parameter from BIGINT to NVARCHAR(200)
-- Stephen Long     12/19/2018 Added pagination logic.
-- Stephen Long     07/07/2019 Added monitoring session ID to parameters and where clause.
-- Stephen Long     07/10/2019 Changed address join from exposure location to patient's current 
--                             residence address.
-- Stephen Long     07/19/2019 Corrected patient name and person entered by name ', '.
-- Stephen Long     02/26/2020 Added non-configurable site filtration rules.
-- Lamont Mitchell  03/03/2020 Modified all joins on human case and human to join on human actual.
-- Stephen Long     04/01/2020 Added if/else for first-level and second-level site types to bypass 
--                             non-configurable rules.
-- Stephen Long     05/18/2020 Added disease filtration rules from use case SAUC62.
-- Stephen Long     06/18/2020 Corrected the join on the rayon of the report current residence 
--                             address (human ID to human ID instead of human ID to human actual 
--                             ID).
-- Stephen Long     06/18/2020 Added where criteria to the query when no site filtration is 
--                             required.
-- Stephen Long     07/07/2020 Added trim to EIDSS identifier like criteria.
-- Doug Albanese	11/16/2020 Added Outbreak Tied filtering
-- Stephen Long     11/18/2020 Added site ID to the query.
-- Stephen Long     11/28/2020 Added configurable site filtration rules.
-- Stephen Long     12/13/2020 Added apply configurable filtration indicator parameter.
-- Stephen Long     12/24/2020 Modified join on disease filtration default role rule.
-- Stephen Long     12/29/2020 Changed function call on reference data for inactive records.
-- Stephen Long     01/04/2020 Added option recompile due to number of optional parameters for 
--                             better execution plan.
-- Stephen Long     04/04/2021 Added updated pagination and location hierarchy.
-- Mike Kornegay	09/23/2021 Added HospitalizationStatus field
-- Stephen Long     11/03/2021 Added disease ID field.
-- Mike Kornegay	11/16/2021 Fix hospitalization field for translations
-- Mike Kornegay	12/07/2021 Added back EnteredByPersonName 
-- Mike Kornegay	12/08/2021 Swapped out FN_GBL_GIS_ReferenceRepair for new flat hierarchy
-- Mike Kornegay	12/23/2021 Fixed YN hospitalization where clause
-- Manickandan Govindarajan 03/21/2022  Rename Param PageNumber to Page
-- Stephen Long     03/29/2022 Fix to site filtration to pull back a user's own site records.
-- Stephen Long     06/03/2022 Updated to point default access rules to base reference.
-- Mike Kornegay    06/06/2022 Added parameter OutcomeID.
-- Mike Kornegay	06/13/2022 Changed inner joins to left joins in final query because result set 
--                             was incorrect.
-- Stephen Long     08/14/2022 Added additional criteria for outbreak cases for laboratory module.
--                             TODO: replace filter outbreak cases parameter, and just filter in 
--                             the initial query to avoid getting extra unneeded records; also just 
--                             make it a boolean value.
-- Mark Wilson      09/01/2022 update to use denormalized locations to work with site filtration.
-- Stephen Long     09/22/2022 Add check for "0" page size.  If "0", then set to 1.
-- Mike Kornegay	10/11/2022 Move order by back to CTE row partition for performance and add 
--                             LanguageID to default filtration rule joins.
-- Stephen Long     11/02/2022 Fixes for 4599 - site filtration returning the wrong results.
-- Stephen Long     11/09/2022 Fix on where criteria when filtration is run; added groupings for 
--                             the user entered parameters from the search criteria page.
-- Ann Xiong		11/29/2022 Updated to return records correctly when filter by only 
--                             DateEnteredFrom or DateEnteredTo.
-- Ann Xiong		11/30/2022 Updated to return records including DateEnteredTo.
-- Stephen Long     01/09/2023 Updated for site filtration queries.
-- Stephen Long     04/21/2023 Changed employee default group logic on disease filtration.
-- Stephen Long     05/09/2023 Corrected exposure table alias on the where criteria, and removed
--                             unneeded gisLocation left join in the final query.  Added 
--                             record identifier search indicator logic.
--
-- Testing code:
-- EXEC USP_HUM_DISEASE_REPORT_GETList 'en-US'
-- EXEC USP_HUM_DISEASE_REPORT_GETList 'en-US', @EIDSSReportID = 'H'
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_HUM_DISEASE_REPORT_GETList]
    @LanguageID NVARCHAR(50),
    @ReportKey BIGINT = NULL,
    @ReportID NVARCHAR(200) = NULL,
    @LegacyReportID NVARCHAR(200) = NULL,
    @SessionKey BIGINT = NULL,
    @PatientID BIGINT = NULL,
    @PersonID NVARCHAR(200) = NULL,
    @DiseaseID BIGINT = NULL,
    @ReportStatusTypeID BIGINT = NULL,
    @AdministrativeLevelID BIGINT = NULL,
    @DateEnteredFrom DATETIME = NULL,
    @DateEnteredTo DATETIME = NULL,
    @ClassificationTypeID BIGINT = NULL,
    @HospitalizationYNID BIGINT = NULL,
    @PatientFirstName NVARCHAR(200) = NULL,
    @PatientMiddleName NVARCHAR(200) = NULL,
    @PatientLastName NVARCHAR(200) = NULL,
    @SentByFacilityID BIGINT = NULL,
    @ReceivedByFacilityID BIGINT = NULL,
    @DiagnosisDateFrom DATETIME = NULL,
    @DiagnosisDateTo DATETIME = NULL,
    @LocalOrFieldSampleID NVARCHAR(200) = NULL,
    @DataEntrySiteID BIGINT = NULL,
    @DateOfSymptomsOnsetFrom DATETIME = NULL,
    @DateOfSymptomsOnsetTo DATETIME = NULL,
    @NotificationDateFrom DATETIME = NULL,
    @NotificationDateTo DATETIME = NULL,
    @DateOfFinalCaseClassificationFrom DATETIME = NULL,
    @DateOfFinalCaseClassificationTo DATETIME = NULL,
    @LocationOfExposureAdministrativeLevelID BIGINT = NULL,
    @OutcomeID BIGINT = NULL,
    @FilterOutbreakTiedReports INT = 0,
    @OutbreakCasesIndicator BIT = 0,
    @RecordIdentifierSearchIndicator BIT = 0,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT,
    @ApplySiteFiltrationIndicator BIT = 0,
    @SortColumn NVARCHAR(30) = 'ReportID',
    @SortOrder NVARCHAR(4) = 'DESC',
    @Page INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @firstRec INT,
            @lastRec INT,
            @FiltrationSiteAdministrativeLevelID AS BIGINT,
            @LanguageCode AS BIGINT = dbo.FN_GBL_LanguageCode_GET(@LanguageID);
    SET @firstRec = (@Page - 1) * @PageSize
    SET @lastRec = (@Page * @PageSize + 1);

    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL INDEX IX1 CLUSTERED,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL INDEX IX1 CLUSTERED,
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

        -- ========================================================================================
        -- NO CONFIGURABLE FILTRATION RULES APPLIED
        --
        -- For first and second level sites, do not apply any site filtration rules.
        -- ========================================================================================
        IF @ApplySiteFiltrationIndicator = 0
        BEGIN
            IF @RecordIdentifierSearchIndicator = 1
            BEGIN
                INSERT INTO @Results
                SELECT idfHumanCase,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbHumanCase
                WHERE intRowStatus = 0
                      AND idfsFinalDiagnosis IS NOT NULL
                      AND (
                              strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                              OR @ReportID IS NULL
                          )
                      AND (
                              LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                              OR @LegacyReportID IS NULL
                          )
            END
            ELSE
            BEGIN
                INSERT INTO @Results
                SELECT hc.idfHumanCase,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbHumanCase hc
                    INNER JOIN dbo.tlbHuman h
                        ON h.idfHuman = hc.idfHuman
                           AND h.intRowStatus = 0
                    INNER JOIN dbo.tlbGeoLocation currentAddress
                        ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
                    LEFT JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = currentAddress.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    LEFT JOIN dbo.tlbMaterial m
                        ON m.idfHumanCase = hc.idfHumanCase
                           AND m.intRowStatus = 0
                    LEFT JOIN dbo.tlbGeoLocation exposure
                        ON exposure.idfGeoLocation = hc.idfPointGeoLocation
                    LEFT JOIN dbo.gisLocationDenormalized gExposure
                        ON gExposure.idfsLocation = exposure.idfsLocation
                           AND gExposure.idfsLanguage = @LanguageCode
                WHERE hc.intRowStatus = 0
                      AND hc.idfsFinalDiagnosis IS NOT NULL
                      AND (
                              hc.idfHumanCase = @ReportKey
                              OR @ReportKey IS NULL
                          )
                      AND (
                              hc.idfParentMonitoringSession = @SessionKey
                              OR @SessionKey IS NULL
                          )
                      AND (
                              h.idfHumanActual = @PatientID
                              OR @PatientID IS NULL
                          )
                      AND (
                              h.strPersonId = @PersonID
                              OR @PersonID IS NULL
                          )
                      AND (
                              idfsFinalDiagnosis = @DiseaseID
                              OR @DiseaseID IS NULL
                          )
                      AND (
                              idfsCaseProgressStatus = @ReportStatusTypeID
                              OR @ReportStatusTypeID IS NULL
                          )
                      AND (
                              g.Level1ID = @AdministrativeLevelID
                              OR g.Level2ID = @AdministrativeLevelID
                              OR g.Level3ID = @AdministrativeLevelID
                              OR g.Level4ID = @AdministrativeLevelID
                              OR g.Level5ID = @AdministrativeLevelID
                              OR g.Level6ID = @AdministrativeLevelID
                              OR g.Level7ID = @AdministrativeLevelID
                              OR @AdministrativeLevelID IS NULL
                          )
                      AND (
                              hc.datEnteredDate >= @DateEnteredFrom
                              OR @DateEnteredFrom IS NULL
                          )
                      AND (
                              (CONVERT(DATE, hc.datEnteredDate, 102) <= @DateEnteredTo)
                              OR @DateEnteredTo IS NULL
                          )
                      AND (
                              (CAST(hc.datFinalDiagnosisDate AS DATE)
                      BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                              )
                              OR (
                                     @DiagnosisDateFrom IS NULL
                                     OR @DiagnosisDateTo IS NULL
                                 )
                          )
                      AND (
                              (CAST(hc.datNotificationDate AS DATE)
                      BETWEEN @NotificationDateFrom AND @NotificationDateTo
                              )
                              OR (
                                     @NotificationDateFrom IS NULL
                                     OR @NotificationDateTo IS NULL
                                 )
                          )
                      AND (
                              (CAST(hc.datOnSetDate AS DATE)
                      BETWEEN @DateOfSymptomsOnsetFrom AND @DateOfSymptomsOnsetTo
                              )
                              OR (
                                     @DateOfSymptomsOnsetFrom IS NULL
                                     OR @DateOfSymptomsOnsetTo IS NULL
                                 )
                          )
                      AND (
                              (CAST(hc.datFinalCaseClassificationDate AS DATE)
                      BETWEEN @DateOfFinalCaseClassificationFrom AND @DateOfFinalCaseClassificationTo
                              )
                              OR (
                                     @DateOfFinalCaseClassificationFrom IS NULL
                                     OR @DateOfFinalCaseClassificationTo IS NULL
                                 )
                          )
                      AND (
                              hc.idfReceivedByOffice = @ReceivedByFacilityID
                              OR @ReceivedByFacilityID IS NULL
                          )
                      AND (
                              hc.idfSentByOffice = @SentByFacilityID
                              OR @SentByFacilityID IS NULL
                          )
                      AND (
                              idfsFinalCaseStatus = @ClassificationTypeID
                              OR @ClassificationTypeID IS NULL
                          )
                      AND (
                              idfsYNHospitalization = @HospitalizationYNID
                              OR @HospitalizationYNID IS NULL
                          )
                      AND (
                              gExposure.Level1ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level2ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level3ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level4ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level5ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level6ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level7ID = @LocationOfExposureAdministrativeLevelID
                              OR @LocationOfExposureAdministrativeLevelID IS NULL
                          )
                      AND (
                              (ISNULL(h.strFirstName, '') = CASE ISNULL(@PatientFirstName, '')
                                                                WHEN '' THEN
                                                                    ISNULL(h.strFirstName, '')
                                                                ELSE
                                                                    @PatientFirstName
                                                            END
                              )
                              OR (CHARINDEX(@PatientFirstName, ISNULL(h.strFirstName, '')) > 0)
                          )
                      AND (
                              (ISNULL(h.strSecondName, '') = CASE ISNULL(@PatientMiddleName, '')
                                                                 WHEN '' THEN
                                                                     ISNULL(h.strSecondName, '')
                                                                 ELSE
                                                                     @PatientMiddleName
                                                             END
                              )
                              OR (CHARINDEX(@PatientMiddleName, ISNULL(h.strSecondName, '')) > 0)
                          )
                      AND (
                              (ISNULL(h.strLastName, '') = CASE ISNULL(@PatientLastName, '')
                                                               WHEN '' THEN
                                                                   ISNULL(h.strLastName, '')
                                                               ELSE
                                                                   @PatientLastName
                                                           END
                              )
                              OR (CHARINDEX(@PatientLastName, ISNULL(h.strLastName, '')) > 0)
                          )
                      AND (
                              hc.idfsSite = @DataEntrySiteID
                              OR @DataEntrySiteID IS NULL
                          )
                      AND (
                              (
                                  hc.idfOutbreak IS NULL
                                  AND @OutbreakCasesIndicator = 0
                              )
                              OR (
                                     hc.idfOutbreak IS NOT NULL
                                     AND @OutbreakCasesIndicator = 1
                                 )
                              OR (@OutbreakCasesIndicator IS NULL)
                          )
                      AND (
                              hc.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                              OR @ReportID IS NULL
                          )
                      AND (
                              hc.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                              OR @LegacyReportID IS NULL
                          )
                      AND (
                              m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                              OR @LocalOrFieldSampleID IS NULL
                          )
                      AND (
                              hc.idfsOutcome = @OutcomeID
                              OR @OutcomeID IS NULL
                          )
                GROUP BY hc.idfHumanCase;
            END
        END
        ELSE
        BEGIN -- Configurable Filtration Rules
            DECLARE @InitialFilteredResults TABLE
            (
                ID BIGINT NOT NULL,
                ReadPermissionIndicator INT NOT NULL,
                AccessToPersonalDataPermissionIndicator INT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
                WritePermissionIndicator INT NOT NULL,
                DeletePermissionIndicator INT NOT NULL, INDEX IDX_ID (ID
                                                                     ));

            INSERT INTO @InitialFilteredResults
            SELECT idfHumanCase,
                   1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.tlbHumanCase
            WHERE intRowStatus = 0
                  AND idfsSite = @UserSiteID;

            IF @RecordIdentifierSearchIndicator = 1
            BEGIN
                INSERT INTO @Results
                SELECT idfHumanCase,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM @InitialFilteredResults res
                    INNER JOIN dbo.tlbHumanCase hc
                        ON hc.idfHumanCase = res.ID
                WHERE intRowStatus = 0
                      AND idfsFinalDiagnosis IS NOT NULL
                      AND (
                              strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                              OR @ReportID IS NULL
                          )
                      AND (
                              LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                              OR @LegacyReportID IS NULL
                          )
            END
            ELSE
            BEGIN
                INSERT INTO @Results
                SELECT hc.idfHumanCase,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM @InitialFilteredResults res
                    INNER JOIN dbo.tlbHumanCase hc
                        ON hc.idfHumanCase = res.ID
                    INNER JOIN dbo.tlbHuman h
                        ON h.idfHuman = hc.idfHuman
                           AND h.intRowStatus = 0
                    INNER JOIN dbo.tlbGeoLocation currentAddress
                        ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
                    LEFT JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = currentAddress.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    LEFT JOIN dbo.tlbMaterial m
                        ON m.idfHumanCase = hc.idfHumanCase
                           AND m.intRowStatus = 0
                    LEFT JOIN dbo.tlbGeoLocation exposure
                        ON exposure.idfGeoLocation = hc.idfPointGeoLocation
                    LEFT JOIN dbo.gisLocationDenormalized gExposure
                        ON gExposure.idfsLocation = exposure.idfsLocation
                           AND gExposure.idfsLanguage = @LanguageCode
                WHERE hc.idfsFinalDiagnosis IS NOT NULL
                      AND (
                              hc.idfHumanCase = @ReportKey
                              OR @ReportKey IS NULL
                          )
                      AND (
                              hc.idfParentMonitoringSession = @SessionKey
                              OR @SessionKey IS NULL
                          )
                      AND (
                              h.idfHumanActual = @PatientID
                              OR @PatientID IS NULL
                          )
                      AND (
                              h.strPersonId = @PersonID
                              OR @PersonID IS NULL
                          )
                      AND (
                              idfsFinalDiagnosis = @DiseaseID
                              OR @DiseaseID IS NULL
                          )
                      AND (
                              idfsCaseProgressStatus = @ReportStatusTypeID
                              OR @ReportStatusTypeID IS NULL
                          )
                      AND (
                              g.Level1ID = @AdministrativeLevelID
                              OR g.Level2ID = @AdministrativeLevelID
                              OR g.Level3ID = @AdministrativeLevelID
                              OR g.Level4ID = @AdministrativeLevelID
                              OR g.Level5ID = @AdministrativeLevelID
                              OR g.Level6ID = @AdministrativeLevelID
                              OR g.Level7ID = @AdministrativeLevelID
                              OR @AdministrativeLevelID IS NULL
                          )
                      AND (
                              hc.datEnteredDate >= @DateEnteredFrom
                              OR @DateEnteredFrom IS NULL
                          )
                      AND (
                              (CONVERT(DATE, hc.datEnteredDate, 102) <= @DateEnteredTo)
                              OR @DateEnteredTo IS NULL
                          )
                      AND (
                              (CAST(hc.datFinalDiagnosisDate AS DATE)
                      BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                              )
                              OR (
                                     @DiagnosisDateFrom IS NULL
                                     OR @DiagnosisDateTo IS NULL
                                 )
                          )
                      AND (
                              (CAST(hc.datNotificationDate AS DATE)
                      BETWEEN @NotificationDateFrom AND @NotificationDateTo
                              )
                              OR (
                                     @NotificationDateFrom IS NULL
                                     OR @NotificationDateTo IS NULL
                                 )
                          )
                      AND (
                              (CAST(hc.datOnSetDate AS DATE)
                      BETWEEN @DateOfSymptomsOnsetFrom AND @DateOfSymptomsOnsetTo
                              )
                              OR (
                                     @DateOfSymptomsOnsetFrom IS NULL
                                     OR @DateOfSymptomsOnsetTo IS NULL
                                 )
                          )
                      AND (
                              (CAST(hc.datFinalCaseClassificationDate AS DATE)
                      BETWEEN @DateOfFinalCaseClassificationFrom AND @DateOfFinalCaseClassificationTo
                              )
                              OR (
                                     @DateOfFinalCaseClassificationFrom IS NULL
                                     OR @DateOfFinalCaseClassificationTo IS NULL
                                 )
                          )
                      AND (
                              hc.idfReceivedByOffice = @ReceivedByFacilityID
                              OR @ReceivedByFacilityID IS NULL
                          )
                      AND (
                              hc.idfSentByOffice = @SentByFacilityID
                              OR @SentByFacilityID IS NULL
                          )
                      AND (
                              idfsFinalCaseStatus = @ClassificationTypeID
                              OR @ClassificationTypeID IS NULL
                          )
                      AND (
                              idfsYNHospitalization = @HospitalizationYNID
                              OR @HospitalizationYNID IS NULL
                          )
                      AND (
                              gExposure.Level1ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level2ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level3ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level4ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level5ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level6ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level7ID = @LocationOfExposureAdministrativeLevelID
                              OR @LocationOfExposureAdministrativeLevelID IS NULL
                          )
                      AND (
                              (ISNULL(h.strFirstName, '') = CASE ISNULL(@PatientFirstName, '')
                                                                WHEN '' THEN
                                                                    ISNULL(h.strFirstName, '')
                                                                ELSE
                                                                    @PatientFirstName
                                                            END
                              )
                              OR (CHARINDEX(@PatientFirstName, ISNULL(h.strFirstName, '')) > 0)
                          )
                      AND (
                              (ISNULL(h.strSecondName, '') = CASE ISNULL(@PatientMiddleName, '')
                                                                 WHEN '' THEN
                                                                     ISNULL(h.strSecondName, '')
                                                                 ELSE
                                                                     @PatientMiddleName
                                                             END
                              )
                              OR (CHARINDEX(@PatientMiddleName, ISNULL(h.strSecondName, '')) > 0)
                          )
                      AND (
                              (ISNULL(h.strLastName, '') = CASE ISNULL(@PatientLastName, '')
                                                               WHEN '' THEN
                                                                   ISNULL(h.strLastName, '')
                                                               ELSE
                                                                   @PatientLastName
                                                           END
                              )
                              OR (CHARINDEX(@PatientLastName, ISNULL(h.strLastName, '')) > 0)
                          )
                      AND (
                              hc.idfsSite = @DataEntrySiteID
                              OR @DataEntrySiteID IS NULL
                          )
                      AND (
                              (
                                  hc.idfOutbreak IS NULL
                                  AND @OutbreakCasesIndicator = 0
                              )
                              OR (
                                     hc.idfOutbreak IS NOT NULL
                                     AND @OutbreakCasesIndicator = 1
                                 )
                              OR (@OutbreakCasesIndicator IS NULL)
                          )
                      AND (
                              hc.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                              OR @ReportID IS NULL
                          )
                      AND (
                              hc.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                              OR @LegacyReportID IS NULL
                          )
                      AND (
                              m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                              OR @LocalOrFieldSampleID IS NULL
                          )
                      AND (
                              hc.idfsOutcome = @OutcomeID
                              OR @OutcomeID IS NULL
                          )
                GROUP BY hc.idfHumanCase;
            END

            DECLARE @FilteredResults TABLE
            (
                ID BIGINT NOT NULL,
                ReadPermissionIndicator INT NOT NULL,
                AccessToPersonalDataPermissionIndicator INT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
                WritePermissionIndicator INT NOT NULL,
                DeletePermissionIndicator INT NOT NULL, INDEX IDX_ID (ID
                                                                     ));

            -- =======================================================================================
            -- DEFAULT CONFIGURABLE FILTRATION RULES
            --
            -- Apply active default filtration rules for third level sites.
            -- =======================================================================================
            DECLARE @RuleActiveStatus INT = 0;
            DECLARE @AdministrativeLevelTypeID INT;
            DECLARE @DefaultAccessRules AS TABLE
            (
                AccessRuleID BIGINT NOT NULL,
                ActiveIndicator INT NOT NULL,
                ReadPermissionIndicator INT NOT NULL,
                AccessToPersonalDataPermissionIndicator INT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
                WritePermissionIndicator INT NOT NULL,
                DeletePermissionIndicator INT NOT NULL,
                AdministrativeLevelTypeID INT NULL
            );

            INSERT INTO @DefaultAccessRules
            SELECT AccessRuleID,
                   a.intRowStatus,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator,
                   a.AdministrativeLevelTypeID
            FROM dbo.AccessRule a
            WHERE DefaultRuleIndicator = 1;

            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537000;

            IF @RuleActiveStatus = 0
            BEGIN
                SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
                FROM @DefaultAccessRules
                WHERE AccessRuleID = 10537000;

                SELECT @FiltrationSiteAdministrativeLevelID = CASE
                                                                  WHEN @AdministrativeLevelTypeID = 1 THEN
                                                                      g.Level1ID
                                                                  WHEN @AdministrativeLevelTypeID = 2 THEN
                                                                      g.Level2ID
                                                                  WHEN @AdministrativeLevelTypeID = 3 THEN
                                                                      g.Level3ID
                                                                  WHEN @AdministrativeLevelTypeID = 4 THEN
                                                                      g.Level4ID
                                                                  WHEN @AdministrativeLevelTypeID = 5 THEN
                                                                      g.Level5ID
                                                                  WHEN @AdministrativeLevelTypeID = 6 THEN
                                                                      g.Level6ID
                                                                  WHEN @AdministrativeLevelTypeID = 7 THEN
                                                                      g.Level7ID
                                                              END
                FROM dbo.tlbOffice o
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                WHERE o.intRowStatus = 0
                      AND o.idfOffice = @UserOrganizationID;

                -- Administrative level specified in the rule of the site where the report was created.
                INSERT INTO @FilteredResults
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tstSite s
                        ON h.idfsSite = s.idfsSite
                    INNER JOIN dbo.tlbOffice o
                        ON o.idfOffice = s.idfOffice
                           AND o.intRowStatus = 0
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537000
                WHERE h.intRowStatus = 0
                      AND (
                              g.Level1ID = @FiltrationSiteAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          )

                -- Administrative level specified in the rule of the report current residence address.
                INSERT INTO @FilteredResults
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tlbHuman hu
                        ON hu.idfHuman = h.idfHuman
                           AND hu.intRowStatus = 0
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = hu.idfCurrentResidenceAddress
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537000
                WHERE h.intRowStatus = 0
                      AND (
                              g.Level1ID = @FiltrationSiteAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          )

                -- Administrative level specified in the rule of the report location of exposure, 
                -- if corresponding field was filled in.
                INSERT INTO @FilteredResults
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = h.idfPointGeoLocation
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537000
                WHERE h.intRowStatus = 0
                      AND (
                              g.Level1ID = @FiltrationSiteAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          )
            END;

            -- Report data shall be available to all sites' organizations connected to the particular report.
            -- Notification sent by, notification received by, facility where the patient first sought 
            -- care, hospital, and the conducting investigation organizations.
            SELECT @RuleActiveStatus = intRowStatus
            FROM dbo.AccessRule
            WHERE AccessRuleID = 10537001;

            IF @RuleActiveStatus = 0
            BEGIN
                INSERT INTO @FilteredResults
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537001
                WHERE h.intRowStatus = 0
                      AND (
                              h.idfSentByOffice = @UserOrganizationID
                              OR h.idfReceivedByOffice = @UserOrganizationID
                              OR h.idfSoughtCareFacility = @UserOrganizationID
                              OR h.idfHospital = @UserOrganizationID
                              OR h.idfInvestigatedByOffice = @UserOrganizationID
                          )
                ORDER BY h.idfHumanCase;

                -- Sample collected by and sent to organizations
                INSERT INTO @FilteredResults
                SELECT MAX(m.idfHumanCase),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbHumanCase h
                        ON h.idfHumanCase = m.idfHumanCase
                           AND h.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537001
                WHERE m.intRowStatus = 0
                      AND (
                              m.idfFieldCollectedByOffice = @UserOrganizationID
                              OR m.idfSendToOffice = @UserOrganizationID
                          )
                GROUP BY m.idfHumanCase,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;

                -- Sample transferred to organizations
                INSERT INTO @FilteredResults
                SELECT MAX(m.idfHumanCase),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbHumanCase h
                        ON h.idfHumanCase = m.idfHumanCase
                           AND h.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOutMaterial tom
                        ON m.idfMaterial = tom.idfMaterial
                           AND tom.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOUT t
                        ON tom.idfTransferOut = t.idfTransferOut
                           AND t.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537001
                WHERE m.intRowStatus = 0
                      AND t.idfSendToOffice = @UserOrganizationID
                GROUP BY m.idfHumanCase,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;
            END;

            --
            -- Report data shall be available to the sites with the connected outbreak, if the report 
            -- is the primary report/session for an outbreak.
            --
            SELECT @RuleActiveStatus = intRowStatus
            FROM dbo.AccessRule
            WHERE AccessRuleID = 10537002;

            IF @RuleActiveStatus = 0
            BEGIN
                INSERT INTO @FilteredResults
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tlbOutbreak o
                        ON h.idfHumanCase = o.idfPrimaryCaseOrSession
                           AND o.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537002
                WHERE h.intRowStatus = 0
                      AND o.idfsSite = @UserSiteID;
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
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
                INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                    ON userSiteGroup.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's employee group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's ID level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
                INNER JOIN dbo.tstUserTable u
                    ON u.idfPerson = @UserEmployeeID
                       AND u.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorUserID = u.idfUserID
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND sgs.idfsSite = h.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteID = h.idfsSite;

            -- 
            -- Apply at the user's employee group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteID = h.idfsSite;

            -- 
            -- Apply at the user's ID level, granted by a site.
            ----
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tstUserTable u
                    ON u.idfPerson = @UserEmployeeID
                       AND u.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorUserID = u.idfUserID
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteID = h.idfsSite;

            -- Copy filtered results to results and use search criteria
            INSERT INTO @Results
            SELECT ID,
                   ReadPermissionIndicator,
                   AccessToPersonalDataPermissionIndicator,
                   AccessToGenderAndAgeDataPermissionIndicator,
                   WritePermissionIndicator,
                   DeletePermissionIndicator
            FROM @FilteredResults
                INNER JOIN dbo.tlbHumanCase hc
                    ON hc.idfHumanCase = ID
                INNER JOIN dbo.tlbHuman h
                    ON h.idfHuman = hc.idfHuman
                       AND h.intRowStatus = 0
                INNER JOIN dbo.tlbHumanActual ha
                    ON ha.idfHumanActual = h.idfHumanActual
                       AND ha.intRowStatus = 0
                INNER JOIN dbo.tlbGeoLocation currentAddress
                    ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
                LEFT JOIN dbo.gisLocationDenormalized g
                    ON g.idfsLocation = currentAddress.idfsLocation
                       AND g.idfsLanguage = @LanguageCode
                LEFT JOIN dbo.tlbMaterial m
                    ON m.idfHumanCase = hc.idfHumanCase
                       AND m.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocation exposure
                    ON exposure.idfGeoLocation = hc.idfPointGeoLocation
                LEFT JOIN dbo.gisLocationDenormalized gExposure
                    ON gExposure.idfsLocation = exposure.idfsLocation
                       AND gExposure.idfsLanguage = @LanguageCode
            WHERE hc.intRowStatus = 0
                  AND hc.idfsFinalDiagnosis IS NOT NULL
                  AND (
                          hc.idfHumanCase = @ReportKey
                          OR @ReportKey IS NULL
                      )
                  AND (
                          hc.idfParentMonitoringSession = @SessionKey
                          OR @SessionKey IS NULL
                      )
                  AND (
                          ha.idfHumanActual = @PatientID
                          OR @PatientID IS NULL
                      )
                  AND (
                          h.strPersonId = @PersonID
                          OR @PersonID IS NULL
                      )
                  AND (
                          idfsFinalDiagnosis = @DiseaseID
                          OR @DiseaseID IS NULL
                      )
                  AND (
                          idfsCaseProgressStatus = @ReportStatusTypeID
                          OR @ReportStatusTypeID IS NULL
                      )
                  AND (
                          g.Level1ID = @AdministrativeLevelID
                          OR g.Level2ID = @AdministrativeLevelID
                          OR g.Level3ID = @AdministrativeLevelID
                          OR g.Level4ID = @AdministrativeLevelID
                          OR g.Level5ID = @AdministrativeLevelID
                          OR g.Level6ID = @AdministrativeLevelID
                          OR g.Level7ID = @AdministrativeLevelID
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          hc.datEnteredDate >= @DateEnteredFrom
                          OR @DateEnteredFrom IS NULL
                      )
                  AND (
                          (CONVERT(DATE, hc.datEnteredDate, 102) <= @DateEnteredTo)
                          OR @DateEnteredTo IS NULL
                      )
                  AND (
                          (CAST(hc.datFinalDiagnosisDate AS DATE)
                  BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                          )
                          OR (
                                 @DiagnosisDateFrom IS NULL
                                 OR @DiagnosisDateTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datNotificationDate AS DATE)
                  BETWEEN @NotificationDateFrom AND @NotificationDateTo
                          )
                          OR (
                                 @NotificationDateFrom IS NULL
                                 OR @NotificationDateTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datOnSetDate AS DATE)
                  BETWEEN @DateOfSymptomsOnsetFrom AND @DateOfSymptomsOnsetTo
                          )
                          OR (
                                 @DateOfSymptomsOnsetFrom IS NULL
                                 OR @DateOfSymptomsOnsetTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datFinalCaseClassificationDate AS DATE)
                  BETWEEN @DateOfFinalCaseClassificationFrom AND @DateOfFinalCaseClassificationTo
                          )
                          OR (
                                 @DateOfFinalCaseClassificationFrom IS NULL
                                 OR @DateOfFinalCaseClassificationTo IS NULL
                             )
                      )
                  AND (
                          hc.idfReceivedByOffice = @ReceivedByFacilityID
                          OR @ReceivedByFacilityID IS NULL
                      )
                  AND (
                          hc.idfSentByOffice = @SentByFacilityID
                          OR @SentByFacilityID IS NULL
                      )
                  AND (
                          idfsFinalCaseStatus = @ClassificationTypeID
                          OR @ClassificationTypeID IS NULL
                      )
                  AND (
                          idfsYNHospitalization = @HospitalizationYNID
                          OR @HospitalizationYNID IS NULL
                      )
                  AND (
                          gExposure.Level1ID = @LocationOfExposureAdministrativeLevelID
                          OR gExposure.Level2ID = @LocationOfExposureAdministrativeLevelID
                          OR gExposure.Level3ID = @LocationOfExposureAdministrativeLevelID
                          OR gExposure.Level4ID = @LocationOfExposureAdministrativeLevelID
                          OR gExposure.Level5ID = @LocationOfExposureAdministrativeLevelID
                          OR gExposure.Level6ID = @LocationOfExposureAdministrativeLevelID
                          OR gExposure.Level7ID = @LocationOfExposureAdministrativeLevelID
                          OR @LocationOfExposureAdministrativeLevelID IS NULL
                      )
                  AND (
                          (ISNULL(h.strFirstName, '') = CASE ISNULL(@PatientFirstName, '')
                                                            WHEN '' THEN
                                                                ISNULL(h.strFirstName, '')
                                                            ELSE
                                                                @PatientFirstName
                                                        END
                          )
                          OR (CHARINDEX(@PatientFirstName, ISNULL(h.strFirstName, '')) > 0)
                      )
                  AND (
                          (ISNULL(h.strSecondName, '') = CASE ISNULL(@PatientMiddleName, '')
                                                             WHEN '' THEN
                                                                 ISNULL(h.strSecondName, '')
                                                             ELSE
                                                                 @PatientMiddleName
                                                         END
                          )
                          OR (CHARINDEX(@PatientMiddleName, ISNULL(h.strSecondName, '')) > 0)
                      )
                  AND (
                          (ISNULL(h.strLastName, '') = CASE ISNULL(@PatientLastName, '')
                                                           WHEN '' THEN
                                                               ISNULL(h.strLastName, '')
                                                           ELSE
                                                               @PatientLastName
                                                       END
                          )
                          OR (CHARINDEX(@PatientLastName, ISNULL(h.strLastName, '')) > 0)
                      )
                  AND (
                          hc.idfsSite = @DataEntrySiteID
                          OR @DataEntrySiteID IS NULL
                      )
                  AND (
                          (
                              hc.idfOutbreak IS NULL
                              AND @OutbreakCasesIndicator = 0
                          )
                          OR (
                                 hc.idfOutbreak IS NOT NULL
                                 AND @OutbreakCasesIndicator = 1
                             )
                          OR (@OutbreakCasesIndicator IS NULL)
                      )
                  AND (
                          hc.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                          OR @ReportID IS NULL
                      )
                  AND (
                          hc.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                          OR @LegacyReportID IS NULL
                      )
                  AND (
                          m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                          OR @LocalOrFieldSampleID IS NULL
                      )
                  AND (
                          hc.idfsOutcome = @OutcomeID
                          OR @OutcomeID IS NULL
                      )
            GROUP BY ID,
                     ReadPermissionIndicator,
                     AccessToPersonalDataPermissionIndicator,
                     AccessToGenderAndAgeDataPermissionIndicator,
                     WritePermissionIndicator,
                     DeletePermissionIndicator;
        END;

        -- =======================================================================================
        -- Remove "Outbreak" tied disease reports, if filtering is needed
        -- =======================================================================================
        IF @FilterOutbreakTiedReports = 1
        BEGIN
            DELETE I
            FROM @Results I
                INNER JOIN dbo.tlbHumanCase hc
                    ON hc.idfHumanCase = I.ID
            WHERE hc.idfOutbreak IS NOT NULL;
        END;

        -- =======================================================================================
        -- DISEASE FILTRATION RULES
        --
        -- Apply disease filtration rules from use case SAUC62.
        -- =======================================================================================
        -- 
        -- Apply level 0 disease filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without disease filtration rules applied.
        --
        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT hc.idfHumanCase
            FROM dbo.tlbHumanCase hc
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = hc.idfsFinalDiagnosis
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE hc.intRowStatus = 0
                  AND oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = eg.idfEmployeeGroup
        );

        --
        -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        INSERT INTO @Results
        SELECT hc.idfHumanCase,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbHumanCase hc
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = hc.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND hc.intRowStatus = 0
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup
              AND hc.idfsFinalDiagnosis IS NOT NULL
        GROUP BY hc.idfHumanCase;

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbHumanCase hc
                ON hc.idfHumanCase = res.ID
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = hc.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 1 -- Deny permission
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup;

        --
        -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT hc.idfHumanCase,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbHumanCase hc
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = hc.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND hc.intRowStatus = 0
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = @UserEmployeeID
              AND hc.idfsFinalDiagnosis IS NOT NULL
        GROUP BY hc.idfHumanCase;

        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT hc.idfHumanCase
            FROM dbo.tlbHumanCase hc
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = hc.idfsFinalDiagnosis
                       AND oa.intRowStatus = 0
            WHERE hc.intRowStatus = 0
                  AND oa.intPermission = 1 -- Deny permission
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
            SELECT hc.idfHumanCase
            FROM dbo.tlbHumanCase hc
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = hc.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE hc.intRowStatus = 0
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
        SELECT hc.idfHumanCase,
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbHumanCase hc
        WHERE hc.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = hc.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbHumanCase hc
                ON hc.idfHumanCase = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = hc.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT hc.idfHumanCase,
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbHumanCase hc
        WHERE hc.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = hc.idfsSite
        );

        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT hc.idfHumanCase
            FROM dbo.tlbHumanCase hc
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = hc.idfsSite
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
            INNER JOIN dbo.tlbHumanCase hc
                ON hc.idfHumanCase = res.ID
            INNER JOIN dbo.tlbHuman h
                ON h.idfHuman = hc.idfHuman
                   AND h.intRowStatus = 0
            INNER JOIN dbo.tlbHumanActual ha
                ON ha.idfHumanActual = h.idfHumanActual
                   AND ha.intRowStatus = 0
            INNER JOIN dbo.tlbGeoLocation currentAddress
                ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
            LEFT JOIN dbo.gisLocationDenormalized g
                ON g.idfsLocation = currentAddress.idfsLocation
                   AND g.idfsLanguage = @LanguageCode
            LEFT JOIN dbo.tlbMaterial m
                ON m.idfHumanCase = hc.idfHumanCase
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbGeoLocation exposure
                ON exposure.idfGeoLocation = hc.idfPointGeoLocation
            LEFT JOIN dbo.gisLocationDenormalized gExposure
                ON gExposure.idfsLocation = exposure.idfsLocation
                   AND gExposure.idfsLanguage = @LanguageCode
        WHERE res.ReadPermissionIndicator IN ( 1, 3, 5 )
              AND hc.idfsFinalDiagnosis IS NOT NULL
              AND (
                      hc.idfHumanCase = @ReportKey
                      OR @ReportKey IS NULL
                  )
              AND (
                      hc.idfParentMonitoringSession = @SessionKey
                      OR @SessionKey IS NULL
                  )
              AND (
                      h.idfHumanActual = @PatientID
                      OR @PatientID IS NULL
                  )
              AND (
                      h.strPersonId = @PersonID
                      OR @PersonID IS NULL
                  )
              AND (
                      idfsFinalDiagnosis = @DiseaseID
                      OR @DiseaseID IS NULL
                  )
              AND (
                      idfsCaseProgressStatus = @ReportStatusTypeID
                      OR @ReportStatusTypeID IS NULL
                  )
              AND (
                      g.Level1ID = @AdministrativeLevelID
                      OR g.Level2ID = @AdministrativeLevelID
                      OR g.Level3ID = @AdministrativeLevelID
                      OR g.Level4ID = @AdministrativeLevelID
                      OR g.Level5ID = @AdministrativeLevelID
                      OR g.Level6ID = @AdministrativeLevelID
                      OR g.Level7ID = @AdministrativeLevelID
                      OR @AdministrativeLevelID IS NULL
                  )
              AND (
                      hc.datEnteredDate >= @DateEnteredFrom
                      OR @DateEnteredFrom IS NULL
                  )
              AND (
                      (CONVERT(date, hc.datEnteredDate, 102) <= @DateEnteredTo)
                      OR @DateEnteredTo IS NULL
                  )
              AND (
                      (CAST(hc.datFinalDiagnosisDate AS DATE)
              BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                      )
                      OR (
                             @DiagnosisDateFrom IS NULL
                             OR @DiagnosisDateTo IS NULL
                         )
                  )
              AND (
                      (CAST(hc.datNotificationDate AS DATE)
              BETWEEN @NotificationDateFrom AND @NotificationDateTo
                      )
                      OR (
                             @NotificationDateFrom IS NULL
                             OR @NotificationDateTo IS NULL
                         )
                  )
              AND (
                      (CAST(hc.datOnSetDate AS DATE)
              BETWEEN @DateOfSymptomsOnsetFrom AND @DateOfSymptomsOnsetTo
                      )
                      OR (
                             @DateOfSymptomsOnsetFrom IS NULL
                             OR @DateOfSymptomsOnsetTo IS NULL
                         )
                  )
              AND (
                      (CAST(hc.datFinalCaseClassificationDate AS DATE)
              BETWEEN @DateOfFinalCaseClassificationFrom AND @DateOfFinalCaseClassificationTo
                      )
                      OR (
                             @DateOfFinalCaseClassificationFrom IS NULL
                             OR @DateOfFinalCaseClassificationTo IS NULL
                         )
                  )
              AND (
                      hc.idfReceivedByOffice = @ReceivedByFacilityID
                      OR @ReceivedByFacilityID IS NULL
                  )
              AND (
                      hc.idfSentByOffice = @SentByFacilityID
                      OR @SentByFacilityID IS NULL
                  )
              AND (
                      idfsFinalCaseStatus = @ClassificationTypeID
                      OR @ClassificationTypeID IS NULL
                  )
              AND (
                      idfsYNHospitalization = @HospitalizationYNID
                      OR @HospitalizationYNID IS NULL
                  )
              AND (
                      gExposure.Level1ID = @LocationOfExposureAdministrativeLevelID
                      OR gExposure.Level2ID = @LocationOfExposureAdministrativeLevelID
                      OR gExposure.Level3ID = @LocationOfExposureAdministrativeLevelID
                      OR gExposure.Level4ID = @LocationOfExposureAdministrativeLevelID
                      OR gExposure.Level5ID = @LocationOfExposureAdministrativeLevelID
                      OR gExposure.Level6ID = @LocationOfExposureAdministrativeLevelID
                      OR gExposure.Level7ID = @LocationOfExposureAdministrativeLevelID
                      OR @LocationOfExposureAdministrativeLevelID IS NULL
                  )
              AND (
                      (ISNULL(h.strFirstName, '') = CASE ISNULL(@PatientFirstName, '')
                                                        WHEN '' THEN
                                                            ISNULL(h.strFirstName, '')
                                                        ELSE
                                                            @PatientFirstName
                                                    END
                      )
                      OR (CHARINDEX(@PatientFirstName, ISNULL(h.strFirstName, '')) > 0)
                  )
              AND (
                      (ISNULL(h.strSecondName, '') = CASE ISNULL(@PatientMiddleName, '')
                                                         WHEN '' THEN
                                                             ISNULL(h.strSecondName, '')
                                                         ELSE
                                                             @PatientMiddleName
                                                     END
                      )
                      OR (CHARINDEX(@PatientMiddleName, ISNULL(h.strSecondName, '')) > 0)
                  )
              AND (
                      (ISNULL(h.strLastName, '') = CASE ISNULL(@PatientLastName, '')
                                                       WHEN '' THEN
                                                           ISNULL(h.strLastName, '')
                                                       ELSE
                                                           @PatientLastName
                                                   END
                      )
                      OR (CHARINDEX(@PatientLastName, ISNULL(h.strLastName, '')) > 0)
                  )
              AND (
                      hc.idfsSite = @DataEntrySiteID
                      OR @DataEntrySiteID IS NULL
                  )
              AND (
                      (
                          hc.idfOutbreak IS NULL
                          AND @OutbreakCasesIndicator = 0
                      )
                      OR (
                             hc.idfOutbreak IS NOT NULL
                             AND @OutbreakCasesIndicator = 1
                         )
                      OR (@OutbreakCasesIndicator IS NULL)
                  )
              AND (
                      hc.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                      OR @ReportID IS NULL
                  )
              AND (
                      hc.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                      OR @LegacyReportID IS NULL
                  )
              AND (
                      m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                      OR @LocalOrFieldSampleID IS NULL
                  )
              AND (
                      hc.idfsOutcome = @OutcomeID
                      OR @OutcomeID IS NULL
                  )
        GROUP BY ID;

        WITH paging
        AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @SortColumn = 'ReportID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       hc.strCaseID
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'ReportID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       hc.strCaseID
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'EnteredDate'
                                                        AND @SortOrder = 'ASC' THEN
                                                       hc.datEnteredDate
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'EnteredDate'
                                                        AND @SortOrder = 'DESC' THEN
                                                       hc.datEnteredDate
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'DiseaseName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       disease.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'DiseaseName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       disease.name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'PersonName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       ISNULL(h.strLastName, N'') + ISNULL(', ' + h.strFirstName, N'')
                                                       + ISNULL(' ' + h.strSecondName, N'')
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'PersonName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       ISNULL(h.strLastName, N'') + ISNULL(', ' + h.strFirstName, N'')
                                                       + ISNULL(' ' + h.strSecondName, N'')
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'PersonLocation'
                                                        AND @SortOrder = 'ASC' THEN
                                               (LH.AdminLevel1Name + ', ' + LH.AdminLevel2Name)
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'PersonLocation'
                                                        AND @SortOrder = 'DESC' THEN
                                               (LH.AdminLevel1Name + ', ' + LH.AdminLevel2Name)
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'ClassificationTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       finalClassification.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'ClassificationTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       finalClassification.name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'ReportStatusTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       reportStatus.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'ReportStatusTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       reportStatus.name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'LegacyReportID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       hc.LegacyCaseID
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'LegacyReportID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       hc.LegacyCaseID
                                               END DESC
                                     ) AS ROWNUM,
                   res.ID AS ReportKey,
                   hc.strCaseId AS ReportID,
                   hc.LegacyCaseID AS LegacyReportID,
                   reportStatus.name AS ReportStatusTypeName,
                   reportType.name AS ReportTypeName,
                   hc.datTentativeDiagnosisDate AS TentativeDiagnosisDate,
                   hc.datFinalDiagnosisDate AS FinalDiagnosisDate,
                   ISNULL(finalClassification.name, initialClassification.name) AS ClassificationTypeName,
                   finalClassification.name AS FinalClassificationTypeName,
                   hc.datOnSetDate AS DateOfOnset,
                   hc.idfsFinalDiagnosis AS DiseaseID,
                   disease.Name AS DiseaseName,
                   h.idfHumanActual AS PersonMasterID,
                   hc.idfHuman AS PersonKey,
                   haai.EIDSSPersonID AS PersonID,
                   h.strPersonID AS PersonalID,
                   dbo.FN_GBL_ConcatFullName(h.strLastName, h.strFirstName, h.strSecondName) AS PersonName,
                   ISNULL(LH.AdminLevel1Name, '') + IIF(LH.AdminLevel2Name IS NULL, '', ', ')
                   + ISNULL(LH.AdminLevel2Name, '') AS PersonLocation,
                   ha.strEmployerName AS EmployerName,
                   hc.datEnteredDate AS EnteredDate,
                   ISNULL(p.strFamilyName, N'') + ISNULL(', ' + p.strFirstName, N'')
                   + ISNULL(' ' + p.strSecondName, N'') AS EnteredByPersonName,
                   organization.AbbreviatedName AS EnteredByOrganizationName, 
                   hc.datModificationDate AS ModificationDate,
                   ISNULL(hospitalization.name, hospitalization.strDefault) AS HospitalizationStatus,
                   hc.idfsSite AS SiteID,
                   res.ReadPermissionIndicator AS ReadPermissionIndicator,
                   res.AccessToPersonalDataPermissionIndicator AS AccessToPersonalDataPermissionIndicator,
                   res.AccessToGenderAndAgeDataPermissionIndicator AS AccessToGenderAndAgeDataPermissionIndicator,
                   res.WritePermissionIndicator AS WritePermissionIndicator,
                   res.DeletePermissionIndicator AS DeletePermissionIndicator,
                   COUNT(*) OVER () AS RecordCount,
                   (
                       SELECT COUNT(*) FROM dbo.tlbHumanCase hc WHERE hc.intRowStatus = 0
                   ) AS TotalCount,
                   LH.AdminLevel2Name AS Region,
                   LH.AdminLevel3Name AS Rayon
            FROM @FinalResults res
                INNER JOIN dbo.tlbHumanCase hc
                    ON hc.idfHumanCase = res.ID
                INNER JOIN dbo.tlbHuman h
                    ON h.idfHuman = hc.idfHuman
                       AND h.intRowStatus = 0
                INNER JOIN dbo.tlbHumanActual ha
                    ON ha.idfHumanActual = h.idfHumanActual
                       AND ha.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON gl.idfGeoLocation = h.idfCurrentResidenceAddress
                LEFT JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) LH
                    ON LH.idfsLocation = gl.idfsLocation
                LEFT JOIN dbo.HumanActualAddlInfo haai
                    ON haai.HumanActualAddlInfoUID = ha.idfHumanActual
                       AND haai.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                    ON disease.idfsReference = hc.idfsFinalDiagnosis
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) initialClassification
                    ON initialClassification.idfsReference = hc.idfsInitialCaseStatus
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) finalClassification
                    ON finalClassification.idfsReference = hc.idfsFinalCaseStatus
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000111) reportStatus
                    ON reportStatus.idfsReference = hc.idfsCaseProgressStatus
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000144) reportType
                    ON reportType.idfsReference = hc.DiseaseReportTypeID
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000041) hospitalization
                    ON hospitalization.idfsReference = idfsHospitalizationStatus
                LEFT JOIN dbo.tlbPerson p
                    ON p.idfPerson = hc.idfPersonEnteredBy
                       AND p.intRowStatus = 0
                INNER JOIN dbo.tstSite s 
                    ON s.idfsSite = hc.idfsSite
                LEFT JOIN dbo.FN_GBL_Institution_Min(@LanguageID) organization
                ON organization.idfOffice = p.idfInstitution
           )
        SELECT ReportKey,
               ReportID,
               LegacyReportID,
               ReportStatusTypeName,
               ReportTypeName,
               TentativeDiagnosisDate,
               FinalDiagnosisDate,
               ClassificationTypeName,
               FinalClassificationTypeName,
               DateOfOnset,
               DiseaseID,
               DiseaseName,
               PersonMasterID,
               PersonKey,
               PersonID,
               PersonalID,
               PersonName,
               PersonLocation,
               EmployerName,
               EnteredDate,
               EnteredByPersonName,
               EnteredByOrganizationName, 
               ModificationDate,
               HospitalizationStatus,
               SiteID,
               CASE
                   WHEN ReadPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN ReadPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN ReadPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN ReadPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, ReadPermissionIndicator)
               END AS ReadPermissionindicator,
               CASE
                   WHEN AccessToPersonalDataPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToPersonalDataPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN AccessToPersonalDataPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToPersonalDataPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, AccessToPersonalDataPermissionIndicator)
               END AS AccessToPersonalDataPermissionIndicator,
               CASE
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, AccessToGenderAndAgeDataPermissionIndicator)
               END AS AccessToGenderAndAgeDataPermissionIndicator,
               CASE
                   WHEN WritePermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN WritePermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN WritePermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN WritePermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, WritePermissionIndicator)
               END AS WritePermissionIndicator,
               CASE
                   WHEN DeletePermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN DeletePermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN DeletePermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN DeletePermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, DeletePermissionIndicator)
               END AS DeletePermissionIndicator,
               RecordCount,
               TotalCount,
               TotalPages = (RecordCount / @PageSize) + IIF(RecordCount % @PageSize > 0, 1, 0),
               CurrentPage = @Page,
               Region,
               Rayon
        FROM paging
        WHERE RowNum > @firstRec
              AND RowNum < @lastRec
        OPTION (RECOMPILE);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
GO
PRINT N'Altering Procedure [dbo].[USP_HUM_HUMAN_MASTER_GETList]...';


GO
-- ================================================================================================
-- Name: USP_HUM_HUMAN_MASTER_GETList
--
-- Description: Get human actual list for human, laboratory and veterinary modules.
--          
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mandar Kulkarni             Initial release.
-- Stephen Long     03/13/2018 Added additional address fields.
-- Stephen Long     08/23/2018 Added EIDSS person ID to list.
-- Stephen Long     09/26/2018 Added wildcard to the front of fields using the wildcard symbol, as 
--                             per use case.
-- Stephen Long		09/28/2018 Added order by and total records, as per use case.
-- Stephen Long     11/26/2018 Updated for the new API; removed returnCode and returnMsg. Total 
--                             records will need to be handled differently.
-- Stephen Long     12/14/2018 Added pagination set, page size and max pages per fetch parameters
--                             and fetch portion.
-- Stephen Long     12/30/2018 Renamed to master so the human get list stored procedure can query 
--                             the human table which is needed for the lab module instead of human 
--                             actual.
-- Stephen Long     01/18/2019 Changed date of birth to date of birth range, and duplicate check.
-- Stephen Long     04/08/2019 Changed full name from first name last name second name to last 
--                             name ', ' first name and then second name.
-- Stephen Long     07/07/2019 Added settlement ID and settlement name to select.
-- Ann Xiong	    10/29/2019 added PassportNumber to return
-- Ann Xiong		01/15/2020 Used humanAddress.strAddressString instead of 
--                             humanAddress.strForeignAddress for AddressString
-- Stephen Long     01/28/2021 Added order by clause to handle user selected sorting across 
--                             pagination sets.
-- Doug Albanese	06/11/2021 Refactored to conform to the new filtering requirements and return structure for our gridview.
-- Mark Wilson		10/05/2021 updated for changes to DOB rules, location udpates, etc...
-- Mark Wilson		10/26/2021 changed to nolock...
-- Ann Xiong		12/03/2021 Changed ha.datDateofBirth AS DateOfBirth to CONVERT(char(10), ha.datDateofBirth,126) AS DateOfBirth
-- Mike Kornegay	12/10/2021 Changed procedure to use denormailized location table function.
-- Mike Kornegay	01/12/2022 Swapped where condition referring to gisLocation for new flat location hierarchy and corrected ISNULL
--							   check on PersonalTypeID and fixed where statements on left joins.
-- Mike Kornegay	04/27/2022 Added AddressID and ContactPhoneNbrTypeID to revert fields after accidental alter.
-- Mike Kornegay	05/06/2022 Changed inner join to left join on FN_GBL_LocationHierarchy_Flattened so results return if location is not
--								in FN_GBL_LocationHierarchy_Flattened.
-- Stephen Long     09/22/2022 Add check for "0" page size.  If "0", then set to 1.
-- Stephen Long     10/10/2022 Added monitoring session ID parameter and where criteria.
-- Ann Xiong		11/10/2022 Added SettlementTypeID parameter and where criteria.
-- Stephen Long     03/30/2023 Removed option recompile; performance improvement.
-- Ann Xiong		11/10/2022 Added SettlementTypeID parameter and where criteria. 
-- Stephen Long     03/30/2023 Removed option recompile; performance improvement.
-- Mani             03/31/2023 Changed the Location Joins to Inner Join as Location is a requied field
-- Stephen Long     05/08/2023 Added dbo prefix on flattened hierarchy.

--
/*Test Code

EXEC dbo.USP_HUM_HUMAN_MASTER_GETList
	@LangID = 'en-US',
	@FirstOrGivenName = 'a',
--	@idfsLocation = 1344330000000 -- region = Baku
	@idfsLocation = 4720500000000  -- Rayon = Pirallahi (Baku)

EXEC dbo.USP_HUM_HUMAN_MASTER_GETList
	@LangID = 'en-US',
	@FirstOrGivenName = 'a',
    @DateOfBirthFrom = '2010-12-30 00:00:00.000',
    @DateOfBirthTo = '2012-12-30 00:00:00.000',
	--@idfsLocation = 1344330000000, -- region = Baku
	@idfsLocation = 1344380000000, -- Rayon = Khatai (Baku)
	@pageSize = 50000 
---------

DECLARE @return_value int

EXEC    @return_value = [dbo].[USP_HUM_HUMAN_MASTER_GETList]
        @LangID = N'en-US',
        @EIDSSPersonID = NULL,
        @PersonalIDType = NULL,
        @PersonalID = NULL,
        @FirstOrGivenName = 'a',
        @SecondName = NULL,
        @LastOrSurname = NULL,
        @DateOfBirthFrom = '1976-02-04 00:00:00.000',
        @DateOfBirthTo = '1980-02-04 00:00:00.000',
        @GenderTypeID = NULL,
		@idfsLocation = 1344330000000, -- region = Baku
        @pageNo = 1,
        @pageSize = 10,
        @sortColumn = N'EIDSSPersonID',
        @sortOrder = N'asc'

SELECT  @return_value
*/
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_HUM_HUMAN_MASTER_GETList]
(
    @LangID NVARCHAR(50),
    @EIDSSPersonID NVARCHAR(200) = NULL,
    @PersonalIDType BIGINT = NULL,
    @PersonalID NVARCHAR(100) = NULL,
    @FirstOrGivenName NVARCHAR(200) = NULL,
    @SecondName NVARCHAR(200) = NULL,
    @LastOrSurname NVARCHAR(200) = NULL,
    @DateOfBirthFrom DATETIME = NULL,
    @DateOfBirthTo DATETIME = NULL,
    @GenderTypeID BIGINT = NULL,
    @idfsLocation BIGINT = NULL,
    @MonitoringSessionID BIGINT = NULL,
    @SettlementTypeID BIGINT = NULL,
    @pageNo INT = 1,
    @pageSize INT = 10,
    @sortColumn NVARCHAR(30) = 'EIDSSPersonID',
    @sortOrder NVARCHAR(4) = 'DESC'
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @firstRec INT
        DECLARE @lastRec INT

        IF @PageSize = 0
        BEGIN
            SET @PageSize = 1;
        END

        DECLARE @DOB DATETIME = NULL

        IF (@DateOfBirthTo IS NOT NULL AND @DateOfBirthTo = @DateOfBirthFrom)
            SET @DOB = @DateOfBirthFrom

        SET @firstRec = (@pageNo - 1) * @pagesize
        SET @lastRec = (@pageNo * @pageSize + 1);

        WITH CTEResults
        AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @sortColumn = 'EIDSSPersonID'
                                                        AND @SortOrder = 'asc' THEN
                                                       hai.EIDSSPersonID
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'EIDSSPersonID'
                                                        AND @SortOrder = 'desc' THEN
                                                       hai.EIDSSPersonID
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'LastOrSurname'
                                                        AND @SortOrder = 'asc' THEN
                                                       ha.strLastName
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'LastOrSurname'
                                                        AND @SortOrder = 'desc' THEN
                                                       ha.strLastName
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'FirstOrGivenName'
                                                        AND @SortOrder = 'asc' THEN
                                                       ha.strFirstName
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'FirstOrGivenName'
                                                        AND @SortOrder = 'desc' THEN
                                                       ha.strFirstName
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'PersonalID'
                                                        AND @SortOrder = 'asc' THEN
                                                       ha.strPersonID
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'PersonalID'
                                                        AND @SortOrder = 'desc' THEN
                                                       ha.strPersonID
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'PersonIDTypeName'
                                                        AND @SortOrder = 'asc' THEN
                                                       idType.name
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'PersonIDTypeName'
                                                        AND @SortOrder = 'desc' THEN
                                                       idType.name
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'PassportNumber'
                                                        AND @SortOrder = 'asc' THEN
                                                       hai.PassportNbr
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'PassportNumber'
                                                        AND @SortOrder = 'desc' THEN
                                                       hai.PassportNbr
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'GenderTypeName'
                                                        AND @SortOrder = 'asc' THEN
                                                       genderType.name
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'GenderTypeName'
                                                        AND @SortOrder = 'desc' THEN
                                                       genderType.name
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'RayonName'
                                                        AND @SortOrder = 'asc' THEN
                                                       LH.AdminLevel3Name
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'RayonName'
                                                        AND @SortOrder = 'desc' THEN
                                                       LH.AdminLevel3Name
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'DateOfBirth'
                                                        AND @SortOrder = 'asc' THEN
                                                       ha.datDateofBirth
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'DateOfBirth'
                                                        AND @SortOrder = 'desc' THEN
                                                       ha.datDateofBirth
                                               END DESC
                                     ) AS ROWNUM,
                   COUNT(*) OVER () AS TotalRowCount,
                   ha.idfHumanActual AS HumanMasterID,
                   hai.EIDSSPersonID AS EIDSSPersonID,
                   ha.idfCurrentResidenceAddress AS AddressID,
                   ha.strFirstName AS FirstOrGivenName,
                   ha.strSecondName AS SecondName,
                   ha.strLastName AS LastOrSurname,
                   dbo.FN_GBL_ConcatFullName(ha.strLastName, ha.strFirstName, ha.strSecondName) AS FullName,
                   CONVERT(CHAR(10), ha.datDateofBirth, 126) AS DateOfBirth,
                   ha.strPersonID AS PersonalID,
                   ISNULL(idType.[name], idType.strDefault) AS PersonIDTypeName,
                   humanAddress.strStreetName AS StreetName,
                   dbo.FN_GBL_CreateAddressString(
                                                     LH.AdminLevel1Name,
                                                     LH.AdminLevel2Name,
                                                     LH.AdminLevel3Name,
                                                     humanAddress.strPostCode,
                                                     '',
                                                     LH.AdminLevel4Name,
                                                     humanAddress.strStreetName,
                                                     humanAddress.strHouse,
                                                     humanAddress.strBuilding,
                                                     humanAddress.strApartment,
                                                     humanAddress.blnForeignAddress,
                                                     ''
                                                 ) AS AddressString,
                   (CONVERT(NVARCHAR(100), humanAddress.dblLatitude) + ', '
                    + CONVERT(NVARCHAR(100), humanAddress.dblLongitude)
                   ) AS LongitudeLatitude,
                   hai.ContactPhoneCountryCode AS ContactPhoneCountryCode,
                   hai.ContactPhoneNbr AS ContactPhoneNumber,
                   hai.ContactPhoneNbrTypeID AS ContactPhoneNbrTypeID,
                   hai.ReportedAge AS Age,
                   hai.PassportNbr AS PassportNumber,
                   ha.idfsNationality AS CitizenshipTypeID,
                   citizenshipType.[name] AS CitizenshipTypeName,
                   ha.idfsHumanGender AS GenderTypeID,
                   genderType.[name] AS GenderTypeName,
                   humanAddress.idfsCountry AS CountryID,
                   LH.AdminLevel1Name AS CountryName,
                   LH.AdminLevel2ID AS RegionID,
                   LH.AdminLevel2Name AS RegionName,
                   LH.AdminLevel3ID AS RayonID,
                   LH.AdminLevel3Name AS RayonName,
                   humanAddress.idfsSettlement AS SettlementID,
                   LH.AdminLevel4Name AS SettlementName,
                   dbo.FN_GBL_CreateAddressString(
                                                     LH.AdminLevel1Name,
                                                     LH.AdminLevel2Name,
                                                     LH.AdminLevel3Name,
                                                     '',
                                                     '',
                                                     '',
                                                     '',
                                                     '',
                                                     '',
                                                     '',
                                                     humanAddress.blnForeignAddress,
                                                     humanAddress.strForeignAddress
                                                 ) AS FormattedAddressString
            FROM dbo.tlbHumanActual AS ha WITH (NOLOCK)
                INNER JOIN dbo.HumanActualAddlInfo hai WITH (NOLOCK)
                    ON ha.idfHumanActual = hai.HumanActualAddlInfoUID
                       AND hai.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000043) genderType
                    ON ha.idfsHumanGender = genderType.idfsReference
                       AND genderType.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000148) idType
                    ON ha.idfsPersonIDType = idType.idfsReference
                       AND idType.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000054) citizenshipType
                    ON ha.idfsNationality = citizenshipType.idfsReference
                       AND citizenshipType.intRowStatus = 0
                INNER JOIN dbo.tlbGeoLocationShared humanAddress WITH (NOLOCK)
                    ON ha.idfCurrentResidenceAddress = humanAddress.idfGeoLocationShared
                       AND humanAddress.intRowStatus = 0
                INNER JOIN dbo.gisLocation L WITH (NOLOCK)
                    ON L.idfsLocation = humanAddress.idfsLocation
                INNER JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) LH
                    ON LH.idfsLocation = humanAddress.idfsLocation
            WHERE (
                      ha.intRowStatus = 0
                      AND (
                              (
                                  @idfsLocation IS NOT NULL
                                  AND (
                                          LH.AdminLevel1ID = @idfsLocation
                                          OR LH.AdminLevel2ID = @idfsLocation
                                          OR LH.AdminLevel3ID = @idfsLocation
                                          OR LH.AdminLevel4ID = @idfsLocation
                                          OR LH.AdminLevel5ID = @idfsLocation
                                          OR LH.AdminLevel6ID = @idfsLocation
                                          OR LH.AdminLevel7ID = @idfsLocation
                                      )
                              )
                              OR (@idfsLocation IS NULL)
                          )
                      AND (
                              (
                                  @SettlementTypeID IS NOT NULL
                                  AND L.idfsType = @SettlementTypeID
                              )
                              OR (@SettlementTypeID IS NULL)
                          )
                      AND (
                              @DOB = ha.datDateofBirth
                              OR @DateOfBirthFrom IS NULL
                              OR (ha.datDateofBirth
                  BETWEEN @DateOfBirthFrom AND @DateOfBirthTo
                                 )
                          )
                      AND (
                              (
                                  @EIDSSPersonID IS NOT NULL
                                  AND hai.EIDSSPersonID LIKE '%' + @EIDSSPersonID + '%'
                              )
                              OR @EIDSSPersonID IS NULL
                          )
                      AND (
                              (
                                  @PersonalID IS NOT NULL
                                  AND ha.strPersonID LIKE '%' + @PersonalID + '%'
                              )
                              OR @PersonalID IS NULL
                          )
                      AND (
                              (
                                  @FirstOrGivenName IS NOT NULL
                                  AND ha.strFirstName LIKE '%' + @FirstOrGivenName + '%'
                              )
                              OR @FirstOrGivenName IS NULL
                          )
                      AND (
                              (
                                  @SecondName IS NOT NULL
                                  AND ha.strSecondName LIKE '%' + @SecondName + '%'
                              )
                              OR @SecondName IS NULL
                          )
                      AND (
                              (
                                  @LastOrSurname IS NOT NULL
                                  AND ha.strLastName LIKE '%' + @LastOrSurname + '%'
                              )
                              OR @LastOrSurname IS NULL
                          )
                      AND (
                              (
                                  @PersonalIDType IS NOT NULL
                                  AND ha.idfsPersonIDType = @PersonalIDType
                              )
                              OR @PersonalIDType IS NULL
                          )
                      AND (
                              (
                                  @GenderTypeID IS NOT NULL
                                  AND ha.idfsHumanGender = @GenderTypeID
                              )
                              OR @GenderTypeID IS NULL
                          )
                      AND (
                              EXISTS
            (
                SELECT h.idfHuman
                FROM dbo.tlbHuman h
                    INNER JOIN dbo.tlbMaterial m
                        ON m.idfHuman = h.idfHuman
                WHERE h.idfHumanActual = ha.idfHumanActual
                      AND m.idfMonitoringSession = @MonitoringSessionID
            )
                              OR @MonitoringSessionID IS NULL
                          )
                  )
           )
        SELECT TotalRowCount,
               HumanMasterID,
               EIDSSPersonID,
               AddressID,
               FirstOrGivenName,
               SecondName,
               LastOrSurname,
               FullName,
               DateOfBirth,
               PersonalID,
               PersonIDTypeName,
               StreetName,
               AddressString,
               LongitudeLatitude,
               ContactPhoneCountryCode,
               ContactPhoneNumber,
               ContactPhoneNbrTypeID,
               Age,
               PassportNumber,
               CitizenshipTypeID,
               CitizenshipTypeName,
               GenderTypeID,
               GenderTypeName,
               CountryID,
               CountryName,
               RegionID,
               RegionName,
               RayonID,
               RayonName,
               SettlementID,
               SettlementName,
               FormattedAddressString,
               TotalPages = (TotalRowCount / @pageSize) + IIF(TotalRowCount % @pageSize > 0, 1, 0),
               CurrentPage = @pageNo
        FROM CTEResults
        WHERE RowNum > @firstRec
              AND RowNum < @lastRec;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO
PRINT N'Altering Procedure [dbo].[USP_ADMIN_EMP_ORGANIZATION_USER_GROUP_GETList]...';


GO
-- ================================================================================================
-- Name: USP_ADMIN_EMP_ORGANIZATION_USER_GROUP_GETList		
-- 
-- Description: Returns a list of Organizations, site IDs, User Groups for an Employee.
--
-- Revision History:
--		
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ann Xiong     	08/24/2020 Initial release.
-- Ann Xiong     	08/31/2020 Changed to consider default Organization
-- Ann Xiong     	09/08/2020 Rearranged scripts to return UserGroupID and UserGroup
-- Ann Xiong     	09/10/2020 Modified to return multiple Organizations
-- Ann Xiong     	09/14/2020 Added idfUserID to the select list.
-- Ann Xiong     	10/15/2020 Modified to return correct Organization from tlbPerson and return '' for SiteID and SiteName when s.idfsSite = 1.
-- Ann Xiong     	10/20/2020 Modified to return only active records (intRowStatus = 0) if there is any active records otherwise return Deactivated records (intRowStatus = 1).
-- Ann Xiong     	11/06/2020 Modified to only return record if intRowStatus = 0 for tlbEmployeeGroupMember
-- Stephen Long     12/11/2020 Added site group ID and site type ID to the query.
-- Stephen Long     01/08/2021 Add string aggregate function on site to site group to get a list 
--                             of site groups in a concatenated list.  Removed join on main query 
--                             to eliminate duplicates.
-- Mani				01/22/2021  Added OrganizationFullName
-- Minal			08/09/2021  Organization is picked from EmployeeToInstitution in place of Person
-- Ann Xiong     	03/23/2023 Modified to return translated User Group name
-- Stephen Long     05/05/2023 Replaced institution with institution min.
--
-- Testing Code:
-- EXEC USP_ADMIN_EMP_ORGANIZATION_USER_GROUP_GETList -471, 'en'
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_ADMIN_EMP_ORGANIZATION_USER_GROUP_GETList] (
	@idfPerson BIGINT
	,@LangID NVARCHAR(50)
	)
AS
BEGIN
	DECLARE @returnMsg VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode BIGINT = 0;

	BEGIN TRY
		DECLARE @aspNetUserId NVARCHAR(128);

		SELECT @aspNetUserId = ei.aspNetUserId
		FROM dbo.tstUserTable ut
		LEFT JOIN dbo.EmployeeToInstitution ei ON ut.idfUserID = ei.idfUserID
		WHERE ut.idfPerson = @idfPerson;

		SELECT ROW_NUMBER() OVER (
				ORDER BY ei.IsDefault DESC
					,ut.idfUserID
				) AS Row
			,s.idfsSite
			,CASE 
				WHEN s.idfsSite = 1
					THEN ''
				ELSE s.strSiteID
				END AS SiteID
			,CASE 
				WHEN s.idfsSite = 1
					THEN ''
				ELSE s.strSiteName
				END AS SiteName
			,ei.idfInstitution AS OrganizationID
			,o.AbbreviatedName AS Organization
			,o.EnglishFullName AS OrganizationFullName
			,STRING_AGG(g.idfEmployeeGroup, ', ') WITHIN
		GROUP (
				ORDER BY g.idfEmployeeGroup DESC
				) AS UserGroupID
			,STRING_AGG(egbr.[name], ', ') AS UserGroup
			,e.idfEmployee
			,ISNULL(ei.intRowStatus, 1) AS STATUS
			,ei.Active 
			,ei.IsDefault
			,ut.idfUserID
			,s.idfsSiteType AS SiteTypeID
			,NULL AS SiteGroupID --TODO: temporary fix until site filtration logic is adjusted to use new site group list below.  Will remove this field once complete.  SHL
			,(
				SELECT STRING_AGG(ssg.idfSiteGroup, ',') WITHIN
				GROUP (
						ORDER BY ssg.idfSiteGroup ASC
						) AS SiteGroupID
				FROM dbo.tflSiteToSiteGroup AS ssg 
				WHERE ssg.idfsSite = s.idfsSite
				) AS SiteGroupList
		FROM dbo.tstUserTable ut
		LEFT JOIN dbo.tlbEmployee e ON e.idfEmployee = ut.idfPerson
		LEFT JOIN dbo.tstSite s ON s.idfsSite = e.idfsSite
			AND s.intRowStatus = 0
		LEFT JOIN dbo.tlbPerson p ON e.idfEmployee = p.idfPerson
		LEFT JOIN dbo.EmployeeToInstitution ei ON ut.idfUserID = ei.idfUserID
		LEFT JOIN dbo.FN_GBL_Institution_Min(@LangID) o ON ei.idfInstitution = o.idfOffice
		LEFT JOIN dbo.tlbEmployeeGroupMember m ON m.idfEmployee = ut.idfPerson
			AND m.intRowStatus = 0
		LEFT JOIN dbo.tlbEmployeeGroup g ON m.idfEmployeeGroup = g.idfEmployeeGroup
			AND g.idfEmployeeGroup <> - 1
			AND g.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000022) egbr
					ON g.idfsEmployeeGroupName = egbr.idfsReference
		WHERE ei.aspNetUserId = @aspNetUserId
			AND ut.intRowStatus = 0
			AND e.intRowStatus = 0
		GROUP BY s.idfsSite
			,s.strSiteID
			,s.strSiteName
			,ei.idfInstitution
			,o.AbbreviatedName
			,e.idfEmployee
			,ei.intRowStatus
			,ei.Active
			,ei.IsDefault
			,ut.idfUserID
			,s.idfsSiteType
			,o.EnglishFullName;
	END TRY

	BEGIN CATCH
	THROW;
	END CATCH;
END
GO
PRINT N'Altering Procedure [dbo].[USP_ADMIN_FF_Copy_Template]...';


GO
-- ================================================================================================
-- Name: USP_ADMIN_FF_Copy_Template
-- Description: Copies the base structure of a template and its components to prevent historical damage.
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Doug Albanese	01/12/2021	Initial release for use by other SPs.
-- Doug Albanese	01/19/2021	Fixed the return to provide the new Form Template id
-- Doug Albanese	01/21/2021	Change of business rule to allow older templates to still be modified.
-- Doug Albanese	01/21/2021	Disabled UNI for the old template being copied.
-- Doug Albanese	07/02/2021	Altered the procedure to ignore blank idfsSections
-- Doug Albanese	07/06/2021	Refactored for use with a user initiated copy.
-- Doug Albanese	07/09/2021	Added language parameter
-- Doug Albanese	07/09/2021	Removed supression
-- Doug Albanese	07/12/2021	Corrected return aliases
-- Doug Albanese	07/12/2021	Corrections to remove copying of Sections and Parameters, and replace with association to the new template
-- Doug Albanese	07/14/2021	Turning off content to make this process a successor procedure only
-- Doug Albanese	07/14/2021	Created translation for SP generated "Copy"
-- Doug Albanese	07/14/2021	Added ordering from original template
-- Doug Albanese	07/14/2021	Added Edit Mode for Mandatory/Ordinary settings
--	Doug Albanese	05/12/2022	Adjusting for copying to another formtype
--	Doug Albanese	06/02/2022	Changed the functioncall parameter for USP_ADMIN_FF_ParameterTemplate_SET, to work with USP_ADMIN_FF_ParameterDesignOptions_SET
--	Doug Albanese	06/07/2022	Changed USP_ADMIN_FF_ParameterTemplate_SET, to call as a function
--	Doug Albanese	06/08/2022	Corrected the Determinants value copy. Was in the wrong place
--	Doug Albanese	06/10/2022	Making use of USP_ADMIN_FF_ParameterTemplateForCopy_SET, instead of USP_ADMIN_FF_ParameterTemplate_SET for EF Generation purposes
--								Realigned call to USP_Admin_FF_Rule_GetDetails for new changes
--	Doug Albanese	06/30/2022	Correcting the process of copying Determinants
--	Doug Albanese	07/01/2022	Removed rollback
--	Doug Albanese	07/21/2022	Re-aligned to work with changes made on USP_ADMIN_FF_Template_SET
--	Doug Albanese	08/04/2022	Added a secondary "intRowStatus"
--	Doug Albanese	08/04/2022	Corrected a call to USP_ADMIN_FF_Determinant_SET, because it was remotely set for Event logging.
--	Doug Albanese	08/04/2022	Corrected "Template Details" to coalesce the blnUNI value, when it was null
--  Doug Albanese	01/26/2023	Correction to allow Copying of templates to create Outbreak assigned flex forms.
-- Doug Albanese	03/22/2023	Changed SP to make use of UserId, instead of User...so that event logging will not break.
-- Doug Albanese	04/14/2023	Changed size of "Name" fields from 200 to 2000
-- Doug Albanese   04/25/2023	Added SourceSystemNameID and SourceSystemKeyValue to the "Rule Constant" insert statement
-- Doug Albanese  05/04/2023	Brought the determinant SQL, directly into this SP. The Event Logging was breaking in this "Auto Copy", done when a template is altered.
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_ADMIN_FF_Copy_Template] (
	@LangId									NVARCHAR(50),
	@idfsFormTemplate						BIGINT,
	@User									NVARCHAR(50),
	@idfsSite								BIGINT = NULL,
	@idfsNewFormType						BIGINT = NULL
)
AS
BEGIN
	DECLARE @returnCode						INT = 0;
	DECLARE @returnMsg						NVARCHAR(MAX) = 'SUCCESS';
	
	Declare @SupressSelect TABLE
	(	
		retrunCode							INT,
		returnMessage						VARCHAR(200)
	) 

	DECLARE @Supress_USP_ADMIN_FF_Parameters_SET TABLE (
		ReturnCode							INT,
		ReturnMessage						VARCHAR(200),
		idfsParameter						BIGINT,
		idfsParameterCaption				BIGINT
	)
	
	DECLARE @Supress_USP_ADMIN_FF_ParameterTemplate_SET TABLE(
		ReturnData							VARCHAR(200)
	)

	DECLARE @iObservations					INT = 0


	BEGIN TRY
		
		--Changes that have the potential to trigger copying of a template
		--Template details
		--Parameter addition, moving, or deleting from a template
		--Section addition, moving, or deleting from a template
		--Parameter Editor changes
		--Section Editor Changes
		--Updating "Mandatory" status
		--Adding, Editing, or Removing a Rule

		DECLARE @FormTemplate				NVARCHAR(2000)
		DECLARE @NationalName				NVARCHAR(2000)
		DECLARE @NationalLongName			NVARCHAR(2000)
		DECLARE @idfsFormType				BIGINT
		DECLARE @strNote					NVARCHAR(MAX)
		DECLARE @blnUNI						BIT

		DECLARE @idfsSection				BIGINT
		DECLARE @idfsParameter				BIGINT
		DECLARE @idfsParentSection			BIGINT 
		DECLARE @DefaultName				NVARCHAR(2000)
		DECLARE @DefaultLongName			NVARCHAR(2000)
		DECLARE @intOrder					INT
		DECLARE @blnGrid					BIT
		DECLARE @blnFixedRowset				BIT
		DECLARE @idfsMatrixType				BIGINT
		DECLARE @intRowStatus				INT
		DECLARE @idfsSectionNew				BIGINT
		DECLARE @idfsFormTemplateNew		BIGINT

		DECLARE @idfsParameterNew			BIGINT
		DECLARE	@idfsParameterCaption		BIGINT
		DECLARE @idfsParameterType			BIGINT
		DECLARE @idfsEditor					BIGINT
		DECLARE @intHACode					INT
		DECLARE @langid_int					BIGINT
		DECLARE @idfsRule					BIGINT
		DECLARE @idfsEditMode				BIGINT

		DECLARE @idfsRuleMessage			BIGINT
		DECLARE @idfsRuleFunction			BIGINT
		DECLARE @idfsRuleAction				BIGINT
		DECLARE	@idfsFunctionParameter		BIGINT
		DECLARE @idfsActionParameter		BIGINT
		DECLARE	@idfsFunctionParameterNew	BIGINT
		DECLARE @idfsActionParameterNew		BIGINT
		DECLARE @intNumberOfParameters		INT
		DECLARE @idfsCheckPoint				BIGINT
		DECLARE @MessageText				NVARCHAR(MAX)
		DECLARE @MessageNationalText		NVARCHAR(MAX)
		DECLARE @blnNot						BIT
		DECLARE	@idfsRuleNew				BIGINT
		DECLARE	@strFillValue				NVARCHAR(MAX)
		DECLARE	@strCompareValue			NVARCHAR(MAX)

		DECLARE @DefaultRuleName			NVARCHAR(MAX)
		DECLARE @NationalRuleName			NVARCHAR(MAX)
		DECLARE @DefaultRuleMessage			NVARCHAR(MAX)
		DECLARE @NationalRuleMessage		NVARCHAR(MAX)
		DECLARE @strActionParameters		NVARCHAR(MAX)

		DECLARE @idfRuleConstant			BIGINT
		DECLARE @idfRuleConstantNew			BIGINT
		DECLARE @varConstant				SQL_VARIANT

		DECLARE @idfDeterminantValue		BIGINT
		DECLARE @idfDeterminant				BIGINT
		DECLARE @idfsBaseReference			BIGINT
		DECLARE @idfsGISBaseReference		BIGINT

		DECLARE @strResourceString			NVARCHAR(200) = 'Copy'
		DECLARE @UserId						 BIGINT

		SET NOCOUNT ON

		SET @langid_int = dbo.FN_GBL_LanguageCode_GET(@LangID);

		SELECT @UserId = userInfo.UserId,
		  @idfsSite = userInfo.SiteId
		   FROM dbo.FN_UserSiteInformation(@User) userInfo;

		
		--Are any observations made for the given active (intRowStatus = 0) template?
		--SELECT
		--	@iObservations = COUNT(idfObservation)
		--FROM
		--	tlbObservation O
		--INNER JOIN ffFormTemplate FT
		--	ON FT.idfsFormTemplate = O.idfsFormTemplate
		--	AND FT.intRowStatus = 0
		--WHERE
		--	O.idfsFormTemplate = @idfsFormTemplate

		--IF @iObservations > 0
		--	BEGIN
				----------------------------------------------------------------------------------------
				--Create table structures for collecting up items to enumerate and tag,				  --
				--and capture EXEC results                                                            --
				----------------------------------------------------------------------------------------
				DECLARE @Sections TABLE (
					idfsSection			BIGINT NULL,
					idfsSectionNew		BIGINT NULL
				)

				DECLARE @Parameters TABLE (
					idfsParameter		BIGINT,
					idfsParameterNew	BIGINT,
					idfsSection			BIGINT,
					idfsSectionNew		BIGINT
				)

				DECLARE @ActionParameters TABLE (
					idfsParameter		BIGINT
				)

				DECLARE @FunctionParameters TABLE (
					idfsParameter		BIGINT
				)

				DECLARE @TemplateDetails TABLE (
					idfsFormTemplate	BIGINT,
					FormTemplate		NVARCHAR(2000),
					DefaultName			NVARCHAR(2000),
					NationalName		NVARCHAR(2000),
					idfsFormType		BIGINT,
					strNote				NVARCHAR(MAX),
					blnUNI				BIT
				)

				DECLARE @SectionSetResults TABLE (
					returnCode			BIGINT,
					returnMsg			NVARCHAR(MAX),
					idfsSection			BIGINT
				)

				DECLARE @SectionDetailResults TABLE (
					idfsParentSection	BIGINT,
					idfsFormType		BIGINT,
					intOrder			INT,
					blnGrid				BIT,
					blnFixedRowset		BIT,
					idfsMatrixType		BIGINT,
					strDefault			NVARCHAR(MAX),
					NationalName		NVARCHAR(MAX)
				)

				DECLARE @TemplateDetailsResults TABLE (
					returnCode			BIGINT,
					returnMsg			NVARCHAR(MAX),
					idfsFormTemplate	BIGINT
				)

				DECLARE	@Rules	TABLE (
					idfsRule			BIGINT,
					idfsRuleNew			BIGINT
				)

				DECLARE @RuleDetailResults TABLE (
					idfsRule				BIGINT,
					defaultRuleName			NVARCHAR(MAX),
					RuleName				NVARCHAR(MAX),
					idfsRuleMessage			BIGINT,
					defaultRuleMessage		NVARCHAR(MAX),
					RuleMessage				NVARCHAR(MAX),
					idfsCheckPoint			BIGINT,
					idfsRuleFunction		BIGINT,
					blnNot					BIT,
					idfsRuleAction			BIGINT,
					strActionParameters		NVARCHAR(MAX),
					idfsFunctionParameter	BIGINT,
					FillValue				NVARCHAR(MAX)
				)

				DECLARE @RuleConstants TABLE (
					idfRuleConstant		BIGINT,
					idfsRule			BIGINT,
					varConstant			SQL_VARIANT
				)

				DECLARE @Functions TABLE (
					idfParameterForFunction	BIGINT,
					idfsParameter			BIGINT,
					idfsFormTemplate		BIGINT,
					idfsRule				BIGINT,
					intOrder				INT,
					strCompareValue			NVARCHAR(MAX)
				)

				DECLARE @Actions TABLE (
					idfParameterForAction	BIGINT,
					idfsParameter			BIGINT,
					idfsFormTemplate		BIGINT,
					idfsRuleAction			BIGINT,
					idfsRule				BIGINT,
					strFillValue			NVARCHAR(MAX)
				)

				DECLARE @GlobalReference TABLE (
					idfs					BIGINT,
					idfsNew					BIGINT
				)

				DECLARE @Determinants TABLE (
					idfDeterminantValue		BIGINT,
					idfsBaseReference		BIGINT
				)

				----------------------------------------------------------------------------------------

				----------------------------------------------------------------------------------------
				--Make a copy of the base Template													  --
				----------------------------------------------------------------------------------------
				INSERT INTO @TemplateDetails
				EXEC USP_ADMIN_FF_Template_GetDetail @LangID = @LangId, @idfsFormTemplate = @idfsFormTemplate

				SELECT
					@idfsFormTemplate = idfsFormTemplate,
					@FormTemplate = FormTemplate,
					@DefaultName = DefaultName,
					@NationalName = NationalName,
					@idfsFormType = idfsFormType,
					@strNote = strNote,
					@blnUNI = COALESCE(blnUNI,0)
				FROM
					@TemplateDetails

				if @idfsNewFormType IS NOT NULL
					BEGIN
						--if NOT EXISTS(SELECT TOP 1 idfsFormTemplate FROM ffFormTemplate WHERE idfsFormType = @idfsNewFormType AND intRowStatus = 0)
						--	BEGIN
								SET @idfsFormType = @idfsNewFormType
								SET @blnUNI = 1
							--END
					END
				--Collect remaining details that are not supplied by the existing SP
				--SELECT
				--	@DefaultName = strDefault
				--FROM
				--	trtBaseReference 
				--WHERE
				--	idfsBaseReference = @idfsFormTemplate
				
				--Generate new idfsFormTemplate with existing names, having "Copy" appended to it
				SELECT
					@strResourceString = strResourceString
				FROM
					trtResourceTranslation
				WHERE 
					idfsResource = 744 and 
					idfsLanguage = @langid_int

				SET @DefaultName = CONCAT(@DefaultName,' (', @strResourceString , ')')
				SET @NationalName = CONCAT(@NationalName,' (', @strResourceString , ')')

				INSERT INTO @SupressSelect
				EXEC dbo.USSP_GBL_BaseReference_SET @idfsFormTemplateNew OUTPUT, 19000033/*'rftParameter'*/,@LangID, @DefaultName, @NationalName, 0

				--Create Global Reference for use by subsequential steps
				INSERT INTO @GlobalReference (idfs, idfsNew) VALUES (@idfsFormTemplate, @idfsFormTemplateNew)

				--Create the new Template
				INSERT INTO @SupressSelect
				EXEC USP_ADMIN_FF_Template_SET 
					@idfsFormType = @idfsFormType, 
					@DefaultName = @DefaultName,
					@NationalName = @NationalName, 
					@strNote = @strNote, 
					@LangId = @LangID, 
					@blnUNI = @blnUNI,
					@idfsFormTemplate = @idfsFormTemplateNew,
					@User = @User,
					@FunctionCall = 1,
					@CopyOnly = 1,
					@EventTypeId =10025120,
					@SiteId = @idfsSite,
					@UserId = @UserId,
					@LocationId = -1
					

				--Turn off UNI on old Template, since the newer on is the primary one now
				UPDATE
					ffFormTemplate
				SET
					blnUNI = 0
				WHERE
					idfsFormTemplate = @idfsFormTemplate

				--Disable existing Template
				--UPDATE
				--	ffFormTemplate
				--SET
				--	intRowStatus = 1
				--WHERE
				--	idfsFormTemplate = @idfsFormTemplate
				----------------------------------------------------------------------------------------

				----------------------------------------------------------------------------------------
				--Obtain a collection of Sections													  --
				----------------------------------------------------------------------------------------
				INSERT INTO @Sections (idfsSection)
				SELECT
					SFT.idfsSection
				FROM
					ffSectionForTemplate SFT
				INNER JOIN ffSection S
					ON S.idfsSection = SFT.idfsSection AND
						SFT.intRowStatus = 0
				WHERE
					SFT.idfsFormTemplate = @idfsFormTemplate AND
					S.intRowStatus = 0

				----------------------------------------------------------------------------------------

				----------------------------------------------------------------------------------------
				--Obtain a collection of Parameters and their associated Sections					  --
				----------------------------------------------------------------------------------------
				INSERT INTO @Parameters (idfsParameter, idfsSection)
				SELECT
					PFT.idfsParameter,
					P.idfsSection
				FROM
					ffParameterForTemplate PFT
				INNER JOIN ffParameter P
					ON P.idfsParameter = PFT.idfsParameter AND
						PFT.intRowStatus = 0
				WHERE
					PFT.idfsFormTemplate = @idfsFormTemplate AND
					P.intRowStatus = 0
				----------------------------------------------------------------------------------------

				----------------------------------------------------------------------------------------
				--Obtain a collection of Rules														  --
				----------------------------------------------------------------------------------------
				INSERT INTO @Rules (idfsRule)
				SELECT
					idfsRule
				FROM
					ffRule
				WHERE
					idfsFormTemplate = @idfsFormTemplate AND
					intRowStatus = 0
				----------------------------------------------------------------------------------------

				----------------------------------------------------------------------------------------
				--Obtain a collection of Rules														  --
				----------------------------------------------------------------------------------------
				--INSERT INTO @Rules (idfsRule)
				--SELECT
				--	idfsRule
				--FROM
				--	ffRule
				--WHERE
				--	idfsFormTemplate = @idfsFormTemplate
				----------------------------------------------------------------------------------------

				----------------------------------------------------------------------------------------
				--Obtain a collection of Rule Constants												  --
				----------------------------------------------------------------------------------------
				INSERT INTO @RuleConstants (idfRuleConstant, idfsRule, varConstant)
				SELECT
					RC.idfRuleConstant,
					RC.idfsRule,
					RC.varConstant
				FROM
					ffRuleConstant RC
				INNER JOIN ffRule R
					ON R.idfsRule = RC.idfsRule
				WHERE
					R.idfsFormTemplate = @idfsFormTemplate AND
					R.intRowStatus = 0
				----------------------------------------------------------------------------------------

				----------------------------------------------------------------------------------------
				--Obtain a collection of Template Determinants										  --
				--------------------------------------------------------------------------------------
				INSERT INTO @Determinants (idfDeterminantValue, idfsBaseReference)
				SELECT
					 DISTINCT
					idfDeterminantValue,
					idfsBaseReference
				FROM
					ffDeterminantValue
				WHERE
					idfsFormTemplate = @idfsFormTemplate and 
					intRowStatus = 0 and 
					idfsBaseReference is not null
				----------------------------------------------------------------------------------------

				----------------------------------------------------------------------------------------
				--Make a copy of each Section and its Template association							  --
				----------------------------------------------------------------------------------------
				WHILE EXISTS(SELECT TOP 1 idfsSection FROM @Sections WHERE idfsSectionNew IS NULL)
					BEGIN
						--Get another recored that hasn't been converted yet
						SELECT TOP 1 @idfsSection = idfsSection FROM @Sections WHERE idfsSectionNew IS NULL
						SELECT @intOrder = intOrder FROM ffSectionDesignOption WHERE idfsFormTemplate = @idfsFormTemplate AND idfsSection = @idfsSection
						
						--SELECT
						--	@idfsParentSection	= idfsParentSection,
						--	@idfsFormType		= idfsFormType,
						--	@intOrder			= S.intOrder,
						--	@blnGrid			= blnGrid,
						--	@blnFixedRowset		= blnFixedRowset,
						--	@idfsMatrixType		= idfsMatrixType,
						--	@DefaultName		= B.strDefault,
						--	@NationalName		= ISNULL(SNT.[strTextString], B.[strDefault]) 
						--FROM
						--	ffSection S
						--INNER JOIN dbo.trtBaseReference B
						--ON B.[idfsBaseReference] = S.[idfsSection]
						--   AND B.[intRowStatus] = 0  
						--LEFT JOIN dbo.trtStringNameTranslation SNT
						--ON SNT.[idfsBaseReference] = S.[idfsSection]
						--   AND SNT.idfsLanguage = @langid_int
						--   AND SNT.[intRowStatus] = 0
						--WHERE
						--	idfsSection = @idfsSection
							
						--Reset to grab a new id each iteration
						--SET @idfsSectionNew = NULL

						--Create another Section, based off of the details obtained from the previous step
						--INSERT INTO @SupressSelect
						--EXEC dbo.USSP_GBL_BaseReference_SET @idfsSectionNew OUTPUT,19000101,@LangID,@DefaultName,@NationalName,0

						--IF @idfsSectionNew IS NOT NULL 
						--	BEGIN
								--Create Global Reference for use by subsequential steps
								--INSERT INTO @GlobalReference (idfs, idfsNew) VALUES (@idfsSection, @idfsSectionNew)
								----INSERT INTO @SectionSetResults
								--INSERT INTO @SupressSelect
								--EXEC USP_ADMIN_FF_Sections_SET 
								--	@idfsSection		= @idfsSectionNew, 
								--	@idfsParentSection	= @idfsParentSection, 
								--	@idfsFormType		= @idfsFormType,
								--	@intOrder			= @intOrder,
								--	@blnGrid			= @blnGrid,
								--	@blnFixedRowset		= @blnFixedRowset,
								--	@idfsMatrixType		= @idfsMatrixType,
								--	@intRowStatus		= @intRowStatus,
								--	@User				= @User,
								--	@CopyOnly			= 1

								--Create entry for the association of this new Section against the new Template
								INSERT INTO @SupressSelect
								EXEC USP_ADMIN_FF_SectionTemplate_SET 
									@LangId = @LangID, 
									@idfsSection = @idfsSection, 
									@idfsFormTemplate = @idfsFormTemplateNew,
									@User = @User

								UPDATE
									ffSectionDesignOption
								SET
									intOrder = @intOrder
								WHERE
									idfsFormTemplate = @idfsFormTemplate AND
									idfsSection = @idfsSection

								--Update the temporary table, to mark it as converted
								UPDATE
									@Sections
								SET
									idfsSectionNew = @idfsSection
								WHERE
									idfsSection = @idfsSection

								UPDATE
									@Parameters
								SET
									idfsSectionNew = @idfsSection
								WHERE
									idfsSection = @idfsSection
									
								--Soft delete the old section, from the ffSection table
								--UPDATE 
								--	ffSection
								--SET
								--	intRowStatus = 1
								--WHERE
								--	idfsSection = @idfsSection
							--END
					END
				----------------------------------------------------------------------------------------

				----------------------------------------------------------------------------------------
				--Make a copy of each Parameter and its Template association						  --
				----------------------------------------------------------------------------------------
				WHILE EXISTS(SELECT TOP 1 idfsParameter FROM @Parameters WHERE idfsParameterNew IS NULL)
					BEGIN
						--Get another record that hasn't been converted yet
						SELECT TOP 1 @idfsParameter = idfsParameter FROM @Parameters WHERE idfsParameterNew IS NULL
						SELECT @intOrder = intOrder FROM ffParameterDesignOption WHERE idfsFormTemplate = @idfsFormTemplate AND idfsParameter = @idfsParameter
						SELECT @idfsEditMode = idfsEditMode FROM ffParameterForTemplate WHERE idfsFormTemplate = @idfsFormTemplate AND idfsParameter = @idfsParameter

						--Grab the details for the current parameter
						--SELECT
						--	@idfsSection			= P.idfsSection,
						--	@idfsParameterCaption	= P.idfsParameterCaption,
						--	@idfsParameterType		= P.idfsParameterType,
						--	@idfsFormType			= P.idfsFormType,
						--	@idfsEditor				= P.idfsEditor,
						--	@strNote				= P.strNote,
						--	@intOrder				= P.intOrder,
						--	@intHACode				= P.intHACode,
						--	@DefaultName			= ISNULL(B2.[strDefault], ''),
						--	@DefaultLongName		= ISNULL(B1.[strDefault], ''),
						--	@NationalName			= ISNULL(SNT2.[strTextString], B2.[strDefault]),
						--	@NationalLongName		= ISNULL(SNT1.[strTextString], B1.[strDefault])
						--FROM
						--	ffParameter P
						--INNER JOIN dbo.trtBaseReference B1
						--ON B1.[idfsBaseReference] = P.[idfsParameter]
						--	AND B1.[intRowStatus] = 0
						--LEFT JOIN dbo.trtBaseReference B2
						--ON B2.[idfsBaseReference] = P.[idfsParameterCaption]
						--	AND B2.[intRowStatus] = 0
						--LEFT JOIN dbo.trtStringNameTranslation SNT1
						--ON (SNT1.[idfsBaseReference] = P.[idfsParameter]
						--	AND SNT1.[idfsLanguage] = @langid_int)
						--	AND SNT1.[intRowStatus] = 0
						--LEFT JOIN dbo.trtStringNameTranslation SNT2
						--ON (SNT2.[idfsBaseReference] = P.[idfsParameterCaption]
						--	AND SNT2.[idfsLanguage] = @langid_int)
						--	AND SNT2.[intRowStatus] = 0
						--WHERE
						--	P.idfsParameter = @idfsParameter
							
						--Reset to grab a new id each iteration
						--SET @idfsParameterNew = NULL

						----Create another parameter, based off of the details obtained from the previous step
						--INSERT INTO @SupressSelect
						--EXEC dbo.USSP_GBL_BaseReference_SET @idfsParameterNew OUTPUT, 19000066/*'rftParameter'*/,@LangID, @DefaultLongName, @NationalLongName, 0

						--INSERT INTO @SupressSelect
						--EXEC dbo.USSP_GBL_BaseReference_SET @idfsParameterCaption OUTPUT, 19000070 /*'rftParameterToolTip'*/,@LangID, @DefaultName, @NationalName, 0

						----Create Global Reference for use by subsequential steps
						--INSERT INTO @GlobalReference (idfs, idfsNew) VALUES (@idfsParameter, @idfsParameterNew)

						--Obtain the id for the newly copied section
						--SELECT
						--	@idfsSectionNew = idfsSectionNew
						--FROM
						--	@Parameters
						--WHERE
						--	idfsParameter = @idfsParameter

						--Create the copy of the existing Parameter
						--INSERT INTO @Supress_USP_ADMIN_FF_Parameters_SET
						--EXEC USP_ADMIN_FF_Parameters_SET 
						--	@LangID					= @LangID,
						--	@idfsSection			= @idfsSectionNew, 
						--	@idfsFormType			= @idfsFormType,
						--	@idfsParameterType		= @idfsParameterType,
						--	@idfsEditor				= @idfsEditor,
						--	@intHACode				= @intHACode,
						--	@intOrder				= @intOrder,
						--	@strNote				= @strNote,
						--	@DefaultName			= @DefaultName,
						--	@NationalName			= @NationalName,
						--	@DefaultLongName		= @DefaultLongName,
						--	@NationalLongName		= @NationalLongName,
						--	@idfsParameter			= @idfsParameterNew,
						--	@idfsParameterCaption	= @idfsParameterCaption,
						--	@User					= @User,
						--	@intRowStatus			= 0,
						--	@CopyOnly				= 1

						--Create entry for the association of this new Section against the new Template
						--INSERT INTO @Supress_USP_ADMIN_FF_ParameterTemplate_SET
						EXEC USP_ADMIN_FF_ParameterTemplateForCopy_SET
							@LangID= @LangID,
							@idfsParameter = @idfsParameter, 
							@idfsFormTemplate = @idfsFormTemplateNew,
							@User = @User,
							@CopyOnly = 1,
							@FunctionCall = 1

						--Apply ordering settings
						UPDATE
							ffParameterDesignOption
						SET
							intOrder = @intOrder
						WHERE
							idfsFormTemplate = @idfsFormTemplateNew AND
							idfsParameter = @idfsParameter

						--Apply Edit Mode (Mandatory or Ordinary)
						UPDATE
							ffParameterForTemplate
						SET
							idfsEditMode = @idfsEditMode
						WHERE
							idfsFormTemplate = @idfsFormTemplateNew AND
							idfsParameter = @idfsParameter

						--Update the temporary table, to mark it as converted
						UPDATE
							@Parameters
						SET
							idfsParameterNew = @idfsParameter
						WHERE
							idfsParameter = @idfsParameter


						--Soft delete the old section, from the ffSection table
						--UPDATE 
						--	ffParameter
						--SET
						--	intRowStatus = 1
						--WHERE
						--	idfsParameter = @idfsParameter

					END
				----------------------------------------------------------------------------------------

				
				--Enumerate through all determinants that are related to the Template
				WHILE EXISTS (SELECT idfDeterminantValue FROM @Determinants)
					BEGIN
						--Grab the first items in the list
						SELECT
							TOP 1
							@idfDeterminantValue = idfDeterminantValue,
							@idfsBaseReference = idfsBaseReference
						FROM
							@Determinants

						INSERT INTO @SupressSelect
						EXEC dbo.USP_GBL_NEXTKEYID_GET 'ffDeterminantValue', @idfDeterminant OUTPUT;

						INSERT INTO dbo.ffDeterminantValue
						(
							  idfDeterminantValue,
							  idfsFormTemplate,
							  idfsBaseReference,
							  intRowStatus,
							  AuditCreateUser,
							  AuditCreateDTM,
							  SourceSystemNameID,
							  SourceSystemKeyValue
						)
						VALUES
						(@idfDeterminant,
						   @idfsFormTemplateNew,
						   @idfsBaseReference,
						   0,
						   @User,
						   GETDATE(),
						   10519001,
						   '[{"idfDeterminantValue":' + CAST(@idfDeterminant AS NVARCHAR(300)) + '}]'
						);

						--Disable
						UPDATE
							ffDeterminantValue
						SET
							intRowStatus = 1
						WHERE
							idfDeterminantValue = @idfDeterminantValue

						DELETE
						FROM
							@Determinants
						WHERE
							idfDeterminantValue = @idfDeterminantValue
					END

				----------------------------------------------------------------------------------------
				--Make a copy of each Rule															  --
				----------------------------------------------------------------------------------------
				WHILE EXISTS(SELECT TOP 1 idfsRule FROM @Rules WHERE idfsRuleNew IS NULL)
					BEGIN
						--Get another record that hasn't been converted yet
						SELECT
							TOP 1 @idfsRule = idfsRule
						FROM
							@Rules
						WHERE
							idfsRuleNew IS NULL

						--Reset @RuleDetailResults, so that it will only have one row at a time in it
						DELETE FROM @RuleDetailResults

						--Grab the details for the current Rule
						INSERT INTO @RuleDetailResults
						EXEC USP_ADMIN_FF_Rule_GetDetails @langid=@LangId, @idfsRule = @idfsRule

						SELECT
							@idfsRule = idfsRule,
							@DefaultRuleName = defaultRuleName,
							@NationalRuleName = RuleName,
							@DefaultRuleMessage = defaultRuleMessage,
							@NationalRuleMessage = RuleMessage,
							@idfsRuleMessage = idfsRuleMessage,
							@idfsCheckPoint = idfsCheckPoint,
							@idfsRuleFunction = idfsRuleFunction,
							@blnNot = blnNot,
							@idfsRuleAction = idfsRuleAction,
							@strActionParameters = strActionParameters,
							@idfsFunctionParameter = idfsFunctionParameter,
							@strFillValue = FillValue
						FROM
							@RuleDetailResults
						
						--Reset to grab a new id each iteration
						--SET @idfsRuleNew = -1

						--Create another Rule, based off of the details obtained from the previous step
						--INSERT INTO @SupressSelect
						EXEC dbo.USSP_GBL_BaseReference_SET @ReferenceID = @idfsRuleNew OUTPUT, @ReferenceType = 19000029, @LangId = @LangID, @DefaultName = @DefaultName, @NationalName = @NationalName, @System = 0

						INSERT INTO @SupressSelect
						EXEC dbo.USSP_GBL_BaseReference_SET @idfsRuleMessage OUTPUT, 19000032, @LangID, @MessageText, @MessageNationalText, 0
						
						--Create Global Reference for use by subsequential steps
						INSERT INTO @GlobalReference (idfs, idfsNew) VALUES (@idfsRule, @idfsRuleNew)

						--Reset the Action Parameters Table
						DELETE FROM @ActionParameters
						
						--Create table from string "Parameters" of the current rule details
						INSERT INTO @ActionParameters (idfsParameter)
						SELECT
							CAST(L.value AS BIGINT) AS idfsParameter
						FROM
							[dbo].[FN_GBL_SYS_SplitList](@strActionParameters, 0, ',') L

						--Get the conversion of the idfsParameter from its old value for the Function that the parameter is using.
						SELECT
							@idfsFunctionParameterNew = idfsNew
						FROM
							@GlobalReference
						WHERE
							idfs = @idfsFunctionParameter

						
						--Enumerate through all Action Parameters, that are associated with the rule
						WHILE EXISTS(SELECT idfsParameter FROM @ActionParameters)
							BEGIN
								SELECT 
									TOP 1 @idfsActionParameter = idfsParameter
								FROM
									@ActionParameters
									
								--Get the conversion of the idfsParameter from its old value for the Action that the parameter is using.
								SELECT
									@idfsActionParameterNew = idfsNew
								FROM
									@GlobalReference
								WHERE
									idfs = @idfsActionParameter

								--Create the copy of the existing Parameter
								--INSERT INTO @SupressSelect
								EXEC USP_ADMIN_FF_Rules_SET
									@idfsRule = @idfsRuleNew,
									@idfsFormTemplate = @idfsFormTemplateNew,
									@idfsCheckPoint = @idfsCheckPoint,
									@idfsRuleFunction = @idfsRuleFunction,
									@idfsRuleAction = @idfsRuleAction,
									@DefaultName = @DefaultName,
									@NationalName = @NationalName,
									@MessageText = @MessageText,
									@MessageNationalText = @MessageNationalText,
									@blnNot = @blnNot,
									@LangID = @LangID,
									@idfsRuleMessage = @idfsRuleMessage,
									@idfsFunctionParameter = @idfsFunctionParameterNew,
									@idfsActionParameter = @idfsActionParameterNew,
									@User = @User,
									@strFillValue = @strFillValue,
									@strCompareValue = @strCompareValue,
									@intRowStatus = 0,
									@FunctionCall = 1,
									@CopyOnly = 1

								DELETE FROM @ActionParameters WHERE idfsParameter = @idfsActionParameter
							END

						--Enumerate through all Constants, that are related to the Rule
						WHILE EXISTS(SELECT idfRuleConstant FROM @RuleConstants)
							BEGIN
								SELECT
									TOP 1
									@idfRuleConstant = idfRuleConstant,
									@idfsRule = idfsRule,
									@varConstant = varConstant
								FROM
									@RuleConstants

								--Get a new row id
								INSERT INTO @SupressSelect
								EXEC dbo.USP_GBL_NEXTKEYID_GET 'ffRuleConstant', @idfRuleConstantNew OUTPUT;

								--Get the newly created id for the old entry.
								SELECT
									@idfRuleConstantNew = idfsNew
								FROM
									@GlobalReference
								WHERE
									idfs = @idfRuleConstant

								--Get the newly created id for the old entry.
								SELECT
									@idfsRuleNew = idfsNew
								FROM
									@GlobalReference
								WHERE
									idfs = @idfsRuleNew

								--Create the new Record
								INSERT INTO ffRuleConstant (
									idfRuleConstant, 
									idfsRule, 
									varConstant, 
									intRowStatus,
									AuditCreateDTM,
									AuditCreateUser,
									SourceSystemNameID,
									SourceSystemKeyValue
								)
								VALUES (
									@idfRuleConstantNew,
									@idfsRuleNew,
									@varConstant,
									0,
									GETDATE(),
									@User,
									10519001,
									'[{"idfRuleConstant":13663030001100}]'
								)
								
								--Delete the top record so that continous looping doesn't occur to produce records over and over
								DELETE 
								FROM 
									@RuleConstants
								WHERE
									idfRuleConstant = @idfRuleConstant
							END
						
						--Update the temporary table, to mark it as converted
						UPDATE
							@Rules
						SET
							idfsRuleNew = @idfsRuleNew
						WHERE
							idfsRule = @idfsRule
						
						--Soft delete the old section, from the ffSection table
						UPDATE 
							ffRule
						SET
							intRowStatus = 1
						WHERE
							idfsRule= @idfsRule

					END
				----------------------------------------------------------------------------------------

				--USP_ADMIN_FF_Parameter_Copy
				--USP_ADMIN_FF_Section_Copy
				--SELECT * FROM @SectionsParameters
				--USP_ADMIN_FF_TemplateSectionOrder_Set
				--USP_ADMIN_FF_RequiredParameter_SET
				--USP_ADMIN_FF_ParameterDesignOptions_SET
				--USP_ADMIN_FF_Parameters_SET
				--USP_ADMIN_FF_ParameterFixedPresetValue_SET
				--USP_ADMIN_FF_ParameterTypes_SET
				--USP_ADMIN_FF_ParameterTemplate_SET
				--USP_ADMIN_FF_RuleConstant_SET
				--USP_ADMIN_FF_RuleParameterForAction_SET
				--USP_ADMIN_FF_RuleParameterForFunction_SET
				--USP_ADMIN_FF_Rules_SET
				--USP_ADMIN_FF_SectionDesignOptions_SET
				--USP_ADMIN_FF_Sections_SET
				--USP_ADMIN_FF_SectionTemplate_SET
				--USP_ADMIN_FF_SectionTemplateRecursive_SET ????????????????
				--USP_ADMIN_FF_Template_SET
				--USP_ADMIN_FF_TemplateDeterminantValues_SET
				--USP_ADMIN_FF_TemplateParameterOrder_Set
				--USP_ADMIN_FF_Determinant_SET

			--END
		
		--If any observations are made, then the following must be copied
		--select * from ffDeterminantValue where idfsFormTemplate = 9871670000000 

		IF @idfsFormTemplateNew IS NULL
			BEGIN
				SET @idfsFormTemplateNew = @idfsFormTemplate
			END

		SELECT	@returnCode as ReturnCode, @returnMsg as ReturnMessage, @idfsFormTemplateNew As idfsFormTemplate
	END TRY

	BEGIN CATCH

		SET @returnCode = ERROR_NUMBER();
		SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();;

		throw;
	END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_ADMIN_FF_Templates_GET]...';


GO
-- ================================================================================================
-- Name: USP_ADMIN_FF_Templates_GET
-- Description: Return list of Templates
--          
-- Revision History:
-- Name            Date			Change
-- --------------- ----------	--------------------------------------------------------------------
-- Kishore Kodru    11/28/2018	Initial release for new API.
-- Stephen Long     10/02/2019	Removed commit transaction.
-- Doug Albanese	09/21/2021	Added Disease Id for filtering by Outbreak/FFD connection
-- Doug Albanese	09/29/2021	Corrected the joins to return query by idfsFormType
-- Mark Wilson		09/30/2021	Updated to use FN_GBL_ReferenceRepair_GET
-- Doug Albanese	10/28/2021	Removed disease query
-- Doug Albanese	01/20/2023	Added the determinate value on return
-- Doug Albnaese	05/08/2023	Added ability to capture Outbreak assigned Templates, with an Outbreak ID
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_ADMIN_FF_Templates_GET]
(
	@LangID								NVARCHAR(50)
	,@idfsFormTemplate					BIGINT = NULL
	,@idfsFormType						BIGINT = NULL
	,@idfOUtbreak					    BIGINT = NULL
)	
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE @Outbreak	   BIT = 0

	BEGIN TRY
	  
	  IF @idfOUtbreak IS NULL or @idfOUtbreak = -1
		 BEGIN
			IF @idfsFormType BETWEEN 10034501 AND 10034503
			   BEGIN
				  SET @Outbreak = 1

				  SELECT
					 DISTINCT
					 FT.idfsFormTemplate,
					 FT.idfsFormType,
					 FT.blnUNI,
					 FT.rowguid,
					 FT.intRowStatus,
					 FT.strNote,
					 RF.strDefault AS DefaultName,
					 O.strOutbreakID AS NationalName,
					 RF.[LongName] AS NationalLongName,
					 NULL AS idfsDiagnosisOrDiagnosisGroup
				  FROM 
					 OutbreakSpeciesParameter OSP
				  INNER JOIN ffFormTemplate FT
					 ON FT.idfsFormTemplate = OSP.CaseQuestionaireTemplateID
				  INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000033) RF 
					 ON FT.idfsFormTemplate = RF.idfsReference
				  INNER JOIN tlbOUtbreak O
					 ON O.idfOutbreak = OSP.idfOutbreak
				  WHERE
					 FT.idfsFormType = @idfsFormType AND 
					 RF.strDefault IS NOT NULL
		 
			   END
  
			IF @idfsFormType BETWEEN 10034504 AND 10034506
			   BEGIN
				  SET @Outbreak = 1

				  SELECT
					 DISTINCT
					 FT.idfsFormTemplate,
					 FT.idfsFormType,
					 FT.blnUNI,
					 FT.rowguid,
					 FT.intRowStatus,
					 FT.strNote,
					 RF.strDefault AS DefaultName,
					 O.strOutbreakID AS NationalName,
					 RF.[LongName] AS NationalLongName,
					 NULL AS idfsDiagnosisOrDiagnosisGroup
				  FROM 
					 OutbreakSpeciesParameter OSP
				  INNER JOIN ffFormTemplate FT
					 ON FT.idfsFormTemplate = OSP.CaseMonitoringTemplateID
				  INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000033) RF 
					 ON FT.idfsFormTemplate = RF.idfsReference
				  INNER JOIN tlbOUtbreak O
					 ON O.idfOutbreak = OSP.idfOutbreak
				  WHERE
					 FT.idfsFormType = @idfsFormType AND 
					 RF.strDefault IS NOT NULL
			   END

			IF @idfsFormType BETWEEN 10034507 AND 10034509
			   BEGIN
				  SET @Outbreak = 1

				  SELECT
					 DISTINCT
					 FT.idfsFormTemplate,
					 FT.idfsFormType,
					 FT.blnUNI,
					 FT.rowguid,
					 FT.intRowStatus,
					 FT.strNote,
					 RF.strDefault AS DefaultName,
					 O.strOutbreakID AS NationalName,
					 RF.[LongName] AS NationalLongName,
					 NULL AS idfsDiagnosisOrDiagnosisGroup
				  FROM 
					 OutbreakSpeciesParameter OSP
				  INNER JOIN ffFormTemplate FT
					 ON FT.idfsFormTemplate = OSP.ContactTracingTemplateID
				  INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000033) RF 
					 ON FT.idfsFormTemplate = RF.idfsReference
				  INNER JOIN tlbOUtbreak O
					 ON O.idfOutbreak = OSP.idfOutbreak
				  WHERE
					 FT.idfsFormType = @idfsFormType AND 
					 RF.strDefault IS NOT NULL
			   END

			   IF @Outbreak = 0
				  BEGIN
					 SELECT
						DISTINCT
						FT.idfsFormTemplate,
						FT.idfsFormType,
						FT.blnUNI,
						FT.rowguid,
						FT.intRowStatus,
						FT.strNote,
						RF.strDefault AS DefaultName,
						RF.[name] AS NationalName,
						RF.[LongName] AS NationalLongName,
						NULL AS idfsDiagnosisOrDiagnosisGroup
		
					FROM [dbo].[ffFormTemplate] FT
					INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000033) RF ON FT.idfsFormTemplate = RF.idfsReference
					WHERE ((FT.idfsFormTemplate = @idfsFormTemplate ) OR (@idfsFormTemplate IS NULL))
					AND ((FT.idfsFormType  = @idfsFormType) OR (@idfsFormType  IS NULL))	  
					AND (FT.intRowStatus = 0)
					ORDER BY NationalName;
				  END
			   
		 END
	  ELSE
		 BEGIN
			  SELECT 
				  DISTINCT
				  FT.idfsFormTemplate,
				  FT.idfsFormType,
				  FT.blnUNI,
				  FT.rowguid,
				  FT.intRowStatus,
				  FT.strNote,
				  RF.strDefault AS DefaultName,
				  RF.[name] AS NationalName,
				  RF.[LongName] AS NationalLongName,
				  DV.idfsBaseReference AS idfsDiagnosisOrDiagnosisGroup
		
			  FROM [dbo].[ffFormTemplate] FT
			  LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000033) RF ON FT.idfsFormTemplate = RF.idfsReference
			  LEFT JOIN dbo.ffDeterminantValue DV ON DV.idfsFormTemplate = FT.idfsFormTemplate
			  WHERE ((FT.idfsFormTemplate = @idfsFormTemplate ) OR (@idfsFormTemplate IS NULL))
			  AND ((FT.idfsFormType  = @idfsFormType) OR (@idfsFormType  IS NULL))	  
			  AND (FT.intRowStatus = 0)
			  ORDER BY NationalName;
		 END

	END TRY 
	BEGIN CATCH
		THROW;
	END CATCH;
END
GO
PRINT N'Altering Procedure [dbo].[USP_ADMIN_ORG_GETList]...';


GO
-- ================================================================================================
-- Name:USP_ADMIN_ORG_GETList
--
-- Description: Returns a list of organizations.
--          
-- Author: Mandar Kulkarni
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		06/09/2019 Created a temp table to store string query for POCO
-- Ricky Moss		06/14/2019 Added Organization Type ID
-- Ricky Moss		09/13/2019 Added AuditCreateDTM field for descending order
-- Ricky Moss		11/14/2019 Added paging paging parameters
-- Doug Albanese	11/19/2019 Corrected the HACode usage
-- Lamont Mitchell	04/13/2020 ADDED NULL Check for pagesize,maxpageperfetch and paginationset
-- Ricky Moss	    05/12/2020 Added Translated Values of name and full name
-- Mark Wilson		06/05/2020 used INTERSECT function to compare @intHACode with intHACode of org
-- Ricky Moss		06/15/2020 Used intOrder and strDefaut as original search fields
-- Doug Albanese	12/22/2020 Added idfsCountry for searching.	
-- Doug Albanese	02/01/2021 Corrected the use of NULL, in the where clause
-- Doug Albanese	02/08/2021 Changed the WHERE clause to detect filter searches properly.
-- Stephen Long     04/21/2021 Changed for updated pagination and location hierarchy.
-- Stephen Long     06/07/2021 Fixed address string to include additional fields for postal code, 
--                             street, building, apartment and house.
-- Stephen Long     06/24/2021 Added is null check on create address string.
-- Stephen Long     06/30/2021 Fix to order by column name on abbreviated and full names.
-- Stephen Long     08/03/2021 Added default sort order by order then organization full name; 
--                             national or default.
-- Leo Tracchia		08/17/2021 Changed intHACode to pull from tlbOffice	
-- Stephen Long     10/15/2021 Fix on total pages calculation.
-- Stephen Long     12/06/2021 Changed over to location hierarchy flattened for admin levels.
-- Stephen Long     03/14/2022 Changed over to pull from institution repair function to match 
--                             organization lookup procedure.
-- Stephen Long     05/05/2023 Correction to use proper joins on abbreviated and full names.
--
-- Testing Code:
-- EXEC USP_ADMIN_ORG_GETList 'en', null, null, null, null, 2, null, null, null, 1, 10
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_ADMIN_ORG_GETList]
(
    @LanguageID NVARCHAR(50),
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(30) = 'Order',
    @SortOrder NVARCHAR(4) = 'ASC',
    @OrganizationKey BIGINT = NULL,
    @OrganizationID NVARCHAR(100) = NULL,
    @AbbreviatedName NVARCHAR(100) = NULL,
    @FullName NVARCHAR(100) = NULL,
    @AccessoryCode INT = NULL,
    @SiteID BIGINT = NULL,
    @AdministrativeLevelID BIGINT = NULL,
    @OrganizationTypeID BIGINT = NULL,
    @ShowForeignOrganizationsIndicator BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @AdministrativeLevelNode AS HIERARCHYID,
                @firstRec INT,
                @lastRec INT,
                @TotalRowCount INT = (
                                         SELECT COUNT(*) FROM dbo.tlbOffice WHERE intRowStatus = 0
                                     );

        SET @firstRec = (@PageNumber - 1) * @PageSize;
        SET @lastRec = (@PageNumber * @PageSize + 1);

        IF @AdministrativeLevelID IS NOT NULL
        BEGIN
            SELECT @AdministrativeLevelNode = node
            FROM dbo.gisLocation
            WHERE idfsLocation = @AdministrativeLevelID;
        END;

        SELECT OrganizationKey,
               OrganizationID,
               AbbreviatedName,
               FullName,
               [Order],
               AddressString,
               OrganizationTypeName,
               AccessoryCode,
               SiteID,
               RowStatus,
               [RowCount],
               TotalRowCount,
               CurrentPage,
               TotalPages
        FROM
        (
            SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @SortColumn = 'AbbreviatedName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       ISNULL(abbreviatedName.name, abbreviatedName.strDefault)
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AbbreviatedName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       ISNULL(abbreviatedName.name, abbreviatedName.strDefault)
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'FullName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       ISNULL(fullName.name, fullName.strDefault)
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'FullName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       ISNULL(fullName.name, fullName.strDefault)
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'OrganizationID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       o.strOrganizationID
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'OrganizationID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       o.strOrganizationID
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AddressString'
                                                        AND @SortOrder = 'ASC' THEN
                                                       dbo.FN_GBL_CreateAddressString(
                                                                                         ISNULL(LH.AdminLevel1Name, ''),
                                                                                         ISNULL(LH.AdminLevel2Name, ''),
                                                                                         ISNULL(LH.AdminLevel3Name, ''),
                                                                                         ISNULL(gls.strPostCode, ''),
                                                                                         '',
                                                                                         '',
                                                                                         ISNULL(gls.strStreetName, ''),
                                                                                         ISNULL(gls.strHouse, ''),
                                                                                         ISNULL(gls.strBuilding, ''),
                                                                                         ISNULL(gls.strApartment, ''),
                                                                                         gls.blnForeignAddress,
                                                                                         ISNULL(
                                                                                                   gls.strForeignAddress,
                                                                                                   ''
                                                                                               )
                                                                                     )
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AddressString'
                                                        AND @SortOrder = 'DESC' THEN
                                                       dbo.FN_GBL_CreateAddressString(
                                                                                         ISNULL(LH.AdminLevel1Name, ''),
                                                                                         ISNULL(LH.AdminLevel2Name, ''),
                                                                                         ISNULL(LH.AdminLevel3Name, ''),
                                                                                         ISNULL(gls.strPostCode, ''),
                                                                                         '',
                                                                                         '',
                                                                                         ISNULL(gls.strStreetName, ''),
                                                                                         ISNULL(gls.strHouse, ''),
                                                                                         ISNULL(gls.strBuilding, ''),
                                                                                         ISNULL(gls.strApartment, ''),
                                                                                         gls.blnForeignAddress,
                                                                                         ISNULL(
                                                                                                   gls.strForeignAddress,
                                                                                                   ''
                                                                                               )
                                                                                     )
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'OrganizationTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       organizationType.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'OrganizationTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       organizationType.name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'Order'
                                                        AND @SortOrder = 'ASC' THEN
                                                       abbreviatedName.intOrder
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'Order'
                                                        AND @SortOrder = 'DESC' THEN
                                                       abbreviatedName.intOrder
                                               END DESC,
                                               IIF(@SortColumn = 'Order',
                                                   ISNULL(abbreviatedName.name, abbreviatedName.strDefault),
                                                   NULL) ASC
                                     ) AS RowNum,
                   o.idfOffice AS OrganizationKey,
                   o.strOrganizationID AS OrganizationID,
                   abbreviatedName.name AS AbbreviatedName,
                   fullName.name AS FullName,
                   abbreviatedName.intOrder AS [Order],
                   dbo.FN_GBL_CreateAddressString(
                                                     ISNULL(lh.AdminLevel1Name, ''),
                                                     ISNULL(lh.AdminLevel2Name, ''),
                                                     ISNULL(lh.AdminLevel3Name, ''),
                                                     ISNULL(gls.strPostCode, ''),
                                                     '',
                                                     '',
                                                     ISNULL(gls.strStreetName, ''),
                                                     ISNULL(gls.strHouse, ''),
                                                     ISNULL(gls.strBuilding, ''),
                                                     ISNULL(gls.strApartment, ''),
                                                     gls.blnForeignAddress,
                                                     ISNULL(gls.strForeignAddress, '')
                                                 ) AS AddressString,
                   organizationType.name AS OrganizationTypeName,
                   o.intHACode AS AccessoryCode,
                   o.idfsSite AS SiteID,
                   o.intRowStatus AS RowStatus,
                   COUNT(*) OVER () AS [RowCount],
                   @TotalRowCount AS TotalRowCount,
                   CurrentPage = @PageNumber,
                   TotalPages = (@TotalRowCount / @PageSize) + IIF(COUNT(*) % @PageSize > 0, 1, 0)
            FROM dbo.tlbOffice o
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000046) fullName
                    ON fullName.idfsReference = o.idfsOfficeName
                       AND fullName.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000045) abbreviatedName
                    ON abbreviatedName.idfsReference = o.idfsOfficeAbbreviation
                       AND abbreviatedName.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocationShared gls
                    ON o.idfLocation = gls.idfGeoLocationShared
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = gls.idfsLocation
                LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                    ON lh.idfsLocation = g.idfsLocation
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000504) organizationType
                    ON o.OrganizationTypeID = organizationType.idfsReference
            WHERE o.intRowStatus = 0
                  AND (
                          o.idfOffice = @OrganizationKey
                          OR @OrganizationKey IS NULL
                      )
                  AND (
                          o.strOrganizationID LIKE '%' + @OrganizationID + '%'
                          OR @OrganizationID IS NULL
                      )
                  AND (
                          (
                              abbreviatedName.strDefault LIKE '%' + @AbbreviatedName + '%'
                              OR abbreviatedName.name LIKE '%' + @AbbreviatedName + '%'
                          )
                          OR @AbbreviatedName IS NULL
                      )
                  AND (
                          (
                              fullName.strDefault LIKE '%' + @FullName + '%'
                              OR fullName.name LIKE '%' + @FullName + '%'
                          )
                          OR @FullName IS NULL
                      )
                  AND (
                          g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND EXISTS
            (
                SELECT *
                FROM [dbo].[FN_GBL_SplitHACode](@AccessoryCode, 510)
                INTERSECT
                SELECT *
                FROM [dbo].[FN_GBL_SplitHACode](ISNULL(o.intHACode, 1), 510)
            )
                  AND (
                          o.idfsSite = @SiteID
                          OR @SiteID IS NULL
                      )
                  AND (
                          organizationType.idfsReference = @OrganizationTypeID
                          OR @OrganizationTypeID IS NULL
                      )
                  AND gls.blnForeignAddress = @ShowForeignOrganizationsIndicator
            GROUP BY o.idfOffice,
                     o.idfsSite,
                     o.intRowStatus,
                     abbreviatedName.intOrder,
                     o.intHACode,
                     abbreviatedName.strDefault,
                     fullName.strDefault,
                     abbreviatedName.name,
                     fullName.name,
                     o.strOrganizationID,
                     organizationType.name,
                     LH.AdminLevel1Name,
                     LH.AdminLevel2Name,
                     LH.AdminLevel3Name,
                     gls.strApartment,
                     gls.blnForeignAddress,
                     gls.strForeignAddress,
                     gls.strBuilding,
                     gls.strHouse,
                     gls.strStreetName,
                     gls.strPostCode
        ) AS x
        WHERE RowNum > @firstRec
              AND RowNum < @lastRec
        ORDER BY RowNum;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
GO
PRINT N'Altering Procedure [dbo].[USP_DAS_USERS_GETList]...';


GO
-- ================================================================================================
-- Name: USP_DAS_USERS_GETList
--
-- Description: Returns a list of users in the system based on langauge and site list.
--
-- Author: Ricky Moss
-- 
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		11/16/2018 Initial Release
-- Ricky Moss		12/11/2018 Added idfsInstitution and idfsPosition fields and removed 
--                             identifier fields
-- Ricky Moss		05/06/2018 Added pagination set.
-- Stephen Long     01/26/2020 Added site list parameter for site filtration, and corrected table
--                             query was selecting from (tlbPerson to tstUserTable).
-- Leo Tracchia		03/02/2022  Added pagination logic for radzen components
-- Stephen Long     05/05/2023 Replaced institution with institution min.
--
-- Testing Code:
-- exec USP_DAS_USERS_GETList 'en', 1, 10, 10
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_DAS_USERS_GETList] (
	@LanguageID NVARCHAR(50),
	@SiteList VARCHAR(MAX) = NULL,
	@pageNo INT = 1,
	@pageSize INT = 10 ,
	@sortColumn NVARCHAR(30) = 'FamilyName',
	@sortOrder NVARCHAR(4) = 'asc'  
	)
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
	--	@ReturnCode BIGINT = 0;

	DECLARE @firstRec INT
    DECLARE @lastRec INT

	DECLARE @tempUsers TABLE( 
		EmployeeID BIGINT PRIMARY KEY NOT NULL,
		FirstName nvarchar(2000),
		FamilyName nvarchar(2000),
		SecondName nvarchar(2000),
		InstitutionID bigint,
		OrganizationName nvarchar(2000), 
		OrganizationFullName nvarchar(2000), 
		PositionID bigint,
		Position nvarchar(2000),
		DepartmentID bigint,
		DepartmentName nvarchar(2000)
	)

     SET @firstRec = (@pageNo-1)* @pagesize
     SET @lastRec = (@pageNo*@pageSize+1)

	BEGIN TRY
		INSERT INTO @tempUsers
		SELECT p.idfPerson AS 'EmployeeID',
			p.strFirstName as 'FirstName',
			p.strFamilyName as 'FamilyName',
			p.strSecondName as 'SecondName',
			p.idfInstitution as 'InstitutionID',
			organization.AbbreviatedName AS 'OrganizationName',
			organization.EnglishFullName AS 'OrganizationFullName',
			position.idfsReference AS 'PositionID',
			position.[name] AS 'Position',
			p.idfDepartment as 'DepartmentID',
			dept.[name] as 'DepartmentName'
		FROM dbo.tstUserTable u
		INNER JOIN dbo.tlbPerson p
			ON p.idfPerson = u.idfPerson
				AND p.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000073) position
			ON p.idfsStaffPosition = position.idfsReference
		LEFT JOIN dbo.tlbDepartment td ON p.idfDepartment = td.idfDepartment AND td.intRowStatus =0
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000164) dept
			ON td.idfsDepartmentName = dept.idfsReference	
		LEFT JOIN dbo.FN_GBL_Institution_Min(@LanguageID) organization
			ON organization.idfOffice = p.idfInstitution
		WHERE u.intRowStatus = 0
			AND (
				(
					u.idfsSite IN (
						SELECT CAST([Value] AS BIGINT)
						FROM dbo.FN_GBL_SYS_SplitList(@SiteList, NULL, ',')
						)
					)
				OR (@SiteList IS NULL)
				);

		WITH CTEResults as
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'EmployeeID' AND @SortOrder = 'asc' THEN EmployeeID END ASC,
				CASE WHEN @sortColumn = 'EmployeeID' AND @SortOrder = 'desc' THEN EmployeeID END DESC,

				CASE WHEN @sortColumn = 'FirstName' AND @SortOrder = 'asc' THEN FirstName END ASC,
				CASE WHEN @sortColumn = 'FirstName' AND @SortOrder = 'desc' THEN FirstName END DESC,

				CASE WHEN @sortColumn = 'FamilyName' AND @SortOrder = 'asc' THEN FamilyName END ASC,
				CASE WHEN @sortColumn = 'FamilyName' AND @SortOrder = 'desc' THEN FamilyName END DESC,

				CASE WHEN @sortColumn = 'SecondName' AND @SortOrder = 'asc' THEN SecondName END ASC,
				CASE WHEN @sortColumn = 'SecondName' AND @SortOrder = 'desc' THEN SecondName END DESC,

				CASE WHEN @sortColumn = 'InstitutionID' AND @SortOrder = 'asc' THEN InstitutionID END ASC,
				CASE WHEN @sortColumn = 'InstitutionID' AND @SortOrder = 'desc' THEN InstitutionID END DESC,

				CASE WHEN @sortColumn = 'OrganizationName' AND @SortOrder = 'asc' THEN OrganizationName END ASC,
				CASE WHEN @sortColumn = 'OrganizationName' AND @SortOrder = 'desc' THEN OrganizationName END DESC,

				CASE WHEN @sortColumn = 'OrganizationFullName' AND @SortOrder = 'asc' THEN OrganizationFullName END ASC,
				CASE WHEN @sortColumn = 'OrganizationFullName' AND @SortOrder = 'desc' THEN OrganizationFullName END DESC,

				CASE WHEN @sortColumn = 'PositionID' AND @SortOrder = 'asc' THEN PositionID END ASC,
				CASE WHEN @sortColumn = 'PositionID' AND @SortOrder = 'asc' THEN PositionID END ASC,

				CASE WHEN @sortColumn = 'Position' AND @SortOrder = 'desc' THEN Position END DESC,
				CASE WHEN @sortColumn = 'Position' AND @SortOrder = 'asc' THEN Position END ASC,

				CASE WHEN @sortColumn = 'DepartmentID' AND @SortOrder = 'desc' THEN DepartmentID END DESC,
				CASE WHEN @sortColumn = 'DepartmentID' AND @SortOrder = 'asc' THEN DepartmentID END ASC,

				CASE WHEN @sortColumn = 'DepartmentName' AND @SortOrder = 'desc' THEN DepartmentName END DESC,
				CASE WHEN @sortColumn = 'DepartmentName' AND @SortOrder = 'asc' THEN DepartmentName END ASC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount,
				EmployeeID,
				FirstName,
				FamilyName,
				SecondName,
				InstitutionID,
				OrganizationName,
				OrganizationFullName,
				PositionID,
				Position,
				DepartmentID,
				DepartmentName
			FROM @tempUsers
		)	
			SELECT
				TotalRowCount,
				EmployeeID,
				FirstName,
				FamilyName,
				SecondName,
				InstitutionID,
				OrganizationName,
				OrganizationFullName,
				PositionID,
				Position,
				DepartmentID,
				DepartmentName
				,TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0)
				,CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
GO
PRINT N'Altering Procedure [dbo].[USP_GBL_LKUP_ORG_GETList]...';


GO
--*************************************************************************************************
-- Name 				: USP_GBL_LKUP_ORG_GETList
-- Description			: Returns list of organizations with our without sites.
--          
-- Author               : Mandar Kulkarni
-- Revision History:
-- Name              Date       Change Detail
-- ----------------- ---------- ------------------------------------------------------------------
-- Minal             09/21/2021 Added introwstatus=0 for tstsite
-- Stephen Long      09/24/2021 Added accessory code and organization type parameters. Added group 
--                              by to remove duplicate organizations from returning.
-- Stephen Long      10/29/2021 Corrected site join to use idfOffice orgead of the organization's 
--                              site ID as the site set no longer stores site ID in tlbOffice.
-- Stephen Long      11/02/2021 Changed site ID to use the site's ID orgead of the one on 
--                              tlbOffice. 
-- Minal Shah        11/05/2021	Changed a join for idfssite
-- Mark Wilson       11/09/2021	Changed to check tstSite for idfsSite values
-- Mark Wilson       02/01/2022	Changed to use INTERSECT
-- Mark Wilson       03/15/2022	updated to account for null intHACode
-- Stephen Long      05/16/2022 Added row status parameter and where criteria; defaulted to null.
-- Mike Kornegay	 06/15/2022 Added idfsLocation as return field and parameter for filtering by location.
-- Stephen Long      05/05/2023 Corrected the joins for the abbreviated and full organization names.
--
-- Testing code:
/*
--Example of a call of procedure:

EXEC USP_GBL_LKUP_ORG_GETList 'en-US', 0, NULL, NULL, NULL --Orgs associated with a Site
EXEC USP_GBL_LKUP_ORG_GETList 'en-US', 1, NULL, NULL, NULL --Orgs without a site
EXEC USP_GBL_LKUP_ORG_GETList 'en-US', 2, NULL, NULL, NULL --All orgs irrespective of site
EXEC USP_GBL_LKUP_ORG_GETList 'en-US', 2, 64, NULL, NULL -- All orgs with HACode = 64 irrespective of site 
EXEC USP_GBL_LKUP_ORG_GETList 'en-US', 2, 96, NULL, NULL, NULL, 155575840002421 --All orgs with a specific location
*/
--*************************************************************************************************
ALTER PROCEDURE [dbo].[USP_GBL_LKUP_ORG_GETList]
(
    @LangID NVARCHAR(50),
    @SiteFlag INT = 0,
    @AccessoryCode INT = NULL,
    @OrganizationTypeID BIGINT = NULL,
    @AdvancedSearch NVARCHAR(200),
    @RowStatus INT = NULL,
	@LocationID BIGINT = NULL
)
AS
BEGIN
    DECLARE @returnMsg VARCHAR(MAX) = 'Success',
            @returnCode INT = 0;

    BEGIN TRY
        SELECT org.idfOffice,
               org.idfsOfficeName,
               fullName.strDefault AS EnglishFullName,
               org.idfsOfficeAbbreviation,
               abbreviatedName.strDefault AS EnglishName,
               fullName.strDefault AS FullName,
               abbreviatedName.name AS name,
               org.intHACode,
               S.idfsSite,
               S.strSiteName,
			   org.idfLocation
		FROM dbo.tlbOffice org
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000046) fullName ON fullName.idfsReference = org.idfsOfficeName
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000045) abbreviatedName ON abbreviatedName.idfsReference = org.idfsOfficeAbbreviation
			LEFT JOIN dbo.tlbGeoLocationShared gls
                    ON org.idfLocation = gls.idfGeoLocationShared
            LEFT JOIN dbo.tstSite S
                ON S.idfOffice = org.idfOffice
                   AND S.intRowStatus = 0
        WHERE (org.intRowStatus = @RowStatus OR @RowStatus IS NULL)
			  AND (org.idfLocation = @LocationID OR @LocationID IS NULL)
              AND (
                  (
                      @SiteFlag = 0
                      AND S.idfsSite IS NOT NULL
                  )
                  OR (
                         @SiteFlag = 1
                         AND S.idfsSite IS NULL
                     )
                  OR (@SiteFlag = 2)
              )
        AND (EXISTS
        (
            SELECT *
            FROM dbo.FN_GBL_SplitHACode(@AccessoryCode, 510)
            INTERSECT
            SELECT *
            FROM dbo.FN_GBL_SplitHACode(ISNULL(org.intHACode, 1), 510)
        
		) OR @AccessoryCode IS NULL)
              AND (
                      org.OrganizationTypeID = @OrganizationTypeID
                      OR @OrganizationTypeID IS NULL
                  )
              AND (
                      @AdvancedSearch IS NOT NULL
                      AND (
                              abbreviatedName.name LIKE '%' + @AdvancedSearch + '%'
                              --OR fullName.name LIKE '%' + @AdvancedSearch + '%'
                              OR abbreviatedName.strDefault LIKE '%' + @AdvancedSearch + '%'
                              --OR fullName.strDefault LIKE '%' + @AdvancedSearch + '%'
                          ) -- Apply filter if advanced search string is passed.
                      OR @AdvancedSearch IS NULL
                  ) -- Apply no filter if advanced search string is NULL		
        ORDER BY abbreviatedName.name;
    END TRY
    BEGIN CATCH
        SET @returnCode = ERROR_NUMBER()
        SET @returnMsg
            = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: '
              + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE())
              + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: '
              + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE()
    END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_GBL_LKUP_PERSON_GETList]...';


GO
-- ************************************************************************************************
-- Name: USP_GBL_LKUP_PERSON_GETList
--
-- Description: Selects data for person lookup tables
--          
-- Author: Mandar Kulkarni
--
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Stephen Long    01/10/2022 Added advanced search parameter.
-- Stephen Long    05/05/2023 Changed from institution repair to institution min.
--
-- Testing code:
/*
exec  USP_GBL_LKUP_PERSON_GETList 'en-US', NULL, NULL, 1, NULL, NULL
*/
-- ************************************************************************************************
ALTER PROCEDURE [dbo].[USP_GBL_LKUP_PERSON_GETList]
(
    @LangID NVARCHAR(50),    --##PARAM @LangID - language ID
    @OfficeID BIGINT = NULL, --##PARAM @OfficeID - person office, if not NULL only persons related with this office are selected
    @ID BIGINT = NULL,       --##PARAM @ID - person ID, if NOT NULL only person with this ID IS selected.
    @ShowUsersOnly BIT = NULL,
    @intHACode INT = NULL,
    @AdvancedSearch NVARCHAR(200) = NULL
)
AS
BEGIN
    BEGIN TRY
        IF @ShowUsersOnly = 1
        BEGIN
            SELECT p.idfPerson,
                   ISNULL(p.strFamilyName, N'') + ISNULL(' ' + p.strFirstName, '') + ISNULL(' ' + p.strSecondName, '') AS FullName,
                   p.strFamilyName,
                   p.strFirstName,
                   organization.AbbreviatedName AS Organization,
                   organization.idfOffice,
                   position.name AS Position,
                   e.intRowStatus,
                   organization.intHACode,
                   CAST(CASE
                            WHEN (organization.intHACode & 2) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnHuman,
                   CAST(CASE
                            WHEN (organization.intHACode & 96) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnVet,
                   CAST(CASE
                            WHEN (organization.intHACode & 32) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnLivestock,
                   CAST(CASE
                            WHEN (organization.intHACode & 64) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnAvian,
                   CAST(CASE
                            WHEN (organization.intHACode & 128) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnVector,
                   CAST(CASE
                            WHEN (organization.intHACode & 256) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnSyndromic
            FROM dbo.tlbPerson p
                INNER JOIN dbo.tlbEmployee e
                    ON p.idfPerson = e.idfEmployee
                LEFT OUTER JOIN dbo.FN_GBL_Institution_Min(@LangID) organization
                    ON p.idfInstitution = organization.idfOffice
                LEFT OUTER JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000073) position
                    ON p.idfsStaffPosition = position.idfsReference
            WHERE idfOffice = ISNULL(NULLIF(@OfficeID, 0), idfOffice)
                  AND (
                          @ID IS NULL
                          OR @ID = p.idfPerson
                      )
                  AND (
                          @intHACode = 0
                          OR @intHACode IS NULL
                          OR (organization.intHACode & @intHACode) > 0
                      )
                  --intRowStatus IS not used here because we want to show in lookups all users including deleted ones
                  AND (
                          @AdvancedSearch IS NOT NULL
                          AND (
                                  p.strFamilyName LIKE '%' + @AdvancedSearch + '%'
                                  OR p.strFirstName LIKE '%' + @AdvancedSearch + '%'
                              )
                          OR @AdvancedSearch IS NULL
                      )
                  AND EXISTS
            (
                SELECT *
                FROM dbo.tstUserTable
                WHERE dbo.tstUserTable.idfPerson = p.idfPerson
                      and dbo.tstUserTable.intRowStatus = 0
            )   --Show only employees that have/had logins
                  AND p.intRowStatus = 0
                  and e.intRowStatus = 0
            ORDER BY FullName,
                     organization.AbbreviatedName,
                     position.name;
        END
        ELSE
        BEGIN
            SELECT p.idfPerson,
                   ISNULL(p.strFamilyName, N'') + ISNULL(' ' + p.strFirstName, '') + ISNULL(' ' + p.strSecondName, '') AS FullName,
                   p.strFamilyName,
                   p.strFirstName,
                   organization.AbbreviatedName AS Organization,
                   organization.idfOffice,
                   position.name AS Position,
                   e.intRowStatus,
                   organization.intHACode,
                   CAST(CASE
                            WHEN (organization.intHACode & 2) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnHuman,
                   CAST(CASE
                            WHEN (organization.intHACode & 96) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnVet,
                   CAST(CASE
                            WHEN (organization.intHACode & 32) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnLivestock,
                   CAST(CASE
                            WHEN (organization.intHACode & 64) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnAvian,
                   CAST(CASE
                            WHEN (organization.intHACode & 128) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnVector,
                   CAST(CASE
                            WHEN (organization.intHACode & 256) > 0 THEN
                                1
                            ELSE
                                0
                        END AS BIT) AS blnSyndromic
            FROM dbo.tlbPerson p
                INNER JOIN dbo.tlbEmployee e
                    ON p.idfPerson = e.idfEmployee
                LEFT OUTER JOIN dbo.FN_GBL_Institution_Min(@LangID) organization
                    ON p.idfInstitution = organization.idfOffice
                LEFT OUTER JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000073) position
                    ON p.idfsStaffPosition = position.idfsReference
            WHERE idfOffice = ISNULL(NULLIF(@OfficeID, 0), idfOffice)
                  AND (
                          @ID IS NULL
                          OR @ID = idfPerson
                      )
                  AND (
                          @intHACode = 0
                          OR @intHACode IS NULL
                          OR (organization.intHACode & @intHACode) > 0
                      )
                  AND (
                          @AdvancedSearch IS NOT NULL
                          AND (
                                  p.strFamilyName LIKE '%' + @AdvancedSearch + '%'
                                  OR p.strFirstName LIKE '%' + @AdvancedSearch + '%'
                              )
                          OR @AdvancedSearch IS NULL
                      )
                  AND p.intRowStatus = 0
                  and e.intRowStatus = 0
            ORDER BY FullName,
                     organization.intOrder,
                     organization.AbbreviatedName,
                     position.name;
        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_REP_LAB_AssignmentDiagnosticAZSendTo_GETList]...';


GO
--*************************************************************************
-- Name: dbo.USP_REP_LAB_AssignmentDiagnosticAZSendTo_GETList
--
-- Description: This procedure used in Assignment For Laboratory Diagnostic 
-- report to populate SentToID values.
--          
-- Author: Srini Goli

-- Revision History:
-- Name			       Date       Change Detail
-- ------------------- ---------- ----------------------------------------
-- Stephen Long        05/08/2023 Changed from institution repair to min.
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC dbo.USP_REP_LAB_AssignmentDiagnosticAZSendToLookup 'ru', 'HUMBA00019AS45'
EXEC dbo.USP_REP_LAB_AssignmentDiagnosticAZSendToLookup 'en', 'HUMTBTB0200102'
EXEC dbo.USP_REP_LAB_AssignmentDiagnosticAZSendToLookup 'ru', '123'

SELECT	thc.strCaseID,*
FROM	tlbMaterial m
	INNER JOIN tlbHumanCase thc
	ON thc.idfHumanCase = m.idfHumanCase
	AND thc.intRowStatus = 0
	
	INNER JOIN dbo.FN_GBL_Institution_Min('en') i_sent_to
	ON i_sent_to.idfOffice = m.idfSendToOffice
WHERE	m.intRowStatus = 0
		AND m.idfsSampleType <> 10320001 /*Unknown*/
		AND m.idfParentMaterial is null /*it is initially collected sample*/
*/
ALTER PROCEDURE [dbo].[USP_REP_LAB_AssignmentDiagnosticAZSendTo_GETList]
(
	@LangID	AS NVARCHAR(10), 
	@CaseID	AS VARCHAR(36)
)
AS	

DECLARE @ReportTable TABLE 
(
	idfsReference BIGINT PRIMARY KEY NOT NULL, 
	strName NVARCHAR(200)
)

/*
input parameters: language, case id

output: organization  id, organization abbreviations

o If case was not found it should returns (-2, null) 
o If case was found, and it does not contain any registered sample meeting criteria of General filtration rules, it should returns (-1, null)
o If case was found, and there is at least one sample meeting criteria of General filtration rules registered in the case, 
then all unique non-blank abbreviations of organizations taken from Send to Organization attribute of all samples meeting criteria 
of General filtration rules shall be returned with their ids


*/

IF NOT EXISTS (SELECT * FROM dbo.tlbHumanCase thc WHERE thc.strCaseID = @CaseID)
BEGIN
	-- -2 means that case does not exist
	INSERT INTO @ReportTable VALUES (-2, NULL)
END
ELSE	
IF NOT EXISTS (
	SELECT		*
	FROM	dbo.tlbMaterial m
		INNER JOIN dbo.tlbHumanCase thc
		ON thc.idfHumanCase = m.idfHumanCase
		AND thc.intRowStatus = 0
	WHERE	m.intRowStatus = 0
			AND m.idfsSampleType <> 10320001 /*Unknown*/
			AND m.idfParentMaterial is NULL /*it is initially collected sample*/
			AND thc.strCaseID = @CaseID
)	
BEGIN
	-- -1 means that case exists, but does not contain registered samples
	INSERT INTO @ReportTable VALUES (-1, NULL) 
END
ELSE
IF EXISTS (
	SELECT		*
	FROM	dbo.tlbMaterial m
		INNER JOIN dbo.tlbHumanCase thc
		ON thc.idfHumanCase = m.idfHumanCase
		AND thc.intRowStatus = 0
		INNER JOIN dbo.FN_GBL_Institution_Min(@LangID) i_sent_to
		ON i_sent_to.idfOffice = m.idfSendToOffice
	WHERE	m.intRowStatus = 0
			AND m.idfsSampleType <> 10320001 /*Unknown*/
			AND m.idfParentMaterial IS NULL /*it is initially collected sample*/
			AND thc.strCaseID = @CaseID
)
BEGIN
	--	o If case was found, and there is at least one sample meeting criteria of General filtration rules registered in the case, 
	--then all unique non-blank abbreviations of organizations taken from Send to Organization attribute of all samples meeting criteria 
	--of General filtration rules shall be returned with their ids
	INSERT INTO @ReportTable (idfsReference, strName)
	SELECT	DISTINCT m.idfSendToOffice, i_sent_to.AbbreviatedName
	FROM	dbo.tlbMaterial m
		INNER JOIN dbo.tlbHumanCase thc
		ON thc.idfHumanCase = m.idfHumanCase
		AND thc.intRowStatus = 0
		INNER JOIN dbo.FN_GBL_Institution_Min(@LangID) i_sent_to
		ON i_sent_to.idfOffice = m.idfSendToOffice
	WHERE	m.intRowStatus = 0
			AND m.idfsSampleType <> 10320001 /*Unknown*/
			AND m.idfParentMaterial IS NULL /*it is initially collected sample*/
			AND thc.strCaseID = @CaseID
END	

SELECT idfsReference, 
	strName
FROM @ReportTable
GO
PRINT N'Altering Procedure [Report].[USP_REP_GBL_Facilities_GET]...';


GO




--*************************************************************************
-- Name 				: report.USP_REP_GBL_Facilities_GET
-- Description			: List of Spacific Facilities
--						  - to select on or all facilities
--          
-- Author               : Mark Wilson
-- Revision History
--		Name			Date       Change Detail
-- -------------------- ---------- ---------------------------------------
-- Stephen Long         05/08/2023 Changed from institution repair to min.
--
-- Testing code:
--
-- EXEC report.USP_REP_GBL_Facilities_GET 'ka'
-- EXEC report.USP_REP_GBL_Facilities_GET 'en', 2
--*************************************************************************
ALTER PROCEDURE [Report].[USP_REP_GBL_Facilities_GET] 
(
	@LangID NVARCHAR(50) = 'en-US',	--##PARAM @LangID - language ID
	@intHACode INT = NULL
)
AS	
BEGIN	
	SELECT 
		idfOffice,
		AbbreviatedName AS OfficeName
	FROM dbo.FN_GBL_Institution_Min(@LangID)
	WHERE @intHACode IN (SELECT CAST(intHACode AS INT) FROM dbo.FN_GBL_SplitHACode(intHACode,510))	
	OR @intHACode IS NULL;
END
GO
PRINT N'Altering Procedure [Report].[USP_REP_HUM_DataQualityIndicators]...';


GO
--********************************************************************************************************
-- Name 				: USP_REP_HUM_DataQualityIndicators
-- Description			: This procedure returns resultset for Main indicators of AFP surveillance report
--          
-- Author               : Mandar Kulkarni
--
-- Revision History:
-- Name                Date       Change Detail
-- ------------------- ---------- -----------------------------------------------------------------------
-- Stephen Long        05/08/2023 Changed from institution repair to min.
--
--Example of a call of procedure:

--SELECT td.idfsDiagnosis, tbr.strDefault, tsnt.strTextString, tsnt.idfsLanguage, td.idfsUsingType
--  FROM trtDiagnosis td
--INNER JOIN trtBaseReference tbr
--ON tbr.idfsBaseReference = td.idfsDiagnosis
--INNER JOIN trtStringNameTranslation tsnt
--ON tsnt.idfsBaseReference = tbr.idfsBaseReference

--WHERE
--tbr.strDefault like '%Acute intestinal infection %'
--AND tbr.intRowStatus = 0

/*
 EXEC report.USP_REP_HUM_DataQualityIndicators 
 'en', 
'7718070000000,7718060000000',
 2016,
 1,
 12
 */
--********************************************************************************************************
ALTER PROCEDURE [Report].[USP_REP_HUM_DataQualityIndicators]
(
    @LangID AS NVARCHAR(50),
    @Diagnosis AS NVARCHAR(MAX),
    @Year AS INT,
    @StartMonth AS INT = NULL,
    @EndMonth AS INT = NULL,
    @RegionID AS BIGINT = NULL,
    @RayonID AS BIGINT = NULL,
    @SiteID AS BIGINT = NULL
)
AS
SET NOCOUNT ON

DECLARE @CountryID BIGINT,
        @iDiagnosis INT,
        @SDDate DATETIME,
        @EDDate DATETIME,
        @idfsLanguage BIGINT,
        @idfsCustomReportType BIGINT,
        @Ind_1_Notification NUMERIC(4, 2),
        @Ind_2_CaseInvestigation NUMERIC(4, 2),
        @Ind_3_TheResultsOfLabTestsAndInterpretation NUMERIC(4, 2),
        @Ind_N1_CaseStatus NUMERIC(4, 2),
        @Ind_N1_DateofCompletionPF NUMERIC(4, 2),
        @Ind_N1_NameofEmployer NUMERIC(4, 2),
        @Ind_N1_CurrentLocationPatient NUMERIC(4, 2),
        @Ind_N1_NotifDateTime NUMERIC(4, 2),
        @Ind_N2_NotifDateTime NUMERIC(4, 2),
        @Ind_N3_NotifDateTime NUMERIC(4, 2),
        @Ind_N1_NotifSentByName NUMERIC(4, 2),
        @Ind_N1_NotifReceivedByFacility NUMERIC(4, 2),
        @Ind_N1_NotifReceivedByName NUMERIC(4, 2),
        @Ind_N1_TimelinessOfDataEntryDTEN NUMERIC(4, 2),
        @Ind_N2_TimelinessOfDataEntryDTEN NUMERIC(4, 2),
        @Ind_N3_TimelinessOfDataEntryDTEN NUMERIC(4, 2),
        @Ind_N1_DIStartingDTOfInvestigation NUMERIC(4, 2),
        @Ind_N2_DIStartingDTOfInvestigation NUMERIC(4, 2),
        @Ind_N3_DIStartingDTOfInvestigation NUMERIC(4, 2),
        @Ind_N1_DIOccupation NUMERIC(4, 2),
        @Ind_N1_CIInitCaseClassification NUMERIC(4, 2),
        @Ind_N1_CILocationOfExposure NUMERIC(4, 2),
        @Ind_N1_CIAntibioticTherapyAdministratedBSC NUMERIC(4, 2),
        @Ind_N1_SamplesCollection NUMERIC(4, 2),
        @Ind_N1_ContactLisAddContact NUMERIC(4, 2),
        @Ind_N1_CaseClassificationCS NUMERIC(4, 2),
        @Ind_N1_EpiLinksRiskFactorsByEpidCard NUMERIC(4, 2),
        @Ind_N2_EpiLinksRiskFactorsByEpidCard NUMERIC(4, 2),
        @Ind_N3_EpiLinksRiskFactorsByEpidCard NUMERIC(4, 2),
        @Ind_N1_FCCOBasisOfDiagnosis NUMERIC(4, 2),
        @Ind_N1_FCCOOutcome NUMERIC(4, 2),
        @Ind_N1_FCCOIsThisCaseRelatedToOutbreak NUMERIC(4, 2),
        @Ind_N1_FCCOEpidemiologistName NUMERIC(4, 2),
        @Ind_N1_ResultsOfLabTestsTestsConducted NUMERIC(4, 2),
        @Ind_N1_ResultsOfLabTestsResultObservation NUMERIC(4, 2),
        @idfsRegionBaku BIGINT,
        @idfsRegionOtherRayons BIGINT,
        @idfsRegionNakhichevanAR BIGINT

DECLARE @DiagnosisTABLE TABLE
(
    intRowNumber INT IDENTITY(1, 1) PRIMARY KEY,
    [key] NVARCHAR(300),
    [value] NVARCHAR(300),
    intNotificationToCHE INT,
    intStartingDTOfInvestigation INT,
    blnLaboratoryConfirmation BIT,
    intQuantityOfMandatoryFieldCS INT,
    intQuantityOfMandatoryFieldCSForDC INT,
    intEPILincsAndFactors INT
)

DECLARE @ReportTABLE TABLE
(
    idfsBaseReference BIGINT IDENTITY NOT NULL PRIMARY KEY,
    idfsRegion BIGINT NOT NULL,
/*1*/
    strRegion NVARCHAR(200) NOT NULL,
    intRegionOrder INT NULL,
    idfsRayon BIGINT NOT NULL,
/*2*/
    strRayon NVARCHAR(200) NOT NULL,
    strAZRayon NVARCHAR(200) NOT NULL,
    intRayonOrder INT NULL,
    intCaseCount INT NOT NULL,
    idfsDiagnosis BIGINT NOT NULL,
/*3*/
    strDiagnosis NVARCHAR(300) COLLATE database_default NOT NULL,

/*6(1+2+3+5+6+8+9+10)*/
    dbl_1_Notification FLOAT NULL,
/*7(1)*/
    dblCaseStatus FLOAT NULL,
/*8(2)*/
    dblDateOfCompletionOfPaperForm FLOAT NULL,
/*9(3)*/
    dblNameOfEmployer FLOAT NULL,
/*11(5)*/
    dblCurrentLocationOfPatient FLOAT NULL,
/*12(6)*/
    dblNotificationDateTime FLOAT NULL,
/*13(7)*/
    dbldblNotificationSentByName FLOAT NULL,
/*14(8)*/
    dblNotificationReceivedByFacility FLOAT NULL,
/*15(9)*/
    dblNotificationReceivedByName FLOAT NULL,
/*16(10)*/
    dblTimelinessofDataEntry FLOAT NULL,

/*17(11..23)*/
    dbl_2_CaseInvestigation FLOAT NULL,
/*18(11)*/
    dblDemographicInformationStartingDateTimeOfInvestigation FLOAT NULL,
/*19(12)*/
    dblDemographicInformationOccupation FLOAT NULL,
/*20(13)*/
    dblClinicalInformationInitialCaseClassification FLOAT NULL,
/*21(14)*/
    dblClinicalInformationLocationOfExposure FLOAT NULL,
/*22(15)*/
    dblClinicalInformationAntibioticAntiviralTherapy FLOAT NULL,
/*23(16)*/
    dblSamplesCollectionSamplesCollected FLOAT NULL,
/*24(17)*/
    dblContactListAddContact FLOAT NULL,
/*25(18)*/
    dblCaseClassificationClinicalSigns FLOAT NULL,
/*26(19)*/
    dblEpidemiologicalLinksAndRiskFactors FLOAT NULL,
/*27(20)*/
    dblFinalCaseClassificationBasisOfDiagnosis FLOAT NULL,
/*28(21)*/
    dblFinalCaseClassificationOutcome FLOAT NULL,
/*29(22)*/
    dblFinalCaseClassificationIsThisCaseOutbreak FLOAT NULL,
/*30(23)*/
    dblFinalCaseClassificationEpidemiologistName FLOAT NULL,

/*31(24+25)*/
    dbl_3_TheResultsOfLaboratoryTests FLOAT NULL,
/*32(24)*/
    dblTheResultsOfLaboratoryTestsTestsConducted FLOAT NULL,
/*33(25)*/
    dblTheResultsOfLaboratoryTestsResultObservation FLOAT NULL,

/*34*/
    dblSummaryScoreByIndicators FLOAT NULL
)

IF @StartMonth IS NULL
BEGIN
    SET @SDDate = (CAST(@Year AS VARCHAR(4)) + '01' + '01')
    SET @EDDate = dateADD(yyyy, 1, @SDDate)
END
ELSE
BEGIN
    IF @StartMonth < 10
        SET @SDDate = (CAST(@Year AS VARCHAR(4)) + '0' + CAST(@StartMonth AS VARCHAR(2)) + '01')
    ELSE
        SET @SDDate = (CAST(@Year AS VARCHAR(4)) + CAST(@StartMonth AS VARCHAR(2)) + '01')

    IF (@EndMonth is NULL)
       or (@StartMonth = @EndMonth)
        SET @EDDate = DATEADD(mm, 1, @SDDate)
    ELSE
    BEGIN
        IF @EndMonth < 10
            SET @EDDate = (CAST(@Year AS VARCHAR(4)) + '0' + CAST(@EndMonth AS VARCHAR(2)) + '01')
        ELSE
            SET @EDDate = (CAST(@Year AS VARCHAR(4)) + CAST(@EndMonth AS VARCHAR(2)) + '01')

        SET @EDDate = DATEADD(mm, 1, @EDDate)
    END
END

SET @CountryID = 170000000
SET @idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
SET @idfsCustomReportType = 10290021

INSERT INTO @DiagnosisTABLE
(
    [key]
)
SELECT CAST([Value] AS BIGINT)
FROM report.FN_GBL_SYS_SplitList(@Diagnosis, 1, ',')

-- IF @Diagnosis is blank, fill to @DiagnosisTABLE all diagnosis
IF
(
    SELECT COUNT(*) FROM @DiagnosisTABLE
) = 0
BEGIN
    INSERT INTO @DiagnosisTABLE
    (
        [key],
        [value]
    )
    SELECT tbr.idfsBaseReference,
           tbr.strBaseReferenceCode
    FROM dbo.trtBaseReference tbr
        INNER JOIN dbo.trtBaseReferenceToCP tbrtc
            ON tbrtc.idfsBaseReference = tbr.idfsBaseReference
        INNER JOIN dbo.tstCustomizationPackage cp
            ON cp.idfCustomizationPackage = tbrtc.idfCustomizationPackage
               AND cp.idfsCountry = @CountryID
        INNER JOIN dbo.trtBaseReferenceAttribute tbra3
            INNER JOIN dbo.trtAttributeType tat3
                ON tat3.idfAttributeType = tbra3.idfAttributeType
                   AND tat3.strAttributeTypeName = 'QI Laboratory Confirmation'
            ON tbra3.idfsBaseReference = tbr.idfsBaseReference
    WHERE tbr.idfsReferenceType = 19000019 /*diagnosis*/
          AND tbr.intRowStatus = 0
          AND (tbr.intHACode & 2) > 1
END
ELSE
BEGIN
    UPDATE @DiagnosisTABLE
    SET [value] = b.strBaseReferenceCode
    FROM @DiagnosisTABLE a
        INNER JOIN trtBaseReference b
            ON a.[key] = b.idfsBaseReference
END

-- new !
UPDATE dt
SET dt.intNotificationToCHE = CASE
                                  WHEN SQL_VARIANT_PROPERTY(tbra1.varValue, 'BaseType') in ( 'BIGINT', 'decimal',
                                                                                             'FLOAT', 'INT', 'NUMERIC',
                                                                                             'real', 'smallint',
                                                                                             'tinyint'
                                                                                           ) THEN
                                      CAST(tbra1.varValue AS INT)
                                  ELSE
                                      NULL
                              END,
    dt.intStartingDTOfInvestigation = CASE
                                          WHEN SQL_VARIANT_PROPERTY(tbra2.varValue, 'BaseType') in ( 'BIGINT',
                                                                                                     'decimal',
                                                                                                     'FLOAT', 'INT',
                                                                                                     'NUMERIC', 'real',
                                                                                                     'smallint',
                                                                                                     'tinyint'
                                                                                                   ) THEN
                                              CAST(tbra2.varValue AS INT)
                                          ELSE
                                              NULL
                                      END,
    dt.blnLaboratoryConfirmation = CASE
                                       WHEN SQL_VARIANT_PROPERTY(tbra3.varValue, 'BaseType') in ( 'BIGINT', 'decimal',
                                                                                                  'FLOAT', 'INT',
                                                                                                  'NUMERIC', 'real',
                                                                                                  'smallint', 'tinyint'
                                                                                                ) THEN
                                           CAST(tbra3.varValue AS INT)
                                       ELSE
                                           NULL
                                   END,
    dt.intQuantityOfMandatoryFieldCS = CASE
                                           WHEN SQL_VARIANT_PROPERTY(tbra5.varValue, 'BaseType') in ( 'BIGINT',
                                                                                                      'decimal',
                                                                                                      'FLOAT', 'INT',
                                                                                                      'NUMERIC',
                                                                                                      'real',
                                                                                                      'smallint',
                                                                                                      'tinyint'
                                                                                                    ) THEN
                                               CAST(tbra5.varValue AS INT)
                                           ELSE
                                               NULL
                                       END,
    dt.intQuantityOfMandatoryFieldCSForDC = CASE
                                                WHEN SQL_VARIANT_PROPERTY(tbra6.varValue, 'BaseType') in ( 'BIGINT',
                                                                                                           'decimal',
                                                                                                           'FLOAT',
                                                                                                           'INT',
                                                                                                           'NUMERIC',
                                                                                                           'real',
                                                                                                           'smallint',
                                                                                                           'tinyint'
                                                                                                         ) THEN
                                                    CAST(tbra6.varValue AS INT)
                                                ELSE
                                                    NULL
                                            END,
    dt.intEPILincsAndFactors = CASE
                                   WHEN SQL_VARIANT_PROPERTY(tbra7.varValue, 'BaseType') in ( 'BIGINT', 'decimal',
                                                                                              'FLOAT', 'INT',
                                                                                              'NUMERIC', 'real',
                                                                                              'smallint', 'tinyint'
                                                                                            ) THEN
                                       CAST(tbra7.varValue AS INT)
                                   ELSE
                                       NULL
                               END
FROM @DiagnosisTABLE dt
    LEFT JOIN dbo.trtBaseReferenceAttribute tbra1
        INNER JOIN dbo.trtAttributeType tat1
            ON tat1.idfAttributeType = tbra1.idfAttributeType
               AND tat1.strAttributeTypeName = 'QI Transmission of Emergency Notification to CHE'
        ON tbra1.idfsBaseReference = dt.[key]
    LEFT JOIN dbo.trtBaseReferenceAttribute tbra2
        INNER JOIN dbo.trtAttributeType tat2
            ON tat2.idfAttributeType = tbra2.idfAttributeType
               AND tat2.strAttributeTypeName = 'QI Starting date, time of investigation'
        ON tbra2.idfsBaseReference = dt.[key]
    LEFT JOIN dbo.trtBaseReferenceAttribute tbra3
        INNER JOIN dbo.trtAttributeType tat3
            ON tat3.idfAttributeType = tbra3.idfAttributeType
               AND tat3.strAttributeTypeName = 'QI Laboratory Confirmation'
        ON tbra3.idfsBaseReference = dt.[key]
    LEFT JOIN dbo.trtBaseReferenceAttribute tbra5
        INNER JOIN dbo.trtAttributeType tat5
            ON tat5.idfAttributeType = tbra5.idfAttributeType
               AND tat5.strAttributeTypeName = 'QI Quantity of mandatory fields of Clinical Signs'
        ON tbra5.idfsBaseReference = dt.[key]
    LEFT JOIN dbo.trtBaseReferenceAttribute tbra6
        INNER JOIN dbo.trtAttributeType tat6
            ON tat6.idfAttributeType = tbra6.idfAttributeType
               AND tat6.strAttributeTypeName = 'QI Quantity of mandatory fields of Clinical Signs that’s nesessary for diagnosis confirmation by Clinical Signs ("Yes")'
        ON tbra6.idfsBaseReference = dt.[key]
    LEFT JOIN dbo.trtBaseReferenceAttribute tbra7
        INNER JOIN dbo.trtAttributeType tat7
            ON tat7.idfAttributeType = tbra7.idfAttributeType
               AND tat7.strAttributeTypeName = 'QI Epidemiological Links AND Risk Factors - Minimum quantity logically filled fields.'
        ON tbra7.idfsBaseReference = dt.[key]

-- new
--1.
SELECT @Ind_1_Notification = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.Notification'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--1.1.
SELECT @Ind_N1_CaseStatus = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.1. CASE Status'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--1.2.
SELECT @Ind_N1_DateofCompletionPF = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.2. Date of Completion of Paper form'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--1.3.
SELECT @Ind_N1_NameofEmployer = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.3. Name of Employer'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--1.5.
SELECT @Ind_N1_CurrentLocationPatient = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.5. Current location of patient'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--1.6.
SELECT @Ind_N1_NotifDateTime = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.6. Notification date, time'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

SELECT @Ind_N2_NotifDateTime = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N2'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.6. Notification date, time'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

SELECT @Ind_N3_NotifDateTime = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N3'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.6. Notification date, time'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--1.8.
SELECT @Ind_N1_NotifSentByName = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.8. Notification sent by: Name'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--1.9.
SELECT @Ind_N1_NotifReceivedByFacility = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.9. Notification received by: Facility'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--1.10.
SELECT @Ind_N1_NotifReceivedByName = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.10. Notification received by: Name'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--1.11.
SELECT @Ind_N1_TimelinessOfDataEntryDTEN = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.11. Timeliness of Data Entry, date AND time of the Emergency Notification'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

SELECT @Ind_N2_TimelinessOfDataEntryDTEN = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N2'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.11. Timeliness of Data Entry, date AND time of the Emergency Notification'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

SELECT @Ind_N3_TimelinessOfDataEntryDTEN = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N3'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.11. Timeliness of Data Entry, date AND time of the Emergency Notification'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.
SELECT @Ind_2_CaseInvestigation = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2. CASE Investigation'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.1.1.
SELECT @Ind_N1_DIStartingDTOfInvestigation = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.1.1. Demographic Information -Starting date, time of investigation'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

SELECT @Ind_N2_DIStartingDTOfInvestigation = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N2'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.1.1. Demographic Information -Starting date, time of investigation'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

SELECT @Ind_N3_DIStartingDTOfInvestigation = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N3'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.1.1. Demographic Information -Starting date, time of investigation'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.1.2.
SELECT @Ind_N1_DIOccupation = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.1.2. Demographic Information – Occupation'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.2.1.
SELECT @Ind_N1_CIInitCaseClassification = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.2.1. Clinical information - Initial CASE Classification'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.2.2.
SELECT @Ind_N1_CILocationOfExposure = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.2.2. Clinical information - Location of Exposure IF it known'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.2.3.
SELECT @Ind_N1_CIAntibioticTherapyAdministratedBSC = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.2.3. Clinical information - Antibiotic/Antiviral therapy administrated before samples collection'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.3.1.
SELECT @Ind_N1_SamplesCollection = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.3.1. Samples Collection  - Samples collected'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.4.1.
SELECT @Ind_N1_ContactLisAddContact = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.4.1. Contact List  - Add Contact'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.5.
SELECT @Ind_N1_CaseClassificationCS = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.5. CASE Classification (Clinical signs)'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.6.1.
SELECT @Ind_N1_EpiLinksRiskFactorsByEpidCard = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.6.1. Epidemiological Links AND Risk Factors - by Epidemiological card'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

SELECT @Ind_N2_EpiLinksRiskFactorsByEpidCard = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N2'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.6.1. Epidemiological Links AND Risk Factors - by Epidemiological card'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

SELECT @Ind_N3_EpiLinksRiskFactorsByEpidCard = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N3'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.6.1. Epidemiological Links AND Risk Factors - by Epidemiological card'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )


--2.7.3.
SELECT @Ind_N1_FCCOBasisOfDiagnosis = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.7.3. Final CASE Classification AND Outcome - Basis of Diagnosis'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.7.4.
SELECT @Ind_N1_FCCOOutcome = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.7.4. Final CASE Classification AND Outcome – Outcome'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.7.5.
SELECT @Ind_N1_FCCOIsThisCaseRelatedToOutbreak = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.7.5. Final CASE Classification AND Outcome - Is this CASE related to an outbreak'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.7.6.
SELECT @Ind_N1_FCCOEpidemiologistName = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.7.6. Final CASE Classification AND Outcome - Epidemiologist name'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--3.
SELECT @Ind_3_TheResultsOfLabTestsAndInterpretation = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '3.The results of Laboratory Tests AND  Interpretation'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--3.1.
SELECT @Ind_N1_ResultsOfLabTestsTestsConducted = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '3.1. The results of Laboratory Tests AND Interpretation - Tests Conducted'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--3.2.
SELECT @Ind_N1_ResultsOfLabTestsResultObservation = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '3.2. The results of Laboratory Tests AND Interpretation - Result/Observation'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )



--Transport CHE
DECLARE @TransportCHE BIGINT

SELECT @TransportCHE = frr.idfsReference
FROM dbo.FN_GBL_ReferenceRepair('en', 19000020) frr
WHERE frr.name = 'Transport CHE'
print @TransportCHE


--1344330000000 --Baku
SELECT @idfsRegionBaku = tbra.idfsGISBaseReference
FROM dbo.trtGISBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType at
        ON at.strAttributeTypeName = N'AZ Region'
WHERE CAST(tbra.varValue AS NVARCHAR(100)) = N'Baku'

--1344340000000 --Other rayons
SELECT @idfsRegionOtherRayons = tbra.idfsGISBaseReference
FROM dbo.trtGISBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType at
        ON at.strAttributeTypeName = N'AZ Region'
WHERE CAST(tbra.varValue AS NVARCHAR(100)) = N'Other rayons'


--1344350000000 --Nakhichevan AR
SELECT @idfsRegionNakhichevanAR = tbra.idfsGISBaseReference
FROM dbo.trtGISBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType at
        ON at.strAttributeTypeName = N'AZ Region'
WHERE CAST(tbra.varValue AS NVARCHAR(100)) = N'Nakhichevan AR'


-------------------------------------------
DECLARE @isTLVL BIGINT
SET @isTLVL = 0

SELECT @isTLVL = CASE
                     WHEN ts.idfsSiteType = 10085007 THEN
                         1
                     ELSE
                         0
                 END
FROM tstSite ts
WHERE ts.idfsSite = ISNULL(@SiteID, dbo.fnSiteID())

DECLARE @isWeb BIGINT
SET @isWeb = 0

SELECT @isWeb = ISNULL(ts.blnIsWEB, 0)
FROM tstSite ts
WHERE ts.idfsSite = dbo.fnSiteID()
-------------------------------------------

IF OBJECT_ID('tempdb.dbo.#FilteredRayonsTABLE') is NOT NULL
    DROP TABLE #FilteredRayonsTABLE
CREATE TABLE #FilteredRayonsTABLE
(
    idfsRegion BIGINT,
    idfsRayon BIGINT,
    PRIMARY KEY
    (
        idfsRegion,
        idfsRayon
    )
)

--DECLARE #ReportDataTABLE TABLE
IF OBJECT_ID('tempdb.dbo.#ReportDataTABLE') is NOT NULL
    DROP TABLE #ReportDataTABLE
CREATE TABLE #ReportDataTABLE
(
    id INT IDENTITY(1, 1) PRIMARY KEY,
    IdRegion BIGINT,
    strRegion NVARCHAR(2000) COLLATE database_default,
    IdRayon BIGINT,
    strRayon NVARCHAR(2000) COLLATE database_default,
    strAZRayon NVARCHAR(2000) COLLATE database_default,
    IdDiagnosis BIGINT,
    Diagnosis NVARCHAR(2000) COLLATE database_default,
    intRegionOrder INT,
    intRayonOrder INT,
    CountCasesForDiag INT
)

--DECLARE #ReportCaseTABLE TABLE
IF OBJECT_ID('tempdb.dbo.#ReportCaseTABLE') is NOT NULL
    DROP TABLE #ReportCaseTABLE
CREATE TABLE #ReportCaseTABLE
(
    id INT IDENTITY(1, 1) PRIMARY KEY,
    idfCase BIGINT,
    IdRegion BIGINT,
    strRegion NVARCHAR(2000) COLLATE database_default,
    IdRayon BIGINT,
    strRayon NVARCHAR(2000) COLLATE database_default,
    strAZRayon NVARCHAR(2000) COLLATE database_default,
    intRegionOrder INT,
    intRayonOrder INT,
    idfsShowDiagnosis BIGINT,
    Diagnosis NVARCHAR(2000) COLLATE database_default,
    idfsShowDiagnosisFromCase BIGINT,

/*7(1)*/
    IndCaseStatus FLOAT,
/*8(2)*/
    IndDateOfCompletionPaperFormDate FLOAT,
/*9(3)*/
    IndNameOfEmployer FLOAT,
/*11(5)*/
    IndCurrentLocation FLOAT,
/*12(6)*/
    IndNotificationDate FLOAT,
/*13(7)*/
    IndNotificationSentByName FLOAT,
/*14(8)*/
    IndNotificationReceivedByFacility FLOAT,
/*15(9)*/
    IndNotificationReceivedByName FLOAT,
/*16(10)*/
    IndDateAndTimeOfTheEmergencyNotification FLOAT,

/*18(11)*/
    IndInvestigationStartDate FLOAT,
/*19(12)*/
    IndOccupationType FLOAT,
/*20(13)*/
    IndInitialCaseClassification FLOAT,
/*21(14)*/
    IndLocationOfExplosure FLOAT,
/*22(15)*/
    IndAATherapyAdmBeforeSamplesCollection FLOAT,
/*23(16)*/
    IndSamplesCollected FLOAT,
/*24(17)*/
    IndAddcontact FLOAT,
/*25(18)*/
    IndClinicalSigns FLOAT,
/*26(19)*/
    IndEpidemiologicalLinksAndRiskFactors FLOAT,

/*27(20)*/
    IndBasisOfDiagnosis FLOAT,
/*28(21)*/
    IndOutcome FLOAT,
/*29(22)*/
    IndISThisCaseRelatedToOutbreak FLOAT,
/*30(23)*/
    IndEpidemiologistName FLOAT,

/*32(24)*/
    IndResultsTestsConducted FLOAT,
/*33(25)*/
    IndResultsResultObservation FLOAT
)

IF OBJECT_ID('tempdb.dbo.#ReportCaseTABLE_CountForDiagnosis') is NOT NULL
    DROP TABLE #ReportCaseTABLE_CountForDiagnosis
CREATE TABLE #ReportCaseTABLE_CountForDiagnosis
(
    CountCase INT,
    IdRegion BIGINT,
    IdRayon BIGINT,
    idfsShowDiagnosis BIGINT
        PRIMARY KEY
        (
            IdRegion,
            IdRayon,
            idfsShowDiagnosis
        )
)

INSERT INTO #FilteredRayonsTABLE
SELECT CASE
           WHEN s_current.intFlags = 1
                AND cp.idfsCountry = @CountryID THEN
               @TransportCHE
           ELSE
               gls.idfsRegion
       END AS idfsRegion,
       CASE
           WHEN s_current.intFlags = 1
                AND cp.idfsCountry = @CountryID THEN
               s_current.idfsSite
           ELSE
               gls.idfsRayon
       END AS idfsRayon
FROM dbo.tstSite s_current
    INNER JOIN dbo.tstCustomizationPackage cp
        ON cp.idfCustomizationPackage = s_current.idfCustomizationPackage
           AND cp.idfsCountry = @CountryID
    INNER JOIN dbo.tlbOffice o_current
        ON o_current.idfOffice = s_current.idfOffice
           AND o_current.intRowStatus = 0
    INNER JOIN dbo.tlbGeoLocationShared gls
        ON gls.idfGeoLocationShared = o_current.idfLocation
WHERE s_current.idfsSite = ISNULL(@SiteID, dbo.fnSiteID())
      AND gls.idfsRayon is NOT NULL
UNION
SELECT CASE
           WHEN s.intFlags = 1
                AND cp.idfsCountry = @CountryID THEN
               @TransportCHE
           ELSE
               gls.idfsRegion
       END AS idfsRegion,
       CASE
           WHEN s.intFlags = 1
                AND cp.idfsCountry = @CountryID THEN
               s.idfsSite
           ELSE
               gls.idfsRayon
       END AS idfsRayon
FROM dbo.tstSite s
    INNER JOIN dbo.tstCustomizationPackage cp
        ON cp.idfCustomizationPackage = s.idfCustomizationPackage
           AND cp.idfsCountry = @CountryID
    INNER JOIN dbo.tlbOffice o
        ON o.idfOffice = s.idfOffice
           AND o.intRowStatus = 0
    INNER JOIN dbo.tlbGeoLocationShared gls
        ON gls.idfGeoLocationShared = o.idfLocation
    INNER JOIN dbo.tflSiteToSiteGROUP sts
        INNER JOIN dbo.tflSiteGROUP tsg
            ON tsg.idfSiteGROUP = sts.idfSiteGROUP
               AND tsg.idfsRayon is NULL
        ON sts.idfsSite = s.idfsSite
    INNER JOIN dbo.tflSiteGROUPRelation sgr
        ON sgr.idfSenderSiteGROUP = sts.idfSiteGROUP
    INNER JOIN dbo.tflSiteToSiteGROUP stsr
        INNER JOIN dbo.tflSiteGROUP tsgr
            ON tsgr.idfSiteGROUP = stsr.idfSiteGROUP
               AND tsgr.idfsRayon IS NULL
        ON sgr.idfReceiverSiteGROUP = stsr.idfSiteGROUP
           AND stsr.idfsSite = ISNULL(@SiteID, dbo.fnSiteID())
WHERE gls.idfsRayon is NOT NULL

-- + border area
INSERT INTO #FilteredRayonsTABLE
(
    idfsRayon
)
SELECT DISTINCT
    osr.idfsRayon
FROM #FilteredRayonsTABLE fr
    INNER JOIN report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) r
        ON r.idfsRayon = fr.idfsRayon
           AND r.intRowStatus = 0
    INNER JOIN dbo.tlbGeoLocationShared gls
        ON gls.idfsRayon = r.idfsRayon
    INNER JOIN dbo.tlbOffice o
        ON gls.idfGeoLocationShared = o.idfLocation
           AND o.intRowStatus = 0
    INNER JOIN dbo.tstSite s
        INNER JOIN dbo.tstCustomizationPackage cp
            ON cp.idfCustomizationPackage = s.idfCustomizationPackage
        ON s.idfOffice = o.idfOffice
    INNER JOIN dbo.tflSiteGROUP tsg_cent
        ON tsg_cent.idfsCentralSite = s.idfsSite
           AND tsg_cent.idfsRayon is NULL
           AND tsg_cent.intRowStatus = 0
    INNER JOIN dbo.tflSiteToSiteGROUP tstsg
        ON tstsg.idfSiteGROUP = tsg_cent.idfSiteGROUP
    INNER JOIN dbo.tstSite ts
        ON ts.idfsSite = tstsg.idfsSite
    INNER JOIN dbo.tlbOffice os
        ON os.idfOffice = ts.idfOffice
           AND os.intRowStatus = 0
    INNER JOIN dbo.tlbGeoLocationShared ogl
        ON ogl.idfGeoLocationShared = o.idfLocation
    INNER JOIN report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) osr
        ON osr.idfsRayon = ogl.idfsRayon
           AND ogl.intRowStatus = 0
    LEFT JOIN #FilteredRayonsTABLE fr2
        ON osr.idfsRayon = fr2.idfsRayon
WHERE fr2.idfsRayon is NULL

INSERT INTO #ReportDataTABLE
(
    IdRegion,
    strRegion,
    IdRayon,
    strRayon,
    strAZRayon,
    IdDiagnosis,
    Diagnosis,
    intRegionOrder,
    intRayonOrder
)
SELECT reg.idfsRegion AS IdRegion,
       refReg.[name] AS strRegion,
       ray.idfsRayon AS IdRayon,
       refRay.[name] AS strRayon,
       refRayAZ.[name] AS strAZRayon,
       0 AS IdDiagnosis,
       '' AS Diagnosis,
       CASE reg.idfsRegion
           WHEN @idfsRegionBaku --1344330000000 --Baku
       THEN
               1
           WHEN @idfsRegionOtherRayons --1344340000000 --Other rayons
       THEN
               2
           WHEN @idfsRegionNakhichevanAR --1344350000000 --Nakhichevan AR
       THEN
               3
           ELSE
               0
       END AS intRegionOrder,
       0 AS intRayonOrder
FROM report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) AS reg
    JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000003 /*rftRegion*/) AS refReg
        ON reg.idfsRegion = refReg.idfsReference
           AND reg.idfsCountry = @CountryID
    JOIN report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) AS ray
        ON ray.idfsRegion = reg.idfsRegion
    JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000002 /*rftRayon*/) AS refRay
        ON ray.idfsRayon = refRay.idfsReference
    JOIN dbo.FN_GBL_GIS_Reference('az-l', 19000002 /*rftRayon*/) AS refRayAZ
        ON ray.idfsRayon = refRayAZ.idfsReference
    LEFT JOIN #FilteredRayonsTABLE frt
        ON frt.idfsRegion = reg.idfsRegion
           AND frt.idfsRayon = ray.idfsRayon
WHERE CAST(@Diagnosis AS NVARCHAR(MAX)) = '<ItemList/>'
      AND (
              @isTLVL = 0
              or frt.idfsRayon is NOT NULL
              or @isWeb = 1
          )
UNION ALL
SELECT tbr.idfsGISBaseReference AS IdRegion,
       frr.[name] AS strRegion,
       ts.idfsSite AS IdRayon,
       fir.AbbreviatedName AS strRayon,
       firAZ.AbbreviatedName AS strAZRayon,
       0 AS IdDiagnosis,
       '' AS Diagnosis,
       4 AS intRegionOrder,
       tbr1.intOrder AS intRayonOrder
FROM dbo.gisBaseReference tbr --TransportCHE
    JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000020) frr
        ON frr.idfsReference = tbr.idfsGISBaseReference
           AND tbr.idfsGISBaseReference = @TransportCHE
    CROSS JOIN dbo.tstSite ts
    LEFT JOIN #FilteredRayonsTABLE frt
        ON frt.idfsRegion = @TransportCHE
           AND frt.idfsRayon = ts.idfsSite
    JOIN dbo.tstCustomizationPackage cp
        ON cp.idfCustomizationPackage = ts.idfCustomizationPackage
           AND cp.idfsCountry = @CountryID
    JOIN dbo.FN_GBL_Institution_Min(@LangID) fir
        ON fir.idfOffice = ts.idfOffice
           AND ts.intFlags = 1
    JOIN dbo.FN_GBL_Institution_Min('az-l') firAZ
        ON firAZ.idfOffice = ts.idfOffice
           AND ts.intFlags = 1
    JOIN dbo.trtBaseReference tbr1
        ON tbr1.idfsBaseReference = fir.idfsOfficeAbbreviation
WHERE CAST(@Diagnosis AS NVARCHAR(max)) = '<ItemList/>'
      AND (
              @isTLVL = 0
              or frt.idfsRayon is NOT NULL
              or @isWeb = 1
          )
UNION ALL
SELECT reg.idfsRegion AS IdRegion,
       refReg.[name] AS strRegion,
       ray.idfsRayon AS IdRayon,
       refRay.[name] AS strRayon,
       refRayAZ.[name] AS strAZRayon,
       CAST(dt.[key] AS BIGINT) AS IdDiagnosis,
       refDiag.name AS Diagnosis,
       CASE reg.idfsRegion
           WHEN @idfsRegionBaku --1344330000000 --Baku
       THEN
               1
           WHEN @idfsRegionOtherRayons --1344340000000 --Other rayons
       THEN
               2
           WHEN @idfsRegionNakhichevanAR --1344350000000 --Nakhichevan AR
       THEN
               3
           ELSE
               0
       END AS intRegionOrder,
       0 AS intRayonOrder
FROM report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) AS reg
    JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000003 /*rftRegion*/) AS refReg
        ON reg.idfsRegion = refReg.idfsReference
           AND reg.idfsCountry = @CountryID
    JOIN report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) AS ray
        ON ray.idfsRegion = reg.idfsRegion
    JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000002 /*rftRayon*/) AS refRay
        ON ray.idfsRayon = refRay.idfsReference
    JOIN dbo.FN_GBL_GIS_Reference('az-l', 19000002 /*rftRayon*/) AS refRayAZ
        ON ray.idfsRayon = refRayAZ.idfsReference
    LEFT JOIN #FilteredRayonsTABLE frt
        ON frt.idfsRegion = reg.idfsRegion
           AND frt.idfsRayon = ray.idfsRayon
    CROSS JOIN @DiagnosisTABLE AS dt
    JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019 /*rftDiagnosis*/) AS refDiag
        ON dt.[key] = refDiag.idfsReference
WHERE CAST(@Diagnosis AS NVARCHAR(MAX)) <> '<ItemList/>'
      AND (
              @isTLVL = 0
              or frt.idfsRayon is NOT NULL
              or @isWeb = 1
          )
UNION ALL
SELECT tbr.idfsGISBaseReference AS IdRegion,
       frr.[name] AS strRegion,
       ts.idfsSite AS IdRayon,
       fir.AbbreviatedName AS strRayon,
       firAZ.AbbreviatedName AS strAZRayon,
       CAST(dt.[key] AS BIGINT) AS IdDiagnosis,
       refDiag.name AS Diagnosis,
       4 AS intRegionOrder,
       tbr1.intOrder AS intRayonOrder
FROM dbo.gisBaseReference tbr --TransportCHE
    JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000020) frr
        ON frr.idfsReference = tbr.idfsGISBaseReference
           AND tbr.idfsGISBaseReference = @TransportCHE
    CROSS JOIN dbo.tstSite ts
    LEFT JOIN #FilteredRayonsTABLE frt
        ON frt.idfsRegion = @TransportCHE
           AND frt.idfsRayon = ts.idfsSite
    JOIN dbo.tstCustomizationPackage cp
        ON cp.idfCustomizationPackage = ts.idfCustomizationPackage
           AND cp.idfsCountry = @CountryID
    JOIN dbo.FN_GBL_Institution_Min(@LangID) fir
        ON fir.idfOffice = ts.idfOffice
           AND ts.intFlags = 1
    JOIN dbo.FN_GBL_Institution_Min('az-l') firAZ
        ON firAZ.idfOffice = ts.idfOffice
           AND ts.intFlags = 1
    JOIN dbo.trtBaseReference tbr1
        ON tbr1.idfsBaseReference = fir.idfsOfficeAbbreviation
    CROSS JOIN @DiagnosisTABLE AS dt
    JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019 /*rftDiagnosis*/) AS refDiag
        ON dt.[key] = refDiag.idfsReference
WHERE CAST(@Diagnosis AS NVARCHAR(MAX)) <> '<ItemList/>'
      AND (
              @isTLVL = 0
              or frt.idfsRayon is NOT NULL
              or @isWeb = 1
          );

DECLARE @EPI TABLE
(
    idfHumanCase BIGINT PRIMARY KEY,
    countEPI INT
)

INSERT INTO @EPI
(
    idfHumanCase,
    countEPI
)
SELECT hcs.idfHumanCase,
       COUNT(tap.idfActivityParameters) AS countEPI
FROM dbo.tlbHumanCase hcs
    INNER JOIN dbo.tlbObservation obs
        ON obs.idfObservation = hcs.idfEpiObservation
           AND obs.intRowStatus = 0
    INNER JOIN dbo.ffFormTemplate fft
        ON fft.idfsFormTemplate = obs.idfsFormTemplate
           AND idfsFormType = 10034011 /*Human Epi Investigations*/
    INNER JOIN dbo.ffParameterForTemplate pft
        ON pft.idfsFormTemplate = obs.idfsFormTemplate
           AND pft.intRowStatus = 0
    INNER JOIN dbo.ffParameter fp
        INNER JOIN dbo.ffParameterType fpt
            ON fpt.idfsParameterType = fp.idfsParameterType
               AND fpt.idfsReferenceType is NOT NULL
               AND fpt.intRowStatus = 0
        ON fp.idfsParameter = pft.idfsParameter
           AND fp.idfsFormType = 10034011 /*Human Epi Investigations*/
           --AND fp.idfsParameterType = 217140000000 /*Y_N_Unk*/
           AND fp.intRowStatus = 0
    INNER JOIN dbo.tlbActivityParameters tap
        ON tap.idfObservation = obs.idfObservation
           AND tap.idfsParameter = fp.idfsParameter
           AND (
                   fp.idfsParameterType = 217140000000 /*Y_N_Unk*/
                   AND CAST(tap.varValue AS NVARCHAR) in ( N'25460000000' /*pfv_YNU_yes*/, N'25640000000' /*pfv_YNU_no*/ )
                   or fp.idfsParameterType <> 217140000000
                      AND tap.varValue is NOT NULL
               )
           AND tap.intRowStatus = 0
WHERE hcs.intRowStatus = 0
      AND hcs.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/
      AND (
              @SDDate <= hcs.datFinalCaseClassificationDate
              AND hcs.datFinalCaseClassificationDate < @EDDate
          )
GROUP by hcs.idfHumanCase

DECLARE @CS TABLE
(
    idfHumanCase BIGINT PRIMARY KEY,
    countCS INT,
    blnUNI BIT
)

INSERT INTO @CS
(
    idfHumanCase,
    countCS,
    blnUNI
)
SELECT hcs.idfHumanCase,
       COUNT(tap.idfActivityParameters) AS countCS,
       fft.blnUNI
FROM dbo.tlbHumanCase hcs
    INNER JOIN dbo.tlbObservation obs
        ON obs.idfObservation = hcs.idfCSObservation
           AND obs.intRowStatus = 0
    INNER JOIN dbo.ffParameterForTemplate pft
        ON pft.idfsFormTemplate = obs.idfsFormTemplate
           AND pft.idfsEditMode = 10068003 /*Mandatory*/
           AND pft.idfsFormTemplate = obs.idfsFormTemplate
           AND pft.intRowStatus = 0
    INNER JOIN dbo.ffFormTemplate fft
        ON fft.idfsFormTemplate = pft.idfsFormTemplate
    LEFT JOIN dbo.ffParameter fp
        ON fp.idfsParameter = pft.idfsParameter
           AND (
                   fp.idfsParameterType = 217140000000 /*Y_N_Unk*/
                   or fp.idfsParameterType = 10071045 /*text - parString*/
               )
           AND fp.idfsFormType = 10034010 /*Human Clinical Signs*/
           AND fp.intRowStatus = 0
    INNER JOIN dbo.tlbActivityParameters tap
        ON tap.idfObservation = obs.idfObservation
           AND tap.idfsParameter = fp.idfsParameter
           AND tap.intRowStatus = 0
           AND (
                   (
                       CAST(tap.varValue AS NVARCHAR) = N'25460000000' /*pfv_YNU_yes,	Yes*/
                       AND fp.idfsParameterType = 217140000000 /*Y_N_Unk*/
                       AND fft.blnUNI = 0
                   )
                   or (
                          fft.blnUNI = 1
                          AND fp.idfsParameterType = 10071045 /*text - parString*/
                          AND CAST(tap.varValue AS NVARCHAR(500)) <> ''
                      )
               )
WHERE hcs.intRowStatus = 0
      AND hcs.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/
      AND (
              @SDDate <= hcs.datFinalCaseClassificationDate
              AND hcs.datFinalCaseClassificationDate < @EDDate
          )
GROUP by hcs.idfHumanCase,
         fft.blnUNI

--SELECT cs.idfHumanCase, cs.countCS, thc.strCaseID FROM @CS cs
--INNER JOIN tlbHumanCase thc
--ON thc.idfHumanCase = cs.idfHumanCase

--INNER JOIN tlbHuman th
--ON th.idfHuman = thc.idfHuman

--INNER JOIN tlbGeoLocation tgl
--ON tgl.idfGeoLocation = th.idfCurrentResidenceAddress
--AND tgl.idfsRayon = 1344420000000
--WHERE thc.strCaseID = 'HWEB00154695'

IF OBJECT_ID('tempdb.dbo.#CCP') is NOT NULL
    DROP TABLE #CCP
CREATE TABLE #CCP
(
    idfHumanCase BIGINT PRIMARY KEY,
    countCCP INT
)

INSERT INTO #CCP
(
    idfHumanCase,
    countCCP
)
SELECT tccp.idfHumanCase,
       COUNT(tccp.idfContactedCasePerson) AS CountContacts
FROM dbo.tlbContactedCasePerson tccp
    INNER JOIN dbo.tlbHumanCase thc
        ON thc.idfHumanCase = tccp.idfHumanCase
WHERE thc.intRowStatus = 0
      AND thc.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/
      AND (
              @SDDate <= thc.datFinalCaseClassificationDate
              AND thc.datFinalCaseClassificationDate < @EDDate
          )
      AND tccp.intRowStatus = 0
GROUP by tccp.idfHumanCase

IF OBJECT_ID('tempdb.dbo.#CTR') IS NOT NULL
    DROP TABLE #CTR
CREATE TABLE #CTR
(
    idfHumanCase BIGINT PRIMARY KEY,
    countCTR INT
)

INSERT INTO #CTR
(
    idfHumanCase,
    countCTR
)
SELECT m.idfHumanCase,
       COUNT(tt.idfTesting) AS CountTestResults
FROM dbo.tlbMaterial m
    INNER JOIN dbo.tlbTesting tt
        ON tt.idfMaterial = m.idfMaterial
           AND tt.intRowStatus = 0
           AND tt.idfsTestResult is NOT NULL
    INNER JOIN dbo.tlbHumanCase thc
        ON thc.idfHumanCase = m.idfHumanCase
WHERE thc.intRowStatus = 0
      AND thc.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/
      AND (
              @SDDate <= thc.datFinalCaseClassificationDate
              AND thc.datFinalCaseClassificationDate < @EDDate
          )
      AND m.intRowStatus = 0
      AND m.idfHumanCase is NOT NULL
GROUP by m.idfHumanCase

INSERT INTO #ReportCaseTABLE
(
    idfCase,
    IdRegion,
    strRegion,
    IdRayon,
    strRayon,
    strAZRayon,
    intRegionOrder,
    intRayonOrder,
    idfsShowDiagnosis,
    Diagnosis,
    idfsShowDiagnosisFromCase,

/*7(1)*/
    IndCaseStatus,
/*8(2)*/
    IndDateOfCompletionPaperFormDate,
/*9(3)*/
    IndNameOfEmployer,
/*11(5)*/
    IndCurrentLocation,
/*12(6)*/
    IndNotificationDate,
/*13(7)*/
    IndNotificationSentByName,
/*14(8)*/
    IndNotificationReceivedByFacility,
/*15(9)*/
    IndNotificationReceivedByName,
/*16(10)*/
    IndDateAndTimeOfTheEmergencyNotification,

/*18(11)*/
    IndInvestigationStartDate,
/*19(12)*/
    IndOccupationType,
/*20(13)*/
    IndInitialCaseClassification,
/*21(14)*/
    IndLocationOfExplosure,
/*22(15)*/
    IndAATherapyAdmBeforeSamplesCollection,
/*23(16)*/
    IndSamplesCollected,
/*24(17)*/
    IndAddcontact,
/*25(18)*/
    IndClinicalSigns,
/*26(19)*/
    IndEpidemiologicalLinksAndRiskFactors,

/*27(20)*/
    IndBasisOfDiagnosis,
/*28(21)*/
    IndOutcome,
/*29(22)*/
    IndISThisCaseRelatedToOutbreak,
/*30(23)*/
    IndEpidemiologistName,

/*32(24)*/
    IndResultsTestsConducted,
/*33(25)*/
    IndResultsResultObservation
)
SELECT hc.idfHumanCase AS idfCase,
       fdt.IdRegion,
       fdt.strRegion,
       fdt.IdRayon,
       fdt.strRayon,
       fdt.strAZRayon,
       fdt.intRegionOrder,
       fdt.intRayonOrder,
       ISNULL(fdt.IdDiagnosis, '') AS idfsShowDiagnosis,
       ISNULL(fdt.Diagnosis, '') AS Diagnosis,
       ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) AS idfsShowDiagnosisFromCase,

                                                      /*7(1)*/
       CASE
           WHEN hc.idfsCaseProgressStatus = 10109002 /*Closed*/
       THEN
               @Ind_N1_CaseStatus
           ELSE
               0.00
       END AS IndCaseStatus,

                                                      /*8(2)*/
       CASE
           WHEN ISNULL(hc.datCompletionPaperFormDate, '') <> '' THEN
               @Ind_N1_DateofCompletionPF
           ELSE
               0.00
       END AS IndDateOfCompletionPaperFormDate,

                                                      /*9(3)*/
       CASE
           WHEN ISNULL(h.strEmployerName, '') <> '' THEN
               @Ind_N1_NameofEmployer
           ELSE
               0.00
       END AS IndNameOfEmployer,

                                                      /*11(5)*/
       CASE
           WHEN ISNULL(hc.idfsHospitalizationStatus, 0) <> 0 THEN
               @Ind_N1_CurrentLocationPatient
           ELSE
               0.00
       END AS IndCurrentLocation,

                                                      /*12(6)*/
       CASE
           WHEN (
                    ISNULL(hc.datCompletionPaperFormDate, '') <> ''
                    AND hc.datCompletionPaperFormDate = hc.datNotificationDate
                )
                OR (
                       ISNULL(hc.datCompletionPaperFormDate, '') <> ''
                       AND ISNULL(hc.datNotificationDate, '') <> ''
                       AND CAST(hc.datNotificationDate - hc.datCompletionPaperFormDate AS FLOAT) < 1
                   ) THEN
               @Ind_N1_NotifDateTime
           WHEN ISNULL(hc.datCompletionPaperFormDate, '') <> ''
                AND ISNULL(hc.datNotificationDate, '') <> ''
                AND CAST(dbo.fnDateCutTime(hc.datNotificationDate) - dbo.fnDateCutTime(hc.datCompletionPaperFormDate) AS FLOAT)
                between 1 AND 2 THEN
               @Ind_N2_NotifDateTime
           WHEN ISNULL(hc.datCompletionPaperFormDate, '') <> ''
                AND ISNULL(hc.datNotificationDate, '') <> ''
                AND CAST(dbo.fnDateCutTime(hc.datNotificationDate) - dbo.fnDateCutTime(hc.datCompletionPaperFormDate) AS FLOAT) > 2 THEN
               @Ind_N3_NotifDateTime
           ELSE
               0.00
       END AS IndNotificationDate,


                                                      /*13(7)*/
       CASE
           WHEN ISNULL(hc.idfSentByPerson, '') <> '' THEN
               @Ind_N1_NotifSentByName
           ELSE
               0.00
       END AS IndNotificationSentByName,

                                                      /*14(8)*/
       CASE
           WHEN ISNULL(hc.idfReceivedByOffice, '') <> '' THEN
               @Ind_N1_NotifReceivedByFacility
           ELSE
               0.00
       END AS IndNotificationReceivedByFacility,

                                                      /*15(9)*/
       CASE
           WHEN ISNULL(hc.idfReceivedByPerson, '') <> '' THEN
               @Ind_N1_NotifReceivedByName
           ELSE
               0.00
       END AS IndNotificationReceivedByName,

                                                      /*16(10)*/
       CASE
           WHEN ISNULL(hc.datEnteredDate, '') <> ''
                AND ISNULL(hc.datNotificationDate, '') <> ''
                AND CAST(dbo.fnDateCutTime(hc.datEnteredDate) - dbo.fnDateCutTime(hc.datNotificationDate) AS FLOAT) < 1 THEN
               @Ind_N1_TimelinessOfDataEntryDTEN
           WHEN ISNULL(hc.datEnteredDate, '') <> ''
                AND ISNULL(hc.datNotificationDate, '') <> ''
                AND CAST(dbo.fnDateCutTime(hc.datEnteredDate) - dbo.fnDateCutTime(hc.datNotificationDate) AS FLOAT)
                between 1 AND 2 THEN
               @Ind_N2_TimelinessOfDataEntryDTEN
           WHEN ISNULL(hc.datEnteredDate, '') <> ''
                AND ISNULL(hc.datNotificationDate, '') <> ''
                AND CAST(dbo.fnDateCutTime(hc.datEnteredDate) - dbo.fnDateCutTime(hc.datNotificationDate) AS FLOAT) > 2 THEN
               @Ind_N3_TimelinessOfDataEntryDTEN
           ELSE
               0.00
       END AS IndDateAndTimeOfTheEmergencyNotification,

                                                      /*18(11)*/
       CASE
           WHEN ISNULL(hc.datInvestigationStartDate, '') <> ''
                AND ISNULL(hc.datNotificationDate, '') <> ''
                AND CAST(dbo.fnDateCutTime(hc.datNotificationDate) - dbo.fnDateCutTime(hc.datInvestigationStartDate) AS FLOAT) < 1 THEN
               @Ind_N1_DIStartingDTOfInvestigation
           WHEN ISNULL(hc.datInvestigationStartDate, '') <> ''
                AND ISNULL(hc.datNotificationDate, '') <> ''
                AND CAST(dbo.fnDateCutTime(hc.datNotificationDate) - dbo.fnDateCutTime(hc.datInvestigationStartDate) AS FLOAT)
                between 1 AND 2 THEN
               @Ind_N2_DIStartingDTOfInvestigation
           WHEN ISNULL(hc.datInvestigationStartDate, '') <> ''
                AND ISNULL(hc.datNotificationDate, '') <> ''
                AND CAST(dbo.fnDateCutTime(hc.datNotificationDate) - dbo.fnDateCutTime(hc.datInvestigationStartDate) AS FLOAT) > 2 THEN
               @Ind_N3_DIStartingDTOfInvestigation
           ELSE
               0.00
       END AS IndInvestigationStartDate,

                                                      /*19(12)*/
       CASE
           WHEN ISNULL(h.idfsOccupationType, '') <> '' THEN
               @Ind_N1_DIOccupation
           ELSE
               0.00
       END AS IndOccupationType,                      --20(13)
       CASE
           WHEN ISNULL(hc.idfsInitialCaseStatus, '') = 380000000 /*Suspect*/
                OR ISNULL(hc.idfsInitialCaseStatus, '') = 360000000 /*Probable CASE*/
       THEN
               @Ind_N1_CIInitCaseClassification
           ELSE
               0.00
       END AS IndInitialCaseClassification,           --21(14)
       CASE
           WHEN ISNULL(tgl.idfsRegion, 0) <> 0
                AND ISNULL(tgl.idfsRayon, 0) <> 0
                AND ISNULL(tgl.idfsSettlement, 0) <> 0 THEN
               @Ind_N1_CILocationOfExposure
           ELSE
               0.00
       END AS IndLocationOfExplosure,                 --22(15)
       CASE
           WHEN ISNULL(hc.idfsYNAntimicrobialTherapy, '') <> '' THEN
               @Ind_N1_CIAntibioticTherapyAdministratedBSC
           ELSE
               0.00
       END AS IndAATherapyAdmBeforeSamplesCollection, --23(16)


       CASE
           WHEN (
                    dt.blnLaboratoryConfirmation = 1
                    AND hc.idfsYNSpecimenCollected = 10100001 /*Yes*/
                )
                or dt.blnLaboratoryConfirmation = 0 THEN
               @Ind_N1_SamplesCollection
           ELSE
               0.00
       END AS IndSamplesCollected,                    -- 24(17)


       CASE
           WHEN CCP.CountCCP > 0 THEN
               @Ind_N1_ContactLisAddContact
           ELSE
               0.00
       END AS IndAddcontact,                          -- 25(18)
       CASE
           WHEN dt.intQuantityOfMandatoryFieldCSForDC = 0
                or (
                       dt.intQuantityOfMandatoryFieldCSForDC = 1
                       AND CS.blnUNI = 1
                       AND CS.countCS >= 1
                   )
                or (
                       dt.intQuantityOfMandatoryFieldCSForDC > 0
                       AND CS.blnUNI = 0
                       AND CS.countCS >= dt.intQuantityOfMandatoryFieldCSForDC
                   ) THEN
               @Ind_N1_CaseClassificationCS
           ELSE
               0.00
       END AS IndClinicalSigns,                       -- 26(19)
       CASE
           WHEN (
                    dt.intEPILincsAndFactors > 0
                    AND EPI.countEPI > 0.8 * dt.intEPILincsAndFactors
                )
                or dt.intEPILincsAndFactors = 0 THEN
               @Ind_N1_EpiLinksRiskFactorsByEpidCard
           WHEN dt.intEPILincsAndFactors > 0
                AND EPI.countEPI > 0.5 * dt.intEPILincsAndFactors
                AND EPI.countEPI <= 0.8 * dt.intEPILincsAndFactors THEN
               @Ind_N2_EpiLinksRiskFactorsByEpidCard
           WHEN dt.intEPILincsAndFactors > 0
                AND EPI.countEPI <= 0.5 * dt.intEPILincsAndFactors THEN
               @Ind_N3_EpiLinksRiskFactorsByEpidCard
           ELSE
               0.00
       END AS IndEpidemiologicalLinksAndRiskFactors,  --27(20)

       CASE
           WHEN ISNULL(hc.blnClinicalDiagBasis, '') = 1
                OR ISNULL(hc.blnLabDiagBasis, '') = 1
                OR ISNULL(hc.blnEpiDiagBasis, '') = 1 THEN
               @Ind_N1_FCCOBasisOfDiagnosis
           ELSE
               0.00
       END AS IndBasisOfDiagnosis,                    --30(23)
       CASE
           WHEN ISNULL(hc.idfsOutcome, '') <> '' THEN
               @Ind_N1_FCCOOutcome
           ELSE
               0.00
       END AS IndOutcome,                             --31(24)
       CASE
           WHEN ISNULL(hc.idfsYNRelatedToOutbreak, '') = 10100001 /*Yes*/
                OR ISNULL(hc.idfsYNRelatedToOutbreak, '') = 10100002 /*No*/
       THEN
               @Ind_N1_FCCOIsThisCaseRelatedToOutbreak
           ELSE
               0.00
       END AS IndISThisCaseRelatedToOutbreak,         --32(25)
       CASE
           WHEN ISNULL(hc.idfInvestigatedByPerson, '') <> '' THEN
               @Ind_N1_FCCOEpidemiologistName
           ELSE
               00.00
       END AS IndEpidemiologistName,                  --33(26)
       CASE
           WHEN (
                    dt.blnLaboratoryConfirmation = 1
                    AND hc.idfsYNTestsConducted = 10100001 /*Yes*/
                )
                or dt.blnLaboratoryConfirmation = 0 THEN
               @Ind_N1_ResultsOfLabTestsTestsConducted
           ELSE
               0.00
       END AS IndResultsTestsConducted,               --35(27)
       CASE
           WHEN (
                    dt.blnLaboratoryConfirmation = 1
                    AND CTR.CountCTR > 0
                )
                or dt.blnLaboratoryConfirmation = 0 THEN
               @Ind_N1_ResultsOfLabTestsResultObservation
           ELSE
               0.00
       END AS IndResultsResultObservation             --36(28)

FROM
(
    SELECT *
    FROM #ReportDataTABLE AS rt
    WHERE (
              rt.IdRegion = @RegionID
              or @RegionID is NULL
          )
          AND (
                  rt.IdRayon = @RayonID
                  or @RayonID is NULL
              )
) fdt
    LEFT JOIN dbo.tlbHumanCase hc
        JOIN dbo.tstSite ts
            ON ts.idfsSite = hc.idfsSite
        JOIN dbo.tlbHuman h
            ON hc.idfHuman = h.idfHuman
               AND h.intRowStatus = 0
        JOIN dbo.tlbGeoLocation gl
            ON h.idfCurrentResidenceAddress = gl.idfGeoLocation
               AND gl.intRowStatus = 0
        LEFT JOIN dbo.tlbGeoLocation tgl
            ON tgl.idfGeoLocation = hc.idfPointGeoLocation
               AND tgl.intRowStatus = 0
        ON hc.intRowStatus = 0
           AND hc.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/
           AND (
                   @SDDate <= hc.datFinalCaseClassificationDate
                   AND hc.datFinalCaseClassificationDate < @EDDate
               )
           AND (
                   (
                       ISNULL(ts.intFlags, 0) = 0
                       AND fdt.IdRegion = gl.idfsRegion
                       AND fdt.IdRayon = gl.idfsRayon
                   )
                   or (
                          ts.intFlags = 1
                          AND fdt.IdRegion = @TransportCHE
                          AND fdt.IdRayon = hc.idfsSite
                      )
               )
           AND fdt.IdDiagnosis = CASE
                                     WHEN CAST(@Diagnosis AS NVARCHAR(MAX)) <> '<ItemList/>' THEN
                                         ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)
                                     ELSE
                                         fdt.IdDiagnosis
                                 END
    LEFT JOIN @DiagnosisTABLE dt
        ON dt.[key] = ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)
    LEFT JOIN @CS AS CS
        ON CS.idfHumanCase = hc.idfHumanCase
    LEFT JOIN @EPI AS EPI
        ON EPI.idfHumanCase = hc.idfHumanCase
    LEFT JOIN #CCP AS CCP
        ON CCP.idfHumanCase = hc.idfHumanCase
    LEFT JOIN #CTR AS CTR
        ON CTR.idfHumanCase = hc.idfHumanCase

INSERT INTO #ReportCaseTABLE_CountForDiagnosis
SELECT COUNT(*) AS CountCase,
       IdRegion,
       IdRayon,
       idfsShowDiagnosis
FROM #ReportCaseTABLE rct
    LEFT JOIN @DiagnosisTABLE dt
        ON dt.[key] = rct.idfsShowDiagnosisFromCase
WHERE CAST(@Diagnosis AS NVARCHAR(MAX)) <> '<ItemList/>'
      AND rct.idfCase is NOT NULL
GROUP by IdRegion,
         strRegion,
         intRegionOrder,
         IdRayon,
         strRayon,
         intRayonOrder,
         idfsShowDiagnosis,
         Diagnosis,
         blnLaboratoryConfirmation,
         intQuantityOfMandatoryFieldCSForDC
UNION ALL
SELECT 0 AS CountCase,
       IdRegion,
       IdRayon,
       idfsShowDiagnosis
FROM #ReportCaseTABLE rct
    LEFT JOIN @DiagnosisTABLE dt
        ON dt.[key] = rct.idfsShowDiagnosisFromCase
WHERE CAST(@Diagnosis AS NVARCHAR(MAX)) <> '<ItemList/>'
      AND rct.idfCase is NULL
GROUP by IdRegion,
         strRegion,
         intRegionOrder,
         IdRayon,
         strRayon,
         intRayonOrder,
         idfsShowDiagnosis,
         Diagnosis,
         blnLaboratoryConfirmation,
         intQuantityOfMandatoryFieldCSForDC;
WITH ReportSumCaseTABLE
AS (SELECT rct.IdRegion,
           rct.strRegion,
           rct.IdRayon,
           rct.strRayon,
           rct.strAZRayon,
           rct.idfsShowDiagnosis,
           rct.Diagnosis,
           rct.intRegionOrder,
           rct.intRayonOrder,
           rct_count.CountCase AS intCaseCount,
           /*7(1)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndCaseStatus) / rct_count.CountCase
           END AS IndCaseStatus,
           /*8(2)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndDateOfCompletionPaperFormDate) / rct_count.CountCase
           END AS IndDateOfCompletionPaperFormDate,
           /*9(3)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndNameOfEmployer) / rct_count.CountCase
           END AS IndNameOfEmployer,
           /*11(5)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndCurrentLocation) / rct_count.CountCase
           END AS IndCurrentLocation,
           /*12(6)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndNotificationDate) / rct_count.CountCase
           END AS IndNotificationDate,
           /*13(7)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndNotificationSentByName) / rct_count.CountCase
           END AS IndNotificationSentByName,
           /*14(8)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndNotificationReceivedByFacility) / rct_count.CountCase
           END AS IndNotificationReceivedByFacility,
           /*15(9)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndNotificationReceivedByName) / rct_count.CountCase
           END AS IndNotificationReceivedByName,
           /*16(10)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndDateAndTimeOfTheEmergencyNotification) / rct_count.CountCase
           END AS IndDateAndTimeOfTheEmergencyNotification,
           /*18(11)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndInvestigationStartDate) / rct_count.CountCase
           END AS IndInvestigationStartDate,
           /*19(12)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndOccupationType) / rct_count.CountCase
           END AS IndOccupationType,
           /*20(13)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndInitialCaseClassification) / rct_count.CountCase
           END AS IndInitialCaseClassification,
           /*21(14)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndLocationOfExplosure) / rct_count.CountCase
           END AS IndLocationOfExplosure,
           /*22(15)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndAATherapyAdmBeforeSamplesCollection) / rct_count.CountCase
           END AS IndAATherapyAdmBeforeSamplesCollection,
           /*23(16)*/
           CASE
               WHEN rct_count.CountCase > 0 THEN
                   SUM(IndSamplesCollected) / rct_count.CountCase
               ELSE
                   0.00
           END AS IndSamplesCollected,
           /*24(17)*/
           CASE
               WHEN rct_count.CountCase > 0 THEN
                   SUM(IndAddcontact) / rct_count.CountCase
               ELSE
                   0.00
           END AS IndAddcontact,
           /*25(18)*/
           CASE
               WHEN rct_count.CountCase > 0 THEN
                   SUM(IndClinicalSigns) / rct_count.CountCase
               ELSE
                   0.00
           END AS IndClinicalSigns,
           /*26(19)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndEpidemiologicalLinksAndRiskFactors) / rct_count.CountCase
           END AS IndEpidemiologicalLinksAndRiskFactors,
           /*27(20)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndBasisOfDiagnosis) / rct_count.CountCase
           END AS IndBasisOfDiagnosis,
           /*28(21)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndOutcome) / rct_count.CountCase
           END AS IndOutcome,
           /*29(22)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndISThisCaseRelatedToOutbreak) / rct_count.CountCase
           END AS IndISThisCaseRelatedToOutbreak,
           /*30(23)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndEpidemiologistName) / rct_count.CountCase
           END AS IndEpidemiologistName,
           /*32(24)*/
           CASE
               WHEN rct_count.CountCase > 0 THEN
                   SUM(IndResultsTestsConducted) / rct_count.CountCase
               ELSE
                   0.00
           END AS IndResultsTestsConducted,
           /*33(25)*/
           CASE
               WHEN rct_count.CountCase > 0 THEN
                   SUM(IndResultsResultObservation) / rct_count.CountCase
               ELSE
                   0.00
           END AS IndResultsResultObservation
    FROM #ReportCaseTABLE rct
        INNER JOIN #ReportCaseTABLE_CountForDiagnosis rct_count
            ON rct.IdRegion = rct_count.IdRegion
               AND rct.IdRayon = rct_count.IdRayon
               AND rct.idfsShowDiagnosis = rct_count.idfsShowDiagnosis
        LEFT JOIN @DiagnosisTABLE dt
            ON dt.[key] = rct.idfsShowDiagnosisFromCase
    WHERE CAST(@Diagnosis AS NVARCHAR(MAX)) <> '<ItemList/>'
    GROUP by rct.IdRegion,
             rct.strRegion,
             rct.intRegionOrder,
             rct.IdRayon,
             rct.strRayon,
             rct.strAZRayon,
             rct.intRayonOrder,
             rct.idfsShowDiagnosis,
             rct.Diagnosis,
             dt.blnLaboratoryConfirmation,
             dt.intQuantityOfMandatoryFieldCSForDC,
             rct_count.CountCase
   ),
     ReportSumCaseTABLEForRayons
AS (SELECT IdRegion,
           strRegion,
           IdRayon,
           strRayon,
           strAZRayon,
           idfsShowDiagnosis,
           Diagnosis,
           intRegionOrder,
           intRayonOrder,
           /*7(1)*/
           SUM(IndCaseStatus) AS IndCaseStatus,
           /*8(2)*/
           SUM(IndDateOfCompletionPaperFormDate) AS IndDateOfCompletionPaperFormDate,
           /*9(3)*/
           SUM(IndNameOfEmployer) AS IndNameOfEmployer,
           /*11(5)*/
           SUM(IndCurrentLocation) AS IndCurrentLocation,
           /*12(6)*/
           SUM(IndNotificationDate) AS IndNotificationDate,
           /*13(7)*/
           SUM(IndNotificationSentByName) AS IndNotificationSentByName,
           /*14(8)*/
           SUM(IndNotificationReceivedByFacility) AS IndNotificationReceivedByFacility,
           /*15(9)*/
           SUM(IndNotificationReceivedByName) AS IndNotificationReceivedByName,
           /*16(10)*/
           SUM(IndDateAndTimeOfTheEmergencyNotification) AS IndDateAndTimeOfTheEmergencyNotification,

           /*18(11)*/
           SUM(IndInvestigationStartDate) AS IndInvestigationStartDate,
           /*19(12)*/
           SUM(IndOccupationType) AS IndOccupationType,
           /*20(13)*/
           SUM(IndInitialCaseClassification) AS IndInitialCaseClassification,
           /*21(14)*/
           SUM(IndLocationOfExplosure) AS IndLocationOfExplosure,
           /*22(15)*/
           SUM(IndAATherapyAdmBeforeSamplesCollection) AS IndAATherapyAdmBeforeSamplesCollection,

           /*23(16)*/
           CASE
               WHEN dt.blnLaboratoryConfirmation = 1 THEN
                   SUM(IndSamplesCollected)
               ELSE
                   0.00
           END AS IndSamplesCollected,
           CASE
               WHEN dt.blnLaboratoryConfirmation = 1 THEN
                   COUNT(idfCase)
               ELSE
                   0.00
           END AS CountIndSamplesCollected,
           /*24(17)*/
           SUM(IndAddcontact) AS IndAddcontact,
           /*25(18)*/
           CASE
               WHEN dt.intQuantityOfMandatoryFieldCSForDC > 0 THEN
                   SUM(IndClinicalSigns)
               ELSE
                   0.00
           END AS IndClinicalSigns,
           CASE
               WHEN dt.intQuantityOfMandatoryFieldCSForDC > 0 THEN
                   COUNT(idfCase)
               ELSE
                   0.00
           END AS CountIndClinicalSigns,
           /*26(19)*/
           SUM(IndEpidemiologicalLinksAndRiskFactors) AS IndEpidemiologicalLinksAndRiskFactors,

           /*27(20)*/
           SUM(IndBasisOfDiagnosis) AS IndBasisOfDiagnosis,
           /*28(21)*/
           SUM(IndOutcome) AS IndOutcome,
           /*29(22)*/
           SUM(IndISThisCaseRelatedToOutbreak) AS IndISThisCaseRelatedToOutbreak,
           /*30(23)*/
           SUM(IndEpidemiologistName) AS IndEpidemiologistName,
           /*32(24)*/
           CASE
               WHEN dt.blnLaboratoryConfirmation = 1 THEN
                   SUM(IndResultsTestsConducted)
               ELSE
                   0.00
           END AS IndResultsTestsConducted,
           CASE
               WHEN dt.blnLaboratoryConfirmation = 1 THEN
                   COUNT(idfCase)
               ELSE
                   0.00
           END AS CountIndResultsTestsConducted,
           /*33(25)*/
           CASE
               WHEN dt.blnLaboratoryConfirmation = 1 THEN
                   SUM(IndResultsResultObservation)
               ELSE
                   0.00
           END AS IndResultsResultObservation,
           CASE
               WHEN dt.blnLaboratoryConfirmation = 1 THEN
                   COUNT(idfCase)
               ELSE
                   0.00
           END AS CountIndResultsResultObservation,
           COUNT(idfCase) AS CountRecForDiag
    FROM #ReportCaseTABLE rct
        LEFT JOIN @DiagnosisTABLE dt
            ON dt.[key] = rct.idfsShowDiagnosisFromCase
    WHERE CAST(@Diagnosis AS NVARCHAR(MAX)) = '<ItemList/>'
    GROUP by IdRegion,
             strRegion,
             intRegionOrder,
             IdRayon,
             strRayon,
             strAZRayon,
             intRayonOrder,
             idfsShowDiagnosis,
             Diagnosis,
             blnLaboratoryConfirmation,
             intQuantityOfMandatoryFieldCSForDC
   ),
     ReportSumCaseTABLEForRayons_Summary
AS (SELECT IdRegion,
           strRegion,
           IdRayon,
           strRayon,
           strAZRayon,
           '' AS idfsShowDiagnosis,
           '' AS Diagnosis,
           intRegionOrder,
           intRayonOrder,
           SUM(CountRecForDiag) AS intCaseCount, -- UPDATE 29.11.14
                                                 /*7(1)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndCaseStatus) / SUM(CountRecForDiag)
           END AS IndCaseStatus,
                                                 /*8(2)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndDateOfCompletionPaperFormDate) / SUM(CountRecForDiag)
           END AS IndDateOfCompletionPaperFormDate,
                                                 /*9(3)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndNameOfEmployer) / SUM(CountRecForDiag)
           END AS IndNameOfEmployer,
                                                 /*11(5)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndCurrentLocation) / SUM(CountRecForDiag)
           END AS IndCurrentLocation,
                                                 /*12(6)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndNotificationDate) / SUM(CountRecForDiag)
           END AS IndNotificationDate,
                                                 /*13(7)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndNotificationSentByName) / SUM(CountRecForDiag)
           END AS IndNotificationSentByName,
                                                 /*14(8)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndNotificationReceivedByFacility) / SUM(CountRecForDiag)
           END AS IndNotificationReceivedByFacility,
                                                 /*15(9)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndNotificationReceivedByName) / SUM(CountRecForDiag)
           END AS IndNotificationReceivedByName,
                                                 /*16(10)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndDateAndTimeOfTheEmergencyNotification) / SUM(CountRecForDiag)
           END AS IndDateAndTimeOfTheEmergencyNotification,

                                                 /*18(11)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndInvestigationStartDate) / SUM(CountRecForDiag)
           END AS IndInvestigationStartDate,
                                                 /*19(12)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndOccupationType) / SUM(CountRecForDiag)
           END AS IndOccupationType,
                                                 /*20(13)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndInitialCaseClassification) / SUM(CountRecForDiag)
           END AS IndInitialCaseClassification,
                                                 /*21(14)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndLocationOfExplosure) / SUM(CountRecForDiag)
           END AS IndLocationOfExplosure,
                                                 /*22(15)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndAATherapyAdmBeforeSamplesCollection) / SUM(CountRecForDiag)
           END AS IndAATherapyAdmBeforeSamplesCollection,

                                                 /*23(16)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               WHEN SUM(CountIndSamplesCollected) = 0 THEN
                   0.00
               ELSE
                   SUM(IndSamplesCollected) / SUM(CountIndSamplesCollected)
           END AS IndSamplesCollected,
                                                 /*24(17)*/
           CASE
               WHEN SUM(CountRecForDiag) = 0 THEN
                   0.00
               ELSE
                   SUM(IndAddcontact) / SUM(CountRecForDiag)
           END AS IndAddcontact,
                                                 /*25(18)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               WHEN SUM(CountIndClinicalSigns) = 0 THEN
                   0.00
               ELSE
                   SUM(IndClinicalSigns) / SUM(CountIndClinicalSigns)
           END AS IndClinicalSigns,
                                                 /*26(19)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndEpidemiologicalLinksAndRiskFactors) / SUM(CountRecForDiag)
           END AS IndEpidemiologicalLinksAndRiskFactors,

                                                 /*27(20)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndBasisOfDiagnosis) / SUM(CountRecForDiag)
           END AS IndBasisOfDiagnosis,
                                                 /*28(21)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndOutcome) / SUM(CountRecForDiag)
           END AS IndOutcome,
                                                 /*29(22)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndISThisCaseRelatedToOutbreak) / SUM(CountRecForDiag)
           END AS IndISThisCaseRelatedToOutbreak,
                                                 /*30(23)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndEpidemiologistName) / SUM(CountRecForDiag)
           END AS IndEpidemiologistName,

                                                 /*32(24)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               WHEN SUM(CountIndResultsTestsConducted) = 0 THEN
                   0.00
               ELSE
                   SUM(IndResultsTestsConducted) / SUM(CountIndResultsTestsConducted)
           END AS IndResultsTestsConducted,
                                                 /*33(25)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               WHEN SUM(CountIndResultsResultObservation) = 0 THEN
                   0.00
               ELSE
                   SUM(IndResultsResultObservation) / SUM(CountIndResultsResultObservation)
           END AS IndResultsResultObservation
    FROM ReportSumCaseTABLEForRayons rct
    WHERE CAST(@Diagnosis AS NVARCHAR(MAX)) = '<ItemList/>'
    GROUP by IdRegion,
             strRegion,
             intRegionOrder,
             IdRayon,
             strRayon,
             strAZRayon,
             intRayonOrder --, CountRecForDiag -- UPDATE 29.11.14
   )
INSERT INTO @ReportTABLE
(
    idfsRegion,
    strRegion,
    intRegionOrder,
    idfsRayon,
    strRayon,
    strAZRayon,
    intRayonOrder,
    intCaseCount,
    idfsDiagnosis,
    strDiagnosis,
    dbl_1_Notification,
    dblCaseStatus,
    dblDateOfCompletionOfPaperForm,
    dblNameOfEmployer,
    dblCurrentLocationOfPatient,
    dblNotificationDateTime,
    dbldblNotificationSentByName,
    dblNotificationReceivedByFacility,
    dblNotificationReceivedByName,
    dblTimelinessofDataEntry,
    dbl_2_CaseInvestigation,
    dblDemographicInformationStartingDateTimeOfInvestigation,
    dblDemographicInformationOccupation,
    dblClinicalInformationInitialCaseClassification,
    dblClinicalInformationLocationOfExposure,
    dblClinicalInformationAntibioticAntiviralTherapy,
    dblSamplesCollectionSamplesCollected,
    dblContactListAddContact,
    dblCaseClassificationClinicalSigns,
    dblEpidemiologicalLinksAndRiskFactors,
    dblFinalCaseClassificationBasisOfDiagnosis,
    dblFinalCaseClassificationOutcome,
    dblFinalCaseClassificationIsThisCaseOutbreak,
    dblFinalCaseClassificationEpidemiologistName,
    dbl_3_TheResultsOfLaboratoryTests,
    dblTheResultsOfLaboratoryTestsTestsConducted,
    dblTheResultsOfLaboratoryTestsResultObservation,
    dblSummaryScoreByIndicators
)
SELECT IdRegion,
       strRegion,
       intRegionOrder,
       IdRayon,
       strRayon,
       strAZRayon,
       intRayonOrder,
       intCaseCount,
       idfsShowDiagnosis,
       Diagnosis,

/*6(1+2+3+5+6+8+9+10)*/
/*7(1)*/
       IndCaseStatus + /*8(2)*/ IndDateOfCompletionPaperFormDate + /*9(3)*/ IndNameOfEmployer
       + /*11(5)*/ IndCurrentLocation + /*12(6)*/ IndNotificationDate + /*13(7)*/ IndNotificationSentByName
       + /*14(8)*/ IndNotificationReceivedByFacility + /*15(9)*/ IndNotificationReceivedByName
       + /*16(10)*/ IndDateAndTimeOfTheEmergencyNotification AS IndNotification,

/*7(1)*/
       IndCaseStatus AS IndCaseStatus,
/*8(2)*/
       IndDateOfCompletionPaperFormDate AS IndDateOfCompletionPaperFormDate,
/*9(3)*/
       IndNameOfEmployer AS IndNameOfEmployer,
/*11(5)*/
       IndCurrentLocation AS IndCurrentLocation,
/*12(6)*/
       IndNotificationDate AS IndNotificationDate,
/*13(7)*/
       IndNotificationSentByName AS IndNotificationSentByName,
/*14(8)*/
       IndNotificationReceivedByFacility AS IndNotificationReceivedByFacility,
/*15(9)*/
       IndNotificationReceivedByName AS IndNotificationReceivedByName,
/*16(10)*/
       IndDateAndTimeOfTheEmergencyNotification AS IndDateAndTimeOfTheEmergencyNotification,


/*17(11..23)*/
/*18(11)*/
       IndInvestigationStartDate + /*19(12)*/ IndOccupationType + /*20(13)*/ IndInitialCaseClassification
       + /*21(14)*/ IndLocationOfExplosure + /*22(15)*/ IndAATherapyAdmBeforeSamplesCollection
       + /*23(16)*/ IndSamplesCollected + /*24(17)*/ IndAddcontact + /*25(18)*/ IndClinicalSigns
       + /*26(19)*/ IndEpidemiologicalLinksAndRiskFactors + /*27(20)*/ IndBasisOfDiagnosis + /*28(21)*/ IndOutcome
       + /*29(22)*/ IndISThisCaseRelatedToOutbreak + /*30(23)*/ IndEpidemiologistName AS IndCaseInvestigation,

/*18(11)*/
       IndInvestigationStartDate AS IndInvestigationStartDate,
/*19(12)*/
       IndOccupationType AS IndOccupationType,
/*20(13)*/
       IndInitialCaseClassification AS IndInitialCaseClassification,
/*21(14)*/
       IndLocationOfExplosure AS IndLocationOfExplosure,
/*22(15)*/
       IndAATherapyAdmBeforeSamplesCollection AS IndAATherapyAdmBeforeSamplesCollection,
/*23(16)*/
       IndSamplesCollected AS IndSamplesCollected,
/*24(17)*/
       IndAddcontact AS IndAddcontact,
/*25(18)*/
       IndClinicalSigns AS IndClinicalSigns,
/*26(19)*/
       IndEpidemiologicalLinksAndRiskFactors AS IndEpidemiologicalLinksAndRiskFactors,
/*27(20)*/
       IndBasisOfDiagnosis AS IndBasisOfDiagnosis,
/*28(21)*/
       IndOutcome AS IndOutcome,
/*29(22)*/
       IndISThisCaseRelatedToOutbreak AS IndISThisCaseRelatedToOutbreak,
/*30(23)*/
       IndEpidemiologistName AS IndEpidemiologistName,


/*31(24+25)*/
/*32(24)*/
       IndResultsTestsConducted + /*33(25)*/ IndResultsResultObservation AS IndResults,
/*32(24)*/
       IndResultsTestsConducted AS IndResultsTestsConducted,
/*33(25)*/
       IndResultsResultObservation AS IndResultsResultObservation,

/*34*/
/*7(1)*/
       IndCaseStatus + /*8(2)*/ IndDateOfCompletionPaperFormDate + /*9(3)*/ IndNameOfEmployer
       + /*11(5)*/ IndCurrentLocation + /*12(6)*/ IndNotificationDate + /*13(7)*/ IndNotificationSentByName
       + /*14(8)*/ IndNotificationReceivedByFacility + /*15(9)*/ IndNotificationReceivedByName
       + /*16(10)*/ IndDateAndTimeOfTheEmergencyNotification + /*18(11)*/ IndInvestigationStartDate
       + /*19(12)*/ IndOccupationType + /*20(13)*/ IndInitialCaseClassification + /*21(14)*/ IndLocationOfExplosure
       + /*22(15)*/ IndAATherapyAdmBeforeSamplesCollection + /*23(16)*/ IndSamplesCollected + /*24(17)*/ IndAddcontact
       + /*25(18)*/ IndClinicalSigns + /*26(19)*/ IndEpidemiologicalLinksAndRiskFactors
       + /*27(20)*/ IndBasisOfDiagnosis + /*28(21)*/ IndOutcome + /*29(22)*/ IndISThisCaseRelatedToOutbreak
       + /*30(23)*/ IndEpidemiologistName + /*32(24)*/ IndResultsTestsConducted
       + /*33(25)*/ IndResultsResultObservation AS SummaryScoreByIndicators
FROM ReportSumCaseTABLE
WHERE CAST(@Diagnosis AS NVARCHAR(MAX)) <> '<ItemList/>'
union all
SELECT IdRegion,
       strRegion,
       intRegionOrder,
       IdRayon,
       strRayon,
       strAZRayon,
       intRayonOrder,
       intCaseCount,
       idfsShowDiagnosis,
       Diagnosis,

/*6(1+2+3+5+6+8+9+10)*/
/*7(1)*/
       IndCaseStatus + /*8(2)*/ IndDateOfCompletionPaperFormDate + /*9(3)*/ IndNameOfEmployer
       + /*11(5)*/ IndCurrentLocation + /*12(6)*/ IndNotificationDate + /*13(7)*/ IndNotificationSentByName
       + /*14(8)*/ IndNotificationReceivedByFacility + /*15(9)*/ IndNotificationReceivedByName
       + /*16(10)*/ IndDateAndTimeOfTheEmergencyNotification AS IndNotification,

/*7(1)*/
       IndCaseStatus AS IndCaseStatus,
/*8(2)*/
       IndDateOfCompletionPaperFormDate AS IndDateOfCompletionPaperFormDate,
/*9(3)*/
       IndNameOfEmployer AS IndNameOfEmployer,
/*11(5)*/
       IndCurrentLocation AS IndCurrentLocation,
/*12(6)*/
       IndNotificationDate AS IndNotificationDate,
/*13(7)*/
       IndNotificationSentByName AS IndNotificationSentByName,
/*14(8)*/
       IndNotificationReceivedByFacility AS IndNotificationReceivedByFacility,
/*15(9)*/
       IndNotificationReceivedByName AS IndNotificationReceivedByName,
/*16(10)*/
       IndDateAndTimeOfTheEmergencyNotification AS IndDateAndTimeOfTheEmergencyNotification,

/*17(11..23)*/
/*18(11)*/
       IndInvestigationStartDate + /*19(12)*/ IndOccupationType + /*20(13)*/ IndInitialCaseClassification
       + /*21(14)*/ IndLocationOfExplosure + /*22(15)*/ IndAATherapyAdmBeforeSamplesCollection
       + /*23(16)*/ IndSamplesCollected + /*24(17)*/ IndAddcontact + /*25(18)*/ IndClinicalSigns
       + /*26(19)*/ IndEpidemiologicalLinksAndRiskFactors + /*27(20)*/ IndBasisOfDiagnosis + /*28(21)*/ IndOutcome
       + /*29(22)*/ IndISThisCaseRelatedToOutbreak + /*30(23)*/ IndEpidemiologistName AS IndCaseInvestigation,

/*18(11)*/
       IndInvestigationStartDate AS IndInvestigationStartDate,
/*19(12)*/
       IndOccupationType AS IndOccupationType,
/*20(13)*/
       IndInitialCaseClassification AS IndInitialCaseClassification,
/*21(14)*/
       IndLocationOfExplosure AS IndLocationOfExplosure,
/*22(15)*/
       IndAATherapyAdmBeforeSamplesCollection AS IndAATherapyAdmBeforeSamplesCollection,
/*23(16)*/
       IndSamplesCollected AS IndSamplesCollected,
/*24(17)*/
       IndAddcontact AS IndAddcontact,
/*25(18)*/
       IndClinicalSigns AS IndClinicalSigns,
/*26(19)*/
       IndEpidemiologicalLinksAndRiskFactors AS IndEpidemiologicalLinksAndRiskFactors,
/*27(20)*/
       IndBasisOfDiagnosis AS IndBasisOfDiagnosis,
/*28(21)*/
       IndOutcome AS IndOutcome,
/*29(22)*/
       IndISThisCaseRelatedToOutbreak AS IndISThisCaseRelatedToOutbreak,
/*30(23)*/
       IndEpidemiologistName AS IndEpidemiologistName,

/*31(24+25)*/
/*32(24)*/
       IndResultsTestsConducted + /*33(25)*/ IndResultsResultObservation AS IndResults,
/*32(24)*/
       IndResultsTestsConducted AS IndResultsTestsConducted,
/*33(25)*/
       IndResultsResultObservation AS IndResultsResultObservation,

/*34*/
/*7(1)*/
       IndCaseStatus + /*8(2)*/ IndDateOfCompletionPaperFormDate + /*9(3)*/ IndNameOfEmployer
       + /*11(5)*/ IndCurrentLocation + /*12(6)*/ IndNotificationDate + /*13(7)*/ IndNotificationSentByName
       + /*14(8)*/ IndNotificationReceivedByFacility + /*15(9)*/ IndNotificationReceivedByName
       + /*16(10)*/ IndDateAndTimeOfTheEmergencyNotification + /*18(11)*/ IndInvestigationStartDate
       + /*19(12)*/ IndOccupationType + /*20(13)*/ IndInitialCaseClassification + /*21(14)*/ IndLocationOfExplosure
       + /*22(15)*/ IndAATherapyAdmBeforeSamplesCollection + /*23(16)*/ IndSamplesCollected + /*24(17)*/ IndAddcontact
       + /*25(18)*/ IndClinicalSigns + /*26(19)*/ IndEpidemiologicalLinksAndRiskFactors
       + /*27(20)*/ IndBasisOfDiagnosis + /*28(21)*/ IndOutcome + /*29(22)*/ IndISThisCaseRelatedToOutbreak
       + /*30(23)*/ IndEpidemiologistName + /*32(24)*/ IndResultsTestsConducted
       + /*33(25)*/ IndResultsResultObservation AS SummaryScoreByIndicators
FROM ReportSumCaseTABLEForRayons_Summary
WHERE CAST(@Diagnosis AS NVARCHAR(MAX)) = '<ItemList/>'

SELECT -1 AS idfsBaseReference,
       -1 AS idfsRegion,
       '' AS strRegion,
       -1 AS intRegionOrder,
       -1 AS idfsRayon,
       '' AS strRayon,
       '' AS strAZRayon,
       -1 AS intRayonOrder,
       0 AS intCaseCount,
       -1 AS idfsDiagnosis,
       '' AS strDiagnosis,
       @Ind_1_Notification AS dbl_1_Notification,
       @Ind_N1_CaseStatus AS dblCaseStatus,
       @Ind_N1_DateofCompletionPF AS dblDateOfCompletionOfPaperForm,
       @Ind_N1_NameofEmployer AS dblNameOfEmployer,
       @Ind_N1_CurrentLocationPatient AS dblCurrentLocationOfPatient,
       @Ind_N1_NotifDateTime AS dblNotificationDateTime,
       @Ind_N1_NotifSentByName AS dbldblNotificationSentByName,
       @Ind_N1_NotifReceivedByFacility AS dblNotificationReceivedByFacility,
       @Ind_N1_NotifReceivedByName AS dblNotificationReceivedByName,
       @Ind_N1_TimelinessOfDataEntryDTEN AS dblTimelinessofDataEntry,
       @Ind_2_CaseInvestigation AS dbl_2_CaseInvestigation,
       @Ind_N1_DIStartingDTOfInvestigation AS dblDemographicInformationStartingDateTimeOfInvestigation,
       @Ind_N1_DIOccupation AS dblDemographicInformationOccupation,
       @Ind_N1_CIInitCaseClassification AS dblClinicalInformationInitialCaseClassification,
       @Ind_N1_CILocationOfExposure AS dblClinicalInformationLocationOfExposure,
       @Ind_N1_CIAntibioticTherapyAdministratedBSC AS dblClinicalInformationAntibioticAntiviralTherapy,
       @Ind_N1_SamplesCollection AS dblSamplesCollectionSamplesCollected,
       @Ind_N1_ContactLisAddContact AS dblContactListAddContact,
       @Ind_N1_CaseClassificationCS AS dblCaseClassificationClinicalSigns,
       @Ind_N1_EpiLinksRiskFactorsByEpidCard AS dblEpidemiologicalLinksAndRiskFactors,
       @Ind_N1_FCCOBasisOfDiagnosis AS dblFinalCaseClassificationBasisOfDiagnosis,
       @Ind_N1_FCCOOutcome AS dblFinalCaseClassificationOutcome,
       @Ind_N1_FCCOIsThisCaseRelatedToOutbreak AS dblFinalCaseClassificationIsThisCaseOutbreak,
       @Ind_N1_FCCOEpidemiologistName AS dblFinalCaseClassificationEpidemiologistName,
       @Ind_3_TheResultsOfLabTestsAndInterpretation AS dbl_3_TheResultsOfLaboratoryTests,
       @Ind_N1_ResultsOfLabTestsTestsConducted AS dblTheResultsOfLaboratoryTestsTestsConducted,
       @Ind_N1_ResultsOfLabTestsResultObservation AS dblTheResultsOfLaboratoryTestsResultObservation,
       @Ind_1_Notification + @Ind_2_CaseInvestigation + @Ind_3_TheResultsOfLabTestsAndInterpretation AS dblSummaryScoreByIndicators
UNION ALL
SELECT rt.idfsBaseReference,
       rt.idfsRegion,
       rt.strRegion,
       rt.intRegionOrder,
       rt.idfsRayon,
       rt.strRayon,
       rt.strAZRayon,
       rt.intRayonOrder,
       rt.intCaseCount,
       rt.idfsDiagnosis,
       rt.strDiagnosis,

/*6(1+2+3+5+6+8+9+10)*/
       rt.dbl_1_Notification,
/*7(1)*/
       rt.dblCaseStatus,
/*8(2)*/
       rt.dblDateOfCompletionOfPaperForm,
/*9(3)*/
       rt.dblNameOfEmployer,
/*11(5)*/
       rt.dblCurrentLocationOfPatient,
/*12(6)*/
       rt.dblNotificationDateTime,
/*13(7)*/
       rt.dbldblNotificationSentByName,
/*14(8)*/
       rt.dblNotificationReceivedByFacility,
/*15(9)*/
       rt.dblNotificationReceivedByName,
/*16(10)*/
       rt.dblTimelinessofDataEntry,

/*17(11..23)*/
       rt.dbl_2_CaseInvestigation,
/*18(11)*/
       rt.dblDemographicInformationStartingDateTimeOfInvestigation,
/*19(12)*/
       rt.dblDemographicInformationOccupation,
/*20(13)*/
       rt.dblClinicalInformationInitialCaseClassification,
/*21(14)*/
       rt.dblClinicalInformationLocationOfExposure,
/*22(15)*/
       rt.dblClinicalInformationAntibioticAntiviralTherapy,
/*23(16)*/
       rt.dblSamplesCollectionSamplesCollected,
/*24(17)*/
       rt.dblContactListAddContact,
/*25(18)*/
       rt.dblCaseClassificationClinicalSigns,
/*26(19)*/
       rt.dblEpidemiologicalLinksAndRiskFactors,
/*27(20)*/
       rt.dblFinalCaseClassificationBasisOfDiagnosis,
/*28(21)*/
       rt.dblFinalCaseClassificationOutcome,
/*29(22)*/
       rt.dblFinalCaseClassificationIsThisCaseOutbreak,
/*30(23)*/
       rt.dblFinalCaseClassificationEpidemiologistName,

/*31(24+25)*/
       rt.dbl_3_TheResultsOfLaboratoryTests,
/*32(24)*/
       rt.dblTheResultsOfLaboratoryTestsTestsConducted,
/*33(25)*/
       rt.dblTheResultsOfLaboratoryTestsResultObservation,

/*35*/
       rt.dblSummaryScoreByIndicators
FROM @ReportTABLE rt
ORDER BY intRegionOrder,
         strRegion,
         strRayon,
         idfsDiagnosis
GO
PRINT N'Altering Procedure [Report].[USP_REP_HUM_TuberculosisCasesTested]...';


GO
--*************************************************************************
-- Name 				: report.USP_REP_HUM_TuberculosisCasesTested
-- DescriptiON			: 
--          
-- Author               : Srini Goli
--
-- Revision History:
-- Name                Date       Change Detail
-- ------------------- ---------- ----------------------------------------
-- Stephen Long        05/08/2023 Changed from institution repair to min.
--
-- Testing code:
 /*

exec [report].[USP_REP_HUM_TuberculosisCasesTested] 'en',  N'2016, 2014', 12, 12, 7721290000000
 
exec [report].[USP_REP_HUM_TuberculosisCasesTested] 'en',  N'2016, 2014', 1, 12, null
 
exec [report].[USP_REP_HUM_TuberculosisCasesTested] @LangID='en',@StrYear='2014, 2013, 2012, 2011',@FromMonth=NULL,@ToMonth=NULL,@DiagnosisId=NULL,@SiteID=871

exec [report].[USP_REP_HUM_TuberculosisCasesTested] @LangID='en',@StrYear='2016,2015, 2013, 2012, 2010',@FromMonth=NULL,@ToMonth=NULL,@DiagnosisId=7721290000000,@SiteID=871  
*/ 
 ALTER PROCEDURE [Report].[USP_REP_HUM_TuberculosisCasesTested]
 	@LangID				as varchar(36),
 	@StrYear			as nvarchar(max),
 	@FromMonth			as int = null,
 	@ToMonth			as int = null,
 	@DiagnosisId		as bigint = null,
 	@SiteID				as bigint = null
 AS
 BEGIN
 	set @FromMonth = isnull(@FromMonth,1)
	set @ToMonth = isnull(@ToMonth,12)
	
	declare	@ReportTable	table
	(	
		idfsRegion				bigint not null,
	
 		idfsRayon				bigint not null,
 		strRayonName			nvarchar(2000) not null,
 		
 		blnIsTransportCHE		bit not null default(0),
 		 		
 		strDiagnosisName		nvarchar(2000) null,
 		
 		intNumberOfCases_1		int default(0),
 		intTestedForHIV_1		int default(0),

 		intNumberOfCases_2		int default(0),
 		intTestedForHIV_2		int default(0),

 		intNumberOfCases_3		int default(0),
 		intTestedForHIV_3		int default(0),

 		intNumberOfCases_4		int default(0),
 		intTestedForHIV_4		int default(0),

 		intNumberOfCases_5		int default(0),
 		intTestedForHIV_5		int default(0),
 		
 		intRegionOrder			int,
 		primary key (idfsRayon)
	)
 	
 	declare @DiagnosisTable table (
 			idfsDiagnosis	bigint 	not null primary key	
 	)
 	
 	declare @Years table (
 		intOrder		int not null identity(1,1) primary key,
 		intYear			int not null,
 		datStartDate	datetime,
 		datEndDate		datetime
 	)
 	
	declare
		 @CountryID					bigint,
		 @idfsLanguage				bigint,
		 @idfsCustomReportType		bigint,
		 
		 @idfsRegionBaku			bigint,
		 @idfsRegionOtherRayons		bigint,
		 @idfsRegionNakhichevanAR	bigint,
		 @TransportCHE				bigint,
		 
		 @strDiagnosisName			nvarchar(2000),
		 @Tuberculosis				nvarchar(2000),
		 
		 @iYears					int,
		 
		 @intYear					int,
		 @datStartDate				datetime, 
		 @datEndDate				datetime,
		 
		 @idfsSample_Blood			bigint
 	
 	
	set @CountryID = 170000000

	SET @idfsLanguage = dbo.FN_GBL_LanguageCode_GET  (@LangID)		  

	SET @idfsCustomReportType = 10290041 --Report on Tuberculosis cases tested for HIV
 	
 	
	--1344330000000 --Baku
	select @idfsRegionBaku = tbra.idfsGISBaseReference
	from dbo.trtGISBaseReferenceAttribute tbra
		inner join	trtAttributeType at
		on			at.strAttributeTypeName = N'AZ Region'
	where cast(tbra.varValue as nvarchar(100)) = N'Baku'

	--1344340000000 --Other rayons
	select @idfsRegionOtherRayons = tbra.idfsGISBaseReference
	from dbo.trtGISBaseReferenceAttribute tbra
		inner join	dbo.trtAttributeType at
		on			at.strAttributeTypeName = N'AZ Region'
	where cast(tbra.varValue as nvarchar(100)) = N'Other rayons'


	--1344350000000 --Nakhichevan AR
	select @idfsRegionNakhichevanAR = tbra.idfsGISBaseReference
	from dbo.trtGISBaseReferenceAttribute tbra
		inner join	dbo.trtAttributeType at
		on			at.strAttributeTypeName = N'AZ Region'
	where cast(tbra.varValue as nvarchar(100)) = N'Nakhichevan AR'    
	
 	select @TransportCHE = frr.idfsReference
 	from dbo.FN_GBL_GIS_ReferenceRepair('en', 19000020) frr
 	where frr.name =  'Transport CHE'
 	print @TransportCHE		
	

	--7721530000000 --Blood
	select @idfsSample_Blood = tbra.idfsBaseReference
	from dbo.trtBaseReferenceAttribute tbra
		inner join	dbo.trtAttributeType at
		on			at.strAttributeTypeName = N'Sample type'
		
		inner join dbo.trtBaseReferenceAttribute tbra2
			inner join dbo.trtAttributeType tat2
			on tat2.idfAttributeType = tbra2.idfAttributeType
			and tat2.strAttributeTypeName = 'attr_part_in_report'
		on tbra.idfsBaseReference = tbra2.idfsBaseReference
		and tbra2.varValue = @idfsCustomReportType 
	where cast(tbra.varValue as nvarchar(100)) = N'Blood'
 	
 	--Tuberculosis
 	select @Tuberculosis = tsnt.strTextString
 	from dbo.trtBaseReference tbr 
 		inner join dbo.trtStringNameTranslation tsnt
 		on tsnt.idfsBaseReference = tbr.idfsBaseReference
 		and tsnt.idfsLanguage = @idfsLanguage
 	where tbr.idfsReferenceType = 19000132 /*additional report text*/
 	and tbr.strDefault = 'Tuberculosis'
 	
 	select @strDiagnosisName = fr.name
 	from dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) fr
 	where fr.idfsReference = @DiagnosisId
 	
 	set @strDiagnosisName = isnull(@strDiagnosisName, @Tuberculosis)

 	insert into @DiagnosisTable (idfsDiagnosis)
 	select d.idfsDiagnosis
	from dbo.trtDiagnosis d
	  inner join dbo.trtDiagnosisToGroupForReportType dgrt
	  on dgrt.idfsDiagnosis = d.idfsDiagnosis
	  and dgrt.idfsCustomReportType = @idfsCustomReportType
	  
	  inner join dbo.trtReportDiagnosisGroup dg
	  on dgrt.idfsReportDiagnosisGroup = dg.idfsReportDiagnosisGroup
	  and dg.intRowStatus = 0 and dg.strDiagnosisGroupAlias = 'DG_Tuberculosis'
	where d.intRowStatus = 0
		and (d.idfsDiagnosis = @DiagnosisId or @DiagnosisId is null)
 	
 	
 	--exec sp_xml_preparedocument @iYears output, @YearXml
	insert into @Years (
		intYear
	) 
	select 
		CAST(cn.[Value] AS BIGINT)
	from report.FN_GBL_SYS_SplitList(@StrYear,1,',') cn	
	ORDER BY CAST(cn.[Value] AS BIGINT) ASC
	
	--select @FromMonth as [@FromMonth], @ToMonth as [@ToMonth]
	update years
	set
		years.datStartDate	= dateadd(month, -1, dateadd(month, @FromMonth, cast(cast(years.intYear as varchar(4)) + '0101' as datetime))),
		years.datEndDate	= dateadd(month, @ToMonth, cast(cast(years.intYear as varchar(4)) + '0101' as datetime))
	from @Years years
	
	
	insert into @ReportTable
	(
		  strDiagnosisName
		, blnIsTransportCHE
		, idfsRegion
		, idfsRayon
		, strRayonName	

		, intNumberOfCases_1
 		, intTestedForHIV_1
 		
 		, intNumberOfCases_2
 		, intTestedForHIV_2

 		, intNumberOfCases_3
 		, intTestedForHIV_3

 		, intNumberOfCases_4
 		, intTestedForHIV_4

 		, intNumberOfCases_5
 		, intTestedForHIV_5
 		
 		,intRegionOrder
	)
	select
		@strDiagnosisName,
		0,
		ray.idfsRegion,
		ray.idfsRayon,

		isnull(gsnt_ray.strTextString, gbr_ray.strDefault),

		0,
		0,
		
		0,
		0,

		0,
		0,

		0,
		0,

		0,
		0,	
							
		case ray.idfsRegion
		  when @idfsRegionBaku --Baku
		  then 1
		  
		  when @idfsRegionOtherRayons --Other rayons
		  then 2
		  
		  when @idfsRegionNakhichevanAR --Nakhichevan AR
		  then 3
		  
		  else 0
		 end 
  
	from report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) ray
      inner join report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) reg
      on ray.idfsRegion = reg.idfsRegion
      and reg.intRowStatus = 0
      and reg.idfsCountry = @CountryID
      
      inner join dbo.gisBaseReference gbr_ray
      on gbr_ray.idfsGISBaseReference = ray.idfsRayon
      and gbr_ray.intRowStatus = 0
      
      inner join dbo.gisStringNameTranslation gsnt_ray
      on gsnt_ray.idfsGISBaseReference = gbr_ray.idfsGISBaseReference
      and gsnt_ray.idfsLanguage = @idfsLanguage
      and gsnt_ray.intRowStatus = 0
	where ray.intRowStatus = 0 	
 	
 	
 	
	insert into @ReportTable
 	(
		  strDiagnosisName
		, blnIsTransportCHE
		, idfsRegion
		, idfsRayon
		, strRayonName	

		, intNumberOfCases_1
 		, intTestedForHIV_1
 		
 		, intNumberOfCases_2
 		, intTestedForHIV_2

 		, intNumberOfCases_3
 		, intTestedForHIV_3

 		, intNumberOfCases_4
 		, intTestedForHIV_4

 		, intNumberOfCases_5
 		, intTestedForHIV_5
 		
 		,intRegionOrder

	)
	select
		@strDiagnosisName,
		1,
		reg.idfsGISBaseReference,
		ray.idfsSite,
								
		i.AbbreviatedName AS [name],
    
		0,
		0,
		
		0,
		0,

		0,
		0,

		0,
		0,

		0,
		0,
    
		4
  
	from dbo.tstSite ray
		join dbo.gisBaseReference reg
		on reg.idfsGISBaseReference = @TransportCHE

		inner join dbo.gisStringNameTranslation gsnt_reg
		on gsnt_reg.idfsGISBaseReference = reg.idfsGISBaseReference
		and gsnt_reg.idfsLanguage = @idfsLanguage
		and gsnt_reg.intRowStatus = 0

		inner join	dbo.FN_GBL_Institution_Min(@LangID) as i  
		on	ray.idfOffice = i.idfOffice  

	where ray.intRowStatus = 0		
	and ray.intFlags = 1				 	
 	
   

	declare	@ReportCaseTable	table
	(	idfCase					bigint not null primary key,
		intYear					int not null,
		blnTestedforHIV			int not null default(0),
		idfsRayon				bigint not null
	)

	declare cur cursor local forward_only for
	select years.intYear, years.datStartDate, years.datEndDate from @Years years
	
	open cur
	
	fetch next from cur into @intYear, @datStartDate, @datEndDate
	
	while @@FETCH_STATUS = 0
	begin
		
		insert into	@ReportCaseTable
		(	
			idfCase,
			intYear,
			blnTestedforHIV,
			idfsRayon
		)
		select
			hc.idfHumanCase AS idfCase,
			year(datFinalCaseClassificationDate) as intYear,
			0, --case when tested.idfTesting is not null then 1 else 0 end  as blnTestedforHIV,			
			case when ts.idfsSite is not null then ts.idfsSite else gl.idfsRayon  end /*rayon CR*/
		from dbo.tlbHumanCase hc
			left join @ReportCaseTable rct
			on hc.idfHumanCase = rct.idfCase
			
			inner join dbo.tlbHuman h
				left join dbo.tlbGeoLocation gl
				on h.idfCurrentResidenceAddress = gl.idfGeoLocation 
				and gl.intRowStatus = 0
			on hc.idfHuman = h.idfHuman 
			and	h.intRowStatus = 0
			
			--inner join @Years years
			--on years.intYear = year(hc.datFinalCaseClassificationDate)
				
			inner join @DiagnosisTable fdt
			on	fdt.idfsDiagnosis = COALESCE(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)
					
			left join dbo.tstSite ts
			on ts.idfsSite = hc.idfsSite
			and ts.intRowStatus = 0
			and ts.intFlags = 1
			
			--outer apply (
			--	select top 1 t.idfTesting
			--	from tlbMaterial m
			--		inner join tlbTesting t
			--			inner join trtTestTypeForCustomReport ttcr --ifa for HIV
			--			on ttcr.idfsTestName = t.idfsTestName
			--			and ttcr.idfsCustomReportType = @idfsCustomReportType
			--		on t.idfMaterial = m.idfMaterial
			--		and t.intRowStatus = 0
			--		and t.idfsTestStatus in (10001001 /*Final*/, 10001006 /*Amended*/)
			--	where m.idfHuman = h.idfHuman
			--	and m.intRowStatus = 0	
			--	and m.idfsSampleType = @idfsSample_Blood
			--	order by t.idfTesting
			--) tested
		    			
		where		
			hc.datFinalCaseClassificationDate is not null and
			(	@datStartDate <= hc.datFinalCaseClassificationDate
							and hc.datFinalCaseClassificationDate < @datEndDate				
			) 
			and ((gl.idfsRegion is not null and gl.idfsRayon is not null) or (ts.idfsSite is not null))
			and hc.intRowStatus = 0 
			and hc.idfsFinalCaseStatus = 350000000 /*Confirmed Case*/		
			and rct.idfCase is null
		
		
		fetch next from cur into @intYear, @datStartDate, @datEndDate
	end
	
	close cur
	deallocate cur
	
	

	update rct set 
		rct.blnTestedforHIV = case when t.idfTesting is not null then 1 else 0 end	
	from @ReportCaseTable rct
		inner join dbo.tlbHumanCase hc
		on rct.idfCase = hc.idfHumanCase
		
		inner join dbo.tlbHuman h
		on h.idfHuman = hc.idfHuman
		
		inner join dbo.tlbMaterial m
			inner join dbo.tlbTesting t
				inner join dbo.trtTestTypeForCustomReport ttcr --ifa for HIV
				on ttcr.idfsTestName = t.idfsTestName
				and ttcr.idfsCustomReportType = @idfsCustomReportType
			on t.idfMaterial = m.idfMaterial
			and t.intRowStatus = 0
			and t.idfsTestStatus in (10001001 /*Final*/, 10001006 /*Amended*/)
		on m.idfHuman = h.idfHuman
		and m.intRowStatus = 0	
		and m.idfsSampleType = @idfsSample_Blood




	--Total
	declare	@ReportCaseTotalValuesTable	table
	(	intTotal				numeric(8,4) not null,
		intTotalTestedForHIV	numeric(8,4) not null,
		idfsRayon				bigint not null,
		intYear					int not null,
		primary key	(
		  idfsRayon asc,
		  intYear asc
		)
	)

	insert into	@ReportCaseTotalValuesTable
	(	
		intTotal,
		intTotalTestedForHIV,
		idfsRayon,
		intYear
	)
	select	
				count(fct.idfCase),
				sum(fct.blnTestedforHIV),
				idfsRayon,
				fct.intYear
	from		@ReportCaseTable fct
	group by	fct.idfsRayon, fct.intYear

	


	update rt set
		rt.intNumberOfCases_1			= isnull(rct1.intTotal, 0),
		rt.intTestedForHIV_1			= isnull(rct1.intTotalTestedForHIV, 0),
		
		rt.intNumberOfCases_2			= isnull(rct2.intTotal, 0),
		rt.intTestedForHIV_2			= isnull(rct2.intTotalTestedForHIV, 0),

		rt.intNumberOfCases_3			= isnull(rct3.intTotal, 0),
		rt.intTestedForHIV_3			= isnull(rct3.intTotalTestedForHIV, 0),

		rt.intNumberOfCases_4			= isnull(rct4.intTotal, 0),
		rt.intTestedForHIV_4			= isnull(rct4.intTotalTestedForHIV, 0),

		rt.intNumberOfCases_5			= isnull(rct5.intTotal, 0),
		rt.intTestedForHIV_5			= isnull(rct5.intTotalTestedForHIV, 0)
		
	from @ReportTable rt
		left join @ReportCaseTotalValuesTable rct1
			inner join @Years y1
			on y1.intYear = rct1.intYear
			and y1.intOrder = 1
		on rct1.idfsRayon = rt.idfsRayon
	
	
		left join @ReportCaseTotalValuesTable rct2
			inner join @Years y2
			on y2.intYear = rct2.intYear
			and y2.intOrder = 2
		on rct2.idfsRayon = rt.idfsRayon
	
		left join @ReportCaseTotalValuesTable rct3
			inner join @Years y3
			on y3.intYear = rct3.intYear
			and y3.intOrder = 3
		on rct3.idfsRayon = rt.idfsRayon	

		left join @ReportCaseTotalValuesTable rct4
			inner join @Years y4
			on y4.intYear = rct4.intYear
			and y4.intOrder = 4
		on rct4.idfsRayon = rt.idfsRayon	

		left join @ReportCaseTotalValuesTable rct5
			inner join @Years y5
			on y5.intYear = rct5.intYear
			and y5.intOrder = 5
		on rct5.idfsRayon = rt.idfsRayon	

	---- total
	
	--insert into @ReportTable
	--	(
	--		idfsRegion, 
	--		idfsRayon, 
	--		strRayonName, 
	--		strDiagnosisName, 
			
	--		intNumberOfCases_1,
	--		intTestedForHIV_1, 
	--		intPercentRegistered_1, 
			
	--		intNumberOfCases_2,
	--		intTestedForHIV_2, 
	--		intPercentRegistered_2, 
			
	--		intNumberOfCases_3,
	--		intTestedForHIV_3, 
	--		intPercentRegistered_3, 
			
	--		intNumberOfCases_4,
	--		intTestedForHIV_4, 
	--		intPercentRegistered_4, 
			
	--		intNumberOfCases_5,
	--		intTestedForHIV_5, 
	--		intPercentRegistered_5, 
			
	--		intRegionOrder
	--	)
	--select	
	--		-1,
	--		-1,
	--		'Total',
	--		rt.strDiagnosisName,
			
	--		sum(intNumberOfCases_1),
	--		sum(intTestedForHIV_1), 
	--		case when sum(intNumberOfCases_1) <> 0 then sum(intTestedForHIV_1)/sum(intNumberOfCases_1)*1.0000 else 0 end, 
			
	--		sum(intNumberOfCases_2),
	--		sum(intTestedForHIV_2), 
	--		case when sum(intNumberOfCases_2) <> 0 then sum(intTestedForHIV_2)/sum(intNumberOfCases_2)*1.0000 else 0 end, 
			
	--		sum(intNumberOfCases_3),
	--		sum(intTestedForHIV_3), 
	--		case when sum(intNumberOfCases_3) <> 0 then sum(intTestedForHIV_3)/sum(intNumberOfCases_3)*1.0000 else 0 end, 
			
	--		sum(intNumberOfCases_4),
	--		sum(intTestedForHIV_4), 
	--		case when sum(intNumberOfCases_4) <> 0 then sum(intTestedForHIV_4)/sum(intNumberOfCases_4)*1.0000 else 0 end, 
			
	--		sum(intNumberOfCases_5),
	--		sum(intTestedForHIV_5), 
	--		case when sum(intNumberOfCases_5) <> 0 then sum(intTestedForHIV_5)/sum(intNumberOfCases_5)*1.0000 else 0 end, 
			
	--		999
			
	--from		@ReportTable rt
	--group by rt.strDiagnosisName
		
	--================================================================================= 
 	select * from @ReportTable
 	order by intRegionOrder, strRayonName
 END
GO
PRINT N'Altering Procedure [Report].[USP_REP_HumCaseForm_GET]...';


GO
--*************************************************************************
-- Name 				: report.USP_REP_HumCaseForm_GET
-- DescriptiON			: Select data for Human Case Investigation report.
--          
-- Author               : Mark Wilson
-- Revision History
-- Name			       Date       Change Detail
-- ------------------- ---------- ----------------------------------------
-- Mark Wilson	       03-23-2022 Initial E7 version
-- Srini Goli          10/20/2022 Updated SentByOffice
-- Stephen Long        05/08/2023 Changed from institution repair to min.
--
-- Testing code:
/*

--Example of a call of procedure:

exec report.USP_REP_HumCaseForm_GET @LangID=N'en-US',@ObjID=121490

*/
ALTER PROCEDURE [Report].[USP_REP_HumCaseForm_GET]
(
    @LangID AS NVARCHAR(10),
    @ObjID AS BIGINT = NULL
)
AS
SELECT HC.idfCase AS idfCase,
       HC.strLocalIdentifier AS LocalID,
       SentByOfficeRef.LongName AS OrgSentNotification,
       InvestigatedByOfficeRef.LongName AS OrgConductInv,
       LRegistration.AdminLevel2Name AS RegRegion,
       LRegistration.AdminLevel3Name AS RegRayon,
       LRegistration.AdminLevel4Name AS RegVillage,
       tRegistratedLocation.strStreetName AS RegStreet,
       tRegistratedLocation.strPostCode AS RegPostalCode,
       tRegistratedLocation.strBuilding AS RegBuld,
       tRegistratedLocation.strHouse AS RegHouse,
       tRegistratedLocation.strApartment AS RegApp,
       HC.strRegistrationPhone AS RegPhone,
       CASE
           WHEN tRegistratedLocation.blnForeignAddress = 1 THEN
               tRegistratedLocation.strAddressString
           ELSE
               ''
       END AS RegForeignAddress,
       tRegistratedLocation.dblLongitude AS RegLongitude,
       tRegistratedLocation.dblLatitude AS RegLatitude,
                                                             ---- Employer Address---
       LEmployer.AdminLevel1Name AS EmpCountry,
       LEmployer.AdminLevel2Name AS EmpRegion,
       LEmployer.AdminLevel3Name AS EmpRayon,
       LEmployer.AdminLevel4Name AS EmpVillage,
       tEmployerLocation.strStreetName AS EmpStreet,
       HC.strWorkPhone AS EmpPhone,
       tEmployerLocation.strPostCode AS EmpPostalCode,
       tEmployerLocation.strBuilding AS EmpBuild,
       tEmployerLocation.strHouse AS EmpHouse,
       tEmployerLocation.strApartment AS EmpApp,
       rfInitialCaseStatus.[name] AS InitCaseStatus,
       HC.datNotificationDate AS DateFromHealthCareProvider, -- dbo.Activity.datReportDate
       HC.strCaseID AS CaseIdentifier,
       HC.datInvestigationStartDate AS StartingDateOfInvestigation,
       HC.datCompletionPaperFormDate AS CompletionPaperFormDate,
       HC.strPatientFullName AS NameOfPatient,
       HC.datDateofBirth AS DOB,
       HC.strPersonID AS strPersonID,
       HC.strPersonIDType AS strPersonIDType,
       HC.strPatientAgeType AS AgeType,
       HC.intPatientAge AS Age,
       HC.strPatientGender AS Sex,
       rfNationality.[name] AS Citizenship,
       LCurrent.AdminLevel2Name AS Region,
       LCurrent.AdminLevel3Name AS Rayon,
       LCurrent.AdminLevel4Name AS City,
       tCurrentLocation.strStreetName AS Street,
       tCurrentLocation.strPostCode AS strPost_Code,
       HC.strHomePhone AS PhoneNumber,
       rfOccupationType.[name] AS Occupation,
       tCurrentLocation.strBuilding AS BuildingNum,
       tCurrentLocation.strHouse AS HouseNum,
       tCurrentLocation.strApartment AS AptNum,
       tCurrentLocation.dblLongitude AS Longitude,
       tCurrentLocation.dblLatitude AS Latitude,
       rfHospitalizationStatus.[name] AS strCurrentLocationStatus,
       HC.strEmployerName AS NameOfEmployer,
       HC.datFacilityLastVisit AS datFacilityLastVisit,
       HC.datExposureDate AS DateOfExposure,
       HC.datOnSetDate AS DateofSymptomsOnset,
       HC.datFirstSoughtCareDate AS DateOfFirstSoughtCare,
       SoughtCareFacility.EnglishFullName AS FacilityOfPatientSoughtCare,
       CurrentLocationOffice.AbbreviatedName AS CurrentLocationOfficeName,
       HC.datHospitalizationDate AS HospitalizationDate,
       HC.datDischargeDate AS DateOfDischarged,
       HC.strHospitalizationPlace AS PlaceOfHospitalization,
       rfHospitalisationYN.[name] AS Hospitalization,
       HC.strClinicalNotes AS ClinicalComments,
       (
           SELECT strDefault
           FROM trtbasereference
           WHERE idfsBaseReference = hc.idfsCaseStatus
       ) AS FinalCaseClassification,
       HC.datFinalCaseClassificationDate AS FinalCaseClassificationDate,
       rfCaseStatus.[name] AS CaseProgerssStatus,
       ISNULL(HC.strFinalDiagnosis, HC.strTentetiveDiagnosis) AS FinalDiagnosis,
       ISNULL(HC.datFinalDiagnosisDate, HC.datTentativeDiagnosisDate) AS FinalDiagDate,
       HC.strTentetiveDiagnosis AS InitialDiagnosis,
       HC.datTentativeDiagnosisDate AS InitialDiagDate,
       HC.strClinicalDiagnosis AS ClinicalDiagnosis,
       rfSpecimenCollectedYN.[name] AS SpeciemenCollected,
       HC.strNotCollectedReason AS ReasonForNotCollectingSpeciemens,
       tHumanCase.strSampleNotes AS strSampleNotes,
       rfTherapyYN.[name] AS Antibiotics,
       ISNULL(tHumanCase.blnClinicalDiagBasis, 0) AS blnClinicalDiagBasis,
       ISNULL(tHumanCase.blnLabDiagBasis, 0) AS blnLabDiagBasis,
       ISNULL(tHumanCase.blnEpiDiagBasis, 0) AS blnEpiDiagBasis,
       rfOutcome.[name] AS Outcome,
       HC.datDateOfDeath AS DateOfDeath,
       rfRelatedToOutbreakYN.[name] AS RelatedToOutbreak,
       tOutbreak.strOutbreakID AS OutbreakID,
       HC.strSummaryNotes AS SummaryComments,
       HC.strEpidemiologistsName AS EpiName,
       HC.strGeoLocation AS strGeoLocation,
       HC.strFinalState AS strFinalState,
       HC.strNote AS strClinicalInformationComments
FROM report.FN_REP_HumanCaseProperties_GET(@LangID) AS HC
    -- Get Current ADDRESS 
    LEFT JOIN dbo.tlbGeoLocation tCurrentLocation
        ON HC.idfCurrentResidenceAddress = tCurrentLocation.idfGeoLocation
    LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) LCurrent
        ON LCurrent.idfsLocation = tCurrentLocation.idfsLocation
    -- Get registration location 
    LEFT JOIN dbo.tlbGeoLocation tRegistratedLocation
        ON HC.idfRegistrationAddress = tRegistratedLocation.idfGeoLocation
    LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) LRegistration
        ON LRegistration.idfsLocation = tRegistratedLocation.idfsLocation
    -- Get Employer ADDRESS 
    LEFT JOIN dbo.tlbGeoLocation tEmployerLocation
        ON HC.idfEmployerAddress = tEmployerLocation.idfGeoLocation
    LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) LEmployer
        ON LEmployer.idfsLocation = tEmployerLocation.idfsLocation
    -- Get sent by office name
    LEFT JOIN dbo.tlbOffice SBO
        ON SBO.idfOffice = hc.idfSentByOffice
    LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000045) SentByOfficeRef
        ON SentByOfficeRef.idfsReference = SBO.idfsOfficeAbbreviation
    -- Get investigated by office name
    LEFT JOIN dbo.tlbOffice IBO
        ON IBO.idfOffice = hc.idfInvestigatedByOffice
    LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000045) InvestigatedByOfficeRef
        ON InvestigatedByOfficeRef.idfsReference = IBO.idfsOfficeAbbreviation
    -- Get investigated by office name
    LEFT JOIN dbo.FN_GBL_Institution_Min(@LangID) AS SoughtCareFacility
        ON SoughtCareFacility.idfOffice = HC.idfSoughtCareFacility
    -- Get investigated by office name
    LEFT JOIN dbo.FN_GBL_Institution_Min(@LangID) AS CurrentLocationOffice
        ON CurrentLocationOffice.idfOffice = HC.idfHospital
    -- Get Case status
    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000111) AS rfCaseStatus
        ON rfCaseStatus.idfsReference = HC.idfsCaseProgressStatus
    -- Get Case classification
    --LEFT JOIN  dbo.FN_GBL_Reference_GETList(@LangID, 19000111) AS rfInitialCaseStatus ON rfInitialCaseStatus.idfsReference = HC.idfsInitialCaseStatus
    LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000011) AS rfInitialCaseStatus
        ON rfInitialCaseStatus.idfsReference = hc.idfsInitialCaseStatus
    -- Get Nationality
    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000054) AS rfNationality
        ON rfNationality.idfsReference = HC.idfsNationality
    -- Get HospitalizationStatus
    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000041) AS rfHospitalizationStatus
        ON rfHospitalizationStatus.idfsReference = HC.idfsHospitalizationStatus
    -- Get OcupationType
    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000061) AS rfOccupationType
        ON rfOccupationType.idfsReference = HC.idfsOccupationType
    -- Get is Hospitalisation
    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000100) AS rfHospitalisationYN
        ON rfHospitalisationYN.idfsReference = HC.idfsYNHospitalization
    -- Get is SpecimenCollected
    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000100) AS rfSpecimenCollectedYN
        ON rfSpecimenCollectedYN.idfsReference = HC.idfsYNSpecimenCollected
    -- Get is AntimicrobialTherapy
    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000100) AS rfTherapyYN
        ON rfTherapyYN.idfsReference = HC.idfsYNAntimicrobialTherapy
    -- Get is RelatedToOutbreak
    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000100) AS rfRelatedToOutbreakYN
        ON rfRelatedToOutbreakYN.idfsReference = HC.idfsYNRelatedToOutbreak
    -- Get is Outcome
    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000064) AS rfOutcome
        ON rfOutcome.idfsReference = HC.idfsOutcome
    -- Get Outbreak
    LEFT JOIN dbo.tlbOutbreak AS tOutbreak
        ON tOutbreak.idfOutbreak = HC.idfOutbreak
    LEFT JOIN dbo.tlbHumanCase AS tHumanCase
        ON tHumanCase.idfHumanCase = @ObjID
WHERE @ObjID = HC.idfCase
      OR @ObjID IS NULL;
GO
PRINT N'Altering Procedure [Report].[USP_REP_Lim_SampleTransferForm_GET]...';


GO
-- ================================================================================================
-- Name: report.USP_REP_Lim_SampleTransferForm_GET
--
-- Description:	Select data for Container Transfer report.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mark Wilson		12132021	Initial Version, converted to E7 standards
-- Stephen Long     05/08/2023 Changed from institution repair to min.

/*
--Example of a call of procedure:

exec report.USP_REP_Lim_SampleTransferForm_GET 
	@ObjID=181450001100,
	@LangID=N'en-US'

*/
ALTER  PROCEDURE [Report].[USP_REP_Lim_SampleTransferForm_GET]
    (
		@ObjID BIGINT,
		@LangID AS NVARCHAR(20)
    )
AS
BEGIN 
	SELECT	
		O.strBarcode AS TransferOutBarcode,
		O.strBarcode AS TransferOutLabel,
		O.strNote AS PurposeOfTransfer,
		InstFromName.AbbreviatedName AS TransferredFrom,
		InstToName.AbbreviatedName AS SampleTrasnferredTo,
		dbo.FN_GBL_ConcatFullName(SentByPerson.strFamilyName, SentByPerson.strFirstName, SentByPerson.strSecondName) AS SentBy,
		O.datSendDate AS DateSent,
		M.strBarcode AS SourceLabID,
		M.strBarcode AS SourceLabIDBarcode,
		ST.[name] AS SampleType,
		PM.datAccession AS DateSampleReceived,
		dbo.FN_GBL_ConcatFullName(ReceivedByPerson.strFamilyName, ReceivedByPerson.strFirstName, ReceivedByPerson.strSecondName)	AS ReceivedBy,
		M.strFieldBarcode AS SampleID,
		PM.strBarcode AS LabSampleID,
		rfCondition.name AS Condition,				
		RF.[Path] AS StorageLocation,				
		PM.strCondition AS Comment,
		rfFuncArea.name AS FunctionalArea				

	FROM dbo.tlbTransferOUT O
	LEFT JOIN dbo.tlbTransferOutMaterial OM ON OM.idfTransferOut=O.idfTransferOut
	LEFT JOIN dbo.tlbMaterial M ON M.idfMaterial = OM.idfMaterial AND M.intRowStatus = 0
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000087) ST ON ST.idfsReference = M.idfsSampleType
	LEFT JOIN dbo.tlbMaterial PM ON PM.idfParentMaterial=M.idfMaterial AND PM.idfsSampleKind = 12675430000000 /* TransferredIn */ AND PM.intRowStatus = 0
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000110) rfCondition ON rfCondition.idfsReference = PM.idfsAccessionCondition
   	LEFT JOIN report.FN_SAMPLE_RepositorySchema_GET(@LangID,NULL,NULL) RF ON RF.idfSubdivision = PM.idfSubdivision
	LEFT JOIN dbo.FN_GBL_Department(@LangID) rfFuncArea ON rfFuncArea.idfDepartment = PM.idfInDepartment
	LEFT JOIN dbo.FN_GBL_Institution_Min(@LangID) AS InstFromName ON O.idfSendFromOffice = InstFromName.idfOffice
	LEFT JOIN dbo.FN_GBL_Institution_Min(@LangID) AS InstToName ON O.idfSendToOffice = InstToName.idfOffice
	LEFT JOIN dbo.tlbPerson AS SentByPerson ON O.idfSendByPerson = SentByPerson.idfPerson
	LEFT JOIN dbo.tlbPerson AS ReceivedByPerson ON PM.idfAccesionByPerson = ReceivedByPerson.idfPerson

	WHERE	O.idfTransferOut = @ObjID

END
GO
PRINT N'Altering Procedure [Report].[USP_REP_Organization_GET]...';


GO
--*************************************************************************
-- Name 				: report.USP_REP_Organization_GET
-- Description			: returns the user's organization
--          
-- Author               : Mark Wilson
-- Revision History
-- Name			       Date       Change Detail
-- ------------------- ---------- ----------------------------------------
-- Stephen Long        05/08/2023 Changed from institution repair to min.
--
-- Testing code:
--
-- EXEC report.USP_REP_Organization_GET -498, 'ka'
-- EXEC report.USP_REP_Organization_GET -498
--*************************************************************************
ALTER PROCEDURE  [Report].[USP_REP_Organization_GET]
(
	@idfPerson BIGINT,
	@LangID NVARCHAR(50) = NULL
)
AS
BEGIN
	SELECT 
		P.idfInstitution,
		I.EnglishFullName AS OrganizationName
	FROM  dbo.tlbPerson P
	LEFT JOIN dbo.FN_GBL_Institution_Min(@LangID) I ON I.idfOffice = P.idfInstitution
	WHERE P.idfPerson = @idfPerson;
END
GO
PRINT N'Altering Procedure [Report].[USP_REP_Organization_SelectLookup]...';


GO
--*************************************************************************
-- Name: report.USP_REP_Organization_SelectLookup
--
-- Description: To Get the Organization List 
--          
-- Author: Srini Goli
--
-- Revision History:
-- Name			       Date       Change Detail
-- ------------------- ---------- ----------------------------------------
-- Stephen Long        05/08/2023 Changed from institution repair to min.
--
-- Testing code:
/*
--Example of procedure call:
EXEC report.USP_REP_Organization_SelectLookup 'en', NULL
EXEC report.USP_REP_Organization_SelectLookup 'en', 1152
*/
ALTER PROCEDURE [Report].[USP_REP_Organization_SelectLookup]
	@LangID AS NVARCHAR(50),	--##PARAM @LangID - language ID
	@ID AS BIGINT = NULL		--##PARAM @ID - organization ID, if not null only record with this organization is selected
AS
	DECLARE @CountryID BIGINT
	DECLARE @ReportTable TABLE   
	(  
		idfInstitution BIGINT PRIMARY KEY NOT NULL,   
		Name NVARCHAR(200),
		intRowStatus INT
	)  
  
BEGIN	
	SELECT	@CountryID= tcp1.idfsCountry
 	FROM	dbo.tstCustomizationPackage tcp1
	JOIN	dbo.tstSite s ON
		s.idfCustomizationPackage = tcp1.idfCustomizationPackage
 	INNER JOIN	dbo.tstLocalSiteOptions lso
 	ON		lso.strName = N'SiteID'
 			AND lso.strValue = CAST(s.idfsSite AS NVARCHAR(20))
 	
 	INSERT INTO @ReportTable 
 	SELECT 0 AS idfInstitution
 			,'' AS [name]
 			,0 AS intRowStatus	
 	UNION ALL			
	SELECT ts.idfsSite AS idfInstitution
		   ,fir.AbbreviatedName AS [name]
		   ,fir.intRowStatus
	FROM dbo.tstSite ts
	JOIN dbo.tstCustomizationPackage tcpac on
		tcpac.idfCustomizationPackage = ts.idfCustomizationPackage
	JOIN dbo.FN_GBL_Institution_Min(@LangID) fir	
		ON fir.idfOffice = ts.idfOffice
		and tcpac.idfsCountry = @CountryID
--		and ts.intFlags = 1
	JOIN dbo.trtBaseReference tbr1
	ON tbr1.idfsBaseReference = fir.idfsOfficeAbbreviation  
	
	SELECT idfInstitution
			,[name]
			,intRowStatus
	FROM @ReportTable
	WHERE idfInstitution = ISNULL(@ID, idfInstitution)
    ORDER BY [name]
END
GO
PRINT N'Altering Procedure [Report].[USP_REP_VET_Form1ADiagnosticInvestigationsAZ]...';


GO
--*************************************************************************
-- Name: report.USP_REP_VET_Form1ADiagnosticInvestigationsAZ
--
-- Description: Select Diagnostic investigations data for Veterinary Report Form Vet1A.
--          
-- Author: Srini Goli
--
-- Revision History:
-- Name			       Date       Change Detail
-- ------------------- ---------- ----------------------------------------
-- Stephen Long        05/08/2023 Changed from institution repair to min.
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC report.USP_REP_VET_Form1ADiagnosticInvestigationsAZ 'en',2014,2016
EXEC report.USP_REP_VET_Form1ADiagnosticInvestigationsAZ @LangID=N'en', @FromYear = 2016, @ToYear = 2016, @FromMonth = 1, @ToMonth = 11
EXEC report.USP_REP_VET_Form1ADiagnosticInvestigationsAZ 'en',2012,2013
EXEC report.USP_REP_VET_Form1ADiagnosticInvestigationsAZ @LangID=N'en', @FromYear = 2015, @ToYear = 2015, @FromMonth = 1, @ToMonth = 12
*/
ALTER  PROCEDURE [Report].[USP_REP_VET_Form1ADiagnosticInvestigationsAZ]
    (
        @LangID as NVARCHAR(10)
        , @FromYear AS INT
		, @ToYear AS INT
		, @FromMonth AS INT = NULL
		, @ToMonth AS INT = NULL
		, @RegionID AS BIGINT = NULL
		, @RayonID AS BIGINT = NULL
		, @OrganizationEntered AS BIGINT = NULL
		, @OrganizationID AS BIGINT = NULL
		, @idfUserID AS BIGINT = NULL
    )
WITH RECOMPILE
AS

--DECLARE @LangID as NVARCHAR(10) = N'en'
--        , @FromYear AS INT = 2015
--		, @ToYear AS INT = 2015
--		, @FromMonth AS INT = 1
--		, @ToMonth AS INT = 12
--		, @RegionID AS BIGINT = NULL
--		, @RayonID AS BIGINT = NULL
--		, @OrganizationEntered AS BIGINT = NULL
--		, @OrganizationID AS BIGINT = NULL
--		, @idfUserID AS BIGINT = NULL


BEGIN


DECLARE	@drop_cmd	NVARCHAR(4000)

-- Drop temporary tables
IF Object_ID('tempdb..#ActiveSurveillanceSessionList') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #ActiveSurveillanceSessionList'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#ActiveSurveillanceSessionData') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #ActiveSurveillanceSessionData'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#ASAnimal') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #ASAnimal'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#ActiveSurveillanceSessionSourceData') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #ActiveSurveillanceSessionSourceData'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#VetAggregateAction') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetAggregateAction'
	EXECUTE sp_executesql @drop_cmd
END

DECLARE @Result AS TABLE
(
	strDiagnosisSpeciesKey	NVARCHAR(200) collate database_default NOT NULL primary key,
	strInvestigationName	NVARCHAR(2000) collate database_default null,
	idfsDiagnosticAction	bigint NOT NULL,
	idfsDiagnosis			bigint NOT NULL,
	idfsSpeciesType			bigint NOT NULL,
	strDiagnosisName		NVARCHAR(2000) collate database_default null,
	strOIECode				NVARCHAR(200) collate database_default null,
	strSpecies				NVARCHAR(2000) collate database_default null,
	strFooterPerformer		NVARCHAR(2000) collate database_default null,
	intTested				INT NULL,
	intPositivaReaction		INT NULL,
	strNote					NVARCHAR(2000) collate database_default null,
	InvestigationOrderColumn	INT NULL,
	SpeciesOrderColumn		INT NULL,
	DiagnosisOrderColumn	INT NULL,
	blnAdditionalText		BIT
)

DECLARE	@idfsSummaryReportType	bigint
SET	@idfsSummaryReportType = 10290033	-- Veterinary Report Form Vet 1A - Diagnostic

DECLARE	@idfsMatrixType	bigint
SET	@idfsMatrixType = 71460000000	-- Diagnostic investigations


-- Specify the value of missing month IF remaining month is specified in interval (1-12)
IF	@FromMonth is null AND @ToMonth IS NOT NULL AND @ToMonth >= 1 AND @ToMonth <= 12
	SET	@FromMonth = 1
IF	@ToMonth is null AND @FromMonth IS NOT NULL AND @FromMonth >= 1 AND @FromMonth <= 12
	SET	@ToMonth = 12

-- Calculate Start AND End dates for conditions: Start Date <= date from Vet Case < End date
DECLARE	@StartDate	date
DECLARE	@EndDate	date

IF	@FromMonth is null or @FromMonth < 1 or @FromMonth > 12
	SET	@StartDate = CAST(@FromYear as NVARCHAR) + N'0101'
ELSE IF @FromMonth < 10
	SET	@StartDate = CAST(@FromYear as NVARCHAR) + N'0' + CAST(@FromMonth as NVARCHAR) + N'01'
ELSE
	SET	@StartDate = CAST(@FromYear as NVARCHAR) + CAST(@FromMonth as NVARCHAR) + N'01'

IF	@ToMonth is null or @ToMonth < 1 or @ToMonth > 12
BEGIN
	SET	@EndDate = CAST(@ToYear as NVARCHAR) + N'0101'
	SET	@EndDate = dateadd(year, 1, @EndDate)
END
ELSE
BEGIN
	IF @ToMonth < 10
		SET	@EndDate = CAST(@ToYear as NVARCHAR) + N'0' + CAST(@ToMonth as NVARCHAR) + N'01'
	ELSE
		SET	@EndDate = CAST(@ToYear as NVARCHAR) + CAST(@ToMonth as NVARCHAR) + N'01'
	
	SET	@EndDate = dateadd(month, 1, @EndDate)
END

DECLARE	@OrganizationName_GenerateReport	NVARCHAR(2000)
SELECT		@OrganizationName_GenerateReport = i.EnglishFullName
FROM		dbo.FN_GBL_Institution_Min(@LangID) i
WHERE		i.idfOffice = @OrganizationID
IF	@OrganizationName_GenerateReport is null
	SET	@OrganizationName_GenerateReport = N''


-- Calculate Footer parameter "Name AND Last Name of Performer:" - start
DECLARE	@FooterNameOfPerformer	NVARCHAR(2000)
SET	@FooterNameOfPerformer = N''

-- Show the user Name AND Surname which is generating the report 
-- AND near it current organization name (Organization from which user has logged on to the system) 
--     in round brackets in respective report language

DECLARE	@EmployeeName_GenerateReport	NVARCHAR(2000)
SELECT		@EmployeeName_GenerateReport = dbo.FN_GBL_ConcatFullName(p.strFamilyName, p.strFirstName, p.strSecondName)
FROM		tlbPerson p
INNER JOIN	tstUserTable ut
ON			ut.idfPerson = p.idfPerson
WHERE		ut.idfUserID = @idfUserID
IF	@EmployeeName_GenerateReport is null
	SET	@EmployeeName_GenerateReport = N''

SET	@FooterNameOfPerformer = @EmployeeName_GenerateReport
IF	ltrim(rtrim(@OrganizationName_GenerateReport)) <> N''
BEGIN
	IF	ltrim(rtrim(@FooterNameOfPerformer)) = N''
	BEGIN
		SET @FooterNameOfPerformer = N'(' + @OrganizationName_GenerateReport + N')' 
	END
	ELSE
	BEGIN
		SET	@FooterNameOfPerformer = @FooterNameOfPerformer + N' (' + @OrganizationName_GenerateReport + N')'
	END
END

-- Calculate Footer parameter "Name AND Last Name of Performer:" - end

-- Select report informative part - start

DECLARE	@vet_form_1_use_specific_gis	bigint
DECLARE	@vet_form_1_specific_gis_region	bigint
DECLARE	@vet_form_1_specific_gis_rayon	bigint
DECLARE	@attr_part_in_report			bigint

SELECT	@vet_form_1_use_specific_gis = at.idfAttributeType
FROM	trtAttributeType at
WHERE	at.strAttributeTypeName = N'vet_form_1_use_specific_gis'

SELECT	@vet_form_1_specific_gis_region = at.idfAttributeType
FROM	trtAttributeType at
WHERE	at.strAttributeTypeName = N'vet_form_1_specific_gis_region'

SELECT	@vet_form_1_specific_gis_rayon = at.idfAttributeType
FROM	trtAttributeType at
WHERE	at.strAttributeTypeName = N'vet_form_1_specific_gis_rayon'

SELECT	@attr_part_in_report = at.idfAttributeType
FROM	trtAttributeType at
WHERE	at.strAttributeTypeName = N'attr_part_in_report'

DECLARE @SpecificOfficeId BIGINT
SELECT
	 @SpecificOfficeId = ts.idfOffice
FROM tstSite ts 
WHERE ts.intRowStatus = 0
	AND ts.intFlags = 100 /*organization with abbreviation = Baku city VO*/

DECLARE	@Diagnostic_Tested		BIGINT
DECLARE	@Diagnostic_Positive	BIGINT
DECLARE	@Diagnostic_Note		BIGINT


-- Diagnostic_Tested
SELECT		@Diagnostic_Tested = p.idfsParameter
FROM		trtFFObjectForCustomReport ff_for_cr
INNER JOIN	ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Diagnostic_Tested'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

-- Diagnostic_Positive
SELECT		@Diagnostic_Positive = p.idfsParameter
FROM		trtFFObjectForCustomReport ff_for_cr
INNER JOIN	ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Diagnostic_Positive'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

-- Diagnostic_Note
SELECT		@Diagnostic_Note = p.idfsParameter
FROM		trtFFObjectForCustomReport ff_for_cr
INNER JOIN	ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Diagnostic_Note'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

-- Lab Diagnostic - investigation type for data from AS Session
DECLARE	@Lab_diagnostics				BIGINT
DECLARE	@Lab_diagnostics_Translation	NVARCHAR(2000)
DECLARE	@Lab_diagnostics_Order			int

SELECT		@Lab_diagnostics = rat.idfsReference,
			@Lab_diagnostics_Translation = rat.[name],
			@Lab_diagnostics_Order = rat.intOrder
FROM		trtBaseReferenceAttribute bra
INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000132) rat	/*Report Additional Text*/
ON			rat.idfsReference = bra.idfsBaseReference
WHERE		bra.idfAttributeType = @attr_part_in_report
			AND CAST(bra.varValue as NVARCHAR) = CAST(@idfsSummaryReportType as NVARCHAR(20))
			AND bra.strAttributeItem = N'Name of investigation - Lab diagnostics'

IF	@Lab_diagnostics is null
	SET	@Lab_diagnostics = -1
IF	@Lab_diagnostics_Translation is null
	SET	@Lab_diagnostics_Translation = N''
	
	
-- Project monitoring - investigation type for data from AS Session
DECLARE	@Project_monitoring				BIGINT
DECLARE	@Project_monitoring_Translation	NVARCHAR(2000)
DECLARE	@Project_monitoring_Order			int

SELECT		@Project_monitoring = rat.idfsReference,
			@Project_monitoring_Translation = rat.[name],
			@Project_monitoring_Order = rat.intOrder
FROM		trtBaseReferenceAttribute bra
INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000132) rat	/*Report Additional Text*/
ON			rat.idfsReference = bra.idfsBaseReference
WHERE		bra.idfAttributeType = @attr_part_in_report
			AND CAST(bra.varValue as NVARCHAR) = CAST(@idfsSummaryReportType as NVARCHAR(20))
			AND bra.strAttributeItem = N'Name of investigation - Project monitoring'

IF	@Project_monitoring is null
	SET	@Project_monitoring = -1
IF	@Project_monitoring_Translation is null
	SET	@Project_monitoring_Translation = N''

-- Included state sector - note for data from AS Session containing farm, 
-- which has ownership structure = State Farm AND is counted for the report
DECLARE	@Included_state_sector				BIGINT
DECLARE	@Included_state_sector_Translation	NVARCHAR(2000)

SELECT		@Included_state_sector = rat.idfsReference,
			@Included_state_sector_Translation = rat.[name]
FROM		trtBaseReferenceAttribute bra
INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000132) rat	/*Report Additional Text*/
ON			rat.idfsReference = bra.idfsBaseReference
WHERE		bra.idfAttributeType = @attr_part_in_report
			AND CAST(bra.varValue as NVARCHAR) = CAST(@idfsSummaryReportType as NVARCHAR(20))
			AND bra.strAttributeItem = N'Note - Diagnostic'

IF	@Included_state_sector is null
	SET	@Included_state_sector = -1
IF	@Included_state_sector_Translation is null
	SET	@Included_state_sector_Translation = N''

-- Active Surveillance Session List for calculations
CREATE TABLE	#ActiveSurveillanceSessionList
(	idfMonitoringSessiON			BIGINT NOT NULL PRIMARY KEY
	, LabDiagnostics BIT NOT NULL
)


INSERT INTO	#ActiveSurveillanceSessionList
(	idfMonitoringSession
	, LabDiagnostics
)
SELECT	DISTINCT
			ms.idfMonitoringSession
			, CASE WHEN tc.idfCampaign IS NULL THEN 1 ELSE 0 END
FROM		
-- AS Session
			tlbMonitoringSession ms

-- Site, Organization entered session
INNER JOIN	tstSite s
	LEFT JOIN	dbo.FN_GBL_Institution_Min(@LangID) i
	ON			i.idfOffice = CASE WHEN s.intFlags = 10 THEN @SpecificOfficeId ELSE s.idfOffice END

	-- Specific Region AND Rayon for the site with specific attributes (B46)
	LEFT JOIN	trtBaseReferenceAttribute bra
	ON			bra.idfsBaseReference = i.idfsOfficeAbbreviation
				AND bra.idfAttributeType = @vet_form_1_use_specific_gis
				AND CAST(bra.varValue as NVARCHAR) = s.strSiteID
	LEFT JOIN	trtGISBaseReferenceAttribute gis_bra_region
	ON			CAST(gis_bra_region.varValue as NVARCHAR) = s.strSiteID
				AND gis_bra_region.idfAttributeType = @vet_form_1_specific_gis_region
	LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) reg_specific
	ON			reg_specific.idfsReference = gis_bra_region.idfsGISBaseReference
	LEFT JOIN	trtGISBaseReferenceAttribute gis_bra_rayon
	ON			CAST(gis_bra_rayon.varValue as NVARCHAR) = s.strSiteID
				AND gis_bra_rayon.idfAttributeType = @vet_form_1_specific_gis_rayon
	LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) ray_specific
	ON			ray_specific.idfsReference = gis_bra_rayon.idfsGISBaseReference

ON			s.idfsSite = ms.idfsSite

-- Region AND Rayon
LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) reg
ON			reg.idfsReference = ms.idfsRegion
LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) ray
ON			ray.idfsReference = ms.idfsRayon

LEFT JOIN tlbCampaign tc ON 
	tc.idfCampaign = ms.idfCampaign 
	AND tc.intRowStatus = 0 
	AND tc.idfsCampaignType = 10150002 /*Study*/

WHERE		ms.intRowStatus = 0

			-- Session Start Date is not blank
			AND ms.datStartDate IS NOT NULL


			-- From Year, Month To Year, Month
			AND ISNULL(ms.datEndDate, ms.datStartDate) >= @StartDate
			AND ISNULL(ms.datEndDate, ms.datStartDate) < @EndDate
			
			-- Region
			AND (@RegionID is null or (@RegionID IS NOT NULL AND ISNULL(reg_specific.idfsReference, reg.idfsReference) = @RegionID))
			-- Rayon
			AND (@RayonID is null or (@RayonID IS NOT NULL AND ISNULL(ray_specific.idfsReference, ray.idfsReference) = @RayonID))
			
			-- Entered by organization
			AND (@OrganizationEntered is null or (@OrganizationEntered IS NOT NULL AND i.idfOffice = @OrganizationEntered))





-- Active Surveillance Session data
create TABLE	#ActiveSurveillanceSessionData
(	strDiagnosisSpeciesKey			NVARCHAR(200) collate database_default NOT NULL /*primary key*/,
	idfsDiagnosis					BIGINT NOT NULL,
	idfsDiagnosticActiON			BIGINT NOT NULL,
	idfsSpeciesType					BIGINT NOT NULL,
	strInvestigationName			NVARCHAR(2000) collate database_default null,
	strDiagnosisName				NVARCHAR(2000) collate database_default null,
	strOIECode						NVARCHAR(200) collate database_default null,
	strSpecies						NVARCHAR(2000) collate database_default null,
	intTested						INT NULL,
	intPositivaReactiON				INT NULL,
	blnAddNote						INT NULL default (0),
	InvestigationOrderColumn		INT NULL,
	SpeciesOrderColumn				INT NULL,
	DiagnosisOrderColumn			INT NULL
)



DECLARE	@NotDeletedDiagnosis TABLE
(	idfsDiagnosis		BIGINT NOT NULL primary key,
	[name]				NVARCHAR(2000) collate Cyrillic_General_CI_AS null,
	intOrder			INT NULL,
	strOIECode			NVARCHAR(200) collate Cyrillic_General_CI_AS null, 
	idfsActualDiagnosis	BIGINT NOT NULL
)

INSERT INTO	@NotDeletedDiagnosis
(	idfsDiagnosis,
	[name],
	intOrder,
	strOIECode,
	idfsActualDiagnosis
)
SELECT
			r_d.idfsReference AS idfsDiagnosis
			, r_d.[name] AS [name]
			, CASE
				WHEN	actual_diagnosis.idfsDiagnosis IS NOT NULL
					THEN actual_diagnosis.intOrder
				ELSE	r_d.intOrder
			  END as intOrder
			, CASE
				WHEN	actual_diagnosis.idfsDiagnosis IS NOT NULL
					THEN actual_diagnosis.strOIECode
				ELSE	d.strOIECode
			  END as strOIECode
			, ISNULL(actual_diagnosis.idfsDiagnosis, r_d.idfsReference) AS idfsActualDiagnosis
FROM		dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) r_d
LEFT JOIN	trtDiagnosis d
ON			d.idfsDiagnosis = r_d.idfsReference
LEFT JOIN	(
	SELECT	d_actual.idfsDiagnosis,
			r_d_actual.[name],
			r_d_actual.intOrder,
			d_actual.strOIECode,
			ROW_NUMBER() OVER (PARTITION BY r_d_actual.[name] ORDER BY d_actual.idfsDiagnosis) AS rn
	FROM		trtDiagnosis d_actual
	INNER JOIN	report.FN_GBL_ReferenceRepair_GET('en', 19000019) r_d_actual
	ON			r_d_actual.idfsReference = d_actual.idfsDiagnosis
	WHERE		d_actual.idfsUsingType = 10020001	/*Case-based*/
				AND d_actual.intRowStatus = 0
			) actual_diagnosis
	ON		actual_diagnosis.[name] = r_d.[name] collate Cyrillic_General_CI_AS
			AND actual_diagnosis.rn = 1


DECLARE	@NotDeletedSpecies TABLE
(	idfsSpeciesType			BIGINT NOT NULL primary key,
	[name]					NVARCHAR(2000) collate Cyrillic_General_CI_AS null,
	intOrder			INT NULL,
	idfsActualSpeciesType	BIGINT NOT NULL
)

INSERT INTO	@NotDeletedSpecies
(	idfsSpeciesType,
	[name],
	intOrder,
	idfsActualSpeciesType
)
SELECT
			r_sp.idfsReference AS idfsSpeciesType
			, CAST(r_sp.[name] AS NVARCHAR(2000)) AS [name]
			, CASE
				WHEN	actual_SpeciesType.idfsSpeciesType IS NOT NULL
					THEN actual_SpeciesType.intOrder
				ELSE	r_sp.intOrder
			  END as intOrder
			, ISNULL(actual_SpeciesType.idfsSpeciesType, r_sp.idfsReference) AS idfsActualSpeciesType
FROM		dbo.FN_GBL_ReferenceRepair(@LangID, 19000086) r_sp
LEFT JOIN	(
	SELECT	st_actual.idfsSpeciesType,
			r_st_actual.[name],
			r_st_actual.intOrder,
			ROW_NUMBER() OVER (PARTITION BY r_st_actual.[name] ORDER BY st_actual.idfsSpeciesType) AS rn
	FROM		trtSpeciesType st_actual
	INNER JOIN	report.FN_GBL_ReferenceRepair_GET('en', 19000086) r_st_actual
	ON			r_st_actual.idfsReference = st_actual.idfsSpeciesType
	WHERE		st_actual.intRowStatus = 0
		) actual_SpeciesType
on		actual_SpeciesType.[name] = r_sp.[name] collate Cyrillic_General_CI_AS
		AND actual_SpeciesType.rn = 1


INSERT INTO	#ActiveSurveillanceSessionData
(	strDiagnosisSpeciesKey,
	idfsDiagnosis,
	idfsDiagnosticAction,
	idfsSpeciesType,
	strInvestigationName,
	strDiagnosisName,
	strOIECode,
	strSpecies,
	intTested,
	intPositivaReaction,
	blnAddNote,
	InvestigationOrderColumn,
	SpeciesOrderColumn,
	DiagnosisOrderColumn
)
SELECT
	CAST(ndd.idfsActualDiagnosis AS NVARCHAR(20)) + N'_' + 
		CAST(ndsp.idfsActualSpeciesType AS NVARCHAR(20)) + N'_' + 
		CAST(CASE WHEN LabDiagnostics = 1 THEN @Lab_diagnostics ELSE @Project_monitoring END AS NVARCHAR(20)) AS strDiagnosisSpeciesKey,
	ndd.idfsActualDiagnosis AS idfsDiagnosis,
	CASE WHEN LabDiagnostics = 1 THEN @Lab_diagnostics ELSE @Project_monitoring END AS idfsDiagnosticAction,
	ndsp.idfsActualSpeciesType AS idfsSpeciesType,
	CASE WHEN LabDiagnostics = 1 THEN @Lab_diagnostics_Translation ELSE @Project_monitoring_Translation END AS strInvestigationName,
	ISNULL(ndd.[name], N'') AS strDiagnosisName,
	ISNULL(ndd.strOIECode, N'') AS strOIECode,
	ISNULL(ndsp.[name], N'') AS strSpecies,
		COUNT(DISTINCT /*DISTINCT for calculating 
						number of unique animals - 
						ticket 10165*/ sd.idfMaterial),
		COUNT(DISTINCT /*DISTINCT for calculating 
						number of unique animals - 
						ticket 10165*/ sd.idfTesting),
		SUM(CAST((ISNULL(sd.idfsOwnershipStructure, 0) / 10820000000) AS INT)) AS blnAddNote, /*State Farm*/
	CASE WHEN LabDiagnostics = 1 THEN @Lab_diagnostics_Order ELSE @Project_monitoring_Order END AS InvestigationOrderColumn,
	ISNULL(ndsp.intOrder, -1000) AS SpeciesOrderColumn,
	ISNULL(ndd.intOrder, -1000) AS DiagnosisOrderColumn
	
FROM
(
	SELECT DISTINCT
			asd.idfsDiagnosis,
				sp.idfsSpeciesType,
				a.idfAnimal as idfMaterial,
				CASE
					WHEN t.idfTesting IS NOT NULL
						THEN	a.idfAnimal
					ELSE	null
				END as idfTesting,
				--a.idfsOwnershipStructure
				CASE
					WHEN	f.idfsOwnershipStructure = 10820000000 /*State Farm*/
						THEN	10820000000 /*State Farm*/
					ELSE	null
				END idfsOwnershipStructure
			, asl.LabDiagnostics
	FROM		tlbMaterial m

	JOIN tlbAnimal a ON
		a.idfAnimal = m.idfAnimal
		AND a.intRowStatus = 0

	JOIN tlbSpecies sp ON
		sp.idfSpecies = a.idfSpecies
		AND sp.intRowStatus = 0

	--JOIN @NotDeletedSpecies ndsp ON
	--	ndsp.idfsSpeciesType = sp.idfsSpeciesType

	JOIN tlbHerd h ON
		h.idfHerd = sp.idfHerd
		AND h.intRowStatus = 0

	JOIN tlbFarm f ON
		f.idfFarm = h.idfFarm
		AND f.intRowStatus = 0
		AND f.idfMonitoringSession = m.idfMonitoringSession

	JOIN #ActiveSurveillanceSessionList asl ON
		asl.idfMonitoringSession = f.idfMonitoringSession
	
	outer apply	(
		SELECT	DISTINCT
					ms_to_d.idfsDiagnosis--, ndd.idfsActualDiagnosis
		FROM		tlbMonitoringSessionToDiagnosis ms_to_d
		
		--join		@NotDeletedDiagnosis ndd
		--ON			ndd.idfsDiagnosis = ms_to_d.idfsDiagnosis
		
		WHERE		ms_to_d.idfMonitoringSession = asl.idfMonitoringSession
					AND ms_to_d.idfsSpeciesType = sp.idfsSpeciesType
					AND ms_to_d.intRowStatus = 0
				) asd

	LEFT JOIN	tlbTesting t
		join	report.FN_GBL_ReferenceRepair_GET(@LangID, 19000001) ref_teststatus
		on		ref_teststatus.idfsReference = t.idfsTestStatus
	ON			t.idfMaterial = m.idfMaterial
				AND t.intRowStatus = 0
				and	t.idfsDiagnosis = asd.idfsDiagnosis
				AND ISNULL(t.blnExternalTest, 0) = 0
				AND ref_teststatus.idfsReference IN (10001001, 10001006)  /*Final, Amended*/
				AND exists	(
						SELECT TOP 1 1
						FROM	trtTestTypeToTestResult tttttr
						WHERE	tttttr.idfsTestName = t.idfsTestName
								AND tttttr.idfsTestResult = t.idfsTestResult
								AND tttttr.intRowStatus = 0
								AND tttttr.blnIndicative = 1
							)

	WHERE		m.intRowStatus = 0
				AND asd.idfsDiagnosis IS NOT NULL
				AND m.idfsSampleType <> 10320001	/*Unknown*/
				AND m.datFieldCollectionDate IS NOT NULL
				AND exists	(
						SELECT TOP 1 1
						FROM	tlbMonitoringSessionToDiagnosis ms_to_d
						WHERE	ms_to_d.idfMonitoringSession = asl.idfMonitoringSession
								AND ms_to_d.intRowStatus = 0
								AND ms_to_d.idfsDiagnosis = asd.idfsDiagnosis
								AND ms_to_d.idfsSpeciesType = sp.idfsSpeciesType
								AND (	ms_to_d.idfsSampleType is null
										OR	(	ms_to_d.idfsSampleType IS NOT NULL
												AND ms_to_d.idfsSampleType = m.idfsSampleType
											)
									)
							)
) sd

INNER JOIN	@NotDeletedDiagnosis ndd
ON			ndd.idfsDiagnosis = sd.idfsDiagnosis

INNER JOIN	@NotDeletedSpecies ndsp
ON			ndsp.idfsSpeciesType = sd.idfsSpeciesType

GROUP BY	CAST(ndd.idfsActualDiagnosis as NVARCHAR(20)) + N'_' + 
				CAST(ndsp.idfsActualSpeciesType as NVARCHAR(20)) + N'_' + 
				CAST(CASE WHEN LabDiagnostics = 1 THEN @Lab_diagnostics ELSE @Project_monitoring END AS NVARCHAR(20)),
			ndd.idfsActualDiagnosis,
			ndsp.idfsActualSpeciesType,
			ISNULL(ndd.[name], N''),
			ISNULL(ndd.strOIECode, N''),
			ISNULL(ndsp.[name], N''),
			ISNULL(ndsp.intOrder, -1000),
			ISNULL(ndd.intOrder, -1000),
			LabDiagnostics






-- Select aggregate data
DECLARE @MinAdminLevel BIGINT
DECLARE @MinTimeInterval BIGINT
DECLARE @AggrCaseType BIGINT



SET @AggrCaseType = 10102003 /*Vet Aggregate Action*/

SELECT	@MinAdminLevel = idfsStatisticAreaType,
		@MinTimeInterval = idfsStatisticPeriodType
FROM report.FN_AggregateSettings_GET (@AggrCaseType)

CREATE TABLE #VetAggregateAction
(	idfAggrCase					BIGINT NOT NULL PRIMARY KEY,
	idfDiagnosticObservation	BIGINT,
	datStartDate				datetime,
	idfDiagnosticVersion		BIGINT
	, idfsRegion BIGINT
	, idfsRayon BIGINT
	, idfsAdministrativeUnit BIGINT
	, datFinishDate DATETIME
)

DECLARE	@idfsCurrentCountry	BIGINT
SELECT	@idfsCurrentCountry = ISNULL(dbo.FN_GBL_CURRENTCOUNTRY_GET(), 170000000) /*Azerbaijan*/

INSERT INTO	#VetAggregateAction
(	idfAggrCase,
	idfDiagnosticObservation,
	datStartDate,
	idfDiagnosticVersion
	, idfsRegion
	, idfsRayon
	, idfsAdministrativeUnit
	, datFinishDate
)
SELECT		a.idfAggrCase,
			obs.idfObservation,
			a.datStartDate,
			a.idfDiagnosticVersion
			, COALESCE(s.idfsRegion, rr.idfsRegion, r.idfsRegion, NULL) AS idfsRegion
			, COALESCE(s.idfsRayon, rr.idfsRayon, NULL) AS idfsRayon
			, a.idfsAdministrativeUnit
			, a.datFinishDate
FROM		tlbAggrCase a
INNER JOIN	tlbObservation obs
ON			obs.idfObservation = a.idfDiagnosticObservation
LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c
ON			c.idfsReference = a.idfsAdministrativeUnit
LEFT JOIN	report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) r
ON			r.idfsRegion = a.idfsAdministrativeUnit 
LEFT JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) rr
ON			rr.idfsRayon = a.idfsAdministrativeUnit
LEFT JOIN	report.FN_GBL_GIS_Settlement_GET(@LangID, 19000004 /*Settlement*/) s
ON			s.idfsSettlement = a.idfsAdministrativeUnit

-- Site, Organization entered aggregate action
INNER JOIN	tstSite sit
	LEFT JOIN	dbo.FN_GBL_Institution_Min(@LangID) i
	ON			i.idfOffice = sit.idfOffice
ON			sit.idfsSite = a.idfsSite

WHERE		a.idfsAggrCaseType = @AggrCaseType
-- Time Period satisfies Report Filters
			AND (	@StartDate <= a.datStartDate
					AND a.datFinishDate < @EndDate
				)
	AND (
			(r.idfsRegion = @RegionID OR @RegionID IS NULL)
			OR (
				(rr.idfsRayon = @RayonID OR @RayonID IS NULL) 
				AND (rr.idfsRegion = @RegionID OR @RegionID IS NULL)
				)
			OR (
				a.idfsAdministrativeUnit = s.idfsSettlement
				AND (s.idfsRayon = @RayonID OR @RayonID IS NULL) 
				AND (s.idfsRegion = @RegionID OR @RegionID IS NULL)
				)
		)
			-- Entered by organization satisfies Report Filters
			AND (@OrganizationEntered is null or (@OrganizationEntered IS NOT NULL AND i.idfOffice = @OrganizationEntered))

			AND a.intRowStatus = 0

	SELECT	
		@MinAdminLevel = idfsStatisticAreaType
		, @MinTimeInterval = idfsStatisticPeriodType
	FROM report.FN_AggregateSettings_GET (10102003 /*Vet Aggregate Action*/)
	

	DELETE FROM #VetAggregateAction
	WHERE idfAggrCase IN (
		SELECT
			idfAggrCase
		FROM (
			SELECT 
				COUNT(*) OVER (PARTITION BY ac.idfAggrCase) cnt
				, ac2.idfAggrCase
				, CASE 
					WHEN DATEDIFF(YEAR, ac2.datStartDate, ac2.datFinishDate) = 0 AND DATEDIFF(quarter, ac2.datStartDate, ac2.datFinishDate) > 1 
						THEN 10091005 --sptYear
					WHEN DATEDIFF(quarter, ac2.datStartDate, ac2.datFinishDate) = 0 AND DATEDIFF(MONTH, ac2.datStartDate, ac2.datFinishDate) > 1
						THEN 10091003 --sptQuarter
					WHEN DATEDIFF(MONTH, ac2.datStartDate, ac2.datFinishDate) = 0 AND report.FN_GBL_WeekDateDiff_GET(ac2.datStartDate, ac2.datFinishDate) > 1
						THEN 10091001 --sptMonth
					WHEN report.FN_GBL_WeekDateDiff_GET(ac2.datStartDate, ac2.datFinishDate) = 0 AND DATEDIFF(DAY, ac2.datStartDate, ac2.datFinishDate) > 1
						THEN 10091004 --sptWeek
					WHEN DATEDIFF(DAY, ac2.datStartDate, ac2.datFinishDate) = 0
						THEN 10091002 --sptOnday
				END AS TimeInterval
				, CASE
					WHEN ac2.idfsAdministrativeUnit = c2.idfsReference THEN 10089001 --satCountry
					WHEN ac2.idfsAdministrativeUnit = r2.idfsRegion THEN 10089003 --satRegion
					WHEN ac2.idfsAdministrativeUnit = rr2.idfsRayon THEN 10089002 --satRayon
					WHEN ac2.idfsAdministrativeUnit = s2.idfsSettlement THEN 10089004 --satSettlement
				END AS AdminLevel
			FROM #VetAggregateAction ac
			LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c
			ON			c.idfsReference = ac.idfsAdministrativeUnit
			LEFT JOIN	report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) r
			ON			r.idfsRegion = ac.idfsAdministrativeUnit 
			LEFT JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) rr
			ON			rr.idfsRayon = ac.idfsAdministrativeUnit
			LEFT JOIN	report.FN_GBL_GIS_Settlement_GET(@LangID, 19000004 /*Settlement*/) s
			ON			s.idfsSettlement = ac.idfsAdministrativeUnit
				
			JOIN #VetAggregateAction ac2 ON
				(
					ac2.datStartDate BETWEEN ac.datStartDate AND ac.datFinishDate
					OR ac2.datFinishDate BETWEEN ac.datStartDate AND ac.datFinishDate
				)
				
			LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c2
			ON			c2.idfsReference = ac2.idfsAdministrativeUnit
			LEFT JOIN	report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) r2
			ON			r2.idfsRegion = ac2.idfsAdministrativeUnit 
			LEFT JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) rr2
			ON			rr2.idfsRayon = ac2.idfsAdministrativeUnit
			LEFT JOIN	report.FN_GBL_GIS_Settlement_GET(@LangID, 19000004 /*Settlement*/) s2
			ON			s2.idfsSettlement = ac2.idfsAdministrativeUnit
			
			WHERE COALESCE(s2.idfsRayon, rr2.idfsRayon) = ac.idfsAdministrativeUnit
				OR COALESCE(s2.idfsRegion, rr2.idfsRegion, r2.idfsRegion) = ac.idfsAdministrativeUnit
				OR COALESCE(s2.idfsCountry, rr2.idfsCountry, r2.idfsCountry, c2.idfsReference) = ac.idfsAdministrativeUnit
		) a
		WHERE cnt > 1	
			AND CASE WHEN TimeInterval = @MinTimeInterval AND AdminLevel = @MinAdminLevel THEN 1 ELSE 0 END = 0
	)

DECLARE	@VetAggregateActionData	TABLE
(	strDiagnosisSpeciesKey		NVARCHAR(200) collate database_default NOT NULL primary key,
	idfsDiagnosis				BIGINT NOT NULL,
	idfsDiagnosticAction		BIGINT NOT NULL,
	idfsSpeciesType				BIGINT NOT NULL,
	strInvestigationName		NVARCHAR(2000) collate database_default null,
	strDiagnosisName			NVARCHAR(2000) collate database_default null,
	strOIECode					NVARCHAR(200) collate database_default null,
	strSpecies					NVARCHAR(2000) collate database_default null,
	intTested					INT NULL,
	intPositivaReactiON			INT NULL,
	strNote						NVARCHAR(2000) collate database_default null,
	SpeciesOrderColumn			INT NULL,
	DiagnosisOrderColumn		INT NULL,
	InvestigationOrderColumn	INT NULL
)

DECLARE @NotDeletedAggregateDiagnosis TABLE (
	[name] NVARCHAR(500)
	, idfsDiagnosis BIGINT
	, intOrder INT
	, strOIECode NVARCHAR(100)
	, rn INT
)

INSERT INTO @NotDeletedAggregateDiagnosis
SELECT
	r_d_actual.[name]
	, d_actual.idfsDiagnosis
	, r_d_actual.intOrder
	, d_actual.strOIECode
	, ROW_NUMBER() OVER (PARTITION BY r_d_actual.[name] ORDER BY d_actual.idfsDiagnosis) AS rn
FROM		trtDiagnosis d_actual
INNER JOIN	report.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) r_d_actual
ON			r_d_actual.idfsReference = d_actual.idfsDiagnosis
WHERE		d_actual.idfsUsingType = 10020002	/*Aggregate*/
			AND d_actual.intRowStatus = 0
	

DECLARE @NotDeletedAggregateSpecies TABLE (
	[name] NVARCHAR(500)
	, idfsSpeciesType BIGINT
	, intOrder INT
	, rn INT
)	

INSERT INTO @NotDeletedAggregateSpecies
SELECT
	r_sp_actual.[name]
	, st_actual.idfsSpeciesType
	, r_sp_actual.intOrder
	, ROW_NUMBER() OVER (PARTITION BY r_sp_actual.[name] ORDER BY st_actual.idfsSpeciesType) AS rn
FROM		trtSpeciesType st_actual
INNER JOIN	report.FN_GBL_ReferenceRepair_GET(@LangID, 19000086) r_sp_actual
ON			r_sp_actual.idfsReference = st_actual.idfsSpeciesType
WHERE		st_actual.intRowStatus = 0


DECLARE @NotDeletedAggregateInvestigationType TABLE (
	[name] NVARCHAR(500)
	, idfsDiagnosticAction BIGINT
	, intOrder INT
	, rn INT
)

INSERT INTO @NotDeletedAggregateInvestigationType
SELECT
	r_di_actual.[name]
	, r_di_actual.idfsReference as idfsDiagnosticAction
	, r_di_actual.intOrder
	, ROW_NUMBER() OVER (PARTITION BY r_di_actual.[name] ORDER BY r_di_actual.idfsReference) AS rn
FROM		report.FN_GBL_ReferenceRepair_GET(@LangID, 19000021) r_di_actual



INSERT INTO	@VetAggregateActionData
(	strDiagnosisSpeciesKey,
	idfsDiagnosis,
	idfsDiagnosticAction,
	idfsSpeciesType,
	strInvestigationName,
	strDiagnosisName,
	strOIECode,
	strSpecies,
	intTested,
	intPositivaReaction,
	strNote,
	SpeciesOrderColumn,
	DiagnosisOrderColumn,
	InvestigationOrderColumn
)
SELECT		CAST(ISNULL(Actual_Diagnosis.idfsDiagnosis, mtx.idfsDiagnosis) as NVARCHAR(20)) + N'_' + 
				CAST(ISNULL(Actual_Species_Type.idfsSpeciesType, mtx.idfsSpeciesType) as NVARCHAR(20)) + N'_' + 
				CAST(ISNULL(Actual_Investigation_Type.idfsDiagnosticAction, 
								mtx.idfsDiagnosticAction) as NVARCHAR(20)) as strDiagnosisSpeciesKey,
			ISNULL(Actual_Diagnosis.idfsDiagnosis, mtx.idfsDiagnosis) as idfsDiagnosis,
			ISNULL(Actual_Investigation_Type.idfsDiagnosticAction, mtx.idfsDiagnosticAction) as idfsDiagnosticAction,
			ISNULL(Actual_Species_Type.idfsSpeciesType, mtx.idfsSpeciesType) as idfsSpeciesType,
			ISNULL(r_di.[name], N'') as strInvestigationName,
			ISNULL(r_d.[name], N'') as strDiagnosisName,
			ISNULL(Actual_Diagnosis.strOIECode, ISNULL(d.strOIECode, N'')) as strOIECode,
			ISNULL(r_sp.[name], N'') as strSpecies,
			SUM(ISNULL(CAST(Diagnostic_Tested.varValue as int), 0)) as intTested,
			SUM(ISNULL(CAST(Diagnostic_Positive.varValue as int), 0)) as intPositivaReaction,
			MAX(LEFT(ISNULL(CAST(Diagnostic_Note.varValue as NVARCHAR), N''), 2000)) as strNote,
			ISNULL(Actual_Species_Type.intOrder, ISNULL(r_sp.intOrder, -1000)) as SpeciesOrderColumn,
			ISNULL(Actual_Diagnosis.intOrder, ISNULL(r_d.intOrder, -1000)) as DiagnosisOrderColumn,
			ISNULL(Actual_Investigation_Type.intOrder, ISNULL(r_di.intOrder, -1000)) as InvestigationOrderColumn
			
FROM		#VetAggregateAction vaa
-- Matrix version
INNER JOIN	tlbAggrMatrixVersionHeader h
ON			h.idfsMatrixType = @idfsMatrixType
			AND (	-- Get matrix version selected by the user in aggregate action
					h.idfVersion = vaa.idfDiagnosticVersion
					-- If matrix version is not selected by the user in aggregate case, 
					-- then select active matrix with the latest date activation that is earlier than aggregate action start date
					or (	vaa.idfDiagnosticVersion is null 
							and	h.datStartDate <= vaa.datStartDate
							and	h.blnIsActive = 1
							AND not exists	(
										SELECT	*
										FROM	tlbAggrMatrixVersionHeader h_later
										WHERE	h_later.idfsMatrixType = @idfsMatrixType
												and	h_later.datStartDate <= vaa.datStartDate
												and	h_later.blnIsActive = 1
												AND h_later.intRowStatus = 0
												and	h_later.datStartDate > h.datStartDate
											)
						)
				)
			AND h.intRowStatus = 0
			
-- Matrix row
INNER JOIN	tlbAggrDiagnosticActionMTX mtx
ON			mtx.idfVersion = h.idfVersion
			AND mtx.intRowStatus = 0

-- Diagnosis       
INNER JOIN	trtDiagnosis d
	INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) r_d
	ON			r_d.idfsReference = d.idfsDiagnosis

	-- Not deleted diagnosis with the same name AND aggregate using type
	LEFT JOIN @NotDeletedAggregateDiagnosis AS Actual_Diagnosis ON
		Actual_Diagnosis.[name] = r_d.[name] collate Cyrillic_General_CI_AS
		AND Actual_Diagnosis.rn = 1
ON			d.idfsDiagnosis = mtx.idfsDiagnosis

-- Species Type
INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000086) r_sp
	-- Not deleted species type with the same name
	LEFT JOIN @NotDeletedAggregateSpecies AS Actual_Species_Type ON
		Actual_Species_Type.[name] = r_sp.[name] collate Cyrillic_General_CI_AS
		AND Actual_Species_Type.rn = 1
ON			r_sp.idfsReference = mtx.idfsSpeciesType

-- Investigation Type
INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000021) r_di
	-- Not deleted species type with the same name
	LEFT JOIN @NotDeletedAggregateInvestigationType AS Actual_Investigation_Type ON
		Actual_Investigation_Type.[name] = r_di.[name] collate Cyrillic_General_CI_AS
		AND Actual_Investigation_Type.rn = 1
ON			r_di.idfsReference = mtx.idfsDiagnosticAction

-- Tested
outer apply ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	tlbActivityParameters ap
 	WHERE	ap.idfObservation = vaa.idfDiagnosticObservation
 			AND ap.idfRow = mtx.idfAggrDiagnosticActionMTX
			AND ap.idfsParameter = @Diagnostic_Tested
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			order by ap.idfActivityParameters asc
 		) as  Diagnostic_Tested

-- Positive reaction
outer apply ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	tlbActivityParameters ap
 	WHERE	ap.idfObservation = vaa.idfDiagnosticObservation
 			AND ap.idfRow = mtx.idfAggrDiagnosticActionMTX
			AND ap.idfsParameter = @Diagnostic_Positive
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			order by ap.idfActivityParameters asc
 		) as  Diagnostic_Positive

-- Note
outer apply ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	tlbActivityParameters ap
 	WHERE	ap.idfObservation = vaa.idfDiagnosticObservation
 			AND ap.idfRow = mtx.idfAggrDiagnosticActionMTX
			AND ap.idfsParameter = @Diagnostic_Note
			AND ap.intRowStatus = 0
			AND ap.varValue IS NOT NULL
 			order by ap.idfActivityParameters asc
 		) as  Diagnostic_Note

GROUP BY	CAST(ISNULL(Actual_Diagnosis.idfsDiagnosis, mtx.idfsDiagnosis) as NVARCHAR(20)) + N'_' + 
				CAST(ISNULL(Actual_Species_Type.idfsSpeciesType, mtx.idfsSpeciesType) as NVARCHAR(20)) + N'_' + 
				CAST(ISNULL(Actual_Investigation_Type.idfsDiagnosticAction, 
								mtx.idfsDiagnosticAction) as NVARCHAR(20)),
			ISNULL(Actual_Diagnosis.idfsDiagnosis, mtx.idfsDiagnosis),
			ISNULL(Actual_Investigation_Type.idfsDiagnosticAction, mtx.idfsDiagnosticAction),
			ISNULL(Actual_Species_Type.idfsSpeciesType, mtx.idfsSpeciesType),
			ISNULL(r_di.[name], N''),
			ISNULL(r_d.[name], N''),
			ISNULL(Actual_Diagnosis.strOIECode, ISNULL(d.strOIECode, N'')),
			ISNULL(r_sp.[name], N''),
			ISNULL(Actual_Species_Type.intOrder, ISNULL(r_sp.intOrder, -1000)),
			ISNULL(Actual_Diagnosis.intOrder, ISNULL(r_d.intOrder, -1000)),
			ISNULL(Actual_Investigation_Type.intOrder, ISNULL(r_di.intOrder, -1000))
-- Do not include the rows with Tested = 0 in the report
HAVING		SUM(ISNULL(CAST(Diagnostic_Tested.varValue AS INT), 0)) > 0


-- Fill result TABLE
INSERT INTO	@Result
(	strDiagnosisSpeciesKey,
	strInvestigationName,
	idfsDiagnosis,
	idfsDiagnosticAction,
	idfsSpeciesType,
	strDiagnosisName,
	strOIECode,
	strSpecies,
	strFooterPerformer,
	intTested,
	intPositivaReaction,
	strNote,
	InvestigationOrderColumn,
	SpeciesOrderColumn,
	DiagnosisOrderColumn,
	blnAdditionalText
)
SELECT DISTINCT
			s.strDiagnosisSpeciesKey,
			s.strInvestigationName,
			s.idfsDiagnosis,
			s.idfsDiagnosticAction,
			s.idfsSpeciesType,
			s.strDiagnosisName,
			s.strOIECode,
			s.strSpecies,
			@FooterNameOfPerformer,
			s.intTested,
			s.intPositivaReaction,
			CASE
				WHEN	s.blnAddNote > 0
					THEN	@Included_state_sector_Translation
				ELSE	N''
			END,
			s.InvestigationOrderColumn,
			s.SpeciesOrderColumn,
			s.DiagnosisOrderColumn,
			1 AS blnAdditionalText

FROM		#ActiveSurveillanceSessionData s



INSERT INTO	@Result
(	strDiagnosisSpeciesKey,
	strInvestigationName,
	idfsDiagnosis,
	idfsDiagnosticAction,
	idfsSpeciesType,
	strDiagnosisName,
	strOIECode,
	strSpecies,
	strFooterPerformer,
	intTested,
	intPositivaReaction,
	strNote,
	InvestigationOrderColumn,
	SpeciesOrderColumn,
	DiagnosisOrderColumn,
	blnAdditionalText
)
SELECT		a.strDiagnosisSpeciesKey,
			a.strInvestigationName,
			a.idfsDiagnosis,
			a.idfsDiagnosticAction,
			a.idfsSpeciesType,
			a.strDiagnosisName,
			a.strOIECode,
			a.strSpecies,
			@FooterNameOfPerformer,
			a.intTested,
			a.intPositivaReaction,
			CASE
				WHEN	@FromYear = @ToYear
						and	@FromMonth = @ToMonth
					THEN	a.strNote
				ELSE	N''
			END,
			a.InvestigationOrderColumn,
			a.SpeciesOrderColumn,
			a.DiagnosisOrderColumn,
			0 AS blnAdditionalText
			
FROM		@VetAggregateActionData a
LEFT JOIN	@Result r
ON			r.strDiagnosisSpeciesKey = a.strDiagnosisSpeciesKey
WHERE		r.idfsDiagnosis is null

-- Update orders in the table
update	r
SET		r.InvestigationOrderColumn = -1000000,
		r.DiagnosisOrderColumn = 0,
		r.SpeciesOrderColumn = 0
FROM	@Result r
WHERE	(ISNULL(r.idfsDiagnosticAction, -1) = @Lab_diagnostics OR ISNULL(r.idfsDiagnosticAction, -1) = @Project_monitoring)
		AND (	ISNULL(r.InvestigationOrderColumn, 0) <> -1000000
				OR	ISNULL(r.DiagnosisOrderColumn, 0) <> 0
				OR	ISNULL(r.SpeciesOrderColumn, 0) <> 0
			)

update		r
SET			r.InvestigationOrderColumn = ISNULL(adaMTX.intNumRow, 0),
			r.DiagnosisOrderColumn = 0,
			r.SpeciesOrderColumn = 0
FROM		@Result r
INNER JOIN	tlbAggrDiagnosticActionMTX adaMTX
ON			adaMTX.idfsDiagnosis = r.idfsDiagnosis
			AND adaMTX.idfsDiagnosticAction = r.idfsDiagnosticAction
			AND adaMTX.idfsSpeciesType = r.idfsSpeciesType
			AND adaMTX.intRowStatus = 0
INNER JOIN	tlbAggrMatrixVersionHeader amvh
ON			amvh.idfVersion = adaMTX.idfVersion
			AND amvh.intRowStatus = 0
			AND amvh.blnIsActive = 1
			AND amvh.blnIsDefault = 1
			AND amvh.datStartDate <= getdate()
WHERE		(	ISNULL(r.InvestigationOrderColumn, 0) <> ISNULL(adaMTX.intNumRow, 0)
				OR	ISNULL(r.DiagnosisOrderColumn, 0) <> 0
				OR	ISNULL(r.SpeciesOrderColumn, 0) <> 0
			)

update		r
SET			r.InvestigationOrderColumn = 1000000,
			r.DiagnosisOrderColumn = 0,
			r.SpeciesOrderColumn = 0
FROM		@Result r

WHERE		not exists	(
					SELECT	*
					FROM		tlbAggrDiagnosticActionMTX adaMTX
					INNER JOIN	tlbAggrMatrixVersionHeader amvh
					ON			amvh.idfVersion = adaMTX.idfVersion
								AND amvh.intRowStatus = 0
								AND amvh.blnIsActive = 1
								AND amvh.blnIsDefault = 1
								AND amvh.datStartDate <= getdate()
					WHERE		adaMTX.idfsDiagnosis = r.idfsDiagnosis
								AND adaMTX.idfsDiagnosticAction = r.idfsDiagnosticAction
								AND adaMTX.idfsSpeciesType = r.idfsSpeciesType
								AND adaMTX.intRowStatus = 0
						)
			AND (ISNULL(r.idfsDiagnosticAction, -1) = @Lab_diagnostics OR ISNULL(r.idfsDiagnosticAction, -1) = @Project_monitoring)
			AND (	ISNULL(r.InvestigationOrderColumn, 0) <> 1000000
					OR	ISNULL(r.DiagnosisOrderColumn, 0) <> 0
					OR	ISNULL(r.SpeciesOrderColumn, 0) <> 0
				)


-- Select report informative part - start

-- Return results
IF (SELECT COUNT(*) FROM @result) = 0
	select	'' as strDiagnosisSpeciesKey,
	'' as strInvestigationName,
	- 1 as idfsDiagnosis,
	- 1 as idfsDiagnosticAction,
	- 1 as idfsSpeciesType,
	'' as strDiagnosisName,
	'' as strOIECode, 
	'' as strSpecies,
	@FooterNameOfPerformer as strFooterPerformer,
	null as intTested, 
	null as intPositivaReaction, 
	null as strNote,
	null as InvestigationOrderColumn,
	null as SpeciesOrderColumn, 
	null as DiagnosisOrderColumn,
	0   as blnAdditionalText
ELSE
	SELECT * FROM @result ORDER BY InvestigationOrderColumn, strInvestigationName, DiagnosisOrderColumn, strDiagnosisName, idfsDiagnosis, SpeciesOrderColumn, blnAdditionalText
	
	

	
	     
-- Drop temporary tables
IF Object_ID('tempdb..#ActiveSurveillanceSessionList') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #ActiveSurveillanceSessionList'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#ASDiagnosisAndSpeciesType') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #ASDiagnosisAndSpeciesType'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#ActiveSurveillanceSessionData') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #ActiveSurveillanceSessionData'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#ASAnimal') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #ASAnimal'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#ActiveSurveillanceSessionSourceData') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #ActiveSurveillanceSessionSourceData'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#VetAggregateAction') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetAggregateAction'
	EXECUTE sp_executesql @drop_cmd
END




END
GO
PRINT N'Altering Procedure [Report].[USP_REP_VET_Form1ASanitaryMeasuresAZ]...';


GO
--*************************************************************************
-- Name: report.USP_REP_VET_Form1ASanitaryMeasuresAZ
--
-- Description: Select Sanitary Measures data for Veterinary 
-- Report Form Vet1A.
--          
-- Author: Srini Goli
--
-- Revision History:
-- Name                 Date       Change Detail
-- -------------------- ---------- ---------------------------------------
-- Stephen Long         05/08/2023 Changed from institution repair to min.
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC report.USP_REP_VET_Form1ASanitaryMeasuresAZ 'en',2014,2016
EXEC report.USP_REP_VET_Form1ASanitaryMeasuresAZ 'ru',2017,2018
EXEC report.USP_REP_VET_Form1ASanitaryMeasuresAZ @LangID=N'en', @FromYear = 2014, @ToYear = 2014, @FromMonth = 9, @ToMonth = 9
*/
ALTER PROCEDURE [Report].[USP_REP_VET_Form1ASanitaryMeasuresAZ]
    (
      @LangID AS NVARCHAR(10)
    , @FromYear AS INT
	, @ToYear AS INT
	, @FromMonth AS INT = NULL
	, @ToMonth AS INT = NULL
	, @RegionID AS BIGINT = NULL
	, @RayonID AS BIGINT = NULL
	, @OrganizationEntered AS BIGINT = NULL
	, @OrganizationID AS BIGINT = NULL
)
WITH RECOMPILE
AS
BEGIN

DECLARE	@drop_cmd	NVARCHAR(4000)

-- Drop temporary tables
if Object_ID('tempdb..#VetAggregateAction') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetAggregateAction'
	EXECUTE sp_executesql @drop_cmd
END

DECLARE @Result AS TABLE
(
	strKey					NVARCHAR(200) COLLATE database_default NOT NULL PRIMARY KEY,
	strMeasureName			NVARCHAR(2000) COLLATE database_default NULL,
	SanitaryMeasureOrderColumn	INT NULL,
	intNumberFacilities		INT NULL,
	intSquare				FLOAT NULL,
	strNote					NVARCHAR(2000) COLLATE database_default NULL,
	blnAdditionalText		BIT
)

DECLARE	@idfsSummaryReportType	BIGINT
SET	@idfsSummaryReportType = 10290035	-- Veterinary Report Form Vet 1A - Sanitary

DECLARE	@idfsMatrixType	BIGINT
SET	@idfsMatrixType = 71260000000	-- Veterinary-sanitary measures

-- Specify the value of missing month if remaining month is specified in interval (1-12)
IF	@FromMonth IS NULL AND @ToMonth IS NOT NULL AND @ToMonth >= 1 AND @ToMonth <= 12
	SET	@FromMonth = 1
IF	@ToMonth IS NULL AND @FromMonth IS NOT NULL AND @FromMonth >= 1 AND @FromMonth <= 12
	SET	@ToMonth = 12

-- Calculate Start and End dates for conditions: Start Date <= date from Vet Case < End date
DECLARE	@StartDate	DATE
DECLARE	@EndDate	DATE

IF	@FromMonth IS NULL or @FromMonth < 1 or @FromMonth > 12
	SET	@StartDate = CAST(@FromYear AS NVARCHAR) + N'0101'
ELSE IF @FromMonth < 10
	SET	@StartDate = CAST(@FromYear AS NVARCHAR) + N'0' + CAST(@FromMonth AS NVARCHAR) + N'01'
ELSE
	SET	@StartDate = CAST(@FromYear AS NVARCHAR) + CAST(@FromMonth AS NVARCHAR) + N'01'

IF	@ToMonth IS NULL or @ToMonth < 1 or @ToMonth > 12
BEGIN
	SET	@EndDate = CAST(@ToYear AS NVARCHAR) + N'0101'
	SET	@EndDate = DATEADD(YEAR, 1, @EndDate)
END
ELSE
BEGIN
	IF @ToMonth < 10
		SET	@EndDate = CAST(@ToYear AS NVARCHAR) + N'0' + CAST(@ToMonth AS NVARCHAR) + N'01'
	ELSE
		SET	@EndDate = CAST(@ToYear AS NVARCHAR) + CAST(@ToMonth AS NVARCHAR) + N'01'
	
	SET	@EndDate = DATEADD(MONTH, 1, @EndDate)
END


/*Vet Sanitary Aggregate Matrix that was activated and has the latest Activation Start Date
* , which belongs to the period between first date of the year specified in From Year filter 
* and last date of the year specified in To Year filter, among all activated Vet Sanitary Aggregate Matrices 
* with Activation Start Date belonging to the same period
*/
DECLARE @idfSanitaryVersion BIGINT 

SELECT
	@idfSanitaryVersion = tamvh.idfVersion
FROM dbo.tlbAggrMatrixVersionHeader tamvh
WHERE tamvh.blnIsActive = 1
	AND tamvh.intRowStatus = 0
	AND tamvh.datStartDate BETWEEN @StartDate AND @EndDate
	AND tamvh.idfsMatrixType = @idfsMatrixType
	AND NOT EXISTS (SELECT
						1
					FROM dbo.tlbAggrMatrixVersionHeader tamvh2
					WHERE tamvh2.blnIsActive = 1
						AND tamvh2.intRowStatus = 0
						AND tamvh2.datStartDate BETWEEN @StartDate AND @EndDate
						AND (tamvh2.datStartDate > tamvh.datStartDate
							OR(tamvh2.datStartDate = tamvh.datStartDate AND tamvh2.idfVersion > tamvh.idfVersion)
							)
						AND tamvh2.idfsMatrixType = 71260000000 /*Veterinary-sanitary measures*/)

-- Select report informative part - start
DECLARE	@attr_part_in_report			BIGINT

SELECT	@attr_part_in_report = at.idfAttributeType
FROM	dbo.trtAttributeType at
WHERE	at.strAttributeTypeName = N'attr_part_in_report'


DECLARE	@Sanitary_Number_of_facilities	BIGINT
DECLARE	@Sanitary_Area					BIGINT
DECLARE	@Sanitary_Note					BIGINT

-- Sanitary_Number_of_facilities
SELECT		@Sanitary_Number_of_facilities = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Sanitary_Number_of_facilities'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

-- Sanitary_Area
SELECT		@Sanitary_Area = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Sanitary_Area'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

-- Sanitary_Note
SELECT		@Sanitary_Note = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Sanitary_Note'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0


DECLARE @SpecificOfficeId BIGINT
SELECT
	 @SpecificOfficeId = ts.idfOffice
FROM dbo.tstSite ts 
WHERE ts.intRowStatus = 0
	AND ts.intFlags = 100 /*organization with abbreviation = Baku city VO*/

-- Select aggregate data
DECLARE @MinAdminLevel BIGINT
DECLARE @MinTimeInterval BIGINT
DECLARE @AggrCaseType BIGINT


/*

19000091	rftStatisticPeriodType:
    10091001	sptMonth	Month
    10091002	sptOnday	Day
    10091003	sptQuarter	Quarter
    10091004	sptWeek	Week
    10091005	sptYear	Year

19000089	rftStatisticAreaType
    10089001	satCountry	Country
    10089002	satRayon	Rayon
    10089003	satRegion	Region
    10089004	satSettlement	Settlement


19000102	rftAggregateCaseType:
    10102001  Aggregate Case

*/

SET @AggrCaseType = 10102003 /*Vet Aggregate Action*/

SELECT	@MinAdminLevel = idfsStatisticAreaType,
		@MinTimeInterval = idfsStatisticPeriodType
FROM report.FN_AggregateSettings_GET (@AggrCaseType)

CREATE TABLE	#VetAggregateAction
(	idfAggrCase				BIGINT NOT NULL PRIMARY KEY,
	idfSanitaryObservation	BIGINT,
	datStartDate			DATETIME,
	idfSanitaryVersion		BIGINT
	, idfsRegion BIGINT
	, idfsRayon BIGINT
	, idfsAdministrativeUnit BIGINT
	, datFinishDate DATETIME
)

DECLARE	@idfsCurrentCountry	BIGINT
SELECT	@idfsCurrentCountry = ISNULL(dbo.FN_GBL_CURRENTCOUNTRY_GET(), 170000000) /*Azerbaijan*/

INSERT INTO	#VetAggregateAction
(	idfAggrCase,
	idfSanitaryObservation,
	datStartDate,
	idfSanitaryVersion
	, idfsRegion
	, idfsRayon
	, idfsAdministrativeUnit
	, datFinishDate
)
SELECT		a.idfAggrCase,
			obs.idfObservation,
			a.datStartDate,
			a.idfSanitaryVersion
			, COALESCE(s.idfsRegion, rr.idfsRegion, r.idfsRegion, NULL) AS idfsRegion
			, COALESCE(s.idfsRayon, rr.idfsRayon, NULL) AS idfsRayon
			, a.idfsAdministrativeUnit
			, a.datFinishDate
FROM		dbo.tlbAggrCase a
INNER JOIN	dbo.tlbObservation obs ON obs.idfObservation = a.idfSanitaryObservation
LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c
ON			c.idfsReference = a.idfsAdministrativeUnit
LEFT JOIN	report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) r
ON			r.idfsRegion = a.idfsAdministrativeUnit 
LEFT JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) rr
ON			rr.idfsRayon = a.idfsAdministrativeUnit
LEFT JOIN	report.FN_GBL_GIS_Settlement_GET(@LangID, 19000004 /*Settlement*/) s
ON			s.idfsSettlement = a.idfsAdministrativeUnit
-- Site, Organization entered aggregate action
INNER JOIN	dbo.tstSite sit
	LEFT JOIN dbo.FN_GBL_Institution_Min(@LangID) i
	ON			i.idfOffice = CASE WHEN sit.intFlags = 10 THEN @SpecificOfficeId ELSE sit.idfOffice END
ON			sit.idfsSite = a.idfsSite
WHERE		a.idfsAggrCaseType = @AggrCaseType
-- Time Period satisfies Report Filters
			AND (	@StartDate <= a.datStartDate
					AND a.datFinishDate < @EndDate
				)
	AND (
			(r.idfsRegion = @RegionID OR @RegionID IS NULL)
			OR (
				(rr.idfsRayon = @RayonID OR @RayonID IS NULL) 
				AND (rr.idfsRegion = @RegionID OR @RegionID IS NULL)
				)
			OR (
				a.idfsAdministrativeUnit = s.idfsSettlement
				AND (s.idfsRayon = @RayonID OR @RayonID IS NULL) 
				AND (s.idfsRegion = @RegionID OR @RegionID IS NULL)
				)
		)	
			-- Entered by organization satisfies Report Filters
			AND (@OrganizationEntered IS NULL or (@OrganizationEntered IS NOT NULL AND i.idfOffice = @OrganizationEntered))
			AND a.intRowStatus = 0

	SELECT	
		@MinAdminLevel = idfsStatisticAreaType
		, @MinTimeInterval = idfsStatisticPeriodType
	FROM report.FN_AggregateSettings_GET (10102003 /*Vet Aggregate Action*/)

	DELETE FROM #VetAggregateAction
	WHERE idfAggrCase IN (
		SELECT
			idfAggrCase
		FROM (
			SELECT 
				COUNT(*) OVER (PARTITION BY ac.idfAggrCase) cnt
				, ac2.idfAggrCase
				, CASE 
					WHEN DATEDIFF(YEAR, ac2.datStartDate, ac2.datFinishDate) = 0 AND DATEDIFF(quarter, ac2.datStartDate, ac2.datFinishDate) > 1 
						THEN 10091005 --sptYear
					WHEN DATEDIFF(quarter, ac2.datStartDate, ac2.datFinishDate) = 0 AND DATEDIFF(MONTH, ac2.datStartDate, ac2.datFinishDate) > 1
						THEN 10091003 --sptQuarter
					WHEN DATEDIFF(MONTH, ac2.datStartDate, ac2.datFinishDate) = 0 AND report.FN_GBL_WeekDateDiff_GET(ac2.datStartDate, ac2.datFinishDate) > 1
						THEN 10091001 --sptMonth
					WHEN report.FN_GBL_WeekDateDiff_GET(ac2.datStartDate, ac2.datFinishDate) = 0 AND DATEDIFF(DAY, ac2.datStartDate, ac2.datFinishDate) > 1
						THEN 10091004 --sptWeek
					WHEN DATEDIFF(DAY, ac2.datStartDate, ac2.datFinishDate) = 0
						THEN 10091002 --sptOnday
				END AS TimeInterval
				, CASE
					WHEN ac2.idfsAdministrativeUnit = c2.idfsReference THEN 10089001 --satCountry
					WHEN ac2.idfsAdministrativeUnit = r2.idfsRegion THEN 10089003 --satRegion
					WHEN ac2.idfsAdministrativeUnit = rr2.idfsRayon THEN 10089002 --satRayon
					WHEN ac2.idfsAdministrativeUnit = s2.idfsSettlement THEN 10089004 --satSettlement
				END AS AdminLevel
			FROM #VetAggregateAction ac
			LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c
			ON			c.idfsReference = ac.idfsAdministrativeUnit
			LEFT JOIN	report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) r
			ON			r.idfsRegion = ac.idfsAdministrativeUnit 
			LEFT JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) rr
			ON			rr.idfsRayon = ac.idfsAdministrativeUnit
			LEFT JOIN	report.FN_GBL_GIS_Settlement_GET(@LangID, 19000004 /*Settlement*/) s
			ON			s.idfsSettlement = ac.idfsAdministrativeUnit
			JOIN #VetAggregateAction ac2 ON
				(
					ac2.datStartDate BETWEEN ac.datStartDate AND ac.datFinishDate
					OR ac2.datFinishDate BETWEEN ac.datStartDate AND ac.datFinishDate
				)
			LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c2
			ON			c2.idfsReference = ac2.idfsAdministrativeUnit
			LEFT JOIN	report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) r2
			ON			r2.idfsRegion = ac2.idfsAdministrativeUnit 
			LEFT JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) rr2
			ON			rr2.idfsRayon = ac2.idfsAdministrativeUnit
			LEFT JOIN	report.FN_GBL_GIS_Settlement_GET(@LangID, 19000004 /*Settlement*/) s2
			ON			s2.idfsSettlement = ac2.idfsAdministrativeUnit
			WHERE COALESCE(s2.idfsRayon, rr2.idfsRayon) = ac.idfsAdministrativeUnit
				OR COALESCE(s2.idfsRegion, rr2.idfsRegion, r2.idfsRegion) = ac.idfsAdministrativeUnit
				OR COALESCE(s2.idfsCountry, rr2.idfsCountry, r2.idfsCountry, c2.idfsReference) = ac.idfsAdministrativeUnit
		) a
		WHERE cnt > 1	
			AND CASE WHEN TimeInterval = @MinTimeInterval AND AdminLevel = @MinAdminLevel THEN 1 ELSE 0 END = 0
	)

DECLARE	@VetAggregateActionData	table
(	strKey						NVARCHAR(200) COLLATE database_default NOT NULL PRIMARY KEY,
	idfsSanitaryActiON			BIGINT NOT NULL,
	strMeasureName				NVARCHAR(2000) COLLATE database_default NULL,
	intNumberFacilities			INT NULL,
	intSquare					FLOAT NULL,
	strNote						NVARCHAR(2000) COLLATE database_default NULL,
	SanitaryMeasureOrderColumn	INT NULL,
	MTXOrderColumn				INT NULL
)

DECLARE @NotDeletedAggregateSanitaryAction TABLE (
	[name] NVARCHAR(500)
	, idfsSanitaryAction BIGINT
	, intOrder INT
	, rn INT
)

INSERT INTO @NotDeletedAggregateSanitaryAction
SELECT
	r_sm_actual.[name]
	, r_sm_actual.idfsReference AS idfsSanitaryAction
	, r_sm_actual.intOrder
	, ROW_NUMBER() OVER (PARTITION BY r_sm_actual.[name] ORDER BY r_sm_actual.idfsReference) AS rn
FROM dbo.FN_GBL_Reference_GETList(@LangID, 19000079) r_sm_actual /*Sanitary Measure List*/

INSERT INTO	@VetAggregateActionData
(	strKey,
	idfsSanitaryAction,
	strMeasureName,
	intNumberFacilities,
	intSquare,
	strNote,
	SanitaryMeasureOrderColumn,
	MTXOrderColumn
)
SELECT		CAST(ISNULL(Actual_Measure_Name.idfsSanitaryAction, 
								mtx.idfsSanitaryAction) AS NVARCHAR(20)) AS strKey,
			ISNULL(Actual_Measure_Name.idfsSanitaryAction, mtx.idfsSanitaryAction) AS idfsSanitaryAction,
			ISNULL(r_sm.[name], N'') AS strMeasureName,
			SUM(ISNULL(CAST(Sanitary_Number_of_facilities.varValue AS INT), 0)) AS intNumberFacilities,
			SUM(ISNULL(CAST(Sanitary_Area.varValue AS FLOAT), 0.00)) AS intSquare,
			MAX(left(ISNULL(CAST(Sanitary_Note.varValue AS NVARCHAR), N''), 2000)) AS strNote,
			ISNULL(Actual_Measure_Name.intOrder, ISNULL(r_sm.intOrder, -1000)) AS SanitaryMeasureOrderColumn,
			ISNULL(mtx.intNumRow, -1000) AS MTXOrderColumn

FROM		#VetAggregateAction vaa
-- Matrix version
INNER JOIN	dbo.tlbAggrMatrixVersionHeader h
ON			h.idfsMatrixType = @idfsMatrixType
			AND (	-- Get matrix version selected by the user in aggregate action
					h.idfVersion = vaa.idfSanitaryVersion
					-- If matrix version is not selected by the user in aggregate case, 
					-- then select active matrix with the latest date activation that is earlier than aggregate action start date
					OR (	vaa.idfSanitaryVersion IS NULL 
							AND h.idfVersion = @idfSanitaryVersion
						)
				)
			AND h.intRowStatus = 0
			
-- Matrix row
INNER JOIN	dbo.tlbAggrSanitaryActionMTX mtx
ON			mtx.idfVersion = h.idfVersion
			AND mtx.intRowStatus = 0

-- Measure Name
INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000079) r_sm /*Sanitary Measure List*/
	-- Not deleted species type with the same name
	LEFT JOIN @NotDeletedAggregateSanitaryAction AS Actual_Measure_Name ON
		Actual_Measure_Name.[name] = r_sm.[name] COLLATE Cyrillic_General_CI_AS
		AND Actual_Measure_Name.rn = 1
ON			r_sm.idfsReference = mtx.idfsSanitaryAction

-- Number_of_facilities
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	dbo.tlbActivityParameters ap
 	WHERE	ap.idfObservation = vaa.idfSanitaryObservation
 			AND ap.idfRow = mtx.idfAggrSanitaryActionMTX
			AND ap.idfsParameter = @Sanitary_Number_of_facilities
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			ORDER BY ap.idfActivityParameters ASC
 		) AS  Sanitary_Number_of_facilities

-- Area
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	dbo.tlbActivityParameters ap
 	WHERE	ap.idfObservation = vaa.idfSanitaryObservation
 			AND ap.idfRow = mtx.idfAggrSanitaryActionMTX
			AND ap.idfsParameter = @Sanitary_Area
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			ORDER BY ap.idfActivityParameters ASC
 		) AS  Sanitary_Area

-- Note
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	dbo.tlbActivityParameters ap
 	WHERE	ap.idfObservation = vaa.idfSanitaryObservation
 			AND ap.idfRow = mtx.idfAggrSanitaryActionMTX
			AND ap.idfsParameter = @Sanitary_Note
			AND ap.intRowStatus = 0
			AND ap.varValue IS NOT NULL
 			ORDER BY ap.idfActivityParameters ASC
 		) AS  Sanitary_Note

GROUP BY	CAST(ISNULL(Actual_Measure_Name.idfsSanitaryAction, 
								mtx.idfsSanitaryAction) AS NVARCHAR(20)),
			ISNULL(Actual_Measure_Name.idfsSanitaryAction, mtx.idfsSanitaryAction),
			ISNULL(r_sm.[name], N''),
			ISNULL(Actual_Measure_Name.intOrder, ISNULL(r_sm.intOrder, -1000)),
			ISNULL(mtx.intNumRow, -1000)
/*Condition is not included in the report specification
-- Do not include the rows with Number of facilities = 0 in the report
having		sum(ISNULL(CAST(Sanitary_Number_of_facilities.varValue AS int), 0)) > 0
*/

DECLARE @NotDeletedAggregateSanitaryActionWithoutData TABLE (
	[name] NVARCHAR(500)
	, idfsSanitaryAction BIGINT
	, intOrder INT
	, rn INT
)

INSERT INTO @NotDeletedAggregateSanitaryActionWithoutData
SELECT
	r_sm_actual.[name]
	, r_sm_actual.idfsReference AS idfsSanitaryAction
	, r_sm_actual.intOrder
	, ROW_NUMBER() OVER (PARTITION BY r_sm_actual.[name] ORDER BY r_sm_actual.idfsReference) AS rn
FROM dbo.FN_GBL_Reference_GETList (@LangID, 19000079) r_sm_actual /*Sanitary Measure List*/

-- Return all measures even witout FF values
INSERT INTO	@VetAggregateActionData
(	strKey,
	idfsSanitaryAction,
	strMeasureName,
	intNumberFacilities,
	intSquare,
	strNote,
	SanitaryMeasureOrderColumn,
	MTXOrderColumn
)
SELECT		CAST(ISNULL(Actual_Measure_Name.idfsSanitaryAction, 
								mtx.idfsSanitaryAction) AS NVARCHAR(20)) AS strKey,
			ISNULL(Actual_Measure_Name.idfsSanitaryAction, mtx.idfsSanitaryAction) AS idfsSanitaryAction,
			ISNULL(r_sm.[name], N'') AS strMeasureName,
			0 AS intNumberFacilities,
			CAST(0 AS FLOAT) AS intSquare,
			N'' AS strNote,
			ISNULL(Actual_Measure_Name.intOrder, ISNULL(r_sm.intOrder, -1000)) AS SanitaryMeasureOrderColumn,
			ISNULL(mtx.intNumRow, -1000) AS MTXOrderColumn

FROM		dbo.tlbAggrMatrixVersionHeader h
			
-- Matrix row
INNER JOIN	dbo.tlbAggrSanitaryActionMTX mtx
ON			mtx.idfVersion = h.idfVersion
			AND mtx.intRowStatus = 0

-- Measure Name
INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000079) r_sm /*Sanitary Measure List*/
	-- Not deleted species type with the same name
	LEFT JOIN @NotDeletedAggregateSanitaryActionWithoutData AS Actual_Measure_Name ON
		Actual_Measure_Name.[name] = r_sm.[name] COLLATE Cyrillic_General_CI_AS
		AND Actual_Measure_Name.rn = 1
ON			r_sm.idfsReference = mtx.idfsSanitaryAction
LEFT JOIN	@VetAggregateActionData vaad
ON			vaad.strKey = CAST(ISNULL(Actual_Measure_Name.idfsSanitaryAction, 
								mtx.idfsSanitaryAction) AS NVARCHAR(20))
WHERE		h.idfVersion = @idfSanitaryVersion
			AND vaad.strKey IS NULL

-- Fill result table
INSERT INTO	@Result
(	strKey,
	strMeasureName,
	SanitaryMeasureOrderColumn,
	intNumberFacilities,
	intSquare,
	strNote
)
SELECT		a.strKey,
			a.strMeasureName,
			ISNULL(a.MTXOrderColumn, a.SanitaryMeasureOrderColumn),
			a.intNumberFacilities,
			a.intSquare,
			CASE
				WHEN	@FromYear = @ToYear
						and	@FromMonth = @ToMonth
					THEN	a.strNote
				ELSE	N''
			END
FROM		@VetAggregateActionData a
-- SELECT report informative part - start

-- Return results
IF (SELECT COUNT(*) FROM @result) = 0
	SELECT	CAST('' AS NVARCHAR(200)) AS strKey,
	CAST('' AS NVARCHAR(2000)) AS strMeasureName,
	CAST(NULL AS INT) AS SanitaryMeasureOrderColumn,
	CAST(NULL AS INT) AS intNumberFacilities, 
	CAST(null AS FLOAT) AS intSquare, 
	CAST(null AS NVARCHAR(2000)) AS strNote,
	0 AS blnAdditionalText
ELSE
	SELECT * FROM @result ORDER BY strMeasureName

-- Drop temporary tables
IF Object_ID('tempdb..#VetAggregateAction') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetAggregateAction'
	EXECUTE sp_executesql @drop_cmd
END

END
GO
PRINT N'Altering Procedure [Report].[USP_REP_VET_Form1AVaccinationMeasuresAZ]...';


GO


--##SUMMARY Select data for REPORT ON ACTIONS TAKEN AGAINST EPIZOOTIC: Diagnostic investigations report.

--##RETURNS Doesn't use

/*
--Example of a call of procedure:
EXEC report.USP_REP_VET_Form1AVaccinationMeasuresAZ 'en',2014,2016
EXEC report.USP_REP_VET_Form1AVaccinationMeasuresAZ 'ru',2017,2018
EXEC report.USP_REP_VET_Form1AVaccinationMeasuresAZ @LangID=N'en', @FromYear = 2016, @ToYear = 2016, @FromMonth = 1, @ToMonth = 11, @RegionID = 1344340000000, @RayonID = 1344870000000
*/
ALTER PROCEDURE [Report].[USP_REP_VET_Form1AVaccinationMeasuresAZ]
    (
      @LangID AS NVARCHAR(10)
    , @FromYear AS INT
	, @ToYear AS INT
	, @FromMonth AS INT = NULL
	, @ToMonth AS INT = NULL
	, @RegionID AS BIGINT = NULL
	, @RayonID AS BIGINT = NULL
	, @OrganizationEntered AS BIGINT = NULL
	, @OrganizationID AS BIGINT = NULL
    )
WITH RECOMPILE
AS
BEGIN


DECLARE	@drop_cmd	NVARCHAR(4000)

-- Drop temporary tables
IF Object_ID('tempdb..#VetAggregateAction') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetAggregateAction'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#VetCaseData') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetCaseData'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#VetAggregateActionData') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetAggregateActionData'
	EXECUTE sp_executesql @drop_cmd
END


DECLARE @Result AS TABLE
(
	strDiagnosisSpeciesKey	NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL PRIMARY KEY,
	strMeasureName			NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	idfsDiagnosis			BIGINT NOT NULL,
	idfsProphylacticAction	BIGINT NOT NULL,
	idfsSpeciesType			BIGINT NOT NULL,
	strDiagnosisName		NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	strOIECode				NVARCHAR(200) COLLATE Cyrillic_General_CI_AS NULL,
	strSpecies				NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	intActionTaken			INT NULL,
	strNote					NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	InvestigationOrderColumn	INT NULL,
	SpeciesOrderColumn		INT NULL,
	DiagnosisOrderColumn	INT NULL,
	blnAdditionalText		BIT
)


DECLARE	@idfsSummaryReportType	BIGINT
SET	@idfsSummaryReportType = 10290034	-- Veterinary Report Form Vet 1A - Prophylactics

DECLARE	@idfsMatrixType	BIGINT
SET	@idfsMatrixType = 71300000000	-- Treatment-prophylactics AND vaccination measures


-- Specify the value of missing month IF remaining month is specified in interval (1-12)
IF	@FromMonth IS NULL AND @ToMonth IS NOT NULL AND @ToMonth >= 1 AND @ToMonth <= 12
	SET	@FromMonth = 1
IF	@ToMonth IS NULL AND @FromMonth IS NOT NULL AND @FromMonth >= 1 AND @FromMonth <= 12
	SET	@ToMonth = 12

-- Calculate Start and End dates for conditions: Start Date <= date from Vet Case < End date
DECLARE	@StartDate	date
DECLARE	@EndDate	date

IF	@FromMonth IS NULL or @FromMonth < 1 or @FromMonth > 12
	SET	@StartDate = CAST(@FromYear AS NVARCHAR) + N'0101'
ELSE IF @FromMonth < 10
	SET	@StartDate = CAST(@FromYear AS NVARCHAR) + N'0' + CAST(@FromMonth AS NVARCHAR) + N'01'
ELSE
	SET	@StartDate = CAST(@FromYear AS NVARCHAR) + CAST(@FromMonth AS NVARCHAR) + N'01'

IF	@ToMonth IS NULL OR @ToMonth < 1 or @ToMonth > 12
BEGIN
	SET	@EndDate = CAST(@ToYear AS NVARCHAR) + N'0101'
	SET	@EndDate = DATEADD(YEAR, 1, @EndDate)
END
ELSE
BEGIN
	IF @ToMonth < 10
		SET	@EndDate = CAST(@ToYear AS NVARCHAR) + N'0' + CAST(@ToMonth AS NVARCHAR) + N'01'
	ELSE
		SET	@EndDate = CAST(@ToYear AS NVARCHAR) + CAST(@ToMonth AS NVARCHAR) + N'01'
	
	SET	@EndDate = DATEADD(MONTH, 1, @EndDate)
END

-- Select report informative part - start

DECLARE	@vet_form_1_use_specific_gis	BIGINT
DECLARE	@vet_form_1_specific_gis_region	BIGINT
DECLARE	@vet_form_1_specific_gis_rayon	BIGINT
DECLARE	@attr_part_in_report			BIGINT

SELECT	@vet_form_1_use_specific_gis = at.idfAttributeType
FROM	trtAttributeType at
WHERE	at.strAttributeTypeName = N'vet_form_1_use_specific_gis'

SELECT	@vet_form_1_specific_gis_region = at.idfAttributeType
FROM	trtAttributeType at
WHERE	at.strAttributeTypeName = N'vet_form_1_specific_gis_region'

SELECT	@vet_form_1_specific_gis_rayon = at.idfAttributeType
FROM	trtAttributeType at
WHERE	at.strAttributeTypeName = N'vet_form_1_specific_gis_rayon'

SELECT	@attr_part_in_report = at.idfAttributeType
FROM	trtAttributeType at
WHERE	at.strAttributeTypeName = N'attr_part_in_report'

DECLARE @SpecificOfficeId BIGINT
SELECT
	 @SpecificOfficeId = ts.idfOffice
FROM tstSite ts 
WHERE ts.intRowStatus = 0
	AND ts.intFlags = 100 /*organization with abbreviation = Baku city VO*/

DECLARE	@Prophylactics_Livestock_Treated_number	BIGINT
DECLARE	@Prophylactics_Avian_Treated_number		BIGINT

DECLARE	@Prophylactics_Aggr_Action_taken		BIGINT
DECLARE	@Prophylactics_Aggr_Note				BIGINT

-- Prophylactics_Livestock_Treated_number
SELECT		@Prophylactics_Livestock_Treated_number = p.idfsParameter
FROM		trtFFObjectForCustomReport ff_for_cr
INNER JOIN	ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Prophylactics_Livestock_Treated_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

-- Prophylactics_Avian_Treated_number
SELECT		@Prophylactics_Avian_Treated_number = p.idfsParameter
FROM		trtFFObjectForCustomReport ff_for_cr
INNER JOIN	ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Prophylactics_Avian_Treated_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

-- Prophylactics_Aggr_Action_taken
SELECT		@Prophylactics_Aggr_Action_taken = p.idfsParameter
FROM		trtFFObjectForCustomReport ff_for_cr
INNER JOIN	ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Prophylactics_Aggr_Action_taken'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

-- Prophylactics_Aggr_Note
SELECT		@Prophylactics_Aggr_Note = p.idfsParameter
FROM		trtFFObjectForCustomReport ff_for_cr
INNER JOIN	ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Prophylactics_Aggr_Note'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0


-- Treatment - Prophylactic measure for data from Vet Case
DECLARE	@Treatment				BIGINT
DECLARE	@Treatment_Translation	NVARCHAR(2000)

SELECT		@Treatment = rat.idfsReference,
			@Treatment_Translation = rat.[name]
FROM		trtBaseReferenceAttribute bra
INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000132) rat	/*Report Additional Text*/
ON			rat.idfsReference = bra.idfsBaseReference
WHERE		bra.idfAttributeType = @attr_part_in_report
			AND CAST(bra.varValue AS NVARCHAR) = CAST(@idfsSummaryReportType AS NVARCHAR(20))
			AND bra.strAttributeItem = N'Name of measure'

IF	@Treatment IS NULL
	SET	@Treatment = -1
IF	@Treatment_Translation IS NULL
	SET	@Treatment_Translation = N''

-- Included state sector - note for data from Vet Cases connecting to the farms, 
-- which have ownership structure = State Farm AND are counted for the report
DECLARE	@Included_state_sector				BIGINT
DECLARE	@Included_state_sector_Translation	NVARCHAR(2000)

SELECT		@Included_state_sector = rat.idfsReference,
			@Included_state_sector_Translation = rat.[name]
FROM		trtBaseReferenceAttribute bra
INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000132) rat	/*Report Additional Text*/
ON			rat.idfsReference = bra.idfsBaseReference
WHERE		bra.idfAttributeType = @attr_part_in_report
			AND CAST(bra.varValue AS NVARCHAR) = CAST(@idfsSummaryReportType AS NVARCHAR(20))
			AND bra.strAttributeItem = N'Note - Prophylactics'

IF	@Included_state_sector IS NULL
	SET	@Included_state_sector = -1
IF	@Included_state_sector_Translation IS NULL
	SET	@Included_state_sector_Translation = N''




-- Vet Case data
create table	#VetCaseData
(	strDiagnosisSpeciesKey			NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL PRIMARY KEY,
	idfsDiagnosis					BIGINT NOT NULL,
	idfsProphylacticActiON			BIGINT NOT NULL,
	idfsSpeciesType					BIGINT NOT NULL,
	strMeasureName					NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	strDiagnosisName				NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	strOIECode						NVARCHAR(200) COLLATE Cyrillic_General_CI_AS NULL,
	strSpecies						NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	intActionTaken					INT NULL,
	blnAddNote						INT NULL default (0),
	SpeciesOrderColumn				INT NULL,
	DiagnosisOrderColumn			INT NULL
)



DECLARE	@NotDeletedCaseBasedDiagnosis table
(	idfsDiagnosis		BIGINT NOT NULL PRIMARY KEY,
	[name]				NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	intOrder			INT NULL,
	strOIECode			NVARCHAR(200) COLLATE Cyrillic_General_CI_AS NULL, 
	idfsActualDiagnosis	BIGINT NOT NULL
)

INSERT INTO	@NotDeletedCaseBasedDiagnosis
(	idfsDiagnosis,
	[name],
	intOrder,
	strOIECode,
	idfsActualDiagnosis
)
SELECT
			r_d.idfsReference AS idfsDiagnosis
			, r_d.[name] AS [name]
			, CASE
				WHEN	actual_diagnosis.idfsDiagnosis IS NOT NULL
					then actual_diagnosis.intOrder
				ELSE	r_d.intOrder
			  END AS INTOrder
			, CASE
				WHEN	actual_diagnosis.idfsDiagnosis IS NOT NULL
					then actual_diagnosis.strOIECode
				ELSE	d.strOIECode
			  END AS strOIECode
			, ISNULL(actual_diagnosis.idfsDiagnosis, r_d.idfsReference) AS idfsActualDiagnosis
FROM		dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) r_d
LEFT JOIN	trtDiagnosis d
ON			d.idfsDiagnosis = r_d.idfsReference
LEFT JOIN	(
	SELECT	d_actual.idfsDiagnosis,
			r_d_actual.[name],
			r_d_actual.intOrder,
			d_actual.strOIECode,
			ROW_NUMBER() OVER (PARTITION BY r_d_actual.[name] ORDER BY d_actual.idfsDiagnosis) AS rn
	FROM		trtDiagnosis d_actual
	INNER JOIN	dbo.FN_GBL_Reference_GETList('en', 19000019) r_d_actual
	ON			r_d_actual.idfsReference = d_actual.idfsDiagnosis
	WHERE		d_actual.idfsUsingType = 10020001	/*Case-based*/
				AND d_actual.intRowStatus = 0
			) actual_diagnosis
	ON		actual_diagnosis.[name] = r_d.[name] COLLATE Cyrillic_General_CI_AS
			AND actual_diagnosis.rn = 1

DECLARE	@NotDeletedAggregateDiagnosis table
(	idfsDiagnosis		BIGINT NOT NULL PRIMARY KEY,
	[name]				NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	intOrder			INT NULL,
	strOIECode			NVARCHAR(200) COLLATE Cyrillic_General_CI_AS NULL, 
	idfsActualDiagnosis	BIGINT NOT NULL
)

INSERT INTO	@NotDeletedAggregateDiagnosis
(	idfsDiagnosis,
	[name],
	intOrder,
	strOIECode,
	idfsActualDiagnosis
)
SELECT
			r_d.idfsReference AS idfsDiagnosis
			, r_d.[name] AS [name]
			, CASE
				WHEN	actual_diagnosis.idfsDiagnosis IS NOT NULL
					THEN actual_diagnosis.intOrder
				ELSE	r_d.intOrder
			  END AS INTOrder
			, CASE
				WHEN	actual_diagnosis.idfsDiagnosis IS NOT NULL
					then actual_diagnosis.strOIECode
				ELSE	d.strOIECode
			  END AS strOIECode
			, ISNULL(actual_diagnosis.idfsDiagnosis, r_d.idfsReference) AS idfsActualDiagnosis
FROM		dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) r_d
LEFT JOIN	trtDiagnosis d
ON			d.idfsDiagnosis = r_d.idfsReference
LEFT JOIN	(
	SELECT	d_actual.idfsDiagnosis,
			r_d_actual.[name],
			r_d_actual.intOrder,
			d_actual.strOIECode,
			ROW_NUMBER() OVER (PARTITION BY r_d_actual.[name] ORDER BY d_actual.idfsDiagnosis) AS rn
	FROM		trtDiagnosis d_actual
	INNER JOIN	dbo.FN_GBL_Reference_GETList('en', 19000019) r_d_actual
	ON			r_d_actual.idfsReference = d_actual.idfsDiagnosis
	WHERE		d_actual.idfsUsingType = 10020002	/*Aggregate*/
				AND d_actual.intRowStatus = 0
			) actual_diagnosis
	ON		actual_diagnosis.[name] = r_d.[name] COLLATE Cyrillic_General_CI_AS
			AND actual_diagnosis.rn = 1


DECLARE	@NotDeletedSpecies table
(	idfsSpeciesType			BIGINT NOT NULL PRIMARY KEY,
	[name]					NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	intOrder				INT NULL,
	idfsActualSpeciesType	BIGINT NOT NULL
)

INSERT INTO	@NotDeletedSpecies
(	idfsSpeciesType,
	[name],
	intOrder,
	idfsActualSpeciesType
)
SELECT
			r_sp.idfsReference AS idfsSpeciesType
			, CAST(r_sp.[name] AS NVARCHAR(2000)) AS [name]
			, CASE
				WHEN	actual_SpeciesType.idfsSpeciesType IS NOT NULL
					then actual_SpeciesType.intOrder
				ELSE	r_sp.intOrder
			  END AS INTOrder
			, ISNULL(actual_SpeciesType.idfsSpeciesType, r_sp.idfsReference) AS idfsActualSpeciesType
FROM		dbo.FN_GBL_ReferenceRepair(@LangID, 19000086) r_sp
LEFT JOIN	(
	SELECT	st_actual.idfsSpeciesType,
			r_st_actual.[name],
			r_st_actual.intOrder,
			ROW_NUMBER() OVER (PARTITION BY r_st_actual.[name] ORDER BY st_actual.idfsSpeciesType) AS rn
	FROM		trtSpeciesType st_actual
	INNER JOIN	dbo.FN_GBL_Reference_GETList('en', 19000086) r_st_actual
	ON			r_st_actual.idfsReference = st_actual.idfsSpeciesType
	WHERE		st_actual.intRowStatus = 0
		) actual_SpeciesType
ON		actual_SpeciesType.[name] = r_sp.[name] COLLATE Cyrillic_General_CI_AS
		AND actual_SpeciesType.rn = 1


DECLARE @NotDeletedProphylacticAction TABLE
(	idfsProphylacticActiON			BIGINT NOT NULL PRIMARY KEY,
	[name]							NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	intOrder						INT NULL,
	idfsActualProphylacticAction	BIGINT NOT NULL
)

INSERT INTO	@NotDeletedProphylacticAction
(	idfsProphylacticAction,
	[name],
	intOrder,
	idfsActualProphylacticAction
)
SELECT
			r_pm.idfsReference AS idfsProphylacticAction
			, CAST(r_pm.[name] AS NVARCHAR(2000)) AS [name]
			, CASE
				WHEN	actual_ProphylacticAction.idfsProphylacticAction IS NOT NULL
					then actual_ProphylacticAction.intOrder
				ELSE	r_pm.intOrder
			  END AS INTOrder
			, ISNULL(actual_ProphylacticAction.idfsProphylacticAction, r_pm.idfsReference) AS idfsActualProphylacticAction
FROM		dbo.FN_GBL_ReferenceRepair(@LangID, 19000074/*Prophylactic Measure List*/) r_pm
LEFT JOIN	(
	SELECT	pa_actual.idfsProphilacticAction AS idfsProphylacticAction,
			r_pa_actual.[name],
			r_pa_actual.intOrder,
			ROW_NUMBER() OVER (PARTITION BY r_pa_actual.[name] ORDER BY pa_actual.idfsProphilacticAction) AS rn
	FROM		trtProphilacticAction pa_actual
	INNER JOIN	dbo.FN_GBL_Reference_GETList('en', 19000074/*Prophylactic Measure List*/) r_pa_actual
	ON			r_pa_actual.idfsReference = pa_actual.idfsProphilacticAction
	WHERE		pa_actual.intRowStatus = 0
		) actual_ProphylacticAction
ON		actual_ProphylacticAction.[name] = r_pm.[name] COLLATE Cyrillic_General_CI_AS
		AND actual_ProphylacticAction.rn = 1


INSERT INTO	#VetCaseData
(	strDiagnosisSpeciesKey,
	idfsDiagnosis,
	idfsProphylacticAction,
	idfsSpeciesType,
	strMeasureName,
	strDiagnosisName,
	strOIECode,
	strSpecies,
	intActionTaken,
	blnAddNote,
	SpeciesOrderColumn,
	DiagnosisOrderColumn
)
SELECT		(CAST(Actual_Diagnosis.idfsActualDiagnosis AS NVARCHAR(20)) + N'_' + 
				CAST(Actual_Species_Type.idfsActualSpeciesType AS NVARCHAR(20)) + N'_' + 
				CAST(ISNULL(@Treatment, -1) AS NVARCHAR(20))) COLLATE Latin1_General_CI_AS AS strDiagnosisSpeciesKey,
			Actual_Diagnosis.idfsActualDiagnosis AS idfsDiagnosis,
			ISNULL(@Treatment, -1) AS idfsProphylacticAction,
			Actual_Species_Type.idfsActualSpeciesType AS idfsSpeciesType,
			@Treatment_Translation,
			ISNULL(Actual_Diagnosis.[name], N'') AS strDiagnosisName,
			ISNULL(Actual_Diagnosis.strOIECode, N'') AS strOIECode,
			ISNULL(Actual_Species_Type.[name], N'') AS strSpecies,
			SUM(ISNULL(CAST(Treated_number.varValue AS INT), 0)) AS INTActionTaken,
			SUM(CAST((ISNULL(fot.idfsReference, 0) / 10820000000) AS INT)) AS blnAddNote, /*State Farm*/
			ISNULL(Actual_Species_Type.intOrder, -1000) AS SpeciesOrderColumn,
			ISNULL(Actual_Diagnosis.intOrder, -1000) AS DiagnosisOrderColumn
FROM		
-- Veterinary Case
			tlbVetCase vc

-- Diagnosis = Final Diagnosis of Veterinary Case
INNER JOIN	@NotDeletedCaseBasedDiagnosis AS Actual_Diagnosis ON
	Actual_Diagnosis.idfsDiagnosis = VC.idfsFinalDiagnosis


-- Species - start
INNER JOIN	tlbFarm f

	-- Region AND Rayon
	LEFT JOIN	tlbGeoLocation gl
		LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) reg
		ON			reg.idfsReference = gl.idfsRegion
		LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) ray
		ON			ray.idfsReference = gl.idfsRayon
	ON			gl.idfGeoLocation = f.idfFarmAddress

	-- State Farm
	LEFT JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000065) fot	/*Farm Ownership Type*/
	ON			fot.idfsReference = f.idfsOwnershipStructure
				AND fot.idfsReference = 10820000000 /*State Farm*/
ON			f.idfFarm = vc.idfFarm
			AND f.intRowStatus = 0
INNER JOIN	tlbHerd h
ON			h.idfFarm = f.idfFarm
			AND h.intRowStatus = 0
INNER JOIN	tlbSpecies sp
	INNER JOIN	@NotDeletedSpecies AS Actual_Species_Type ON
		Actual_Species_Type.idfsSpeciesType = sp.idfsSpeciesType
ON			sp.idfHerd = h.idfHerd
			AND sp.intRowStatus = 0
			-- Sick + Dead > 0
			AND ISNULL(sp.intDeadAnimalQty, 0) + ISNULL(sp.intSickAnimalQty, 0) > 0
			-- Total > 0
			AND ISNULL(sp.intTotalAnimalQty, 0) > 0

-- Species - end

-- Site, Organization entered case
INNER JOIN	tstSite s
	LEFT JOIN	dbo.FN_GBL_Institution_Min(@LangID) i
	ON			i.idfOffice = CASE WHEN s.intFlags = 10 THEN @SpecificOfficeId ELSE s.idfOffice END
ON			s.idfsSite = vc.idfsSite

-- Specific Region and Rayon for the site with specific attributes (B46)
LEFT JOIN	trtBaseReferenceAttribute bra
	LEFT JOIN	trtGISBaseReferenceAttribute gis_bra_region
		INNER JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) reg_specific
		ON			reg_specific.idfsReference = gis_bra_region.idfsGISBaseReference
	ON			CAST(gis_bra_region.varValue AS NVARCHAR) = CAST(bra.varValue AS NVARCHAR)
				AND gis_bra_region.idfAttributeType = @vet_form_1_specific_gis_region
	LEFT JOIN	trtGISBaseReferenceAttribute gis_bra_rayon
		INNER JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) ray_specific
		ON			ray_specific.idfsReference = gis_bra_rayon.idfsGISBaseReference
	ON			CAST(gis_bra_rayon.varValue AS NVARCHAR) = CAST(bra.varValue AS NVARCHAR)
				AND gis_bra_rayon.idfAttributeType = @vet_form_1_specific_gis_rayon
ON			bra.idfsBaseReference = i.idfsOfficeAbbreviation
			AND bra.idfAttributeType = @vet_form_1_use_specific_gis
			AND CAST(bra.varValue AS NVARCHAR) = s.strSiteID

-- Species Observation
LEFT JOIN	tlbObservation	obs
ON			obs.idfObservation = sp.idfObservation


-- FF: Treated number
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	tlbActivityParameters ap
 	WHERE	ap.idfObservation = obs.idfObservation
			AND ap.idfsParameter in (@Prophylactics_Livestock_Treated_number, @Prophylactics_Avian_Treated_number)
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			order by ap.idfRow asc
 		) AS  Treated_number

WHERE		vc.intRowStatus = 0
			-- Case Classification = Confirmed
			AND vc.idfsCaseClassification = 350000000	/*Confirmed*/
			
			-- FF: Treated number > 0
			AND CAST(Treated_number.varValue AS INT) > 0

			-- From Year, Month To Year, Month
			AND ISNULL(vc.datFinalDiagnosisDate, vc.datTentativeDiagnosis1Date) >= @StartDate
			AND ISNULL(vc.datFinalDiagnosisDate, vc.datTentativeDiagnosis1Date) < @EndDate
			
			-- Region
			AND (@RegionID IS NULL or (@RegionID IS NOT NULL AND ISNULL(reg_specific.idfsReference, reg.idfsReference) = @RegionID))
			-- Rayon
			AND (@RayonID IS NULL or (@RayonID IS NOT NULL AND ISNULL(ray_specific.idfsReference, ray.idfsReference) = @RayonID))
			
			-- Entered by organization
			AND (@OrganizationEntered IS NULL or (@OrganizationEntered IS NOT NULL AND i.idfOffice = @OrganizationEntered))

GROUP BY	CAST(Actual_Diagnosis.idfsActualDiagnosis AS NVARCHAR(20)) + N'_' + 
				CAST(Actual_Species_Type.idfsActualSpeciesType AS NVARCHAR(20)) + N'_' + 
				CAST(ISNULL(@Treatment, -1) AS NVARCHAR(20)) COLLATE Latin1_General_CI_AS,
			Actual_Diagnosis.idfsActualDiagnosis,
			Actual_Species_Type.idfsActualSpeciesType,
			ISNULL(Actual_Diagnosis.[name], N''),
			ISNULL(Actual_Diagnosis.strOIECode, N''),
			ISNULL(Actual_Species_Type.[name], N''),
			ISNULL(Actual_Species_Type.intOrder, -1000),
			ISNULL(Actual_Diagnosis.intOrder, -1000)


-- SELECT aggregate data
DECLARE @MinAdminLevel BIGINT
DECLARE @MinTimeInterval BIGINT
DECLARE @AggrCaseType BIGINT



SET @AggrCaseType = 10102003 /*Vet Aggregate Action*/

SELECT	@MinAdminLevel = idfsStatisticAreaType,
		@MinTimeInterval = idfsStatisticPeriodType
FROM report.FN_AggregateSettings_GET (@AggrCaseType)

create TABLE	#VetAggregateAction
(	idfAggrCase					BIGINT NOT NULL PRIMARY KEY,
	idfProphylacticObservation	BIGINT,
	datStartDate				datetime,
	idfProphylacticVersion		BIGINT
	, idfsRegion BIGINT
	, idfsRayon BIGINT
	, idfsAdministrativeUnit BIGINT
	, datFinishDate DATETIME
)

DECLARE	@idfsCurrentCountry	BIGINT
SELECT	@idfsCurrentCountry = ISNULL(dbo.FN_GBL_CURRENTCOUNTRY_GET(), 170000000) /*Azerbaijan*/

INSERT INTO	#VetAggregateAction
(	idfAggrCase,
	idfProphylacticObservation,
	datStartDate,
	idfProphylacticVersion
	, idfsRegion
	, idfsRayon
	, idfsAdministrativeUnit
	, datFinishDate
)
SELECT		a.idfAggrCase,
			obs.idfObservation,
			a.datStartDate,
			a.idfProphylacticVersion
			, COALESCE(s.idfsRegion, rr.idfsRegion, r.idfsRegion, NULL) AS idfsRegion
			, COALESCE(s.idfsRayon, rr.idfsRayon, NULL) AS idfsRayon
			, a.idfsAdministrativeUnit
			, a.datFinishDate
FROM		tlbAggrCase a
INNER JOIN	tlbObservation obs
ON			obs.idfObservation = a.idfProphylacticObservation
LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c
ON			c.idfsReference = a.idfsAdministrativeUnit
LEFT JOIN	report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) r
ON			r.idfsRegion = a.idfsAdministrativeUnit 
LEFT JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) rr
ON			rr.idfsRayon = a.idfsAdministrativeUnit
LEFT JOIN	report.FN_GBL_GIS_Settlement_GET(@LangID, 19000004 /*Settlement*/) s
ON			s.idfsSettlement = a.idfsAdministrativeUnit

-- Site, Organization entered aggregate action
INNER JOIN	tstSite sit
	LEFT JOIN	dbo.FN_GBL_Institution_Min(@LangID) i
	ON			i.idfOffice = sit.idfOffice
ON			sit.idfsSite = a.idfsSite

WHERE		a.idfsAggrCaseType = @AggrCaseType
-- Time Period satisfies Report Filters
			AND (	@StartDate <= a.datStartDate
					AND a.datFinishDate < @EndDate
			)
			
	AND (
			(r.idfsRegion = @RegionID OR @RegionID IS NULL)
			OR (
				(rr.idfsRayon = @RayonID OR @RayonID IS NULL) 
				AND (rr.idfsRegion = @RegionID OR @RegionID IS NULL)
				)
			OR (
				a.idfsAdministrativeUnit = s.idfsSettlement
				AND (s.idfsRayon = @RayonID OR @RayonID IS NULL) 
				AND (s.idfsRegion = @RegionID OR @RegionID IS NULL)
				)
		)			
			-- Entered by organization satisfies Report Filters
			AND (@OrganizationEntered IS NULL or (@OrganizationEntered IS NOT NULL AND i.idfOffice = @OrganizationEntered))

			AND a.intRowStatus = 0


	SELECT	
		@MinAdminLevel = idfsStatisticAreaType
		, @MinTimeInterval = idfsStatisticPeriodType
	FROM report.FN_AggregateSettings_GET (10102003 /*Vet Aggregate Action*/)
	

	DELETE FROM #VetAggregateAction
	WHERE idfAggrCase IN (
		SELECT
			idfAggrCase
		FROM (
			SELECT 
				COUNT(*) OVER (PARTITION BY ac.idfAggrCase) cnt
				, ac2.idfAggrCase
				, CASE 
					WHEN DATEDIFF(YEAR, ac2.datStartDate, ac2.datFinishDate) = 0 AND DATEDIFF(quarter, ac2.datStartDate, ac2.datFinishDate) > 1 
						THEN 10091005 --sptYear
					WHEN DATEDIFF(quarter, ac2.datStartDate, ac2.datFinishDate) = 0 AND DATEDIFF(MONTH, ac2.datStartDate, ac2.datFinishDate) > 1
						THEN 10091003 --sptQuarter
					WHEN DATEDIFF(MONTH, ac2.datStartDate, ac2.datFinishDate) = 0 AND report.FN_GBL_WeekDateDiff_GET(ac2.datStartDate, ac2.datFinishDate) > 1
						THEN 10091001 --sptMonth
					WHEN report.FN_GBL_WeekDateDiff_GET(ac2.datStartDate, ac2.datFinishDate) = 0 AND DATEDIFF(DAY, ac2.datStartDate, ac2.datFinishDate) > 1
						THEN 10091004 --sptWeek
					WHEN DATEDIFF(DAY, ac2.datStartDate, ac2.datFinishDate) = 0
						THEN 10091002 --sptOnday
				END AS TimeInterval
				, CASE
					WHEN ac2.idfsAdministrativeUnit = c2.idfsReference THEN 10089001 --satCountry
					WHEN ac2.idfsAdministrativeUnit = r2.idfsRegion THEN 10089003 --satRegion
					WHEN ac2.idfsAdministrativeUnit = rr2.idfsRayon THEN 10089002 --satRayon
					WHEN ac2.idfsAdministrativeUnit = s2.idfsSettlement THEN 10089004 --satSettlement
				END AS AdminLevel
			FROM #VetAggregateAction ac
			LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c
			ON			c.idfsReference = ac.idfsAdministrativeUnit
			LEFT JOIN	report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) r
			ON			r.idfsRegion = ac.idfsAdministrativeUnit 
			LEFT JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) rr
			ON			rr.idfsRayon = ac.idfsAdministrativeUnit
			LEFT JOIN	report.FN_GBL_GIS_Settlement_GET(@LangID, 19000004 /*Settlement*/) s
			ON			s.idfsSettlement = ac.idfsAdministrativeUnit
				
			JOIN #VetAggregateAction ac2 ON
				(
					ac2.datStartDate BETWEEN ac.datStartDate AND ac.datFinishDate
					OR ac2.datFinishDate BETWEEN ac.datStartDate AND ac.datFinishDate
				)
				
			LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c2
			ON			c2.idfsReference = ac2.idfsAdministrativeUnit
			LEFT JOIN	report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) r2
			ON			r2.idfsRegion = ac2.idfsAdministrativeUnit 
			LEFT JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) rr2
			ON			rr2.idfsRayon = ac2.idfsAdministrativeUnit
			LEFT JOIN	report.FN_GBL_GIS_Settlement_GET(@LangID, 19000004 /*Settlement*/) s2
			ON			s2.idfsSettlement = ac2.idfsAdministrativeUnit
			
			WHERE COALESCE(s2.idfsRayon, rr2.idfsRayon) = ac.idfsAdministrativeUnit
				OR COALESCE(s2.idfsRegion, rr2.idfsRegion, r2.idfsRegion) = ac.idfsAdministrativeUnit
				OR COALESCE(s2.idfsCountry, rr2.idfsCountry, r2.idfsCountry, c2.idfsReference) = ac.idfsAdministrativeUnit
		) a
		WHERE cnt > 1	
			AND CASE WHEN TimeInterval = @MinTimeInterval AND AdminLevel = @MinAdminLevel THEN 1 ELSE 0 END = 0
	)


create TABLE	#VetAggregateActionData
(	strDiagnosisSpeciesKey		NVARCHAR(200) COLLATE Latin1_General_CI_AS not null PRIMARY KEY,
	idfsDiagnosis				BIGINT NOT NULL,
	idfsProphylacticAction		BIGINT NOT NULL,
	idfsSpeciesType				BIGINT NOT NULL,
	strMeasureName				NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	strDiagnosisName			NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	strOIECode					NVARCHAR(200) COLLATE Cyrillic_General_CI_AS NULL,
	strSpecies					NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	intActionTaken				INT NULL,
	strNote						NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	SpeciesOrderColumn			INT NULL,
	DiagnosisOrderColumn		INT NULL,
	InvestigationOrderColumn	INT NULL
)


INSERT INTO	#VetAggregateActionData
(	strDiagnosisSpeciesKey,
	idfsDiagnosis,
	idfsProphylacticAction,
	idfsSpeciesType,
	strMeasureName,
	strDiagnosisName,
	strOIECode,
	strSpecies,
	intActionTaken,
	strNote,
	SpeciesOrderColumn,
	DiagnosisOrderColumn,
	InvestigationOrderColumn
)
SELECT		CAST(ndad.idfsActualDiagnosis AS NVARCHAR(20)) + N'_' + 
				CAST(nds.idfsActualSpeciesType AS NVARCHAR(20)) + N'_' + 
				CAST(ndpa.idfsActualProphylacticAction AS NVARCHAR(20)) COLLATE Latin1_General_CI_AS AS strDiagnosisSpeciesKey,
			ndad.idfsActualDiagnosis AS idfsDiagnosis,
			ndpa.idfsActualProphylacticAction AS idfsProphylacticAction,
			nds.idfsActualSpeciesType AS idfsSpeciesType,
			ISNULL(ndpa.[name], N'') AS strMeasureName,
			ISNULL(ndad.[name], N'') AS strDiagnosisName,
			ISNULL(ndad.strOIECode, N'') AS strOIECode,
			ISNULL(nds.[name], N'') AS strSpecies,
			SUM(ISNULL(CAST(Action_taken.varValue AS INT), 0)) AS INTTested,
			max(left(ISNULL(CAST(Prophylactics_Note.varValue AS NVARCHAR), N''), 2000)) AS INTPositivaReaction,
			ISNULL(nds.intOrder, -1000) AS SpeciesOrderColumn,
			ISNULL(ndad.intOrder, -1000) AS DiagnosisOrderColumn,
			ISNULL(ndpa.intOrder, -1000) AS InvestigationOrderColumn
FROM		#VetAggregateAction vaa
-- Matrix version
INNER JOIN	tlbAggrMatrixVersionHeader h
ON			h.idfsMatrixType = @idfsMatrixType
			AND (	-- Get matrix version selected by the user in aggregate action
					h.idfVersion = vaa.idfProphylacticVersion
					-- IF matrix version is not selected by the user in aggregate case, 
					-- then select active matrix with the latest date activation that is earlier than aggregate action start date
					OR (	vaa.idfProphylacticVersion IS NULL 
							AND	h.datStartDate <= vaa.datStartDate
							AND	h.blnIsActive = 1
							AND NOT EXISTS	(
										SELECT	*
										FROM	tlbAggrMatrixVersionHeader h_later
										WHERE	h_later.idfsMatrixType = @idfsMatrixType
												AND	h_later.datStartDate <= vaa.datStartDate
												AND	h_later.blnIsActive = 1
												AND h_later.intRowStatus = 0
												AND	h_later.datStartDate > h.datStartDate
											)
						)
				)
			AND h.intRowStatus = 0
			
-- Matrix row
INNER JOIN	tlbAggrProphylacticActionMTX mtx
ON			mtx.idfVersion = h.idfVersion
			AND mtx.intRowStatus = 0

-- Diagnosis       
INNER JOIN	@NotDeletedAggregateDiagnosis ndad
ON			ndad.idfsDiagnosis = mtx.idfsDiagnosis

-- Species Type
INNER JOIN	@NotDeletedSpecies nds
ON			nds.idfsSpeciesType = mtx.idfsSpeciesType

-- Measure Name
INNER JOIN	@NotDeletedProphylacticAction  ndpa
ON			ndpa.idfsProphylacticAction = mtx.idfsProphilacticAction

-- Action_taken
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	tlbActivityParameters ap
 	WHERE	ap.idfObservation = vaa.idfProphylacticObservation
 			AND ap.idfRow = mtx.idfAggrProphylacticActionMTX
			AND ap.idfsParameter = @Prophylactics_Aggr_Action_taken
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			order by ap.idfActivityParameters asc
 		) AS  Action_taken

-- Note
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	tlbActivityParameters ap
 	WHERE	ap.idfObservation = vaa.idfProphylacticObservation
 			AND ap.idfRow = mtx.idfAggrProphylacticActionMTX
			AND ap.idfsParameter = @Prophylactics_Aggr_Note
			AND ap.intRowStatus = 0
			AND ap.varValue IS NOT NULL
 			order by ap.idfActivityParameters asc
 		) AS  Prophylactics_Note

GROUP BY	CAST(ndad.idfsActualDiagnosis AS NVARCHAR(20)) + N'_' + 
				CAST(nds.idfsActualSpeciesType AS NVARCHAR(20)) + N'_' + 
				CAST(ndpa.idfsActualProphylacticAction AS NVARCHAR(20)) COLLATE Latin1_General_CI_AS,
			ndad.idfsActualDiagnosis,
			ndpa.idfsActualProphylacticAction,
			nds.idfsActualSpeciesType,
			ISNULL(ndpa.[name], N''),
			ISNULL(ndad.[name], N''),
			ISNULL(ndad.strOIECode, N''),
			ISNULL(nds.[name], N''),
			ISNULL(nds.intOrder, -1000),
			ISNULL(ndad.intOrder, -1000),
			ISNULL(ndpa.intOrder, -1000)
-- Do not include the rows with Action Taken = 0 in the report
HAVING		SUM(ISNULL(CAST(Action_taken.varValue AS INT), 0)) > 0


-- Fill result TABLE
INSERT INTO	@Result
(	strDiagnosisSpeciesKey,
	strMeasureName,
	idfsDiagnosis,
	idfsProphylacticAction,
	idfsSpeciesType,
	strDiagnosisName,
	strOIECode,
	strSpecies,
	intActionTaken,
	strNote,
	SpeciesOrderColumn,
	DiagnosisOrderColumn,
	blnAdditionalText
)
SELECT DISTINCT
			s.strDiagnosisSpeciesKey,
			s.strMeasureName,
			s.idfsDiagnosis,
			s.idfsProphylacticAction,
			s.idfsSpeciesType,
			s.strDiagnosisName,
			s.strOIECode,
			s.strSpecies,
			s.intActionTaken,
			CASE
				WHEN	s.blnAddNote > 0
					THEN	@Included_state_sector_Translation
				ELSE	N''
			END,
			s.SpeciesOrderColumn,
			s.DiagnosisOrderColumn,
			1 AS blnAdditionalText

FROM		#VetCaseData s

INSERT INTO	@Result
(	strDiagnosisSpeciesKey,
	strMeasureName,
	idfsDiagnosis,
	idfsProphylacticAction,
	idfsSpeciesType,
	strDiagnosisName,
	strOIECode,
	strSpecies,
	intActionTaken,
	strNote,
	InvestigationOrderColumn,
	SpeciesOrderColumn,
	DiagnosisOrderColumn,
	blnAdditionalText
)
SELECT		a.strDiagnosisSpeciesKey,
			a.strMeasureName,
			a.idfsDiagnosis,
			a.idfsProphylacticAction,
			a.idfsSpeciesType,
			a.strDiagnosisName,
			a.strOIECode,
			a.strSpecies,
			a.intActionTaken,
			CASE
				WHEN	@FromYear = @ToYear
						and	@FromMonth = @ToMonth
					THEN	a.strNote
				ELSE	N''
			END,
			a.InvestigationOrderColumn,
			a.SpeciesOrderColumn,
			a.DiagnosisOrderColumn,
			0 AS blnAdditionalText
			
FROM		#VetAggregateActionData a
LEFT JOIN	@Result r
ON			r.strDiagnosisSpeciesKey = a.strDiagnosisSpeciesKey
WHERE		r.idfsDiagnosis IS NULL

-- Update orders in the table
UPDATE		r
SET			r.InvestigationOrderColumn = ROrderTable.RowOrder,
			r.DiagnosisOrderColumn = 0,
			r.SpeciesOrderColumn = 0
FROM		@Result r
INNER JOIN	(	
	SELECT	r_order.strDiagnosisSpeciesKey,
			ROW_NUMBER () OVER	(	ORDER BY	ISNULL(r_order.strMeasureName, N''), 
												ISNULL(r_order.strDiagnosisName, N''),
												ISNULL(r_order.SpeciesOrderColumn, 0),
												ISNULL(r_order.strSpecies, N'')
								) AS RowOrder
	FROM	@Result r_order
			) AS ROrderTable
ON			ROrderTable.strDiagnosisSpeciesKey = r.strDiagnosisSpeciesKey


-- SELECT report informative part - start

/*
insert into @Result Values('aaa', 'dddd', 7718320000000, 'diagnos', 'B051', 'dog', 12, 'fff', 34, 45, 56)
insert into @Result Values('b', 'dddd', 7718320000000, 'diagnos', 'B051', 'cat', 13, 'jjj', 24, 35, 46)
insert into @Result Values('c', 'gdhdfgdh', 7718730000000, 'diagnos2', 'B103, B152, B253', 'sheep', 12, 'note', 23, 34, 45)
insert into @Result Values('?', 'sdfgsafdgsdfg', 7718350000000, 'diagnos3', 'B0512', 'cat', 13, 'note2', 24, 35, 46)
insert into @Result Values('?', 'sdfgsafdgsdfg', 7718760000000, 'diagnos4', 'B1031, B152, B253', 'sheep', 12, 'note5', 23, 34, 45)
insert into @Result Values('aaa1', 'sdfgsafdgsdfg', 7718520000000, 'diagnos5', 'B051', 'dog', 12, 'notedddd', 23, 34, 45)
insert into @Result Values('b1', 'sdfgsafdgsdfg', 7718520000000, 'diagnos5', 'B051', 'cat', 13, 'notesdfgs', 24, 35, 46)
*/


-- Return results
IF (SELECT COUNT(*) FROM @result) = 0
	SELECT	'' AS strDiagnosisSpeciesKey,
	'' AS strMeasureName,
	- 1 AS idfsDiagnosis,
	- 1 AS idfsProphylacticAction,
	- 1 AS idfsSpeciesType,
	'' AS strDiagnosisName,
	'' AS strOIECode, 
	'' AS strSpecies,
	NULL AS INTActionTaken, 
	NULL AS strNote,
	NULL AS InvestigationOrderColumn, 
	NULL AS SpeciesOrderColumn, 
	NULL AS DiagnosisOrderColumn,
	0 AS blnAdditionalText
ELSE
	SELECT * FROM @result ORDER BY InvestigationOrderColumn

-- Drop temporary tables
IF Object_ID('tempdb..#VetAggregateAction') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetAggregateAction'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#VetCaseData') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetCaseData'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#VetAggregateActionData') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetAggregateActionData'
	EXECUTE sp_executesql @drop_cmd
END
	     
END
GO
PRINT N'Altering Procedure [Report].[USP_REP_VET_Form1ReportAZ]...';


GO
--*************************************************************************
-- Name: report.USP_REP_VET_Form1ReportAZ
--
-- Description: Select data for REPORT ON Veterinary Report Form Vet1.
--          
-- Author: Srini Goli
--
-- Revision History:
-- Name			       Date       Change Detail
-- ------------------- ---------- ----------------------------------------
-- Stephen Long        05/08/2023 Changed from institution repair to min.
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC report.USP_REP_VET_Form1ReportAZ @LangID=N'en', @FromYear = 2012, @ToYear = 2014
EXEC report.USP_REP_VET_Form1ReportAZ 'ru',2012,2013, @OrganizationEntered = 48120000000, @OrganizationID = 48120000000

*/
ALTER PROCEDURE [Report].[USP_REP_VET_Form1ReportAZ]
    (
        @LangID AS NVARCHAR(10)
        , @FromYear AS INT
		, @ToYear AS INT
		, @FromMonth AS INT = NULL
		, @ToMonth AS INT = NULL
		, @RegionID AS BIGINT = NULL
		, @RayonID AS BIGINT = NULL
		, @OrganizationEntered AS BIGINT = NULL
		, @OrganizationID AS BIGINT = NULL
		, @idfUserID AS BIGINT = NULL
    )
AS
BEGIN

DECLARE	@drop_cmd	NVARCHAR(4000)

-- Drop temporary tables
IF Object_ID('tempdb..#VetCaseTable') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetCaseTable'
	EXECUTE sp_executesql @drop_cmd
END

DECLARE @Result AS TABLE
(
	strDiagnosisSpeciesKey		NVARCHAR(200) COLLATE DATABASE_DEFAULT NOT NULL PRIMARY KEY,
	idfsDiagnosis				BIGINT NOT NULL,
	strDiagnosisName			NVARCHAR(2000) COLLATE DATABASE_DEFAULT NULL,
	strOIECode					NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL,
	strSpecies					NVARCHAR(2000) COLLATE DATABASE_DEFAULT NULL,
	intNumberSensSpecies		INT NULL,
	intNumberUnhealthySt		INT NULL,
	intNumberSick				INT NULL,
	intNumberDead				INT NULL,
	intNumberVaccinated			INT NULL,
	intOtherMeasures 			INT NULL,
	intNumberAnnihilated		INT NULL,
	intNumberSlaughtered		INT NULL,
	intNumberUnhealthyStLeft	INT NULL,
	intNumberDiseased			INT NULL,
	SpeciesOrderColumn			INT NULL,
	DiagnosisOrderColumn		INT NULL,
	strFooterPerformer			NVARCHAR(2000) COLLATE DATABASE_DEFAULT null
)
/*
INSERT INTO @Result Values('aaa', 7718320000000, 'diagnos', 'B051', 'dog', 12, 23, 34, 45, 56, 67, 78, 89, 90, 111, 1, 1, 'sentby', 'Vasya Pupkin')
INSERT INTO @Result Values('b', 7718320000000, 'diagnos', 'B051', 'cat', 13, 24, 35, 46, 57, 68, 79, 80, 91, 112, 1, 1, 'sentby', 'Vasya Pupkin')
INSERT INTO @Result Values('c', 7718730000000, 'diagnos2', 'B103, B152, B253', 'sheep', 12, 23, 34, 45, 56, 67, 78, 89, 90, 111, 1, 1, 'sentby', 'Vasya Pupkin')
INSERT INTO @Result Values('в', 7718350000000, 'diagnos3', 'B0512', 'cat', 13, 24, 35, 46, 57, 68, 79, 80, 91, 112, 1, 1, 'sentby', 'Vasya Pupkin')
INSERT INTO @Result Values('ф', 7718760000000, 'diagnos4', 'B1031, B152, B253', 'sheep', 12, 23, 34, 45, 56, 67, 78, 89, 90, 111, 1, 1, 'sentby', 'Vasya Pupkin')
INSERT INTO @Result Values('aaa1', 7718520000000, 'diagnos5', 'B051', 'dog', 12, 23, 34, 45, 56, 67, 78, 89, 90, 111, 1, 1, 'sentby', 'Vasya Pupkin')
INSERT INTO @Result Values('b1', 7718520000000, 'diagnos5', 'B051', 'cat', 13, 24, 35, 46, 57, 68, 79, 80, 91, 112, 1, 1, 'sentby', 'Vasya Pupkin')
*/

DECLARE	@idfsSummaryReportType	BIGINT
SET	@idfsSummaryReportType = 10290032	-- Veterinary Report Form Vet 1


-- Specify the value of missing month if remaining month is specified in interval (1-12)
IF	@FromMonth IS NULL AND @ToMonth IS NOT NULL AND @ToMonth >= 1 AND @ToMonth <= 12
	SET	@FromMonth = 1
IF	@ToMonth IS NULL AND @FromMonth IS NOT NULL AND @FromMonth >= 1 AND @FromMonth <= 12
	SET	@ToMonth = 12

-- Calculate Start AND End dates for conditions: Start Date <= date from Vet Case < End date
DECLARE	@StartDate	date
DECLARE	@EndDate	date

IF	@FromMonth IS NULL or @FromMonth < 1 or @FromMonth > 12
	SET	@StartDate = CAST(@FromYear as NVARCHAR) + N'0101'
else if @FromMonth < 10
	SET	@StartDate = CAST(@FromYear as NVARCHAR) + N'0' + CAST(@FromMonth as NVARCHAR) + N'01'
else
	SET	@StartDate = CAST(@FromYear as NVARCHAR) + CAST(@FromMonth as NVARCHAR) + N'01'

IF	@ToMonth IS NULL or @ToMonth < 1 or @ToMonth > 12
BEGIN
	SET	@EndDate = CAST(@ToYear as NVARCHAR) + N'0101'
	SET	@EndDate = dateadd(year, 1, @EndDate)
END
else
BEGIN
	if @ToMonth < 10
		SET	@EndDate = CAST(@ToYear as NVARCHAR) + N'0' + CAST(@ToMonth as NVARCHAR) + N'01'
	else
		SET	@EndDate = CAST(@ToYear as NVARCHAR) + CAST(@ToMonth as NVARCHAR) + N'01'
	
	SET	@EndDate = dateadd(month, 1, @EndDate)
END

DECLARE	@OrganizationName_GenerateReport	NVARCHAR(2000)
SELECT		@OrganizationName_GenerateReport = i.EnglishFullName
FROM		dbo.FN_GBL_Institution_Min(@LangID) i
WHERE		i.idfOffice = @OrganizationID
IF	@OrganizationName_GenerateReport IS NULL
	SET	@OrganizationName_GenerateReport = N''



-- Calculate Footer parameter "Name and Last Name of Performer:" - start
DECLARE	@FooterNameOfPerformer	NVARCHAR(2000)
SET	@FooterNameOfPerformer = N''

-- Show the user Name and Surname which is generating the report 
-- and near it current organization name (Organization from which user has logged on to the system) 
--     in round brackets in respective report language

DECLARE	@EmployeeName_GenerateReport	NVARCHAR(2000)
SELECT		@EmployeeName_GenerateReport = dbo.FN_GBL_ConcatFullName(p.strFamilyName, p.strFirstName, p.strSecondName)
FROM		dbo.tlbPerson p
INNER JOIN	dbo.tstUserTable ut
ON			ut.idfPerson = p.idfPerson
WHERE		ut.idfUserID = @idfUserID
IF	@EmployeeName_GenerateReport IS NULL
	SET	@EmployeeName_GenerateReport = N''

SET	@FooterNameOfPerformer = @EmployeeName_GenerateReport
IF	LTRIM(RTRIM(@OrganizationName_GenerateReport)) <> N''
BEGIN
	IF	LTRIM(RTRIM(@FooterNameOfPerformer)) = N''
	BEGIN
		set @FooterNameOfPerformer = N'(' + @OrganizationName_GenerateReport + N')' 
	END
	else
	BEGIN
		SET	@FooterNameOfPerformer = @FooterNameOfPerformer + N' (' + @OrganizationName_GenerateReport + N')'
	END
END

-- Calculate Footer parameter "Name and Last Name of Performer:" - end

-- Select report informative part - start

DECLARE	@vet_form_1_use_specific_gis	BIGINT
DECLARE	@vet_form_1_specific_gis_region	BIGINT
DECLARE	@vet_form_1_specific_gis_rayon	BIGINT

SELECT	@vet_form_1_use_specific_gis = at.idfAttributeType
FROM	dbo.trtAttributeType at
WHERE	at.strAttributeTypeName = N'vet_form_1_use_specific_gis'

SELECT	@vet_form_1_specific_gis_region = at.idfAttributeType
FROM	dbo.trtAttributeType at
WHERE	at.strAttributeTypeName = N'vet_form_1_specific_gis_region'

SELECT	@vet_form_1_specific_gis_rayon = at.idfAttributeType
FROM	dbo.trtAttributeType at
WHERE	at.strAttributeTypeName = N'vet_form_1_specific_gis_rayon'

DECLARE @SpecificOfficeId BIGINT
SELECT
	 @SpecificOfficeId = ts.idfOffice
FROM dbo.tstSite ts 
WHERE ts.intRowStatus = 0
	AND ts.intFlags = 100 /*organization with abbreviation = Baku city VO*/

DECLARE	@Livestock_Vaccinated_number BIGINT
DECLARE	@Avian_Vaccinated_number	BIGINT

DECLARE	@Livestock_Quarantined_number	BIGINT
DECLARE	@Avian_Quarantined_number	BIGINT

DECLARE	@Livestock_Desinfected_number	BIGINT
DECLARE	@Avian_Desinfected_number	BIGINT

DECLARE	@Livestock_Number_selected_for_monitoring	BIGINT
DECLARE	@Avian_Number_selected_for_monitoring	BIGINT

DECLARE	@Livestock_Annihilated_number	BIGINT
DECLARE	@Avian_Annihilated_number	BIGINT

DECLARE	@Livestock_Slaughtered_number	BIGINT
DECLARE	@Avian_Slaughtered_number	BIGINT

DECLARE	@Livestock_Number_of_diseased_left	BIGINT
DECLARE	@Avian_Number_of_diseased_left	BIGINT

-- Vaccinated_number - start
SELECT		@Livestock_Vaccinated_number = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Livestock_Vaccinated_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

SELECT		@Avian_Vaccinated_number = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Avian_Vaccinated_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0
-- Vaccinated_number - end

-- Quarantined_number - start
SELECT		@Livestock_Quarantined_number = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Livestock_Quarantined_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

SELECT		@Avian_Quarantined_number = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Avian_Quarantined_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0
-- Quarantined_number - end

-- Desinfected_number - start
SELECT		@Livestock_Desinfected_number = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Livestock_Desinfected_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

SELECT		@Avian_Desinfected_number = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Avian_Desinfected_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0
-- Desinfected_number - end

-- Number_selected_for_monitoring - start
SELECT		@Livestock_Number_selected_for_monitoring = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Livestock_Number_selected_for_monitoring'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

SELECT		@Avian_Number_selected_for_monitoring = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Avian_Number_selected_for_monitoring'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0
-- Number_selected_for_monitoring - end

-- Annihilated_number - start
SELECT		@Livestock_Annihilated_number = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Livestock_Annihilated_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

SELECT		@Avian_Annihilated_number = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Avian_Annihilated_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0
-- Annihilated_number - end

-- Slaughtered_number - start
SELECT		@Livestock_Slaughtered_number = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Livestock_Slaughtered_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

SELECT		@Avian_Slaughtered_number = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Avian_Slaughtered_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0
-- Slaughtered_number - end

-- Number_of_diseased_left - start
SELECT		@Livestock_Number_of_diseased_left = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Livestock_Number_of_diseased_left'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

SELECT		@Avian_Number_of_diseased_left = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Avian_Number_of_diseased_left'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0
-- Number_of_diseased_left - end


CREATE TABLE #VetCaseTable
(	idfID							BIGINT NOT NULL IDENTITY (1, 1) PRIMARY KEY,
	idfVetCase						BIGINT NOT NULL,
	strDiagnosisSpeciesKey			NVARCHAR(200) COLLATE DATABASE_DEFAULT NOT NULL,
	idfsDiagnosis					BIGINT NOT NULL,
	strDiagnosisName				NVARCHAR(2000) COLLATE DATABASE_DEFAULT NULL,
	strOIECode						NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL,
	strSpecies						NVARCHAR(2000) COLLATE DATABASE_DEFAULT NULL,
	SpeciesOrderColumn				INT NULL,
	DiagnosisOrderColumn			INT NULL,
	idfsSpeciesType					BIGINT NOT NULL,
	idfSpecies						BIGINT NOT NULL,
	idfObservation					BIGINT NOT NULL,
	intDeadAnimalQty				INT NULL,
	intSickAnimalQty				INT NULL,
	intTotalAnimalQty				INT NULL,
	intVaccinatedNumber				INT NULL,
	intVaccinatedNumber_FF			INT NULL,
	intQuarantinedNumber			INT NULL,
	intDesinfectedNumber			INT NULL,
	intSelectedForMonitoringNumber	INT NULL,
	intAnnihilatedNumber			INT NULL,
	intSlaughteredNumber			INT NULL,
	intDiseasedLeftNumber			INT NULL
)

INSERT INTO	#VetCaseTable
(	idfVetCase,
	strDiagnosisSpeciesKey,
	idfsDiagnosis,
	strDiagnosisName,
	strOIECode,
	strSpecies,
	SpeciesOrderColumn,
	DiagnosisOrderColumn,
	idfsSpeciesType,
	idfSpecies,
	idfObservation,
	intDeadAnimalQty,
	intSickAnimalQty,
	intTotalAnimalQty,
	intVaccinatedNumber,
	intVaccinatedNumber_FF,
	intQuarantinedNumber,
	intDesinfectedNumber,
	intSelectedForMonitoringNumber,
	intAnnihilatedNumber,
	intSlaughteredNumber,
	intDiseasedLeftNumber
)
SELECT		vc.idfVetCase as idfVetCase,
			CAST(ISNULL(Actual_Diagnosis.idfsDiagnosis, d.idfsDiagnosis) as NVARCHAR(20)) + N'_' + 
				CAST(ISNULL(Actual_Species_Type.idfsSpeciesType, sp.idfsSpeciesType) as NVARCHAR(20)) as strDiagnosisSpeciesKey,
			ISNULL(Actual_Diagnosis.idfsDiagnosis, d.idfsDiagnosis) as idfsDiagnosis,
			ISNULL(r_d.[name], N'') as strDiagnosisName,
			ISNULL(Actual_Diagnosis.strOIECode, ISNULL(d.strOIECode, N'')) as strOIECode,
			ISNULL(r_sp.[name], N'') as strSpecies,
			ISNULL(Actual_Species_Type.intOrder, ISNULL(r_sp.intOrder, -1000)) as SpeciesOrderColumn,
			ISNULL(Actual_Diagnosis.intOrder, ISNULL(r_d.intOrder, -1000)) as DiagnosisOrderColumn,
			ISNULL(Actual_Species_Type.idfsSpeciesType, sp.idfsSpeciesType) as idfsSpeciesType,
			sp.idfSpecies as idfSpecies,
			obs.idfObservation as idfObservation,
			ISNULL(sp.intDeadAnimalQty, 0) as intDeadAnimalQty,
			ISNULL(sp.intSickAnimalQty, 0) as intSickAnimalQty,
			ISNULL(sp.intTotalAnimalQty, ISNULL(sp.intDeadAnimalQty, 0) + ISNULL(sp.intSickAnimalQty, 0)) as intTotalAnimalQty,
			MAX(ISNULL(vac.intNumberVaccinated, 0)) as intNumberVaccinated,
			ISNULL(CAST(Vaccinated_number.varValue AS INT), 0) as intNumberVaccinated_FF,
			ISNULL(CAST(Quarantined_number.varValue AS INT), 0) as intQuarantinedNumber,
			ISNULL(CAST(Desinfected_number.varValue AS INT), 0) as intDesinfectedNumber,
			ISNULL(CAST(Number_selected_for_monitoring.varValue AS INT), 0) as intSelectedForMonitoringNumber,
			ISNULL(CAST(Annihilated_number.varValue AS INT), 0) as intAnnihilatedNumber,
			ISNULL(CAST(Slaughtered_number.varValue AS INT), 0) as intSlaughteredNumber,
			ISNULL(CAST(Number_of_diseased_left.varValue AS INT), 0) as intDiseasedLeftNumber
FROM		
-- Veterinary Case
			dbo.tlbVetCase vc

-- Diagnosis = Final Diagnosis of Veterinary Case
INNER JOIN	dbo.trtDiagnosis d
	INNER JOIN	dbo.FN_GBL_DiagnosisRepair(@LangID, 19000019, null) r_d
	ON			r_d.idfsDiagnosis = d.idfsDiagnosis

	-- Not deleted diagnosis with the same name and using type
	OUTER APPLY (
 		SELECT TOP 1
 					d_actual.idfsDiagnosis, r_d_actual.intOrder, d_actual.strOIECode
 		FROM		dbo.trtDiagnosis d_actual
		INNER JOIN	dbo.FN_GBL_Reference_GETList(@LangID, 19000019) r_d_actual
		ON			r_d_actual.idfsReference = d_actual.idfsDiagnosis
 		WHERE		d_actual.idfsUsingType = d.idfsUsingType
					AND d_actual.intRowStatus = 0
					AND r_d_actual.[name] = r_d.[name]
 		ORDER BY d_actual.idfsDiagnosis ASC
 			) AS  Actual_Diagnosis
				
ON			d.idfsDiagnosis = vc.idfsFinalDiagnosis
			AND d.idfsUsingType = 10020001	/*Case-based*/

-- Species - start
INNER JOIN	dbo.tlbFarm f
-- Region and Rayon
	LEFT JOIN	dbo.tlbGeoLocation gl
		LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) reg
		ON			reg.idfsReference = gl.idfsRegion
		LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) ray
		ON			ray.idfsReference = gl.idfsRayon
	ON			gl.idfGeoLocation = f.idfFarmAddress
ON			f.idfFarm = vc.idfFarm
			AND f.intRowStatus = 0
INNER JOIN	dbo.tlbHerd h
ON			h.idfFarm = f.idfFarm
			AND h.intRowStatus = 0
INNER JOIN	dbo.tlbSpecies sp
	INNER JOIN	report.FN_GBL_ReferenceRepair_GET(@LangID, 19000086) r_sp
	ON			r_sp.idfsReference = sp.idfsSpeciesType

	-- Not deleted species type with the same name
	OUTER APPLY (
 		SELECT TOP 1
 					st_actual.idfsSpeciesType, r_sp_actual.intOrder
 		FROM		dbo.trtSpeciesType st_actual
		INNER JOIN	dbo.FN_GBL_Reference_GETList(@LangID, 19000086) r_sp_actual
		ON			r_sp_actual.idfsReference = st_actual.idfsSpeciesType
 		WHERE		st_actual.intRowStatus = 0
					AND r_sp_actual.[name] = r_sp.[name]
 		ORDER BY st_actual.idfsSpeciesType ASC
 			) AS  Actual_Species_Type

ON			sp.idfHerd = h.idfHerd
			AND sp.intRowStatus = 0
			-- not blank value in Sick and/or Dead fields
			AND (	sp.intDeadAnimalQty IS NOT NULL
					or sp.intSickAnimalQty IS NOT NULL
				)
-- Species - end

-- Site, Organization entered case
INNER JOIN	dbo.tstSite s 
	LEFT JOIN	dbo.FN_GBL_Institution_Min(@LangID) i
	ON			i.idfOffice = CASE WHEN s.intFlags = 10 THEN @SpecificOfficeId ELSE s.idfOffice END
ON			s.idfsSite = vc.idfsSite

-- Specific Region and Rayon for the site with specific attributes (B46)
LEFT JOIN	dbo.trtBaseReferenceAttribute bra
	LEFT JOIN	dbo.trtGISBaseReferenceAttribute gis_bra_region
		INNER JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) reg_specific
		ON			reg_specific.idfsReference = gis_bra_region.idfsGISBaseReference
	ON			CAST(gis_bra_region.varValue as NVARCHAR) = CAST(bra.varValue as NVARCHAR)
				AND gis_bra_region.idfAttributeType = @vet_form_1_specific_gis_region
	LEFT JOIN	dbo.trtGISBaseReferenceAttribute gis_bra_rayon
		INNER JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) ray_specific
		ON			ray_specific.idfsReference = gis_bra_rayon.idfsGISBaseReference
	ON			CAST(gis_bra_rayon.varValue as NVARCHAR) = CAST(bra.varValue as NVARCHAR)
				AND gis_bra_rayon.idfAttributeType = @vet_form_1_specific_gis_rayon
ON			bra.idfsBaseReference = i.idfsOfficeAbbreviation
			AND bra.idfAttributeType = @vet_form_1_use_specific_gis
			AND CAST(bra.varValue as NVARCHAR) = s.strSiteID

-- Vaccination records
LEFT JOIN	dbo.tlbVaccination vac
ON			vac.idfVetCase = vc.idfVetCase
			AND vac.idfSpecies = sp.idfSpecies
			AND vac.idfsDiagnosis = d.idfsDiagnosis -- NOT from specification, but from common sense
			AND vac.intNumberVaccinated IS NOT NULL
			AND vac.intRowStatus = 0


-- Species Observation
LEFT JOIN	dbo.tlbObservation	obs
ON			obs.idfObservation = sp.idfObservation


-- FF values

-- Vaccinated_number
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	dbo.tlbActivityParameters ap
 	WHERE	ap.idfObservation = obs.idfObservation
			AND ap.idfsParameter IN (@Livestock_Vaccinated_number, @Avian_Vaccinated_number)
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
			AND NOT EXISTS	(
						SELECT	*
						FROM	dbo.tlbVaccination vac_ex
						WHERE	vac_ex.idfVetCase = vc.idfVetCase
								AND vac_ex.idfSpecies = sp.idfSpecies
								AND vac_ex.idfsDiagnosis = d.idfsDiagnosis -- NOT from specification, but from common sense
								AND vac_ex.intNumberVaccinated IS NOT NULL
								AND vac_ex.intRowStatus = 0
							)
 			ORDER BY ap.idfRow ASC
 		) AS  Vaccinated_number

-- Quarantined_number
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	dbo.tlbActivityParameters ap
 	WHERE	ap.idfObservation = obs.idfObservation
			AND ap.idfsParameter IN (@Livestock_Quarantined_number, @Avian_Quarantined_number)
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			ORDER BY ap.idfRow ASC
 		) AS  Quarantined_number

-- Desinfected_number
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	dbo.tlbActivityParameters ap
 	WHERE	ap.idfObservation = obs.idfObservation
			AND ap.idfsParameter IN (@Livestock_Desinfected_number, @Avian_Desinfected_number)
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			ORDER BY ap.idfRow ASC
 		) AS  Desinfected_number

-- Number_selected_for_monitoring
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	dbo.tlbActivityParameters ap
 	WHERE	ap.idfObservation = obs.idfObservation
			AND ap.idfsParameter IN (@Livestock_Number_selected_for_monitoring, @Avian_Number_selected_for_monitoring)
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			ORDER BY ap.idfRow ASC
 		) AS  Number_selected_for_monitoring

-- Annihilated_number
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	dbo.tlbActivityParameters ap
 	WHERE	ap.idfObservation = obs.idfObservation
			AND ap.idfsParameter IN (@Livestock_Annihilated_number, @Avian_Annihilated_number)
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			ORDER BY ap.idfRow ASC
 		) AS  Annihilated_number

-- Slaughtered_number
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	dbo.tlbActivityParameters ap
 	WHERE	ap.idfObservation = obs.idfObservation
			AND ap.idfsParameter IN (@Livestock_Slaughtered_number, @Avian_Slaughtered_number)
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			ORDER BY ap.idfRow ASC
 		) AS  Slaughtered_number

-- Number_of_diseased_left
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	dbo.tlbActivityParameters ap
 	WHERE	ap.idfObservation = obs.idfObservation
			AND ap.idfsParameter IN (@Livestock_Number_of_diseased_left, @Avian_Number_of_diseased_left)
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			ORDER BY ap.idfRow ASC
 		) AS  Number_of_diseased_left


WHERE		vc.intRowStatus = 0
			-- Case Classification = Confirmed
			AND vc.idfsCaseClassification = 350000000	/*Confirmed*/
			
			-- From Year, Month To Year, Month
			AND ISNULL(vc.datFinalDiagnosisDate, vc.datTentativeDiagnosis1Date) >= @StartDate
			AND ISNULL(vc.datFinalDiagnosisDate, vc.datTentativeDiagnosis1Date) < @EndDate
			
			-- Region
			AND (@RegionID IS NULL OR (@RegionID IS NOT NULL AND ISNULL(reg_specific.idfsReference, reg.idfsReference) = @RegionID))
			-- Rayon
			AND (@RayonID IS NULL OR (@RayonID IS NOT NULL AND ISNULL(ray_specific.idfsReference, ray.idfsReference) = @RayonID))
			
			-- Entered BY organization
			AND (@OrganizationEntered IS NULL OR (@OrganizationEntered IS NOT NULL AND i.idfOffice = @OrganizationEntered))

GROUP BY	vc.idfVetCase,
			CAST(ISNULL(Actual_Diagnosis.idfsDiagnosis, d.idfsDiagnosis) as NVARCHAR(20)) + N'_' + 
				CAST(ISNULL(Actual_Species_Type.idfsSpeciesType, sp.idfsSpeciesType) as NVARCHAR(20)),
			ISNULL(Actual_Diagnosis.idfsDiagnosis, d.idfsDiagnosis),
			ISNULL(r_d.[name], N''),
			ISNULL(Actual_Diagnosis.strOIECode, ISNULL(d.strOIECode, N'')),
			ISNULL(r_sp.[name], N''),
			ISNULL(Actual_Species_Type.intOrder, ISNULL(r_sp.intOrder, -1000)),
			ISNULL(Actual_Diagnosis.intOrder, ISNULL(r_d.intOrder, -1000)),
			ISNULL(Actual_Species_Type.idfsSpeciesType, sp.idfsSpeciesType),
			sp.idfSpecies,
			obs.idfObservation,
			ISNULL(sp.intDeadAnimalQty, 0),
			ISNULL(sp.intSickAnimalQty, 0),
			ISNULL(sp.intTotalAnimalQty, ISNULL(sp.intDeadAnimalQty, 0) + ISNULL(sp.intSickAnimalQty, 0)),
			ISNULL(CAST(Vaccinated_number.varValue AS INT), 0),
			ISNULL(CAST(Quarantined_number.varValue AS INT), 0),
			ISNULL(CAST(Desinfected_number.varValue AS INT), 0),
			ISNULL(CAST(Number_selected_for_monitoring.varValue AS INT), 0),
			ISNULL(CAST(Annihilated_number.varValue AS INT), 0),
			ISNULL(CAST(Slaughtered_number.varValue AS INT), 0),
			ISNULL(CAST(Number_of_diseased_left.varValue AS INT), 0)

INSERT INTO	@Result
(	strDiagnosisSpeciesKey,
	idfsDiagnosis,
	strDiagnosisName,
	strOIECode,
	strSpecies,
	intNumberSensSpecies,
	intNumberUnhealthySt,
	intNumberSick,
	intNumberDead,
	intNumberVaccinated,
	intOtherMeasures,
	intNumberAnnihilated,
	intNumberSlaughtered,
	intNumberUnhealthyStLeft,
	intNumberDiseased,
	SpeciesOrderColumn,
	DiagnosisOrderColumn,
	strFooterPerformer
)
SELECT DISTINCT
			vct.strDiagnosisSpeciesKey,
			vct.idfsDiagnosis,
			vct.strDiagnosisName,
			vct.strOIECode,
			vct.strSpecies,
			sum(ISNULL(vct.intTotalAnimalQty, 0) - ISNULL(vct.intSickAnimalQty, 0) - ISNULL(vct.intDeadAnimalQty, 0)), /*intNumberSensSpecies - Number of sensitive species*/
			count(vct.idfVetCase), /*intNumberUnhealthySt - Number of unhealthy stations*/
			sum(ISNULL(vct.intSickAnimalQty, 0)), /*intNumberSick - Number of sick*/
			sum(ISNULL(vct.intDeadAnimalQty, 0)), /*intNumberDead - Number of dead*/
			sum(ISNULL(vct.intVaccinatedNumber, 0) + ISNULL(vct.intVaccinatedNumber_FF, 0)), /*intNumberVaccinated - Vaccinated*/
			sum(ISNULL(vct.intQuarantinedNumber, 0) + 
				ISNULL(vct.intDesinfectedNumber, 0) + 
				ISNULL(vct.intSelectedForMonitoringNumber, 0)), /*intOtherMeasures - Other measures (disinfection, monitoring and etc.)*/
			sum(ISNULL(vct.intAnnihilatedNumber, 0)), /*intNumberAnnihilated - Annihilated*/
			sum(ISNULL(vct.intSlaughteredNumber, 0)), /*intNumberSlaughtered - Slaughtered*/
			0, /*intNumberUnhealthyStLeft - Left until the end of the reported period: Number of unhealthy stations*/
			sum(ISNULL(vct.intDiseasedLeftNumber, 0)), /*intNumberDiseased - Left until the end of the reported period: Number of diseased*/
			vct.SpeciesOrderColumn,
			vct.DiagnosisOrderColumn,
			@FooterNameOfPerformer

FROM		#VetCaseTable vct

GROUP BY	vct.strDiagnosisSpeciesKey,
			vct.idfsDiagnosis,
			vct.strDiagnosisName,
			vct.strOIECode,
			vct.strSpecies,
			vct.SpeciesOrderColumn,
			vct.DiagnosisOrderColumn

/*intNumberUnhealthyStLeft - Left until the end of the reported period: Number of unhealthy stations*/
update		r
SET			r.intNumberUnhealthyStLeft = 
			(	SELECT	count(vct.idfVetCase)
				FROM	#VetCaseTable vct
				WHERE	vct.strDiagnosisSpeciesKey = r.strDiagnosisSpeciesKey
						AND vct.intDiseasedLeftNumber > 0
			)
FROM		@Result r

-- Select report informative part - start

-- Return results
if (SELECT count(*) FROM @result) = 0
	SELECT	'' as strDiagnosisSpeciesKey,
	- 1 as idfsDiagnosis,
	'' as strDiagnosisName,
	'' as strOIECode, 
	'' as strSpecies,
	null as intNumberSensSpecies, 
	null as intNumberUnhealthySt, 
	null as intNumberSick, 
	null as intNumberDead, 
	null as intNumberVaccinated, 
	null as intOtherMeasures, 
	null as intNumberAnnihilated, 
	null as intNumberSlaughtered, 
	null as intNumberUnhealthyStLeft, 
	null as intNumberDiseased, 
	null as SpeciesOrderColumn, 
	null as DiagnosisOrderColumn, 
	@FooterNameOfPerformer as strFooterPerformer
else
	SELECT * FROM @result ORDER BY DiagnosisOrderColumn, strDiagnosisName, idfsDiagnosis, SpeciesOrderColumn


-- Drop temporary tables
if Object_ID('tempdb..#VetCaseTable') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetCaseTable'
	execute sp_executesql @drop_cmd
END
	     
END
GO
PRINT N'Altering Procedure [Report].[USP_REP_VET_SummaryActiveSurveillanceAZ]...';


GO
--*************************************************************************
-- Name: report.USP_REP_VET_SummaryActiveSurveillanceAZ
-- Description: Used in Summary Veterinary Report For Active Surveillance
--          
-- Author: Srini Goli
--
-- Revision History:
-- Name			       Date       Change Detail
-- ------------------- ---------- ----------------------------------------
-- Stephen Long        05/08/2023 Changed from institution repair to min.
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC report.USP_REP_VET_SummaryActiveSurveillanceAZ 
'en', 
N'2016-01-01T00:00:00',
N'2018-11-30T00:00:00',
7718730000000,
'49558320000000,7722710000000'


EXEC report.USP_REP_VET_SummaryActiveSurveillanceAZ 
'en', 
N'2016-01-01T00:00:00',
N'2016-12-31T00:00:00',
7718730000000,
49558320000000
--'<ItemList><Item key="49558320000000" value=""/></ItemList>'

*/ 
ALTER PROCEDURE [Report].[USP_REP_VET_SummaryActiveSurveillanceAZ]
(
	 @LangID			AS NVARCHAR(50),
	 @SD				AS DATETIME, 
	 @ED				AS DATETIME,
	 @Diagnosis			AS BIGINT,
	 @SpeciesType		AS NVARCHAR(MAX),
	 @InvestigationOrMeasureType BIGINT = NULL
)
AS

	DECLARE @SDDate AS DATETIME
	DECLARE @EDDate AS DATETIME
	DECLARE @CountryID BIGINT
	DECLARE @iSpeciesType INT
	
	DECLARE @idfsRegionBaku BIGINT,
		@idfsRegionOtherRayons BIGINT,
		@idfsRegionNakhichevanAR BIGINT
		
		
	DECLARE @sql AS NVARCHAR (MAX) = ''

	
	SET @SDDate=dbo.fn_SetMinMaxTime(CAST(@SD AS DATETIME),0)
	SET @EDDate=dbo.fn_SetMinMaxTime(CAST(@ED AS DATETIME),1)
	
	SET @CountryID = 170000000
				

	DECLARE @SpeciesTypeTable	TABLE
		(
			[key]  NVARCHAR(300)			
		)	
	
	INSERT INTO @SpeciesTypeTable 
 	SELECT CAST([Value] AS BIGINT) FROM report.FN_GBL_SYS_SplitList(@SpeciesType,1,',')

	--1344330000000 --Baku
	SELECT
		@idfsRegionBaku = fgr.idfsReference
	FROM dbo.FN_GBL_GIS_Reference('en', 19000003) fgr
	WHERE fgr.name = N'Baku'

	--1344340000000 --Other rayons
	SELECT
		@idfsRegionOtherRayons = fgr.idfsReference
	FROM dbo.FN_GBL_GIS_Reference('en', 19000003) fgr
	WHERE fgr.name = N'Other rayons'

	--1344350000000 --Nakhichevan AR
	SELECT
		@idfsRegionNakhichevanAR = fgr.idfsReference
	FROM dbo.FN_GBL_GIS_Reference('en', 19000003) fgr
	WHERE fgr.name = N'Nakhichevan AR'  
	
	
	DECLARE @vet_form_1_use_specific_gis BIGINT 
	DECLARE @vet_form_1_specific_gis_region BIGINT 
	DECLARE @vet_form_1_specific_gis_rayon BIGINT
	DECLARE @attr_part_in_report BIGINT 

	SELECT 
		@vet_form_1_use_specific_gis = at.idfAttributeType
	FROM trtAttributeType at
	WHERE at.strAttributeTypeName = N'vet_form_1_use_specific_gis'

	SELECT 
		@vet_form_1_specific_gis_region = at.idfAttributeType
	FROM trtAttributeType at
	WHERE at.strAttributeTypeName = N'vet_form_1_specific_gis_region'

	SELECT 
		@vet_form_1_specific_gis_rayon = at.idfAttributeType
	FROM trtAttributeType at
	WHERE at.strAttributeTypeName = N'vet_form_1_specific_gis_rayon'
	
	SELECT
		@attr_part_in_report = at.idfAttributeType
	FROM	trtAttributeType at
	WHERE	at.strAttributeTypeName = N'attr_part_in_report'
	
	
	

DECLARE	@drop_cmd	NVARCHAR(4000)

-- Drop temporary TABLEs
IF Object_ID('tempdb..#MonitoringSession') is NOT NULL
BEGIN
	SET	@drop_cmd = N'drop TABLE #MonitoringSession'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#MaterialCnt') is NOT NULL
BEGIN
	SET	@drop_cmd = N'drop TABLE #MaterialCnt'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#TestCnt') is NOT NULL
BEGIN
	SET	@drop_cmd = N'drop TABLE #TestCnt'
	EXECUTE sp_executesql @drop_cmd
END

	

	CREATE TABLE #MonitoringSession (
		idfMonitoringSession BIGINT
		, idfsRegion BIGINT
		, idfsRayon BIGINT
	)
		
	INSERT INTO #MonitoringSession
	SELECT DISTINCT 
		tms.idfMonitoringSession
		, ISNULL(reg_specific.idfsReference, tms.idfsRegion)
		, ISNULL(ray_specific.idfsReference, tms.idfsRayon)
	FROM dbo.tlbMonitoringSession tms
	
	-- Site, Organization entered case
	JOIN dbo.tstSite s
		LEFT JOIN dbo.FN_GBL_Institution_Min(@LangID) i ON
			i.idfOffice = s.idfOffice
	ON s.idfsSite = tms.idfsSite
		-- Specific Region and Rayon for the site with specific attributes (B46)
	LEFT JOIN dbo.trtBaseReferenceAttribute bra
		LEFT JOIN dbo.trtGISBaseReferenceAttribute gis_bra_region
			JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) reg_specific ON
				reg_specific.idfsReference = gis_bra_region.idfsGISBaseReference
		ON CAST(gis_bra_region.varValue AS NVARCHAR) = CAST(bra.varValue AS NVARCHAR)
			AND gis_bra_region.idfAttributeType = @vet_form_1_specific_gis_region
		LEFT JOIN dbo.trtGISBaseReferenceAttribute gis_bra_rayon
			JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) ray_specific ON
				ray_specific.idfsReference = gis_bra_rayon.idfsGISBaseReference 
		ON CAST(gis_bra_rayon.varValue AS NVARCHAR) = CAST(bra.varValue AS NVARCHAR)
			AND gis_bra_rayon.idfAttributeType = @vet_form_1_specific_gis_rayon
	ON bra.idfsBaseReference = i.idfsOfficeAbbreviation
		AND bra.idfAttributeType = @vet_form_1_use_specific_gis
		AND CAST(bra.varValue AS NVARCHAR) = s.strSiteID			
		
	WHERE tms.intRowStatus = 0
		AND tms.datStartDate IS NOT NULL
		AND ISNULL(tms.datEndDate, tms.datStartDate) BETWEEN @SDDate AND @EDDate

	DECLARE	@NotDeletedDiagnosis TABLE
	(	idfsDiagnosis		BIGINT NOT NULL PRIMARY KEY,
		[name]				NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
		idfsActualDiagnosis	BIGINT NOT NULL
	)
	
	INSERT INTO	@NotDeletedDiagnosis
	(	idfsDiagnosis,
		[name],
		idfsActualDiagnosis
	)
	SELECT
		r_d.idfsReference AS idfsDiagnosis
		, r_d.[name] AS [name]
		, ISNULL(actual_diagnosis.idfsDiagnosis, r_d.idfsReference) AS idfsActualDiagnosis
	FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) r_d
	LEFT JOIN	(
		SELECT	d_actual.idfsDiagnosis,
				r_d_actual.[name],
				ROW_NUMBER() OVER (PARTITION BY r_d_actual.[name] ORDER BY d_actual.idfsDiagnosis) AS rn
		FROM		dbo.trtDiagnosis d_actual
		INNER JOIN	dbo.FN_GBL_Reference_GETList('en', 19000019) r_d_actual
		ON			r_d_actual.idfsReference = d_actual.idfsDiagnosis
		WHERE		d_actual.idfsUsingType = 10020001	/*Case-based*/
					AND d_actual.intRowStatus = 0
				) actual_diagnosis
		ON		actual_diagnosis.[name] = r_d.[name] COLLATE Cyrillic_General_CI_AS
				AND actual_diagnosis.rn = 1
	WHERE	ISNULL(actual_diagnosis.idfsDiagnosis, r_d.idfsReference) = @Diagnosis

	DECLARE	@NotDeletedSpecies TABLE
	(	idfsSpeciesType			BIGINT NOT NULL PRIMARY KEY,
		[name]					NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
		idfsActualSpeciesType	BIGINT NOT NULL
	)

	INSERT INTO	@NotDeletedSpecies
	(	idfsSpeciesType,
		[name],
		idfsActualSpeciesType
	)
		SELECT
			r_sp.idfsReference AS idfsSpeciesType
			, CAST(r_sp.[name] AS NVARCHAR(2000)) AS [name]
			, ISNULL(actual_SpeciesType.idfsSpeciesType, r_sp.idfsReference) AS idfsActualSpeciesType
		FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000086) r_sp
		LEFT JOIN	(
			SELECT	st_actual.idfsSpeciesType,
					r_st_actual.[name],
					ROW_NUMBER() OVER (PARTITION BY r_st_actual.[name] ORDER BY st_actual.idfsSpeciesType) AS rn
			FROM		dbo.trtSpeciesType st_actual
			INNER JOIN	dbo.FN_GBL_Reference_GETList('en', 19000086) r_st_actual
			ON			r_st_actual.idfsReference = st_actual.idfsSpeciesType
			WHERE		st_actual.intRowStatus = 0
				) actual_SpeciesType
		ON		actual_SpeciesType.[name] = r_sp.[name] COLLATE Cyrillic_General_CI_AS
				AND actual_SpeciesType.rn = 1
		INNER JOIN	@SpeciesTypeTable stt
		ON			stt.[key] = ISNULL(actual_SpeciesType.idfsSpeciesType, r_sp.idfsReference)


	CREATE TABLE #MaterialCnt (
		idfMonitoringSession BIGINT
		, idfsSpeciesType BIGINT
		, idfAnimalCount INT
	)
	
	INSERT INTO #MaterialCnt
	SELECT
		tm.idfMonitoringSession
		, Actual_Species_Type.idfsActualSpeciesType
		, COUNT(DISTINCT ta.idfAnimal) cnt
	FROM dbo.tlbMaterial tm
	JOIN #MonitoringSession ms ON
		ms.idfMonitoringSession = tm.idfMonitoringSession
	JOIN dbo.tlbAnimal ta ON
		ta.idfAnimal = tm.idfAnimal
		AND ta.intRowStatus = 0
	JOIN dbo.tlbSpecies ts ON
		ts.idfSpecies = ta.idfSpecies
		AND ts.intRowStatus = 0

	JOIN @NotDeletedSpecies AS Actual_Species_Type ON
		Actual_Species_Type.idfsSpeciesType = ts.idfsSpeciesType

	WHERE tm.intRowStatus = 0
			AND tm.datFieldCollectionDate IS NOT NULL
			AND tm.intRowStatus = 0
			AND tm.idfsSampleType <> 10320001	/*Unknown*/
			AND tm.datFieldCollectionDate is NOT NULL

			AND EXISTS	(
					SELECT TOP 1 1
					FROM	dbo.tlbMonitoringSessionToDiagnosis ms_to_d

					JOIN	@NotDeletedDiagnosis AS Actual_Diagnosis ON
						Actual_Diagnosis.idfsDiagnosis = ms_to_d.idfsDiagnosis

					WHERE	ms_to_d.idfMonitoringSession = ms.idfMonitoringSession
							AND ms_to_d.intRowStatus = 0
							AND ms_to_d.idfsSpeciesType = ts.idfsSpeciesType
							AND (	ms_to_d.idfsSampleType is null
									or	(	ms_to_d.idfsSampleType is NOT NULL
											AND ms_to_d.idfsSampleType = tm.idfsSampleType
										)
								)
						)
	GROUP BY tm.idfMonitoringSession
		, Actual_Species_Type.idfsActualSpeciesType


	CREATE TABLE #TestCnt (
		idfMonitoringSession BIGINT
		, idfsSpeciesType BIGINT
		, idfAnimalCount INT
	)


	INSERT INTO #TestCnt
	SELECT
		tm.idfMonitoringSession
		, Actual_Species_Type.idfsActualSpeciesType
		, COUNT(DISTINCT ta.idfAnimal) cnt
	FROM dbo.tlbTesting tt
	JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000001) ref_teststatus ON
		ref_teststatus.idfsReference = tt.idfsTestStatus
	JOIN dbo.tlbMaterial tm ON
		tm.idfMaterial = tt.idfMaterial
		AND tm.intRowStatus = 0
		AND tm.datFieldCollectionDate IS NOT NULL
		AND tm.intRowStatus = 0
		AND tm.idfsSampleType <> 10320001	/*Unknown*/
		AND tm.datFieldCollectionDate is NOT NULL
	JOIN #MonitoringSession ms ON
		ms.idfMonitoringSession = tm.idfMonitoringSession
	JOIN dbo.tlbAnimal ta ON
		ta.idfAnimal = tm.idfAnimal
		AND ta.intRowStatus = 0
	JOIN dbo.tlbSpecies ts ON
		ts.idfSpecies = ta.idfSpecies
		AND ts.intRowStatus = 0

	JOIN @NotDeletedSpecies AS Actual_Species_Type ON
		Actual_Species_Type.idfsSpeciesType = ts.idfsSpeciesType
	WHERE tt.idfsDiagnosis = @Diagnosis
		AND ref_teststatus.idfsReference IN (10001001, 10001006)  /*Final, Amended*/
		AND tt.intRowStatus = 0
		AND isnull(tt.blnExternalTest, 0) = 0
		AND EXISTS	(
				SELECT TOP 1 1
				FROM	dbo.trtTestTypeToTestResult tttttr
				WHERE	tttttr.idfsTestName = tt.idfsTestName
						AND tttttr.idfsTestResult = tt.idfsTestResult
						AND tttttr.intRowStatus = 0
						AND tttttr.blnIndicative = 1
					)
	
			AND EXISTS	(
					SELECT TOP 1 1
					FROM	dbo.tlbMonitoringSessionToDiagnosis ms_to_d

					JOIN	@NotDeletedDiagnosis AS Actual_Diagnosis ON
						Actual_Diagnosis.idfsDiagnosis = ms_to_d.idfsDiagnosis

					WHERE	ms_to_d.idfMonitoringSession = ms.idfMonitoringSession
							AND ms_to_d.intRowStatus = 0
							AND ms_to_d.idfsDiagnosis = tt.idfsDiagnosis
							AND ms_to_d.idfsSpeciesType = ts.idfsSpeciesType
							AND (	ms_to_d.idfsSampleType is null
									OR	(	ms_to_d.idfsSampleType is NOT NULL
											AND ms_to_d.idfsSampleType = tm.idfsSampleType
										)
								)
						)

	GROUP BY tm.idfMonitoringSession
		, Actual_Species_Type.idfsActualSpeciesType
		
		
	CREATE TABLE #ActiveSurveillanceSessions
		(
			idfsRegion BIGINT
			, idfsRayon BIGINT
			, idfsSpeciesType BIGINT
			, CntMaterial INT
			, CntTest INT
		)	

	INSERT INTO #ActiveSurveillanceSessions
	SELECT
		ms.idfsRegion
		, ms.idfsRayon
		, mc.idfsSpeciesType
		, SUM(mc.idfAnimalCount) as CntMaterial
		, SUM(ISNULL(tc.idfAnimalCount, 0)) as CntTest
	FROM #MonitoringSession ms
	JOIN #MaterialCnt mc ON
		mc.idfMonitoringSession = ms.idfMonitoringSession
	LEFT JOIN #TestCnt tc ON
		tc.idfMonitoringSession = ms.idfMonitoringSession
		AND tc.idfsSpeciesType = mc.idfsSpeciesType
	GROUP BY ms.idfsRegion
		, ms.idfsRayon
		, mc.idfsSpeciesType

	SELECT 
		CASE ray.idfsRegion 
			WHEN @idfsRegionBaku THEN 1 
			WHEN @idfsRegionOtherRayons THEN 2
			WHEN @idfsRegionNakhichevanAR THEN 3
			ELSE 0
		END AS intRegionOrder
		,refReg.[name] AS strRegion
		,refRay.[name] AS strRayon
		,ref_spec.[name] AS strSpecies
		,MAX(isnull(ASSessions.CntMaterial,0)) as CntMaterial
		,MAX(isnull(ASSessions.CntTest,0)) as CntTest
	FROM report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) AS reg
	JOIN FN_GBL_GIS_Reference(@LangID, 19000003 /*rftRegion*/) AS refReg ON
		reg.idfsRegion = refReg.idfsReference			
		AND reg.idfsCountry = @CountryID
	JOIN report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) AS ray ON 
		ray.idfsRegion = reg.idfsRegion	
	JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000002 /*rftRayon*/) AS refRay ON
		ray.idfsRayon = refRay.idfsReference
	LEFT JOIN @SpeciesTypeTable stt ON 1=1
	LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000086) ref_spec ON
		stt.[key] = ref_spec.idfsReference	
	LEFT JOIN #ActiveSurveillanceSessions AS ASSessions ON
		ASSessions.idfsRegion = ray.idfsRegion
		AND ASSessions.idfsRayon = ray.idfsRayon
		AND ASSessions.idfsSpeciesType = ref_spec.idfsReference

	GROUP BY CASE ray.idfsRegion 
				WHEN @idfsRegionBaku THEN 1 
				WHEN @idfsRegionOtherRayons THEN 2
				WHEN @idfsRegionNakhichevanAR THEN 3
				ELSE 0
			END
			,refReg.[name]
			,refRay.[name]
			,ref_spec.[name]
	ORDER BY intRegionOrder, strRayon
GO
