
-- Variables

declare	@SearchCnt int = 10

declare	@StartOfDateInterval datetime = '20220301'
declare	@EndOfDateInterval datetime = '20230203'

if (@EndOfDateInterval is null)
	set	@EndOfDateInterval = convert(nvarchar, getdate(), 112)

if (datediff(day, @StartOfDateInterval, @EndOfDateInterval) <= 0)
	set @EndOfDateInterval = convert(nvarchar, getdate(), 112)


declare	@DateIntervalInDays int = datediff(day, @StartOfDateInterval, @EndOfDateInterval)


-- Implementation
set nocount on
set XACT_ABORT on
SET DATEFORMAT dmy
SET DATEFIRST 1

declare
    @LanguageID NVARCHAR(50),
    @ReportKey BIGINT = NULL,
    @ReportID NVARCHAR(200) = NULL,
    @LegacyReportID NVARCHAR(200) = NULL,
    @SessionKey BIGINT = NULL,
    @PatientID BIGINT = NULL,
    @PersonID NVARCHAR(200) = NULL,
    @DiseaseID BIGINT = NULL,
    @ReportStatusTypeID BIGINT = NULL,
    @AdministrativeLevelID BIGINT = NULL,
    @DateEnteredFrom DATETIME = NULL,
    @DateEnteredTo DATETIME = NULL,
    @ClassificationTypeID BIGINT = NULL,
    @HospitalizationYNID BIGINT = NULL,
    @PatientFirstName NVARCHAR(200) = NULL,
    @PatientMiddleName NVARCHAR(200) = NULL,
    @PatientLastName NVARCHAR(200) = NULL,
    @SentByFacilityID BIGINT = NULL,
    @ReceivedByFacilityID BIGINT = NULL,
    @DiagnosisDateFrom DATETIME = NULL,
    @DiagnosisDateTo DATETIME = NULL,
    @LocalOrFieldSampleID NVARCHAR(200) = NULL,
    @DataEntrySiteID BIGINT = NULL,
    @DateOfSymptomsOnsetFrom DATETIME = NULL,
    @DateOfSymptomsOnsetTo DATETIME = NULL,
    @NotificationDateFrom DATETIME = NULL,
    @NotificationDateTo DATETIME = NULL,
    @DateOfFinalCaseClassificationFrom DATETIME = NULL,
    @DateOfFinalCaseClassificationTo DATETIME = NULL,
    @LocationOfExposureAdministrativeLevelID BIGINT = NULL,
    @OutcomeID BIGINT = NULL,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT,
    @SortColumn NVARCHAR(30) = 'ReportID',
    @SortOrder NVARCHAR(4) = 'DESC',
    @Page INT = 1,
    @PageSize INT = 100


-- Define and fill in customazable values: 
-- list of regions (provinces), 
-- diagnoses, 
-- case classifications,
-- last, first and second names associated with human genders
declare	@DefaultSite nvarchar(200)
declare	@idfsDefaultSite bigint
declare	@idfDefaultSiteOrganization bigint
declare	@idfsDefaultSiteEmployee bigint


declare	@Lng table
(
	idfID int not null identity(1,1) primary key
	, LngCode nvarchar(2000) collate Cyrillic_General_CI_AS not null
	, idfsLanguage bigint null
)


declare	@Diagnosis table
(
	idfID int not null identity(1,1) primary key
	, Diagnosis nvarchar(2000) collate Cyrillic_General_CI_AS not null
	, idfsDiagnosis bigint null
)

declare	@CaseClassification table
(
	idfID int not null identity(1,1) primary key
	, CaseClassification nvarchar(2000) collate Cyrillic_General_CI_AS not null
	, idfsCaseClassification bigint null
	, blnInitialHumanCaseClassification bit null
	, blnFinalHumanCaseClassification bit null
)



declare	@Region table
(
	idfID int not null identity(1,1) primary key
	, RegionName nvarchar(200) collate Cyrillic_General_CI_AS not null
	, RegionId bigint null
)


declare	@FirstName table
(
	idfID int not null identity(1,1) primary key
	, FirstName nvarchar(200) collate Cyrillic_General_CI_AS not null
	, HumanGender nvarchar(200) collate Cyrillic_General_CI_AS not null
	, idfsHumanGender bigint null
)

declare	@SecondName table
(
	idfID int not null identity(1,1) primary key
	, SecondName nvarchar(200) collate Cyrillic_General_CI_AS not null
	, HumanGender nvarchar(200) collate Cyrillic_General_CI_AS not null
	, idfsHumanGender bigint null
)


declare	@LastName table
(
	idfID int not null identity(1,1) primary key
	, LastName nvarchar(200) collate Cyrillic_General_CI_AS not null
	, HumanGender nvarchar(200) collate Cyrillic_General_CI_AS not null
	, idfsHumanGender bigint null
)



declare	@existDiagnosisToSampleType	 bit = 0
declare	@existDiagnosisToTestName	 bit = 0

if	exists	(
		select	1
		from		trtDiagnosis d
		join		fnReference('en', 19000019 /*Diagnosis*/) r_d
		on			r_d.idfsReference = d.idfsDiagnosis
		join		trtMaterialForDisease mfd
		on			mfd.idfsDiagnosis = d.idfsDiagnosis
					and mfd.intRowStatus = 0
		where		d.idfsUsingType = 10020001 /*Case-based*/
					and r_d.intHACode & 2 /*Human*/ > 0
					and d.intRowStatus = 0
			)
begin
	set	@existDiagnosisToSampleType = 1
end

if	exists	(
		select	1
		from		trtDiagnosis d
		join		fnReference('en', 19000019 /*Diagnosis*/) r_d
		on			r_d.idfsReference = d.idfsDiagnosis
		join		trtTestForDisease tfd
		on			tfd.idfsDiagnosis = d.idfsDiagnosis
					and tfd.intRowStatus = 0
		where		d.idfsUsingType = 10020001 /*Case-based*/
					and r_d.intHACode & 2 /*Human*/ > 0
					and d.intRowStatus = 0
			)
begin
	set	@existDiagnosisToTestName = 1
end



declare	  @CurrentCustomization	bigint
		, @CurrentCountry		bigint
		, @CustomizationPackage	bigint

select		@CustomizationPackage = cp.idfCustomizationPackage,
			@CurrentCustomization = cp.idfCustomizationPackage,
			@CurrentCountry = cp.idfsCountry
from		tstGlobalSiteOptions gso
inner join	tstCustomizationPackage cp
on			cast(cp.idfCustomizationPackage as nvarchar) = gso.strValue
inner join	gisCountry c
on			c.idfsCountry = cp.idfsCountry
			and c.intRowStatus = 0
inner join	gisBaseReference c_br
on			c_br.idfsGISBaseReference = c.idfsCountry
			and c_br.intRowStatus = 0
where		gso.strName = N'CustomizationPackage' collate Cyrillic_General_CI_AS
			and ISNUMERIC(gso.strValue) = 1


select		@CurrentCustomization = isnull(cp.idfCustomizationPackage, @CustomizationPackage),
			@CurrentCountry = isnull(cp.idfsCountry, @CurrentCountry)
from		tstLocalSiteOptions lso
inner join	tstSite s
on			cast(s.idfsSite as nvarchar(200)) = lso.strValue collate Cyrillic_General_CI_AS
			and s.intRowStatus = 0
inner join	tstCustomizationPackage cp
on			cp.idfCustomizationPackage = s.idfCustomizationPackage
inner join	gisCountry c
on			c.idfsCountry = cp.idfsCountry
			and c.intRowStatus = 0
inner join	gisBaseReference c_br
on			c_br.idfsGISBaseReference = c.idfsCountry
			and c_br.intRowStatus = 0
where		lso.strName = N'SiteID' collate Cyrillic_General_CI_AS


-- Define and fill in customazable values based on Customization package: start
if @CurrentCustomization = 51577400000000/*Armenia*/
begin

	insert into @FirstName
		(FirstName, HumanGender)
	values
		(N'Արա', 'Male')
		, (N'Արտակ', 'Male')
		, (N'Բաբիկ', 'Male')
		, (N'Գուրգեն', 'Male')
		, (N'Զավեն', 'Male')
		, (N'Զորիկ', 'Male')
		, (N'Թաթուլ', 'Male')
		, (N'Թելման', 'Male')
		, (N'Դերենիկ', 'Male')
		, (N'Ծատուր', 'Male')
		, (N'Սևակ', 'Male')
		, (N'Սուրեն', 'Male')

		
		, (N'Անահիտ', 'Female')
		, (N'Ասյա', 'Female')
		, (N'Ալվարդ', 'Female')
		, (N'Գյուլնարա', 'Female')
		, (N'Սիրուն', 'Female')
		, (N'Նազելի', 'Female')
		, (N'Նունե', 'Female')
		, (N'Կլարա', 'Female')
		, (N'Նարգիզ', 'Female')
		, (N'Բելլա', 'Female')
		, (N'Դոնարա', 'Female')
		, (N'Վարսինե', 'Female')


	insert into @LastName
		(LastName, HumanGender)
	values
		(N'Սարգսյան', 'Male') 
		, (N'Աբրահամյան', 'Male')
		, (N'Հարությունյան', 'Male')
		, (N'Պողոսյան', 'Male')
		, (N'Բալասանյան', 'Male')
		, (N'Բաբայան', 'Male')
		, (N'Գևորգյան', 'Male')
		, (N'Եկանյան', 'Male')
		, (N'Սարդարյան', 'Male')
		, (N'Մամիկոնյան', 'Male')
		, (N'Վարդանյան', 'Male')
		, (N'Զաքարյան', 'Male')
		, (N'Զավարյան', 'Male')
		, (N'Թադևոսյան', 'Male')
		, (N'Թաթոսյան', 'Male')
		, (N'Ժամկոչյան', 'Male')
		, (N'Իսրայելյան', 'Male')
		, (N'Իսկանդարյան', 'Male')
		, (N'Լալայան', 'Male')
		, (N'Լևոնյան', 'Male')
		, (N'Ծատուրյան', 'Male')
		, (N'Կարախանյան', 'Male')
		, (N'Հակոբյան', 'Male')
		, (N'Հաբաթյան', 'Male')

		, (N'Սարգսյան', 'Female') 
		, (N'Աբրահամյան', 'Female')
		, (N'Հարությունյան', 'Female')
		, (N'Պողոսյան', 'Female')
		, (N'Բալասանյան', 'Female')
		, (N'Բաբայան', 'Female')
		, (N'Գևորգյան', 'Female')
		, (N'Եկանյան', 'Female')
		, (N'Սարդարյան', 'Female')
		, (N'Մամիկոնյան', 'Female')
		, (N'Վարդանյան', 'Female')
		, (N'Զաքարյան', 'Female')
		, (N'Զավարյան', 'Female')
		, (N'Թադևոսյան', 'Female')
		, (N'Թաթոսյան', 'Female')
		, (N'Ժամկոչյան', 'Female')
		, (N'Իսրայելյան', 'Female')
		, (N'Իսկանդարյան', 'Female')
		, (N'Լալայան', 'Female')
		, (N'Լևոնյան', 'Female')
		, (N'Ծատուրյան', 'Female')
		, (N'Կարախանյան', 'Female')
		, (N'Հակոբյան', 'Female')
		, (N'Հաբաթյան', 'Female')

	insert into @Region
		(RegionName)
	values 
		(N'Lori')
		, (N'Tavush')
		, (N'Shirak')
		, (N'Yerevan')
		, (N'Syunik')
