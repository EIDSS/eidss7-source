
-- TODO: Specify the code of the language which translations shall be inserted/updated
declare @LanguageCode nvarchar(100)
set @LanguageCode = 'az-Latn-AZ'

-- Do not modify the code below except values for the table with translations
SET XACT_ABORT ON 
SET NOCOUNT ON 

declare @idfsLanguage bigint
set @idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageCode)

declare @idfsLanguageEn bigint
set @idfsLanguageEn = dbo.FN_GBL_LanguageCode_GET('en-US')


declare	@Error	int
set	@Error = 0

declare	@ErrorMsg	nvarchar(MAX)
set	@ErrorMsg = N''


BEGIN TRAN

BEGIN TRY


if @idfsLanguageEn is not null and @idfsLanguage is not null
    and (@LanguageCode = 'en-US' collate Cyrillic_General_CI_AS 
			or @idfsLanguage <> @idfsLanguageEn)
begin

PRINT N'Creating #NewTranslationsMenu at ' + CAST(GETDATE() AS NVARCHAR(24))

IF OBJECT_ID('tempdb..#NewTranslationsMenu') IS NOT NULL
BEGIN
	exec sp_executesql N'drop table #NewTranslationsMenu'
END

IF OBJECT_ID('tempdb..#NewTranslationsMenu') IS NULL
CREATE TABLE #NewTranslationsMenu (
    ID BIGINT PRIMARY KEY,
    NewTranslation NVARCHAR(200) collate Cyrillic_General_CI_AS
)

truncate table #NewTranslationsMenu



PRINT N'Creating #NewTranslationsAppObject at ' + CAST(GETDATE() AS NVARCHAR(24))

IF OBJECT_ID('tempdb..#NewTranslationsAppObject') IS NOT NULL
BEGIN
	exec sp_executesql N'drop table #NewTranslationsAppObject'
END

IF OBJECT_ID('tempdb..#NewTranslationsAppObject') IS NULL
CREATE TABLE #NewTranslationsAppObject (
    ID BIGINT PRIMARY KEY,
    NewTranslation NVARCHAR(200) collate Cyrillic_General_CI_AS
)

truncate table #NewTranslationsAppObject

PRINT N''
PRINT N''

