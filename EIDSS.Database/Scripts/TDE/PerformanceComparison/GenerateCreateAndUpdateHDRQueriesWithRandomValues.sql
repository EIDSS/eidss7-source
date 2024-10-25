

-- Variables
declare	@StartOfDateInterval datetime = '20240101'
declare	@EndOfDateInterval datetime = '20240325'
declare	@CaseCnt int = 10
declare	@MaxSampleCountPerCase bigint = 2
declare	@MaxTestCountPerSample bigint = 1
declare	@Iterations int = 1

if (@EndOfDateInterval is null)
	set	@EndOfDateInterval = convert(nvarchar, getdate(), 112)

if (datediff(day, @StartOfDateInterval, @EndOfDateInterval) <= 0)
	set @EndOfDateInterval = convert(nvarchar, getdate(), 112)

-- Implementation
set nocount on
set XACT_ABORT on
SET DATEFORMAT dmy
SET DATEFIRST 1

declare	  @DateIntervalInDays int = datediff(day, @StartOfDateInterval, @EndOfDateInterval)

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


-- Define and fill in customazable values: 
-- list of regions (provinces), 
-- diagnoses, 
-- case classifications,
-- sample types for diagnoses,
-- test names for sample types and diagnoses,
-- last, first and second names associated with human genders, 
-- street names,
-- specific FF parameters with Y/N/Unk values
-- specifc FF parameters with specific values
declare	@DefaultSite nvarchar(200)
declare	@idfsDefaultSite bigint
declare	@idfDefaultSiteOrganization bigint
declare	@idfsDefaultSiteEmployee bigint
declare	@DefaultSiteUser nvarchar(200)


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


declare	@SampleTypeForDiagnosis table
(
	idfID int not null identity(1,1) primary key
	, Diagnosis nvarchar(2000) collate Cyrillic_General_CI_AS not null
	, SampleType nvarchar(2000) collate Cyrillic_General_CI_AS not null
	, idfsDiagnosis bigint null
	, idfsSampleType bigint null
)

declare	@TestNameToSampleTypeAndDiagnosis table
(
	idfID int not null identity(1,1) primary key
	, Diagnosis nvarchar(2000) collate Cyrillic_General_CI_AS not null
	, SampleType nvarchar(2000) collate Cyrillic_General_CI_AS not null
	, TestName nvarchar(2000) collate Cyrillic_General_CI_AS not null
	, TestCategory nvarchar(2000) collate Cyrillic_General_CI_AS not null
	, idfsDiagnosis bigint null
	, idfsSampleType bigint null
	, idfsTestName bigint null
	, idfsTestCategory bigint null
)


declare	@Region table
(
	idfID int not null identity(1,1) primary key
	, RegionName nvarchar(200) collate Cyrillic_General_CI_AS not null
	, RegionId bigint null
)

declare	@Employee table
(
	idfID int not null identity(1,2) primary key
	, PersonId bigint null
	, UserId bigint null
	, EmployeeFirstName nvarchar(200) collate Cyrillic_General_CI_AS not null
	, EmployeeLastName nvarchar(200) collate Cyrillic_General_CI_AS not null
	, EmployeeAccountName nvarchar(200) collate Cyrillic_General_CI_AS not null
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

-- Add specific EPI FF parameters with drop-downs if necessary
declare	@MandatoryEpiFFWithDropDowns	table
(	idfsParameter			bigint not null primary key,
	idfsParameterType		bigint null
)


-- Add specifc CS and EPI FF with Yes/No values if necessary
declare	@FFWithYNUnk	table
(	idfsParameter			bigint not null primary key,
	blnAllowEmpty			bit not null default(0),
	blnHCS					bit not null default(0),
	blnHEI					bit not null default(0)
)

-- Add specific and EPI FF with specific values if necessary
declare	@FFWithSpecificValue	table
(	idfsParameter			bigint not null primary key,
	blnAllowEmpty			bit not null default(0),
	blnHCS					bit not null default(0),
	blnHEI					bit not null default(0)
)

declare	@YNUnkEmpty	table
(	idfID int not null identity(1,1) primary key,
	idfsYNUnk bigint null,
	blnEmpty bit not null default(0)
)

insert into	@YNUnkEmpty (idfsYNUnk, blnEmpty) values
	 (25460000000/*Yes*/, 0)
	, (25640000000/*No*/, 0)
	, (25660000000/*Unknown*/, 0)
	, (cast(null as bigint), 1)

declare	@FFSpecificValue	table
(	idfID int not null identity(1,1) primary key,
	idfsParameter bigint not null,
	varValue sql_variant null,
	blnEmpty bit not null default(0)
)


declare	@Street	table
(	idfID int not null identity(1,1) primary key
	, StreetName nvarchar(200) collate Cyrillic_General_CI_AS null
)
declare	@StreetName nvarchar(200)


declare	@NumericOrEmptyString	table
(	idfID int not null identity(1,1) primary key
	, intNum int null
	, strNum nvarchar(200) collate Cyrillic_General_CI_AS null
)


declare	@HospitalizationPlace	table
(	idfID int not null identity(1,1) primary key
	, strHospitalizationPlace nvarchar(200) collate Cyrillic_General_CI_AS null
)


declare	@EmployeeGroupName nvarchar(200)
declare	@idfEmployeeGroup bigint

-- Fill in names based on Customization package: start

insert into	@NumericOrEmptyString (intNum, strNum)
select a*10 + b + 1, cast((a*10 + b + 1) as nvarchar(20))
from
(	select	0 as a union all
	select	1 union all
	select	2 union all
	select	3 union all
	select	4 union all
	select	5 union all
	select	6 union all
	select	7 union all
	select	8 union all
	select	9 union all
	select	null
) a
cross join
(	select	0 as b union all
	select	1 union all
	select	2 union all
	select	3 union all
	select	4 union all
	select	5 union all
	select	6 union all
	select	7 union all
	select	8 union all
	select	9 union all
	select	null union all
	select	null union all
	select	null
) b
order by newid()


if @CurrentCustomization = 51577400000000/*Armenia*/
begin
	set @StreetName = isnull(@StreetName, N'Հալաբյան փողոց')
	insert into	@Street (StreetName) values (@StreetName)

	insert into @Employee 
		(EmployeeFirstName, EmployeeLastName, EmployeeAccountName)
	values
		(N'Արտակ', N'Արարատյան', N'AraratyanA')
		, (N'Սևակ', N'Սրապյան', N'SrapyanS')
		, (N'Մանուշ', N'Մակարյան', N'MakaryanM')
		, (N'Սարգսյան', N'Սարանդ', N'SargsyanS')
		, (N'Նարգիզ', N'Ներսիսյան', N'NersisyanN')

		, (N'Արա', N'Սարգսյան', N'SentByEmployee')

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

	set @StreetName = isnull(@StreetName, N'Rəşid Behbudov')
	insert into	@Street (StreetName) values (@StreetName)

	insert into @Employee 
		(EmployeeFirstName, EmployeeLastName, EmployeeAccountName)
	values
		(N'Kərim', N'Hüseynov', N'khuseynov')
		, (N'Lalə', N'Orucova', N'lorucova')
		, (N'Səbinə', N'Babayeva', N'sbabayeva')
		, (N'Tural', N'Rzayev', N'trzayev')
		, (N'Rauf', N'Muxtarov', N'rmuxtarov')

		, (N'Kərim', N'Muxtarov', N'SentByEmployee')

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

	set @StreetName = isnull(@StreetName, N'Green')
	insert into	@Street (StreetName) values (@StreetName)

	set	@EmployeeGroupName = N'Epidemiologist'
	
	insert into @Employee 
		(EmployeeFirstName, EmployeeLastName, EmployeeAccountName)
	values
		(N'Kate', N'Miller', N'Miller.Kate')
		, (N'John', N'Smith', N'Smith.John')
		, (N'David', N'Fox', N'Fox.David')
		, (N'Ann', N'Johnson', N'Johnson.Ann')
		, (N'Helen', N'Brown', N'Brown.Helen')
		
		, (N'Kate', N'Smith', N'SentByEmployee')

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

		--Thai mandatory EPI parameters
		insert into	@MandatoryEpiFFWithDropDowns (idfsParameter, idfsParameterType)
		select		p.idfsParameter, p.idfsParameterType
		from		ffParameter p
		join		dbo.fnReference('en', 19000066) r_p
		on			r_p.idfsReference = p.idfsParameter
		join		ffParameterType pt
		on			pt.idfsParameterType = p.idfsParameterType
					and pt.idfsReferenceType = 19000069 /*Parameter Fixed Preset Value*/
					and pt.intRowStatus = 0
		where		p.idfsFormType = 10034011 /*EPI Investigations*/
					and p.intRowStatus = 0
					and p.idfsParameter in
						(	57496180000000,	/*Hospitalization*/
							57496370000000,	/*Marital status*/
							57497080000000,	/*Municipality*/
							57497270000000,	/*Patient's type*/
							57497500000000	/*Type of foreigner*/
						)


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


	insert into	@SampleTypeForDiagnosis (Diagnosis, SampleType)
	values
		  (N'COVID-19', N'Oropharyngeal smear')
		, (N'COVID-19', N'Nasopharyngeal smear')


	insert into	@TestNameToSampleTypeAndDiagnosis (Diagnosis, SampleType, TestName, TestCategory)
	values
		  (N'COVID-19', N'Oropharyngeal smear', N'Expres PCR for SARS-CoV-2  (gene expert)', N'Confirmatory')
		, (N'COVID-19', N'Nasopharyngeal smear', N'Expres PCR for SARS-CoV-2  (gene expert)', N'Confirmatory')

	insert into @Street (StreetName)
	values
		  (N'Абрикосова вул.')
		, (N'Вавілова вул.')
		, (N'Ватутіна вул.')
		, (N'Вербівська вул.')
		, (N'')
		, (N'')
		, (N'Виноградна вул.')
		, (N'Вишнева вул.')
		, (N'Вишневецького вул.')
		, (N'Вінницька вул.')
		, (N'Гагаріна Ю. вул.')
		, (N'Глібова вул.')
		, (N'Глушкова вул.')
		, (N'')
		, (N'')
		, (N'')
		, (N'Гоголя вул.')
		, (N'Декабристів вул.')
		, (N'Довженка вул.')
		, (N'Дружби вул.')
		, (N'Електриків вул.')
		, (N'Ентузіастів вул.')
		, (N'')
		, (N'Залізнична вул.')
		, (N'Затишна вул.')
		, (N'Західна вул.')
		, (N'Зелена вул.')
		, (N'Індустріальна вул.')
		, (N'')
		, (N'Калинова вул.')
		, (N'Комарова вул.')
		, (N'Космодемянська З. вул.')
		, (N'Курортна вул.')
		, (N'Кутузова М. вул.')
		, (N'Левадна вул.')
		, (N'Лелітська вул.')
		, (N'Лермонтова М. вул.')
		, (N'Липова вул.')
		, (N'Літописна вул.')
		, (N'')
		, (N'')
		, (N'Лугова вул.')
		, (N'Магістральний провул.')
		, (N'Меморіальна вул.')
		, (N'Маяковського вул.')
		, (N'Миру вулиця')
		, (N'Молодіжна вул.')
		, (N'Монастирська вул.')
		, (N'Набережна вул.')
		, (N'')
		, (N'Нагірна вул.')
		, (N'Нахімова вул.')
		, (N'Незалежності вул.')
		, (N'Некрасова вул.')
		, (N'Новоселів вул.')
		, (N'Озерна вул.')
		, (N'Освіти вул.')
		, (N'Паркова вул.')
		, (N'Перемоги вул.')
		, (N'')
		, (N'')
		, (N'')
		, (N'Пирогова вул.')
		, (N'Північна вул.')
		, (N'Полтавська вул.')
		, (N'Привокзальна вул.')
		, (N'Пушкіна вул.')
		, (N'Робітнича вул.')
		, (N'')
		, (N'Садова вул.')
		, (N'Свободи просп.')
		, (N'Сидориська вул.')
		, (N'')
		, (N'Сковороди вул.')
		, (N'Соколівська вул.')
		, (N'')
		, (N'')
		, (N'Соснова вул.')
		, (N'Станційна вул.')
		, (N'Столярчука вул.')
		, (N'')
		, (N'Суворова О. вул.')
		, (N'Тімірязєва вул.')
		, (N'Трипільська вул.')
		, (N'')
		, (N'Тургенєва С. провул.')
		, (N'Чайковського П. вул.')
		, (N'')
		, (N'Черешнева вул.')
		, (N'Шевченка Т. вул.')

	set	@EmployeeGroupName = N'Epidemiologist'
	

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

		insert into	@HospitalizationPlace (strHospitalizationPlace)
		values
		  (N'Hospital 1')
		, (N'Hospital 2')
		, (N'Hospital 3')
		, (N'Hospital 4')
		, (N'Hospital 5')
		, (N'Hospital 6')
		, (N'Hospital 7')
		, (N'Hospital 8')
		, (N'Hospital 9')
		, (N'Hospital 10')
		, (N'Hospital 11')
		, (N'Hospital 12')
		, (N'Hospital 13')
		, (N'Hospital 14')
		, (N'Hospital 15')
		, (N'Hospital 16')
		, (N'Hospital 17')
		, (N'Hospital 18')
		, (N'Hospital 19')
		, (N'Hospital 20')
		, (N'Hospital 21')
		, (N'Hospital 22')
		, (N'Hospital 23')
		, (N'Hospital 24')
		, (N'Hospital 25')
		, (N'Hospital 26')
		, (N'Hospital 27')
		, (N'Hospital 28')
		, (N'Hospital 29')
		, (N'Hospital 30')

		insert into	@FFWithYNUnk
		(	idfsParameter,
			blnAllowEmpty,
			blnHCS,
			blnHEI
		)
		select		p.idfsParameter, 
					1,
					1,
					0
		from		ffParameter p
		join		dbo.fnReference('en', 19000066) r_p
		on			r_p.idfsReference = p.idfsParameter
		join		ffParameterType pt
		on			pt.idfsParameterType = p.idfsParameterType
					and pt.idfsReferenceType = 19000069 /*Parameter Fixed Preset Value*/
					and pt.intRowStatus = 0
		where		p.idfsFormType = 10034010	/*Human Clinical Signs*/
					and p.intRowStatus = 0
					and p.idfsParameterType = 217140000000	/*Y_N_Unk*/
					and r_p.[name] in
						(	  N'The presence of symptoms'
							, N'The presence of concomitant conditions'
							, N'Pregnancy'
							, N'Postpartum period (up to 42 days)'
							, N'Immunodeficiency'
							, N'Cardiovascular diseases, incl. hypertension'
							, N'Diabetes'
							, N'Liver disease'
							, N'Chronic neurological or neuromuscular diseases'
							, N'Kidney disease'
							, N'Malignant neoplasms'
							, N'Chronic lung diseases'
							, N'Stay in the intensive care unit'
							, N'Artificial ventilation'
							, N'Extracorporeal membrane oxygenation'
							, N'Oxygen therapy'
						)

		insert into	@FFWithYNUnk
		(	idfsParameter,
			blnAllowEmpty,
			blnHCS,
			blnHEI
		)
		select		p.idfsParameter, 
					1,
					0,
					1
		from		ffParameter p
		join		dbo.fnReference('en', 19000066) r_p
		on			r_p.idfsReference = p.idfsParameter
		join		ffParameterType pt
		on			pt.idfsParameterType = p.idfsParameterType
					and pt.idfsReferenceType = 19000069 /*Parameter Fixed Preset Value*/
					and pt.intRowStatus = 0
		where		p.idfsFormType = 10034011	/*Human Epi Investigations*/
					and p.intRowStatus = 0
					and p.idfsParameterType = 217140000000	/*Y_N_Unk*/
					and r_p.[name] in
						(	  N'Is the patient a health care provider?'
							, N'Travel 14 days before symptoms appear'
							, N'Contact with confirmed case 14 days before illness'
							, N'Selfisolation'
							, N'Isolation address matches the address of residence'
						)

		insert into	@FFWithSpecificValue
		(	idfsParameter,
			blnAllowEmpty,
			blnHCS,
			blnHEI
		)
		select		p.idfsParameter, 
					1,
					1,
					0
		from		ffParameter p
		join		dbo.fnReference('en', 19000066) r_p
		on			r_p.idfsReference = p.idfsParameter
		where		p.idfsFormType = 10034010	/*Human Clinical Signs*/
					and p.intRowStatus = 0
					and p.idfsParameterType = 10071045	/*String*/
					and r_p.[name] = N'Other, specify'


		insert into	@FFSpecificValue
		(	idfsParameter,
			varValue,
			blnEmpty
		)
		select		p.idfsParameter, 
					val.strTextValue,
					case when val.strTextValue is null then 1 else 0 end
		from		ffParameter p
		join		dbo.fnReference('en', 19000066) r_p
		on			r_p.idfsReference = p.idfsParameter
		cross join
		(	select	cast(N'Symptom A' as nvarchar(200)) as strTextValue union all
			select	cast(null as nvarchar(200)) as strTextValue union all
			select	cast(N'Symptom B' as nvarchar(200)) as strTextValue union all
			select	cast(null as nvarchar(200)) as strTextValue union all
			select	cast(null as nvarchar(200)) as strTextValue union all
			select	cast(N'Symptom C' as nvarchar(200)) as strTextValue union all
			select	cast(N'Symptom D' as nvarchar(200)) as strTextValue union all
			select	cast(null as nvarchar(200)) as strTextValue union all
			select	cast(N'Symptom E' as nvarchar(200)) as strTextValue union all
			select	cast(null as nvarchar(200)) as strTextValue union all
			select	cast(null as nvarchar(200)) as strTextValue union all
			select	cast(N'Symptom F' as nvarchar(200)) as strTextValue union all
			select	cast(null as nvarchar(200)) as strTextValue union all
			select	cast(N'Symptom G' as nvarchar(200)) as strTextValue union all
			select	cast(null as nvarchar(200)) as strTextValue union all
			select	cast(N'Symptom I' as nvarchar(200)) as strTextValue
		) val
		where		p.idfsFormType = 10034010	/*Human Clinical Signs*/
					and p.intRowStatus = 0
					and p.idfsParameterType = 10071045	/*String*/
					and r_p.[name] = N'Other, specify'

end
else if @CurrentCustomization = 51577430000000/*Georgia*/
begin
	set	@EmployeeGroupName = N'Epidemiologist'


	insert into @Employee 
		(EmployeeFirstName, EmployeeLastName, EmployeeAccountName)
	values
		(N'Kate', N'Miller', N'Miller.Kate')
		, (N'John', N'Smith', N'Smith.John')
		, (N'David', N'Fox', N'Fox.David')
		, (N'Ann', N'Johnson', N'Johnson.Ann')
		, (N'Helen', N'Brown', N'Brown.Helen')
		
		, (N'Kate', N'Smith', N'SentByEmployee')

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

	insert into	@Diagnosis (Diagnosis)
	values	  (N'Anthrax - Cutaneous')
			, (N'Anthrax - Gastrointestinal')
			, (N'Anthrax - Oropharyngeal')
			, (N'Anthrax - Pulmonary')


	insert into	@SampleTypeForDiagnosis (Diagnosis, SampleType)
	values
		  (N'Anthrax - Cutaneous', N'Blood')
		, (N'Anthrax - Gastrointestinal', N'Blood')
		, (N'Anthrax - Oropharyngeal', N'Blood')
		, (N'Anthrax - Pulmonary', N'Blood')
		, (N'Anthrax - Cutaneous', N'Sputum')
		, (N'Anthrax - Gastrointestinal', N'Sputum')
		, (N'Anthrax - Oropharyngeal', N'Sputum')
		, (N'Anthrax - Pulmonary', N'Sputum')
		, (N'Anthrax - Cutaneous', N'Blood')
		, (N'Anthrax - Gastrointestinal', N'Blood')
		, (N'Anthrax - Oropharyngeal', N'Blood')
		, (N'Anthrax - Pulmonary', N'Blood')
		, (N'Anthrax - Cutaneous', N'Sputum')
		, (N'Anthrax - Gastrointestinal', N'Sputum')
		, (N'Anthrax - Oropharyngeal', N'Sputum')
		, (N'Anthrax - Pulmonary', N'Sputum')
		, (N'Anthrax - Cutaneous', N'Blood')
		, (N'Anthrax - Gastrointestinal', N'Blood')
		, (N'Anthrax - Oropharyngeal', N'Blood')
		, (N'Anthrax - Pulmonary', N'Blood')
		, (N'Anthrax - Cutaneous', N'Sputum')
		, (N'Anthrax - Gastrointestinal', N'Sputum')
		, (N'Anthrax - Oropharyngeal', N'Sputum')
		, (N'Anthrax - Pulmonary', N'Sputum')


	insert into	@TestNameToSampleTypeAndDiagnosis (Diagnosis, SampleType, TestName, TestCategory)
	values
		  (N'Anthrax - Cutaneous', N'Blood', N'PCR', N'Confirmatory')
		, (N'Anthrax - Cutaneous', N'Sputum', N'PCR', N'Confirmatory')
		, (N'Anthrax - Gastrointestinal', N'Blood', N'PCR', N'Confirmatory')
		, (N'Anthrax - Gastrointestinal', N'Sputum', N'PCR', N'Confirmatory')
		, (N'Anthrax - Oropharyngeal', N'Blood', N'PCR', N'Confirmatory')
		, (N'Anthrax - Oropharyngeal', N'Sputum', N'PCR', N'Confirmatory')
		, (N'Anthrax - Pulmonary', N'Blood', N'PCR', N'Confirmatory')
		, (N'Anthrax - Pulmonary', N'Sputum', N'PCR', N'Confirmatory')

	insert into @Street (StreetName)
	values
		  (N'Main')
		, (N'Green')
		, (N'Number 1')
		, (N'Number 2')
		, (N'')
		, (N'')
		, (N'Number 3')
		, (N'Number 4')
		, (N'')
		, (N'')
		, (N'')
		, (N'')
		, (N'Garden')
		, (N'Number 5')
	


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



		insert into	@HospitalizationPlace (strHospitalizationPlace)
		values
		  (N'Hospital 1')
		, (N'Hospital 2')
		, (N'Hospital 3')
		, (N'Hospital 4')
		, (N'Hospital 5')
		, (N'Hospital 6')
		, (N'Hospital 7')
		, (N'Hospital 8')
		, (N'Hospital 9')
		, (N'Hospital 10')
		, (N'Hospital 11')
		, (N'Hospital 12')
		, (N'Hospital 13')
		, (N'Hospital 14')
		, (N'Hospital 15')
		, (N'Hospital 16')
		, (N'Hospital 17')
		, (N'Hospital 18')
		, (N'Hospital 19')
		, (N'Hospital 20')
		, (N'Hospital 21')
		, (N'Hospital 22')
		, (N'Hospital 23')
		, (N'Hospital 24')
		, (N'Hospital 25')
		, (N'Hospital 26')
		, (N'Hospital 27')
		, (N'Hospital 28')
		, (N'Hospital 29')
		, (N'Hospital 30')

		insert into	@FFWithYNUnk
		(	idfsParameter,
			blnAllowEmpty,
			blnHCS,
			blnHEI
		)
		select		p.idfsParameter, 
					1,
					1,
					0
		from		ffParameter p
		join		dbo.fnReference('en', 19000066) r_p
		on			r_p.idfsReference = p.idfsParameter
		join		ffParameterType pt
		on			pt.idfsParameterType = p.idfsParameterType
					and pt.idfsReferenceType = 19000069 /*Parameter Fixed Preset Value*/
					and pt.intRowStatus = 0
		where		p.idfsFormType = 10034010	/*Human Clinical Signs*/
					and p.intRowStatus = 0
					and p.idfsParameterType = 217140000000	/*Y_N_Unk*/
					and r_p.[name] in
						(	  N'Cleaning of farms or territories where animals are/were kept'
							, N'Confirmed (for all forms): Positive laboratory test'
							, N'Consumption of raw or undercooked meat'
							, N'Contact with animal products (meat, skin, leather or bones) or their preparation'
							, N'Detection of large gram positive capsule and/or spore-developing bacillus in a microscopic study or smear'
							, N'Earthwork or other work associated with soil in an area where ill animals were kept or where dead animals were buried or the immediate surrounding area'
							, N'Epidemiological link with confirmed human anthrax case'
							, N'Laboratory worker with potential occupational exposure to anthrax'
							, N'Positive anthrax antigen skin test'
							, N'Probable (for all forms): Meets Suspect definition'
							, N'Within two weeks before symptom onset, travel to or living in a location where animal or human anthrax cases were reported'
							, N'Within two weeks of symptom onset, contact with animal products imported from infected area, such as meat, fur, skins, or leather'
						)

		insert into	@FFWithYNUnk
		(	idfsParameter,
			blnAllowEmpty,
			blnHCS,
			blnHEI
		)
		select		p.idfsParameter, 
					1,
					0,
					1
		from		ffParameter p
		join		dbo.fnReference('en', 19000066) r_p
		on			r_p.idfsReference = p.idfsParameter
		join		ffParameterType pt
		on			pt.idfsParameterType = p.idfsParameterType
					and pt.idfsReferenceType = 19000069 /*Parameter Fixed Preset Value*/
					and pt.intRowStatus = 0
		where		p.idfsFormType = 10034011	/*Human Epi Investigations*/
					and p.intRowStatus = 0
					and p.idfsParameterType = 217140000000	/*Y_N_Unk*/
					and r_p.[name] in
						(	  N'Bites of big blood-sucking insects (horseflies)'
							, N'Cleaning of farms or territories where agricultural animals are/were kept? (in epi investigation)'
							, N'Contact with animal products (meat, skin, leather or bones) or their preparation? (in epi investigation)'
							, N'Contact with animal products, imported from infected area such as meat, fur, skins, or leather (in epi investigation)'
							, N'Cooking or consumption of raw or undercooked meat? (Within two weeks of symptoms onset) (in epi investigation)'
							, N'Did the case have contact with the same animal(s) as the other person?'
							, N'Did the case visit specific places where this person lived or worked?'
							, N'Earthwork or other work associated with soil in an area where ill animals were kept or where dead animals were buried or the immediate surrounding area (in epi investigation)'
							, N'In the past two weeks, did the case have any contact with this person(s)'
							, N'Is the case aware of any other persons having a similar disease?'
							, N'Laboratory worker with potential occupational exposure to anthrax (in epi investigation)'
							, N'Other possible exposure(s) to anthrax not covered above?'
							, N'Travel outside of residence (Within two weeks of symptoms onset)'
							, N'Was specific vaccination administered?'
						)

		insert into	@FFWithSpecificValue
		(	idfsParameter,
			blnAllowEmpty,
			blnHCS,
			blnHEI
		)
		select		p.idfsParameter, 
					1,
					1,
					0
		from		ffParameter p
		join		dbo.fnReference('en', 19000066) r_p
		on			r_p.idfsReference = p.idfsParameter
		where		p.idfsFormType = 10034010	/*Human Clinical Signs*/
					and p.intRowStatus = 0
					and p.idfsParameterType = 10071045	/*String*/
					and r_p.[name] = N'Confirmed (for all forms): Comments for clinical signs'

		insert into	@FFWithSpecificValue
		(	idfsParameter,
			blnAllowEmpty,
			blnHCS,
			blnHEI
		)
		select		p.idfsParameter, 
					1,
					0,
					1
		from		ffParameter p
		join		dbo.fnReference('en', 19000066) r_p
		on			r_p.idfsReference = p.idfsParameter
		where		p.idfsFormType = 10034011	/*Human Epi Investigations*/
					and p.intRowStatus = 0
					and p.idfsParameterType = 10071045	/*String*/
					and r_p.[name] in
						(	  N'Additional Clinical or Epidemiological Remarks:'
							, N'Big blood-sucking insects'
							, N'Comment for other possible exposures to anthrax'
						)


		insert into	@FFSpecificValue
		(	idfsParameter,
			varValue,
			blnEmpty
		)
		select		p.idfsParameter, 
					val.strTextValue,
					case when val.strTextValue is null then 1 else 0 end
		from		ffParameter p
		join		dbo.fnReference('en', 19000066) r_p
		on			r_p.idfsReference = p.idfsParameter
		cross join
		(	select	cast(N'Text A' as nvarchar(200)) as strTextValue union all
			select	cast(null as nvarchar(200)) as strTextValue union all
			select	cast(N'Text B' as nvarchar(200)) as strTextValue union all
			select	cast(null as nvarchar(200)) as strTextValue union all
			select	cast(null as nvarchar(200)) as strTextValue union all
			select	cast(N'Text C' as nvarchar(200)) as strTextValue union all
			select	cast(N'Text D' as nvarchar(200)) as strTextValue union all
			select	cast(null as nvarchar(200)) as strTextValue union all
			select	cast(N'Text E' as nvarchar(200)) as strTextValue union all
			select	cast(null as nvarchar(200)) as strTextValue union all
			select	cast(null as nvarchar(200)) as strTextValue union all
			select	cast(N'Text F' as nvarchar(200)) as strTextValue union all
			select	cast(null as nvarchar(200)) as strTextValue union all
			select	cast(N'Text G' as nvarchar(200)) as strTextValue union all
			select	cast(null as nvarchar(200)) as strTextValue union all
			select	cast(N'Text I' as nvarchar(200)) as strTextValue
		) val
		where		exists (select 1 from @FFWithSpecificValue ffsv where ffsv.idfsParameter = p.idfsParameter)
					and p.intRowStatus = 0
					and p.idfsParameterType = 10071045	/*String*/


	insert into @Region
		(RegionName)
	values 
		  (N'Adjara')
		, (N'Guria')
		, (N'Imereti')
		, (N'Kakheti')

end
else 
begin

	set @StreetName = isnull(@StreetName, N'Green')
	insert into	@Street (StreetName) values (@StreetName)

	select	@EmployeeGroupName = gr.[name]
	from	(
		select	top 1 r_egn.[name]
		from	tlbEmployeeGroup eg
		join	fnReference('en', 19000022 /*Employee Group Name*/) r_egn
		on		r_egn.idfsReference = eg.idfsEmployeeGroupName
		where	eg.intRowStatus = 0
				and eg.idfEmployeeGroup <> -1 /*Default*/
		order by	eg.idfEmployeeGroup
			) gr

	insert into @Employee 
		(EmployeeFirstName, EmployeeLastName, EmployeeAccountName)
	values
		(N'Kate', N'Miller', N'Miller.Kate')
		, (N'John', N'Smith', N'Smith.John')
		, (N'David', N'Fox', N'Fox.David')
		, (N'Ann', N'Johnson', N'Johnson.Ann')
		, (N'Helen', N'Brown', N'Brown.Helen')
		
		, (N'Kate', N'Smith', N'SentByEmployee')

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

	insert into @Region
		(RegionName)
	values 
		(N'Apkhazeti')
		, (N'Adjara')
		, (N'Guria')
		, (N'Imereti')
		, (N'Kakheti')
end

-- Fill in names based on Customization package: end

-- Update Ids in the tables with customizable values

select	@idfEmployeeGroup = eg.idfEmployeeGroup
from	tlbEmployeeGroup eg
join	fnReference('en', 19000022 /*Employee Group Name*/) r_egn
on		r_egn.idfsReference = eg.idfsEmployeeGroupName
where	eg.intRowStatus = 0
		and eg.idfEmployeeGroup <> -1 /*Default*/
		and r_egn.[name] = @EmployeeGroupName collate Cyrillic_General_CI_AS



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

delete	reg_selected
from	@Region reg_selected
where	reg_selected.RegionId is null

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

delete	d_selected
from	@Diagnosis d_selected
where	d_selected.idfsDiagnosis is null

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

delete	cc_selected
from	@CaseClassification cc_selected
where	cc_selected.CaseClassification is null

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


update	sfd_selected
set		sfd_selected.idfsDiagnosis = d.idfsDiagnosis
from	@SampleTypeForDiagnosis sfd_selected
join	trtDiagnosis d
	join	fnReference('en', 19000019 /*Diagnosis*/) r_d
	on		r_d.idfsReference = d.idfsDiagnosis
on		d.idfsUsingType = 10020001 /*Case-based*/
		and d.intRowStatus = 0
		and r_d.[name] = sfd_selected.Diagnosis collate Cyrillic_General_CI_AS
		and r_d.intHACode & 2 /*Human*/ > 0

update	sfd_selected
set		sfd_selected.idfsSampleType = st.idfsSampleType
from	@SampleTypeForDiagnosis sfd_selected
join	trtSampleType st
	join	fnReference('en', 19000087 /*Sample Type*/) r_st
	on		r_st.idfsReference = st.idfsSampleType
on		st.intRowStatus = 0
		and r_st.[name] = sfd_selected.SampleType collate Cyrillic_General_CI_AS
		and r_st.intHACode & 2 /*Human*/ > 0

delete	sfd_selected
from	@SampleTypeForDiagnosis sfd_selected
where	sfd_selected.idfsDiagnosis is null
		or sfd_selected.idfsSampleType is null

if	@existDiagnosisToSampleType = 1
	and exists
	(	select		1
		from		@Diagnosis d
		left join	@SampleTypeForDiagnosis sfd_selected
		on			sfd_selected.idfsDiagnosis = d.idfsDiagnosis
		where		sfd_selected.idfID is null
	)
begin
	insert into	@SampleTypeForDiagnosis (Diagnosis, SampleType, idfsDiagnosis, idfsSampleType)
	select		d.Diagnosis, r_st.[name], d.idfsDiagnosis, st.idfsSampleType
	from		@Diagnosis d
	cross apply
	(			select	top 5
				mfd.idfsSampleType, mfd.intRecommendedQty, newid() as sortRandom
		from	trtMaterialForDisease mfd
		where	mfd.idfsDiagnosis = d.idfsDiagnosis
				and mfd.intRowStatus = 0
		union all
		select	top 5
				mfd.idfsSampleType, mfd.intRecommendedQty, newid() as sortRandom
		from	trtMaterialForDisease mfd
		where	mfd.idfsDiagnosis = d.idfsDiagnosis
				and mfd.intRowStatus = 0
				and mfd.intRecommendedQty > 1
		union all
		select	top 5
				mfd.idfsSampleType, mfd.intRecommendedQty, newid() as sortRandom
		from	trtMaterialForDisease mfd
		where	mfd.idfsDiagnosis = d.idfsDiagnosis
				and mfd.intRowStatus = 0
				and mfd.intRecommendedQty > 2
		order by intRecommendedQty desc, sortRandom
	) mfd
	inner join	trtSampleType st
	on			st.idfsSampleType = mfd.idfsSampleType
	inner join	fnReference('en', 19000087 /*Sample Type*/) r_st
	on			r_st.idfsReference = st.idfsSampleType
	left join	@SampleTypeForDiagnosis sfd
	on			sfd.idfsDiagnosis = d.idfsDiagnosis
	where		sfd.idfID is null
end


update	tntsfd_selected
set		tntsfd_selected.idfsDiagnosis = d.idfsDiagnosis
from	@TestNameToSampleTypeAndDiagnosis tntsfd_selected
join	trtDiagnosis d
	join	fnReference('en', 19000019 /*Diagnosis*/) r_d
	on		r_d.idfsReference = d.idfsDiagnosis
on		d.idfsUsingType = 10020001 /*Case-based*/
		and d.intRowStatus = 0
		and r_d.[name] = tntsfd_selected.Diagnosis collate Cyrillic_General_CI_AS
		and r_d.intHACode & 2 /*Human*/ > 0

update	tntsfd_selected
set		tntsfd_selected.idfsSampleType = st.idfsSampleType
from	@TestNameToSampleTypeAndDiagnosis tntsfd_selected
join	trtSampleType st
	join	fnReference('en', 19000087 /*Sample Type*/) r_st
	on		r_st.idfsReference = st.idfsSampleType
on		st.intRowStatus = 0
		and r_st.[name] = tntsfd_selected.SampleType collate Cyrillic_General_CI_AS
		and r_st.intHACode & 2 /*Human*/ > 0

update	tntsfd_selected
set		tntsfd_selected.idfsTestName = r_tn.idfsReference
from	@TestNameToSampleTypeAndDiagnosis tntsfd_selected
join	fnReference('en', 19000097 /*Test Name*/) r_tn
on		r_tn.[name] = tntsfd_selected.TestName collate Cyrillic_General_CI_AS
		and r_tn.intHACode & 2 /*Human*/ > 0


update	tntsfd_selected
set		tntsfd_selected.idfsTestCategory = r_tc.idfsReference
from	@TestNameToSampleTypeAndDiagnosis tntsfd_selected
join	fnReference('en', 19000095 /*Test Category*/) r_tc
on		r_tc.[name] = tntsfd_selected.TestCategory collate Cyrillic_General_CI_AS

update	tntsfd_selected
set		tntsfd_selected.idfsTestCategory = 10095003 /*Presumptive*/,
		tntsfd_selected.TestCategory = N'Presumptive'
from	@TestNameToSampleTypeAndDiagnosis tntsfd_selected
where	tntsfd_selected.idfsTestCategory is null

delete	tntsfd_selected
from	@TestNameToSampleTypeAndDiagnosis tntsfd_selected
where	tntsfd_selected.idfsDiagnosis is null
		or tntsfd_selected.idfsSampleType is null
		or tntsfd_selected.idfsTestName is null

if	@existDiagnosisToTestName = 1
	and exists
	(	select		1
		from		@SampleTypeForDiagnosis sfd
		left join	@TestNameToSampleTypeAndDiagnosis tntsfd_selected
		on			tntsfd_selected.idfsDiagnosis = sfd.idfsDiagnosis
					and tntsfd_selected.idfsSampleType = sfd.idfsSampleType
		where		tntsfd_selected.idfID is null
	)
begin
	insert into	@TestNameToSampleTypeAndDiagnosis (Diagnosis, SampleType, TestName, TestCategory, idfsDiagnosis, idfsSampleType, idfsTestName, idfsTestCategory)
	select		sfd.Diagnosis, sfd.SampleType, r_tn.[name], isnull(r_tc.[name], N'Presumptive'), sfd.idfsDiagnosis, sfd.idfsSampleType, r_tn.idfsReference, isnull(r_tc.idfsReference, 10095003 /*Presumptive*/)
	from		@SampleTypeForDiagnosis sfd
	cross apply
	(			select	top 5
				tfd.idfsTestName, tfd.idfsTestCategory, tfd.intRecommendedQty, newid() as sortRandom
		from	trtTestForDisease tfd
		where	tfd.idfsDiagnosis = sfd.idfsDiagnosis
				and (tfd.idfsSampleType is null or tfd.idfsSampleType = sfd.idfsSampleType)
				and tfd.intRowStatus = 0
		union all
		select	top 5
				tfd.idfsTestName, tfd.idfsTestCategory, tfd.intRecommendedQty, newid() as sortRandom
		from	trtTestForDisease tfd
		where	tfd.idfsDiagnosis = sfd.idfsDiagnosis
				and (tfd.idfsSampleType is null or tfd.idfsSampleType = sfd.idfsSampleType)
				and tfd.intRowStatus = 0
				and tfd.intRecommendedQty > 1
		union all
		select	top 5
				tfd.idfsTestName, tfd.idfsTestCategory, tfd.intRecommendedQty, newid() as sortRandom
		from	trtTestForDisease tfd
		where	tfd.idfsDiagnosis = sfd.idfsDiagnosis
				and (tfd.idfsSampleType is null or tfd.idfsSampleType = sfd.idfsSampleType)
				and tfd.intRowStatus = 0
				and tfd.intRecommendedQty > 2
		order by idfsSampleType desc, intRecommendedQty desc, sortRandom
	) tfd
	inner join	fnReference('en', 19000097 /*Test Name*/) r_tn
	on			r_tn.idfsReference = tfd.idfsTestName
	left join	fnReference('en', 19000095 /*Test Category*/) r_tc
	on			r_tc.idfsReference = tfd.idfsTestCategory
	left join	@TestNameToSampleTypeAndDiagnosis tntsfd_selected
	on			tntsfd_selected.idfsDiagnosis = sfd.idfsDiagnosis
				and tntsfd_selected.idfsSampleType = sfd.idfsSampleType
	where		tntsfd_selected.idfID is null
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



select	@idfsDefaultSiteEmployee = ut.idfPerson,
		@DefaultSiteUser = aspU.[UserName]
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
select	@idfsDefaultSiteEmployee = ut.idfPerson,
		@DefaultSiteUser = aspU.[UserName]
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
select	@idfsDefaultSiteEmployee = ut.idfPerson,
		@DefaultSiteUser = aspU.[UserName]
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


declare @cmd nvarchar(max)

-- Start iterations
declare @CurrentIteration int = 0
declare	@curCaseCount	bigint = 0
declare	@MissingEmployees int = 0
declare	@Today	datetime = convert(nvarchar, getdate(), 112)

declare	@err_number int
declare	@err_severity int
declare	@err_state int
declare	@err_line int
declare	@err_procedure	nvarchar(200)
declare	@err_message	nvarchar(MAX)


while @CurrentIteration < isnull(@Iterations, 1)
begin

set	@CurrentIteration = @CurrentIteration + 1

print	'Iteration #' + cast(@CurrentIteration as varchar(20))
print	''
print	''


-- Temporary tables
if object_id('tempdb..#GenerateHC') is not null
begin
	set @cmd = N'drop table #GenerateHC'
	execute sp_executesql @cmd
end

if object_id('tempdb..#GenerateHC') is null
create table	#GenerateHC
(	idfID											bigint not null identity(1,22) primary key,
	idfGuid											uniqueidentifier not null default(newid()),
	randValue1										float null,
	randValue2										float null,
	randValue3										float null,
	randValue4										float null,
	randValue5										float null,
	randValue6										float null,
	idfHumanCase									bigint null,
	idfHuman										bigint null,
	idfHumanActual									bigint null,
	idfCSObservation								bigint null,
	idfEpiObservation								bigint null,
	idfPointGeoLocation								bigint null,
	EIDSSPersonID									nvarchar(200) collate Cyrillic_General_CI_AS null,
	strCaseID										nvarchar(200) collate Cyrillic_General_CI_AS null,
	idfsCRRegion									bigint null,
	idfsCRRayon										bigint null,
	idfsCRSettlement								bigint null,
	strStreetName									nvarchar(200) collate Cyrillic_General_CI_AS null,
	strPostalCode									nvarchar(200) collate Cyrillic_General_CI_AS null,
	strBuilding										nvarchar(200) collate Cyrillic_General_CI_AS null,
	strHouse										nvarchar(200) collate Cyrillic_General_CI_AS null,
	strApartment									nvarchar(200) collate Cyrillic_General_CI_AS null,
	idfsHumanGender									bigint null,
	strPatientLast									nvarchar(200) collate Cyrillic_General_CI_AS null,
	strPatientFirst									nvarchar(200) collate Cyrillic_General_CI_AS null,
	strPatientSecond								nvarchar(200) collate Cyrillic_General_CI_AS null,
	strPhoneNumber									nvarchar(200) collate Cyrillic_General_CI_AS null,
	idfsPersonIDType								bigint null,
	idfsOccupationType								bigint null,
	idfsNationality									bigint null,
	idfsSite										bigint null,
	idfPerson										bigint null,
	idfUserID										bigint null,
	strUserName										nvarchar(200) collate Cyrillic_General_CI_AS null,
	idfSentByOffice									bigint null,
	idfSentByPerson									bigint null,
	idfsCaseProgressStatus							bigint null default (10109001/*In process*/),
	idfsTentativeDiagnosis							bigint null,
	idfsFinalDiagnosis								bigint null,
	idfsCSFormTemplate								bigint null,
	idfsEpiFormTemplate								bigint null,
	idfsOutcome										bigint null,
	idfsHospitalizationStatus						bigint null,
	idfsFinalState									bigint null,
	idfsInitialCaseStatus							bigint null,
	idfsFinalCaseStatus								bigint null,
	blnClinicalDiagBasis							bit null,
	blnEpiDiagBasis									bit null,
	blnLabDiagBasis									bit null,
	idfsYNSpecimenCollected							bigint null,
	idfsYNTestsConducted							bigint null,
	idfsYNHospitalization							bigint null,
	strHospitalizationPlace							nvarchar(200) collate Cyrillic_General_CI_AS null,
	datHospitalizationDate							datetime null,
	datEnteredDate									datetime null,
	datCompletionPaperFormDate						datetime null,
	datNotificationDate								datetime null,
	datModificationDate								datetime null,
	datFacilityLastVisit							datetime null,
	datDischargeDate								datetime null,
	datOnsetDate									datetime null,
	datTentativeDiagnosisDate						datetime null,
	datFinalDiagnosisDate							datetime null,
	datFinalCaseClassificationDate					datetime null,
	datDateOfBirth									datetime null,
	datDateOfDeath									datetime null,
	intAgeYear										int null,
	intAgeMonth										int null,
	intAgeDay										int null,
	intPatientAge									int null,
	idfsHumanAgeType								bigint null,
	datCreatePersonExecutionTime					datetime null,
	intCreatePersonElapsedTimeMicrosecond			bigint null,
	fltCreatePersonElapsedTimeMilisecond			float null,
	intCreatePersonWorkerTimeMicrosecond			bigint null,
	fltCreatePersonWorkerTimeMilisecond				float null,
	intCreatePersonTotalExecutionTimeMiliSecond		bigint null,
	intCreatePersonProcessedRows					bigint null,
	intCreatePersonLogicalReads						bigint null,
	intCreatePersonLogicalWrites					bigint null,
	strCreatePersonQuery							nvarchar(max) collate Cyrillic_General_CI_AS null,
	datCreateHDRExecutionTime						datetime null,
	intCreateHDRElapsedTimeMicrosecond				bigint null,
	fltCreateHDRElapsedTimeMilisecond				float null,
	intCreateHDRWorkerTimeMicrosecond				bigint null,
	fltCreateHDRWorkerTimeMilisecond				float null,
	intCreateHDRTotalExecutionTimeMiliSecond		bigint null,
	intCreateHDRProcessedRows						bigint null,
	intCreateHDRLogicalReads						bigint null,
	intCreateHDRLogicalWrites						bigint null,
	strCreateHDRQuery								nvarchar(max) collate Cyrillic_General_CI_AS null,
	datEditHDRSampleExecutionTime					datetime null,
	intEditHDRSampleElapsedTimeMicrosecond			bigint null,
	fltEditHDRSampleElapsedTimeMilisecond			float null,
	intEditHDRSampleWorkerTimeMicrosecond			bigint null,
	fltEditHDRSampleWorkerTimeMilisecond			float null,
	intEditHDRSampleTotalExecutionTimeMiliSecond	bigint null,
	intEditHDRSampleProcessedRows					bigint null,
	intEditHDRSampleLogicalReads					bigint null,
	intEditHDRSampleLogicalWrites					bigint null,
	strEditHDRSampleQuery							nvarchar(max) collate Cyrillic_General_CI_AS null,
	datEditHDRTestExecutionTime						datetime null,
	intEditHDRTestElapsedTimeMicrosecond			bigint null,
	fltEditHDRTestElapsedTimeMilisecond				float null,
	intEditHDRTestWorkerTimeMicrosecond				bigint null,
	fltEditHDRTestWorkerTimeMilisecond				float null,
	intEditHDRTestTotalExecutionTimeMiliSecond		bigint null,
	intEditHDRTestProcessedRows						bigint null,
	intEditHDRTestLogicalReads						bigint null,
	intEditHDRTestLogicalWrites						bigint null,
	strEditHDRTestQuery								nvarchar(max) collate Cyrillic_General_CI_AS null
)
truncate table #GenerateHC



if object_id('tempdb..#GenerateSpecificFFValue') is not null
begin
	set @cmd = N'drop table #GenerateSpecificFFValue'
	execute sp_executesql @cmd
end

if object_id('tempdb..#GenerateSpecificFFValue') is null
create table	#GenerateSpecificFFValue
(	idfID					bigint not null identity(1,1) primary key,
	idfHCID					bigint not null,
	blnHCS					bit null,
	blnHEI					bit null,
	idfObservation			bigint null,
	idfsParameter			bigint not null,
	idfActivityParameters	bigint null,
	idfRow					bigint null,
	varValue				sql_variant null
)
truncate table #GenerateSpecificFFValue


if object_id('tempdb..#GenerateHCSample') is not null
begin
	set @cmd = N'drop table #GenerateHCSample'
	execute sp_executesql @cmd
end

if object_id('tempdb..#GenerateHCSample') is null
create table	#GenerateHCSample
(	idfID						bigint not null identity(1,1) primary key,
	idfHCID						bigint not null,
	idfHCGuid					uniqueidentifier not null,
	randValue1					float null,
	randValue2					float null,
	randValue3					float null,
	randValue4					float null,
	randValue5					float null,
	randValue6					float null,
	idfHumanCase				bigint null,
	idfHuman					bigint null,
	idfMaterial					bigint null,
	strCaseID					nvarchar(200) collate Cyrillic_General_CI_AS null,
	strPatientLast				nvarchar(200) collate Cyrillic_General_CI_AS null,
	strPatientFirst				nvarchar(200) collate Cyrillic_General_CI_AS null,
	strPatientSecond			nvarchar(200) collate Cyrillic_General_CI_AS null,
	idfsDiagnosis				bigint null,
	idfsSite					bigint null,
	strFieldBarcode				nvarchar(200) collate Cyrillic_General_CI_AS null,
	idfsSampleType				bigint null,
	idfSendToOffice				bigint null,
	idfFieldCollectedByOffice	bigint null,
	idfFieldCollectedByPerson	bigint null,
	idfsSampleStatus			bigint null,
	idfsSampleKind				bigint null,
	datEnteringDate				datetime null,
	datFieldCollectionDate		datetime null

)
truncate table #GenerateHCSample


if object_id('tempdb..#GenerateHCTest') is not null
begin
	set @cmd = N'drop table #GenerateHCTest'
	execute sp_executesql @cmd
end

if object_id('tempdb..#GenerateHCTest') is null
create table	#GenerateHCTest
(	idfID							bigint not null identity(1,2) primary key,
	idfHCID							bigint not null,
	idfMaterialID					bigint not null,
	randValue1						float null,
	randValue2						float null,
	randValue3						float null,
	randValue4						float null,
	randValue5						float null,
	randValue6						float null,
	idfMaterial						bigint null,
	idfTesting						bigint null,
	idfObservation					bigint null,
	idfsSite						bigint null,
	idfsDiagnosis					bigint null,
	idfsSampleType					bigint null,
	idfsTestName					bigint null,
	idfsTestCategory				bigint null,
	idfsTestStatus					bigint null,
	idfsTestResult					bigint null,
	datStartedDate					datetime null,
	datConcludedDate				datetime null,
	idfTestedByOffice				bigint null,
	idfTestedByPerson				bigint null,
	idfResultEnteredByOffice		bigint null,
	idfResultEnteredByPerson		bigint null
)
truncate table #GenerateHCTest



-- Random child record
if Object_ID('tempdb..#RandomChildRecord') is not null
begin
	set	@cmd = N'drop table #RandomChildRecord'
	execute sp_executesql @cmd
end

if Object_ID('tempdb..#RandomChildRecord') is null
create table	#RandomChildRecord
(	[idfID]		int not null identity(1,1) primary key,
	idfGuid		uniqueidentifier not null default(newid()),
	randValue	float null
)
truncate table #RandomChildRecord


if object_id('tempdb..#RandomDate') is not null
begin
	set @cmd = N'drop table #RandomDate'
	execute sp_executesql @cmd
end

if object_id('tempdb..#RandomDate') is null
create table	#RandomDate
(	idfID				bigint not null identity(1,1) primary key,
	intDayDiff			int not null,
	intHour				int not null default(0),
	intMin				int not null default(0),
	intSec				int not null default(0),
	datRandomDate		datetime null,
	datRandomDateTime	datetime null
)
truncate table #RandomDate


-- Fill random values 
insert into	#RandomChildRecord (randValue)
select	top (100)
	val.randValue
from	(	
	select	rand(b*1000000 + a*100000 + c*10000 + d*1000) as randValue	
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
		) val
order by NEWID()



insert into	#RandomDate (intDayDiff)
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
from	#RandomDate rd
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
--	order by newid()
			) h
