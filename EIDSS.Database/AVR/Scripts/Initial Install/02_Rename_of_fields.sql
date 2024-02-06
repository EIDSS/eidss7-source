
-- Rename of existing fields
-- Notes: a total of 139 records did not exist, UPDATEs were changed to INSERTs
ALTER TABLE trtBaseReference DISABLE TRIGGER ALL
ALTER TABLE dbo.trtStringNameTranslation DISABLE TRIGGER ALL

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Campaign - Name' WHERE idfsBaseReference = 10080302 -- old value 'AS Campaign - Administrator'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Campaign - Name' WHERE idfsBaseReference = 10080302 AND idfsLanguage = 10049003 -- old value 'AS Campaign - Administrator'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის კამპანია - დასახელება' WHERE idfsBaseReference = 10080302 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Kampaniyası - Adı' WHERE idfsBaseReference = 10080302 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'حملة المراقبة البيطرية النشطة - الاسم' WHERE idfsBaseReference = 10080302 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Campaign - Administrator' WHERE idfsBaseReference = 10080303 -- old value 'AS Campaign - Administrator'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Campaign - Administrator' WHERE idfsBaseReference = 10080303 AND idfsLanguage = 10049003 -- old value 'AS Campaign - Administrator'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული აქტიური ზედამხედველობის (ვაზ) კამპანია - ადმინისტრატორი' WHERE idfsBaseReference = 10080303 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Kampaniyası - Administrator' WHERE idfsBaseReference = 10080303 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'حملة المراقبة البيطرية النشطة - إداري' WHERE idfsBaseReference = 10080303 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Campaign - Campaign ID' WHERE idfsBaseReference = 10080301 -- old value 'AS Campaign - Campaign ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Campaign - Campaign ID' WHERE idfsBaseReference = 10080301 AND idfsLanguage = 10049003 -- old value 'AS Campaign - Campaign ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის კამპანია - კამპანიის ID' WHERE idfsBaseReference = 10080301 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Kampaniyası - Kampaniyanın Q/N-si' WHERE idfsBaseReference = 10080301 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'حملة المراقبة البيطرية النشطة - معرّف الحملة' WHERE idfsBaseReference = 10080301 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Campaign - Diseases' WHERE idfsBaseReference = 10080308 -- old value 'AS Campaign - Diseases'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Campaign - Diseases' WHERE idfsBaseReference = 10080308 AND idfsLanguage = 10049003 -- old value 'AS Campaign - Diseases'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის კამპანია - დაავადებები' WHERE idfsBaseReference = 10080308 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Kampaniyası - Xəstəliklər' WHERE idfsBaseReference = 10080308 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'حملة المراقبة البيطرية النشطة - أمراض' WHERE idfsBaseReference = 10080308 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Campaign - End Date' WHERE idfsBaseReference = 10080307 -- old value 'AS Campaign - End Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Campaign - End Date' WHERE idfsBaseReference = 10080307 AND idfsLanguage = 10049003 -- old value 'AS Campaign - End Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის კამპანია - დაავადებები' WHERE idfsBaseReference = 10080307 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Kampaniyası - Xəstəliklər' WHERE idfsBaseReference = 10080307 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'حملة المراقبة البيطرية النشطة - أمراض' WHERE idfsBaseReference = 10080307 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Campaign - Start Date' WHERE idfsBaseReference = 10080306 -- old value 'AS Campaign - Start Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Campaign - Start Date' WHERE idfsBaseReference = 10080306 AND idfsLanguage = 10049003 -- old value 'AS Campaign - Start Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის კამპანია - დაწყების თარიღი' WHERE idfsBaseReference = 10080306 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Kampaniyası - Başlanma tarixi' WHERE idfsBaseReference = 10080306 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'حملة المراقبة البيطرية النشطة - تاريخ البدء' WHERE idfsBaseReference = 10080306 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Campaign - Status' WHERE idfsBaseReference = 10080305 -- old value 'AS Campaign - Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Campaign - Status' WHERE idfsBaseReference = 10080305 AND idfsLanguage = 10049003 -- old value 'AS Campaign - Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის კამპანია - სტატუსი' WHERE idfsBaseReference = 10080305 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Kampaniyası - Statusu' WHERE idfsBaseReference = 10080305 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'حملة المراقبة البيطرية النشطة - الحالة' WHERE idfsBaseReference = 10080305 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Campaign - Type' WHERE idfsBaseReference = 10080304 -- old value 'VAS Campaign - Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Campaign - Type' WHERE idfsBaseReference = 10080304 AND idfsLanguage = 10049003 -- old value 'VAS Campaign - Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის კამპანია - ტიპი' WHERE idfsBaseReference = 10080304 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Kampaniyası - Növü' WHERE idfsBaseReference = 10080304 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'حملة المراقبة البيطرية النشطة - النوع' WHERE idfsBaseReference = 10080304 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Accession Date' WHERE idfsBaseReference = 10080270 -- old value 'AS Sample - Accession Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Accession Date' WHERE idfsBaseReference = 10080270 AND idfsLanguage = 10049003 -- old value 'AS Sample - Accession Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში - მიღების თარიღი' WHERE idfsBaseReference = 10080270 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Qəbul edilmə tarixi' WHERE idfsBaseReference = 10080270 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة - تاريخ الانضمام ' WHERE idfsBaseReference = 10080270 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Animal ID' WHERE idfsBaseReference = 10080276 -- old value 'AS Sample - Animal ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Animal ID' WHERE idfsBaseReference = 10080276 AND idfsLanguage = 10049003 -- old value 'AS Sample - Animal ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში - ცხოველის ID' WHERE idfsBaseReference = 10080276 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Heyvanın Q/N-si' WHERE idfsBaseReference = 10080276 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة - الرقم التعريفي للحيوان ' WHERE idfsBaseReference = 10080276 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Collection Date' WHERE idfsBaseReference = 10080269 -- old value 'AS Sample - Collection Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Collection Date' WHERE idfsBaseReference = 10080269 AND idfsLanguage = 10049003 -- old value 'AS Sample - Collection Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში - აღების თარიღი' WHERE idfsBaseReference = 10080269 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Toplama tarixi' WHERE idfsBaseReference = 10080269 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة  البيطرية النشطة -  تاريخ الجمع ' WHERE idfsBaseReference = 10080269 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Comment' WHERE idfsBaseReference = 10080271 -- old value 'AS Sample - Comment'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Comment' WHERE idfsBaseReference = 10080271 AND idfsLanguage = 10049003 -- old value 'AS Sample - Comment'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში - კომენტარი' WHERE idfsBaseReference = 10080271 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Qeyd' WHERE idfsBaseReference = 10080271 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة -  تعليق' WHERE idfsBaseReference = 10080271 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Condition Received' WHERE idfsBaseReference = 10080272 -- old value 'AS Sample - Condition Received'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Condition Received' WHERE idfsBaseReference = 10080272 AND idfsLanguage = 10049003 -- old value 'AS Sample - Condition Received'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში - მდგომარეობა მიღებისას' WHERE idfsBaseReference = 10080272 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Qəbul zamanı nümunənin vəziyyəti' WHERE idfsBaseReference = 10080272 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة -  وضع الحالة عند الاستلام' WHERE idfsBaseReference = 10080272 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Current Laboratory' WHERE idfsBaseReference = 10080764 -- old value 'AS Sample - Current Laboratory'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Current Laboratory' WHERE idfsBaseReference = 10080764 AND idfsLanguage = 10049003 -- old value 'AS Sample - Current Laboratory'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080764 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში - მოქმედი ლაბორატორია' WHERE idfsBaseReference = 10080764 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის ნიმუში - მოქმედი ლაბორატორია', 10080764, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080764 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Cari laboratoriya' WHERE idfsBaseReference = 10080764 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Nümunəsi - Cari laboratoriya', 10080764, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080764 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة -  المختبر الحالي' WHERE idfsBaseReference = 10080764 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للمراقبة البيطرية النشطة -  المختبر الحالي', 10080764, 10049011)
UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Days in Transit' WHERE idfsBaseReference = 10080275 -- old value 'AS Sample - Days in Transit'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Days in Transit' WHERE idfsBaseReference = 10080275 AND idfsLanguage = 10049003 -- old value 'AS Sample - Days in Transit'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ- ის ნიმუში - ტრანზიტში ყოფნის დღეების რაოდენობა' WHERE idfsBaseReference = 10080275 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Nümunənin yolda olduğu günlərin sayı' WHERE idfsBaseReference = 10080275 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة -  أيام العبور ' WHERE idfsBaseReference = 10080275 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Destruction Method' WHERE idfsBaseReference = 10080549 -- old value 'AS Sample - Destruction Method'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Destruction Method' WHERE idfsBaseReference = 10080549 AND idfsLanguage = 10049003 -- old value 'AS Sample - Destruction Method'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში - დესტრუქციის მეთოდი' WHERE idfsBaseReference = 10080549 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Məhv edilmə üsulu' WHERE idfsBaseReference = 10080549 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة -  طريقة التدمير' WHERE idfsBaseReference = 10080549 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Farm Owner' WHERE idfsBaseReference = 10080265 -- old value 'AS Sample - Farm Owner'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Farm Owner' WHERE idfsBaseReference = 10080265 AND idfsLanguage = 10049003 -- old value 'AS Sample - Farm Owner'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში  - ფერმის მესაკუთრე' WHERE idfsBaseReference = 10080265 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Fermanın sahibi' WHERE idfsBaseReference = 10080265 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة -  مالك المزرعة' WHERE idfsBaseReference = 10080265 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Field Sample ID' WHERE idfsBaseReference = 10080267 -- old value 'AS Sample - Field Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Field Sample ID' WHERE idfsBaseReference = 10080267 AND idfsLanguage = 10049003 -- old value 'AS Sample - Field Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ- ის ნიმუში - საველე ნიმუშის ID' WHERE idfsBaseReference = 10080267 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Nümunənin sahədəki Q/N-si' WHERE idfsBaseReference = 10080267 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة -   عينة لمعرّف الحقل ' WHERE idfsBaseReference = 10080267 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Initially Collected Sample - Accession Date' WHERE idfsBaseReference = 10080762 -- old value 'AS Sample - Initially Collected Sample - Accession Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Initially Collected Sample - Accession Date' WHERE idfsBaseReference = 10080762 AND idfsLanguage = 10049003 -- old value 'AS Sample - Initially Collected Sample - Accession Date'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080762 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში - თავდაპირველად აღებული ნიმუში - მიღების თარიღი' WHERE idfsBaseReference = 10080762 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის ნიმუში - თავდაპირველად აღებული ნიმუში - მიღების თარიღი', 10080762, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080762 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - İlkin toplanılmış nümunə - Qəbul edilmə tarixi' WHERE idfsBaseReference = 10080762 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Nümunəsi - İlkin toplanılmış nümunə - Qəbul edilmə tarixi', 10080762, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080762 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة - العينة الأولية - تاريخ الانضمام' WHERE idfsBaseReference = 10080762 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للمراقبة البيطرية النشطة - العينة الأولية - تاريخ الانضمام', 10080762, 10049011)
UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Initially Collected Sample - Collection Date' WHERE idfsBaseReference = 10080760 -- old value 'AS Sample - Initially Collected Sample - Collection Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Initially Collected Sample - Collection Date' WHERE idfsBaseReference = 10080760 AND idfsLanguage = 10049003 -- old value 'AS Sample - Initially Collected Sample - Collection Date'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080760 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში - თავდაპირველად აღებული ნიმუში - აღების თარიღი' WHERE idfsBaseReference = 10080760 AND idfsLanguage = 10049004
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის ნიმუში - თავდაპირველად აღებული ნიმუში - აღების თარიღი', 10080760, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080760 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - İlkin toplanılmış nümunə - Toplama tarixi' WHERE idfsBaseReference = 10080760 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Nümunəsi - İlkin toplanılmış nümunə - Toplama tarixi', 10080760, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080760 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة - العينة الأولية المُجمعة - تاريخ الجمع' WHERE idfsBaseReference = 10080760 AND idfsLanguage = 10049011
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للمراقبة البيطرية النشطة - العينة الأولية المُجمعة - تاريخ الجمع', 10080760, 10049011)
UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Initially Collected Sample - Current Laboratory' WHERE idfsBaseReference = 10080758 -- old value 'AS Sample - Initially Collected Sample - Current Laboratory'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Initially Collected Sample - Current Laboratory' WHERE idfsBaseReference = 10080758 AND idfsLanguage = 10049003 -- old value 'AS Sample - Initially Collected Sample - Current Laboratory'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080758 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ- ის ნიმუში - თავდაპირველად აღებული ნიმუში - მოქმედი ლაბორატორია' WHERE idfsBaseReference = 10080758 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ- ის ნიმუში - თავდაპირველად აღებული ნიმუში - მოქმედი ლაბორატორია', 10080758, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080758 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - İlkin toplanılmış nümunə - Cari laboratoriya' WHERE idfsBaseReference = 10080758 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Nümunəsi - İlkin toplanılmış nümunə - Cari laboratoriya', 10080758, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080758 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة - العينة الأولية المُجمعة - المختبر الحالي ' WHERE idfsBaseReference = 10080758 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للمراقبة البيطرية النشطة - العينة الأولية المُجمعة - المختبر الحالي ', 10080758, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Initially Collected Sample - Field ID' WHERE idfsBaseReference = 10080756 -- old value 'AS Sample - Initially Collected Sample - Field ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Initially Collected Sample - Field ID' WHERE idfsBaseReference = 10080756 AND idfsLanguage = 10049003 -- old value 'AS Sample - Initially Collected Sample - Field ID'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080756 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ- ის ნიმუში - თავდაპირველად აღებული ნიმუში - საველე ID' WHERE idfsBaseReference = 10080756 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ- ის ნიმუში - თავდაპირველად აღებული ნიმუში - საველე ID', 10080756, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080756 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - İlkin toplanılmış nümunə - Sahədəki Q/N-si' WHERE idfsBaseReference = 10080756 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Nümunəsi - İlkin toplanılmış nümunə - Sahədəki Q/N-si', 10080756, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080756 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة - العينة الأولية المُجمعة - معرّف الحقل' WHERE idfsBaseReference = 10080756 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للمراقبة البيطرية النشطة - العينة الأولية المُجمعة - معرّف الحقل', 10080756, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Initially Collected Sample - Lab ID' WHERE idfsBaseReference = 10080755 -- old value 'AS Sample - Initially Collected Sample - Lab ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Initially Collected Sample - Lab ID' WHERE idfsBaseReference = 10080755 AND idfsLanguage = 10049003 -- old value 'AS Sample - Initially Collected Sample - Lab ID'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080755 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ- ის ნიმუში - თავდაპირველად აღებული ნიმუში - ლაბორატორიული ID' WHERE idfsBaseReference = 10080755 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ- ის ნიმუში - თავდაპირველად აღებული ნიმუში - ლაბორატორიული ID', 10080755, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080755 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - İlkin toplanılmış nümunə - Laborator nümunənin Q/N-si' WHERE idfsBaseReference = 10080755 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Nümunəsi - İlkin toplanılmış nümunə - Laborator nümunənin Q/N-si', 10080755, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080755 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة - العينة الأولية المُجمعة - معرّف المختبر' WHERE idfsBaseReference = 10080755 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للمراقبة البيطرية النشطة - العينة الأولية المُجمعة - معرّف المختبر', 10080755, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Initially Collected Sample - Sent to Organization' WHERE idfsBaseReference = 10080761 -- old value 'AS Sample - Initially Collected Sample - Sent to Organization'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Initially Collected Sample - Sent to Organization' WHERE idfsBaseReference = 10080761 AND idfsLanguage = 10049003 -- old value 'AS Sample - Initially Collected Sample - Sent to Organization'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080761 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ -ის ნიმუში -  თავდაპირველად აღებული ნიმუში - გაგზავნილია ორგანიზაციაში' WHERE idfsBaseReference = 10080761 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ -ის ნიმუში -  თავდაპირველად აღებული ნიმუში - გაგზავნილია ორგანიზაციაში', 10080761, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080761 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - İlkin toplanılmış nümunə - Hara göndərilib' WHERE idfsBaseReference = 10080761 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Nümunəsi - İlkin toplanılmış nümunə - Hara göndərilib', 10080761, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080761 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة - العينة الأولية المُجمعة - المُرسلة إلى المؤسسة' WHERE idfsBaseReference = 10080761 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للمراقبة البيطرية النشطة - العينة الأولية المُجمعة - المُرسلة إلى المؤسسة', 10080761, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Initially Collected Sample - Status' WHERE idfsBaseReference = 10080763 -- old value 'AS Sample - Initially Collected Sample - Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Initially Collected Sample - Status' WHERE idfsBaseReference = 10080763 AND idfsLanguage = 10049003 -- old value 'AS Sample - Initially Collected Sample - Status'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080763 AND idfsLanguage = 10049004)
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ -ის ნიმუში -  თავდაპირველად აღებული ნიმუში - სტატუსი' WHERE idfsBaseReference = 10080763 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ -ის ნიმუში -  თავდაპირველად აღებული ნიმუში - სტატუსი', 10080763, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080763 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - İlkin toplanılmış nümunə - Statusu' WHERE idfsBaseReference = 10080763 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Nümunəsi - İlkin toplanılmış nümunə - Statusu', 10080763, 10049001)

IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080763 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة - العينة الأولية المُجمعة - الحالة' WHERE idfsBaseReference = 10080763 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للمراقبة البيطرية النشطة - العينة الأولية المُجمعة - الحالة', 10080763, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Initially Collected Sample - Type' WHERE idfsBaseReference = 10080757 -- old value 'AS Sample - Initially Collected Sample - Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Initially Collected Sample - Type' WHERE idfsBaseReference = 10080757 AND idfsLanguage = 10049003 -- old value 'AS Sample - Initially Collected Sample - Type'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080757 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ -ის ნიმუში -  თავდაპირველად აღებული ნიმუში - ტიპი' WHERE idfsBaseReference = 10080757 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ -ის ნიმუში -  თავდაპირველად აღებული ნიმუში - ტიპი', 10080757, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080757 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - İlkin toplanılmış nümunə - Növü' WHERE idfsBaseReference = 10080757 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Nümunəsi - İlkin toplanılmış nümunə - Növü', 10080757, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080757 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة - العينة الأولية المُجمعة - النوع ' WHERE idfsBaseReference = 10080757 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للمراقبة البيطرية النشطة - العينة الأولية المُجمعة - النوع ', 10080757, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Lab Sample ID' WHERE idfsBaseReference = 10080266 -- old value 'AS Sample - Lab Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Lab Sample ID' WHERE idfsBaseReference = 10080266 AND idfsLanguage = 10049003 -- old value 'AS Sample - Lab Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში - ლაბორატორიული ნიმუშის ID' WHERE idfsBaseReference = 10080266 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Laborator nümunənin Q/N-si' WHERE idfsBaseReference = 10080266 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة -  عينة لمعرّف المختبر ' WHERE idfsBaseReference = 10080266 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Parent Sample - Accession Date' WHERE idfsBaseReference = 10080771 -- old value 'AS Sample - Parent Sample - Accession Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Parent Sample - Accession Date' WHERE idfsBaseReference = 10080771 AND idfsLanguage = 10049003 -- old value 'AS Sample - Parent Sample - Accession Date'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080771 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში - მთავარი ნიმუში - მიღების თარიღი' WHERE idfsBaseReference = 10080771 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის ნიმუში - მთავარი ნიმუში - მიღების თარიღი', 10080771, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080771 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Əsas nümunə - Qəbul edilmə tarixi' WHERE idfsBaseReference = 10080771 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Nümunəsi - Əsas nümunə - Qəbul edilmə tarixi', 10080771, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080771 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة - أصل العينة  - تاريخ الانضمام ' WHERE idfsBaseReference = 10080771 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للمراقبة البيطرية النشطة - أصل العينة  - تاريخ الانضمام ', 10080771, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Parent Sample - Collection Date' WHERE idfsBaseReference = 10080769 -- old value 'AS Sample - Parent Sample - Collection Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Parent Sample - Collection Date' WHERE idfsBaseReference = 10080769 AND idfsLanguage = 10049003 -- old value 'AS Sample - Parent Sample - Collection Date'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080769 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში - მთავარი ნიმუში - აღების თარიღი' WHERE idfsBaseReference = 10080769 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის ნიმუში - მთავარი ნიმუში - აღების თარიღი', 10080769, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080769 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Əsas nümunə - Toplama tarixi' WHERE idfsBaseReference = 10080769 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Nümunəsi - Əsas nümunə - Toplama tarixi', 10080769, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080769 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة - أصل العينة  - تاريخ الجمع' WHERE idfsBaseReference = 10080769 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للمراقبة البيطرية النشطة - أصل العينة  - تاريخ الجمع', 10080769, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Parent Sample - Current Laboratory' WHERE idfsBaseReference = 10080767 -- old value 'AS Sample - Parent Sample - Current Laboratory'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Parent Sample - Current Laboratory' WHERE idfsBaseReference = 10080767 AND idfsLanguage = 10049003 -- old value 'AS Sample - Parent Sample - Current Laboratory'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080767 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში - მთავარი ნიმუში - მოქმედი ლაბორატორია' WHERE idfsBaseReference = 10080767 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის ნიმუში - მთავარი ნიმუში - მოქმედი ლაბორატორია', 10080767, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080767 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Əsas nümunə - Cari laboratoriya' WHERE idfsBaseReference = 10080767 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Nümunəsi - Əsas nümunə - Cari laboratoriya', 10080767, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080767 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة - أصل العينة  - المختبر الحالي' WHERE idfsBaseReference = 10080767 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للمراقبة البيطرية النشطة - أصل العينة  - المختبر الحالي', 10080767, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Parent Sample - Field ID' WHERE idfsBaseReference = 10080765 -- old value 'AS Sample - Parent Sample - Field ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Parent Sample - Field ID' WHERE idfsBaseReference = 10080765 AND idfsLanguage = 10049003 -- old value 'AS Sample - Parent Sample - Field ID'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080765 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში - მთავარი ნიმუში - საველე ID' WHERE idfsBaseReference = 10080765 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის ნიმუში - მთავარი ნიმუში - საველე ID', 10080765, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080765 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Əsas nümunə - Sahədəki Q/N-si' WHERE idfsBaseReference = 10080765 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Nümunəsi - Əsas nümunə - Sahədəki Q/N-si', 10080765, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080765 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة - أصل العينة  - معرّف الحقل ' WHERE idfsBaseReference = 10080765 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للمراقبة البيطرية النشطة - أصل العينة  - معرّف الحقل ', 10080765, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Parent Sample - Lab ID' WHERE idfsBaseReference = 10080268 -- old value 'AS Sample - Parent Sample - Lab ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Parent Sample - Lab ID' WHERE idfsBaseReference = 10080268 AND idfsLanguage = 10049003 -- old value 'AS Sample - Parent Sample - Lab ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში - მთავარი ნიმუში - ლაბორატორიული  ID' WHERE idfsBaseReference = 10080268 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Əsas nümunə - Laborator nümunənin Q/N-si' WHERE idfsBaseReference = 10080268 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة - أصل العينة  - معرّف المختبر' WHERE idfsBaseReference = 10080268 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Parent Sample - Sent to Organization' WHERE idfsBaseReference = 10080770 -- old value 'AS Sample - Parent Sample - Sent to Organization'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Parent Sample - Sent to Organization' WHERE idfsBaseReference = 10080770 AND idfsLanguage = 10049003 -- old value 'AS Sample - Parent Sample - Sent to Organization'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080770 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში - მთავარი ნიმუში - გაგზავნილია ორგანიზაციაში' WHERE idfsBaseReference = 10080770 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის ნიმუში - მთავარი ნიმუში - გაგზავნილია ორგანიზაციაში', 10080770, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080770 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Əsas nümunə - Hara göndərilib' WHERE idfsBaseReference = 10080770 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Nümunəsi - Əsas nümunə - Hara göndərilib', 10080770, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080770 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة - أصل العينة  - المُرسلة إلى المؤسسة' WHERE idfsBaseReference = 10080770 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للمراقبة البيطرية النشطة - أصل العينة  - المُرسلة إلى المؤسسة', 10080770, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Parent Sample - Status' WHERE idfsBaseReference = 10080772 -- old value 'AS Sample - Parent Sample - Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Parent Sample - Status' WHERE idfsBaseReference = 10080772 AND idfsLanguage = 10049003 -- old value 'AS Sample - Parent Sample - Status'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080772 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში - მთავარი ნიმუში - სტატუსი' WHERE idfsBaseReference = 10080772 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის ნიმუში - მთავარი ნიმუში - სტატუსი', 10080772, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080772 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Əsas nümunə - Statusu' WHERE idfsBaseReference = 10080772 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Nümunəsi - Əsas nümunə - Statusu', 10080772, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080772 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة - أصل العينة  - الحالة' WHERE idfsBaseReference = 10080772 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للمراقبة البيطرية النشطة - أصل العينة  - الحالة', 10080772, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Parent Sample - Type' WHERE idfsBaseReference = 10080766 -- old value 'AS Sample - Parent Sample - Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Parent Sample - Type' WHERE idfsBaseReference = 10080766 AND idfsLanguage = 10049003 -- old value 'VAS Sample - Parent Sample - Type'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080766 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში - მთავარი ნიმუში - ტიპი' WHERE idfsBaseReference = 10080766 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის ნიმუში - მთავარი ნიმუში - ტიპი', 10080766, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080766 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Əsas nümunə - Növü' WHERE idfsBaseReference = 10080766 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Nümunəsi - Əsas nümunə - Növü', 10080766, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080766 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة - أصل العينة  - النوع' WHERE idfsBaseReference = 10080766 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للمراقبة البيطرية النشطة - أصل العينة  - النوع', 10080766, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Sent to Organization' WHERE idfsBaseReference = 10080810 -- old value 'AS Sample - Sent to Organization'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Sent to Organization' WHERE idfsBaseReference = 10080810 AND idfsLanguage = 10049003 -- old value 'AS Sample - Sent to Organization'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში - გაგზავნილია ორგანიზაციაში' WHERE idfsBaseReference = 10080810 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Hara göndərilib' WHERE idfsBaseReference = 10080810 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة - المُرسلة إلى المؤسسة' WHERE idfsBaseReference = 10080810 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Session ID' WHERE idfsBaseReference = 10080264 -- old value 'AS Sample - Session ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Session ID' WHERE idfsBaseReference = 10080264 AND idfsLanguage = 10049003 -- old value 'AS Sample - Session ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში - სესიის ID' WHERE idfsBaseReference = 10080264 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Sessiyanın Q/N-si' WHERE idfsBaseReference = 10080264 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة - معرّف الجلسة' WHERE idfsBaseReference = 10080264 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Species' WHERE idfsBaseReference = 10080277 -- old value 'AS Sample - Species'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Species' WHERE idfsBaseReference = 10080277 AND idfsLanguage = 10049003 -- old value 'AS Sample - Species'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ - ის ნიმუში - სახეობები' WHERE idfsBaseReference = 10080277 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Heyvan növü' WHERE idfsBaseReference = 10080277 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة - أنواع الحيوانات' WHERE idfsBaseReference = 10080277 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Status' WHERE idfsBaseReference = 10080715 -- old value 'AS Sample - Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Status' WHERE idfsBaseReference = 10080715 AND idfsLanguage = 10049003 -- old value 'AS Sample - Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში - სტატუსი' WHERE idfsBaseReference = 10080715 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Statusu' WHERE idfsBaseReference = 10080715 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للمراقبة البيطرية النشطة - الحالة' WHERE idfsBaseReference = 10080715 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Sample - Type' WHERE idfsBaseReference = 10080274 -- old value 'AS Sample - Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Sample - Type' WHERE idfsBaseReference = 10080274 AND idfsLanguage = 10049003 -- old value 'AS Sample - Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის ნიმუში - ტიპი' WHERE idfsBaseReference = 10080274 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Nümunəsi - Növü' WHERE idfsBaseReference = 10080274 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج  للمراقبة البيطرية النشطة - النوع' WHERE idfsBaseReference = 10080274 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Session - Campaign ID' WHERE idfsBaseReference = 10080309 -- old value 'AS Session - Campaign ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session - Campaign ID' WHERE idfsBaseReference = 10080309 AND idfsLanguage = 10049003 -- old value 'AS Session - Campaign ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესია - კამპანიის ID' WHERE idfsBaseReference = 10080309 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası - Kampaniyanın Q/N-si' WHERE idfsBaseReference = 10080309 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة -  معرّف الحملة' WHERE idfsBaseReference = 10080309 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Session - Campaign Name' WHERE idfsBaseReference = 10080310 -- old value 'AS Session - Campaign Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session - Campaign Name' WHERE idfsBaseReference = 10080310 AND idfsLanguage = 10049003 -- old value 'AS Session - Campaign Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესია - კამპანიის დასახელება' WHERE idfsBaseReference = 10080310 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası - Kampaniyanın adı' WHERE idfsBaseReference = 10080310 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة - اسم  الحملة' WHERE idfsBaseReference = 10080310 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Session - Campaign Type' WHERE idfsBaseReference = 10080311 -- old value 'AS Session - Campaign Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session - Campaign Type' WHERE idfsBaseReference = 10080311 AND idfsLanguage = 10049003 -- old value 'AS Session - Campaign Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ- ის სესია - კამპანიის ტიპი' WHERE idfsBaseReference = 10080311 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası - Kampaniyanın növü' WHERE idfsBaseReference = 10080311 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة - نوع  الحملة' WHERE idfsBaseReference = 10080311 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Session - Diseases' WHERE idfsBaseReference = 10080319 -- old value 'AS Session - Diseases'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session - Diseases' WHERE idfsBaseReference = 10080319 AND idfsLanguage = 10049003 -- old value 'AS Session - Diseases'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესია - დაავადებები' WHERE idfsBaseReference = 10080319 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası - Xəstəliklər' WHERE idfsBaseReference = 10080319 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة - الأمراض' WHERE idfsBaseReference = 10080319 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Session - End Date' WHERE idfsBaseReference = 10080811 -- old value 'AS Session - End Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session - End Date' WHERE idfsBaseReference = 10080811 AND idfsLanguage = 10049003 -- old value 'AS Session - End Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესია - დასრულების თარიღი' WHERE idfsBaseReference = 10080811 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası - Bitmə tarixi' WHERE idfsBaseReference = 10080811 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة - تاريخ الانتهاء' WHERE idfsBaseReference = 10080811 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Session - Entered Date' WHERE idfsBaseReference = 10080318 -- old value 'AS Session - Entered Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session - Entered Date' WHERE idfsBaseReference = 10080318 AND idfsLanguage = 10049003 -- old value 'AS Session - Entered Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესია - შეყვანის თარიღი' WHERE idfsBaseReference = 10080318 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası - Daxil edilmə tarixi' WHERE idfsBaseReference = 10080318 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة - تاريخ الدخول' WHERE idfsBaseReference = 10080318 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Session - Session ID' WHERE idfsBaseReference = 10080312 -- old value 'AS Session - Session ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session - Session ID' WHERE idfsBaseReference = 10080312 AND idfsLanguage = 10049003 -- old value 'AS Session - Session ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესია - სესიის ID' WHERE idfsBaseReference = 10080312 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası - Sessiyanın Q/N-si' WHERE idfsBaseReference = 10080312 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة - معرّف الجلسة' WHERE idfsBaseReference = 10080312 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Session - Start Date' WHERE idfsBaseReference = 10080812 -- old value 'AS Session - Start Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session - Start Date' WHERE idfsBaseReference = 10080812 AND idfsLanguage = 10049003 -- old value 'AS Session - Start Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესია - დაწყების თარიღი' WHERE idfsBaseReference = 10080812 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası - Başlanma tarixi' WHERE idfsBaseReference = 10080812 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة - تاريخ البدء' WHERE idfsBaseReference = 10080812 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Session - Status' WHERE idfsBaseReference = 10080313 -- old value 'AS Session - Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session - Status' WHERE idfsBaseReference = 10080313 AND idfsLanguage = 10049003 -- old value 'AS Session - Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესია - სტატუსი' WHERE idfsBaseReference = 10080313 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası - Status' WHERE idfsBaseReference = 10080313 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة - الحالة' WHERE idfsBaseReference = 10080313 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Session Address - Country' WHERE idfsBaseReference = 10080314 -- old value 'AS Session Address - Country'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Address - Country' WHERE idfsBaseReference = 10080314 AND idfsLanguage = 10049003 -- old value 'AS Session Address - Country'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის მისამართი - ქვეყანა' WHERE idfsBaseReference = 10080314 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Ünvan - Ölkə' WHERE idfsBaseReference = 10080314 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'عنوان جلسة المراقبة البيطرية النشطة - البلد' WHERE idfsBaseReference = 10080314 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Session Address - Elevation (m)' WHERE idfsBaseReference = 10080588 -- old value 'AS Session Address - Elevation (m)'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Address - Elevation (m)' WHERE idfsBaseReference = 10080588 AND idfsLanguage = 10049003 -- old value 'AS Session Address - Elevation (m)'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის მისამართი - ელევაცია (მ)' WHERE idfsBaseReference = 10080588 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Ünvan - Hündürlük (m)' WHERE idfsBaseReference = 10080588 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'عنوان جلسة المراقبة البيطرية النشطة - الارتفاع (م)' WHERE idfsBaseReference = 10080588 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Session Address - Rayon' WHERE idfsBaseReference = 10080316 -- old value 'AS Session Address - Rayon'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Address - Rayon' WHERE idfsBaseReference = 10080316 AND idfsLanguage = 10049003 -- old value 'AS Session Address - Rayon'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის მისამართი - რაიონი' WHERE idfsBaseReference = 10080316 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Ünvan - Rayon ' WHERE idfsBaseReference = 10080316 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'عنوان جلسة المراقبة البيطرية النشطة - رايون ' WHERE idfsBaseReference = 10080316 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Session Address - Region' WHERE idfsBaseReference = 10080315 -- old value 'AS Session Address - Region'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Address - Region' WHERE idfsBaseReference = 10080315 AND idfsLanguage = 10049003 -- old value 'AS Session Address - Region'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის მისამართი - რეგიონი' WHERE idfsBaseReference = 10080315 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Ünvan - Region' WHERE idfsBaseReference = 10080315 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'عنوان جلسة المراقبة البيطرية النشطة - المنطقة' WHERE idfsBaseReference = 10080315 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'VAS Session Address - Settlement' WHERE idfsBaseReference = 10080317 -- old value 'AS Session Address - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Address - Settlement' WHERE idfsBaseReference = 10080317 AND idfsLanguage = 10049003 -- old value 'AS Session Address - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის მისამართი - დასახლება' WHERE idfsBaseReference = 10080317 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Ünvan - Yaşayış məntəqəsi' WHERE idfsBaseReference = 10080317 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'عنوان جلسة المراقبة البيطرية النشطة - الاقامة' WHERE idfsBaseReference = 10080317 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Test - Animal ID' WHERE idfsBaseReference = 10080286 AND idfsLanguage = 10049003 -- old value 'AS Session Test - Animal ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ტესტი - ცხოველის ID' WHERE idfsBaseReference = 10080286 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Test - Heyvanın Q/N-si' WHERE idfsBaseReference = 10080286 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار جلسة المراقبة البيطرية النشطة - الرقم التعريفي للحيوان ' WHERE idfsBaseReference = 10080286 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Test - Date Started' WHERE idfsBaseReference = 10080294 AND idfsLanguage = 10049003 -- old value 'AS Session Test - Date Started'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ტესტი - დაწყების თარიღი' WHERE idfsBaseReference = 10080294 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Test - Başlanma tarixi' WHERE idfsBaseReference = 10080294 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار جلسة المراقبة البيطرية النشطة - تاريخ البدء' WHERE idfsBaseReference = 10080294 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Test - Disease' WHERE idfsBaseReference = 10080292 AND idfsLanguage = 10049003 -- old value 'AS Session Test - Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ტესტი - დაავადება' WHERE idfsBaseReference = 10080292 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Test - Xəstəlik' WHERE idfsBaseReference = 10080292 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار جلسة المراقبة البيطرية النشطة - المرض' WHERE idfsBaseReference = 10080292 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Test - Disease - Is Zoonotic' WHERE idfsBaseReference = 10080557 AND idfsLanguage = 10049003 -- old value 'AS Session Test - Diagnosis - Is Zoonotic'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ტესტი - დაავადება - არის ზოონოზური' WHERE idfsBaseReference = 10080557 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Test - Xəstəlik - Zoonozdur' WHERE idfsBaseReference = 10080557 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار جلسة المراقبة البيطرية النشطة - مرض - حيوانيّ المصدر ' WHERE idfsBaseReference = 10080557 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Test - Farm Owner' WHERE idfsBaseReference = 10080288 AND idfsLanguage = 10049003 -- old value 'AS Session Test - Farm Owner'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ტესტი - ფერმის მესაკუთრე' WHERE idfsBaseReference = 10080288 AND idfsLanguage = 10049004 
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Test - Fermanın sahibi' WHERE idfsBaseReference = 10080288 AND idfsLanguage = 10049001 
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار جلسة المراقبة البيطرية النشطة - مالك المزرعة' WHERE idfsBaseReference = 10080288 AND idfsLanguage = 10049011 

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Test - Field Sample ID' WHERE idfsBaseReference = 10080290 AND idfsLanguage = 10049003 -- old value 'AS Session Test - Field Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ტესტი - საველე ნიმუშის ID' WHERE idfsBaseReference = 10080290 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Test - Nümunənin sahədəki Q/N-si' WHERE idfsBaseReference = 10080290 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار جلسة المراقبة البيطرية النشطة - عينة لمعرّف الحقل ' WHERE idfsBaseReference = 10080290 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Test - Is Entered by Laboratory' WHERE idfsBaseReference = 10080792 AND idfsLanguage = 10049003 -- old value 'AS Session Test - Is Entered by Laboratory'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080792 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ტესტი - შეყვანილია ლაბორატორიის მიერ' WHERE idfsBaseReference = 10080792 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის სესიის ტესტი - შეყვანილია ლაბორატორიის მიერ', 10080792, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080792 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Test - Laboratoriya tərəfindən daxil edildi' WHERE idfsBaseReference = 10080792 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Sessiyası Test - Laboratoriya tərəfindən daxil edildi', 10080792, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080792 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار جلسة المراقبة البيطرية النشطة - يتم ادخاله في المختبر ' WHERE idfsBaseReference = 10080792 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'اختبار جلسة المراقبة البيطرية النشطة - يتم ادخاله في المختبر ', 10080792, 10049011)

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Test - Lab Sample ID' WHERE idfsBaseReference = 10080289 AND idfsLanguage = 10049003 -- old value 'AS Session Test - Lab Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ტესტი - ლაბორატორიული ნიმუშის ID' WHERE idfsBaseReference = 10080289 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Test - Laborator nümunənin Q/N-si' WHERE idfsBaseReference = 10080289 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار جلسة المراقبة البيطرية النشطة - عينة لمعرّف المختبر' WHERE idfsBaseReference = 10080289 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Test - Result Date' WHERE idfsBaseReference = 10080295 AND idfsLanguage = 10049003 -- old value 'AS Session Test - Result Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ტესტი - შედეგის თარიღი' WHERE idfsBaseReference = 10080295 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Test - Nəticənin tarixi' WHERE idfsBaseReference = 10080295 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار جلسة المراقبة البيطرية النشطة - تاريخ النتيجة' WHERE idfsBaseReference = 10080295 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Test - Sample Type' WHERE idfsBaseReference = 10080291 AND idfsLanguage = 10049003 -- old value 'AS Session Test - Sample Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ტესტი - ნიმუშის ტიპი' WHERE idfsBaseReference = 10080291 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Test - Nümunənin növü' WHERE idfsBaseReference = 10080291 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار جلسة المراقبة البيطرية النشطة - نوع العينة' WHERE idfsBaseReference = 10080291 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Test - Session ID' WHERE idfsBaseReference = 10080285 AND idfsLanguage = 10049003 -- old value 'AS Session Test - Session ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ტესტი - სესიის ID' WHERE idfsBaseReference = 10080285 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Test - Sessiyanın Q/N-si' WHERE idfsBaseReference = 10080285 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار جلسة المراقبة البيطرية النشطة - معرّف الجلسة' WHERE idfsBaseReference = 10080285 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Test - Species' WHERE idfsBaseReference = 10080287 AND idfsLanguage = 10049003 -- old value 'AS Session Test - Species'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ტესტი - სახეობები' WHERE idfsBaseReference = 10080287 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Test - Heyvan növü' WHERE idfsBaseReference = 10080287 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار جلسة المراقبة البيطرية النشطة - أنواع الحيوانات' WHERE idfsBaseReference = 10080287 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Test - Status' WHERE idfsBaseReference = 10080296 AND idfsLanguage = 10049003 -- old value 'AS Session Test - Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ტესტი - სტატუსი' WHERE idfsBaseReference = 10080296 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Test - Status' WHERE idfsBaseReference = 10080296 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار جلسة المراقبة البيطرية النشطة - الحالة' WHERE idfsBaseReference = 10080296 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Test - Test Name' WHERE idfsBaseReference = 10080297 AND idfsLanguage = 10049003 -- old value 'AS Session Test - Test Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ტესტი - ტესტის დასახელება' WHERE idfsBaseReference = 10080297 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Test - Testin adı' WHERE idfsBaseReference = 10080297 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار جلسة المراقبة البيطرية النشطة - اسم الاختبار' WHERE idfsBaseReference = 10080297 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Test - Test Result' WHERE idfsBaseReference = 10080293 AND idfsLanguage = 10049003 -- old value 'AS Session Test - Test Result'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ტესტი - ტესტის შედეგი' WHERE idfsBaseReference = 10080293 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Test - Testin nəticəsi' WHERE idfsBaseReference = 10080293 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار جلسة المراقبة البيطرية النشطة - نتيجة الاختبار' WHERE idfsBaseReference = 10080293 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Test - Test Run ID' WHERE idfsBaseReference = 10080298 AND idfsLanguage = 10049003 -- old value 'AS Session Test - Test Run ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ტესტი - ტესტის ჩატარების  ID' WHERE idfsBaseReference = 10080298 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Test - Testin icra edilmə Q/N-si' WHERE idfsBaseReference = 10080298 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار جلسة المراقبة البيطرية النشطة - معرّف تشغيل  الاختبار' WHERE idfsBaseReference = 10080298 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Animal - Age' WHERE idfsBaseReference = 10080254 AND idfsLanguage = 10049003 -- old value 'AS Session Animal - Age'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ცხოველი - ასაკი' WHERE idfsBaseReference = 10080254 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Heyvan - Yaşı' WHERE idfsBaseReference = 10080254 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة  المراقبة البيطرية النشطة  للحيوان - العمر' WHERE idfsBaseReference = 10080254 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Animal - Animal ID' WHERE idfsBaseReference = 10080255 AND idfsLanguage = 10049003 -- old value 'AS Session Animal - Animal ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ცხოველი - ცხოველის ID' WHERE idfsBaseReference = 10080255 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Heyvan  - Heyvanın Q/N-si' WHERE idfsBaseReference = 10080255 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة  المراقبة البيطرية النشطة  للحيوان - الرقم التعريفي للحيوان' WHERE idfsBaseReference = 10080255 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Animal - Color' WHERE idfsBaseReference = 10080259 AND idfsLanguage = 10049003 -- old value 'AS Session Animal - Color'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ცხოველი - ფერი' WHERE idfsBaseReference = 10080259 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Heyvan - Rəngi' WHERE idfsBaseReference = 10080259 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة  المراقبة البيطرية النشطة  للحيوان - اللون' WHERE idfsBaseReference = 10080259 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Animal - Herd ID' WHERE idfsBaseReference = 10080256 AND idfsLanguage = 10049003 -- old value 'AS Session Animal - Herd ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ცხოველი - ჯოგის  ID' WHERE idfsBaseReference = 10080256 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Heyvan - Sürünün Q/N-si' WHERE idfsBaseReference = 10080256 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة  المراقبة البيطرية النشطة  للحيوان - معرّف القطيع' WHERE idfsBaseReference = 10080256 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Animal - Name' WHERE idfsBaseReference = 10080260 AND idfsLanguage = 10049003 -- old value 'AS Session Animal - Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ცხოველი - სახელი' WHERE idfsBaseReference = 10080260 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Heyvan - Adı' WHERE idfsBaseReference = 10080260 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة  المراقبة البيطرية النشطة  للحيوان - الاسم' WHERE idfsBaseReference = 10080260 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Animal - Sex' WHERE idfsBaseReference = 10080257 AND idfsLanguage = 10049003 -- old value 'AS Session Animal - Sex'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ცხოველი - სქესი' WHERE idfsBaseReference = 10080257 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Heyvan - Cinsiyyəti' WHERE idfsBaseReference = 10080257 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة  المراقبة البيطرية النشطة  للحيوان - الجنس' WHERE idfsBaseReference = 10080257 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Animal - Species' WHERE idfsBaseReference = 10080258 AND idfsLanguage = 10049003 -- old value 'AS Session Animal - Species'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ცხოველი - სახეობები' WHERE idfsBaseReference = 10080258 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Heyvan - Növü' WHERE idfsBaseReference = 10080258 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة  المراقبة البيطرية النشطة  للحيوان - الانواع' WHERE idfsBaseReference = 10080258 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Farm - Address' WHERE idfsBaseReference = 10080796 AND idfsLanguage = 10049003 -- old value 'AS Session Farm - Address'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080796 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ფერმა - მისამართი' WHERE idfsBaseReference = 10080796 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის სესიის ფერმა - მისამართი', 10080796, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080796 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Ünvanı' WHERE idfsBaseReference = 10080796 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Ünvanı', 10080796, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080796 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N' جلسة المراقبة البيطرية النشطة للمزرعة - العنوان' WHERE idfsBaseReference = 10080796 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N' جلسة المراقبة البيطرية النشطة للمزرعة - العنوان', 10080796, 10049011)

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Farm - Coordinates' WHERE idfsBaseReference = 10080797 AND idfsLanguage = 10049003 -- old value 'AS Session Farm - Coordinates'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080797 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ფერმა - კოორდინატები' WHERE idfsBaseReference = 10080797 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის სესიის ფერმა - კოორდინატები', 10080797, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080797 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Koordinatları' WHERE idfsBaseReference = 10080797 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'XXX', 10080797, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080797 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N' جلسة المراقبة البيطرية النشطة للمزرعة   - الاحداثيات' WHERE idfsBaseReference = 10080797 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N' جلسة المراقبة البيطرية النشطة للمزرعة   - الاحداثيات', 10080797, 10049011)

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Farm - Country' WHERE idfsBaseReference = 10080802 AND idfsLanguage = 10049003 -- old value 'AS Session Farm - Country'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080802 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ფერმა - ქვეყანა' WHERE idfsBaseReference = 10080802 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის სესიის ფერმა - ქვეყანა', 10080802, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080802 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Ölkə' WHERE idfsBaseReference = 10080802 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Ölkə', 10080802, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080802 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N' جلسة المراقبة البيطرية النشطة للمزرعة - البلد' WHERE idfsBaseReference = 10080802 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N' جلسة المراقبة البيطرية النشطة للمزرعة - البلد', 10080802, 10049011)

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Farm - Elevation (m)' WHERE idfsBaseReference = 10080799 AND idfsLanguage = 10049003 -- old value 'AS Session Farm - Elevation (m)'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080799 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ფერმა - ელევაცია (მ)' WHERE idfsBaseReference = 10080799 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის სესიის ფერმა - ელევაცია (მ)', 10080799, 10049004)
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Hündürlük (m)' WHERE idfsBaseReference = 10080799 AND idfsLanguage = 10049001
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080799 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N' جلسة المراقبة البيطرية النشطة للمزرعة - الارتفاع (م)' WHERE idfsBaseReference = 10080799 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N' جلسة المراقبة البيطرية النشطة للمزرعة - الارتفاع (م)', 10080799, 10049011)

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Farm - Email' WHERE idfsBaseReference = 10080806 AND idfsLanguage = 10049003 -- old value 'AS Session Farm - Email'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080806 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ფერმა - ელექტრონული ფოსტა' WHERE idfsBaseReference = 10080806 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის სესიის ფერმა - ელექტრონული ფოსტა', 10080806, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080806 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Elektron poçt ünvanı' WHERE idfsBaseReference = 10080806 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Elektron poçt ünvanı', 10080806, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080806 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة للمزرعة   - البريد الالكتروني' WHERE idfsBaseReference = 10080806 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'جلسة المراقبة البيطرية النشطة للمزرعة   - البريد الالكتروني', 10080806, 10049011)

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Farm - Fax' WHERE idfsBaseReference = 10080807 AND idfsLanguage = 10049003 -- old value 'AS Session Farm - Fax'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080807 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ფერმა - ფაქსი' WHERE idfsBaseReference = 10080807 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის სესიის ფერმა - ფაქსი', 10080807, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080807 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Faks nömrəsi' WHERE idfsBaseReference = 10080807 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Faks nömrəsi', 10080807, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080807 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة للمزرعة - فاكس' WHERE idfsBaseReference = 10080807 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'جلسة المراقبة البيطرية النشطة للمزرعة - فاكس', 10080807, 10049011)

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Farm - ID' WHERE idfsBaseReference = 10080242 AND idfsLanguage = 10049003 -- old value 'AS Session Farm - ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ფერმა - ID' WHERE idfsBaseReference = 10080242 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Q/N-si' WHERE idfsBaseReference = 10080242 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة للمزرعة   - معرّف' WHERE idfsBaseReference = 10080242 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Farm - Latitude' WHERE idfsBaseReference = 10080803 AND idfsLanguage = 10049003 -- old value 'AS Session Farm - Latitude'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080803 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ფერმა - განედი' WHERE idfsBaseReference = 10080803 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის სესიის ფერმა - განედი', 10080803, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080803 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - En dairəsi' WHERE idfsBaseReference = 10080803 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - En dairəsi', 10080803, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080803 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة للمزرعة   - خط العرض' WHERE idfsBaseReference = 10080803 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'جلسة المراقبة البيطرية النشطة للمزرعة   - خط العرض', 10080803, 10049011)

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Farm - Longitude' WHERE idfsBaseReference = 10080804 AND idfsLanguage = 10049003 -- old value 'AS Session Farm - Longitude'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080804 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ფერმა გრძედი' WHERE idfsBaseReference = 10080804 AND idfsLanguage = 10049004  -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის სესიის ფერმა გრძედი', 10080804, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080804 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Uzunluq dairəsi' WHERE idfsBaseReference = 10080804 AND idfsLanguage = 10049001 
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Uzunluq dairəsi', 10080804, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080804 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة للمزرعة  - خط الطول' WHERE idfsBaseReference = 10080804 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'جلسة المراقبة البيطرية النشطة للمزرعة  - خط الطول', 10080804, 10049011)

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Farm - Name' WHERE idfsBaseReference = 10080243 AND idfsLanguage = 10049003 -- old value 'AS Session Farm - Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ფერმა - დასახელება' WHERE idfsBaseReference = 10080243 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Adı' WHERE idfsBaseReference = 10080243 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة للمزرعة   - الاسم' WHERE idfsBaseReference = 10080243 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Farm - Owner' WHERE idfsBaseReference = 10080244 AND idfsLanguage = 10049003 -- old value 'AS Session Farm - Owner'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ფერმა - მესაკუთრე' WHERE idfsBaseReference = 10080244 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Sahibi' WHERE idfsBaseReference = 10080244 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة للمزرعة  - المالك' WHERE idfsBaseReference = 10080244 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Farm - Ownership Structure' WHERE idfsBaseReference = 10080245 AND idfsLanguage = 10049003 -- old value 'AS Session Farm - Ownership Structure'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ფერმა - საკუთრების სტრუქტურა' WHERE idfsBaseReference = 10080245 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Mülkiyyətin növü' WHERE idfsBaseReference = 10080245 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة للمزرعة  - هيكل الملكية' WHERE idfsBaseReference = 10080245 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Farm - Phone' WHERE idfsBaseReference = 10080808 AND idfsLanguage = 10049003 -- old value 'AS Session Farm - Phone'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080808 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ფერმა - ტელეფონი' WHERE idfsBaseReference = 10080808 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის სესიის ფერმა - ტელეფონი', 10080808, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080808 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Telefon nömrəsi' WHERE idfsBaseReference = 10080808 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Telefon nömrəsi', 10080808, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080808 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة للمزرعة  - الهاتف' WHERE idfsBaseReference = 10080808 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'جلسة المراقبة البيطرية النشطة للمزرعة  - الهاتف', 10080808, 10049011)

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Farm - Postal Code' WHERE idfsBaseReference = 10080805 AND idfsLanguage = 10049003 -- old value 'AS Session Farm - Postal Code'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080805 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ფერმა - საფოსტო კოდი' WHERE idfsBaseReference = 10080805 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის სესიის ფერმა - საფოსტო კოდი', 10080805, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080805 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Poçt indeksi' WHERE idfsBaseReference = 10080805 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Poçt indeksi', 10080805, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080805 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة للمزرعة   - الرمز البريدي' WHERE idfsBaseReference = 10080805 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'جلسة المراقبة البيطرية النشطة للمزرعة   - الرمز البريدي', 10080805, 10049011)

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Farm - Rayon' WHERE idfsBaseReference = 10080800 AND idfsLanguage = 10049003 -- old value 'AS Session Farm - Rayon'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080800 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ფერმა - რაიონი' WHERE idfsBaseReference = 10080800 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის სესიის ფერმა - რაიონი', 10080800, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080800 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Rayon' WHERE idfsBaseReference = 10080800 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Rayon', 10080800, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080800 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة للمزرعة  - رايون' WHERE idfsBaseReference = 10080800 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'جلسة المراقبة البيطرية النشطة للمزرعة  - رايون', 10080800, 10049011)

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Farm - Region' WHERE idfsBaseReference = 10080801 AND idfsLanguage = 10049003 -- old value 'AS Session Farm - Region'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080801 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ფერმა - რეგიონი' WHERE idfsBaseReference = 10080801 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის სესიის ფერმა - რეგიონი', 10080801, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080801 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Region' WHERE idfsBaseReference = 10080801 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Region', 10080801, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080801 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة للمزرعة   - المنطقة' WHERE idfsBaseReference = 10080801 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'جلسة المراقبة البيطرية النشطة للمزرعة   - المنطقة', 10080801, 10049011)

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Farm - Settlement' WHERE idfsBaseReference = 10080798 AND idfsLanguage = 10049003 -- old value 'AS Session Farm - Town or Village'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080798 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის ფერმა - დასახლება' WHERE idfsBaseReference = 10080798 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვაზ-ის სესიის ფერმა - დასახლება', 10080798, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080798 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Yaşayış məntəqəsi' WHERE idfsBaseReference = 10080798 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Fəal Müşahidə Sessiyası Ferma - Yaşayış məntəqəsi', 10080798, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080798 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة للمزرعة  - الاقامة' WHERE idfsBaseReference = 10080798 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'جلسة المراقبة البيطرية النشطة للمزرعة  - الاقامة', 10080798, 10049011)

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Herd/Flock - Farm ID' WHERE idfsBaseReference = 10080248 AND idfsLanguage = 10049003 -- old value 'AS Session Herd - Farm ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესია ჯოგი/ფარა-ფერმის ID' WHERE idfsBaseReference = 10080248 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Sürü/Dəstə - Fermanın Q/N-si' WHERE idfsBaseReference = 10080248 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة للقطيع - معرّف المزرعة' WHERE idfsBaseReference = 10080248 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Herd/Flock - Herd ID' WHERE idfsBaseReference = 10080247 AND idfsLanguage = 10049003 -- old value 'AS Session Herd - Herd ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესია ჯოგი/ფარა- ჯოგის  ID' WHERE idfsBaseReference = 10080247 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Sürü/Dəstə - Sürünün Q/N-si' WHERE idfsBaseReference = 10080247 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة للقطيع - معرّف القطيع' WHERE idfsBaseReference = 10080247 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Herd/Flock - Total Number Of Animals' WHERE idfsBaseReference = 10080249 AND idfsLanguage = 10049003 -- old value 'AS Session Herd - Total Number Of Animals'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესია ჯოგი/ფარა-ცხოველების საერთო რაოდენობა' WHERE idfsBaseReference = 10080249 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Sürü/Dəstə - Heyvanların ümumi sayı' WHERE idfsBaseReference = 10080249 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة للقطيع -  إجمالي عدد الحيوانات' WHERE idfsBaseReference = 10080249 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Species - Animal Species' WHERE idfsBaseReference = 10080252 AND idfsLanguage = 10049003 -- old value 'AS Session Species - Animal Species'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის სახეობები - ცხოველის სახეობები' WHERE idfsBaseReference = 10080252 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Növlər - Heyvan növü' WHERE idfsBaseReference = 10080252 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة للانواع -  أنواع الحيوانات' WHERE idfsBaseReference = 10080252 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Species - Herd ID' WHERE idfsBaseReference = 10080250 AND idfsLanguage = 10049003 -- old value 'AS Session Species - Herd ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის სახეობები - ჯოგის ID' WHERE idfsBaseReference = 10080250 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Növlər - Sürünün Q/N-si' WHERE idfsBaseReference = 10080250 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة للانواع -  معرّف القطيع' WHERE idfsBaseReference = 10080250 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Species - Note (include breed)' WHERE idfsBaseReference = 10080251 AND idfsLanguage = 10049003 -- old value 'AS Session Species - Note (include breed)'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის სახეობები - შენიშვნა ( მომრავლების ჩათვლით)' WHERE idfsBaseReference = 10080251 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Növlər - Qeyd (cinsini daxil edin)' WHERE idfsBaseReference = 10080251 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة للانواع -  ملاحظة ( مع شمل السلالة)' WHERE idfsBaseReference = 10080251 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'VAS Session Species - Total Number of Animals' WHERE idfsBaseReference = 10080253 AND idfsLanguage = 10049003 -- old value 'AS Session Species - Total Number of Animals'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვაზ-ის სესიის სახეობები - ცხოველების საერთო რაოდენობა' WHERE idfsBaseReference = 10080253 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Fəal Müşahidə Sessiyası Növlər - Heyvanların ümumi sayı' WHERE idfsBaseReference = 10080253 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'جلسة المراقبة البيطرية النشطة للانواع -   إجمالي عدد الحيوانات' WHERE idfsBaseReference = 10080253 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Case/Vector Entity - Disease' WHERE idfsBaseReference = 10080336 -- old value 'Case/Vector Entity - Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Case/Vector Entity - Disease' WHERE idfsBaseReference = 10080336 AND idfsLanguage = 10049003 -- old value 'Case/Vector Entity - Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'შემთხვევა/ვექტორი-დაავადება' WHERE idfsBaseReference = 10080336 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Hadisə/Keçirici - Xəstəlik' WHERE idfsBaseReference = 10080336 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'الحالة/ الكينونة المتجهة - المرض' WHERE idfsBaseReference = 10080336 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Case/Vector Entity - Disease - Is Zoonotic' WHERE idfsBaseReference = 10080558 -- old value 'Case/Vector Entity - Diagnosis - Is Zoonotic'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Case/Vector Entity - Disease - Is Zoonotic' WHERE idfsBaseReference = 10080558 AND idfsLanguage = 10049003 -- old value 'Case/Vector Entity - Diagnosis - Is Zoonotic'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'შემთხვევა/ვექტორი/დაავადება-არის ზოონოზური' WHERE idfsBaseReference = 10080558 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Hadisə/Keçirici - Xəstəlik - Zoonozdur' WHERE idfsBaseReference = 10080558 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'الحالة/ الكينونة المتجهة - المرض - حيوانيّ المصدر' WHERE idfsBaseReference = 10080558 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Case/Vector Entity - Date of Disease' WHERE idfsBaseReference = 10080335 -- old value 'Case/Vector Entity - Diagnosis Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Case/Vector Entity - Date of Disease' WHERE idfsBaseReference = 10080335 AND idfsLanguage = 10049003 -- old value 'Case/Vector Entity - Diagnosis Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'შემთხვევა/ვექტორი/დაავადების თარიღი' WHERE idfsBaseReference = 10080335 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Hadisə/Keçirici - Xəstəliyin aşkar olunma tarixi' WHERE idfsBaseReference = 10080335 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'الحالة/ الكينونة المتجهة -  تاريخ المرض' WHERE idfsBaseReference = 10080335 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Case/Vector Entity - Settlement' WHERE idfsBaseReference = 10080332 -- old value 'Case/Vector Entity - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Case/Vector Entity - Settlement' WHERE idfsBaseReference = 10080332 AND idfsLanguage = 10049003 -- old value 'Case/Vector Entity - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'შემთხვევა/ვექტორი/დასახლება' WHERE idfsBaseReference = 10080332 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Hadisə/Keçirici - Yaşayış məntəqəsi' WHERE idfsBaseReference = 10080332 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'الحالة/ الكينونة المتجهة -  الاقامة' WHERE idfsBaseReference = 10080332 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Combined Diseases - Report Type' WHERE idfsBaseReference = 10080459 -- old value 'Combined Diseases - Case Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Combined Diseases - Report Type' WHERE idfsBaseReference = 10080459 AND idfsLanguage = 10049003 -- old value 'Combined Diseases - Case Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'კომბინირებული დაავადებები - ანგარიშის ტიპი' WHERE idfsBaseReference = 10080459 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Birləşdirilmiş Xəstəliklər - Hesabat növü' WHERE idfsBaseReference = 10080459 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'الامراض المشتركة - نوع التقرير ' WHERE idfsBaseReference = 10080459 AND idfsLanguage = 10049011
-- Hide extra 'Combined Diseases - Report Type' field
UPDATE dbo.trtBaseReference SET intRowStatus = 1 WHERE idfsBaseReference = 10080494

