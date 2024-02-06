/*
	Mike Kornegay
	Set all AS Species Types that are not Livestock or Avian to inactive.
*/

update trtBaseReference 
set intRowStatus = 1 
where idfsReferenceType = 19000538 
and blnSystem = 0