on			h.rn = rd.idfID

update	rd
set		rd.intMin = isnull(m.minNum, 0)
from	#RandomDate rd
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

update	#RandomDate
set		datRandomDateTime = dateadd(second, intSec, dateadd(minute, intMin, dateadd(hour, intHour, dateadd(day, -intDayDiff, @EndOfDateInterval /*@Today*/))))


-- Fill case data
insert into	#GenerateHC (idfGuid, randValue1, randValue2, randValue3, randValue4, randValue5, randValue6)
select	top (@CaseCnt) cases.idfGuid, cases.randValue1, cases.randValue2, cases.randValue3, cases.randValue4, cases.randValue5, cases.randValue6
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
	where a*1000000 + b*100000 + c*10000 + d*1000 + e*100 + f*10 + g < @CaseCnt
		) cases
order by NEWID()

update		ghc
set			ghc.idfsCRRegion = crRegion.idfsRegion
from		#GenerateHC ghc
outer apply	(
	select
				count(reg.idfsRegion) as regCount
	from		gisRegion reg
	join		@Region reg_selected
	on			reg_selected.RegionId = reg.idfsRegion
	where		reg.idfsCountry = @CurrentCountry
				and reg.intRowStatus = 0
			) crRegionCount
left join	(
	select
				reg.idfsRegion, row_number () over (order by newid()) as rn
	from		gisRegion reg
	join		@Region reg_selected
	on			reg_selected.RegionId = reg.idfsRegion
	where		reg.idfsCountry = @CurrentCountry
				and reg.intRowStatus = 0
			) crRegion
on			crRegion.rn = cast((ghc.randValue1*crRegionCount.regCount+1) as int)		


update		ghc
set			ghc.idfsCRRayon = crRayon.idfsRayon,
			ghc.strBuilding = 
					case
						when @CurrentCustomization = 51577490000000 /*Thailand*/ 
								and crRayon.idfsRayon is not null 
							then crRayon.strHASC + N'00'
						else null
					end
from		#GenerateHC ghc
outer apply	(
	select
				count(ray.idfsRayon) as rayCount
	from		gisRayon ray
	left join	gisDistrictSubdistrict dsd
	on			dsd.idfsParent = ray.idfsRayon
	where		ray.idfsCountry = @CurrentCountry
				and ray.intRowStatus = 0
				and ray.idfsRegion = ghc.idfsCRRegion
				and dsd.idfsGeoObject is null
			) crRayonCount
left join	(
	select
				ray.idfsRayon, ray.idfsRegion, ray.strHASC, row_number () over (partition by ray.idfsRegion order by newid()) as rn
	from		gisRayon ray
	left join	gisDistrictSubdistrict dsd
	on			dsd.idfsParent = ray.idfsRayon
	where		ray.idfsCountry = @CurrentCountry
				and ray.intRowStatus = 0
				and dsd.idfsGeoObject is null
			) crRayon
on			crRayon.idfsRegion = ghc.idfsCRRegion
			and crRayon.rn = cast((ghc.randValue2*crRayonCount.rayCount+1) as int)