UPDATE dbo.trtBaseReference SET strDefault = N'Combined Diseases - Diseases Group' WHERE idfsBaseReference = 10080579 -- old value 'Combined Diseases - Diagnoses Group'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Combined Diseases - Diseases Group' WHERE idfsBaseReference = 10080579 AND idfsLanguage = 10049003 -- old value 'Combined Diseases - Diagnoses Group'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'კომბინირებული დაავადებები - დაავადებების ჯგუფი' WHERE idfsBaseReference = 10080579 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Birləşdirilmiş Xəstəliklər - Xəstəliklər qrupu' WHERE idfsBaseReference = 10080579 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'الامراض المشتركة - مجموعة الامراض' WHERE idfsBaseReference = 10080579 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Combined Diseases - Disease' WHERE idfsBaseReference = 10080468 -- old value 'Combined Diseases - Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Combined Diseases - Disease' WHERE idfsBaseReference = 10080468 AND idfsLanguage = 10049003 -- old value 'Combined Diseases - Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'კომბინირებული დაავადებები - დაავადება' WHERE idfsBaseReference = 10080468 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Birləşdirilmiş Xəstəliklər - Xəstəlik' WHERE idfsBaseReference = 10080468 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'الامراض المشتركة - المرض' WHERE idfsBaseReference = 10080468 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Combined Diseases - Disease - Is Zoonotic' WHERE idfsBaseReference = 10080556 -- old value 'Combined Diseases - Diagnosis - Is Zoonotic'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Combined Diseases - Disease - Is Zoonotic' WHERE idfsBaseReference = 10080556 AND idfsLanguage = 10049003 -- old value 'Combined Diseases - Diagnosis - Is Zoonotic'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'კომბინირებული დაავადებები - დაავადება - არის ზოონოზური' WHERE idfsBaseReference = 10080556 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Birləşdirilmiş Xəstəliklər - Xəstəlik - Zoonozdur' WHERE idfsBaseReference = 10080556 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'الامراض المشتركة - المرض - حيوانيّ المصدر' WHERE idfsBaseReference = 10080556 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Combined Diseases - Location of Exposure - Settlement' WHERE idfsBaseReference = 10080482 AND idfsLanguage = 10049003 -- old value 'Combined Diseases - Location of Exposure - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'კომბინირებული დაავადებები - ექსპოზიციის ადგილი - დასახლება' WHERE idfsBaseReference = 10080482 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Birləşdirilmiş Xəstəliklər - Yoluxma yeri - Yaşayış məntəqəsi' WHERE idfsBaseReference = 10080482 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'الامراض المشتركة - مكان الحادثة - الاقامة' WHERE idfsBaseReference = 10080482 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Combined Diseases - Patient Employer - Settlement' WHERE idfsBaseReference = 10080487 -- old value 'Combined Diseases - Patient Employer - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Combined Diseases - Patient Employer - Settlement' WHERE idfsBaseReference = 10080487 AND idfsLanguage = 10049003 -- old value 'Combined Diseases - Patient Employer - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'კომბინირებული დაავადებები -პაციენტის დამსაქმებელი - დასახლება' WHERE idfsBaseReference = 10080487 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Birləşdirilmiş Xəstəliklər - Xəstənin iş yeri - Yaşayış məntəqəsi' WHERE idfsBaseReference = 10080487 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'الامراض المشتركة - المريض وهو صاحب العمل - الاقامة' WHERE idfsBaseReference = 10080487 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Combined Diseases - Settlement' WHERE idfsBaseReference = 10080463 -- old value 'Combined Diseases - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Combined Diseases - Settlement' WHERE idfsBaseReference = 10080463 AND idfsLanguage = 10049003 -- old value 'Combined Diseases - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'კომბინირებული დაავადებები - დასახლება' WHERE idfsBaseReference = 10080463 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Birləşdirilmiş Xəstəliklər - Yaşayış məntəqəsi' WHERE idfsBaseReference = 10080463 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'الامراض المشتركة  - الاقامة' WHERE idfsBaseReference = 10080463 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Farm - Settlement' WHERE idfsBaseReference = 10080538 -- old value 'Farm - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Farm - Settlement' WHERE idfsBaseReference = 10080538 AND idfsLanguage = 10049003 -- old value 'Farm - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ფერმა - დასახლება' WHERE idfsBaseReference = 10080538 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Ferma - Yaşayış məntəqəsi' WHERE idfsBaseReference = 10080538 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'المزرعة - الاقامة' WHERE idfsBaseReference = 10080538 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report Column - Name' WHERE idfsBaseReference = 10080712 -- old value 'Human Aggregate Case Column - Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report Column - Name' WHERE idfsBaseReference = 10080712 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case Column - Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიშის სვეტი - სახელი' WHERE idfsBaseReference = 10080712 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat Sütunu - Adı' WHERE idfsBaseReference = 10080712 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'عمود التقرير الإجمالي عن الأمراض البشرية - الاسم' WHERE idfsBaseReference = 10080712 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report Column - Numeric Value' WHERE idfsBaseReference = 10080714 -- old value 'Human Aggregate Case Column - Numeric Value'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report Column - Numeric Value' WHERE idfsBaseReference = 10080714 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case Column - Numeric Value'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიშის სვეტი - რიცხობრივი მნიშვნელობა' WHERE idfsBaseReference = 10080714 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat Sütunu - Rəqəm göstəricisi' WHERE idfsBaseReference = 10080714 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'عمود التقرير الإجمالي عن الأمراض البشرية - القيمة العددية' WHERE idfsBaseReference = 10080714 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report Column - Text Value' WHERE idfsBaseReference = 10080713 -- old value 'Human Aggregate Case Column - Text Value'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report Column - Text Value' WHERE idfsBaseReference = 10080713 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case Column - Text Value'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიშის სვეტი - ტექსტის მნიშვნელობა' WHERE idfsBaseReference = 10080713 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat Sütunu - Mətn göstəricisi' WHERE idfsBaseReference = 10080713 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'عمود التقرير الإجمالي عن الأمراض البشرية - القيمة النصية' WHERE idfsBaseReference = 10080713 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Administrative Level' WHERE idfsBaseReference = 10080710 -- old value 'Human Aggregate Case - Administrative Level'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Administrative Level' WHERE idfsBaseReference = 10080710 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Administrative Level'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - ადმინისტრაციული  დონე' WHERE idfsBaseReference = 10080710 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080710 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N' التقرير الإجمالي عن الأمراض البشرية - المستوى الاداري' WHERE idfsBaseReference = 10080710 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Disease Report ID' WHERE idfsBaseReference = 10080708 -- old value 'Human Aggregate Case - Case ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Disease Report ID' WHERE idfsBaseReference = 10080708 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Case ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - დაავადების ანგარიშის ID' WHERE idfsBaseReference = 10080708 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080708 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N' التقرير الإجمالي عن الأمراض البشرية - معرّف تقرير المرض' WHERE idfsBaseReference = 10080708 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Country' WHERE idfsBaseReference = 10080694 -- old value 'Human Aggregate Case - Country'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Country' WHERE idfsBaseReference = 10080694 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Country'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - ქვეყანა' WHERE idfsBaseReference = 10080694 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080694 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N' التقرير الإجمالي عن الأمراض البشرية - البلد' WHERE idfsBaseReference = 10080694 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Date of Entry' WHERE idfsBaseReference = 10080690 -- old value 'Human Aggregate Case - Date of Entry'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Date of Entry' WHERE idfsBaseReference = 10080690 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Date of Entry'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - შეყვანის თარიღი' WHERE idfsBaseReference = 10080690 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080690 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N' التقرير الإجمالي عن الأمراض البشرية - تاريخ الدخول' WHERE idfsBaseReference = 10080690 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Disease' WHERE idfsBaseReference = 10080685 -- old value 'Human Aggregate Case - Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Disease' WHERE idfsBaseReference = 10080685 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - დაავადება' WHERE idfsBaseReference = 10080685 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080685 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N' التقرير الإجمالي عن الأمراض البشرية - المرض' WHERE idfsBaseReference = 10080685 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Disease - Is Zoonotic' WHERE idfsBaseReference = 10080687 -- old value 'Human Aggregate Case - Diagnosis - Is Zoonotic'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Disease - Is Zoonotic' WHERE idfsBaseReference = 10080687 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Diagnosis - Is Zoonotic'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - დაავადება - არის ზოონოზური' WHERE idfsBaseReference = 10080687 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080687 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N' التقرير الإجمالي عن الأمراض البشرية - المرض - حيوانيّ المصدر' WHERE idfsBaseReference = 10080687 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Disease Code' WHERE idfsBaseReference = 10080686 -- old value 'Human Aggregate Case - Diagnosis Code'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Disease Code' WHERE idfsBaseReference = 10080686 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Diagnosis Code'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - დაავადების კოდი' WHERE idfsBaseReference = 10080686 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat ' WHERE idfsBaseReference = 10080686 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N' التقرير الإجمالي عن الأمراض البشرية - رمز المرض' WHERE idfsBaseReference = 10080686 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Elevation (m)' WHERE idfsBaseReference = 10080698 -- old value 'Human Aggregate Case - Elevation (m)'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Elevation (m)' WHERE idfsBaseReference = 10080698 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Elevation (m)'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - ელევაცია (მ)' WHERE idfsBaseReference = 10080698 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080698 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N' التقرير الإجمالي عن الأمراض البشرية - الارتفاع  (م)' WHERE idfsBaseReference = 10080698 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Entered by Officer' WHERE idfsBaseReference = 10080707 -- old value 'Human Aggregate Case - Entered by Officer'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Entered by Officer' WHERE idfsBaseReference = 10080707 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Entered by Officer'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - შეყვანილია თანამშრომლის მიერ' WHERE idfsBaseReference = 10080707 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080707 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N' التقرير الإجمالي عن الأمراض البشرية - يُدخله الموظف' WHERE idfsBaseReference = 10080707 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Entered by Organization - Abbreviation' WHERE idfsBaseReference = 10080701 -- old value 'Human Aggregate Case - Entered by Organization - Abbreviation'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Entered by Organization - Abbreviation' WHERE idfsBaseReference = 10080701 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Entered by Organization - Abbreviation'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - შეყვანილია ორგანიზაციის მიერ - აბრევიაცია' WHERE idfsBaseReference = 10080701 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080701 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N' التقرير الإجمالي عن الأمراض البشرية - تُدخله المنظمة - الاختصار' WHERE idfsBaseReference = 10080701 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Entered by Organization - ID' WHERE idfsBaseReference = 10080704 -- old value 'Human Aggregate Case - Entered by Organization - ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Entered by Organization - ID' WHERE idfsBaseReference = 10080704 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Entered by Organization - ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - შეყვანილია ორგანიზაციის მიერ  - ID' WHERE idfsBaseReference = 10080704 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080704 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N' التقرير الإجمالي عن الأمراض البشرية - تُدخله المنظمة - المعرّف' WHERE idfsBaseReference = 10080704 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Notification Received by Institution - ID' WHERE idfsBaseReference = 10080703 -- old value 'Human Aggregate Case - Notification Received by Institution - ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Notification Received by Institution - ID' WHERE idfsBaseReference = 10080703 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Notification Received by Institution - ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - შეტყობინება მიღებულია დაწესებულების მიერ - ID' WHERE idfsBaseReference = 10080703 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080703 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'التقرير الإجمالي عن الأمراض البشرية - الإخطار الذي تلقته المؤسسة - المعرّف' WHERE idfsBaseReference = 10080703 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Notification Received by Institution - Name' WHERE idfsBaseReference = 10080700 -- old value 'Human Aggregate Case - Notification Received by Institution - Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Notification Received by Institution - Name' WHERE idfsBaseReference = 10080700 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Notification Received by Institution - Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - შეტყობინება მიღებულია დაწესებულების მიერ - დასახელება' WHERE idfsBaseReference = 10080700 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080700 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'التقرير الإجمالي عن الأمراض البشرية - الإخطار الذي تلقته المؤسسة - الاسم' WHERE idfsBaseReference = 10080700 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Notification Received by Officer' WHERE idfsBaseReference = 10080706 -- old value 'Human Aggregate Case - Notification Received by Officer'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Notification Received by Officer' WHERE idfsBaseReference = 10080706 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Notification Received by Officer'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - შეტყობინება მიღებულია თანამშრომლის მიერ' WHERE idfsBaseReference = 10080706 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080706 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'التقرير الإجمالي عن الأمراض البشرية - الإخطار الذي تلقاه الموظف' WHERE idfsBaseReference = 10080706 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Notification Received Date' WHERE idfsBaseReference = 10080689 -- old value 'Human Aggregate Case - Notification Received Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Notification Received Date' WHERE idfsBaseReference = 10080689 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Notification Received Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - შეტყობინების მიღების თარიღი' WHERE idfsBaseReference = 10080689 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080689 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'التقرير الإجمالي عن الأمراض البشرية - تاريخ تلقي الإخطار ' WHERE idfsBaseReference = 10080689 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Notification Sent by Institution - ID' WHERE idfsBaseReference = 10080702 -- old value 'Human Aggregate Case - Notification Sent by Institution - ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Notification Sent by Institution - ID' WHERE idfsBaseReference = 10080702 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Notification Sent by Institution - ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - შეტყობინება გაგზავნილია დაწესებულების მიერ - ID' WHERE idfsBaseReference = 10080702 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080702 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'التقرير الإجمالي عن الأمراض البشرية - الاخطار المرسل من المؤسسة- المعرّف' WHERE idfsBaseReference = 10080702 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Notification Sent by Institution - Name' WHERE idfsBaseReference = 10080699 -- old value 'Human Aggregate Case - Notification Sent by Institution - Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Notification Sent by Institution - Name' WHERE idfsBaseReference = 10080699 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Notification Sent by Institution - Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - შეტყობინება გაგზავნილია დაწესებულების მიერ - დასახელება' WHERE idfsBaseReference = 10080699 AND idfsLanguage = 10049004 
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080699 AND idfsLanguage = 10049001 
UPDATE dbo.trtStringNameTranslation SET strTextString = N'التقرير الإجمالي عن الأمراض البشرية - الاخطار المرسل من المؤسسة- الاسم' WHERE idfsBaseReference = 10080699 AND idfsLanguage = 10049011 

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Notification Sent by Officer' WHERE idfsBaseReference = 10080705 -- old value 'Human Aggregate Case - Notification Sent by Officer'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Notification Sent by Officer' WHERE idfsBaseReference = 10080705 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Notification Sent by Officer'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - შეტყობინება გაგზავნილია თანამშრომლის მიერ' WHERE idfsBaseReference = 10080705 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080705 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'التقرير الإجمالي عن الأمراض البشرية - الإخطار الذي أرسله الموظف' WHERE idfsBaseReference = 10080705 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Notification Sent Date' WHERE idfsBaseReference = 10080688 -- old value 'Human Aggregate Case - Notification Sent Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Notification Sent Date' WHERE idfsBaseReference = 10080688 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Notification Sent Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - შეტყობინების გაგზავნის თარიღი' WHERE idfsBaseReference = 10080688 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080688 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'التقرير الإجمالي عن الأمراض البشرية - تاريخ ارسال الإخطار ' WHERE idfsBaseReference = 10080688 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Rayon' WHERE idfsBaseReference = 10080696 -- old value 'Human Aggregate Case - Rayon'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Rayon' WHERE idfsBaseReference = 10080696 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Rayon'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - რაიონი' WHERE idfsBaseReference = 10080696 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080696 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'التقرير الإجمالي عن الأمراض البشرية - رايون' WHERE idfsBaseReference = 10080696 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Region' WHERE idfsBaseReference = 10080695 -- old value 'Human Aggregate Case - Region'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Region' WHERE idfsBaseReference = 10080695 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Region'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - რეგიონი' WHERE idfsBaseReference = 10080695 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080695 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'التقرير الإجمالي عن الأمراض البشرية - المنطقة' WHERE idfsBaseReference = 10080695 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Time Interval Date for grouping' WHERE idfsBaseReference = 10080693 -- old value 'Human Aggregate Case - Time Interval Date for grouping'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Time Interval Date for grouping' WHERE idfsBaseReference = 10080693 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Time Interval Date for grouping'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - დაჯგუფების დროის შუალედის თარიღი' WHERE idfsBaseReference = 10080693 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080693 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'التقرير الإجمالي عن الأمراض البشرية - تاريخ الفاصل الزمني للتجمع' WHERE idfsBaseReference = 10080693 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Time Interval End Date' WHERE idfsBaseReference = 10080692 -- old value 'Human Aggregate Case - Time Interval End Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Time Interval End Date' WHERE idfsBaseReference = 10080692 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Time Interval End Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - დროის შუალედის დასრულების თარიღი' WHERE idfsBaseReference = 10080692 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080692 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'التقرير الإجمالي عن الأمراض البشرية - تاريخ  انتهاء الفاصل الزمني ' WHERE idfsBaseReference = 10080692 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Time Interval Start Date' WHERE idfsBaseReference = 10080691 -- old value 'Human Aggregate Case - Time Interval Start Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Time Interval Start Date' WHERE idfsBaseReference = 10080691 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Time Interval Start Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - დროის შუალედის დაწყების თარიღი' WHERE idfsBaseReference = 10080691 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080691 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'التقرير الإجمالي عن الأمراض البشرية - تاريخ  بدء  الفاصل الزمني ' WHERE idfsBaseReference = 10080691 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Time Interval Unit' WHERE idfsBaseReference = 10080709 -- old value 'Human Aggregate Case - Time Interval Unit'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Time Interval Unit' WHERE idfsBaseReference = 10080709 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Time Interval Unit'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - დროის შუალედის ერთეული' WHERE idfsBaseReference = 10080709 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080709 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'التقرير الإجمالي عن الأمراض البشرية - وحدة الفاصل الزمني ' WHERE idfsBaseReference = 10080709 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Total' WHERE idfsBaseReference = 10080711 -- old value 'Human Aggregate Case - Total'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Total' WHERE idfsBaseReference = 10080711 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Total'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - საერთო' WHERE idfsBaseReference = 10080711 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080711 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'التقرير الإجمالي عن الأمراض البشرية - المجموع ' WHERE idfsBaseReference = 10080711 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Aggregate Disease Report - Settlement' WHERE idfsBaseReference = 10080697 -- old value 'Human Aggregate Case - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Aggregate Disease Report - Settlement' WHERE idfsBaseReference = 10080697 AND idfsLanguage = 10049003 -- old value 'Human Aggregate Case - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების აგრეგირებული ანგარიში - დასახლება' WHERE idfsBaseReference = 10080697 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Cəmləşdirilmiş İnsan Xəstəliyi üzrə Heabat' WHERE idfsBaseReference = 10080697 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'التقرير الإجمالي عن الأمراض البشرية - الاقامة' WHERE idfsBaseReference = 10080697 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Age Group' WHERE idfsBaseReference = 10080497 AND idfsLanguage = 10049003 -- old value 'Age Group'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ასაკობრივი ჯგუფი' WHERE idfsBaseReference = 10080497 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Yaş qrupu' WHERE idfsBaseReference = 10080497 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  الفئة العمرية ' WHERE idfsBaseReference = 10080497 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Antibiotic - Date First Administrated' WHERE idfsBaseReference = 10080021 AND idfsLanguage = 10049003 -- old value 'Antibiotic - Date First Administrated'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების  ანგარიში - ანტიბიოტიკი - პირველად დანიშვნის თარიღი' WHERE idfsBaseReference = 10080021 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Antibiotik - İlk təyinat tarixi' WHERE idfsBaseReference = 10080021 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  مضاد حيوي - تاريخ  أول موعد ' WHERE idfsBaseReference = 10080021 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Antibiotic - Dose' WHERE idfsBaseReference = 10080028 AND idfsLanguage = 10049003 -- old value 'Antibiotic - Dose'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების  ანგარიში - ანტიბიოტიკი -დოზა' WHERE idfsBaseReference = 10080028 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Antibiotik - Doza' WHERE idfsBaseReference = 10080028 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  مضاد حيوي - جرعة' WHERE idfsBaseReference = 10080028 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Antibiotic - Name' WHERE idfsBaseReference = 10080027 AND idfsLanguage = 10049003 -- old value 'Antibiotic - Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ანტიბიოტიკი - დასახელება' WHERE idfsBaseReference = 10080027 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Antibiotik - Adı' WHERE idfsBaseReference = 10080027 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  مضاد حيوي - الاسم ' WHERE idfsBaseReference = 10080027 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Contact - Date of Last Contact' WHERE idfsBaseReference = 10080034 AND idfsLanguage = 10049003 -- old value 'Contact - Date of Last Contact'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - კონტაქტი - ბოლო კონტაქტის თარიღი' WHERE idfsBaseReference = 10080034 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Təmasda olan şəxs - Son təmas tarixi' WHERE idfsBaseReference = 10080034 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  التواصل - تاريخ آخر اتصال ' WHERE idfsBaseReference = 10080034 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Contact - Information' WHERE idfsBaseReference = 10080032 AND idfsLanguage = 10049003 -- old value 'Contact - Information'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - კონტაქტი - ინფორმაცია' WHERE idfsBaseReference = 10080032 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Təmasda olan şəxs - Məlumat' WHERE idfsBaseReference = 10080032 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  التواصل - المعلومات ' WHERE idfsBaseReference = 10080032 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Contact - Name' WHERE idfsBaseReference = 10080033 AND idfsLanguage = 10049003 -- old value 'Contact - Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - კონტაქტი - სახელი' WHERE idfsBaseReference = 10080033 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Təmasda olan şəxs - Adı' WHERE idfsBaseReference = 10080033 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  التواصل - الاسم' WHERE idfsBaseReference = 10080033 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Contact - Place of Last Contact' WHERE idfsBaseReference = 10080038 AND idfsLanguage = 10049003 -- old value 'Contact - Place of Last Contact'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - კონტაქტი - ბოლო კონტაქტის ადგილი' WHERE idfsBaseReference = 10080038 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Təmasda olan şəxs - Son təmas yeri' WHERE idfsBaseReference = 10080038 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  التواصل - مكان آخر اتصال ' WHERE idfsBaseReference = 10080038 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Contact - Relation' WHERE idfsBaseReference = 10080037 AND idfsLanguage = 10049003 -- old value 'Contact - Relation'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - კონტაქტი - კავშირი' WHERE idfsBaseReference = 10080037 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Təmasda olan şəxs - Əlaqə tipi' WHERE idfsBaseReference = 10080037 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  التواصل - العلاقة' WHERE idfsBaseReference = 10080037 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Age' WHERE idfsBaseReference = 10080024 -- old value 'Human Case - Age'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Age' WHERE idfsBaseReference = 10080024 AND idfsLanguage = 10049003 -- old value 'Human Case - Age'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ასაკი' WHERE idfsBaseReference = 10080024 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Yaşı' WHERE idfsBaseReference = 10080024 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  العمر' WHERE idfsBaseReference = 10080024 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Age Type' WHERE idfsBaseReference = 10080227 -- old value 'Human Case - Age Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Age Type' WHERE idfsBaseReference = 10080227 AND idfsLanguage = 10049003 -- old value 'Human Case - Age Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში -ასაკის ტიპი' WHERE idfsBaseReference = 10080227 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Yaş növü' WHERE idfsBaseReference = 10080227 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -   الفئة العمرية ' WHERE idfsBaseReference = 10080227 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Antibiotics Administrated' WHERE idfsBaseReference = 10080026 -- old value 'Human Case - Antibiotics Administrated'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Antibiotics Administrated' WHERE idfsBaseReference = 10080026 AND idfsLanguage = 10049003 -- old value 'Human Case - Antibiotics Administrated'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დანიშნული ანტიბიოტიკები' WHERE idfsBaseReference = 10080026 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Antibiotik müalicəsi aparılıb' WHERE idfsBaseReference = 10080026 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  المضادات الحيوية  الموصوفة ' WHERE idfsBaseReference = 10080026 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Basis of Diagnosis - Clinical' WHERE idfsBaseReference = 10080428 -- old value 'Human Case - Basis of Diagnosis - Clinical'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Basis of Diagnosis - Clinical' WHERE idfsBaseReference = 10080428 AND idfsLanguage = 10049003 -- old value 'Human Case - Basis of Diagnosis - Clinical'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დიაგნოზის საფუძველი - კლინიკური' WHERE idfsBaseReference = 10080428 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Diaqnozun əsası - Kliniki' WHERE idfsBaseReference = 10080428 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  أساس التشخيص - أكلينيكي' WHERE idfsBaseReference = 10080428 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Basis of Diagnosis - Epidemiological Links' WHERE idfsBaseReference = 10080429 -- old value 'Human Case - Basis of Diagnosis - Epidemiological Links'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Basis of Diagnosis - Epidemiological Links' WHERE idfsBaseReference = 10080429 AND idfsLanguage = 10049003 -- old value 'Human Case - Basis of Diagnosis - Epidemiological Links'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დიაგნოზის საფუძველი - ეპიდემიოლოგიური  კავშირები' WHERE idfsBaseReference = 10080429 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Diaqnozun əsası - Epidemioloji əlaqələr' WHERE idfsBaseReference = 10080429 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  أساس التشخيص - الروابط الوبائية ' WHERE idfsBaseReference = 10080429 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Basis of Diagnosis - Laboratory Test' WHERE idfsBaseReference = 10080430 -- old value 'Human Case - Basis of Diagnosis - Laboratory Test'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Basis of Diagnosis - Laboratory Test' WHERE idfsBaseReference = 10080430 AND idfsLanguage = 10049003 -- old value 'Human Case - Basis of Diagnosis - Laboratory Test'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დიაგნოზის საფუძველი - ლაბორატორიული ტესტი' WHERE idfsBaseReference = 10080430 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Diaqnozun əsası - Laborator test' WHERE idfsBaseReference = 10080430 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  أساس التشخيص -  الاختبار المخبري ' WHERE idfsBaseReference = 10080430 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Disease Report Classification' WHERE idfsBaseReference = 10080029 -- old value 'Human Case - Case Classification'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Disease Report Classification' WHERE idfsBaseReference = 10080029 AND idfsLanguage = 10049003 -- old value 'Human Case - Case Classification'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დაავადების ანგარიშის კლასიფიკაცია' WHERE idfsBaseReference = 10080029 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstəlik hesabatının təsnifatı' WHERE idfsBaseReference = 10080029 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - تصنيف تقرير المرض ' WHERE idfsBaseReference = 10080029 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Disease Report ID' WHERE idfsBaseReference = 10080030 -- old value 'Human Case - Case ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Disease Report ID' WHERE idfsBaseReference = 10080030 AND idfsLanguage = 10049003 -- old value 'Human Case - Case ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დაავადების ანგარიშის ID' WHERE idfsBaseReference = 10080030 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstəlik hesabatının Q/N-si' WHERE idfsBaseReference = 10080030 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - معرّف تقرير المرض ' WHERE idfsBaseReference = 10080030 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Disease Report Status' WHERE idfsBaseReference = 10080223 -- old value 'Human Case - Case Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Disease Report Status' WHERE idfsBaseReference = 10080223 AND idfsLanguage = 10049003 -- old value 'Human Case - Case Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დაავადების ანგარიშის სტატუსი' WHERE idfsBaseReference = 10080223 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstəlik hesabatının statusu' WHERE idfsBaseReference = 10080223 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - حالة  تقرير المرض ' WHERE idfsBaseReference = 10080223 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080035 -- hide 'Human Case - Changed Diagnosis'
UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080561 -- hide 'Human Case - Changed Diagnosis - Is Zoonotic'
UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080036 -- hide 'Human Case - Changed Diagnosis Code'

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Date Entered' WHERE idfsBaseReference = 10080040 -- old value 'Human Case - Date Entered'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Date Entered' WHERE idfsBaseReference = 10080040 AND idfsLanguage = 10049003 -- old value 'Human Case - Date Entered'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - შეყვანის თარიღი' WHERE idfsBaseReference = 10080040 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Daxil etmə tarixi' WHERE idfsBaseReference = 10080040 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - تاريخ الدخول' WHERE idfsBaseReference = 10080040 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Date Last Saved' WHERE idfsBaseReference = 10080041 -- old value 'Human Case - Date Last Saved'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Date Last Saved' WHERE idfsBaseReference = 10080041 AND idfsLanguage = 10049003 -- old value 'Human Case - Date Last Saved'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ბოლოს შენახვის თარიღი' WHERE idfsBaseReference = 10080041 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Son yaddaşa salınma tarixi' WHERE idfsBaseReference = 10080041 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - تاريخ الحفظ الأخير' WHERE idfsBaseReference = 10080041 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Date of Birth' WHERE idfsBaseReference = 10080042 -- old value 'Human Case - Date of Birth'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Date of Birth' WHERE idfsBaseReference = 10080042 AND idfsLanguage = 10049003 -- old value 'Human Case - Date of Birth'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დაბადების თარიღი' WHERE idfsBaseReference = 10080042 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Doğum tarixi' WHERE idfsBaseReference = 10080042 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - تاريخ الولادة' WHERE idfsBaseReference = 10080042 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080043 -- hide 'Human Case - Date Of Changed Diagnosis'

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Date of Completion of Paper form' WHERE idfsBaseReference = 10080044 -- old value 'Human Case - Date of Completion of Paper form' TODO: missing translation
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Date of Completion of Paper form' WHERE idfsBaseReference = 10080044 AND idfsLanguage = 10049003 -- old value 'Human Case - Date of Completion of Paper form'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Date of Completion of Paper form' WHERE idfsBaseReference = 10080044 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Date of Completion of Paper form' WHERE idfsBaseReference = 10080044 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Date of Completion of Paper form' WHERE idfsBaseReference = 10080044 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Date of Death' WHERE idfsBaseReference = 10080045 -- old value 'Human Case - Date of Death'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Date of Death' WHERE idfsBaseReference = 10080045 AND idfsLanguage = 10049003 -- old value 'Human Case - Date of Death'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - გარდაცვალების თარიღი' WHERE idfsBaseReference = 10080045 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Ölüm tarixi' WHERE idfsBaseReference = 10080045 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - تاريخ الوفاة' WHERE idfsBaseReference = 10080045 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Date of Discharge' WHERE idfsBaseReference = 10080046 -- old value 'Human Case - Date of Discharge'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Date of Discharge' WHERE idfsBaseReference = 10080046 AND idfsLanguage = 10049003 -- old value 'Human Case - Date of Discharge'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - გაწერის თარიღი' WHERE idfsBaseReference = 10080046 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstəxanadan çıxma tarixi' WHERE idfsBaseReference = 10080046 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - تاريخ التسريح' WHERE idfsBaseReference = 10080046 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Date of Exposure' WHERE idfsBaseReference = 10080047 -- old value 'Human Case - Date of Exposure'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Date of Exposure' WHERE idfsBaseReference = 10080047 AND idfsLanguage = 10049003 -- old value 'Human Case - Date of Exposure'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ექსპოზიციის თარიღი' WHERE idfsBaseReference = 10080047 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Təxmini yoluxma tarixi' WHERE idfsBaseReference = 10080047 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - تاريخ التعرض للمرض' WHERE idfsBaseReference = 10080047 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Date of Final Disease Report Classification' WHERE idfsBaseReference = 10080553 -- old value 'Human Case - Date of Final Case Classification'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Date of Final Disease Report Classification' WHERE idfsBaseReference = 10080553 AND idfsLanguage = 10049003 -- old value 'Human Case - Date of Final Case Classification'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დაავადების  ანგარიშის საბოლოო კლასიფიკაციის თარიღი' WHERE idfsBaseReference = 10080553 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstəlik hesabatının son təsnifat tarixi' WHERE idfsBaseReference = 10080553 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - تاريخ التصنيف الأخير لتقرير المرض ' WHERE idfsBaseReference = 10080553 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Date of Disease' WHERE idfsBaseReference = 10080226 -- old value 'Human Case - Date of Final Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Date of Disease' WHERE idfsBaseReference = 10080226 AND idfsLanguage = 10049003 -- old value 'Human Case - Date of Final Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დაავადების თარიღი' WHERE idfsBaseReference = 10080226 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstəliyin aşkar olunma tarixi' WHERE idfsBaseReference = 10080226 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - تاريخ المرض' WHERE idfsBaseReference = 10080226 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Date of Hospitalization' WHERE idfsBaseReference = 10080229 -- old value 'Human Case - Date of Hospitalization'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Date of Hospitalization' WHERE idfsBaseReference = 10080229 AND idfsLanguage = 10049003 -- old value 'Human Case - Date of Hospitalization'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ჰოსპიტალიზაციის თარიღი' WHERE idfsBaseReference = 10080229 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Hospitalizasiya tarixi' WHERE idfsBaseReference = 10080229 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - تاريخ دخول المستشفى ' WHERE idfsBaseReference = 10080229 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Date of Last Patient Presence at Work' WHERE idfsBaseReference = 10080048 -- old value 'Human Case - Date of Last Patient Presence at Work'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Date of Last Patient Presence at Work' WHERE idfsBaseReference = 10080048 AND idfsLanguage = 10049003 -- old value 'Human Case - Date of Last Patient Presence at Work'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სამსახურში პაციენტის ბოლოს ყოფნის თარიღი' WHERE idfsBaseReference = 10080048 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin iş yerində olduğu son tarix' WHERE idfsBaseReference = 10080048 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - تاريخ آخر حضور للمريض إلى العمل' WHERE idfsBaseReference = 10080048 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Date of Symptom Onset' WHERE idfsBaseReference = 10080049 -- old value 'Human Case - Date of Symptom Onset'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Date of Symptom Onset' WHERE idfsBaseReference = 10080049 AND idfsLanguage = 10049003 -- old value 'Human Case - Date of Symptom Onset'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სიმპტომების გამოვლენის თარიღი' WHERE idfsBaseReference = 10080049 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Simptomların başlanma tarixi' WHERE idfsBaseReference = 10080049 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - تاريخ ظهور الأعراض ' WHERE idfsBaseReference = 10080049 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Date Patient First Sought Care' WHERE idfsBaseReference = 10080230 -- old value 'Human Case - Date Patient First Sought Care'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Date Patient First Sought Care' WHERE idfsBaseReference = 10080230 AND idfsLanguage = 10049003 -- old value 'Human Case - Date Patient First Sought Care'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში -პაციენტის პირველადი მიმართვის თარიღი' WHERE idfsBaseReference = 10080230 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin ilk yardım üçün müraciət tarixi' WHERE idfsBaseReference = 10080230 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - تاريخ الاسعافات الاولية للمريض' WHERE idfsBaseReference = 10080230 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Days after First Sought Care until Notification' WHERE idfsBaseReference = 10080446 -- old value 'Human Case - Days after First Sought Care until Notification'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Days after First Sought Care until Notification' WHERE idfsBaseReference = 10080446 AND idfsLanguage = 10049003 -- old value 'Human Case - Days after First Sought Care until Notification'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დღეების რაოდენობა მიმართვიდან შეტყობინებამდე' WHERE idfsBaseReference = 10080446 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin ilk yardım üçün müraciət etdiyi tarixdən Bildiriş tarixinədək keçən günlərin sayı' WHERE idfsBaseReference = 10080446 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  الأيام التي انقضت من  تاريخ الاسعافات الأولية للمريض  إلى تاريخ الإخطار' WHERE idfsBaseReference = 10080446 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080449 -- hide 'Human Case - Days after Initial Diagnosis until Final Diagnosis'

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Days after Diagnosis until Notification' WHERE idfsBaseReference = 10080443 -- old value 'Human Case - Days after Initial Diagnosis until Notification'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Days after Diagnosis until Notification' WHERE idfsBaseReference = 10080443 AND idfsLanguage = 10049003 -- old value 'Human Case - Days after Initial Diagnosis until Notification'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დღეების რაოდენობა დიაგნოზის დასმიდან შეტყობინებამდე' WHERE idfsBaseReference = 10080443 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Diaqnoz qoyulduğu tarixdən Bildiriş tarixinədək keçən günlərin sayı' WHERE idfsBaseReference = 10080443 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  الأيام التي انقضت من  تاريخ التشخيص   إلى تاريخ الإخطار' WHERE idfsBaseReference = 10080443 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Days after Notification until Entered in the system' WHERE idfsBaseReference = 10080050 AND idfsLanguage = 10049003 -- old value 'Human Case - Days after Notification until Entered in the system'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დღეების რაოდეობა შეტყობინებიდან სისტემაში შეყვანამდე' WHERE idfsBaseReference = 10080050 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Bildiriş tarixindən Sistemə daxil etmə tarixinədək keçən günlərin sayı' WHERE idfsBaseReference = 10080050 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  الأيام التي انقضت من   تاريخ الإخطار  إلى تاريخ الدخول في النظام' WHERE idfsBaseReference = 10080050 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Days after Notification until Disease Report Investigation' WHERE idfsBaseReference = 10080448 -- old value 'Human Case - Days after Notification until Case Investigation'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Days after Notification until Disease Report Investigation' WHERE idfsBaseReference = 10080448 AND idfsLanguage = 10049003 -- old value 'Human Case - Days after Notification until Case Investigation'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დღეების რაოდენობა შეტყობინებიდან  დაავადების ანგარიშის გამოკვლევამდე' WHERE idfsBaseReference = 10080448 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Bildiriş tarixindən Xəstəlik hesabatının tədqiqatı tarixinədək keçən günlərin sayı' WHERE idfsBaseReference = 10080448 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  الأيام التي انقضت من  تاريخ الإخطار  إلى تاريخ البحث في تقرير المريض' WHERE idfsBaseReference = 10080448 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Days after Onset of Patient Symptoms until Notification' WHERE idfsBaseReference = 10080444 -- old value 'Human Case - Days after Onset of Patient Symptoms until Notification'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Days after Onset of Patient Symptoms until Notification' WHERE idfsBaseReference = 10080444 AND idfsLanguage = 10049003 -- old value 'Human Case - Days after Onset of Patient Symptoms until Notification'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დღეების რაოდენობა პაციენტის სიმპტომების გამოვლენიდან შეტყობინებამდე' WHERE idfsBaseReference = 10080444 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin simptomlarının başlanma tarixindən Bildiriş tarixinədək keçən günlərin sayı' WHERE idfsBaseReference = 10080444 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  الأيام التي انقضت من  تاريخ ظهور الأعراض للمريض  إلى تاريخ الإخطار' WHERE idfsBaseReference = 10080444 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Days after Patient First Sought Care until Entered' WHERE idfsBaseReference = 10080447 -- old value 'Human Case - Days after Patient First Sought Care until Entered'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Days after Patient First Sought Care until Entered' WHERE idfsBaseReference = 10080447 AND idfsLanguage = 10049003 -- old value 'Human Case - Days after Patient First Sought Care until Entered'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დღეების რაოდენობა პაციენტის პირველადი მიმართვიდან ინფორმაციის შეყვანამდე' WHERE idfsBaseReference = 10080447 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin ilk yardım üçün müraciət tarixindən Daxil etmə tarixinədək keçən günlərin sayı' WHERE idfsBaseReference = 10080447 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  الأيام التي انقضت من  تاريخ الاسعافات الاولية للمريض  إلى تاريخ دخوله' WHERE idfsBaseReference = 10080447 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Days after Patient First Sought Care until Diagnosis' WHERE idfsBaseReference = 10080450 -- old value 'Human Case - Days after Patient First Sought Care until Final Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Days after Patient First Sought Care until Diagnosis' WHERE idfsBaseReference = 10080450 AND idfsLanguage = 10049003 -- old value 'Human Case - Days after Patient First Sought Care until Final Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დღეების რაოდენობა პაციენტის პირველადი მიმართვიდან დიაგნოზის დასმამდე' WHERE idfsBaseReference = 10080450 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin ilk yardım üçün müraciət etdiyi tarixdən Diaqnozun qoyulma tarixinədək keçən günlərin sayı' WHERE idfsBaseReference = 10080450 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  الأيام التي انقضت من  تاريخ الاسعافات الاولية للمريض  إلى تاريخ التشخيص' WHERE idfsBaseReference = 10080450 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Days after Symptom Onset until First Sought Care' WHERE idfsBaseReference = 10080445 -- old value 'Human Case - Days after Symptom Onset until First Sought Care'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Days after Symptom Onset until First Sought Care' WHERE idfsBaseReference = 10080445 AND idfsLanguage = 10049003 -- old value 'Human Case - Days after Symptom Onset until First Sought Care'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დღეების რაოდენობა სიმპტომების გამოვლენიდან პიველად  მიმართვამდე' WHERE idfsBaseReference = 10080445 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Simptomların başlanma tarixindən Xəstənin ilk yardım üçün müraciət etdiyi tarixədək keçən günlərin sayı' WHERE idfsBaseReference = 10080445 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  الأيام التي انقضت من تاريخ ظهور الأعراض للمريض  إلى تاريخ الاسعافات الأولية' WHERE idfsBaseReference = 10080445 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Disease Group' WHERE idfsBaseReference = 10080577 -- old value 'Human Case - Diagnoses Group'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Disease Group' WHERE idfsBaseReference = 10080577 AND idfsLanguage = 10049003 -- old value 'Human Case - Diagnoses Group'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დაავადების ჯგუფი' WHERE idfsBaseReference = 10080577 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstəlik qrupu' WHERE idfsBaseReference = 10080577 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  مجموعة الأمراض ' WHERE idfsBaseReference = 10080577 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Disease' WHERE idfsBaseReference = 10080051 -- old value 'Human Case - Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Disease' WHERE idfsBaseReference = 10080051 AND idfsLanguage = 10049003 -- old value 'Human Case - Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დაავადება' WHERE idfsBaseReference = 10080051 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstəlik' WHERE idfsBaseReference = 10080051 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  المرض ' WHERE idfsBaseReference = 10080051 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Disease - Is Zoonotic' WHERE idfsBaseReference = 10080562 -- old value 'Human Case - Diagnosis - Is Zoonotic'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Disease - Is Zoonotic' WHERE idfsBaseReference = 10080562 AND idfsLanguage = 10049003 -- old value 'Human Case - Diagnosis - Is Zoonotic'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დაავადება - არის ზოონოზური' WHERE idfsBaseReference = 10080562 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstəlik - Zoonozdur' WHERE idfsBaseReference = 10080562 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  المرض - حيوانيّ المصدر' WHERE idfsBaseReference = 10080562 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Disease Code' WHERE idfsBaseReference = 10080053 -- old value 'Human Case - Diagnosis Code'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Disease Code' WHERE idfsBaseReference = 10080053 AND idfsLanguage = 10049003 -- old value 'Human Case - Diagnosis Code'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დაავადების კოდი' WHERE idfsBaseReference = 10080053 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstəliyin kodu' WHERE idfsBaseReference = 10080053 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - رمز المرض ' WHERE idfsBaseReference = 10080053 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Disease Date' WHERE idfsBaseReference = 10080052 -- old value 'Human Case - Diagnosis Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Disease Date' WHERE idfsBaseReference = 10080052 AND idfsLanguage = 10049003 -- old value 'Human Case - Diagnosis Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დაავადების თარიღი' WHERE idfsBaseReference = 10080052 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstəliyin aşkar olunma tarixi' WHERE idfsBaseReference = 10080052 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - تاريخ المرض ' WHERE idfsBaseReference = 10080052 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Employer Name' WHERE idfsBaseReference = 10080073 -- old value 'Human Case - Employer Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Employer Name' WHERE idfsBaseReference = 10080073 AND idfsLanguage = 10049003 -- old value 'Human Case - Employer Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დამსაქმებლის სახელი' WHERE idfsBaseReference = 10080073 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - İş yerinin adı' WHERE idfsBaseReference = 10080073 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - اسم صاحب العمل' WHERE idfsBaseReference = 10080073 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Employer Phone Number' WHERE idfsBaseReference = 10080055 -- old value 'Human Case - Employer Phone Number'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Employer Phone Number' WHERE idfsBaseReference = 10080055 AND idfsLanguage = 10049003 -- old value 'Human Case - Employer Phone Number'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დამსაქმებლის ტელეფონის ნომერი' WHERE idfsBaseReference = 10080055 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - İş yerinin telefon nömrəsi' WHERE idfsBaseReference = 10080055 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - هاتف صاحب العمل' WHERE idfsBaseReference = 10080055 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Entered by Officer' WHERE idfsBaseReference = 10080554 -- old value 'Human Case - Entered by Officer'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Entered by Officer' WHERE idfsBaseReference = 10080554 AND idfsLanguage = 10049003 -- old value 'Human Case - Entered by Officer'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - შეყვანილია თანამშრომლის მიერ' WHERE idfsBaseReference = 10080554 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Daxil edən işçi' WHERE idfsBaseReference = 10080554 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - يُدخله الموظف' WHERE idfsBaseReference = 10080554 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Entered by Organization - ID' WHERE idfsBaseReference = 10080583 -- old value 'Human Case - Entered by Organization - ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Entered by Organization - ID' WHERE idfsBaseReference = 10080583 AND idfsLanguage = 10049003 -- old value 'Human Case - Entered by Organization - ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - შეყვანილია ორგანიზაციის მიერ - ID' WHERE idfsBaseReference = 10080583 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Daxil edən təşkilat - Q/N-si' WHERE idfsBaseReference = 10080583 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - تُدخله المؤسسة - المعرّف' WHERE idfsBaseReference = 10080583 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Entered by Organization - Name' WHERE idfsBaseReference = 10080511 -- old value 'Human Case - Entered by Organization - Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Entered by Organization - Name' WHERE idfsBaseReference = 10080511 AND idfsLanguage = 10049003 -- old value 'Human Case - Entered by Organization - Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - შეყვანილია ორგანიზაციის მიერ - დასახელება' WHERE idfsBaseReference = 10080511 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Daxil edən təşkilat - Adı' WHERE idfsBaseReference = 10080511 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - تُدخله المؤسسة - الاسم' WHERE idfsBaseReference = 10080511 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Epidemiologist Name' WHERE idfsBaseReference = 10080499 -- old value 'Human Case - Epidemiologist Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Epidemiologist Name' WHERE idfsBaseReference = 10080499 AND idfsLanguage = 10049003 -- old value 'Human Case - Epidemiologist Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ეპიდემიოლოგის სახელი' WHERE idfsBaseReference = 10080499 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Epidemioloqun adı' WHERE idfsBaseReference = 10080499 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - اسم اختصاصيّ الوبائيات' WHERE idfsBaseReference = 10080499 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Facility Where Patient First Sought Care - ID' WHERE idfsBaseReference = 10080584 -- old value 'Human Case - Facility Where Patient First Sought Care - ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Facility Where Patient First Sought Care - ID' WHERE idfsBaseReference = 10080584 AND idfsLanguage = 10049003 -- old value 'Human Case - Facility Where Patient First Sought Care - ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - პაციენტის პირველადი  მიმართვის დაწესებულება - ID' WHERE idfsBaseReference = 10080584 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin ilk yardım üçün müraciət etdiyi müəssisə - Q/N-si' WHERE idfsBaseReference = 10080584 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - المنشأة التي طلب فيها المريض الاسعافات الأولية - المعرّف' WHERE idfsBaseReference = 10080584 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Facility Where Patient First Sought Care - Name' WHERE idfsBaseReference = 10080439 -- old value 'Human Case - Facility Where Patient First Sought Care - Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Facility Where Patient First Sought Care - Name' WHERE idfsBaseReference = 10080439 AND idfsLanguage = 10049003 -- old value 'Human Case - Facility Where Patient First Sought Care - Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - პაციენტის პირველადი  მიმართვის დაწესებულება - სახელი ' WHERE idfsBaseReference = 10080439 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin ilk yardım üçün müraciət etdiyi müəssisə - Adı' WHERE idfsBaseReference = 10080439 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - المنشأة التي طلب فيها المريض الاسعافات الأولية - الاسم' WHERE idfsBaseReference = 10080439 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Final Disease Report Classification' WHERE idfsBaseReference = 10080225 -- old value 'Human Case - Final Case Classification'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Final Disease Report Classification' WHERE idfsBaseReference = 10080225 AND idfsLanguage = 10049003 -- old value 'Human Case - Final Case Classification'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დაავადების ანგარიშის საბოლოო კლასიფიკაცია' WHERE idfsBaseReference = 10080225 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstəlik hesabatının son təsnifatı' WHERE idfsBaseReference = 10080225 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - التصنيف الأخير لتقرير المرض' WHERE idfsBaseReference = 10080225 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080098 -- hide 'Human Case - Final Diagnosis'
UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080563 -- hide 'Human Case - Final Diagnosis - Is Zoonotic'
UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080099 -- hide 'Human Case - Final Diagnosis Code'

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Hospital at the time of notification - Abbreviation' WHERE idfsBaseReference = 10080064 -- old value 'Human Case - Hospital at the time of notification - Abbreviation'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Hospital at the time of notification - Abbreviation' WHERE idfsBaseReference = 10080064 AND idfsLanguage = 10049003 -- old value 'Human Case - Hospital at the time of notification - Abbreviation'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - საავადმყოფო შეტყობინების დროს  - აბრევიაცია' WHERE idfsBaseReference = 10080064 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Bildiriş zamanı xəstəxana - Qısa adı' WHERE idfsBaseReference = 10080064 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - المستشفى في وقت الإخطار - الاختصار' WHERE idfsBaseReference = 10080064 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Hospital at the time of notification - ID' WHERE idfsBaseReference = 10080555 -- old value 'Human Case - Hospital at the time of notification - ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Hospital at the time of notification - ID' WHERE idfsBaseReference = 10080555 AND idfsLanguage = 10049003 -- old value 'Human Case - Hospital at the time of notification - ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - საავადმყოფო შეტყობინების დროს -  ID' WHERE idfsBaseReference = 10080555 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Bildiriş zamanı xəstəxana - Q/N-si' WHERE idfsBaseReference = 10080555 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - المستشفى في وقت الإخطار - المعرّف' WHERE idfsBaseReference = 10080555 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Hospitalization' WHERE idfsBaseReference = 10080063 -- old value 'Human Case - Hospitalization'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Hospitalization' WHERE idfsBaseReference = 10080063 AND idfsLanguage = 10049003 -- old value 'Human Case - Hospitalization'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ჰოსპიტალიზაცია' WHERE idfsBaseReference = 10080063 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Hospitalizasiya' WHERE idfsBaseReference = 10080063 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - المستشفى في وقت الإخطار - استشفاء' WHERE idfsBaseReference = 10080063 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Initial Disease Report Classification' WHERE idfsBaseReference = 10080224 -- old value 'Human Case - Initial Case Classification'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Initial Disease Report Classification' WHERE idfsBaseReference = 10080224 AND idfsLanguage = 10049003 -- old value 'Human Case - Initial Case Classification'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დაავადების  ანგარიშის საწყისი კლასიფიკაცია' WHERE idfsBaseReference = 10080224 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstəlik hesabatının ilkin təsnifatı' WHERE idfsBaseReference = 10080224 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - التصنيف الأولي  لتقارير المرض ' WHERE idfsBaseReference = 10080224 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Local Identifier' WHERE idfsBaseReference = 10080066 -- old value 'Human Case - Local Identifier'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Local Identifier' WHERE idfsBaseReference = 10080066 AND idfsLanguage = 10049003 -- old value 'Human Case - Local Identifier'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ადგილობრივი იდენტიფიკატორი' WHERE idfsBaseReference = 10080066 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Təcili bildirişin Q/N-si' WHERE idfsBaseReference = 10080066 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - المعرّف المحلي' WHERE idfsBaseReference = 10080066 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Location at Time of Notification' WHERE idfsBaseReference = 10080039 -- old value 'Human Case - Location at Time of Notification'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Location at Time of Notification' WHERE idfsBaseReference = 10080039 AND idfsLanguage = 10049003 -- old value 'Human Case - Location at Time of Notification'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ადგილმდებარეობა შეტყობინების დროს' WHERE idfsBaseReference = 10080039 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Bildiriş zamanı yerləşmə yeri' WHERE idfsBaseReference = 10080039 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - الموقع في وقت الإخطار' WHERE idfsBaseReference = 10080039 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Location of Exposure - Coordinates' WHERE idfsBaseReference = 10080232 -- old value 'Human Case - Location of Exposure - Coordinates'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Location of Exposure - Coordinates' WHERE idfsBaseReference = 10080232 AND idfsLanguage = 10049003 -- old value 'Human Case - Location of Exposure - Coordinates'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ექსპოზიციის ადგილი - კოორდინატები' WHERE idfsBaseReference = 10080232 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Yoluxma yeri - Koordinatlar' WHERE idfsBaseReference = 10080232 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - موقع التعرض للمرض - الاحداثيات' WHERE idfsBaseReference = 10080232 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Location of Exposure - Country' WHERE idfsBaseReference = 10080601 -- old value 'Human Case - Location of Exposure - Country'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Location of Exposure - Country' WHERE idfsBaseReference = 10080601 AND idfsLanguage = 10049003 -- old value 'Human Case - Location of Exposure - Country'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ექსპოზიციის ადგილი - ქვეყანა' WHERE idfsBaseReference = 10080601 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Yoluxma yeri - Ölkə' WHERE idfsBaseReference = 10080601 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - موقع التعرض للمرض - البلد' WHERE idfsBaseReference = 10080601 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080590 -- hide 'Human Case - Location of Exposure - Elevation (m)'

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Location of Exposure - Foreign Address' WHERE idfsBaseReference = 10080603 -- old value 'Human Case - Location of Exposure - Foreign Address'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Location of Exposure - Foreign Address' WHERE idfsBaseReference = 10080603 AND idfsLanguage = 10049003 -- old value 'Human Case - Location of Exposure - Foreign Address'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ექსპოზიციის ადგილი - უცხოური მისამართი' WHERE idfsBaseReference = 10080603 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Yoluxma yeri - Xarici ünvan' WHERE idfsBaseReference = 10080603 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - موقع التعرض للمرض - العنوان الأجنبي' WHERE idfsBaseReference = 10080603 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Location of Exposure - Is Foreign Address' WHERE idfsBaseReference = 10080602 -- old value 'Human Case - Location of Exposure - Is Foreign Address'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Location of Exposure - Is Foreign Address' WHERE idfsBaseReference = 10080602 AND idfsLanguage = 10049003 -- old value 'Human Case - Location of Exposure - Is Foreign Address'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ექსპოზიციის ადგილი - არის უხოური მისამართი' WHERE idfsBaseReference = 10080602 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Yoluxma yeri - Xarici ünvandır' WHERE idfsBaseReference = 10080602 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - موقع التعرض للمرض - عنوان أجنبي' WHERE idfsBaseReference = 10080602 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Location of Exposure - Latitude' WHERE idfsBaseReference = 10080515 -- old value 'Human Case - Location of Exposure - Latitude'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Location of Exposure - Latitude' WHERE idfsBaseReference = 10080515 AND idfsLanguage = 10049003 -- old value 'Human Case - Location of Exposure - Latitude'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ექსპოზიციის ადგილი - განედი' WHERE idfsBaseReference = 10080515 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Yoluxma yeri - En dairəsi' WHERE idfsBaseReference = 10080515 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - موقع التعرض للمرض - خط العرض' WHERE idfsBaseReference = 10080515 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Location of Exposure - Longitude' WHERE idfsBaseReference = 10080514 -- old value 'Human Case - Location of Exposure - Longitude'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Location of Exposure - Longitude' WHERE idfsBaseReference = 10080514 AND idfsLanguage = 10049003 -- old value 'Human Case - Location of Exposure - Longitude'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ექსპოზიციის ადგილი - გრძედი' WHERE idfsBaseReference = 10080514 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Yoluxma yeri - Uzunluq dairəsi' WHERE idfsBaseReference = 10080514 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - موقع التعرض للمرض - خط الطول' WHERE idfsBaseReference = 10080514 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Location of Exposure - Rayon' WHERE idfsBaseReference = 10080068 -- old value 'Human Case - Location of Exposure - Rayon'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Location of Exposure - Rayon' WHERE idfsBaseReference = 10080068 AND idfsLanguage = 10049003 -- old value 'Human Case - Location of Exposure - Rayon'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ექსპოზიციის ადგილი - რაიონი' WHERE idfsBaseReference = 10080068 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Yoluxma yeri - Rayon' WHERE idfsBaseReference = 10080068 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - موقع التعرض للمرض - رايون' WHERE idfsBaseReference = 10080068 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Location of Exposure - Region' WHERE idfsBaseReference = 10080070 -- old value 'Human Case - Location of Exposure - Region'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Location of Exposure - Region' WHERE idfsBaseReference = 10080070 AND idfsLanguage = 10049003 -- old value 'Human Case - Location of Exposure - Region'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ექსპოზიციის ადგილი - რეგიონი' WHERE idfsBaseReference = 10080070 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Yoluxma yeri - Region' WHERE idfsBaseReference = 10080070 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - موقع التعرض للمرض - المنطقة' WHERE idfsBaseReference = 10080070 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Location of Exposure - Settlement' WHERE idfsBaseReference = 10080231 -- old value 'Human Case - Location of Exposure - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Location of Exposure - Settlement' WHERE idfsBaseReference = 10080231 AND idfsLanguage = 10049003 -- old value 'Human Case - Location of Exposure - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ექსპოზიციის ადგილი - დასახლება' WHERE idfsBaseReference = 10080231 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Yoluxma yeri - Yaşayış məntəqəsi' WHERE idfsBaseReference = 10080231 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - موقع التعرض للمرض - الاقامة' WHERE idfsBaseReference = 10080231 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Citizenship' WHERE idfsBaseReference = 10080074 AND idfsLanguage = 10049003 -- old value 'Human Case - Citizenship'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - მოქალაქეობა' WHERE idfsBaseReference = 10080074 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Vətəndaşlıq' WHERE idfsBaseReference = 10080074 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - موقع التعرض للمرض - المواطنة' WHERE idfsBaseReference = 10080074 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Non-Notifiable Diagnosis from facility where patient first sought care' WHERE idfsBaseReference = 10080440 -- old value 'Human Case - Non-Notifiable Diagnosis from facility where patient first sought care'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Non-Notifiable Diagnosis from facility where patient first sought care' WHERE idfsBaseReference = 10080440 AND idfsLanguage = 10049003 -- old value 'Human Case - Non-Notifiable Diagnosis from facility where patient first sought care'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - დიაგნოზი,  პირველადი მიმართვის დაწესებულებიდან, რომელიც შეტყობინებას არ ექვემდებარება' WHERE idfsBaseReference = 10080440 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin ilk yardım üçün müraciət etdiyi müəssisədə qoyulmuş qeyri-yoluxucu diaqnoz' WHERE idfsBaseReference = 10080440 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - تشخيص غير قابل للإخطار من المنشأة التي طلب منها المريض الاسعافات الأولية ' WHERE idfsBaseReference = 10080440 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Notification Date' WHERE idfsBaseReference = 10080075 -- old value 'Human Case - Notification Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Notification Date' WHERE idfsBaseReference = 10080075 AND idfsLanguage = 10049003 -- old value 'Human Case - Notification Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - შეტყობინების თარიღი' WHERE idfsBaseReference = 10080075 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Bildiriş tarixi' WHERE idfsBaseReference = 10080075 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - تاريخ الإخطار' WHERE idfsBaseReference = 10080075 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Notification Received By Facility - ID' WHERE idfsBaseReference = 10080585 -- old value 'Human Case - Notification Received By Facility - ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Notification Received By Facility - ID' WHERE idfsBaseReference = 10080585 AND idfsLanguage = 10049003 -- old value 'Human Case - Notification Received By Facility - ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - შეტყობინება მიღებულია დაწესებულების მიერ - ID' WHERE idfsBaseReference = 10080585 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Bildirişi qəbul edən müəssisə - Q/N-si ' WHERE idfsBaseReference = 10080585 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - الإخطار الذي تلقته المنشأة - المعرّف' WHERE idfsBaseReference = 10080585 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Notification Received By Facility - Name' WHERE idfsBaseReference = 10080061 -- old value 'Human Case - Notification Received By Facility - Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Notification Received By Facility - Name' WHERE idfsBaseReference = 10080061 AND idfsLanguage = 10049003 -- old value 'Human Case - Notification Received By Facility - Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - შეტყობინება მიღებულია დაწესებულების მიერ - დასახელება' WHERE idfsBaseReference = 10080061 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Bildirişi qəbul edən müəssisə - Adı' WHERE idfsBaseReference = 10080061 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - الإخطار الذي تلقته المنشأة - الاسم' WHERE idfsBaseReference = 10080061 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Notification Received By Officer' WHERE idfsBaseReference = 10080076 -- old value 'Human Case - Notification Received By Officer'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Notification Received By Officer' WHERE idfsBaseReference = 10080076 AND idfsLanguage = 10049003 -- old value 'Human Case - Notification Received By Officer'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - შეტყობინება მიღებულია თანამშრომლის მიერ' WHERE idfsBaseReference = 10080076 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Bildirişi qəbul edən işçi' WHERE idfsBaseReference = 10080076 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - الإخطار الذي تلقاه الموظف' WHERE idfsBaseReference = 10080076 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Notification Sent By Facility - ID' WHERE idfsBaseReference = 10080586 -- old value 'Human Case - Notification Sent By Facility - ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Notification Sent By Facility - ID' WHERE idfsBaseReference = 10080586 AND idfsLanguage = 10049003 -- old value 'Human Case - Notification Sent By Facility - ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - შეტყობინება გაგზავნილია დაწესებულების მიერ - ID' WHERE idfsBaseReference = 10080586 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Bildirişi qəbul edən işçi - Q/N-si' WHERE idfsBaseReference = 10080586 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - الإخطار الذي أرسلته المنشأة - المعرّف' WHERE idfsBaseReference = 10080586 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Notification Sent By Facility - Name' WHERE idfsBaseReference = 10080062 -- old value 'Human Case - Notification Sent By Facility - Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Notification Sent By Facility - Name' WHERE idfsBaseReference = 10080062 AND idfsLanguage = 10049003 -- old value 'Human Case - Notification Sent By Facility - Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - შეტყობინება გაგზავნილია დაწესებულების მიერ - დასახელება' WHERE idfsBaseReference = 10080062 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Bildirişi qəbul edən işçi - Adı' WHERE idfsBaseReference = 10080062 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - الإخطار الذي أرسلته المنشأة - الاسم ' WHERE idfsBaseReference = 10080062 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Notification Sent by Officer' WHERE idfsBaseReference = 10080077 -- old value 'Human Case - Notification Sent by Officer'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Notification Sent by Officer' WHERE idfsBaseReference = 10080077 AND idfsLanguage = 10049003 -- old value 'Human Case - Notification Sent by Officer'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - შეტყობინება გაგზავნილია თანამშრომლის მიერ' WHERE idfsBaseReference = 10080077 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Bildirişi göndərən işçi' WHERE idfsBaseReference = 10080077 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - الإخطار الذي أرسله الموظف' WHERE idfsBaseReference = 10080077 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Occupation' WHERE idfsBaseReference = 10080228 -- old value 'Human Case - Occupation'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Occupation' WHERE idfsBaseReference = 10080228 AND idfsLanguage = 10049003 -- old value 'Human Case - Occupation'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - პროფესია' WHERE idfsBaseReference = 10080228 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Vəzifəsi' WHERE idfsBaseReference = 10080228 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - المهنة' WHERE idfsBaseReference = 10080228 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Organization Conducting Investigation - ID' WHERE idfsBaseReference = 10080587 -- old value 'Human Case - Organization Conducting Investigation - ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Organization Conducting Investigation - ID' WHERE idfsBaseReference = 10080587 AND idfsLanguage = 10049003 -- old value 'Human Case - Organization Conducting Investigation - ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ორგანიზაცია, რომელიც ატარებს გამოკვლევას - ID' WHERE idfsBaseReference = 10080587 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Tədqiqatı aparan təşkilat - Q/N-si' WHERE idfsBaseReference = 10080587 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - المنظمة التي تجري البحث - المعرّف' WHERE idfsBaseReference = 10080587 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Organization Conducting Investigation - Name' WHERE idfsBaseReference = 10080078 -- old value 'Human Case - Organization Conducting Investigation - Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Organization Conducting Investigation - Name' WHERE idfsBaseReference = 10080078 AND idfsLanguage = 10049003 -- old value 'Human Case - Organization Conducting Investigation - Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ორგანიზაცია, რომელიც ატარებს გამოკვლევას - დასახელება' WHERE idfsBaseReference = 10080078 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Tədqiqatı aparan təşkilat - Adı' WHERE idfsBaseReference = 10080078 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - المنظمة التي تجري البحث - الاسم' WHERE idfsBaseReference = 10080078 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Other location name at the time of notification' WHERE idfsBaseReference = 10080441 -- old value 'Human Case - Other location name at the time of notification'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Other location name at the time of notification' WHERE idfsBaseReference = 10080441 AND idfsLanguage = 10049003 -- old value 'Human Case - Other location name at the time of notification'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - შეტყობინების დროს სხვა ადგილმდებარეობის  დასახელება' WHERE idfsBaseReference = 10080441 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Bildiriş zamanı digər yerin adı' WHERE idfsBaseReference = 10080441 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - اسم موقع آخر في وقت الإخطار' WHERE idfsBaseReference = 10080441 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080080 -- hide 'Human Case - Outbreak ID'

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Outcome' WHERE idfsBaseReference = 10080081 -- old value 'Human Case - Outcome' TODO: missing translation
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Outcome' WHERE idfsBaseReference = 10080081 AND idfsLanguage = 10049003 -- old value 'Human Case - Outcome'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Outcome' WHERE idfsBaseReference = 10080081 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Outcome' WHERE idfsBaseReference = 10080081 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Outcome' WHERE idfsBaseReference = 10080081 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Patient Age Group' WHERE idfsBaseReference = 10080025 -- old value 'Human Case - Patient Age Group'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Patient Age Group' WHERE idfsBaseReference = 10080025 AND idfsLanguage = 10049003 -- old value 'Human Case - Patient Age Group'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - პაციენტის ასაკობრივი ჯგუფი' WHERE idfsBaseReference = 10080025 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin yaş qrupu' WHERE idfsBaseReference = 10080025 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - الفئة العمرية للمريض' WHERE idfsBaseReference = 10080025 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Patient Current Address - Address' WHERE idfsBaseReference = 10080023 -- old value 'Human Case - Patient Current Residence - Address'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Patient Current Address - Address' WHERE idfsBaseReference = 10080023 AND idfsLanguage = 10049003 -- old value 'Human Case - Patient Current Residence - Address'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - პაციენტის ამჟამინდელი მისამართი - მისამართი' WHERE idfsBaseReference = 10080023 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin cari ünvanı - Ünvan' WHERE idfsBaseReference = 10080023 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - عنوان المريض - العنوان' WHERE idfsBaseReference = 10080023 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Patient Current Address - Coordinates' WHERE idfsBaseReference = 10080495 -- old value 'Human Case - Patient Current Residence - Coordinates'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Patient Current Address - Coordinates' WHERE idfsBaseReference = 10080495 AND idfsLanguage = 10049003 -- old value 'Human Case - Patient Current Residence - Coordinates'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - პაციენტის ამჟამინდელი მისამართი - კოორდინატები' WHERE idfsBaseReference = 10080495 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin cari ünvanı - Koordinatlar' WHERE idfsBaseReference = 10080495 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - عنوان المريض - الاحداثيات' WHERE idfsBaseReference = 10080495 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Patient Current Address - Elevation (m)' WHERE idfsBaseReference = 10080591 -- old value 'Human Case - Patient Current Residence - Elevation (m)'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Patient Current Address - Elevation (m)' WHERE idfsBaseReference = 10080591 AND idfsLanguage = 10049003 -- old value 'Human Case - Patient Current Residence - Elevation (m)'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - პაციენტის ამჟამინდელი მისამართი - ელევაცია (მ)' WHERE idfsBaseReference = 10080591 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin cari ünvanı - Hündürlük (m)' WHERE idfsBaseReference = 10080591 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - عنوان المريض - الارتفاع (م) ' WHERE idfsBaseReference = 10080591 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Patient Current Address - Latitude' WHERE idfsBaseReference = 10080513 -- old value 'Human Case - Patient Current Residence - Latitude'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Patient Current Address - Latitude' WHERE idfsBaseReference = 10080513 AND idfsLanguage = 10049003 -- old value 'Human Case - Patient Current Residence - Latitude'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - პაციენტის ამჟამინდელი მისამართი - განედი' WHERE idfsBaseReference = 10080513 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin cari ünvanı - En dairəsi' WHERE idfsBaseReference = 10080513 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - عنوان المريض - خط العرض' WHERE idfsBaseReference = 10080513 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Patient Current Address - Longitude' WHERE idfsBaseReference = 10080512 -- old value 'Human Case - Patient Current Residence - Longitude'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Patient Current Address - Longitude' WHERE idfsBaseReference = 10080512 AND idfsLanguage = 10049003 -- old value 'Human Case - Patient Current Residence - Longitude'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - პაციენტის ამჟამინდელი მისამართი - გრძედი' WHERE idfsBaseReference = 10080512 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin cari ünvanı - Uzunluq dairəsi' WHERE idfsBaseReference = 10080512 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - عنوان المريض - خط الطول ' WHERE idfsBaseReference = 10080512 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Patient Current Address - Rayon' WHERE idfsBaseReference = 10080083 -- old value 'Human Case - Patient Current Residence - Rayon'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Patient Current Address - Rayon' WHERE idfsBaseReference = 10080083 AND idfsLanguage = 10049003 -- old value 'Human Case - Patient Current Residence - Rayon'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - პაციენტის ამჟამინდელი მისამართი - რაიონი' WHERE idfsBaseReference = 10080083 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin cari ünvanı - Rayon' WHERE idfsBaseReference = 10080083 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - عنوان المريض - رايون ' WHERE idfsBaseReference = 10080083 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Patient Current Address - Region' WHERE idfsBaseReference = 10080085 -- old value 'Human Case - Patient Current Residence - Region'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Patient Current Address - Region' WHERE idfsBaseReference = 10080085 AND idfsLanguage = 10049003 -- old value 'Human Case - Patient Current Residence - Region'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - პაციენტის ამჟამინდელი მისამართი - რეგიონი' WHERE idfsBaseReference = 10080085 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin cari ünvanı - Region' WHERE idfsBaseReference = 10080085 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - عنوان المريض - المنطقة' WHERE idfsBaseReference = 10080085 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Patient Current Address - Settlement' WHERE idfsBaseReference = 10080087 -- old value 'Human Case - Patient Current Residence - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Patient Current Address - Settlement' WHERE idfsBaseReference = 10080087 AND idfsLanguage = 10049003 -- old value 'Human Case - Patient Current Residence - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - პაციენტის ამჟამინდელი მისამართი - დასახლება' WHERE idfsBaseReference = 10080087 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin cari ünvanı - Yaşayış məntəqəsi' WHERE idfsBaseReference = 10080087 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - عنوان المريض - الاقامة' WHERE idfsBaseReference = 10080087 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Patient Employer - Address' WHERE idfsBaseReference = 10080054 -- old value 'Human Case - Patient Employer - Address'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Patient Employer - Address' WHERE idfsBaseReference = 10080054 AND idfsLanguage = 10049003 -- old value 'Human Case - Patient Employer - Address'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - პაციენტის დამსაქმებელი  - მისამართი' WHERE idfsBaseReference = 10080054 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin iş yeri - Ünvan' WHERE idfsBaseReference = 10080054 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - المريض وهو صاحب العمل - العنوان ' WHERE idfsBaseReference = 10080054 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Patient Employer - Elevation (m)' WHERE idfsBaseReference = 10080592 -- old value 'Human Case - Patient Employer - Elevation (m)'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Patient Employer - Elevation (m)' WHERE idfsBaseReference = 10080592 AND idfsLanguage = 10049003 -- old value 'Human Case - Patient Employer - Elevation (m)'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - პაციენტის დამსაქმებელი - ელევაცია (მ)' WHERE idfsBaseReference = 10080592 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin iş yeri - Hündürlük (m)' WHERE idfsBaseReference = 10080592 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - المريض وهو صاحب العمل - الارتفاع (م)' WHERE idfsBaseReference = 10080592 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Patient Employer - Rayon' WHERE idfsBaseReference = 10080056 -- old value 'Human Case - Patient Employer - Rayon'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Patient Employer - Rayon' WHERE idfsBaseReference = 10080056 AND idfsLanguage = 10049003 -- old value 'Human Case - Patient Employer - Rayon'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - პაციენტის დამსაქმებელი - რაიონი' WHERE idfsBaseReference = 10080056 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin iş yeri - Rayon' WHERE idfsBaseReference = 10080056 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - المريض وهو صاحب العمل - رايون' WHERE idfsBaseReference = 10080056 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Patient Employer - Region' WHERE idfsBaseReference = 10080058 -- old value 'Human Case - Patient Employer - Region'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Patient Employer - Region' WHERE idfsBaseReference = 10080058 AND idfsLanguage = 10049003 -- old value 'Human Case - Patient Employer - Region'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - პაციენტის დამსაქმებელი - რეგიონი' WHERE idfsBaseReference = 10080058 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin iş yeri - Region' WHERE idfsBaseReference = 10080058 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - المريض وهو صاحب العمل - المنطقة' WHERE idfsBaseReference = 10080058 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Patient Employer - Settlement' WHERE idfsBaseReference = 10080060 -- old value 'Human Case - Patient Employer - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Patient Employer - Settlement' WHERE idfsBaseReference = 10080060 AND idfsLanguage = 10049003 -- old value 'Human Case - Patient Employer - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - პაციენტის დამსაქმებელი - დასახლება' WHERE idfsBaseReference = 10080060 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin iş yeri - Yaşayış yeri' WHERE idfsBaseReference = 10080060 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - المريض وهو صاحب العمل - الاقامة' WHERE idfsBaseReference = 10080060 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Patient Name' WHERE idfsBaseReference = 10080072 -- old value 'Human Case - Patient Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Patient Name' WHERE idfsBaseReference = 10080072 AND idfsLanguage = 10049003 -- old value 'Human Case - Patient Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - პაციენტის სახელი' WHERE idfsBaseReference = 10080072 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin adı' WHERE idfsBaseReference = 10080072 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - اسم المريض' WHERE idfsBaseReference = 10080072 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Patient Personal ID' WHERE idfsBaseReference = 10080581 -- old value 'Human Case - Patient Personal ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Patient Personal ID' WHERE idfsBaseReference = 10080581 AND idfsLanguage = 10049003 -- old value 'Human Case - Patient Personal ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - პაციენტის პერსონალური ID' WHERE idfsBaseReference = 10080581 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin Fərdi İN' WHERE idfsBaseReference = 10080581 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - الهوية الشخصية للمريض' WHERE idfsBaseReference = 10080581 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Patient Personal ID Type' WHERE idfsBaseReference = 10080580 -- old value 'Human Case - Patient Personal ID Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Patient Personal ID Type' WHERE idfsBaseReference = 10080580 AND idfsLanguage = 10049003 -- old value 'Human Case - Patient Personal ID Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - პაციენტის პერსონალური ID-ის ტიპი' WHERE idfsBaseReference = 10080580 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Xəstənin Fərdi İN növü' WHERE idfsBaseReference = 10080580 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - نوع الهوية الشخصية للمريض' WHERE idfsBaseReference = 10080580 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference set intRowStatus = 0 where idfsBaseReference = 10080503 -- hide 'Human Case - Permanent Residence - Address'
UPDATE dbo.trtBaseReference set intRowStatus = 0 where idfsBaseReference = 10080496 -- hide 'Human Case - Permanent Residence - Coordinates'
UPDATE dbo.trtBaseReference set intRowStatus = 0 where idfsBaseReference = 10080504 -- hide 'Human Case - Permanent Residence - Country'

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Alternate Address - Address' WHERE idfsBaseReference = 10080503 -- old value 'Human Case - Permanent Residence - Address'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Alternate Address - Address' WHERE idfsBaseReference = 10080503 AND idfsLanguage = 10049003 -- old value 'Human Case - Permanent Residence - Address'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ალტერნატიული მისამართი - მისამართი' WHERE idfsBaseReference = 10080503 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Alternativ ünvan - Ünvan' WHERE idfsBaseReference = 10080503 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - العنوان البديل - العنوان ' WHERE idfsBaseReference = 10080503 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Alternate Address - Coordinates' WHERE idfsBaseReference = 10080496 -- old value 'Human Case - Permanent Residence - Coordinates'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Alternate Address - Coordinates' WHERE idfsBaseReference = 10080496 AND idfsLanguage = 10049003 -- old value 'Human Case - Permanent Residence - Coordinates'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ალტერნატიული მისამართი - კოორდინატები' WHERE idfsBaseReference = 10080496 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Alternativ ünvan - Koordinatlar' WHERE idfsBaseReference = 10080496 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - العنوان البديل - الاحداثيات ' WHERE idfsBaseReference = 10080496 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Alternate Address - Country' WHERE idfsBaseReference = 10080504 -- old value 'Human Case - Permanent Residence - Country'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Alternate Address - Country' WHERE idfsBaseReference = 10080504 AND idfsLanguage = 10049003 -- old value 'Human Case - Permanent Residence - Country'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ალტერნატიული მისამართი - ქვეყანა' WHERE idfsBaseReference = 10080504 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Alternativ ünvan - Ölkə' WHERE idfsBaseReference = 10080504 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - العنوان البديل - البلد' WHERE idfsBaseReference = 10080504 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Alternate Address - Elevation (m)' WHERE idfsBaseReference = 10080593 -- old value 'Human Case - Permanent Residence - Elevation (m)'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Alternate Address - Elevation (m)' WHERE idfsBaseReference = 10080593 AND idfsLanguage = 10049003 -- old value 'Human Case - Permanent Residence - Elevation (m)'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ალტერნატიული მისამართი - ელევაცია (მ)' WHERE idfsBaseReference = 10080593 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Alternativ ünvan - Hündürlük (m)' WHERE idfsBaseReference = 10080593 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - العنوان البديل - الارتفاع (م)' WHERE idfsBaseReference = 10080593 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Alternate Address - Foreign Address' WHERE idfsBaseReference = 10080505 -- old value 'Human Case - Permanent Residence - Foreign Address'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Alternate Address - Foreign Address' WHERE idfsBaseReference = 10080505 AND idfsLanguage = 10049003 -- old value 'Human Case - Permanent Residence - Foreign Address'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ალტერნატიული მისამართი -უცხოური  მისამართი' WHERE idfsBaseReference = 10080505 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Alternativ ünvan - Xarici ünvan' WHERE idfsBaseReference = 10080505 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - العنوان البديل - العنوان الأجنبي' WHERE idfsBaseReference = 10080505 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Alternate Address - Latitude' WHERE idfsBaseReference = 10080517 -- old value 'Human Case - Permanent Residence - Latitude'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Alternate Address - Latitude' WHERE idfsBaseReference = 10080517 AND idfsLanguage = 10049003 -- old value 'Human Case - Permanent Residence - Latitude'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ალტერნატიული მისამართი - განედი' WHERE idfsBaseReference = 10080517 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Insan Xəstəliyi üzrə Hesabat - Alternativ ünvan - En dairəsi' WHERE idfsBaseReference = 10080517 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - العنوان البديل - خط العرض' WHERE idfsBaseReference = 10080517 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Alternate Address - Longitude' WHERE idfsBaseReference = 10080516 -- old value 'Human Case - Permanent Residence - Longitude'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Alternate Address - Longitude' WHERE idfsBaseReference = 10080516 AND idfsLanguage = 10049003 -- old value 'Human Case - Permanent Residence - Longitude'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ალტერნატიული მისამართი - გრძედი' WHERE idfsBaseReference = 10080516 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Alternativ ünvan - Uzunluq dairəsi' WHERE idfsBaseReference = 10080516 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - العنوان البديل - خط الطول' WHERE idfsBaseReference = 10080516 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Alternate Address - Rayon' WHERE idfsBaseReference = 10080501 -- old value 'Human Case - Permanent Residence - Rayon'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Alternate Address - Rayon' WHERE idfsBaseReference = 10080501 AND idfsLanguage = 10049003 -- old value 'Human Case - Permanent Residence - Rayon'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ალტერნატიული მისამართი - რაიონი' WHERE idfsBaseReference = 10080501 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Alternativ ünvan - Rayon' WHERE idfsBaseReference = 10080501 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - العنوان البديل - رايون' WHERE idfsBaseReference = 10080501 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Alternate Address - Region' WHERE idfsBaseReference = 10080500 -- old value 'Human Case - Permanent Residence - Region'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Alternate Address - Region' WHERE idfsBaseReference = 10080500 AND idfsLanguage = 10049003 -- old value 'Human Case - Permanent Residence - Region'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ალტერნატიული მისამართი - რეგიონი' WHERE idfsBaseReference = 10080500 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Alternativ ünvan - Region' WHERE idfsBaseReference = 10080500 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - العنوان البديل - المنطقة' WHERE idfsBaseReference = 10080500 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Alternate Address - Town or Village' WHERE idfsBaseReference = 10080502 -- old value 'Human Case - Permanent Residence - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Alternate Address - Town or Village' WHERE idfsBaseReference = 10080502 AND idfsLanguage = 10049003 -- old value 'Human Case - Permanent Residence - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ალტერნატიული მისამართი - ქალაქი ან სოფელი' WHERE idfsBaseReference = 10080502 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Alternativ ünvan - Şəhər və ya Kənd' WHERE idfsBaseReference = 10080502 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - العنوان البديل - المدينة أو القرية ' WHERE idfsBaseReference = 10080502 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Alternate Address Phone Number' WHERE idfsBaseReference = 10080506 -- old value 'Human Case - Permanent Residence Phone Number'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Alternate Address Phone Number' WHERE idfsBaseReference = 10080506 AND idfsLanguage = 10049003 -- old value 'Human Case - Permanent Residence Phone Number'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ალტერნატიული მისამართი ტელეფონის ნომერი' WHERE idfsBaseReference = 10080506 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Alternativ ünvan Telefon nömrəsi' WHERE idfsBaseReference = 10080506 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - العنوان البديل - رقم الهاتف' WHERE idfsBaseReference = 10080506 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Place of Hospitalization' WHERE idfsBaseReference = 10080233 -- old value 'Human Case - Place of Hospitalization'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Place of Hospitalization' WHERE idfsBaseReference = 10080233 AND idfsLanguage = 10049003 -- old value 'Human Case - Place of Hospitalization'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ჰოსპიტალიზაციის ადგილი' WHERE idfsBaseReference = 10080233 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Hospitalizasiya yeri' WHERE idfsBaseReference = 10080233 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - مكان الاستشفاء ' WHERE idfsBaseReference = 10080233 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Reason for not Collecting Sample' WHERE idfsBaseReference = 10080438 -- old value 'Human Case - Reason for not Collecting Sample'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Reason for not Collecting Sample' WHERE idfsBaseReference = 10080438 AND idfsLanguage = 10049003 -- old value 'Human Case - Reason for not Collecting Sample'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - მიზეზი, თუ რატომ არ მოხდა ნიმუშის აღება' WHERE idfsBaseReference = 10080438 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Nümunələrin toplanmamasının səbəbi' WHERE idfsBaseReference = 10080438 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - سبب عدم جمع العينة ' WHERE idfsBaseReference = 10080438 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080065 -- hide 'Human Case - Relation to Outbreak'
UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Samples Collected' WHERE idfsBaseReference = 10080089 -- old value 'Human Case - Samples Collected'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Samples Collected' WHERE idfsBaseReference = 10080089 AND idfsLanguage = 10049003 -- old value 'Human Case - Samples Collected'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - აღებული ნიმუშები' WHERE idfsBaseReference = 10080089 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Toplanmış nümunələr' WHERE idfsBaseReference = 10080089 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - العينات المُجمعة ' WHERE idfsBaseReference = 10080089 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Sex' WHERE idfsBaseReference = 10080088 -- old value 'Human Case - Sex'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Sex' WHERE idfsBaseReference = 10080088 AND idfsLanguage = 10049003 -- old value 'Human Case - Sex'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სქესი' WHERE idfsBaseReference = 10080088 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Cinsiyyəti' WHERE idfsBaseReference = 10080088 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - الجنس ' WHERE idfsBaseReference = 10080088 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Starting Date Of Investigation' WHERE idfsBaseReference = 10080090 -- old value 'Human Case - Starting Date Of Investigation'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Starting Date Of Investigation' WHERE idfsBaseReference = 10080090 AND idfsLanguage = 10049003 -- old value 'Human Case - Starting Date Of Investigation'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - გამოკვლევის დაწყების თარიღი' WHERE idfsBaseReference = 10080090 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Tədqiqatın başlanma tarixi' WHERE idfsBaseReference = 10080090 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - تاريخ البدء في البحث' WHERE idfsBaseReference = 10080090 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Status of the Patient at Time of Notification' WHERE idfsBaseReference = 10080091 -- old value 'Human Case - Status of the Patient at Time of Notification'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Status of the Patient at Time of Notification' WHERE idfsBaseReference = 10080091 AND idfsLanguage = 10049003 -- old value 'Human Case - Status of the Patient at Time of Notification'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - პაციენტის სტატუსი შეტყობინების დროს' WHERE idfsBaseReference = 10080091 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Bildiriş qəbul olunduğu zaman xəstənin vəziyyəti' WHERE idfsBaseReference = 10080091 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - حالة المريض في وقت الإخطار' WHERE idfsBaseReference = 10080091 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Tests Conducted' WHERE idfsBaseReference = 10080498 -- old value 'Human Case - Tests Conducted'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Tests Conducted' WHERE idfsBaseReference = 10080498 AND idfsLanguage = 10049003 -- old value 'Human Case - Tests Conducted'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - ჩატარებული ტესტები' WHERE idfsBaseReference = 10080498 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Aparılan testlər' WHERE idfsBaseReference = 10080498 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية - الاختبارات التي أُجريت' WHERE idfsBaseReference = 10080498 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Accession Date' WHERE idfsBaseReference = 10080118 -- old value 'Human Case Sample - Accession Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Accession Date' WHERE idfsBaseReference = 10080118 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Accession Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - მიღების თარიღი' WHERE idfsBaseReference = 10080118 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Qəbul etmə tarixi' WHERE idfsBaseReference = 10080118 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - تاريخ الانضمام' WHERE idfsBaseReference = 10080118 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Disease Report ID' WHERE idfsBaseReference = 10080119 -- old value 'Human Case Sample - Case ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Disease Report ID' WHERE idfsBaseReference = 10080119 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Case ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - დაავადების ანგარიშის ID' WHERE idfsBaseReference = 10080119 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Xəstəlik hesabatının Q/N-si' WHERE idfsBaseReference = 10080119 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - معرّف تقرير المرض ' WHERE idfsBaseReference = 10080119 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Collected By Institution' WHERE idfsBaseReference = 10080100 -- old value 'Human Case Sample - Collected By Institution'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Collected By Institution' WHERE idfsBaseReference = 10080100 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Collected By Institution'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - აღებულია დაწესებულების მიერ' WHERE idfsBaseReference = 10080100 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Toplayan müəssisə' WHERE idfsBaseReference = 10080100 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - جمعتها المؤسسة ' WHERE idfsBaseReference = 10080100 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Collected By Officer' WHERE idfsBaseReference = 10080100 -- old value 'Human Disease Report Sample - Collected By Institution'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Collected By Officer' WHERE idfsBaseReference = 10080100 AND idfsLanguage = 10049003 -- old value 'Human Disease Report Sample - Collected By Institution'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - აღებულია თანამშრომლის მიერ' WHERE idfsBaseReference = 10080100 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Toplayan işçi' WHERE idfsBaseReference = 10080100 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - جمعها الموظف' WHERE idfsBaseReference = 10080100 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Collection Date' WHERE idfsBaseReference = 10080016 -- old value 'Human Case Sample - Collection Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Collection Date' WHERE idfsBaseReference = 10080016 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Collection Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - აღების თარიღი' WHERE idfsBaseReference = 10080016 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Toplama tarixi' WHERE idfsBaseReference = 10080016 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - تاريخ الجمع' WHERE idfsBaseReference = 10080016 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Comment' WHERE idfsBaseReference = 10080120 -- old value 'Human Case Sample - Comment'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Comment' WHERE idfsBaseReference = 10080120 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Comment'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - კომენტარი' WHERE idfsBaseReference = 10080120 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Qeyd' WHERE idfsBaseReference = 10080120 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - تعليق' WHERE idfsBaseReference = 10080120 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Condition Received' WHERE idfsBaseReference = 10080235 -- old value 'Human Case Sample - Condition Received'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Condition Received' WHERE idfsBaseReference = 10080235 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Condition Received'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - მდგომარეობა მიღებისას' WHERE idfsBaseReference = 10080235 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Qəbul zamanı nümunənin vəziyyəti' WHERE idfsBaseReference = 10080235 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - الحالة المتلقاة ' WHERE idfsBaseReference = 10080235 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Current Laboratory' WHERE idfsBaseReference = 10080728 -- old value 'Human Case Sample - Current Laboratory'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Current Laboratory' WHERE idfsBaseReference = 10080728 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Current Laboratory'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080728 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში -მოქმედი ლაბორატორია' WHERE idfsBaseReference = 10080728 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ადამიანის დაავადების ანგარიშის ნიმუში -მოქმედი ლაბორატორია', 10080728, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080728 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Cari laboratoriya' WHERE idfsBaseReference = 10080728 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Cari laboratoriya', 10080728, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080728 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - المختبر الحالي' WHERE idfsBaseReference = 10080728 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج عن تقرير الامراض البشرية - المختبر الحالي', 10080728, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Days after First Sought Care until Sample Collection' WHERE idfsBaseReference = 10080453 -- old value 'Human Case Sample - Days after First Sought Care until Sample Collection'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Days after First Sought Care until Sample Collection' WHERE idfsBaseReference = 10080453 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Days after First Sought Care until Sample Collection'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - დღეების რაოდენობა პირველადი მიმართვიდან ნიმუშის აღებამდე' WHERE idfsBaseReference = 10080453 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - İlk yardım üçün müraciət tarixindən Nümunənin toplanması tarixinədək keçən günlərin sayı' WHERE idfsBaseReference = 10080453 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية -عدد الأيام التي انقضت من تاريخ تقديم الاسعافات الأولية إلى تاريخ جمع العينة' WHERE idfsBaseReference = 10080453 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Days after Notification until Sample Collection' WHERE idfsBaseReference = 10080452 -- old value 'Human Case Sample - Days after Notification until Sample Collection'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Days after Notification until Sample Collection' WHERE idfsBaseReference = 10080452 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Days after Notification until Sample Collection'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - დღეების რაოდენობა შეტყობინებიდან ნიმუშის აღებამდე' WHERE idfsBaseReference = 10080452 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Bildiriş tarixindən Nümunənin toplanması tarixinədək keçən günlərin sayı' WHERE idfsBaseReference = 10080452 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية -عدد الأيام التي انقضت من تاريخ الإخطار  إلى تاريخ جمع العينة' WHERE idfsBaseReference = 10080452 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Days in Transit' WHERE idfsBaseReference = 10080018 -- old value 'Human Case Sample - Days in Transit'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Days in Transit' WHERE idfsBaseReference = 10080018 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Days in Transit'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - დღეების რაოდენობა ტრანზიტში' WHERE idfsBaseReference = 10080018 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Daşınma vaxtı (günlər)' WHERE idfsBaseReference = 10080018 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - أيام العبور ' WHERE idfsBaseReference = 10080018 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Days until Sample Accessioned Since Sent Date' WHERE idfsBaseReference = 10080455 -- old value 'Human Case Sample - Days until Sample Accessioned Since Sent Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Days until Sample Accessioned Since Sent Date' WHERE idfsBaseReference = 10080455 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Days until Sample Accessioned Since Sent Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - დღეების რაოდენობა ნიმუშის გაგზავნიდან მიღებამდე' WHERE idfsBaseReference = 10080455 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Nümunənin göndərildiyi tarixdən Nümunənin qəbul edildiyi tarixədək keçən günlərin sayı' WHERE idfsBaseReference = 10080455 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - عدد الأيام  المتبقية إلى وصول العينة منذ تاريخ الارسال' WHERE idfsBaseReference = 10080455 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Days until Sample Sent Since Collection' WHERE idfsBaseReference = 10080454 -- old value 'Human Case Sample - Days until Sample Sent Since Collection'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Days until Sample Sent Since Collection' WHERE idfsBaseReference = 10080454 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Days until Sample Sent Since Collection'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - დღეების რაოდენობა  ნიმუშის აღებიდან გაგზავნამდე' WHERE idfsBaseReference = 10080454 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Nümunənin toplanma tarixindən Nümunənin göndərildiyi tarixədək keçən günlərin sayı' WHERE idfsBaseReference = 10080454 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - عدد الأيام المتبقية  لارسال العينة منذ تاريخ جمعها' WHERE idfsBaseReference = 10080454 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Destruction Method' WHERE idfsBaseReference = 10080550 -- old value 'Human Case Sample - Destruction Method'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Destruction Method' WHERE idfsBaseReference = 10080550 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Destruction Method'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - დესტრუქციის მეთოდი' WHERE idfsBaseReference = 10080550 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Məhv edilmə metodu' WHERE idfsBaseReference = 10080550 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - طريقة التدمير' WHERE idfsBaseReference = 10080550 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Disease' WHERE idfsBaseReference = 10080019 -- old value 'Human Case Sample - Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Disease' WHERE idfsBaseReference = 10080019 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - დაავადება' WHERE idfsBaseReference = 10080019 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Xəstəlik' WHERE idfsBaseReference = 10080019 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - المرض ' WHERE idfsBaseReference = 10080019 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Disease - Is Zoonotic' WHERE idfsBaseReference = 10080564 -- old value 'Human Case Sample - Diagnosis - Is Zoonotic'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Disease - Is Zoonotic' WHERE idfsBaseReference = 10080564 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Diagnosis - Is Zoonotic'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში -დაავადება - არის ზოონოზური' WHERE idfsBaseReference = 10080564 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Xəstəlik - Zoonoz' WHERE idfsBaseReference = 10080564 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - المرض - حيواني المصدر' WHERE idfsBaseReference = 10080564 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Functional Area' WHERE idfsBaseReference = 10080507 -- old value 'Human Case Sample - Functional Area'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Functional Area' WHERE idfsBaseReference = 10080507 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Functional Area'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - ფუნქციონალური არეალი' WHERE idfsBaseReference = 10080507 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Laboratoriya (şöbə)' WHERE idfsBaseReference = 10080507 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - المجال الوظيفي' WHERE idfsBaseReference = 10080507 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Initially Collected Sample - Accession Date' WHERE idfsBaseReference = 10080726 -- old value 'Human Case Sample - Initially Collected Sample - Accession Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Initially Collected Sample - Accession Date' WHERE idfsBaseReference = 10080726 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Initially Collected Sample - Accession Date'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080726 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - მიღების თარიღი' WHERE idfsBaseReference = 10080726 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ადამიანის დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - მიღების თარიღი', 10080726, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080726 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - İlkin toplanılmış nümunə - Qəbul edilmə tarixi' WHERE idfsBaseReference = 10080726 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'İnsan Xəstəliyi üzrə Hesabat Nümunə - İlkin toplanılmış nümunə - Qəbul edilmə tarixi', 10080726, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080726 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - العينة الأولية المُجمعة - تاريخ الانضمام' WHERE idfsBaseReference = 10080726 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج عن تقرير الامراض البشرية - العينة الأولية المُجمعة - تاريخ الانضمام', 10080726, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Initially Collected Sample - Collected By Institution' WHERE idfsBaseReference = 10080723 -- old value 'Human Case Sample - Initially Collected Sample - Collected By Institution'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Initially Collected Sample - Collected By Institution' WHERE idfsBaseReference = 10080723 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Initially Collected Sample - Collected By Institution'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080723 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში -  თავდაპირველად აღებული ნიმუში - აღებულია დაწესებულების მიერ' WHERE idfsBaseReference = 10080723 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ადამიანის დაავადების ანგარიშის ნიმუში -  თავდაპირველად აღებული ნიმუში - აღებულია დაწესებულების მიერ', 10080723, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080723 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - İlkin toplanılmış nümunə - Toplayan müəssisə' WHERE idfsBaseReference = 10080723 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'İnsan Xəstəliyi üzrə Hesabat Nümunə - İlkin toplanılmış nümunə - Toplayan müəssisə', 10080723, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080723 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - العينة الأولية المُجمعة - جمعتها المؤسسة ' WHERE idfsBaseReference = 10080723 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج عن تقرير الامراض البشرية - العينة الأولية المُجمعة - جمعتها المؤسسة ', 10080723, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Initially Collected Sample - Collection Date' WHERE idfsBaseReference = 10080724 -- old value 'Human Case Sample - Initially Collected Sample - Collection Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Initially Collected Sample - Collection Date' WHERE idfsBaseReference = 10080724 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Initially Collected Sample - Collection Date'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080724 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - აღების თარიღი' WHERE idfsBaseReference = 10080724 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ადამიანის დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - აღების თარიღი', 10080724, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080724 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - İlkin toplanılmış nümunə - Toplama tarixi' WHERE idfsBaseReference = 10080724 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'İnsan Xəstəliyi üzrə Hesabat Nümunə - İlkin toplanılmış nümunə - Toplama tarixi', 10080724, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080724 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - العينة الأولية المُجمعة - تاريخ الجمع ' WHERE idfsBaseReference = 10080724 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج عن تقرير الامراض البشرية - العينة الأولية المُجمعة - تاريخ الجمع ', 10080724, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Initially Collected Sample - Current Laboratory' WHERE idfsBaseReference = 10080722 -- old value 'Human Case Sample - Initially Collected Sample - Current Laboratory'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Initially Collected Sample - Current Laboratory' WHERE idfsBaseReference = 10080722 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Initially Collected Sample - Current Laboratory'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080722 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - მოქმედი ლაბორატორია' WHERE idfsBaseReference = 10080722 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ადამიანის დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - მოქმედი ლაბორატორია', 10080722, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080722 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - İlkin toplanılmış nümunə - Cari laboratoriya' WHERE idfsBaseReference = 10080722 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'İnsan Xəstəliyi üzrə Hesabat Nümunə - İlkin toplanılmış nümunə - Cari laboratoriya', 10080722, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080722 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - العينة الأولية المُجمعة - المختبر الحالي ' WHERE idfsBaseReference = 10080722 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج عن تقرير الامراض البشرية - العينة الأولية المُجمعة - المختبر الحالي ', 10080722, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Initially Collected Sample - Lab ID' WHERE idfsBaseReference = 10080719 -- old value 'Human Case Sample - Initially Collected Sample - Lab ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Initially Collected Sample - Lab ID' WHERE idfsBaseReference = 10080719 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Initially Collected Sample - Lab ID'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080719 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - ლაბორატორიული ID' WHERE idfsBaseReference = 10080719 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ადამიანის დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - ლაბორატორიული ID', 10080719, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080719 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - İlkin toplanılmış nümunə - Laborator nümunənin Q/N-si' WHERE idfsBaseReference = 10080719 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'İnsan Xəstəliyi üzrə Hesabat Nümunə - İlkin toplanılmış nümunə - Laborator nümunənin Q/N-si', 10080719, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080719 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - العينة الأولية المُجمعة - معرّف المختبر ' WHERE idfsBaseReference = 10080719 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج عن تقرير الامراض البشرية - العينة الأولية المُجمعة - معرّف المختبر ', 10080719, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Initially Collected Sample - Local ID' WHERE idfsBaseReference = 10080720 -- old value 'Human Case Sample - Initially Collected Sample - Local ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Initially Collected Sample - Local ID' WHERE idfsBaseReference = 10080720 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Initially Collected Sample - Local ID'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080720 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში -ადგილობრივი  ID' WHERE idfsBaseReference = 10080720 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ადამიანის დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში -ადგილობრივი  ID', 10080720, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080720 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - İlkin toplanılmış nümunə - Nümunənin yerli Q/N-si' WHERE idfsBaseReference = 10080720 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'İnsan Xəstəliyi üzrə Hesabat Nümunə - İlkin toplanılmış nümunə - Nümunənin yerli Q/N-si', 10080720, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080720 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - العينة الأولية المُجمعة - المعرّف المحلي' WHERE idfsBaseReference = 10080720 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج عن تقرير الامراض البشرية - العينة الأولية المُجمعة - المعرّف المحلي', 10080720, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Initially Collected Sample - Sent to Organization' WHERE idfsBaseReference = 10080725 -- old value 'Human Case Sample - Initially Collected Sample - Sent to Organization'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Initially Collected Sample - Sent to Organization' WHERE idfsBaseReference = 10080725 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Initially Collected Sample - Sent to Organization'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080725 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - გაგზავნილია ორგანიზაციაში' WHERE idfsBaseReference = 10080725 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ადამიანის დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - გაგზავნილია ორგანიზაციაში', 10080725, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080725 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - İlkin toplanılmış nümunə - Hara göndərilib' WHERE idfsBaseReference = 10080725 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'İnsan Xəstəliyi üzrə Hesabat Nümunə - İlkin toplanılmış nümunə - Hara göndərilib', 10080725, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080725 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية  - العينة الأولية المُجمعة - ارسلت الى المنظمة ' WHERE idfsBaseReference = 10080725 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج عن تقرير الامراض البشرية  - العينة الأولية المُجمعة - ارسلت الى المنظمة ', 10080725, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Initially Collected Sample - Status' WHERE idfsBaseReference = 10080727 -- old value 'Human Case Sample - Initially Collected Sample - Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Initially Collected Sample - Status' WHERE idfsBaseReference = 10080727 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Initially Collected Sample - Status'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080727 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - სტატუსი' WHERE idfsBaseReference = 10080727 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ადამიანის დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - სტატუსი', 10080727, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080727 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - İlkin toplanılmış nümunə - Statusu' WHERE idfsBaseReference = 10080727 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'İnsan Xəstəliyi üzrə Hesabat Nümunə - İlkin toplanılmış nümunə - Statusu', 10080727, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080727 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية  - العينة الأولية المُجمعة - الحالة ' WHERE idfsBaseReference = 10080727 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE 
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج عن تقرير الامراض البشرية  - العينة الأولية المُجمعة - الحالة ', 10080727, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Initially Collected Sample - Type' WHERE idfsBaseReference = 10080721 -- old value 'Human Case Sample - Initially Collected Sample - Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Initially Collected Sample - Type' WHERE idfsBaseReference = 10080721 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Initially Collected Sample - Type'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080721 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - ტიპი' WHERE idfsBaseReference = 10080721 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ადამიანის დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - ტიპი', 10080721, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080721 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - İlkin toplanılmış nümunə - Növü' WHERE idfsBaseReference = 10080721 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'İnsan Xəstəliyi üzrə Hesabat Nümunə - İlkin toplanılmış nümunə - Növü', 10080721, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080721 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - العينة الأولية المُجمعة - النوع' WHERE idfsBaseReference = 10080721 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج عن تقرير الامراض البشرية - العينة الأولية المُجمعة - النوع', 10080721, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Lab Sample ID' WHERE idfsBaseReference = 10080101 -- old value 'Human Case Sample - Lab Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Lab Sample ID' WHERE idfsBaseReference = 10080101 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Lab Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში - ლაბორატორიული ნიმუშის ID' WHERE idfsBaseReference = 10080101 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Laborator nümunənin Q/N-si' WHERE idfsBaseReference = 10080101 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - معرّف العينة المخبرية ' WHERE idfsBaseReference = 10080101 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Local Sample ID' WHERE idfsBaseReference = 10080103 -- old value 'Human Case Sample - Local Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Local Sample ID' WHERE idfsBaseReference = 10080103 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Local Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში -  ადგილობრივი ნიმუშის ID ' WHERE idfsBaseReference = 10080103 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Nümunənin yerli Q/N-si' WHERE idfsBaseReference = 10080103 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - معرّف العينة المحلية' WHERE idfsBaseReference = 10080103 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Parent Sample - Accession Date' WHERE idfsBaseReference = 10080735 -- old value 'Human Case Sample - Parent Sample - Accession Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Parent Sample - Accession Date' WHERE idfsBaseReference = 10080735 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Parent Sample - Accession Date'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080735 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში  - ძირითადი ნიმუში - მიღების თარიღი' WHERE idfsBaseReference = 10080735 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ადამიანის დაავადების ანგარიშის ნიმუში  - ძირითადი ნიმუში - მიღების თარიღი', 10080735, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080735 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Əsas nümunə - Qəbul edilmə tarixi' WHERE idfsBaseReference = 10080735 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Əsas nümunə - Qəbul edilmə tarixi', 10080735, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080735 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - أصل العينة - تاريخ الانضمام ' WHERE idfsBaseReference = 10080735 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج عن تقرير الامراض البشرية - أصل العينة - تاريخ الانضمام ', 10080735, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Parent Sample - Collected By Institution' WHERE idfsBaseReference = 10080732 -- old value 'Human Case Sample - Parent Sample - Collected By Institution'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Parent Sample - Collected By Institution' WHERE idfsBaseReference = 10080732 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Parent Sample - Collected By Institution'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080732 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში  - ძირითადი ნიმუში - აღებულია დაწესებულების მიერ' WHERE idfsBaseReference = 10080732 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ადამიანის დაავადების ანგარიშის ნიმუში  - ძირითადი ნიმუში - აღებულია დაწესებულების მიერ', 10080732, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080732 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Əsas nümunə - Toplayan müəssisə' WHERE idfsBaseReference = 10080732 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Əsas nümunə - Toplayan müəssisə', 10080732, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080732 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - أصل العينة - جمعتها المؤسسة ' WHERE idfsBaseReference = 10080732 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج عن تقرير الامراض البشرية - أصل العينة - جمعتها المؤسسة ', 10080732, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Parent Sample - Collection Date' WHERE idfsBaseReference = 10080733 -- old value 'Human Case Sample - Parent Sample - Collection Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Parent Sample - Collection Date' WHERE idfsBaseReference = 10080733 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Parent Sample - Collection Date'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080733 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში  - ძირითადი ნიმუში - აღების თარიღი' WHERE idfsBaseReference = 10080733 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ადამიანის დაავადების ანგარიშის ნიმუში  - ძირითადი ნიმუში - აღების თარიღი', 10080733, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080733 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Əsas nümunə - Toplama tarixi' WHERE idfsBaseReference = 10080733 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Əsas nümunə - Toplama tarixi', 10080733, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080733 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - أصل العينة -تاريخ الجمع ' WHERE idfsBaseReference = 10080733 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج عن تقرير الامراض البشرية - أصل العينة -تاريخ الجمع ', 10080733, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Parent Sample - Current Laboratory' WHERE idfsBaseReference = 10080731 -- old value 'Human Case Sample - Parent Sample - Current Laboratory'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Parent Sample - Current Laboratory' WHERE idfsBaseReference = 10080731 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Parent Sample - Current Laboratory'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080731 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში  - ძირითადი ნიმუში - მოქმედი ლაბორატორია' WHERE idfsBaseReference = 10080731 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ადამიანის დაავადების ანგარიშის ნიმუში  - ძირითადი ნიმუში - მოქმედი ლაბორატორია' , 10080731, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080731 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Əsas nümunə - Cari laboratoriya' WHERE idfsBaseReference = 10080731 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Əsas nümunə - Cari laboratoriya', 10080731, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080731 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - أصل العينة - المختبر الحالي' WHERE idfsBaseReference = 10080731 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج عن تقرير الامراض البشرية - أصل العينة - المختبر الحالي', 10080731, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Parent Sample - Lab ID' WHERE idfsBaseReference = 10080117 -- old value 'Human Case Sample - Parent Sample - Lab ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Parent Sample - Lab ID' WHERE idfsBaseReference = 10080117 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Parent Sample - Lab ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში  - ძირითადი ნიმუში - ლაბორატორიული ID' WHERE idfsBaseReference = 10080117 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Əsas nümunə - Laborator nümunənin Q/N-si' WHERE idfsBaseReference = 10080117 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - أصل العينة -معرّف المختبر ' WHERE idfsBaseReference = 10080117 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Parent Sample - Local ID' WHERE idfsBaseReference = 10080729 -- old value 'Human Case Sample - Parent Sample - Local ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Parent Sample - Local ID' WHERE idfsBaseReference = 10080729 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Parent Sample - Local ID'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080729 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში  - ძირითადი ნიმუში - ადგილობრივი ID' WHERE idfsBaseReference = 10080729 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ადამიანის დაავადების ანგარიშის ნიმუში  - ძირითადი ნიმუში - ადგილობრივი ID', 10080729, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080729 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Əsas nümunə - Nümunənin yerli Q/N-si' WHERE idfsBaseReference = 10080729 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Əsas nümunə - Nümunənin yerli Q/N-si', 10080729, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080729 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - أصل العينة -المعرّف المحلي ' WHERE idfsBaseReference = 10080729 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج عن تقرير الامراض البشرية - أصل العينة -المعرّف المحلي ', 10080729, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Parent Sample - Sent to Organization' WHERE idfsBaseReference = 10080734 -- old value 'Human Case Sample - Parent Sample - Sent to Organization'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Parent Sample - Sent to Organization' WHERE idfsBaseReference = 10080734 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Parent Sample - Sent to Organization'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080734 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში  - ძირითადი ნიმუში - გაგზავნილია ორგანიზაციაში' WHERE idfsBaseReference = 10080734 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ადამიანის დაავადების ანგარიშის ნიმუში  - ძირითადი ნიმუში - გაგზავნილია ორგანიზაციაში', 10080734, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080734 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Əsas nümunə - Hara göndərilib' WHERE idfsBaseReference = 10080734 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Əsas nümunə - Hara göndərilib', 10080734, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080734 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - أصل العينة -ارسلت الى المنظمة ' WHERE idfsBaseReference = 10080734 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج عن تقرير الامراض البشرية - أصل العينة -ارسلت الى المنظمة ', 10080734, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Parent Sample - Status' WHERE idfsBaseReference = 10080736 -- old value 'Human Case Sample - Parent Sample - Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Parent Sample - Status' WHERE idfsBaseReference = 10080736 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Parent Sample - Status'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080736 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში  - ძირითადი ნიმუში - სტატუსი' WHERE idfsBaseReference = 10080736 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ადამიანის დაავადების ანგარიშის ნიმუში  - ძირითადი ნიმუში - სტატუსი', 10080736, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080736 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Əsas nümunə - Statusu' WHERE idfsBaseReference = 10080736 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Əsas nümunə - Statusu', 10080736, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080736 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - أصل العينة -الحالة' WHERE idfsBaseReference = 10080736 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج عن تقرير الامراض البشرية - أصل العينة -الحالة', 10080736, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Parent Sample - Type' WHERE idfsBaseReference = 10080730 -- old value 'Human Case Sample - Parent Sample - Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Parent Sample - Type' WHERE idfsBaseReference = 10080730 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Parent Sample - Type'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080730 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში  - ძირითადი ნიმუში - ტიპი' WHERE idfsBaseReference = 10080730 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ადამიანის დაავადების ანგარიშის ნიმუში  - ძირითადი ნიმუში - ტიპი', 10080730, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080730 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Əsas nümunə - Növü' WHERE idfsBaseReference = 10080730 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Əsas nümunə - Növü', 10080730, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080730 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - أصل العينة -النوع ' WHERE idfsBaseReference = 10080730 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج عن تقرير الامراض البشرية - أصل العينة -النوع ', 10080730, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Patient Name' WHERE idfsBaseReference = 10080234 -- old value 'Human Case Sample - Patient Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Patient Name' WHERE idfsBaseReference = 10080234 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Patient Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში  - პაციენტის სახელი' WHERE idfsBaseReference = 10080234 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Xəstənin adı' WHERE idfsBaseReference = 10080234 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - اسم المريض ' WHERE idfsBaseReference = 10080234 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Reason for not Collecting Sample' WHERE idfsBaseReference = 10080451 -- old value 'Human Case Sample - Reason for not Collecting Sample'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Reason for not Collecting Sample' WHERE idfsBaseReference = 10080451 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Reason for not Collecting Sample'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში  - მიზეზი, თუ რატომ არ მოხდა ნიმუშის აღება' WHERE idfsBaseReference = 10080451 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Nümunəninn toplanmamasının səbəbi' WHERE idfsBaseReference = 10080451 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - أسباب لعدم جمع العينات ' WHERE idfsBaseReference = 10080451 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Sample Type' WHERE idfsBaseReference = 10080122 -- old value 'Human Case Sample - Sample Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Sample Type' WHERE idfsBaseReference = 10080122 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Sample Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში  - ნიმუშის ტიპი' WHERE idfsBaseReference = 10080122 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Nümunənin növü' WHERE idfsBaseReference = 10080122 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - نوع العينة ' WHERE idfsBaseReference = 10080122 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Sent Date' WHERE idfsBaseReference = 10080121 -- old value 'Human Case Sample - Sent Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Sent Date' WHERE idfsBaseReference = 10080121 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Sent Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში  - გაგზავნის თარიღი' WHERE idfsBaseReference = 10080121 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Göndərilmə tarixi' WHERE idfsBaseReference = 10080121 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية -تاريخ الارسال ' WHERE idfsBaseReference = 10080121 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Sample - Sent to Organization' WHERE idfsBaseReference = 10080509 -- old value 'Human Case Sample - Sent to Organization'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Sample - Sent to Organization' WHERE idfsBaseReference = 10080509 AND idfsLanguage = 10049003 -- old value 'Human Case Sample - Sent to Organization'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ნიმუში  - გაგზავნილია ორგანიზაციაში' WHERE idfsBaseReference = 10080509 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Nümunə - Hara göndərilib' WHERE idfsBaseReference = 10080509 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج عن تقرير الامراض البشرية - ارسلت الى المنظمة ' WHERE idfsBaseReference = 10080509 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference set intRowStatus = 0 where idfsBaseReference = 10080716 -- do not hide 'Human Case Sample - Status' new request from Anatoliy 4/14/22

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Test - Disease Report ID' WHERE idfsBaseReference = 10080133 -- old value 'Human Case Test - Case ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Test - Disease Report ID' WHERE idfsBaseReference = 10080133 AND idfsLanguage = 10049003 -- old value 'Human Case Test - Case ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ტესტი  - დაავადების ანგარიშის ID' WHERE idfsBaseReference = 10080133 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Test - Xəstəlik hesabatının Q/N-si' WHERE idfsBaseReference = 10080133 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار تقرير الامراض البشرية - معرّف تقرير المرض ' WHERE idfsBaseReference = 10080133 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Test - Date Started' WHERE idfsBaseReference = 10080017 -- old value 'Human Case Test - Date Started'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Test - Date Started' WHERE idfsBaseReference = 10080017 AND idfsLanguage = 10049003 -- old value 'Human Case Test - Date Started'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ტესტი - დაწყების თარიღი' WHERE idfsBaseReference = 10080017 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Test - Başlanma tarixi' WHERE idfsBaseReference = 10080017 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - تاريخ البدء ' WHERE idfsBaseReference = 10080017 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Test - Days until Testing since Sample Accessioned' WHERE idfsBaseReference = 10080457 -- old value 'Human Case Test - Days until Testing since Sample Accessioned'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Test - Days until Testing since Sample Accessioned' WHERE idfsBaseReference = 10080457 AND idfsLanguage = 10049003 -- old value 'Human Case Test - Days until Testing since Sample Accessioned'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ტესტი - დღეების რაოდენობა ნიმუშის მიღებიდან ტესტირებამდე' WHERE idfsBaseReference = 10080457 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Test - Nümunə qəbul edildiyi tarixdən testin aparılma tarixinədək keçən günlərin sayı' WHERE idfsBaseReference = 10080457 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - الأيام المتبقية للاختبار منذ انضمام العينة ' WHERE idfsBaseReference = 10080457 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Test - Days until Testing since Sample Sent' WHERE idfsBaseReference = 10080456 -- old value 'Human Case Test - Days until Testing since Sample Sent'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Test - Days until Testing since Sample Sent' WHERE idfsBaseReference = 10080456 AND idfsLanguage = 10049003 -- old value 'Human Case Test - Days until Testing since Sample Sent'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ტესტი - დღეების რაოდენობა ნიმუშის გაგზავნიდან ტესტირებამდე' WHERE idfsBaseReference = 10080456 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Test - Nümunə göndərildiyi tarixdən testin aparılma tarixinədək keçən günlərin sayı' WHERE idfsBaseReference = 10080456 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - الأيام المتبقية  للاختبار منذ ارسال العينة ' WHERE idfsBaseReference = 10080456 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Test - Disease' WHERE idfsBaseReference = 10080279 -- old value 'Human Case Test - Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Test - Disease' WHERE idfsBaseReference = 10080279 AND idfsLanguage = 10049003 -- old value 'Human Case Test - Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ტესტი - დაავადება' WHERE idfsBaseReference = 10080279 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Test - Xəstəlik' WHERE idfsBaseReference = 10080279 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - المرض ' WHERE idfsBaseReference = 10080279 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Test - Disease - Is Zoonotic' WHERE idfsBaseReference = 10080565 -- old value 'Human Case Test - Diagnosis - Is Zoonotic'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Test - Disease - Is Zoonotic' WHERE idfsBaseReference = 10080565 AND idfsLanguage = 10049003 -- old value 'Human Case Test - Diagnosis - Is Zoonotic'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ტესტი - დაავადება - არის ზოონოზური' WHERE idfsBaseReference = 10080565 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Test - Xəstəlik - Zoonoz' WHERE idfsBaseReference = 10080565 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - المرض - حيوانيّ المصدر ' WHERE idfsBaseReference = 10080565 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Test - Is Entered by Laboratory' WHERE idfsBaseReference = 10080793 -- old value 'Human Case Test - Is Entered by Laboratory'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Test - Is Entered by Laboratory' WHERE idfsBaseReference = 10080793 AND idfsLanguage = 10049003 -- old value 'Human Case Test - Is Entered by Laboratory'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080793 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ტესტი - შეყვანილია ლაბორატორიის მიერ' WHERE idfsBaseReference = 10080793 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ადამიანის დაავადების ანგარიშის ტესტი - შეყვანილია ლაბორატორიის მიერ', 10080793, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080793 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Test - Laboratoriya tərəfindən daxil edildi' WHERE idfsBaseReference = 10080793 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'İnsan Xəstəliyi üzrə Hesabat Test - Laboratoriya tərəfindən daxil edildi', 10080793, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080793 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - يتم ادخاله في المختبر ' WHERE idfsBaseReference = 10080793 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'اختبار  تقرير الامراض البشرية - يتم ادخاله في المختبر ', 10080793, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Test - Lab Sample ID' WHERE idfsBaseReference = 10080102 -- old value 'Human Case Test - Lab Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Test - Lab Sample ID' WHERE idfsBaseReference = 10080102 AND idfsLanguage = 10049003 -- old value 'Human Case Test - Lab Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ტესტი - ლაბორატორიული ნიმუშის ID' WHERE idfsBaseReference = 10080102 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Test - Laborator nümunənin Q/N-si' WHERE idfsBaseReference = 10080102 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - معرّف للعينة المخبرية' WHERE idfsBaseReference = 10080102 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Test - Local Sample ID' WHERE idfsBaseReference = 10080104 -- old value 'Human Case Test - Local Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Test - Local Sample ID' WHERE idfsBaseReference = 10080104 AND idfsLanguage = 10049003 -- old value 'Human Case Test - Local Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ტესტი -  ადგილობრივი ნიმუშის ID' WHERE idfsBaseReference = 10080104 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Test - Nümunənin yerli Q/N-si' WHERE idfsBaseReference = 10080104 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - معرّف للعينة المحلية' WHERE idfsBaseReference = 10080104 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Test - Patient Name' WHERE idfsBaseReference = 10080278 -- old value 'Human Case Test - Patient Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Test - Patient Name' WHERE idfsBaseReference = 10080278 AND idfsLanguage = 10049003 -- old value 'Human Case Test - Patient Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ტესტი - პაციენტის სახელი' WHERE idfsBaseReference = 10080278 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Test - Xəstənin adı' WHERE idfsBaseReference = 10080278 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - اسم المريض' WHERE idfsBaseReference = 10080278 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Test - Result Date' WHERE idfsBaseReference = 10080280 -- old value 'Human Case Test - Result Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Test - Result Date' WHERE idfsBaseReference = 10080280 AND idfsLanguage = 10049003 -- old value 'Human Case Test - Result Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ტესტი - შედეგის თარიღი' WHERE idfsBaseReference = 10080280 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Test - Nəticənin tarixi' WHERE idfsBaseReference = 10080280 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - تاريخ النتيجة' WHERE idfsBaseReference = 10080280 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Test - Sample Type' WHERE idfsBaseReference = 10080123 -- old value 'Human Case Test - Sample Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Test - Sample Type' WHERE idfsBaseReference = 10080123 AND idfsLanguage = 10049003 -- old value 'Human Case Test - Sample Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ტესტი - ნიმუშის ტიპი' WHERE idfsBaseReference = 10080123 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Test - Nümunənin növü' WHERE idfsBaseReference = 10080123 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - نوع العينة' WHERE idfsBaseReference = 10080123 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Test - Test Category' WHERE idfsBaseReference = 10080510 -- old value 'Human Case Test - Test Category'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Test - Test Category' WHERE idfsBaseReference = 10080510 AND idfsLanguage = 10049003 -- old value 'Human Case Test - Test Category'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ტესტი - ტესტის კატეგორია' WHERE idfsBaseReference = 10080510 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Test - Testin kateqoriyası' WHERE idfsBaseReference = 10080510 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - فئة الاختبار' WHERE idfsBaseReference = 10080510 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Test - Test Name' WHERE idfsBaseReference = 10080132 -- old value 'Human Case Test - Test Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Test - Test Name' WHERE idfsBaseReference = 10080132 AND idfsLanguage = 10049003 -- old value 'Human Case Test - Test Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ტესტი - ტესტის დასახელება' WHERE idfsBaseReference = 10080132 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Test - Testin adı' WHERE idfsBaseReference = 10080132 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - اسم الاختبار ' WHERE idfsBaseReference = 10080132 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Test - Test Result' WHERE idfsBaseReference = 10080134 -- old value 'Human Case Test - Test Result'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Test - Test Result' WHERE idfsBaseReference = 10080134 AND idfsLanguage = 10049003 -- old value 'Human Case Test - Test Result'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ტესტი - ტესტის შედეგი' WHERE idfsBaseReference = 10080134 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Test - Testin nəticəsi' WHERE idfsBaseReference = 10080134 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - نتيجة الاختبار ' WHERE idfsBaseReference = 10080134 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Test - Test Run ID' WHERE idfsBaseReference = 10080135 -- old value 'Human Case Test - Test Run ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Test - Test Run ID' WHERE idfsBaseReference = 10080135 AND idfsLanguage = 10049003 -- old value 'Human Case Test - Test Run ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ტესტი - ტესტის ჩატარების ID' WHERE idfsBaseReference = 10080135 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Test - Testin icra edilmə Q/N-si' WHERE idfsBaseReference = 10080135 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية -  معرّف تشغيل الاختبار' WHERE idfsBaseReference = 10080135 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report Test - Test Status' WHERE idfsBaseReference = 10080136 -- old value 'Human Case Test - Test Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report Test - Test Status' WHERE idfsBaseReference = 10080136 AND idfsLanguage = 10049003 -- old value 'Human Case Test - Test Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიშის ტესტი - ტესტის სტატუსი' WHERE idfsBaseReference = 10080136 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat Test - Testin statusu' WHERE idfsBaseReference = 10080136 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - حالة الاختبار' WHERE idfsBaseReference = 10080136 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Pool/Vector - Location - Settlement' WHERE idfsBaseReference = 10080354 -- old value 'Pool/Vector - Location - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Pool/Vector - Location - Settlement' WHERE idfsBaseReference = 10080354 AND idfsLanguage = 10049003 -- old value 'Pool/Vector - Location - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'პული/ვექტორი - ადგილმდებარეობა - დასახლება' WHERE idfsBaseReference = 10080354 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Hövzə/Keçirici - Yer - Yaşayış məntəqəsi' WHERE idfsBaseReference = 10080354 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تجميعة / ناقِل - الموقع - الاقامة ' WHERE idfsBaseReference = 10080354 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vector Summary Info - Settlement' WHERE idfsBaseReference = 10080608 -- old value 'Vector Summary Info - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vector Summary Info - Settlement' WHERE idfsBaseReference = 10080608 AND idfsLanguage = 10049003 -- old value 'Vector Summary Info - Town or Village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N' ვექტორის შემაჯამებელი ინფო - დასახლება' WHERE idfsBaseReference = 10080608 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Keçiricilərə dair ümumi məlumat - Yaşayış məntəqəsi' WHERE idfsBaseReference = 10080608 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ملخص معلومات الناقِل - التسوية ' WHERE idfsBaseReference = 10080608 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Animal - Age' WHERE idfsBaseReference = 10080009 AND idfsLanguage = 10049003 -- old value 'Vet Case - Animal - Age'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ცხოველი - ასაკი' WHERE idfsBaseReference = 10080009 AND idfsLanguage = 10049004 -- old value 'Vet Case - Animal - Age'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Heyvan - Yaşı' WHERE idfsBaseReference = 10080009 AND idfsLanguage = 10049001 -- old value 'Vet Case - Animal - Age'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - الحيوان - العمر ' WHERE idfsBaseReference = 10080009 AND idfsLanguage = 10049011 -- old value 'Vet Case - Animal - Age'

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Animal - Animal ID' WHERE idfsBaseReference = 10080010 AND idfsLanguage = 10049003 -- old value 'Vet Case - Animal - Animal ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ცხოველი - ცხოველის ID' WHERE idfsBaseReference = 10080010 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Heyvan - Heyvanın Q/N-si' WHERE idfsBaseReference = 10080010 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - الحيوان - الرقم التعريفي للحيوان ' WHERE idfsBaseReference = 10080010 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Animal - Herd ID' WHERE idfsBaseReference = 10080012 AND idfsLanguage = 10049003 -- old value 'Vet Case - Animal - Herd ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ცხოველი - ჯოგის  ID ' WHERE idfsBaseReference = 10080012 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Heyvan - Sürünün Q/N-si' WHERE idfsBaseReference = 10080012 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  الحيوان - معرّف القطيع ' WHERE idfsBaseReference = 10080012 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Animal - Sex' WHERE idfsBaseReference = 10080013 AND idfsLanguage = 10049003 -- old value 'Vet Case - Animal - Sex'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ცხოველი - სქესი ' WHERE idfsBaseReference = 10080013 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Heyvan - Cinsiyyəti' WHERE idfsBaseReference = 10080013 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - الحيوان - الجنس' WHERE idfsBaseReference = 10080013 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Animal - Species' WHERE idfsBaseReference = 10080014 AND idfsLanguage = 10049003 -- old value 'Vet Case - Animal - Species'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ცხოველი - სახეობები' WHERE idfsBaseReference = 10080014 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Heyvan - Heyvan növü' WHERE idfsBaseReference = 10080014 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - الحيوان - الانواع ' WHERE idfsBaseReference = 10080014 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Animal - Status' WHERE idfsBaseReference = 10080015 AND idfsLanguage = 10049003 -- old value 'Vet Case - Animal - Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ცხოველი - სტატუსი' WHERE idfsBaseReference = 10080015 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Heyvan - Vəziyyəti' WHERE idfsBaseReference = 10080015 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - الحيوان -الحالة' WHERE idfsBaseReference = 10080015 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Herd - Farm ID' WHERE idfsBaseReference = 10080240 AND idfsLanguage = 10049003 -- old value 'Vet Case - Herd - Farm ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ჯოგი - ფერმის ID' WHERE idfsBaseReference = 10080240 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Sürü - Fermanın Q/N-si' WHERE idfsBaseReference = 10080240 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - القطيع - معرّف المزرعة ' WHERE idfsBaseReference = 10080240 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Herd - Herd ID' WHERE idfsBaseReference = 10080094 AND idfsLanguage = 10049003 -- old value 'Vet Case - Herd - Herd ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ჯოგი - ჯოგის  ID' WHERE idfsBaseReference = 10080094 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Sürü - Sürünün Q/N-si' WHERE idfsBaseReference = 10080094 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - القطيع - معرّف القطيع ' WHERE idfsBaseReference = 10080094 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Herd - Number Of Dead Animals' WHERE idfsBaseReference = 10080093 AND idfsLanguage = 10049003 -- old value 'Vet Case - Herd - Number Of Dead Animals'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ჯოგი - დაცემულ ცხოველთა რაოდენობა' WHERE idfsBaseReference = 10080093 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Sürü - Ölmüş heyvanların sayı' WHERE idfsBaseReference = 10080093 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - القطيع - عدد الوفيات للحيوانات ' WHERE idfsBaseReference = 10080093 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Herd - Number Of Sick Animals' WHERE idfsBaseReference = 10080096 AND idfsLanguage = 10049003 -- old value 'Vet Case - Herd - Number Of Sick Animals'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ჯოგი - დაავადებულ ცხოველთა რაოდენობა' WHERE idfsBaseReference = 10080096 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Sürü - Xəstə heyvanların sayı' WHERE idfsBaseReference = 10080096 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - القطيع -  عدد الحيوانات المصابة بمرض' WHERE idfsBaseReference = 10080096 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Herd - Total Number Of Animals' WHERE idfsBaseReference = 10080097 AND idfsLanguage = 10049003 -- old value 'Vet Case - Herd - Total Number Of Animals'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ჯოგი - ცხოველების საერთო რაოდეობა' WHERE idfsBaseReference = 10080097 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Sürü - Heyvanların ümumi sayı' WHERE idfsBaseReference = 10080097 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - القطيع - العدد الاجمالي الحيوانات ' WHERE idfsBaseReference = 10080097 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Penside Test - Animal ID' WHERE idfsBaseReference = 10080193 AND idfsLanguage = 10049003 -- old value 'Vet Case - Penside Test - Animal ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  საველე ტესტი - ცხოველის ID' WHERE idfsBaseReference = 10080193 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Təcili test - Heyvanın Q/N-si' WHERE idfsBaseReference = 10080193 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  اختبار المستضد -  الرقم التعريفي للحيوان ' WHERE idfsBaseReference = 10080193 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Penside Test - Field Sample ID' WHERE idfsBaseReference = 10080195 AND idfsLanguage = 10049003 -- old value 'Vet Case - Penside Test - Field Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  საველე ტესტი - საველე ნიმუშის ID' WHERE idfsBaseReference = 10080195 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Təcili test - Nümunənin sahədəki Q/N-si' WHERE idfsBaseReference = 10080195 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  اختبار المستضد -  عينة لمعرّف الحقل ' WHERE idfsBaseReference = 10080195 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Penside Test - Sample Type' WHERE idfsBaseReference = 10080197 AND idfsLanguage = 10049003 -- old value 'Vet Case - Penside Test - Sample Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  საველე ტესტი - ნიმუშის ტიპი' WHERE idfsBaseReference = 10080197 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Təcili test - Nümunə növü' WHERE idfsBaseReference = 10080197 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - اختبار المستضد - نوع العينة ' WHERE idfsBaseReference = 10080197 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Penside Test - Species' WHERE idfsBaseReference = 10080198 AND idfsLanguage = 10049003 -- old value 'Vet Case - Penside Test - Species'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  საველე ტესტი - სახეობები' WHERE idfsBaseReference = 10080198 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Təcili test - Heyvan növü' WHERE idfsBaseReference = 10080198 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - اختبار المستضد - أنواع الحيوانات' WHERE idfsBaseReference = 10080198 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Penside Test - Test Name' WHERE idfsBaseReference = 10080199 AND idfsLanguage = 10049003 -- old value 'Vet Case - Penside Test - Test Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  საველე ტესტი - ტესტის დასახელება' WHERE idfsBaseReference = 10080199 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Təcili test - Testin adı' WHERE idfsBaseReference = 10080199 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - اختبار المستضد - اسم الاختبار ' WHERE idfsBaseReference = 10080199 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Penside Test - Test Result' WHERE idfsBaseReference = 10080196 AND idfsLanguage = 10049003 -- old value 'Vet Case - Penside Test - Test Result'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  საველე ტესტი - ტესტის შედეგი' WHERE idfsBaseReference = 10080196 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Təcili test - Testin nəticəsi' WHERE idfsBaseReference = 10080196 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - اختبار المستضد - نتيجة الاختبار ' WHERE idfsBaseReference = 10080196 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Species - Animal Species' WHERE idfsBaseReference = 10080130 AND idfsLanguage = 10049003 -- old value 'Vet Case - Species - Animal Species'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  სახეობა - ცხოველის სახეობები' WHERE idfsBaseReference = 10080130 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Növ - Heyvan növü' WHERE idfsBaseReference = 10080130 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  الانواع - أنواع الحيوانات ' WHERE idfsBaseReference = 10080130 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Species - Avg. Age (weeks)' WHERE idfsBaseReference = 10080124 AND idfsLanguage = 10049003 -- old value 'Vet Case - Species - Avg. Age (weeks)'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - სახეობა - საშუალო ასაკი (კვირა)' WHERE idfsBaseReference = 10080124 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Növ - Orta yaş (həftələr)' WHERE idfsBaseReference = 10080124 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  الانواع -  متوسط العمر ( أسابيع) ' WHERE idfsBaseReference = 10080124 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Species - Herd ID' WHERE idfsBaseReference = 10080128 AND idfsLanguage = 10049003 -- old value 'Vet Case - Species - Herd ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  სახეობა - ჯოგის ID' WHERE idfsBaseReference = 10080128 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Növ - Sürünün Q/N-si' WHERE idfsBaseReference = 10080128 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  الانواع -  معرّف القطيع ' WHERE idfsBaseReference = 10080128 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Species - Note (include breed)' WHERE idfsBaseReference = 10080127 AND idfsLanguage = 10049003 -- old value 'Vet Case - Species - Note (include breed)'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  სახეობა - შენიშვნა (მომრავლების ჩათვლით)' WHERE idfsBaseReference = 10080127 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Növ - Qeyd (cinsi daxil edərək)' WHERE idfsBaseReference = 10080127 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  الانواع -  ملاحظة ( مع شمل السلالة ) ' WHERE idfsBaseReference = 10080127 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Species - Number of Dead Animals' WHERE idfsBaseReference = 10080126 AND idfsLanguage = 10049003 -- old value 'Vet Case - Species - Number of Dead Animals'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  სახეობა - დაცემულ ცხოველთა რაოდენობა' WHERE idfsBaseReference = 10080126 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Növ - Ölmüş heyvanların sayı' WHERE idfsBaseReference = 10080126 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  الانواع - عدد الوفيات للحيوانات ' WHERE idfsBaseReference = 10080126 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Species - Number of Sick Animals' WHERE idfsBaseReference = 10080129 AND idfsLanguage = 10049003 -- old value 'Vet Case - Species - Number of Sick Animals'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  სახეობა - დაავადებულ ცხოველთა რაოდენობა' WHERE idfsBaseReference = 10080129 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Növ - Xəstə heyvanların sayı' WHERE idfsBaseReference = 10080129 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  الانواع -  عدد الحيوانات المصابة بمرض ' WHERE idfsBaseReference = 10080129 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Species - Start of Signs' WHERE idfsBaseReference = 10080241 AND idfsLanguage = 10049003 -- old value 'Vet Case - Species - Start of Signs'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  სახეობა - სიმპტომების დაწყება' WHERE idfsBaseReference = 10080241 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Növ - Xəstəlik əlamətlərinin başlanma tarixi' WHERE idfsBaseReference = 10080241 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  الانواع -  بدء ظهور العلامات ' WHERE idfsBaseReference = 10080241 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Species - Total Number of Animals' WHERE idfsBaseReference = 10080131 AND idfsLanguage = 10049003 -- old value 'Vet Case - Species - Total Number of Animals'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - სახეობა - ცხოველების საერთო რაოდენობა' WHERE idfsBaseReference = 10080131 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Növ - Heyvanların ümumi sayı' WHERE idfsBaseReference = 10080131 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  الانواع - العدد الاجمالي للحيوانات ' WHERE idfsBaseReference = 10080131 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Vaccination - Comments' WHERE idfsBaseReference = 10080142 AND idfsLanguage = 10049003 -- old value 'Vet Case - Vaccination - Comments'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  ვაქცინაცია - კომენტარები' WHERE idfsBaseReference = 10080142 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Peyvəndləmə - Qeydlər' WHERE idfsBaseReference = 10080142 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - التطعيم - التعليقات ' WHERE idfsBaseReference = 10080142 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Vaccination - Date' WHERE idfsBaseReference = 10080138 AND idfsLanguage = 10049003 -- old value 'Vet Case - Vaccination - Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  ვაქცინაცია - თარიღი' WHERE idfsBaseReference = 10080138 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Peyvəndləmə - Tarix' WHERE idfsBaseReference = 10080138 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - التطعيم - التاريخ' WHERE idfsBaseReference = 10080138 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Vaccination - Disease' WHERE idfsBaseReference = 10080139 AND idfsLanguage = 10049003 -- old value 'Vet Case - Vaccination - Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  ვაქცინაცია - დაავადება' WHERE idfsBaseReference = 10080139 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Peyvəndləmə - Xəstəlik' WHERE idfsBaseReference = 10080139 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - التطعيم - المرض' WHERE idfsBaseReference = 10080139 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Vaccination - Disease - Is Zoonotic' WHERE idfsBaseReference = 10080567 AND idfsLanguage = 10049003 -- old value 'Vet Case - Vaccination - Diagnosis - Is Zoonotic'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  ვაქცინაცია - დაავადება - არის ზოონოზური' WHERE idfsBaseReference = 10080567 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Peyvəndləmə - Xəstəlik - Zoonozdur' WHERE idfsBaseReference = 10080567 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - التطعيم - المرض - حيوانيّ المصدر ' WHERE idfsBaseReference = 10080567 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Vaccination - Lot Number' WHERE idfsBaseReference = 10080143 AND idfsLanguage = 10049003 -- old value 'Vet Case - Vaccination - Lot Number'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  ვაქცინაცია - პარტიის ნომერი' WHERE idfsBaseReference = 10080143 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Peyvəndləmə - Seriya nömrəsi' WHERE idfsBaseReference = 10080143 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - التطعيم - رقم المجموعة ' WHERE idfsBaseReference = 10080143 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Vaccination - Manufacturer' WHERE idfsBaseReference = 10080144 AND idfsLanguage = 10049003 -- old value 'Vet Case - Vaccination - Manufacturer'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  ვაქცინაცია - მწარმოებელი' WHERE idfsBaseReference = 10080144 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Peyvəndləmə - İstehsalçı' WHERE idfsBaseReference = 10080144 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - التطعيم - الشركة المصنعة ' WHERE idfsBaseReference = 10080144 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Vaccination - Route' WHERE idfsBaseReference = 10080145 AND idfsLanguage = 10049003 -- old value 'Vet Case - Vaccination - Route'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  ვაქცინაცია - ხერხი' WHERE idfsBaseReference = 10080145 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Peyvəndləmə - Peyvəndləmənin üsulu' WHERE idfsBaseReference = 10080145 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - التطعيم - طريقة التطعيم ' WHERE idfsBaseReference = 10080145 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Vaccination - Species' WHERE idfsBaseReference = 10080141 AND idfsLanguage = 10049003 -- old value 'Vet Case - Vaccination - Species'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  ვაქცინაცია - სახეობა' WHERE idfsBaseReference = 10080141 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Peyvəndləmə - Heyvan növü' WHERE idfsBaseReference = 10080141 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - التطعيم - أنواع الحيوانات' WHERE idfsBaseReference = 10080141 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Vaccination - Type' WHERE idfsBaseReference = 10080146 AND idfsLanguage = 10049003 -- old value 'Vet Case - Vaccination - Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  ვაქცინაცია - ტიპი' WHERE idfsBaseReference = 10080146 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Peyvəndləmə - Növü' WHERE idfsBaseReference = 10080146 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - التطعيم - النوع ' WHERE idfsBaseReference = 10080146 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Vaccination - Vaccinated Number' WHERE idfsBaseReference = 10080140 AND idfsLanguage = 10049003 -- old value 'Vet Case - Vaccination - Vaccinated Number'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  ვაქცინაცია - ვაქცინირებულთა რაოდენობა' WHERE idfsBaseReference = 10080140 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Peyvəndləmə - Peyvənd olunmuşların sayı' WHERE idfsBaseReference = 10080140 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - التطعيم - عدد اللقلحات' WHERE idfsBaseReference = 10080140 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Assigned Date' WHERE idfsBaseReference = 10080147 -- old value 'Vet Case - Assigned Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Assigned Date' WHERE idfsBaseReference = 10080147 AND idfsLanguage = 10049003 -- old value 'Vet Case - Assigned Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  დანიშვნის თარიღი' WHERE idfsBaseReference = 10080147 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Təyin edilmə tarixi' WHERE idfsBaseReference = 10080147 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - تاريخ الانضمام ' WHERE idfsBaseReference = 10080147 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Avian Farm Type' WHERE idfsBaseReference = 10080159 -- old value 'Vet Case - Avian Farm Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Avian Farm Type' WHERE idfsBaseReference = 10080159 AND idfsLanguage = 10049003 -- old value 'Vet Case - Avian Farm Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  ფრინველის ფერმის ტიპი' WHERE idfsBaseReference = 10080159 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Quş fermasının növü' WHERE idfsBaseReference = 10080159 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - نوع مزرعة الطيور ' WHERE idfsBaseReference = 10080159 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Disease Report Classification' WHERE idfsBaseReference = 10080149 -- old value 'Vet Case - Case Classification'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Disease Report Classification' WHERE idfsBaseReference = 10080149 AND idfsLanguage = 10049003 -- old value 'Vet Case - Case Classification'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  დაავადების ანგარიშის კლასიფიკაცია' WHERE idfsBaseReference = 10080149 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Xəstəlik hesabatının təsnifatı' WHERE idfsBaseReference = 10080149 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  تصنيف تقرير المرض ' WHERE idfsBaseReference = 10080149 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Disease Report ID' WHERE idfsBaseReference = 10080148 -- old value 'Vet Case - Case ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Disease Report ID' WHERE idfsBaseReference = 10080148 AND idfsLanguage = 10049003 -- old value 'Vet Case - Case ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  დაავადების ანგარიშის ID' WHERE idfsBaseReference = 10080148 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Xəstəlik hesabatının Q/N-si' WHERE idfsBaseReference = 10080148 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - معرّف تقرير المرض ' WHERE idfsBaseReference = 10080148 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Disease Report Status' WHERE idfsBaseReference = 10080236 -- old value 'Vet Case - Case Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Disease Report Status' WHERE idfsBaseReference = 10080236 AND idfsLanguage = 10049003 -- old value 'Vet Case - Case Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  დაავადების ანგარიშის სტატუსი' WHERE idfsBaseReference = 10080236 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Xəstəlik hesabatının statusu' WHERE idfsBaseReference = 10080236 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  حالة تقرير المرض ' WHERE idfsBaseReference = 10080236 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Disease Report Type' WHERE idfsBaseReference = 10080150 -- old value 'Vet Case - Case Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Disease Report Type' WHERE idfsBaseReference = 10080150 AND idfsLanguage = 10049003 -- old value 'Vet Case - Case Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  დაავადების ანგარიშის ტიპი' WHERE idfsBaseReference = 10080150 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Xəstəlik hesabatının növü' WHERE idfsBaseReference = 10080150 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  نوع تقرير المرض ' WHERE idfsBaseReference = 10080150 AND idfsLanguage = 10049011

UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Days After Reporting until Entered in the system' WHERE idfsBaseReference = 10080153 AND idfsLanguage = 10049003 -- old value 'Vet Case - Days After Reporting until Entered in the system'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  დღეების რაოდენობა ანგირიშგებიდან სისტემაში შეყვანამდე' WHERE idfsBaseReference = 10080153 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Hesabat verildiyi tarixdən Sistemə daxil edildiyi tarixədək keçən günlərin sayı' WHERE idfsBaseReference = 10080153 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  الايام التي انقضت  بعد الابلاغ  حتى أيام الدخول في النظام ' WHERE idfsBaseReference = 10080153 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Diseases Group' WHERE idfsBaseReference = 10080578 -- old value 'Vet Case - Diagnoses Group'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Diseases Group' WHERE idfsBaseReference = 10080578 AND idfsLanguage = 10049003 -- old value 'Vet Case - Diagnoses Group'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  დაავადებების ჯგუფი' WHERE idfsBaseReference = 10080578 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Xəstəliklər qrupu' WHERE idfsBaseReference = 10080578 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  مجموعة الامراض' WHERE idfsBaseReference = 10080578 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Disease' WHERE idfsBaseReference = 10080300 -- old value 'Vet Case - Diagnosis'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Disease' WHERE idfsBaseReference = 10080300 AND idfsLanguage = 10049003 -- old value 'Vet Case - Diagnosis'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - დაავადება' WHERE idfsBaseReference = 10080300 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Xəstəlik' WHERE idfsBaseReference = 10080300 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  المرض ' WHERE idfsBaseReference = 10080300 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Disease - Is Zoonotic' WHERE idfsBaseReference = 10080570 -- old value 'Vet Case - Diagnosis - Is Zoonotic'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Disease - Is Zoonotic' WHERE idfsBaseReference = 10080570 AND idfsLanguage = 10049003 -- old value 'Vet Case - Diagnosis - Is Zoonotic'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - დაავადება - არის ზოონოზური' WHERE idfsBaseReference = 10080570 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Xəstəlik - Zoonozdur' WHERE idfsBaseReference = 10080570 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - المرض - حيوانيّ المصدر ' WHERE idfsBaseReference = 10080570 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Entered By Officer' WHERE idfsBaseReference = 10080180 -- old value 'Vet Case - Entered By Officer'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Entered By Officer' WHERE idfsBaseReference = 10080180 AND idfsLanguage = 10049003 -- old value 'Vet Case - Entered By Officer'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - შეყვანილია  თანამშრომლის მიერ' WHERE idfsBaseReference = 10080180 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Daxil edən işçi' WHERE idfsBaseReference = 10080180 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  أدخلها الموظف ' WHERE idfsBaseReference = 10080180 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Entered by Site' WHERE idfsBaseReference = 10080192 -- old value 'Vet Case - Entered by Site'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Entered by Site' WHERE idfsBaseReference = 10080192 AND idfsLanguage = 10049003 -- old value 'Vet Case - Entered by Site'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - საიტი, საიდანაც მოხდა  შეყვანა' WHERE idfsBaseReference = 10080192 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Daxil edən sayt' WHERE idfsBaseReference = 10080192 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - أدخلها الموقع ' WHERE idfsBaseReference = 10080192 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Entered Date' WHERE idfsBaseReference = 10080152 -- old value 'Vet Case - Entered Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Entered Date' WHERE idfsBaseReference = 10080152 AND idfsLanguage = 10049003 -- old value 'Vet Case - Entered Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - შეყვანის თარიღი' WHERE idfsBaseReference = 10080152 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Daxil etmə tarixi' WHERE idfsBaseReference = 10080152 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  تاريخ الدخول ' WHERE idfsBaseReference = 10080152 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Farm Address - Coordinates' WHERE idfsBaseReference = 10080237 -- old value 'Vet Case - Farm Address - Coordinates'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Farm Address - Coordinates' WHERE idfsBaseReference = 10080237 AND idfsLanguage = 10049003 -- old value 'Vet Case - Farm Address - Coordinates'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ფერმის მისამართი - კოორდინატები' WHERE idfsBaseReference = 10080237 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Fermanın ünvanı - Koordinatlar' WHERE idfsBaseReference = 10080237 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - عنوان المزرعة - الاحداثيات ' WHERE idfsBaseReference = 10080237 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Farm Address - Country' WHERE idfsBaseReference = 10080151 -- old value 'Vet Case - Farm Address - Country'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Farm Address - Country' WHERE idfsBaseReference = 10080151 AND idfsLanguage = 10049003 -- old value 'Vet Case - Farm Address - Country'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ფერმის მისამართი - ქვეყანა' WHERE idfsBaseReference = 10080151 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Fermanın ünvanı - Ölkə' WHERE idfsBaseReference = 10080151 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  عنوان المزرعة - البلد ' WHERE idfsBaseReference = 10080151 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Farm Address - Elevation (m)' WHERE idfsBaseReference = 10080597 -- old value 'Vet Case - Farm Address - Elevation (m)'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Farm Address - Elevation (m)' WHERE idfsBaseReference = 10080597 AND idfsLanguage = 10049003 -- old value 'Vet Case - Farm Address - Elevation (m)'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ფერმის მისამართი - ელევაცია (მ)' WHERE idfsBaseReference = 10080597 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Fermanın ünvanı - Hündürlük (m)' WHERE idfsBaseReference = 10080597 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  عنوان المزرعة - الارتفاع (م)' WHERE idfsBaseReference = 10080597 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Farm Address - Latitude' WHERE idfsBaseReference = 10080519 -- old value 'Vet Case - Farm Address - Latitude'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Farm Address - Latitude' WHERE idfsBaseReference = 10080519 AND idfsLanguage = 10049003 -- old value 'Vet Case - Farm Address - Latitude'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ფერმის მისამართი - განედი' WHERE idfsBaseReference = 10080519 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Fermanın ünvanı - En dairəsi' WHERE idfsBaseReference = 10080519 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  عنوان المزرعة - خط العرض ' WHERE idfsBaseReference = 10080519 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Farm Address - Longitude' WHERE idfsBaseReference = 10080518 -- old value 'Vet Case - Farm Address - Longitude'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Farm Address - Longitude' WHERE idfsBaseReference = 10080518 AND idfsLanguage = 10049003 -- old value 'Vet Case - Farm Address - Longitude'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ფერმის მისამართი - გრძედი' WHERE idfsBaseReference = 10080518 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Fermanın ünvanı - Uzunluq dairəsi' WHERE idfsBaseReference = 10080518 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  عنوان المزرعة -خط الطول ' WHERE idfsBaseReference = 10080518 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Farm Address - Rayon' WHERE idfsBaseReference = 10080186 -- old value 'Vet Case - Farm Address - Rayon'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Farm Address - Rayon' WHERE idfsBaseReference = 10080186 AND idfsLanguage = 10049003 -- old value 'Vet Case - Farm Address - Rayon'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ფერმის მისამართი - რაიონი' WHERE idfsBaseReference = 10080186 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Fermanın ünvanı - Rayon' WHERE idfsBaseReference = 10080186 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  عنوان المزرعة - رايون ' WHERE idfsBaseReference = 10080186 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Farm Address - Region' WHERE idfsBaseReference = 10080188 -- old value 'Vet Case - Farm Address - Region'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Farm Address - Region' WHERE idfsBaseReference = 10080188 AND idfsLanguage = 10049003 -- old value 'Vet Case - Farm Address - Region'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ფერმის მისამართი - რეგიონი' WHERE idfsBaseReference = 10080188 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Fermanın ünvanı - Region' WHERE idfsBaseReference = 10080188 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  عنوان المزرعة - المنطقة ' WHERE idfsBaseReference = 10080188 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Farm Address - Settlement' WHERE idfsBaseReference = 10080191 -- old value 'Vet Case - Farm Address - Town or village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Farm Address - Settlement' WHERE idfsBaseReference = 10080191 AND idfsLanguage = 10049003 -- old value 'Vet Case - Farm Address - Town or village'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ფერმის მისამართი - დასახლება' WHERE idfsBaseReference = 10080191 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Fermanın ünvanı - Yaşayış məntəqəsi' WHERE idfsBaseReference = 10080191 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  عنوان المزرعة - الاقامة ' WHERE idfsBaseReference = 10080191 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Farm E-Mail' WHERE idfsBaseReference = 10080154 -- old value 'Vet Case - Farm E-Mail'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Farm E-Mail' WHERE idfsBaseReference = 10080154 AND idfsLanguage = 10049003 -- old value 'Vet Case - Farm E-Mail'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში -  ფერმის ელექტრონული ფოსტა' WHERE idfsBaseReference = 10080154 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Fermanın elektron poçt ünvanı' WHERE idfsBaseReference = 10080154 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  البريد الالكتروني للمزرعة ' WHERE idfsBaseReference = 10080154 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Farm Fax' WHERE idfsBaseReference = 10080160 -- old value 'Vet Case - Farm Fax
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Farm Fax' WHERE idfsBaseReference = 10080160 AND idfsLanguage = 10049003 -- old value 'Vet Case - Farm Fax'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ფერმის ფაქსი' WHERE idfsBaseReference = 10080160 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Fermanın faks nömrəsi' WHERE idfsBaseReference = 10080160 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - فاكس المزرعة ' WHERE idfsBaseReference = 10080160 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Farm ID' WHERE idfsBaseReference = 10080155 -- old value 'Vet Case - Farm ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Farm ID' WHERE idfsBaseReference = 10080155 AND idfsLanguage = 10049003 -- old value 'Vet Case - Farm ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ფერმის ID' WHERE idfsBaseReference = 10080155 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Fermanın Q/N-si' WHERE idfsBaseReference = 10080155 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - معرّف المزرعة ' WHERE idfsBaseReference = 10080155 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Farm Name' WHERE idfsBaseReference = 10080156 -- old value 'Vet Case - Farm Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Farm Name' WHERE idfsBaseReference = 10080156 AND idfsLanguage = 10049003 -- old value 'Vet Case - Farm Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ფერმის დასახელება' WHERE idfsBaseReference = 10080156 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Fermanın adı' WHERE idfsBaseReference = 10080156 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - اسم المزرعة ' WHERE idfsBaseReference = 10080156 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Farm Owner' WHERE idfsBaseReference = 10080157 -- old value 'Vet Case - Farm Owner'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Farm Owner' WHERE idfsBaseReference = 10080157 AND idfsLanguage = 10049003 -- old value 'Vet Case - Farm Owner'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ფერმის მესაკუთრე' WHERE idfsBaseReference = 10080157 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Fermanın sahibi' WHERE idfsBaseReference = 10080157 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  مالك المزرعة ' WHERE idfsBaseReference = 10080157 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Farm Ownership Structure' WHERE idfsBaseReference = 10080183 -- old value 'Vet Case - Farm Ownership Structure'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Farm Ownership Structure' WHERE idfsBaseReference = 10080183 AND idfsLanguage = 10049003 -- old value 'Vet Case - Farm Ownership Structure'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ფერმის საკუთრების სტრუქტურა' WHERE idfsBaseReference = 10080183 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Fermanın mülkiyyət quruluşu' WHERE idfsBaseReference = 10080183 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  هيكل الملكية للمزرعة ' WHERE idfsBaseReference = 10080183 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Farm Phone' WHERE idfsBaseReference = 10080158 -- old value 'Vet Case - Farm Phone'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Farm Phone' WHERE idfsBaseReference = 10080158 AND idfsLanguage = 10049003 -- old value 'Vet Case - Farm Phone'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ფერმის ტელეფონი' WHERE idfsBaseReference = 10080158 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Fermanın telefon nömrəsi' WHERE idfsBaseReference = 10080158 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - الرقم الهاتفي للمزرعة ' WHERE idfsBaseReference = 10080158 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Field Accession ID' WHERE idfsBaseReference = 10080161 -- old value 'Vet Case - Field Accession ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Field Accession ID' WHERE idfsBaseReference = 10080161 AND idfsLanguage = 10049003 -- old value 'Vet Case - Field Accession ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - საველე მიღების ID' WHERE idfsBaseReference = 10080161 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Xəstəliyin məntəqədə qeyd alınma nömrəsi' WHERE idfsBaseReference = 10080161 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - معرّف انضمام المزرعة ' WHERE idfsBaseReference = 10080161 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Disease' WHERE idfsBaseReference = 10080162 -- old value 'Vet Case - Final Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Disease' WHERE idfsBaseReference = 10080162 AND idfsLanguage = 10049003 -- old value 'Vet Case - Final Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - დაავადება' WHERE idfsBaseReference = 10080162 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Xəstəlik' WHERE idfsBaseReference = 10080162 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - المرض  ' WHERE idfsBaseReference = 10080162 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Disease - Is Zoonotic' WHERE idfsBaseReference = 10080571 -- old value 'Vet Case - Final Diagnosis - Is Zoonotic'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Disease - Is Zoonotic' WHERE idfsBaseReference = 10080571 AND idfsLanguage = 10049003 -- old value 'Vet Case - Final Diagnosis - Is Zoonotic'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - დაავადება - არის ზოონოზური' WHERE idfsBaseReference = 10080571 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Xəstəlik - Zoonozdur' WHERE idfsBaseReference = 10080571 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - المرض - حيوانيّ المصدر ' WHERE idfsBaseReference = 10080571 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Disease Code' WHERE idfsBaseReference = 10080164 -- old value 'Vet Case - Final Diagnosis Code'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Disease Code' WHERE idfsBaseReference = 10080164 AND idfsLanguage = 10049003 -- old value 'Vet Case - Final Diagnosis Code'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - დაავადების კოდი' WHERE idfsBaseReference = 10080164 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Xəstəliyin kodu' WHERE idfsBaseReference = 10080164 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - رمز المرض ' WHERE idfsBaseReference = 10080164 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Disease Date' WHERE idfsBaseReference = 10080163 -- old value 'Vet Case - Final Diagnosis Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Disease Date' WHERE idfsBaseReference = 10080163 AND idfsLanguage = 10049003 -- old value 'Vet Case - Final Diagnosis Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - დაავადების თარიღი' WHERE idfsBaseReference = 10080163 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Xəstəliyin aşkar olunma tarixi' WHERE idfsBaseReference = 10080163 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - تاريخ المرض ' WHERE idfsBaseReference = 10080163 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Initial Report Date' WHERE idfsBaseReference = 10080175 -- old value 'Vet Case - Initial Report Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Initial Report Date' WHERE idfsBaseReference = 10080175 AND idfsLanguage = 10049003 -- old value 'Vet Case - Initial Report Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - თავდაპირველი ანგარიშის თარიღი' WHERE idfsBaseReference = 10080175 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - İlkin hesabat tarixi' WHERE idfsBaseReference = 10080175 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - تاريخ التقرير الأولي ' WHERE idfsBaseReference = 10080175 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Investigation Date' WHERE idfsBaseReference = 10080177 -- old value 'Vet Case - Investigation Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Investigation Date' WHERE idfsBaseReference = 10080177 AND idfsLanguage = 10049003 -- old value 'Vet Case - Investigation Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - გამოკვლევის თარიღი' WHERE idfsBaseReference = 10080177 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Tədqiqatın aparılma tarixi' WHERE idfsBaseReference = 10080177 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - تاريخ البحث' WHERE idfsBaseReference = 10080177 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Investigator Name' WHERE idfsBaseReference = 10080178 -- old value 'Vet Case - Investigator Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Investigator Name' WHERE idfsBaseReference = 10080178 AND idfsLanguage = 10049003 -- old value 'Vet Case - Investigator Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - მკვლევარის სახელი ' WHERE idfsBaseReference = 10080178 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Tədqiqatçının adı' WHERE idfsBaseReference = 10080178 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - اسم الباحث ' WHERE idfsBaseReference = 10080178 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Number of birds per farm barns/buildings' WHERE idfsBaseReference = 10080239 -- old value 'Vet Case - Number of birds per farm barns/buildings'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Number of birds per farm barns/buildings' WHERE idfsBaseReference = 10080239 AND idfsLanguage = 10049003 -- old value 'Vet Case - Number of birds per farm barns/buildings'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ფრინველის რაოდენობა ფერმის თითოეულ საქათმეში' WHERE idfsBaseReference = 10080239 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Hər tikilidə olan quşların sayı' WHERE idfsBaseReference = 10080239 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية -  عدد الطيور في كل مزرعة-  حظائر / مباني ' WHERE idfsBaseReference = 10080239 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Number of farm barns/buildings' WHERE idfsBaseReference = 10080238 -- old value 'Vet Case - Number of farm barns/buildings'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Number of farm barns/buildings' WHERE idfsBaseReference = 10080238 AND idfsLanguage = 10049003 -- old value 'Vet Case - Number of farm barns/buildings'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ფერმის საქათმეების რაოდენობა' WHERE idfsBaseReference = 10080238 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Tikililərin sayı' WHERE idfsBaseReference = 10080238 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - عدد الحظائر و المباني في المزرعة ' WHERE idfsBaseReference = 10080238 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080182 -- hide 'Vet Case - Outbreak ID'

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Report Type' WHERE idfsBaseReference = 10080425 -- old value 'Vet Case - Report Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Report Type' WHERE idfsBaseReference = 10080425 AND idfsLanguage = 10049003 -- old value 'Vet Case - Report Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ანგარიშის ტიპი' WHERE idfsBaseReference = 10080425 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Hesabat növü' WHERE idfsBaseReference = 10080425 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - نوع التقرير ' WHERE idfsBaseReference = 10080425 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report - Reported By Officer' WHERE idfsBaseReference = 10080190 -- old value 'Vet Case - Reported By Officer'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report - Reported By Officer' WHERE idfsBaseReference = 10080190 AND idfsLanguage = 10049003 -- old value 'Vet Case - Reported By Officer'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიში - ანგარიშგებულია თანამშრომლის მიერ' WHERE idfsBaseReference = 10080190 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı - Hesabatı verən işçi' WHERE idfsBaseReference = 10080190 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البيطرية - الموظف المُبلغ ' WHERE idfsBaseReference = 10080190 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080166 -- hide 'Vet Case - Tentative Diagnosis 1'
UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080572 -- hide 'Vet Case - Tentative Diagnosis 1 - Is Zoonotic'
UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080168 -- hide 'Vet Case - Tentative Diagnosis 1 Code'
UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080167 -- hide 'Vet Case - Tentative Diagnosis 1 Date'
UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080169 -- hide 'Vet Case - Tentative Diagnosis 2'
UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080573 -- hide 'Vet Case - Tentative Diagnosis 2 - Is Zoonotic'
UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080171 -- hide 'Vet Case - Tentative Diagnosis 2 Code'
UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080170 -- hide 'Vet Case - Tentative Diagnosis 2 Date'
UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080172 -- hide 'Vet Case - Tentative Diagnosis 3'
UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080574 -- hide 'Vet Case - Tentative Diagnosis 3 - Is Zoonotic'
UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080174 -- hide 'Vet Case - Tentative Diagnosis 3 Code'
UPDATE dbo.trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10080173 -- hide 'Vet Case - Tentative Diagnosis 3 Date'

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Accession Date' WHERE idfsBaseReference = 10080211 -- old value 'Vet Case Sample - Accession Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Accession Date' WHERE idfsBaseReference = 10080211 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Accession Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ნიმუში - მიღების თარიღი' WHERE idfsBaseReference = 10080211 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Qəbul edilmə tarixi' WHERE idfsBaseReference = 10080211 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - تاريخ الانضمام ' WHERE idfsBaseReference = 10080211 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Animal ID' WHERE idfsBaseReference = 10080200 -- old value 'Vet Case Sample - Animal ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Animal ID' WHERE idfsBaseReference = 10080200 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Animal ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - ცხოველის ID' WHERE idfsBaseReference = 10080200 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Heyvanın Q/N-si' WHERE idfsBaseReference = 10080200 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - الرقم التعريفي للحيوان ' WHERE idfsBaseReference = 10080200 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Disease Report ID' WHERE idfsBaseReference = 10080212 -- old value 'Vet Case Sample - Case ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Disease Report ID' WHERE idfsBaseReference = 10080212 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Case ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - დაავადების ანგარიშის  ID' WHERE idfsBaseReference = 10080212 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Xəstəlik hesabatının Q/N-si' WHERE idfsBaseReference = 10080212 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - معرّف تقرير المرض ' WHERE idfsBaseReference = 10080212 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Disease Report Type' WHERE idfsBaseReference = 10080202 -- old value 'Vet Case Sample - Case Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Disease Report Type' WHERE idfsBaseReference = 10080202 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Case Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - დაავადების ანგარიშის ტიპი' WHERE idfsBaseReference = 10080202 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Xəstəlik hesabatının növü' WHERE idfsBaseReference = 10080202 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - نوع معرّف تقرير المرض ' WHERE idfsBaseReference = 10080202 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Collected By Institution' WHERE idfsBaseReference = 10080208 -- old value 'Vet Case Sample - Collected By Institution'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Collected By Institution' WHERE idfsBaseReference = 10080208 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Collected By Institution'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის  ნიმუში -აღებულია დაწესებულების მიერ' WHERE idfsBaseReference = 10080208 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Toplayan müəssisə' WHERE idfsBaseReference = 10080208 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - جمعتها المؤسسة ' WHERE idfsBaseReference = 10080208 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Collection Date' WHERE idfsBaseReference = 10080204 -- old value 'Vet Case Sample - Collection Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Collection Date' WHERE idfsBaseReference = 10080204 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Collection Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - აღების თარიღი' WHERE idfsBaseReference = 10080204 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Toplama tarixi' WHERE idfsBaseReference = 10080204 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - تاريخ الجمع ' WHERE idfsBaseReference = 10080204 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Comment' WHERE idfsBaseReference = 10080213 -- old value 'Vet Case Sample - Comment'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Comment' WHERE idfsBaseReference = 10080213 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Comment'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - კომენტარი' WHERE idfsBaseReference = 10080213 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Qeyd' WHERE idfsBaseReference = 10080213 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - تعليق ' WHERE idfsBaseReference = 10080213 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Condition Received' WHERE idfsBaseReference = 10080263 -- old value 'Vet Case Sample - Condition Received'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Condition Received' WHERE idfsBaseReference = 10080263 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Condition Received'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - მდგომარეობა მიღებისას' WHERE idfsBaseReference = 10080263 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Qəbul zamanı nümunənin vəziyyəti' WHERE idfsBaseReference = 10080263 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - وضع الحالة عند الاستلام ' WHERE idfsBaseReference = 10080263 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Current Laboratory' WHERE idfsBaseReference = 10080746 -- old value 'Vet Case Sample - Current Laboratory'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Current Laboratory' WHERE idfsBaseReference = 10080746 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Current Laboratory'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080746 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - მოქმედი ლაბორატორია' WHERE idfsBaseReference = 10080746 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვეტერინარული დაავადების ანგარიშის ნიმუში - მოქმედი ლაბორატორია', 10080746, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080746 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Cari laboratoriya' WHERE idfsBaseReference = 10080746 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'XXX', 10080746, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080746 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - المختبر الحالي ' WHERE idfsBaseReference = 10080746 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للتقرير عن الامراض البيطرية - المختبر الحالي ', 10080746, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Days in Transit' WHERE idfsBaseReference = 10080206 -- old value 'Vet Case Sample - Days in Transit'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Days in Transit' WHERE idfsBaseReference = 10080206 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Days in Transit'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - დღეების რაოდენობა ტრანზიტში' WHERE idfsBaseReference = 10080206 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Daşınma vaxtı (günlər)' WHERE idfsBaseReference = 10080206 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - أيام العبور' WHERE idfsBaseReference = 10080206 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Destruction Method' WHERE idfsBaseReference = 10080552 -- old value 'Vet Case Sample - Destruction Method'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Destruction Method' WHERE idfsBaseReference = 10080552 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Destruction Method'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - დესტრუქციის მეთოდი' WHERE idfsBaseReference = 10080552 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Məhv edilmə üsulu' WHERE idfsBaseReference = 10080552 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - طريقة التدمير ' WHERE idfsBaseReference = 10080552 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Disease' WHERE idfsBaseReference = 10080262 -- old value 'Vet Case Sample - Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Disease' WHERE idfsBaseReference = 10080262 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - დაავადება' WHERE idfsBaseReference = 10080262 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Xəstəlik' WHERE idfsBaseReference = 10080262 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية -المرض ' WHERE idfsBaseReference = 10080262 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Disease - Is Zoonotic' WHERE idfsBaseReference = 10080575 -- old value 'Vet Case Sample - Diagnosis - Is Zoonotic'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Disease - Is Zoonotic' WHERE idfsBaseReference = 10080575 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Diagnosis - Is Zoonotic'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - დაავადება - არის ზოონოზური' WHERE idfsBaseReference = 10080575 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Xəstəlik - Zoonozdur' WHERE idfsBaseReference = 10080575 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - المرض - حيوانيّ المصدر ' WHERE idfsBaseReference = 10080575 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Farm Owner' WHERE idfsBaseReference = 10080261 -- old value 'Vet Case Sample - Farm Owner'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Farm Owner' WHERE idfsBaseReference = 10080261 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Farm Owner'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - ფერმის მესაკუთრე' WHERE idfsBaseReference = 10080261 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Fermanın sahibi' WHERE idfsBaseReference = 10080261 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - مالك المزرعة ' WHERE idfsBaseReference = 10080261 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Field Sample ID' WHERE idfsBaseReference = 10080207 -- old value 'Vet Case Sample - Field Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Field Sample ID' WHERE idfsBaseReference = 10080207 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Field Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - საველე ნიმუშის  ID' WHERE idfsBaseReference = 10080207 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Nümunənin sahədəki Q/N-si' WHERE idfsBaseReference = 10080207 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - عينة لمعرّف الحقل ' WHERE idfsBaseReference = 10080207 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Initially Collected Sample - Accession Date' WHERE idfsBaseReference = 10080744 -- old value 'Vet Case Sample - Initially Collected Sample - Accession Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Initially Collected Sample - Accession Date' WHERE idfsBaseReference = 10080744 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Initially Collected Sample - Accession Date'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080744 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - მიღების თარიღი' WHERE idfsBaseReference = 10080744 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვეტერინარული დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - მიღების თარიღი', 10080744, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080744 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - İlkin toplanılmış nümunə - Qəbul edilmə tarixi' WHERE idfsBaseReference = 10080744 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Xəstəliyi Hesabatı Nümunə - İlkin toplanılmış nümunə - Qəbul edilmə tarixi', 10080744, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080744 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية -  العينة الأولية المُجمعة' WHERE idfsBaseReference = 10080744 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للتقرير عن الامراض البيطرية -  العينة الأولية المُجمعة', 10080744, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Initially Collected Sample - Collected By Institution' WHERE idfsBaseReference = 10080741 -- old value 'Vet Case Sample - Initially Collected Sample - Collected By Institution'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Initially Collected Sample - Collected By Institution' WHERE idfsBaseReference = 10080741 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Initially Collected Sample - Collected By Institution'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080741 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - აღებულია დაწესებულების მიერ' WHERE idfsBaseReference = 10080741 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვეტერინარული დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - აღებულია დაწესებულების მიერ', 10080741, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080741 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - İlkin toplanılmış nümunə - Toplayan müəssisə' WHERE idfsBaseReference = 10080741 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Xəstəliyi Hesabatı Nümunə - İlkin toplanılmış nümunə - Toplayan müəssisə', 10080741, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080741 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - العينة الأولية المُجمعة- جمعتها المؤسسة ' WHERE idfsBaseReference = 10080741 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للتقرير عن الامراض البيطرية - العينة الأولية المُجمعة- جمعتها المؤسسة ', 10080741, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Initially Collected Sample - Collection Date' WHERE idfsBaseReference = 10080742 -- old value 'Vet Case Sample - Initially Collected Sample - Collection Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Initially Collected Sample - Collection Date' WHERE idfsBaseReference = 10080742 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Initially Collected Sample - Collection Date'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080742 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - აღების თარიღი' WHERE idfsBaseReference = 10080742 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვეტერინარული დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - აღების თარიღი', 10080742, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080742 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - İlkin toplanılmış nümunə - Toplama tarixi' WHERE idfsBaseReference = 10080742 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Xəstəliyi Hesabatı Nümunə - İlkin toplanılmış nümunə - Toplama tarixi', 10080742, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080742 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - العينة الأولية المُجمعة- تاريخ الجمع ' WHERE idfsBaseReference = 10080742 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للتقرير عن الامراض البيطرية - العينة الأولية المُجمعة- تاريخ الجمع ', 10080742, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Initially Collected Sample - Current Laboratory' WHERE idfsBaseReference = 10080740 -- old value 'Vet Case Sample - Initially Collected Sample - Current Laboratory'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Initially Collected Sample - Current Laboratory' WHERE idfsBaseReference = 10080740 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Initially Collected Sample - Current Laboratory'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080740 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - მოქმედი ლაბორატორია' WHERE idfsBaseReference = 10080740 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვეტერინარული დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - მოქმედი ლაბორატორია', 10080740, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080740 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - İlkin toplanılmış nümunə - Cari laboratoriya' WHERE idfsBaseReference = 10080740 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Xəstəliyi Hesabatı Nümunə - İlkin toplanılmış nümunə - Cari laboratoriya', 10080740, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080740 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - العينة الأولية المُجمعة- المختبر الحالي ' WHERE idfsBaseReference = 10080740 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للتقرير عن الامراض البيطرية - العينة الأولية المُجمعة- المختبر الحالي ', 10080740, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Initially Collected Sample - Field ID' WHERE idfsBaseReference = 10080738 -- old value 'Vet Case Sample - Initially Collected Sample - Field ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Initially Collected Sample - Field ID' WHERE idfsBaseReference = 10080738 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Initially Collected Sample - Field ID'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080738 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - საველე ID' WHERE idfsBaseReference = 10080738 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვეტერინარული დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - საველე ID', 10080738, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080738 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - İlkin toplanılmış nümunə - Nümunənin sahədəki Q/N-si' WHERE idfsBaseReference = 10080738 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Xəstəliyi Hesabatı Nümunə - İlkin toplanılmış nümunə - Nümunənin sahədəki Q/N-si', 10080738, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080738 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - العينة الأولية المُجمعة - معرّف الحقل ' WHERE idfsBaseReference = 10080738 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للتقرير عن الامراض البيطرية - العينة الأولية المُجمعة - معرّف الحقل ', 10080738, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Initially Collected Sample - Lab ID' WHERE idfsBaseReference = 10080737 -- old value 'Vet Case Sample - Initially Collected Sample - Lab ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Initially Collected Sample - Lab ID' WHERE idfsBaseReference = 10080737 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Initially Collected Sample - Lab ID'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080737 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - ლაბორატორიული ID' WHERE idfsBaseReference = 10080737 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვეტერინარული დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - ლაბორატორიული ID', 10080737, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080737 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - İlkin toplanılmış nümunə - Laborator nümunənin Q/N-si' WHERE idfsBaseReference = 10080737 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Xəstəliyi Hesabatı Nümunə - İlkin toplanılmış nümunə - Laborator nümunənin Q/N-si', 10080737, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080737 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - العينة الأولية المُجمعة -معرّف المختبر ' WHERE idfsBaseReference = 10080737 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للتقرير عن الامراض البيطرية - العينة الأولية المُجمعة -معرّف المختبر ', 10080737, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Initially Collected Sample - Sent to Organization' WHERE idfsBaseReference = 10080743 -- old value 'Vet Case Sample - Initially Collected Sample - Sent to Organization'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Initially Collected Sample - Sent to Organization' WHERE idfsBaseReference = 10080743 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Initially Collected Sample - Sent to Organization'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080743 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - გაგზავნილია ორგანიზაციაში' WHERE idfsBaseReference = 10080743 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვეტერინარული დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - გაგზავნილია ორგანიზაციაში', 10080743, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080743 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - İlkin toplanılmış nümunə - Hara göndərilib' WHERE idfsBaseReference = 10080743 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Xəstəliyi Hesabatı Nümunə - İlkin toplanılmış nümunə - Hara göndərilib', 10080743, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080743 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - العينة الأولية المُجمعة - اُرسل إلى المنظمة ' WHERE idfsBaseReference = 10080743 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للتقرير عن الامراض البيطرية - العينة الأولية المُجمعة - اُرسل إلى المنظمة ', 10080743, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Initially Collected Sample - Status' WHERE idfsBaseReference = 10080745 -- old value 'Vet Case Sample - Initially Collected Sample - Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Initially Collected Sample - Status' WHERE idfsBaseReference = 10080745 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Initially Collected Sample - Status'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080745 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - სტატუსი' WHERE idfsBaseReference = 10080745 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვეტერინარული დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - სტატუსი', 10080745, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080745 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - İlkin toplanılmış nümunə - Statusu' WHERE idfsBaseReference = 10080745 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Xəstəliyi Hesabatı Nümunə - İlkin toplanılmış nümunə - Statusu', 10080745, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080745 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - العينة الأولية المُجمعة - الحالة ' WHERE idfsBaseReference = 10080745 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للتقرير عن الامراض البيطرية - العينة الأولية المُجمعة - الحالة ', 10080745, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Initially Collected Sample - Type' WHERE idfsBaseReference = 10080739 -- old value 'Vet Case Sample - Initially Collected Sample - Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Initially Collected Sample - Type' WHERE idfsBaseReference = 10080739 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Initially Collected Sample - Type'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080739 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - ტიპი' WHERE idfsBaseReference = 10080739 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვეტერინარული დაავადების ანგარიშის ნიმუში - თავდაპირველად აღებული ნიმუში - ტიპი', 10080739, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080739 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - İlkin toplanılmış nümunə - Növü' WHERE idfsBaseReference = 10080739 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Xəstəliyi Hesabatı Nümunə - İlkin toplanılmış nümunə - Növü', 10080739, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080739 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - العينة الأولية المُجمعة - النوع ' WHERE idfsBaseReference = 10080739 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للتقرير عن الامراض البيطرية - العينة الأولية المُجمعة - النوع ', 10080739, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Lab Sample ID' WHERE idfsBaseReference = 10080209 -- old value 'Vet Case Sample - Lab Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Lab Sample ID' WHERE idfsBaseReference = 10080209 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Lab Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - ლაბორატორიული ნიმუშის  ID' WHERE idfsBaseReference = 10080209 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Laborator nümunənin Q/N-si' WHERE idfsBaseReference = 10080209 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - عينة لمعرّف المختبر ' WHERE idfsBaseReference = 10080209 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Parent Sample - Accession Date' WHERE idfsBaseReference = 10080753 -- old value 'Vet Case Sample - Parent Sample - Accession Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Parent Sample - Accession Date' WHERE idfsBaseReference = 10080753 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Parent Sample - Accession Date'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080753 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - ძირითადი ნიმუში - მიღების თარიღი' WHERE idfsBaseReference = 10080753 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვეტერინარული დაავადების ანგარიშის ნიმუში - ძირითადი ნიმუში - მიღების თარიღი', 10080753, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080753 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Əsas nümunə - Qəbul edilmə tarixi' WHERE idfsBaseReference = 10080753 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Əsas nümunə - Qəbul edilmə tarixi', 10080753, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080753 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - أصل العينة - تاريخ الانضمام ' WHERE idfsBaseReference = 10080753 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للتقرير عن الامراض البيطرية - أصل العينة - تاريخ الانضمام ', 10080753, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Parent Sample - Collected By Institution' WHERE idfsBaseReference = 10080750 -- old value 'Vet Case Sample - Parent Sample - Collected By Institution'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Parent Sample - Collected By Institution' WHERE idfsBaseReference = 10080750 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Parent Sample - Collected By Institution'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080750 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - ძირითადი ნიმუში - აღებულია დაწესებულების მიერ' WHERE idfsBaseReference = 10080750 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვეტერინარული დაავადების ანგარიშის ნიმუში - ძირითადი ნიმუში - აღებულია დაწესებულების მიერ', 10080750, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080750 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Əsas nümunə - Toplayan müəssisə ' WHERE idfsBaseReference = 10080750 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Əsas nümunə - Toplayan müəssisə ', 10080750, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080750 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية  - أصل العينة -  جمعتها المؤسسة ' WHERE idfsBaseReference = 10080750 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للتقرير عن الامراض البيطرية  - أصل العينة -  جمعتها المؤسسة ', 10080750, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Parent Sample - Collection Date' WHERE idfsBaseReference = 10080751 -- old value 'Vet Case Sample - Parent Sample - Collection Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Parent Sample - Collection Date' WHERE idfsBaseReference = 10080751 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Parent Sample - Collection Date'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080751 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - ძირითადი ნიმუში - აღების თარიღი' WHERE idfsBaseReference = 10080751 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვეტერინარული დაავადების ანგარიშის ნიმუში - ძირითადი ნიმუში - აღების თარიღი', 10080751, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080751 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Əsas nümunə - Toplama tarixi' WHERE idfsBaseReference = 10080751 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Əsas nümunə - Toplama tarixi', 10080751, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080751 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية  - أصل العينة - تاريخ الجمع ' WHERE idfsBaseReference = 10080751 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للتقرير عن الامراض البيطرية  - أصل العينة - تاريخ الجمع ', 10080751, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Parent Sample - Current Laboratory' WHERE idfsBaseReference = 10080749 -- old value 'Vet Case Sample - Parent Sample - Current Laboratory'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Parent Sample - Current Laboratory' WHERE idfsBaseReference = 10080749 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Parent Sample - Current Laboratory'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080749 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - ძირითადი ნიმუში -მოქმედი ლაბორატორია' WHERE idfsBaseReference = 10080749 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვეტერინარული დაავადების ანგარიშის ნიმუში - ძირითადი ნიმუში -მოქმედი ლაბორატორია', 10080749, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080749 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Əsas nümunə - Cari laboratoriya' WHERE idfsBaseReference = 10080749 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Əsas nümunə - Cari laboratoriya', 10080749, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080749 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية  - أصل العينة -  المختبر الحالي ' WHERE idfsBaseReference = 10080749 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للتقرير عن الامراض البيطرية  - أصل العينة -  المختبر الحالي ', 10080749, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Parent Sample - Field ID' WHERE idfsBaseReference = 10080747 -- old value 'Vet Case Sample - Parent Sample - Field ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Parent Sample - Field ID' WHERE idfsBaseReference = 10080747 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Parent Sample - Field ID'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080747 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - ძირითადი ნიმუში - საველე ID' WHERE idfsBaseReference = 10080747 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვეტერინარული დაავადების ანგარიშის ნიმუში - ძირითადი ნიმუში - საველე ID', 10080747, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080747 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Əsas nümunə - Nümunənin sahədəki Q/N-si' WHERE idfsBaseReference = 10080747 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Əsas nümunə - Nümunənin sahədəki Q/N-si', 10080747, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080747 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية  - أصل العينة - معرّف الحقل ' WHERE idfsBaseReference = 10080747 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للتقرير عن الامراض البيطرية  - أصل العينة - معرّف الحقل ', 10080747, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Parent Sample - Lab ID' WHERE idfsBaseReference = 10080181 -- old value 'Vet Case Sample - Parent Sample - Lab ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Parent Sample - Lab ID' WHERE idfsBaseReference = 10080181 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Parent Sample - Lab ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - ძირითადი ნიმუში - ლაბორატორიული ID' WHERE idfsBaseReference = 10080181 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Əsas nümunə - Laborator nümunənin Q/N-si' WHERE idfsBaseReference = 10080181 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية  - أصل العينة - معرّف المختبر ' WHERE idfsBaseReference = 10080181 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Parent Sample - Sent to Organization' WHERE idfsBaseReference = 10080752 -- old value 'Vet Case Sample - Parent Sample - Sent to Organization'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Parent Sample - Sent to Organization' WHERE idfsBaseReference = 10080752 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Parent Sample - Sent to Organization'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080752 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - ძირითადი ნიმუში - გაგზავნილია ორგანიზაციაში' WHERE idfsBaseReference = 10080752 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვეტერინარული დაავადების ანგარიშის ნიმუში - ძირითადი ნიმუში - გაგზავნილია ორგანიზაციაში', 10080752, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080752 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Əsas nümunə - Hara göndərilib' WHERE idfsBaseReference = 10080752 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Əsas nümunə - Hara göndərilib', 10080752, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080752 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية  - أصل العينة - اُرسل إلى المنظمة ' WHERE idfsBaseReference = 10080752 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للتقرير عن الامراض البيطرية  - أصل العينة - اُرسل إلى المنظمة ', 10080752, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Parent Sample - Status' WHERE idfsBaseReference = 10080754 -- old value 'Vet Case Sample - Parent Sample - Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Parent Sample - Status' WHERE idfsBaseReference = 10080754 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Parent Sample - Status'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080754 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - ძირითადი ნიმუში - სტატუსი' WHERE idfsBaseReference = 10080754 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვეტერინარული დაავადების ანგარიშის ნიმუში - ძირითადი ნიმუში - სტატუსი', 10080754, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080754 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Əsas nümunə - Statusu' WHERE idfsBaseReference = 10080754 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Əsas nümunə - Statusu', 10080754, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080754 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية  - أصل العينة - الحالة ' WHERE idfsBaseReference = 10080754 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للتقرير عن الامراض البيطرية  - أصل العينة - الحالة ', 10080754, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Parent Sample - Type' WHERE idfsBaseReference = 10080748 -- old value 'Vet Case Sample - Parent Sample - Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Parent Sample - Type' WHERE idfsBaseReference = 10080748 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Parent Sample - Type'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080748 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - ძირითადი ნიმუში - ტიპი' WHERE idfsBaseReference = 10080748 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვეტერინარული დაავადების ანგარიშის ნიმუში - ძირითადი ნიმუში - ტიპი' , 10080748, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080748 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Əsas nümunə - Növü' WHERE idfsBaseReference = 10080748 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Əsas nümunə - Növü', 10080748, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080748 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية  - أصل العينة - النوع ' WHERE idfsBaseReference = 10080748 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'نموذج للتقرير عن الامراض البيطرية  - أصل العينة - النوع ', 10080748, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Report Type' WHERE idfsBaseReference = 10080426 -- old value 'Vet Case Sample - Report Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Report Type' WHERE idfsBaseReference = 10080426 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Report Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - ანგარიშის ტიპი' WHERE idfsBaseReference = 10080426 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Hesabat növü' WHERE idfsBaseReference = 10080426 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية -  نوع التقرير ' WHERE idfsBaseReference = 10080426 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Sample Type' WHERE idfsBaseReference = 10080216 -- old value 'Vet Case Sample - Sample Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Sample Type' WHERE idfsBaseReference = 10080216 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Sample Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - ნიმუშის ტიპი' WHERE idfsBaseReference = 10080216 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Nümunənin növü ' WHERE idfsBaseReference = 10080216 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - نوع العينة ' WHERE idfsBaseReference = 10080216 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Sent to Organization' WHERE idfsBaseReference = 10080815 -- old value 'Vet Case Sample - Sent to Organization'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Sent to Organization' WHERE idfsBaseReference = 10080815 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Sent to Organization'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - გაგზავნილია ორგანიზაციაში' WHERE idfsBaseReference = 10080815 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Hara göndərilib' WHERE idfsBaseReference = 10080815 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - اُرسل إلى المنظمة ' WHERE idfsBaseReference = 10080815 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Species' WHERE idfsBaseReference = 10080214 -- old value 'Vet Case Sample - Species'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Species' WHERE idfsBaseReference = 10080214 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Species'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - სახეობა' WHERE idfsBaseReference = 10080214 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Heyvan növü' WHERE idfsBaseReference = 10080214 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - أنواع الحيوانات' WHERE idfsBaseReference = 10080214 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Sample - Status' WHERE idfsBaseReference = 10080718 -- old value 'Vet Case Sample - Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Sample - Status' WHERE idfsBaseReference = 10080718 AND idfsLanguage = 10049003 -- old value 'Vet Case Sample - Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ნიმუში - სტატუსი' WHERE idfsBaseReference = 10080718 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Nümunə - Statusu' WHERE idfsBaseReference = 10080718 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'نموذج للتقرير عن الامراض البيطرية - الحالة ' WHERE idfsBaseReference = 10080718 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Test - Animal ID' WHERE idfsBaseReference = 10080201 -- old value 'Vet Case Test - Animal ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Test - Animal ID' WHERE idfsBaseReference = 10080201 AND idfsLanguage = 10049003 -- old value 'Vet Case Test - Animal ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ტესტი - ცხოველის ID' WHERE idfsBaseReference = 10080201 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Test - Heyvanın Q/N-si' WHERE idfsBaseReference = 10080201 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية -  الرقم التعريفي للحيوان ' WHERE idfsBaseReference = 10080201 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Test - Disease Report ID' WHERE idfsBaseReference = 10080219 -- old value 'Vet Case Test - Case ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Test - Disease Report ID' WHERE idfsBaseReference = 10080219 AND idfsLanguage = 10049003 -- old value 'Vet Case Test - Case ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ტესტი - დაავადების ანგარიშის  ID ' WHERE idfsBaseReference = 10080219 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Test - Xəstəlik hesabatının Q/N-si' WHERE idfsBaseReference = 10080219 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - معرّف تقرير المرض ' WHERE idfsBaseReference = 10080219 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Test - Disease Report Type' WHERE idfsBaseReference = 10080203 -- old value 'Vet Case Test - Case Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Test - Disease Report Type' WHERE idfsBaseReference = 10080203 AND idfsLanguage = 10049003 -- old value 'Vet Case Test - Case Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ტესტი - დაავადების ანგარიშის ტიპი' WHERE idfsBaseReference = 10080203 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Test - Xəstəlik hesabatının növü' WHERE idfsBaseReference = 10080203 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - نوع تقرير المرض ' WHERE idfsBaseReference = 10080203 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Test - Date Started' WHERE idfsBaseReference = 10080205 -- old value 'Vet Case Test - Date Started'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Test - Date Started' WHERE idfsBaseReference = 10080205 AND idfsLanguage = 10049003 -- old value 'Vet Case Test - Date Started'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ტესტი - დაწყების თარიღი' WHERE idfsBaseReference = 10080205 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Test - Başlanma tarixi' WHERE idfsBaseReference = 10080205 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - تاريخ البدء ' WHERE idfsBaseReference = 10080205 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Test - Disease' WHERE idfsBaseReference = 10080283 -- old value 'Vet Case Test - Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Test - Disease' WHERE idfsBaseReference = 10080283 AND idfsLanguage = 10049003 -- old value 'Vet Case Test - Diagnosis'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ტესტი - დაავადება' WHERE idfsBaseReference = 10080283 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Test - Xəstəlik' WHERE idfsBaseReference = 10080283 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - المرض ' WHERE idfsBaseReference = 10080283 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Test - Disease - Is Zoonotic' WHERE idfsBaseReference = 10080576 -- old value 'Vet Case Test - Diagnosis - Is Zoonotic'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Test - Disease - Is Zoonotic' WHERE idfsBaseReference = 10080576 AND idfsLanguage = 10049003 -- old value 'Vet Case Test - Diagnosis - Is Zoonotic'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ტესტი - დაავადება - არის ზოონოზური' WHERE idfsBaseReference = 10080576 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Test - Xəstəlik - Zoonozdur' WHERE idfsBaseReference = 10080576 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - المرض - حيوانيّ المصدر ' WHERE idfsBaseReference = 10080576 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Test - Farm Owner' WHERE idfsBaseReference = 10080281 -- old value 'Vet Case Test - Farm Owner'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Test - Farm Owner' WHERE idfsBaseReference = 10080281 AND idfsLanguage = 10049003 -- old value 'Vet Case Test - Farm Owner'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ტესტი - ფერმის მესაკუთრე' WHERE idfsBaseReference = 10080281 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Test - Fermanın sahibi' WHERE idfsBaseReference = 10080281 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - مالك المزرعة ' WHERE idfsBaseReference = 10080281 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Test - Field Sample ID' WHERE idfsBaseReference = 10080210 -- old value 'Vet Case Test - Field Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Test - Field Sample ID' WHERE idfsBaseReference = 10080210 AND idfsLanguage = 10049003 -- old value 'Vet Case Test - Field Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ტესტი - საველე ნიმუშის  ID' WHERE idfsBaseReference = 10080210 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Test - Nümunənin sahədəki Q/N-si' WHERE idfsBaseReference = 10080210 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - عينة لمعرّف الحقل ' WHERE idfsBaseReference = 10080210 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Test - Is Entered by Laboratory' WHERE idfsBaseReference = 10080794 -- old value 'Vet Case Test - Is Entered by Laboratory'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Test - Is Entered by Laboratory' WHERE idfsBaseReference = 10080794 AND idfsLanguage = 10049003 -- old value 'Vet Case Test - Is Entered by Laboratory'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080794 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ტესტი - შეყვანილია ლაბორატორიის მიერ' WHERE idfsBaseReference = 10080794 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვეტერინარული დაავადების ანგარიშის ტესტი - შეყვანილია ლაბორატორიის მიერ', 10080794, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080794 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Test - Laboratoriya tərəfindən daxil edilib' WHERE idfsBaseReference = 10080794 AND idfsLanguage = 10049001
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Xəstəliyi Hesabatı Test - Laboratoriya tərəfindən daxil edilib', 10080794, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080794 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - اُدخل بواسطة المختير ' WHERE idfsBaseReference = 10080794 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'اختبار  تقرير الامراض البشرية - اُدخل بواسطة المختير ', 10080794, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Test - Lab Sample ID' WHERE idfsBaseReference = 10080282 -- old value 'Vet Case Test - Lab Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Test - Lab Sample ID' WHERE idfsBaseReference = 10080282 AND idfsLanguage = 10049003 -- old value 'Vet Case Test - Lab Sample ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ტესტი - ლაბორატორიული ნიმუშის ID' WHERE idfsBaseReference = 10080282 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Test - Laborator nümunənin Q/N-si' WHERE idfsBaseReference = 10080282 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - عينة لمعرّف المختبر ' WHERE idfsBaseReference = 10080282 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Test - Report Type' WHERE idfsBaseReference = 10080427 -- old value 'Vet Case Test - Report Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Test - Report Type' WHERE idfsBaseReference = 10080427 AND idfsLanguage = 10049003 -- old value 'Vet Case Test - Report Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ტესტი - ანგარიშის ტიპი' WHERE idfsBaseReference = 10080427 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Test - Hesabat növü' WHERE idfsBaseReference = 10080427 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - نوع التقرير ' WHERE idfsBaseReference = 10080427 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Test - Result Date' WHERE idfsBaseReference = 10080284 -- old value 'Vet Case Test - Result Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Test - Result Date' WHERE idfsBaseReference = 10080284 AND idfsLanguage = 10049003 -- old value 'Vet Case Test - Result Date'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ტესტი - ანგარიშის თარიღი' WHERE idfsBaseReference = 10080284 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Test - Nəticənin tarixi' WHERE idfsBaseReference = 10080284 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - تاريخ النتيجة ' WHERE idfsBaseReference = 10080284 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Test - Sample Type' WHERE idfsBaseReference = 10080217 -- old value 'Vet Case Test - Sample Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Test - Sample Type' WHERE idfsBaseReference = 10080217 AND idfsLanguage = 10049003 -- old value 'Vet Case Test - Sample Type'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ტესტი - ნიმუშის ტიპი' WHERE idfsBaseReference = 10080217 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Test - Nümunənin növü' WHERE idfsBaseReference = 10080217 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - نوع العينة ' WHERE idfsBaseReference = 10080217 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Test - Species' WHERE idfsBaseReference = 10080215 -- old value 'Vet Case Test - Species'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Test - Species' WHERE idfsBaseReference = 10080215 AND idfsLanguage = 10049003 -- old value 'Vet Case Test - Species'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ტესტი - სახეობა' WHERE idfsBaseReference = 10080215 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Test - Heyvan növü' WHERE idfsBaseReference = 10080215 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - أنواع الحيوانات ' WHERE idfsBaseReference = 10080215 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Test - Test Name' WHERE idfsBaseReference = 10080218 -- old value 'Vet Case Test - Test Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Test - Test Name' WHERE idfsBaseReference = 10080218 AND idfsLanguage = 10049003 -- old value 'Vet Case Test - Test Name'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ტესტი - ტესტის დასახელება' WHERE idfsBaseReference = 10080218 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Test - Testin adı' WHERE idfsBaseReference = 10080218 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - اسم الاختبار ' WHERE idfsBaseReference = 10080218 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Test - Test Result' WHERE idfsBaseReference = 10080220 -- old value 'Vet Case Test - Test Result'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Test - Test Result' WHERE idfsBaseReference = 10080220 AND idfsLanguage = 10049003 -- old value 'Vet Case Test - Test Result'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ტესტი - ტესტის შედეგი' WHERE idfsBaseReference = 10080220 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Test - Testin nəticəsi' WHERE idfsBaseReference = 10080220 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - تاريخ الاختبار ' WHERE idfsBaseReference = 10080220 AND idfsLanguage = 10049011

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Test - Test Run ID' WHERE idfsBaseReference = 10080221 -- old value 'Vet Case Test - Test Run ID'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Test - Test Run ID' WHERE idfsBaseReference = 10080221 AND idfsLanguage = 10049003 -- old value 'Vet Case Test - Test Run ID'
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080221 AND idfsLanguage = 10049004)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ტესტი - ტესტის ჩატარების ID' WHERE idfsBaseReference = 10080221 AND idfsLanguage = 10049004 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'ვეტერინარული დაავადების ანგარიშის ტესტი - ტესტის ჩატარების ID', 10080221, 10049004)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080221 AND idfsLanguage = 10049001)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Test - Testin icra edilmə Q/N-si' WHERE idfsBaseReference = 10080221 AND idfsLanguage = 10049001 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'Baytarlıq Xəstəliyi Hesabatı Test - Testin icra edilmə Q/N-si', 10080221, 10049001)
IF EXISTS(SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10080221 AND idfsLanguage = 10049011)
	UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية - معرّف تشغيل الاختبار ' WHERE idfsBaseReference = 10080221 AND idfsLanguage = 10049011 -- <<< record does not exist >>>