end
else if @CurrentCustomization = 51577410000000/*Azerbaijan*/
begin

	insert into @FirstName
		(FirstName, HumanGender)
	values		
		(N'Təbriz', 'Male')
		, (N'İlyas', 'Male')
		, (N'Tural', 'Male')
		, (N'Nicat', 'Male')
		, (N'Rauf', 'Male')
		, (N'Elmar', 'Male')
		, (N'Həci', 'Male')
		, (N'Emil', 'Male')
		, (N'Həsən', 'Male')
		, (N'Əli', 'Male')

		, (N'Səbinə', 'Female')
		, (N'Aynurə', 'Female')
		, (N'Leyla', 'Female')
		, (N'Çinarə', 'Female')
		, (N'Aysel', 'Female')
		, (N'Aydan', 'Female')
		, (N'Əzizə', 'Female')
		, (N'Esmira', 'Female')
		, (N'Kəmalə', 'Female')
		, (N'Lalə', 'Female')


	insert into @LastName
		(LastName, HumanGender)
	values		
		(N'İbrahimov', 'Male')
		, (N'Rzayev', 'Male')
		, (N'Tağıyev', 'Male')
		, (N'Muxtarov', 'Male')
		, (N'Quliyev', 'Male')
		, (N'Süleymanov', 'Male')
		, (N'Orucov', 'Male')
		, (N'Balayev', 'Male')
		, (N'Abdullayev', 'Male')
		, (N'Paşayev', 'Male')
		, (N'Nərimanov', 'Male')
		, (N'Mustafayev', 'Male')
		, (N'Səmədov', 'Male')
		, (N'Mirzoyev', 'Male')
		, (N'Axundov', 'Male')
		, (N'Xanlarov', 'Male')
		, (N'Əzimov', 'Male')
		, (N'Əmirov', 'Male')
		, (N'Əsgərov', 'Male')
		, (N'Qəmbərov', 'Male')

		, (N'Hüseynova', 'Female')
		, (N'Əliyeva', 'Female')
		, (N'Məmmədova', 'Female')
		, (N'Novruzova', 'Female')
		, (N'Heydərova', 'Female')
		, (N'Nəsirova', 'Female')
		, (N'Nəbiyeva', 'Female')
		, (N'Zeynalova', 'Female')
		, (N'Qarayeva', 'Female')
		, (N'Kərimova', 'Female')
		, (N'Dadaşova', 'Female')
		, (N'Həbibova', 'Female')
		, (N'Həsənova', 'Female')
		, (N'Cəfərova', 'Female')
		, (N'Səfərova', 'Female')
		, (N'Vəliyeva', 'Female')
		, (N'Qasımova', 'Female')
		, (N'Mextiyeva', 'Female')
		, (N'Əmirova', 'Female')
		, (N'Babayeva', 'Female')

	insert into @Region
		(RegionName)
	values 
		(N'Baku')
		, (N'Other rayons')
		, (N'Nakhichevan AR')
end
else if @CurrentCustomization = 51577490000000/*Thailand*/
begin

	insert into @FirstName
		(FirstName, HumanGender)
	values
		(N'Jacob', 'Male')
		, (N'Ethan', 'Male')
		, (N'Michael', 'Male')
		, (N'Alexander', 'Male')
		, (N'William', 'Male')
		, (N'Joshua', 'Male')
		, (N'Daniel', 'Male')
		, (N'Jayden', 'Male')
		, (N'Noah', 'Male')
		, (N'Anthony', 'Male')
		
		, (N'Emma', 'Female')
		, (N'Olivia', 'Female')
		, (N'Ava', 'Female')
		, (N'Mia', 'Female')
		, (N'Amelia', 'Female')
		, (N'Madison', 'Female')
		, (N'Abigail', 'Female')
		, (N'Lily', 'Female')
		, (N'Ella', 'Female')
		, (N'Chloe', 'Female')

	insert into @LastName
		(LastName, HumanGender)
	values
		(N'Smith', 'Male') 
		, (N'Johnson', 'Male')
		, (N'Williams', 'Male')
		, (N'Jones', 'Male')
		, (N'Brown', 'Male')
		, (N'Davis', 'Male')
		, (N'Miller', 'Male')
		, (N'Wilson', 'Male')
		, (N'Moore', 'Male')
		, (N'Taylor', 'Male')
		, (N'Anderson', 'Male')
		, (N'Thomas', 'Male')
		, (N'Jackson', 'Male')
		, (N'White', 'Male')
		, (N'Harris', 'Male')
		, (N'Martin', 'Male')
		
		, (N'Smith', 'Female') 
		, (N'Johnson', 'Female')
		, (N'Williams', 'Female')
		, (N'Jones', 'Female')
		, (N'Brown', 'Female')
		, (N'Davis', 'Female')
		, (N'Miller', 'Female')
		, (N'Wilson', 'Female')
		, (N'Moore', 'Female')
		, (N'Taylor', 'Female')
		, (N'Anderson', 'Female')
		, (N'Thomas', 'Female')
		, (N'Jackson', 'Female')
		, (N'White', 'Female')
		, (N'Harris', 'Female')
		, (N'Martin', 'Female')