--TODO: Add/Replace data from CSV/Excel file below into two tables
PRINT(N'Add rows to #NewTranslationsMenu')
INSERT INTO #NewTranslationsMenu VALUES
(10506057,N'Parolu dəyiş'),
(10506058,N'Təhlükəsizlik Siyasəti'),
(10506059,N'İstifadəçi Qrupları'),
(10506060,N'Sistem Funksiyaları'),
(10506061,N'YXEMS Saytları'),
(10506062,N'Təhlükəsizlik Hadisələri jurnalı'),
(10506063,N'Sistem Hadisələri jurnalı'),
(10506064,N'Audit Məlumatlarının fəaliyyəti Jurnalı'),
(10506065,N'İnterfeys Redaktoru'),
(10506066,N'İstinad Redaktorları'),
(10506067,N'Əsas İstinad Redaktoru'),
(10506068,N'Xəstəliklər'),
(10506069,N'Tədbirlər'),
(10506070,N'Nümunə Növləri'),
(10506071,N'Keçirici Növləri'),
(10506072,N'Keçiricilərin Heyvan Növləri'),
(10506073,N'Heyvan/Quş Növləri'),
(10506074,N'Hadisənin Təsnifatları'),
(10506075,N'Hesabatın Xəstəlik Qrupları'),
(10506076,N'Ümumi Statistik Növlər'),
(10506077,N'Yaş Qrupları'),
(10506078,N'Cəmləşdirilmiş İnsan Xəstəlik Hesabatı Matriksi'),
(10506079,N'Qrupşəkilli Baytarlıq Xəstəlik Hesabatın Matriksi'),
(10506080,N'Baytarlıq Diaqnostik Tədqiqatlar Matriksi'),
(10506081,N'Baytarlıq Profilaktik Tədbirlərin Matriksi'),
(10506082,N'Baytarlıq Sanitariya Tədbirlərin Matriksi'),
(10506083,N'Heyvan növləri - Heyvanın yaşı Matriksi'),
(10506084,N'Nümunə Növü - Törəmə Növü Matriksi'),
(10506085,N'Xəstəlik - Nümunə növü matriksi'),
(10506086,N'Xəstəlik - Laborator Test Matriksi'),
(10506087,N'Xəstəlik - Təcili Test Matriksi'),
(10506088,N'Test - Test nəticəsi matriksi'),
(10506089,N'Keçiricilərin növləri - Toplama üsulları matriksi'),
(10506056,N'Təhlükəsizlik'),
(10506055,N'Statistik Məlumatlar'),
(10506054,N'Yaşayış Məntəqələrin Növləri'),
(10506053,N'Təşkilatlar'),
(10506052,N'İşçilər'),
(10506051,N'Xəbərdarlıqlara Abunə Olmaq'),
(10506050,N'Məlumatların arxivləşmə prosesinin köklənməsi'),
(10506049,N'Arxiv məlumatlarına Qoşulmaq'),
(10506047,N'Nümunələrin saxlanılma yeri'),
(10506046,N'Qrupşəkilli testlər'),
(10506045,N'Təsdiqlər'),
(10506044,N'Testlər'),
(10506043,N'Ötürülmüş Nümunələr'),
(10506042,N'Nümunələr'),
(10506041,N'Müşahidə Sessiyası'),
(10506040,N'Alovlanma'),
(10506038,N'Epi INFO-ya keçid'),
(10506037,N'Müşahidə Sessiyası'),
(10506036,N'Müşahidə Kampaniyası'),
(10506035,N'Qrupşəkilli Tədbirlərin Yekun hesabatı'),
(10506034,N'Qrupşəkilli Tədbirlər'),
(10506033,N'Qrupşəkilli Hesabatların Yekun forması'),
(10506032,N'Qrupşəkilli Hesabat'),
(10506031,N'Yayılmanın təhlili'),
(10506030,N'Heyvanlar arasında Xəstəlik Hesabatı'),
(10506029,N'Quşlar arasında Xəstəlik Hesabatı'),
(10506028,N'Heyvanlar arasında Xəstəlik Hesabatı'),
(10506027,N'Quşlar arasında Xəstəlik Hesabatı'),
(10506026,N'Ferma'),
(10506025,N'Ferma'),
(10506022,N'ÜST-na idxal'),
(10506021,N'Yayılmanın təhlili'),
(10506020,N'Müşahidə Sessiyası'),
(10506019,N'Müşahidə Kampaniyası'),
(10506018,N'Çəmləşdirilmiş Hesabatın Yekun forması'),
(10506017,N'Cəmləşdirilmiş Hesabat'),
(10506016,N'İnsan xəstəliyi üzrə hesabat'),
(10506015,N'Xəstəlik Hesabatı'),
(10506014,N'Şəxs'),
(10506013,N'Şəxs'),
(10506012,N'İstifadəçinin ayarları'),
(10506011,N'Dil'),
(10506010,N'Sistemdən Çıxış'),
(10506009,N'Hesabatlar'),
(10506008,N'Konfiqurasiya'),
(10506007,N'İdarəetmə'),
(10506006,N'Laboratoriya'),
(10506005,N'Keçiricilər'),
(10506004,N'Alovlanma'),
(10506003,N'Baytarlıq'),
(10506002,N'İnsan'),
(10506090,N'Keçiricilərin növləri - Nümunə növünün matriksi'),
(10506091,N'Keçiricilərin növləri - Təcili testlər matriksi'),
(10506092,N'Xəstəlik - Yaş Qrupları Matriksi'),
(10506093,N'Hesabatın Diaqnozlar Qrupu - Diaqnozlar Matriksi'),
(10506094,N'Köklənilən hesabatların sətirləri'),
(10506095,N'Yaş Qrupu - Statistik Yaş Qrupu Matriksi'),
(10506096,N'Xəstəlik qrupu - Xəstəlik matriksi'),
(10506097,N'Parametr Növlərinin Redaktəedicisi'),
(10506098,N'Obyektlərin unikal nömrələmə sxemi'),
(10506099,N'Qrupşəkilli Parametrlər'),
(10506100,N'Xəritənin köklənməsi'),
(10506101,N'Kağız formaları'),
(10506102,N'Standart hesabatlar'),
(10506103,N'İnsan modulu üzrə Hesabatlar'),
(10506104,N'Baytarlıq modulu üzrə Hesabatlar'),
(10506105,N'Laborator modulu üzrə Hesabatlar'),
(10506107,N'Inzibati Hesabatlar'),
(10506108,N'Barkodların Çapı'),
(10506109,N'Insan Xəstəlikləri Üzrə Hesabat'),
(10506110,N'Insan Xəstəlikləri Üzrə Cəmləşdirilmiş Hesabat'),
(10506111,N'İnsanlar arasında Fəal Müşahidə Kampaniyası'),
(10506112,N'İnsanlar arasında Fəal Müşahidə Sessiyası'),
(10506113,N'Şəxs'),
(10506114,N'Alovlanma'),
(10506115,N'Ferma'),
(10506116,N'Quşlar arasında Xəstəlik Hesabatı'),
(10506117,N'Heyvanlar arasında Xəstəlik Hesabatı'),
(10506118,N'Heyvan Xəstəlikləri Üzrə Hesabatlar'),
(10506119,N'Qrupşəkilli Baytarlıq Xəstəliklərin Hesabatı'),
(10506120,N'Qrupşəkilli baytarlıq tədbirləri'),
(10506121,N'Baytarlıq Fəal Müşahidə Sessiyaları'),
(10506122,N'Nümunələri axtar'),
(10506123,N'Testlər'),
(10506124,N'Nümunənin ötürülməsi'),
(10506125,N'Təsdiqlər'),
(10506126,N'Seçdiklərim'),
(10506127,N'Keçiricilərin toplanması'),
(10506128,N'Təlim videoları'),
(10506129,N'Bildirişlər'),
(10506130,N'Mənim bildirişlərim'),
(10506131,N'Mənim tədqiqatlarım'),
(10506132,N'Tədqiqatlar'),
(10506133,N'Qəbul olunmamış Nümunələr'),
(10506134,N'Təsdiqlər'),
(10506135,N'Mənim seçdirklərim'),
(10506136,N'İstifadəçilər'),
(10506137,N'Kağız formaları yüklə'),
(10506138,N'Təlim videoları'),
(10506139,N'Sistem Kökləmələri'),
(10506140,N'İşçilər'),
(10506141,N'İstifadəçi qrupları'),
(10506142,N'Saytlar'),
(10506143,N'Təşkilatlar'),
(10506144,N'Yaşayış məntəqələri'),
(10506145,N'QBX cəmləşdirilmiş forma'),
(10506146,N'Dedublikasiya'),
(10506147,N'Dəyişdirilən Formaların Parametrlərin Redaktoru'),
(10506148,N'Dəyişdirilən Formaların Tərtibatçısı'),
(10506149,N'QBX Yayılmanın Təhlili'),
(10506150,N'Aylıq Xəstələnmə Və Ölüm Göstəriciləri'),
(10506151,N'Ilkin Və Yekun Diaqnozlar Arasında Uyğunluq'),
(10506152,N'Baytarlıq üzrə illik vəziyyət'),
(10506153,N'Baytarlıq Fəal Müşahidəsi'),
(10506154,N'Xəstəlik - İnsan Cinsi Matriksi'),
(10506155,N'Fərdi Identifikasiya Növü Matriksi'),
(10506156,N'Saytlar'),
(10506157,N'Sayt qrupları'),
(10506160,N'Sistem kökləmələri'),
(10506161,N'Quduzluq Hadisələrin Siyahısı Avropa Bülleteni üçün - Rüblük Müşahidə Vərəqəsi'),
(10506162,N'İllərin aylar üzrə müqayisəli hesabatı'),
(10506163,N'Yoluxucu Xəstəliklərin/Vəziyyətlərin Müqayisəli Hesabatı (aylar üzrə)'),
(10506164,N'Seroloji Tədqiqat Nəticəsi'),
(10506165,N'Antibiotiklərə həssaslıq Kartı (NCDC&PH)'),
(10506166,N'Antibiotiklərə həssaslıq Kartı (LMA)'),
(10506167,N'60B Jurnalı'),
(10506168,N'Müəyyən Xəstəliklər/Şəraitlər Haqqında Hesabat (Aylıq Forma IV-03)'),
(10506169,N'İnzibati hadisələr jurnalı'),
(10506170,N'Aylıq Forma IV-03 üzrə Aralıq Hesabat'),
(10506171,N'ÜST - Məxmərək/Qızılça üzrə hesabat'),
(10506172,N'Hesabatların köhnə versiyası'),
(10506173,N'Müəyyən Xəstəliklər/Şəraitlər Haqqında Hesabat (Aylıq Forma IV-03 - SN 01-82/N əmrinə uyğun)'),
(10506174,N'Aylıq Forma IV-03 üzrə Aralıq Hesabat (SN 01-82/N əmrinə uyğun)'),
(10506175,N'Müəyyən Xəstəliklər/Şəraitlər Haqqında Hesabat (Aylıq Forma IV-03 - SN 01-27/N əmrinə uyğun)'),
(10506176,N'Aylıq Forma IV-03 üzrə Aralıq Hesabat (SN 01-27/N əmrinə uyğun)'),
(10506177,N'İllik Hesabat Verilən Yoluxucu Xəstəliklər Haqqında Hesabat (İllik Forma IV-03 - SN 101/N Sərəncamına uyğun olaraq)'),
(10506178,N'Illik Forma IV-03 üzrə Aralıq Hesabat (SN 101/N əmrinə uyğun)'),
(10506179,N'Yoluxucu Xəstəliklər Haqqında Hesabat (Aylıq Forma IV-03/1 - SN 101/N Sərəncamına uyğun olaraq)'),
(10506180,N'Aylıq Forma IV-0/13 üzrə Aralıq Hesabat (SN 101/N əmrinə uyğun)'),
(10506181,N'1 nömrəli forma (A3)'),
(10506182,N'1 nömrəli forma (A4)'),
(10506183,N'Müqayisəli hesabat'),
(10506184,N'Mikrobioloji Tədqiqat Nəticəsi'),
(10506185,N'Xarici müqayisəli hesabat'),
(10506186,N'Daxil edilən məlumatın keyfiyyət indikatorları'),
(10506187,N'Yoluxucu xəstəliklərin rayonlar və diaqnozlar üzrə hesabatı'),
(10506188,N'Həftəlik Hesabat Forması'),
(10506189,N'Həftəlik Hesabat Yekun Forması'),
(10506190,N'Kəskin Süst Ifliç Üzərində Nəzarətin Əsas Indikatorları'),
(10506191,N'Kəskin Süst Ifliç Üzərində Nəzarətin Əlavə Indikatorları'),
(10506192,N'İllərin aylar üzrə müqayisəli hesabatı'),
(10506193,N'Laborator Müayinəyə Göndəriş'),
(10506194,N'Laborator Müayinənin Nəticələri'),
(10506195,N'Baytarlıq hesabatı Forma Vet1'),
(10506196,N'İnzibati Hesabatın Audit jurnalı'),
(10506197,N'Baytarlıq hesabatı Forma Vet1A'),
(10506198,N'Toplu baytarlıq hesabatı'),
(10506199,N'Baytarlıq Laboratoriyalarında görülmüş işlər üzrə hesabat'),
(10506200,N'Baytarlıq məlumatın keyfiyyət indikatorları'),
(10506201,N'Konfiqurasiya edilə bilən saytlar arasında filtrasiya'),
(10506202,N'Baytarlıq üzrə xəstəlik hadisələrinin hesabatı'),
(10506203,N'Sadələşdirilmiş analiz'),
(10506204,N'Daxil edilən məlumatın keyfiyyət indikatorları (Rayonlar)'),
(10506205,N'Həmsərhəd rayonların xəstələnməsi üzrə müqayisəli hesabat'),
(10506206,N'ÜST - Məxmərək/Qızılça üzrə hesabat'),
(10506207,N'İİV-a müayinə olunmuş vərəm xəstəlik hadisələr üzrə hesabat '),
(10506208,N'Zoonoz xəstəlikləri üzrə müqayisəli hesabat (aylar üzrə)'),
(10506209,N'Zoonoz üzrə Hesabatlar'),
(10506210,N'Zoonoz xəstəlikləri üzrə müqayisəli hesabat (aylar üzrə)'),
(10506212,N'İnzibati Vahidlər'),
(10506213,N'Arxiv məlumatlarına Qoşulmaq'),
(10506214,N'İnterfeys Redaktoru'),
(10506216,N'İnsan Xəstəliyi üzrə Tədqiqat forması'),
(10506217,N'Quş xəstəliyi üzrə tədqiqat forması'),
(10506218,N'Heyvan xəstəliyi üzrə tədqiqat forması'),
(10506219,N'YXEMS7 İdarəetmə lövhəsi');


