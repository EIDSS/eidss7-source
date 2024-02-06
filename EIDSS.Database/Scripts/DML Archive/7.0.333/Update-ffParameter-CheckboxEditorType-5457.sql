/*

	Mike Kornegay
	02/16/2023
	This script corrects migrated basic syndromic surveillance sessions by doing the following:
	1.  Corrects the checkbox editor type for the form 10034010 (clinical symptoms).
	
	Note:  The select statements are only for testing to verify counts before running updates and are not necessary

*/

--get the parameters that have incorrect editor types for clinical syndromes
select * from ffParameter where idfsEditor = 19000067

begin tran
update		ffParameter 
set			idfsEditor = 10067001
where		idfsEditor = 19000067
and			idfsParameterType = 10071025
and			idfsFormType = 10034010
commit tran