end
else if @CurrentCustomization = 51577460000000/*Ukraine*/
begin

	insert into	@Diagnosis (Diagnosis)
	values (N'COVID-19')

	insert into	@CaseClassification (CaseClassification)
	values
		    (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  --,	(N'Confirmed')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Probable')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Suspect')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  --, (N'Lost to Follow-up')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')

		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')


	insert into @FirstName
		(FirstName, HumanGender)
	values
		  (N'Анатолій', 'Male')
		, (N'Андрон', 'Male')
		, (N'Аркадій', 'Male')
		, (N'Арсен', 'Male')
		, (N'Артем', 'Male')
		, (N'Орхип', 'Male')
		, (N'Біломир', 'Male')
		, (N'Білослав', 'Male')
		, (N'Богдан', 'Male')
		, (N'Божан', 'Male')
		, (N'Братислав', 'Male')
		, (N'Валентин', 'Male')
		, (N'Валерій', 'Male')
		, (N'Василь', 'Male')
		, (N'Вадим', 'Male')
		, (N'Ведан', 'Male')
		, (N'Віктор', 'Male')
		, (N'Владислав', 'Male')
		, (N'В''ячеслав', 'Male')
		, (N'Гаврило', 'Male')
		, (N'Геннадій', 'Male')
		, (N'Георгій', 'Male')
		, (N'Герасим', 'Male')
		, (N'Гліб', 'Male')
		, (N'Данило', 'Male')
		, (N'Денис', 'Male')
		, (N'Дмитро', 'Male')
		, (N'Євгеній', 'Male')
		, (N'Єгор', 'Male')
		, (N'Живослав', 'Male')
		, (N'Житомир', 'Male')
		, (N'Захар', 'Male')
		, (N'Земислав', 'Male')
		, (N'Зіновій', 'Male')
		, (N'Іван', 'Male')
		, (N'Ігор', 'Male')
		, (N'Кирило', 'Male')
		, (N'Корній', 'Male')
		, (N'Костянтин', 'Male')
		, (N'Кузьма', 'Male')
		, (N'Лев', 'Male')
		, (N'Леонід', 'Male')
		, (N'Любим', 'Male')
		, (N'Лука', 'Male')
		, (N'Макар', 'Male')
		, (N'Максим', 'Male')
		, (N'Матвій', 'Male')
		, (N'Мечислав', 'Male')
		, (N'Микола', 'Male')
		, (N'Милан', 'Male')
		, (N'Мстислав', 'Male')
		, (N'Никифор', 'Male')
		, (N'Никодим', 'Male')
		, (N'Олег', 'Male')
		, (N'Олександр', 'Male')
		, (N'Олексій', 'Male')
		, (N'Ондрій', 'Male')
		, (N'Павло', 'Male')
		, (N'Петро', 'Male')
		, (N'Радило', 'Male')
		, (N'Радим', 'Male')
		, (N'Роман', 'Male')
		, (N'Ростислав', 'Male')
		, (N'Свирид', 'Male')
		, (N'Світозар', 'Male')
		, (N'Світослав', 'Male')
		, (N'Святополк', 'Male')
		, (N'Святослав', 'Male')
		, (N'Слава', 'Male')
		, (N'Станислав', 'Male')
		, (N'Терентій', 'Male')
		, (N'Тимофій', 'Male')
		, (N'Тихон', 'Male')
		, (N'Устим', 'Male')
		, (N'Федір', 'Male')
		, (N'Юліан', 'Male')
		, (N'Юрій', 'Male')
		, (N'Яр', 'Male')
		, (N'Ярило', 'Male')
		, (N'Ярослав', 'Male')
		
		, (N'Агафія', 'Female')
		, (N'Аглая', 'Female')
		, (N'Алена', 'Female')
		, (N'Аліна', 'Female')
		, (N'Аліса', 'Female')
		, (N'Алісія', 'Female')
		, (N'Алла', 'Female')
		, (N'Анастасія', 'Female')
		, (N'Анна', 'Female')
		, (N'Антоніна', 'Female')
		, (N'Валерія', 'Female')
		, (N'Василина', 'Female')
		, (N'Вероніка', 'Female')
		, (N'Вікторія', 'Female')
		, (N'Віра', 'Female')
		, (N'Галина', 'Female')
		, (N'Дарина', 'Female')
		, (N'Дарія', 'Female')
		, (N'Євгенія', 'Female')
		, (N'Євдокія', 'Female')
		, (N'Єлизавета', 'Female')
		, (N'Злата', 'Female')
		, (N'Зоряна', 'Female')
		, (N'Іванна', 'Female')
		, (N'Інна', 'Female')
		, (N'Ірина', 'Female')
		, (N'Катерина', 'Female')
		, (N'Кіра', 'Female')
		, (N'Ксенія', 'Female')
		, (N'Лариса', 'Female')
		, (N'Лілія', 'Female')
		, (N'Любов', 'Female')
		, (N'Людмила', 'Female')
		, (N'Марина', 'Female')
		, (N'Марія', 'Female')
		, (N'Милана', 'Female')
		, (N'Мирослава', 'Female')
		, (N'Надія', 'Female')
		, (N'Наталя', 'Female')
		, (N'Оксана', 'Female')
		, (N'Олександра', 'Female')
		, (N'Олена', 'Female')
		, (N'Олеся', 'Female')
		, (N'Ольга', 'Female')
		, (N'Парасковія', 'Female')
		, (N'Пенні', 'Female')
		, (N'Рада', 'Female')
		, (N'Рита', 'Female')
		, (N'Світлана', 'Female')
		, (N'Софія', 'Female')
		, (N'Тетяна', 'Female')
		, (N'Урсула', 'Female')
		, (N'Феодора', 'Female')
		, (N'Феофанія', 'Female')
		, (N'Христина', 'Female')
		, (N'Юлія', 'Female')
		, (N'Юстина', 'Female')
		, (N'Ядвіга', 'Female')
		, (N'Яна', 'Female')
		, (N'Ярослава', 'Female')

	insert into	@SecondName
		(SecondName, HumanGender)
	values
		  (N'Іванович', 'Male')
		, (N'Сергійович', 'Male')
		, (N'Анатоліїйович', 'Male')
		, (N'Дмитрович', 'Male')
		, (N'Миколайович', 'Male')
		, (N'Антонович', 'Male')
		, (N'Петрович', 'Male')
		, (N'Олександрович', 'Male')
		, (N'Григорович', 'Male')
		, (N'Юрійович', 'Male')
		, (N'Дем''янович', 'Male')
		, (N'Віталійович', 'Male')
		, (N'Константинович', 'Male')
		, (N'Геннадійович', 'Male')
		, (N'Левович', 'Male')
		, (N'Володимирович', 'Male')
		, (N'Олегович', 'Male')
		, (N'Степанович', 'Male')
		, (N'Федорович', 'Male')
		, (N'Васильович', 'Male')
		, (N'Валерійович', 'Male')
		, (N'Леонідович', 'Male')
		, (N'Михайлович', 'Male')
		, (N'Францович', 'Male')
		, (N'В''ячеславович', 'Male')
		, (N'Якович', 'Male')
		, (N'Микитович', 'Male')
		, (N'Валентинович', 'Male')
		, (N'Андрійович', 'Male')
		, (N'Євстафійович', 'Male')
		, (N'Павлович', 'Male')
		, (N'Борисович', 'Male')
		, (N'Юрийович', 'Male')
		, (N'Ігорович', 'Male')
		, (N'Григорович', 'Male')
		, (N'Вахтангович', 'Male')
		, (N'Олегович', 'Male')
		, (N'Самуілович', 'Male')
		, (N'Костянтинович', 'Male')
		, (N'Іванівна', 'Female')
		, (N'Сергіївна', 'Female')
		, (N'Анатоліївна', 'Female')
		, (N'Дмитрівна', 'Female')
		, (N'Миколаївна', 'Female')
		, (N'Антонівна', 'Female')
		, (N'Петрівна', 'Female')
		, (N'Олександрівна', 'Female')
		, (N'Степанівна', 'Female')
		, (N'Федорівна', 'Female')
		, (N'Василівна', 'Female')
		, (N'Валеріївна', 'Female')
		, (N'Леонідівна', 'Female')
		, (N'Михайлівна', 'Female')
		, (N'Володимирівна', 'Female')
		, (N'Тадеушівна', 'Female')
		, (N'Францівна', 'Female')
		, (N'В''ячеславівна', 'Female')
		, (N'Яківна', 'Female')
		, (N'Микитівна', 'Female')
		, (N'Валентинівна', 'Female')
		, (N'Андріївна', 'Female')
		, (N'Панфілівна', 'Female')
		, (N'Євстафіївна', 'Female')
		, (N'Павлівна', 'Female')
		, (N'Борисівна', 'Female')
		, (N'Віталіївна', 'Female')
		, (N'Борисівна', 'Female')
		, (N'Юріївна', 'Female')
		, (N'Ігорівна', 'Female')
		, (N'Григорівна', 'Female')
		, (N'Пимонівна', 'Female')
		, (N'Вахтангівна', 'Female')
		, (N'Олегівна', 'Female')
		, (N'Самуілівна', 'Female')
		, (N'Костянтинівна', 'Female')


	insert into @LastName
		(LastName, HumanGender)
	values
		  (N'Абраменко', 'Male')
		, (N'Абрамчук', 'Female')
		, (N'Авдєєнко', 'Male')
		, (N'Авдієнко', 'Female')
		, (N'Алешко', 'Male')
		, (N'Алєксейчук', 'Female')
		, (N'Алєксєєнко', 'Male')
		, (N'Алєксєйчук', 'Female')
		, (N'Андрейко', 'Male')
		, (N'Антипенко', 'Female')
		, (N'Антипченко', 'Male')
		, (N'Артемук', 'Female')
		, (N'Артемчук', 'Male')
		, (N'Архіпенко', 'Female')
		, (N'Архіпчук', 'Male')
		, (N'Бабаєнко', 'Female')
		, (N'Бабій', 'Male')
		, (N'Бабіч', 'Female')
		, (N'Батейко', 'Male')
		, (N'Батенко', 'Female')
		, (N'Бойко ', 'Male')
		, (N'Бондаренко', 'Female')
		, (N'Будило', 'Male')
		, (N'Буділко', 'Female')
		, (N'Будко', 'Male')
		, (N'Вакуленко', 'Female')
		, (N'Вакулко', 'Male')
		, (N'Василейко', 'Female')
		, (N'Василенко', 'Male')
		, (N'Вдовиченко', 'Female')
		, (N'Велещук', 'Male')
		, (N'Велічко', 'Female')
		, (N'Гаврилко', 'Male')
		, (N'Галушко', 'Female')
		, (N'Гривко', 'Male')
		, (N'Григоренко', 'Female')
		, (N'Давиденко', 'Male')
		, (N'Дем’яненко', 'Female')
		, (N'Дем’янчук', 'Male')
		, (N'Деменко', 'Female')
		, (N'Діхтяренко', 'Male')
		, (N'Дмитерчук', 'Female')
		, (N'Євтушенко', 'Male')
		, (N'Ємельяненко', 'Female')
		, (N'Єфименко', 'Male')
		, (N'Єфіменко', 'Female')
		, (N'Жезло', 'Male')
		, (N'Железко', 'Female')
		, (N'Желізко', 'Male')
		, (N'Замирайло', 'Female')
		, (N'Замковенко', 'Male')
		, (N'Зінченко ', 'Female')
		, (N'Іванчук', 'Male')
		, (N'Іванько', 'Female')
		, (N'Іващенко', 'Male')
		, (N'Кир''яненко', 'Female')
		, (N'Кондратюк', 'Male')
		, (N'Кондрачук', 'Female')
		, (N'Кондрашко', 'Male')
		, (N'Лазоренко', 'Female')
		, (N'Лаптієнко', 'Male')
		, (N'Лапченко', 'Female')
		, (N'Лопошук', 'Male')
		, (N'Мар''яненко', 'Female')
		, (N'Матвіенко', 'Male')
		, (N'Міняйло', 'Female')
		, (N'Мушенко', 'Male')
		, (N'Нагайко', 'Female')
		, (N'Назарченко', 'Male')
		, (N'Наливайко', 'Female')
		, (N'Носко', 'Male')
		, (N'Овчаренко', 'Female')
		, (N'Онищенко', 'Male')
		, (N'Онищук', 'Female')
		, (N'Орлик', 'Male')
		, (N'Павлюченко', 'Female')
		, (N'Павлючук', 'Male')
		, (N'Паленко', 'Female')
		, (N'Петреченко', 'Male')
		, (N'Плічко', 'Female')
		, (N'Плішенко', 'Male')
		, (N'Половинченко', 'Female')
		, (N'Порохонько', 'Male')
		, (N'Потійко', 'Female')
		, (N'Прихідько', 'Male')
		, (N'Приходько', 'Female')
		, (N'Ревенко', 'Male')
		, (N'Ревенчук', 'Female')
		, (N'Ревко', 'Male')
		, (N'Резниченко', 'Female')
		, (N'Резніченко', 'Male')
		, (N'Савченко ', 'Female')
		, (N'Сидорченко', 'Male')
		, (N'Сидорчук', 'Female')
		, (N'Скріпченко', 'Male')
		, (N'Сосєдко', 'Female')
		, (N'Сосідко', 'Male')
		, (N'Теремчук', 'Female')
		, (N'Теренчук', 'Male')
		, (N'Тимошенко ', 'Female')
		, (N'Трубенко', 'Male')
		, (N'Удовиченко', 'Female')
		, (N'Удовіченко', 'Male')
		, (N'Федоренко ', 'Female')
		, (N'Філіпченко', 'Male')
		, (N'Халапенко', 'Female')
		, (N'Хатько', 'Male')
		, (N'Ходченко', 'Female')
		, (N'Целуйко', 'Male')
		, (N'Ціпенко', 'Female')
		, (N'Чеботько', 'Male')
		, (N'Черненко', 'Female')
		, (N'Чурило', 'Male')
		, (N'Швидко', 'Female')
		, (N'Швидько', 'Male')
		, (N'Шумило ', 'Female')
		, (N'Юрійчук', 'Male')
		, (N'Явдокименко', 'Female')
		, (N'Яцук', 'Male')
		, (N'Ящук', 'Female')
		, (N'Абраменко', 'Female')
		, (N'Абрамчук', 'Male')
		, (N'Алєксєєнко', 'Female')
		, (N'Алєксєйчук', 'Male')
		, (N'Артемчук', 'Female')
		, (N'Архіпенко', 'Male')
		, (N'Батейко', 'Female')
		, (N'Батенко', 'Male')
		, (N'Будко', 'Female')
		, (N'Вакуленко', 'Male')
		, (N'Велещук', 'Female')
		, (N'Велічко', 'Male')
		, (N'Давиденко', 'Female')
		, (N'Дем’яненко', 'Male')
		, (N'Євтушенко', 'Female')
		, (N'Ємельяненко', 'Male')
		, (N'Желізко', 'Female')
		, (N'Замирайло', 'Male')
		, (N'Іващенко', 'Female')
		, (N'Кир''яненко', 'Male')
		, (N'Лаптієнко', 'Female')
		, (N'Лапченко', 'Male')
		, (N'Мушенко', 'Female')
		, (N'Нагайко', 'Male')
		, (N'Онищенко', 'Female')
		, (N'Онищук', 'Male')
		, (N'Петреченко', 'Female')
		, (N'Плічко', 'Male')
		, (N'Прихідько', 'Female')
		, (N'Приходько', 'Male')
		, (N'Резніченко', 'Female')
		, (N'Савченко ', 'Male')
		, (N'Сосідко', 'Female')
		, (N'Теремчук', 'Male')
		, (N'Удовіченко', 'Female')
		, (N'Федоренко ', 'Male')
		, (N'Целуйко', 'Female')
		, (N'Ціпенко', 'Male')
		, (N'Швидько', 'Female')
		, (N'Шумило ', 'Male')