update		ghc
set			ghc.idfsCRSettlement = crSettlement.idfsSettlement,
			ghc.strPostalCode = left(cast(crSettlement.idfsSettlement as nvarchar) + N'123456789', 5),
			ghc.strBuilding = 
					case
						when @CurrentCustomization = 51577490000000 /*Thailand*/ 
								and crSettlement.idfsSettlement is not null 
							then crSettlement.strSettlementCode
						when @CurrentCustomization not in 
								(	51577400000000/*Armenia*/, 
									51577410000000/*Azerbaijan*/, 
									51577430000000/*Georgia*/, 
									51577380000000/*Kazakhstan (MoH)*/, 
									51577460000000/*Ukraine*/
								)
								and crSettlement.idfsSettlement is not null
							then substring(cast(ghc.randValue3 as nvarchar), 2, 5)
						else ghc.strBuilding
					end
from		#GenerateHC ghc
outer apply	(
	select
				count(s.idfsSettlement) as stlmCount
	from		gisSettlement s
	where		s.idfsCountry = @CurrentCountry
				and s.intRowStatus = 0
				and s.idfsRegion = ghc.idfsCRRegion
				and s.idfsSettlement = ghc.idfsCRRayon
			) crSettlementCount
left join	(
	select
				s.idfsSettlement, s.strSettlementCode, s.idfsRayon, s.idfsRegion, row_number () over (partition by s.idfsRegion, s.idfsRayon order by newid()) as rn
	from		gisSettlement s
	where		s.idfsCountry = @CurrentCountry
				and s.intRowStatus = 0
			) crSettlement
on			crSettlement.idfsRegion = ghc.idfsCRRegion
			and crSettlement.idfsRayon = ghc.idfsCRRayon
			and crSettlement.rn = cast((ghc.randValue3*crSettlementCount.stlmCount+1) as int)


update		ghc
set			ghc.strStreetName = crStreet.StreetName,
			ghc.strHouse = 
					case
						when @CurrentCustomization not in 
								(	51577400000000/*Armenia*/, 
									51577410000000/*Azerbaijan*/, 
									51577430000000/*Georgia*/, 
									51577380000000/*Kazakhstan (MoH)*/, 
									51577460000000/*Ukraine*/
								)
							then crHouse.strNum
						else ghc.strHouse
					end,
			ghc.strApartment = 
					case
						when @CurrentCustomization not in 
								(	51577400000000/*Armenia*/, 
									51577410000000/*Azerbaijan*/, 
									51577430000000/*Georgia*/, 
									51577380000000/*Kazakhstan (MoH)*/, 
									51577460000000/*Ukraine*/
								)
							then crApt.strNum
						else ghc.strApartment
					end
from		#GenerateHC ghc

outer apply	(
	select
				count(s.idfID) as strCount
	from		@Street s
			) crStreetCount
left join	(
	select
				s.StreetName, row_number () over (order by newid()) as rn
	from		@Street s
			) crStreet
on			crStreet.rn = cast((ghc.randValue6*crStreetCount.strCount+1) as int)

outer apply	(
	select
				count(ns.idfID) as nsCount
	from		@NumericOrEmptyString ns
	where		ns.intNum is not null
			) crHouseCount
left join	(
	select
				ns.strNum, row_number () over (order by newid()) as rn
	from		@NumericOrEmptyString ns
	where		ns.intNum is not null
			) crHouse
on			crHouse.rn = cast((ghc.randValue1*crHouseCount.nsCount+1) as int)

outer apply	(
	select
				count(ns.idfID) as nsCount
	from		@NumericOrEmptyString ns
			) crAptCount
left join	(
	select
				ns.strNum, row_number () over (order by newid()) as rn
	from		@NumericOrEmptyString ns
			) crApt
on			crApt.rn = cast((ghc.randValue4*crAptCount.nsCount+1) as int)

where		ghc.idfsCRSettlement is not null

update		ghc
set			ghc.strPhoneNumber = 
				N'+' + 
				left(replace(right(cast(ghc.randValue2 as nvarchar(100)), len(cast(ghc.randValue2 as nvarchar(100)))-2), N'0', N'') + 
					N'12034056', 6) +
				left(right(cast(ghc.randValue3 as nvarchar(100)), len(cast(ghc.randValue3 as nvarchar(100)))-2) + 
					N'078901', 6)
from		#GenerateHC ghc
where		round(ghc.randValue1, 0) = 0
			or round(ghc.randValue4, 0) = 0
			or round(ghc.randValue5, 0) = 0
			or round(ghc.randValue6, 0) = 0


update		ghc
set			ghc.idfsHumanGender = item.idfsReference
from		#GenerateHC ghc
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
set			ghc.strPatientLast = item.LastName
from		#GenerateHC ghc
outer apply	(
	select
				count(ln.idfID) as intCount
	from		@LastName ln
	where		ln.idfsHumanGender = ghc.idfsHumanGender
			) itemsCount
left join	(
	select
				ln.LastName, ln.idfsHumanGender, row_number () over (partition by ln.idfsHumanGender order by newid()) as rn
	from		@LastName ln
			) item
on			item.idfsHumanGender = ghc.idfsHumanGender
			and item.rn = cast((ghc.randValue1*itemsCount.intCount+1) as int)		

update		ghc
set			ghc.strPatientSecond = item.SecondName
from		#GenerateHC ghc
outer apply	(
	select
				count(sn.idfID) as intCount
	from		@SecondName sn
	where		sn.idfsHumanGender = ghc.idfsHumanGender
			) itemsCount
left join	(
	select
				sn.SecondName, sn.idfsHumanGender, row_number () over (partition by sn.idfsHumanGender order by newid()) as rn
	from		@SecondName sn
			) item
on			item.idfsHumanGender = ghc.idfsHumanGender
			and item.rn = cast((ghc.randValue3*itemsCount.intCount+1) as int)		

update		ghc
set			ghc.strPatientFirst = item.FirstName
from		#GenerateHC ghc
outer apply	(
	select
				count(fn.idfID) as intCount
	from		@FirstName fn
	where		fn.idfsHumanGender = ghc.idfsHumanGender
			) itemsCount
left join	(
	select
				fn.FirstName, fn.idfsHumanGender, row_number () over (partition by fn.idfsHumanGender order by newid()) as rn
	from		@FirstName fn
			) item
on			item.idfsHumanGender = ghc.idfsHumanGender
			and item.rn = cast((ghc.randValue2*itemsCount.intCount+1) as int)		

update		ghc
set			ghc.idfsPersonIDType = item.idfsReference
from		#GenerateHC ghc
outer apply	(
	select
				count(r_pidt.idfsReference) as intCount
	from		fnReference('en', 19000148 /*Person ID Type*/) r_pidt
			) itemsCount
left join	(
	select
				r_pidt.idfsReference, row_number () over (order by newid()) as rn
	from		fnReference('en', 19000148 /*Person ID Type*/) r_pidt
			) item
on			item.rn = cast((ghc.randValue5*itemsCount.intCount+1) as int)		

update		ghc
set			ghc.idfsOccupationType = item.idfsReference
from		#GenerateHC ghc
outer apply	(
	select
				count(r_oct.idfsReference) as intCount
	from		fnReference('en', 19000061 /*Occupation Type*/) r_oct
			) itemsCount
left join	(
	select
				r_oct.idfsReference, row_number () over (order by newid()) as rn
	from		fnReference('en', 19000061 /*Occupation Type*/) r_oct
			) item
on			item.rn = cast((ghc.randValue6*itemsCount.intCount+1) as int)
where		itemsCount.intCount > 0

update		ghc
set			ghc.idfsNationality = item.idfsReference
from		#GenerateHC ghc
outer apply	(
	select
				count(r_nl.idfsReference) as intCount
	from		fnReference('en', 19000054 /*Nationality List*/) r_nl
			) itemsCount
left join	(
	select
				r_nl.idfsReference, row_number () over (order by newid()) as rn
	from		fnReference('en', 19000054 /*Nationality List*/) r_nl
			) item
on			item.rn = cast((ghc.randValue1*itemsCount.intCount+1) as int)
where		itemsCount.intCount > 0

update		ghc
set			ghc.idfsSite = isnull(item.idfsSite, @idfsDefaultSite),
			ghc.idfSentByOffice = item.idfOffice
from		#GenerateHC ghc
outer apply	(
	select
				count(s.idfsSite) as intCount
	from		tstSite s
	join		tlbOffice o
	on			o.idfOffice = s.idfOffice
	left join	tlbGeoLocationShared gls
	on			gls.idfGeoLocationShared = o.idfLocation
	where		s.intRowStatus = 0
				and s.idfCustomizationPackage = @CurrentCustomization
				and s.blnIsWEB = 0
				and gls.idfsRegion = ghc.idfsCRRegion
				and gls.idfsRayon = ghc.idfsCRRayon
				and (	(@CurrentCustomization = 51577430000000 /*Georgia*/ and isnull(s.intFlags, o.intHACode) & 2 /*Human*/ > 0)
						or (@CurrentCustomization <> 51577430000000 /*Georgia*/ and isnull(o.intHACode, 0) & 2 /*Human*/ > 0)
					)
			) itemsCount
left join	(
	select
				s.idfsSite, o.idfOffice, gls.idfsRegion, gls.idfsRayon, s.idfsParentSite, 
				row_number () over (partition by gls.idfsRegion, gls.idfsRayon, s.idfsParentSite order by newid()) as rn
	from		tstSite s
	join		tlbOffice o
	on			o.idfOffice = s.idfOffice
	left join	tlbGeoLocationShared gls
	on			gls.idfGeoLocationShared = o.idfLocation
	where		s.intRowStatus = 0
				and s.idfCustomizationPackage = @CurrentCustomization
				and s.blnIsWEB = 0
				and (	(@CurrentCustomization = 51577430000000 /*Georgia*/ and isnull(s.intFlags, o.intHACode) & 2 /*Human*/ > 0)
						or (@CurrentCustomization <> 51577430000000 /*Georgia*/ and isnull(o.intHACode, 0) & 2 /*Human*/ > 0)
					)
			) item
on			item.idfsRegion = ghc.idfsCRRegion
			and item.idfsRayon = ghc.idfsCRRayon
			and item.rn = cast((ghc.randValue4*itemsCount.intCount+1) as int)		


update		ghc
set			ghc.idfSentByOffice = isnull(item.idfOffice, ghc.idfSentByOffice)
from		#GenerateHC ghc
outer apply	(
	select
				count(o.idfOffice) as intCount
	from		tlbOffice o
	left join	tlbGeoLocationShared gls
	on			gls.idfGeoLocationShared = o.idfLocation
	left join	tstSite s
	on			s.idfOffice = o.idfOffice
				and s.intRowStatus = 0
	where		o.intRowStatus = 0
				and o.idfCustomizationPackage = @CurrentCustomization
				and (isnull(s.blnIsWEB, 0) <> 1)
				and gls.idfsRegion = ghc.idfsCRRegion
				and gls.idfsRayon = ghc.idfsCRRayon
				and (	(@CurrentCustomization = 51577430000000 /*Georgia*/ and isnull(s.intFlags, o.intHACode) & 2 /*Human*/ > 0)
						or (@CurrentCustomization <> 51577430000000 /*Georgia*/ and isnull(o.intHACode, 0) & 2 /*Human*/ > 0)
					)
			) itemsCount
left join	(
	select
				o.idfOffice, gls.idfsRegion, gls.idfsRayon, 
				row_number () over (partition by gls.idfsRegion, gls.idfsRayon order by newid()) as rn
	from		tlbOffice o
	left join	tlbGeoLocationShared gls
	on			gls.idfGeoLocationShared = o.idfLocation
	left join	tstSite s
	on			s.idfOffice = o.idfOffice
				and s.intRowStatus = 0
	where		o.intRowStatus = 0
				and o.idfCustomizationPackage = @CurrentCustomization
				and (isnull(s.blnIsWEB, 0) <> 1)
				and (	(@CurrentCustomization = 51577430000000 /*Georgia*/ and isnull(s.intFlags, o.intHACode) & 2 /*Human*/ > 0)
						or (@CurrentCustomization <> 51577430000000 /*Georgia*/ and isnull(o.intHACode, 0) & 2 /*Human*/ > 0)
					)
			) item
on			item.idfsRegion = ghc.idfsCRRegion
			and item.idfsRayon = ghc.idfsCRRayon
			and item.rn = cast((ghc.randValue5*itemsCount.intCount+1) as int)		




update		ghc
set			ghc.idfsTentativeDiagnosis = item.idfsDiagnosis
from		#GenerateHC ghc
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
on			item.rn = cast((ghc.randValue5*itemsCount.intCount+1) as int)		


update		ghc
set			ghc.idfsFinalDiagnosis = 
				case
					when	cast((ghc.randValue1*2) as int) = 0 
							or ghc.idfsTentativeDiagnosis = item.idfsDiagnosis 
						then	null 
					else	item.idfsDiagnosis 
				end
from		#GenerateHC ghc
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


update		ghc
set			ghc.idfsOutcome = case when cast(ghc.randValue5*20 as int) = 0 then 10770000000 /*Died*/ else item.idfsReference end
from		#GenerateHC ghc
outer apply	(
	select
				count(r_out.idfsReference) as intCount
	from		fnReference('en', 19000064 /*Case Outcome List*/) r_out
	where		r_out.idfsReference <> 10770000000	/*Died*/
			) itemsCount
left join	(
	select
				r_out.idfsReference, row_number () over (order by newid()) as rn
	from		fnReference('en', 19000064 /*Case Outcome List*/) r_out
	where		r_out.idfsReference <> 10770000000	/*Died*/
			) item
on			item.rn = cast((ghc.randValue4*itemsCount.intCount+1) as int)		

if @CurrentCustomization <> 51577460000000/*Ukraine*/
begin
	update		ghc
	set			ghc.idfsHospitalizationStatus = item.idfsReference
	from		#GenerateHC ghc
	outer apply	(
		select
					count(r_plt.idfsReference) as intCount
		from		fnReference('en', 19000041 /*Patient Location Type*/) r_plt
				) itemsCount
	left join	(
		select
					r_plt.idfsReference, row_number () over (order by newid()) as rn
		from		fnReference('en', 19000041 /*Patient Location Type*/) r_plt
				) item
	on			item.rn = cast((ghc.randValue1*itemsCount.intCount+1) as int)
	where		itemsCount.intCount > 0
end
else begin
	update		ghc
	set			ghc.idfsYNHospitalization = item.idfsReference
	from		#GenerateHC ghc
	outer apply	(
		select
					count(r_plt.idfsReference) as intCount
		from		fnReference('en', 19000100	/*Yes/No Value List*/) r_plt
				) itemsCount
	left join	(
		select
					r_plt.idfsReference, row_number () over (order by newid()) as rn
		from		fnReference('en', 19000100	/*Yes/No Value List*/) r_plt
				) item
	on			item.rn = cast((ghc.randValue1*itemsCount.intCount+1) as int)
	where		itemsCount.intCount > 0

	update		ghc
	set			ghc.datHospitalizationDate = isnull(ghc.datFacilityLastVisit, ghc.datTentativeDiagnosisDate),
				ghc.strHospitalizationPlace = item.strHospitalizationPlace
	from		#GenerateHC ghc
	outer apply	(
		select
					count(hp.idfID) as intCount
		from		@HospitalizationPlace hp
				) itemsCount
	left join	(
		select
					hp.strHospitalizationPlace, row_number () over (order by newid()) as rn
		from		@HospitalizationPlace hp
				) item
	on			item.rn = cast((ghc.randValue4*itemsCount.intCount+1) as int)
	where		ghc.idfsYNHospitalization = 10100001	/*Yes*/

end

update		ghc
set			ghc.idfsFinalState = item.idfsReference
from		#GenerateHC ghc
outer apply	(
	select
				count(r_ps.idfsReference) as intCount
	from		fnReference('en', 19000035 /*Patient State*/) r_ps
	where		r_ps.idfsReference <> 10035001 /*Dead*/
			) itemsCount
left join	(
	select
				r_ps.idfsReference, row_number () over (order by newid()) as rn
	from		fnReference('en', 19000035 /*Patient State*/) r_ps
	where		r_ps.idfsReference <> 10035001 /*Dead*/
			) item
on			item.rn = cast((ghc.randValue6*itemsCount.intCount+1) as int)
where		itemsCount.intCount > 0


update		ghc
set			ghc.idfsInitialCaseStatus = item.idfsCaseClassification
from		#GenerateHC ghc
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


update		ghc
set			ghc.idfsFinalCaseStatus = 
				case
					when ghc.idfsInitialCaseStatus in (350000000 /*Confirmed*/, 370000000 /*Not a Case*/)
						then ghc.idfsInitialCaseStatus
					else item.idfsCaseClassification
				end
from		#GenerateHC ghc
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


update		ghc
set			ghc.blnClinicalDiagBasis = item.blnOption
from		#GenerateHC ghc
left join	(
	select		val.blnOption, row_number () over (order by newid()) as rn
	from
	(	select	cast(1 as bit) as blnOption
		union all select cast(0 as bit)
	) val
			) item
on			item.rn = cast((ghc.randValue5*2+1) as int)


update		ghc
set			ghc.blnEpiDiagBasis = item.blnOption
from		#GenerateHC ghc
left join	(
	select		val.blnOption, row_number () over (order by newid()) as rn
	from
	(	select	cast(1 as bit) as blnOption
		union all select cast(0 as bit)
	) val
			) item
on			item.rn = cast((ghc.randValue6*2+1) as int)


-- Fill random dates
update		ghc
set			ghc.datOnsetDate = item.datRandomDateTime,
			ghc.intAgeYear = 
				case
					when cast(ghc.randValue1*5 as int) <= 1 then cast(ghc.randValue3*5 as int)
					when cast(ghc.randValue1*5 as int) > 1 and cast(ghc.randValue1*5 as int) <= 3 then cast(ghc.randValue4*40 as int)
					else cast(ghc.randValue5*70 as int)
				end,
			ghc.intAgeMonth = 
				case
					when cast(ghc.randValue3*5 as int) <= 1 then cast(ghc.randValue4*4 as int)
					when cast(ghc.randValue3*5 as int) > 1 and cast(ghc.randValue3*5 as int) <= 3 then 4 + cast(ghc.randValue5*4 as int)
					else 8 + cast(ghc.randValue6*4 as int)
				end,
			ghc.intAgeDay = 
				case
					when cast(ghc.randValue4*5 as int) <= 1 then cast(ghc.randValue1*10 as int)
					when cast(ghc.randValue4*5 as int) > 1 and cast(ghc.randValue4*5 as int) <= 3 then 10 + cast(ghc.randValue2*10 as int)
					else 20 + cast(ghc.randValue3*10 as int)
				end
from		#GenerateHC ghc
outer apply	(
	select
				count(rd.idfID) as intCount
	from		#RandomDate rd
			) itemsCount
left join	(
	select
				rd.datRandomDate, rd.datRandomDateTime, row_number () over (order by newid()) as rn
	from		#RandomDate rd
			) item
on			item.rn = cast((ghc.randValue2*itemsCount.intCount+1) as int)		

-- Update case data based on random attributes

update		ghc
set			ghc.datEnteredDate = case when dateadd(day, cast(ghc.randValue3*14 as int), ghc.datOnsetDate) > @EndOfDateInterval /*@Today*/ then @EndOfDateInterval /*@Today*/ else dateadd(day, cast(ghc.randValue3*14 as int), ghc.datOnsetDate) end,
			ghc.datOnsetDate = convert(nvarchar, ghc.datOnsetDate, 112)--,
from		#GenerateHC ghc

update		ghc
set			ghc.datModificationDate = ghc.datEnteredDate,
			ghc.datCompletionPaperFormDate = case when @CurrentCustomization = 51577460000000/*Ukraine*/ then ghc.datEnteredDate else null end,
			ghc.datFacilityLastVisit = case when cast(ghc.randValue1*2 as int) > 0 then dateadd(day, cast(ghc.randValue2*(-3) as int), ghc.datOnsetDate) else null end,
			ghc.datTentativeDiagnosisDate = dateadd(day, cast(ghc.randValue4*datediff(day, ghc.datOnsetDate, convert(nvarchar, ghc.datEnteredDate, 112)) as int), ghc.datOnsetDate),
			ghc.datNotificationDate = dateadd(day, cast(ghc.randValue5*datediff(day, dateadd(day, cast(ghc.randValue4*datediff(day, ghc.datOnsetDate, convert(nvarchar, ghc.datEnteredDate, 112)) as int), ghc.datOnsetDate), convert(nvarchar, ghc.datEnteredDate, 112)) as int), dateadd(day, cast(ghc.randValue4*datediff(day, ghc.datOnsetDate, convert(nvarchar, ghc.datEnteredDate, 112)) as int), ghc.datOnsetDate)),
			ghc.datFinalDiagnosisDate = case when ghc.idfsFinalDiagnosis is not null then dateadd(day, cast(ghc.randValue6*datediff(day, dateadd(day, cast(ghc.randValue4*datediff(day, ghc.datOnsetDate, convert(nvarchar, ghc.datEnteredDate, 112)) as int), ghc.datOnsetDate), convert(nvarchar, ghc.datEnteredDate, 112)) as int), dateadd(day, cast(ghc.randValue4*datediff(day, ghc.datOnsetDate, convert(nvarchar, ghc.datEnteredDate, 112)) as int), ghc.datOnsetDate)) else null end,
			ghc.datFinalCaseClassificationDate = case when ghc.idfsFinalDiagnosis is not null then dateadd(day, cast(ghc.randValue6*datediff(day, dateadd(day, cast(ghc.randValue4*datediff(day, ghc.datOnsetDate, convert(nvarchar, ghc.datEnteredDate, 112)) as int), ghc.datOnsetDate), convert(nvarchar, ghc.datEnteredDate, 112)) as int), dateadd(day, cast(ghc.randValue4*datediff(day, ghc.datOnsetDate, convert(nvarchar, ghc.datEnteredDate, 112)) as int), ghc.datOnsetDate)) else dateadd(day, cast(ghc.randValue4*datediff(day, ghc.datOnsetDate, convert(nvarchar, ghc.datEnteredDate, 112)) as int), ghc.datOnsetDate) end,
			ghc.datDateOfBirth = dateadd(day, -ghc.intAgeDay, dateadd(month, -ghc.intAgeMonth, dateadd(year, -ghc.intAgeYear, ghc.datOnsetDate))),
			ghc.idfsHumanAgeType =
				case
					when	intAgeYear > 0
						then	10042003	/*Years*/
					when	intAgeYear = 0
							and intAgeMonth > 0
						then	10042002	/*Month*/
					else	10042001	/*Days*/
				end,
			ghc.intPatientAge =
				case
					when	intAgeYear > 0
						then	intAgeYear
					when	intAgeYear = 0
							and intAgeMonth > 0
						then	intAgeMonth
					else	intAgeDay
				end,
			ghc.datDischargeDate =
				case
					when	ghc.idfsOutcome = 10760000000	/*Recovered*/
						then	case when ghc.idfsFinalDiagnosis is not null then dateadd(day, cast(ghc.randValue6*datediff(day, dateadd(day, cast(ghc.randValue4*datediff(day, ghc.datOnsetDate, convert(nvarchar, ghc.datEnteredDate, 112)) as int), ghc.datOnsetDate), convert(nvarchar, ghc.datEnteredDate, 112)) as int), dateadd(day, cast(ghc.randValue4*datediff(day, ghc.datOnsetDate, convert(nvarchar, ghc.datEnteredDate, 112)) as int), ghc.datOnsetDate)) else dateadd(day, cast(ghc.randValue4*datediff(day, ghc.datOnsetDate, convert(nvarchar, ghc.datEnteredDate, 112)) as int), ghc.datOnsetDate) end
					else null
				end,
			ghc.datDateOfDeath =
				case
					when	ghc.idfsOutcome = 10770000000	/*Died*/
						then	case when ghc.idfsFinalDiagnosis is not null then dateadd(day, cast(ghc.randValue6*datediff(day, dateadd(day, cast(ghc.randValue4*datediff(day, ghc.datOnsetDate, convert(nvarchar, ghc.datEnteredDate, 112)) as int), ghc.datOnsetDate), convert(nvarchar, ghc.datEnteredDate, 112)) as int), dateadd(day, cast(ghc.randValue4*datediff(day, ghc.datOnsetDate, convert(nvarchar, ghc.datEnteredDate, 112)) as int), ghc.datOnsetDate)) else dateadd(day, cast(ghc.randValue4*datediff(day, ghc.datOnsetDate, convert(nvarchar, ghc.datEnteredDate, 112)) as int), ghc.datOnsetDate) end
					else null
				end,
			idfsCaseProgressStatus = case when ghc.idfsFinalCaseStatus in (350000000 /*Confirmed*/, 370000000 /*Not a Case*/) then 10109002 /*Closed*/ else ghc.idfsCaseProgressStatus end
from		#GenerateHC ghc

update		ghc
set			ghc.idfPerson = entered_by_user.idfPerson,
			ghc.idfUserID = entered_by_user.idfUserID,
			ghc.strUserName = entered_by_user.[UserName]
from		#GenerateHC ghc
join		tstSite s
on			s.idfsSite = ghc.idfsSite
join		fnInstitution('en') i
on			i.idfOffice = s.idfOffice 
outer apply (
	select top 1 
		p.idfPerson, ut.idfUserID, aspU.[UserName]
	from	tlbPerson p
	join	tstUserTable ut
	on		ut.idfPerson = p.idfPerson
			and ut.intRowStatus = 0
	join	AspNetUsers aspU
	on		aspU.idfUserID = ut.idfUserID
	join	EmployeeToInstitution e_to_i
	on		e_to_i.idfInstitution = p.idfInstitution
			and e_to_i.aspNetUserId = aspU.[Id]
			and e_to_i.idfUserId = ut.idfUserID
			and e_to_i.intRowStatus = 0
			and e_to_i.IsDefault = 1
			and e_to_i.Active = 1
	where	p.idfInstitution = i.idfOffice
			and p.intRowStatus = 0
			and ut.strAccountName not like N'%Administrator%' collate Cyrillic_General_CI_AS
	order by newid()
			) entered_by_user
where		entered_by_user.idfUserID is not null


update		ghc
set			ghc.idfSentByPerson = sent_by_person.idfPerson
from		#GenerateHC ghc
join		fnInstitution('en') i
on			i.idfOffice = ghc.idfSentByOffice 
outer apply (
	select top 1 
		p.idfPerson
	from	tlbPerson p
	where	p.idfInstitution = ghc.idfSentByOffice
			and p.intRowStatus = 0
			and p.strFamilyName not like N'%Administrator%' collate Cyrillic_General_CI_AS
			and p.strFirstName not like N'%Administrator%' collate Cyrillic_General_CI_AS
	order by newid()
			) sent_by_person
where		sent_by_person.idfPerson is not null


select	@curCaseCount = count(hc.idfHumanCase)
from	tlbHumanCase hc


update		ghc
set			ghc.idfsCSFormTemplate = CS.idfsCSFormTemplate,
			ghc.idfsEpiFormTemplate = Epi.idfsEpiFormTemplate,
			ghc.idfsFinalState = case when ghc.idfsOutcome = 10770000000 /*Died*/ and ghc.datDateOfDeath = ghc.datNotificationDate then 10035001 /*Dead*/ else ghc.idfsFinalState end
from		#GenerateHC ghc
outer apply (
	select top 1 
		ft_CS.idfsFormTemplate AS idfsCSFormTemplate
	from	ffFormTemplate ft_CS
	where	ft_CS.idfsFormType = 10034010 /*Human Clinical Signs*/
			and ft_CS.intRowStatus = 0
			and ( 
					exists (
							select	1
							from	ffDeterminantValue dv_CS
							where	dv_CS.idfsFormTemplate = ft_CS.idfsFormTemplate
									and dv_CS.idfsBaseReference = isnull(ghc.idfsFinalDiagnosis, ghc.idfsTentativeDiagnosis)
									and dv_CS.intRowStatus = 0
							)
					or	( 
						not exists (
									select	1
									from	ffDeterminantValue dv_CS_determ
									join	ffFormTemplate ft_CS_determ ON
											ft_CS_determ.idfsFormTemplate = dv_CS_determ.idfsFormTemplate
											and ft_CS_determ.idfsFormType = 10034010 /*Human Clinical Signs*/
											and ft_CS_determ.intRowStatus = 0
									where	dv_CS_determ.idfsBaseReference = isnull(ghc.idfsFinalDiagnosis, ghc.idfsTentativeDiagnosis)
											and dv_CS_determ.intRowStatus = 0
									)
						and ft_CS.blnUNI = 1
						)
				)
			) CS
