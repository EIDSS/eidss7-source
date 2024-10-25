-- Script creates/updates resources, their translations and connections to the resource sets
-- Navigate to TODO section to add values for processing

SET XACT_ABORT ON 
SET NOCOUNT ON 

if object_id(N'tempdb..#ResourcesToProcess') is not null
	exec sp_executesql N'drop table #ResourcesToProcess'

if object_id(N'tempdb..#ResourcesToProcess') is null
	create table #ResourcesToProcess
	(	idfId bigint not null identity(1,1) primary key,
		idfsResource bigint not null,
		strResourceEN nvarchar(512) collate Cyrillic_General_CI_AS not null,
		strResourceType nvarchar(200) collate Cyrillic_General_CI_AS null,-- Button Text, Tooltip, Column Heading, Field Label, Heading, Message
		idfsResourceType bigint null default (10540006 /*Message*/),
		strResourceGE nvarchar(2000) collate Cyrillic_General_CI_AS null,
		strResourceAZ nvarchar(2000) collate Cyrillic_General_CI_AS null,
		strResourceRU nvarchar(2000) collate Cyrillic_General_CI_AS null,
		strResourceAM nvarchar(2000) collate Cyrillic_General_CI_AS null,
		strResourceARJO nvarchar(2000) collate Cyrillic_General_CI_AS null,
		strResourceARIQ nvarchar(2000) collate Cyrillic_General_CI_AS null,
		strResourceKZ nvarchar(2000) collate Cyrillic_General_CI_AS null,
		strResourceTH nvarchar(2000) collate Cyrillic_General_CI_AS null,
		strResourceUA nvarchar(2000) collate Cyrillic_General_CI_AS null
	)

truncate table #ResourcesToProcess

if object_id(N'tempdb..#ResourceToResourceSet') is not null
	exec sp_executesql N'drop table #ResourceToResourceSet'

if object_id(N'tempdb..#ResourceToResourceSet') is null
	create table #ResourceToResourceSet
	(	idfId bigint not null identity(1,1) primary key,
		idfsResource bigint not null,
		strResourceEN nvarchar(512) collate Cyrillic_General_CI_AS not null,
		strResourceSetPath nvarchar(2000) collate Cyrillic_General_CI_AS not null,
		idfsResourceSet bigint null,
		isHidden bit null,
		isRequired bit null,
		canEdit bit null,
		idfsReportTextID bigint null
	)

truncate table #ResourceToResourceSet

-- TODO: Insert values here into #ResourcesToProcess
insert into #ResourcesToProcess(idfsResource, strResourceEN, strResourceType, strResourceGE, strResourceAZ, strResourceRU) values
(4812, N'Alphanumeric', N'Field Label', N'ალფანუმერული', N'', N''),
(4813, N'Numeric', N'Field Label', N'რიცხვითი', N'', N''),
(4814, N'Add Street', N'Heading', N'ქუჩის დამატება', N'', N''),
(4815, N'Add Postal Code', N'Heading', N'დაამატეთ საფოსტო კოდი', N'', N''),
(4816, N'EpiCurve', N'Heading', N'ეპი მრუდი', N'', N''),
(4817, N'Language', N'Field Label', N'ენა', N'', N''),
(4818, N'Download Template button', N'Field Label', N'შაბლონის ჩამოტვირთვა ღილაკი', N'', N''),
(4819, N'Upload button', N'Field Label', N'ატვირთვის ღილაკი', N'', N''),
(4820, N'Notifying organisation', N'Column Heading', N'შემტყობინებელი ორგანიზაცია', N'', N''),
(4821, N'Notifying by', N'Column Heading', N'შემტყობინებელი', N'', N''),
(4822, N'ELECTRONIC INTEGRATED DISEASE SURVEILANCE SYSTEM', N'Column Heading', N'დაავადებათა ზედამხედველობის ელექტრონული ინტეგრირებული სისტემა', N'', N''),
(4823, N'Number of Records', N'Column Heading', N'ჩანაწერების რაოდენობა', N'', N''),
(4824, N'Date entered', N'Column Heading', N'შეყვანის თარიღი', N'', N''),
(4825, N'Disease', N'Column Heading', N'დაავადება', N'', N''),
(4826, N'Investigation Date', N'Column Heading', N'გამოძიების თარიღი', N'', N''),
(4827, N'Classification', N'Column Heading', N'კლასიფიკაცია', N'', N''),
(4828, N'Address', N'Column Heading', N'მისამართი', N'', N''),
(4829, N'Date entered', N'Column Heading', N'შეყვანის თარიღი', N'', N''),
(4830, N'Disease', N'Column Heading', N'დაავადება', N'', N''),
(4831, N'Investigation Date', N'Column Heading', N'გამოძიების თარიღი', N'', N''),
(4832, N'Classification', N'Column Heading', N'გამოძიების თარიღი', N'', N''),
(4833, N'Address', N'Column Heading', N'მისამართი', N'', N''),
(4834, N'Date Entered', N'Column Heading', N'შეყვანის თარიღი', N'', N''),
(4835, N'Report ID', N'Column Heading', N'ანგარიშის ID', N'', N''),
(4836, N'Person', N'Column Heading', N'პიროვნება', N'', N''),
(4837, N'Disease', N'Column Heading', N'დაავადება', N'', N''),
(4838, N'Disease Date', N'Column Heading', N'დაავადების თარიღი', N'', N''),
(4839, N'Classification', N'Column Heading', N'კლასიფიკაცია', N'', N''),
(4840, N'Investigated By', N'Column Heading', N'გამოძიებული', N'', N''),
(4841, N'Session ID', N'Column Heading', N'სესიის ID', N'', N''),
(4842, N'Date Entered', N'Column Heading', N'შეყვანის თარიღი', N'', N''),
(4843, N'Vector/Pools', N'Column Heading', N'ვექტორი/აუზები', N'', N''),
(4844, N'Disease', N'Column Heading', N'დაავადება', N'', N''),
(4845, N'Start Date', N'Column Heading', N'დაწყების თარიღი', N'', N''),
(4846, N'Region', N'Column Heading', N'რეგიონი', N'', N''),
(4847, N'Rayon', N'Column Heading', N'რაიონი', N'', N''),
(4848, N'Alternate Address', N'Heading', N'ალტერნატიული მისამართი', N'', N''),
(245, N'Choose File to Upload', N'Heading', N'აირჩიეთ ფაილი ასატვირთად', N'', N''),
(4849, N'Permanent Address', N'Heading', N'მუდმივი მისამართი', N'', N''),
(4850, N'Comments', N'Field Label', N'კომენტარები', N'Qeydlər', N'')

