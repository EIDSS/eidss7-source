-- Create stored procedure spOutbreakTypeSelectLookup for OutbreakType
--##REMARKS Author: Edgard Torres
--##REMARKS Create date: 02/08/2022

--##RETURNS Don't use 

/*
--Example of a call of procedure:

exec spOutbreakTypeSelectLookup 'en'

*/ 
 
CREATE   PROCEDURE [dbo].[spOutbreakTypeSelectLookup]
	@LangID			as varchar(36)
AS
BEGIN
	select distinct
		r.idfsReference, 
		r.[name],
		r.intOrder  
		from		fnReferenceRepair(@LangID, 19000513) r
		where		r.idfsReference in
					(	
						10513001,	-- Human
						10513002,	-- Veterinary
						10513003	-- Zoonotic
					)
		order by	r.intOrder, r.[name], r.idfsReference

END