declare @N int
set @N =
	(	select	count(*)
		from	#NewTranslationsMenu
	)
PRINT(N'Operation applied to ' + cast(@N as nvarchar(20)) + N' rows in the table #NewTranslationsMenu')
PRINT N''


PRINT(N'Add rows to #NewTranslationsAppObject')
INSERT INTO #NewTranslationsAppObject VALUES
(10506002,N'İnsan'),
(10506003,N'Baytarlıq'),
(10506004,N'Alovlanma'),
(10506005,N'Keçiricilər'),
(10506006,N'Laboratoriya'),
(10506007,N'İdarəetmə'),
(10506008,N'Konfiqurasiya'),
(10506009,N'Hesabatlar'),
(10506010,N'Sistemdən Çıxış'),
(10506011,N'Dil'),
(10506012,N'İstifadəçinin ayarları'),
(10506013,N'Şəxs'),
(10506014,N'Şəxs'),
(10506015,N'Xəstəlik hesabatı'),
(10506016,N'İnsan xəstəliyi üzrə hesabat'),
(10506017,N'Cəmləşdirilmiş Hesabat'),
(10506018,N'Çəmləşdirilmiş Hesabatın Yekun forması'),
(10506019,N'Müşahidə Kampaniyası'),
(10506020,N'Müşahidə Sessiyası'),
(10506021,N'Yayılmanın təhlili'),
(10506022,N'ÜST-na idxal'),
(10506025,N'Ferma'),
(10506026,N'Ferma'),
(10506027,N'Quşlar arasında xəstəlik Hesabatı'),
(10506028,N'Heyvanlar arasında xəstəlik Hesabatı'),
(10506029,N'Quşlar arasında xəstəlik Hesabatı'),
(10506030,N'Heyvanlar arasında xəstəlik Hesabatı'),
(10506031,N'Yayılmanın təhlili'),
(10506032,N'Qrupşəkilli Hesabat'),
(10506033,N'Qrupşəkilli Hesabatların Yekun forması'),
(10506034,N'Qrupşəkilli Tədbirlər'),
(10506035,N'Qrupşəkilli Tədbirlərin Yekun Hesabatı'),
(10506036,N'Müşahidə Kampaniyası'),
(10506037,N'Müşahidə Sessiyası'),
(10506040,N'Alovlanma'),
(10506041,N'Müşahidə Sessiyası'),
(10506042,N'Nümunələr'),
(10506043,N'Ötürülmüş Nümunələr'),
(10506044,N'Testlər'),
(10506045,N'Təsdiqlər'),
(10506046,N'Qrupşəkilli testlər'),
(10506047,N'Nümunələrin saxlanılma yeri'),
(10506050,N'Məlumatların arxivləşmə prosesinin köklənməsi'),
(10506051,N'Xəbərdarlıqlara Abunə Olmaq'),
(10506052,N'İşçilər'),
(10506053,N'Təşkilatlar'),
(10506054,N'Yaşayış Məntəqələrin Növləri'),
(10506055,N'Statistik məlumatlar'),
(10506056,N'Təhlükəsizlik'),
(10506058,N'Təhlükəsizlik Siyasəti'),
(10506059,N'İstifadəçi Qrupları'),
(10506060,N'Sistem Funksiyaları'),
(10506062,N'Təhlükəsizlik Hadisələri jurnalı'),
(10506063,N'Sistem Hadisələri jurnalı'),
(10506064,N'Audit Məlumatlarının fəaliyyəti Jurnalı'),
(10506065,N'İnterfeys Redaktoru'),
(10506066,N'İstinad Redaktorları'),
(10506067,N'Əsas İstinad Redaktoru'),
(10506068,N'Xəstəliklər'),
(10506069,N'Tədbirlər'),
(10506070,N'Nümunə Növləri'),
(10506071,N'Keçirici növləri'),
(10506072,N'Keçiricilərin Heyvan Növləri'),
(10506073,N'Heyvan/Quş Növləri'),
(10506074,N'Hadisənin Təsnifatları'),
(10506075,N'Hesabatın Xəstəlik Qrupları'),
(10506076,N'Ümumi Statistik Növlər'),
(10506077,N'Yaş Qrupları'),
(10506078,N'Cəmləşdirilmiş İnsan Xəstəlik Hesabatı Matriksi'),
(10506079,N'Qrupşəkilli Baytarlıq Xəstəlik Hesabatın Matriksi'),
(10506080,N'Baytarlıq Diaqnostik Tədqiqatlar Matriksi'),
(10506081,N'Baytarlıq Profilaktik Tədbirlərin Matriksi'),
(10506082,N'Baytarlıq Sanitariya Tədbirlərin Matriksi'),
(10506083,N'Heyvan növləri - Heyvanın yaşı Matriksi'),
(10506084,N'Nümunə Növü - Törəmə Növü Matriksi'),
(10506085,N'Xəstəlik - Nümunə Növü Matriksi'),
(10506086,N'Xəstəlik - Laborator Test Matriksi'),
(10506087,N'Xəstəlik - Təcili Test Matriksi'),
(10506088,N'Test - Test Nəticəsi Matriksi'),
(10506089,N'Keçiricilərin növləri - Toplama üsulları matriksi'),
(10506090,N'Keçiricilərin növləri - Nümunə növünün matriksi'),
(10506091,N'Keçiricilərin növləri - Təcili testlər matriksi'),
(10506092,N'Xəstəlik - Yaş Qrupları Matriksi'),
(10506093,N'Hesabatın Diaqnozlar Qrupu - Diaqnozlar Matriksi'),
(10506094,N'Köklənilən Hesabatların Sətirləri'),
(10506095,N'Yaş Qrupu - Statistik Yaş Qrupu Matriksi'),
(10506096,N'Xəstəlik Qrupu - Xəstəlik Matriksi'),
(10506097,N'Parametr Növlərinin Redaktəedicisi'),
(10506098,N'Obyektlərin Unikal Nömrələmə Sxemi'),
(10506099,N'Qrupşəkilli Parametrlər'),
(10506101,N'Kağız formaları'),
(10506102,N'Standart Hesabatlar'),
(10506103,N'İnsan modulu üzrə Hesabatlar'),
(10506104,N'Baytarlıq modulu üzrə Hesabatlar'),
(10506105,N'Laborator modulu üzrə Hesabatlar'),
(10506107,N'Inzibati Hesabatlar'),
(10506108,N'Barkodların Çapı'),
(10506109,N'Insan Xəstəlikləri Üzrə Hesabat'),
(10506110,N'Insan Xəstəlikləri Üzrə Cəmləşdirilmiş Hesabat'),
(10506111,N'İnsanlar arasında Fəal Müşahidə Kampaniyası'),
(10506112,N'İnsanlar arasında Fəal Müşahidə Sessiyası'),
(10506113,N'Şəxs'),
(10506114,N'Alovlanma'),
(10506115,N'Ferma'),
(10506116,N'Quşlar arasında Xəstəlik Hesabatı'),
(10506117,N'Heyvanlar arasında Xəstəlik Hesabatı'),
(10506118,N'Heyvan Xəstəlikləri Üzrə Hesabatlar'),
(10506119,N'Qrupşəkilli Baytarlıq Xəstəliklərin Hesabatı'),
(10506120,N'Qrupşəkilli Baytarlıq Tədbirləri'),
(10506121,N'Baytarlıq Fəal Müşahidə Sessiyaları'),
(10506122,N'Nümunələri Axtar'),
(10506123,N'Testlər'),
(10506124,N'Nümunənin ötürülməsi'),
(10506125,N'Təsdiqlər'),
(10506126,N'Seçdiklərim'),
(10506127,N'Keçiricilərin Toplanması'),
(10506128,N'Təlim Videoları'),
(10506129,N'Bildirişlər'),
(10506130,N'Mənim Bildirişlərim'),
(10506131,N'Mənim Tədqiqatlarım'),
(10506132,N'Tədqiqatlar'),
(10506133,N'Qəbul Olunmamış Nümunələr'),
(10506134,N'Təsdiqlər'),
(10506135,N'Mənim seçdirklərim'),
(10506136,N'İstifadəçilər'),
(10506137,N'Kağız Formaları Yüklə'),
(10506138,N'Təlim Videoları'),
(10506139,N'Sistem Kökləmələri'),
(10506140,N'İşçilər'),
(10506141,N'İstifadəçi qrupları'),
(10506142,N'Saytlar'),
(10506143,N'Təşkilatlar'),
(10506144,N'Yaşayış Məntəqələri'),
(10506145,N'QBX Cəmləşdirilmiş Forma'),
(10506146,N'Dedublikasiya'),
(10506148,N'Dəyişdirilən Formaların Tərtibatçısı'),
(10506149,N'QBX Yayılmanın Təhlili'),
(10506150,N'Aylıq Xəstələnmə Və Ölüm Göstəriciləri'),
(10506151,N'Ilkin Və Yekun Diaqnozlar Arasında Uyğunluq'),
(10506152,N'Baytarlıq Üzrə Illik Vəziyyət'),
(10506153,N'Baytarlıq Fəal Müşahidəsi'),
(10506154,N'Xəstəlik - İnsan Cinsi Matriksi'),
(10506155,N'Fərdi Identifikasiya Növü Matriksi'),
(10506156,N'Saytlar'),
(10506157,N'Sayt Qrupları'),
(10506160,N'Sistem Kökləmələri'),
(10506161,N'Quduzluq Hadisələrin Siyahısı Avropa Bülleteni üçün - Rüblük Müşahidə Vərəqəsi'),
(10506162,N'İllərin aylar üzrə Müqayisəli Hesabatı'),
(10506163,N'Yoluxucu Xəstəliklərin/Vəziyyətlərin Müqayisəli Hesabatı (aylar üzrə)'),
(10506164,N'Seroloji Tədqiqat Nəticəsi'),
(10506165,N'Antibiotiklərə həssaslıq Kartı (NCDC&PH)'),
(10506166,N'Antibiotiklərə həssaslıq Kartı (LMA)'),
(10506167,N'60B Jurnalı'),
(10506168,N'Müəyyən Xəstəliklər/Şəraitlər Haqqında Hesabat (Aylıq Forma IV-03)'),
(10506169,N'İnzibati hadisələr jurnalı'),
(10506170,N'Aylıq Forma IV-03 üzrə Aralıq Hesabat'),
(10506172,N'Hesabatların köhnə versiyası'),
(10506173,N'Müəyyən Xəstəliklər/Şəraitlər Haqqında Hesabat (Aylıq Forma IV-03 - SN 01-82/N əmrinə uyğun)'),
(10506174,N'Aylıq Forma IV-03 üzrə Aralıq Hesabat (SN 01-82/N əmrinə uyğun)'),
(10506175,N'Müəyyən Xəstəliklər/Şəraitlər Haqqında Hesabat (Aylıq Forma IV-03 - SN 01-27/N əmrinə uyğun)'),
(10506176,N'Aylıq Forma IV-03 üzrə Aralıq Hesabat (SN 01-27/N əmrinə uyğun)'),
(10506177,N'İllik Hesabat Verilən Yoluxucu Xəstəliklər Haqqında Hesabat (İllik Forma IV-03 - SN 101/N Sərəncamına uyğun olaraq)'),
(10506178,N'Illik Forma IV-03 üzrə Aralıq Hesabat (SN 101/N əmrinə uyğun)'),
(10506179,N'Yoluxucu Xəstəliklər Haqqında Hesabat (Aylıq Forma IV-03/1 - SN 101/N Sərəncamına uyğun olaraq)'),
(10506180,N'Aylıq Forma IV-0/13 üzrə Aralıq Hesabat (SN 101/N əmrinə uyğun)'),
(10506181,N'1 Nömrəli Forma (A3)'),
(10506182,N'1 Nömrəli Forma (A4)'),
(10506183,N'Müqayisəli Hesabat'),
(10506184,N'Mikrobioloji Tədqiqat Nəticəsi'),
(10506185,N'Xarici Müqayisəli Hesabat'),
(10506186,N'Daxil Edilən Məlumatın Keyfiyyət Indikatorları'),
(10506187,N'Yoluxucu xəstəliklərin rayonlar və diaqnozlar üzrə hesabatı'),
(10506188,N'Həftəlik Hesabat Forması'),
(10506189,N'Həftəlik Hesabat Yekun Forması'),
(10506190,N'Kəskin Süst Ifliç Üzərində Nəzarətin Əsas Indikatorları'),
(10506191,N'Kəskin Süst Ifliç Üzərində Nəzarətin Əlavə Indikatorları'),
(10506192,N'İllərin aylar üzrə müqayisəli hesabatı'),
(10506193,N'Laborator Müayinəyə Göndəriş'),
(10506194,N'Laborator Müayinənin Nəticələri'),
(10506195,N'Baytarlıq Hesabatı Forma Vet1'),
(10506196,N'İnzibati Hesabatın Audit jurnalı'),
(10506197,N'Baytarlıq Hesabatı Forma Vet1A'),
(10506198,N'Toplu baytarlıq hesabatı'),
(10506199,N'Baytarlıq Laboratoriyalarında görülmüş işlər üzrə hesabat'),
(10506200,N'Baytarlıq məlumatın keyfiyyət indikatorları'),
(10506201,N'Konfiqurasiya edilə bilən saytlar arasında filtrasiya'),
(10506202,N'Baytarlıq üzrə xəstəlik hadisələrinin hesabatı'),
(10506203,N'Sadələşdirilmiş analiz'),
(10506204,N'Daxil edilən məlumatın keyfiyyət indikatorları (Rayonlar)'),
(10506205,N'Həmsərhəd Rayonların Xəstələnməsi Üzrə Müqayisəli Hesabat'),
(10506207,N'İİV-a müayinə olunmuş vərəm xəstəlik hadisələr üzrə hesabat '),
(10506208,N'Zoonoz xəstəlikləri üzrə müqayisəli hesabat (aylar üzrə)'),
(10506209,N'Zoonoz üzrə Hesabatlar'),
(10506210,N'Zoonoz xəstəlikləri üzrə müqayisəli hesabat (aylar üzrə)'),
(10506212,N'İnzibati Vahidlər'),
(10506216,N'İnsan Xəstəliyi üzrə Tədqiqat forması'),
(10506217,N'Quş xəstəliyi üzrə tədqiqat forması'),
(10506218,N'Heyvan xəstəliyi üzrə tədqiqat forması'),
(10506219,N'YXEMS7 İdarəetmə lövhəsi');