end
else if @CurrentCustomization = 51577430000000/*Georgia*/
begin

	insert into @FirstName
		(FirstName, HumanGender)
	values
		(N'Jacob', 'Male')
		, (N'Ethan', 'Male')
		, (N'Michael', 'Male')
		, (N'Alexander', 'Male')
		, (N'William', 'Male')
		, (N'Joshua', 'Male')
		, (N'Daniel', 'Male')
		, (N'Jayden', 'Male')
		, (N'Noah', 'Male')
		, (N'Anthony', 'Male')
		
		, (N'Emma', 'Female')
		, (N'Olivia', 'Female')
		, (N'Ava', 'Female')
		, (N'Mia', 'Female')
		, (N'Amelia', 'Female')
		, (N'Madison', 'Female')
		, (N'Abigail', 'Female')
		, (N'Lily', 'Female')
		, (N'Ella', 'Female')
		, (N'Chloe', 'Female')

	insert into @LastName
		(LastName, HumanGender)
	values
		(N'Smith', 'Male') 
		, (N'Johnson', 'Male')
		, (N'Williams', 'Male')
		, (N'Jones', 'Male')
		, (N'Brown', 'Male')
		, (N'Davis', 'Male')
		, (N'Miller', 'Male')
		, (N'Wilson', 'Male')
		, (N'Moore', 'Male')
		, (N'Taylor', 'Male')
		, (N'Anderson', 'Male')
		, (N'Thomas', 'Male')
		, (N'Jackson', 'Male')
		, (N'White', 'Male')
		, (N'Harris', 'Male')
		, (N'Martin', 'Male')
		
		, (N'Smith', 'Female') 
		, (N'Johnson', 'Female')
		, (N'Williams', 'Female')
		, (N'Jones', 'Female')
		, (N'Brown', 'Female')
		, (N'Davis', 'Female')
		, (N'Miller', 'Female')
		, (N'Wilson', 'Female')
		, (N'Moore', 'Female')
		, (N'Taylor', 'Female')
		, (N'Anderson', 'Female')
		, (N'Thomas', 'Female')
		, (N'Jackson', 'Female')
		, (N'White', 'Female')
		, (N'Harris', 'Female')
		, (N'Martin', 'Female')
	

	insert into	@CaseClassification (CaseClassification)
	values
		    (N'Confirmed')
		  , (N'Suspect')
		  , (N'Suspect')
		  , (N'Confirmed')
		  , (N'Confirmed')
		  , (N'Not a Case')
		  , (N'Suspect')
		  , (N'Probable')
		  , (N'Suspect')
		  , (N'Suspect')
		  , (N'Not a Case')
		  , (N'Suspect')
		  , (N'Suspect')
		  , (N'Probable')
		  , (N'Probable')
		  , (N'Confirmed')
		  , (N'Suspect')
		  , (N'Not a Case')
		  , (N'Suspect')
		  , (N'Suspect')
		  , (N'Suspect')
		  , (N'Confirmed')
		  , (N'Confirmed')
		  , (N'Suspect')
		  , (N'Suspect')
		  , (N'Suspect')
		  , (N'Confirmed')
		  , (N'Confirmed')
		  , (N'Probable')
		  , (N'Suspect')
		  , (N'Not a Case')
		  , (N'Suspect')
		  , (N'Probable')
		  , (N'Probable')
		  , (N'Confirmed')
		  , (N'Confirmed')
		  , (N'Suspect')
		  , (N'Not a Case')
		  , (N'Suspect')
		  , (N'Confirmed')
		  , (N'Not a Case')
		  , (N'Confirmed')
		  , (N'Confirmed')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Confirmed')
		  , (N'Suspect')
		  , (N'Not a Case')
		  , (N'Confirmed')
		  , (N'Suspect')
		  , (N'Confirmed')
		  , (N'Suspect')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Confirmed')
		  , (N'Confirmed')
		  , (N'Not a Case')
		  , (N'Not a Case')
		  , (N'Probable')
		  , (N'Not a Case')
		  , (N'Probable')
		  , (N'Confirmed')
		  , (N'Probable')
		  , (N'Suspect')
		  , (N'Confirmed')
		  , (N'Suspect')
		  , (N'Probable')
		  , (N'Confirmed')
		  , (N'Probable')
		  , (N'Not a Case')
		  , (N'Confirmed')
		  , (N'Probable')
		  , (N'Confirmed')
		  , (N'Probable')
		  , (N'Not a Case')
		  , (N'Suspect')
		  , (N'Confirmed')
		  , (N'Not a Case')
		  , (N'Suspect')
		  , (N'Suspect')
		  , (N'Not a Case')
		  , (N'Confirmed')
		  , (N'Suspect')


	insert into	@Diagnosis (Diagnosis, idfsDiagnosis)
	select	diag_list.[name], diag_list.idfsDiagnosis
	from
	(
		select	r_d.[name], d.idfsDiagnosis
		from	trtDiagnosis d
			join	fnReference('en', 19000019 /*Diagnosis*/) r_d
			on		r_d.idfsReference = d.idfsDiagnosis
		where	d.idfsUsingType = 10020001 /*Case-based*/
				and d.intRowStatus = 0	
				and r_d.intHACode & 2 /*Human*/ > 0
				and (	@existDiagnosisToSampleType = 0
						or	exists	(
								select 1
								from	trtMaterialForDisease mfd
								where	mfd.idfsDiagnosis = d.idfsDiagnosis
										and mfd.intRowStatus = 0
									)
					)
				and (	@existDiagnosisToTestName = 0
						or	exists	(
								select 1
								from	trtTestForDisease tfd
								where	tfd.idfsDiagnosis = d.idfsDiagnosis
										and tfd.intRowStatus = 0
									)
					)
		union all
		(	select N'' as [name], cast(null as bigint) as idfsDiagnosis
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
		)
	) diag_list
	order by NEWID()


	insert into @Region
		(RegionName)
	values 
		  (N'')
		, (N'Adjara')
		, (N'')
		, (N'')
		, (N'')
		, (N'Guria')
		, (N'')
		, (N'')
		, (N'')
		, (N'')
		, (N'Imereti')
		, (N'')
		, (N'')
		, (N'')
		, (N'')
		, (N'Kakheti')
		, (N'')
		, (N'')
		, (N'')
		, (N'')
		, (N'Tbilisi')
		, (N'')
		, (N'')
		, (N'')
		, (N'')
		, (N'')
		, (N'')
		, (N'')
		, (N'')

end
else 
begin

	insert into @FirstName
		(FirstName, HumanGender)
	values
		(N'Jacob', 'Male')
		, (N'Ethan', 'Male')
		, (N'Michael', 'Male')
		, (N'Alexander', 'Male')
		, (N'William', 'Male')
		, (N'Joshua', 'Male')
		, (N'Daniel', 'Male')
		, (N'Jayden', 'Male')
		, (N'Noah', 'Male')
		, (N'Anthony', 'Male')
		
		, (N'Emma', 'Female')
		, (N'Olivia', 'Female')
		, (N'Ava', 'Female')
		, (N'Mia', 'Female')
		, (N'Amelia', 'Female')
		, (N'Madison', 'Female')
		, (N'Abigail', 'Female')
		, (N'Lily', 'Female')
		, (N'Ella', 'Female')
		, (N'Chloe', 'Female')

	insert into @LastName
		(LastName, HumanGender)
	values
		(N'Smith', 'Male') 
		, (N'Johnson', 'Male')
		, (N'Williams', 'Male')
		, (N'Jones', 'Male')
		, (N'Brown', 'Male')
		, (N'Davis', 'Male')
		, (N'Miller', 'Male')
		, (N'Wilson', 'Male')
		, (N'Moore', 'Male')
		, (N'Taylor', 'Male')
		, (N'Anderson', 'Male')
		, (N'Thomas', 'Male')
		, (N'Jackson', 'Male')
		, (N'White', 'Male')
		, (N'Harris', 'Male')
		, (N'Martin', 'Male')
		
		, (N'Smith', 'Female') 
		, (N'Johnson', 'Female')
		, (N'Williams', 'Female')
		, (N'Jones', 'Female')
		, (N'Brown', 'Female')
		, (N'Davis', 'Female')
		, (N'Miller', 'Female')
		, (N'Wilson', 'Female')
		, (N'Moore', 'Female')
		, (N'Taylor', 'Female')
		, (N'Anderson', 'Female')
		, (N'Thomas', 'Female')
		, (N'Jackson', 'Female')
		, (N'White', 'Female')
		, (N'Harris', 'Female')
		, (N'Martin', 'Female')



	insert into	@Diagnosis (Diagnosis, idfsDiagnosis)
	select	diag_list.[name], diag_list.idfsDiagnosis
	from
	(
		select	r_d.[name], d.idfsDiagnosis
		from	trtDiagnosis d
			join	fnReference('en', 19000019 /*Diagnosis*/) r_d
			on		r_d.idfsReference = d.idfsDiagnosis
		where	d.idfsUsingType = 10020001 /*Case-based*/
				and d.intRowStatus = 0	
				and r_d.intHACode & 2 /*Human*/ > 0
				and (	@existDiagnosisToSampleType = 0
						or	exists	(
								select 1
								from	trtMaterialForDisease mfd
								where	mfd.idfsDiagnosis = d.idfsDiagnosis
										and mfd.intRowStatus = 0
									)
					)
				and (	@existDiagnosisToTestName = 0
						or	exists	(
								select 1
								from	trtTestForDisease tfd
								where	tfd.idfsDiagnosis = d.idfsDiagnosis
										and tfd.intRowStatus = 0
									)
					)
		union all
		(	select N'' as [name], cast(null as bigint) as idfsDiagnosis
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
			union all select N'', cast(null as bigint)
		)
	) diag_list
	order by NEWID()

	insert into @Region
		(RegionName)
	values 
		  (N'')
		, (N'Adjara')
		, (N'')
		, (N'')
		, (N'')
		, (N'Guria')
		, (N'')
		, (N'')
		, (N'')
		, (N'')
		, (N'Imereti')
		, (N'')
		, (N'')
		, (N'')
		, (N'')
		, (N'Kakheti')
		, (N'')
		, (N'')
		, (N'')
		, (N'')
		, (N'Tbilisi')
		, (N'')
		, (N'')
		, (N'')
		, (N'')
		, (N'')
		, (N'')
		, (N'')
		, (N'')


end


-- Fill in customazable values based on Customization package: end


-- Update Ids in the tables with customizable values - start


update	lng_selected
set		lng_selected.idfsLanguage = br_lng.idfsBaseReference
from	@Lng lng_selected
join	trtBaseReference br_lng
on		br_lng.idfsReferenceType = 19000049 /*Language*/
		and br_lng.intRowStatus = 0
		and br_lng.strBaseReferenceCode = lng_selected.LngCode collate Cyrillic_General_CI_AS

delete	lng_selected
from	@Lng lng_selected
where	lng_selected.idfsLanguage is null

if not exists (select 1 from @Lng)
begin
	insert into	@Lng (LngCode, idfsLanguage)
	select	br_lng.strBaseReferenceCode, lng_to_cp.idfsLanguage
	from	trtLanguageToCP lng_to_cp
		join	trtBaseReference br_lng
		on		br_lng.idfsReferenceType = 19000049 /*Language*/
				and br_lng.intRowStatus = 0
				and br_lng.idfsBaseReference = lng_to_cp.idfsLanguage
	where	lng_to_cp.idfCustomizationPackage = @CurrentCustomization
end


update	reg_selected
set		reg_selected.RegionId = reg.idfsRegion
from	@Region reg_selected
join	gisRegion reg
	join	fnGisReference('en', 19000003 /*Region*/) r_reg
	on		r_reg.idfsReference = reg.idfsRegion
on		reg.idfsCountry = @CurrentCountry
		and reg.intRowStatus = 0
		and r_reg.[name] = reg_selected.RegionName collate Cyrillic_General_CI_AS


if not exists (select 1 from @Region)
begin
	insert into	@Region (RegionName, RegionId)
	select	r_reg.[name], reg.idfsRegion
	from	gisRegion reg
		join	fnGisReference('en', 19000003 /*Region*/) r_reg
		on		r_reg.idfsReference = reg.idfsRegion
	where	reg.idfsCountry = @CurrentCountry
			and reg.intRowStatus = 0	
end

update	d_selected
set		d_selected.idfsDiagnosis = d.idfsDiagnosis
from	@Diagnosis d_selected
join	trtDiagnosis d
	join	fnReference('en', 19000019 /*Diagnosis*/) r_d
	on		r_d.idfsReference = d.idfsDiagnosis
on		d.idfsUsingType = 10020001 /*Case-based*/
		and d.intRowStatus = 0
		and r_d.[name] = d_selected.Diagnosis collate Cyrillic_General_CI_AS
		and r_d.intHACode & 2 /*Human*/ > 0



