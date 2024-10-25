/*
	Mike Kornegay
	02/20/2023
	This script changes the editor type for the clinical signs form.
	Previously, parameter types that were set to parString where set to use
	combo box as their editor type but this should have been text box.

*/

begin tran
update p
set idfsEditor = 10067008
from ffParameter p
inner join trtBaseReference br
on br.idfsBaseReference = p.idfsParameter
where p.idfsParameterType = 10071045
and p.idfsFormType = 10034010
and p.idfsEditor <> 10067008
commit tran
