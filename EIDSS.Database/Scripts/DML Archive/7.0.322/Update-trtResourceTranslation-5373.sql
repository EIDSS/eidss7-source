/*
	Doug Albanese
	12/15/2022
	Translation correction for "Weekly Reporting Form" header
	Defect 5373
*/

update trtResourceTranslation
set strResourceString = N'ყოველკვირეული ანგარიშგების ფორმა'
where idfsResource = 747 and idfsLanguage = 10049004