-- Do not modify the code below except values for the table with translations

set @N =
	(	select	count(*)
		from	#NewTranslationsAppObject
	)
PRINT(N'Operation applied to ' + cast(@N as nvarchar(20)) + N' rows in the table #NewTranslationsAppObject')
PRINT N''
PRINT N''
--------------Select not existing items which translations have been provided----------------------

declare @N1 int
declare @N2 int
set @N1 =
	(	select		count(*)
		from		#NewTranslationsMenu t
		left join	trtBaseReference r
		on			r.idfsBaseReference = t.[ID]
		where		r.idfsBaseReference is null
	)
set @N2 =
	(	select		count(*)
		from		#NewTranslationsAppObject t
		left join	trtBaseReference r
		on			r.idfsBaseReference = t.[ID]
		where		r.idfsBaseReference is null
	)
set @N = @N1 + @N2

if @N > 0
begin
	if @N1 > 0
	begin
		if @N1 = 1
			print N'!!!!!There is ' + cast(@N1 as nvarchar(20)) + N' not existing menu item, which translation has been provided!!!!'
		else
			print N'!!!!!There are ' + cast(@N1 as nvarchar(20)) + N' not existing menu items, which translations have been provided!!!!'

		select		t.*
		from		#NewTranslationsMenu t
		left join	trtBaseReference r
		on			r.idfsBaseReference = t.[ID]
		where		r.idfsBaseReference is null
	end

	if @N2 > 0
	begin
		if @N2 = 1
			print N'!!!!!There is ' + cast(@N2 as nvarchar(20)) + N' not existing dashboard object item, which translation has been provided!!!!'
		else
			print N'!!!!!There are ' + cast(@N2 as nvarchar(20)) + N' not existing dashboard object items, which translations have been provided!!!!'

		select		t.*
		from		#NewTranslationsAppObject t
		left join	trtBaseReference r
		on			r.idfsBaseReference = t.[ID]
		where		r.idfsBaseReference is null
	end

	if @N = 1
		print N'No translations will be applied. Add missing item to the database or remove it from the corresponding table and execute script again.'
	else if @N1 = 0 or @N2 = 0
		print N'No translations will be applied. Add missing ' + cast(@N as nvarchar(20)) + N' items to the database or remove them from the corresponding table and execute script again.'
	else
		print N'No translations will be applied. Add missing ' + cast(@N as nvarchar(20)) + N' items to the database or remove them from the corresponding tables and execute script again.'