if not exists (select 1 from @Diagnosis)
begin
	insert into	@Diagnosis (Diagnosis, idfsDiagnosis)
	select	r_d.[name], d.idfsDiagnosis
	from	trtDiagnosis d
		join	fnReference('en', 19000019 /*Diagnosis*/) r_d
		on		r_d.idfsReference = d.idfsDiagnosis
	where	d.idfsUsingType = 10020001 /*Case-based*/
			and d.intRowStatus = 0	
			and r_d.intHACode & 2 /*Human*/ > 0
			and (	@existDiagnosisToSampleType = 0
					or	exists	(
							select 1
							from	trtMaterialForDisease mfd
							where	mfd.idfsDiagnosis = d.idfsDiagnosis
									and mfd.intRowStatus = 0
								)
				)
			and (	@existDiagnosisToTestName = 0
					or	exists	(
							select 1
							from	trtTestForDisease tfd
							where	tfd.idfsDiagnosis = d.idfsDiagnosis
									and tfd.intRowStatus = 0
								)
				)
end


update	cc_selected
set		cc_selected.idfsCaseClassification = cc.idfsCaseClassification,
		cc_selected.blnInitialHumanCaseClassification = cc.blnInitialHumanCaseClassification,
		cc_selected.blnFinalHumanCaseClassification = cc.blnFinalHumanCaseClassification
from	@CaseClassification cc_selected
join	trtCaseClassification cc
	join	fnReference('en', 19000011 /*Case Classification*/) r_cc
	on		r_cc.idfsReference = cc.idfsCaseClassification
on		cc.intRowStatus = 0
		and r_cc.[name] = cc_selected.CaseClassification collate Cyrillic_General_CI_AS
		and r_cc.intHACode & 2 /*Human*/ > 0


if not exists (select 1 from @CaseClassification)
begin

	insert into	@CaseClassification (CaseClassification, idfsCaseClassification, blnInitialHumanCaseClassification, blnFinalHumanCaseClassification)
	select		r_cc.[name], cc.idfsCaseClassification, cc.blnInitialHumanCaseClassification, cc.blnFinalHumanCaseClassification
	from		trtCaseClassification cc
	inner join	fnReference('en', 19000011 /*Case Classification*/) r_cc
	on			r_cc.idfsReference = cc.idfsCaseClassification
	where		r_cc.intHACode & 2 > 0
				and cc.intRowStatus = 0
end


update	fn
set		fn.idfsHumanGender = r_hg.idfsReference
from	@FirstName fn
join	fnReference('en', 19000043 /*Human Gender*/) r_hg
on		r_hg.[name] = fn.HumanGender collate Cyrillic_General_CI_AS

update	sn
set		sn.idfsHumanGender = r_hg.idfsReference
from	@SecondName sn
join	fnReference('en', 19000043 /*Human Gender*/) r_hg
on		r_hg.[name] = sn.HumanGender collate Cyrillic_General_CI_AS

update	ln
set		ln.idfsHumanGender = r_hg.idfsReference
from	@LastName ln
join	fnReference('en', 19000043 /*Human Gender*/) r_hg
on		r_hg.[name] = ln.HumanGender collate Cyrillic_General_CI_AS

select	@idfsDefaultSite = s.idfsSite,
		@idfDefaultSiteOrganization = s.idfOffice
from	tstSite s
join	fnInstitution('en') i
on		i.idfOffice = s.idfOffice
where	s.intRowStatus = 0
		and s.idfCustomizationPackage = @CurrentCustomization
		and s.blnIsWEB = 0
		and (	(	isnull(@DefaultSite, N'') = N'' collate Cyrillic_General_CI_AS
					and s.idfsParentSite is null
				)
				or i.[name] = @DefaultSite collate Cyrillic_General_CI_AS
			)

select	@idfsDefaultSiteEmployee = ut.idfPerson
from	AspNetUsers aspU
join	tstUserTable ut
on		ut.idfUserID = aspU.idfUserID
		and ut.intRowStatus = 0
join	tlbPerson p
on		p.idfPerson = ut.idfPerson
		and p.intRowStatus = 0
join	EmployeeToInstitution e_to_i
on		e_to_i.idfInstitution = @idfDefaultSiteOrganization
		and e_to_i.aspNetUserId = aspU.[Id]
		and e_to_i.idfUserId = ut.idfUserID
		and e_to_i.intRowStatus = 0
		and e_to_i.IsDefault = 1
		and e_to_i.Active = 1
where	aspU.[UserName] = N'admin' collate Cyrillic_General_CI_AS

if @idfsDefaultSiteEmployee is null
select	@idfsDefaultSiteEmployee = ut.idfPerson
from	AspNetUsers aspU
join	tstUserTable ut
on		ut.idfUserID = aspU.idfUserID
		and ut.intRowStatus = 0
join	tlbPerson p
on		p.idfPerson = ut.idfPerson
		and p.intRowStatus = 0
join	EmployeeToInstitution e_to_i
on		e_to_i.idfInstitution = @idfDefaultSiteOrganization
		and e_to_i.aspNetUserId = aspU.[Id]
		and e_to_i.idfUserId = ut.idfUserID
		and e_to_i.intRowStatus = 0
		and e_to_i.IsDefault = 1
		and e_to_i.Active = 1
where	aspU.[UserName] = N'demo' collate Cyrillic_General_CI_AS

if @idfsDefaultSiteEmployee is null
select	@idfsDefaultSiteEmployee = ut.idfPerson
from	AspNetUsers aspU
join	tstUserTable ut
on		ut.idfUserID = aspU.idfUserID
		and ut.intRowStatus = 0
join	tlbPerson p
on		p.idfPerson = ut.idfPerson
		and p.intRowStatus = 0
join	EmployeeToInstitution e_to_i
on		e_to_i.idfInstitution = @idfDefaultSiteOrganization
		and e_to_i.aspNetUserId = aspU.[Id]
		and e_to_i.idfUserId = ut.idfUserID
		and e_to_i.intRowStatus = 0
		and e_to_i.IsDefault = 1
		and e_to_i.Active = 1


-- Update Ids in the tables with customizable values - end


-- Temporary tables - start


if object_id('tempdb..##RandomDate') is not null
begin
	execute sp_executesql N'drop table ##RandomDate'
end

if object_id('tempdb..##RandomDate') is null
create table	##RandomDate
(	idfID				bigint not null identity(1,1) primary key,
	intDayDiff			int not null,
	intHour				int not null default(0),
	intMin				int not null default(0),
	intSec				int not null default(0),
	datRandomDate		datetime null,
	datRandomDateTime	datetime null
)
truncate table ##RandomDate


if object_id('tempdb..##GenerateCriteria') is not null
begin
	execute sp_executesql N'drop table ##GenerateCriteria'
end

if object_id('tempdb..##GenerateCriteria') is null
create table	##GenerateCriteria
(	idfID							bigint not null identity(1,18) primary key,
	idfGuid							uniqueidentifier not null default(newid()),
	randValue1						float null,
	randValue2						float null,
	randValue3						float null,
	randValue4						float null,
	randValue5						float null,
	randValue6						float null,
	DiseaseID						bigint null,
	AdministrativeLevelID			bigint null,
	ClassificationTypeID			bigint null,
	DataEntrySiteID					bigint null,
	SentByFacilityID				bigint null,
	HumanGenderID					bigint null,
	DateEnteredFrom					datetime null,
	DateEnteredTo					datetime null,
	DateOfSymptomsOnsetFrom			datetime null,
	DateOfSymptomsOnsetTo			datetime null,
	PatientLastName					nvarchar(200) collate Cyrillic_General_CI_AS null,
	LanguageID						nvarchar(50) collate Cyrillic_General_CI_AS null,
	datExecutionTime				datetime null,
	intProcessedRows				bigint null,
	intResultRows					bigint null,
	intResultPages					int null,
	intLogicalReads					bigint null,
	intLogicalWrites				bigint null,
	intElapsedTimeMicrosecond		bigint null,
	fltElapsedTimeMilisecond		float null,
	intWorkerTimeMicrosecond		bigint null,
	fltWorkerTimeMilisecond			float null,
	intTotalExecutionTimeMiliSecond	bigint null,
	strSearchQuery					nvarchar(max) collate Cyrillic_General_CI_AS null,
)
truncate table ##GenerateCriteria

-- Temporary tables - end

-- Fill random values - start

insert into	##RandomDate (intDayDiff)
select	top (@DateIntervalInDays) dayNum
from	(	
	select a*1000 + b*100 + c*10 + d as dayNum
	from	(
		select 0 as a
		union select 1 union select 2 union select 3 union select 4
		union select 5 union select 6 union select 7 union select 8 union select 9
			) a
	cross join	(
		select 0 as b 
		union select 1 union select 2 union select 3 union select 4
		union select 5 union select 6 union select 7 union select 8 union select 9
				) b
	cross join	(
		select 0 as c 
		union select 1 union select 2 union select 3 union select 4
		union select 5 union select 6 union select 7 union select 8 union select 9
				) c
	cross join	(
		select  0 as d
		union select 1 union  select 2 union select 3 union select 4
		union select 5 union select 6 union select 7 union select 8 union select 9
				) d
	where a*1000 + b*100 + c*10 + d < @DateIntervalInDays
		) a
order by 1


update	rd
set		rd.intHour = isnull(h.hourNum, 0)
from	##RandomDate rd
left join	(
	select top (@DateIntervalInDays)
				case cast(rand()*3 as int) when 0 then h1 when 1 then h2 else h3 end as hourNum,
				row_number() over (order by newid()) as rn
	from		(
		select 7 as h1
		union select 8 union select 9 union select 10 union select 11 union select 12
		union select 13 union select 14 union select 15 union select 16 union select 17 union select 18 union select 19
				) h1
	cross join	(
		select 7 as h2
		union select 8 union select 9 union select 10 union select 11 union select 12
		union select 13 union select 14 union select 15 union select 16 union select 17 union select 18 union select 19
				) h2
	cross join	(
		select 7 as h3
		union select 8 union select 9 union select 10 union select 11 union select 12
		union select 13 union select 14 union select 15 union select 16 union select 17 union select 18 union select 19
				) h3
	cross join	(
		select 7 as h4
		union select 8 union select 9 union select 10 union select 11 union select 12
		union select 13 union select 14 union select 15 union select 16 union select 17 union select 18 union select 19
				) h4	
			) h
on			h.rn = rd.idfID

update	rd
set		rd.intMin = isnull(m.minNum, 0)
from	##RandomDate rd
left join	(
	select top (@DateIntervalInDays)
				case cast(rand()*2 as int) when 0 then mm1*10 + m1 else mm2*10 + m2 end as minNum,
				row_number() over (order by newid()) as rn
	from	(
		select 0 as m1
		union select 1 union select 2 union select 3 union select 4
		union select 5 union select 6 union select 7 union select 8 union select 9
			) m1
	cross join	(
		select 0 as mm1
		union select 1 union select 2 union select 3 union select 4
		union select 5
				) mm1
	cross join	(
		select 0 as m2
		union select 1 union select 2 union select 3 union select 4
		union select 5 union select 6 union select 7 union select 8 union select 9
			) m2
	cross join	(
		select 0 as mm2
		union select 1 union select 2 union select 3 union select 4
		union select 5
				) mm2
	order by newid()
			) m
on			m.rn = rd.idfID
where		rd.intHour > 0

update	##RandomDate
set		datRandomDateTime = dateadd(second, intSec, dateadd(minute, intMin, dateadd(hour, intHour, dateadd(day, -intDayDiff, @EndOfDateInterval /*@Today*/))))


