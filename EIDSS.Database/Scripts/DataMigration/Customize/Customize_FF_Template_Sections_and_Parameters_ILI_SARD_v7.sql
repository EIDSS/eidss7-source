-- This script applies customization requirements for flexible form sections and parameters with links to templates


use [Giraffe]
GO


CREATE or ALTER          function [dbo].[fnGetLanguageCode](@LangID  nvarchar(50))
returns bigint
as
BEGIN
DECLARE @LanguageCode bigint
SET @LanguageCode = CASE @LangID WHEN N'az-L'	THEN 10049001
		WHEN N'ru'			THEN 10049006
		WHEN N'ka'			THEN 10049004
		WHEN N'kk'			THEN 10049005
		WHEN N'uz-C'		THEN 10049007
		WHEN N'uz-L'		THEN 10049008
		WHEN N'uk'			THEN 10049009
		WHEN N'CISID-AZ'	THEN 10049002
		WHEN N'hy'			THEN 10049010
		WHEN N'ar-IQ'		THEN 10049015
		WHEN N'ar'			THEN 10049011
		WHEN N'vi'			THEN 10049012
		WHEN N'lo'			THEN 10049013
		WHEN N'th'			THEN 10049014
		ELSE 10049003 END
return @LanguageCode
END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- select * from fnReference('ru',19000040)

CREATE or ALTER          function [dbo].[fnReference](@LangID  nvarchar(50), @type bigint)
returns table
as
return(

select
			b.idfsBaseReference as idfsReference, 
			IsNull(c.strTextString, b.strDefault) as [name],
			b.idfsReferenceType, 
			b.intHACode, 
			b.strDefault, 
			IsNull(c.strTextString, b.strDefault) as LongName,
			b.intOrder

from		dbo.trtBaseReference as b with(index=IX_trtBaseReference_RR)
left join	dbo.trtStringNameTranslation as c with(index=IX_trtStringNameTranslation_BL)
on			b.idfsBaseReference = c.idfsBaseReference and c.idfsLanguage = dbo.fnGetLanguageCode(@LangID)

where		b.idfsReferenceType = @type and b.intRowStatus = 0 
)

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER	FUNCTION [dbo].[FN_GBL_TriggersWork] ()
RETURNS BIT
AS
BEGIN
RETURN 0
--RETURN 1
END

GO

set nocount on
set XACT_ABORT on

BEGIN TRAN

declare	@PerformDeletions	int
set	@PerformDeletions = 0
--	0 - incorrect parameter types and values will be kept without changes
--	1 -	incorrect parameter types and values will be marked as deleted
--	2 -	incorrect parameter types and values will be deleted, 
--		as well as all incorrect flexible form values,
--		records, whose attributes with links to incorrect reference values aren't main for the record, will be cleared.

declare	@idfCustomizationPackage	bigint

-- Define table with sections of all customization packages
declare	@SectionTable	table
(	idfID					bigint not null identity (1, 1) primary key,
	idfsSection				bigint null,
	idfsFormTemplate		bigint null,
	idfSectionDesignOption	bigint null,
	idfsParentSection		bigint null,
	idfsFormType			bigint null,
	FormType_EN				nvarchar(500) collate database_default not null,
	FormTemplate_EN			nvarchar(500) collate database_default not null,
	OrderInTemplate			nvarchar(500) collate database_default null,
	SectionPath_EN			nvarchar(2000) collate database_default not null,
	Section_EN				nvarchar(500) collate database_default null,
	Section_RU				nvarchar(500) collate database_default null,
	Section_AM				nvarchar(500) collate database_default null,
	Section_AZ				nvarchar(500) collate database_default null,
	Section_GG				nvarchar(500) collate database_default null,
	Section_KZ				nvarchar(500) collate database_default null,
	Section_IQ				nvarchar(500) collate database_default null,
	Section_UA				nvarchar(500) collate database_default null,
	Section_TH				nvarchar(500) collate database_default null,
	SectionType				nvarchar(500) collate database_default null,
	ParentSection_EN		nvarchar(500) collate database_default null,
	strCustomizationPackage	nvarchar(200) collate database_default not null,
	blnGrid					bit null,
	SectionOrder			int null,
	idfCustomizationPackage				bigint null
)

-- Define table with parameters and templates of all customization packages
declare	@ParameterTable	table
(	idfID						bigint not null identity (1, 1) primary key,
	idfsParameter				bigint null,
	idfsParameterCaption		bigint null,	
	idfsSection					bigint null,
	idfsParameterType			bigint null,
	idfsFormTemplate			bigint null,
	idfsEditor					bigint null,
	idfsEditMode				bigint null,
	idfDefParameterDesignOption	bigint null,
	idfParameterDesignOption	bigint null,
	idfsFormType				bigint null,
	FormType_EN					nvarchar(500) collate database_default not null,
	FormTemplate_EN				nvarchar(500) collate database_default not null,
	OrderInTemplate				nvarchar(500) collate database_default null,
	Parameter_EN				nvarchar(500) collate database_default null,
	Parameter_RU				nvarchar(500) collate database_default null,
	Parameter_AM				nvarchar(500) collate database_default null,
	Parameter_AZ				nvarchar(500) collate database_default null,
	Parameter_GG				nvarchar(500) collate database_default null,
	Parameter_KZ				nvarchar(500) collate database_default null,
	Parameter_IQ				nvarchar(500) collate database_default null,
	Parameter_UA				nvarchar(500) collate database_default null,
	Parameter_TH				nvarchar(500) collate database_default null,
	ParameterOrder				int null,
	Tooltip_EN					nvarchar(500) collate database_default not null,
	Tooltip_RU					nvarchar(500) collate database_default null,
	Tooltip_AM					nvarchar(500) collate database_default null,
	Tooltip_AZ					nvarchar(500) collate database_default null,
	Tooltip_GG					nvarchar(500) collate database_default null,
	Tooltip_KZ					nvarchar(500) collate database_default null,
	Tooltip_IQ					nvarchar(500) collate database_default null,
	Tooltip_UA					nvarchar(500) collate database_default null,
	Tooltip_TH					nvarchar(500) collate database_default null,
	SectionPath_EN				nvarchar(2000) collate database_default null,
	Section_EN					nvarchar(300) collate database_default null,
	ParameterType_EN			nvarchar(300) collate database_default null,
	Editor_EN					nvarchar(300) collate database_default null,
	Mode_EN						nvarchar(300) collate database_default null,
	strCustomizationPackage		nvarchar(200) collate database_default not null,
	idfCustomizationPackage		bigint null
)

declare	@LabelTable table
(	idfDecorElement			bigint null,
	idfsBaseReference		bigint null,
	idfsFormTemplate		bigint not null,
	idfsSection				bigint null,
	Label_EN				nvarchar(500) collate database_default not null,
	Label_RU				nvarchar(500) collate database_default null,
	Label_AM				nvarchar(500) collate database_default null,
	Label_AZ				nvarchar(500) collate database_default null,
	Label_GG				nvarchar(500) collate database_default null,
	Label_KZ				nvarchar(500) collate database_default null,
	Label_IQ				nvarchar(500) collate database_default null,
	Label_UA				nvarchar(500) collate database_default null,
	Label_TH				nvarchar(500) collate database_default null,
	LabelOrder				int not null,
	idfCustomizationPackage	bigint not null
	primary key
	(	Label_EN asc,
		idfsFormTemplate asc,
		idfCustomizationPackage asc,
		LabelOrder asc
	)
)

-- Table containing sizes and positions of parameters and labels in specified templates
declare	@ParameterLabelDesignOption	table
(	idfsFormTemplate				bigint not null,
	idfsParameterOrDecorElement		bigint not null,
	intOrder						int not null,
	intLeft							int null,
	intTop							int null,
	intWidth						int null,
	intHeight						int null,
	intScheme						int null,
	intLabelSize					int null,
	primary key	(
		idfsFormTemplate asc,
		idfsParameterOrDecorElement asc
				)
)

-- Table containing sizes and positions of sections in specified templates
declare	@SectionDesignOption	table
(	idfsFormTemplate	bigint not null,
	idfsSection			bigint not null,
	intOrder			int not null,
	intLeft				int null,
	intTop				int null,
	intWidth			int null,
	intHeight			int null,
	intCaptionHeight	int not null default(26),
	primary key	(
		idfsFormTemplate	asc,
		idfsSection			desc
				)
)

declare	@FormTypeAndCountryToCustomize	table
(	idfsFormType	bigint not null,
	idfCustomizationPackage		bigint not null,
	primary key	(
		idfsFormType	asc,
		idfCustomizationPackage		asc
				)
)

--TODO: Remove for other than ILI/SARD templates - start
exec sp_executesql N'disable trigger TR_ffDecorElementText_I_Delete on dbo.ffDecorElementText'
exec sp_executesql N'disable trigger TR_ffDecorElement_I_Delete on dbo.ffDecorElement'

delete ffDecorElementText where idfDecorElement in (1, 2)
delete ffDecorElement where idfDecorElement in (1, 2)

exec sp_executesql N'enable trigger TR_ffDecorElementText_I_Delete on dbo.ffDecorElementText'
exec sp_executesql N'enable trigger TR_ffDecorElement_I_Delete on dbo.ffDecorElement'

exec sp_executesql N'disable trigger TR_ffParameterForTemplate_I_Delete on dbo.ffParameterForTemplate'
exec sp_executesql N'disable trigger TR_ffParameterDesignOption_I_Delete on dbo.ffParameterDesignOption'

delete ffParameterForTemplate where idfsParameter in (58010200000001, 58010200000003)
delete ffParameterDesignOption where idfsParameter in (58010200000001, 58010200000003)

exec sp_executesql N'enable trigger TR_ffParameterForTemplate_I_Delete on dbo.ffParameterForTemplate'
exec sp_executesql N'enable trigger TR_ffParameterDesignOption_I_Delete on dbo.ffParameterDesignOption'


--TODO: Remove for other than ILI/SARD templates - end


-- Fill format tables
insert into @SectionTable (idfsFormTemplate, idfsSection, idfSectionDesignOption, FormType_EN, FormTemplate_EN, OrderInTemplate, SectionPath_EN, Section_EN, Section_GG, SectionType, ParentSection_EN, strCustomizationPackage) 
values
 (10033501, 10101501, 1, N'Human Clinical Signs', N'HCS ILI', N'1', N'Syndromes', N'Syndromes', N'სინდრომები', N'Default', N'None', N'Azerbaijan')
,(10033502, 10101501, 2, N'Human Clinical Signs', N'HCS SARD', N'1', N'Syndromes', N'Syndromes', N'სინდრომები', N'Default', N'None', N'Azerbaijan')

--Parameter Type: 10071501, Method of measurement, Reference Type: Basic Syndromic Surveillance - Method of Measurement
--Parameter Type: 10071503, Lab Test Result, Reference Type: Basic Syndromic Surveillance - Test Result
--Parameter Type: 10071502, Outcome, Reference Type: Case Outcome List

insert into @ParameterTable (idfsFormTemplate, idfsParameter, idfsParameterCaption, idfDefParameterDesignOption, idfParameterDesignOption, FormType_EN, FormTemplate_EN, OrderInTemplate, Parameter_EN, Parameter_GG, ParameterType_EN, Tooltip_EN, Tooltip_GG, SectionPath_EN, Section_EN, Editor_EN, Mode_EN, strCustomizationPackage) 
values 
 (10033501, 10066501, 10070501, 58, 1, N'Human Clinical Signs', N'HCS ILI', N'1', N'Date of Symptoms onset', N'სიმპტომების გამოვლენის თარიღი', N'Date', N'ILI/SARD: Date of Symptoms onset', N'გმდ/SARD: სიმპტომების გამოვლენის თარიღი', N'Syndromes', N'Syndromes', N'Date Control', N'Ordinary', N'Azerbaijan')
,(10033501, 10066502, 10070502, 59, 2, N'Human Clinical Signs', N'HCS ILI', N'2', N'Pregnant', N'ორსული', N'Y_N_Unk', N'ILI/SARD: Pregnant', N'გმდ/SARD: ორსული', N'Syndromes', N'Syndromes', N'Combo Box', N'Ordinary', N'Azerbaijan')
,(10033501, 10066503, 10070503, 60, 3, N'Human Clinical Signs', N'HCS ILI', N'3', N'Postpartum period (6 weeks)', N'მშობიარობის შემდგომი პერიოდი (6 კვირა)', N'Y_N_Unk', N'ILI/SARD: Postpartum period (6 weeks)', N'გმდ/SARD: მშობიარობის შემდგომი პერიოდი (6 კვირა)', N'Syndromes', N'Syndromes', N'Combo Box', N'Ordinary', N'Azerbaijan')
,(10033501, 10066504, 10070504, 61, 4, N'Human Clinical Signs', N'HCS ILI', N'4', N'Fever >38C', N'ცხელება > 38C', N'Y_N_Unk', N'ILI/SARD: Fever >38C', N'გმდ/SARD: ცხელება > 38C', N'Syndromes', N'Syndromes', N'Combo Box', N'Ordinary', N'Azerbaijan')
,(10033501, 10066505, 10070505, 62, 5, N'Human Clinical Signs', N'HCS ILI', N'5', N'Method of measurement', N'გაზომვის მეთოდი', N'Method of measurement', N'ILI/SARD: Method of measurement', N'გმდ/SARD: გაზომვის მეთოდი', N'Syndromes', N'Syndromes', N'Combo Box', N'Ordinary', N'Azerbaijan')
,(10033501, 10066506, 10070506, 63, 6, N'Human Clinical Signs', N'HCS ILI', N'6', N'If other, enter method', N'თუ სხვა, მიუთითეთ მეთოდი', N'String', N'ILI/SARD: If other, enter method', N'გმდ/SARD: თუ სხვა, მიუთითეთ მეთოდი', N'Syndromes', N'Syndromes', N'Text Box', N'Ordinary', N'Azerbaijan')
,(10033501, 10066507, 10070507, 64, 7, N'Human Clinical Signs', N'HCS ILI', N'7', N'Cough', N'ხველება', N'Y_N_Unk', N'ILI/SARD: Cough', N'გმდ/SARD: ხველება', N'Syndromes', N'Syndromes', N'Combo Box', N'Ordinary', N'Azerbaijan')
,(10033501, 10066508, 10070508, 65, 8, N'Human Clinical Signs', N'HCS ILI', N'8', N'Shortness of breath', N'ქოშინი', N'Y_N_Unk', N'ILI/SARD: Shortness of breath', N'გმდ/SARD: ქოშინი', N'Syndromes', N'Syndromes', N'Combo Box', N'Ordinary', N'Azerbaijan')
,(10033501, 10066509, 10070509, 66, 9, N'Human Clinical Signs', N'HCS ILI', N'9', N'Seasonal Flu Vaccine', N'სეზონური გრიპის ვაქცინა', N'Y_N_Unk', N'ILI/SARD: Seasonal Flu Vaccine', N'გმდ/SARD: სეზონური გრიპის ვაქცინა', N'Syndromes', N'Syndromes', N'Combo Box', N'Ordinary', N'Azerbaijan')
,(10033501, 10066515, 10070515, 72, 10, N'Human Clinical Signs', N'HCS ILI', N'10', N'Patient was administered antiviral medicine', N'პაციენტს დაენიშნა ანტივირუსული პრეპარატი', N'Y_N_Unk', N'ILI/SARD: Patient was administered antiviral medicine', N'გმდ/SARD: პაციენტს დაენიშნა ანტივირუსული პრეპარატი', N'Syndromes', N'Syndromes', N'Combo Box', N'Ordinary', N'Azerbaijan')
,(10033501, 10066516, 10070516, 73, 11, N'Human Clinical Signs', N'HCS ILI', N'11', N'Name of medication', N'მედიკამენტის სახელი', N'String', N'ILI/SARD: Name of medication', N'გმდ/SARD: მედიკამენტის სახელი', N'Syndromes', N'Syndromes', N'Text Box', N'Ordinary', N'Azerbaijan')
,(10033501, 10066517, 10070517, 74, 12, N'Human Clinical Signs', N'HCS ILI', N'12', N'Date Received', N'მიღების თარიღი', N'Date', N'ILI/SARD: Date Received', N'გმდ/SARD: მიღების თარიღი', N'Syndromes', N'Syndromes', N'Date Control', N'Ordinary', N'Azerbaijan')
,(10033501, 10131501, null, null, 1, N'Human Clinical Signs', N'HCS ILI', N'13', N'Concurrent Chronic Diseases or Conditions', N'თანმხლები ქრონიკული დაავადებები ან მდგომარეობები', N'Label', N'', N'', N'Syndromes', N'Syndromes', N'', N'', N'Azerbaijan')
,(10033501, 10066518, 10070518, 75, 13, N'Human Clinical Signs', N'HCS ILI', N'14', N'Respiratory system', N'სასუნთქი სისტემა', N'Boolean', N'ILI/SARD: Respiratory system', N'გმდ/SARD: სასუნთქი სისტემა', N'Syndromes', N'Syndromes', N'Check Box', N'Ordinary', N'Azerbaijan')
,(10033501, 10066519, 10070519, 76, 14, N'Human Clinical Signs', N'HCS ILI', N'15', N'Asthma', N'ასთმა', N'Boolean', N'ILI/SARD: Asthma', N'გმდ/SARD: ასთმა', N'Syndromes', N'Syndromes', N'Check Box', N'Ordinary', N'Azerbaijan')
,(10033501, 10066520, 10070520, 77, 15, N'Human Clinical Signs', N'HCS ILI', N'16', N'Diabetes', N'დიაბეტი', N'Boolean', N'ILI/SARD: Diabetes', N'გმდ/SARD: დიაბეტი', N'Syndromes', N'Syndromes', N'Check Box', N'Ordinary', N'Azerbaijan')
,(10033501, 10066521, 10070521, 78, 16, N'Human Clinical Signs', N'HCS ILI', N'17', N'Cardiovascular', N'კარდიოვასკულური', N'Boolean', N'ILI/SARD: Cardiovascular', N'გმდ/SARD: კარდიოვასკულური', N'Syndromes', N'Syndromes', N'Check Box', N'Ordinary', N'Azerbaijan')
,(10033501, 10066522, 10070522, 79, 17, N'Human Clinical Signs', N'HCS ILI', N'18', N'Obesity: BMI>30, not elevated', N'სიმსუქნე: (სხეულის მასის ინდექსი) BMI>30 მომატებული არ არის', N'Boolean', N'ILI/SARD: Obesity: BMI>30, not elevated', N'გმდ/SARD: სიმსუქნე: (სხეულის მასის ინდექსი) BMI>30 მომატებული არ არის', N'Syndromes', N'Syndromes', N'Check Box', N'Ordinary', N'Azerbaijan')
,(10033501, 10066523, 10070523, 80, 18, N'Human Clinical Signs', N'HCS ILI', N'19', N'Renal', N'თირკლმის', N'Boolean', N'ILI/SARD: Renal', N'გმდ/SARD: თირკლმის', N'Syndromes', N'Syndromes', N'Check Box', N'Ordinary', N'Azerbaijan')
,(10033501, 10066524, 10070524, 81, 19, N'Human Clinical Signs', N'HCS ILI', N'20', N'Liver', N'ღვიძლი', N'Boolean', N'ILI/SARD: Liver', N'გმდ/SARD: ღვიძლი', N'Syndromes', N'Syndromes', N'Check Box', N'Ordinary', N'Azerbaijan')
,(10033501, 10066525, 10070525, 82, 20, N'Human Clinical Signs', N'HCS ILI', N'21', N'Neurological/Psychological', N'ნევროლოგიურ/ფსიქოლოგიური', N'Boolean', N'ILI/SARD: Neurological/Psychological', N'გმდ/SARD: ნევროლოგიურ/ფსიქოლოგიური', N'Syndromes', N'Syndromes', N'Check Box', N'Ordinary', N'Azerbaijan')
,(10033501, 10066526, 10070526, 83, 21, N'Human Clinical Signs', N'HCS ILI', N'22', N'Immunodeficiency', N'იმუნოდეფიციტი', N'Boolean', N'ILI/SARD: Immunodeficiency', N'გმდ/SARD: იმუნოდეფიციტი', N'Syndromes', N'Syndromes', N'Check Box', N'Ordinary', N'Azerbaijan')
,(10033501, 10066527, 10070527, 84, 22, N'Human Clinical Signs', N'HCS ILI', N'23', N'Unknown Etiology', N'უცნობი ეტიოლოგიის', N'Boolean', N'ILI/SARD: Unknown Etiology', N'გმდ/SARD: უცნობი ეტიოლოგიის', N'Syndromes', N'Syndromes', N'Check Box', N'Ordinary', N'Azerbaijan')
,(10033501, 10066528, 10070528, 85, 23, N'Human Clinical Signs', N'HCS ILI', N'24', N'Sample Collection Date', N'ნიმუშების აღების თარიღი', N'Date', N'ILI/SARD: Sample Collection Date', N'გმდ/SARD: ნიმუშების აღების თარიღი', N'Syndromes', N'Syndromes', N'Date Control', N'Ordinary', N'Azerbaijan')
,(10033501, 10066529, 10070529, 86, 24, N'Human Clinical Signs', N'HCS ILI', N'25', N'Sample ID', N'ნიმუშის ID', N'String', N'ILI/SARD: Sample ID', N'გმდ/SARD: ნიმუშის ID', N'Syndromes', N'Syndromes', N'Text Box', N'Ordinary', N'Azerbaijan')
,(10033501, 10066530, 10070530, 87, 25, N'Human Clinical Signs', N'HCS ILI', N'26', N'Test Result', N'ტესტის შედეგი', N'Lab Test Result', N'ILI/SARD: Test Result', N'გმდ/SARD: ტესტის შედეგი', N'Syndromes', N'Syndromes', N'Combo Box', N'Ordinary', N'Azerbaijan')
,(10033501, 10066531, 10070531, 88, 26, N'Human Clinical Signs', N'HCS ILI', N'27', N'Result Date', N'შედეგის თარიღი', N'Date', N'ILI/SARD: Result Date', N'გმდ/SARD: შედეგის თარიღი', N'Syndromes', N'Syndromes', N'Date Control', N'Ordinary', N'Azerbaijan')


,(10033502, 10066501, 10070501, 58, 27, N'Human Clinical Signs', N'HCS SARD', N'1', N'Date of Symptoms onset', N'სიმპტომების გამოვლენის თარიღი', N'Date', N'ILI/SARD: Date of Symptoms onset', N'გმდ/SARD: სიმპტომების გამოვლენის თარიღი', N'Syndromes', N'Syndromes', N'Date Control', N'Ordinary', N'Azerbaijan')
,(10033502, 10066502, 10070502, 59, 28, N'Human Clinical Signs', N'HCS SARD', N'2', N'Pregnant', N'ორსული', N'Y_N_Unk', N'ILI/SARD: Pregnant', N'გმდ/SARD: ორსული', N'Syndromes', N'Syndromes', N'Combo Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066503, 10070503, 60, 29, N'Human Clinical Signs', N'HCS SARD', N'3', N'Postpartum period (6 weeks)', N'მშობიარობის შემდგომი პერიოდი (6 კვირა)', N'Y_N_Unk', N'ILI/SARD: Postpartum period (6 weeks)', N'გმდ/SARD: მშობიარობის შემდგომი პერიოდი (6 კვირა)', N'Syndromes', N'Syndromes', N'Combo Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066504, 10070504, 61, 30, N'Human Clinical Signs', N'HCS SARD', N'4', N'Fever >38C', N'ცხელება > 38C', N'Y_N_Unk', N'ILI/SARD: Fever >38C', N'გმდ/SARD: ცხელება > 38C', N'Syndromes', N'Syndromes', N'Combo Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066505, 10070505, 62, 31, N'Human Clinical Signs', N'HCS SARD', N'5', N'Method of measurement', N'გაზომვის მეთოდი', N'Method of measurement', N'ILI/SARD: Method of measurement', N'გმდ/SARD: გაზომვის მეთოდი', N'Syndromes', N'Syndromes', N'Combo Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066506, 10070506, 63, 32, N'Human Clinical Signs', N'HCS SARD', N'6', N'If other, enter method', N'თუ სხვა, მიუთითეთ მეთოდი', N'String', N'ILI/SARD: If other, enter method', N'გმდ/SARD: თუ სხვა, მიუთითეთ მეთოდი', N'Syndromes', N'Syndromes', N'Text Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066507, 10070507, 64, 33, N'Human Clinical Signs', N'HCS SARD', N'7', N'Cough', N'ხველება', N'Y_N_Unk', N'ILI/SARD: Cough', N'გმდ/SARD: ხველება', N'Syndromes', N'Syndromes', N'Combo Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066508, 10070508, 65, 34, N'Human Clinical Signs', N'HCS SARD', N'8', N'Shortness of breath', N'ქოშინი', N'Y_N_Unk', N'ILI/SARD: Shortness of breath', N'გმდ/SARD: ქოშინი', N'Syndromes', N'Syndromes', N'Combo Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066509, 10070509, 66, 35, N'Human Clinical Signs', N'HCS SARD', N'9', N'Seasonal Flu Vaccine', N'სეზონური გრიპის ვაქცინა', N'Y_N_Unk', N'ILI/SARD: Seasonal Flu Vaccine', N'გმდ/SARD: სეზონური გრიპის ვაქცინა', N'Syndromes', N'Syndromes', N'Combo Box', N'Ordinary', N'Azerbaijan')

,(10033502, 10066510, 10070510, 67, 36, N'Human Clinical Signs', N'HCS SARD', N'10', N'Date of Care', N'მკურნალობის თარიღი', N'Date', N'SARD: Date of Care', N'SARD: მკურნალობის თარიღი', N'Syndromes', N'Syndromes', N'Date Control', N'Ordinary', N'Azerbaijan')
,(10033502, 10066511, 10070511, 68, 37, N'Human Clinical Signs', N'HCS SARD', N'11', N'Patient was in EIR or Intensive Care?', N'დააწვინეს პაციენტი ინტენსიური თერაპიის ან რეანიმაციულ განყოფილებაში?', N'Y_N_Unk', N'SARD: Patient was in EIR or Intensive Care', N'SARD: დააწვინეს პაციენტი ინტენსიური თერაპიის ან რეანიმაციულ განყოფილებაში', N'Syndromes', N'Syndromes', N'Combo Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066512, 10070512, 69, 38, N'Human Clinical Signs', N'HCS SARD', N'12', N'Patient was hospitalized at least one night?', N'იყო პაციენტი ჰოსპიტალიზებული სულ მცირე ერთი დღით?', N'Y_N_Unk', N'SARD: Patient was hospitalized at least one night', N'SARD: იყო პაციენტი ჰოსპიტალიზებული სულ მცირე ერთი დღით', N'Syndromes', N'Syndromes', N'Combo Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066513, 10070513, 70, 39, N'Human Clinical Signs', N'HCS SARD', N'13', N'Outcome', N'გამოსავალი', N'Outcome', N'SARD: Outcome', N'SARD: გამოსავალი', N'Syndromes', N'Syndromes', N'Combo Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066514, 10070514, 71, 40, N'Human Clinical Signs', N'HCS SARD', N'14', N'Treatment included artificial ventilation of lungs', N'მკურნალობდა მოიცავდა ფილტვების ხელოვნურ ვენტილაციას', N'Y_N_Unk', N'SARD: Treatment included artificial ventilation of lungs', N'SARD: მკურნალობდა მოიცავდა ფილტვების ხელოვნურ ვენტილაციას', N'Syndromes', N'Syndromes', N'Combo Box', N'Ordinary', N'Azerbaijan')


,(10033502, 10066515, 10070515, 72, 41, N'Human Clinical Signs', N'HCS SARD', N'15', N'Patient was administered antiviral medicine', N'პაციენტს დაენიშნა ანტივირუსული პრეპარატი', N'Y_N_Unk', N'ILI/SARD: Patient was administered antiviral medicine', N'გმდ/SARD: პაციენტს დაენიშნა ანტივირუსული პრეპარატი', N'Syndromes', N'Syndromes', N'Combo Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066516, 10070516, 73, 42, N'Human Clinical Signs', N'HCS SARD', N'16', N'Name of medication', N'მედიკამენტის სახელი', N'String', N'ILI/SARD: Name of medication', N'გმდ/SARD: მედიკამენტის სახელი', N'Syndromes', N'Syndromes', N'Text Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066517, 10070517, 74, 43, N'Human Clinical Signs', N'HCS SARD', N'17', N'Date Received', N'მიღების თარიღი', N'Date', N'ILI/SARD: Date Received', N'გმდ/SARD: მიღების თარიღი', N'Syndromes', N'Syndromes', N'Date Control', N'Ordinary', N'Azerbaijan')

,(10033502, 10131502, null, null, 2, N'Human Clinical Signs', N'HCS SARD', N'18', N'Concurrent Chronic Diseases or Conditions', N'თანმხლები ქრონიკული დაავადებები ან მდგომარეობები', N'Label', N'', N'', N'Syndromes', N'Syndromes', N'', N'', N'Azerbaijan')
,(10033502, 10066518, 10070518, 75, 44, N'Human Clinical Signs', N'HCS SARD', N'19', N'Respiratory system', N'სასუნთქი სისტემა', N'Boolean', N'ILI/SARD: Respiratory system', N'გმდ/SARD: სასუნთქი სისტემა', N'Syndromes', N'Syndromes', N'Check Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066519, 10070519, 76, 45, N'Human Clinical Signs', N'HCS SARD', N'20', N'Asthma', N'ასთმა', N'Boolean', N'ILI/SARD: Asthma', N'გმდ/SARD: ასთმა', N'Syndromes', N'Syndromes', N'Check Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066520, 10070520, 77, 46, N'Human Clinical Signs', N'HCS SARD', N'21', N'Diabetes', N'დიაბეტი', N'Boolean', N'ILI/SARD: Diabetes', N'გმდ/SARD: დიაბეტი', N'Syndromes', N'Syndromes', N'Check Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066521, 10070521, 78, 47, N'Human Clinical Signs', N'HCS SARD', N'22', N'Cardiovascular', N'კარდიოვასკულური', N'Boolean', N'ILI/SARD: Cardiovascular', N'გმდ/SARD: კარდიოვასკულური', N'Syndromes', N'Syndromes', N'Check Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066522, 10070522, 79, 48, N'Human Clinical Signs', N'HCS SARD', N'23', N'Obesity: BMI>30, not elevated', N'სიმსუქნე: (სხეულის მასის ინდექსი) BMI>30 მომატებული არ არის', N'Boolean', N'ILI/SARD: Obesity: BMI>30, not elevated', N'გმდ/SARD: სიმსუქნე: (სხეულის მასის ინდექსი) BMI>30 მომატებული არ არის', N'Syndromes', N'Syndromes', N'Check Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066523, 10070523, 80, 49, N'Human Clinical Signs', N'HCS SARD', N'24', N'Renal', N'თირკლმის', N'Boolean', N'ILI/SARD: Renal', N'გმდ/SARD: თირკლმის', N'Syndromes', N'Syndromes', N'Check Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066524, 10070524, 81, 50, N'Human Clinical Signs', N'HCS SARD', N'25', N'Liver', N'ღვიძლი', N'Boolean', N'ILI/SARD: Liver', N'გმდ/SARD: ღვიძლი', N'Syndromes', N'Syndromes', N'Check Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066525, 10070525, 82, 51, N'Human Clinical Signs', N'HCS SARD', N'26', N'Neurological/Psychological', N'ნევროლოგიურ/ფსიქოლოგიური', N'Boolean', N'ILI/SARD: Neurological/Psychological', N'გმდ/SARD: ნევროლოგიურ/ფსიქოლოგიური', N'Syndromes', N'Syndromes', N'Check Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066526, 10070526, 83, 52, N'Human Clinical Signs', N'HCS SARD', N'27', N'Immunodeficiency', N'იმუნოდეფიციტი', N'Boolean', N'ILI/SARD: Immunodeficiency', N'გმდ/SARD: იმუნოდეფიციტი', N'Syndromes', N'Syndromes', N'Check Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066527, 10070527, 84, 53, N'Human Clinical Signs', N'HCS SARD', N'28', N'Unknown Etiology', N'უცნობი ეტიოლოგიის', N'Boolean', N'ILI/SARD: Unknown Etiology', N'გმდ/SARD: უცნობი ეტიოლოგიის', N'Syndromes', N'Syndromes', N'Check Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066528, 10070528, 85, 54, N'Human Clinical Signs', N'HCS SARD', N'29', N'Sample Collection Date', N'ნიმუშების აღების თარიღი', N'Date', N'ILI/SARD: Sample Collection Date', N'გმდ/SARD: ნიმუშების აღების თარიღი', N'Syndromes', N'Syndromes', N'Date Control', N'Ordinary', N'Azerbaijan')
,(10033502, 10066529, 10070529, 86, 55, N'Human Clinical Signs', N'HCS SARD', N'30', N'Sample ID', N'ნიმუშის ID', N'String', N'ILI/SARD: Sample ID', N'გმდ/SARD: ნიმუშის ID', N'Syndromes', N'Syndromes', N'Text Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066530, 10070530, 87, 56, N'Human Clinical Signs', N'HCS SARD', N'31', N'Test Result', N'ტესტის შედეგი', N'Lab Test Result', N'ILI/SARD: Test Result', N'გმდ/SARD: ტესტის შედეგი', N'Syndromes', N'Syndromes', N'Combo Box', N'Ordinary', N'Azerbaijan')
,(10033502, 10066531, 10070531, 88, 57, N'Human Clinical Signs', N'HCS SARD', N'32', N'Result Date', N'შედეგის თარიღი', N'Date', N'ILI/SARD: Result Date', N'გმდ/SARD: შედეგის თარიღი', N'Syndromes', N'Syndromes', N'Date Control', N'Ordinary', N'Azerbaijan')


-- Apply FF sections and parameters customization formats
print 'Applying customization requirements for flexible form sections and parameters with links to templates'
print ''
print ''

--TODO: For Armenia only!!!! 
update		s
set			s.blnGrid = 0
from		ffSection s
inner join trtBaseReferenceToCP brcp
on			s.idfsSection = brcp.idfsBaseReference
-- Form Type
inner join	fnReference('en', 19000034) r_ft				-- Flexible Form Type
on			r_ft.idfsReference = s.idfsFormType
where		brcp.idfCustomizationPackage = 51577400000000
			and r_ft.name = N'Human Epi Investigations'
			and s.blnGrid = 1
print 'BlnGrid (ffSection) - update: ' + cast(@@rowcount as varchar(20))
print ''

-- update existing IDs in the tables
print 'Update IDs of existing attributes'
print ''

-- Update Country ID in section table
update		st
set			st.idfCustomizationPackage = c.idfCustomizationPackage
from		@SectionTable st
inner join	tstCustomizationPackage c
on			IsNull(c.strCustomizationPackageName, N'') = 
			IsNull(st.strCustomizationPackage, N'Not specified') collate Cyrillic_General_CI_AS
print 'Rows, containing Sections, with existing IDs of customization packages: ' + cast(@@rowcount as varchar(20))


-- Update ID of FF Type in section table
update		st
set			st.idfsFormType = ft.idfsReference
from		@SectionTable st
inner join	fnReference('en', 19000034) ft	-- Flexible Form Type
on			ft.[name] = st.FormType_EN collate Cyrillic_General_CI_AS
print 'Rows, containing Sections, with existing IDs of FF form types: ' + cast(@@rowcount as varchar(20))


-- Update integer section orders
update		st
set			st.SectionOrder = cast(st.OrderInTemplate as integer)
from		@SectionTable st
where		IsNumeric(IsNull(st.OrderInTemplate, N'')) = 1
print 'Rows, containing Sections, with integer orders: ' + cast(@@rowcount as varchar(20))


-- Update section type
update		st
set			st.blnGrid = 
				case	IsNull(st.SectionType, N'Default')
					when	N'Default'
						then	0
					else	1
				end
from		@SectionTable st
print 'Rows, containing Sections, with correct type [Table / Default]: ' + cast(@@rowcount as varchar(20))


update		st
set			st.idfsFormTemplate = ft.idfsFormTemplate
from		@SectionTable st
inner join	trtBaseReference br
on			br.strDefault = st.FormTemplate_EN collate Cyrillic_General_CI_AS
			and br.idfsReferenceType = 19000033		-- Flexible Form Template
			and br.intRowStatus = 0
inner join	ffFormTemplate ft
on			ft.idfsFormTemplate = br.idfsBaseReference
			and ft.idfsFormType = st.idfsFormType
			and ft.intRowStatus = 0
inner join	trtBaseReferenceToCP br_to_c
on			br_to_c.idfsBaseReference = ft.idfsFormTemplate
			and br_to_c.idfCustomizationPackage = st.idfCustomizationPackage
print 'Rows, containing Sections, with existing IDs of FF form templates that belongs to specified customization packages: ' + cast(@@rowcount as varchar(20))


-- Update Country ID in Parameter table
update		pt
set			pt.idfCustomizationPackage = c.idfCustomizationPackage
from		@ParameterTable pt
inner join	tstCustomizationPackage c
on			IsNull(c.strCustomizationPackageName, N'') = 
				IsNull(pt.strCustomizationPackage, N'Not specified') collate Cyrillic_General_CI_AS
print 'Rows, containing Parameters/Labels, with existing IDs of customization packages: ' + cast(@@rowcount as varchar(20))

-- Update ID of FF Type in Parameter table
update		pt
set			pt.idfsFormType = ft.idfsReference
from		@ParameterTable pt
inner join	fnReference('en', 19000034) ft	-- Flexible Form Type
on			ft.[name] = pt.FormType_EN collate Cyrillic_General_CI_AS
print 'Rows, containing Parameters/Labels, with existing IDs of FF form types: ' + cast(@@rowcount as varchar(20))


-- Update integer Parameter orders
update		pt
set			pt.ParameterOrder = cast(pt.OrderInTemplate as integer)
from		@ParameterTable pt
where		IsNumeric(IsNull(pt.OrderInTemplate, N'')) = 1
print 'Rows, containing Parameters/Labels, with integer orders: ' + cast(@@rowcount as varchar(20))


-- Update tooltips for Labels
update		pt
set			pt.Tooltip_EN = N'Label ' + cast(pt.idfID as nvarchar(100))
from		@ParameterTable pt
where		IsNull(pt.ParameterType_EN, N'') = N'Label' collate Cyrillic_General_CI_AS
print 'Rows, containing Labels: ' + cast(@@rowcount as varchar(20))


update		pt
set			pt.idfsFormTemplate = ft.idfsFormTemplate
from		@ParameterTable pt
inner join	trtBaseReference br
on			br.strDefault = pt.FormTemplate_EN collate Cyrillic_General_CI_AS
			and br.idfsReferenceType = 19000033		-- Flexible Form Template
			and br.intRowStatus = 0
inner join	ffFormTemplate ft
on			ft.idfsFormTemplate = br.idfsBaseReference
			and ft.idfsFormType = pt.idfsFormType
			and ft.intRowStatus = 0
inner join	trtBaseReferenceToCP br_to_c
on			br_to_c.idfsBaseReference = ft.idfsFormTemplate
			and br_to_c.idfCustomizationPackage = pt.idfCustomizationPackage
print 'Rows, containing Parameters/Labels, with existing IDs of FF form templates that belongs to specified customization packages: ' + cast(@@rowcount as varchar(20))


update		pt
set			pt.idfsParameterType = part.idfsParameterType
from		@ParameterTable pt
inner join	trtBaseReference br
on			br.strDefault = pt.ParameterType_EN collate Cyrillic_General_CI_AS
			and br.idfsReferenceType = 19000071		-- Flexible Form Parameter Type
			and br.intRowStatus = 0
inner join	ffParameterType part
on			part.idfsParameterType = br.idfsBaseReference
			and part.intRowStatus = 0
inner join	trtBaseReferenceToCP br_to_c
on			br_to_c.idfsBaseReference = part.idfsParameterType
			and br_to_c.idfCustomizationPackage = pt.idfCustomizationPackage
print 'Rows, containing Parameters, with existing IDs of FF parameter types that belongs to specified customization packages: ' + cast(@@rowcount as varchar(20))


update		pt
set			pt.idfsParameterType = part.idfsParameterType
from		@ParameterTable pt
inner join	trtBaseReference br
on			br.strDefault = pt.ParameterType_EN collate Cyrillic_General_CI_AS
			and br.idfsReferenceType = 19000071		-- Flexible Form Parameter Type
			and br.intRowStatus = 0
inner join	ffParameterType part
on			part.idfsParameterType = br.idfsBaseReference
			and part.intRowStatus = 0
left join	trtBaseReferenceToCP br_to_c
on			br_to_c.idfsBaseReference = part.idfsParameterType
where		br_to_c.idfsBaseReference is null
print 'Rows, containing Parameters, with existing IDs of FF parameter types that do not belongs to any country: ' + cast(@@rowcount as varchar(20))

update		pt
set			pt.idfsEditor = br.idfsBaseReference
from		@ParameterTable pt
inner join	trtBaseReference br
on			br.strDefault = pt.Editor_EN collate Cyrillic_General_CI_AS
			and br.idfsReferenceType = 19000067		-- Flexible Form Parameter Editor
			and br.intRowStatus = 0
print 'Rows, containing Parameters, with existing IDs of FF parameter editors: ' + cast(@@rowcount as varchar(20))

update		pt
set			pt.idfsEditMode = br.idfsBaseReference
from		@ParameterTable pt
inner join	trtBaseReference br
on			br.strDefault = pt.Mode_EN collate Cyrillic_General_CI_AS
			and br.idfsReferenceType = 19000068		-- Flexible Form Parameter Mode
			and br.intRowStatus = 0
print 'Rows, containing Parameters, with existing IDs of FF parameter modes: ' + cast(@@rowcount as varchar(20))
print ''
print ''

print 'Update IDs of existing sections'
print ''

-- Table containing structure of existing sections
declare	@SectionStructure table
(	idfsSection					bigint not null,
	intParentLevel				int not null,
	idfsLevelParentSection		bigint null,
	strLevelSectionPathEN		nvarchar(MAX) collate database_default not null,
	blnGrid						bit null,
	primary key
	(	idfsSection asc,
		intParentLevel asc
	)
)

-- Table containing all sections from the database
declare	@AllSections	table
(	idfsSection			bigint not null primary key,
	idfsParentSection	bigint null,
	strSectionEN		nvarchar(2000) collate database_default not null,
	blnGrid				bit null
)

insert into	@AllSections
(	idfsSection,
	idfsParentSection,
	strSectionEN
)
select		s.idfsSection,
			s_parent.idfsSection,
			r_s_en.[name]
from		ffSection s
inner join	fnReference('en', 19000101) r_s_en				-- Flexible Form Section
on			r_s_en.idfsReference = s.idfsSection
left join	(
	ffSection s_parent
	inner join	fnReference('en', 19000101) r_s_parent_en	-- Flexible Form Section
	on			r_s_parent_en.idfsReference = s_parent.idfsSection
			)
on			s_parent.idfsSection = s.idfsParentSection
			and s_parent.intRowStatus = 0
where		s.intRowStatus = 0
print 'Total numbers of sections in the database before new sections are added: ' + cast(@@rowcount as varchar(20))

-- Select structure of sections from the database
;
with	sectionTable	(
			idfsSection,
			intParentLevel,
			idfsLevelParentSection,
			strLevelSectionPathEN
					)
as	(	select		s.idfsSection,
					0 as intParentLevel,
					s.idfsParentSection as idfsLevelParentSection,
					cast(s.strSectionEN as nvarchar(MAX)) as strLevelSectionPathEN
		from		@AllSections s
		union all
		select		sectionTable.idfsSection,
					sectionTable.intParentLevel + 1 as intParentLevel,
					s_all.idfsParentSection as idfsLevelParentSection,
					cast((s_all.strSectionEN + N'>' + sectionTable.strLevelSectionPathEN) as nvarchar(MAX)) as strLevelSectionPathEN
		from		@AllSections s_all
		inner join	sectionTable
		on			sectionTable.idfsLevelParentSection = s_all.idfsSection
	)

insert into	@SectionStructure
(	idfsSection,
	intParentLevel,
	idfsLevelParentSection,
	strLevelSectionPathEN
)
select		idfsSection,
			intParentLevel,
			idfsLevelParentSection,
			strLevelSectionPathEN
from		sectionTable
print 'Number of sections and their parent sections in the database before new sections are added: ' + cast(@@rowcount as varchar(20))

update		st
set			st.idfsSection = s.idfsSection
from		@SectionTable st
inner join	trtBaseReference br
on			br.strDefault = st.Section_EN collate Cyrillic_General_CI_AS
			and br.idfsReferenceType = 19000101	 	-- Flexible Form Section
			and br.intRowStatus = 0
inner join	ffSection s
on			s.idfsSection = br.idfsBaseReference
			and s.idfsFormType = st.idfsFormType
			and s.intRowStatus = 0
inner join	trtBaseReferenceToCP br_to_c
on			br_to_c.idfsBaseReference = s.idfsSection
			and br_to_c.idfCustomizationPackage = st.idfCustomizationPackage
inner join	@SectionStructure s_path
on			s_path.idfsSection = s.idfsSection
			and s_path.idfsLevelParentSection is null
			and s_path.strLevelSectionPathEN = st.SectionPath_EN
print 'Rows, containing Sections, with existing IDs of sections that belong to specified customization packages: ' + cast(@@rowcount as varchar(20))

update		st
set			st.idfSectionDesignOption = sdo.idfSectionDesignOption
from		@SectionTable st
inner join	ffFormTemplate ft
on			ft.idfsFormTemplate = st.idfsFormTemplate
inner join	ffSectionDesignOption sdo
on			sdo.idfsFormTemplate = ft.idfsFormTemplate
			and sdo.idfsSection = st.idfsSection
			and sdo.idfsLanguage = dbo.fnGetLanguageCode('en')
print 'Rows, containing Sections, with existing IDs of section design options in specified FF form templates: ' + cast(@@rowcount as varchar(20))
print ''
print ''

print 'Update IDs of existing parameters'
print ''
update		pt
set			pt.idfsParameter = p.idfsParameter
from		@ParameterTable pt
inner join	trtBaseReference br
on			br.strDefault = pt.Tooltip_EN collate Cyrillic_General_CI_AS
			and br.idfsReferenceType = 19000066		-- Flexible Form Parameter
			and br.intRowStatus = 0
inner join	ffParameter p
on			p.idfsParameter = br.idfsBaseReference
			and p.idfsFormType = pt.idfsFormType
			and p.intRowStatus = 0
inner join	trtBaseReferenceToCP br_to_c
on			br_to_c.idfsBaseReference = p.idfsParameter
			and br_to_c.idfCustomizationPackage = pt.idfCustomizationPackage
where		pt.ParameterType_EN <> N'Label'
print 'Rows, containing Parameters, with existing IDs of parameter tooltips that belong to specified customization packages: ' + cast(@@rowcount as varchar(20))

update		pt
set			pt.idfsParameterCaption = p.idfsParameterCaption
from		@ParameterTable pt
inner join	ffParameter p
on			p.idfsParameter = pt.idfsParameter
			--and p.idfsParameterCaption = br.idfsBaseReference
			and p.idfsFormType = pt.idfsFormType
			and p.intRowStatus = 0
inner join	trtBaseReference br
on			br.idfsBaseReference = p.idfsParameterCaption
			and br.idfsReferenceType = 19000070		-- Flexible Form Parameter Tooltip
			and br.intRowStatus = 0
inner join	trtBaseReferenceToCP br_to_c
on			br_to_c.idfsBaseReference = br.idfsBaseReference
			and br_to_c.idfCustomizationPackage = pt.idfCustomizationPackage
where		pt.ParameterType_EN <> N'Label'
print 'Rows, containing Parameters, with existing IDs of parameter captions that belong to specified customization packages: ' + cast(@@rowcount as varchar(20))

update		pt
set			pt.idfDefParameterDesignOption = pdo.idfParameterDesignOption
from		@ParameterTable pt
inner join	ffFormTemplate ft
on			ft.idfsFormTemplate = pt.idfsFormTemplate
inner join	ffParameterDesignOption pdo
on			pdo.idfsFormTemplate is null
			and pdo.idfsParameter = pt.idfsParameter
			and pdo.idfsLanguage = dbo.fnGetLanguageCode('en')
where		pt.ParameterType_EN <> N'Label'
print 'Rows, containing Parameters, with existing IDs of default parameter design options: ' + cast(@@rowcount as varchar(20))

update		pt
set			pt.idfParameterDesignOption = pdo.idfParameterDesignOption
from		@ParameterTable pt
inner join	ffFormTemplate ft
on			ft.idfsFormTemplate = pt.idfsFormTemplate
inner join	ffParameterDesignOption pdo
on			pdo.idfsFormTemplate = ft.idfsFormTemplate
			and pdo.idfsParameter = pt.idfsParameter
			and pdo.idfsLanguage = dbo.fnGetLanguageCode('en')
where		pt.ParameterType_EN <> N'Label'
print 'Rows, containing Parameters, with existing IDs of parameter design options in specified FF form templates: ' + cast(@@rowcount as varchar(20))
print ''
print ''

-- generate new section IDs
print 'Generate new IDs for sections and section design options in FF form templates'

declare	@NewIdCount				bigint
declare @idfsSection			bigint
declare	@idfSectionDesignOption	bigint
declare	@SectionPath_EN			nvarchar(2000)
declare	@FormTemplate_EN		nvarchar(2000)
declare	@idfsFormTemplate		bigint
declare	@FormType_EN			nvarchar(2000)
declare	@idfsFormType			bigint

set	@NewIdCount = 0
declare	SectionCursor Cursor local read_only forward_only for
	select		st.idfsSection,
				st.idfSectionDesignOption,
				st.SectionPath_EN,
				st.FormTemplate_EN,
				st.idfsFormTemplate,
				st.FormType_EN,
				st.idfsFormType,
				st.idfCustomizationPackage
	from		@SectionTable st
	order by	st.SectionPath_EN,
				st.idfsFormTemplate,
				st.idfsFormType,
				st.idfCustomizationPackage
open SectionCursor
fetch next from SectionCursor into 
	@idfsSection,
	@idfSectionDesignOption,
	@SectionPath_EN,
	@FormTemplate_EN,
	@idfsFormTemplate,
	@FormType_EN,
	@idfsFormType,
	@idfCustomizationPackage

while @@fetch_status <> -1
begin
	if @idfsSection is null
	begin

		select	@idfsSection = st.idfsSection
		from	@SectionTable st
		where	st.SectionPath_EN = @SectionPath_EN
				and st.idfsSection is not null
				and	st.idfsFormType = @idfsFormType
				and st.idfCustomizationPackage = @idfCustomizationPackage

		if @idfsSection is null
		begin
			exec spsysGetNewID @idfsSection output

			print N''
			print N'ID for a new section with form type [' + replace(@FormType_EN, N'''', N'''''') + N'] and full path [' + replace(@SectionPath_EN, N'''', N'''''') + N'] is generated'
			
			set	@NewIdCount = @NewIdCount + 1
		end

		update	st
		set		st.idfsSection = @idfsSection
		from	@SectionTable st
		where	st.SectionPath_EN = @SectionPath_EN
				and st.idfsFormTemplate = @idfsFormTemplate
				and	st.idfsFormType = @idfsFormType
				and st.idfCustomizationPackage = @idfCustomizationPackage

	end

	if @idfSectionDesignOption is null
	begin

		exec spsysGetNewID @idfSectionDesignOption output

		print N''
		print N'ID for the design option of the section with form type [' + replace(@FormType_EN, N'''', N'''''') + N'] and full path [' + replace(@SectionPath_EN, N'''', N'''''') + N'] 
in the template [' + replace(@FormTemplate_EN, N'''', N'''''') + N'] is generated'
			
		set	@NewIdCount = @NewIdCount + 1

		update	st
		set		st.idfSectionDesignOption = @idfSectionDesignOption
		from	@SectionTable st
		where	st.idfsSection = @idfsSection
				and st.idfsFormTemplate = @idfsFormTemplate
				and	st.idfsFormType = @idfsFormType
				and st.idfCustomizationPackage = @idfCustomizationPackage

	end

	fetch next from SectionCursor into 
		@idfsSection,
		@idfSectionDesignOption,
		@SectionPath_EN,
		@FormTemplate_EN,
		@idfsFormTemplate,
		@FormType_EN,
		@idfsFormType,
		@idfCustomizationPackage

end
close SectionCursor
deallocate SectionCursor

if @NewIdCount = 0
	print 'No new ID is needed.'
print ''
print ''

-- generate new parameter IDs
print 'Generate new IDs for parameter tooltips, captions, default design options and design options in FF form templates'
declare @idfsParameter					bigint
declare @idfsParameterCaption			bigint
declare	@idfDefParameterDesignOption	bigint
declare	@idfParameterDesignOption		bigint
declare	@Tooltip_EN						nvarchar(500)

set	@NewIdCount = 0
declare	ParameterCursor Cursor local read_only forward_only for
	select		pt.idfsParameter,
				pt.idfsParameterCaption,
				pt.idfDefParameterDesignOption,
				pt.idfParameterDesignOption,
				pt.Tooltip_EN,
				pt.FormTemplate_EN,
				pt.idfsFormTemplate,
				pt.FormType_EN,
				pt.idfsFormType,
				pt.idfCustomizationPackage
	from		@ParameterTable pt
	where		pt.ParameterType_EN <> N'Label'
	order by	pt.Tooltip_EN,
				pt.idfsFormTemplate,
				pt.idfsFormType,
				pt.idfCustomizationPackage
open ParameterCursor
fetch next from ParameterCursor into 
	@idfsParameter,
	@idfsParameterCaption,
	@idfDefParameterDesignOption,
	@idfParameterDesignOption,
	@Tooltip_EN,
	@FormTemplate_EN,
	@idfsFormTemplate,
	@FormType_EN,
	@idfsFormType,
	@idfCustomizationPackage

while @@fetch_status <> -1
begin
	if @idfsParameter is null
	begin

		select	@idfsParameter = pt.idfsParameter
		from	@ParameterTable pt
		where	pt.Tooltip_EN = @Tooltip_EN
				and pt.idfsParameter is not null
				and	pt.idfsFormType = @idfsFormType
				and pt.idfCustomizationPackage = @idfCustomizationPackage

		if @idfsParameter is null
		begin
			exec spsysGetNewID @idfsParameter output

			print N''
			print N'ID for a new parameter with form type [' + replace(@FormType_EN, N'''', N'''''') + N'] and tooltip [' + replace(@Tooltip_EN, N'''', N'''''') + N'] is generated'
			
			set	@NewIdCount = @NewIdCount + 1
		end

		update	pt
		set		pt.idfsParameter = @idfsParameter
		from	@ParameterTable pt
		where	pt.Tooltip_EN = @Tooltip_EN
				and pt.idfsFormTemplate = @idfsFormTemplate
				and	pt.idfsFormType = @idfsFormType
				and pt.idfCustomizationPackage = @idfCustomizationPackage

	end

	if @idfsParameterCaption is null
	begin
		select	@idfsParameterCaption = pt.idfsParameterCaption
		from	@ParameterTable pt
		where	pt.idfsParameter = @idfsParameter
				and pt.idfsParameterCaption is not null
				and	pt.idfsFormType = @idfsFormType
				and pt.idfCustomizationPackage = @idfCustomizationPackage

		if @idfsParameterCaption is null
		begin
			exec spsysGetNewID @idfsParameterCaption output

			print N''
			print N'ID for the caption of the parameter with form type [' + replace(@FormType_EN, N'''', N'''''') + N'] and tooltip [' + replace(@Tooltip_EN, N'''', N'''''') + N'] is generated'
			
			set	@NewIdCount = @NewIdCount + 1
		end

		update	pt
		set		pt.idfsParameterCaption = @idfsParameterCaption
		from	@ParameterTable pt
		where	pt.idfsParameter = @idfsParameter
				and pt.idfsFormTemplate = @idfsFormTemplate
				and	pt.idfsFormType = @idfsFormType
				and pt.idfCustomizationPackage = @idfCustomizationPackage

	end

	if @idfDefParameterDesignOption is null
	begin
		select	@idfDefParameterDesignOption = pt.idfDefParameterDesignOption
		from	@ParameterTable pt
		where	pt.idfsParameter = @idfsParameter
				and pt.idfDefParameterDesignOption is not null
				and	pt.idfsFormType = @idfsFormType
				and pt.idfCustomizationPackage = @idfCustomizationPackage

		if @idfDefParameterDesignOption is null
		begin

			exec spsysGetNewID @idfDefParameterDesignOption output

			print N''
			print N'ID for the default design option of the parameter with form type [' + replace(@FormType_EN, N'''', N'''''') + N'] and tooltip [' + replace(@Tooltip_EN, N'''', N'''''') + N'] is generated'
			
			set	@NewIdCount = @NewIdCount + 1
		end

		update	pt
		set		pt.idfDefParameterDesignOption = @idfDefParameterDesignOption
		from	@ParameterTable pt
		where	pt.idfsParameter = @idfsParameter
				and pt.idfsFormTemplate = @idfsFormTemplate
				and	pt.idfsFormType = @idfsFormType
				and pt.idfCustomizationPackage = @idfCustomizationPackage

	end

	if @idfParameterDesignOption is null
	begin
		exec spsysGetNewID @idfParameterDesignOption output

		print N''
		print N'ID for the design option of the parameter with form type [' + replace(@FormType_EN, N'''', N'''''') + N'] and tooltip [' + replace(@Tooltip_EN, N'''', N'''''') + N'] 
in the template [' + replace(@FormTemplate_EN, N'''', N'''''') + N'] is generated'
			
		set	@NewIdCount = @NewIdCount + 1

		update	pt
		set		pt.idfParameterDesignOption = @idfParameterDesignOption
		from	@ParameterTable pt
		where	pt.idfsParameter = @idfsParameter
				and pt.idfsFormTemplate = @idfsFormTemplate
				and	pt.idfsFormType = @idfsFormType
				and pt.idfCustomizationPackage = @idfCustomizationPackage

	end

	fetch next from ParameterCursor into 
		@idfsParameter,
		@idfsParameterCaption,
		@idfDefParameterDesignOption,
		@idfParameterDesignOption,
		@Tooltip_EN,
		@FormTemplate_EN,
		@idfsFormTemplate,
		@FormType_EN,
		@idfsFormType,
		@idfCustomizationPackage

end
close ParameterCursor
deallocate ParameterCursor 
if @NewIdCount = 0
	print 'No new ID is needed.'
print ''
print ''

-- update section IDs

-- What about aggregate sections? Desision: update aggregate section names in formats
print 'Update IDs of parent sections for the sections and parameters/labels'
print ''
update		st
set			st.idfsParentSection = pst.idfsSection
from		@SectionTable st
inner join	@SectionTable pst
on			len(st.SectionPath_EN) > len(st.Section_EN) + 1
			and pst.SectionPath_EN = left(st.SectionPath_EN, len(st.SectionPath_EN) - len(st.Section_EN) - 1)
			and pst.idfsFormType = st.idfsFormType
			and pst.idfCustomizationPackage = st.idfCustomizationPackage
			and pst.idfsFormTemplate = st.idfsFormTemplate
print 'Rows, containing Sections, with updated non-blank IDs of parent sections: '  + cast(@@rowcount as varchar(20))

update		pt
set			pt.idfsSection = st.idfsSection
from		@ParameterTable pt
inner join	@SectionTable st
on			st.SectionPath_EN = pt.SectionPath_EN
			and st.idfsFormType = pt.idfsFormType
			and st.idfsFormTemplate = pt.idfsFormTemplate
			and st.idfCustomizationPackage = pt.idfCustomizationPackage
print 'Rows, containing Parameters/Labels, with updated non-blank IDs of parent sections: '  + cast(@@rowcount as varchar(20))
print ''
print ''

-- Update serial numbers of the sections and parameters/labels
-- It is assumed there are not more than 9 consecutive sub-sections in the formats.
update		st
set			st.SectionOrder = st.SectionOrder * 100
from		@SectionTable st

update		pt
set			pt.ParameterOrder = pt.ParameterOrder * 100 + 10
from		@ParameterTable pt

update		st
set			st.SectionOrder = pt_min.ParameterOrder - 1
from		@SectionTable st
inner join	@ParameterTable pt_min
on			pt_min.idfsFormType = st.idfsFormType
			and pt_min.idfsFormTemplate = st.idfsFormTemplate
			and pt_min.idfCustomizationPackage = st.idfCustomizationPackage
			and pt_min.idfsSection = st.idfsSection
left join	@ParameterTable pt
on			pt.idfsFormType = st.idfsFormType
			and pt.idfsFormTemplate = st.idfsFormTemplate
			and pt.idfCustomizationPackage = st.idfCustomizationPackage
			and pt.idfsSection = st.idfsSection
			and pt.ParameterOrder < pt_min.ParameterOrder
left join	@SectionTable pst
on			pst.idfsParentSection = st.idfsSection
			and pst.idfsFormType = st.idfsFormType
			and pst.idfsFormTemplate = st.idfsFormTemplate
			and pst.idfCustomizationPackage = st.idfCustomizationPackage
where		pt.Tooltip_EN is null
			and pst.idfsSection is null

declare	@Goon	int
set	@Goon = 1

while	exists	(
			select		*
			from		@SectionTable st
			where		cast(st.SectionOrder as varchar(20)) like '%00' 
				)
		and @Goon <> 0
begin
	update		st
	set			st.SectionOrder = pt_min.ParameterOrder - 1
	from		@SectionTable st
	inner join	@ParameterTable pt_min
	on			pt_min.idfsFormType = st.idfsFormType
				and pt_min.idfsFormTemplate = st.idfsFormTemplate
				and pt_min.idfCustomizationPackage = st.idfCustomizationPackage
				and pt_min.idfsSection = st.idfsSection
	left join	@ParameterTable pt
	on			pt.idfsFormType = st.idfsFormType
				and pt.idfsFormTemplate = st.idfsFormTemplate
				and pt.idfCustomizationPackage = st.idfCustomizationPackage
				and pt.idfsSection = st.idfsSection
				and pt.ParameterOrder < pt_min.ParameterOrder
	left join	@SectionTable pst_upd_min
	on			pst_upd_min.idfsParentSection = st.idfsSection
				and pst_upd_min.idfsFormType = st.idfsFormType
				and pst_upd_min.idfsFormTemplate = st.idfsFormTemplate
				and pst_upd_min.idfCustomizationPackage = st.idfCustomizationPackage
				and pst_upd_min.SectionOrder < pt_min.ParameterOrder 
	left join	@SectionTable pst_not_upd
	on			pst_not_upd.idfsParentSection = st.idfsSection
				and pst_not_upd.idfsFormType = st.idfsFormType
				and pst_not_upd.idfsFormTemplate = st.idfsFormTemplate
				and pst_not_upd.idfCustomizationPackage = st.idfCustomizationPackage
				and cast(pst_not_upd.SectionOrder as varchar(20)) like '%00' 
	where		cast(st.SectionOrder as varchar(20)) like '%00' 
				and pt.Tooltip_EN is null
				and pst_upd_min.idfsSection is null
				and pst_not_upd.idfsSection is null

	set	@Goon = @@rowcount

	update		st
	set			st.SectionOrder = pst_upd_min.SectionOrder - 1
	from		@SectionTable st
	inner join	@SectionTable pst_upd_min
	on			pst_upd_min.idfsParentSection = st.idfsSection
				and pst_upd_min.idfsFormType = st.idfsFormType
				and pst_upd_min.idfsFormTemplate = st.idfsFormTemplate
				and pst_upd_min.idfCustomizationPackage = st.idfCustomizationPackage
	left join	@SectionTable pst_upd
	on			pst_upd.idfsParentSection = st.idfsSection
				and pst_upd.idfsFormType = st.idfsFormType
				and pst_upd.idfsFormTemplate = st.idfsFormTemplate
				and pst_upd.idfCustomizationPackage = st.idfCustomizationPackage
				and pst_upd.SectionOrder < pst_upd_min.SectionOrder
	left join	@ParameterTable pt_min
	on			pt_min.idfsFormType = st.idfsFormType
				and pt_min.idfsFormTemplate = st.idfsFormTemplate
				and pt_min.idfCustomizationPackage = st.idfCustomizationPackage
				and pt_min.idfsSection = st.idfsSection
				and pt_min.ParameterOrder < pst_upd_min.SectionOrder
	left join	@SectionTable pst_not_upd
	on			pst_not_upd.idfsParentSection = st.idfsSection
				and pst_not_upd.idfsFormType = st.idfsFormType
				and pst_not_upd.idfsFormTemplate = st.idfsFormTemplate
				and pst_not_upd.idfCustomizationPackage = st.idfCustomizationPackage
				and cast(pst_not_upd.SectionOrder as varchar(20)) like '%00' 
	where		cast(st.SectionOrder as varchar(20)) like '%00' 
				and pt_min.Tooltip_EN is null
				and pst_upd.idfsSection is null
				and pst_not_upd.idfsSection is null

	set	@Goon = @Goon + @@rowcount

end

update		st
set			st.SectionOrder = 0
from		@SectionTable st
where		st.idfsFormType in (10034012, 10034021, 10034022, 10034023, 10034024)	-- Aggregate Types
			and st.idfsParentSection is null

print 'Serial numbers of the sections and parameters/labels are updated.'
print ''
print ''

-- fill labels
print 'Update IDs of existing labels and generate IDs for new labels and their text in FF form templates'
-- Criteria of label existence: the same EN label text, the same section, the same template, 
-- and the same previous object (section/parameter/label)
declare @idfID							bigint
declare @idfDecorElement				bigint
declare @idfsLabelBaseReference			bigint
declare @idfExistedDecorElement			bigint
declare @idfsExistedLabelBaseReference	bigint
declare	@LabelText_EN					nvarchar(2000)
declare	@PrevParameterTooltip_EN		nvarchar(2000)
declare	@idfsPrevParameter				bigint
declare	@PrevSectionFullPath_EN			nvarchar(2000)
declare	@idfsPrevSection				bigint
declare	@PrevLabelText_EN				nvarchar(2000)
declare	@idfsPrevLabel					bigint

set @NewIdCount = 0
declare	LabelCursor Cursor local read_only forward_only for
	select		pt.idfID,
				pt.Parameter_EN,
				pt.idfsParameter,
				pt.idfParameterDesignOption,
				pt.SectionPath_EN,
				pt.idfsSection,
				pt.FormTemplate_EN,
				pt.idfsFormTemplate,
				pt.FormType_EN,
				pt.idfsFormType,
				pt.idfCustomizationPackage,
				case
					when	pt_prev_max.idfID is not null
							and pt_prev_max.ParameterType_EN <> 'Label'
							and (	(	st_prev_max.idfID is not null
										and pt_prev_max.ParameterOrder >= st_prev_max.SectionOrder
									)
									or	st_prev_max.idfID is null
								)
						then	pt_prev_max.Tooltip_EN
					else	null
				end,
				case
					when	pt_prev_max.idfID is not null
							and pt_prev_max.ParameterType_EN <> 'Label'
							and (	(	st_prev_max.idfID is not null
										and pt_prev_max.ParameterOrder >= st_prev_max.SectionOrder
									)
									or	st_prev_max.idfID is null
								)
						then	pt_prev_max.idfsParameter
					else	null
				end,
				case
					when	st_prev_max.idfID is not null
							and (	(	pt_prev_max.idfID is not null
										and st_prev_max.SectionOrder > pt_prev_max.ParameterOrder
									)
									or	pt_prev_max.idfID is null
								)
						then	st_prev_max.SectionPath_EN
					else	null
				end,
				case
					when	st_prev_max.idfID is not null
							and (	(	pt_prev_max.idfID is not null
										and st_prev_max.SectionOrder > pt_prev_max.ParameterOrder
									)
									or	pt_prev_max.idfID is null
								)
						then	st_prev_max.idfsSection
					else	null
				end,
				case
					when	pt_prev_max.idfID is not null
							and pt_prev_max.ParameterType_EN = 'Label'
							and (	(	st_prev_max.idfID is not null
										and pt_prev_max.ParameterOrder >= st_prev_max.SectionOrder
									)
									or	st_prev_max.idfID is null
								)
						then	pt_prev_max.Parameter_EN
					else	null
				end
	from		@ParameterTable pt
	left join	@ParameterTable pt_prev_max
	on			pt_prev_max.idfsFormType = pt.idfsFormType
				and pt_prev_max.idfsFormTemplate = pt.idfsFormTemplate
				and pt_prev_max.idfCustomizationPackage = pt.idfCustomizationPackage
				and IsNull(pt_prev_max.idfsSection, -1) = IsNull(pt.idfsSection, -1)
				and pt_prev_max.ParameterOrder < pt.ParameterOrder
	left join	@ParameterTable pt_prev
	on			pt_prev.idfsFormType = pt.idfsFormType
				and pt_prev.idfsFormTemplate = pt.idfsFormTemplate
				and pt_prev.idfCustomizationPackage = pt.idfCustomizationPackage
				and IsNull(pt_prev.idfsSection, -1) = IsNull(pt.idfsSection, -1)
				and pt_prev.ParameterOrder < pt.ParameterOrder
				and pt_prev.ParameterOrder > pt_prev_max.ParameterOrder
	left join	@SectionTable st_prev_max
	on			st_prev_max.idfsFormType = pt.idfsFormType
				and st_prev_max.idfsFormTemplate = pt.idfsFormTemplate
				and st_prev_max.idfCustomizationPackage = pt.idfCustomizationPackage
				and IsNull(st_prev_max.idfsParentSection, -1) = IsNull(pt.idfsSection, -1)
				and st_prev_max.SectionOrder < pt.ParameterOrder
	left join	@SectionTable st_prev
	on			st_prev.idfsFormType = pt.idfsFormType
				and st_prev.idfsFormTemplate = pt.idfsFormTemplate
				and st_prev.idfCustomizationPackage = pt.idfCustomizationPackage
				and IsNull(st_prev.idfsParentSection, -1) = IsNull(pt.idfsSection, -1)
				and st_prev.SectionOrder < pt.ParameterOrder
				and st_prev.SectionOrder > st_prev_max.SectionOrder
	where		pt.ParameterType_EN = N'Label'
				and pt_prev.idfID is null
				and st_prev.idfID is null
	order by	pt.idfCustomizationPackage,
				pt.idfsFormType,
				pt.idfsFormTemplate,
				pt.ParameterOrder
open LabelCursor
fetch next from LabelCursor into
	@idfID, 
	@LabelText_EN,
	@idfsLabelBaseReference,
	@idfDecorElement,
	@SectionPath_EN,
	@idfsSection,
	@FormTemplate_EN,
	@idfsFormTemplate,
	@FormType_EN,
	@idfsFormType,
	@idfCustomizationPackage,
	@PrevParameterTooltip_EN,
	@idfsPrevParameter,
	@PrevSectionFullPath_EN,
	@idfsPrevSection,
	@PrevLabelText_EN

while @@fetch_status <> -1
begin

	set	@idfExistedDecorElement = null
	set	@idfsExistedLabelBaseReference = null

	if	@PrevLabelText_EN is not null
	begin
		select		@idfExistedDecorElement = de.idfDecorElement,
					@idfsExistedLabelBaseReference = br.idfsBaseReference
		from		(
			trtBaseReference br
			inner join	ffDecorElementText det
			on			det.idfsBaseReference = br.idfsBaseReference
						and br.intRowStatus = 0
			inner join	ffDecorElement de
			on			de.idfDecorElement = det.idfDecorElement
						and de.idfsDecorElementType = 10106001		-- Label
						and de.idfsLanguage = dbo.fnGetLanguageCode('en')
						and de.intRowStatus = 0
			inner join	trtBaseReferenceToCP brc
			on			brc.idfsBaseReference = br.idfsBaseReference
						and brc.idfCustomizationPackage = @idfCustomizationPackage
					)
		inner join	(
			trtBaseReference br_prev
			inner join	ffDecorElementText det_prev
			on			det_prev.idfsBaseReference = br_prev.idfsBaseReference
						and br_prev.intRowStatus = 0
			inner join	ffDecorElement de_prev
			on			de_prev.idfDecorElement = det_prev.idfDecorElement
						and de_prev.idfsDecorElementType = 10106001		-- Label
						and de_prev.idfsLanguage = dbo.fnGetLanguageCode('en')
						and de_prev.intRowStatus = 0
			inner join	trtBaseReferenceToCP brc_l_prev
			on			brc_l_prev.idfsBaseReference = br_prev.idfsBaseReference
						and brc_l_prev.idfCustomizationPackage = @idfCustomizationPackage
					)
		on			br_prev.idfsReferenceType = 19000131		-- Flexible Form Label Text
					and br_prev.idfsBaseReference = @idfsPrevLabel
					and br_prev.intRowStatus = 0
					and de_prev.idfsFormTemplate = @idfsFormTemplate
					and IsNull(de_prev.idfsSection, -1) = IsNull(@idfsSection, -1)
					and det_prev.intTop < det.intTop
		left join	(
			trtBaseReference br_prev_between
			inner join	ffDecorElementText det_prev_between
			on			det_prev_between.idfsBaseReference = br_prev_between.idfsBaseReference
						and br_prev_between.intRowStatus = 0
			inner join	ffDecorElement de_prev_between
			on			de_prev_between.idfDecorElement = det_prev_between.idfDecorElement
						and de_prev_between.idfsDecorElementType = 10106001		-- Label
						and de_prev_between.idfsLanguage = dbo.fnGetLanguageCode('en')
						and de_prev_between.intRowStatus = 0
			inner join	trtBaseReferenceToCP brc_l_prev_between
			on			brc_l_prev_between.idfsBaseReference = br_prev_between.idfsBaseReference
						and brc_l_prev_between.idfCustomizationPackage = @idfCustomizationPackage
					)
		on			br_prev_between.idfsReferenceType = 19000131		-- Flexible Form Label Text
					and br_prev_between.intRowStatus = 0
					and de_prev_between.idfsFormTemplate = @idfsFormTemplate
					and IsNull(de_prev_between.idfsSection, -1) = IsNull(@idfsSection, -1)
					and det_prev_between.intTop < det.intTop
					and det_prev_between.intTop > det_prev.intTop
		left join	(
			ffSectionDesignOption sdo_prev_between
			inner join	ffSection s_prev_between
			on			s_prev_between.idfsSection = sdo_prev_between.idfsSection
						and IsNull(s_prev_between.idfsParentSection, -1) = IsNull(@idfsSection, -1)
						and s_prev_between.idfsFormType = @idfsFormType
						and s_prev_between.intRowStatus = 0
			inner join	trtBaseReferenceToCP brc_s_prev_between
			on			brc_s_prev_between.idfsBaseReference = s_prev_between.idfsSection
						and brc_s_prev_between.idfCustomizationPackage = @idfCustomizationPackage
					)			
		on			sdo_prev_between.idfsFormTemplate = @idfsFormTemplate
					and sdo_prev_between.idfsLanguage = dbo.fnGetLanguageCode('en')
					and sdo_prev_between.intRowStatus = 0
					and sdo_prev_between.intTop < det.intTop
					and sdo_prev_between.intTop > det_prev.intTop
		left join	(
			ffParameterDesignOption pdo_prev_between
			inner join	ffParameter p_prev_between
			on			p_prev_between.idfsParameter = pdo_prev_between.idfsParameter
						and IsNull(p_prev_between.idfsSection, -1) = IsNull(@idfsSection, -1)
						and p_prev_between.idfsFormType = @idfsFormType
						and p_prev_between.intRowStatus = 0
			inner join	trtBaseReferenceToCP brc_p_prev_between
			on			brc_p_prev_between.idfsBaseReference = p_prev_between.idfsParameter
						and brc_p_prev_between.idfCustomizationPackage = @idfCustomizationPackage
					)			
		on			pdo_prev_between.idfsFormTemplate = @idfsFormTemplate
					and pdo_prev_between.idfsLanguage = dbo.fnGetLanguageCode('en')
					and pdo_prev_between.intRowStatus = 0
					and pdo_prev_between.intTop < det.intTop
					and pdo_prev_between.intTop > det_prev.intTop
		where		br.idfsReferenceType = 19000131		-- Flexible Form Label Text
					and br.strDefault = @LabelText_EN
					and br.intRowStatus = 0
					and de.idfsFormTemplate = @idfsFormTemplate
					and IsNull(de.idfsSection, -1) = IsNull(@idfsSection, -1)
					and de_prev_between.idfDecorElement is null
					and sdo_prev_between.idfSectionDesignOption is null
					and pdo_prev_between.idfParameterDesignOption is null
	end


	if	@PrevParameterTooltip_EN is not null
	begin
		select		@idfExistedDecorElement = de.idfDecorElement,
					@idfsExistedLabelBaseReference = br.idfsBaseReference
		from		(
			trtBaseReference br
			inner join	ffDecorElementText det
			on			det.idfsBaseReference = br.idfsBaseReference
						and br.intRowStatus = 0
			inner join	ffDecorElement de
			on			de.idfDecorElement = det.idfDecorElement
						and de.idfsDecorElementType = 10106001		-- Label
						and de.idfsLanguage = dbo.fnGetLanguageCode('en')
						and de.intRowStatus = 0
			inner join	trtBaseReferenceToCP brc
			on			brc.idfsBaseReference = br.idfsBaseReference
						and brc.idfCustomizationPackage = @idfCustomizationPackage
					)
		inner join	(
			ffParameterDesignOption pdo_prev
			inner join	ffParameter p_prev
			on			p_prev.idfsParameter = pdo_prev.idfsParameter
						and IsNull(p_prev.idfsSection, -1) = IsNull(@idfsSection, -1)
						and p_prev.idfsFormType = @idfsFormType
						and p_prev.intRowStatus = 0
			inner join	trtBaseReferenceToCP brc_p_prev
			on			brc_p_prev.idfsBaseReference = p_prev.idfsParameter
						and brc_p_prev.idfCustomizationPackage = @idfCustomizationPackage
					)			
		on			pdo_prev.idfsFormTemplate = @idfsFormTemplate
					and pdo_prev.idfsParameter = @idfsPrevParameter
					and pdo_prev.idfsLanguage = dbo.fnGetLanguageCode('en')
					and pdo_prev.intRowStatus = 0
					and pdo_prev.intTop < det.intTop
		left join	(
			trtBaseReference br_prev_between
			inner join	ffDecorElementText det_prev_between
			on			det_prev_between.idfsBaseReference = br_prev_between.idfsBaseReference
						and br_prev_between.intRowStatus = 0
			inner join	ffDecorElement de_prev_between
			on			de_prev_between.idfDecorElement = det_prev_between.idfDecorElement
						and de_prev_between.idfsDecorElementType = 10106001		-- Label
						and de_prev_between.idfsLanguage = dbo.fnGetLanguageCode('en')
						and de_prev_between.intRowStatus = 0
			inner join	trtBaseReferenceToCP brc_l_prev_between
			on			brc_l_prev_between.idfsBaseReference = br_prev_between.idfsBaseReference
						and brc_l_prev_between.idfCustomizationPackage = @idfCustomizationPackage
					)
		on			br_prev_between.idfsReferenceType = 19000131		-- Flexible Form Label Text
					and br_prev_between.intRowStatus = 0
					and de_prev_between.idfsFormTemplate = @idfsFormTemplate
					and IsNull(de_prev_between.idfsSection, -1) = IsNull(@idfsSection, -1)
					and det_prev_between.intTop < det.intTop
					and det_prev_between.intTop > pdo_prev.intTop
		left join	(
			ffSectionDesignOption sdo_prev_between
			inner join	ffSection s_prev_between
			on			s_prev_between.idfsSection = sdo_prev_between.idfsSection
						and IsNull(s_prev_between.idfsParentSection, -1) = IsNull(@idfsSection, -1)
						and s_prev_between.idfsFormType = @idfsFormType
						and s_prev_between.intRowStatus = 0
			inner join	trtBaseReferenceToCP brc_s_prev_between
			on			brc_s_prev_between.idfsBaseReference = s_prev_between.idfsSection
						and brc_s_prev_between.idfCustomizationPackage = @idfCustomizationPackage
					)			
		on			sdo_prev_between.idfsFormTemplate = @idfsFormTemplate
					and sdo_prev_between.idfsLanguage = dbo.fnGetLanguageCode('en')
					and sdo_prev_between.intRowStatus = 0
					and sdo_prev_between.intTop < det.intTop
					and sdo_prev_between.intTop > pdo_prev.intTop
		left join	(
			ffParameterDesignOption pdo_prev_between
			inner join	ffParameter p_prev_between
			on			p_prev_between.idfsParameter = pdo_prev_between.idfsParameter
						and IsNull(p_prev_between.idfsSection, -1) = IsNull(@idfsSection, -1)
						and p_prev_between.idfsFormType = @idfsFormType
						and p_prev_between.intRowStatus = 0
			inner join	trtBaseReferenceToCP brc_p_prev_between
			on			brc_p_prev_between.idfsBaseReference = p_prev_between.idfsParameter
						and brc_p_prev_between.idfCustomizationPackage = @idfCustomizationPackage
					)			
		on			pdo_prev_between.idfsFormTemplate = @idfsFormTemplate
					and pdo_prev_between.idfsLanguage = dbo.fnGetLanguageCode('en')
					and pdo_prev_between.intRowStatus = 0
					and pdo_prev_between.intTop < det.intTop
					and pdo_prev_between.intTop > pdo_prev.intTop
		where		br.idfsReferenceType = 19000131		-- Flexible Form Label Text
					and br.strDefault = @LabelText_EN
					and br.intRowStatus = 0
					and de.idfsFormTemplate = @idfsFormTemplate
					and IsNull(de.idfsSection, -1) = IsNull(@idfsSection, -1)
					and de_prev_between.idfDecorElement is null
					and sdo_prev_between.idfSectionDesignOption is null
					and pdo_prev_between.idfParameterDesignOption is null
	end


	if	@PrevSectionFullPath_EN is not null
	begin
		select		@idfExistedDecorElement = de.idfDecorElement,
					@idfsExistedLabelBaseReference = br.idfsBaseReference
		from		(
			trtBaseReference br
			inner join	ffDecorElementText det
			on			det.idfsBaseReference = br.idfsBaseReference
						and br.intRowStatus = 0
			inner join	ffDecorElement de
			on			de.idfDecorElement = det.idfDecorElement
						and de.idfsDecorElementType = 10106001		-- Label
						and de.idfsLanguage = dbo.fnGetLanguageCode('en')
						and de.intRowStatus = 0
			inner join	trtBaseReferenceToCP brc
			on			brc.idfsBaseReference = br.idfsBaseReference
						and brc.idfCustomizationPackage = @idfCustomizationPackage
					)
		inner join	(
			ffSectionDesignOption sdo_prev
			inner join	ffSection s_prev
			on			s_prev.idfsSection = sdo_prev.idfsSection
						and IsNull(s_prev.idfsParentSection, -1) = IsNull(@idfsSection, -1)
						and s_prev.idfsFormType = @idfsFormType
						and s_prev.intRowStatus = 0
			inner join	trtBaseReferenceToCP brc_s_prev
			on			brc_s_prev.idfsBaseReference = s_prev.idfsSection
						and brc_s_prev.idfCustomizationPackage = @idfCustomizationPackage
					)			
		on			sdo_prev.idfsFormTemplate = @idfsFormTemplate
					and sdo_prev.idfsSection = @idfsPrevSection
					and sdo_prev.idfsLanguage = dbo.fnGetLanguageCode('en')
					and sdo_prev.intRowStatus = 0
					and sdo_prev.intTop < det.intTop
		left join	(
			trtBaseReference br_prev_between
			inner join	ffDecorElementText det_prev_between
			on			det_prev_between.idfsBaseReference = br_prev_between.idfsBaseReference
						and br_prev_between.intRowStatus = 0
			inner join	ffDecorElement de_prev_between
			on			de_prev_between.idfDecorElement = det_prev_between.idfDecorElement
						and de_prev_between.idfsDecorElementType = 10106001		-- Label
						and de_prev_between.idfsLanguage = dbo.fnGetLanguageCode('en')
						and de_prev_between.intRowStatus = 0
			inner join	trtBaseReferenceToCP brc_l_prev_between
			on			brc_l_prev_between.idfsBaseReference = br_prev_between.idfsBaseReference
						and brc_l_prev_between.idfCustomizationPackage = @idfCustomizationPackage
					)
		on			br_prev_between.idfsReferenceType = 19000131		-- Flexible Form Label Text
					and br_prev_between.intRowStatus = 0
					and de_prev_between.idfsFormTemplate = @idfsFormTemplate
					and IsNull(de_prev_between.idfsSection, -1) = IsNull(@idfsSection, -1)
					and det_prev_between.intTop < det.intTop
					and det_prev_between.intTop > sdo_prev.intTop
		left join	(
			ffSectionDesignOption sdo_prev_between
			inner join	ffSection s_prev_between
			on			s_prev_between.idfsSection = sdo_prev_between.idfsSection
						and IsNull(s_prev_between.idfsParentSection, -1) = IsNull(@idfsSection, -1)
						and s_prev_between.idfsFormType = @idfsFormType
						and s_prev_between.intRowStatus = 0
			inner join	trtBaseReferenceToCP brc_s_prev_between
			on			brc_s_prev_between.idfsBaseReference = s_prev_between.idfsSection
						and brc_s_prev_between.idfCustomizationPackage = @idfCustomizationPackage
					)			
		on			sdo_prev_between.idfsFormTemplate = @idfsFormTemplate
					and sdo_prev_between.idfsLanguage = dbo.fnGetLanguageCode('en')
					and sdo_prev_between.intRowStatus = 0
					and sdo_prev_between.intTop < det.intTop
					and sdo_prev_between.intTop > sdo_prev.intTop
		left join	(
			ffParameterDesignOption pdo_prev_between
			inner join	ffParameter p_prev_between
			on			p_prev_between.idfsParameter = pdo_prev_between.idfsParameter
						and IsNull(p_prev_between.idfsSection, -1) = IsNull(@idfsSection, -1)
						and p_prev_between.idfsFormType = @idfsFormType
						and p_prev_between.intRowStatus = 0
			inner join	trtBaseReferenceToCP brc_p_prev_between
			on			brc_p_prev_between.idfsBaseReference = p_prev_between.idfsParameter
						and brc_p_prev_between.idfCustomizationPackage = @idfCustomizationPackage
					)			
		on			pdo_prev_between.idfsFormTemplate = @idfsFormTemplate
					and pdo_prev_between.idfsLanguage = dbo.fnGetLanguageCode('en')
					and pdo_prev_between.intRowStatus = 0
					and pdo_prev_between.intTop < det.intTop
					and pdo_prev_between.intTop > sdo_prev.intTop
		where		br.idfsReferenceType = 19000131		-- Flexible Form Label Text
					and br.strDefault = @LabelText_EN
					and br.intRowStatus = 0
					and de.idfsFormTemplate = @idfsFormTemplate
					and IsNull(de.idfsSection, -1) = IsNull(@idfsSection, -1)
					and de_prev_between.idfDecorElement is null
					and sdo_prev_between.idfSectionDesignOption is null
					and pdo_prev_between.idfParameterDesignOption is null
	end
	
	if	@PrevLabelText_EN is null and @PrevSectionFullPath_EN is null and @PrevParameterTooltip_EN is null
	begin
		select		@idfExistedDecorElement = de.idfDecorElement,
					@idfsExistedLabelBaseReference = br.idfsBaseReference
		from		(
			trtBaseReference br
			inner join	ffDecorElementText det
			on			det.idfsBaseReference = br.idfsBaseReference
						and br.intRowStatus = 0
			inner join	ffDecorElement de
			on			de.idfDecorElement = det.idfDecorElement
						and de.idfsDecorElementType = 10106001		-- Label
						and de.idfsLanguage = dbo.fnGetLanguageCode('en')
						and de.intRowStatus = 0
			inner join	trtBaseReferenceToCP brc
			on			brc.idfsBaseReference = br.idfsBaseReference
						and brc.idfCustomizationPackage = @idfCustomizationPackage
					)
		left join	(
			trtBaseReference br_prev_between
			inner join	ffDecorElementText det_prev_between
			on			det_prev_between.idfsBaseReference = br_prev_between.idfsBaseReference
						and br_prev_between.intRowStatus = 0
			inner join	ffDecorElement de_prev_between
			on			de_prev_between.idfDecorElement = det_prev_between.idfDecorElement
						and de_prev_between.idfsDecorElementType = 10106001		-- Label
						and de_prev_between.idfsLanguage = dbo.fnGetLanguageCode('en')
						and de_prev_between.intRowStatus = 0
			inner join	trtBaseReferenceToCP brc_l_prev_between
			on			brc_l_prev_between.idfsBaseReference = br_prev_between.idfsBaseReference
						and brc_l_prev_between.idfCustomizationPackage = @idfCustomizationPackage
					)
		on			br_prev_between.idfsReferenceType = 19000131		-- Flexible Form Label Text
					and br_prev_between.intRowStatus = 0
					and de_prev_between.idfsFormTemplate = @idfsFormTemplate
					and IsNull(de_prev_between.idfsSection, -1) = IsNull(@idfsSection, -1)
					and det_prev_between.intTop < det.intTop
		left join	(
			ffSectionDesignOption sdo_prev_between
			inner join	ffSection s_prev_between
			on			s_prev_between.idfsSection = sdo_prev_between.idfsSection
						and IsNull(s_prev_between.idfsParentSection, -1) = IsNull(@idfsSection, -1)
						and s_prev_between.idfsFormType = @idfsFormType
						and s_prev_between.intRowStatus = 0
			inner join	trtBaseReferenceToCP brc_s_prev_between
			on			brc_s_prev_between.idfsBaseReference = s_prev_between.idfsSection
						and brc_s_prev_between.idfCustomizationPackage = @idfCustomizationPackage
					)			
		on			sdo_prev_between.idfsFormTemplate = @idfsFormTemplate
					and sdo_prev_between.idfsLanguage = dbo.fnGetLanguageCode('en')
					and sdo_prev_between.intRowStatus = 0
					and sdo_prev_between.intTop < det.intTop
		left join	(
			ffParameterDesignOption pdo_prev_between
			inner join	ffParameter p_prev_between
			on			p_prev_between.idfsParameter = pdo_prev_between.idfsParameter
						and IsNull(p_prev_between.idfsSection, -1) = IsNull(@idfsSection, -1)
						and p_prev_between.idfsFormType = @idfsFormType
						and p_prev_between.intRowStatus = 0
			inner join	trtBaseReferenceToCP brc_p_prev_between
			on			brc_p_prev_between.idfsBaseReference = p_prev_between.idfsParameter
						and brc_p_prev_between.idfCustomizationPackage = @idfCustomizationPackage
					)			
		on			pdo_prev_between.idfsFormTemplate = @idfsFormTemplate
					and pdo_prev_between.idfsLanguage = dbo.fnGetLanguageCode('en')
					and pdo_prev_between.intRowStatus = 0
					and pdo_prev_between.intTop < det.intTop
		where		br.idfsReferenceType = 19000131		-- Flexible Form Label Text
					and br.strDefault = @LabelText_EN
					and br.intRowStatus = 0
					and de.idfsFormTemplate = @idfsFormTemplate
					and IsNull(de.idfsSection, -1) = IsNull(@idfsSection, -1)
					and de_prev_between.idfDecorElement is null
					and sdo_prev_between.idfSectionDesignOption is null
					and pdo_prev_between.idfParameterDesignOption is null		
	end

	if	@idfExistedDecorElement is not null and @idfsExistedLabelBaseReference is not null
	begin
		update	pt
		set		pt.idfsParameter = isnull(pt.idfsParameter, @idfsExistedLabelBaseReference),
				pt.idfParameterDesignOption = isnull(pt.idfParameterDesignOption, @idfExistedDecorElement)
		from	@ParameterTable pt
		where	pt.idfID = @idfID
		
		set	@idfDecorElement = isnull(@idfDecorElement, @idfExistedDecorElement)
		set	@idfsLabelBaseReference = isnull(@idfsLabelBaseReference, @idfsExistedLabelBaseReference)
	end

	if @idfDecorElement is null
	begin
		exec spsysGetNewID @idfDecorElement output

		print N''
		if	IsNull(@SectionPath_EN, N'') = N''
			print N'ID for the new label with text [' + replace(@LabelText_EN, N'''', N'''''') + N'] 
in the template [' + replace(@FormTemplate_EN, N'''', N'''''') + N'] of type [' + replace(@FormType_EN, N'''', N'''''') + N'] is generated'
		else
			print N'ID for the new label with text [' + replace(@LabelText_EN, N'''', N'''''') + N'] in the section with full path [' + replace(@SectionPath_EN, N'''', N'''''') + N']
of the template [' + replace(@FormTemplate_EN, N'''', N'''''') + N'] of type [' + replace(@FormType_EN, N'''', N'''''') + N'] is generated'
			
		set	@NewIdCount = @NewIdCount + 1

		update	pt
		set		pt.idfParameterDesignOption = @idfDecorElement
		from	@ParameterTable pt
		where	pt.idfID = @idfID

	end

	if @idfsLabelBaseReference is null
	begin
		exec spsysGetNewID @idfsLabelBaseReference output

		print N''
		if	IsNull(@SectionPath_EN, N'') = N''
			print N'ID for the text value of the label [' + replace(@LabelText_EN, N'''', N'''''') + N'] 
in the template [' + replace(@FormTemplate_EN, N'''', N'''''') + N'] of type [' + replace(@FormType_EN, N'''', N'''''') + N'] is generated'
		else
			print N'ID for the text value of the label [' + replace(@LabelText_EN, N'''', N'''''') + N'] in the section with full path [' + replace(@SectionPath_EN, N'''', N'''''') + N']
of the template [' + replace(@FormTemplate_EN, N'''', N'''''') + N'] of type [' + replace(@FormType_EN, N'''', N'''''') + N'] is generated'
			
		set	@NewIdCount = @NewIdCount + 1

		update	pt
		set		pt.idfsParameter = @idfsLabelBaseReference
		from	@ParameterTable pt
		where	pt.idfID = @idfID

	end
	
	set	@idfsPrevLabel = @idfsLabelBaseReference

	fetch next from LabelCursor into 
		@idfID,
		@LabelText_EN,
		@idfsLabelBaseReference,
		@idfDecorElement,
		@SectionPath_EN,
		@idfsSection,
		@FormTemplate_EN,
		@idfsFormTemplate,
		@FormType_EN,
		@idfsFormType,
		@idfCustomizationPackage,
		@PrevParameterTooltip_EN,
		@idfsPrevParameter,
		@PrevSectionFullPath_EN,
		@idfsPrevSection,
		@PrevLabelText_EN

end
close LabelCursor
deallocate LabelCursor 
if	@NewIdCount = 0
	print 'No new ID is needed.'
print ''
print ''

--select		pt.idfParameterDesignOption,
--			pt.idfsParameter,
--			pt.idfsFormTemplate,
--			pt.idfsSection,
--			pt.Parameter_EN,
--			pt.Parameter_RU,
--			pt.Parameter_AZ,
--			pt.Parameter_GG,
--			pt.Parameter_KZ,
--			pt.Parameter_IQ,
--			pt.Parameter_UA,
--			pt.Parameter_TH,
--			pt.ParameterOrder,
--			pt.idfCustomizationPackage
--from		@ParameterTable pt
--where		pt.ParameterType_EN = 'Label'
--and pt.idfsFormTemplate is null


insert into	@LabelTable
(	idfDecorElement,
	idfsBaseReference,
	idfsFormTemplate,
	idfsSection,
	Label_EN,
	Label_AM,
	Label_AZ,
	Label_GG,
	Label_KZ,
	Label_IQ,
	Label_RU,
	Label_UA,
	Label_TH,
	LabelOrder,
	idfCustomizationPackage
)
select		pt.idfParameterDesignOption,
			pt.idfsParameter,
			pt.idfsFormTemplate,
			pt.idfsSection,
			pt.Parameter_EN,
			pt.Parameter_AM,
			pt.Parameter_AZ,
			pt.Parameter_GG,
			pt.Parameter_KZ,
			pt.Parameter_IQ,
			pt.Parameter_RU,
			pt.Parameter_UA,
			pt.Parameter_TH,
			pt.ParameterOrder,
			pt.idfCustomizationPackage
from		@ParameterTable pt
where		pt.ParameterType_EN = 'Label'
print 'Rows, containing Labels, with updated IDs: ' + cast(@@rowcount as varchar(20))
print ''
print ''


-- delete incorrect records linked to the specified customization packages and form types in the formats

insert into	@FormTypeAndCountryToCustomize
(	idfsFormType,
	idfCustomizationPackage
)
select	distinct
			pt.idfsFormType,
			pt.idfCustomizationPackage
from		@ParameterTable pt
where		pt.idfsFormType is not null
			and pt.idfCustomizationPackage is not null

-- Define the table, containing FF references to delete
declare	@ffBRToDel	table
(	idfsBaseReference	bigint not null primary key
)

-- Define the table, containing FF labels to delete
declare	@LabelToDel	table
(	idfDecorElement	bigint not null primary key
)

-- Define the table, containing FF parameters to delete
declare	@ParameterToDel	table
(	idfsParameter	bigint not null primary key
)

-- Define the table, containing FF sections to delete
declare	@SectionToDel	table
(	idfsSection	bigint not null primary key
)

if @PerformDeletions = 1
begin

	print	''
	print	'Mark incorrect records as deleted'
	print	''

	-- Labels' text to delete
	insert into	@ffBRToDel	(idfsBaseReference)
	select distinct
				br.idfsBaseReference
	from		ffDecorElementText det
	inner join	trtBaseReference br
	on			br.idfsBaseReference = det.idfsBaseReference
	inner join	trtBaseReferenceToCP brc
	on			brc.idfsBaseReference = br.idfsBaseReference
	inner join	ffDecorElement de
	on			de.idfDecorElement = det.idfDecorElement
	inner join	ffFormTemplate t
	on			t.idfsFormTemplate = de.idfsFormTemplate
	inner join	@FormTypeAndCountryToCustomize ftc
	on			ftc.idfsFormType = t.idfsFormType
				and ftc.idfCustomizationPackage = brc.idfCustomizationPackage
	left join	@LabelTable lt
	on			lt.idfsBaseReference = br.idfsBaseReference
	where		not exists	(
						select		*
						from		ffDecorElementText det_another
						inner join	trtBaseReference br_another
						on			br_another.idfsBaseReference = det_another.idfsBaseReference
						inner join	trtBaseReferenceToCP brc_another
						on			brc_another.idfsBaseReference = br_another.idfsBaseReference
						inner join	ffDecorElement de_another
						on			de_another.idfDecorElement = det_another.idfDecorElement
						inner join	ffFormTemplate t_another
						on			t_another.idfsFormTemplate = de_another.idfsFormTemplate
						left join	@FormTypeAndCountryToCustomize ftc_another
						on			ftc_another.idfsFormType = t_another.idfsFormType
									and ftc_another.idfCustomizationPackage = brc_another.idfCustomizationPackage
						where		br_another.idfsBaseReference = br.idfsBaseReference
									and	ftc_another.idfCustomizationPackage is null
							)
				and	lt.Label_EN is null


	-- Labels to delete
	insert into	@LabelToDel (idfDecorElement)
	select		de.idfDecorElement
	from		ffDecorElementText det
	inner join	trtBaseReference br
	on			br.idfsBaseReference = det.idfsBaseReference
	inner join	trtBaseReferenceToCP brc
	on			brc.idfsBaseReference = br.idfsBaseReference
	inner join	ffDecorElement de
	on			de.idfDecorElement = det.idfDecorElement
	inner join	ffFormTemplate t
	on			t.idfsFormTemplate = de.idfsFormTemplate
	inner join	@FormTypeAndCountryToCustomize ftc
	on			ftc.idfsFormType = t.idfsFormType
				and ftc.idfCustomizationPackage = brc.idfCustomizationPackage
	left join	@LabelTable lt
	on			lt.idfDecorElement = de.idfDecorElement
	where		not exists	(
						select		*
						from		ffDecorElementText det_another
						inner join	trtBaseReference br_another
						on			br_another.idfsBaseReference = det_another.idfsBaseReference
						inner join	trtBaseReferenceToCP brc_another
						on			brc_another.idfsBaseReference = br_another.idfsBaseReference
						inner join	ffDecorElement de_another
						on			de_another.idfDecorElement = det_another.idfDecorElement
						inner join	ffFormTemplate t_another
						on			t_another.idfsFormTemplate = de_another.idfsFormTemplate
						left join	@FormTypeAndCountryToCustomize ftc_another
						on			ftc_another.idfsFormType = t_another.idfsFormType
									and ftc_another.idfCustomizationPackage = brc_another.idfCustomizationPackage
						where		de_another.idfDecorElement = de.idfDecorElement
									and	ftc_another.idfCustomizationPackage is null
							)
				and	lt.Label_EN is null

	update		det
	set			det.intRowStatus = 1
	from		ffDecorElementText det
	inner join	@LabelToDel l_del
	on			l_del.idfDecorElement = det.idfDecorElement
	where		det.intRowStatus <> 1
	print	'Labels (ffDecorElementText) - mark as deleted: ' + cast(@@rowcount as varchar(20))

	update		de
	set			de.intRowStatus = 1
	from		ffDecorElement de
	inner join	@LabelToDel l_del
	on			l_del.idfDecorElement = de.idfDecorElement
	where		de.intRowStatus <> 1
	print	'Labels (ffDecorElement) - mark as deleted: ' + cast(@@rowcount as varchar(20))

	-- Sections to delete
	insert into	@SectionToDel (idfsSection)
	select		s.idfsSection
	from		ffSection s
	inner join	trtBaseReferenceToCP brc
	on			brc.idfsBaseReference = s.idfsSection
	inner join	@FormTypeAndCountryToCustomize ftc
	on			ftc.idfsFormType = s.idfsFormType
				and ftc.idfCustomizationPackage = brc.idfCustomizationPackage
	left join	@SectionTable st
	on			st.idfsSection = s.idfsSection
	where		not exists	(
						select		*
						from		ffSection s_another
						inner join	trtBaseReferenceToCP brc_another
						on			brc_another.idfsBaseReference = s_another.idfsSection
						left join	@FormTypeAndCountryToCustomize ftc_another
						on			ftc_another.idfsFormType = s_another.idfsFormType
									and ftc_another.idfCustomizationPackage = brc_another.idfCustomizationPackage
						where		s_another.idfsSection = s.idfsSection
									and	ftc_another.idfCustomizationPackage is null
							)
				and st.idfsSection not in
					(	71460000000,	-- Diagnostic investigations: Diagnostic investigations
						71190000000,	-- Human Aggregate Case: Human Aggregate Case
						71300000000,	-- Treatment-prophylactics and vaccination measures: Treatment-prophylactics and vaccination measures
						71090000000,	-- Vet Aggregate Case: Vet Aggregate Case
						71260000000		-- Veterinary-sanitary measures: Veterinary-sanitary measures
					)
				and	st.idfID is null

	-- Sections' names to delete
	insert into	@ffBRToDel (idfsBaseReference)
	select		s.idfsSection
	from		ffSection s
	inner join	@SectionToDel s_del
	on			s_del.idfsSection = s.idfsSection
	left join	@ffBRToDel br_del
	on			br_del.idfsBaseReference = s.idfsSection
	where		br_del.idfsBaseReference is null

	-- Parameters to delete
	insert into	@ParameterToDel	(idfsParameter)
	select		p.idfsParameter
	from		ffParameter p
	inner join	trtBaseReferenceToCP brc
	on			brc.idfsBaseReference = p.idfsParameter
	inner join	@FormTypeAndCountryToCustomize ftc
	on			ftc.idfsFormType = p.idfsFormType
				and ftc.idfCustomizationPackage = brc.idfCustomizationPackage
	left join	@ParameterTable pt
	on			pt.idfsParameter = p.idfsParameter
	where		not exists	(
						select		*
						from		ffParameter p_another
						inner join	trtBaseReferenceToCP brc_another
						on			brc_another.idfsBaseReference = p_another.idfsParameter
						left join	@FormTypeAndCountryToCustomize ftc_another
						on			ftc_another.idfsFormType = p_another.idfsFormType
									and ftc_another.idfCustomizationPackage = brc_another.idfCustomizationPackage
						where		p_another.idfsParameter = p.idfsParameter
									and	ftc_another.idfCustomizationPackage is null
							)
				and pt.idfsParameter not in
					(	226930000000,	-- Diagnostic investigations: Diagnosis
						231670000000,	-- Diagnostic investigations: Investigation type
						234430000000,	-- Diagnostic investigations: OIE Code
						239030000000,	-- Diagnostic investigations: Species
						226890000000,	-- Human Aggregate Case: Diagnosis
						229630000000,	-- Human Aggregate Case: ICD-10 Code
						226950000000,	-- Treatment-prophylactics and vaccination measures: Diagnosis
						233170000000,	-- Treatment-prophylactics and vaccination measures: Measure Code
						245270000000,	-- Treatment-prophylactics and vaccination measures: Measure Type
						234450000000,	-- Treatment-prophylactics and vaccination measures: OIE Code
						239050000000,	-- Treatment-prophylactics and vaccination measures: Species
						226910000000,	-- Vet Aggregate Case: Diagnosis
						234410000000,	-- Vet Aggregate Case: OIE Code
						239010000000,	-- Vet Aggregate Case: Species
						233150000000,	-- Veterinary-sanitary measures: Measure Code
						233190000000	-- Veterinary-sanitary measures: Measure Type
					)
				and	pt.idfID is null

	-- Parameters' tooltips to delete
	insert into	@ffBRToDel (idfsBaseReference)
	select		p.idfsParameter
	from		ffParameter p
	inner join	@ParameterToDel p_del
	on			p_del.idfsParameter = p.idfsParameter
	left join	@ffBRToDel br_del
	on			br_del.idfsBaseReference = p.idfsParameter
	where		br_del.idfsBaseReference is null

	-- Parameters' captions to delete
	insert into	@ffBRToDel (idfsBaseReference)
	select		p.idfsParameterCaption
	from		ffParameter p
	inner join	@ParameterToDel p_del
	on			p_del.idfsParameter = p.idfsParameter
	left join	@ffBRToDel br_del
	on			br_del.idfsBaseReference = p.idfsParameterCaption
	where		br_del.idfsBaseReference is null

	update		sfa
	set			sfa.intRowStatus = 1
	from		ffSectionForAction sfa
	inner join	@SectionToDel s_del
	on			s_del.idfsSection = sfa.idfsSection
	where		sfa.intRowStatus <> 1
	print	'Rules'' actions with sections to be deleted from the list of sections (ffSectionForAction) - mark as deleted: ' + cast(@@rowcount as varchar(20))

	update		sfa
	set			sfa.intRowStatus = 1
	from		ffSectionForAction sfa
	inner join	ffFormTemplate t
	on			t.idfsFormTemplate = sfa.idfsFormTemplate
	inner join	trtBaseReferenceToCP brc
	on			brc.idfsBaseReference = t.idfsFormTemplate
	inner join	@FormTypeAndCountryToCustomize ftc
	on			ftc.idfsFormType = t.idfsFormType
				and ftc.idfCustomizationPackage = brc.idfCustomizationPackage
	left join	@SectionToDel s_del
	on			s_del.idfsSection = sfa.idfsSection
	where		sfa.intRowStatus <> 1
				and s_del.idfsSection is null
				and	not exists	(
							select	*
							from	@SectionTable st
							where	st.idfsFormTemplate = t.idfsFormTemplate
									and st.idfsSection = sfa.idfsSection
								)
	print	'Rules'' actions with sections on templates, from which corresponding sections shall be removed (ffSectionForAction) - mark as deleted: ' + cast(@@rowcount as varchar(20))

	update		pfa
	set			pfa.intRowStatus = 1
	from		ffParameterForAction pfa
	inner join	@ParameterToDel p_del
	on			p_del.idfsParameter = pfa.idfsParameter
	where		pfa.intRowStatus <> 1
	print	'Rules'' actions with parameters to be deleted from the list of parameters (ffParameterForAction) - mark as deleted: ' + cast(@@rowcount as varchar(20))

	update		pfa
	set			pfa.intRowStatus = 1
	from		ffParameterForAction pfa
	inner join	ffFormTemplate t
	on			t.idfsFormTemplate = pfa.idfsFormTemplate
	inner join	trtBaseReferenceToCP brc
	on			brc.idfsBaseReference = t.idfsFormTemplate
	inner join	@FormTypeAndCountryToCustomize ftc
	on			ftc.idfsFormType = t.idfsFormType
				and ftc.idfCustomizationPackage = brc.idfCustomizationPackage
	left join	@ParameterToDel p_del
	on			p_del.idfsParameter = pfa.idfsParameter
	where		pfa.intRowStatus <> 1
				and p_del.idfsParameter is null
				and	not exists	(
							select	*
							from	@ParameterTable pt
							where	pt.idfsFormTemplate = t.idfsFormTemplate
									and pt.idfsParameter = pfa.idfsParameter
								)
	print	'Rules'' actions with parameters on templates, from which corresponding parameters shall be removed (ffParameterForAction) - mark as deleted: ' + cast(@@rowcount as varchar(20))

	update		pff
	set			pff.intRowStatus = 1
	from		ffParameterForFunction pff
	inner join	@ParameterToDel p_del
	on			p_del.idfsParameter = pff.idfsParameter
	where		pff.intRowStatus <> 1
	print	'Prameters'' variables of the rules to be deleted from the list of parameters (ffParameterForFunction) - mark as deleted: ' + cast(@@rowcount as varchar(20))

	update		pff
	set			pff.intRowStatus = 1
	from		ffParameterForFunction pff
	inner join	ffFormTemplate t
	on			t.idfsFormTemplate = pff.idfsFormTemplate
	inner join	trtBaseReferenceToCP brc
	on			brc.idfsBaseReference = t.idfsFormTemplate
	inner join	@FormTypeAndCountryToCustomize ftc
	on			ftc.idfsFormType = t.idfsFormType
				and ftc.idfCustomizationPackage = brc.idfCustomizationPackage
	left join	@ParameterToDel p_del
	on			p_del.idfsParameter = pff.idfsParameter
	where		pff.intRowStatus <> 1
				and p_del.idfsParameter is null
				and	not exists	(
							select	*
							from	@ParameterTable pt
							where	pt.idfsFormTemplate = t.idfsFormTemplate
									and pt.idfsParameter = pff.idfsParameter
								)
	print	'Prameters'' variables of the rules for the templates, from which corresponding parameters shall be removed (ffParameterForAction) - mark as deleted: ' + cast(@@rowcount as varchar(20))

	update		pdo
	set			pdo.intRowStatus = 1
	from		ffParameterDesignOption pdo
	inner join	@ParameterToDel p_del
	on			p_del.idfsParameter = pdo.idfsParameter
	where		pdo.intRowStatus <> 1
				and pdo.idfsFormTemplate is null
	print	'Default design options of the parameters to be deleted from the list of parameters (ffParameterDesignOption) - mark as deleted: ' + cast(@@rowcount as varchar(20))

	update		pdo
	set			pdo.intRowStatus = 1
	from		ffParameterDesignOption pdo
	inner join	@ParameterToDel p_del
	on			p_del.idfsParameter = pdo.idfsParameter
	where		pdo.intRowStatus <> 1
				and pdo.idfsFormTemplate is not null
	print	'Design options of the parameters on the templates to be deleted from the list of parameters (ffParameterDesignOption) - mark as deleted: ' + cast(@@rowcount as varchar(20))

	update		pdo
	set			pdo.intRowStatus = 1
	from		ffParameterDesignOption pdo
	inner join	ffFormTemplate t
	on			t.idfsFormTemplate = pdo.idfsFormTemplate
	inner join	trtBaseReferenceToCP brc
	on			brc.idfsBaseReference = t.idfsFormTemplate
	inner join	@FormTypeAndCountryToCustomize ftc
	on			ftc.idfsFormType = t.idfsFormType
				and ftc.idfCustomizationPackage = brc.idfCustomizationPackage
	left join	@ParameterToDel p_del
	on			p_del.idfsParameter = pdo.idfsParameter
	where		pdo.intRowStatus <> 1
				and p_del.idfsParameter is null
				and	not exists	(
							select	*
							from	@ParameterTable pt
							where	pt.idfsFormTemplate = t.idfsFormTemplate
									and pt.idfsParameter = pdo.idfsParameter
								)
	print	'Design options of the parameters on the templates, from which corresponding parameters shall be removed (ffParameterDesignOption) - mark as deleted: ' + cast(@@rowcount as varchar(20))

	update		sdo
	set			sdo.intRowStatus = 1
	from		ffSectionDesignOption sdo
	inner join	@SectionToDel s_del
	on			s_del.idfsSection = sdo.idfsSection
	where		sdo.intRowStatus <> 1
	print	'Design options of the sections on the templates to be deleted from the list of sections (ffSectionDesignOption) - mark as deleted: ' + cast(@@rowcount as varchar(20))

	update		sdo
	set			sdo.intRowStatus = 1
	from		ffSectionDesignOption sdo
	inner join	ffFormTemplate t
	on			t.idfsFormTemplate = sdo.idfsFormTemplate
	inner join	trtBaseReferenceToCP brc
	on			brc.idfsBaseReference = t.idfsFormTemplate
	inner join	@FormTypeAndCountryToCustomize ftc
	on			ftc.idfsFormType = t.idfsFormType
				and ftc.idfCustomizationPackage = brc.idfCustomizationPackage
	left join	@SectionToDel s_del
	on			s_del.idfsSection = sdo.idfsSection
	where		sdo.intRowStatus <> 1
				and s_del.idfsSection is null
				and	not exists	(
							select	*
							from	@SectionTable st
							where	st.idfsFormTemplate = t.idfsFormTemplate
									and st.idfsSection = sdo.idfsSection
								)
	print	'Design options of the sections on the templates, from which corresponding sections shall be removed (ffSectionDesignOption) - mark as deleted: ' + cast(@@rowcount as varchar(20))


	update		pft
	set			pft.intRowStatus = 1
	from		ffParameterForTemplate pft
	inner join	@ParameterToDel p_del
	on			p_del.idfsParameter = pft.idfsParameter
	where		pft.intRowStatus <> 1
	print	'Presence of the parameters on the templates to be deleted from the list of parameters (ffParameterForTemplate) - mark as deleted: ' + cast(@@rowcount as varchar(20))

	update		pft
	set			pft.intRowStatus = 1
	from		ffParameterForTemplate pft
	inner join	ffFormTemplate t
	on			t.idfsFormTemplate = pft.idfsFormTemplate
	inner join	trtBaseReferenceToCP brc
	on			brc.idfsBaseReference = t.idfsFormTemplate
	inner join	@FormTypeAndCountryToCustomize ftc
	on			ftc.idfsFormType = t.idfsFormType
				and ftc.idfCustomizationPackage = brc.idfCustomizationPackage
	left join	@ParameterToDel p_del
	on			p_del.idfsParameter = pft.idfsParameter
	where		pft.intRowStatus <> 1
				and p_del.idfsParameter is null
				and	not exists	(
							select	*
							from	@ParameterTable pt
							where	pt.idfsFormTemplate = t.idfsFormTemplate
									and pt.idfsParameter = pft.idfsParameter
								)
	print	'Presence of the parameters on the templates, from which corresponding parameters shall be removed (ffParameterForTemplate) - mark as deleted: ' + cast(@@rowcount as varchar(20))

	update		sft
	set			sft.intRowStatus = 1
	from		ffSectionForTemplate sft
	inner join	@SectionToDel s_del
	on			s_del.idfsSection = sft.idfsSection
	where		sft.intRowStatus <> 1
	print	'Presence of the sections on the templates to be deleted from the list of sections (ffSectionForTemplate) - mark as deleted: ' + cast(@@rowcount as varchar(20))

	update		sft
	set			sft.intRowStatus = 1
	from		ffSectionForTemplate sft
	inner join	ffFormTemplate t
	on			t.idfsFormTemplate = sft.idfsFormTemplate
	inner join	trtBaseReferenceToCP brc
	on			brc.idfsBaseReference = t.idfsFormTemplate
	inner join	@FormTypeAndCountryToCustomize ftc
	on			ftc.idfsFormType = t.idfsFormType
				and ftc.idfCustomizationPackage = brc.idfCustomizationPackage
	left join	@SectionToDel s_del
	on			s_del.idfsSection = sft.idfsSection
	where		sft.intRowStatus <> 1
				and s_del.idfsSection is null
				and	not exists	(
							select	*
							from	@SectionTable st
							where	st.idfsFormTemplate = t.idfsFormTemplate
									and st.idfsSection = sft.idfsSection
								)
	print	'Presence of the sections on the templates, from which corresponding sections shall be removed (ffSectionForTemplate) - mark as deleted: ' + cast(@@rowcount as varchar(20))

	delete		deffr
	from		tdeDataExportFFReference deffr
	inner join	ffParameter p
	on			p.idfsParameter = deffr.idfsParameter
	inner join	@ParameterToDel p_del
	on			p_del.idfsParameter = p.idfsParameter
	print	'Links from the parameters to be deleted from the list of parameters to the parameters utilized for the export to WHO (tdeDataExportFFReference) - delete: ' + cast(@@rowcount as varchar(20))

	delete		deffr
	from		tdeDataExportFFReference deffr
	inner join	ffParameter p
	on			p.idfsParameter = deffr.idfsParameter
	inner join	@FormTypeAndCountryToCustomize ftc
	on			ftc.idfsFormType = p.idfsFormType
				and ftc.idfCustomizationPackage = deffr.idfCustomizationPackage
	left join	@ParameterToDel p_del
	on			p_del.idfsParameter = p.idfsParameter
	where		p_del.idfsParameter is null
				and	not exists	(
							select	*
							from	@ParameterTable pt
							where	pt.idfCustomizationPackage = deffr.idfCustomizationPackage
									and pt.idfsParameter = p.idfsParameter
									and pt.idfsFormType = p.idfsFormType
								)
	print	'Links from the parameters to be deleted from the list of parameters of the specified country to the parameters utilized for the export to WHO for the specified country (tdeDataExportFFReference) - delete: ' + cast(@@rowcount as varchar(20))

	delete		p_to_d_for_cr
	from		trtFFObjectToDiagnosisForCustomReport p_to_d_for_cr
	inner join	trtFFObjectForCustomReport p_to_cr
	on			p_to_cr.idfFFObjectForCustomReport = p_to_d_for_cr.idfFFObjectForCustomReport
	inner join	@ParameterToDel p_del
	on			p_del.idfsParameter = p_to_cr.idfsFFObject
	print	'Links to the diagnoses from the parameters to be deleted from the list of parameters, utilized in the custom reports (trtFFParameterToDiagnosisForCustomReport) - delete: ' + cast(@@rowcount as varchar(20))

	delete		p_to_cr
	from		trtFFObjectForCustomReport p_to_cr
	inner join	@ParameterToDel p_del
	on			p_del.idfsParameter = p_to_cr.idfsFFObject
	print	'Utilization of the parameters to be deleted from the list of parameters in the custom reports (trtFFParameterForCustomReport) - delete: ' + cast(@@rowcount as varchar(20))

	delete		p_to_d_for_cr
	from		trtFFObjectToDiagnosisForCustomReport p_to_d_for_cr
	inner join	trtFFObjectForCustomReport p_to_cr
	on			p_to_cr.idfFFObjectForCustomReport = p_to_d_for_cr.idfFFObjectForCustomReport
	inner join	@SectionToDel s_del
	on			s_del.idfsSection = p_to_cr.idfsFFObject
	print	'Links to the diagnoses from the sections to be deleted from the list of sections, utilized in the custom reports (trtFFParameterToDiagnosisForCustomReport) - delete: ' + cast(@@rowcount as varchar(20))

	delete		p_to_cr
	from		trtFFObjectForCustomReport p_to_cr
	inner join	@SectionToDel s_del
	on			s_del.idfsSection = p_to_cr.idfsFFObject
	print	'Utilization of the sections to be deleted from the list of sections in the custom reports (trtFFParameterForCustomReport) - delete: ' + cast(@@rowcount as varchar(20))

	delete		sf_to_p
	from		tasSearchFieldToFFParameter sf_to_p
	inner join	@ParameterToDel p_del
	on			p_del.idfsParameter = sf_to_p.idfsParameter
	print	'Links from AVR search fields to the parameters to be deleted from the list of parameters (tasSearchFieldToFFParameter) - delete: ' + cast(@@rowcount as varchar(20))

	--TODO: update deletion from AVR queries, layouts, views
	--update		lsf
	--set			lsf.idfUnitLayoutSearchField = null 
	--from		tasglLayoutSearchField lsf
	--inner join	tasglLayoutSearchField lsf_unit
	--on			lsf_unit.idfLayoutSearchField = lsf.idfUnitLayoutSearchField
	--inner join	tasglQuerySearchField qsf_unit
	--on			qsf_unit.idfQuerySearchField = lsf_unit.idfQuerySearchField
	--inner join	@ParameterToDel p_del
	--on			p_del.idfsParameter = qsf_unit.idfsParameter
	--print	'Published AVR layout fields with aggregate functions, utilizing another AVR layout field, linked to the parameters to be deleted from the list of parameters, as a source of statistical georgaphic administrative units (tasglLayoutSearchField) - update: ' + cast(@@rowcount as varchar(20))

	--update		lsf
	--set			lsf.idfDateLayoutSearchField = null 
	--from		tasglLayoutSearchField lsf
	--inner join	tasglLayoutSearchField lsf_date
	--on			lsf_date.idfLayoutSearchField = lsf.idfDateLayoutSearchField
	--inner join	tasglQuerySearchField qsf_date
	--on			qsf_date.idfQuerySearchField = lsf_date.idfQuerySearchField
	--inner join	@ParameterToDel p_del
	--on			p_del.idfsParameter = qsf_date.idfsParameter
	--print	'Published AVR layout fields with aggregate functions, utilizing another AVR layout field, linked to the parameters to be deleted from the list of parameters, as a source of statistical year units (tasglLayoutSearchField) - update: ' + cast(@@rowcount as varchar(20))

	--delete		lsf
	--from		tasglLayoutSearchField lsf
	--inner join	tasglQuerySearchField qsf
	--on			qsf.idfQuerySearchField = lsf.idfQuerySearchField
	--inner join	@ParameterToDel p_del
	--on			p_del.idfsParameter = qsf.idfsParameter
	--print	'Published AVR layout fields linked to the parameters to be deleted from the list of parameters (tasglLayoutSearchField) - delete: ' + cast(@@rowcount as varchar(20))

	--delete		qsf
	--from		tasglQuerySearchFieldCondition qsfc
	--inner join	tasglQuerySearchField qsf
	--on			qsfc.idfQuerySearchField = qsf.idfQuerySearchField
	--inner join	@ParameterToDel p_del
	--on			p_del.idfsParameter = qsf.idfsParameter
	--print	'Filter conditions, containing published AVR query fields linked to the parameters to be deleted from the list of parameters (tasglQuerySearchField) - delete: ' + cast(@@rowcount as varchar(20))

	--delete		qsf
	--from		tasglQuerySearchField qsf
	--inner join	@ParameterToDel p_del
	--on			p_del.idfsParameter = qsf.idfsParameter
	--print	'Published AVR query fields linked to the parameters to be deleted from the list of parameters (tasglQuerySearchField) - delete: ' + cast(@@rowcount as varchar(20))

	--delete		qso
	--from		tasglQuerySearchField qso
	--left join	tasglQuerySearchField qsf
	--on			qsf.idfQuerySearchObject = qso.idfQuerySearchObject
	--where		qsf.idfQuerySearchField is null
	--print	'Published AVR query objects not containing at least one field (tasglQuerySearchObject) - delete: ' + cast(@@rowcount as varchar(20))

	--declare	@QueryToUpdate	table
	--(	idflQuery	bigint not null primary key
	--)
	
	--insert into	@QueryToUpdate (idflQuery)
	--select distinct
	--			qso.idflQuery
	--from		tasQuerySearchField qsf
	--inner join	@ParameterToDel p_del
	--on			p_del.idfsParameter = qsf.idfsParameter
	--inner join	tasQuerySearchObject qso
	--on			qso.idfQuerySearchObject = qso.idfQuerySearchObject


	--update		lsf
	--set			lsf.idfUnitQuerySearchField = null 
	--from		tasLayoutSearchField lsf
	--inner join	tasLayoutSearchField lsf_unit
	--on			lsf_unit.idfLayoutSearchField = lsf.idfUnitQuerySearchField
	--inner join	tasQuerySearchField qsf_unit
	--on			qsf_unit.idfQuerySearchField = lsf_unit.idfQuerySearchField
	--inner join	@ParameterToDel p_del
	--on			p_del.idfsParameter = qsf_unit.idfsParameter
	--print	'Local AVR layout fields with aggregate functions, utilizing another AVR layout field, linked to the parameters to be deleted from the list of parameters, as a source of statistical georgaphic administrative units (tasglLayoutSearchField) - update: ' + cast(@@rowcount as varchar(20))

	--update		lsf
	--set			lsf.idfDateQuerySearchField = null 
	--from		tasLayoutSearchField lsf
	--inner join	tasLayoutSearchField lsf_date
	--on			lsf_date.idfLayoutSearchField = lsf.idfDateQuerySearchField
	--inner join	tasQuerySearchField qsf_date
	--on			qsf_date.idfQuerySearchField = lsf_date.idfQuerySearchField
	--inner join	@ParameterToDel p_del
	--on			p_del.idfsParameter = qsf_date.idfsParameter
	--print	'Local AVR layout fields with aggregate functions, utilizing another AVR layout field, linked to the parameters to be deleted from the list of parameters, as a source of statistical year units (tasglLayoutSearchField) - update: ' + cast(@@rowcount as varchar(20))

	--update		lsf
	--set			lsf.idfDenominatorQuerySearchField = null 
	--from		tasLayoutSearchField lsf
	--inner join	tasLayoutSearchField lsf_denominator
	--on			lsf_denominator.idfLayoutSearchField = lsf.idfDenominatorQuerySearchField
	--inner join	tasQuerySearchField qsf_denominator
	--on			qsf_denominator.idfQuerySearchField = lsf_denominator.idfQuerySearchField
	--inner join	@ParameterToDel p_del
	--on			p_del.idfsParameter = qsf_denominator.idfsParameter
	--print	'Local AVR layout fields with aggregate functions, utilizing another AVR layout field, linked to the parameters to be deleted from the list of parameters, as a denominator (tasglLayoutSearchField) - update: ' + cast(@@rowcount as varchar(20))

	--delete		lsf
	--from		tasLayoutSearchField lsf
	--inner join	tasQuerySearchField qsf
	--on			qsf.idfQuerySearchField = lsf.idfQuerySearchField
	--inner join	@ParameterToDel p_del
	--on			p_del.idfsParameter = qsf.idfsParameter
	--print	'Local AVR layout fields linked to the parameters to be deleted from the list of parameters (tasglLayoutSearchField) - delete: ' + cast(@@rowcount as varchar(20))
	
	--delete		qsf
	--from		tasQuerySearchFieldCondition qsfc
	--inner join	tasQuerySearchField qsf
	--on			qsfc.idfQuerySearchField = qsf.idfQuerySearchField
	--inner join	@ParameterToDel p_del
	--on			p_del.idfsParameter = qsf.idfsParameter
	--print	'Filter conditions, containing local AVR query fields linked to the parameters to be deleted from the list of parameters (tasQuerySearchField) - delete: ' + cast(@@rowcount as varchar(20))

	--delete		qsf
	--from		tasQuerySearchField qsf
	--inner join	@ParameterToDel p_del
	--on			p_del.idfsParameter = qsf.idfsParameter
	--print	'Local AVR query fields linked to the parameters to be deleted from the list of parameters (tasQuerySearchField) - delete: ' + cast(@@rowcount as varchar(20))

	--delete		qso
	--from		tasQuerySearchField qso
	--left join	tasQuerySearchField qsf
	--on			qsf.idfQuerySearchObject = qso.idfQuerySearchObject
	--where		qsf.idfQuerySearchField is null
	--print	'Local AVR query objects not containing at least one field (tasQuerySearchObject) - delete: ' + cast(@@rowcount as varchar(20))

	--declare	@i					bigint
	--declare	@idflQuery			bigint
	--declare	@QueryToUpdateCount	bigint
	--declare	@QueryToUpdateName	nvarchar(2000)
	
	--set	@i = 0
	--select	@QueryToUpdateCount = count(*)
	--from		@QueryToUpdate q_upd
	--inner join	tasQuery q
	--on			q.idflQuery = q_upd.idflQuery
	
	--while	@i < @QueryToUpdateCount
	--begin
	--	select		@idflQuery = q_upd.idflQuery,
	--				@QueryToUpdateName = IsNull(lsnt.strTextString, cast(q_upd.idflQuery as nvarchar(20)))
	--	from		@QueryToUpdate q_upd
	--	inner join	tasQuery q
	--	on			q.idflQuery = q_upd.idflQuery
	--	left join	locStringNameTranslation lsnt
	--	on			lsnt.idflBaseReference = q.idflQuery
	--				and lsnt.idfsLanguage = dbo.fnGetLanguageCode('en')
	--	where	(	select		count(*)
	--				from		@QueryToUpdate q_upd_less
	--				inner join	tasQuery q_less
	--				on			q_less.idflQuery = q_upd_less.idflQuery
	--				where		q_upd_less.idflQuery < q_upd.idflQuery
	--			) = @i
		
		
	--	if	@idflQuery is not null
	--	begin
	--		print	N'Regenerate the query [' + @QueryToUpdateName + N']'

	--		execute	spAsQueryFunction_Post	@idflQuery
	--	end
		
	--	set	@i = @i + 1
	--end

	---- TODO: Insert into the script for @PerformDeletions = 2
	----update		p
	----set			p.idfsSection = null
	----from		ffParameter p
	----inner join	@SectionToDel s_del
	----on			p.idfsSection = s_del.idfsSection
	----left join	@ParameterToDel p_del
	----on			p_del.idfsParameter = p.idfsParameter
	----where		p_del.idfsParameter is null
	----print	'Presence of the parameters on the sections to be deleted from the list of sections (ffParameter) - update: ' + cast(@@rowcount as varchar(20))
	

	---- TODO: Insert into the script for @PerformDeletions = 2
	----update		s
	----set			s.idfsParentSection = null
	----from		ffSection s
	----inner join	@SectionToDel s_parent_del
	----on			s_parent_del.idfsSection = s.idfsParentSection
	----left join	@SectionToDel s_del
	----on			s_del.idfsSection = s.idfsSection
	----where		s_del.idfsSection is null
	----print	'Parent sections of the sections to be deleted from the list of sections (ffSection) - update: ' + cast(@@rowcount as varchar(20))

	update		p
	set			p.intRowStatus = 1
	from		ffParameter p
	inner join	@ParameterToDel p_del
	on			p_del.idfsParameter = p.idfsParameter
	where		p.intRowStatus <> 1
	print	'Parameters to be deleted from the list of parameters (ffParameter) - mark as deleted: ' + cast(@@rowcount as varchar(20))

	update		s
	set			s.intRowStatus = 1
	from		ffSection s
	inner join	@SectionToDel s_del
	on			s_del.idfsSection = s.idfsSection
	where		s.intRowStatus <> 1
	print	'Sections to be deleted from the list of sections (ffSection) - mark as deleted: ' + cast(@@rowcount as varchar(20))

	---- TODO: Insert tables trtBaseReferenceToCP and trtStringNameTranslation into the script for @PerformDeletions = 2

	update		br
	set			br.intRowStatus = 1
	from		trtBaseReference br
	inner join	@ffBRToDel br_del
	on			br_del.idfsBaseReference = br.idfsBaseReference
	where		br.intRowStatus <> 1
	print	'Reference values linked to FF objects (labels'' text, parameters'' tooltips and captions, sections'' names) to be deleted (trtBaseReference) - mark as deleted: ' + cast(@@rowcount as varchar(20))

	print	''
	print	''
end


-- insert and update sections
print 'Insert and update sections'
print ''
update		br
set			br.idfsReferenceType = 	19000101,		-- Flexible Form Section
			br.strDefault = st.Section_EN,
			br.intHACode = null,
			br.intOrder = 0,
			br.blnSystem = 0,
			br.intRowStatus = 0
from		trtBaseReference br
inner join	@SectionTable st
on			st.idfsSection = br.idfsBaseReference
where		(	br.idfsReferenceType <> 19000101		-- Flexible Form Section
				or IsNull(br.strDefault, N'') <> st.Section_EN collate Cyrillic_General_CI_AS
				or br.intHACode is not null
				or br.intOrder <> 0
				or IsNull(br.blnSystem, 1) <> 0
				or br.intRowStatus <> 0
			)
print 'Sections (trtBaseReference) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtBaseReference
(	idfsBaseReference,
	idfsReferenceType,
	strDefault,
	intHACode,
	intOrder,
	blnSystem,
	intRowStatus
)
select distinct
			st.idfsSection,
			19000101,		-- Flexible Form Section
			st.Section_EN,
			null,
			0,
			0,
			0
from		@SectionTable st
left join	trtBaseReference br
on			br.idfsBaseReference = st.idfsSection
where		br.idfsBaseReference is null
print 'Sections (trtBaseReference) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = st.Section_EN,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@SectionTable st
on			st.idfsSection = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('en')
			and	(	(IsNull(snt.strTextString, N'') <> st.Section_EN collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
print 'Sections'' translations into English (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct	
			st.idfsSection,
			dbo.fnGetLanguageCode('en'),
			st.Section_EN,
			0
from		trtBaseReference br
inner join	@SectionTable st
on			st.idfsSection = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = st.idfsSection
			and snt.idfsLanguage = dbo.fnGetLanguageCode('en')
where		snt.idfsBaseReference is null
print 'Sections'' translations into English (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = st.Section_AM,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@SectionTable st
on			st.idfsSection = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('hy')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(st.Section_AM, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
print 'Sections'' translations into Armenian (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct	
			st.idfsSection,
			dbo.fnGetLanguageCode('hy'),
			st.Section_AM,
			0
from		trtBaseReference br
inner join	@SectionTable st
on			st.idfsSection = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = st.idfsSection
			and snt.idfsLanguage = dbo.fnGetLanguageCode('hy')
where		IsNull(snt.strTextString, N'') <> IsNull(st.Section_AM, N'') collate Cyrillic_General_CI_AS 
			and snt.idfsBaseReference is null
print 'Sections'' translations into Armenian (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = st.Section_AZ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@SectionTable st
on			st.idfsSection = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('az-L')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(st.Section_AZ, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
print 'Sections'' translations into Azeri (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct	
			st.idfsSection,
			dbo.fnGetLanguageCode('az-L'),
			st.Section_AZ,
			0
from		trtBaseReference br
inner join	@SectionTable st
on			st.idfsSection = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = st.idfsSection
			and snt.idfsLanguage = dbo.fnGetLanguageCode('az-L')
where		IsNull(snt.strTextString, N'') <> IsNull(st.Section_AZ, N'') collate Cyrillic_General_CI_AS 
			and snt.idfsBaseReference is null
print 'Sections'' translations into Azeri (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = st.Section_GG,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@SectionTable st
on			st.idfsSection = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ka')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(st.Section_GG, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
print 'Sections'' translations into Azerbaijann (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct	
			st.idfsSection,
			dbo.fnGetLanguageCode('ka'),
			st.Section_GG,
			0
from		trtBaseReference br
inner join	@SectionTable st
on			st.idfsSection = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = st.idfsSection
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ka')
where		IsNull(snt.strTextString, N'') <> IsNull(st.Section_GG, N'') collate Cyrillic_General_CI_AS 
			and snt.idfsBaseReference is null
print 'Sections'' translations into Azerbaijann (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = st.Section_RU,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@SectionTable st
on			st.idfsSection = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ru')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(st.Section_RU, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
print 'Sections'' translations into Russian (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct	
			st.idfsSection,
			dbo.fnGetLanguageCode('ru'),
			st.Section_RU,
			0
from		trtBaseReference br
inner join	@SectionTable st
on			st.idfsSection = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = st.idfsSection
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ru')
where		IsNull(snt.strTextString, N'') <> IsNull(st.Section_RU, N'') collate Cyrillic_General_CI_AS 
			and snt.idfsBaseReference is null
print 'Sections'' translations into Russian (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = st.Section_KZ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@SectionTable st
on			st.idfsSection = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('kk')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(st.Section_KZ, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
print 'Sections'' translations into Kazakh (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct	
			st.idfsSection,
			dbo.fnGetLanguageCode('kk'),
			st.Section_KZ,
			0
from		trtBaseReference br
inner join	@SectionTable st
on			st.idfsSection = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = st.idfsSection
			and snt.idfsLanguage = dbo.fnGetLanguageCode('kk')
where		IsNull(snt.strTextString, N'') <> IsNull(st.Section_KZ, N'') collate Cyrillic_General_CI_AS 
			and snt.idfsBaseReference is null
print 'Sections'' translations into Kazakh (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = st.Section_IQ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@SectionTable st
on			st.idfsSection = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ar')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(st.Section_IQ, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
print 'Sections'' translations into Arabic (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct	
			st.idfsSection,
			dbo.fnGetLanguageCode('ar'),
			st.Section_IQ,
			0
from		trtBaseReference br
inner join	@SectionTable st
on			st.idfsSection = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = st.idfsSection
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ar')
where		IsNull(snt.strTextString, N'') <> IsNull(st.Section_IQ, N'') collate Cyrillic_General_CI_AS 
			and snt.idfsBaseReference is null
print 'Sections'' translations into Arabic (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = st.Section_UA,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@SectionTable st
on			st.idfsSection = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('uk')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(st.Section_UA, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
print 'Sections'' translations into Ukrainian (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct	
			st.idfsSection,
			dbo.fnGetLanguageCode('uk'),
			st.Section_UA,
			0
from		trtBaseReference br
inner join	@SectionTable st
on			st.idfsSection = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = st.idfsSection
			and snt.idfsLanguage = dbo.fnGetLanguageCode('uk')
where		IsNull(snt.strTextString, N'') <> IsNull(st.Section_UA, N'') collate Cyrillic_General_CI_AS 
			and snt.idfsBaseReference is null
print 'Sections'' translations into Ukrainian (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = st.Section_TH,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@SectionTable st
on			st.idfsSection = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('th')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(st.Section_TH, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
print 'Sections'' translations into Thai (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct	
			st.idfsSection,
			dbo.fnGetLanguageCode('th'),
			st.Section_TH,
			0
from		trtBaseReference br
inner join	@SectionTable st
on			st.idfsSection = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = st.idfsSection
			and snt.idfsLanguage = dbo.fnGetLanguageCode('th')
where		IsNull(snt.strTextString, N'') <> IsNull(st.Section_TH, N'') collate Cyrillic_General_CI_AS 
			and snt.idfsBaseReference is null
print 'Sections'' translations into Thai (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		br_to_c
set			br_to_c.intHACode = null,
			br_to_c.intOrder = 0
from		trtBaseReferenceToCP br_to_c
inner join	tstCustomizationPackage c
on			c.idfCustomizationPackage = br_to_c.idfCustomizationPackage
inner join	@SectionTable st
on			st.idfsSection = br_to_c.idfsBaseReference
			and st.idfCustomizationPackage = c.idfCustomizationPackage
where		(	br_to_c.intHACode is not null
				or IsNull(br_to_c.intOrder, -1) <> 0 
			)
print 'Links from Sections to customization packages (trtBaseReferenceToCP) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtBaseReferenceToCP
(	idfsBaseReference,
	idfCustomizationPackage,
	intHACode,
	intOrder
)
select distinct
			st.idfsSection,
			c.idfCustomizationPackage,
			null,
			0
from		trtBaseReference br
inner join	@SectionTable st
on			st.idfsSection = br.idfsBaseReference
inner join	tstCustomizationPackage c
on			c.idfCustomizationPackage = st.idfCustomizationPackage
left join	trtBaseReferenceToCP br_to_c
on			br_to_c.idfsBaseReference = st.idfsSection
			and br_to_c.idfCustomizationPackage = c.idfCustomizationPackage
where		br_to_c.idfsBaseReference is null
print 'Links from Sections to customization packages (trtBaseReferenceToCP) - insert: ' + cast(@@rowcount as varchar(20))


insert into	ffSection
(	idfsSection,
	idfsParentSection,
	idfsFormType,
	intOrder,
	blnGrid,
	blnFixedRowSet,
	intRowStatus,
	idfsMatrixType
)
select distinct
			st.idfsSection,
			null,
			st.idfsFormType,
			0,
			st.blnGrid,
			0,
			0,
			case
				when	st.idfsParentSection is null
						and st.idfsFormType = 10034012	-- Human Aggregate Case
					then	71190000000	-- Human Aggregate Case
				when	st.idfsParentSection is null
						and st.idfsFormType = 10034021	-- Vet Aggregate Case
					then	71090000000	-- Vet Aggregate Case
				when	st.idfsParentSection is null
						and st.idfsFormType = 10034023	-- Diagnostic investigations
					then	71460000000	-- Diagnostic investigations
				when	st.idfsParentSection is null
						and st.idfsFormType = 10034024	-- Treatment-prophylactics and vaccination measures
					then	71300000000	-- Treatment-prophylactics and vaccination measures
				when	st.idfsParentSection is null
						and st.idfsFormType = 10034022	-- Veterinary-sanitary measures
					then	71260000000	-- Veterinary-sanitary measures
				else	null
			end
from		@SectionTable st
inner join	trtBaseReference br
on			br.idfsBaseReference = st.idfsSection
left join	ffSection s
on			s.idfsSection = br.idfsBaseReference
where		s.idfsSection is null
print 'Sections (ffSection) - insert (without specified parent sections): ' + cast(@@rowcount as varchar(20))

update		s
set			s.idfsParentSection = st.idfsParentSection,
			s.idfsFormType = st.idfsFormType,
			s.intOrder = 0,
			s.blnGrid = st.blnGrid,
			s.blnFixedRowSet = 0,
			s.intRowStatus = 0
from		ffSection s
inner join	@SectionTable st
on			st.idfsSection = s.idfsSection
where		(	(IsNull(s.idfsParentSection, -1) <> IsNull(st.idfsParentSection, -1))
				or (s.idfsFormType <> st.idfsFormType)
				or (s.intOrder <> 0)
				or (s.blnGrid <> st.blnGrid)
				or (s.blnFixedRowSet <> 0)
				or (s.intRowStatus <> 0)
			)
print 'Sections (ffSection) - update: ' + cast(@@rowcount as varchar(20))

update		sft
set			sft.blnFreeze = 0,
			sft.intRowStatus = 0
from		ffSectionForTemplate sft
inner join	@SectionTable st
on			st.idfsFormTemplate = sft.idfsFormTemplate
			and st.idfsSection = sft.idfsSection
where		(	sft.blnFreeze <> 0
				or sft.intRowStatus <> 0
			)
print 'Presence of the sections on the templates (ffSectionForTemplate) - update: ' + cast(@@rowcount as varchar(20))

insert into	ffSectionForTemplate
(	idfsFormTemplate,
	idfsSection,
	blnFreeze,
	intRowStatus
)
select distinct	
			st.idfsFormTemplate,
			st.idfsSection,
			0,
			0
from		@SectionTable st
inner join	ffSection s
on			s.idfsSection = st.idfsSection
inner join	ffFormTemplate ft
on			ft.idfsFormTemplate = st.idfsFormTemplate
left join	ffSectionForTemplate sft
on			sft.idfsFormTemplate = ft.idfsFormTemplate
			and sft.idfsSection = s.idfsSection
where		sft.idfsFormTemplate is null
print 'Presence of the sections on the templates (ffSectionForTemplate) - insert: ' + cast(@@rowcount as varchar(20))


update		sdo
set			sdo.intOrder = st.SectionOrder,
			sdo.intRowStatus = 0
from		ffSectionDesignOption sdo
inner join	ffSection s
on			s.idfsSection = sdo.idfsSection
inner join	ffFormTemplate ft
on			ft.idfsFormTemplate = sdo.idfsFormTemplate
inner join	@SectionTable st
on			st.idfSectionDesignOption = sdo.idfSectionDesignOption
			and st.idfsSection = s.idfsSection
			and st.idfsFormTemplate = ft.idfsFormTemplate
where		(	sdo.intOrder <> st.SectionOrder
				or sdo.intRowStatus <> 0
			)
print 'Sections'' design options in templates (ffSectionDesignOption) - update order in template: ' + cast(@@rowcount as varchar(20))

insert into	ffSectionDesignOption
(	idfSectionDesignOption,
	idfsLanguage,
	idfsFormTemplate,
	idfsSection,
	intLeft,
	intTop,
	intWidth,
	intHeight,
	intCaptionHeight,
	intOrder,
	intRowStatus
)
select		st.idfSectionDesignOption,
			dbo.fnGetLanguageCode('en'),
			st.idfsFormTemplate,
			st.idfsSection,
			0,
			0,
			0,
			0,
			0,
			st.SectionOrder,
			0
from		@SectionTable st
inner join	ffSection s
on			s.idfsSection = st.idfsSection
inner join	ffFormTemplate ft
on			ft.idfsFormTemplate = st.idfsFormTemplate
left join	ffSectionDesignOption sdo
on			sdo.idfsFormTemplate = ft.idfsFormTemplate
			and sdo.idfsSection = s.idfsSection
			and sdo.idfsLanguage = dbo.fnGetLanguageCode('en')
where		sdo.idfSectionDesignOption is null
print 'Sections'' design options in templates (ffSectionDesignOption) - insert: ' + cast(@@rowcount as varchar(20))
print ''
print ''

-- insert and update parameters
print 'Insert and update parameters'
print ''
update		br
set			br.idfsReferenceType = 	19000066,		-- Flexible Form Parameter
			br.strDefault = pt.Tooltip_EN,
			br.intHACode = null,
			br.intOrder = 0,
			br.blnSystem = 0,
			br.intRowStatus = 0
from		trtBaseReference br
inner join	@ParameterTable pt
on			pt.idfsParameter = br.idfsBaseReference
where		(	br.idfsReferenceType <> 19000066		-- Flexible Form Parameter
				or IsNull(br.strDefault, N'') <> pt.Tooltip_EN collate Cyrillic_General_CI_AS
				or br.intHACode is not null
				or br.intOrder <> 0
				or IsNull(br.blnSystem, 1) <> 0
				or br.intRowStatus <> 0
			)
			and pt.ParameterType_EN <> N'Label'
print 'Parameters'' tooltips (trtBaseReference) - update: ' + cast(@@rowcount as varchar(20))


insert into	trtBaseReference
(	idfsBaseReference,
	idfsReferenceType,
	strDefault,
	intHACode,
	intOrder,
	blnSystem,
	intRowStatus
)
select distinct
			pt.idfsParameter,
			19000066,		-- Flexible Form Parameter
			pt.Tooltip_EN,
			null,
			0,
			0,
			0
from		@ParameterTable pt
left join	trtBaseReference br
on			br.idfsBaseReference = pt.idfsParameter
where		br.idfsBaseReference is null
			and pt.ParameterType_EN <> N'Label'
print 'Parameters'' tooltips (trtBaseReference) - insert: ' + cast(@@rowcount as varchar(20))

update		br
set			br.idfsReferenceType = 	19000070,		-- Flexible Form Parameter Tooltip
			br.strDefault = pt.Parameter_EN,
			br.intHACode = null,
			br.intOrder = 0,
			br.blnSystem = 0,
			br.intRowStatus = 0
from		trtBaseReference br
inner join	@ParameterTable pt
on			pt.idfsParameterCaption = br.idfsBaseReference
where		(	br.idfsReferenceType <> 19000070		-- Flexible Form Parameter Tooltip
				or IsNull(br.strDefault, N'') <> pt.Parameter_EN collate Cyrillic_General_CI_AS
				or br.intHACode is not null
				or br.intOrder <> 0
				or IsNull(br.blnSystem, 1) <> 0
				or br.intRowStatus <> 0
			)
			and pt.ParameterType_EN <> N'Label'
print 'Parameters'' captions (trtBaseReference) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtBaseReference
(	idfsBaseReference,
	idfsReferenceType,
	strDefault,
	intHACode,
	intOrder,
	blnSystem,
	intRowStatus
)
select distinct
			pt.idfsParameterCaption,
			19000070,		-- Flexible Form Parameter Tooltip
			pt.Parameter_EN,
			null,
			0,
			0,
			0
from		@ParameterTable pt
left join	trtBaseReference br
on			br.idfsBaseReference = pt.idfsParameterCaption
where		br.idfsBaseReference is null
			and pt.ParameterType_EN <> N'Label'
print 'Parameters'' captions (trtBaseReference) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = pt.Tooltip_EN,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@ParameterTable pt
on			pt.idfsParameter = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('en')
			and	(	(IsNull(snt.strTextString, N'') <> pt.Tooltip_EN collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' tooltips into English (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct	
			pt.idfsParameter,
			dbo.fnGetLanguageCode('en'),
			pt.Tooltip_EN,
			0
from		trtBaseReference br
inner join	@ParameterTable pt
on			pt.idfsParameter = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = pt.idfsParameter
			and snt.idfsLanguage = dbo.fnGetLanguageCode('en')
where		snt.idfsBaseReference is null
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' tooltips into English (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = pt.Parameter_EN,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@ParameterTable pt
on			pt.idfsParameterCaption = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('en')
			and	(	(IsNull(snt.strTextString, N'') <> pt.Parameter_EN collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' captions into English (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct		
			pt.idfsParameterCaption,
			dbo.fnGetLanguageCode('en'),
			pt.Parameter_EN,
			0
from		trtBaseReference br
inner join	@ParameterTable pt
on			pt.idfsParameterCaption = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = pt.idfsParameterCaption
			and snt.idfsLanguage = dbo.fnGetLanguageCode('en')
where		snt.idfsBaseReference is null
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' captions into English (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = pt.Tooltip_AM,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@ParameterTable pt
on			pt.idfsParameter = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('hy')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(pt.Tooltip_AM, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' tooltips into Armenian (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			pt.idfsParameter,
			dbo.fnGetLanguageCode('hy'),
			pt.Tooltip_AM,
			0
from		trtBaseReference br
inner join	@ParameterTable pt
on			pt.idfsParameter = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = pt.idfsParameter
			and snt.idfsLanguage = dbo.fnGetLanguageCode('hy')
where		IsNull(snt.strTextString, N'') <> IsNull(pt.Tooltip_AM, N'') collate Cyrillic_General_CI_AS 		
			and snt.idfsBaseReference is null
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' tooltips into Armenian (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = pt.Parameter_AM,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@ParameterTable pt
on			pt.idfsParameterCaption = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('hy')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(pt.Parameter_AM, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' captions into Armenian (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			pt.idfsParameterCaption,
			dbo.fnGetLanguageCode('hy'),
			pt.Parameter_AM,
			0
from		trtBaseReference br
inner join	@ParameterTable pt
on			pt.idfsParameterCaption = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = pt.idfsParameterCaption
			and snt.idfsLanguage = dbo.fnGetLanguageCode('hy')
where		IsNull(snt.strTextString, N'') <> IsNull(pt.Parameter_AM, N'') collate Cyrillic_General_CI_AS
			and snt.idfsBaseReference is null
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' captions into Armenian (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = pt.Tooltip_AZ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@ParameterTable pt
on			pt.idfsParameter = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('az-L')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(pt.Tooltip_AZ, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' tooltips into Azeri (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			pt.idfsParameter,
			dbo.fnGetLanguageCode('az-L'),
			pt.Tooltip_AZ,
			0
from		trtBaseReference br
inner join	@ParameterTable pt
on			pt.idfsParameter = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = pt.idfsParameter
			and snt.idfsLanguage = dbo.fnGetLanguageCode('az-L')
where		IsNull(snt.strTextString, N'') <> IsNull(pt.Tooltip_AZ, N'') collate Cyrillic_General_CI_AS
			and snt.idfsBaseReference is null
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' tooltips into Azeri (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = pt.Parameter_AZ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@ParameterTable pt
on			pt.idfsParameterCaption = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('az-L')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(pt.Parameter_AZ, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' captions into Azeri (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			pt.idfsParameterCaption,
			dbo.fnGetLanguageCode('az-L'),
			pt.Parameter_AZ,
			0
from		trtBaseReference br
inner join	@ParameterTable pt
on			pt.idfsParameterCaption = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = pt.idfsParameterCaption
			and snt.idfsLanguage = dbo.fnGetLanguageCode('az-L')
where		IsNull(snt.strTextString, N'') <> IsNull(pt.Parameter_AZ, N'') collate Cyrillic_General_CI_AS
			and snt.idfsBaseReference is null
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' captions into Azeri (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = pt.Tooltip_GG,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@ParameterTable pt
on			pt.idfsParameter = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ka')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(pt.Tooltip_GG, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' tooltips into Azerbaijann (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			pt.idfsParameter,
			dbo.fnGetLanguageCode('ka'),
			pt.Tooltip_GG,
			0
from		trtBaseReference br
inner join	@ParameterTable pt
on			pt.idfsParameter = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = pt.idfsParameter
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ka')
where		IsNull(snt.strTextString, N'') <> IsNull(pt.Tooltip_GG, N'') collate Cyrillic_General_CI_AS
			and snt.idfsBaseReference is null
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' tooltips into Azerbaijann (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = pt.Parameter_GG,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@ParameterTable pt
on			pt.idfsParameterCaption = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ka')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(pt.Parameter_GG, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' captions into Azerbaijann (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			pt.idfsParameterCaption,
			dbo.fnGetLanguageCode('ka'),
			pt.Parameter_GG,
			0
from		trtBaseReference br
inner join	@ParameterTable pt
on			pt.idfsParameterCaption = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = pt.idfsParameterCaption
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ka')
where		IsNull(snt.strTextString, N'') <> IsNull(pt.Parameter_GG, N'') collate Cyrillic_General_CI_AS
			and snt.idfsBaseReference is null
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' captions into Azerbaijann (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = pt.Tooltip_RU,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@ParameterTable pt
on			pt.idfsParameter = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ru')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(pt.Tooltip_RU, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' tooltips into Russian (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			pt.idfsParameter,
			dbo.fnGetLanguageCode('ru'),
			pt.Tooltip_RU,
			0
from		trtBaseReference br
inner join	@ParameterTable pt
on			pt.idfsParameter = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = pt.idfsParameter
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ru')
where		IsNull(snt.strTextString, N'') <> IsNull(pt.Tooltip_RU, N'') collate Cyrillic_General_CI_AS
			and snt.idfsBaseReference is null
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' tooltips into Russian (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = pt.Parameter_RU,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@ParameterTable pt
on			pt.idfsParameterCaption = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ru')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(pt.Parameter_RU, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' captions into Russian (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			pt.idfsParameterCaption,
			dbo.fnGetLanguageCode('ru'),
			pt.Parameter_RU,
			0
from		trtBaseReference br
inner join	@ParameterTable pt
on			pt.idfsParameterCaption = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = pt.idfsParameterCaption
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ru')
where		IsNull(snt.strTextString, N'') <> IsNull(pt.Parameter_RU, N'') collate Cyrillic_General_CI_AS
			and snt.idfsBaseReference is null
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' captions into Russian (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = pt.Tooltip_KZ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@ParameterTable pt
on			pt.idfsParameter = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('kk')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(pt.Tooltip_KZ, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' tooltips into Kazakh (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			pt.idfsParameter,
			dbo.fnGetLanguageCode('kk'),
			pt.Tooltip_KZ,
			0
from		trtBaseReference br
inner join	@ParameterTable pt
on			pt.idfsParameter = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = pt.idfsParameter
			and snt.idfsLanguage = dbo.fnGetLanguageCode('kk')
where		IsNull(snt.strTextString, N'') <> IsNull(pt.Tooltip_KZ, N'') collate Cyrillic_General_CI_AS
			and snt.idfsBaseReference is null
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' tooltips into Kazakh (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = pt.Parameter_KZ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@ParameterTable pt
on			pt.idfsParameterCaption = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('kk')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(pt.Parameter_KZ, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' captions into Kazakh (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			pt.idfsParameterCaption,
			dbo.fnGetLanguageCode('kk'),
			pt.Parameter_KZ,
			0
from		trtBaseReference br
inner join	@ParameterTable pt
on			pt.idfsParameterCaption = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = pt.idfsParameterCaption
			and snt.idfsLanguage = dbo.fnGetLanguageCode('kk')
where		IsNull(snt.strTextString, N'') <> IsNull(pt.Parameter_KZ, N'') collate Cyrillic_General_CI_AS
			and snt.idfsBaseReference is null
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' captions into Kazakh (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = pt.Tooltip_IQ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@ParameterTable pt
on			pt.idfsParameter = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ar')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(pt.Tooltip_IQ, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' tooltips into Arabic (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			pt.idfsParameter,
			dbo.fnGetLanguageCode('ar'),
			pt.Tooltip_IQ,
			0
from		trtBaseReference br
inner join	@ParameterTable pt
on			pt.idfsParameter = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = pt.idfsParameter
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ar')
where		IsNull(snt.strTextString, N'') <> IsNull(pt.Tooltip_IQ, N'') collate Cyrillic_General_CI_AS
			and snt.idfsBaseReference is null
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' tooltips into Arabic (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = pt.Parameter_IQ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@ParameterTable pt
on			pt.idfsParameterCaption = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ar')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(pt.Parameter_IQ, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' captions into Arabic (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			pt.idfsParameterCaption,
			dbo.fnGetLanguageCode('ar'),
			pt.Parameter_IQ,
			0
from		trtBaseReference br
inner join	@ParameterTable pt
on			pt.idfsParameterCaption = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = pt.idfsParameterCaption
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ar')
where		IsNull(snt.strTextString, N'') <> IsNull(pt.Parameter_IQ, N'') collate Cyrillic_General_CI_AS
			and snt.idfsBaseReference is null
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' captions into Arabic (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = pt.Tooltip_UA,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@ParameterTable pt
on			pt.idfsParameter = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('uk')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(pt.Tooltip_UA, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' tooltips into Ukrainian (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			pt.idfsParameter,
			dbo.fnGetLanguageCode('uk'),
			pt.Tooltip_UA,
			0
from		trtBaseReference br
inner join	@ParameterTable pt
on			pt.idfsParameter = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = pt.idfsParameter
			and snt.idfsLanguage = dbo.fnGetLanguageCode('uk')
where		IsNull(snt.strTextString, N'') <> IsNull(pt.Tooltip_UA, N'') collate Cyrillic_General_CI_AS
			and snt.idfsBaseReference is null
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' tooltips into Ukrainian (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = pt.Parameter_UA,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@ParameterTable pt
on			pt.idfsParameterCaption = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('uk')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(pt.Parameter_UA, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' captions into Ukrainian (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			pt.idfsParameterCaption,
			dbo.fnGetLanguageCode('uk'),
			pt.Parameter_UA,
			0
from		trtBaseReference br
inner join	@ParameterTable pt
on			pt.idfsParameterCaption = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = pt.idfsParameterCaption
			and snt.idfsLanguage = dbo.fnGetLanguageCode('uk')
where		IsNull(snt.strTextString, N'') <> IsNull(pt.Parameter_UA, N'') collate Cyrillic_General_CI_AS
			and snt.idfsBaseReference is null
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' captions into Ukrainian (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = pt.Tooltip_TH,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@ParameterTable pt
on			pt.idfsParameter = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('th')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(pt.Tooltip_TH, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' tooltips into Thai (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			pt.idfsParameter,
			dbo.fnGetLanguageCode('th'),
			pt.Tooltip_TH,
			0
from		trtBaseReference br
inner join	@ParameterTable pt
on			pt.idfsParameter = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = pt.idfsParameter
			and snt.idfsLanguage = dbo.fnGetLanguageCode('th')
where		IsNull(snt.strTextString, N'') <> IsNull(pt.Tooltip_TH, N'') collate Cyrillic_General_CI_AS
			and snt.idfsBaseReference is null
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' tooltips into Thai (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = pt.Parameter_TH,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@ParameterTable pt
on			pt.idfsParameterCaption = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('th')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(pt.Parameter_TH, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' captions into Thai (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			pt.idfsParameterCaption,
			dbo.fnGetLanguageCode('th'),
			pt.Parameter_TH,
			0
from		trtBaseReference br
inner join	@ParameterTable pt
on			pt.idfsParameterCaption = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = pt.idfsParameterCaption
			and snt.idfsLanguage = dbo.fnGetLanguageCode('th')
where		IsNull(snt.strTextString, N'') <> IsNull(pt.Parameter_TH, N'') collate Cyrillic_General_CI_AS
			and snt.idfsBaseReference is null
			and pt.ParameterType_EN <> N'Label'
print 'Translations of parameters'' captions into Thai (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))


update		br_to_c
set			br_to_c.intHACode = null,
			br_to_c.intOrder = 0
from		trtBaseReferenceToCP br_to_c
inner join	tstCustomizationPackage c
on			c.idfCustomizationPackage = br_to_c.idfCustomizationPackage
inner join	@ParameterTable pt
on			pt.idfsParameter = br_to_c.idfsBaseReference
			and pt.idfCustomizationPackage = c.idfCustomizationPackage
where		(	br_to_c.intHACode is not null
				or IsNull(br_to_c.intOrder, -1) <> 0 
			)
			and pt.ParameterType_EN <> N'Label'
print 'Links from parameters'' tooltips to customization packages (trtBaseReferenceToCP) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtBaseReferenceToCP
(	idfsBaseReference,
	idfCustomizationPackage,
	intHACode,
	intOrder
)
select distinct
			pt.idfsParameter,
			c.idfCustomizationPackage,
			null,
			0
from		trtBaseReference br
inner join	@ParameterTable pt
on			pt.idfsParameter = br.idfsBaseReference
inner join	tstCustomizationPackage c
on			c.idfCustomizationPackage = pt.idfCustomizationPackage
left join	trtBaseReferenceToCP br_to_c
on			br_to_c.idfsBaseReference = pt.idfsParameter
			and br_to_c.idfCustomizationPackage = c.idfCustomizationPackage
where		br_to_c.idfsBaseReference is null
			and pt.ParameterType_EN <> N'Label'
print 'Links from parameters'' tooltips to customization packages (trtBaseReferenceToCP) - insert: ' + cast(@@rowcount as varchar(20))

update		br_to_c
set			br_to_c.intHACode = null,
			br_to_c.intOrder = 0
from		trtBaseReferenceToCP br_to_c
inner join	tstCustomizationPackage c
on			c.idfCustomizationPackage = br_to_c.idfCustomizationPackage
inner join	@ParameterTable pt
on			pt.idfsParameterCaption = br_to_c.idfsBaseReference
			and pt.idfCustomizationPackage = 1
where		(	br_to_c.intHACode is not null
				or IsNull(br_to_c.intOrder, -1) <> 0 
			)
			and pt.ParameterType_EN <> N'Label'
print 'Links from parameters'' captions to customization packages (trtBaseReferenceToCP) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtBaseReferenceToCP
(	idfsBaseReference,
	idfCustomizationPackage,
	intHACode,
	intOrder
)
select distinct
			pt.idfsParameterCaption,
			c.idfCustomizationPackage,
			null,
			0
from		trtBaseReference br
inner join	@ParameterTable pt
on			pt.idfsParameterCaption = br.idfsBaseReference
inner join	tstCustomizationPackage c
on			c.idfCustomizationPackage = pt.idfCustomizationPackage
left join	trtBaseReferenceToCP br_to_c
on			br_to_c.idfsBaseReference = pt.idfsParameterCaption
			and br_to_c.idfCustomizationPackage = c.idfCustomizationPackage
where		br_to_c.idfsBaseReference is null
			and pt.ParameterType_EN <> N'Label'
print 'Links from parameters'' captions to customization packages (trtBaseReferenceToCP) - insert: ' + cast(@@rowcount as varchar(20))

update		p
set			p.idfsParameterCaption = pt.idfsParameterCaption,
			p.idfsSection = s.idfsSection,
			p.idfsParameterType = pt.idfsParameterType,
			p.idfsFormType = pt.idfsFormType,
			p.idfsEditor = pt.idfsEditor,
			p.strNote = null,
			p.intOrder = 0,
			p.intHACode = 0,
			p.intRowStatus = 0
from		ffParameter p
inner join	@ParameterTable pt
on			pt.idfsParameter = p.idfsParameter
inner join	trtBaseReference br_p
on			br_p.idfsBaseReference = pt.idfsParameter
inner join	trtBaseReference br_pc
on			br_pc.idfsBaseReference = pt.idfsParameterCaption
inner join	ffParameterType part
on			part.idfsParameterType = pt.idfsParameterType
inner join	trtBaseReference br_e
on			br_e.idfsBaseReference = pt.idfsEditor
left join	ffSection s
on			s.idfsSection = pt.idfsSection
where		(	(IsNull(p.idfsParameterCaption, -1) <> IsNull(pt.idfsParameterCaption, -1))
				or (IsNull(p.idfsSection, -1) <> IsNull(s.idfsSection, -1))
				or (IsNull(p.idfsParameterType, -1) <> IsNull(pt.idfsParameterType, -1))
				or (p.idfsFormType <> pt.idfsFormType)
				or (IsNull(p.idfsEditor, -1) <> IsNull(pt.idfsEditor, -1))
				or (p.strNote is not null)
				or (p.intOrder <> 0)
				or (IsNull(p.intHACode, -1) <> 0)
				or (p.intRowStatus <> 0)
			)
			and pt.ParameterType_EN <> N'Label'
print 'Parameters (ffParameter) - update: ' + cast(@@rowcount as varchar(20))

--select *
--from		@ParameterTable pt
--inner join	trtBaseReference br_p
--on			br_p.idfsBaseReference = pt.idfsParameter
--inner join	trtBaseReference br_pc
--on			br_pc.idfsBaseReference = pt.idfsParameterCaption
--inner join	ffParameterType part
--on			part.idfsParameterType = pt.idfsParameterType
--inner join	trtBaseReference br_e
--on			br_e.idfsBaseReference = pt.idfsEditor
--left join	ffSection s
--on			s.idfsSection = pt.idfsSection
--left join	ffParameter p
--on			p.idfsParameter = br_p.idfsBaseReference
--where		pt.ParameterType_EN <> N'Label'
--			and p.idfsParameter is null


insert into	ffParameter
(	idfsParameter,
	idfsSection,
	idfsParameterCaption,
	idfsParameterType,
	idfsFormType,
	idfsEditor,
	strNote,
	intOrder,
	intHACode,
	intRowStatus
)
select distinct
			pt.idfsParameter,
			s.idfsSection,
			pt.idfsParameterCaption,
			pt.idfsParameterType,
			pt.idfsFormType,
			pt.idfsEditor,
			null,
			0,
			0,
			0
from		@ParameterTable pt
inner join	trtBaseReference br_p
on			br_p.idfsBaseReference = pt.idfsParameter
inner join	trtBaseReference br_pc
on			br_pc.idfsBaseReference = pt.idfsParameterCaption
inner join	ffParameterType part
on			part.idfsParameterType = pt.idfsParameterType
inner join	trtBaseReference br_e
on			br_e.idfsBaseReference = pt.idfsEditor
left join	ffSection s
on			s.idfsSection = pt.idfsSection
left join	ffParameter p
on			p.idfsParameter = br_p.idfsBaseReference
where		pt.ParameterType_EN <> N'Label'
			and p.idfsParameter is null
print 'Parameters (ffParameter) - insert: ' + cast(@@rowcount as varchar(20))

update		pft
set			pft.idfsEditMode = pt.idfsEditMode,
			pft.blnFreeze = 0,
			pft.intRowStatus = 0
from		ffParameterForTemplate pft
inner join	@ParameterTable pt
on			pt.idfsFormTemplate = pft.idfsFormTemplate
			and pt.idfsParameter = pft.idfsParameter
where		(	IsNull(pft.idfsEditMode, -1) <> IsNull(pt.idfsEditMode, -1)
				or pft.blnFreeze <> 0
				or pft.intRowStatus <> 0
			)
			and pt.ParameterType_EN <> N'Label'
print 'Presence of the parameters on the templates (ffParameterForTemplate) - update: ' + cast(@@rowcount as varchar(20))

insert into	ffParameterForTemplate
(	idfsFormTemplate,
	idfsParameter,
	idfsEditMode,
	blnFreeze,
	intRowStatus
)
select distinct	
			pt.idfsFormTemplate,
			pt.idfsParameter,
			pt.idfsEditMode,
			0,
			0
from		@ParameterTable pt
inner join	ffParameter p
on			p.idfsParameter = pt.idfsParameter
inner join	ffFormTemplate ft
on			ft.idfsFormTemplate = pt.idfsFormTemplate
left join	ffParameterForTemplate pft
on			pft.idfsFormTemplate = ft.idfsFormTemplate
			and pft.idfsParameter = p.idfsParameter
where		pft.idfsFormTemplate is null
			and pt.ParameterType_EN <> N'Label'
print 'Presence of the parameters on the templates (ffParameterForTemplate) - insert: ' + cast(@@rowcount as varchar(20))

update		pdo
set			pdo.intOrder = pt.ParameterOrder,
			pdo.intRowStatus = 0
from		ffParameterDesignOption pdo
inner join	ffParameter p
on			p.idfsParameter = pdo.idfsParameter
inner join	ffFormTemplate ft
on			ft.idfsFormTemplate = pdo.idfsFormTemplate
inner join	@ParameterTable pt
on			pt.idfParameterDesignOption = pdo.idfParameterDesignOption
			and pt.idfsParameter = p.idfsParameter
			and pt.idfsFormTemplate = ft.idfsFormTemplate
where		pt.ParameterType_EN <> N'Label'
			and (	pdo.intOrder <> pt.ParameterOrder
					or pdo.intRowStatus <> 0
				)
print 'Parameters'' design options in templates (ffParameterDesignOption) - update orders in templates: ' + cast(@@rowcount as varchar(20))

insert into	ffParameterDesignOption
(	idfParameterDesignOption,
	idfsLanguage,
	idfsFormTemplate,
	idfsParameter,
	intLeft,
	intTop,
	intWidth,
	intHeight,
	intScheme,
	intLabelSize,
	intOrder,
	intRowStatus
)
select		pt.idfParameterDesignOption,
			dbo.fnGetLanguageCode('en'),
			pt.idfsFormTemplate,
			pt.idfsParameter,
			0,
			0,
			0,
			0,
			0,
			0,
			pt.ParameterOrder,
			0
from		@ParameterTable pt
inner join	ffParameter p
on			p.idfsParameter = pt.idfsParameter
inner join	ffFormTemplate ft
on			ft.idfsFormTemplate = pt.idfsFormTemplate
left join	ffParameterDesignOption pdo
on			pdo.idfParameterDesignOption = pt.idfParameterDesignOption
where		pdo.idfParameterDesignOption is null
			and pt.ParameterType_EN <> N'Label'
print 'Parameters'' design options in templates (ffParameterDesignOption) - insert: ' + cast(@@rowcount as varchar(20))

insert into	ffParameterDesignOption
(	idfParameterDesignOption,
	idfsLanguage,
	idfsFormTemplate,
	idfsParameter,
	intLeft,
	intTop,
	intWidth,
	intHeight,
	intScheme,
	intLabelSize,
	intOrder,
	intRowStatus
)
select distinct	
			pt.idfDefParameterDesignOption,
			dbo.fnGetLanguageCode('en'),
			null,
			pt.idfsParameter,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0
from		@ParameterTable pt
inner join	ffParameter p
on			p.idfsParameter = pt.idfsParameter
left join	ffParameterDesignOption pdo
on			pdo.idfParameterDesignOption = pt.idfDefParameterDesignOption
where		pdo.idfParameterDesignOption is null
			and pt.ParameterType_EN <> N'Label'
print 'Default parameters'' design options (ffParameterDesignOption) - insert: ' + cast(@@rowcount as varchar(20))
print ''
print ''

-- Insert and update labels
print 'Insert and update labels'
print ''
update		br
set			br.idfsReferenceType = 	19000131,		-- Flexible Form Label Text
			br.strDefault = lt.Label_EN,
			br.intHACode = null,
			br.intOrder = lt.LabelOrder,
			br.blnSystem = 0,
			br.intRowStatus = 0
from		trtBaseReference br
inner join	@LabelTable lt
on			lt.idfsBaseReference = br.idfsBaseReference
where		(	br.idfsReferenceType <> 19000131		-- Flexible Form Label Text
				or IsNull(br.strDefault, N'') <> lt.Label_EN collate Cyrillic_General_CI_AS
				or br.intHACode is not null
				or br.intOrder <> lt.LabelOrder
				or IsNull(br.blnSystem, 1) <> 0
				or br.intRowStatus <> 0
			)
print 'Labels'' text (trtBaseReference) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtBaseReference
(	idfsBaseReference,
	idfsReferenceType,
	strDefault,
	intHACode,
	intOrder,
	blnSystem,
	intRowStatus
)
select distinct
			lt.idfsBaseReference,
			19000131,		-- Flexible Form Label Text
			lt.Label_EN,
			null,
			lt.LabelOrder,
			0,
			0
from		@LabelTable lt
left join	trtBaseReference br
on			br.idfsBaseReference = lt.idfsBaseReference
where		br.idfsBaseReference is null
print 'Labels'' text (trtBaseReference) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = lt.Label_EN,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@LabelTable lt
on			lt.idfsBaseReference = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('en')
			and	(	(IsNull(snt.strTextString, N'') <> lt.Label_EN collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
print 'Translations of Labels'' text into English (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			lt.idfsBaseReference,
			dbo.fnGetLanguageCode('en'),
			lt.Label_EN,
			0
from		trtBaseReference br
inner join	@LabelTable lt
on			lt.idfsBaseReference = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = lt.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('en')
where		snt.idfsBaseReference is null
print 'Translations of Labels'' text into English (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = lt.Label_AM,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@LabelTable lt
on			lt.idfsBaseReference = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('hy')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(lt.Label_AM, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
print 'Translations of Labels'' text into Armenian (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			lt.idfsBaseReference,
			dbo.fnGetLanguageCode('hy'),
			lt.Label_AM,
			0
from		trtBaseReference br
inner join	@LabelTable lt
on			lt.idfsBaseReference = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = lt.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('hy')
where		lt.Label_AM is not null
			and snt.idfsBaseReference is null
print 'Translations of Labels'' text into Armenian (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = lt.Label_AZ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@LabelTable lt
on			lt.idfsBaseReference = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('az-L')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(lt.Label_AZ, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
print 'Translations of Labels'' text into Azeri (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			lt.idfsBaseReference,
			dbo.fnGetLanguageCode('az-L'),
			lt.Label_AZ,
			0
from		trtBaseReference br
inner join	@LabelTable lt
on			lt.idfsBaseReference = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = lt.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('az-L')
where		lt.Label_AZ is not null
			and snt.idfsBaseReference is null
print 'Translations of Labels'' text into Azeri (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = lt.Label_GG,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@LabelTable lt
on			lt.idfsBaseReference = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ka')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(lt.Label_GG, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
print 'Translations of Labels'' text into Azerbaijann (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			lt.idfsBaseReference,
			dbo.fnGetLanguageCode('ka'),
			lt.Label_GG,
			0
from		trtBaseReference br
inner join	@LabelTable lt
on			lt.idfsBaseReference = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = lt.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ka')
where		lt.Label_GG is not null
			and snt.idfsBaseReference is null
print 'Translations of Labels'' text into Azerbaijann (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = lt.Label_RU,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@LabelTable lt
on			lt.idfsBaseReference = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ru')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(lt.Label_RU, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
print 'Translations of Labels'' text into Russian (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			lt.idfsBaseReference,
			dbo.fnGetLanguageCode('ru'),
			lt.Label_RU,
			0
from		trtBaseReference br
inner join	@LabelTable lt
on			lt.idfsBaseReference = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = lt.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ru')
where		lt.Label_RU is not null
			and snt.idfsBaseReference is null
print 'Translations of Labels'' text into Russian (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = lt.Label_KZ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@LabelTable lt
on			lt.idfsBaseReference = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('kk')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(lt.Label_KZ, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
print 'Translations of Labels'' text into Kazakh (trtStringNameTranslation) - update ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			lt.idfsBaseReference,
			dbo.fnGetLanguageCode('kk'),
			lt.Label_KZ,
			0
from		trtBaseReference br
inner join	@LabelTable lt
on			lt.idfsBaseReference = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = lt.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('kk')
where		lt.Label_KZ is not null
			and snt.idfsBaseReference is null
print 'Translations of Labels'' text into Kazakh (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = lt.Label_IQ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@LabelTable lt
on			lt.idfsBaseReference = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ar')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(lt.Label_IQ, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
print 'Translations of Labels'' text into Arabic (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			lt.idfsBaseReference,
			dbo.fnGetLanguageCode('ar'),
			lt.Label_IQ,
			0
from		trtBaseReference br
inner join	@LabelTable lt
on			lt.idfsBaseReference = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = lt.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ar')
where		lt.Label_IQ is not null
			and snt.idfsBaseReference is null
print 'Translations of Labels'' text into Arabic (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = lt.Label_UA,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@LabelTable lt
on			lt.idfsBaseReference = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('uk')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(lt.Label_UA, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
print 'Translations of Labels'' text into Ukrainian (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			lt.idfsBaseReference,
			dbo.fnGetLanguageCode('uk'),
			lt.Label_UA,
			0
from		trtBaseReference br
inner join	@LabelTable lt
on			lt.idfsBaseReference = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = lt.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('uk')
where		lt.Label_UA is not null
			and snt.idfsBaseReference is null
print 'Translations of Labels'' text into Ukrainian (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		snt
set			snt.strTextString = lt.Label_TH,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	@LabelTable lt
on			lt.idfsBaseReference = snt.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('th')
			and	(	(IsNull(snt.strTextString, N'') <> IsNull(lt.Label_TH, N'') collate Cyrillic_General_CI_AS)
					or	(snt.intRowStatus <> 0)
				)
print 'Translations of Labels'' text into Thai (trtStringNameTranslation) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select distinct
			lt.idfsBaseReference,
			dbo.fnGetLanguageCode('th'),
			lt.Label_TH,
			0
from		trtBaseReference br
inner join	@LabelTable lt
on			lt.idfsBaseReference = br.idfsBaseReference
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = lt.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('th')
where		lt.Label_TH is not null
			and snt.idfsBaseReference is null
print 'Translations of Labels'' text into Thai (trtStringNameTranslation) - insert: ' + cast(@@rowcount as varchar(20))

update		br_to_c
set			br_to_c.intHACode = null,
			br_to_c.intOrder = 0
from		trtBaseReferenceToCP br_to_c
inner join	tstCustomizationPackage c
on			c.idfCustomizationPackage = br_to_c.idfCustomizationPackage
inner join	@LabelTable lt
on			lt.idfsBaseReference = br_to_c.idfsBaseReference
			and lt.idfCustomizationPackage = c.idfCustomizationPackage
where		(	br_to_c.intHACode is not null
				or IsNull(br_to_c.intOrder, -1) <> 0 
			)
print 'Links from Labels'' text to customization packages (trtBaseReferenceToCP) - update: ' + cast(@@rowcount as varchar(20))

insert into	trtBaseReferenceToCP
(	idfsBaseReference,
	idfCustomizationPackage,
	intHACode,
	intOrder
)
select distinct
			lt.idfsBaseReference,
			c.idfCustomizationPackage,
			null,
			0
from		trtBaseReference br
inner join	@LabelTable lt
on			lt.idfsBaseReference = br.idfsBaseReference
inner join	tstCustomizationPackage c
on			c.idfCustomizationPackage = lt.idfCustomizationPackage
left join	trtBaseReferenceToCP br_to_c
on			br_to_c.idfsBaseReference = lt.idfsBaseReference
			and br_to_c.idfCustomizationPackage = c.idfCustomizationPackage
where		br_to_c.idfsBaseReference is null
print 'Links from Labels'' text to customization packages (trtBaseReferenceToCP) - insert: ' + cast(@@rowcount as varchar(20))


insert into	ffDecorElement
(	idfDecorElement,
	idfsDecorElementType,
	idfsLanguage,
	idfsFormTemplate,
	idfsSection,
	intRowStatus
)
select distinct
			lt.idfDecorElement,
			10106001,		-- Label
			dbo.fnGetLanguageCode('en'),
			lt.idfsFormTemplate,
			s.idfsSection,
			0
from		@LabelTable lt
inner join	ffFormTemplate ft
on			ft.idfsFormTemplate = lt.idfsFormTemplate
left join	ffSection s
on			s.idfsSection = lt.idfsSection
left join	ffDecorElement de
on			de.idfDecorElement = lt.idfDecorElement
where		de.idfDecorElement is null
print 'Labels (ffDecorElement) - insert: ' + cast(@@rowcount as varchar(20))


insert into	ffDecorElementText
(	idfDecorElement,
	idfsBaseReference,
	intFontSize,
	intFontStyle,
	intColor,
	intLeft,
	intTop,
	intWidth,
	intHeight,
	intRowStatus
)
select distinct
			lt.idfDecorElement,
			lt.idfsBaseReference,
			10,
			0,
			-16777216,
			0,
			0,
			100,
			20,
			0
from		@LabelTable lt
inner join	trtBaseReference br
on			br.idfsBaseReference = lt.idfsBaseReference
inner join	ffDecorElement de
on			de.idfDecorElement = lt.idfDecorElement
left join	ffDecorElementText det
on			det.idfsBaseReference = br.idfsBaseReference
where		det.idfDecorElement is null
print 'Labels (ffDecorElementText) - insert: ' + cast(@@rowcount as varchar(20))
print ''
print ''


-- Recalculate design options of sections, parameters, labels in templates
print 'Recalculate design options of sections, parameters, labels in templates'
print ''

insert into	@ParameterTable
(	FormTemplate_EN,
	FormType_EN,
	ParameterOrder,
	SectionPath_EN,
	Section_EN,
	Tooltip_EN,
	idfDefParameterDesignOption,
	idfParameterDesignOption,
	idfCustomizationPackage,
	idfsFormTemplate,
	idfsFormType,
	idfsParameter,
	idfsParameterCaption,
	idfsParameterType,
	idfsSection,
	strCustomizationPackage
)
select		pt.FormTemplate_EN,
			pt.FormType_EN,
			case	p.idfsParameter
				when	226890000000 -- Human Aggregate Case: Diagnosis
					then	1
				when	229630000000 -- Human Aggregate Case: ICD-10 Code
					then	2
				when	239010000000 -- Vet Aggregate Case: Species
					then	1
				when	226910000000 -- Vet Aggregate Case: Diagnosis
					then	2
				when	234410000000 -- Vet Aggregate Case: OIE Code
					then	3
				when	233190000000 -- Veterinary-sanitary measures: Measure Type
					then	1
				when	233150000000 -- Veterinary-sanitary measures: Measure Code
					then	2
				when	231670000000 -- Diagnostic investigations: Investigation type
					then	1
				when	239030000000 -- Diagnostic investigations: Species
					then	2
				when	226930000000 -- Diagnostic investigations: Diagnosis
					then	3
				when	234430000000 -- Diagnostic investigations: OIE Code
					then	4
				when	245270000000 -- Treatment-prophylactics and vaccination measures: Measure Type
					then	1
				when	233170000000 -- Treatment-prophylactics and vaccination measures: Measure Code
					then	2
				when	239050000000 -- Treatment-prophylactics and vaccination measures: Species
					then	3
				when	226950000000 -- Treatment-prophylactics and vaccination measures: Diagnosis
					then	4
				when	234450000000 -- Treatment-prophylactics and vaccination measures: OIE Code
					then	5
				else	0
			end,
			br_s.strDefault,
			br_s.strDefault,
			br_p.strDefault,
			pdo_def.idfParameterDesignOption,
			pdo.idfParameterDesignOption,
			pt.idfCustomizationPackage,
			pt.idfsFormTemplate,
			pt.idfsFormType,
			p.idfsParameter,
			p.idfsParameterCaption,
			p.idfsParameterType,
			s.idfsSection,
			pt.strCustomizationPackage
from		@ParameterTable pt
inner join	ffParameter p
on			p.idfsFormType = pt.idfsFormType
			and p.idfsParameter in
				(	226890000000, -- Human Aggregate Case: Diagnosis
					229630000000, -- Human Aggregate Case: ICD-10 Code
					226910000000, -- Vet Aggregate Case: Diagnosis
					234410000000, -- Vet Aggregate Case: OIE Code
					239010000000, -- Vet Aggregate Case: Species
					233150000000, -- Veterinary-sanitary measures: Measure Code
					233190000000, -- Veterinary-sanitary measures: Measure Type
					226930000000, -- Diagnostic investigations: Diagnosis
					231670000000, -- Diagnostic investigations: Investigation type
					234430000000, -- Diagnostic investigations: OIE Code
					239030000000, -- Diagnostic investigations: Species
					226950000000, -- Treatment-prophylactics and vaccination measures: Diagnosis
					233170000000, -- Treatment-prophylactics and vaccination measures: Measure Code
					245270000000, -- Treatment-prophylactics and vaccination measures: Measure Type
					234450000000, -- Treatment-prophylactics and vaccination measures: OIE Code
					239050000000  -- Treatment-prophylactics and vaccination measures: Species
				)
			and p.intRowStatus = 0
inner join	trtBaseReference br_p
on			br_p.idfsBaseReference = p.idfsParameter
			and br_p.intRowStatus = 0
inner join	trtBaseReferenceToCP brc_p
on			brc_p.idfsBaseReference = p.idfsParameter
			and brc_p.idfCustomizationPackage = pt.idfCustomizationPackage
inner join	ffSection s
	inner join	trtBaseReference br_s
	on			br_s.idfsBaseReference = s.idfsSection
				and br_s.intRowStatus = 0
	inner join	trtBaseReferenceToCP brc_s
	on			brc_s.idfsBaseReference = s.idfsSection
on			s.idfsFormType = pt.idfsFormType
			and s.blnGrid = 1
			and s.idfsParentSection is null
			and brc_s.idfCustomizationPackage = pt.idfCustomizationPackage
			and s.intRowStatus = 0
left join	ffParameterDesignOption pdo_def
on			pdo_def.idfsParameter = p.idfsParameter
			and pdo_def.idfsFormTemplate is null
			and pdo_def.idfsLanguage = dbo.fnGetLanguageCode('en')
left join	ffParameterDesignOption pdo
on			pdo.idfsParameter = p.idfsParameter
			and pdo.idfsFormTemplate = pt.idfsFormTemplate
			and pdo.idfsLanguage = dbo.fnGetLanguageCode('en')
left join	@ParameterTable pt_dupl
on			pt_dupl.idfsFormTemplate = pt.idfsFormTemplate
			and pt_dupl.idfID < pt.idfID
where		pt.idfsFormType in (10034012, 10034021, 10034022, 10034023, 10034024)	-- Aggregate Types
			and pt_dupl.idfID is null

insert into	@ParameterLabelDesignOption (idfsFormTemplate, idfsParameterOrDecorElement, intOrder)
select		pt.idfsFormTemplate,
			pt.idfsParameter,
			pt.ParameterOrder
from		@ParameterTable pt
where		pt.idfsFormTemplate is not null
			and pt.idfsParameter is not null
			and pt.ParameterType_EN <> N'Label'
-- TODO: remove from the script
--			and pt.idfsFormType not in (10034012, 10034021, 10034022, 10034023, 10034024)	-- Aggregate Types

insert into	@ParameterLabelDesignOption (idfsFormTemplate, idfsParameterOrDecorElement, intOrder)
select		lt.idfsFormTemplate,
			lt.idfDecorElement,
			lt.LabelOrder
from		@LabelTable lt
where		lt.idfsFormTemplate is not null
			and lt.idfDecorElement is not null

insert into	@SectionDesignOption (idfsFormTemplate, idfsSection, intOrder)
select		st.idfsFormTemplate,
			st.idfsSection,
			st.SectionOrder
from		@SectionTable st
where		st.idfsFormTemplate is not null
			and st.idfsSection is not null

if	exists	(
		select		*
		from		ffParameterForTemplate pft
		left join	@ParameterLabelDesignOption tt
		on			tt.idfsFormTemplate = pft.idfsFormTemplate
					and tt.idfsParameterOrDecorElement = pft.idfsParameter
		where		pft.intRowStatus = 0
					and	exists	(
							select		*
							from		@ParameterLabelDesignOption t
							where		t.idfsFormTemplate = pft.idfsFormTemplate
								)
					and tt.idfsFormTemplate is null
			)
begin
	raiserror	(
		'There are some parameters in template(s) that are not included in customization format.', -- Message text.
		16,	-- Severity.
		1	-- State.
				)

	select		pft.idfsFormTemplate, pft.idfsParameter
	from		ffParameterForTemplate pft
	left join	@ParameterLabelDesignOption tt
	on			tt.idfsFormTemplate = pft.idfsFormTemplate
				and tt.idfsParameterOrDecorElement = pft.idfsParameter
	where		pft.intRowStatus = 0
				and	exists	(
						select		*
						from		@ParameterLabelDesignOption t
						where		t.idfsFormTemplate = pft.idfsFormTemplate
							)
				and tt.idfsFormTemplate is null
end

if	exists	(
		select		*
		from		ffSectionForTemplate sft
		left join	@SectionDesignOption sdo
		on			sdo.idfsFormTemplate = sft.idfsFormTemplate
					and sdo.idfsSection = sft.idfsSection
		where		sft.intRowStatus = 0
					and	exists	(
							select		*
							from		@SectionDesignOption t
							where		t.idfsFormTemplate = sft.idfsFormTemplate
								)
					and sdo.idfsFormTemplate is null
			)
begin
	raiserror	(
		'There are some sections in template(s) that are not included in customization format.', -- Message text.
		16,	-- Severity.
		1	-- State.
				)

	select		sft.idfsFormTemplate, sft.idfsSection
	from		ffSectionForTemplate sft
	left join	@SectionDesignOption sdo
	on			sdo.idfsFormTemplate = sft.idfsFormTemplate
				and sdo.idfsSection = sft.idfsSection
	where		sft.intRowStatus = 0
				and	exists	(
						select		*
						from		@SectionDesignOption t
						where		t.idfsFormTemplate = sft.idfsFormTemplate
							)
				and sdo.idfsFormTemplate is null
end

-- TODO: Remove select below
		------select		*
		------from		ffDecorElement de
		------left join	@ParameterLabelDesignOption tt
		------on			tt.idfsFormTemplate = de.idfsFormTemplate
		------			and tt.idfsParameterOrDecorElement = de.idfDecorElement
		------where		de.intRowStatus = 0
		------			and	exists	(
		------					select		*
		------					from		@ParameterLabelDesignOption t
		------					where		t.idfsFormTemplate = de.idfsFormTemplate
		------						)
		------			and tt.idfsFormTemplate is null


if	exists	(
		select		*
		from		ffDecorElement de
		left join	@ParameterLabelDesignOption tt
		on			tt.idfsFormTemplate = de.idfsFormTemplate
					and tt.idfsParameterOrDecorElement = de.idfDecorElement
		where		de.intRowStatus = 0
					and	exists	(
							select		*
							from		@ParameterLabelDesignOption t
							where		t.idfsFormTemplate = de.idfsFormTemplate
								)
					and tt.idfsFormTemplate is null
			)
begin
	raiserror	(
		'There are some labels in template(s) that are not included in customization format.', -- Message text.
		16,	-- Severity.
		1	-- State.
				)

	select		de.idfsFormTemplate, de.idfDecorElement
	from		ffDecorElement de
	left join	@ParameterLabelDesignOption tt
	on			tt.idfsFormTemplate = de.idfsFormTemplate
				and tt.idfsParameterOrDecorElement = de.idfDecorElement
	where		de.intRowStatus = 0
				and	exists	(
						select		*
						from		@ParameterLabelDesignOption t
						where		t.idfsFormTemplate = de.idfsFormTemplate
							)
				and tt.idfsFormTemplate is null
end

if	exists	(
		select		*
		from		@ParameterLabelDesignOption tt
		left join	ffParameterForTemplate pft
		on			pft.idfsFormTemplate = tt.idfsFormTemplate
					and pft.idfsParameter = tt.idfsParameterOrDecorElement
					and pft.intRowStatus = 0
		left join	ffDecorElement de
		on			de.idfsFormTemplate = tt.idfsFormTemplate
					and de.idfDecorElement = tt.idfsParameterOrDecorElement
					and de.intRowStatus = 0
		where		pft.idfsFormTemplate is null
					and de.idfDecorElement is null
					and tt.idfsParameterOrDecorElement not in
						(	226890000000, -- Human Aggregate Case: Diagnosis
							229630000000, -- Human Aggregate Case: ICD-10 Code
							226910000000, -- Vet Aggregate Case: Diagnosis
							234410000000, -- Vet Aggregate Case: OIE Code
							239010000000, -- Vet Aggregate Case: Species
							233150000000, -- Veterinary-sanitary measures: Measure Code
							233190000000, -- Veterinary-sanitary measures: Measure Type
							226930000000, -- Diagnostic investigations: Diagnosis
							231670000000, -- Diagnostic investigations: Investigation type
							234430000000, -- Diagnostic investigations: OIE Code
							239030000000, -- Diagnostic investigations: Species
							226950000000, -- Treatment-prophylactics and vaccination measures: Diagnosis
							233170000000, -- Treatment-prophylactics and vaccination measures: Measure Code
							245270000000, -- Treatment-prophylactics and vaccination measures: Measure Type
							234450000000, -- Treatment-prophylactics and vaccination measures: OIE Code
							239050000000  -- Treatment-prophylactics and vaccination measures: Species
						)
			)
begin
	raiserror	(
		'There are some parameters or labels not from template(s) that are included in customization format.', -- Message text.
		16,	-- Severity.
		1	-- State.
				)

	select		tt.idfsFormTemplate, tt.idfsParameterOrDecorElement
	from		@ParameterLabelDesignOption tt
	left join	ffParameterForTemplate pft
	on			pft.idfsFormTemplate = tt.idfsFormTemplate
				and pft.idfsParameter = tt.idfsParameterOrDecorElement
				and pft.intRowStatus = 0
	left join	ffDecorElement de
	on			de.idfsFormTemplate = tt.idfsFormTemplate
				and de.idfDecorElement = tt.idfsParameterOrDecorElement
				and de.intRowStatus = 0
	where		pft.idfsFormTemplate is null
				and de.idfDecorElement is null
				and tt.idfsParameterOrDecorElement not in
					(	226890000000, -- Human Aggregate Case: Diagnosis
						229630000000, -- Human Aggregate Case: ICD-10 Code
						226910000000, -- Vet Aggregate Case: Diagnosis
						234410000000, -- Vet Aggregate Case: OIE Code
						239010000000, -- Vet Aggregate Case: Species
						233150000000, -- Veterinary-sanitary measures: Measure Code
						233190000000, -- Veterinary-sanitary measures: Measure Type
						226930000000, -- Diagnostic investigations: Diagnosis
						231670000000, -- Diagnostic investigations: Investigation type
						234430000000, -- Diagnostic investigations: OIE Code
						239030000000, -- Diagnostic investigations: Species
						226950000000, -- Treatment-prophylactics and vaccination measures: Diagnosis
						233170000000, -- Treatment-prophylactics and vaccination measures: Measure Code
						245270000000, -- Treatment-prophylactics and vaccination measures: Measure Type
						234450000000, -- Treatment-prophylactics and vaccination measures: OIE Code
						239050000000  -- Treatment-prophylactics and vaccination measures: Species
					)
				
end

if	exists	(
		select		*
		from		@SectionDesignOption sdo
		left join	ffSectionForTemplate sft
		on			sft.idfsFormTemplate = sdo.idfsFormTemplate
					and sft.idfsSection = sdo.idfsSection
					and sft.intRowStatus = 0
		where		sft.idfsFormTemplate is null
			)
begin
	raiserror	(
		'There are some sections not in template(s) that are included in customization format.', -- Message text.
		16,	-- Severity.
		1	-- State.
				)

	select		sdo.idfsFormTemplate, sdo.idfsSection
	from		@SectionDesignOption sdo
	left join	ffSectionForTemplate sft
	on			sft.idfsFormTemplate = sdo.idfsFormTemplate
				and sft.idfsSection = sdo.idfsSection
				and sft.intRowStatus = 0
	where		sft.idfsFormTemplate is null

end


print 'Prepare tables, containing all Sections and structure of Sections, after new sections are added'
delete from	@SectionStructure

delete from	@AllSections

-- Table with all sections in the database after new sections are added. 
insert into	@AllSections
(	idfsSection,
	idfsParentSection,
	strSectionEN,
	blnGrid
)
select		s.idfsSection,
			s_parent.idfsSection,
			r_s_en.[name],
			s.blnGrid
from		ffSection s
inner join	fnReference('en', 19000101) r_s_en				-- Flexible Form Section
on			r_s_en.idfsReference = s.idfsSection
left join	(
	ffSection s_parent
	inner join	fnReference('en', 19000101) r_s_parent_en	-- Flexible Form Section
	on			r_s_parent_en.idfsReference = s_parent.idfsSection
			)
on			s_parent.idfsSection = s.idfsParentSection
			and s_parent.intRowStatus = 0
where		s.intRowStatus = 0
print 'Total number of sections in the database after new sections are added: ' + cast(@@rowcount as varchar(20))
;
with	updatedSectionTable	(
			idfsSection,
			intParentLevel,
			idfsLevelParentSection,
			strLevelSectionPathEN,
			blnGrid
					)
as	(	select		s.idfsSection,
					0 as intParentLevel,
					s.idfsParentSection as idfsLevelParentSection,
					cast(s.strSectionEN as nvarchar(MAX)) as strLevelSectionPathEN,
					s.blnGrid
		from		@AllSections s
		union all
		select		updatedSectionTable.idfsSection,
					updatedSectionTable.intParentLevel + 1 as intParentLevel,
					s_all.idfsParentSection as idfsLevelParentSection,
						cast((s_all.strSectionEN + N'>' + updatedSectionTable.strLevelSectionPathEN) as nvarchar(MAX)) as strLevelSectionPathEN,
					s_all.blnGrid
		from		@AllSections s_all
		inner join	updatedSectionTable
		on			updatedSectionTable.idfsLevelParentSection = s_all.idfsSection
	)

insert into	@SectionStructure
(	idfsSection,
	intParentLevel,
	idfsLevelParentSection,
	strLevelSectionPathEN,
	blnGrid
)
select		idfsSection,
			intParentLevel,
			idfsLevelParentSection,
			strLevelSectionPathEN,
			blnGrid
from		updatedSectionTable
print 'Total number of sections and all their parent sections in the database after new sections are added: ' + cast(@@rowcount as varchar(20))

print	''

-- Table with size and location options depending on FF form type
declare	@FFFormTypeDesignOption	table
(	idfsFormType						bigint	not null primary key,
	intTemplateWidth					int not null,
	intParameterHeight					int not null,
	intLabelHeight						int not null,
	intTableSectionHeight				int not null default (192),
	intTableParameterWidth				int not null default (112),
	intSystemTableParameterWidth		int not null default (56),
	blnHideRootTableSectionHeader		int not null default (0)
)

insert into	@FFFormTypeDesignOption	(idfsFormType, intTemplateWidth, intParameterHeight, intLabelHeight, intTableSectionHeight)
values		(	10034007,	-- Avian Farm EPI
				448-16,		-- Template Width
				40,			-- Parameter Height
				32,			-- Label Height
				192			-- Table Section Height
			) 

insert into	@FFFormTypeDesignOption	(idfsFormType, intTemplateWidth, intParameterHeight, intLabelHeight, intTableSectionHeight)
values		(	10034008,	-- Avian Species CS
				448-16,		-- Template Width
				40,			-- Parameter Height
				32,			-- Label Height
				192			-- Table Section Height
			) 
insert into	@FFFormTypeDesignOption	(idfsFormType, intTemplateWidth, intParameterHeight, intLabelHeight, intTableSectionHeight)
values		(	10034010,	-- Human Clinical Signs
				772-16,		-- Template Width
				56,			-- Parameter Height
				40,			-- Label Height
				192			-- Table Section Height
			) 
insert into	@FFFormTypeDesignOption	(idfsFormType, intTemplateWidth, intParameterHeight, intLabelHeight, intTableSectionHeight)
values		(	10034011,	-- Human Epi Investigations
				772-16,		-- Template Width
				56,			-- Parameter Height
				40,			-- Label Height
				192			-- Table Section Height
			) 
insert into	@FFFormTypeDesignOption	(idfsFormType, intTemplateWidth, intParameterHeight, intLabelHeight, intTableSectionHeight)
values		(	10034013,	-- Livestock Animal CS
				336-16,		-- Template Width
				32,			-- Parameter Height
				32,			-- Label Height
				192			-- Table Section Height
			) 
insert into	@FFFormTypeDesignOption	(idfsFormType, intTemplateWidth, intParameterHeight, intLabelHeight, intTableSectionHeight)
values		(	10034014,	-- Livestock Control Measures
				520-16,		-- Template Width
				32,			-- Parameter Height
				32,			-- Label Height
				192			-- Table Section Height
			) 
insert into	@FFFormTypeDesignOption	(idfsFormType, intTemplateWidth, intParameterHeight, intLabelHeight, intTableSectionHeight)
values		(	10034015,	-- Livestock Farm EPI
				448-16,		-- Template Width
				40,			-- Parameter Height
				32,			-- Label Height
				192			-- Table Section Height
			) 
insert into	@FFFormTypeDesignOption	(idfsFormType, intTemplateWidth, intParameterHeight, intLabelHeight, intTableSectionHeight)
values		(	10034016,	-- Livestock Species CS
				448-16,		-- Template Width
				32,			-- Parameter Height
				32,			-- Label Height
				192			-- Table Section Height
			) 
insert into	@FFFormTypeDesignOption	(idfsFormType, intTemplateWidth, intParameterHeight, intLabelHeight, intTableSectionHeight)
values		(	10034018,	-- Test Details
				184-16,		-- Template Width
				80,			-- Parameter Height
				32,			-- Label Height
				192			-- Table Section Height
			) 
insert into	@FFFormTypeDesignOption	(idfsFormType, intTemplateWidth, intParameterHeight, intLabelHeight, intTableSectionHeight)
values		(	10034019,	-- Test Run
				184-16,		-- Template Width
				80,			-- Parameter Height
				32,			-- Label Height
				192			-- Table Section Height
			) 
insert into	@FFFormTypeDesignOption	(idfsFormType, intTemplateWidth, intParameterHeight, intLabelHeight, intTableSectionHeight)
values		(	10034025,	-- Vector type specific data
				448-16,		-- Template Width
				40,			-- Parameter Height
				32,			-- Label Height
				192			-- Table Section Height
			) 
insert into	@FFFormTypeDesignOption	(	idfsFormType, intTemplateWidth, intParameterHeight, intLabelHeight, 
										intTableSectionHeight, intTableParameterWidth, blnHideRootTableSectionHeader)
values		(	10034012,	-- Human Aggregate Case
				976,		-- Template Width
				320,		-- Parameter Height
				32,			-- Label Height
				321,		-- Table Section Height
				120,		-- Table Parameter Width
				1			-- Hide root table section header 
			) 
insert into	@FFFormTypeDesignOption	(	idfsFormType, intTemplateWidth, intParameterHeight, intLabelHeight, 
										intTableSectionHeight, intTableParameterWidth, blnHideRootTableSectionHeader)
values		(	10034021,	-- Vet Aggregate Case
				979,		-- Template Width
				320,		-- Parameter Height
				32,			-- Label Height
				321,		-- Table Section Height
				300,		-- Table Parameter Width
				1			-- Hide root table section header 
			) 
insert into	@FFFormTypeDesignOption	(	idfsFormType, intTemplateWidth, intParameterHeight, intLabelHeight, 
										intTableSectionHeight, intTableParameterWidth, blnHideRootTableSectionHeader)
values		(	10034022,	-- Veterinary-sanitary measures
				976,		-- Template Width
				320,		-- Parameter Height
				32,			-- Label Height
				322,		-- Table Section Height
				200,		-- Table Parameter Width
				1			-- Hide root table section header 
			) 
insert into	@FFFormTypeDesignOption	(	idfsFormType, intTemplateWidth, intParameterHeight, intLabelHeight, 
										intTableSectionHeight, intTableParameterWidth, blnHideRootTableSectionHeader)
values		(	10034023,	-- Diagnostic investigations
				976,		-- Template Width
				320,		-- Parameter Height
				32,			-- Label Height
				322,		-- Table Section Height
				200,		-- Table Parameter Width
				1			-- Hide root table section header 
			) 
insert into	@FFFormTypeDesignOption	(	idfsFormType, intTemplateWidth, intParameterHeight, intLabelHeight, 
										intTableSectionHeight, intTableParameterWidth, blnHideRootTableSectionHeader)
values		(	10034024,	-- Treatment-prophylactics and vaccination measures
				976,		-- Template Width
				320,		-- Parameter Height
				32,			-- Label Height
				322,		-- Table Section Height
				200,		-- Table Parameter Width
				1			-- Hide root table section header 
			) 



declare	@intFlatSectionHeaderHeight	int
declare	@intFlatSectionHeaderFooterHeight	int
declare	@intRootTableSectionHeaderHeight	int
declare	@intTableSubSectionHeaderHeight		int
declare	@intHorizontalShift					int
declare	@intFlatSectionBorderSize			int
declare	@intVerticalShift					int

set	@intFlatSectionHeaderHeight = 26		-- Height of header of flat section
set	@intRootTableSectionHeaderHeight = 52	-- Height of the header of root table section and buttons Copy/Remove
set	@intTableSubSectionHeaderHeight = 26	-- Height of header of table sub-section
set	@intHorizontalShift = 4					-- Horizontal shift from the section left border to the control left position
set	@intFlatSectionBorderSize = 2			-- Size of the border of flat section
set	@intVerticalShift = 4					-- Vertical shift from the begining of the template 
											-- or the bottom of the previous control
											-- to the control top position
set	@intFlatSectionHeaderFooterHeight =		-- Height of header and footer of flat section
		@intFlatSectionHeaderHeight + @intVerticalShift + 2 * @intFlatSectionBorderSize	


print 'Update or insert missing default design options of parameters'
-- Update existing default design options of parameters, which default sizes are equal to 0.
update		pdo
set			pdo.intHeight = ftdo.intParameterHeight,
			pdo.intWidth = ftdo.intTemplateWidth,
			pdo.intLabelSize = ftdo.intTemplateWidth / 2
from		@ParameterLabelDesignOption tt
inner join	ffParameter p
on			p.idfsParameter = tt.idfsParameterOrDecorElement
			and p.intRowStatus = 0
inner join	ffParameterDesignOption pdo
on			pdo.idfsParameter = p.idfsParameter
			and pdo.idfsFormTemplate is null
			and pdo.idfsLanguage = dbo.fnGetLanguageCode('en')
			and pdo.intRowStatus = 0
inner join	@FFFormTypeDesignOption ftdo
on			ftdo.idfsFormType = p.idfsFormType
where		(	pdo.intHeight <= 0
				or	pdo.intWidth <= 0
				or	pdo.intLabelSize <= 0
			)
print	'Default design options of parameters (ffParameterDesignOption) - update (if sizes are equal to or less than 0): ' + cast(@@rowcount as varchar(20))

-- Insert new default design options for parameters, which doesn't have them.
insert into	tstNewID
(	idfTable,
	idfKey1
)
select distinct
			74870000000,	-- ffParameterDesignOption
			p.idfsParameter
from		@ParameterLabelDesignOption tt
inner join	ffParameter p
on			p.idfsParameter = tt.idfsParameterOrDecorElement
			and p.intRowStatus = 0
left join	ffParameterDesignOption pdo
on			pdo.idfsParameter = p.idfsParameter
			and pdo.idfsFormTemplate is null
			and pdo.idfsLanguage = dbo.fnGetLanguageCode('en')
			and pdo.intRowStatus = 0
where		pdo.idfParameterDesignOption is null


insert into	ffParameterDesignOption
(	idfParameterDesignOption,
	idfsParameter,
	idfsLanguage,
	idfsFormTemplate,
	intLeft,
	intTop,
	intWidth,
	intHeight,
	intScheme,
	intLabelSize,
	intOrder,
	intRowStatus
)
select distinct
			nID.[NewID],
			p.idfsParameter,
			dbo.fnGetLanguageCode('en'),
			null,
			0,
			0,
			150,
			100,
			0,
			75,
			0,
			0
from		@ParameterLabelDesignOption tt
inner join	ffParameter p
on			p.idfsParameter = tt.idfsParameterOrDecorElement
			and p.intRowStatus = 0
inner join	tstNewID nID
on			nID.idfTable = 74870000000	-- ffParameterDesignOption
			and nID.idfKey1 = p.idfsParameter
print	'Default design options of parameters (ffParameterDesignOption) - insert: ' + cast(@@rowcount as varchar(20))

delete from	tstNewID
where		idfTable = 74870000000	-- ffParameterDesignOption

print ''

print 'Calculate sizes and positions of sections, parameters and labels'

-- Design options of flat parameters
update		pldo_p
set			
			pldo_p.intHeight = ftdo.intParameterHeight,
			
			pldo_p.intLeft = @intHorizontalShift,
			
			pldo_p.intTop = 
				-- Vertical Shift
				@intVerticalShift +
				-- Product of the number of flat sections, 
				--					which belong to the same parent section as the selected parameter
				--					or do not belong to any parent section as the selected parameter,
				--					are not parent sections for the section, to which the selected parameter belongs,
				--					and have the serial numbers in the template less than 
				--						the serial number of the selected parameter in the same template,
				-- and the sum of vertical shift and height of header and footer of flat section
				(	select		count(*) * (@intVerticalShift + @intFlatSectionHeaderFooterHeight)
					from		@SectionTable st_prev
					left join	@SectionStructure s_str_st_prev
						inner join	@SectionTable st_s_str_st_prev
						on			st_s_str_st_prev.idfsSection = s_str_st_prev.idfsSection
					on			st_s_str_st_prev.idfsSection = st_prev.idfsParentSection
								and st_s_str_st_prev.idfsFormTemplate = st_prev.idfsFormTemplate
								and st_s_str_st_prev.idfCustomizationPackage = st_prev.idfCustomizationPackage
					where		st_prev.idfsFormTemplate = pt.idfsFormTemplate
								and	IsNull(st_prev.blnGrid, 0) = 0
								and st_prev.idfCustomizationPackage = pt.idfCustomizationPackage
								and st_prev.SectionOrder < pt.ParameterOrder
								and	IsNull(st_s_str_st_prev.blnGrid, 0) = 0
								and IsNull(st_s_str_st_prev.SectionOrder, -1) <= pt.ParameterOrder
								and (	IsNull(s_str_st_prev.idfsLevelParentSection, -1) = IsNull(s_str.idfsSection, -1)
										or	(	IsNull(s_str_st_prev.idfsSection, -1) = IsNull(s_str.idfsSection, -1)
												and IsNull(s_str_st_prev.intParentLevel, 0) = 0
											)
									)
				) +
				-- Product of the number of flat parameters, 
				--					which belong to the sections that meet criteria described above,
				--					or do not belong to any section as the selected parameter,
				--					and have the serial numbers in the template less than 
				--						the serial number of the selected parameter in the same template,
				-- and the sum of vertical shift and flat parameter height specified for selected form type
				(	select		count(*) * (@intVerticalShift + ftdo.intParameterHeight)
					from		@ParameterTable pt_prev
					left join	@SectionStructure s_str_prev_pt_prev
						inner join	@SectionTable st_pt_prev
						on			st_pt_prev.idfsSection = s_str_prev_pt_prev.idfsSection
					on			s_str_prev_pt_prev.idfsSection = pt_prev.idfsSection
								and st_pt_prev.idfsFormTemplate = pt_prev.idfsFormTemplate
								and st_pt_prev.idfCustomizationPackage = pt_prev.idfCustomizationPackage
					where		pt_prev.idfsFormTemplate = pt.idfsFormTemplate
								and pt_prev.idfCustomizationPackage = pt.idfCustomizationPackage
								and pt_prev.ParameterType_EN <> N'Label'
								and pt_prev.ParameterOrder < pt.ParameterOrder
								and IsNull(st_pt_prev.blnGrid, 0) = 0
								and IsNull(st_pt_prev.SectionOrder, -1) <= pt.ParameterOrder
								and (	IsNull(s_str_prev_pt_prev.idfsLevelParentSection, -1) = IsNull(s_str.idfsSection, -1)
										or	(	IsNull(s_str_prev_pt_prev.idfsSection, -1) = IsNull(s_str.idfsSection, -1)
												and IsNull(s_str_prev_pt_prev.intParentLevel, 0) = 0
											)
									)
				) +
				-- Product of the number of labels, 
				--					which belong to the sections that meet criteria described above,
				--					or do not belong to any section as the selected parameter,
				--					and have the serial numbers in the template less than 
				--						the serial number of the selected parameter in the same template,
				-- and the sum of vertical shift and label height specified for selected form type
				(	select		count(*) * (@intVerticalShift + ftdo.intLabelHeight)
					from		@ParameterTable l_prev
					left join	@SectionStructure s_str_prev_l_prev
						inner join	@SectionTable st_l_prev
						on			st_l_prev.idfsSection = s_str_prev_l_prev.idfsSection
					on			s_str_prev_l_prev.idfsSection = l_prev.idfsSection
								and st_l_prev.idfsFormTemplate = l_prev.idfsFormTemplate
								and st_l_prev.idfCustomizationPackage = l_prev.idfCustomizationPackage
					where		l_prev.idfsFormTemplate = pt.idfsFormTemplate
								and l_prev.idfCustomizationPackage = pt.idfCustomizationPackage
								and l_prev.ParameterType_EN = N'Label'
								and l_prev.ParameterOrder < pt.ParameterOrder
								and IsNull(st_l_prev.blnGrid, 0) = 0
								and IsNull(st_l_prev.SectionOrder, -1) <= pt.ParameterOrder
								and (	IsNull(s_str_prev_l_prev.idfsLevelParentSection, -1) = IsNull(s_str.idfsSection, -1)
										or	(	IsNull(s_str_prev_l_prev.idfsSection, -1) = IsNull(s_str.idfsSection, -1)
												and IsNull(s_str_prev_l_prev.intParentLevel, 0) = 0
											)
									)
				) +
				-- Product of the number of root table sections, 
				--					which belong to the sections that meet criteria described above,
				--					or do not belong to any section as the selected parameter,
				--					and have the serial numbers in the template less than 
				--						the serial number of the selected parameter in the same template,
				-- and the sum of vertical shift and table section height specified for selected form type
				(	select		count(*) * (@intVerticalShift + ftdo.intTableSectionHeight)
					from		@SectionTable st_table_prev
					left join	@SectionStructure s_str_prev_st_table_prev
						inner join	@SectionTable st_st_table_prev
						on			st_st_table_prev.idfsSection = s_str_prev_st_table_prev.idfsSection
					on			s_str_prev_st_table_prev.idfsSection = st_table_prev.idfsParentSection
								and st_st_table_prev.idfsFormTemplate = st_table_prev.idfsFormTemplate
								and st_st_table_prev.idfCustomizationPackage = st_table_prev.idfCustomizationPackage
					left join	@SectionStructure st_table_prev_1
					on			st_table_prev_1.idfsSection = st_table_prev.idfsSection
								and st_table_prev_1.intParentLevel = 1
					where		st_table_prev.idfsFormTemplate = pt.idfsFormTemplate
								and st_table_prev.idfCustomizationPackage = pt.idfCustomizationPackage
								and IsNull(st_table_prev.blnGrid, 0) = 1
								and IsNull(st_table_prev_1.blnGrid, 0) = 0
								and st_table_prev.SectionOrder < pt.ParameterOrder
								and IsNull(st_st_table_prev.blnGrid, 0) = 0
								and IsNull(st_st_table_prev.SectionOrder, -1) <= pt.ParameterOrder
								and (	IsNull(s_str_prev_st_table_prev.idfsLevelParentSection, -1) = IsNull(s_str.idfsSection, -1)
										or	(	IsNull(s_str_prev_st_table_prev.idfsSection, -1) = IsNull(s_str.idfsSection, -1)
												and IsNull(s_str_prev_st_table_prev.intParentLevel, 0) = 0
											)
									)
				),

			pldo_p.intWidth = 
				-- Template width specified for form type minus
				ftdo.intTemplateWidth - 
				-- Two horizontal shifts
				@intHorizontalShift * 2 -
				-- The product of two sum of horizontal shift and flat section border size
				-- and the number of flat sections, to which the selected parameter belongs
				(@intFlatSectionBorderSize + @intHorizontalShift) * 2 * (IsNull(s_str_maxlevel.intParentLevel + 1, 0)),

			pldo_p.intLabelSize = 
			-- A half of parameter width
				ftdo.intTemplateWidth / 2 - 
				@intHorizontalShift -
				(@intFlatSectionBorderSize + @intHorizontalShift) * (IsNull(s_str_maxlevel.intParentLevel + 1, 0)),

			pldo_p.intScheme = 0

from		@ParameterLabelDesignOption pldo_p
inner join	@ParameterTable pt
on			pt.idfsParameter = pldo_p.idfsParameterOrDecorElement
			and	pt.idfsFormTemplate = pldo_p.idfsFormTemplate
			and pt.ParameterType_EN <> N'Label'
inner join	@FFFormTypeDesignOption ftdo
on			ftdo.idfsFormType = pt.idfsFormType
left join	@SectionStructure s_str
	inner join	@SectionStructure s_str_maxlevel
	on			s_str_maxlevel.idfsSection = s_str.idfsSection
				and s_str_maxlevel.idfsLevelParentSection is null
on			s_str.idfsSection = pt.idfsSection
			and s_str.intParentLevel = 0
where		(	s_str.idfsSection is null
				or	(	s_str.idfsSection is not null
						and IsNull(s_str.blnGrid, 0) = 0
					)
			)

-- Design options of labels
update		pldo_l
set			
			pldo_l.intHeight = ftdo.intLabelHeight,
			
			pldo_l.intLeft = @intHorizontalShift,
			
			pldo_l.intTop = 
				-- Vertical Shift
				@intVerticalShift +
				-- Product of the number of flat sections, 
				--					which belong to the same parent section as the selected label
				--					or do not belong to any parent section as the selected label,
				--					are not parent sections for the section, to which the selected label belongs,
				--					and have the serial numbers in the template less than 
				--						the serial number of the selected label in the same template,
				-- and the sum of vertical shift and height of header and footer of flat section
				(	select		count(*) * (@intVerticalShift + @intFlatSectionHeaderFooterHeight)
					from		@SectionTable st_prev
					left join	@SectionStructure s_str_st_prev
						inner join	@SectionTable st_s_str_st_prev
						on			st_s_str_st_prev.idfsSection = s_str_st_prev.idfsSection
					on			st_s_str_st_prev.idfsSection = st_prev.idfsParentSection
								and st_s_str_st_prev.idfsFormTemplate = st_prev.idfsFormTemplate
								and st_s_str_st_prev.idfCustomizationPackage = st_prev.idfCustomizationPackage
					where		st_prev.idfsFormTemplate = pt.idfsFormTemplate
								and st_prev.idfCustomizationPackage = pt.idfCustomizationPackage
								and	IsNull(st_prev.blnGrid, 0) = 0
								and st_prev.SectionOrder < pt.ParameterOrder
								and	IsNull(st_s_str_st_prev.blnGrid, 0) = 0
								and IsNull(st_s_str_st_prev.SectionOrder, -1) <= pt.ParameterOrder
								and (	IsNull(s_str_st_prev.idfsLevelParentSection, -1) = IsNull(s_str.idfsSection, -1)
										or	(	IsNull(s_str_st_prev.idfsSection, -1) = IsNull(s_str.idfsSection, -1)
												and IsNull(s_str_st_prev.intParentLevel, 0) = 0
											)
									)
				) +
				-- Product of the number of flat parameters, 
				--					which belong to the sections that meet criteria described above,
				--					or do not belong to any section as the parameter,
				--					and have the serial numbers in the template less than 
				--						the serial number of the parameter in the same template,
				-- and the sum of vertical shift and flat parameter height specified for selected form type
				(	select		count(*) * (@intVerticalShift + ftdo.intParameterHeight)
					from		@ParameterTable pt_prev
					left join	@SectionStructure s_str_prev_pt_prev
						inner join	@SectionTable st_pt_prev
						on			st_pt_prev.idfsSection = s_str_prev_pt_prev.idfsSection
					on			s_str_prev_pt_prev.idfsSection = pt_prev.idfsSection
								and st_pt_prev.idfsFormTemplate = pt_prev.idfsFormTemplate
								and st_pt_prev.idfCustomizationPackage = pt_prev.idfCustomizationPackage
					where		pt_prev.idfsFormTemplate = pt.idfsFormTemplate
								and pt_prev.idfCustomizationPackage = pt.idfCustomizationPackage
								and pt_prev.ParameterType_EN <> N'Label'
								and pt_prev.ParameterOrder < pt.ParameterOrder
								and IsNull(st_pt_prev.blnGrid, 0) = 0
								and IsNull(st_pt_prev.SectionOrder, -1) <= pt.ParameterOrder
								and (	IsNull(s_str_prev_pt_prev.idfsLevelParentSection, -1) = IsNull(s_str.idfsSection, -1)
										or	(	IsNull(s_str_prev_pt_prev.idfsSection, -1) = IsNull(s_str.idfsSection, -1)
												and IsNull(s_str_prev_pt_prev.intParentLevel, 0) = 0
											)
									)
				) +
				-- Product of the number of labels, 
				--					which belong to the sections that meet criteria described above,
				--					or do not belong to any section as the selected label,
				--					and have the serial numbers in the template less than 
				--						the serial number of the selected label in the same template,
				-- and the sum of vertical shift and label height specified for selected form type
				(	select		count(*) * (@intVerticalShift + ftdo.intLabelHeight)
					from		@ParameterTable l_prev
					left join	@SectionStructure s_str_prev_l_prev
						inner join	@SectionTable st_l_prev
						on			st_l_prev.idfsSection = s_str_prev_l_prev.idfsSection
					on			s_str_prev_l_prev.idfsSection = l_prev.idfsSection
								and st_l_prev.idfsFormTemplate = l_prev.idfsFormTemplate
								and st_l_prev.idfCustomizationPackage = l_prev.idfCustomizationPackage
					where		l_prev.idfsFormTemplate = pt.idfsFormTemplate
								and l_prev.idfCustomizationPackage = pt.idfCustomizationPackage
								and l_prev.ParameterType_EN = N'Label'
								and l_prev.ParameterOrder < pt.ParameterOrder
								and IsNull(st_l_prev.blnGrid, 0) = 0
								and IsNull(st_l_prev.SectionOrder, -1) <= pt.ParameterOrder
								and (	IsNull(s_str_prev_l_prev.idfsLevelParentSection, -1) = IsNull(s_str.idfsSection, -1)
										or	(	IsNull(s_str_prev_l_prev.idfsSection, -1) = IsNull(s_str.idfsSection, -1)
												and IsNull(s_str_prev_l_prev.intParentLevel, 0) = 0
											)
									)
				) +
				-- Product of the number of root table sections, 
				--					which belong to the sections that meet criteria described above,
				--					or do not belong to any section as the selected label,
				--					and have the serial numbers in the template less than 
				--						the serial number of the selected label in the same template,
				-- and the sum of vertical shift and table section height specified for selected form type
				(	select		count(*) * (@intVerticalShift + ftdo.intTableSectionHeight)
					from		@SectionTable st_table_prev
					left join	@SectionStructure s_str_prev_st_table_prev
						inner join	@SectionTable st_st_table_prev
						on			st_st_table_prev.idfsSection = s_str_prev_st_table_prev.idfsSection
					on			s_str_prev_st_table_prev.idfsSection = st_table_prev.idfsParentSection
								and st_st_table_prev.idfsFormTemplate = st_table_prev.idfsFormTemplate
								and st_st_table_prev.idfCustomizationPackage = st_table_prev.idfCustomizationPackage
					left join	@SectionStructure st_table_prev_1
					on			st_table_prev_1.idfsSection = st_table_prev.idfsSection
								and st_table_prev_1.intParentLevel = 1
					where		st_table_prev.idfsFormTemplate = pt.idfsFormTemplate
								and st_table_prev.idfCustomizationPackage = pt.idfCustomizationPackage
								and IsNull(st_table_prev.blnGrid, 0) = 1
								and IsNull(st_table_prev_1.blnGrid, 0) = 0
								and st_table_prev.SectionOrder < pt.ParameterOrder
								and IsNull(st_st_table_prev.blnGrid, 0) = 0
								and IsNull(st_st_table_prev.SectionOrder, -1) <= pt.ParameterOrder
								and (	IsNull(s_str_prev_st_table_prev.idfsLevelParentSection, -1) = IsNull(s_str.idfsSection, -1)
										or	(	IsNull(s_str_prev_st_table_prev.idfsSection, -1) = IsNull(s_str.idfsSection, -1)
												and IsNull(s_str_prev_st_table_prev.intParentLevel, 0) = 0
											)
									)
				),

			pldo_l.intWidth = 
				-- Template width specified for form type minus
				ftdo.intTemplateWidth - 
				-- Two horizontal shifts
				@intHorizontalShift * 2 -
				-- The product of two sum of horizontal shift and flat section border size
				-- and the number of flat sections, to which the selected label belongs
				(@intFlatSectionBorderSize + @intHorizontalShift) * 2 * (IsNull(s_str_maxlevel.intParentLevel + 1, 0)),

			pldo_l.intLabelSize = 
				-- The same as label width
				ftdo.intTemplateWidth - 
				@intHorizontalShift * 2 -
				(@intFlatSectionBorderSize + @intHorizontalShift) * 2 * (IsNull(s_str_maxlevel.intParentLevel + 1, 0)),

			pldo_l.intScheme = 0

from		@ParameterLabelDesignOption pldo_l
inner join	@ParameterTable pt
on			pt.idfParameterDesignOption = pldo_l.idfsParameterOrDecorElement
			and	pt.idfsFormTemplate = pldo_l.idfsFormTemplate
			and pt.ParameterType_EN = N'Label'
inner join	@FFFormTypeDesignOption ftdo
on			ftdo.idfsFormType = pt.idfsFormType
left join	@SectionStructure s_str
	inner join	@SectionStructure s_str_maxlevel
	on			s_str_maxlevel.idfsSection = s_str.idfsSection
				and s_str_maxlevel.idfsLevelParentSection is null
on			s_str.idfsSection = pt.idfsSection
			and s_str.intParentLevel = 0
where		(	s_str.idfsSection is null
				or	(	s_str.idfsSection is not null
						and IsNull(s_str.blnGrid, 0) = 0
					)
			)

-- Design options of table parameters
update		pldo_p
set			
			pldo_p.intHeight = 
				-- Table section height specified for form type minus
				ftdo.intTableSectionHeight -
				-- Height of root table section and buttons Copy/Remove 
				-- if root table section header and buttons shall not be hidden for selected form type
				(1 - ftdo.blnHideRootTableSectionHeader) * @intRootTableSectionHeaderHeight -
				-- The product of the number of parent table sub-sections (that do not coincide with not root table section)
				-- and height of the header of table sub-sections (not root)
				s_str_maxtablelevel.intParentLevel * @intTableSubSectionHeaderHeight,
			
			pldo_p.intLeft = 
				-- The product of the number of not system parameters,
				--						which belong to the same table section
				--						and have the serial numbers in the template less than 
				--									the serial number of the parameter in the same template,
				-- and the width of table parameter specified for selected form type
				(	select		count(*) * ftdo.intTableParameterWidth
					from		@ParameterTable pt_table_prev
					inner join	@SectionStructure s_str_pt_table_prev
					on			s_str_pt_table_prev.idfsSection = pt_table_prev.idfsSection
								and (	s_str_pt_table_prev.idfsLevelParentSection = s_str.idfsSection
										or	(	s_str_pt_table_prev.idfsSection = s_str.idfsSection
												and s_str_pt_table_prev.intParentLevel = 0
											)
									)
								and IsNull(s_str_pt_table_prev.blnGrid, 0) = 1
					inner join	@SectionTable st_pt_table_prev
					on			st_pt_table_prev.idfsSection = pt_table_prev.idfsSection
								and st_pt_table_prev.idfsFormTemplate = pt_table_prev.idfsFormTemplate
								and st_pt_table_prev.idfCustomizationPackage = pt_table_prev.idfCustomizationPackage
								and st_pt_table_prev.SectionOrder < pt.ParameterOrder
					where		pt_table_prev.idfsFormTemplate = pt.idfsFormTemplate
								and pt_table_prev.idfCustomizationPackage = pt.idfCustomizationPackage
								and pt_table_prev.ParameterOrder < pt.ParameterOrder
								and pt_table_prev.idfsParameter not in
									(	226890000000, -- Human Aggregate Case: Diagnosis
										229630000000, -- Human Aggregate Case: ICD-10 Code
										226910000000, -- Vet Aggregate Case: Diagnosis
										234410000000, -- Vet Aggregate Case: OIE Code
										239010000000, -- Vet Aggregate Case: Species
										233150000000, -- Veterinary-sanitary measures: Measure Code
										233190000000, -- Veterinary-sanitary measures: Measure Type
										226930000000, -- Diagnostic investigations: Diagnosis
										231670000000, -- Diagnostic investigations: Investigation type
										234430000000, -- Diagnostic investigations: OIE Code
										239030000000, -- Diagnostic investigations: Species
										226950000000, -- Treatment-prophylactics and vaccination measures: Diagnosis
										233170000000, -- Treatment-prophylactics and vaccination measures: Measure Code
										245270000000, -- Treatment-prophylactics and vaccination measures: Measure Type
										234450000000, -- Treatment-prophylactics and vaccination measures: OIE Code
										239050000000  -- Treatment-prophylactics and vaccination measures: Species
									)
				) +
				-- The product of the number of system parameters,
				--						which belong to the same table section
				--						and have the serial numbers in the template less than 
				--									the serial number of the parameter in the same template,
				-- and the width of system table parameter specified for selected form type
				(	select		count(*) * ftdo.intSystemTableParameterWidth
					from		@ParameterTable pt_table_prev
					inner join	@SectionStructure s_str_pt_table_prev
					on			s_str_pt_table_prev.idfsSection = pt_table_prev.idfsSection
								and (	s_str_pt_table_prev.idfsLevelParentSection = s_str.idfsSection
										or	(	s_str_pt_table_prev.idfsSection = s_str.idfsSection
												and s_str_pt_table_prev.intParentLevel = 0
											)
									)
								and IsNull(s_str_pt_table_prev.blnGrid, 0) = 1
					inner join	@SectionTable st_pt_table_prev
					on			st_pt_table_prev.idfsSection = pt_table_prev.idfsSection
								and st_pt_table_prev.idfsFormTemplate = pt_table_prev.idfsFormTemplate
								and st_pt_table_prev.idfCustomizationPackage = pt_table_prev.idfCustomizationPackage
								and st_pt_table_prev.SectionOrder < pt.ParameterOrder
					where		pt_table_prev.idfsFormTemplate = pt.idfsFormTemplate
								and pt_table_prev.idfCustomizationPackage = pt.idfCustomizationPackage
								and pt_table_prev.ParameterOrder < pt.ParameterOrder
								and pt_table_prev.idfsParameter in
									(	226890000000, -- Human Aggregate Case: Diagnosis
										229630000000, -- Human Aggregate Case: ICD-10 Code
										226910000000, -- Vet Aggregate Case: Diagnosis
										234410000000, -- Vet Aggregate Case: OIE Code
										239010000000, -- Vet Aggregate Case: Species
										233150000000, -- Veterinary-sanitary measures: Measure Code
										233190000000, -- Veterinary-sanitary measures: Measure Type
										226930000000, -- Diagnostic investigations: Diagnosis
										231670000000, -- Diagnostic investigations: Investigation type
										234430000000, -- Diagnostic investigations: OIE Code
										239030000000, -- Diagnostic investigations: Species
										226950000000, -- Treatment-prophylactics and vaccination measures: Diagnosis
										233170000000, -- Treatment-prophylactics and vaccination measures: Measure Code
										245270000000, -- Treatment-prophylactics and vaccination measures: Measure Type
										234450000000, -- Treatment-prophylactics and vaccination measures: OIE Code
										239050000000  -- Treatment-prophylactics and vaccination measures: Species
									)
				),
			
			pldo_p.intTop = 0,

			pldo_p.intWidth = ftdo.intTableParameterWidth,

			pldo_p.intLabelSize = ftdo.intTableParameterWidth,

			pldo_p.intScheme = 0

from		@ParameterLabelDesignOption pldo_p
inner join	@ParameterTable pt
on			pt.idfsParameter = pldo_p.idfsParameterOrDecorElement
			and	pt.idfsFormTemplate = pldo_p.idfsFormTemplate
			and pt.ParameterType_EN <> N'Label'
inner join	@FFFormTypeDesignOption ftdo
on			ftdo.idfsFormType = pt.idfsFormType
inner join	@SectionStructure s_str
on			s_str.idfsSection = pt.idfsSection
			and s_str.intParentLevel = 0
inner join	@SectionStructure s_str_maxlevel
on			s_str_maxlevel.idfsSection = s_str.idfsSection
			and s_str_maxlevel.idfsLevelParentSection is null
inner join	@SectionStructure s_str_maxtablelevel
on			s_str_maxtablelevel.idfsSection = s_str.idfsSection
			and IsNull(s_str_maxtablelevel.blnGrid, 0) = 1
left join	@SectionStructure s_str_tablelevel
on			s_str_tablelevel.idfsSection = s_str.idfsSection
			and IsNull(s_str_tablelevel.blnGrid, 0) = 1
			and s_str_tablelevel.intParentLevel > s_str_maxtablelevel.intParentLevel
where		IsNull(s_str.blnGrid, 0) = 1
			and s_str_tablelevel.idfsSection is null


-- Design options of flat sections
update		sdo
set			
			sdo.intHeight = 
				-- Height of header and footer of flat section
				@intFlatSectionHeaderFooterHeight +
				-- The product of the number of flat sections,
				--						which belong to the selected section,
				-- and the sum of vertical shift and height of header and footer of flat section
				(	select		count(*) * (@intVerticalShift + @intFlatSectionHeaderFooterHeight)
					from		@SectionStructure s_str_child
					inner join	@SectionTable st_s_str_child
					on			st_s_str_child.idfsSection = s_str_child.idfsSection
								and st_s_str_child.idfsFormTemplate = st.idfsFormTemplate
								and st_s_str_child.idfCustomizationPackage = st.idfCustomizationPackage
								and st_s_str_child.SectionOrder > st.SectionOrder
					where		IsNull(s_str_child.blnGrid, 0) = 0
								and s_str_child.idfsLevelParentSection = st.idfsSection
				) +
				-- Product of the number of flat parameters, 
				--					which belong to the sections that meet criteria described above,
				--					and have the serial numbers in the template greater than 
				--						the serial number of the selected section in the same template,
				-- and the sum of vertical shift and flat parameter height specified for selected form type
				(	select		count(*) * (@intVerticalShift + ftdo.intParameterHeight)
					from		@ParameterTable pt_child
					inner join	@SectionStructure s_str_child_pt_child
					on			IsNull(s_str_child_pt_child.blnGrid, 0) = 0
								and	(	s_str_child_pt_child.idfsLevelParentSection = st.idfsSection
										or	(	s_str_child_pt_child.idfsSection = st.idfsSection
												and s_str_child_pt_child.intParentLevel = 0
											)
									)
								and s_str_child_pt_child.idfsSection = pt_child.idfsSection 
					inner join	@SectionTable st_s_str_child_pt_child
					on			st_s_str_child_pt_child.idfsSection = s_str_child_pt_child.idfsSection
								and st_s_str_child_pt_child.idfsFormTemplate = st.idfsFormTemplate
								and st_s_str_child_pt_child.idfCustomizationPackage = st.idfCustomizationPackage
								and st_s_str_child_pt_child.SectionOrder >= st.SectionOrder
					where		pt_child.idfsFormTemplate = st.idfsFormTemplate
								and pt_child.idfCustomizationPackage = st.idfCustomizationPackage
								and pt_child.ParameterType_EN <> N'Label'
								and pt_child.ParameterOrder > st.SectionOrder
				) +
				-- Product of the number of labels, 
				--					which belong to the sections that meet criteria described above,
				--					and have the serial numbers in the template greater than 
				--						the serial number of the selected section in the same template,
				-- and the sum of vertical shift and label height specified for selected form type
				(	select		count(*) * (@intVerticalShift + ftdo.intLabelHeight)
					from		@ParameterTable l_child
					inner join	@SectionStructure s_str_child_l_child
					on			IsNull(s_str_child_l_child.blnGrid, 0) = 0
								and	(	s_str_child_l_child.idfsLevelParentSection = st.idfsSection
										or	(	s_str_child_l_child.idfsSection = st.idfsSection
												and s_str_child_l_child.intParentLevel = 0
											)
									)
								and s_str_child_l_child.idfsSection = l_child.idfsSection 
					inner join	@SectionTable st_s_str_child_l_child
					on			st_s_str_child_l_child.idfsSection = s_str_child_l_child.idfsSection
								and st_s_str_child_l_child.idfsFormTemplate = st.idfsFormTemplate
								and st_s_str_child_l_child.idfCustomizationPackage = st.idfCustomizationPackage
								and st_s_str_child_l_child.SectionOrder >= st.SectionOrder
					where		l_child.idfsFormTemplate = st.idfsFormTemplate
								and l_child.idfCustomizationPackage = st.idfCustomizationPackage
								and l_child.ParameterType_EN = N'Label'
								and l_child.ParameterOrder > st.SectionOrder
				) +
				-- Product of the number of root table sections, 
				--					which belong to the sections that meet criteria described above,
				--					and have the serial numbers in the template greater than 
				--						the serial number of the selected section in the same template,
				-- and the sum of vertical shift and table section height specified for selected form type
				(	select		count(*) * (@intVerticalShift + ftdo.intTableSectionHeight)
					from		@SectionTable st_table_child
					inner join	@SectionStructure s_str_child_st_table_child
					on			IsNull(s_str_child_st_table_child.blnGrid, 0) = 0
								and	(	s_str_child_st_table_child.idfsLevelParentSection = st.idfsSection
										or	(	s_str_child_st_table_child.idfsSection = st.idfsSection
												and s_str_child_st_table_child.intParentLevel = 0
											)
									)
								and s_str_child_st_table_child.idfsSection = st_table_child.idfsParentSection 
					inner join	@SectionTable st_s_str_child_st_table_child
					on			st_s_str_child_st_table_child.idfsSection = s_str_child_st_table_child.idfsSection
								and st_s_str_child_st_table_child.idfsFormTemplate = st.idfsFormTemplate
								and st_s_str_child_st_table_child.idfCustomizationPackage = st.idfCustomizationPackage
								and st_s_str_child_st_table_child.SectionOrder >= st.SectionOrder
					inner join	@SectionStructure st_table_child_1
					on			st_table_child_1.idfsSection = st_table_child.idfsSection
								and st_table_child_1.intParentLevel = 1
					where		st_table_child.idfsFormTemplate = st.idfsFormTemplate
								and st_table_child.idfCustomizationPackage = st.idfCustomizationPackage
								and IsNull(st_table_child.blnGrid, 0) = 1
								and IsNull(st_table_child_1.blnGrid, 0) = 0
								and st_table_child.SectionOrder > st.SectionOrder
				),
			
			sdo.intLeft = @intHorizontalShift * (1 - ftdo.blnHideRootTableSectionHeader),
			
			sdo.intTop = 
				-- Vertical Shift
				@intVerticalShift +
				-- Product of the number of flat sections, 
				--					which belong to the same parent section as the selected section
				--					or do not belong to any parent section as the selected section,
				--					are not parent sections for the section, to which the selected section belongs,
				--					and have the serial numbers in the template less than 
				--						the serial number of the selected section in the same template,
				-- and the sum of vertical shift and height of header and footer of flat section
				(	select		count(*) * (@intVerticalShift + @intFlatSectionHeaderFooterHeight)
					from		@SectionTable st_prev
					left join	@SectionStructure s_str_st_prev
						inner join	@SectionTable st_s_str_st_prev
						on			st_s_str_st_prev.idfsSection = s_str_st_prev.idfsSection
					on			st_s_str_st_prev.idfsSection = st_prev.idfsParentSection
								and st_s_str_st_prev.idfsFormTemplate = st_prev.idfsFormTemplate
								and st_s_str_st_prev.idfCustomizationPackage = st_prev.idfCustomizationPackage
					where		st_prev.idfsFormTemplate = st.idfsFormTemplate
								and st_prev.idfCustomizationPackage = st.idfCustomizationPackage
								and	IsNull(st_prev.blnGrid, 0) = 0
								and st_prev.SectionOrder < st.SectionOrder
								and	IsNull(st_s_str_st_prev.blnGrid, 0) = 0
								and IsNull(st_s_str_st_prev.SectionOrder, -1) <= st.SectionOrder
								and (	IsNull(s_str_st_prev.idfsLevelParentSection, -1) = IsNull(s_str.idfsSection, -1)
										or	(	IsNull(s_str_st_prev.idfsSection, -1) = IsNull(s_str.idfsSection, -1)
												and IsNull(s_str_st_prev.intParentLevel, 0) = 0
											)
									)
				) +
				-- Product of the number of flat parameters, 
				--					which belong to the sections that meet criteria described above,
				--					or do not belong to any section as the selected section,
				--					and have the serial numbers in the template less than 
				--						the serial number of the selected section in the same template,
				-- and the sum of vertical shift and flat parameter height specified for selected form type
				(	select		count(*) * (@intVerticalShift + ftdo.intParameterHeight)
					from		@ParameterTable pt_prev
					left join	@SectionStructure s_str_prev_pt_prev
						inner join	@SectionTable st_pt_prev
						on			st_pt_prev.idfsSection = s_str_prev_pt_prev.idfsSection
					on			s_str_prev_pt_prev.idfsSection = pt_prev.idfsSection
								and st_pt_prev.idfsFormTemplate = pt_prev.idfsFormTemplate
								and st_pt_prev.idfCustomizationPackage = pt_prev.idfCustomizationPackage
					where		pt_prev.idfsFormTemplate = st.idfsFormTemplate
								and pt_prev.idfCustomizationPackage = st.idfCustomizationPackage
								and pt_prev.ParameterType_EN <> N'Label'
								and pt_prev.ParameterOrder < st.SectionOrder
								and IsNull(st_pt_prev.blnGrid, 0) = 0
								and IsNull(st_pt_prev.SectionOrder, -1) <= st.SectionOrder
								and (	IsNull(s_str_prev_pt_prev.idfsLevelParentSection, -1) = IsNull(s_str.idfsSection, -1)
										or	(	IsNull(s_str_prev_pt_prev.idfsSection, -1) = IsNull(s_str.idfsSection, -1)
												and IsNull(s_str_prev_pt_prev.intParentLevel, 0) = 0
											)
									)
				) +
				-- Product of the number of labels, 
				--					which belong to the sections that meet criteria described above,
				--					or do not belong to any section as the selected section,
				--					and have the serial numbers in the template less than 
				--						the serial number of the selected section in the same template,
				-- and the sum of vertical shift and label height specified for selected form type
				(	select		count(*) * (@intVerticalShift + ftdo.intLabelHeight)
					from		@ParameterTable l_prev
					left join	@SectionStructure s_str_prev_l_prev
						inner join	@SectionTable st_l_prev
						on			st_l_prev.idfsSection = s_str_prev_l_prev.idfsSection
					on			s_str_prev_l_prev.idfsSection = l_prev.idfsSection
								and st_l_prev.idfsFormTemplate = l_prev.idfsFormTemplate
								and st_l_prev.idfCustomizationPackage = l_prev.idfCustomizationPackage
					where		l_prev.idfsFormTemplate = st.idfsFormTemplate
								and l_prev.idfCustomizationPackage = st.idfCustomizationPackage
								and l_prev.ParameterType_EN = N'Label'
								and l_prev.ParameterOrder < st.SectionOrder
								and IsNull(st_l_prev.blnGrid, 0) = 0
								and IsNull(st_l_prev.SectionOrder, -1) <= st.SectionOrder
								and (	IsNull(s_str_prev_l_prev.idfsLevelParentSection, -1) = IsNull(s_str.idfsSection, -1)
										or	(	IsNull(s_str_prev_l_prev.idfsSection, -1) = IsNull(s_str.idfsSection, -1)
												and IsNull(s_str_prev_l_prev.intParentLevel, 0) = 0
											)
									)
				) +
				-- Product of the number of root table sections, 
				--					which belong to the sections that meet criteria described above,
				--					or do not belong to any section as the selected section,
				--					and have the serial numbers in the template less than 
				--						the serial number of the selected section in the same template,
				-- and the sum of vertical shift and table section height specified for selected form type
				(	select		count(*) * (@intVerticalShift + ftdo.intTableSectionHeight)
					from		@SectionTable st_table_prev
					left join	@SectionStructure s_str_prev_st_table_prev
						inner join	@SectionTable st_st_table_prev
						on			st_st_table_prev.idfsSection = s_str_prev_st_table_prev.idfsSection
					on			s_str_prev_st_table_prev.idfsSection = st_table_prev.idfsParentSection
								and st_st_table_prev.idfsFormTemplate = st_table_prev.idfsFormTemplate
								and st_st_table_prev.idfCustomizationPackage = st_table_prev.idfCustomizationPackage
					left join	@SectionStructure st_table_prev_1
					on			st_table_prev_1.idfsSection = st_table_prev.idfsSection
								and st_table_prev_1.intParentLevel = 1
					where		st_table_prev.idfsFormTemplate = st.idfsFormTemplate
								and st_table_prev.idfCustomizationPackage = st.idfCustomizationPackage
								and IsNull(st_table_prev.blnGrid, 0) = 1
								and IsNull(st_table_prev_1.blnGrid, 0) = 0
								and st_table_prev.SectionOrder < st.SectionOrder
								and IsNull(st_st_table_prev.blnGrid, 0) = 0
								and IsNull(st_st_table_prev.SectionOrder, -1) <= st.SectionOrder
								and (	IsNull(s_str_prev_st_table_prev.idfsLevelParentSection, -1) = IsNull(s_str.idfsSection, -1)
										or	(	IsNull(s_str_prev_st_table_prev.idfsSection, -1) = IsNull(s_str.idfsSection, -1)
												and IsNull(s_str_prev_st_table_prev.intParentLevel, 0) = 0
											)
									)
				),

			sdo.intWidth = 
				-- Template width specified for form type minus
				ftdo.intTemplateWidth - 
				-- Two horizontal shifts
				@intHorizontalShift * 2 -
				-- The product of two sum of horizontal shift and flat section border size
				-- and the number of flat sections, to which the selected section belongs
				(@intFlatSectionBorderSize + @intHorizontalShift) * 2 * (IsNull(s_str_maxlevel.intParentLevel + 1, 0)),

			sdo.intCaptionHeight = @intFlatSectionHeaderHeight

from		@SectionDesignOption sdo
inner join	@SectionTable st
on			st.idfsSection = sdo.idfsSection
			and	st.idfsFormTemplate = sdo.idfsFormTemplate
inner join	@FFFormTypeDesignOption ftdo
on			ftdo.idfsFormType = st.idfsFormType
left join	@SectionStructure s_str
	inner join	@SectionStructure s_str_maxlevel
	on			s_str_maxlevel.idfsSection = s_str.idfsSection
				and s_str_maxlevel.idfsLevelParentSection is null
on			s_str.idfsSection = st.idfsParentSection
			and s_str.intParentLevel = 0
where		IsNull(st.blnGrid, 0) = 0


-- Design options of root table sections
update		sdo
set			
			sdo.intHeight = ftdo.intTableSectionHeight,			
			sdo.intLeft = @intHorizontalShift * (1 - ftdo.blnHideRootTableSectionHeader),
			
			sdo.intTop = 
				-- Vertical Shift
				@intVerticalShift +
				-- Product of the number of flat sections, 
				--					which belong to the same parent section as the selected section
				--					or do not belong to any parent section as the selected section,
				--					are not parent sections for the section, to which the selected section belongs,
				--					and have the serial numbers in the template less than 
				--						the serial number of the selected section in the same template,
				-- and the sum of vertical shift and height of header and footer of flat section
				(	select		count(*) * (@intVerticalShift + @intFlatSectionHeaderFooterHeight)
					from		@SectionTable st_prev
					left join	@SectionStructure s_str_st_prev
						inner join	@SectionTable st_s_str_st_prev
						on			st_s_str_st_prev.idfsSection = s_str_st_prev.idfsSection
					on			st_s_str_st_prev.idfsSection = st_prev.idfsParentSection
								and st_s_str_st_prev.idfsFormTemplate = st_prev.idfsFormTemplate
								and st_s_str_st_prev.idfCustomizationPackage = st_prev.idfCustomizationPackage
					where		st_prev.idfsFormTemplate = st.idfsFormTemplate
								and st_prev.idfCustomizationPackage = st.idfCustomizationPackage
								and	IsNull(st_prev.blnGrid, 0) = 0
								and st_prev.SectionOrder < st.SectionOrder
								and	IsNull(st_s_str_st_prev.blnGrid, 0) = 0
								and IsNull(st_s_str_st_prev.SectionOrder, -1) <= st.SectionOrder
								and (	IsNull(s_str_st_prev.idfsLevelParentSection, -1) = IsNull(s_str.idfsSection, -1)
										or	(	IsNull(s_str_st_prev.idfsSection, -1) = IsNull(s_str.idfsSection, -1)
												and IsNull(s_str_st_prev.intParentLevel, 0) = 0
											)
									)
				) +
				-- Product of the number of flat parameters, 
				--					which belong to the sections that meet criteria described above,
				--					or do not belong to any section as the selected section,
				--					and have the serial numbers in the template less than 
				--						the serial number of the selected section in the same template,
				-- and the sum of vertical shift and flat parameter height specified for selected form type
				(	select		count(*) * (@intVerticalShift + ftdo.intParameterHeight)
					from		@ParameterTable pt_prev
					left join	@SectionStructure s_str_prev_pt_prev
						inner join	@SectionTable st_pt_prev
						on			st_pt_prev.idfsSection = s_str_prev_pt_prev.idfsSection
					on			s_str_prev_pt_prev.idfsSection = pt_prev.idfsSection
								and st_pt_prev.idfsFormTemplate = pt_prev.idfsFormTemplate
								and st_pt_prev.idfCustomizationPackage = pt_prev.idfCustomizationPackage
					where		pt_prev.idfsFormTemplate = st.idfsFormTemplate
								and pt_prev.idfCustomizationPackage = st.idfCustomizationPackage
								and pt_prev.ParameterType_EN <> N'Label'
								and pt_prev.ParameterOrder < st.SectionOrder
								and IsNull(st_pt_prev.blnGrid, 0) = 0
								and IsNull(st_pt_prev.SectionOrder, -1) <= st.SectionOrder
								and (	IsNull(s_str_prev_pt_prev.idfsLevelParentSection, -1) = IsNull(s_str.idfsSection, -1)
										or	(	IsNull(s_str_prev_pt_prev.idfsSection, -1) = IsNull(s_str.idfsSection, -1)
												and IsNull(s_str_prev_pt_prev.intParentLevel, 0) = 0
											)
									)
				) +
				-- Product of the number of labels, 
				--					which belong to the sections that meet criteria described above,
				--					or do not belong to any section as the selected section,
				--					and have the serial numbers in the template less than 
				--						the serial number of the selected section in the same template,
				-- and the sum of vertical shift and label height specified for selected form type
				(	select		count(*) * (@intVerticalShift + ftdo.intLabelHeight)
					from		@ParameterTable l_prev
					left join	@SectionStructure s_str_prev_l_prev
						inner join	@SectionTable st_l_prev
						on			st_l_prev.idfsSection = s_str_prev_l_prev.idfsSection
					on			s_str_prev_l_prev.idfsSection = l_prev.idfsSection
								and st_l_prev.idfsFormTemplate = l_prev.idfsFormTemplate
								and st_l_prev.idfCustomizationPackage = l_prev.idfCustomizationPackage
					where		l_prev.idfsFormTemplate = st.idfsFormTemplate
								and l_prev.idfCustomizationPackage = st.idfCustomizationPackage
								and l_prev.ParameterType_EN = N'Label'
								and l_prev.ParameterOrder < st.SectionOrder
								and IsNull(st_l_prev.blnGrid, 0) = 0
								and IsNull(st_l_prev.SectionOrder, -1) <= st.SectionOrder
								and (	IsNull(s_str_prev_l_prev.idfsLevelParentSection, -1) = IsNull(s_str.idfsSection, -1)
										or	(	IsNull(s_str_prev_l_prev.idfsSection, -1) = IsNull(s_str.idfsSection, -1)
												and IsNull(s_str_prev_l_prev.intParentLevel, 0) = 0
											)
									)
				) +
				-- Product of the number of root table sections, 
				--					which belong to the sections that meet criteria described above,
				--					or do not belong to any section as the selected section,
				--					and have the serial numbers in the template less than 
				--						the serial number of the selected section in the same template,
				-- and the sum of vertical shift and table section height specified for selected form type
				(	select		count(*) * (@intVerticalShift + ftdo.intTableSectionHeight)
					from		@SectionTable st_table_prev
					left join	@SectionStructure s_str_prev_st_table_prev
						inner join	@SectionTable st_st_table_prev
						on			st_st_table_prev.idfsSection = s_str_prev_st_table_prev.idfsSection
					on			s_str_prev_st_table_prev.idfsSection = st_table_prev.idfsParentSection
								and st_st_table_prev.idfsFormTemplate = st_table_prev.idfsFormTemplate
								and st_st_table_prev.idfCustomizationPackage = st_table_prev.idfCustomizationPackage
					left join	@SectionStructure st_table_prev_1
					on			st_table_prev_1.idfsSection = st_table_prev.idfsSection
								and st_table_prev_1.intParentLevel = 1
					where		st_table_prev.idfsFormTemplate = st.idfsFormTemplate
								and st_table_prev.idfCustomizationPackage = st.idfCustomizationPackage
								and IsNull(st_table_prev.blnGrid, 0) = 1
								and IsNull(st_table_prev_1.blnGrid, 0) = 0
								and st_table_prev.SectionOrder < st.SectionOrder
								and IsNull(st_st_table_prev.blnGrid, 0) = 0
								and IsNull(st_st_table_prev.SectionOrder, -1) <= st.SectionOrder
								and (	IsNull(s_str_prev_st_table_prev.idfsLevelParentSection, -1) = IsNull(s_str.idfsSection, -1)
										or	(	IsNull(s_str_prev_st_table_prev.idfsSection, -1) = IsNull(s_str.idfsSection, -1)
												and IsNull(s_str_prev_st_table_prev.intParentLevel, 0) = 0
											)
									)
				),

			sdo.intWidth = 
				-- Template width specified for form type minus
				ftdo.intTemplateWidth - 
				-- Two horizontal shifts if root table section shall be hidden for selected form type
				@intHorizontalShift * 2 * (1 - ftdo.blnHideRootTableSectionHeader) -
				-- The product of two horizontal shift and the number of flat sections, to which the root table section belongs
				@intHorizontalShift * 2 * (IsNull(s_str_maxlevel.intParentLevel + 1, 0)),

			sdo.intCaptionHeight = @intFlatSectionHeaderHeight

from		@SectionDesignOption sdo
inner join	@SectionTable st
on			st.idfsSection = sdo.idfsSection
			and	st.idfsFormTemplate = sdo.idfsFormTemplate
inner join	@FFFormTypeDesignOption ftdo
on			ftdo.idfsFormType = st.idfsFormType

inner join	@SectionStructure s_str_table_root
on			s_str_table_root.idfsSection = st.idfsSection
			and s_str_table_root.intParentLevel = 0
			and IsNull(s_str_table_root.blnGrid, 0) = 1
left join	@SectionStructure s_str_table_root_parent
on			s_str_table_root_parent.idfsSection = st.idfsSection
			and IsNull(s_str_table_root_parent.blnGrid, 0) = 1
			and s_str_table_root_parent.intParentLevel = 1

left join	@SectionStructure s_str
	inner join	@SectionStructure s_str_maxlevel
	on			s_str_maxlevel.idfsSection = s_str.idfsSection
				and s_str_maxlevel.idfsLevelParentSection is null
on			s_str.idfsSection = st.idfsParentSection
			and s_str.intParentLevel = 0

where		IsNull(st.blnGrid, 0) = 1
			and s_str_table_root_parent.idfsSection is null


-- Design options of table sub-sections (not root)
update		sdo
set			
			sdo.intHeight = 
				-- Table section height specified for form type minus
				ftdo.intTableSectionHeight -
				-- Height of root table section and buttons Copy/Remove 
				-- if root table section header and buttons shall not be hidden for selected form type
				(1 - ftdo.blnHideRootTableSectionHeader) * @intRootTableSectionHeaderHeight -
				-- The product of the number of parent table sub-sections (that do not coincide with not root table section)
				-- and height of the header of table sub-sections (not root)
				s_str_maxtablelevel.intParentLevel * @intTableSubSectionHeaderHeight,
			
			sdo.intLeft = 
				-- The product of the number of not system parameters,
				--						which belong to the same table section
				--						and have the serial numbers in the template less than 
				--									the serial number of the selected section in the same template,
				-- and the width of table parameter specified for selected form type
				(	select		count(*) * ftdo.intTableParameterWidth
					from		@ParameterTable pt_table_prev
					inner join	@SectionStructure s_str_pt_table_prev
					on			s_str_pt_table_prev.idfsSection = pt_table_prev.idfsSection
								and (	s_str_pt_table_prev.idfsLevelParentSection = s_str.idfsSection
										or	(	s_str_pt_table_prev.idfsSection = s_str.idfsSection
												and s_str_pt_table_prev.intParentLevel = 0
											)
									)
								and IsNull(s_str_pt_table_prev.blnGrid, 0) = 1
					inner join	@SectionTable st_pt_table_prev
					on			st_pt_table_prev.idfsSection = pt_table_prev.idfsSection
								and st_pt_table_prev.idfsFormTemplate = pt_table_prev.idfsFormTemplate
								and st_pt_table_prev.idfCustomizationPackage = pt_table_prev.idfCustomizationPackage
								and st_pt_table_prev.SectionOrder <= st.SectionOrder
					where		pt_table_prev.idfsFormTemplate = st.idfsFormTemplate
								and pt_table_prev.idfCustomizationPackage = st.idfCustomizationPackage
								and pt_table_prev.ParameterOrder < st.SectionOrder
								and pt_table_prev.idfsParameter not in
									(	226890000000, -- Human Aggregate Case: Diagnosis
										229630000000, -- Human Aggregate Case: ICD-10 Code
										226910000000, -- Vet Aggregate Case: Diagnosis
										234410000000, -- Vet Aggregate Case: OIE Code
										239010000000, -- Vet Aggregate Case: Species
										233150000000, -- Veterinary-sanitary measures: Measure Code
										233190000000, -- Veterinary-sanitary measures: Measure Type
										226930000000, -- Diagnostic investigations: Diagnosis
										231670000000, -- Diagnostic investigations: Investigation type
										234430000000, -- Diagnostic investigations: OIE Code
										239030000000, -- Diagnostic investigations: Species
										226950000000, -- Treatment-prophylactics and vaccination measures: Diagnosis
										233170000000, -- Treatment-prophylactics and vaccination measures: Measure Code
										245270000000, -- Treatment-prophylactics and vaccination measures: Measure Type
										234450000000, -- Treatment-prophylactics and vaccination measures: OIE Code
										239050000000  -- Treatment-prophylactics and vaccination measures: Species
									)
				) +
				-- The product of the number of system parameters,
				--						which belong to the same table section
				--						and have the serial numbers in the template less than 
				--									the serial number of the selected section in the same template,
				-- and the width of system table parameter specified for selected form type
				(	select		count(*) * ftdo.intSystemTableParameterWidth
					from		@ParameterTable pt_table_prev
					inner join	@SectionStructure s_str_pt_table_prev
					on			s_str_pt_table_prev.idfsSection = pt_table_prev.idfsSection
								and (	s_str_pt_table_prev.idfsLevelParentSection = s_str.idfsSection
										or	(	s_str_pt_table_prev.idfsSection = s_str.idfsSection
												and s_str_pt_table_prev.intParentLevel = 0
											)
									)
								and IsNull(s_str_pt_table_prev.blnGrid, 0) = 1
					inner join	@SectionTable st_pt_table_prev
					on			st_pt_table_prev.idfsSection = pt_table_prev.idfsSection
								and st_pt_table_prev.idfsFormTemplate = pt_table_prev.idfsFormTemplate
								and st_pt_table_prev.idfCustomizationPackage = pt_table_prev.idfCustomizationPackage
								and st_pt_table_prev.SectionOrder <= st.SectionOrder
					where		pt_table_prev.idfsFormTemplate = st.idfsFormTemplate
								and pt_table_prev.idfCustomizationPackage = st.idfCustomizationPackage
								and pt_table_prev.ParameterOrder < st.SectionOrder
								and pt_table_prev.idfsParameter in
									(	226890000000, -- Human Aggregate Case: Diagnosis
										229630000000, -- Human Aggregate Case: ICD-10 Code
										226910000000, -- Vet Aggregate Case: Diagnosis
										234410000000, -- Vet Aggregate Case: OIE Code
										239010000000, -- Vet Aggregate Case: Species
										233150000000, -- Veterinary-sanitary measures: Measure Code
										233190000000, -- Veterinary-sanitary measures: Measure Type
										226930000000, -- Diagnostic investigations: Diagnosis
										231670000000, -- Diagnostic investigations: Investigation type
										234430000000, -- Diagnostic investigations: OIE Code
										239030000000, -- Diagnostic investigations: Species
										226950000000, -- Treatment-prophylactics and vaccination measures: Diagnosis
										233170000000, -- Treatment-prophylactics and vaccination measures: Measure Code
										245270000000, -- Treatment-prophylactics and vaccination measures: Measure Type
										234450000000, -- Treatment-prophylactics and vaccination measures: OIE Code
										239050000000  -- Treatment-prophylactics and vaccination measures: Species
									)
				),
			
			sdo.intTop = 0,

			sdo.intWidth = 
				-- The product of the number of not system parameters,
				--						which belong to the selected section
				--						and have the serial numbers in the template greater than 
				--									the serial number of the selected section in the same template,
				-- and the width of table parameter specified for selected form type
				(	select		count(*) * ftdo.intTableParameterWidth
					from		@ParameterTable pt_table_child
					inner join	@SectionStructure s_str_pt_table_child
					on			s_str_pt_table_child.idfsSection = pt_table_child.idfsSection
								and (	s_str_pt_table_child.idfsLevelParentSection = st.idfsSection
										or	(	s_str_pt_table_child.idfsSection = st.idfsSection
												and s_str_pt_table_child.intParentLevel = 0
											)
									)
								and IsNull(s_str_pt_table_child.blnGrid, 0) = 1
					inner join	@SectionTable st_pt_table_child
					on			st_pt_table_child.idfsSection = pt_table_child.idfsSection
								and st_pt_table_child.idfsFormTemplate = pt_table_child.idfsFormTemplate
								and st_pt_table_child.idfCustomizationPackage = pt_table_child.idfCustomizationPackage
								and st_pt_table_child.SectionOrder >= st.SectionOrder
					where		pt_table_child.idfsFormTemplate = st.idfsFormTemplate
								and pt_table_child.idfCustomizationPackage = st.idfCustomizationPackage
								and pt_table_child.ParameterOrder > st.SectionOrder
								and pt_table_child.idfsParameter not in
									(	226890000000, -- Human Aggregate Case: Diagnosis
										229630000000, -- Human Aggregate Case: ICD-10 Code
										226910000000, -- Vet Aggregate Case: Diagnosis
										234410000000, -- Vet Aggregate Case: OIE Code
										239010000000, -- Vet Aggregate Case: Species
										233150000000, -- Veterinary-sanitary measures: Measure Code
										233190000000, -- Veterinary-sanitary measures: Measure Type
										226930000000, -- Diagnostic investigations: Diagnosis
										231670000000, -- Diagnostic investigations: Investigation type
										234430000000, -- Diagnostic investigations: OIE Code
										239030000000, -- Diagnostic investigations: Species
										226950000000, -- Treatment-prophylactics and vaccination measures: Diagnosis
										233170000000, -- Treatment-prophylactics and vaccination measures: Measure Code
										245270000000, -- Treatment-prophylactics and vaccination measures: Measure Type
										234450000000, -- Treatment-prophylactics and vaccination measures: OIE Code
										239050000000  -- Treatment-prophylactics and vaccination measures: Species
									)
				) +
				-- The product of the number of system parameters,
				--						which belong to the selected section
				--						and have the serial numbers in the template greater than 
				--									the serial number of the selected section in the same template,
				-- and the width of system table parameter specified for selected form type
				(	select		count(*) * ftdo.intSystemTableParameterWidth
					from		@ParameterTable pt_table_child
					inner join	@SectionStructure s_str_pt_table_child
					on			s_str_pt_table_child.idfsSection = pt_table_child.idfsSection
								and (	s_str_pt_table_child.idfsLevelParentSection = st.idfsSection
										or	(	s_str_pt_table_child.idfsSection = st.idfsSection
												and s_str_pt_table_child.intParentLevel = 0
											)
									)
								and IsNull(s_str_pt_table_child.blnGrid, 0) = 1
					inner join	@SectionTable st_pt_table_child
					on			st_pt_table_child.idfsSection = pt_table_child.idfsSection
								and st_pt_table_child.idfsFormTemplate = pt_table_child.idfsFormTemplate
								and st_pt_table_child.idfCustomizationPackage = pt_table_child.idfCustomizationPackage
								and st_pt_table_child.SectionOrder >= st.SectionOrder
					where		pt_table_child.idfsFormTemplate = st.idfsFormTemplate
								and pt_table_child.idfCustomizationPackage = st.idfCustomizationPackage
								and pt_table_child.ParameterOrder > st.SectionOrder
								and pt_table_child.idfsParameter in
									(	226890000000, -- Human Aggregate Case: Diagnosis
										229630000000, -- Human Aggregate Case: ICD-10 Code
										226910000000, -- Vet Aggregate Case: Diagnosis
										234410000000, -- Vet Aggregate Case: OIE Code
										239010000000, -- Vet Aggregate Case: Species
										233150000000, -- Veterinary-sanitary measures: Measure Code
										233190000000, -- Veterinary-sanitary measures: Measure Type
										226930000000, -- Diagnostic investigations: Diagnosis
										231670000000, -- Diagnostic investigations: Investigation type
										234430000000, -- Diagnostic investigations: OIE Code
										239030000000, -- Diagnostic investigations: Species
										226950000000, -- Treatment-prophylactics and vaccination measures: Diagnosis
										233170000000, -- Treatment-prophylactics and vaccination measures: Measure Code
										245270000000, -- Treatment-prophylactics and vaccination measures: Measure Type
										234450000000, -- Treatment-prophylactics and vaccination measures: OIE Code
										239050000000  -- Treatment-prophylactics and vaccination measures: Species
									)
				),

			sdo.intCaptionHeight = @intTableSubSectionHeaderHeight

from		@SectionDesignOption sdo
inner join	@SectionTable st
on			st.idfsSection = sdo.idfsSection
			and	st.idfsFormTemplate = sdo.idfsFormTemplate
inner join	@FFFormTypeDesignOption ftdo
on			ftdo.idfsFormType = st.idfsFormType
inner join	@SectionStructure s_str
on			s_str.idfsSection = st.idfsParentSection
			and s_str.intParentLevel = 0
inner join	@SectionStructure s_str_maxlevel
on			s_str_maxlevel.idfsSection = s_str.idfsSection
			and s_str_maxlevel.idfsLevelParentSection is null
inner join	@SectionStructure s_str_maxtablelevel
on			s_str_maxtablelevel.idfsSection = s_str.idfsSection
			and IsNull(s_str_maxtablelevel.blnGrid, 0) = 1
left join	@SectionStructure s_str_tablelevel
on			s_str_tablelevel.idfsSection = s_str.idfsSection
			and IsNull(s_str_tablelevel.blnGrid, 0) = 1
			and s_str_tablelevel.intParentLevel > s_str_maxtablelevel.intParentLevel
where		IsNull(s_str.blnGrid, 0) = 1
			and s_str_tablelevel.idfsSection is null



------ Check scripts
----select		--r_ft.[Name] as FormType,
----			r_t.[Name] as Template, 
----			IsNull(st_max.strLevelSectionPathEN, N'--') as SectionPath_EN,
----			IsNull(st_min.strLevelSectionPathEN, N'--') as SectionName_EN,
----			r_pc.[Name] as ParName,
----			r_pt.[Name] as ParType,
----			r_p.[Name] as ParLongName,
----			pft.intTop as NewParameterTop,
----			pdo.intTop as OldParameterTop,
----			pft.intHeight as NewParameterHeight,
----			pdo.intHeight as OldParameterHeight,
----			pft.intLeft as NewParameterLeft,
----			pdo.intLeft as OldParameterLeft,
----			pft.intWidth as NewParameterWidth,
----			pdo.intWidth as OldParameterWidth,
----			pft.intLabelSize as NewParameterLabelSize,
----			pdo.intLabelSize as OldParameterLabelSize,
----			pft.intOrder as ParameterOrderInTemplate, 
----			st_min.idfsSection as SectionID,
----			p.idfsParameter as ParameterID,
----			t.idfsFormTemplate as TemplateID
----from		ffParameter p
----inner join	@ParameterLabelDesignOption pft
----on			pft.idfsParameterOrDecorElement = p.idfsParameter
----inner join	ffFormTemplate t
----on			t.idfsFormTemplate = pft.idfsFormTemplate
----			and t.intRowStatus = 0
----inner join	fnReference('en', 19000033) r_t					-- Flexible Form Template
----on			r_t.idfsReference = t.idfsFormTemplate
----inner join	fnReference('en', 19000066) r_p					-- Flexible Form Parameter
----on			r_p.idfsReference = p.idfsParameter
----inner join	fnReference('en', 19000034) r_ft				-- Flexible Form Type
----on			r_ft.idfsReference = p.idfsFormType
----left join	ffParameterDesignOption pdo
----on			pdo.idfsParameter = p.idfsParameter
----			and pdo.idfsFormTemplate = t.idfsFormTemplate
----			and pdo.idfsLanguage = dbo.fnGetLanguageCode('en')
----			and pdo.intRowStatus = 0
----left join	ffParameterDesignOption pdo_def
----on			pdo_def.idfsParameter = p.idfsParameter
----			and pdo_def.idfsFormTemplate is null
----			and pdo_def.idfsLanguage = dbo.fnGetLanguageCode('en')
----			and pdo_def.intRowStatus = 0
----left join	fnReference('en', 19000070) r_pc				-- Flexible Form Parameter Tooltip
----on			r_pc.idfsReference = p.idfsParameterCaption
----left join	(
----	ffParameterType pt
----	inner join	fnReference('en', 19000071) r_pt			-- Flexible Form Parameter Type
----	on			r_pt.idfsReference = pt.idfsParameterType
----			)
----on			pt.idfsParameterType = p.idfsParameterType
----			and pt.intRowStatus = 0
----left join	@SectionStructure st_min
----on			st_min.idfsSection = p.idfsSection
----			and st_min.intParentLevel = 0
----left join	@SectionStructure st_max
----on			st_max.idfsSection = p.idfsSection
----			and st_max.idfsLevelParentSection is null
----left join	ffSectionDesignOption sdo
----on			sdo.idfsSection = st_min.idfsSection
----			and sdo.idfsFormTemplate = t.idfsFormTemplate
----			and sdo.idfsLanguage = dbo.fnGetLanguageCode('en')
----			and sdo.intRowStatus = 0
----where		p.intRowStatus = 0
----union all
----select		--r_ft.[Name] as FormType,
----			r_t.[Name] as Template, 
----			IsNull(st_max.strLevelSectionPathEN, N'--') as SectionPath_EN,
----			IsNull(st_min.strLevelSectionPathEN, N'--') as SectionName_EN,
----			r_l_en.[Name] as ParName,
----			N'Label' as ParType,
----			r_l_en.[Name] as ParLongName,
----			pft.intTop as NewParameterTop,
----			det.intTop as OldParameterTop,
----			pft.intHeight as NewParameterHeight,
----			det.intHeight as OldParameterHeight,
----			pft.intLeft as NewParameterLeft,
----			det.intLeft as OldParameterLeft,
----			pft.intWidth as NewParameterWidth,
----			det.intWidth as OldParameterWidth,
----			pft.intWidth as NewParameterLabelSize,
----			det.intWidth as OldParameterLabelSize,
----			pft.intOrder as ParameterOrderInTemplate,
----			st_min.idfsSection as SectionID,
----			det.idfDecorElement as ParameterID,
----			t.idfsFormTemplate as TemplateID
----from		ffDecorElementText det
----inner join	ffDecorElement de
----on			de.idfDecorElement = det.idfDecorElement
----			and de.idfsDecorElementType = 10106001	-- Label
----			and de.idfsLanguage = dbo.fnGetLanguageCode('en')
----			and de.intRowStatus = 0
----inner join	@ParameterLabelDesignOption pft
----on			pft.idfsParameterOrDecorElement = de.idfDecorElement
----			and pft.idfsFormTemplate = de.idfsFormTemplate
----inner join	ffFormTemplate t
----on			t.idfsFormTemplate = de.idfsFormTemplate
----			and t.intRowStatus = 0
----inner join	fnReference('en', 19000033) r_t					-- Flexible Form Template
----on			r_t.idfsReference = t.idfsFormTemplate
----inner join	fnReference('en', 19000034) r_ft				-- Flexible Form Type
----on			r_ft.idfsReference = t.idfsFormType
----inner join	fnReference('en', 19000131) r_l_en				-- Flexible Form Label Text
----on			r_l_en.idfsReference = det.idfsBaseReference
----left join	@SectionStructure st_min
----on			st_min.idfsSection = de.idfsSection
----			and st_min.intParentLevel = 0
----left join	@SectionStructure st_max
----on			st_max.idfsSection = de.idfsSection
----			and st_max.idfsLevelParentSection is null
----left join	ffSectionDesignOption sdo
----on			sdo.idfsSection = st_min.idfsSection
----			and sdo.idfsFormTemplate = t.idfsFormTemplate
----			and sdo.idfsLanguage = dbo.fnGetLanguageCode('en')
----			and sdo.intRowStatus = 0
----where		det.intRowStatus = 0
----order by	Template, ParameterOrderInTemplate

----select		--r_ft.[Name] as FormType,
----			r_t.[Name] as Template,
----			IsNull(st_max.strLevelSectionPathEN, N'--') as SectionPath_EN,
----			IsNull(st_min.strLevelSectionPathEN, N'--') as SectionName_EN,
----			tst.intOrder as NewSectionOrder,
----			sdo.intOrder as OldSectionOrder,
----			tst.intTop as NewSectionTop,
----			sdo.intTop as OldSectionTop,
----			tst.intHeight as NewSectionHeight,
----			sdo.intHeight as OldSectionHeight,
----			tst.intLeft as NewSectionLeft,
----			sdo.intLeft as OldSectionLeft,
----			tst.intWidth as NewSectionWidth,
----			sdo.intWidth as OldSectionWidth,
----			tst.intCaptionHeight as NewSectionCaptionHeight,
----			sdo.intCaptionHeight as OldCaptionHeight,
----			tst.idfsFormTemplate as TemplateID,
----			tst.idfsSection as SectionID
----from		@SectionDesignOption tst
----inner join	ffFormTemplate t
----on			t.idfsFormTemplate = tst.idfsFormTemplate
----			and t.intRowStatus = 0
----inner join	fnReference('en', 19000033) r_t					-- Flexible Form Template
----on			r_t.idfsReference = t.idfsFormTemplate
----inner join	fnReference('en', 19000034) r_ft				-- Flexible Form Type
----on			r_ft.idfsReference = t.idfsFormType
----inner join	@SectionStructure st_min
----on			st_min.idfsSection = tst.idfsSection
----			and st_min.intParentLevel = 0
----inner join	@SectionStructure st_max
----on			st_max.idfsSection = tst.idfsSection
----			and st_max.idfsLevelParentSection is null
----left join	ffSectionDesignOption sdo
----on			sdo.idfsFormTemplate = tst.idfsFormTemplate
----			and sdo.idfsSection = tst.idfsSection
----			and sdo.idfsLanguage = dbo.fnGetLanguageCode('en')
----			and sdo.intRowStatus = 0
----order by	Template, tst.intOrder

-- Update actual records
update		pdo
set			pdo.intLeft = tt.intLeft,
			pdo.intTop = tt.intTop,
			pdo.intWidth = tt.intWidth,
			pdo.intHeight = tt.intHeight,
			pdo.intLabelSize = tt.intLabelSize,
			pdo.intOrder = tt.intOrder
from		@ParameterLabelDesignOption tt
inner join	ffParameterForTemplate pft
on			pft.idfsParameter = tt.idfsParameterOrDecorElement
			and pft.idfsFormTemplate = tt.idfsFormTemplate
			and pft.intRowStatus = 0
inner join	ffParameterDesignOption pdo
on			pdo.idfsParameter = pft.idfsParameter
			and pdo.idfsLanguage = dbo.fnGetLanguageCode('en')
			and pdo.idfsFormTemplate = pft.idfsFormTemplate
			and pdo.intRowStatus = 0
where		(	pdo.intLeft <> tt.intLeft
				or pdo.intTop <> tt.intTop
				or pdo.intWidth <> tt.intWidth
				or pdo.intHeight <> tt.intHeight
				or pdo.intLabelSize <> tt.intLabelSize
				or pdo.intOrder <> tt.intOrder
			)
print	'Update parameter sizes and locations in templates (ffParameterDesignOption): ' + cast(@@rowcount as varchar(20))

update		det
set			det.intLeft = tt.intLeft,
			det.intTop = tt.intTop,
			det.intWidth = tt.intWidth,
			det.intHeight = tt.intHeight
from		@ParameterLabelDesignOption tt
inner join	ffDecorElement de
on			de.idfDecorElement = tt.idfsParameterOrDecorElement
			and de.idfsFormTemplate = tt.idfsFormTemplate
			and de.intRowStatus = 0
inner join	ffDecorElementText det
on			det.idfDecorElement = de.idfDecorElement
			and det.intRowStatus = 0
where		(	det.intLeft <> tt.intLeft
				or det.intTop <> tt.intTop
				or IsNull(det.intWidth, -1) <> tt.intWidth
				or IsNull(det.intHeight, -1) <> tt.intHeight
			)
print	'Update label sizes and locations in templates (ffDecorElementText): ' + cast(@@rowcount as varchar(20))

update		sdo
set			sdo.intLeft = tst.intLeft,
			sdo.intTop = tst.intTop,
			sdo.intWidth = tst.intWidth,
			sdo.intHeight = tst.intHeight,
			sdo.intCaptionHeight = tst.intCaptionHeight,
			sdo.intOrder = tst.intOrder
from		@SectionDesignOption tst
inner join	ffSectionDesignOption sdo
on			sdo.idfsSection = tst.idfsSection
			and sdo.idfsLanguage = dbo.fnGetLanguageCode('en')
			and sdo.idfsFormTemplate = tst.idfsFormTemplate
			and sdo.intRowStatus = 0
where		(	IsNull(sdo.intLeft, -1) <> tst.intLeft
				or IsNull(sdo.intTop, -1) <> tst.intTop
				or sdo.intWidth <> tst.intWidth
				or IsNull(sdo.intHeight, -1) <> tst.intHeight
				or sdo.intCaptionHeight <> tst.intCaptionHeight
				or IsNull(sdo.intOrder, -1) <> tst.intOrder
			)
print	'Update section sizes and locations in templates (ffSectionDesignOption): ' + cast(@@rowcount as varchar(20))

update		sft
set			sft.intRowStatus = 0
from		ffSectionForTemplate sft
inner join	@SectionDesignOption tst
on			tst.idfsFormTemplate = sft.idfsFormTemplate
			and tst.idfsSection = sft.idfsSection
where		sft.intRowStatus <> 0
print	'Restore removed connections between section and templates (ffSectionForTemplate): ' + cast(@@rowcount as varchar(20))

update		sft
set			sft.intRowStatus = 1
from		ffSectionForTemplate sft
left join	@SectionDesignOption tst
on			tst.idfsFormTemplate = sft.idfsFormTemplate
			and tst.idfsSection = sft.idfsSection
where		exists	(
				select		*
				from		@ParameterLabelDesignOption tt
				where		tt.idfsFormTemplate = sft.idfsFormTemplate
					)
			and tst.idfsFormTemplate is null
			and sft.intRowStatus = 0
print	'Remove incorrect connections between section and specified templates (ffSectionForTemplate): ' + cast(@@rowcount as varchar(20))

-- Insert new records
insert into	tstNewID
(	idfTable,
	idfKey1,
	idfKey2
)
select		74870000000,	-- ffParameterDesignOption
			pft.idfsParameter,
			pft.idfsFormTemplate
from		@ParameterLabelDesignOption tt
inner join	ffParameterForTemplate pft
on			pft.idfsParameter = tt.idfsParameterOrDecorElement
			and pft.idfsFormTemplate = tt.idfsFormTemplate
			and pft.intRowStatus = 0
left join	ffParameterDesignOption pdo
on			pdo.idfsParameter = pft.idfsParameter
			and pdo.idfsLanguage = dbo.fnGetLanguageCode('en')
			and pdo.idfsFormTemplate = pft.idfsFormTemplate
			and pdo.intRowStatus = 0
where		pdo.idfParameterDesignOption is null

insert into	ffParameterDesignOption
(	idfParameterDesignOption,
	idfsParameter,
	idfsLanguage,
	idfsFormTemplate,
	intLeft,
	intTop,
	intWidth,
	intHeight,
	intScheme,
	intLabelSize,
	intOrder,
	intRowStatus
)
select		nID.[NewID],
			pft.idfsParameter,
			dbo.fnGetLanguageCode('en'),
			pft.idfsFormTemplate,
			tt.intLeft,
			tt.intTop,
			tt.intWidth,
			tt.intHeight,
			0,
			tt.intLabelSize,
			tt.intOrder,
			0
from		@ParameterLabelDesignOption tt
inner join	ffParameterForTemplate pft
on			pft.idfsParameter = tt.idfsParameterOrDecorElement
			and pft.idfsFormTemplate = tt.idfsFormTemplate
			and pft.intRowStatus = 0
inner join	tstNewID nID
on			nID.idfTable = 74870000000	-- ffParameterDesignOption
			and nID.idfKey1 = pft.idfsParameter
			and nID.idfKey2 = pft.idfsFormTemplate
left join	ffParameterDesignOption pdo
on			pdo.idfParameterDesignOption = nID.[NewID]
where		pdo.idfParameterDesignOption is null
print	'Insert new parameter sizes and locations in templates (ffParameterDesignOption): ' + cast(@@rowcount as varchar(20))

delete from	tstNewID
where		idfTable = 74870000000	-- ffParameterDesignOption

insert into	ffSectionForTemplate
(	idfsFormTemplate,
	idfsSection,
	blnFreeze,
	intRowStatus
)
select		tst.idfsFormtemplate,
			tst.idfsSection,
			0,
			0
from		@SectionDesignOption tst
left join	ffSectionForTemplate sft
on			sft.idfsFormTemplate = tst.idfsFormTemplate
			and sft.idfsSection = tst.idfsSection
where		sft.idfsFormTemplate is null
print	'Insert new connections between section and templates (ffSectionForTemplate): ' + cast(@@rowcount as varchar(20))


insert into	tstNewID
(	idfTable,
	idfKey1,
	idfKey2
)
select		74970000000,	-- ffSectionDesignOption
			tst.idfsSection,
			tst.idfsFormTemplate
from		@SectionDesignOption tst
left join	ffSectionDesignOption sdo
on			sdo.idfsSection = tst.idfsSection
			and sdo.idfsLanguage = dbo.fnGetLanguageCode('en')
			and sdo.idfsFormTemplate = tst.idfsFormTemplate
			and sdo.intRowStatus = 0
where		sdo.idfSectionDesignOption is null

insert into	ffSectionDesignOption
(	idfSectionDesignOption,
	idfsLanguage,
	idfsFormTemplate,
	idfsSection,
	intLeft,
	intTop,
	intWidth,
	intHeight,
	intOrder,
	intCaptionHeight,
	intRowStatus
)
select		nID.[NewID],
			dbo.fnGetLanguageCode('en'),
			tst.idfsFormTemplate,
			tst.idfsSection,
			tst.intLeft,
			tst.intTop,
			tst.intWidth,
			tst.intHeight,
			tst.intOrder,
			tst.intCaptionHeight,
			0
from		@SectionDesignOption tst
inner join	tstNewID nID
on			nID.idfTable = 74970000000	-- ffSectionDesignOption
			and nID.idfKey1 = tst.idfsSection
			and nID.idfKey2 = tst.idfsFormTemplate
left join	ffSectionDesignOption sdo
on			sdo.idfSectionDesignOption = nID.[NewID]
where		sdo.idfSectionDesignOption is null
print	'Insert new section sizes and locations in templates (ffSectionDesignOption): ' + cast(@@rowcount as varchar(20))

delete from	tstNewID
where		idfTable = 74970000000	-- ffSectionDesignOption





-- Generate script to fill reference table
--TODO: update script!!!!!
print	''
print	''
print	'/* Script for filling @SectionTable with correct values */'
print	''
/*
select		
N'insert into @SectionTable
(idfsSection, idfSectionDesignOption, idfsFormType, FormType_EN, FormTemplate_EN, 
OrderInTemplate, strCustomizationPackage, idfCustomizationPackage, 
SectionPath_EN, ParentSection_EN, SectionType, 
Section_EN, Section_AM, Section_AZ, Section_GG, Section_KZ, Section_RU, Section_UA, Section_IQ, Section_TH
)
values	(' + IsNull(cast(tst.idfsSection as nvarchar(200)), N'null') + N', ' +
IsNull(cast(sdo.idfSectionDesignOption as nvarchar(200)), N'null') + N', ' +
IsNull(cast(t.idfsFormType as nvarchar(200)), N'null') + N', ' +
IsNull(N'N''' + replace(r_ft.[name], N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(r_t.[name], N'''', N'''''') + N'''', N'null') + N', ', N'
N''' + 
cast(	(	select		count(*)
			from		@SectionDesignOption tst_order
			inner join	ffFormTemplate t_order
			on			t_order.idfsFormTemplate = tst_order.idfsFormTemplate
						and t_order.intRowStatus = 0
			inner join	fnReference('en', 19000033) r_t_order			-- Flexible Form Template
			on			r_t_order.idfsReference = t_order.idfsFormTemplate
			inner join	fnReference('en', 19000034) r_ft_order			-- Flexible Form Type
			on			r_ft_order.idfsReference = t_order.idfsFormType
			inner join	@SectionStructure st_min_order
			on			st_min_order.idfsSection = tst_order.idfsSection
						and st_min_order.intParentLevel = 0
			inner join	@SectionStructure st_max_order
			on			st_max_order.idfsSection = tst_order.idfsSection
						and st_max_order.idfsLevelParentSection is null
			left join	ffSectionDesignOption sdo_order
			on			sdo_order.idfsFormTemplate = tst_order.idfsFormTemplate
						and sdo_order.idfsSection = tst_order.idfsSection
						and sdo_order.idfsLanguage = dbo.fnGetLanguageCode('en')
						and sdo_order.intRowStatus = 0
			where		t_order.idfsFormTemplate = t.idfsFormTemplate
						and (	tst_order.intOrder < tst.intOrder
								or	(	tst_order.intOrder = tst.intOrder
										and tst_order.idfsSection <= tst.idfsSection
									)
							)
		) as nvarchar(20)
	) + N''', ' +
IsNull(N'N''' + replace(c.strCustomizationPackageName, N'''', N'''''') + N'''', N'N''None''') + N', ' + 
IsNull(cast(brc.idfCustomizationPackage as varchar(20)), N'null') + N', 
' +
IsNull(N'N''' + replace(st_max.strLevelSectionPathEN, N'''', N'''''') + N'''', N'') + N', ' +
IsNull(N'N''' + replace(st_parent.strLevelSectionPathEN, N'''', N'''''') + N'''', N'N''None''') + N', ', N' 
			N''' + replace(replace(cast(IsNull(st_min.blnGrid, 0) as nvarchar(1)), N'0', N'Default'), N'1', N'Table') + N''', ' +
IsNull(N'N''' + replace(st_min.strLevelSectionPathEN, N'''', N'''''') + N'''', N'') + N', ' +
IsNull(N'N''' + replace(snt_AM.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_AZ.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_GG.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_KZ.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_RU.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_UA.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_IQ.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_TH.strTextString, N'''', N'''''') + N'''', N'null') + N'
)

'
from		@SectionDesignOption tst
-- Template
inner join	ffFormTemplate t
on			t.idfsFormTemplate = tst.idfsFormTemplate
			and t.intRowStatus = 0
inner join	fnReference('en', 19000033) r_t					-- Flexible Form Template
on			r_t.idfsReference = t.idfsFormTemplate
-- Form Type
inner join	fnReference('en', 19000034) r_ft				-- Flexible Form Type
on			r_ft.idfsReference = t.idfsFormType

-- Section
inner join	@SectionStructure st_min
on			st_min.idfsSection = tst.idfsSection
			and st_min.intParentLevel = 0
inner join	@SectionStructure st_max
on			st_max.idfsSection = tst.idfsSection
			and st_max.idfsLevelParentSection is null


-- Links to customization packages from templates
left join	trtBaseReferenceToCP brc
	inner join	tstCustomizationPackage c
	on			c.idfCustomizationPackage = brc.idfCustomizationPackage
	inner join	gisBaseReference br_c
	on			br_c.idfsGISBaseReference = c.idfsCountry
				and br_c.intRowStatus = 0
on			brc.idfsBaseReference = t.idfsFormTemplate

-- Translations
left join	trtStringNameTranslation snt_AM
on			snt_AM.idfsBaseReference = tst.idfsSection
			and snt_AM.idfsLanguage = dbo.fnGetLanguageCode('hy')
			and snt_AM.intRowStatus = 0
left join	trtStringNameTranslation snt_AZ
on			snt_AZ.idfsBaseReference = tst.idfsSection
			and snt_AZ.idfsLanguage = dbo.fnGetLanguageCode('az-L')
			and snt_AZ.intRowStatus = 0
left join	trtStringNameTranslation snt_GG
on			snt_GG.idfsBaseReference = tst.idfsSection
			and snt_GG.idfsLanguage = dbo.fnGetLanguageCode('ka')
			and snt_GG.intRowStatus = 0
left join	trtStringNameTranslation snt_KZ
on			snt_KZ.idfsBaseReference = tst.idfsSection
			and snt_KZ.idfsLanguage = dbo.fnGetLanguageCode('kk')
			and snt_KZ.intRowStatus = 0
left join	trtStringNameTranslation snt_RU
on			snt_RU.idfsBaseReference = tst.idfsSection
			and snt_RU.idfsLanguage = dbo.fnGetLanguageCode('ru')
			and snt_RU.intRowStatus = 0
left join	trtStringNameTranslation snt_UA
on			snt_UA.idfsBaseReference = tst.idfsSection
			and snt_UA.idfsLanguage = dbo.fnGetLanguageCode('uk')
			and snt_UA.intRowStatus = 0
left join	trtStringNameTranslation snt_IQ
on			snt_IQ.idfsBaseReference = tst.idfsSection
			and snt_IQ.idfsLanguage = dbo.fnGetLanguageCode('ar')
			and snt_IQ.intRowStatus = 0
left join	trtStringNameTranslation snt_TH
on			snt_TH.idfsBaseReference = tst.idfsSection
			and snt_TH.idfsLanguage = dbo.fnGetLanguageCode('th')
			and snt_TH.intRowStatus = 0
			
-- Parent Section
left join	@SectionStructure st_parent
on			st_parent.idfsSection = st_min.idfsLevelParentSection
			and st_parent.intParentLevel = 0

-- Section Design Option
left join	ffSectionDesignOption sdo
on			sdo.idfsFormTemplate = tst.idfsFormTemplate
			and sdo.idfsSection = tst.idfsSection
			and sdo.idfsLanguage = dbo.fnGetLanguageCode('en')
			and sdo.intRowStatus = 0
-- Restriction on the Form Type			
--where		r_ft.name <> N'Human Epi Investigations'--and r_t.name <= N'HEI Rabies GG' 
order by	r_ft.[name], r_t.[name], tst.intOrder
*/

print	''
print	'/* Script for filling @ParameterTable with correct values */'
print	''

/*
select		'insert into	@ParameterTable
(idfsParameter, idfsParameterCaption, idfDefParameterDesignOption, idfParameterDesignOption, idfsFormType, idfCustomizationPackage,
	FormType_EN, FormTemplate_EN, strCustomizationPackage, OrderInTemplate, 
	Parameter_EN, Parameter_AM, Parameter_AZ, Parameter_GG, Parameter_KZ, Parameter_RU, Parameter_UA, Parameter_IQ, Parameter_TH,
	Tooltip_EN,	Tooltip_AM,	Tooltip_AZ,	Tooltip_GG,	Tooltip_KZ,	Tooltip_RU,	Tooltip_UA,	Tooltip_IQ,	Tooltip_TH,	
	SectionPath_EN, Section_EN, ParameterType_EN, Editor_EN, Mode_EN
)
values	(	' + IsNull(cast(p.idfsParameter as nvarchar(200)), N'null') + N', ' +
IsNull(cast(p.idfsParameterCaption as nvarchar(200)), N'null') + N', ' +
IsNull(cast(pdo_def.idfParameterDesignOption as nvarchar(200)), N'null') + N', ' +
IsNull(cast(pdo.idfParameterDesignOption as nvarchar(200)), N'null') + N', ' +
IsNull(cast(t.idfsFormType as nvarchar(200)), N'null') + N', ' +
IsNull(cast(brc.idfCustomizationPackage as varchar(20)), N'null') + N', 
			' +
	N'' + IsNull(N'N''' + replace(r_ft.[name], N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(r_t.[name], N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(c.strCustomizationPackageName, N'''', N'''''') + N'''', N'N''None''') + N', N''' +
cast(	(	(	select		count(*)
				from		ffParameter p_parameter_order
				inner join	@ParameterLabelDesignOption pft_parameter_order
				on			pft_parameter_order.idfsParameterOrDecorElement = p_parameter_order.idfsParameter
				inner join	ffFormTemplate t_parameter_order
				on			t_parameter_order.idfsFormTemplate = pft_parameter_order.idfsFormTemplate
							and t_parameter_order.intRowStatus = 0
				inner join	fnReference('en', 19000033) r_t_parameter_order			-- Flexible Form Template
				on			r_t_parameter_order.idfsReference = t_parameter_order.idfsFormTemplate
				inner join	fnReference('en', 19000066) r_p_parameter_order			-- Flexible Form Parameter
				on			r_p_parameter_order.idfsReference = p_parameter_order.idfsParameter
				inner join	fnReference('en', 19000034) r_ft_parameter_order			-- Flexible Form Type
				on			r_ft_parameter_order.idfsReference = p_parameter_order.idfsFormType
				left join	ffParameterDesignOption pdo_parameter_order
				on			pdo_parameter_order.idfsParameter = p_parameter_order.idfsParameter
							and pdo_parameter_order.idfsFormTemplate = t_parameter_order.idfsFormTemplate
							and pdo_parameter_order.idfsLanguage = dbo.fnGetLanguageCode('en')
							and pdo_parameter_order.intRowStatus = 0
				left join	ffParameterDesignOption pdo_def_parameter_order
				on			pdo_def_parameter_order.idfsParameter = p_parameter_order.idfsParameter
							and pdo_def_parameter_order.idfsFormTemplate is null
							and pdo_def_parameter_order.idfsLanguage = dbo.fnGetLanguageCode('en')
							and pdo_def_parameter_order.intRowStatus = 0
				left join	fnReference('en', 19000070) r_pc_parameter_order			-- Flexible Form Parameter Tooltip
				on			r_pc_parameter_order.idfsReference = p_parameter_order.idfsParameterCaption
				left join	(
					ffParameterType pt_parameter_order
					inner join	fnReference('en', 19000071) r_pt_parameter_order		-- Flexible Form Parameter Type
					on			r_pt_parameter_order.idfsReference = pt_parameter_order.idfsParameterType
							)
				on			pt_parameter_order.idfsParameterType = p_parameter_order.idfsParameterType
							and pt_parameter_order.intRowStatus = 0
				left join	@SectionStructure st_min_parameter_order
				on			st_min_parameter_order.idfsSection = p_parameter_order.idfsSection
							and st_min_parameter_order.intParentLevel = 0
				left join	@SectionStructure st_max_parameter_order
				on			st_max_parameter_order.idfsSection = p_parameter_order.idfsSection
							and st_max_parameter_order.idfsLevelParentSection is null
				left join	ffSectionDesignOption sdo_parameter_order
				on			sdo_parameter_order.idfsSection = st_min_parameter_order.idfsSection
							and sdo_parameter_order.idfsFormTemplate = t_parameter_order.idfsFormTemplate
							and sdo_parameter_order.idfsLanguage = dbo.fnGetLanguageCode('en')
							and sdo_parameter_order.intRowStatus = 0
				where		p_parameter_order.intRowStatus = 0
							and t_parameter_order.idfsFormTemplate = t.idfsFormTemplate
							and (	pft_parameter_order.intOrder < pft.intOrder
									or	(	pft_parameter_order.intOrder = pft.intOrder
											and pft_parameter_order.idfsParameterOrDecorElement <= pft.idfsParameterOrDecorElement
										)
								)
			) +
			(	select		count(*)
				from		ffDecorElementText det_label_order
				inner join	ffDecorElement de_label_order
				on			de_label_order.idfDecorElement = det_label_order.idfDecorElement
							and de_label_order.idfsDecorElementType = 10106001	-- Label
							and de_label_order.idfsLanguage = dbo.fnGetLanguageCode('en')
							and de_label_order.intRowStatus = 0
				inner join	@ParameterLabelDesignOption pft_label_order
				on			pft_label_order.idfsParameterOrDecorElement = de_label_order.idfDecorElement
							and pft_label_order.idfsFormTemplate = de_label_order.idfsFormTemplate
				inner join	ffFormTemplate t_label_order
				on			t_label_order.idfsFormTemplate = de_label_order.idfsFormTemplate
							and t_label_order.intRowStatus = 0
				inner join	fnReference('en', 19000033) r_t_label_order		-- Flexible Form Template
				on			r_t_label_order.idfsReference = t_label_order.idfsFormTemplate
				inner join	fnReference('en', 19000034) r_ft_label_order	-- Flexible Form Type
				on			r_ft_label_order.idfsReference = t_label_order.idfsFormType
				inner join	fnReference('en', 19000131) r_l_en_label_order	-- Flexible Form Label Text
				on			r_l_en_label_order.idfsReference = det_label_order.idfsBaseReference
				left join	@SectionStructure st_min_label_order
				on			st_min_label_order.idfsSection = de_label_order.idfsSection
							and st_min_label_order.intParentLevel = 0
				left join	@SectionStructure st_max_label_order
				on			st_max_label_order.idfsSection = de_label_order.idfsSection
							and st_max_label_order.idfsLevelParentSection is null
				left join	ffSectionDesignOption sdo_label_order
				on			sdo_label_order.idfsSection = st_min_label_order.idfsSection
							and sdo_label_order.idfsFormTemplate = t_label_order.idfsFormTemplate
							and sdo_label_order.idfsLanguage = dbo.fnGetLanguageCode('en')
							and sdo_label_order.intRowStatus = 0
				where		det_label_order.intRowStatus = 0
							and t_label_order.idfsFormTemplate = t.idfsFormTemplate
							and (	pft_label_order.intOrder < pft.intOrder
									or	(	pft_label_order.intOrder = pft.intOrder
											and pft_label_order.idfsParameterOrDecorElement <= pft.idfsParameterOrDecorElement
										)
								)
			)
		) as nvarchar(20)
	) + N''', 
			' +
IsNull(N'N''' + replace(r_pc.[name], N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_caption_AM.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_caption_AZ.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_caption_GG.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_caption_KZ.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_caption_RU.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_caption_UA.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_caption_IQ.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_caption_TH.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(r_p.[name], N'''', N'''''') + N'''', N'null') + N', ',
N'
			' + IsNull(N'N''' + replace(snt_tooltip_AM.strTextString, N'''', N'''''') + N'''', N'null') + N', ',
N'
			' + IsNull(N'N''' + replace(snt_tooltip_AZ.strTextString, N'''', N'''''') + N'''', N'null') + N', ',
N'
			' + IsNull(N'N''' + replace(snt_tooltip_GG.strTextString, N'''', N'''''') + N'''', N'null') + N', ',
N'
			' + IsNull(N'N''' + replace(snt_tooltip_KZ.strTextString, N'''', N'''''') + N'''', N'null') + N', ',
N'
			' + IsNull(N'N''' + replace(snt_tooltip_RU.strTextString, N'''', N'''''') + N'''', N'null') + N', ',
N'
			' + IsNull(N'N''' + replace(snt_tooltip_UA.strTextString, N'''', N'''''') + N'''', N'null') + N', ',
N'
			' + IsNull(N'N''' + replace(snt_tooltip_IQ.strTextString, N'''', N'''''') + N'''', N'null') + N', ',
N'
			' + IsNull(N'N''' + replace(snt_tooltip_TH.strTextString, N'''', N'''''') + N'''', N'null') + N', ',
N'
			' + IsNull(N'N''' + replace(st_max.strLevelSectionPathEN, N'''', N'''''') + N'''', N'N''None''') + N', ',
N'
			' + IsNull(N'N''' + replace(st_min.strLevelSectionPathEN, N'''', N'''''') + N'''', N'N''None''') + N', ',
N'
			' + IsNull(N'N''' + replace(r_pt.[name], N'''', N'''''') + N'''', N'N''String''') + N', ' +
IsNull(N'N''' + replace(r_pe.[name], N'''', N'''''') + N'''', N'N''Text Box''') + N', ' +
IsNull(N'N''' + replace(r_pm.[name], N'''', N'''''') + N'''', N'N''Ordinary''') + N')

'

from		
-- Parameter
			ffParameter p
inner join	@ParameterLabelDesignOption pft
on			pft.idfsParameterOrDecorElement = p.idfsParameter

-- Template
inner join	ffFormTemplate t
on			t.idfsFormTemplate = pft.idfsFormTemplate
			and t.intRowStatus = 0
inner join	fnReference('en', 19000033) r_t					-- Flexible Form Template
on			r_t.idfsReference = t.idfsFormTemplate

-- Form Type
inner join	fnReference('en', 19000034) r_ft				-- Flexible Form Type
on			r_ft.idfsReference = p.idfsFormType

-- Tooltip translations
inner join	fnReference('en', 19000066) r_p					-- Flexible Form Parameter
on			r_p.idfsReference = p.idfsParameter
left join	trtStringNameTranslation snt_tooltip_AM
on			snt_tooltip_AM.idfsBaseReference = p.idfsParameter
			and snt_tooltip_AM.idfsLanguage = dbo.fnGetLanguageCode('hy')
			and snt_tooltip_AM.intRowStatus = 0
left join	trtStringNameTranslation snt_tooltip_AZ
on			snt_tooltip_AZ.idfsBaseReference = p.idfsParameter
			and snt_tooltip_AZ.idfsLanguage = dbo.fnGetLanguageCode('az-L')
			and snt_tooltip_AZ.intRowStatus = 0
left join	trtStringNameTranslation snt_tooltip_GG
on			snt_tooltip_GG.idfsBaseReference = p.idfsParameter
			and snt_tooltip_GG.idfsLanguage = dbo.fnGetLanguageCode('ka')
			and snt_tooltip_GG.intRowStatus = 0
left join	trtStringNameTranslation snt_tooltip_KZ
on			snt_tooltip_KZ.idfsBaseReference = p.idfsParameter
			and snt_tooltip_KZ.idfsLanguage = dbo.fnGetLanguageCode('kk')
			and snt_tooltip_KZ.intRowStatus = 0
left join	trtStringNameTranslation snt_tooltip_RU
on			snt_tooltip_RU.idfsBaseReference = p.idfsParameter
			and snt_tooltip_RU.idfsLanguage = dbo.fnGetLanguageCode('ru')
			and snt_tooltip_RU.intRowStatus = 0
left join	trtStringNameTranslation snt_tooltip_UA
on			snt_tooltip_UA.idfsBaseReference = p.idfsParameter
			and snt_tooltip_UA.idfsLanguage = dbo.fnGetLanguageCode('uk')
			and snt_tooltip_UA.intRowStatus = 0
left join	trtStringNameTranslation snt_tooltip_IQ
on			snt_tooltip_IQ.idfsBaseReference = p.idfsParameter
			and snt_tooltip_IQ.idfsLanguage = dbo.fnGetLanguageCode('ar')
			and snt_tooltip_IQ.intRowStatus = 0
left join	trtStringNameTranslation snt_tooltip_TH
on			snt_tooltip_TH.idfsBaseReference = p.idfsParameter
			and snt_tooltip_TH.idfsLanguage = dbo.fnGetLanguageCode('th')
			and snt_tooltip_TH.intRowStatus = 0


-- Links to customization packages from templates
left join	trtBaseReferenceToCP brc
	inner join	tstCustomizationPackage c
	on			c.idfCustomizationPackage = brc.idfCustomizationPackage
	inner join	gisBaseReference br_c
	on			br_c.idfsGISBaseReference = c.idfsCountry
				and br_c.intRowStatus = 0
on			brc.idfsBaseReference = t.idfsFormTemplate

-- Parameter Design Option in Template
left join	ffParameterDesignOption pdo
on			pdo.idfsParameter = p.idfsParameter
			and pdo.idfsFormTemplate = t.idfsFormTemplate
			and pdo.idfsLanguage = dbo.fnGetLanguageCode('en')
			and pdo.intRowStatus = 0

-- Default Parameter Design Option
left join	ffParameterDesignOption pdo_def
on			pdo_def.idfsParameter = p.idfsParameter
			and pdo_def.idfsFormTemplate is null
			and pdo_def.idfsLanguage = dbo.fnGetLanguageCode('en')
			and pdo_def.intRowStatus = 0

-- Parameter Caption Translations
left join	fnReference('en', 19000070) r_pc				-- Flexible Form Parameter Tooltip
on			r_pc.idfsReference = p.idfsParameterCaption
left join	trtStringNameTranslation snt_caption_AM
on			snt_caption_AM.idfsBaseReference = p.idfsParameterCaption
			and snt_caption_AM.idfsLanguage = dbo.fnGetLanguageCode('hy')
			and snt_caption_AM.intRowStatus = 0
left join	trtStringNameTranslation snt_caption_AZ
on			snt_caption_AZ.idfsBaseReference = p.idfsParameterCaption
			and snt_caption_AZ.idfsLanguage = dbo.fnGetLanguageCode('az-L')
			and snt_caption_AZ.intRowStatus = 0
left join	trtStringNameTranslation snt_caption_GG
on			snt_caption_GG.idfsBaseReference = p.idfsParameterCaption
			and snt_caption_GG.idfsLanguage = dbo.fnGetLanguageCode('ka')
			and snt_caption_GG.intRowStatus = 0
left join	trtStringNameTranslation snt_caption_KZ
on			snt_caption_KZ.idfsBaseReference = p.idfsParameterCaption
			and snt_caption_KZ.idfsLanguage = dbo.fnGetLanguageCode('kk')
			and snt_caption_KZ.intRowStatus = 0
left join	trtStringNameTranslation snt_caption_RU
on			snt_caption_RU.idfsBaseReference = p.idfsParameterCaption
			and snt_caption_RU.idfsLanguage = dbo.fnGetLanguageCode('ru')
			and snt_caption_RU.intRowStatus = 0
left join	trtStringNameTranslation snt_caption_UA
on			snt_caption_UA.idfsBaseReference = p.idfsParameterCaption
			and snt_caption_UA.idfsLanguage = dbo.fnGetLanguageCode('uk')
			and snt_caption_UA.intRowStatus = 0
left join	trtStringNameTranslation snt_caption_IQ
on			snt_caption_IQ.idfsBaseReference = p.idfsParameterCaption
			and snt_caption_IQ.idfsLanguage = dbo.fnGetLanguageCode('ar')
			and snt_caption_IQ.intRowStatus = 0
left join	trtStringNameTranslation snt_caption_TH
on			snt_caption_TH.idfsBaseReference = p.idfsParameterCaption
			and snt_caption_TH.idfsLanguage = dbo.fnGetLanguageCode('th')
			and snt_caption_TH.intRowStatus = 0
			
-- Parameter Type
left join	(
	ffParameterType pt
	inner join	fnReference('en', 19000071) r_pt			-- Flexible Form Parameter Type
	on			r_pt.idfsReference = pt.idfsParameterType
			)
on			pt.idfsParameterType = p.idfsParameterType
			and pt.intRowStatus = 0

-- Parameter Editor
left join	fnReference('en', 19000067) r_pe			-- Flexible Form Parameter Editor
on			r_pe.idfsReference = p.idfsEditor

-- Parameter Mode
left join	ffParameterForTemplate pft_mode
	inner join	fnReference('en', 19000068) r_pm		-- Flexible Form Parameter Mode
	on			r_pm.idfsReference = pft_mode.idfsEditMode
on			pft_mode.idfsFormTemplate = t.idfsFormTemplate
			and pft_mode.idfsParameter = p.idfsParameter
			and pft_mode.intRowStatus = 0

-- Section
left join	@SectionStructure st_min
on			st_min.idfsSection = p.idfsSection
			and st_min.intParentLevel = 0
left join	@SectionStructure st_max
on			st_max.idfsSection = p.idfsSection
			and st_max.idfsLevelParentSection is null
left join	ffSectionDesignOption sdo
on			sdo.idfsSection = st_min.idfsSection
			and sdo.idfsFormTemplate = t.idfsFormTemplate
			and sdo.idfsLanguage = dbo.fnGetLanguageCode('en')
			and sdo.intRowStatus = 0
-- Restriction on the Form Type				
where		p.intRowStatus = 0 --and r_ft.name <> N'Human Epi Investigations'--and r_t.name <= N'HEI Rabies GG' 
union all
select		'insert into	@ParameterTable
(idfsParameter, idfsParameterCaption, idfDefParameterDesignOption, idfParameterDesignOption, idfsFormType, idfCustomizationPackage,
	FormType_EN, FormTemplate_EN, strCustomizationPackage, OrderInTemplate, 
	Parameter_EN, Parameter_AM, Parameter_AZ, Parameter_GG, Parameter_KZ, Parameter_RU, Parameter_UA, Parameter_IQ, Parameter_TH,
	Tooltip_EN,	Tooltip_AM,	Tooltip_AZ,	Tooltip_GG,	Tooltip_KZ,	Tooltip_RU,	Tooltip_UA,	Tooltip_IQ,	Tooltip_TH,	
	SectionPath_EN, Section_EN, ParameterType_EN, Editor_EN, Mode_EN
)
values	(	' + IsNull(cast(r_l_en.idfsReference as nvarchar(200)), N'null') + N', ' +
N'null, ' +
N'null, ' +
IsNull(cast(de.idfDecorElement as nvarchar(200)), N'null') + N', ' +
IsNull(cast(t.idfsFormType as nvarchar(200)), N'null') + N', ' +
IsNull(cast(brc.idfCustomizationPackage as varchar(20)), N'null') + N', 
			' +
	N'' + IsNull(N'N''' + replace(r_ft.[name], N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(r_t.[name], N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(c.strCustomizationPackageName, N'''', N'''''') + N'''', N'N''None''') + N', N''' +
cast(	(	(	select		count(*)
				from		ffParameter p_parameter_order
				inner join	@ParameterLabelDesignOption pft_parameter_order
				on			pft_parameter_order.idfsParameterOrDecorElement = p_parameter_order.idfsParameter
				inner join	ffFormTemplate t_parameter_order
				on			t_parameter_order.idfsFormTemplate = pft_parameter_order.idfsFormTemplate
							and t_parameter_order.intRowStatus = 0
				inner join	fnReference('en', 19000033) r_t_parameter_order			-- Flexible Form Template
				on			r_t_parameter_order.idfsReference = t_parameter_order.idfsFormTemplate
				inner join	fnReference('en', 19000066) r_p_parameter_order			-- Flexible Form Parameter
				on			r_p_parameter_order.idfsReference = p_parameter_order.idfsParameter
				inner join	fnReference('en', 19000034) r_ft_parameter_order			-- Flexible Form Type
				on			r_ft_parameter_order.idfsReference = p_parameter_order.idfsFormType
				left join	ffParameterDesignOption pdo_parameter_order
				on			pdo_parameter_order.idfsParameter = p_parameter_order.idfsParameter
							and pdo_parameter_order.idfsFormTemplate = t_parameter_order.idfsFormTemplate
							and pdo_parameter_order.idfsLanguage = dbo.fnGetLanguageCode('en')
							and pdo_parameter_order.intRowStatus = 0
				left join	ffParameterDesignOption pdo_def_parameter_order
				on			pdo_def_parameter_order.idfsParameter = p_parameter_order.idfsParameter
							and pdo_def_parameter_order.idfsFormTemplate is null
							and pdo_def_parameter_order.idfsLanguage = dbo.fnGetLanguageCode('en')
							and pdo_def_parameter_order.intRowStatus = 0
				left join	fnReference('en', 19000070) r_pc_parameter_order			-- Flexible Form Parameter Tooltip
				on			r_pc_parameter_order.idfsReference = p_parameter_order.idfsParameterCaption
				left join	(
					ffParameterType pt_parameter_order
					inner join	fnReference('en', 19000071) r_pt_parameter_order		-- Flexible Form Parameter Type
					on			r_pt_parameter_order.idfsReference = pt_parameter_order.idfsParameterType
							)
				on			pt_parameter_order.idfsParameterType = p_parameter_order.idfsParameterType
							and pt_parameter_order.intRowStatus = 0
				left join	@SectionStructure st_min_parameter_order
				on			st_min_parameter_order.idfsSection = p_parameter_order.idfsSection
							and st_min_parameter_order.intParentLevel = 0
				left join	@SectionStructure st_max_parameter_order
				on			st_max_parameter_order.idfsSection = p_parameter_order.idfsSection
							and st_max_parameter_order.idfsLevelParentSection is null
				left join	ffSectionDesignOption sdo_parameter_order
				on			sdo_parameter_order.idfsSection = st_min_parameter_order.idfsSection
							and sdo_parameter_order.idfsFormTemplate = t_parameter_order.idfsFormTemplate
							and sdo_parameter_order.idfsLanguage = dbo.fnGetLanguageCode('en')
							and sdo_parameter_order.intRowStatus = 0
				where		p_parameter_order.intRowStatus = 0
							and t_parameter_order.idfsFormTemplate = t.idfsFormTemplate
							and (	pft_parameter_order.intOrder < pft.intOrder
									or	(	pft_parameter_order.intOrder = pft.intOrder
											and pft_parameter_order.idfsParameterOrDecorElement <= pft.idfsParameterOrDecorElement
										)
								)
			) +
			(	select		count(*)
				from		ffDecorElementText det_label_order
				inner join	ffDecorElement de_label_order
				on			de_label_order.idfDecorElement = det_label_order.idfDecorElement
							and de_label_order.idfsDecorElementType = 10106001	-- Label
							and de_label_order.idfsLanguage = dbo.fnGetLanguageCode('en')
							and de_label_order.intRowStatus = 0
				inner join	@ParameterLabelDesignOption pft_label_order
				on			pft_label_order.idfsParameterOrDecorElement = de_label_order.idfDecorElement
							and pft_label_order.idfsFormTemplate = de_label_order.idfsFormTemplate
				inner join	ffFormTemplate t_label_order
				on			t_label_order.idfsFormTemplate = de_label_order.idfsFormTemplate
							and t_label_order.intRowStatus = 0
				inner join	fnReference('en', 19000033) r_t_label_order		-- Flexible Form Template
				on			r_t_label_order.idfsReference = t_label_order.idfsFormTemplate
				inner join	fnReference('en', 19000034) r_ft_label_order	-- Flexible Form Type
				on			r_ft_label_order.idfsReference = t_label_order.idfsFormType
				inner join	fnReference('en', 19000131) r_l_en_label_order	-- Flexible Form Label Text
				on			r_l_en_label_order.idfsReference = det_label_order.idfsBaseReference
				left join	@SectionStructure st_min_label_order
				on			st_min_label_order.idfsSection = de_label_order.idfsSection
							and st_min_label_order.intParentLevel = 0
				left join	@SectionStructure st_max_label_order
				on			st_max_label_order.idfsSection = de_label_order.idfsSection
							and st_max_label_order.idfsLevelParentSection is null
				left join	ffSectionDesignOption sdo_label_order
				on			sdo_label_order.idfsSection = st_min_label_order.idfsSection
							and sdo_label_order.idfsFormTemplate = t_label_order.idfsFormTemplate
							and sdo_label_order.idfsLanguage = dbo.fnGetLanguageCode('en')
							and sdo_label_order.intRowStatus = 0
				where		det_label_order.intRowStatus = 0
							and t_label_order.idfsFormTemplate = t.idfsFormTemplate
							and (	pft_label_order.intOrder < pft.intOrder
									or	(	pft_label_order.intOrder = pft.intOrder
											and pft_label_order.idfsParameterOrDecorElement <= pft.idfsParameterOrDecorElement
										)
								)
			)
		) as nvarchar(20)
	) + N''', 
			' +
IsNull(N'N''' + replace(r_l_en.[name], N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_label_AM.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_label_AZ.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_label_GG.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_label_KZ.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_label_RU.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_label_UA.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_label_IQ.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_label_TH.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
N'
			N'''', ',
N'
			N'''', ',
N'
			N'''', ',
N'
			N'''', ',
N'
			N'''', ',
N'
			N'''', ',
N'
			N'''', ',
N'
			N'''', ',
N'
			N'''', ',
N'
			' + IsNull(N'N''' + replace(st_max.strLevelSectionPathEN, N'''', N'''''') + N'''', N'N''None''') + N', ',
N'
			' + IsNull(N'N''' + replace(st_min.strLevelSectionPathEN, N'''', N'''''') + N'''', N'N''None''') + N', ',
N'
			N''Label'', ' +
N'N'''', ' +
N'N'''')

'

from		
-- Label
			ffDecorElementText det
inner join	ffDecorElement de
on			de.idfDecorElement = det.idfDecorElement
			and de.idfsDecorElementType = 10106001	-- Label
			and de.idfsLanguage = dbo.fnGetLanguageCode('en')
			and de.intRowStatus = 0
inner join	@ParameterLabelDesignOption pft
on			pft.idfsParameterOrDecorElement = de.idfDecorElement
			and pft.idfsFormTemplate = de.idfsFormTemplate

-- Template
inner join	ffFormTemplate t
on			t.idfsFormTemplate = de.idfsFormTemplate
			and t.intRowStatus = 0
inner join	fnReference('en', 19000033) r_t					-- Flexible Form Template
on			r_t.idfsReference = t.idfsFormTemplate


-- Form Type
inner join	fnReference('en', 19000034) r_ft				-- Flexible Form Type
on			r_ft.idfsReference = t.idfsFormType

-- Label Text Translations
inner join	fnReference('en', 19000131) r_l_en				-- Flexible Form Label Text
on			r_l_en.idfsReference = det.idfsBaseReference
left join	trtStringNameTranslation snt_label_AM
on			snt_label_AM.idfsBaseReference = det.idfsBaseReference
			and snt_label_AM.idfsLanguage = dbo.fnGetLanguageCode('hy')
			and snt_label_AM.intRowStatus = 0
left join	trtStringNameTranslation snt_label_AZ
on			snt_label_AZ.idfsBaseReference = det.idfsBaseReference
			and snt_label_AZ.idfsLanguage = dbo.fnGetLanguageCode('az-L')
			and snt_label_AZ.intRowStatus = 0
left join	trtStringNameTranslation snt_label_GG
on			snt_label_GG.idfsBaseReference = det.idfsBaseReference
			and snt_label_GG.idfsLanguage = dbo.fnGetLanguageCode('ka')
			and snt_label_GG.intRowStatus = 0
left join	trtStringNameTranslation snt_label_KZ
on			snt_label_KZ.idfsBaseReference = det.idfsBaseReference
			and snt_label_KZ.idfsLanguage = dbo.fnGetLanguageCode('kk')
			and snt_label_KZ.intRowStatus = 0
left join	trtStringNameTranslation snt_label_RU
on			snt_label_RU.idfsBaseReference = det.idfsBaseReference
			and snt_label_RU.idfsLanguage = dbo.fnGetLanguageCode('ru')
			and snt_label_RU.intRowStatus = 0
left join	trtStringNameTranslation snt_label_UA
on			snt_label_UA.idfsBaseReference = det.idfsBaseReference
			and snt_label_UA.idfsLanguage = dbo.fnGetLanguageCode('uk')
			and snt_label_UA.intRowStatus = 0
left join	trtStringNameTranslation snt_label_IQ
on			snt_label_IQ.idfsBaseReference = det.idfsBaseReference
			and snt_label_IQ.idfsLanguage = dbo.fnGetLanguageCode('ar')
			and snt_label_IQ.intRowStatus = 0
left join	trtStringNameTranslation snt_label_TH
on			snt_label_TH.idfsBaseReference = det.idfsBaseReference
			and snt_label_TH.idfsLanguage = dbo.fnGetLanguageCode('th')
			and snt_label_TH.intRowStatus = 0


-- Links to customization packages from templates
left join	trtBaseReferenceToCP brc
	inner join	tstCustomizationPackage c
	on			c.idfCustomizationPackage = brc.idfCustomizationPackage
	inner join	gisBaseReference br_c
	on			br_c.idfsGISBaseReference = c.idfsCountry
				and br_c.intRowStatus = 0
on			brc.idfsBaseReference = t.idfsFormTemplate


-- Section
left join	@SectionStructure st_min
on			st_min.idfsSection = de.idfsSection
			and st_min.intParentLevel = 0
left join	@SectionStructure st_max
on			st_max.idfsSection = de.idfsSection
			and st_max.idfsLevelParentSection is null
left join	ffSectionDesignOption sdo
on			sdo.idfsSection = st_min.idfsSection
			and sdo.idfsFormTemplate = t.idfsFormTemplate
			and sdo.idfsLanguage = dbo.fnGetLanguageCode('en')
			and sdo.intRowStatus = 0
-- Restriction on the Form Type				
where		det.intRowStatus = 0 --and r_ft.name <> N'Human Epi Investigations'  --N'Human Epi Investigations' --  
--order by		r_ft.[name], r_t.[name], pft.intOrder
*/

IF @@ERROR <> 0
	ROLLBACK TRAN
ELSE
	COMMIT TRAN

set XACT_ABORT off
set nocount off


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER	FUNCTION [dbo].[FN_GBL_TriggersWork] ()
RETURNS BIT
AS
BEGIN
RETURN 1
--RETURN 0
END
GO