end
else begin

set @N1 =
	(	select		count(distinct t.[ID])
		from		#NewTranslationsMenu t
		cross apply
		(	select	count(*) as intCount
			from	#NewTranslationsMenu t_other
			where	t_other.[ID] = 	t.[ID]
		) num
		where		num.intCount > 1
	)
set @N2 =
	(	select		count(distinct t.[ID])
		from		#NewTranslationsAppObject t
		cross apply
		(	select	count(*) as intCount
			from	#NewTranslationsAppObject t_other
			where	t_other.[ID] = 	t.[ID]
		) num
		where		num.intCount > 1
	)
set @N = @N1 + @N2

if @N > 0
begin
	if @N1 > 0
	begin
		if @N1 = 1
			print N'!!!!!There is ' + cast(@N1 as nvarchar(20)) + N' duplicated menu item, which translations have been provided!!!!'
		else
			print N'!!!!!There are ' + cast(@N1 as nvarchar(20)) + N' duplicated menu items, which translations have been provided!!!!'

		select		distinct t.[ID]
		from		#NewTranslationsMenu t
		cross apply
		(	select	count(*) as intCount
			from	#NewTranslationsMenu t_other
			where	t_other.[ID] = 	t.[ID]
		) num
		where		num.intCount > 1
	end

	if @N2 > 0
	begin
		if @N2 = 1
			print N'!!!!!There is ' + cast(@N2 as nvarchar(20)) + N' duplicated dashboard object item, which translation has been provided!!!!'
		else
			print N'!!!!!There are ' + cast(@N2 as nvarchar(20)) + N' duplicated dashboard object items, which translations have been provided!!!!'

		select		distinct t.[ID]
		from		#NewTranslationsAppObject t
		cross apply
		(	select	count(*) as intCount
			from	#NewTranslationsAppObject t_other
			where	t_other.[ID] = 	t.[ID]
		) num
		where		num.intCount > 1
	end

	if @N = 1
		print N'No translations will be applied. Remove duplicates of the item from the corresponding table and execute script again.'
	else if @N1 = 0 or @N2 = 0
		print N'No translations will be applied. Remove duplicates of ' + cast(@N as nvarchar(20)) + N' items from the corresponding table and execute script again.'
	else
		print N'No translations will be applied. Remove duplicates of ' + cast(@N as nvarchar(20)) + N' items from the corresponding tables and execute script again.'

