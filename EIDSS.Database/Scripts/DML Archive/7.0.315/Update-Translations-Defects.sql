/*
Author:			Doug Albanese
Date:			11/22/2022
Description:	Changes to existing translations

*/

--Tests (header)
update trtResourceTranslation
set strResourceString = N'ტესტები'
where idfsResource = 889 and idfsLanguage = 10049004;

update trtResourceTranslation
set strResourceString = N'Testlər'
where idfsResource = 889 and idfsLanguage = 10049001;

update trtResourceTranslation
set strResourceString = N'الاختباراتər'
where idfsResource = 889 and idfsLanguage = 10049011;;


--Test Details (Header)
update trtResourceTranslation
set strResourceString = N'ტესტის დეტალური ინფორმაცია'
where idfsResource = 1055 and idfsLanguage = 10049004;

update trtResourceTranslation
set strResourceString = N'Testə dair təfərrüatlar'
where idfsResource = 1055 and idfsLanguage = 10049001;

update trtResourceTranslation
set strResourceString = N'تفاصيل الاختبار'
where idfsResource = 1055 and idfsLanguage = 10049011;


--Success (Header)
update trtResourceTranslation
set strResourceString = N'წარმატებები'
where idfsResource in (967,2802) and idfsLanguage = 10049004;

update trtResourceTranslation
set strResourceString = N'Uğur'
where idfsResource in (967,2802) and idfsLanguage = 10049001;

update trtResourceTranslation
set strResourceString = N'النجاح'
where idfsResource in (967,2802) and idfsLanguage = 10049011;