--(2278910540003, N'Alphanumeric', N'', N'ალფანუმერული', N'', N''),
--(2279010540003, N'Numeric', N'', N'რიცხვითი', N'', N''),
--(191112610540004, N'Add Street', N'', N'ქუჩის დამატება', N'', N''),
--(191112710540004, N'Add Postal Code', N'', N'დაამატეთ საფოსტო კოდი', N'', N''),
--(113277310540004, N'EpiCurve', N'', N'ეპი მრუდი', N'', N''),
--(5141310540003, N'Language', N'', N'ენა', N'', N''),
--(5192710540003, N'Download Template button', N'', N'შაბლონის ჩამოტვირთვა ღილაკი', N'', N''),
--(5192810540003, N'Upload button', N'', N'ატვირთვის ღილაკი', N'', N''),
--(447466510540002, N'Notifying organisation', N'', N'შემტყობინებელი ორგანიზაცია', N'', N''),
--(447466610540002, N'Notifying by', N'', N'შემტყობინებელი', N'', N''),
--(447466710540002, N'ELECTRONIC INTEGRATED DISEASE SURVEILANCE SYSTEM', N'', N'დაავადებათა ზედამხედველობის ელექტრონული ინტეგრირებული სისტემა', N'', N''),
--(2399910540002, N'Number of Records', N'', N'ჩანაწერების რაოდენობა', N'', N''),
--(447464110540002, N'Date entered', N'', N'შეყვანის თარიღი', N'', N''),
--(447464210540002, N'Disease', N'', N'დაავადება', N'', N''),
--(447464310540002, N'Investigation Date', N'', N'გამოძიების თარიღი', N'', N''),
--(447464410540002, N'Classification', N'', N'კლასიფიკაცია', N'', N''),
--(447464510540002, N'Address', N'', N'მისამართი', N'', N''),
--(447464610540002, N'Date entered', N'', N'შეყვანის თარიღი', N'', N''),
--(447464910540002, N'Disease', N'', N'დაავადება', N'', N''),
--(447464710540002, N'Investigation Date', N'', N'გამოძიების თარიღი', N'', N''),
--(447464810540002, N'Classification', N'', N'გამოძიების თარიღი', N'', N''),
--(447465010540002, N'Address', N'', N'მისამართი', N'', N''),
--(447465110540002, N'Date Entered', N'', N'შეყვანის თარიღი', N'', N''),
--(447465210540002, N'Report ID', N'', N'ანგარიშის ID', N'', N''),
--(447465310540002, N'Person', N'', N'პიროვნება', N'', N''),
--(447465410540002, N'Disease', N'', N'დაავადება', N'', N''),
--(447465510540002, N'Disease Date', N'', N'დაავადების თარიღი', N'', N''),
--(447465610540002, N'Classification', N'', N'კლასიფიკაცია', N'', N''),
--(447465710540002, N'Investigated By', N'', N'გამოძიებული', N'', N''),
--(447465810540002, N'Session ID', N'', N'სესიის ID', N'', N''),
--(447465910540002, N'Date Entered', N'', N'შეყვანის თარიღი', N'', N''),
--(447466010540002, N'Vector/Pools', N'', N'ვექტორი/აუზები', N'', N''),
--(447466110540002, N'Disease', N'', N'დაავადება', N'', N''),
--(447466210540002, N'Start Date', N'', N'დაწყების თარიღი', N'', N''),
--(447466310540002, N'Region', N'', N'რეგიონი', N'', N''),
--(447466410540002, N'Rayon', N'', N'რაიონი', N'', N''),
--(191110210540004, N'Alrternate Address', N'', N'ალტერნატიული მისამართი', N'', N'')

