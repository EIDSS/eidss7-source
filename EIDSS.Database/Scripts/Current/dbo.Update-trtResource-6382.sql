/*
	This is an update to an existing resource that changes the phrase "Outbreak Status" to "Case Status"

	Author: Doug Albanese
*/

update trtResource set strResourceName = 'Case Status' where idfsResource = 1852

update trtResourceTranslation set strResourceString = N'وضع حالة' where idfsResource = 1852 and idfsLanguage = 10049011
update trtResourceTranslation set strResourceString = N'Hadisənin statusu' where idfsResource = 1852 and idfsLanguage = 10049001
update trtResourceTranslation set strResourceString = N'შემთხვევის სტატუსი' where idfsResource = 1852 and idfsLanguage = 10049004