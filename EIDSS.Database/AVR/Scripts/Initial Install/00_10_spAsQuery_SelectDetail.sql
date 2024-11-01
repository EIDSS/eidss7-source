/****** Object:  StoredProcedure [dbo].[spAsQuery_SelectDetail]    Script Date: 7/18/2022 1:19:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--##SUMMARY This procedure selects details of specified query 
--##SUMMARY and the tree of related query search objects.

--##REMARKS Author: Mirnaya O.
--##REMARKS Create date: 21.04.2010

--##REMARKS UPDATED BY: Vorobiev E.
--##REMARKS Date: 11.11.2011

--##REMARKS UPDATED BY: Torres E.
--##REMARKS Date: 07.18.2022
--##REMARKS Added idfOffice and idfEmployee fields

--##RETURNS Don't use

/*
--Example of a call of procedure:

declare	@ID	bigint
exec spAsQuery_SelectDetail 49540070000000, 'en'
*/ 
 

ALTER procedure	[dbo].[spAsQuery_SelectDetail]
	@ID		bigint,
	@LangID	nvarchar(50)
as

-- tasQuery
select		q.idflQuery,
			q.strFunctionName,
			q.idflDescription,
			q.blnReadOnly,
			q.blnAddAllKeyFieldValues,
			q_snt_en.strTextString as DefQueryName,
			IsNull(q_snt_lng.strTextString, q_snt_en.strTextString) as QueryName,
			d_snt_en.strTextString as DefQueryDescription,
			IsNull(d_snt_lng.strTextString, d_snt_en.strTextString) as QueryDescription,		
			q.idfOffice,
			q.idfEmployee
from		tasQuery q
left join	locStringNameTranslation q_snt_en
on			q_snt_en.idflBaseReference = q.idflQuery
			and q_snt_en.idfsLanguage = dbo.fnGetLanguageCode('en')
left join	locStringNameTranslation q_snt_lng
on			q_snt_lng.idflBaseReference = q.idflQuery
			and q_snt_lng.idfsLanguage = dbo.fnGetLanguageCode(@LangID)
left join	locStringNameTranslation d_snt_en
on			d_snt_en.idflBaseReference = q.idflDescription
			and d_snt_en.idfsLanguage = dbo.fnGetLanguageCode('en')
left join	locStringNameTranslation d_snt_lng
on			d_snt_lng.idflBaseReference = q.idflDescription
			and d_snt_lng.idfsLanguage = dbo.fnGetLanguageCode(@LangID)
where		q.idflQuery = @ID

-- tasQuerySearchObject
exec	spAsQuery_SelectObjectTree @ID, @LangID

GO