end
else begin

set @N =
	(	select		count(distinct t1.[ID])
		from		#NewTranslationsAppObject t2
		inner join	#NewTranslationsMenu t1
		on			t1.[ID] = t2.[ID]
					and t1.[NewTranslation] <> t2.[NewTranslation] collate Cyrillic_General_CI_AS
	)

if @N > 0
begin
	if @N = 1
		print N'!!!!!There is ' + cast(@N as nvarchar(20)) + N' duplicated item in menu and dashboard objects, which translations have been provided!!!!'
	else
		print N'!!!!!There are ' + cast(@N as nvarchar(20)) + N' duplicated items in menu and dashboard objects, which translations have been provided!!!!'

	select		distinct t1.[ID]
	from		#NewTranslationsAppObject t2
	inner join	#NewTranslationsMenu t1
	on			t1.[ID] = t2.[ID]
				and t1.[NewTranslation] <> t2.[NewTranslation] collate Cyrillic_General_CI_AS

	if @N = 1
		print N'No translations will be applied. Remove duplicates of the item from one of the tables and execute script again.'
	else
		print N'No translations will be applied. Remove duplicates of ' + cast(@N as nvarchar(20)) + N' items from one of the tables and execute script again.'

end
else begin

PRINT N'Processing #NewTranslationsMenu - ' + @LanguageCode + N' - at ' + CAST(GETDATE() AS NVARCHAR(24))
PRINT N''