ELSE
	INSERT INTO dbo.trtStringNameTranslation (strTextString, idfsBaseReference, idfsLanguage) VALUES (N'اختبار  تقرير الامراض البشرية - معرّف تشغيل الاختبار ', 10080221, 10049011)

UPDATE dbo.trtBaseReference SET strDefault = N'Vet Disease Report Test - Test Status' WHERE idfsBaseReference = 10080222 -- old value 'Vet Case Test - Test Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Vet Disease Report Test - Test Status' WHERE idfsBaseReference = 10080222 AND idfsLanguage = 10049003 -- old value 'Vet Case Test - Test Status'
UPDATE dbo.trtStringNameTranslation SET strTextString = N'ვეტერინარული დაავადების ანგარიშის ტესტი - ტესტის სტატუსი' WHERE idfsBaseReference = 10080222 AND idfsLanguage = 10049004
UPDATE dbo.trtStringNameTranslation SET strTextString = N'Baytarlıq Xəstəliyi Hesabatı Test - Testin statusu' WHERE idfsBaseReference = 10080222 AND idfsLanguage = 10049001
UPDATE dbo.trtStringNameTranslation SET strTextString = N'اختبار  تقرير الامراض البشرية -  حالة الاختبار ' WHERE idfsBaseReference = 10080222 AND idfsLanguage = 10049011