outer apply (
	select top 1 
		ft_Epi.idfsFormTemplate AS idfsEpiFormTemplate
	from	ffFormTemplate ft_Epi
	where	ft_Epi.idfsFormType = 10034011 /*Human Epi Investigations*/
			and ft_Epi.intRowStatus = 0
			and ( 
					exists (
							select	1
							from	ffDeterminantValue dv_Epi
							where	dv_Epi.idfsFormTemplate = ft_Epi.idfsFormTemplate
									and dv_Epi.idfsBaseReference = isnull(ghc.idfsFinalDiagnosis, ghc.idfsTentativeDiagnosis)
									and dv_Epi.intRowStatus = 0
							)
					or	( 
						not exists (
									select	1
									from	ffDeterminantValue dv_Epi_determ
									join	ffFormTemplate ft_Epi_determ ON
											ft_Epi_determ.idfsFormTemplate = dv_Epi_determ.idfsFormTemplate
											and ft_Epi_determ.idfsFormType = 10034011 /*Human Epi Investigations*/
											and ft_Epi_determ.intRowStatus = 0
									where	dv_Epi_determ.idfsBaseReference = isnull(ghc.idfsFinalDiagnosis, ghc.idfsTentativeDiagnosis)
											and dv_Epi_determ.intRowStatus = 0
									)
						and ft_Epi.blnUNI = 1
						)
				)
			) Epi



-- Specific CS and EPI FF Values

insert into	#GenerateSpecificFFValue (idfHCID, blnHCS, blnHEI, idfsParameter, varValue)
select		ghc.idfID, 
			ffYNUnk.blnHCS,
			ffYNUnk.blnHEI, 
			ffYNUnk.idfsParameter,
			case when ffYNUnk.blnAllowEmpty = 1 then itemAllowEmpty.idfsYNUnk else itemNotEmpty.idfsYNUnk end
from		#GenerateHC ghc
inner join	@FFWithYNUnk ffYNUnk
on	exists	(
		select	1
		from		ffParameterForTemplate pft
		where		pft.idfsParameter = ffYNUnk.idfsParameter
					and pft.idfsFormTemplate = ffYNUnk.blnHCS*ghc.idfsCSFormTemplate + ffYNUnk.blnHEI*ghc.idfsEpiFormTemplate
					and pft.intRowStatus = 0
			)
outer apply	(
	select
				count(y_n_unk.idfID) as intCount
	from		@YNUnkEmpty y_n_unk
	where		((1-ffYNUnk.blnAllowEmpty)*y_n_unk.blnEmpty = 0)
			) itemsCount
left join	(
	select
				y_n_unk.idfsYNUnk, 
				row_number () over (order by newid()) as rn
	from		@YNUnkEmpty y_n_unk
			) itemAllowEmpty
on			ffYNUnk.blnAllowEmpty = 1
			and itemAllowEmpty.rn = cast((ghc.randValue1*itemsCount.intCount+1) as int)
left join	(
	select
				y_n_unk.idfsYNUnk, 
				row_number () over (order by newid()) as rn
	from		@YNUnkEmpty y_n_unk
	where		y_n_unk.blnEmpty = 0
			) itemNotEmpty
on			ffYNUnk.blnAllowEmpty = 0
			and itemNotEmpty.rn = cast((ghc.randValue1*itemsCount.intCount+1) as int)


insert into	#GenerateSpecificFFValue (idfHCID, blnHCS, blnHEI, idfsParameter, varValue)
select		ghc.idfID, 
			ffSV.blnHCS,
			ffSV.blnHEI, 
			ffSV.idfsParameter,
			case when ffSV.blnAllowEmpty = 1 then itemAllowEmpty.varValue else itemNotEmpty.varValue end
from		#GenerateHC ghc
inner join	@FFWithSpecificValue ffSV
on	exists	(
		select	1
		from		ffParameterForTemplate pft
		where		pft.idfsParameter = ffSV.idfsParameter
					and pft.idfsFormTemplate = ghc.idfsCSFormTemplate*ffSV.blnHCS + ghc.idfsEpiFormTemplate*ffSV.blnHEI
					and pft.intRowStatus = 0
			)
outer apply	(
	select
				count(sv.idfID) as intCount
	from		@FFSpecificValue sv
	where		(ffSV.blnAllowEmpty = 1 or sv.blnEmpty = 0)
			) itemsCount
left join	(
	select
				sv.varValue, 
				row_number () over (order by newid()) as rn
	from		@FFSpecificValue sv
			) itemAllowEmpty
on			itemAllowEmpty.rn = cast((ghc.randValue2*itemsCount.intCount+1) as int)
left join	(
	select
				sv.varValue, 
				row_number () over (order by newid()) as rn
	from		@FFSpecificValue sv
	where		sv.blnEmpty = 0
			) itemNotEmpty
on			ffSV.blnAllowEmpty = 0
			and itemNotEmpty.rn = cast((ghc.randValue2*itemsCount.intCount+1) as int)

delete		gsffv
from		#GenerateSpecificFFValue gsffv
where		gsffv.varValue is null


-- Samples
insert into	#GenerateHCSample
(	idfHCID, 
	idfHCGuid, 
	randValue1, 
	randValue2, 
	randValue3, 
	randValue4, 
	randValue5, 
	randValue6, 
	datEnteringDate, 
	datFieldCollectionDate,
	idfsSite,
	strCaseID,
	strPatientLast,
	strPatientFirst,
	strPatientSecond,
	idfsDiagnosis,
	strFieldBarcode,
	idfsSampleStatus,
	idfsSampleKind,
	idfFieldCollectedByOffice,
	idfFieldCollectedByPerson,
	idfSendToOffice
)
select		ghc.idfID,
			ghc.idfGuid,
			ghc.randValue1,
			ghc.randValue2,
			ghc.randValue3,
			ghc.randValue4,
			ghc.randValue5,
			ghc.randValue6,
			ghc.datEnteredDate,
			dateadd(
				day, 
				cast(round(
						ghc.randValue3*
							datediff(day, ghc.datTentativeDiagnosisDate, convert(nvarchar, ghc.datEnteredDate, 112)), 
						0) as int), 
				ghc.datTentativeDiagnosisDate),--TODO: which formula to use for date?
			ghc.idfsSite,
			ghc.strCaseID,
			ghc.strPatientLast,
			ghc.strPatientFirst,
			ghc.strPatientSecond,
			ghc.idfsTentativeDiagnosis,
			left(cast(ghc.idfGuid as nvarchar(36)), 3) + left(child_records.strGuid, 3) collate Cyrillic_General_CI_AS,
			null,
			null,
			ghc.idfSentByOffice,
			ghc.idfSentByPerson,
			isnull(ghc.idfSentByOffice, s.idfOffice)--TODO: Which Lab to specify?
from		#GenerateHC ghc
left join	tstSite s
on			s.idfsSite = ghc.idfsSite
cross apply	(
	select top 1
				records.idfID as intCount
	from		#RandomChildRecord records
	where		records.idfID <= @MaxSampleCountPerCase
				and records.idfID*ghc.randValue2 > 0
	order by	NEWID()
			) child_records_count
cross apply	(
	select top (child_records_count.intCount)	records.idfID, records.randValue, cast(records.idfGuid as nvarchar(36)) as strGuid
	from		#RandomChildRecord records
	order by	NEWID()
			) child_records

declare	@i int
set	@i = 0
while @i < @MaxSampleCountPerCase
begin

	update		t
	set			t.idfsSampleType = item.idfsSampleType
	from		#GenerateHCSample t
	outer apply	(
		select	count(t_parent_same.idfID) as intRecordNumber
		from	#GenerateHCSample t_parent_same
		where	t_parent_same.idfHCID = t.idfHCID
				and t_parent_same.idfID < t.idfID
				) recordNum
	outer apply	(
		select		top 1 sfd.idfsSampleType
		from		@SampleTypeForDiagnosis sfd
		where		sfd.idfsDiagnosis = t.idfsDiagnosis
					and not exists	(
								select	1
								from	#GenerateHCSample t_child_ex
								where	t_child_ex.idfHCID = t.idfHCID
										and t_child_ex.idfsSampleType = sfd.idfsSampleType
									)
		order by	newid()
				) item
	where		recordNum.intRecordNumber = @i


	set @i = @i + 1

end

delete		t
from		#GenerateHCSample t
where		t.idfsSampleType is null


-- Samples Collected attribute
update		ghc
set			ghc.idfsYNSpecimenCollected = item.idfsReference
from		#GenerateHC ghc
outer apply	(
	select
				count(yn_list.idfsReference) as intCount
	from		fnReference('en', 19000100) yn_list
	where		yn_list.idfsReference <> 10100001	/*Yes*/
			) itemsCount
left join	(
	select
				yn_list.idfsReference, 
				row_number () over (order by newid()) as rn
	from		fnReference('en', 19000100) yn_list
	where		yn_list.idfsReference <> 10100001	/*Yes*/
			) item