PRINT N'Update existing translations of menu items'
UPDATE tsn
SET strTextString = ntm.NewTranslation,
	intRowStatus = 0,
	AuditUpdateUser = 'System',
	AuditUpdateDTM = GETUTCDATE(),
	SourceSystemNameID = 10519001 /*EIDSSv7*/,
	SourceSystemKeyValue = N'[{' + N'"idfsBaseReference":' + cast(ntm.[ID] as nvarchar(20)) + N',' + N'"idfsLanguage":' + cast(@idfsLanguage as nvarchar(20)) + N'}]' collate Cyrillic_General_CI_AS
FROM trtStringNameTranslation tsn
INNER JOIN #NewTranslationsMenu ntm ON tsn.idfsBaseReference = ntm.[ID] 
			and ntm.NewTranslation is not null and ltrim(rtrim(ntm.NewTranslation)) <> N'' collate Cyrillic_General_CI_AS
WHERE tsn.idfsLanguage = @idfsLanguage
		and (	tsn.strTextString is null
				or	tsn.strTextString <> ntm.NewTranslation collate Cyrillic_General_CI_AS
				or	tsn.intRowStatus <> 0
			)
print N'Updated records: ' + cast(@@rowcount as nvarchar(20))
print N''


PRINT N'Remove existing translations of menu items that shall be cleared'
UPDATE tsn
SET intRowStatus = 1,
	AuditUpdateUser = 'System',
	AuditUpdateDTM = GETUTCDATE(),
	SourceSystemNameID = 10519001 /*EIDSSv7*/,
	SourceSystemKeyValue = N'[{' + N'"idfsBaseReference":' + cast(ntm.[ID] as nvarchar(20)) + N',' + N'"idfsLanguage":' + cast(@idfsLanguage as nvarchar(20)) + N'}]' collate Cyrillic_General_CI_AS
FROM trtStringNameTranslation tsn
INNER JOIN #NewTranslationsMenu ntm ON tsn.idfsBaseReference = ntm.[ID] 
				and (ntm.NewTranslation is null or ltrim(rtrim(ntm.NewTranslation)) = N'' collate Cyrillic_General_CI_AS)
WHERE tsn.idfsLanguage = @idfsLanguage
		and tsn.intRowStatus <> 1
print N'Marked as deleted records: ' + cast(@@rowcount as nvarchar(20))
print N''

PRINT N'Insert missing translations of menu items'
insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus,
	strMaintenanceFlag,
	strReservedAttribute,
	SourceSystemNameID,
	SourceSystemKeyValue,
	AuditCreateUser,
	AuditCreateDTM,
	AuditUpdateUser,
	AuditUpdateDTM
)
select	ntm.[ID],
		@idfsLanguage,
		ntm.NewTranslation,
		0,
		null,
		null,
		10519001 /*EIDSSv7*/,
		N'[{' + N'"idfsBaseReference":' + cast(ntm.[ID] as nvarchar(20)) + N',' + N'"idfsLanguage":' + cast(@idfsLanguage as nvarchar(20)) + N'}]' collate Cyrillic_General_CI_AS,
		'System',
		GETUTCDATE(),
		'System',
		GETUTCDATE()
from	#NewTranslationsMenu ntm
inner join trtBaseReference br on br.idfsBaseReference = ntm.[ID]
inner join trtBaseReference lng on lng.idfsBaseReference = @idfsLanguage
left join trtStringNameTranslation tsn on tsn.idfsBaseReference = br.idfsBaseReference and tsn.idfsLanguage = lng.idfsBaseReference
where	ntm.NewTranslation is not null and ltrim(rtrim(ntm.NewTranslation)) <> N'' collate Cyrillic_General_CI_AS
		and tsn.idfsBaseReference is null
print N'Inserted records: ' + cast(@@rowcount as nvarchar(20))
print N''
print N''



PRINT N'Processing #NewTranslationsAppObject - ' + @LanguageCode + N' - at ' + CAST(GETDATE() AS NVARCHAR(24))
PRINT N''