-- These fields are now under  'Human Clinical Signs' and "Human Epi Investigations' there is no need to rename them anymore 12/21/2021
--UPDATE dbo.trtBaseReference SET strDefault = N'Syndrome' WHERE idfsBaseReference = 10082042 -- old value 'Basic Syndromic Surveillance Form'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Syndrome' WHERE idfsBaseReference = 10082042 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'სინდრომი' WHERE idfsBaseReference = 10082042 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Sindrom' WHERE idfsBaseReference = 10082042 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'المتلازمة' WHERE idfsBaseReference = 10082042 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Antiviral Medication Date Received' WHERE idfsBaseReference = 10080656 -- old value 'Basic Syndromic Surveillance Form - Antiviral Medication Date Received'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Antiviral Medication Date Received' WHERE idfsBaseReference = 10080656 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - ანტივირუსული პრეპარატის მიღების თარიღი' WHERE idfsBaseReference = 10080656 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Antivirus müalicəsinin qəbul edildiyi tarix ' WHERE idfsBaseReference = 10080656 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - تاريخ استلام الدواء المضاد للفيروسات ' WHERE idfsBaseReference = 10080656 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - CDC Age Group' WHERE idfsBaseReference = 10080671 -- old value 'Basic Syndromic Surveillance Form - CDC Age Group'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - CDC Age Group' WHERE idfsBaseReference = 10080671 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - CDC-ის ასაკობრივი ჯგუფი' WHERE idfsBaseReference = 10080671 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - CDC Yaş qrupu' WHERE idfsBaseReference = 10080671 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - الفئة العمرية لمراكز مكافحة الامراض ' WHERE idfsBaseReference = 10080671 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Complete Patient Age (months)' WHERE idfsBaseReference = 10080635 -- old value 'Basic Syndromic Surveillance Form - Complete Patient Age (months)'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Complete Patient Age (months)' WHERE idfsBaseReference = 10080635 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - შეავსეთ პაციენტის ასაკი (თვე)' WHERE idfsBaseReference = 10080635 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Xəstənin tam yaşı (aylar)' WHERE idfsBaseReference = 10080635 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - عمر المريض الكامل (أشهر)' WHERE idfsBaseReference = 10080635 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Complete Patient Age (Years)' WHERE idfsBaseReference = 10080636 -- old value 'Basic Syndromic Surveillance Form - Complete Patient Age (Years)'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Complete Patient Age (Years)' WHERE idfsBaseReference = 10080636 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - შეავსეთ პაციენტის ასაკი (წელი)' WHERE idfsBaseReference = 10080636 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Xəstənin tam yaşı (illər)' WHERE idfsBaseReference = 10080636 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - عمر المريض الكامل (سنوات )' WHERE idfsBaseReference = 10080636 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Concurrent Chronic Diseases or Conditions - Asthma' WHERE idfsBaseReference = 10080658 -- old value 'Basic Syndromic Surveillance Form - Concurrent Chronic Diseases or Conditions - Asthma'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Concurrent Chronic Diseases or Conditions - Asthma' WHERE idfsBaseReference = 10080658 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - თანმხლები  ქრონიკული დაავადებები ან მდგომარეობები - ასთმა' WHERE idfsBaseReference = 10080658 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Yanaşı gedən xronik xəstəliklər və vəziyyətlər - Astma' WHERE idfsBaseReference = 10080658 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - الامراض أو الحالات المزمنة - الربو ' WHERE idfsBaseReference = 10080658 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Concurrent Chronic Diseases or Conditions - Cardiovascular' WHERE idfsBaseReference = 10080660 -- old value 'Basic Syndromic Surveillance Form - Concurrent Chronic Diseases or Conditions - Cardiovascular'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Concurrent Chronic Diseases or Conditions - Cardiovascular' WHERE idfsBaseReference = 10080660 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - თანმხლები  ქრონიკული დაავადებები ან მდგომარეობები - გულ-სისხლძარღვთა' WHERE idfsBaseReference = 10080660 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Yanaşı gedən xəstəliklər və vəziyyətlər - Ürək-damar ' WHERE idfsBaseReference = 10080660 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة -  الامراض أو الحالات المزمنة - امراض القلب و الأوعية الدموية ' WHERE idfsBaseReference = 10080660 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Concurrent Chronic Diseases or Conditions - Diabetes' WHERE idfsBaseReference = 10080659 -- old value 'Basic Syndromic Surveillance Form - Concurrent Chronic Diseases or Conditions - Diabetes'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Concurrent Chronic Diseases or Conditions - Diabetes' WHERE idfsBaseReference = 10080659 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - თანმხლები  ქრონიკული დაავადებები ან მდგომარეობები - დიაბეტი' WHERE idfsBaseReference = 10080659 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Yanaşı gedən xəstəliklər və vəziyyətlər - Diabet' WHERE idfsBaseReference = 10080659 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة -  الامراض أو الحالات المزمنة - السكري' WHERE idfsBaseReference = 10080659 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Concurrent Chronic Diseases or Conditions - Immunodeficiency' WHERE idfsBaseReference = 10080665 -- old value 'Basic Syndromic Surveillance Form - Concurrent Chronic Diseases or Conditions - Immunodeficiency'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Concurrent Chronic Diseases or Conditions - Immunodeficiency' WHERE idfsBaseReference = 10080665 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - თანმხლები  ქრონიკული დაავადებები ან მდგომარეობები - იმუნოდეფიციტი' WHERE idfsBaseReference = 10080665 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Yanaşı gedən xəstəliklər və vəziyyətlər - İmmunçatışmamazlıq' WHERE idfsBaseReference = 10080665 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - الامراض أو الحالات المزمنة - نقص المناعة البشرية ' WHERE idfsBaseReference = 10080665 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Concurrent Chronic Diseases or Conditions - Liver' WHERE idfsBaseReference = 10080663 -- old value 'Basic Syndromic Surveillance Form - Concurrent Chronic Diseases or Conditions - Liver'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Concurrent Chronic Diseases or Conditions - Liver' WHERE idfsBaseReference = 10080663 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - თანმხლები  ქრონიკული დაავადებები ან მდგომარეობები - ღვიძლი' WHERE idfsBaseReference = 10080663 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Yanaşı gedən xəstəliklər və vəziyyətlər - Qara ciyər' WHERE idfsBaseReference = 10080663 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - الامراض أو الحالات المزمنة - الكبد ' WHERE idfsBaseReference = 10080663 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Concurrent Chronic Diseases or Conditions - Neurological/Physiological' WHERE idfsBaseReference = 10080664 -- old value 'Basic Syndromic Surveillance Form - Concurrent Chronic Diseases or Conditions - Neurological/Physiological'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Concurrent Chronic Diseases or Conditions - Neurological/Physiological' WHERE idfsBaseReference = 10080664 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - თანმხლები  ქრონიკული დაავადებები ან მდგომარეობები - ნევროლოგიური/ფიზიოლოგიური' WHERE idfsBaseReference = 10080664 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Yanaşı gedən xəstəliklər və vəziyyətlər - Nevroloji/Psixoloji' WHERE idfsBaseReference = 10080664 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة -  الامراض أو الحالات المزمنة - العصبية و الفسيولوجية ' WHERE idfsBaseReference = 10080664 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Concurrent Chronic Diseases or Conditions - Obesity - BMI >30; not evaluated' WHERE idfsBaseReference = 10080661 -- old value 'Basic Syndromic Surveillance Form - Concurrent Chronic Diseases or Conditions - Obesity - BMI >30; not evaluated'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Concurrent Chronic Diseases or Conditions - Obesity - BMI >30; not evaluated' WHERE idfsBaseReference = 10080661 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - თანმხლები  ქრონიკული დაავადებები ან მდგომარეობები - სიმსუქნე - ადამიანის სხეულის წონისა და სიმაღლის ინდექსი  >30; არ არის შეფასებული ' WHERE idfsBaseReference = 10080661 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Yanaşı gedən xəstəliklər və vəziyyətlər - Piylənmə - Bədən Kütləsi İndeksi >30; qiymətləndirilməyib ' WHERE idfsBaseReference = 10080661 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة -  الامراض أو الحالات المزمنة - السمنة - مؤشر كتلة الجسم أقل من 30;لم يتم تقييمه' WHERE idfsBaseReference = 10080661 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Concurrent Chronic Diseases or Conditions - Renal' WHERE idfsBaseReference = 10080662 -- old value 'Basic Syndromic Surveillance Form - Concurrent Chronic Diseases or Conditions - Renal'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Concurrent Chronic Diseases or Conditions - Renal' WHERE idfsBaseReference = 10080662 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - თანმხლები  ქრონიკული დაავადებები ან მდგომარეობები - თირკმლის' WHERE idfsBaseReference = 10080662 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Yanaşı gedən xəstəliklər və vəziyyətlər - Böyrək' WHERE idfsBaseReference = 10080662 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة -  الامراض أو الحالات المزمنة - الكلى' WHERE idfsBaseReference = 10080662 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Concurrent Chronic Diseases or Conditions - Respiratory System' WHERE idfsBaseReference = 10080657 -- old value 'Basic Syndromic Surveillance Form - Concurrent Chronic Diseases or Conditions - Respiratory System'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Concurrent Chronic Diseases or Conditions - Respiratory System' WHERE idfsBaseReference = 10080657 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - თანმხლები  ქრონიკული დაავადებები ან მდგომარეობები - სასუნთქი სისტემა' WHERE idfsBaseReference = 10080657 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Yanaşı gedən xəstəliklər və vəziyyətlər - Tənəffüs sistemi' WHERE idfsBaseReference = 10080657 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة -  الامراض أو الحالات المزمنة - الجهاز التنفسي' WHERE idfsBaseReference = 10080657 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Concurrent Chronic Diseases or Conditions - Unknown Etiology' WHERE idfsBaseReference = 10080666 -- old value 'Basic Syndromic Surveillance Form - Concurrent Chronic Diseases or Conditions - Unknown Etiology'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Concurrent Chronic Diseases or Conditions - Unknown Etiology' WHERE idfsBaseReference = 10080666 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - თანმხლები  ქრონიკული დაავადებები ან მდგომარეობები - უცნობი ეტიოლოგიის' WHERE idfsBaseReference = 10080666 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Yanaşı gedən xəstəliklər və vəziyyətlər - Naməlum etiologiya' WHERE idfsBaseReference = 10080666 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة -  الامراض أو الحالات المزمنة - مسببات غير معروفة ' WHERE idfsBaseReference = 10080666 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Cough' WHERE idfsBaseReference = 10080646 -- old value 'Basic Syndromic Surveillance Form - Cough'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Cough' WHERE idfsBaseReference = 10080646 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი  - ხველება' WHERE idfsBaseReference = 10080646 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Öskürək' WHERE idfsBaseReference = 10080646 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة -  سعال ' WHERE idfsBaseReference = 10080646 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Date of Care' WHERE idfsBaseReference = 10080649 -- old value 'Basic Syndromic Surveillance Form - Date of Care'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Date of Care' WHERE idfsBaseReference = 10080649 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - მეთვალყურეობის თარიღი' WHERE idfsBaseReference = 10080649 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Müalicə tarixi' WHERE idfsBaseReference = 10080649 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة -  تاريخ العلاج' WHERE idfsBaseReference = 10080649 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Date of symptoms onset' WHERE idfsBaseReference = 10080642 -- old value 'Basic Syndromic Surveillance Form - Date of symptoms onset'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Date of symptoms onset' WHERE idfsBaseReference = 10080642 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - სიმპტომების გამოვლენის თარიღი' WHERE idfsBaseReference = 10080642 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Simptomların başlanma tarixi' WHERE idfsBaseReference = 10080642 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة -  تاريخ ظهور الأعراض' WHERE idfsBaseReference = 10080642 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Fever >38 C' WHERE idfsBaseReference = 10080643 -- old value 'Basic Syndromic Surveillance Form - Fever >38 C'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Fever >38 C' WHERE idfsBaseReference = 10080643 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი -სიცხე  >38 C' WHERE idfsBaseReference = 10080643 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Qızdırma > 38 C' WHERE idfsBaseReference = 10080643 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة -  حمى  >38  درجة مئوية' WHERE idfsBaseReference = 10080643 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Method of Measurement' WHERE idfsBaseReference = 10080644 -- old value 'Basic Syndromic Surveillance Form - Method of Measurement'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Method of Measurement' WHERE idfsBaseReference = 10080644 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - გაზომვის მეთოდი' WHERE idfsBaseReference = 10080644 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Ölçü üsulu' WHERE idfsBaseReference = 10080644 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - طريقة القياس ' WHERE idfsBaseReference = 10080644 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Method of Measurements (other method)' WHERE idfsBaseReference = 10080645 -- old value 'Basic Syndromic Surveillance Form - Method of Measurements (other method)'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Method of Measurements (other method)' WHERE idfsBaseReference = 10080645 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - გაზომვის მეთოდი (სხვა მეთოდი)' WHERE idfsBaseReference = 10080645 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Ölçü üsulu (digər üsullar)' WHERE idfsBaseReference = 10080645 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - طريقة القياسات ( طريقة أخرى)' WHERE idfsBaseReference = 10080645 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Name of Antiviral Medication' WHERE idfsBaseReference = 10080655 -- old value 'Basic Syndromic Surveillance Form - Name of Antiviral Medication'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Name of Antiviral Medication' WHERE idfsBaseReference = 10080655 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - ანტივირუსული პრეპარატის დასახელება' WHERE idfsBaseReference = 10080655 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Antivirus preparatının adı' WHERE idfsBaseReference = 10080655 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - اسم الدواء المضاد للفيروسات ' WHERE idfsBaseReference = 10080655 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Outcome' WHERE idfsBaseReference = 10080652 -- old value 'Basic Syndromic Surveillance Form - Outcome'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Outcome' WHERE idfsBaseReference = 10080652 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - გამოსავალი' WHERE idfsBaseReference = 10080652 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Nəticə' WHERE idfsBaseReference = 10080652 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - النتيجة' WHERE idfsBaseReference = 10080652 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Patient Age (years, months)' WHERE idfsBaseReference = 10080637 -- old value 'Basic Syndromic Surveillance Form - Patient Age (years, months)'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Patient Age (years, months)' WHERE idfsBaseReference = 10080637 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - პაციენტის ასაკი (წელი, თვე)' WHERE idfsBaseReference = 10080637 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Xəstənin yaşı (illər, aylar)' WHERE idfsBaseReference = 10080637 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - عمر المريض ( سنوات-أشهر)' WHERE idfsBaseReference = 10080637 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Patient was administered antiviral medication?' WHERE idfsBaseReference = 10080654 -- old value 'Basic Syndromic Surveillance Form - Patient was administered antiviral medication?'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Patient was administered antiviral medication?' WHERE idfsBaseReference = 10080654 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - პაციენტს  დაენიშნა ანტივირუსული პრეპარატი?' WHERE idfsBaseReference = 10080654 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Xəstəyə antivirus müaəlicəsi təyin olunub?' WHERE idfsBaseReference = 10080654 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - هل تم إعطاء المريض دواء مضاد للفيروسات ؟' WHERE idfsBaseReference = 10080654 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Patient was hospitalized at least one night?' WHERE idfsBaseReference = 10080651 -- old value 'Basic Syndromic Surveillance Form - Patient was hospitalized at least one night?'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Patient was hospitalized at least one night?' WHERE idfsBaseReference = 10080651 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - მოხდა პაციენტის ჰოსპიტალიზაცია  სულ მცირე ერთი ღამით?' WHERE idfsBaseReference = 10080651 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Xəstə ən azı bir günlük hospitalizasiya olunub?' WHERE idfsBaseReference = 10080651 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - هل دخل المريض ليلة واحدة إلى المستشفى على الأقل ؟' WHERE idfsBaseReference = 10080651 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Patient was in ER or Intensive Care?' WHERE idfsBaseReference = 10080650 -- old value 'Basic Syndromic Surveillance Form - Patient was in ER or Intensive Care?'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Patient was in ER or Intensive Care?' WHERE idfsBaseReference = 10080650 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - იმყოფებოდა  პაციენტი  გადაუდებელი დახმარების  ან ინტენსიური თერაპიის განყოფილებაში?' WHERE idfsBaseReference = 10080650 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Xəstə Təcili Yardım və ya Reanimasiya və İntensiv Terapiya şöbəsində olub?' WHERE idfsBaseReference = 10080650 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - هل كان المريض في غرفة الطوارئ أو في العناية المركزة ؟' WHERE idfsBaseReference = 10080650 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Postpartum period (6 weeks)' WHERE idfsBaseReference = 10080633 -- old value 'Basic Syndromic Surveillance Form - Postpartum period (6 weeks)'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Postpartum period (6 weeks)' WHERE idfsBaseReference = 10080633 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - პოსტნატალური პერიოდი ( 6 კვირა)' WHERE idfsBaseReference = 10080633 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Doğuşdan sonrakı dövr (6 həftə)' WHERE idfsBaseReference = 10080633 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - فترة النّفاس ( 6 أسابيع )' WHERE idfsBaseReference = 10080633 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Pregnant' WHERE idfsBaseReference = 10080632 -- old value 'Basic Syndromic Surveillance Form - Pregnant'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Pregnant' WHERE idfsBaseReference = 10080632 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - ორსული' WHERE idfsBaseReference = 10080632 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Hamilə' WHERE idfsBaseReference = 10080632 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - حامل ' WHERE idfsBaseReference = 10080632 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Result Date' WHERE idfsBaseReference = 10080670 -- old value 'Basic Syndromic Surveillance Form - Result Date'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Result Date' WHERE idfsBaseReference = 10080670 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - შედეგის თარიღი' WHERE idfsBaseReference = 10080670 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Nəticənin tarixi' WHERE idfsBaseReference = 10080670 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - تاريخ النتيجة' WHERE idfsBaseReference = 10080670 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Sample Collection Date' WHERE idfsBaseReference = 10080667 -- old value 'Basic Syndromic Surveillance Form - Sample Collection Date'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Sample Collection Date' WHERE idfsBaseReference = 10080667 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - ნიმუშის აღების თარიღი' WHERE idfsBaseReference = 10080667 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Nümunənin toplama tarixi' WHERE idfsBaseReference = 10080667 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - تاريخ جمع العينات ' WHERE idfsBaseReference = 10080667 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Sample ID' WHERE idfsBaseReference = 10080668 -- old value 'Basic Syndromic Surveillance Form - Sample ID'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Sample ID' WHERE idfsBaseReference = 10080668 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - ნიმუშის ID' WHERE idfsBaseReference = 10080668 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Nümunənin Q/N-si' WHERE idfsBaseReference = 10080668 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - معرّف العينة ' WHERE idfsBaseReference = 10080668 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Seasonal Flu Vaccine' WHERE idfsBaseReference = 10080648 -- old value 'Basic Syndromic Surveillance Form - Seasonal Flu Vaccine'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Seasonal Flu Vaccine' WHERE idfsBaseReference = 10080648 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - სეზონური გრიპის ვაქცინა' WHERE idfsBaseReference = 10080648 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Qripə qarşı peyvənd' WHERE idfsBaseReference = 10080648 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - لقاح الانفلونزا الموسمية' WHERE idfsBaseReference = 10080648 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Shortness of Breath' WHERE idfsBaseReference = 10080647 -- old value 'Basic Syndromic Surveillance Form - Shortness of Breath'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Shortness of Breath' WHERE idfsBaseReference = 10080647 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - ქოშინი' WHERE idfsBaseReference = 10080647 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Təngnəfəslik' WHERE idfsBaseReference = 10080647 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - ضيق التنفس ' WHERE idfsBaseReference = 10080647 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Test Result' WHERE idfsBaseReference = 10080669 -- old value 'Basic Syndromic Surveillance Form - Test Result'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Test Result' WHERE idfsBaseReference = 10080669 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - ტესტის შედეგი' WHERE idfsBaseReference = 10080669 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Testin nəticəsi' WHERE idfsBaseReference = 10080669 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - نتيجة الاختبار ' WHERE idfsBaseReference = 10080669 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - Treatment included artificial ventilation of lungs?' WHERE idfsBaseReference = 10080653 -- old value 'Basic Syndromic Surveillance Form - Treatment included artificial ventilation of lungs?'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - Treatment included artificial ventilation of lungs?' WHERE idfsBaseReference = 10080653 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - მკურნალობა მოიცავდა ფილტვების ხელოვნურ ვენტილაციას?' WHERE idfsBaseReference = 10080653 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - Müalicə zamanı ağciyərlərin süni ventilyasiyası aparatından istifadə olunubmu?' WHERE idfsBaseReference = 10080653 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - هل يشمل العلاج التهوية الاصتناعية للرئتين ؟' WHERE idfsBaseReference = 10080653 AND idfsLanguage = 10049011

--UPDATE dbo.trtBaseReference SET strDefault = N'Human Disease Report - Syndrome - WHO Age Group' WHERE idfsBaseReference = 10080672 -- old value 'Basic Syndromic Surveillance Form - WHO Age Group'
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'Human Disease Report - Syndrome - WHO Age Group' WHERE idfsBaseReference = 10080672 AND idfsLanguage = 10049003
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'ადამიანის დაავადების ანგარიში - სინდრომი - ჯანმო-ს ასაკობრივი ჯგუფი' WHERE idfsBaseReference = 10080672 AND idfsLanguage = 10049004
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'İnsan Xəstəliyi üzrə Hesabat - Sindrom - ÜST Yaş qrupu' WHERE idfsBaseReference = 10080672 AND idfsLanguage = 10049001
--UPDATE dbo.trtStringNameTranslation SET strTextString = N'تقرير عن الامراض البشرية -  متلازمة - الفئة العمرية لمنظمة الصحة العالمية ' WHERE idfsBaseReference = 10080672 AND idfsLanguage = 10049011

ALTER TABLE trtBaseReference ENABLE TRIGGER ALL
ALTER TABLE dbo.trtStringNameTranslation ENABLE TRIGGER ALL

GO