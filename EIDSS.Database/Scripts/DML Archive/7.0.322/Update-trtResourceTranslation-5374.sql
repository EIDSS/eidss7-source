/*
	Doug Albanese
	12/15/2022
	Translation correction for "Details" header
	Defect 5374
*/

update trtResourceTranslation
set strResourceString = N'ანგარიშის დეტალები'
where idfsResource in ( 541, 756)