insert into	##GenerateCriteria (idfGuid, randValue1, randValue2, randValue3, randValue4, randValue5, randValue6)
select	top (@SearchCnt) cases.idfGuid, cases.randValue1, cases.randValue2, cases.randValue3, cases.randValue4, cases.randValue5, cases.randValue6
from	(	
	select NEWID() as idfGuid, 
	rand(g*1000000 + f*100000 + e*10000 + d*1000 + c*100 + b*10 + a) as randValue1,
	rand(e*1000000 + g*100000 + d*10000 + f*1000 + c*100 + a*10 + b) as randValue2,
	rand(f*1000000 + g*100000 + e*10000 + a*1000 + b*100 + d*10 + c) as randValue3,
	rand(c*1000000 + f*100000 + b*10000 + e*1000 + c*100 + a*10 + d) as randValue4,
	rand(d*1000000 + c*100000 + b*10000 + g*1000 + f*100 + e*10 + a) as randValue5,
	rand(a*1000000 + b*100000 + g*10000 + c*1000 + d*100 + f*10 + e) as randValue6
	
	from	(
		select 0 as a
		union select 1 union select 2 union select 3 union select 4
		union select 5 union select 6 union select 7 union select 8 union select 9
			) a
	cross join	(
		select 0 as b 
		union select 1 union select 2 union select 3 union select 4
		union select 5 union select 6 union select 7 union select 8 union select 9
				) b
	cross join	(
		select 0 as c 
		union select 1 union select 2 union select 3 union select 4
		union select 5 union select 6 union select 7 union select 8 union select 9
				) c
	cross join	(
		select  0 as d
		union select 1 union  select 2 union select 3 union select 4
		union select 5 union select 6 union select 7 union select 8 union select 9
				) d
	cross join	(
		select  0 as e
		union select 1 union  select 2 union select 3 union select 4
		union select 5 union select 6 union select 7 union select 8 union select 9
				) e
	cross join	(
		select  0 as f
		union select 1 union  select 2 union select 3 union select 4
		union select 5 union select 6 union select 7 union select 8 union select 9
				) f
	cross join	(
		select  0 as g
		union select 1 union  select 2 union select 3 union select 4
		union select 5 union select 6 union select 7 union select 8 union select 9
				) g
	where a*1000000 + b*100000 + c*10000 + d*1000 + e*100 + f*10 + g < @SearchCnt
		) cases
order by NEWID()



update		ghc
set			ghc.AdministrativeLevelID = Region.RegionId
from		##GenerateCriteria ghc
outer apply	(
	select
				count(reg_selected.idfID) as regCount
	from		@Region reg_selected
			) RegionCount
left join	(
	select
				reg_selected.RegionId, row_number () over (order by newid()) as rn
	from		@Region reg_selected
			) Region
on			Region.rn = cast((ghc.randValue1*RegionCount.regCount+1) as int)		


update		ghc
set			ghc.AdministrativeLevelID = Rayon.idfsRayon
from		##GenerateCriteria ghc
outer apply	(
	select
				count(ray.idfsRayon) as rayCount
	from		gisRayon ray
	left join	gisDistrictSubdistrict dsd
	on			dsd.idfsParent = ray.idfsRayon
	where		ray.idfsCountry = @CurrentCountry
				and ray.intRowStatus = 0
				and ray.idfsRegion = ghc.AdministrativeLevelID
				and dsd.idfsGeoObject is null
			) RayonCount
left join	(
	select
				ray.idfsRayon, ray.idfsRegion, ray.strHASC, row_number () over (partition by ray.idfsRegion order by newid()) as rn
	from		gisRayon ray
	left join	gisDistrictSubdistrict dsd
	on			dsd.idfsParent = ray.idfsRayon
	where		ray.idfsCountry = @CurrentCountry
				and ray.intRowStatus = 0
				and dsd.idfsGeoObject is null
			) Rayon
on			Rayon.idfsRegion = ghc.AdministrativeLevelID
			and Rayon.rn = cast((ghc.randValue2*RayonCount.rayCount+1) as int)
where		ghc.randValue6 > 0.3


update		ghc
set			ghc.HumanGenderID = item.idfsReference
from		##GenerateCriteria ghc
outer apply	(
	select
				count(r_hg.idfsReference) as intCount
	from		fnReference('en', 19000043 /*Human Gender*/) r_hg
			) itemsCount
left join	(
	select
				r_hg.idfsReference, row_number () over (order by newid()) as rn
	from		fnReference('en', 19000043 /*Human Gender*/) r_hg
			) item
on			item.rn = cast((ghc.randValue1*itemsCount.intCount+1) as int)		

update		ghc
set			ghc.PatientLastName = item.LastName
from		##GenerateCriteria ghc
outer apply	(
	select
				count(ln.idfID) as intCount
	from		@LastName ln
	where		ln.idfsHumanGender = ghc.HumanGenderID
			) itemsCount
left join	(
	select
				ln.LastName, ln.idfsHumanGender, row_number () over (partition by ln.idfsHumanGender order by newid()) as rn
	from		@LastName ln
			) item
on			item.idfsHumanGender = ghc.HumanGenderID
			and item.rn = cast((ghc.randValue1*itemsCount.intCount+1) as int)		
where		ghc.randValue3 > 0.8



update		ghc
set			ghc.LanguageID = item.LngCode
from		##GenerateCriteria ghc
outer apply	(
	select
				count(l.idfID) as intCount
	from		@Lng l
			) itemsCount
left join	(
	select
				l.idfsLanguage, l.LngCode, row_number () over (order by newid()) as rn
	from		@Lng l
			) item
on			item.rn = cast((ghc.randValue6*itemsCount.intCount+1) as int)		


update		ghc
set			ghc.DataEntrySiteID = isnull(item.idfOffice, @idfDefaultSiteOrganization)
from		##GenerateCriteria ghc
left join	gisLocation l_ghc
on			l_ghc.idfsLocation = ghc.AdministrativeLevelID
outer apply	(
	select
				count(s.idfsSite) as intCount
	from		tstSite s
	join		tlbOffice o
	on			o.idfOffice = s.idfOffice
	left join	tlbGeoLocationShared gls
	on			gls.idfGeoLocationShared = o.idfLocation
	left join	gisLocation l
	on			l.idfsLocation = gls.idfsLocation
	where		s.intRowStatus = 0
				and s.idfCustomizationPackage = @CurrentCustomization
				and s.blnIsWEB = 0
				and (	l_ghc.idfsLocation is null
						or	(	l_ghc.idfsLocation is not null
								and l.[node].IsDescendantOf(l_ghc.[node]) = 1 
							)
					)
				and (	(@CurrentCustomization = 51577430000000 /*Georgia*/ and isnull(s.intFlags, o.intHACode) & 2 /*Human*/ > 0)
						or (@CurrentCustomization <> 51577430000000 /*Georgia*/ and isnull(o.intHACode, 0) & 2 /*Human*/ > 0)
					)
			) itemsCount
left join	(
	select
				s.idfsSite, o.idfOffice, l.idfsLocation, l.[node], s.idfsParentSite, 
				row_number () over (partition by gls.idfsRegion, gls.idfsRayon, s.idfsParentSite order by newid()) as rn
	from		tstSite s
	join		tlbOffice o
	on			o.idfOffice = s.idfOffice
	left join	tlbGeoLocationShared gls
	on			gls.idfGeoLocationShared = o.idfLocation
	left join	gisLocation l
	on			l.idfsLocation = gls.idfsLocation
	where		s.intRowStatus = 0
				and s.idfCustomizationPackage = @CurrentCustomization
				and s.blnIsWEB = 0
				and (	(@CurrentCustomization = 51577430000000 /*Georgia*/ and isnull(s.intFlags, o.intHACode) & 2 /*Human*/ > 0)
						or (@CurrentCustomization <> 51577430000000 /*Georgia*/ and isnull(o.intHACode, 0) & 2 /*Human*/ > 0)
					)
			) item
on			(	l_ghc.idfsLocation is null
				or	(	l_ghc.idfsLocation is not null
						and item.[node].IsDescendantOf(l_ghc.[node]) = 1 
					)
			)
			and item.rn = cast((ghc.randValue4*itemsCount.intCount+1) as int)
where		ghc.randValue6 < 0.5


update		ghc
set			ghc.SentByFacilityID = item.idfOffice
from		##GenerateCriteria ghc
left join	gisLocation l_ghc
on			l_ghc.idfsLocation = ghc.AdministrativeLevelID
outer apply	(
	select
				count(s.idfsSite) as intCount
	from		tstSite s
	join		tlbOffice o
	on			o.idfOffice = s.idfOffice
	left join	tlbGeoLocationShared gls
	on			gls.idfGeoLocationShared = o.idfLocation
	left join	gisLocation l
	on			l.idfsLocation = gls.idfsLocation
	where		s.intRowStatus = 0
				and s.idfCustomizationPackage = @CurrentCustomization
				and s.blnIsWEB = 0
				and (	l_ghc.idfsLocation is null
						or	(	l_ghc.idfsLocation is not null
								and l.[node].IsDescendantOf(l_ghc.[node]) = 1 
							)
					)
				and (	(@CurrentCustomization = 51577430000000 /*Georgia*/ and isnull(s.intFlags, o.intHACode) & 2 /*Human*/ > 0)
						or (@CurrentCustomization <> 51577430000000 /*Georgia*/ and isnull(o.intHACode, 0) & 2 /*Human*/ > 0)
					)
			) itemsCount
left join	(
	select
				s.idfsSite, o.idfOffice, l.idfsLocation, l.[node], s.idfsParentSite, 
				row_number () over (partition by gls.idfsRegion, gls.idfsRayon, s.idfsParentSite order by newid()) as rn
	from		tstSite s
	join		tlbOffice o
	on			o.idfOffice = s.idfOffice
	left join	tlbGeoLocationShared gls
	on			gls.idfGeoLocationShared = o.idfLocation
	left join	gisLocation l
	on			l.idfsLocation = gls.idfsLocation
	where		s.intRowStatus = 0
				and s.idfCustomizationPackage = @CurrentCustomization
				and s.blnIsWEB = 0
				and (	(@CurrentCustomization = 51577430000000 /*Georgia*/ and isnull(s.intFlags, o.intHACode) & 2 /*Human*/ > 0)
						or (@CurrentCustomization <> 51577430000000 /*Georgia*/ and isnull(o.intHACode, 0) & 2 /*Human*/ > 0)
					)
			) item
on			(	l_ghc.idfsLocation is null
				or	(	l_ghc.idfsLocation is not null
						and item.[node].IsDescendantOf(l_ghc.[node]) = 1 
					)
			)
			and item.rn = cast((ghc.randValue5*itemsCount.intCount+1) as int)		
where		ghc.randValue3 > 0.5


update		ghc
set			ghc.DiseaseID = item.idfsDiagnosis
from		##GenerateCriteria ghc
outer apply	(
	select
				count(d.idfID) as intCount
	from		@Diagnosis d
			) itemsCount
left join	(
	select
				d.idfsDiagnosis, row_number () over (order by newid()) as rn
	from		@Diagnosis d
			) item
on			item.rn = cast((ghc.randValue6*itemsCount.intCount+1) as int)		
where		ghc.randValue1 > 0.6

update		ghc
set			ghc.ClassificationTypeID = item.idfsCaseClassification
from		##GenerateCriteria ghc
outer apply	(
	select
				count(cc.idfsCaseClassification) as intCount
	from		@CaseClassification cc
	where		cc.blnInitialHumanCaseClassification = 1
			) itemsCount
