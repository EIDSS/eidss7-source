
-- TODO: Specify the code of the language which translations shall be inserted/updated
declare @LanguageCode nvarchar(100)
set @LanguageCode = 'ka-GE'

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
--test commit

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
(10506057,N'პაროლის შეცვლა'),
(10506058,N'უსაფრთხოების წესები'),
(10506059,N'მომხმარებელთა ჯგუფები'),
(10506060,N'სისტემური ფუნქციები'),
(10506061,N'დზეის ობიექტები'),
(10506062,N'უსაფრთხოების მოვლენათა ჟურნალი'),
(10506063,N'სისტემურ მოვლენათა ჟურნალი'),
(10506064,N'მონაცემების აუდიტის ჩატარების ჟურნალი'),
(10506065,N'ინტერფეისის რედაქტორი'),
(10506066,N'რესურსების რედაქტორები'),
(10506067,N'ძირითადი ცნობარი'),
(10506068,N'დაავადებები'),
(10506069,N'მიღებული ზომები'),
(10506070,N'ნიმუშის ტიპი'),
(10506071,N'გადამტანის ტიპები'),
(10506072,N'გადამტანის სახეობები'),
(10506073,N'სახეობათა ტიპები'),
(10506074,N'შემთხვევების კლასიფიკაცია'),
(10506075,N'ანგარიშის დიაგნოზთა ჯგუფები'),
(10506076,N'ზოგადი სტატისტიკური ტიპები'),
(10506077,N'ასაკობრივი ჯგუფები'),
(10506078,N'ადამიანის დაავადების აგრეგირებული ანგარიშის მატრიცის რედაქტორი'),
(10506079,N'ვეტერინარული დაავადების აგრეგირებული ანგარიშის მატრიცის რედაქტორი'),
(10506080,N'ვეტერინარული სადიაგნოსტიკო კვლევების მატრიცის რედაქტორი'),
(10506081,N'ვეტერინარული პროფილაქტიკური ღონისძიებათა მატრიცის რედაქტორი'),
(10506082,N'ვეტერინარული სანიტარული ღონისძიებათა მატრიცის რედაქტორი'),
(10506083,N'მატრიცა ცხოველთა სახეობები - ასაკი'),
(10506084,N'მატრიცა ნიმუშის ტიპი - დერივატის ტიპი'),
(10506085,N'მატრიცა დიაგნოზი - ნიმუშის ტიპები'),
(10506086,N'მატრიცა დიაგნოზი - ლაბორატორიული ტესტები'),
(10506087,N'მატრიცა დიაგნოზი - ექსპრეს ტესტები'),
(10506088,N'მატრიცა ტესტები - ტესტების შედეგები'),
(10506089,N'მატრიცა გადამტანის ტიპი - შეგროვების მეთოდი'),
(10506056,N'უსაფრთხოება'),
(10506055,N'სტატისტიკური მონაცემები'),
(10506054,N'დასახლებეს ტიპები'),
(10506053,N'ორგანიზაციები'),
(10506052,N'თანამშრომლები'),
(10506051,N'მოვლენაზე შეტყობინების მიღება'),
(10506050,N'მონაცემთა დაარქივების პარამეტრები'),
(10506049,N'დაკავშირება არქივთან'),
(10506047,N'საცავის განლაგების სქემა'),
(10506046,N'პარტიები'),
(10506045,N'დამტკიცებები'),
(10506044,N'ტესტირება'),
(10506043,N'გადაცემული'),
(10506042,N'ნიმუშები'),
(10506041,N'ზედამხედველობის სესია'),
(10506040,N'ეპიდაფეთქება'),
(10506038,N'ლინკი EPINFO-თან (ვეტ)'),
(10506037,N'ზედამხედველობის სესია'),
(10506036,N'აქტიური ზედამხედველობის კამპანია'),
(10506035,N'აგრეგირებულ ღონისძიებათა შეჯამება'),
(10506034,N'აგრეგირებული ქმედებები'),
(10506033,N'აგრეგირებული ანგარიშის შეფასება'),
(10506032,N'აგრეგირებუი ანგარიში'),
(10506031,N'გადახრის ანალიზი'),
(10506030,N'შინაური ცხოველის დაავადების ანგარიში'),
(10506029,N'ფრინველის დაავადების ანგარიში'),
(10506028,N'შინაური ცხოველის ანგარიში'),
(10506027,N'ფრინველის ანგარიში'),
(10506026,N'ფერმა'),
(10506025,N'ფერმა'),
(10506022,N'CISID-ში შემთხვევების ექსპორტი'),
(10506021,N'გადახრის ანალიზი'),
(10506020,N'აქტიური ზედამხედველობის სესია'),
(10506019,N'აქტიური ზედამხედველობის კამპანია'),
(10506018,N'აგრეგირებული დაავადების ანგარიში შეფასება'),
(10506017,N'აგრეგირებული დაავადების ანგარიში'),
(10506016,N'ადამიანის დაავადების ანგარიში'),
(10506015,N'დაავადების ანგარიში'),
(10506014,N'პიროვნება'),
(10506013,N'პიროვნება'),
(10506012,N'მომხმარებლების პარამეტრების დაყენება'),
(10506011,N'ენა'),
(10506010,N'სისტემიდან გამოსვლა'),
(10506009,N'ანგარიშები'),
(10506008,N'კონფიგურაცია'),
(10506007,N'ადმინისტრირება'),
(10506006,N'ლაბორატორია'),
(10506005,N'გადამტანი'),
(10506004,N'ეპიდაფეთქება'),
(10506003,N'ვეტერინარული'),
(10506002,N'ადამიანი'),
(10506090,N'მარტიცა გადამტანის ტიპი - ნიმუშის ტიპები'),
(10506091,N'მარტიცა გადამტანის ტიპი - საველე ტესტები'),
(10506092,N'მატრიცა დიაგნოზი - ასაკობრივი ჯგუფები'),
(10506093,N'მატრიცა ანგარიშის დიაგნოზთა ჯგუფები - დიაგნოზები'),
(10506094,N'ქვეყნის სტანდარტული ანგარიშების სტრიქონები'),
(10506095,N'მატრიცა ასაკობრივი ჯგუფი - სტატისტიკური ასაკობრივი ჯგუფები'),
(10506096,N'მატრიცა დიაგნოზთა ჯგუფები - დიაგნოზი'),
(10506097,N'პარამეტრის ტიპის რედაქტორი'),
(10506098,N'უნიკალური დანომრვის სქემა'),
(10506099,N'აგრეგირებული ფორმების პარამეტრები'),
(10506100,N'რუკის პარამეტრების დაყენება'),
(10506101,N'ამოსაბეჭდი ფორმები'),
(10506102,N'სტანდარტული ანგარიშები'),
(10506103,N'ადამიანის ანგარიში'),
(10506104,N'ვეტერინარული ანგარიში'),
(10506105,N'ლაბორატორიული ანგარიშები'),
(10506107,N'ადმინისტატიული ანგარიშები'),
(10506108,N'შტრიხკოდების ბეჭდვა'),
(10506109,N'ადამიანის დაავადების ანგარიში'),
(10506110,N'ადამიანის აგრეგირებული ანგარიში'),
(10506111,N'ადამიანის აქტიური ზედამხედველობის კამპანია'),
(10506112,N'ადამიანის აქტიური ზედამხედველობის სესია'),
(10506113,N'პიროვნება'),
(10506114,N'ეპიდაფეთქება'),
(10506115,N'ფერმა'),
(10506116,N'ფრინველის დაავადების ანგარიში'),
(10506117,N'შინაური ცხოველის დაავადების ანგარიში'),
(10506118,N'ცხოველების დაავადების ანგარიში'),
(10506119,N'ვეტერინარი აგრეგირებული ანგარიშგება'),
(10506120,N'ვეტერინარული აგრეგირებული ღონისძიებები'),
(10506121,N'ვეტერინარული აქტიური ზედამხედველობის სესისიები'),
(10506122,N'ძიების ნიმუშები'),
(10506123,N'ტესტირება'),
(10506124,N'ნიმუშის გადაცემა'),
(10506125,N'დამტკიცებები'),
(10506126,N'ჩემი პრიორიტები'),
(10506127,N'ვექტორების აღება'),
(10506128,N'ტრეინიგის ვიდეო ჩანაწერები'),
(10506129,N'შეტყობინება'),
(10506130,N'ჩემი შეტყობინებები'),
(10506131,N'ჩემი კვლევები'),
(10506132,N'გამოკვლევები'),
(10506133,N'ნიმუშები, რომელიც არ არის მიღებული'),
(10506134,N'დამტკიცებები'),
(10506135,N'ჩემი არებულები'),
(10506136,N'მომხმარებლები'),
(10506137,N'ქაღალდის ფორმების ჩამოტვითვა'),
(10506138,N'ტრეინიგის ვიდეო ჩანაწერები'),
(10506139,N'სისტემური უპირატესობები'),
(10506140,N'თანამშრომლები'),
(10506141,N'მომხმარებელთა ჯგუფები'),
(10506142,N'დზეის ობიექტები'),
(10506143,N'ორგანიზაციები'),
(10506144,N'დასახლების პუნქტები'),
(10506145,N'საყრდენი ბაზებით ზედამხედველობის აგრეგირებული ფორმa'),
(10506146,N'დედუპლიკაცია'),
(10506147,N'მოქნილი ფორმის პარამეტრის რედაქტორი'),
(10506148,N'მოქნილი ფორმების დიზაინერი'),
(10506149,N'საყრდენი ბაზებით ზედამხედველობის ანალიზი (გრიპისმაგვარი დაავადება)'),
(10506150,N'სიკვდილიანობა და ავადობა თვეების მიხედვით'),
(10506151,N'ადამიანის დაავადების დიაგნოზი შეცვლილ დიაგნოზთან შედარებით'),
(10506152,N'წლიური ვეტერინარული სიტუაცია'),
(10506153,N'ვეტერინარული აქტიური ზედამხედველობა'),
(10506154,N'დაავადება - ადამიანის სქესის მატრიცა'),
(10506155,N'პერსონალური საიდენტიფიკაციო ტიპის მატრიცა'),
(10506156,N'დზეის ობიექტები'),
(10506157,N'დზეის ობიექტის ჯგუფები'),
(10506160,N'სისტემური უპირატესობები'),
(10506161,N'ევროპის ბიულეტენი ცოფის შესახებ - ზედამხედველობის კვარტალური ანგარიში'),
(10506162,N'რამდენიმე წლის შედარებითი ანგარიში თვეების მიხედვით'),
(10506163,N'გადამდები დაავადებების/მდგომარეობების შედარებითი ანგარიში (თვეების მიხედვით)'),
(10506164,N'სეროლოგიური კვლევის შედეგი'),
(10506165,N'ანტიბიოტიკების მიმართ მგრძნობელობის ბარათი (დკსჯეც)'),
(10506166,N'ანტიბიოტიკების მიმართ მგრძნობელობის ბარათი (სმსლ)'),
(10506167,N'60B ჟურნალი'),
(10506168,N'ანგარიში ზოგიერთი დაავადების/მდგომარეობის შესახებ (ყოველთვიური ფორმა IV–03)'),
(10506169,N'ადმინისტრაციულ მოვლენათა ჟურნალი'),
(10506170,N'შუალედური ანგარიში ყოველთვიური ფორმა IV–03–ის მიხედვით'),
(10506171,N'ჯანმოს ანგარიში წითელასა და წითურას შესახებ'),
(10506172,N'ანგარიშები ძველი რედაქციით'),
(10506173,N'ანგარიში ზოგიერთი დაავადების/მდგომარეობის შესახებ (ყოველთვიური ფორმა IV–03 შჯსდს-ს 01-82/ნ ბრძანების შესაბამისად) '),
(10506174,N'შუალედური ანგარიში ყოველთვიური ფორმა IV–03–ის მიხედვით (შჯსდს-ს 01-82/ნ ბრძანების შესაბამისად)'),
(10506175,N'ანგარიში ზოგიერთი დაავადების/მდგომარეობის შესახებ (ყოველთვიური ფორმა IV–03 შჯსდს-ს 01-27/ნ ბრძანების შესაბამისად)'),
(10506176,N'შუალედური ანგარიში ყოველთვიური ფორმა IV–03–ის მიხედვით (შჯსდს-ს 01-27/ნ ბრძანების შესაბამისად)'),
(10506177,N'ანგარიში წლიურ ანგარიშგებას დაქვემდებარებული გადამდები დაავადების შემთხვევების შესახებ (წლიური ფორმა IV–03 შჯსდს-ს 101/ნ ბრძანების შესაბამისად)'),
(10506178,N'შუალედური ანგარიში წლიური ფორმა IV–03–ის მიხედვით (შჯსდს-ს 101/ნ ბრძანების შესაბამისად)'),
(10506179,N'ანგარიში გადამდები დაავადების შემთხვევების შესახებ (ყოველთვიური ფორმა IV–03/1 შჯსდს-ს 101/ნ ბრძანების შესაბამისად)'),
(10506180,N'შუალედური ანგარიში ყოველთვიური ფორმა IV–03/1–ის მიხედვით (შჯსდს-ს 101/ნ ბრძანების შესაბამისად)'),
(10506181,N'ფორმა # 1 (A3)'),
(10506182,N'ფორმა # 1 (A4)'),
(10506183,N'შედარებითი ანგარიში'),
(10506184,N'მიკრობიოლოგიური კვლევის შედეგი'),
(10506185,N'შედარებითი გარე ანგარიში'),
(10506186,N'ხარისხის ინდიკატორების მონაცემები'),
(10506187,N'ადამიანის დაავადების შემთხვევები რაიონის მიხედვით, დაავადების ანგარიშის შეჯამება'),
(10506188,N'ყოველკვირეული ანგარიშგების ფორმა'),
(10506189,N'ყოველკვირეული ანგარიშგების ფორმის შეჯამება'),
(10506190,N'მწვავე დუნე დამბლის ზედამხედველობის მთავარი ინდიკატორები'),
(10506191,N'მწვავე დუნე დამბლის ზედამხედველობის დამატებითი ინდიკატორები'),
(10506192,N'რამოდენიმე წლის შედარებითი ანგარიში თვეების მიხედვით'),
(10506193,N'ლაბორატორიული დიაგნოსტიკის დანიშვნა'),
(10506194,N'ლაბორატორიული გამოკვლევის შედეგი'),
(10506195,N'ვეტერინარული დაავადების ანგარიშის ფორმა Vet1'),
(10506196,N'აუდიტის ადმინისტრაციული ანგარიშის ჟურნალი'),
(10506197,N'ვეტერინარული დაავადების ანგარიშის ფორმა Vet1A'),
(10506198,N'ვეტერინარული ანგარიშის შეჯამება'),
(10506199,N'ანგარიში ვეტერინარულ ლაბორატორიებში ჩატარებული ღონისძიებების შესახებ'),
(10506200,N'ვეტერინარული ხარისხის ინდიკატორების მონაცემები'),
(10506201,N'კონფიგურირებადი ფილტრაცია'),
(10506202,N'ვეტერინარული დაავადებების შემთხვევების ანგარიში'),
(10506203,N'გამარტივებული ანალიზი'),
(10506204,N'ხარისხის ინდიკატორები რაიონებისთვის'),
(10506205,N'მეზობელ რაიონებში ავადობის შედარებითი ანგარიში'),
(10506206,N'ჯანმოს ანგარიში წითელასა და წითურას შესახებ'),
(10506207,N'ტუბერკულოზის შემთხვევების ანგარიში, რომელთაც ჩაუტარდათ ტესტირება აივ ინფექციაზე'),
(10506208,N'ზოონოზური დაავადების შედარებითი ანგარიში ( თვეების მიხედვით)'),
(10506209,N'ზოონოზური ანგარიშები'),
(10506210,N'ზოონოზური დაავადების შედარებითი ანგარიში ( თვეების მიხედვით)'),
(10506212,N'ადმინისტრაციული ქვედანაყოფი'),
(10506213,N'დაკავშირება არქივთან'),
(10506214,N'ინტერფეისის რედაქტორი'),
(10506216,N'ადამიანის დაავადების გამოკვლევის ფორმა'),
(10506217,N'ფრინველის დაავადების კვლევის ფორმა'),
(10506218,N'ცხოველის დაავადების კვლევის ფორმა'),
(10506219,N'დზეის 7 - ის პანელი');


