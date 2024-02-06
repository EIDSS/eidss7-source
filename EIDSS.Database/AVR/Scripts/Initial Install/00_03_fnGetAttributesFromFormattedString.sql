/****** Object:  UserDefinedFunction [dbo].[fnGetAttributesFromFormattedString]    Script Date: 3/9/2022 10:45:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--##SUMMARY This function retrieves pairs of attribute names and values from formatted string of attributes;
--##SUMMARY Expected format is as follows: N'intAttrInd:1,strAttr:AttrName1,strVal:AttrVal1;intAttrInd:2,strAttr:AttrName2,strVal:AttrVal2;...'
--##SUMMARY If necessary, it's possible to filter results by only one attribute.

--##REMARKS 
--##REMARKS Create date: 20.12.2020

--##RETURNS Returns table of pairs of attribute names and values optionally filtered by selected attribute


/*
Example of a call of function:

select	*
from	dbo.fnGetAttributesFromFormattedString(N'intAttrInd:1,strAttr:TablePrefix,strVal:hc{0};intAttrInd:2,strAttr:FilterTable,strVal:tflHumanCaseFiltered', null)

*/
CREATE OR ALTER FUNCTION [dbo].[fnGetAttributesFromFormattedString]
(	@AttrString	nvarchar(max),			--##PARAM @AttrString Formatted string of attributes; expected format of the string: N'intAttrInd:1,strAttr:AttrName1,strVal:AttrVal1;intAttrInd:2,strAttr:AttrName2,strVal:AttrVal2;...'
	@AttrName	nvarchar(100) = null	--##PARAM @AttrName Optional parameter to retrieve only one attribute
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
	(	intId,
		attrLineNum,
		attrPartNum,
		strVal
	)
	as
	(	select		(attrLine.[num]-1) * 100 + (attrPart.[num]-1) * 2 + attrNameValPair.[num] as intId, 
					attrLine.[num] as attrLineNum, 
					attrPart.[num] as attrPartNum, 
					cast(attrNameValPair.[Value] as nvarchar(max)) as strVal
		from		dbo.fnsysSplitList(@AttrString, 0, N';') attrLine
		outer apply	dbo.fnsysSplitList(cast(attrLine.[Value] as nvarchar(max)), 0, N',') attrPart
		outer apply	dbo.fnsysSplitList(cast(attrPart.[Value] as nvarchar(max)), 0, N':') attrNameValPair
	)

	insert into	@ResTable (strAttr, strVal)
	select		cast(left(attrName.strVal, 100) as varchar(100)) as strAttr, attrVal.strVal as strVal
	from		cte as attrName
	inner join	cte as attrNamePrevPart
	on			attrNamePrevPart.attrLineNum = attrName.attrLineNum
				and attrNamePrevPart.attrPartNum = attrName.attrPartNum
				and attrNamePrevPart.intId = attrName.intId - 1
				and attrNamePrevPart.strVal = N'strAttr' collate Cyrillic_General_CI_AS

	left join	cte as attrVal
		inner join	cte as attrValPrevPart
		on			attrValPrevPart.attrLineNum = attrVal.attrLineNum
					and attrValPrevPart.attrPartNum = attrVal.attrPartNum
					and attrValPrevPart.intId = attrVal.intId - 1
					and attrValPrevPart.strVal = N'strVal' collate Cyrillic_General_CI_AS
	on			attrVal.attrLineNum = attrName.attrLineNum
	where	attrName.strVal is not null
			and (@AttrName is null or (@AttrName is not null and attrName.strVal = @AttrName collate Cyrillic_General_CI_AS))

	return
end

GO