left join	(
	select
				cc.idfsCaseClassification, row_number () over (order by newid()) as rn
	from		@CaseClassification cc
	where		cc.blnInitialHumanCaseClassification = 1
			) item
on			item.rn = cast((ghc.randValue2*itemsCount.intCount+1) as int)
where		ghc.randValue3 < 0.3

update		ghc
set			ghc.ClassificationTypeID = 
				case
					when ghc.ClassificationTypeID in (350000000 /*Confirmed*/, 370000000 /*Not a Case*/)
						then ghc.ClassificationTypeID
					else item.idfsCaseClassification
				end
from		##GenerateCriteria ghc
outer apply	(
	select
				count(cc.idfsCaseClassification) as intCount
	from		@CaseClassification cc
	where		cc.blnFinalHumanCaseClassification = 1
			) itemsCount
left join	(
	select
				cc.idfsCaseClassification, row_number () over (order by newid()) as rn
	from		@CaseClassification cc
	where		cc.blnFinalHumanCaseClassification = 1
			) item
on			item.rn = cast((ghc.randValue3*itemsCount.intCount+1) as int)
where		ghc.randValue3 < 0.3

-- Fill random dates
update		ghc
set			ghc.DateOfSymptomsOnsetFrom = item.datRandomDateTime
from		##GenerateCriteria ghc
outer apply	(
	select
				count(rd.idfID) as intCount
	from		##RandomDate rd
			) itemsCount
left join	(
	select
				rd.datRandomDate, rd.datRandomDateTime, row_number () over (order by newid()) as rn
	from		##RandomDate rd
			) item
on			item.rn = cast((ghc.randValue2*itemsCount.intCount+1) as int)		


update		ghc
set			ghc.DateEnteredFrom = case when dateadd(day, cast(ghc.randValue3*14 as int), ghc.DateOfSymptomsOnsetFrom) > @EndOfDateInterval /*@Today*/ then @EndOfDateInterval /*@Today*/ else dateadd(day, cast(ghc.randValue3*14 as int), ghc.DateOfSymptomsOnsetFrom) end,
			ghc.DateOfSymptomsOnsetFrom = convert(nvarchar, ghc.DateOfSymptomsOnsetFrom, 112)
from		##GenerateCriteria ghc


update		ghc
set			ghc.DateEnteredTo = case when dateadd(day, cast(ghc.randValue4*180 as int), ghc.DateEnteredFrom) > @EndOfDateInterval /*@Today*/ then @EndOfDateInterval /*@Today*/ else dateadd(day, cast(ghc.randValue4*90 as int), ghc.DateEnteredFrom) end,
			ghc.DateOfSymptomsOnsetTo = case when dateadd(day, cast(ghc.randValue1*180 as int), ghc.DateOfSymptomsOnsetFrom) > @EndOfDateInterval /*@Today*/ then @EndOfDateInterval /*@Today*/ else dateadd(day, cast(ghc.randValue1*90 as int), ghc.DateOfSymptomsOnsetFrom) end
from		##GenerateCriteria ghc


update		ghc
set			ghc.DateOfSymptomsOnsetFrom = null,
			ghc.DateOfSymptomsOnsetTo = null
from		##GenerateCriteria ghc
where		ghc.randValue2 < 0.7


-- Fill random values - end

-- Execute search loop - start
declare @cmd nvarchar(max)
declare @spName nvarchar(200) = N'USP_HUM_DISEASE_REPORT_GETList'
declare	@idfID bigint
declare	@SearchStart datetime
declare	@SearchExecutionStart datetime
declare	@SearchExecutionEnd datetime
declare @ReturnRows int
declare @ResultPages int

DECLARE search_exec_cursor CURSOR FOR 
SELECT		ghc.idfID, ghc.AdministrativeLevelID, ghc.ClassificationTypeID, ghc.DataEntrySiteID, ghc.DateEnteredFrom, ghc.DateEnteredTo, ghc.DateOfSymptomsOnsetFrom, ghc.DateOfSymptomsOnsetTo, ghc.DiseaseID, ghc.LanguageID, ghc.PatientLastName, ghc.SentByFacilityID
from		##GenerateCriteria ghc
order by	ghc.idfID

OPEN search_exec_cursor  
FETCH NEXT FROM search_exec_cursor INTO @idfID, @AdministrativeLevelID, @ClassificationTypeID, @DataEntrySiteID, @DateEnteredFrom, @DateEnteredTo, @DateOfSymptomsOnsetFrom, @DateOfSymptomsOnsetTo, @DiseaseID, @LanguageID, @PatientLastName, @SentByFacilityID