on			item.rn = cast((ghc.randValue5*itemsCount.intCount+1) as int)
where		not exists (select 1 from #GenerateHCSample ghcs where ghcs.idfHCID = ghc.idfID)


update		ghc
set			ghc.idfsYNSpecimenCollected = 10100001	/*Yes*/
from		#GenerateHC ghc
where		exists (select 1 from #GenerateHCSample ghcs where ghcs.idfHCID = ghc.idfID)



-- Tests
insert into	#GenerateHCTest
(	idfHCID, 
	idfMaterialID, 
	randValue1, 
	randValue2, 
	randValue3, 
	randValue4, 
	randValue5, 
	randValue6, 
	idfsSite,
	idfsDiagnosis,
	idfsSampleType,
	datStartedDate,
	datConcludedDate,
	idfTestedByOffice,
	idfTestedByPerson,
	idfResultEnteredByOffice,
	idfResultEnteredByPerson
)
select		ghcs.idfHCID,
			ghcs.idfID,
			ghcs.randValue1,
			ghcs.randValue2,
			ghcs.randValue3,
			ghcs.randValue4,
			ghcs.randValue5,
			ghcs.randValue6,
			ghcs.idfsSite,
			ghcs.idfsDiagnosis,
			ghcs.idfsSampleType,
			ghcs.datFieldCollectionDate,
			dateadd(
				day, 
				cast(round(
						ghc.randValue5*
							datediff(day, ghcs.datFieldCollectionDate, convert(nvarchar, ghcs.datEnteringDate, 112)), 
						0) as int), 
				ghcs.datFieldCollectionDate),--TODO: which formula to use for date?
			ghc.idfSentByOffice,
			ghc.idfSentByPerson,
			s.idfOffice,
			ghc.idfPerson
from		#GenerateHCSample ghcs
inner join	#GenerateHC ghc
on			ghc.idfID = ghcs.idfHCID
left join	tstSite s
on			s.idfsSite = ghc.idfsSite
cross apply	(
	select top 1
				records.idfID as intCount
	from		#RandomChildRecord records
	where		records.idfID <= @MaxTestCountPerSample
				and records.idfID*ghc.randValue1 > 0
	order by	NEWID()
			) child_records_count
cross apply	(
	select top (child_records_count.intCount)	records.idfID, records.randValue, cast(records.idfGuid as nvarchar(36)) as strGuid
	from		#RandomChildRecord records
	order by	NEWID()
			) child_records

set	@i = 0
while @i < @MaxTestCountPerSample
begin

	update		t
	set			t.idfsTestName = item.idfsTestName,
				t.idfsTestCategory = item.idfsTestCategory
	from		#GenerateHCTest t
	outer apply	(
		select	count(t_parent_same.idfID) as intRecordNumber
		from	#GenerateHCTest t_parent_same
		where	t_parent_same.idfMaterialID = t.idfMaterialID
				and t_parent_same.idfID < t.idfID
				) recordNum
	outer apply	(
		select		top 1 tntsfd.idfsTestName, tntsfd.idfsTestCategory
		from		@TestNameToSampleTypeAndDiagnosis tntsfd
		where		tntsfd.idfsDiagnosis = t.idfsDiagnosis
					and tntsfd.idfsSampleType = t.idfsSampleType
					and not exists	(
								select	1
								from	#GenerateHCTest t_child_ex
								where	t_child_ex.idfMaterialID = t.idfMaterialID
										and t_child_ex.idfsTestName = tntsfd.idfsTestName
									)
		order by	newid()
				) item
	where		recordNum.intRecordNumber = @i


	set @i = @i + 1

end

delete		t
from		#GenerateHCTest t
where		t.idfsTestName is null

update		ghct
set			ghct.idfsTestResult = item.idfsTestResult
from		#GenerateHCTest ghct
inner join	#GenerateHC ghc
on			ghc.idfID = ghct.idfHCID
			and isnull(ghc.idfsFinalCaseStatus, ghc.idfsInitialCaseStatus) = 350000000 /*Confirmed*/
outer apply	(
	select
				count(tttr.idfsTestResult) as intCount
	from		trtTestTypeToTestResult tttr
	where		tttr.idfsTestName = ghct.idfsTestName
				and tttr.intRowStatus = 0
				and tttr.blnIndicative = 1
			) itemsCount
left join	(
	select
				tttr.idfsTestName, 
				tttr.idfsTestResult,
				row_number () over (partition by tttr.idfsTestName order by newid()) as rn
	from		trtTestTypeToTestResult tttr
	where		tttr.intRowStatus = 0
				and tttr.blnIndicative = 1
			) item
on			item.idfsTestName = ghct.idfsTestName
			and item.rn = cast((ghct.randValue3*itemsCount.intCount+1) as int)

update		ghct
set			ghct.idfsTestResult = item.idfsTestResult
from		#GenerateHCTest ghct
outer apply	(
	select
				count(tttr.idfsTestResult) as intCount
	from		trtTestTypeToTestResult tttr
	where		tttr.idfsTestName = ghct.idfsTestName
				and tttr.intRowStatus = 0
			) itemsCount
left join	(
	select
				tttr.idfsTestName, 
				tttr.idfsTestResult,
				row_number () over (partition by tttr.idfsTestName order by newid()) as rn
	from		trtTestTypeToTestResult tttr
	where		tttr.intRowStatus = 0
			) item
on			item.idfsTestName = ghct.idfsTestName
			and item.rn = cast((ghct.randValue4*itemsCount.intCount+1) as int)
where		ghct.idfsTestResult is null

update		ghct
set			ghct.idfsTestStatus = 10001003/*In progress*/,
			ghct.datConcludedDate = null
from		#GenerateHCTest ghct
where		ghct.idfsTestResult is null

update		ghct
set			ghct.idfsTestStatus = 10001001/*Final*/
from		#GenerateHCTest ghct
where		ghct.idfsTestResult is not null


-- Tests Conducted attribute
update		ghc
set			ghc.idfsYNTestsConducted = item.idfsReference,
			ghc.blnLabDiagBasis = 0
from		#GenerateHC ghc
outer apply	(
	select
				count(yn_list.idfsReference) as intCount
	from		fnReference('en', 19000100) yn_list
	where		yn_list.idfsReference <> 10100001	/*Yes*/
			) itemsCount
left join	(
	select
				yn_list.idfsReference, 
				row_number () over (order by newid()) as rn
	from		fnReference('en', 19000100) yn_list
	where		yn_list.idfsReference <> 10100001	/*Yes*/
			) item
on			item.rn = cast((ghc.randValue6*itemsCount.intCount+1) as int)
where		not exists (select 1 from #GenerateHCTest ghct where ghct.idfHCID = ghc.idfID)


update		ghc
set			ghc.idfsYNTestsConducted = 10100001	/*Yes*/,
			ghc.blnLabDiagBasis = 1
from		#GenerateHC ghc
where		exists (select 1 from #GenerateHCTest ghct where ghct.idfHCID = ghc.idfID)


BEGIN TRANSACTION;

--BEGIN TRY

exec sp_executesql N'
SET ANSI_NULLS ON
'
exec sp_executesql N'
SET QUOTED_IDENTIFIER ON
'
exec sp_executesql N'
ALTER	function [dbo].[FN_GBL_TriggersWork] ()
returns bit
as
begin
return 0
end
'

--Generate missing employees and users
-- Missing Users
print	'Generate missing employees and accounts'

delete from tstNewID

insert into	tstNewID (idfTable, idfKey1, idfKey2)
select		75690000000/*tlbPerson*/,
			s.idfsSite,
			1/*idfPerson*/
from		tstSite s
where		s.intRowStatus = 0
			and s.idfCustomizationPackage = @CurrentCustomization
			and exists (select 1 from #GenerateHC ghc where ghc.idfsSite = s.idfsSite and ghc.idfPerson is null)

insert into	tstNewID (idfTable, idfKey1, idfKey2)
select		76190000000/*tstUserTable*/,
			nId.idfKey1,
			2/*idfUserID*/
from		tstNewID nId
where		nId.idfTable = 75690000000/*tlbPerson*/
			and nId.idfKey2 = 1/*idfPerson*/

insert into	tstNewID (idfTable, idfKey1, idfKey2)
select		76190000000/*tstUserTable*/,
			nId.idfKey1,
			3/*PK of EmployeeToInstitution*/
from		tstNewID nId
where		nId.idfTable = 75690000000/*tlbPerson*/
			and nId.idfKey2 = 1/*idfPerson*/

update		ghc
set			ghc.idfPerson = nId.[NewID]
from		#GenerateHC ghc
join		tstNewID nId
on			nId.idfTable = 75690000000/*tlbPerson*/
			and nId.idfKey1 = ghc.idfsSite
			and nId.idfKey2 = 1/*idfPerson*/

select	@MissingEmployees = count(nId.[NewID])
from	tstNewID nId
where	nId.idfTable = 75690000000/*tlbPerson*/
		and nId.idfKey2 = 1/*idfPerson*/

update		nId
set			nId.strRowGuid = cast(rVal.randValue as nvarchar(36))
from		tstNewID nId
outer apply	(
	select	count(nId_less.[NewID]) as intCount
	from	tstNewID nId_less
	where	nId_less.idfTable = 75690000000/*tlbPerson*/
			and nId_less.idfKey2 = 1/*idfPerson*/
			and nId_less.[NewID] <= nId.[NewID]
			) nId_num
left join	(
	select	top (@MissingEmployees) employees.randValue, row_number() over (order by newid()) as rn
	from		(	
		select rand(g*1000000 + f*100000 + e*10000 + d*1000 + c*100 + b*10 + a) as randValue
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
		where a*1000000 + b*100000 + c*10000 + d*1000 + e*100 + f*10 + g < @CaseCnt
				) employees
			) rVal
on			rVal.rn = nId_num.intCount
where		nId.idfTable = 75690000000/*tlbPerson*/
			and nId.idfKey2 = 1/*idfPerson*/

insert into	tlbEmployee
(	idfEmployee,
	idfsEmployeeType,
	idfsSite,
	intRowStatus,
	AuditCreateUser,
	AuditCreateDTM,
	SourceSystemNameID,
	SourceSystemKeyValue
)
select		nId.[NewID],
			10023002 /*Person*/,
			s.idfsSite,
			0,
			N'system',
			GETDATE(),
			10519001,
			N'[{"idfEmployee":' + CAST(nId.[NewID] AS NVARCHAR(24)) + '}]'
from		tstNewID nId
join		tstSite s
on			s.idfsSite = nId.idfKey1
left join	tlbEmployee e
on			e.idfEmployee = nId.[NewID]
where		nId.idfTable = 75690000000/*tlbPerson*/
			and nId.idfKey2 = 1/*idfPerson*/
			and e.idfEmployee is null
print		'Add missing users of sites who will register new cases (tlbEmployee) - insert: ' + cast(@@rowcount as varchar(20))

insert into	tlbPerson
(	idfPerson,
	idfInstitution,
	strFamilyName,
	strFirstName,
	strSecondName,
	intRowStatus,
	AuditCreateUser,
	AuditCreateDTM,
	SourceSystemNameID,
	SourceSystemKeyValue
)
select		e.idfEmployee,
			s.idfOffice,
			itemLN.LastName,
			itemFN.FirstName,
			itemSN.SecondName,
			0,
			N'system',
			GETDATE(),
			10519001,
			N'[{"idfPerson":' + CAST(e.idfEmployee AS NVARCHAR(24)) + '}]'
from		tstNewID nId
join		tstSite s
on			s.idfsSite = nId.idfKey1
inner join	tlbEmployee e
on			e.idfEmployee = nId.[NewID]
outer apply	(
	select
				count(fn.idfID) as intCount
	from		@FirstName fn
	where		fn.idfsHumanGender = case when cast(cast(nId.strRowGuid as float)*2 as int) < 1 then 10043001 /*Female*/ else 10043002 /*Male*/ end
			) itemsCountFN
left join	(
	select
				fn.FirstName, fn.idfsHumanGender, row_number () over (partition by fn.idfsHumanGender order by newid()) as rn
	from		@FirstName fn
			) itemFN
on			itemFN.idfsHumanGender = case when cast(cast(nId.strRowGuid as float)*2 as int) < 1 then 10043001 /*Female*/ else 10043002 /*Male*/ end
			and itemFN.rn = cast((cast(nId.strRowGuid as float)*itemsCountFN.intCount+1) as int)
outer apply	(
	select
				count(sn.idfID) as intCount
	from		@SecondName sn
	where		sn.idfsHumanGender = case when cast(cast(nId.strRowGuid as float)*2 as int) < 1 then 10043001 /*Female*/ else 10043002 /*Male*/ end
			) itemsCountSN
left join	(
	select
				sn.SecondName, sn.idfsHumanGender, row_number () over (partition by sn.idfsHumanGender order by newid()) as rn
	from		@SecondName sn
			) itemSN
on			itemsn.idfsHumanGender = case when cast(cast(nId.strRowGuid as float)*2 as int) < 1 then 10043001 /*Female*/ else 10043002 /*Male*/ end
			and itemsn.rn = cast((cast(nId.strRowGuid as float)*itemsCountsn.intCount+1) as int)
outer apply	(
	select
				count(ln.idfID) as intCount
	from		@LastName ln
	where		ln.idfsHumanGender = case when cast(cast(nId.strRowGuid as float)*2 as int) < 1 then 10043001 /*Female*/ else 10043002 /*Male*/ end
			) itemsCountLN
left join	(
	select
				ln.LastName, ln.idfsHumanGender, row_number () over (partition by ln.idfsHumanGender order by newid()) as rn
	from		@LastName ln
			) itemLN
on			itemLN.idfsHumanGender = case when cast(cast(nId.strRowGuid as float)*2 as int) < 1 then 10043001 /*Female*/ else 10043002 /*Male*/ end
			and itemLN.rn = cast((cast(nId.strRowGuid as float)*itemsCountLN.intCount+1) as int)
left join	tlbPerson p
on			p.idfPerson = e.idfEmployee
where		nId.idfTable = 75690000000/*tlbPerson*/
			and nId.idfKey2 = 1/*idfPerson*/
			and p.idfPerson is null
print		'Add missing users of sites who will register new cases (tlbPerson) - insert: ' + cast(@@rowcount as varchar(20))

DECLARE @strPassword		VARCHAR(500) = 'EIDss 2023$',
		@strPasswordHash	nvarchar(MAX) = 'AQAAAAEAACcQAAAAEIvm12VITc96N39k6s7XDMYN3Nb63T3uPagwEE/lk+5uh3gz10qlliJV5N97SoAE3w==',
		@strsecurityStamp	NVARCHAR(500) = '6SCD5I2AKVRSE4QVA6JISRSMXQREY45R',
		@idfsLanguage		BIGINT = dbo.FN_GBL_LanguageCode_GET('en-US')

insert into	tstUserTable
(	idfUserID,
	idfPerson,
	idfsSite,
	strAccountName,
	binPassword,
	blnDisabled,
	intRowStatus,
	PreferredLanguageID,
	AuditCreateUser,
	AuditCreateDTM,
	SourceSystemNameID,
	SourceSystemKeyValue
)
select		nId_user.[NewID],
			p.idfPerson,
			s.idfsSite,
			replace(s.strSiteID + N'.' + p.strFamilyName + N'.' + p.strFirstName, N'''', N''''''),
			hashbytes('SHA1', cast(@strPassword as nvarchar(500))),
			0,
			0,
			@idfsLanguage,
			N'system',
			GETDATE(),
			10519001,
			N'[{"idfUserID":' + CAST(nId_user.[NewID] AS NVARCHAR(24)) + '}]'
from		tstNewID nId_person
join		tstSite s
on			s.idfsSite = nId_person.idfKey1
inner join	tlbEmployee e
on			e.idfEmployee = nId_person.[NewID]
inner join	tlbPerson p
on			p.idfPerson = e.idfEmployee
inner join	tstNewID nId_user
on			nId_user.idfTable = 76190000000/*tstUserTable*/
			and nId_user.idfKey1 = s.idfsSite
			and nId_user.idfKey2 = 2/*idfUserID*/
left join	tstUserTable ut
on			ut.idfUserID = nId_user.[NewID]
where		nId_person.idfTable = 75690000000/*tlbPerson*/
			and nId_person.idfKey2 = 1/*idfPerson*/
			and ut.idfUserID is null
print		'Add missing users of sites who will register new cases (tstUserTable) - insert: ' + cast(@@rowcount as varchar(20))

insert into	dbo.AspNetUsers
		(	id, 
			idfUserID,
			EmailConfirmed,
			PasswordHash,
			SecurityStamp,
			TwoFactorEnabled,
			LockoutEnabled,
			AccessFailedCount,
			UserName,
			PhoneNumberConfirmed,
			email,
			NormalizedUsername,
			NormalizedEmail,
			LockoutEnd -- Change from LockoutEndDateUTC and set to NULL below...
		)
select		cast(NEWID() as nvarchar(36)),
			ut.idfUserID,
			0,
			@strPasswordHash,
			@strsecurityStamp,
			1,
			1,
			0,
			ut.strAccountName,
			1,
			ut.strAccountName + N'@dummyemail.com' collate Cyrillic_General_CI_AS,
			UPPER(ut.strAccountName),
			UPPER(ut.strAccountName + N'@dummyemail.com' collate Cyrillic_General_CI_AS),
			NULL
from		tstNewID nId_person
join		tstSite s
on			s.idfsSite = nId_person.idfKey1
inner join	tlbEmployee e
on			e.idfEmployee = nId_person.[NewID]
inner join	tlbPerson p
on			p.idfPerson = e.idfEmployee
inner join	tstNewID nId_user
on			nId_user.idfTable = 76190000000/*tstUserTable*/
			and nId_user.idfKey1 = s.idfsSite
			and nId_user.idfKey2 = 2/*idfUserID*/
inner join	tstUserTable ut
on			ut.idfUserID = nId_user.[NewID]
left join	dbo.AspNetUsers aspU
on			aspU.idfUserID = ut.idfUserID
where		nId_person.idfTable = 75690000000/*tlbPerson*/
			and nId_person.idfKey2 = 1/*idfPerson*/
			and aspU.[Id] is null
print		'Add missing users of sites who will register new cases (AspNetUsers) - insert: ' + cast(@@rowcount as varchar(20))

insert into	dbo.EmployeeToInstitution
(
	EmployeeToInstitution,
	aspNetUserId,
	idfUserId,
	idfInstitution,
	IsDefault,
	Active,
	intRowStatus,
	AuditCreateUser,
	AuditCreateDTM,
	SourceSystemNameID,
	SourceSystemKeyValue
)
select		nId_e_to_i.[NewID],
			aspUser.[Id],
			ut.idfUserID,
			s.idfOffice,
			1,
			1,
			0,
			N'system',
			GETDATE(),
			10519001,
			N'[{"EmployeeToInstitution":' + CAST(nId_e_to_i.[NewID] AS NVARCHAR(24)) + '}]'
from		tstNewID nId_person
join		tstSite s
on			s.idfsSite = nId_person.idfKey1
inner join	tlbEmployee e
on			e.idfEmployee = nId_person.[NewID]
inner join	tlbPerson p
on			p.idfPerson = e.idfEmployee
inner join	tstNewID nId_user
on			nId_user.idfTable = 76190000000/*tstUserTable*/
			and nId_user.idfKey1 = s.idfsSite
			and nId_user.idfKey2 = 2/*idfUserID*/
inner join	tstNewID nId_e_to_i
on			nId_e_to_i.idfTable = 76190000000/*tstUserTable*/
			and nId_e_to_i.idfKey1 = s.idfsSite
			and nId_e_to_i.idfKey2 = 3/*PK of EmployeeToInstitution*/
inner join	tstUserTable ut
on			ut.idfUserID = nId_user.[NewID]
cross apply
(	select top 1 
				aspU.[Id]
	from		dbo.AspNetUsers aspU
	where		aspU.idfUserID = ut.idfUserID
) aspUser
left join	EmployeeToInstitution e_to_i
on			e_to_i.idfUserId = ut.idfUserID
			and e_to_i.aspNetUserId = aspUser.[Id]
			and e_to_i.intRowStatus = 0
left join	EmployeeToInstitution e_to_i_id
on			e_to_i_id.EmployeeToInstitution = nId_e_to_i.[NewID]
where		nId_person.idfTable = 75690000000/*tlbPerson*/
			and nId_person.idfKey2 = 1/*idfPerson*/
			and e_to_i.EmployeeToInstitution is null
			and e_to_i_id.EmployeeToInstitution is null
print		'Add missing users of sites who will register new cases (EmployeeToInstitution) - insert: ' + cast(@@rowcount as varchar(20))



if	@idfEmployeeGroup is not null
begin
	insert into	tlbEmployeeGroupMember
	(	idfEmployee,
		idfEmployeeGroup,
		intRowStatus,
		AuditCreateUser,
		AuditCreateDTM,
		SourceSystemNameID,
		SourceSystemKeyValue
	)
	select		e.idfEmployee,
				@idfEmployeeGroup,
				0,
				N'system',
				GETDATE(),
				10519001,
				N'[{"idfEmployee":' + CAST(e.idfEmployee AS NVARCHAR(24)) + N',"idfEmployeeGroup":' + CAST(@idfEmployeeGroup AS NVARCHAR(24)) + N'}]'
	from		tstNewID nId_person
	join		tstSite s
	on			s.idfsSite = nId_person.idfKey1
	inner join	tlbEmployee e
	on			e.idfEmployee = nId_person.[NewID]
	inner join	tlbPerson p
	on			p.idfPerson = e.idfEmployee
	inner join	tstNewID nId_user
	on			nId_user.idfTable = 76190000000/*tstUserTable*/
				and nId_user.idfKey1 = s.idfsSite
				and nId_user.idfKey2 = 2/*idfUserID*/
	inner join	tstUserTable ut
	on			ut.idfUserID = nId_user.[NewID]
	where		nId_person.idfTable = 75690000000/*tlbPerson*/
				and nId_person.idfKey2 = 1/*idfPerson*/
	print		'Add missing users of sites who will register new cases to the group [' + replace(@EmployeeGroupName, N'''', N'''''') + '] (tlbEmployeeGroupMember) - insert: ' + cast(@@rowcount as varchar(20))
end

delete from tstNewID where idfTable = 75690000000/*tlbPerson*/

update		ghc
set			ghc.idfUserID = nId.[NewID],
			ghc.strUserName = aspUser.[UserName]
from		#GenerateHC ghc
join		tstNewID nId
on			nId.idfTable = 76190000000/*tstUserTable*/
			and nId.idfKey1 = ghc.idfsSite
			and nId.idfKey2 = 2/*idfUserID*/
join	tstUserTable ut
on		ut.idfUserID = nId.[NewID]
		and ut.intRowStatus = 0
join	tlbPerson p
on		p.idfPerson = ut.idfPerson
		and p.intRowStatus = 0
outer apply
(	select top 1
			aspU.[UserName]
	from	AspNetUsers aspU
	join	EmployeeToInstitution e_to_i
	on		e_to_i.idfInstitution = p.idfInstitution
			and e_to_i.aspNetUserId = aspU.[Id]
			and e_to_i.idfUserId = ut.idfUserID
			and e_to_i.intRowStatus = 0
			and e_to_i.IsDefault = 1
			and e_to_i.Active = 1
	where	aspU.idfUserID = ut.idfUserID
) aspUser


delete from tstNewID where idfTable = 76190000000/*tstUserTable*/

print	''

insert into	tstNewID (idfTable, idfKey1)
select		75690000000/*tlbPerson*/,
			o.idfOffice/*idfSentByPerson*/
from		tlbOffice o
where		o.intRowStatus = 0
			and o.idfCustomizationPackage = @CurrentCustomization
			and exists (select 1 from #GenerateHC ghc where ghc.idfSentByOffice = o.idfOffice and ghc.idfSentByPerson is null)


select	@MissingEmployees = count(nId.[NewID])
from	tstNewID nId
where	nId.idfTable = 75690000000/*tlbPerson*/

update		nId
set			nId.strRowGuid = cast(rVal.randValue as nvarchar(36))
from		tstNewID nId
outer apply	(
	select	count(nId_less.[NewID]) as intCount
	from	tstNewID nId_less
	where	nId_less.idfTable = 75690000000/*tlbPerson*/
			and nId_less.[NewID] <= nId.[NewID]
			) nId_num
left join	(
	select	top (@MissingEmployees) employees.randValue, row_number() over (order by newid()) as rn
	from		(	
		select rand(g*1000000 + f*100000 + e*10000 + d*1000 + c*100 + b*10 + a) as randValue
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
		where a*1000000 + b*100000 + c*10000 + d*1000 + e*100 + f*10 + g < @CaseCnt
				) employees
			) rVal
on			rVal.rn = nId_num.intCount
where		nId.idfTable = 75690000000/*tlbPerson*/

insert into	tlbEmployee
(	idfEmployee,
	idfsEmployeeType,
	idfsSite,
	intRowStatus,
	AuditCreateUser,
	AuditCreateDTM,
	SourceSystemNameID,
	SourceSystemKeyValue
)
select		nId.[NewID],
			10023002 /*Person*/,
			@idfsDefaultSite,
			0,
			N'system',
			GETDATE(),
			10519001,
			N'[{"idfEmployee":' + CAST(nId.[NewID] AS NVARCHAR(24)) + '}]'
from		tstNewID nId
join		tlbOffice o
on			o.idfOffice = nId.idfKey1
left join	tlbEmployee e
on			e.idfEmployee = nId.[NewID]
where		nId.idfTable = 75690000000/*tlbPerson*/
			and e.idfEmployee is null
print		'Add missing employees who will send notifications for new cases (tlbEmployee) - insert: ' + cast(@@rowcount as varchar(20))

insert into	tlbPerson
(	idfPerson,
	idfInstitution,
	strFamilyName,
	strFirstName,
	intRowStatus,
	AuditCreateUser,
	AuditCreateDTM,
	SourceSystemNameID,
	SourceSystemKeyValue
)
select		e.idfEmployee,
			o.idfOffice,
			itemLN.LastName,
			itemFN.FirstName,
			0,
			N'system',
			GETDATE(),
			10519001,
			N'[{"idfPerson":' + CAST(e.idfEmployee AS NVARCHAR(24)) + '}]'
from		tstNewID nId
join		tlbOffice o
on			o.idfOffice = nId.idfKey1
inner join	tlbEmployee e
on			e.idfEmployee = nId.[NewID]
outer apply	(
	select
				count(fn.idfID) as intCount
	from		@FirstName fn
	where		fn.idfsHumanGender = case when cast(cast(nId.strRowGuid as float)*2 as int) < 1 then 10043001 /*Female*/ else 10043002 /*Male*/ end
			) itemsCountFN
left join	(
	select
				fn.FirstName, fn.idfsHumanGender, row_number () over (partition by fn.idfsHumanGender order by newid()) as rn
	from		@FirstName fn
			) itemFN
on			itemFN.idfsHumanGender = case when cast(cast(nId.strRowGuid as float)*2 as int) < 1 then 10043001 /*Female*/ else 10043002 /*Male*/ end
			and itemFN.rn = cast((cast(nId.strRowGuid as float)*itemsCountFN.intCount+1) as int)
outer apply	(
	select
				count(ln.idfID) as intCount
	from		@LastName ln
	where		ln.idfsHumanGender = case when cast(cast(nId.strRowGuid as float)*2 as int) < 1 then 10043001 /*Female*/ else 10043002 /*Male*/ end
			) itemsCountLN
left join	(
	select
				ln.LastName, ln.idfsHumanGender, row_number () over (partition by ln.idfsHumanGender order by newid()) as rn
	from		@LastName ln
			) itemLN
on			itemLN.idfsHumanGender = case when cast(cast(nId.strRowGuid as float)*2 as int) < 1 then 10043001 /*Female*/ else 10043002 /*Male*/ end
			and itemLN.rn = cast((cast(nId.strRowGuid as float)*itemsCountLN.intCount+1) as int)
left join	tlbPerson p
on			p.idfPerson = e.idfEmployee
where		nId.idfTable = 75690000000/*tlbPerson*/
			and p.idfPerson is null
print		'Add missing employees who will send notifications for new cases (tlbPerson) - insert: ' + cast(@@rowcount as varchar(20))
print		''


update		ghc
set			ghc.idfSentByPerson = nId.[NewID]
from		#GenerateHC ghc
join		tstNewID nId
on			nId.idfTable = 75690000000/*tlbPerson*/
			and nId.idfKey1 = ghc.idfSentByOffice

delete from tstNewID where idfTable = 75690000000/*tlbPerson*/


exec sp_executesql N'
SET ANSI_NULLS ON
'
exec sp_executesql N'
SET QUOTED_IDENTIFIER ON
'
exec sp_executesql N'
ALTER	function [dbo].[FN_GBL_TriggersWork] ()
returns bit
as
begin
return 1 --0
end
'

-- Create records

-- Cursor by records


-- Execute data save loop - start
declare @spName nvarchar(200)
declare	@idfID bigint
declare	@Start datetime
declare	@CreatePersonExecutionStart datetime
declare	@CreatePersonExecutionEnd datetime
declare	@CreateHDRExecutionStart datetime
declare	@CreateHDRExecutionEnd datetime
declare	@EditHDRSampleExecutionStart datetime
declare	@EditHDRSampleExecutionEnd datetime
declare	@EditHDRTestExecutionStart datetime
declare	@EditHDRTestExecutionEnd datetime
declare	@Splitter nvarchar(100)
declare	@ProcessedRows int
declare	@LogicalReads bigint
declare	@LogicalWrites bigint

declare	@PatientFirstName nvarchar(400),
		@PatientSecondName nvarchar(400),
		@PatientLastName nvarchar(400),
		@DateOfBirth datetime,
		@HumanGenderTypeID bigint,
		@OccupationTypeID bigint,
		@CitizenshipTypeID bigint,
		@PatientLocation bigint,
		@HomePhone nvarchar(200),
		@UserName nvarchar(200),
		@NewHumanActualID bigint,
		@NewEIDSSPersonID nvarchar(200),
		@NewCSObservationID bigint,
		@NewEpiObservationID bigint,
		@CSTemplateID bigint,
		@EpiTemplateID bigint,
		@CSAnswers nvarchar(max),
		@EpiAnswers nvarchar(max),
		@DateOfDeath datetime,
		@NewHDRID bigint,
		@NewHumanID bigint,
		@NewHDRReadableID nvarchar(200),
		@NewHDRPointGLID bigint,
		@idfsFinalDiagnosis bigint,
		@datDateOfDiagnosis datetime,
		@datNotificationDate datetime,
		@idfsFinalState bigint,
		@strLocalIdentifier nvarchar(200),
		@idfSentByOffice bigint,
		@idfSentByPerson bigint,
		@idfsHospitalizationStatus bigint,
		@strHospitalizationPlace nvarchar(200),
		@datOnSetDate datetime,
		@idfsInitialCaseStatus bigint,
		@idfsYNHospitalization bigint,
		@datHospitalizationDate datetime,
		@idfPersonEnteredBy bigint,
		@Events NVARCHAR(MAX),
		@idfsHumanAgeType bigint,
		@intPatientAge int,
		@datCompletionPaperFormDate datetime,
		@idfsSite bigint,
		@idfsFinalCaseStatus bigint,
		@DateofClassification datetime,
		@Samples nvarchar(max),
		@SamplesParameterized nvarchar(max),
		@idfEnteredByUserID bigint

DECLARE record_cursor CURSOR FOR 
SELECT		ghc.idfID, ghc.strPatientFirst, ghc.strPatientSecond, ghc.strPatientLast, ghc.datDateOfBirth, ghc.idfsHumanGender, ghc.idfsOccupationType, ghc.idfsNationality,
			coalesce(ghc.idfsCRSettlement, ghc.idfsCRRayon, ghc.idfsCRRegion, @CurrentCountry), ghc.strPhoneNumber, ghc.strUserName,
			ghc.idfsCSFormTemplate, ghc.idfsEpiFormTemplate, ghc.datDateOfDeath,
			ISNULL(ghc.idfsFinalDiagnosis, ghc.idfsTentativeDiagnosis), isnull(ghc.datFinalDiagnosisDate, ghc.datTentativeDiagnosisDate), ghc.datNotificationDate,
			ghc.idfsFinalState, left(cast(ghc.idfGuid as nvarchar(36)), charindex(N'-', cast(ghc.idfGuid as nvarchar(36)), 0) - 1),
			ghc.idfSentByOffice, ghc.idfSentByPerson, ghc.idfsHospitalizationStatus, ghc.strHospitalizationPlace,
			ghc.datOnsetDate,ghc.idfsInitialCaseStatus, ghc.idfsYNHospitalization, ghc.datHospitalizationDate, ghc.idfPerson,
			N'[{"EventId":-1,"EventTypeId":10025037,"UserId":' + cast(ghc.idfUserID as nvarchar(20)) + N',"SiteId":' + cast(ghc.idfsSite as nvarchar(20)) + N',"LoginSiteId":' + cast(ghc.idfsSite as nvarchar(20)) + 
				N',"ObjectId":0,"DiseaseId":' + cast(ISNULL(ghc.idfsFinalDiagnosis, ghc.idfsTentativeDiagnosis) as nvarchar(20)) + N',"LocationId":' + 
				cast(coalesce(ghc.idfsCRSettlement, ghc.idfsCRRayon, ghc.idfsCRRegion, @CurrentCountry) as nvarchar(20)) + N',"InformationString":null,"LanguageId":null,"User":null}]' collate Cyrillic_General_CI_AS,
			ghc.idfsHumanAgeType, ghc.intPatientAge, ghc.datCompletionPaperFormDate, ghc.idfsSite, ghc.idfsFinalCaseStatus, ghc.datFinalCaseClassificationDate, ghc.idfUserID
from		#GenerateHC ghc
order by	ghc.idfID

OPEN record_cursor  
FETCH NEXT FROM record_cursor INTO @idfID, @PatientFirstName, @PatientSecondName, @PatientLastName, @DateOfBirth, @HumanGenderTypeID, @OccupationTypeID, @CitizenshipTypeID, @PatientLocation, @HomePhone, @UserName,
					@CSTemplateID, @EpiTemplateID, @DateOfDeath, @idfsFinalDiagnosis, @datDateOfDiagnosis, @datNotificationDate, @idfsFinalState, @strLocalIdentifier, @idfSentByOffice,@idfSentByPerson,@idfsHospitalizationStatus, @strHospitalizationPlace,
					@datOnSetDate,@idfsInitialCaseStatus,@idfsYNHospitalization,@datHospitalizationDate, @idfPersonEnteredBy, @Events, @idfsHumanAgeType, @intPatientAge, @datCompletionPaperFormDate, @idfsSite,
					@idfsFinalCaseStatus, @DateofClassification, @idfEnteredByUserID

WHILE @@FETCH_STATUS = 0  
BEGIN  

	-- Clear cache of all execution plans
	----set @cmd = N'CHECKPOINT;'
	----exec sp_executesql @cmd

	----set @cmd = N'DBCC DROPCLEANBUFFERS;'
	----exec sp_executesql @cmd

	set @cmd = N'DBCC FREEPROCCACHE;'
	exec sp_executesql @cmd


	-- Create Person
	set @spName = N'USP_HUM_HUMAN_MASTER_SET_TdeTest'
	
	set @cmd = N'

	set @CreatePersonExecutionStart = getdate()
	exec ' + @spName + N'
		@HumanMasterID=@NewHumanActualID output, 
		@CopyToHumanIndicator=@CopyToHumanIndicator, 
		@PersonalIDType=@PersonalIDType, 
		@EIDSSPersonID=@NewEIDSSPersonID output, 
		@PersonalID=@PersonalID, 
		@FirstName=@FirstName, 
		@SecondName=@SecondName, 
		@LastName=@LastName, 
		@DateOfBirth=@DateOfBirth, 
		@DateOfDeath=@DateOfDeath, 
		@HumanGenderTypeID=@HumanGenderTypeID, 
		@OccupationTypeID=@OccupationTypeID, 
		@CitizenshipTypeID=@CitizenshipTypeID, 
		@PassportNumber=@PassportNumber, 
		@IsEmployedTypeID=@IsEmployedTypeID, 
		@EmployerName=@EmployerName, 
		@EmployedDateLastPresent=@EmployedDateLastPresent, 
		@EmployerForeignAddressIndicator=@EmployerForeignAddressIndicator, 
		@EmployerForeignAddressString=@EmployerForeignAddressString, 
		@EmployerGeoLocationID=@EmployerGeoLocationID, 
		@EmployeridfsLocation=@EmployeridfsLocation, 
		@EmployerstrStreetName=@EmployerstrStreetName, 
		@EmployerstrApartment=@EmployerstrApartment, 
		@EmployerstrBuilding=@EmployerstrBuilding, 
		@EmployerstrHouse=@EmployerstrHouse, 
		@EmployeridfsPostalCode=@EmployeridfsPostalCode, 
		@EmployerPhone=@EmployerPhone, '
	set @cmd = @cmd + N'
		@IsStudentTypeID=@IsStudentTypeID, 
		@SchoolName=@SchoolName, 
		@SchoolDateLastAttended=@SchoolDateLastAttended, 
		@SchoolForeignAddressIndicator=@SchoolForeignAddressIndicator, 
		@SchoolForeignAddressString=@SchoolForeignAddressString, 
		@SchoolGeoLocationID=@SchoolGeoLocationID, 
		@SchoolidfsLocation=@SchoolidfsLocation, 
		@SchoolstrStreetName=@SchoolstrStreetName, 
		@SchoolstrApartment=@SchoolstrApartment, 
		@SchoolstrBuilding=@SchoolstrBuilding, 
		@SchoolstrHouse=@SchoolstrHouse, 
		@SchoolidfsPostalCode=@SchoolidfsPostalCode, 
		@SchoolPhone=@SchoolPhone, 
		@HumanGeoLocationID=@HumanGeoLocationID, 
		@HumanidfsLocation=@HumanidfsLocation, 
		@HumanstrStreetName=@HumanstrStreetName, 
		@HumanstrApartment=@HumanstrApartment, 
		@HumanstrBuilding=@HumanstrBuilding, 
		@HumanstrHouse=@HumanstrHouse, 
		@HumanidfsPostalCode=@HumanidfsPostalCode, 
		@HumanstrLatitude=@HumanstrLatitude, 
		@HumanstrLongitude=@HumanstrLongitude, 
		@HumanstrElevation=@HumanstrElevation, 
		@HumanPermGeoLocationID=@HumanPermGeoLocationID, 
		@HumanPermidfsLocation=@HumanPermidfsLocation, 
		@HumanPermstrStreetName=@HumanPermstrStreetName, 
		@HumanPermstrApartment=@HumanPermstrApartment, 
		@HumanPermstrBuilding=@HumanPermstrBuilding, 
		@HumanPermstrHouse=@HumanPermstrHouse, 
		@HumanPermidfsPostalCode=@HumanPermidfsPostalCode, 
		@HumanAltGeoLocationID=@HumanAltGeoLocationID, 
		@HumanAltForeignAddressIndicator=@HumanAltForeignAddressIndicator, 
		@HumanAltForeignAddressString=@HumanAltForeignAddressString, 
		@HumanAltidfsLocation=@HumanAltidfsLocation, 
		@HumanAltstrStreetName=@HumanAltstrStreetName, 
		@HumanAltstrApartment=@HumanAltstrApartment, 
		@HumanAltstrBuilding=@HumanAltstrBuilding, 
		@HumanAltstrHouse=@HumanAltstrHouse, 
		@HumanAltidfsPostalCode=@HumanAltidfsPostalCode, 
		@RegistrationPhone=@RegistrationPhone, 
		@HomePhone=@HomePhone, 
		@WorkPhone=@WorkPhone, 
		@ContactPhoneCountryCode=@ContactPhoneCountryCode, 
		@ContactPhone=@ContactPhone, 
		@ContactPhoneTypeID=@ContactPhoneTypeID, 
		@ContactPhone2CountryCode=@ContactPhone2CountryCode, 
		@ContactPhone2=@ContactPhone2, 
		@ContactPhone2TypeID=@ContactPhone2TypeID, 
		@idfDataAuditEvent=@idfDataAuditEvent, 
		@AuditUser=@AuditUser

	set @CreatePersonExecutionEnd = getdate()

	'

	set @Start = getdate()
	exec sp_executesql @cmd,
	N'@CopyToHumanIndicator bit,@PersonalIDType bigint,@PersonalID nvarchar(200),@FirstName nvarchar(400),@SecondName nvarchar(400),@LastName nvarchar(400),@DateOfBirth datetime,@DateOfDeath datetime,@HumanGenderTypeID bigint,@OccupationTypeID bigint,@CitizenshipTypeID bigint,@PassportNumber nvarchar(40),@IsEmployedTypeID bigint,@EmployerName nvarchar(400),@EmployedDateLastPresent datetime,@EmployerForeignAddressIndicator bit,@EmployerForeignAddressString nvarchar(400),@EmployerGeoLocationID bigint,@EmployeridfsLocation bigint,@EmployerstrStreetName nvarchar(400),@EmployerstrApartment nvarchar(400),@EmployerstrBuilding nvarchar(400),@EmployerstrHouse nvarchar(400),@EmployeridfsPostalCode nvarchar(400),@EmployerPhone nvarchar(200),@IsStudentTypeID bigint,@SchoolName nvarchar(400),@SchoolDateLastAttended datetime,@SchoolForeignAddressIndicator bit,@SchoolForeignAddressString nvarchar(400),@SchoolGeoLocationID bigint,@SchoolidfsLocation bigint,@SchoolstrStreetName nvarchar(400),@SchoolstrApartment nvarchar(400),@SchoolstrBuilding nvarchar(400),@SchoolstrHouse nvarchar(400),@SchoolidfsPostalCode nvarchar(400),@SchoolPhone nvarchar(200),@HumanGeoLocationID bigint,@HumanidfsLocation bigint,@HumanstrStreetName nvarchar(400),@HumanstrApartment nvarchar(400),@HumanstrBuilding nvarchar(400),@HumanstrHouse nvarchar(400),@HumanidfsPostalCode nvarchar(400),@HumanstrLatitude float,@HumanstrLongitude float,@HumanstrElevation float,@HumanPermGeoLocationID bigint,@HumanPermidfsLocation bigint,@HumanPermstrStreetName nvarchar(400),@HumanPermstrApartment nvarchar(400),@HumanPermstrBuilding nvarchar(400),@HumanPermstrHouse nvarchar(400),@HumanPermidfsPostalCode nvarchar(400),@HumanAltGeoLocationID bigint,@HumanAltForeignAddressIndicator bit,@HumanAltForeignAddressString nvarchar(400),@HumanAltidfsLocation bigint,@HumanAltstrStreetName nvarchar(400),@HumanAltstrApartment nvarchar(400),@HumanAltstrBuilding nvarchar(400),@HumanAltstrHouse nvarchar(400),@HumanAltidfsPostalCode nvarchar(400),@RegistrationPhone nvarchar(400),@HomePhone nvarchar(400),@WorkPhone nvarchar(400),@ContactPhoneCountryCode int,@ContactPhone nvarchar(400),@ContactPhoneTypeID bigint,@ContactPhone2CountryCode int,@ContactPhone2 nvarchar(400),@ContactPhone2TypeID bigint,@idfDataAuditEvent bigint,@AuditUser nvarchar(200),@CreatePersonExecutionStart datetime OUTPUT,@CreatePersonExecutionEnd datetime OUTPUT, @NewHumanActualID bigint OUTPUT,@NewEIDSSPersonID nvarchar(200) OUTPUT',
@CopyToHumanIndicator=0,@PersonalIDType=NULL,@PersonalID=NULL,
@FirstName=@PatientFirstName,@SecondName=@PatientSecondName,@LastName=@PatientLastName,@DateOfBirth=@DateOfBirth,@DateOfDeath=NULL,
@HumanGenderTypeID=@HumanGenderTypeID,@OccupationTypeID=@OccupationTypeID,@CitizenshipTypeID=@CitizenshipTypeID,@PassportNumber=NULL,@IsEmployedTypeID=NULL,@EmployerName=NULL,@EmployedDateLastPresent=NULL,
@EmployerForeignAddressIndicator=NULL,@EmployerForeignAddressString=NULL,@EmployerGeoLocationID=NULL,@EmployeridfsLocation=NULL,@EmployerstrStreetName=NULL,@EmployerstrApartment=NULL,@EmployerstrBuilding=NULL,@EmployerstrHouse=NULL,@EmployeridfsPostalCode=NULL,
@EmployerPhone=NULL,@IsStudentTypeID=NULL,@SchoolName=NULL,@SchoolDateLastAttended=NULL,
@SchoolForeignAddressIndicator=NULL,@SchoolForeignAddressString=NULL,@SchoolGeoLocationID=NULL,@SchoolidfsLocation=NULL,@SchoolstrStreetName=NULL,@SchoolstrApartment=NULL,@SchoolstrBuilding=NULL,@SchoolstrHouse=NULL,@SchoolidfsPostalCode=NULL,@SchoolPhone=NULL,
@HumanGeoLocationID=NULL,@HumanidfsLocation=@PatientLocation,@HumanstrStreetName=NULL,@HumanstrApartment=NULL,@HumanstrBuilding=NULL,@HumanstrHouse=NULL,@HumanidfsPostalCode=NULL,@HumanstrLatitude=NULL,@HumanstrLongitude=NULL,@HumanstrElevation=NULL,
@HumanPermGeoLocationID=NULL,@HumanPermidfsLocation=NULL,@HumanPermstrStreetName=NULL,@HumanPermstrApartment=NULL,@HumanPermstrBuilding=NULL,@HumanPermstrHouse=NULL,@HumanPermidfsPostalCode=NULL,
@HumanAltGeoLocationID=NULL,@HumanAltForeignAddressIndicator=NULL,@HumanAltForeignAddressString=NULL,@HumanAltidfsLocation=NULL,@HumanAltstrStreetName=NULL,@HumanAltstrApartment=NULL,@HumanAltstrBuilding=NULL,@HumanAltstrHouse=NULL,@HumanAltidfsPostalCode=NULL,
@RegistrationPhone=NULL,@HomePhone=@HomePhone,@WorkPhone=NULL,@ContactPhoneCountryCode=NULL,@ContactPhone=NULL,@ContactPhoneTypeID=NULL,@ContactPhone2CountryCode=NULL,@ContactPhone2=NULL,@ContactPhone2TypeID=NULL,
@idfDataAuditEvent=NULL,@AuditUser=@UserName,
@CreatePersonExecutionStart = @CreatePersonExecutionStart output,
@CreatePersonExecutionEnd = @CreatePersonExecutionEnd output,
@NewHumanActualID = @NewHumanActualID output,
@NewEIDSSPersonID = @NewEIDSSPersonID output

		-- Collect statistics of stored procedure execution
		update		ghc
		set			ghc.datCreatePersonExecutionTime = query_stat.last_execution_time,
					ghc.intCreatePersonElapsedTimeMicrosecond = query_stat.last_elapsed_time,
					ghc.fltCreatePersonElapsedTimeMilisecond = query_stat.last_elapsed_time / (1.0*1000),
					ghc.intCreatePersonWorkerTimeMicrosecond = query_stat.last_worker_time,
					ghc.fltCreatePersonWorkerTimeMilisecond = query_stat.last_worker_time / (1.0*1000),
					ghc.intCreatePersonTotalExecutionTimeMiliSecond = datediff(MILLISECOND, @CreatePersonExecutionStart, @CreatePersonExecutionEnd),
					ghc.intCreatePersonProcessedRows = query_stat.last_rows,
					ghc.intCreatePersonLogicalReads = query_stat.last_logical_reads,
					ghc.intCreatePersonLogicalWrites = query_stat.last_logical_writes,
					ghc.idfHumanActual = @NewHumanActualID,
					ghc.EIDSSPersonID = @NewEIDSSPersonID,
					ghc.strCreatePersonQuery = N'

	SET NOCOUNT ON;

	exec ' + replace(@spName, N'_TdeTest', N'') + N'
@HumanMasterID=NULL,@CopyToHumanIndicator=0,@PersonalIDType=NULL,@EIDSSPersonID=NULL,@PersonalID=NULL,
@FirstName=' + isnull(N'N''' + replace(@PatientFirstName, N'''', N'''''') + N'''', N'NULL') + N',
@SecondName=' + isnull(N'N''' + replace(@PatientSecondName, N'''', N'''''') + N'''', N'NULL') + N',
@LastName=' + isnull(N'N''' + replace(@PatientLastName, N'''', N'''''') + N'''', N'NULL') + N',
@DateOfBirth=' + isnull(N'N''' + convert(nvarchar, @DateOfBirth, 120) + N'''', N'NULL') + N',
@DateOfDeath=NULL,
@HumanGenderTypeID=' + isnull(cast(@HumanGenderTypeID as nvarchar(20)), N'NULL') + N',
@OccupationTypeID=' + isnull(cast(@OccupationTypeID as nvarchar(20)), N'NULL') + N',
@CitizenshipTypeID=' + isnull(cast(@CitizenshipTypeID as nvarchar(20)), N'NULL') + N',
@PassportNumber=NULL,@IsEmployedTypeID=NULL,@EmployerName=NULL,@EmployedDateLastPresent=NULL,
@EmployerForeignAddressIndicator=NULL,@EmployerForeignAddressString=NULL,@EmployerGeoLocationID=NULL,@EmployeridfsLocation=NULL,@EmployerstrStreetName=NULL,@EmployerstrApartment=NULL,@EmployerstrBuilding=NULL,@EmployerstrHouse=NULL,@EmployeridfsPostalCode=NULL,
@EmployerPhone=NULL,@IsStudentTypeID=NULL,@SchoolName=NULL,@SchoolDateLastAttended=NULL,
@SchoolForeignAddressIndicator=NULL,@SchoolForeignAddressString=NULL,@SchoolGeoLocationID=NULL,@SchoolidfsLocation=NULL,@SchoolstrStreetName=NULL,@SchoolstrApartment=NULL,@SchoolstrBuilding=NULL,@SchoolstrHouse=NULL,@SchoolidfsPostalCode=NULL,@SchoolPhone=NULL,
@HumanGeoLocationID=NULL,
@HumanidfsLocation=' + isnull(cast(@PatientLocation as nvarchar(20)), N'NULL') + N',
@HumanstrStreetName=NULL,@HumanstrApartment=NULL,@HumanstrBuilding=NULL,@HumanstrHouse=NULL,@HumanidfsPostalCode=NULL,@HumanstrLatitude=NULL,@HumanstrLongitude=NULL,@HumanstrElevation=NULL,
@HumanPermGeoLocationID=NULL,@HumanPermidfsLocation=NULL,@HumanPermstrStreetName=NULL,@HumanPermstrApartment=NULL,@HumanPermstrBuilding=NULL,@HumanPermstrHouse=NULL,@HumanPermidfsPostalCode=NULL,
@HumanAltGeoLocationID=NULL,@HumanAltForeignAddressIndicator=NULL,@HumanAltForeignAddressString=NULL,@HumanAltidfsLocation=NULL,@HumanAltstrStreetName=NULL,@HumanAltstrApartment=NULL,@HumanAltstrBuilding=NULL,@HumanAltstrHouse=NULL,@HumanAltidfsPostalCode=NULL,
@RegistrationPhone=NULL,
@HomePhone=' + isnull(N'N''' + replace(@HomePhone, N'''', N'''''') + N'''', N'NULL') + N',
@WorkPhone=NULL,@ContactPhoneCountryCode=NULL,@ContactPhone=NULL,@ContactPhoneTypeID=NULL,@ContactPhone2CountryCode=NULL,@ContactPhone2=NULL,@ContactPhone2TypeID=NULL,
@idfDataAuditEvent=NULL,
@AuditUser=' + isnull(N'N''' + replace(@UserName, N'''', N'''''') + N'''', N'NULL')
		FROM		#GenerateHC ghc
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
						and qs.creation_time > @Start
		) query_stat
		where		ghc.idfID = @idfID



	set @cmd = N'DBCC FREEPROCCACHE;'
	exec sp_executesql @cmd

	-- Create HDR

	-- Create HCS FF
	set @spName = N'USP_ADMIN_FF_ActivityParameters_SET_TdeTest'
	
	set @CSAnswers = N''
	set @Splitter = N''

	select	@CSAnswers = @CSAnswers + @Splitter + N'{"idfsParameter":' + cast(ff.idfsParameter as nvarchar(20)) + 
							N',"idfsEditor":' + isnull(cast(p.idfsEditor as nvarchar(20)), N'null') + 
							N',"answer":"' + cast(ff.varValue as nvarchar) + 
							N'","idfRow":0}' collate Cyrillic_General_CI_AS,
			@Splitter = N','
	from	#GenerateSpecificFFValue ff
	join	ffParameter p
	on		p.idfsParameter = ff.idfsParameter
	where	ff.idfHCID = @idfID
			and ff.blnHCS = 1

	set	@CSAnswers = N'[' + @CSAnswers + N']' collate Cyrillic_General_CI_AS

	set @cmd = N'

	set @CreateHDRExecutionStart = getdate()
	exec ' + @spName + N'
		@idfObservation=@NewCSObservationID output, 
		@idfsFormTemplate=@idfsFormTemplate, 
		@answers=@answers, 
		@User=@User

	set @CreateHDRExecutionEnd = getdate()

	'

	set @Start = getdate()
	exec sp_executesql @cmd,
	N'@idfsFormTemplate BIGINT,@answers NVARCHAR(MAX),@User NVARCHAR(200),@CreateHDRExecutionStart datetime OUTPUT,@CreateHDRExecutionEnd datetime OUTPUT, @NewCSObservationID bigint OUTPUT',
@idfsFormTemplate=@CSTemplateID,@answers=@CSAnswers,@User=@UserName,
@CreateHDRExecutionStart = @CreateHDRExecutionStart output,
@CreateHDRExecutionEnd = @CreateHDRExecutionEnd output,
@NewCSObservationID = @NewCSObservationID output

		-- Collect statistics of stored procedure execution
		update		ghc
		set			ghc.datCreateHDRExecutionTime = query_stat.last_execution_time,
					ghc.intCreateHDRElapsedTimeMicrosecond = isnull(ghc.intCreateHDRElapsedTimeMicrosecond, 0) + query_stat.last_elapsed_time,
					ghc.fltCreateHDRElapsedTimeMilisecond = isnull(ghc.fltCreateHDRElapsedTimeMilisecond, 0) + query_stat.last_elapsed_time / (1.0*1000),
					ghc.intCreateHDRWorkerTimeMicrosecond = isnull(ghc.intCreateHDRWorkerTimeMicrosecond, 0) + query_stat.last_worker_time,
					ghc.fltCreateHDRWorkerTimeMilisecond = isnull(ghc.fltCreateHDRWorkerTimeMilisecond, 0) + query_stat.last_worker_time / (1.0*1000),
					ghc.intCreateHDRTotalExecutionTimeMiliSecond = isnull(ghc.intCreateHDRTotalExecutionTimeMiliSecond, 0) + datediff(MILLISECOND, @CreateHDRExecutionStart, @CreateHDRExecutionEnd),
					ghc.intCreateHDRProcessedRows = isnull(ghc.intCreateHDRProcessedRows, 0) + query_stat.last_rows,
					ghc.intCreateHDRLogicalReads = isnull(ghc.intCreateHDRLogicalReads, 0) + query_stat.last_logical_reads,
					ghc.intCreateHDRLogicalWrites = isnull(ghc.intCreateHDRLogicalWrites, 0) + query_stat.last_logical_writes,
					ghc.idfCSObservation = @NewCSObservationID,
					ghc.strCreateHDRQuery = isnull(ghc.strCreateHDRQuery + N'
' collate Cyrillic_General_CI_AS, N'') + N'

	SET NOCOUNT ON;

	exec ' + replace(@spName, N'_TdeTest', N'') + N'
@idfObservation=NULL,
@idfsFormTemplate=' + isnull(cast(@CSTemplateID as nvarchar(20)), N'NULL') + N',
@answers=' + isnull(N'N''' + replace(@CSAnswers, N'''', N'''''') + N'''', N'NULL') + N',
@User=' + isnull(N'N''' + replace(@UserName, N'''', N'''''') + N'''', N'NULL') collate Cyrillic_General_CI_AS
		FROM		#GenerateHC ghc
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
						and qs.creation_time > @Start
		) query_stat
		where		ghc.idfID = @idfID



	set @cmd = N'DBCC FREEPROCCACHE;'
	exec sp_executesql @cmd


	-- Create HEI FF
	set @spName = N'USP_ADMIN_FF_ActivityParameters_SET_TdeTest'
	
	set @EpiAnswers = N''
	set @Splitter = N''

	select	@EpiAnswers = @EpiAnswers + @Splitter + N'{"idfsParameter":' + cast(ff.idfsParameter as nvarchar(20)) + 
							N',"idfsEditor":' + isnull(cast(p.idfsEditor as nvarchar(20)), N'null') + 
							N',"answer":"' + cast(ff.varValue as nvarchar) + 
							N'","idfRow":0}' collate Cyrillic_General_CI_AS,
			@Splitter = N','
	from	#GenerateSpecificFFValue ff
	join	ffParameter p
	on		p.idfsParameter = ff.idfsParameter
	where	ff.idfHCID = @idfID
			and ff.blnHEI = 1

	set	@EpiAnswers = N'[' + @EpiAnswers + N']' collate Cyrillic_General_CI_AS

	set @cmd = N'

	set @CreateHDRExecutionStart = getdate()
	exec ' + @spName + N'
		@idfObservation=@NewEpiObservationID output, 
		@idfsFormTemplate=@idfsFormTemplate, 
		@answers=@answers, 
		@User=@User

	set @CreateHDRExecutionEnd = getdate()

	'

	set @Start = getdate()
	exec sp_executesql @cmd,
	N'@idfsFormTemplate BIGINT,@answers NVARCHAR(MAX),@User NVARCHAR(200),@CreateHDRExecutionStart datetime OUTPUT,@CreateHDRExecutionEnd datetime OUTPUT, @NewEpiObservationID bigint OUTPUT',
@idfsFormTemplate=@EpiTemplateID,@answers=@EpiAnswers,@User=@UserName,
@CreateHDRExecutionStart = @CreateHDRExecutionStart output,
@CreateHDRExecutionEnd = @CreateHDRExecutionEnd output,
@NewEpiObservationID = @NewEpiObservationID output

		-- Collect statistics of stored procedure execution
		update		ghc
		set			ghc.datCreateHDRExecutionTime = query_stat.last_execution_time,
					ghc.intCreateHDRElapsedTimeMicrosecond = isnull(ghc.intCreateHDRElapsedTimeMicrosecond, 0) + query_stat.last_elapsed_time,
					ghc.fltCreateHDRElapsedTimeMilisecond = isnull(ghc.fltCreateHDRElapsedTimeMilisecond, 0) + query_stat.last_elapsed_time / (1.0*1000),
					ghc.intCreateHDRWorkerTimeMicrosecond = isnull(ghc.intCreateHDRWorkerTimeMicrosecond, 0) + query_stat.last_worker_time,
					ghc.fltCreateHDRWorkerTimeMilisecond = isnull(ghc.fltCreateHDRWorkerTimeMilisecond, 0) + query_stat.last_worker_time / (1.0*1000),
					ghc.intCreateHDRTotalExecutionTimeMiliSecond = isnull(ghc.intCreateHDRTotalExecutionTimeMiliSecond, 0) + datediff(MILLISECOND, @CreateHDRExecutionStart, @CreateHDRExecutionEnd),
					ghc.intCreateHDRProcessedRows = isnull(ghc.intCreateHDRProcessedRows, 0) + query_stat.last_rows,
					ghc.intCreateHDRLogicalReads = isnull(ghc.intCreateHDRLogicalReads, 0) + query_stat.last_logical_reads,
					ghc.intCreateHDRLogicalWrites = isnull(ghc.intCreateHDRLogicalWrites, 0) + query_stat.last_logical_writes,
					ghc.idfEpiObservation = @NewEpiObservationID,
					ghc.strCreateHDRQuery = isnull(ghc.strCreateHDRQuery + N'
' collate Cyrillic_General_CI_AS, N'') + N'
	exec ' + replace(@spName, N'_TdeTest', N'') + N'
@idfObservation=NULL,
@idfsFormTemplate=' + isnull(cast(@EpiTemplateID as nvarchar(20)), N'NULL') + N',
@answers=' + isnull(N'N''' + replace(@EpiAnswers, N'''', N'''''') + N'''', N'NULL') + N',
@User=' + isnull(N'N''' + replace(@UserName, N'''', N'''''') + N'''', N'NULL') collate Cyrillic_General_CI_AS
		FROM		#GenerateHC ghc
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
						and qs.creation_time > @Start
		) query_stat
		where		ghc.idfID = @idfID



	set @cmd = N'DBCC FREEPROCCACHE;'
	exec sp_executesql @cmd


	-- Update Date of Birth in Patient prior to HDR creation
	set @spName = N''

	set @cmd = N'
	SET NOCOUNT ON;  

	if object_id(N''tempdb..#tmpHumanActualResults'') is null
	create table #tmpHumanActualResults
    (	idfHumanActual bigint not null primary key,
		DatDateOfBirth datetime null,
		datDateOfDeath datetime null,
		strPersonID nvarchar(200) collate Cyrillic_General_CI_AS null
	)
	truncate table #tmpHumanActualResults

	set @CreateHDRExecutionStart = getdate()
	insert into	#tmpHumanActualResults (idfHumanActual, datDateOfBirth, datDateOfDeath, strPersonID)
	select TOP(1) 
			[t].[idfHumanActual], [t].[datDateOfBirth], [t].[datDateOfDeath], [t].[strPersonID]
	FROM [tlbHumanActual] AS [t]
	WHERE [t].[idfHumanActual] = @idfHumanActual

	set @ProcessedRows = @@rowcount

	UPDATE [tlbHumanActual] 
	SET [datDateOfBirth] = @DateOfBirth, 
		[datDateOfDeath] = @DateOfDeath
	WHERE [idfHumanActual] = @idfHumanActual

	set @LogicalWrites = @@rowcount

	set @CreateHDRExecutionEnd = getdate()

	set	@LogicalReads = @ProcessedRows
	set	@ProcessedRows = @ProcessedRows + @LogicalWrites
	'

	exec sp_executesql @cmd,
	N'@idfHumanActual BIGINT, @DateOfBirth datetime, @DateOfDeath datetime,@CreateHDRExecutionStart datetime OUTPUT,@CreateHDRExecutionEnd datetime OUTPUT, @ProcessedRows int OUTPUT, @LogicalReads int OUTPUT, @LogicalWrites int OUTPUT',
@idfHumanActual = @NewHumanActualID,@DateOfBirth = @DateOfBirth,@DateOfDeath = @DateOfDeath,
@CreateHDRExecutionStart = @CreateHDRExecutionStart output,
@CreateHDRExecutionEnd = @CreateHDRExecutionEnd output,
@ProcessedRows = @ProcessedRows output, @LogicalReads = @LogicalReads output, @LogicalWrites = @LogicalWrites output

		-- Collect statistics of stored procedure execution
		update		ghc
		set			ghc.datCreateHDRExecutionTime = @CreateHDRExecutionEnd,
					ghc.intCreateHDRTotalExecutionTimeMiliSecond = isnull(ghc.intCreateHDRTotalExecutionTimeMiliSecond, 0) + datediff(MILLISECOND, @CreateHDRExecutionStart, @CreateHDRExecutionEnd),
					ghc.intCreateHDRProcessedRows = isnull(ghc.intCreateHDRProcessedRows, 0) + isnull(@ProcessedRows, 0),
					ghc.intCreateHDRLogicalReads = isnull(ghc.intCreateHDRLogicalReads, 0) + isnull(@LogicalReads, 0),
					ghc.intCreateHDRLogicalWrites = isnull(ghc.intCreateHDRLogicalWrites, 0) + isnull(@LogicalWrites, 0),
					ghc.strCreateHDRQuery = isnull(ghc.strCreateHDRQuery + N'
' collate Cyrillic_General_CI_AS, N'') + N'
	select TOP(1) 
			[t].[idfHumanActual], [t].[datDateOfBirth], [t].[datDateOfDeath], [t].[strPersonID]
	FROM [tlbHumanActual] AS [t]
	WHERE [t].[idfHumanActual] = ' + isnull(cast(@NewHumanActualID as nvarchar(20)), N'NULL') + N'

	UPDATE [tlbHumanActual] 
	SET [datDateOfBirth] = ' + isnull(N'N''' + convert(nvarchar, @DateOfBirth, 120) + N'''', N'NULL') + N', 
		[datDateOfDeath] = ' + isnull(N'N''' + convert(nvarchar, @DateOfDeath, 120) + N'''', N'NULL') + N'
	WHERE [idfHumanActual] = ' + isnull(cast(@NewHumanActualID as nvarchar(20)), N'NULL') collate Cyrillic_General_CI_AS
		FROM		#GenerateHC ghc
		where		ghc.idfID = @idfID



	set @cmd = N'DBCC FREEPROCCACHE;'
	exec sp_executesql @cmd


	-- Create HDR
	set @spName = N'USP_HUM_HUMAN_DISEASE_SET_TdeTest'

	set @cmd = N'

	set @CreateHDRExecutionStart = getdate()
	exec ' + @spName + N'
		@LanguageID=N''en-US'',
		@idfHumanCase=@NewHDRID output,
		@idfHumanCaseRelatedTo=NULL,
		@idfHuman=@NewHumanID output,
		@idfHumanActual=@idfHumanActual,
		@strHumanCaseId=@NewHDRReadableID output,
		@idfsFinalDiagnosis=@idfsFinalDiagnosis,
		@datDateOfDiagnosis=@datDateOfDiagnosis,
		@datNotificationDate=@datNotificationDate,
		@idfsFinalState=@idfsFinalState,
		@strLocalIdentifier=@strLocalIdentifier,
		@idfSentByOffice=@idfSentByOffice,
		@strSentByFirstName=NULL,
		@strSentByPatronymicName=NULL,
		@strSentByLastName=NULL,
		@idfSentByPerson=@idfSentByPerson,
		@idfReceivedByOffice=NULL,
		@strReceivedByFirstName=NULL,
		@strReceivedByPatronymicName=NULL,
		@strReceivedByLastName=NULL,
		@idfReceivedByPerson=NULL,
		@idfsHospitalizationStatus=@idfsHospitalizationStatus,
		@idfHospital=NULL,
		@strCurrentLocation=NULL,
		@datOnSetDate=@datOnSetDate,
		@idfsInitialCaseStatus=@idfsInitialCaseStatus,
		@idfsYNPreviouslySoughtCare=NULL,
		@datFirstSoughtCareDate=NULL,
		@idfSoughtCareFacility=NULL,
		@idfsNonNotIFiableDiagnosis=NULL,
		@idfsYNHospitalization=@idfsYNHospitalization,
		@datHospitalizationDate=@datHospitalizationDate,
		@datDischargeDate=NULL,
		@strHospitalName=@strHospitalName,
		@idfsYNAntimicrobialTherapy=NULL,
		@strAntibioticName=NULL,
		@strDosage=NULL,
		@datFirstAdministeredDate=NULL,
		@strAntibioticComments=NULL,
		@idfsYNSpecIFicVaccinationAdministered=NULL,
		@idfInvestigatedByOffice=NULL,
		@StartDateofInvestigation=NULL,
		@idfsYNRelatedToOutbreak=NULL,
		@idfOutbreak=NULL,
		@idfsYNExposureLocationKnown=NULL,
		@idfPointGeoLocation=@NewHDRPointGLID output,
		@datExposureDate=NULL,
		@idfsGeoLocationType=NULL,
		@strLocationDescription=NULL,
		@idfsLocationCountry=NULL,
		@idfsLocationRegion=NULL,
		@idfsLocationRayon=NULL,
		@idfsLocationSettlement=NULL,
		@intLocationLatitude=NULL,
		@intLocationLongitude=NULL,
		@intElevation=NULL,
		@idfsLocationGroundType=NULL,
		@intLocationDistance=NULL,
		@intLocationDirection=NULL,
		@strForeignAddress=NULL,
		@strNote=NULL,
		@idfsFinalCaseStatus=NULL,
		@idfsOutcome=NULL,
		@DateOfBirth=@DateOfBirth,
		@datDateofDeath=@DateOfDeath,
		@idfsCaseProgressStatus=10109001,
		@idfPersonEnteredBy=@idfPersonEnteredBy,
		@strClinicalNotes=N'''',
		@idfsYNSpecimenCollected=NULL,
		@idfsYNTestsConducted=NULL,
		@DiseaseReportTypeID=4578940000002,
		@blnClinicalDiagBasis=0,
		@blnLabDiagBasis=0,
		@blnEpiDiagBasis=0,
		@DateofClassification=NULL,
		@strSummaryNotes=NULL,
		@idfEpiObservation=@idfEpiObservation,
		@idfCSObservation=@idfCSObservation,
		@idfInvestigatedByPerson=NULL,
		@strEpidemiologistsName=NULL,
		@idfsNotCollectedReason=NULL,
		@strNotCollectedReason=NULL,
		@SamplesParameters=NULL,
		@TestsParameters=NULL,
		@TestsInterpretationParameters=NULL,
		@AntiviralTherapiesParameters=NULL,
		@VaccinationsParameters=NULL,
		@ContactsParameters=N''[]'',
		@Events=@Events,
		@idfsHumanAgeType=@idfsHumanAgeType,
		@intPatientAge=@intPatientAge,
		@datCompletionPaperFormDate=@datCompletionPaperFormDate,
		@RowStatus=0,
		@idfsSite=@idfsSite,
		@AuditUser=@AuditUser,
		@idfParentMonitoringSession=NULL,
		@ConnectedTestId=NULL

	set @CreateHDRExecutionEnd = getdate()

	'

	set @Start = getdate()
	exec sp_executesql @cmd,
	N'@idfHumanActual BIGINT, @idfsFinalDiagnosis BIGINT, @datDateOfDiagnosis DATETIME,                  
@datNotificationDate DATETIME,@idfsFinalState BIGINT,@strLocalIdentifier NVARCHAR(200),@idfSentByOffice BIGINT,@idfSentByPerson BIGINT,
@idfsHospitalizationStatus BIGINT,@datOnSetDate DATETIME,@idfsInitialCaseStatus BIGINT,@idfsYNHospitalization BIGINT,@datHospitalizationDate DATETIME,@strHospitalName NVARCHAR(200),
@DateOfBirth DATETIME,@DateofDeath DATETIME,@idfPersonEnteredBy BIGINT,
@idfEpiObservation BIGINT,@idfCSObservation BIGINT,
@Events NVARCHAR(MAX),@idfsHumanAgeType BIGINT,@intPatientAge INT,@datCompletionPaperFormDate DATETIME,@idfsSite BIGINT,@AuditUser NVARCHAR(100),
@CreateHDRExecutionStart datetime OUTPUT,@CreateHDRExecutionEnd datetime OUTPUT, @NewHDRID bigint OUTPUT, @NewHumanID bigint OUTPUT, @NewHDRReadableID nvarchar(200) output, @NewHDRPointGLID bigint output',
@idfHumanActual=@NewHumanActualID,@idfsFinalDiagnosis=@idfsFinalDiagnosis,@datDateOfDiagnosis=@datDateOfDiagnosis,@datNotificationDate=@datNotificationDate,
@idfsFinalState=@idfsFinalState,@strLocalIdentifier=@strLocalIdentifier,@idfSentByOffice=@idfSentByOffice,@idfSentByPerson=@idfSentByPerson,@idfsHospitalizationStatus=@idfsHospitalizationStatus,
@datOnSetDate=@datOnSetDate,@idfsInitialCaseStatus=@idfsInitialCaseStatus,@idfsYNHospitalization=@idfsYNHospitalization,@datHospitalizationDate=@datHospitalizationDate,@strHospitalName=@strHospitalizationPlace,
@DateOfBirth=@DateOfBirth,@DateOfDeath=@DateOfDeath,@idfPersonEnteredBy=@idfPersonEnteredBy,@idfEpiObservation=@NewEpiObservationID,@idfCSObservation=@NewCSObservationID,
@Events=@Events,@idfsHumanAgeType=@idfsHumanAgeType,@intPatientAge=@intPatientAge,@datCompletionPaperFormDate=@datCompletionPaperFormDate,@idfsSite=@idfsSite,
@AuditUser=@UserName,
@CreateHDRExecutionStart = @CreateHDRExecutionStart output,
@CreateHDRExecutionEnd = @CreateHDRExecutionEnd output,
@NewHDRID = @NewHDRID output,
@NewHumanID = @NewHumanID output,
@NewHDRReadableID = @NewHDRReadableID output,
@NewHDRPointGLID = @NewHDRPointGLID output

		-- Collect statistics of stored procedure execution
		update		ghc
		set			ghc.datCreateHDRExecutionTime = query_stat.last_execution_time,
					ghc.intCreateHDRElapsedTimeMicrosecond = isnull(ghc.intCreateHDRElapsedTimeMicrosecond, 0) + query_stat.last_elapsed_time,
					ghc.fltCreateHDRElapsedTimeMilisecond = isnull(ghc.fltCreateHDRElapsedTimeMilisecond, 0) + query_stat.last_elapsed_time / (1.0*1000),
					ghc.intCreateHDRWorkerTimeMicrosecond = isnull(ghc.intCreateHDRWorkerTimeMicrosecond, 0) + query_stat.last_worker_time,
					ghc.fltCreateHDRWorkerTimeMilisecond = isnull(ghc.fltCreateHDRWorkerTimeMilisecond, 0) + query_stat.last_worker_time / (1.0*1000),
					ghc.intCreateHDRTotalExecutionTimeMiliSecond = isnull(ghc.intCreateHDRTotalExecutionTimeMiliSecond, 0) + datediff(MILLISECOND, @CreateHDRExecutionStart, @CreateHDRExecutionEnd),
					ghc.intCreateHDRProcessedRows = isnull(ghc.intCreateHDRProcessedRows, 0) + query_stat.last_rows,
					ghc.intCreateHDRLogicalReads = isnull(ghc.intCreateHDRLogicalReads, 0) + query_stat.last_logical_reads,
					ghc.intCreateHDRLogicalWrites = isnull(ghc.intCreateHDRLogicalWrites, 0) + query_stat.last_logical_writes,
					ghc.idfHumanCase = @NewHDRID,
					ghc.idfHuman = @NewHumanID,
					ghc.strCaseID = @NewHDRReadableID,
					ghc.idfPointGeoLocation = @NewHDRPointGLID,
					ghc.strCreateHDRQuery = isnull(ghc.strCreateHDRQuery + N'
' collate Cyrillic_General_CI_AS, N'') + N'
	declare	@NewHumanActualID bigint
	select	@NewHumanActualID = ha.idfHumanActual
	from	[dbo].[tlbHumanActual] ha
	join	[dbo].[HumanActualAddlInfo] ha_ai
	on		ha_ai.[HumanActualAddlInfoUID] = ha.idfHumanActual
	where	ha.intRowStatus = 0
			and ha_ai.[EIDSSPersonID] = ' + isnull(N'N''' + replace(@NewEIDSSPersonID, N'''', N'''''') + N'''', N'NULL') + N' collate Cyrillic_General_CI_AS

	exec ' + replace(@spName, N'_TdeTest', N'') + N'
		@LanguageID=N''en-US'',
		@idfHumanCase=NULL,
		@idfHumanCaseRelatedTo=NULL,
		@idfHuman=NULL,
		@idfHumanActual=@NewHumanActualID,
		@strHumanCaseId=NULL,
		@idfsFinalDiagnosis=' + isnull(cast(@idfsFinalDiagnosis as nvarchar(20)), N'NULL') + N',
		@datDateOfDiagnosis=' + isnull(N'N''' + convert(nvarchar, @datDateOfDiagnosis, 120) + N'''', N'NULL') + N',
		@datNotificationDate=' + isnull(N'N''' + convert(nvarchar, @datNotificationDate, 120) + N'''', N'NULL') + N',
		@idfsFinalState=' + isnull(cast(@idfsFinalState as nvarchar(20)), N'NULL') + N',
		@strLocalIdentifier=' + isnull(N'N''' + replace(@strLocalIdentifier, N'''', N'''''') + N'''', N'NULL') + N',
		@idfSentByOffice=' + isnull(cast(@idfSentByOffice as nvarchar(20)), N'NULL') + N',
		@strSentByFirstName=NULL,
		@strSentByPatronymicName=NULL,
		@strSentByLastName=NULL,
		@idfSentByPerson=' + isnull(cast(@idfSentByPerson as nvarchar(20)), N'NULL') + N',
		@idfReceivedByOffice=NULL,
		@strReceivedByFirstName=NULL,
		@strReceivedByPatronymicName=NULL,
		@strReceivedByLastName=NULL,
		@idfReceivedByPerson=NULL,
		@idfsHospitalizationStatus=' + isnull(cast(@idfsHospitalizationStatus as nvarchar(20)), N'NULL') + N',
		@idfHospital=NULL,
		@strCurrentLocation=NULL,
		@datOnSetDate=' + isnull(N'N''' + convert(nvarchar, @datOnSetDate, 120) + N'''', N'NULL') + N',
		@idfsInitialCaseStatus=' + isnull(cast(@idfsInitialCaseStatus as nvarchar(20)), N'NULL') + N',
		@idfsYNPreviouslySoughtCare=NULL,
		@datFirstSoughtCareDate=NULL,
		@idfSoughtCareFacility=NULL,
		@idfsNonNotIFiableDiagnosis=NULL,
		@idfsYNHospitalization=' + isnull(cast(@idfsYNHospitalization as nvarchar(20)), N'NULL') + N',
		@datHospitalizationDate=' + isnull(N'N''' + convert(nvarchar, @datHospitalizationDate, 120) + N'''', N'NULL') + N',
		@datDischargeDate=NULL,
		@strHospitalName=' + isnull(N'N''' + replace(@strHospitalizationPlace, N'''', N'''''') + N'''', N'NULL') + N',
		@idfsYNAntimicrobialTherapy=NULL,
		@strAntibioticName=NULL,
		@strDosage=NULL,
		@datFirstAdministeredDate=NULL,
		@strAntibioticComments=NULL,
		@idfsYNSpecIFicVaccinationAdministered=NULL,
		@idfInvestigatedByOffice=NULL,
		@StartDateofInvestigation=NULL,
		@idfsYNRelatedToOutbreak=NULL,
		@idfOutbreak=NULL,
		@idfsYNExposureLocationKnown=NULL,
		@idfPointGeoLocation=NULL,
		@datExposureDate=NULL,
		@idfsGeoLocationType=NULL,
		@strLocationDescription=NULL,
		@idfsLocationCountry=NULL,
		@idfsLocationRegion=NULL,
		@idfsLocationRayon=NULL,
		@idfsLocationSettlement=NULL,
		@intLocationLatitude=NULL,
		@intLocationLongitude=NULL,
		@intElevation=NULL,
		@idfsLocationGroundType=NULL,
		@intLocationDistance=NULL,
		@intLocationDirection=NULL,
		@strForeignAddress=NULL,
		@strNote=NULL,
		@idfsFinalCaseStatus=NULL,
		@idfsOutcome=NULL,
		@DateOfBirth=' + isnull(N'N''' + convert(nvarchar, @DateOfBirth, 120) + N'''', N'NULL') + N',
		@datDateofDeath=' + isnull(N'N''' + convert(nvarchar, @DateOfDeath, 120) + N'''', N'NULL') + N',
		@idfsCaseProgressStatus=10109001,
		@idfPersonEnteredBy=' + isnull(cast(@idfPersonEnteredBy as nvarchar(20)), N'NULL') + N',
		@strClinicalNotes=N'',
		@idfsYNSpecimenCollected=NULL,
		@idfsYNTestsConducted=NULL,
		@DiseaseReportTypeID=4578940000002,
		@blnClinicalDiagBasis=0,
		@blnLabDiagBasis=0,
		@blnEpiDiagBasis=0,
		@DateofClassification=NULL,
		@strSummaryNotes=NULL,
		@idfEpiObservation=' + isnull(cast(@NewEpiObservationID as nvarchar(20)), N'NULL') + N',
		@idfCSObservation=' + isnull(cast(@NewCSObservationID as nvarchar(20)), N'NULL') + N',
		@idfInvestigatedByPerson=NULL,
		@strEpidemiologistsName=NULL,
		@idfsNotCollectedReason=NULL,
		@strNotCollectedReason=NULL,
		@SamplesParameters=NULL,
		@TestsParameters=NULL,
		@TestsInterpretationParameters=NULL,
		@AntiviralTherapiesParameters=NULL,
		@VaccinationsParameters=NULL,
		@ContactsParameters=N''[]'',
		@Events=' + isnull(N'N''' + replace(@Events, N'''', N'''''') + N'''', N'NULL') + N',
		@idfsHumanAgeType=' + isnull(cast(@idfsHumanAgeType as nvarchar(20)), N'NULL') + N',
		@intPatientAge=' + isnull(cast(@intPatientAge as nvarchar(20)), N'NULL') + N',
		@datCompletionPaperFormDate=' + isnull(N'N''' + convert(nvarchar, @datCompletionPaperFormDate, 120) + N'''', N'NULL') + N',
		@RowStatus=0,
		@idfsSite=' + isnull(cast(@idfsSite as nvarchar(20)), N'NULL') + N',
		@AuditUser=' + isnull(N'N''' + convert(nvarchar, @UserName, 120) + N'''', N'NULL') + N',
		@idfParentMonitoringSession=NULL,
		@ConnectedTestId=NULL' collate Cyrillic_General_CI_AS
		FROM		#GenerateHC ghc
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
						and qs.creation_time > @Start
		) query_stat
		where		ghc.idfID = @idfID



	-- Edit HDR: Samples Collected, Samples List (new records), Case Classification, Date of Case Classification, Basis of Diagnosis

	-- Update HCS FF
	set @spName = N'USP_ADMIN_FF_ActivityParameters_SET_TdeTest'
	
	set @CSAnswers = N''
	set @Splitter = N''

	select	@CSAnswers = @CSAnswers + @Splitter + N'{"idfsParameter":' + cast(ff.idfsParameter as nvarchar(20)) + 
							N',"idfsEditor":' + isnull(cast(p.idfsEditor as nvarchar(20)), N'null') + 
							N',"answer":"' + cast(ff.varValue as nvarchar) + 
							N'","idfRow":0}' collate Cyrillic_General_CI_AS,
			@Splitter = N','
	from	#GenerateSpecificFFValue ff
	join	ffParameter p
	on		p.idfsParameter = ff.idfsParameter
	where	ff.idfHCID = @idfID
			and ff.blnHCS = 1

	set	@CSAnswers = N'[' + @CSAnswers + N']' collate Cyrillic_General_CI_AS

	set @cmd = N'

	set @EditHDRSampleExecutionStart = getdate()
	exec ' + @spName + N'
		@idfObservation=@idfObservation, 
		@idfsFormTemplate=@idfsFormTemplate, 
		@answers=@answers, 
		@User=@User

	set @EditHDRSampleExecutionEnd = getdate()

	'

	set @Start = getdate()
	exec sp_executesql @cmd,
	N'@idfObservation bigint,@idfsFormTemplate BIGINT,@answers NVARCHAR(MAX),@User NVARCHAR(200),@EditHDRSampleExecutionStart datetime OUTPUT,@EditHDRSampleExecutionEnd datetime OUTPUT',
@idfsFormTemplate=@CSTemplateID,@answers=@CSAnswers,@User=@UserName,
@EditHDRSampleExecutionStart = @EditHDRSampleExecutionStart output,
@EditHDRSampleExecutionEnd = @EditHDRSampleExecutionEnd output,
@idfObservation = @NewCSObservationID

		-- Collect statistics of stored procedure execution
		update		ghc
		set			ghc.datEditHDRSampleExecutionTime = query_stat.last_execution_time,
					ghc.intEditHDRSampleElapsedTimeMicrosecond = isnull(ghc.intEditHDRSampleElapsedTimeMicrosecond, 0) + query_stat.last_elapsed_time,
					ghc.fltEditHDRSampleElapsedTimeMilisecond = isnull(ghc.fltEditHDRSampleElapsedTimeMilisecond, 0) + query_stat.last_elapsed_time / (1.0*1000),
					ghc.intEditHDRSampleWorkerTimeMicrosecond = isnull(ghc.intEditHDRSampleWorkerTimeMicrosecond, 0) + query_stat.last_worker_time,
					ghc.fltEditHDRSampleWorkerTimeMilisecond = isnull(ghc.fltEditHDRSampleWorkerTimeMilisecond, 0) + query_stat.last_worker_time / (1.0*1000),
					ghc.intEditHDRSampleTotalExecutionTimeMiliSecond = isnull(ghc.intEditHDRSampleTotalExecutionTimeMiliSecond, 0) + datediff(MILLISECOND, @EditHDRSampleExecutionStart, @EditHDRSampleExecutionEnd),
					ghc.intEditHDRSampleProcessedRows = isnull(ghc.intEditHDRSampleProcessedRows, 0) + query_stat.last_rows,
					ghc.intEditHDRSampleLogicalReads = isnull(ghc.intEditHDRSampleLogicalReads, 0) + query_stat.last_logical_reads,
					ghc.intEditHDRSampleLogicalWrites = isnull(ghc.intEditHDRSampleLogicalWrites, 0) + query_stat.last_logical_writes,
					ghc.strEditHDRSampleQuery = isnull(ghc.strEditHDRSampleQuery + N'
' collate Cyrillic_General_CI_AS, N'') + N'

	SET NOCOUNT ON;

	exec ' + replace(@spName, N'_TdeTest', N'') + N'
@idfObservation=' + isnull(cast(@NewCSObservationID as nvarchar(20)), N'NULL') + N',
@idfsFormTemplate=' + isnull(cast(@CSTemplateID as nvarchar(20)), N'NULL') + N',
@answers=' + isnull(N'N''' + replace(@CSAnswers, N'''', N'''''') + N'''', N'NULL') + N',
@User=' + isnull(N'N''' + replace(@UserName, N'''', N'''''') + N'''', N'NULL') collate Cyrillic_General_CI_AS
		FROM		#GenerateHC ghc
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
						and qs.creation_time > @Start
		) query_stat
		where		ghc.idfID = @idfID



	set @cmd = N'DBCC FREEPROCCACHE;'
	exec sp_executesql @cmd


	-- Update HEI FF
	set @spName = N'USP_ADMIN_FF_ActivityParameters_SET_TdeTest'
	
	set @EpiAnswers = N''
	set @Splitter = N''

	select	@EpiAnswers = @EpiAnswers + @Splitter + N'{"idfsParameter":' + cast(ff.idfsParameter as nvarchar(20)) + 
							N',"idfsEditor":' + isnull(cast(p.idfsEditor as nvarchar(20)), N'null') + 
							N',"answer":"' + cast(ff.varValue as nvarchar) + 
							N'","idfRow":0}' collate Cyrillic_General_CI_AS,
			@Splitter = N','
	from	#GenerateSpecificFFValue ff
	join	ffParameter p
	on		p.idfsParameter = ff.idfsParameter
	where	ff.idfHCID = @idfID
			and ff.blnHEI = 1

	set	@EpiAnswers = N'[' + @EpiAnswers + N']' collate Cyrillic_General_CI_AS

	set @cmd = N'

	set @EditHDRSampleExecutionStart = getdate()
	exec ' + @spName + N'
		@idfObservation=@idfObservation, 
		@idfsFormTemplate=@idfsFormTemplate, 
		@answers=@answers, 
		@User=@User

	set @EditHDRSampleExecutionEnd = getdate()

	'

	set @Start = getdate()
	exec sp_executesql @cmd,
	N'@idfObservation bigint,@idfsFormTemplate BIGINT,@answers NVARCHAR(MAX),@User NVARCHAR(200),@EditHDRSampleExecutionStart datetime OUTPUT,@EditHDRSampleExecutionEnd datetime OUTPUT',
@idfsFormTemplate=@EpiTemplateID,@answers=@EpiAnswers,@User=@UserName,
@EditHDRSampleExecutionStart = @EditHDRSampleExecutionStart output,
@EditHDRSampleExecutionEnd = @EditHDRSampleExecutionEnd output,
@idfObservation = @NewEpiObservationID

		-- Collect statistics of stored procedure execution
		update		ghc
		set			ghc.datEditHDRSampleExecutionTime = query_stat.last_execution_time,
					ghc.intEditHDRSampleElapsedTimeMicrosecond = isnull(ghc.intEditHDRSampleElapsedTimeMicrosecond, 0) + query_stat.last_elapsed_time,
					ghc.fltEditHDRSampleElapsedTimeMilisecond = isnull(ghc.fltEditHDRSampleElapsedTimeMilisecond, 0) + query_stat.last_elapsed_time / (1.0*1000),
					ghc.intEditHDRSampleWorkerTimeMicrosecond = isnull(ghc.intEditHDRSampleWorkerTimeMicrosecond, 0) + query_stat.last_worker_time,
					ghc.fltEditHDRSampleWorkerTimeMilisecond = isnull(ghc.fltEditHDRSampleWorkerTimeMilisecond, 0) + query_stat.last_worker_time / (1.0*1000),
					ghc.intEditHDRSampleTotalExecutionTimeMiliSecond = isnull(ghc.intEditHDRSampleTotalExecutionTimeMiliSecond, 0) + datediff(MILLISECOND, @EditHDRSampleExecutionStart, @EditHDRSampleExecutionEnd),
					ghc.intEditHDRSampleProcessedRows = isnull(ghc.intEditHDRSampleProcessedRows, 0) + query_stat.last_rows,
					ghc.intEditHDRSampleLogicalReads = isnull(ghc.intEditHDRSampleLogicalReads, 0) + query_stat.last_logical_reads,
					ghc.intEditHDRSampleLogicalWrites = isnull(ghc.intEditHDRSampleLogicalWrites, 0) + query_stat.last_logical_writes,
					ghc.strEditHDRSampleQuery = isnull(ghc.strEditHDRSampleQuery + N'
' collate Cyrillic_General_CI_AS, N'') + N'
	exec ' + replace(@spName, N'_TdeTest', N'') + N'
@idfObservation=' + isnull(cast(@NewEpiObservationID as nvarchar(20)), N'NULL') + N',
@idfsFormTemplate=' + isnull(cast(@EpiTemplateID as nvarchar(20)), N'NULL') + N',
@answers=' + isnull(N'N''' + replace(@EpiAnswers, N'''', N'''''') + N'''', N'NULL') + N',
@User=' + isnull(N'N''' + replace(@UserName, N'''', N'''''') + N'''', N'NULL') collate Cyrillic_General_CI_AS
		FROM		#GenerateHC ghc
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
						and qs.creation_time > @Start
		) query_stat
		where		ghc.idfID = @idfID



	set @cmd = N'DBCC FREEPROCCACHE;'
	exec sp_executesql @cmd


	-- Update Date of Birth in Patient prior to HDR creation
	set @spName = N''

	set @cmd = N'
	SET NOCOUNT ON;  

	if object_id(N''tempdb..#tmpHumanActualResults'') is null
	create table #tmpHumanActualResults
    (	idfHumanActual bigint not null primary key,
		DatDateOfBirth datetime null,
		datDateOfDeath datetime null,
		strPersonID nvarchar(200) collate Cyrillic_General_CI_AS null
	)
	truncate table #tmpHumanActualResults

	set @EditHDRSampleExecutionStart = getdate()
	insert into	#tmpHumanActualResults (idfHumanActual, datDateOfBirth, datDateOfDeath, strPersonID)
	select TOP(1) 
			[t].[idfHumanActual], [t].[datDateOfBirth], [t].[datDateOfDeath], [t].[strPersonID]
	FROM [tlbHumanActual] AS [t]
	WHERE [t].[idfHumanActual] = @idfHumanActual

	set @ProcessedRows = @@rowcount

	UPDATE [tlbHumanActual] 
	SET [datDateOfBirth] = @DateOfBirth, 
		[datDateOfDeath] = @DateOfDeath
	WHERE [idfHumanActual] = @idfHumanActual

	set @LogicalWrites = @@rowcount

	set @EditHDRSampleExecutionEnd = getdate()

	set	@LogicalReads = @ProcessedRows
	set	@ProcessedRows = @ProcessedRows + @LogicalWrites
	'

	exec sp_executesql @cmd,
	N'@idfHumanActual BIGINT, @DateOfBirth datetime, @DateOfDeath datetime,@EditHDRSampleExecutionStart datetime OUTPUT,@EditHDRSampleExecutionEnd datetime OUTPUT, @ProcessedRows int OUTPUT, @LogicalReads int OUTPUT, @LogicalWrites int OUTPUT',
@idfHumanActual = @NewHumanActualID,@DateOfBirth = @DateOfBirth,@DateOfDeath = @DateOfDeath,
@EditHDRSampleExecutionStart = @EditHDRSampleExecutionStart output,
@EditHDRSampleExecutionEnd = @EditHDRSampleExecutionEnd output,
@ProcessedRows = @ProcessedRows output, @LogicalReads = @LogicalReads output, @LogicalWrites = @LogicalWrites output

		-- Collect statistics of stored procedure execution
		update		ghc
		set			ghc.datEditHDRSampleExecutionTime = @EditHDRSampleExecutionEnd,
					ghc.intEditHDRSampleTotalExecutionTimeMiliSecond = isnull(ghc.intEditHDRSampleTotalExecutionTimeMiliSecond, 0) + datediff(MILLISECOND, @EditHDRSampleExecutionStart, @EditHDRSampleExecutionEnd),
					ghc.intEditHDRSampleProcessedRows = isnull(ghc.intEditHDRSampleProcessedRows, 0) + isnull(@ProcessedRows, 0),
					ghc.intEditHDRSampleLogicalReads = isnull(ghc.intEditHDRSampleLogicalReads, 0) + isnull(@LogicalReads, 0),
					ghc.intEditHDRSampleLogicalWrites = isnull(ghc.intEditHDRSampleLogicalWrites, 0) + isnull(@LogicalWrites, 0),
					ghc.strEditHDRSampleQuery = isnull(ghc.strEditHDRSampleQuery + N'
' collate Cyrillic_General_CI_AS, N'') + N'
	select TOP(1) 
			[t].[idfHumanActual], [t].[datDateOfBirth], [t].[datDateOfDeath], [t].[strPersonID]
	FROM [tlbHumanActual] AS [t]
	WHERE [t].[idfHumanActual] = ' + isnull(cast(@NewHumanActualID as nvarchar(20)), N'NULL') + N'

	UPDATE [tlbHumanActual] 
	SET [datDateOfBirth] = ' + isnull(N'N''' + convert(nvarchar, @DateOfBirth, 120) + N'''', N'NULL') + N', 
		[datDateOfDeath] = ' + isnull(N'N''' + convert(nvarchar, @DateOfDeath, 120) + N'''', N'NULL') + N'
	WHERE [idfHumanActual] = ' + isnull(cast(@NewHumanActualID as nvarchar(20)), N'NULL') collate Cyrillic_General_CI_AS
		FROM		#GenerateHC ghc
		where		ghc.idfID = @idfID



	set @cmd = N'DBCC FREEPROCCACHE;'
	exec sp_executesql @cmd


	-- Edit HDR
	set @spName = N'USP_HUM_HUMAN_DISEASE_SET_TdeTest'

	set @SamplesParameterized = N''
	set @Splitter = N''

	select	@SamplesParameterized = @SamplesParameterized + @Splitter + 
			N'{"SampleID":' + cast(rn.intRowNumber as nvarchar(20)) + N',"SampleTypeID":' + isnull(cast(hcs.idfsSampleType as nvarchar(20)), N'null') + 
				N',"RootSampleID":null,"ParentSampleID":null,"HumanMasterID":null,"HumanID":{0},"FarmID":null,"FarmMasterID":null,"FarmOwnerID":null,"SpeciesID":null,"AnimalID":null,"VectorID":null,"HumanDiseaseReportID":{1},"VeterinaryDiseaseReportID":null,"MonitoringSessionID":null,"VectorSessionID":null,"SampleStatusTypeID":null,"CollectionDate":' + 
				isnull(N'"' + left(convert(nvarchar, hcs.datFieldCollectionDate, 21), 10) + N'T00:00:00"', N'null') + 
				N',"CollectedByOrganizationID":null,"CollectedByPersonID":null,"SentDate":null,"SentToOrganizationID":' + isnull(cast(hcs.idfSendToOffice as nvarchar(20)), N'null') + 
				N',"EIDSSLocalOrFieldSampleID":"' + isnull(@NewHDRReadableID, N'') + N'-' + RIGHT(N'0' + cast(rn.intRowNumber as nvarchar(20)), 2) + 
				N'","Comments":"","SiteID":' + isnull(cast(hcs.idfsSite as nvarchar(20)), N'null') + N',"CurrentSiteID":null,"EnteredDate":null,"DiseaseID":' + isnull(cast(hcs.idfsDiagnosis as nvarchar(20)), N'null') + 
				N',"BirdStatusTypeID":null,"ReadOnlyIndicator":false,"LabModuleSourceIndicator":0,"RowStatus":0,"RowAction":1}' collate Cyrillic_General_CI_AS,
			@Splitter = N','
	from	#GenerateHCSample hcs
	cross apply
	(	select	COUNT(hcs_rn.idfID) as intRowNumber
		from	#GenerateHCSample hcs_rn
		where	hcs_rn.idfHCID = @idfID
				and hcs_rn.idfID <= hcs.idfID
	) rn
	where	hcs.idfHCID = @idfID


	set	@SamplesParameterized = N'[' + isnull(@SamplesParameterized, N'') + N']' collate Cyrillic_General_CI_AS

	set @Samples = REPLACE(REPLACE(@SamplesParameterized, N'{0}', isnull(cast(@NewHumanID as nvarchar(20)), N'null')), N'{1}', isnull(cast(@NewHDRID as nvarchar(20)), N'null'))

	set	@Events=N'[{"EventId":-1,"EventTypeId":10025041,"UserId":' + isnull(cast(@idfEnteredByUserID as nvarchar(20)), N'null') + N',"SiteId":' + isnull(cast(@idfsSite as nvarchar(20)), N'null') + 
					N',"LoginSiteId":' + isnull(cast(@idfsSite as nvarchar(20)), N'null') + 
					N',"ObjectId":' + isnull(cast(@NewHDRID as nvarchar(20)), N'null') + 
					N',"DiseaseId":' + isnull(cast(@idfsFinalDiagnosis as nvarchar(20)), N'null') + 
					N',"LocationId":' + isnull(cast(@PatientLocation as nvarchar(20)), N'null') + 
					N',"InformationString":null,"LanguageId":null,"User":null}]'

	set @cmd = N'

	set @EditHDRSampleExecutionStart = getdate()
	exec ' + @spName + N'
		@LanguageID=N''en-US'',
		@idfHumanCase=@idfHumanCase,
		@idfHumanCaseRelatedTo=NULL,
		@idfHuman=@idfHuman output,
		@idfHumanActual=@idfHumanActual,
		@strHumanCaseId=@strHumanCaseId,
		@idfsFinalDiagnosis=@idfsFinalDiagnosis,
		@datDateOfDiagnosis=@datDateOfDiagnosis,
		@datNotificationDate=@datNotificationDate,
		@idfsFinalState=@idfsFinalState,
		@strLocalIdentifier=@strLocalIdentifier,
		@idfSentByOffice=@idfSentByOffice,
		@strSentByFirstName=NULL,
		@strSentByPatronymicName=NULL,
		@strSentByLastName=NULL,
		@idfSentByPerson=@idfSentByPerson,
		@idfReceivedByOffice=NULL,
		@strReceivedByFirstName=NULL,
		@strReceivedByPatronymicName=NULL,
		@strReceivedByLastName=NULL,
		@idfReceivedByPerson=NULL,
		@idfsHospitalizationStatus=@idfsHospitalizationStatus,
		@idfHospital=NULL,
		@strCurrentLocation=NULL,
		@datOnSetDate=@datOnSetDate,
		@idfsInitialCaseStatus=@idfsInitialCaseStatus,
		@idfsYNPreviouslySoughtCare=NULL,
		@datFirstSoughtCareDate=NULL,
		@idfSoughtCareFacility=NULL,
		@idfsNonNotIFiableDiagnosis=NULL,
		@idfsYNHospitalization=@idfsYNHospitalization,
		@datHospitalizationDate=@datHospitalizationDate,
		@datDischargeDate=NULL,
		@strHospitalName=@strHospitalName,
		@idfsYNAntimicrobialTherapy=NULL,
		@strAntibioticName=NULL,
		@strDosage=NULL,
		@datFirstAdministeredDate=NULL,
		@strAntibioticComments=NULL,
		@idfsYNSpecIFicVaccinationAdministered=NULL,
		@idfInvestigatedByOffice=NULL,
		@StartDateofInvestigation=NULL,
		@idfsYNRelatedToOutbreak=NULL,
		@idfOutbreak=NULL,
		@idfsYNExposureLocationKnown=NULL,
		@idfPointGeoLocation=@idfPointGeoLocation,
		@datExposureDate=NULL,
		@idfsGeoLocationType=NULL,
		@strLocationDescription=NULL,
		@idfsLocationCountry=NULL,
		@idfsLocationRegion=NULL,
		@idfsLocationRayon=NULL,
		@idfsLocationSettlement=NULL,
		@intLocationLatitude=NULL,
		@intLocationLongitude=NULL,
		@intElevation=NULL,
		@idfsLocationGroundType=NULL,
		@intLocationDistance=NULL,
		@intLocationDirection=NULL,
		@strForeignAddress=NULL,
		@strNote=NULL,
		@idfsFinalCaseStatus=@idfsFinalCaseStatus,
		@idfsOutcome=NULL,
		@DateOfBirth=@DateOfBirth,
		@datDateofDeath=@DateOfDeath,
		@idfsCaseProgressStatus=10109001,
		@idfPersonEnteredBy=@idfPersonEnteredBy,
		@strClinicalNotes=N'''',
		@idfsYNSpecimenCollected=10100001,
		@idfsYNTestsConducted=NULL,
		@DiseaseReportTypeID=4578940000002,
		@blnClinicalDiagBasis=1,
		@blnLabDiagBasis=1,
		@blnEpiDiagBasis=1,
		@DateofClassification=@DateofClassification,
		@strSummaryNotes=NULL,
		@idfEpiObservation=@idfEpiObservation,
		@idfCSObservation=@idfCSObservation,
		@idfInvestigatedByPerson=NULL,
		@strEpidemiologistsName=NULL,
		@idfsNotCollectedReason=NULL,
		@strNotCollectedReason=NULL,
		@SamplesParameters=@Samples,
		@TestsParameters=NULL,
		@TestsInterpretationParameters=NULL,
		@AntiviralTherapiesParameters=NULL,
		@VaccinationsParameters=NULL,
		@ContactsParameters=N''[]'',
		@Events=@Events,
		@idfsHumanAgeType=@idfsHumanAgeType,
		@intPatientAge=@intPatientAge,
		@datCompletionPaperFormDate=@datCompletionPaperFormDate,
		@RowStatus=0,
		@idfsSite=@idfsSite,
		@AuditUser=@AuditUser,
		@idfParentMonitoringSession=NULL,
		@ConnectedTestId=NULL

	set @EditHDRSampleExecutionEnd = getdate()

	'

	set @Start = getdate()
	exec sp_executesql @cmd,
	N'@idfHumanActual BIGINT, @idfsFinalDiagnosis BIGINT, @datDateOfDiagnosis DATETIME,                  
@datNotificationDate DATETIME,@idfsFinalState BIGINT,@strLocalIdentifier NVARCHAR(200),@idfSentByOffice BIGINT,@idfSentByPerson BIGINT,
@idfsHospitalizationStatus BIGINT,@datOnSetDate DATETIME,@idfsInitialCaseStatus BIGINT,@idfsYNHospitalization BIGINT,@datHospitalizationDate DATETIME,@strHospitalName NVARCHAR(200),
@DateOfBirth DATETIME,@DateofDeath DATETIME,@idfPersonEnteredBy BIGINT,
@idfEpiObservation BIGINT,@idfCSObservation BIGINT,
@Events NVARCHAR(MAX),@idfsHumanAgeType BIGINT,@intPatientAge INT,@datCompletionPaperFormDate DATETIME,@idfsSite BIGINT,@AuditUser NVARCHAR(100),
@idfsFinalCaseStatus bigint, @DateofClassification datetime,@Samples nvarchar(max),
@EditHDRSampleExecutionStart datetime OUTPUT,@EditHDRSampleExecutionEnd datetime OUTPUT, @idfHumanCase bigint, @idfHuman bigint, @strHumanCaseId nvarchar(200), @idfPointGeoLocation bigint',
@idfHumanActual=@NewHumanActualID,@idfsFinalDiagnosis=@idfsFinalDiagnosis,@datDateOfDiagnosis=@datDateOfDiagnosis,@datNotificationDate=@datNotificationDate,
@idfsFinalState=@idfsFinalState,@strLocalIdentifier=@strLocalIdentifier,@idfSentByOffice=@idfSentByOffice,@idfSentByPerson=@idfSentByPerson,@idfsHospitalizationStatus=@idfsHospitalizationStatus,
@datOnSetDate=@datOnSetDate,@idfsInitialCaseStatus=@idfsInitialCaseStatus,@idfsYNHospitalization=@idfsYNHospitalization,@datHospitalizationDate=@datHospitalizationDate,@strHospitalName=@strHospitalizationPlace,
@DateOfBirth=@DateOfBirth,@DateOfDeath=@DateOfDeath,@idfPersonEnteredBy=@idfPersonEnteredBy,@idfEpiObservation=@NewEpiObservationID,@idfCSObservation=@NewCSObservationID,
@Events=@Events,@idfsHumanAgeType=@idfsHumanAgeType,@intPatientAge=@intPatientAge,@datCompletionPaperFormDate=@datCompletionPaperFormDate,@idfsSite=@idfsSite,
@AuditUser=@UserName,
@idfsFinalCaseStatus=@idfsFinalCaseStatus, @DateofClassification=@DateofClassification,@Samples=@Samples,
@EditHDRSampleExecutionStart = @EditHDRSampleExecutionStart output,
@EditHDRSampleExecutionEnd = @EditHDRSampleExecutionEnd output,
@idfHumanCase = @NewHDRID,
@idfHuman = @NewHumanID,
@strHumanCaseId = @NewHDRReadableID,
@idfPointGeoLocation = @NewHDRPointGLID

		-- Collect statistics of stored procedure execution
		update		ghc
		set			ghc.datEditHDRSampleExecutionTime = query_stat.last_execution_time,
					ghc.intEditHDRSampleElapsedTimeMicrosecond = isnull(ghc.intEditHDRSampleElapsedTimeMicrosecond, 0) + query_stat.last_elapsed_time,
					ghc.fltEditHDRSampleElapsedTimeMilisecond = isnull(ghc.fltEditHDRSampleElapsedTimeMilisecond, 0) + query_stat.last_elapsed_time / (1.0*1000),
					ghc.intEditHDRSampleWorkerTimeMicrosecond = isnull(ghc.intEditHDRSampleWorkerTimeMicrosecond, 0) + query_stat.last_worker_time,
					ghc.fltEditHDRSampleWorkerTimeMilisecond = isnull(ghc.fltEditHDRSampleWorkerTimeMilisecond, 0) + query_stat.last_worker_time / (1.0*1000),
					ghc.intEditHDRSampleTotalExecutionTimeMiliSecond = isnull(ghc.intEditHDRSampleTotalExecutionTimeMiliSecond, 0) + datediff(MILLISECOND, @EditHDRSampleExecutionStart, @EditHDRSampleExecutionEnd),
					ghc.intEditHDRSampleProcessedRows = isnull(ghc.intEditHDRSampleProcessedRows, 0) + query_stat.last_rows,
					ghc.intEditHDRSampleLogicalReads = isnull(ghc.intEditHDRSampleLogicalReads, 0) + query_stat.last_logical_reads,
					ghc.intEditHDRSampleLogicalWrites = isnull(ghc.intEditHDRSampleLogicalWrites, 0) + query_stat.last_logical_writes,
					ghc.strEditHDRSampleQuery = isnull(ghc.strEditHDRSampleQuery + N'
' collate Cyrillic_General_CI_AS, N'') + N'
	declare	@NewHumanActualID bigint
	select	@NewHumanActualID = ha.idfHumanActual
	from	[dbo].[tlbHumanActual] ha
	join	[dbo].[HumanActualAddlInfo] ha_ai
	on		ha_ai.[HumanActualAddlInfoUID] = ha.idfHumanActual
	where	ha.intRowStatus = 0
			and ha_ai.[EIDSSPersonID] = ' + isnull(N'N''' + replace(@NewEIDSSPersonID, N'''', N'''''') + N'''', N'NULL') + N' collate Cyrillic_General_CI_AS

	declare	@NewHDRID bigint,
			@NewHumanID bigint,
			@NewHDRPointGLID bigint
	select	@NewHDRID = hc.idfHumanCase,
			@NewHumanID = h.idfHuman,
			@NewHDRPointGLID = hc.idfPointGeoLocation
	from	[dbo].[tlbHumanCase] hc
	join	[dbo].[tlbHuman] h
	on		h.idfHuman = hc.idfHuman
	where	hc.intRowStatus = 0
			and h.idfHumanActual = @NewHumanActualID
			and hc.strCaseID = ' + isnull(N'N''' + replace(@NewHDRReadableID, N'''', N'''''') + N'''', N'NULL') + N' collate Cyrillic_General_CI_AS

	declare	@EventClassificationChanged nvarchar(max)
	set	@EventClassificationChanged =
			N''[{"EventId":-1,"EventTypeId":10025041,"UserId":' + isnull(cast(@idfEnteredByUserID as nvarchar(20)), N'null') + N',"SiteId":' + isnull(cast(@idfsSite as nvarchar(20)), N'null') + 
					N',"LoginSiteId":' + isnull(cast(@idfsSite as nvarchar(20)), N'null') + 
					N',"ObjectId":'' + isnull(cast(@NewHDRID as nvarchar(20)), N''null'') + N''' +
					N',"DiseaseId":' + isnull(cast(@idfsFinalDiagnosis as nvarchar(20)), N'null') + 
					N',"LocationId":' + isnull(cast(@PatientLocation as nvarchar(20)), N'null') + 
					N',"InformationString":null,"LanguageId":null,"User":null}]'' collate Cyrillic_General_CI_AS

	declare @Samples nvarchar(max) = replace(replace(N''' + replace(isnull(@SamplesParameterized, N''), N'''', N'''''''''') + N''', N''{0}'', isnull(cast(@NewHumanID as nvarchar(20)), N''null'')), N''{1}'', isnull(cast(@NewHDRID as nvarchar(20)), N''null''))

	exec ' + replace(@spName, N'_TdeTest', N'') + N'
		@LanguageID=N''en-US'',
		@idfHumanCase=@NewHDRID,
		@idfHumanCaseRelatedTo=NULL,
		@idfHuman=@NewHumanID,
		@idfHumanActual=@NewHumanActualID,
		@strHumanCaseId=NULL,
		@idfsFinalDiagnosis=' + isnull(cast(@idfsFinalDiagnosis as nvarchar(20)), N'NULL') + N',
		@datDateOfDiagnosis=' + isnull(N'N''' + convert(nvarchar, @datDateOfDiagnosis, 120) + N'''', N'NULL') + N',
		@datNotificationDate=' + isnull(N'N''' + convert(nvarchar, @datNotificationDate, 120) + N'''', N'NULL') + N',
		@idfsFinalState=' + isnull(cast(@idfsFinalState as nvarchar(20)), N'NULL') + N',
		@strLocalIdentifier=' + isnull(N'N''' + replace(@strLocalIdentifier, N'''', N'''''') + N'''', N'NULL') + N',
		@idfSentByOffice=' + isnull(cast(@idfSentByOffice as nvarchar(20)), N'NULL') + N',
		@strSentByFirstName=NULL,
		@strSentByPatronymicName=NULL,
		@strSentByLastName=NULL,
		@idfSentByPerson=' + isnull(cast(@idfSentByPerson as nvarchar(20)), N'NULL') + N',
		@idfReceivedByOffice=NULL,
		@strReceivedByFirstName=NULL,
		@strReceivedByPatronymicName=NULL,
		@strReceivedByLastName=NULL,
		@idfReceivedByPerson=NULL,
		@idfsHospitalizationStatus=' + isnull(cast(@idfsHospitalizationStatus as nvarchar(20)), N'NULL') + N',
		@idfHospital=NULL,
		@strCurrentLocation=NULL,
		@datOnSetDate=' + isnull(N'N''' + convert(nvarchar, @datOnSetDate, 120) + N'''', N'NULL') + N',
		@idfsInitialCaseStatus=' + isnull(cast(@idfsInitialCaseStatus as nvarchar(20)), N'NULL') + N',
		@idfsYNPreviouslySoughtCare=NULL,
		@datFirstSoughtCareDate=NULL,
		@idfSoughtCareFacility=NULL,
		@idfsNonNotIFiableDiagnosis=NULL,
		@idfsYNHospitalization=' + isnull(cast(@idfsYNHospitalization as nvarchar(20)), N'NULL') + N',
		@datHospitalizationDate=' + isnull(N'N''' + convert(nvarchar, @datHospitalizationDate, 120) + N'''', N'NULL') + N',
		@datDischargeDate=NULL,
		@strHospitalName=' + isnull(N'N''' + replace(@strHospitalizationPlace, N'''', N'''''') + N'''', N'NULL') + N',
		@idfsYNAntimicrobialTherapy=NULL,
		@strAntibioticName=NULL,
		@strDosage=NULL,
		@datFirstAdministeredDate=NULL,
		@strAntibioticComments=NULL,
		@idfsYNSpecIFicVaccinationAdministered=NULL,
		@idfInvestigatedByOffice=NULL,
		@StartDateofInvestigation=NULL,
		@idfsYNRelatedToOutbreak=NULL,
		@idfOutbreak=NULL,
		@idfsYNExposureLocationKnown=NULL,
		@idfPointGeoLocation=@NewHDRPointGLID,
		@datExposureDate=NULL,
		@idfsGeoLocationType=NULL,
		@strLocationDescription=NULL,
		@idfsLocationCountry=NULL,
		@idfsLocationRegion=NULL,
		@idfsLocationRayon=NULL,
		@idfsLocationSettlement=NULL,
		@intLocationLatitude=NULL,
		@intLocationLongitude=NULL,
		@intElevation=NULL,
		@idfsLocationGroundType=NULL,
		@intLocationDistance=NULL,
		@intLocationDirection=NULL,
		@strForeignAddress=NULL,
		@strNote=NULL,
		@idfsFinalCaseStatus=' + isnull(cast(@idfsFinalCaseStatus as nvarchar(20)), N'NULL') + N',
		@idfsOutcome=NULL,
		@DateOfBirth=' + isnull(N'N''' + convert(nvarchar, @DateOfBirth, 120) + N'''', N'NULL') + N',
		@datDateofDeath=' + isnull(N'N''' + convert(nvarchar, @DateOfDeath, 120) + N'''', N'NULL') + N',
		@idfsCaseProgressStatus=10109001,
		@idfPersonEnteredBy=' + isnull(cast(@idfPersonEnteredBy as nvarchar(20)), N'NULL') + N',
		@strClinicalNotes=N'',
		@idfsYNSpecimenCollected=10100001,
		@idfsYNTestsConducted=NULL,
		@DiseaseReportTypeID=4578940000002,
		@blnClinicalDiagBasis=1,
		@blnLabDiagBasis=1,
		@blnEpiDiagBasis=1,
		@DateofClassification=' + isnull(N'N''' + convert(nvarchar, @DateofClassification, 120) + N'''', N'NULL') + N',
		@strSummaryNotes=NULL,
		@idfEpiObservation=' + isnull(cast(@NewEpiObservationID as nvarchar(20)), N'NULL') + N',
		@idfCSObservation=' + isnull(cast(@NewCSObservationID as nvarchar(20)), N'NULL') + N',
		@idfInvestigatedByPerson=NULL,
		@strEpidemiologistsName=NULL,
		@idfsNotCollectedReason=NULL,
		@strNotCollectedReason=NULL,
		@SamplesParameters=@Samples,
		@TestsParameters=NULL,
		@TestsInterpretationParameters=NULL,
		@AntiviralTherapiesParameters=NULL,
		@VaccinationsParameters=NULL,
		@ContactsParameters=N''[]'',
		@Events=@EventClassificationChanged,
		@idfsHumanAgeType=' + isnull(cast(@idfsHumanAgeType as nvarchar(20)), N'NULL') + N',
		@intPatientAge=' + isnull(cast(@intPatientAge as nvarchar(20)), N'NULL') + N',
		@datCompletionPaperFormDate=' + isnull(N'N''' + convert(nvarchar, @datCompletionPaperFormDate, 120) + N'''', N'NULL') + N',
		@RowStatus=0,
		@idfsSite=' + isnull(cast(@idfsSite as nvarchar(20)), N'NULL') + N',
		@AuditUser=' + isnull(N'N''' + convert(nvarchar, @UserName, 120) + N'''', N'NULL') + N',
		@idfParentMonitoringSession=NULL,
		@ConnectedTestId=NULL' collate Cyrillic_General_CI_AS
		FROM		#GenerateHC ghc
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
						and qs.creation_time > @Start
		) query_stat
		where		ghc.idfID = @idfID


		FETCH NEXT FROM record_cursor INTO @idfID, @PatientFirstName, @PatientSecondName, @PatientLastName, @DateOfBirth, @HumanGenderTypeID, @OccupationTypeID, @CitizenshipTypeID, @PatientLocation, @HomePhone, @UserName,
					@CSTemplateID, @EpiTemplateID, @DateOfDeath, @idfsFinalDiagnosis, @datDateOfDiagnosis, @datNotificationDate, @idfsFinalState, @strLocalIdentifier, @idfSentByOffice,@idfSentByPerson,@idfsHospitalizationStatus,@strHospitalizationPlace,
					@datOnSetDate,@idfsInitialCaseStatus,@idfsYNHospitalization,@datHospitalizationDate, @idfPersonEnteredBy, @Events, @idfsHumanAgeType, @intPatientAge, @datCompletionPaperFormDate, @idfsSite,
					@idfsFinalCaseStatus, @DateofClassification, @idfEnteredByUserID
END 

CLOSE record_cursor  
DEALLOCATE record_cursor



select		ROW_NUMBER() OVER (ORDER BY ghc.idfID) as N'Run #',
			convert(nvarchar, ghc.datCreatePersonExecutionTime, 101) + N' ' + convert(nvarchar, ghc.datCreatePersonExecutionTime, 114) as N'Create Person Completion Time',
			ghc.intCreatePersonTotalExecutionTimeMiliSecond as N'Create Person Execution Time (Miliseconds)',
			ghc.intCreatePersonElapsedTimeMicrosecond as N'Create Person Elapsed Time (Microseconds)',
			ghc.fltCreatePersonElapsedTimeMilisecond as N'Create Person Elapsed Time (Miliseconds)',
			ghc.intCreatePersonWorkerTimeMicrosecond as N'Create Person Work Time (Microseconds)',
			ghc.fltCreatePersonWorkerTimeMilisecond as N'Create Person Work Time (Miliseconds)',
			ghc.intCreatePersonProcessedRows as N'Create Person Processed Rows',
			ghc.intCreatePersonLogicalReads as N'Create Person Logical Reads',
			ghc.intCreatePersonLogicalWrites as N'Create Person Logical Writes',
			convert(nvarchar, ghc.datCreateHDRExecutionTime, 101) + N' ' + convert(nvarchar, ghc.datCreateHDRExecutionTime, 114) as N'Create HDR Completion Time',
			ghc.intCreateHDRTotalExecutionTimeMiliSecond as N'Create HDR Execution Time (Miliseconds)',
			ghc.intCreateHDRElapsedTimeMicrosecond as N'Create HDR Elapsed Time (Microseconds)',
			ghc.fltCreateHDRElapsedTimeMilisecond as N'Create HDR Elapsed Time (Miliseconds)',
			ghc.intCreateHDRWorkerTimeMicrosecond as N'Create HDR Work Time (Microseconds)',
			ghc.fltCreateHDRWorkerTimeMilisecond as N'Create HDR Work Time (Miliseconds)',
			ghc.intCreateHDRProcessedRows as N'Create HDR Processed Rows',
			ghc.intCreateHDRLogicalReads as N'Create HDR Logical Reads',
			ghc.intCreateHDRLogicalWrites as N'Create HDR Logical Writes',
			convert(nvarchar, ghc.datEditHDRSampleExecutionTime, 101) + N' ' + convert(nvarchar, ghc.datEditHDRSampleExecutionTime, 114) as N'Create HDR Completion Time',
			ghc.intEditHDRSampleTotalExecutionTimeMiliSecond as N'Edit HDR Execution Time (Miliseconds)',
			ghc.intEditHDRSampleElapsedTimeMicrosecond as N'Edit HDR Elapsed Time (Microseconds)',
			ghc.fltEditHDRSampleElapsedTimeMilisecond as N'Edit HDR Elapsed Time (Miliseconds)',
			ghc.intEditHDRSampleWorkerTimeMicrosecond as N'Edit HDR Work Time (Microseconds)',
			ghc.fltEditHDRSampleWorkerTimeMilisecond as N'Edit HDR Work Time (Miliseconds)',
			ghc.intEditHDRSampleProcessedRows as N'Edit HDR Processed Rows',
			ghc.intEditHDRSampleLogicalReads as N'Edit HDR Logical Reads',
			ghc.intEditHDRSampleLogicalWrites as N'Edit HDR Logical Writes',
			ISNULL(ghc.strCreatePersonQuery, N'') as N'Create Person Query with Parameters',
			ISNULL(ghc.strCreateHDRQuery, N'') as N'Create HDR Query with Parameters',
			ISNULL(ghc.strEditHDRSampleQuery, N'') as N'Edit HDR Query with Parameters'
from		#GenerateHC ghc
order by	ghc.idfID


--END TRY
--BEGIN CATCH
if @@ERROR <> 0
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION;--COMMIT TRANSACTION;
	
--	select	@err_number = ERROR_NUMBER(),
--			@err_severity = ERROR_SEVERITY(),
--			@err_state = ERROR_STATE(),
--			@err_line = ERROR_LINE(),
--			@err_procedure = ERROR_PROCEDURE(),
--			@err_message = ERROR_MESSAGE()

--	set	@CurrentIteration = @Iterations

--	set	@err_message = N'An error occurred during script execution.
--' + N'Msg ' + cast(isnull(@err_number, 0) as nvarchar(20)) + 
--N', Level ' + cast(isnull(@err_severity, 0) as nvarchar(20)) + 
--N', State ' + cast(isnull(@err_state, 0) as nvarchar(20)) + 
--N', Line ' + cast(isnull(@err_line, 0) as nvarchar(20)) + 
--N', Procedure ' + isnull(@err_procedure, N'unknown') + N'
--' + isnull(@err_message, N'Unknown error')

--	raiserror	(	@err_message,
--					17,
--					@err_state
--				) with SETERROR

--END CATCH;


set	@cmd = N'
-- Script rebuilds or reorganizes all database indexes, updates statistics and shrink database
-- without logging to the Admin database.
-- Execute this script on correct database.
SET NOCOUNT ON;
DECLARE @objectid int;
DECLARE @indexid int;
DECLARE @partitioncount bigint;
DECLARE @schemaname sysname;
DECLARE @objectname sysname;
DECLARE @indexname sysname;
DECLARE @partitionnum bigint;
DECLARE @partitions bigint;
DECLARE @frag float;
DECLARE @command varchar(8000);

declare	@DoPrints bit = 0 -- Specify whether prints for indexes are needed or not

-- Parameters for logging
declare @intUpdateIndexResult int
set @intUpdateIndexResult = 0
declare	@errUpdateIndexMessage nvarchar(1000)

-- ensure the temporary table does not exist
IF EXISTS (SELECT name FROM sys.objects WHERE name = ''work_to_do'')
    DROP TABLE work_to_do;
-- conditionally select from the function, converting object and index IDs to names.
SELECT
    object_id AS objectid,
    index_id AS indexid,
    partition_number AS partitionnum,
    avg_fragmentation_in_percent AS frag
INTO work_to_do
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL , NULL, ''LIMITED'')
WHERE avg_fragmentation_in_percent > 10.0 AND index_id > 0;
-- Declare the cursor for the list of partitions to be processed.
DECLARE partitions CURSOR FOR SELECT * FROM work_to_do;

-- Open the cursor.
OPEN partitions;

-- Loop through the partitions.
FETCH NEXT
   FROM partitions
   INTO @objectid, @indexid, @partitionnum, @frag;

WHILE @@FETCH_STATUS = 0
    BEGIN;
        SELECT @objectname = o.name, @schemaname = s.name
        FROM sys.objects AS o
        JOIN sys.schemas as s ON s.schema_id = o.schema_id
        WHERE o.object_id = @objectid;

        SELECT @indexname = name 
        FROM sys.indexes
        WHERE  object_id = @objectid AND index_id = @indexid;

if  @indexname not like ''%geomShape%''
begin		

        SELECT @partitioncount = count (*) 
        FROM sys.partitions
        WHERE object_id = @objectid AND index_id = @indexid;

		set @intUpdateIndexResult = 0
		set @errUpdateIndexMessage = null

-- 30 is an arbitrary decision point at which to switch between reorganizing and rebuilding
IF @frag < 30.0
    BEGIN;

		begin try 
		    
			SELECT @command = ''ALTER INDEX '' + @indexname + '' ON '' + @schemaname + ''.'' + @objectname + '' REORGANIZE'';
			IF @partitioncount > 1
				SELECT @command = @command + '' PARTITION='' + CONVERT (CHAR, @partitionnum);
			EXEC (@command);

		end try 
		begin catch
			if	@DoPrints = 1
			begin
				set @intUpdateIndexResult = ERROR_NUMBER()
				set @errUpdateIndexMessage = N'' WITH FAILURE'' + IsNull(N''; ERROR: '' + ERROR_MESSAGE(), N'''')
			end
		end catch

		if	@DoPrints = 1
		begin
			set @errUpdateIndexMessage = N''REORGANIZE INDEX '' + @indexname + IsNull(@errUpdateIndexMessage, N'' WITH SUCCESS'')
			set	@intUpdateIndexResult = IsNull(@intUpdateIndexResult, -1)
			print	@errUpdateIndexMessage
		end

    END;

IF @frag >= 30.0
    BEGIN;

		begin try 
		    
			SELECT @command = ''ALTER INDEX '' + @indexname + '' ON '' + @schemaname + ''.'' + @objectname + '' REBUILD'';
			IF @partitioncount > 1
				SELECT @command = @command + '' PARTITION='' + CONVERT (CHAR, @partitionnum);
			EXEC (@command);

		end try 
		begin catch
			if	@DoPrints = 1
			begin
				set @intUpdateIndexResult = ERROR_NUMBER()
				set @errUpdateIndexMessage = N'' WITH FAILURE'' + IsNull(N''; ERROR: '' + ERROR_MESSAGE(), N'''')
			end
		end catch

		if	@DoPrints = 1
		begin
			set @errUpdateIndexMessage = N''REBUILD INDEX '' + @indexname + IsNull(@errUpdateIndexMessage, N'' WITH SUCCESS'')
			set	@intUpdateIndexResult = IsNull(@intUpdateIndexResult, -1)
			print	@errUpdateIndexMessage
		end
    END;
	if	@DoPrints = 1
	begin
		PRINT ''Executed '' + @command;
	end
end

FETCH NEXT FROM partitions INTO @objectid, @indexid, @partitionnum, @frag;
END;
-- Close and deallocate the cursor.
CLOSE partitions;
DEALLOCATE partitions;

-- drop the temporary table
IF EXISTS (SELECT name FROM sys.objects WHERE name = ''work_to_do'')
    DROP TABLE work_to_do;
'
if len(@cmd) > 0
	exec sp_executesql @cmd

set	@cmd = N'
exec sp_updatestats
'
if len(@cmd) > 0
	exec sp_executesql @cmd

end

set XACT_ABORT off
set nocount off








/* TODO:

		DECLARE @Hospital BIGINT = CASE WHEN @HospitalizationStatus = 5350000000 /*Hospital*/ THEN @LocalOffice ELSE NULL END
		DECLARE @YNHospitalization BIGINT = CASE WHEN @HospitalizationStatus = 5350000000 /*Hospital*/ THEN 10100001 /*Yes*/ ELSE NULL END

Samples, including transfer out, Tests, Contacts

select * from trtReferenceType order by strReferenceTypeName
select * from fnReference('en', 19000064) order by intOrder, [name]
select * from tstCustomizationPackage
select * from tauTable order by strName
*/