declare @N int
set @N =
	(	select	count(*)
		from	#NewTranslationsMenu
	)
PRINT(N'Operation applied to ' + cast(@N as nvarchar(20)) + N' rows in the table #NewTranslationsMenu')
PRINT N''


PRINT(N'Add rows to #NewTranslationsAppObject')
INSERT INTO #NewTranslationsAppObject VALUES
(10506002,N'ადამიანი'),
(10506003,N'ვეტერინარული'),
(10506004,N'ეპიდაფეთქება'),
(10506005,N'გადამტანი'),
(10506006,N'ლაბორატორია'),
(10506007,N'ადმინისტრირება'),
(10506008,N'კონფიგურაცია'),
(10506009,N'ანგარიშები'),
(10506010,N'სისტემიდან გამოსვლა'),
(10506011,N'ენა'),
(10506012,N'მომხმარებლების პარამეტრების დაყენება '),
(10506013,N'პიროვნება'),
(10506014,N'პიროვნება'),
(10506015,N'დაავადების ანგარიში'),
(10506016,N'ადამიანის დაავადების ანგარიში '),
(10506017,N'აგრეგირებული დაავადების ანგარიში '),
(10506018,N'აგრეგირებული დაავადების ანგარიში შეფასება'),
(10506019,N'აქტიური ზედამხედველობის კამპანია'),
(10506020,N'აქტიური ზედამხედველობის სესია'),
(10506021,N'გადახრის ანალიზი'),
(10506022,N'CISID-ში შემთხვევების ექსპორტი'),
(10506025,N'ფერმა'),
(10506026,N'ფერმა'),
(10506027,N'ფრინველის ანგარიში'),
(10506028,N'შინაური ცხოველის ანგარიში'),
(10506029,N'ფრინველის დაავადების ანგარიში'),
(10506030,N'შინაური ცხოველის დაავადების ანგარიში'),
(10506031,N'გადახრის ანალიზი'),
(10506032,N'აგრეგირებუი ანგარიში'),
(10506033,N'აგრეგირებული ანგარიშის შეფასება'),
(10506034,N'აგრეგირებული ქმედებები'),
(10506035,N'აგრეგირებულ ღონისძიებათა შეჯამება'),
(10506036,N'აქტიური ზედამხედველობის კამპანია '),
(10506037,N'ზედამხედველობის სესია'),
(10506040,N'ეპიდაფეთქება'),
(10506041,N'ზედამხედველობის სესია'),
(10506042,N'ნიმუშები'),
(10506043,N'გადაცემული'),
(10506044,N'ტესტირება'),
(10506045,N'დამტკიცებები'),
(10506046,N'პარტიები'),
(10506047,N'საცავის განლაგების სქემა'),
(10506050,N'მონაცემთა დაარქივების პარამეტრები'),
(10506051,N'მოვლენაზე შეტყობინების მიღება'),
(10506052,N'თანამშრომლები'),
(10506053,N'ორგანიზაციები'),
(10506054,N'დასახლებეს ტიპები'),
(10506055,N'სტატისტიკური მონაცემები'),
(10506056,N'უსაფრთხოება'),
(10506058,N'უსაფრთხოების წესები'),
(10506059,N'მომხმარებელთა ჯგუფები'),
(10506060,N'სისტემური ფუნქციები'),
(10506062,N'უსაფრთხოების მოვლენათა ჟურნალი'),
(10506063,N'სისტემურ მოვლენათა ჟურნალი'),
(10506064,N'მონაცემების აუდიტის ჩატარების ჟურნალი'),
(10506065,N'ინტერფეისის რედაქტორი'),
(10506066,N'რესურსების რედაქტორები'),
(10506067,N'ძირითადი ცნობარი'),
(10506068,N'დაავადებები'),
(10506069,N'მიღებული ზომები'),
(10506070,N'ნიმუშის ტიპი'),
(10506071,N'გადამტანის ტიპები'),
(10506072,N'გადამტანის სახეობები'),
(10506073,N'სახეობათა ტიპები'),
(10506074,N'შემთხვევების კლასიფიკაცია'),
(10506075,N'ანგარიშის დიაგნოზთა ჯგუფები'),
(10506076,N'ზოგადი სტატისტიკური ტიპები'),
(10506077,N'ასაკობრივი ჯგუფები'),
(10506078,N'ადამიანის დაავადების აგრეგირებული ანგარიშის მატრიცის რედაქტორი'),
(10506079,N'ვეტერინარული დაავადების აგრეგირებული ანგარიშის მატრიცის რედაქტორი'),
(10506080,N'ვეტერინარული სადიაგნოსტიკო კვლევების მატრიცის რედაქტორი'),
(10506081,N'ვეტერინარული პროფილაქტიკური ღონისძიებათა მატრიცის რედაქტორი'),
(10506082,N'ვეტერინარული სანიტარული ღონისძიებათა მატრიცის რედაქტორი'),
(10506083,N'მატრიცა ცხოველთა სახეობები - ასაკი'),
(10506084,N'მატრიცა ნიმუშის ტიპი - დერივატის ტიპი'),
(10506085,N'მატრიცა დიაგნოზი - ნიმუშის ტიპები'),
(10506086,N'მატრიცა დიაგნოზი - ლაბორატორიული ტესტები'),
(10506087,N'მატრიცა დიაგნოზი - ექსპრეს ტესტები'),
(10506088,N'მატრიცა ტესტები - ტესტების შედეგები'),
(10506089,N'მატრიცა გადამტანის ტიპი - შეგროვების მეთოდი'),
(10506090,N'მარტიცა გადამტანის ტიპი - ნიმუშის ტიპები'),
(10506091,N'მარტიცა გადამტანის ტიპი - საველე ტესტები'),
(10506092,N'მატრიცა დიაგნოზი - ასაკობრივი ჯგუფები'),
(10506093,N'მატრიცა ანგარიშის დიაგნოზთა ჯგუფები - დიაგნოზები'),
(10506094,N'ქვეყნის სტანდარტული ანგარიშების სტრიქონები'),
(10506095,N'მატრიცა ასაკობრივი ჯგუფი - სტატისტიკური ასაკობრივი ჯგუფები'),
(10506096,N'მატრიცა დიაგნოზთა ჯგუფები - დიაგნოზი'),
(10506097,N'პარამეტრის ტიპის რედაქტორი'),
(10506098,N'უნიკალური დანომრვის სქემა'),
(10506099,N'აგრეგირებული ფორმების პარამეტრები'),
(10506101,N'ამოსაბეჭდი ფორმები'),
(10506102,N'სტანდარტული ანგარიშები'),
(10506103,N'ადამიანის ანგარიში'),
(10506104,N'ვეტერინარული ანგარიში'),
(10506105,N'ლაბორატორიული ანგარიშები'),
(10506107,N'ადმინისტატიული ანგარიშები'),
(10506108,N'შტრიხკოდების ბეჭდვა'),
(10506109,N'ადამიანის დაავადების ანგარიში '),
(10506110,N'ადამიანის აგრეგირებული ანგარიში'),
(10506111,N'ადამიანის აქტიური ზედამხედველობის კამპანია'),
(10506112,N'ადამიანის აქტიური ზედამხედველობის სესია'),
(10506113,N'პიროვნება'),
(10506114,N'ეპიდაფეთქება'),
(10506115,N'ფერმა'),
(10506116,N'ფრინველის დაავადების ანგარიში'),
(10506117,N'შინაური ცხოველის დაავადების ანგარიში'),
(10506118,N'ცხოველების დაავადების ანგარიში'),
(10506119,N'ვეტერინარი აგრეგირებული ანგარიშგება'),
(10506120,N'ვეტერინარული აგრეგირებული ღონისძიებები'),
(10506121,N'ვეტერინარული აქტიური ზედამხედველობის სესისიები'),
(10506122,N'ძიების ნიმუშები'),
(10506123,N'ტესტირება'),
(10506124,N'ნიმუშის გადაცემა'),
(10506125,N'დამტკიცებები'),
(10506126,N'ჩემი პრიორიტები'),
(10506127,N'ვექტორების აღება '),
(10506128,N'ტრეინიგის ვიდეო ჩანაწერები '),
(10506129,N'შეტყობინება '),
(10506130,N'ჩემი შეტყობინებები'),
(10506131,N'ჩემი კვლევები'),
(10506132,N'გამოკვლევები '),
(10506133,N'ნიმუშები, რომელიც არ არის მიღებული'),
(10506134,N'დამტკიცებები'),
(10506135,N'ჩემი არებულები'),
(10506136,N'მომხმარებლები'),
(10506137,N'ქაღალდის ფორმების ჩამოტვითვა'),
(10506138,N'ტრეინიგის ვიდეო ჩანაწერები '),
(10506139,N'სისტემური უპირატესობები'),
(10506140,N'თანამშრომლები'),
(10506141,N'მომხმარებელთა ჯგუფები'),
(10506142,N'დზეის ობიექტები'),
(10506143,N'ორგანიზაციები'),
(10506144,N'დასახლების პუნქტები'),
(10506145,N'საყრდენი ბაზებით ზედამხედველობის აგრეგირებული ფორმa'),
(10506146,N'დედუპლიკაცია '),
(10506148,N'მოქნილი ფორმების დიზაინერი'),
(10506149,N'საყრდენი ბაზებით ზედამხედველობის ანალიზი (გრიპისმაგვარი დაავადება)'),
(10506150,N'სიკვდილიანობა და ავადობა თვეების მიხედვით'),
(10506151,N'ადამიანის დაავადების დიაგნოზი შეცვლილ დიაგნოზთან შედარებით'),
(10506152,N'წლიური ვეტერინარული სიტუაცია'),
(10506153,N'ვეტერინარული აქტიური ზედამხედველობა '),
(10506154,N'დაავადება - ადამიანის სქესის მატრიცა'),
(10506155,N'პერსონალური საიდენტიფიკაციო ტიპის მატრიცა'),
(10506156,N'დზეის ობიექტები'),
(10506157,N'დზეის ობიექტის ჯგუფები'),
(10506160,N'სისტემური უპირატესობები'),
(10506161,N'ევროპის ბიულეტენი ცოფის შესახებ - ზედამხედველობის კვარტალური ანგარიში'),
(10506162,N'რამდენიმე წლის შედარებითი ანგარიში თვეების მიხედვით'),
(10506163,N'გადამდები დაავადებების/მდგომარეობების შედარებითი ანგარიში (თვეების მიხედვით)'),
(10506164,N'სეროლოგიური კვლევის შედეგი'),
(10506165,N'ანტიბიოტიკების მიმართ მგრძნობელობის ბარათი (დკსჯეც)'),
(10506166,N'ანტიბიოტიკების მიმართ მგრძნობელობის ბარათი (სმსლ)'),
(10506167,N'60B ჟურნალი'),
(10506168,N'ანგარიში ზოგიერთი დაავადების/მდგომარეობის შესახებ (ყოველთვიური ფორმა IV–03)'),
(10506169,N'ადმინისტრაციულ მოვლენათა ჟურნალი'),
(10506170,N'შუალედური ანგარიში ყოველთვიური ფორმა IV–03–ის მიხედვით'),
(10506172,N'ანგარიშები ძველი რედაქციით'),
(10506173,N'ანგარიში ზოგიერთი დაავადების/მდგომარეობის შესახებ (ყოველთვიური ფორმა IV–03 შჯსდს-ს 01-82/ნ ბრძანების შესაბამისად)'),
(10506174,N'შუალედური ანგარიში ყოველთვიური ფორმა IV–03–ის მიხედვით (შჯსდს-ს 01-82/ნ ბრძანების შესაბამისად)'),
(10506175,N'ანგარიში ზოგიერთი დაავადების/მდგომარეობის შესახებ (ყოველთვიური ფორმა IV–03 შჯსდს-ს 01-27/ნ ბრძანების შესაბამისად)'),
(10506176,N'შუალედური ანგარიში ყოველთვიური ფორმა IV–03–ის მიხედვით (შჯსდს-ს 01-27/ნ ბრძანების შესაბამისად)'),
(10506177,N'ანგარიში წლიურ ანგარიშგებას დაქვემდებარებული გადამდები დაავადების შემთხვევების შესახებ (წლიური ფორმა IV–03 შჯსდს-ს 101/ნ ბრძანების შესაბამისად)'),
(10506178,N'შუალედური ანგარიში წლიური ფორმა IV–03–ის მიხედვით (შჯსდს-ს 101/ნ ბრძანების შესაბამისად)'),
(10506179,N'ანგარიში გადამდები დაავადების შემთხვევების შესახებ (ყოველთვიური ფორმა IV–03/1 შჯსდს-ს 101/ნ ბრძანების შესაბამისად)'),
(10506180,N'შუალედური ანგარიში ყოველთვიური ფორმა IV–03/1–ის მიხედვით (შჯსდს-ს 101/ნ ბრძანების შესაბამისად)'),
(10506181,N'ფორმა # 1 (A3)'),
(10506182,N'ფორმა # 1 (A4)'),
(10506183,N'შედარებითი ანგარიში'),
(10506184,N'მიკრობიოლოგიური კვლევის შედეგი'),
(10506185,N'შედარებითი გარე ანგარიში'),
(10506186,N'ხარისხის ინდიკატორების მონაცემები'),
(10506187,N'ადამიანის დაავადების შემთხვევები რაიონის მიხედვით, დაავადების ანგარიშის შეჯამება'),
(10506188,N'ყოველკვირეული ანგარიშგების ფორმა'),
(10506189,N'ყოველკვირეული ანგარიშგების ფორმის შეჯამება'),
(10506190,N'მწვავე დუნე დამბლის ზედამხედველობის მთავარი ინდიკატორები'),
(10506191,N'მწვავე დუნე დამბლის ზედამხედველობის დამატებითი ინდიკატორები'),
(10506192,N'რამოდენიმე წლის შედარებითი ანგარიში თვეების მიხედვით'),
(10506193,N'ლაბორატორიული დიაგნოსტიკის დანიშვნა'),
(10506194,N'ლაბორატორიული გამოკვლევის შედეგი'),
(10506195,N'ვეტერინარული დაავადების ანგარიშის ფორმა Vet1'),
(10506196,N'აუდიტის ადმინისტრაციული ანგარიშის ჟურნალი'),
(10506197,N'ვეტერინარული დაავადების ანგარიშის ფორმა Vet1A'),
(10506198,N'ვეტერინარული ანგარიშის შეჯამება'),
(10506199,N'ანგარიში ვეტერინარულ ლაბორატორიებში ჩატარებული ღონისძიებების შესახებ'),
(10506200,N'ვეტერინარული ხარისხის ინდიკატორების მონაცემები'),
(10506201,N'კონფიგურირებადი ფილტრაცია'),
(10506202,N'ვეტერინარული დაავადებების შემთხვევების ანგარიში'),
(10506203,N'გამარტივებული ანალიზი'),
(10506204,N'ხარისხის ინდიკატორები რაიონებისთვის'),
(10506205,N'მეზობელ რაიონებში ავადობის შედარებითი ანგარიში'),
(10506207,N'ტუბერკულოზის შემთხვევების ანგარიში, რომელთაც ჩაუტარდათ ტესტირება აივ ინფექციაზე'),
(10506208,N'ზოონოზური დაავადების შედარებითი ანგარიში ( თვეების მიხედვით) '),
(10506209,N'ზოონოზური ანგარიშები'),
(10506210,N'ზოონოზური დაავადების შედარებითი ანგარიში ( თვეების მიხედვით) '),
(10506212,N'ადმინისტრაციული ქვედანაყოფი'),
(10506216,N'ადამიანის დაავადების გამოკვლევის ფორმა'),
(10506217,N'ფრინველის დაავადების კვლევის ფორმა'),
(10506218,N'ცხოველის დაავადების კვლევის ფორმა'),
(10506219,N'დზეის 7 - ის პანელი');



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