WHILE @@FETCH_STATUS = 0  
BEGIN  

	-- Clear cache of all execution plans
	----set @cmd = N'CHECKPOINT;'
	----exec sp_executesql @cmd

	----set @cmd = N'DBCC DROPCLEANBUFFERS;'
	----exec sp_executesql @cmd

	set @cmd = N'DBCC FREEPROCCACHE;'
	exec sp_executesql @cmd


	-- Perform search
	set @cmd = N'
	if object_id(N''tempdb..#tmpSearchResults'') is null
	create table #tmpSearchResults
    (	ReportKey bigint not null primary key,
		ReportID nvarchar(200) collate Cyrillic_General_CI_AS null,
		LegacyReportID nvarchar(200) collate Cyrillic_General_CI_AS null,
		ReportStatusTypeName nvarchar(2000) collate Cyrillic_General_CI_AS null,
		ReportTypeName nvarchar(2000) collate Cyrillic_General_CI_AS null,
		TentativeDiagnosisDate datetime null,
		FinalDiagnosisDate datetime null,
		ClassificationTypeName nvarchar(2000) collate Cyrillic_General_CI_AS null,
		FinalClassificationTypeName nvarchar(2000) collate Cyrillic_General_CI_AS null,
		DateOfOnset datetime null,
		DiseaseID bigint null,
		DiseaseName nvarchar(2000) collate Cyrillic_General_CI_AS null,
		PersonMasterID bigint null,
		PersonKey bigint not null,
		PersonID varchar(200) null,
		PersonalID nvarchar(200) collate Cyrillic_General_CI_AS null,
		PersonName nvarchar(2000) collate Cyrillic_General_CI_AS null,
		PersonLocation nvarchar(2000) collate Cyrillic_General_CI_AS null,
		EmployerName nvarchar(2000) collate Cyrillic_General_CI_AS null,
		EnteredDate datetime null,
		EnteredByPersonName nvarchar(2000) collate Cyrillic_General_CI_AS null,
		EnteredByOrganizationName nvarchar(2000) collate Cyrillic_General_CI_AS null, 
		ModificationDate datetime null,
		HospitalizationStatus nvarchar(2000) collate Cyrillic_General_CI_AS null,
		SiteID bigint not null,
		ReadPermissionindicator BIT NULL,
		AccessToPersonalDataPermissionIndicator BIT NULL,
		AccessToGenderAndAgeDataPermissionIndicator BIT NULL,
		WritePermissionIndicator BIT NULL,
		DeletePermissionIndicator BIT NULL,
		RecordCount int not null,
		TotalCount int not null,
		TotalPages int not null,
		CurrentPage int not null,
		Region nvarchar(2000) collate Cyrillic_General_CI_AS null,
		Rayon nvarchar(2000) collate Cyrillic_General_CI_AS null
	)
	truncate table #tmpSearchResults

	set @SearchExecutionStart = getdate()
	INSERT INTO #tmpSearchResults
	exec ' + @spName + N'
		@LanguageID,
		@ReportKey,
		@ReportID,
		@LegacyReportID,
		@SessionKey,
		@PatientID,
		@PersonID,
		@DiseaseID,
		@ReportStatusTypeID,
		@AdministrativeLevelID,
		@DateEnteredFrom,
		@DateEnteredTo,
		@ClassificationTypeID,
		@HospitalizationYNID,
		@PatientFirstName,
		@PatientMiddleName,
		@PatientLastName,
		@SentByFacilityID,
		@ReceivedByFacilityID,
		@DiagnosisDateFrom,
		@DiagnosisDateTo,
		@LocalOrFieldSampleID,
		@DataEntrySiteID,
		@DateOfSymptomsOnsetFrom,
		@DateOfSymptomsOnsetTo,
		@NotificationDateFrom,
		@NotificationDateTo,
		@DateOfFinalCaseClassificationFrom,
		@DateOfFinalCaseClassificationTo,
		@LocationOfExposureAdministrativeLevelID,
		@OutcomeID,
		@FilterOutbreakTiedReports,
		@OutbreakCasesIndicator,
		@RecordIdentifierSearchIndicator,
		@UserSiteID,
		@UserOrganizationID,
		@UserEmployeeID,
		@ApplySiteFiltrationIndicator,
		@SortColumn,
		@SortOrder,
		@Page,
		@PageSize

		set @ReturnRows = @@RowCount
		set @SearchExecutionEnd = getdate()

		set @ResultPages =
			(	select top 1 TotalPages
				from #tmpSearchResults
			)
	'
	set @SearchStart = getdate()
	exec sp_executesql @cmd,
	N'@LanguageID NVARCHAR(50),
    @ReportKey BIGINT,
    @ReportID NVARCHAR(200),
    @LegacyReportID NVARCHAR(200),
    @SessionKey BIGINT,
    @PatientID BIGINT,
    @PersonID NVARCHAR(200),
    @DiseaseID BIGINT,
    @ReportStatusTypeID BIGINT,
    @AdministrativeLevelID BIGINT,
    @DateEnteredFrom DATETIME,
    @DateEnteredTo DATETIME,
    @ClassificationTypeID BIGINT,
    @HospitalizationYNID BIGINT,
    @PatientFirstName NVARCHAR(200),
    @PatientMiddleName NVARCHAR(200),
    @PatientLastName NVARCHAR(200),
    @SentByFacilityID BIGINT,
    @ReceivedByFacilityID BIGINT,
    @DiagnosisDateFrom DATETIME,
    @DiagnosisDateTo DATETIME,
    @LocalOrFieldSampleID NVARCHAR(200),
    @DataEntrySiteID BIGINT,
    @DateOfSymptomsOnsetFrom DATETIME,
    @DateOfSymptomsOnsetTo DATETIME,
    @NotificationDateFrom DATETIME,
    @NotificationDateTo DATETIME,
    @DateOfFinalCaseClassificationFrom DATETIME,
    @DateOfFinalCaseClassificationTo DATETIME,
    @LocationOfExposureAdministrativeLevelID BIGINT,
    @OutcomeID BIGINT,
    @FilterOutbreakTiedReports INT,
    @OutbreakCasesIndicator BIT,
    @RecordIdentifierSearchIndicator BIT,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT,
    @ApplySiteFiltrationIndicator BIT,
    @SortColumn NVARCHAR(30),
    @SortOrder NVARCHAR(4),
    @Page INT,
    @PageSize INT,
	@ReturnRows INT OUTPUT,
	@ResultPages INT OUTPUT,
	@SearchExecutionStart datetime OUTPUT,
	@SearchExecutionEnd datetime OUTPUT',
		@LanguageID = @LanguageID,
		@ReportKey = NULL,
		@ReportID = NULL,
		@LegacyReportID = NULL,
		@SessionKey = NULL,
		@PatientID = NULL,
		@PersonID = NULL,
		@DiseaseID = @DiseaseID,
		@ReportStatusTypeID = NULL,
		@AdministrativeLevelID = @AdministrativeLevelID,
		@DateEnteredFrom = @DateEnteredFrom,
		@DateEnteredTo = @DateEnteredTo,
		@ClassificationTypeID = @ClassificationTypeID,
		@HospitalizationYNID = NULL,
		@PatientFirstName = NULL,
		@PatientMiddleName = NULL,
		@PatientLastName = @PatientLastName,
		@SentByFacilityID = @SentByFacilityID,
		@ReceivedByFacilityID = NULL,
		@DiagnosisDateFrom = NULL,
		@DiagnosisDateTo = NULL,
		@LocalOrFieldSampleID = NULL,
		@DataEntrySiteID = @DataEntrySiteID,
		@DateOfSymptomsOnsetFrom = @DateOfSymptomsOnsetFrom,
		@DateOfSymptomsOnsetTo = @DateOfSymptomsOnsetTo,
		@NotificationDateFrom = NULL,
		@NotificationDateTo = NULL,
		@DateOfFinalCaseClassificationFrom = NULL,
		@DateOfFinalCaseClassificationTo = NULL,
		@LocationOfExposureAdministrativeLevelID = NULL,
		@OutcomeID = NULL,
		@FilterOutbreakTiedReports = 0,
		@OutbreakCasesIndicator = 0,
		@RecordIdentifierSearchIndicator = 0,
		@UserSiteID = @idfsDefaultSite,
		@UserOrganizationID = @idfDefaultSiteOrganization,
		@UserEmployeeID = @idfsDefaultSiteEmployee,
		@ApplySiteFiltrationIndicator = 0,
		@SortColumn = 'ReportID',
		@SortOrder = 'DESC',
		@Page = 1,
		@PageSize = 100,
		@ReturnRows = @ReturnRows output,
		@ResultPages = @ResultPages output,
		@SearchExecutionStart = @SearchExecutionStart output,
		@SearchExecutionEnd = @SearchExecutionEnd output

		-- Collect statistics of stored procedure execution
		update		ghc
		set			ghc.datExecutionTime = search_stat.last_execution_time,
					ghc.intElapsedTimeMicrosecond = search_stat.last_elapsed_time,
					ghc.fltElapsedTimeMilisecond = search_stat.last_elapsed_time / (1.0*1000),
					ghc.intWorkerTimeMicrosecond = search_stat.last_worker_time,
					ghc.fltWorkerTimeMilisecond = search_stat.last_worker_time / (1.0*1000),
					ghc.intTotalExecutionTimeMiliSecond = datediff(MILLISECOND, @SearchExecutionStart, @SearchExecutionEnd),
					ghc.intResultRows = @ReturnRows,
					ghc.intResultPages = ISNULL(@ResultPages, 0),
					ghc.intProcessedRows = search_stat.last_rows,
					ghc.intLogicalReads = search_stat.last_logical_reads,
					ghc.intLogicalWrites = search_stat.last_logical_writes,
					ghc.strSearchQuery = N'
	exec ' + @spName + N'
		@LanguageID = N''' + @LanguageID + ''',
		@ReportKey = NULL,
		@ReportID = NULL,
		@LegacyReportID = NULL,
		@SessionKey = NULL,
		@PatientID = NULL,
		@PersonID = NULL,
		@DiseaseID = ' + isnull(cast(@DiseaseID as nvarchar(20)), N'NULL') + N',
		@ReportStatusTypeID = NULL,
		@AdministrativeLevelID = ' + isnull(cast(@AdministrativeLevelID as nvarchar(20)), N'NULL') + N',
		@DateEnteredFrom = ' + isnull(N'N''' + convert(nvarchar, @DateEnteredFrom, 120) + N'''', N'NULL') + N',
		@DateEnteredTo = ' + isnull(N'N''' + convert(nvarchar, @DateEnteredTo, 120) + N'''', N'NULL') + N',
		@ClassificationTypeID =  ' + isnull(cast(@ClassificationTypeID as nvarchar(20)), N'NULL') + N',
		@HospitalizationYNID = NULL,
		@PatientFirstName = NULL,
		@PatientMiddleName = NULL,
		@PatientLastName = ' + isnull(N'N''' + replace(@PatientLastName, N'''', N'''''') + N'''', N'NULL') + N',
		@SentByFacilityID = ' + isnull(cast(@SentByFacilityID as nvarchar(20)), N'NULL') + N',
		@ReceivedByFacilityID = NULL,
		@DiagnosisDateFrom = NULL,
		@DiagnosisDateTo = NULL,
		@LocalOrFieldSampleID = NULL,
		@DataEntrySiteID = ' + isnull(cast(@DataEntrySiteID as nvarchar(20)), N'NULL') + N',
		@DateOfSymptomsOnsetFrom = ' + isnull(N'N''' + convert(nvarchar, @DateOfSymptomsOnsetFrom, 120) + N'''', N'NULL') + N',
		@DateOfSymptomsOnsetTo = ' + isnull(N'N''' + convert(nvarchar, @DateOfSymptomsOnsetTo, 120) + N'''', N'NULL') + N',
		@NotificationDateFrom = NULL,
		@NotificationDateTo = NULL,
		@DateOfFinalCaseClassificationFrom = NULL,
		@DateOfFinalCaseClassificationTo = NULL,
		@LocationOfExposureAdministrativeLevelID = NULL,
		@OutcomeID = NULL,
		@FilterOutbreakTiedReports = 0,
		@OutbreakCasesIndicator = 0,
		@RecordIdentifierSearchIndicator = 0,
		@UserSiteID = ' + isnull(cast(@idfsDefaultSite as nvarchar(20)), N'NULL') + N',
		@UserOrganizationID = ' + isnull(cast(@idfDefaultSiteOrganization as nvarchar(20)), N'NULL') + N',
		@UserEmployeeID = ' + isnull(cast(@idfsDefaultSiteEmployee as nvarchar(20)), N'NULL') + N',
		@ApplySiteFiltrationIndicator = 0,
		@SortColumn = ''ReportID'',
		@SortOrder = ''DESC'',
		@Page = 1,
		@PageSize = 100'
		FROM		##GenerateCriteria ghc
		cross apply
		(	SELECT		max(qs.last_execution_time) as last_execution_time,
						sum(qs.total_elapsed_time) as last_elapsed_time,
						sum(qs.total_worker_time) as last_worker_time,
						sum(qs.total_rows) as last_rows,
						sum(qs.total_logical_reads) as last_logical_reads,
						sum(qs.total_logical_writes) as last_logical_writes
			FROM		sys.dm_exec_query_stats AS qs
			CROSS APPLY	sys.dm_exec_sql_text(qs.[sql_handle]) AS qt
			WHERE		qt.[dbid] = DB_ID()
						and qs.creation_time > @SearchStart
		) search_stat
		where		ghc.idfID = @idfID
		FETCH NEXT FROM search_exec_cursor INTO @idfID, @AdministrativeLevelID, @ClassificationTypeID, @DataEntrySiteID, @DateEnteredFrom, @DateEnteredTo, @DateOfSymptomsOnsetFrom, @DateOfSymptomsOnsetTo, @DiseaseID, @LanguageID, @PatientLastName, @SentByFacilityID 
END 

CLOSE search_exec_cursor  
DEALLOCATE search_exec_cursor



-- Execute search loop - end

-- Perform search and retrieve search statistics - start
declare @idfsLngEn bigint = dbo.FN_GBL_LanguageCode_GET('en-US')


select		ROW_NUMBER() OVER (ORDER BY ghc.idfID) as N'Search #',
			convert(nvarchar, ghc.datExecutionTime, 101) + N' ' + convert(nvarchar, ghc.datExecutionTime, 114) as N'Search Run Completion Time',
			ghc.intTotalExecutionTimeMiliSecond as N'Search Execution Time (Miliseconds)',
			ghc.intElapsedTimeMicrosecond as N'Search Elapsed Time (Microseconds)',
			ghc.fltElapsedTimeMilisecond as N'Search Elapsed Time (Miliseconds)',
			ghc.intWorkerTimeMicrosecond as N'Search Work Time (Microseconds)',
			ghc.fltWorkerTimeMilisecond as N'Search Work Time (Miliseconds)',
			ghc.intResultRows as N'Result Rows',
			case when ghc.intResultPages = 0 then N'N/A' else N'Page ' + CAST(@Page as nvarchar(20)) + N' of ' + CAST(ghc.intResultPages as nvarchar(20)) + N' (Size: ' + CAST(@PageSize as nvarchar(20)) + N' records)' end as N'Result Page',
			case when ghc.intResultPages = 0 then 0 else @Page end as 'Current Page of Search Results',
			ghc.intResultPages as N'Total Pages of Search Results',
			ghc.intLogicalReads as N'Logical Reads',
			ghc.intLogicalWrites as N'Logical Writes',
			ISNULL(ld.Level1Name + ISNULL(N' > ' + ld.Level2Name + ISNULL(N' > ' + ld.Level3Name, N''), N''), N'') as N'Location',--ghc.AdministrativeLevelID,
			ISNULL(cc.[name], N'') as N'Case Classification',--ghc.ClassificationTypeID,
			ISNULL(org_data_entry.AbbreviatedName, N'') as N'Data Entry Site',--ghc.DataEntrySiteID,
			ISNULL(convert(nvarchar, ghc.DateEnteredFrom, 101), N'') as 'Date Entered: From',
			ISNULL(convert(nvarchar, ghc.DateEnteredTo, 101), N'') as 'Date Entered: To',
			ISNULL(convert(nvarchar, ghc.DateOfSymptomsOnsetFrom, 101), N'') as 'Date Symptoms Onset: From',
			ISNULL(convert(nvarchar, ghc.DateOfSymptomsOnsetTo, 101), N'') as 'Date Symptoms Onset: To',
			ISNULL(d.[name], N'') as N'Disease',--ghc.DiseaseID,
			ghc.LanguageID as N'System Language',
			ISNULL(ghc.PatientLastName, N'') as N'Patient Last Name',--ghc.PatientLastName,
			ISNULL(org_sent_by.AbbreviatedName, N'') as N'Sent by Facility',--ghc.SentByFacilityID
			ISNULL(ghc.strSearchQuery, N'') as N'Search Query with Parameters'
from		##GenerateCriteria ghc

left join	gisLocationDenormalized ld
on			ld.idfsLocation = ghc.AdministrativeLevelID
			and ld.idfsLanguage = @idfsLngEn

left join	dbo.FN_GBL_Repair('en-US', 19000011) cc
on			cc.idfsReference = ghc.ClassificationTypeID

left join	dbo.FN_GBL_Repair('en-US', 19000019) d
on			d.idfsReference = ghc.DiseaseID

left join	dbo.FN_GBL_Institution_Min('en-US') org_data_entry
on			org_data_entry.idfOffice = ghc.DataEntrySiteID

left join	dbo.FN_GBL_Institution_Min('en-US') org_sent_by
on			org_sent_by.idfOffice = ghc.SentByFacilityID

order by	ghc.idfID


-- Perform search and retrieve search statistics - end


-- Drop temporary tables - start


if object_id('tempdb..##RandomDate') is not null
begin
	execute sp_executesql N'drop table ##RandomDate'
end

if object_id('tempdb..##GenerateCriteria') is not null
begin
	execute sp_executesql N'drop table ##GenerateCriteria'
end

-- Drop temporary tables - end
