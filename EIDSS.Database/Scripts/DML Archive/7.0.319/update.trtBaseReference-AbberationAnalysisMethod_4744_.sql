/*
Author:			Doug Albanese
Date:			11/29/2022
Description:	Correction of a system flag to denote this reference type as uneditable.
*/



--Set Aberration Analysis Method, Access Permission as a system defined object (uneditable)
update trtBaseReference
set blnSystem = 1
where idfsBaseReference in (19000165, 19000515)