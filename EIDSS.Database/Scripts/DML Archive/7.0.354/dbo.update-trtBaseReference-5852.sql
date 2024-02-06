/*
	Corrections to base reference item naming

	Author: Doug Albanese

*/

update  trtBaseReference
   set strDefault = 'Disease Groups'
   where idfsBaseReference = 19000156

update  trtBaseReference
   set strDefault = 'Disease Using Type'
   where idfsBaseReference = 19000020

update trtStringNameTranslation
   set strTextString = 'Disease Using Type'
   where idfsBaseReference = 19000020

update  trtBaseReference
   set strDefault = 'Organization Type'
   where idfsBaseReference = 19000504