PRINT N'Update existing translations of dashboard object items'
UPDATE tsn
SET strTextString = ntm.NewTranslation,
	intRowStatus = 0,
	AuditUpdateUser = 'System',
	AuditUpdateDTM = GETUTCDATE(),
	SourceSystemNameID = 10519001 /*EIDSSv7*/,
	SourceSystemKeyValue = N'[{' + N'"idfsBaseReference":' + cast(ntm.[ID] as nvarchar(20)) + N',' + N'"idfsLanguage":' + cast(@idfsLanguage as nvarchar(20)) + N'}]' collate Cyrillic_General_CI_AS
FROM trtStringNameTranslation tsn
INNER JOIN #NewTranslationsAppObject ntm ON tsn.idfsBaseReference = ntm.[ID] 
			and ntm.NewTranslation is not null and ltrim(rtrim(ntm.NewTranslation)) <> N'' collate Cyrillic_General_CI_AS
WHERE tsn.idfsLanguage = @idfsLanguage
		and (	tsn.strTextString is null
				or	tsn.strTextString <> ntm.NewTranslation collate Cyrillic_General_CI_AS
				or	tsn.intRowStatus <> 0
			)
print N'Updated records: ' + cast(@@rowcount as nvarchar(20))
print N''


PRINT N'Remove existing translations of dashboard object items that shall be cleared'
UPDATE tsn
SET intRowStatus = 1,
	AuditUpdateUser = 'System',
	AuditUpdateDTM = GETUTCDATE(),
	SourceSystemNameID = 10519001 /*EIDSSv7*/,
	SourceSystemKeyValue = N'[{' + N'"idfsBaseReference":' + cast(ntm.[ID] as nvarchar(20)) + N',' + N'"idfsLanguage":' + cast(@idfsLanguage as nvarchar(20)) + N'}]' collate Cyrillic_General_CI_AS
FROM trtStringNameTranslation tsn
INNER JOIN #NewTranslationsAppObject ntm ON tsn.idfsBaseReference = ntm.[ID] 
				and (ntm.NewTranslation is null or ltrim(rtrim(ntm.NewTranslation)) = N'' collate Cyrillic_General_CI_AS)
WHERE tsn.idfsLanguage = @idfsLanguage
		and tsn.intRowStatus <> 1
print N'Marked as deleted records: ' + cast(@@rowcount as nvarchar(20))
print N''

PRINT N'Insert missing translations of dashboard object items'
insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus,
	strMaintenanceFlag,
	strReservedAttribute,
	SourceSystemNameID,
	SourceSystemKeyValue,
	AuditCreateUser,
	AuditCreateDTM,
	AuditUpdateUser,
	AuditUpdateDTM
)
select	ntm.[ID],
		@idfsLanguage,
		ntm.NewTranslation,
		0,
		null,
		null,
		10519001 /*EIDSSv7*/,
		N'[{' + N'"idfsBaseReference":' + cast(ntm.[ID] as nvarchar(20)) + N',' + N'"idfsLanguage":' + cast(@idfsLanguage as nvarchar(20)) + N'}]' collate Cyrillic_General_CI_AS,
		'System',
		GETUTCDATE(),
		'System',
		GETUTCDATE()
from	#NewTranslationsAppObject ntm
inner join trtBaseReference br on br.idfsBaseReference = ntm.[ID]
inner join trtBaseReference lng on lng.idfsBaseReference = @idfsLanguage
left join trtStringNameTranslation tsn on tsn.idfsBaseReference = br.idfsBaseReference and tsn.idfsLanguage = lng.idfsBaseReference
where	ntm.NewTranslation is not null and ltrim(rtrim(ntm.NewTranslation)) <> N'' collate Cyrillic_General_CI_AS
		and tsn.idfsBaseReference is null
print N'Inserted records: ' + cast(@@rowcount as nvarchar(20))
print N''
print N''

end

end

end
----------------------------------------
end
else begin
    print   N'Specified language code is not correct'
end

PRINT N''
PRINT N'Dropping #NewTranslationsMenu at ' + CAST(GETDATE() AS NVARCHAR(24))
IF OBJECT_ID('tempdb..#NewTranslationsMenu') IS NOT NULL
BEGIN
	exec sp_executesql N'drop table #NewTranslationsMenu'
END

PRINT N'Dropping #NewTranslationsAppObject at ' + CAST(GETDATE() AS NVARCHAR(24))
IF OBJECT_ID('tempdb..#NewTranslationsAppObject') IS NOT NULL
BEGIN
	exec sp_executesql N'drop table #NewTranslationsAppObject'
END


END TRY
BEGIN CATCH
    set @Error = ERROR_NUMBER()
	set	@ErrorMsg = /*N'ErrorNumber: ' + CONVERT(NVARCHAR, ERROR_NUMBER()) 
		+*/ N' ErrorSeverity: ' + CONVERT(NVARCHAR, ERROR_SEVERITY())
		+ N' ErrorState: ' + CONVERT(NVARCHAR, ERROR_STATE())
		+ N' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), N'')
		+ N' ErrorLine: ' +  CONVERT(NVARCHAR, ISNULL(ERROR_LINE(), N''))
		+ N' ErrorMessage: ' + ERROR_MESSAGE();

	IF OBJECT_ID('tempdb..#NewTranslationsMenu') IS NOT NULL
	BEGIN
		exec sp_executesql N'drop table #NewTranslationsMenu'
	END

	IF OBJECT_ID('tempdb..#NewTranslationsAppObject') IS NOT NULL
	BEGIN
		exec sp_executesql N'drop table #NewTranslationsAppObject'
	END

	
	if	@Error <> 0
	begin
			
		RAISERROR (N'Error %d: %s.', -- Message text.
			   16, -- Severity,
			   1, -- State,
			   @Error,
			   @ErrorMsg) WITH SETERROR; -- Second argument.
	end
    
END CATCH;


IF @@ERROR <> 0
	ROLLBACK TRAN
ELSE
	COMMIT TRAN

SET NOCOUNT OFF 
SET XACT_ABORT OFF 