-- insert into #ResourceToResourceSet(idfsResource, strResourceEN, strResourceSetPath) values
-- (100000, N'xxx', N'Administration>Reference Editors>Base Reference>Add Base Reference Modal')
-- (100000, N'xxx', N'Administration>Reference Editors>Case Classifications>Add Case Classification Modal')
-- (100001, N'xxx1, N'Configuration>Veterinary Aggregate Case Matrix>Veterinary Aggregate Report Matrix>Add Disease Modal>Add Sample Type Modal')

 insert into #ResourceToResourceSet(idfsResource, strResourceEN, strResourceSetPath) values
 (4812, N'Alphanumeric', N'Configuration'),
 (4813, N'Numeric', N'Configuration'),
 (4814, N'Add Street', N'Human>Person>Person Address'),
 (4815, N'Add Postal Code', N'Human>Person>Person Address'),
 (4816, N'EpiCurve', N'Outbreak>Outbreak Session>Outbreak Analysis'),
 (4817, N'Language', N'Administration>Interface Editor'),
 (4818, N'Download Template button', N'Administration>Interface Editor'),
 (4819, N'Upload button', N'Administration>Interface Editor'),
 (4820, N'Notifying organisation', N'Global'),
 (4821, N'Notifying by', N'Global'),
 (4822, N'ELECTRONIC INTEGRATED DISEASE SURVEILANCE SYSTEM', N'Global'),
 (4823, N'Number of Records', N'Laboratory>Approvals'),
 (4824, N'Date entered', N'Global'),
 (4825, N'Disease', N'Global'),
 (4826, N'Investigation Date', N'Global'),
 (4827, N'Classification', N'Global'),
 (4828, N'Address', N'Global'),
 (4829, N'Date entered', N'Global'),
 (4830, N'Disease', N'Global'),
 (4831, N'Investigation Date', N'Global'),
 (4832, N'Classification', N'Global'),
 (4833, N'Address', N'Global'),
 (4834, N'Date Entered', N'Global'),
 (4835, N'Report ID', N'Global'),
 (4836, N'Person', N'Global'),
 (4837, N'Disease', N'Global'),
 (4838, N'Disease Date', N'Global'),
 (4839, N'Classification', N'Global'),
 (4840, N'Investigated By', N'Global'),
 (4841, N'Session ID', N'Global'),
 (4842, N'Date Entered', N'Global'),
 (4843, N'Vector/Pools', N'Global'),
 (4844, N'Disease', N'Global'),
 (4845, N'Start Date', N'Global'),
 (4846, N'Region', N'Global'),
 (4847, N'Rayon', N'Global'),
 (4848, N'Alternate Address', N'Human>Person>Person Address'),
 (245, N'Choose File to Upload', N'Global>Common Controls>Common Headings'),
 (4849, N'Permanent Address', N'Human>Person>Person Address'),
 (4850, N'Comments', N'Veterinary>Livestock Disease Report>Livestock Lab Tests')
-- Implementation of the task



declare @idfsLanguageEn bigint
set @idfsLanguageEn = dbo.FN_GBL_LanguageCode_GET('en-US')


declare	@Error	int
set	@Error = 0

declare	@ErrorMsg	nvarchar(MAX)
set	@ErrorMsg = N''


if object_id(N'tempdb..#ResourceTranslation') is not null
	exec sp_executesql N'drop table #ResourceTranslation'

if object_id(N'tempdb..#ResourceTranslation') is null
	create table #ResourceTranslation
	(	idfId bigint not null identity(1,1) primary key,
		idfsResource bigint not null,
		strResourceEN nvarchar(512) collate Cyrillic_General_CI_AS not null,
		strLanguage nvarchar(50) collate Cyrillic_General_CI_AS not null,
		idfsLanguage bigint not null,
		strResourceTranslation nvarchar(2000) collate Cyrillic_General_CI_AS not null
	)

truncate table #ResourceTranslation


IF OBJECT_ID('tempdb..#Hierarchy') IS NOT NULL
	exec sp_executesql N'drop table #Hierarchy'


IF OBJECT_ID('tempdb..#Hierarchy') IS  NULL
create table #Hierarchy
(	idfHierarchy bigint not null primary key,
	Lvl hierarchyid not null, 
	SelectedRootLvl hierarchyid not null, 
	StepParentLvl hierarchyid null, 
	StepParentIndex int not null, 
	idfsResourceSet bigint not null, 
	strResourceSet nvarchar(200) collate Cyrillic_General_CI_AS null, 
	strResourceSetUnique nvarchar(200) collate Cyrillic_General_CI_AS null, 
	StepResourceSetPath nvarchar(2000) collate Cyrillic_General_CI_AS null, 
	IncludeSelf bit not null default(0)
)
truncate table #Hierarchy


IF OBJECT_ID('tempdb..#Root') IS NOT NULL
	exec sp_executesql N'drop table #Root'


IF OBJECT_ID('tempdb..#Root') IS  NULL
create table #Root
( rootHId hierarchyid
)
truncate table #Root


BEGIN TRAN

BEGIN TRY

if exists
(	select	tempr.idfsResource, count(tempr.IdfId)
	from	#ResourcesToProcess tempr
	group by tempr.idfsResource
	having	count(tempr.IdfId) > 1
)
begin
	select	tempr.idfsResource, count(tempr.IdfId) as N'Duplicates #'
	from	#ResourcesToProcess tempr
	group by tempr.idfsResource
	having	count(tempr.IdfId) > 1

	raiserror (N'There are duplicates of Resource Ids in the table #ResourcesToProcess', 16, 1)
end

if exists
(	select	1
	from	#ResourceToResourceSet temp_r_to_rs
	left join	#ResourcesToProcess tempr
	on			tempr.idfsResource = temp_r_to_rs.idfsResource
	left join	trtResource r
	on			r.idfsResource = temp_r_to_rs.idfsResource
	where	tempr.idfsResource is null
			and r.idfsResource is null
)
begin
	select	temp_r_to_rs.idfsResource, temp_r_to_rs.strResourceEN
	from	#ResourceToResourceSet temp_r_to_rs
	left join	#ResourcesToProcess tempr
	on			tempr.idfsResource = temp_r_to_rs.idfsResource
	left join	trtResource r
	on			r.idfsResource = temp_r_to_rs.idfsResource
	where	tempr.idfsResource is null
			and r.idfsResource is null

	raiserror (N'There are non-existing Resource Ids in the table #ResourceToResourceSet (in both #ResourcesToProcess and trtResource)', 16, 1)
end

insert into #Root (rootHId)
select t.ResourceSetNode
from trtResourceSetHierarchy t
where t.idfResourceHierarchy between 1 and 9

declare @IncludeSelf bit = 1


;
 WITH cte
	(
        idfHierarchy, Lvl, SelectedRootLvl, StepParentLvl, StepParentIndex, idfsResourceSet, strResourceSet, strResourceSetUnique, StepResourceSetPath, IncludeSelf
    )
AS	(
		select child.idfResourceHierarchy, child.ResourceSetNode, selectedRoot.ResourceSetNode, child.ResourceSetNode.GetAncestor(1), 0, s_child.idfsResourceSet, s_child.strResourceSet, s_child.strResourceSetUnique, cast(isnull(s_child.strResourceSetUnique, s_child.strResourceSet) as nvarchar(2000)), @IncludeSelf
		from trtResourceSetHierarchy as selectedRoot
		inner join #Root as rootItem
		on rootItem.rootHId = selectedRoot.ResourceSetNode
		inner join trtResourceSetHierarchy as child
		   on child.ResourceSetNode.IsDescendantOf(
			   selectedRoot.ResourceSetNode
		   ) = 1
		inner join trtResourceSet s_child
		on s_child.idfsResourceSet = child.idfsResourceSet
		where (@IncludeSelf = 1 or (child.ResourceSetNode <> selectedRoot.ResourceSetNode)) and child.intRowStatus = 0
		union all
		select	cte.idfHierarchy, cte.Lvl, cte.SelectedRootLvl, stepParent.ResourceSetNode.GetAncestor(1), cte.StepParentIndex + 1, cte.idfsResourceSet, cte.strResourceSet, cte.strResourceSetUnique, cast((isnull(s_stepParent.strResourceSet, s_stepParent.strResourceSet) + N'>' + cte.StepResourceSetPath) as nvarchar(2000)), cte.IncludeSelf
		from	trtResourceSetHierarchy as stepParent
		inner join trtResourceSet s_stepParent
		on s_stepParent.idfsResourceSet = stepParent.idfsResourceSet
		inner join	cte
		on	cte.StepParentLvl = stepParent.ResourceSetNode
		where stepParent.intRowStatus = 0
	)


insert into #Hierarchy (idfHierarchy, Lvl, SelectedRootLvl, StepParentLvl, StepParentIndex, idfsResourceSet, strResourceSet, strResourceSetUnique, StepResourceSetPath, IncludeSelf)
select idfHierarchy, Lvl, SelectedRootLvl, StepParentLvl, StepParentIndex, idfsResourceSet, strResourceSet, strResourceSetUnique, StepResourceSetPath, IncludeSelf
from cte
where StepParentLvl = '/'
order by Lvl


if exists
(	select	1
	from	#ResourceToResourceSet temp_r_to_rs
	left join	#Hierarchy h
	on		h.StepResourceSetPath = temp_r_to_rs.strResourceSetPath collate Cyrillic_General_CI_AS
	where	h.idfsResourceSet is null
)
begin
	select	temp_r_to_rs.idfsResource, temp_r_to_rs.strResourceEN, temp_r_to_rs.strResourceSetPath
	from	#ResourceToResourceSet temp_r_to_rs
	left join	#Hierarchy h
	on		h.StepResourceSetPath = temp_r_to_rs.strResourceSetPath collate Cyrillic_General_CI_AS
	where	h.idfsResourceSet is null

	raiserror (N'There are non-existing Resource Set Paths in the table #ResourceToResourceSet', 16, 1)
end



if exists
(	select	temp_r_to_rs.idfsResource, temp_r_to_rs.strResourceSetPath, count(temp_r_to_rs.IdfId)
	from	#ResourceToResourceSet temp_r_to_rs
	group by temp_r_to_rs.idfsResource, temp_r_to_rs.strResourceSetPath
	having	count(temp_r_to_rs.IdfId) > 1
)
begin
	select	temp_r_to_rs.idfsResource, temp_r_to_rs.strResourceSetPath, count(temp_r_to_rs.IdfId) as N'Duplicates #'
	from	#ResourceToResourceSet temp_r_to_rs
	group by temp_r_to_rs.idfsResource, temp_r_to_rs.strResourceSetPath
	having	count(temp_r_to_rs.IdfId) > 1

	raiserror (N'There are duplicates of pairs of Resource Ids and Resource Set Paths in the table #ResourceToResourceSet', 16, 1)
end

update	tempr
set		tempr.idfsResourceType = rt.idfsBaseReference
from	#ResourcesToProcess tempr
outer apply
(	select top 1 br_rt.idfsBaseReference
	from	trtBaseReference br_rt
	where	br_rt.strDefault = tempr.strResourceType collate Cyrillic_General_CI_AS
			and br_rt.intRowStatus = 0
) rt

update	temp_r_to_rs
set		temp_r_to_rs.idfsResourceSet = h.idfsResourceSet
from	#ResourceToResourceSet temp_r_to_rs
join	#Hierarchy h
on		h.StepResourceSetPath = temp_r_to_rs.strResourceSetPath collate Cyrillic_General_CI_AS

delete	temp_r_to_rs
from	#ResourceToResourceSet temp_r_to_rs
where	exists
		(	select	1
			from	#ResourceToResourceSet temp_r_to_rs_greater
			where	temp_r_to_rs_greater.idfsResource = temp_r_to_rs.idfsResource
					and temp_r_to_rs_greater.idfsResourceSet = temp_r_to_rs.idfsResourceSet
					and temp_r_to_rs_greater.idfId > temp_r_to_rs.idfId
		)

declare @idfsLanguage bigint

set @idfsLanguage = dbo.fnGetLanguageCode('hy')
if @idfsLanguage is not null and @idfsLanguage <> @idfsLanguageEn
	insert into	#ResourceTranslation
	(	idfsResource,
		idfsLanguage,
		strResourceTranslation,
		strResourceEN,
		strLanguage
	)
	select	tempr.idfsResource,
			@idfsLanguage,
			tempr.strResourceAM,
			tempr.strResourceEN,
			N'hy-AM'
	from	#ResourcesToProcess tempr
	left join	#ResourceTranslation temprtr
	on		temprtr.idfsResource = tempr.idfsResource
			and temprtr.idfsLanguage = @idfsLanguage
	where	tempr.strResourceAM is not null
			and tempr.strResourceAM <> N'' collate Cyrillic_General_CI_AS
			and temprtr.idfId is null

set @idfsLanguage = dbo.fnGetLanguageCode('ar')
if @idfsLanguage is not null and @idfsLanguage <> @idfsLanguageEn
	insert into	#ResourceTranslation
	(	idfsResource,
		idfsLanguage,
		strResourceTranslation,
		strResourceEN,
		strLanguage
	)
	select	tempr.idfsResource,
			@idfsLanguage,
			tempr.strResourceARJO,
			tempr.strResourceEN,
			N'ar-JO'
	from	#ResourcesToProcess tempr
	left join	#ResourceTranslation temprtr
	on		temprtr.idfsResource = tempr.idfsResource
			and temprtr.idfsLanguage = @idfsLanguage
	where	tempr.strResourceARJO is not null
			and tempr.strResourceARJO <> N'' collate Cyrillic_General_CI_AS
			and temprtr.idfId is null

set @idfsLanguage = dbo.fnGetLanguageCode('ar-IQ')
if @idfsLanguage is not null and @idfsLanguage <> @idfsLanguageEn
	insert into	#ResourceTranslation
	(	idfsResource,
		idfsLanguage,
		strResourceTranslation,
		strResourceEN,
		strLanguage
	)
	select	tempr.idfsResource,
			@idfsLanguage,
			tempr.strResourceARIQ,
			tempr.strResourceEN,
			N'ar-IQ'
	from	#ResourcesToProcess tempr
	left join	#ResourceTranslation temprtr
	on		temprtr.idfsResource = tempr.idfsResource
			and temprtr.idfsLanguage = @idfsLanguage
	where	tempr.strResourceARIQ is not null
			and tempr.strResourceARIQ <> N'' collate Cyrillic_General_CI_AS
			and temprtr.idfId is null

set @idfsLanguage = dbo.fnGetLanguageCode('az-L')
if @idfsLanguage is not null and @idfsLanguage <> @idfsLanguageEn
	insert into	#ResourceTranslation
	(	idfsResource,
		idfsLanguage,
		strResourceTranslation,
		strResourceEN,
		strLanguage
	)
	select	tempr.idfsResource,
			@idfsLanguage,
			tempr.strResourceAZ,
			tempr.strResourceEN,
			N'az-Latn-AZ'
	from	#ResourcesToProcess tempr
	left join	#ResourceTranslation temprtr
	on		temprtr.idfsResource = tempr.idfsResource
			and temprtr.idfsLanguage = @idfsLanguage
	where	tempr.strResourceAZ is not null
			and tempr.strResourceAZ <> N'' collate Cyrillic_General_CI_AS
			and temprtr.idfId is null

set @idfsLanguage = dbo.fnGetLanguageCode('ka')
if @idfsLanguage is not null and @idfsLanguage <> @idfsLanguageEn
	insert into	#ResourceTranslation
	(	idfsResource,
		idfsLanguage,
		strResourceTranslation,
		strResourceEN,
		strLanguage
	)
	select	tempr.idfsResource,
			@idfsLanguage,
			tempr.strResourceGE,
			tempr.strResourceEN,
			N'ka-GE'
	from	#ResourcesToProcess tempr
	left join	#ResourceTranslation temprtr
	on		temprtr.idfsResource = tempr.idfsResource
			and temprtr.idfsLanguage = @idfsLanguage
	where	tempr.strResourceGE is not null
			and tempr.strResourceGE <> N'' collate Cyrillic_General_CI_AS
			and temprtr.idfId is null

set @idfsLanguage = dbo.fnGetLanguageCode('kk')
if @idfsLanguage is not null and @idfsLanguage <> @idfsLanguageEn
	insert into	#ResourceTranslation
	(	idfsResource,
		idfsLanguage,
		strResourceTranslation,
		strResourceEN,
		strLanguage
	)
	select	tempr.idfsResource,
			@idfsLanguage,
			tempr.strResourceKZ,
			tempr.strResourceEN,
			N'kk-KZ'
	from	#ResourcesToProcess tempr
	left join	#ResourceTranslation temprtr
	on		temprtr.idfsResource = tempr.idfsResource
			and temprtr.idfsLanguage = @idfsLanguage
	where	tempr.strResourceKZ is not null
			and tempr.strResourceKZ <> N'' collate Cyrillic_General_CI_AS
			and temprtr.idfId is null

set @idfsLanguage = dbo.fnGetLanguageCode('ru')
if @idfsLanguage is not null and @idfsLanguage <> @idfsLanguageEn
	insert into	#ResourceTranslation
	(	idfsResource,
		idfsLanguage,
		strResourceTranslation,
		strResourceEN,
		strLanguage
	)
	select	tempr.idfsResource,
			@idfsLanguage,
			tempr.strResourceRU,
			tempr.strResourceEN,
			N'ru-RU'
	from	#ResourcesToProcess tempr
	left join	#ResourceTranslation temprtr
	on		temprtr.idfsResource = tempr.idfsResource
			and temprtr.idfsLanguage = @idfsLanguage
	where	tempr.strResourceRU is not null
			and tempr.strResourceRU <> N'' collate Cyrillic_General_CI_AS
			and temprtr.idfId is null

			
set @idfsLanguage = dbo.fnGetLanguageCode('th')
if @idfsLanguage is not null and @idfsLanguage <> @idfsLanguageEn
	insert into	#ResourceTranslation
	(	idfsResource,
		idfsLanguage,
		strResourceTranslation,
		strResourceEN,
		strLanguage
	)
	select	tempr.idfsResource,
			@idfsLanguage,
			tempr.strResourceTH,
			tempr.strResourceEN,
			N'th-TH'
	from	#ResourcesToProcess tempr
	left join	#ResourceTranslation temprtr
	on		temprtr.idfsResource = tempr.idfsResource
			and temprtr.idfsLanguage = @idfsLanguage
	where	tempr.strResourceTH is not null
			and tempr.strResourceTH <> N'' collate Cyrillic_General_CI_AS
			and temprtr.idfId is null
			
set @idfsLanguage = dbo.fnGetLanguageCode('uk')
if @idfsLanguage is not null and @idfsLanguage <> @idfsLanguageEn
	insert into	#ResourceTranslation
	(	idfsResource,
		idfsLanguage,
		strResourceTranslation,
		strResourceEN,
		strLanguage
	)
	select	tempr.idfsResource,
			@idfsLanguage,
			tempr.strResourceUA,
			tempr.strResourceEN,
			N'uk-UA'
	from	#ResourcesToProcess tempr
	left join	#ResourceTranslation temprtr
	on		temprtr.idfsResource = tempr.idfsResource
			and temprtr.idfsLanguage = @idfsLanguage
	where	tempr.strResourceUA is not null
			and tempr.strResourceUA <> N'' collate Cyrillic_General_CI_AS
			and temprtr.idfId is null

declare @N int
select @N = count(idfId)
from #ResourcesToProcess

print N'Resources to add/update: ' + cast(@N as nvarchar(20))

select @N = count(idfId)
from #ResourceTranslation

print N'Translations of resources to add/update: ' + cast(@N as nvarchar(20))

select @N = count(idfId)
from #ResourceToResourceSet

print N'Links from resources to resource sets to add/update: ' + cast(@N as nvarchar(20))

print N''

update	r
set		r.idfsResourceType = isnull(tempr.idfsResourceType, r.idfsResourceType),
		r.strResourceName = tempr.strResourceEN,
		r.intRowStatus = 0,
		r.AuditUpdateUser = N'system',
		r.AuditUpdateDTM = getutcdate(),
		r.SourceSystemKeyValue = N'[{' + N'"idfsResource":' + isnull(cast(r.idfsResource as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
from	trtResource r
join	#ResourcesToProcess tempr
on		tempr.idfsResource = r.idfsResource
where	(	(r.idfsResourceType is null and tempr.idfsResourceType is not null)
			or (r.idfsResourceType is not null and tempr.idfsResourceType is not null and tempr.idfsResourceType <> r.idfsResourceType)
			or (r.strResourceName <> tempr.strResourceEN collate Cyrillic_General_CI_AS)
			or r.intRowStatus <> 0
		)
print N'trtResource - update - EN name, type or delete attribute of resources: ' + cast(@@rowcount as nvarchar(200))

insert into	trtResource
(	idfsResource,
	idfsResourceType,
	strResourceName,
	intRowStatus,
	AuditCreateUser,
	AuditCreateDTM,
	AuditUpdateUser,
	AuditUpdateDTM,
	SourceSystemNameID,
	SourceSystemKeyValue
)
select		tempr.idfsResource,
			tempr.idfsResourceType,
			tempr.strResourceEN,
			0,
			N'system',
			getutcdate(),
			N'system',
			getutcdate(),
			10519001 /*Record Source: EIDSS7*/,
			N'[{' + N'"idfsResource":' + isnull(cast(tempr.idfsResource as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
from		#ResourcesToProcess tempr
left join	trtResource r
on			r.idfsResource = tempr.idfsResource
where		r.idfsResource is null
print N'trtResource - insert: ' + cast(@@rowcount as nvarchar(200))

update		rtr
set			rtr.strResourceString = temprtr.strResourceTranslation,
			rtr.intRowStatus = 0,
			rtr.AuditUpdateUser = N'system',
			rtr.AuditUpdateDTM = getutcdate(),
			rtr.SourceSystemKeyValue = N'[{' + N'"idfsResource":' + isnull(cast(temprtr.idfsResource as nvarchar(20)), N'null') + N',' + N'"idfsLanguage":' + isnull(cast(temprtr.idfsLanguage as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
from		trtResourceTranslation rtr
join		#ResourceTranslation temprtr
on			temprtr.idfsResource = rtr.idfsResource
			and temprtr.idfsLanguage = rtr.idfsLanguage
where		(	(rtr.strResourceString is null and temprtr.strResourceTranslation is not null)
				or (rtr.strResourceString is not null and temprtr.strResourceTranslation is not null and rtr.strResourceString <> temprtr.strResourceTranslation)
				or rtr.intRowStatus <> 0
			)
print N'trtResourceTranslation - update - Resource Translation or its delete attribute: ' + cast(@@rowcount as nvarchar(200))

insert into	trtResourceTranslation
(	idfsResource,
	idfsLanguage,
	strResourceString,
	intRowStatus,
	AuditCreateUser,
	AuditCreateDTM,
	AuditUpdateUser,
	AuditUpdateDTM,
	SourceSystemNameID,
	SourceSystemKeyValue
)
select		temprtr.idfsResource,
			temprtr.idfsLanguage,
			temprtr.strResourceTranslation,
			0,
			N'system',
			getutcdate(),
			N'system',
			getutcdate(),
			10519001 /*Record Source: EIDSS7*/,
			N'[{' + N'"idfsResource":' + isnull(cast(temprtr.idfsResource as nvarchar(20)), N'null') + N',' + N'"idfsLanguage":' + isnull(cast(temprtr.idfsLanguage as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
from		#ResourceTranslation temprtr
inner join	trtResource r
on			r.idfsResource = temprtr.idfsResource
left join	trtResourceTranslation rtr
on			temprtr.idfsResource = rtr.idfsResource
			and temprtr.idfsLanguage = rtr.idfsLanguage
where		rtr.idfsResource is null
print N'trtResourceTranslation - insert: ' + cast(@@rowcount as nvarchar(200))

update	r_to_rs
set		r_to_rs.intRowStatus = 0,
		r_to_rs.isHidden = coalesce(temp_r_to_rs.isHidden, r_to_rs.isHidden, 0),
		r_to_rs.isRequired = coalesce(temp_r_to_rs.isRequired, r_to_rs.isRequired, 0),
		r_to_rs.canEdit = coalesce(temp_r_to_rs.canEdit, r_to_rs.canEdit, 1),
		r_to_rs.idfsReportTextID = coalesce(temp_r_to_rs.idfsReportTextID, r_to_rs.idfsReportTextID, 0),
		r_to_rs.AuditUpdateUser = N'system',
		r_to_rs.AuditUpdateDTM = getutcdate(),
		r_to_rs.SourceSystemKeyValue = N'[{' + N'"idfsResourceSet":' + isnull(cast(temp_r_to_rs.idfsResourceSet as nvarchar(20)), N'null') + N',' + N'"idfsResource":' + isnull(cast(temp_r_to_rs.idfsResource as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
from	trtResourceSetToResource r_to_rs
join	#ResourceToResourceSet temp_r_to_rs
on		temp_r_to_rs.idfsResource = r_to_rs.idfsResource
		and temp_r_to_rs.idfsResourceSet = r_to_rs.idfsResourceSet
where	(	r_to_rs.intRowStatus <> 0
			or	(	r_to_rs.isHidden is null
					or (r_to_rs.isHidden is not null and temp_r_to_rs.isHidden is not null and r_to_rs.isHidden <> temp_r_to_rs.isHidden)
				)
			or	(	r_to_rs.isRequired is null
					or (r_to_rs.isRequired is not null and temp_r_to_rs.isRequired is not null and r_to_rs.isRequired <> temp_r_to_rs.isRequired)
				)
			or	(	r_to_rs.canEdit is null
					or (r_to_rs.canEdit is not null and temp_r_to_rs.canEdit is not null and r_to_rs.canEdit <> temp_r_to_rs.canEdit)
				)
		)
print N'trtResourceSetToResource - update delete, hidden, mandatory, editable attributes: ' + cast(@@rowcount as nvarchar(200))


insert into	trtResourceSetToResource
(	idfsResource,
	idfsResourceSet,
	isHidden,
	isRequired,
	canEdit,
	idfsReportTextID,
	intRowStatus,
	AuditCreateUser,
	AuditCreateDTM,
	AuditUpdateUser,
	AuditUpdateDTM,
	SourceSystemNameID,
	SourceSystemKeyValue
)
select		temp_r_to_rs.idfsResource,
			temp_r_to_rs.idfsResourceSet,
			isnull(temp_r_to_rs.isHidden, 0),
			isnull(temp_r_to_rs.isRequired, 0),
			isnull(temp_r_to_rs.canEdit, 1),
			isnull(temp_r_to_rs.idfsReportTextID, 0),
			0,
			N'system',
			getutcdate(),
			N'system',
			getutcdate(),
			10519001 /*Record Source: EIDSS7*/,
			N'[{' + N'"idfsResourceSet":' + isnull(cast(temp_r_to_rs.idfsResourceSet as nvarchar(20)), N'null') + N',' + N'"idfsResource":' + isnull(cast(temp_r_to_rs.idfsResource as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
from		#ResourceToResourceSet temp_r_to_rs
inner join	trtResource r
on			r.idfsResource = temp_r_to_rs.idfsResource
inner join	trtResourceSet rs
on			rs.idfsResourceSet = temp_r_to_rs.idfsResourceSet
left join	trtResourceSetToResource r_to_rs
on			temp_r_to_rs.idfsResource = r_to_rs.idfsResource
			and temp_r_to_rs.idfsResourceSet = r_to_rs.idfsResourceSet
where		r_to_rs.idfsResourceSet is null
print N'trtResourceSetToResource - insert: ' + cast(@@rowcount as nvarchar(200))



END TRY
BEGIN CATCH
    set @Error = ERROR_NUMBER()
	set	@ErrorMsg = /*N'ErrorNumber: ' + CONVERT(NVARCHAR, ERROR_NUMBER()) 
		+*/ N' ErrorSeverity: ' + CONVERT(NVARCHAR, ERROR_SEVERITY())
		+ N' ErrorState: ' + CONVERT(NVARCHAR, ERROR_STATE())
		+ N' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), N'')
		+ N' ErrorLine: ' +  CONVERT(NVARCHAR, ISNULL(ERROR_LINE(), N''))
		+ N' ErrorMessage: ' + ERROR_MESSAGE();


	IF OBJECT_ID('tempdb..#Hierarchy') IS NOT NULL
		exec sp_executesql N'drop table #Hierarchy'


	IF OBJECT_ID('tempdb..#Root') IS NOT NULL
		exec sp_executesql N'drop table #Root'


	if object_id(N'tempdb..#ResourceTranslation') is not null
		exec sp_executesql N'drop table #ResourceTranslation'


	if object_id(N'tempdb..#ResourceToResourceSet') is not null
		exec sp_executesql N'drop table #ResourceToResourceSet'

	if object_id(N'tempdb..#ResourcesToProcess') is not null
		exec sp_executesql N'drop table #ResourcesToProcess'

	
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



IF OBJECT_ID('tempdb..#Hierarchy') IS NOT NULL
	exec sp_executesql N'drop table #Hierarchy'


IF OBJECT_ID('tempdb..#Root') IS NOT NULL
	exec sp_executesql N'drop table #Root'

if object_id(N'tempdb..#ResourceTranslation') is not null
	exec sp_executesql N'drop table #ResourceTranslation'


if object_id(N'tempdb..#ResourceToResourceSet') is not null
	exec sp_executesql N'drop table #ResourceToResourceSet'

if object_id(N'tempdb..#ResourcesToProcess') is not null
	exec sp_executesql N'drop table #ResourcesToProcess'
