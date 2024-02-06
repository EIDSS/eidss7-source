-- This script creates employees of specified orginizations with specified account names and passwords on sites of their organizations.
-- It configures all applicable "Allow" permissions on default site.
--
-- NB! Account names and passwords shall contain English symbols, digits, spaces and points only.
-- NB! Account names shall be unique for different employees in the list.
-- NB! Employee shall be present in the list once.
GO 
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

ALTER	function [dbo].[fnTriggersWork] ()
returns bit
as
begin
return 0
end
GO

set nocount on
set XACT_ABORT on

BEGIN TRAN

declare	@UserTable	table
(	idfID								bigint not null identity(1, 2),
	strEmployeeOrganizationAbbreviation	nvarchar(2000) collate database_default not null,
	strAccountName						varchar(500) collate database_default not null,
	strPassword							varchar(500) collate database_default not null default (N'EIDSS2021'),
	idfOrganization						bigint null,
	idfPerson							bigint null,
	idfUserID							bigint null,
	idfsSite							bigint null,
	primary key	(
		strAccountName asc
				)
)

-- Fill user table
declare	@idfsSite	bigint
set	@idfsSite = null

declare	@strEmployeeOrganizationAbbreviation	nvarchar(2000)

select		@idfsSite = s.idfsSite,
			@strEmployeeOrganizationAbbreviation = i.[name]
from		tstLocalSiteOptions lso
inner join	tstSite s
on			cast(s.idfsSite as nvarchar(20)) = lso.strValue
			and s.idfsSite <> 1
			and s.blnIsWEB = 0
			and s.intRowStatus = 0
inner join	fnInstitution('en') i
on			i.idfOffice = s.idfOffice
where		lso.strName = N'SiteID' collate Cyrillic_General_CI_AS

if	@idfsSite is null
begin
	select		@idfsSite = s.idfsSite,
				@strEmployeeOrganizationAbbreviation = i.[name]
	from		tstGlobalSiteOptions gso
	inner join	tstSite s
	on			cast(s.idfCustomizationPackage as nvarchar(200)) = gso.strValue collate Cyrillic_General_CI_AS
				and s.idfsSite <> 1
				and s.idfsParentSite is null	-- CDR
				and s.intRowStatus = 0
	inner join	fnInstitution('en') i
	on			i.idfOffice = s.idfOffice
	where		gso.strName = N'CustomizationPackage' collate Cyrillic_General_CI_AS
end

if	@idfsSite is null
begin
	select		@idfsSite = s.idfsSite,
				@strEmployeeOrganizationAbbreviation = i.[name]
	from		tstGlobalSiteOptions gso
	inner join	tstCustomizationPackage cp
	on			cast(cp.idfCustomizationPackage as nvarchar(200)) = gso.strValue collate Cyrillic_General_CI_AS
				and cp.strCustomizationPackageName = N'DTRA' collate Cyrillic_General_CI_AS
	inner join	tstSite s
	on			s.idfsSite <> 1
				and s.idfsParentSite is null	-- CDR
				and s.intRowStatus = 0
	inner join	fnInstitution('en') i
	on			i.idfOffice = s.idfOffice
	where		gso.strName = N'CustomizationPackage' collate Cyrillic_General_CI_AS
end



insert into	@UserTable (strEmployeeOrganizationAbbreviation, strAccountName)
select		i.[name], N'demoEidss'
from		tstSite s
inner join	fnInstitution('en') i
on			i.idfOffice = s.idfOffice
where		s.idfsSite = @idfsSite


-- Implementation
declare	@N int

-- Select distinct employees
declare	@PersonTable	table
(	idfID								bigint not null,
	strEmployeeOrganizationAbbreviation	nvarchar(500) collate database_default not null,
	strAccountName						varchar(500) collate database_default not null,
	idfOrganization						bigint null,
	idfPerson							bigint null,
	primary key	(
		strAccountName asc
				)
)

insert into	@PersonTable (idfID, strEmployeeOrganizationAbbreviation, strAccountName, idfOrganization, idfPerson)
select		ut_format.idfID,
			ut_format.strEmployeeOrganizationAbbreviation,
			ut_format.strAccountName,
			ut_format.idfOrganization,
			ut_format.idfPerson
from		@UserTable ut_format



-- Update existing IDs for Employees
update		pt_format
set			pt_format.idfOrganization = i.idfOffice,
			pt_format.idfPerson =
				case
					when	p.idfPerson is not null and p_id.idfEmployee is null
						then	p.idfPerson
					when	p.idfPerson is null and p_id.idfEmployee is null
						then	pt_format.idfPerson
					else	null
				end
from		@PersonTable pt_format
inner join	fnInstitution('en') i
on			i.[name] = pt_format.strEmployeeOrganizationAbbreviation collate Cyrillic_General_CI_AS
inner join	tstSite s
on			s.idfOffice = i.idfOffice
			and s.intRowStatus = 0
left join	tlbPerson p
on			p.strFamilyName = pt_format.strAccountName collate Cyrillic_General_CI_AS
			and p.strFirstName = N'user' collate Cyrillic_General_CI_AS
			and p.idfInstitution = i.idfOffice
			and p.intRowStatus = 0
left join	tlbEmployee p_id
on			p_id.idfEmployee = IsNull(pt_format.idfPerson, -1000)
			and p_id.idfEmployee <> IsNull(p.idfPerson, -1000)

-- Generate new IDs for Employees
delete from	tstNewID where idfTable = 75520000000	-- tlbEmployee

insert into	tstNewID
(	idfTable,
	idfKey1,
	idfKey2
)
select		75520000000,	-- tlbEmployee
			pt_format.idfID,
			null
from		@PersonTable pt_format
where		pt_format.idfPerson is null

update		pt_format
set			pt_format.idfPerson = nId.[NewID]
from		@PersonTable pt_format
inner join	tstNewID nId
on			nId.idfTable = 75520000000	-- tlbEmployee
			and nId.idfKey1 = pt_format.idfID
where		pt_format.idfPerson is null

delete from	tstNewID where idfTable = 75520000000	-- tlbEmployee

-- Print number of records for Employees
select	@N = count(*)
from	@PersonTable pt_format
print	N'Number of employees to create/update: ' + cast(@N as nvarchar(20))

select		@N = count(*)
from		@PersonTable pt_format
inner join	tlbPerson p
on			p.idfPerson = pt_format.idfPerson
			and p.idfInstitution = pt_format.idfOrganization
			and p.intRowStatus = 0
print	N'Number of existing employees: ' + cast(@N as nvarchar(20))
print	N''

-- Insert records in the database for Employees
insert into	tlbEmployee
(	idfEmployee,
	idfsEmployeeType,
	rowguid,
	idfsSite,
	intRowStatus
)
select		pt_format.idfPerson,
			10023002,	-- Person
			NEWID(),
			s.idfsSite,
			0
from		@PersonTable pt_format
inner join	fnInstitution('en') i
on			i.idfOffice = pt_format.idfOrganization
inner join	tstSite s
on			s.idfOffice = pt_format.idfOrganization
			and s.intRowStatus = 0
left join	tlbEmployee e
on			e.idfEmployee = pt_format.idfPerson
where		pt_format.idfPerson is not null
			and e.idfEmployee is null
set	@N = @@rowcount
print		N'Inserted employees (tlbEmployee): ' + cast(@N as nvarchar(20))

insert into	tlbPerson
(	idfPerson,
	idfInstitution,
	rowguid,
	strFamilyName,
	strFirstName,
	intRowStatus
)
select		e.idfEmployee,
			i.idfOffice,
			NEWID(),
			pt_format.strAccountName,
			N'user',
			0
from		@PersonTable pt_format
inner join	fnInstitution('en') i
on			i.idfOffice = pt_format.idfOrganization
inner join	tstSite s
on			s.idfOffice = pt_format.idfOrganization
			and s.intRowStatus = 0
inner join	tlbEmployee e
on			e.idfEmployee = pt_format.idfPerson
left join	tlbPerson p
on			p.idfPerson = pt_format.idfPerson
where		pt_format.idfPerson is not null
			and p.idfPerson is null
set	@N = @@rowcount
print		N'Inserted employees (tlbPerson): ' + cast(@N as nvarchar(20))
print		N''

-- Update employees' IDs in User Table
update		ut_format
set			ut_format.idfPerson = p.idfPerson,
			ut_format.idfOrganization = i.idfOffice
from		@UserTable ut_format
inner join	@PersonTable pt_format
	inner join	fnInstitution('en') i
	on			i.idfOffice = pt_format.idfOrganization
	inner join	tstSite s
	on			s.idfOffice = pt_format.idfOrganization
				and s.intRowStatus = 0
	inner join	tlbEmployee e
	on			e.idfEmployee = pt_format.idfPerson
	inner join	tlbPerson p
	on			p.idfPerson = pt_format.idfPerson
on			pt_format.strEmployeeOrganizationAbbreviation = i.[name] collate Cyrillic_General_CI_AS
			and pt_format.strAccountName = ut_format.strAccountName collate Cyrillic_General_CI_AS

-- Update existing IDs for Logins on sites
update		ut_format
set			ut_format.idfsSite = s.idfsSite,
			ut_format.idfUserID =
				case
					when	ut.idfUserID is not null and ut_id.idfUserID is null
						then	ut.idfUserID
					when	ut.idfUserID is null and ut_id.idfUserID is null
						then	ut_format.idfUserID
					else	null
				end
from		@UserTable ut_format
inner join	fnInstitution('en') i
on			i.idfOffice = ut_format.idfOrganization
inner join	tstSite s
on			s.idfOffice = i.idfOffice
			and s.intRowStatus = 0
inner join	tlbPerson p
on			p.idfPerson = ut_format.idfPerson
left join	tstUserTable ut
on			ut.strAccountName = ut_format.strAccountName collate Cyrillic_General_CI_AS
			and ut.idfPerson = p.idfPerson
--			and ut.idfsSite = s.idfsSite
			and ut.intRowStatus = 0
left join	tstUserTable ut_id
on			ut_id.idfUserID = IsNull(ut_format.idfUserID, -1)
			and ut_id.idfUserID <> IsNull(ut.idfUserID, -1)


-- Generate new IDs for Logins on sites
delete from	tstNewID where idfTable = 76190000000	-- tstUserTable

insert into	tstNewID
(	idfTable,
	idfKey1,
	idfKey2
)
select		76190000000,	-- tstUserTable
			ut_format.idfID + 1,
			null
from		@UserTable ut_format
where		ut_format.idfUserID is null

update		ut_format
set			ut_format.idfUserID = nId.[NewID]
from		@UserTable ut_format
inner join	tstNewID nId
on			nId.idfTable = 76190000000	-- tstUserTable
			and nId.idfKey1 = ut_format.idfID + 1
where		ut_format.idfUserID is null

delete from	tstNewID where idfTable = 76190000000	-- tstUserTable

-- Print number of records for Logins on Sites
select	@N = count(*)
from	@PersonTable pt_format
print	N'Number of logins on sites to create/update: ' + cast(@N as nvarchar(20))

select		@N = count(*)
from		@UserTable ut_format
inner join	tlbPerson p
on			p.idfPerson = ut_format.idfPerson
			and p.idfInstitution = ut_format.idfOrganization
			and p.intRowStatus = 0
inner join	tstUserTable ut
on			ut.idfUserID = ut_format.idfUserID
			and ut.idfPerson = p.idfPerson
--			and ut.idfsSite = ut_format.idfsSite
print	N'Number of existing logins on sites: ' + cast(@N as nvarchar(20))
print	N''


-- Insert records to the database for Logins on sites
declare	@curDate	datetime
set	@curDate = getutcdate()

update		ut
set			ut.binPassword = hashbytes('SHA1', cast(ut_format.strPassword as nvarchar(500))),
			ut.datPasswordSet = @curDate,
			ut.datTryDate = null,
			ut.intTry = null,
			ut.idfsSite = s.idfsSite
from		@UserTable ut_format
inner join	tlbPerson p
on			p.idfPerson = ut_format.idfPerson
			and p.idfInstitution = ut_format.idfOrganization
			and p.intRowStatus = 0
inner join	tstSite s
on			s.idfsSite = ut_format.idfsSite
			and s.intRowStatus = 0
inner join	tstUserTable ut
on			ut.idfUserID = ut_format.idfUserID
			and ut.idfPerson = p.idfPerson
			and ut.idfsSite = ut_format.idfsSite
inner join	tstUserTableLocal ut_loc
on			ut_loc.idfUserID = ut.idfUserID
where		(	ut.binPassword <> hashbytes('SHA1', cast(ut_format.strPassword as nvarchar(500)))
				or	isnull(ut.datPasswordSet, '19000101') <> @curDate
				or	ut.datTryDate is not null
				or	ut.intTry is not null
				or	ut.idfsSite <> s.idfsSite
			)
set	@N = @@rowcount
print		N'Updated passwords and date password set (tstUserTable): ' + cast(@N as nvarchar(20))

insert into	tstUserTable
(	idfUserID,
	idfPerson,
	idfsSite,
	strAccountName,
	binPassword,
	rowguid,
	blnDisabled,
	PreferredLanguageID,
	datPasswordSet,
	datTryDate,
	intTry,
	intRowStatus,
	AuditCreateUser,
	AuditCreateDTM,
	AuditUpdateUser,
	AuditUpdateDTM
)
select		ut_format.idfUserID,
			p.idfPerson,
			s.idfsSite,
			ut_format.strAccountName,
			hashbytes('SHA1', cast(ut_format.strPassword as nvarchar(500))),
			NEWID(),
			0,
			10049003,
			@curDate,
			null,
			null,
			0,
			'DataTeamSA',
			GETDATE(),
			'DataTeamSA',
			GETDATE()
from		@UserTable ut_format
inner join	tlbPerson p
on			p.idfPerson = ut_format.idfPerson
			and p.idfInstitution = ut_format.idfOrganization
			and p.intRowStatus = 0
inner join	tstSite s
on			s.idfsSite = ut_format.idfsSite
			and s.intRowStatus = 0
left join	tstUserTable ut
on			ut.idfUserID = ut_format.idfUserID
where		ut_format.idfUserID is not null
			and ut.idfUserID is null
set	@N = @@rowcount
print		N'Inserted logins on sites (tstUserTable): ' + cast(@N as nvarchar(20))


delete		ut_loc
from		@UserTable ut_format
inner join	tlbPerson p
on			p.idfPerson = ut_format.idfPerson
			and p.idfInstitution = ut_format.idfOrganization
			and p.intRowStatus = 0
inner join	tstUserTable ut
on			ut.idfUserID = ut_format.idfUserID
			and ut.idfPerson = p.idfPerson
			and ut.idfsSite = ut_format.idfsSite
inner join	tstUserTableLocal ut_loc
on			ut_loc.idfUserID = ut.idfUserID
set	@N = @@rowcount
print		N'Deleted login attempts for correct users (tstUserTableLocal): ' + cast(@N as nvarchar(20))


-- Permissions
declare	@ObjectAccess table
(	idfID				bigint not null identity (1, 1),
	idfObjectAccess		bigint null,
	idfPerson			bigint not null,
	idfsSite			bigint not null default ((1)),
	idfsSystemFunction	bigint not null,
	idfsObjectOperation	bigint not null,
	idfsObjectType		bigint not null,
	intPermission		int not null default (2),
	primary key	(
		idfPerson asc,
--		idfsSite asc,
		idfsSystemFunction asc,
		idfsObjectOperation asc
				)
)

insert into	@ObjectAccess
(	idfObjectAccess,
	idfPerson,
	idfsSite,
	idfsSystemFunction,
	idfsObjectOperation,
	idfsObjectType
)
select		oa.idfObjectAccess,
			p.idfPerson,
			1,	-- default site
			sf.idfsSystemFunction,
			br_oo.idfsBaseReference,
			sf.idfsObjectType
from		trtSystemFunction sf
inner join	trtBaseReference br_sf
on			br_sf.idfsBaseReference = sf.idfsSystemFunction
			and br_sf.intRowStatus = 0
inner join	trtObjectTypeToObjectOperation oo_to_oo
on			oo_to_oo.idfsObjectType = sf.idfsObjectType
inner join	trtBaseReference br_oo
on			br_oo.idfsBaseReference = oo_to_oo.idfsObjectOperation
			and br_oo.intRowStatus = 0
inner join	@UserTable ut_format
on			ut_format.idfID is not null
inner join	tlbPerson p
on			p.idfPerson = ut_format.idfPerson
			and p.idfInstitution = ut_format.idfOrganization
			and p.intRowStatus = 0
inner join	tstUserTable ut
on			ut.idfUserID = ut_format.idfUserID
			and ut.idfPerson = p.idfPerson
--			and ut.idfsSite = ut_format.idfsSite
left join	tstObjectAccess oa
on			oa.idfActor = p.idfPerson
			and oa.idfsOnSite = 1	-- default site
			and oa.idfsObjectID = sf.idfsSystemFunction
			and oa.idfsObjectOperation = br_oo.idfsBaseReference
			and oa.intRowStatus = 0
where		sf.intRowStatus = 0
			and sf.idfsSystemFunction <> 10094058	-- Use Simplified Human Case Report Form
set	@N = @@rowcount
print		N'Permissions to sys. functions on sites to create/update: ' + cast(@N as nvarchar(20))


-- Generate IDs for permissions
delete from	tstNewID where idfTable = 76160000000	-- tstObjectAccess

insert into	tstNewID
(	idfTable,
	idfKey1,
	idfKey2
)
select		76160000000,	-- tstObjectAccess
			oa_format.idfID,
			null
from		@ObjectAccess oa_format
where		oa_format.idfObjectAccess is null

update		oa_format
set			oa_format.idfObjectAccess = nId.[NewID]
from		@ObjectAccess oa_format
inner join	tstNewID nId
on			nId.idfTable = 76160000000	-- tstObjectAccess
			and nId.idfKey1 = oa_format.idfID
where		oa_format.idfObjectAccess is null

delete from	tstNewID where idfTable = 776160000000	-- tstObjectAccess

-- Insert/update/delete permissions
delete		oa
from		tstObjectAccess oa
inner join	@UserTable ut_format
	inner join	tlbPerson p
	on			p.idfPerson = ut_format.idfPerson
				and p.idfInstitution = ut_format.idfOrganization
				and p.intRowStatus = 0
	inner join	tstUserTable ut
	on			ut.idfUserID = ut_format.idfUserID
				and ut.idfPerson = p.idfPerson
--				and ut.idfsSite = ut_format.idfsSite
on			p.idfPerson = oa.idfActor
--			and ut.idfsSite = oa.idfsOnSite
left join	@ObjectAccess oa_format
on			oa_format.idfObjectAccess = oa.idfObjectAccess
where		oa_format.idfID is null
set	@N = @@rowcount
print		N'Delete permissions to sys. functions of correct users on specified sites (tstObjectAccess): ' + cast(@N as nvarchar(20))

update		oa
set			oa.intPermission = oa_format.intPermission,
			oa.intRowStatus = 0
from		tstObjectAccess	oa
inner join	@UserTable ut_format
	inner join	tlbPerson p
	on			p.idfPerson = ut_format.idfPerson
				and p.idfInstitution = ut_format.idfOrganization
				and p.intRowStatus = 0
	inner join	tstUserTable ut
	on			ut.idfUserID = ut_format.idfUserID
				and ut.idfPerson = p.idfPerson
--				and ut.idfsSite = ut_format.idfsSite
on			p.idfPerson = oa.idfActor
--			and ut.idfsSite = oa.idfsOnSite
inner join	@ObjectAccess oa_format
on			oa_format.idfObjectAccess = oa.idfObjectAccess
where		(	IsNull(oa.intPermission, -1) <> oa_format.intPermission
				or	oa.intRowStatus <> 0
			)
set	@N = @@rowcount
print		N'Updated permissions to sys. functions of correct users on specified sites (tstObjectAccess): ' + cast(@N as nvarchar(20))

insert into	tstObjectAccess
(	idfObjectAccess,
	idfActor,
	rowguid,
	idfsObjectID,
	idfsObjectOperation,
	idfsObjectType,
	idfsOnSite,
	intPermission,
	intRowStatus
)
select		oa_format.idfObjectAccess,
			oa_format.idfPerson,
			NEWID(),
			oa_format.idfsSystemFunction,
			oa_format.idfsObjectOperation,
			oa_format.idfsObjectType,
			oa_format.idfsSite,
			oa_format.intPermission,
			0
from		@ObjectAccess oa_format
left join	tstObjectAccess oa
on			oa.idfObjectAccess = oa_format.idfObjectAccess
where		oa_format.idfObjectAccess is not null
			and oa.idfObjectAccess is null
set	@N = @@rowcount
print		N'Inserted permissions to sys. functions of correct users on specified sites (tstObjectAccess): ' + cast(@N as nvarchar(20))

---- Script for filling User Table with identifiers
--select		N'insert into @UserTable (idfOrganization, idfPerson, idfUserID, idfsSite, strEmployeeOrganizationAbbreviation, strAccountName, strPassword, strSiteAbbreviation) values (' +
--cast(i.idfOffice as nvarchar(20)) + N', ' +
--cast(p.idfPerson as nvarchar(20)) + N', ' +
--cast(ut.idfUserID as nvarchar(20)) + N', ' +
--cast(s.idfsSite as nvarchar(20)) + N', ' +
--N'N''' + replace(i.[name], N'''', N'''''') + N''', ' +
--N'''' + replace(ut.strAccountName, N'''', N'''''') + N''', ' +
--N'''' + replace(ut_format.strPassword, N'''', N'''''') + N''', ' +
--N'N''' + replace(i_s.[name], N'''', N'''''') + N''')'
--from		@UserTable ut_format
--inner join	tstUserTable ut
--on			ut.idfUserID = ut_format.idfUserID
--			and ut.idfsSite = ut_format.idfsSite
--			and ut.intRowStatus = 0
--inner join	fnInstitution('en') i
--on			i.idfOffice = ut_format.idfOrganization
--inner join	tlbPerson p
--on			p.idfPerson = ut_format.idfPerson
--			and p.idfInstitution = i.idfOffice
--			and p.intRowStatus = 0
--inner join	tstSite s
--on			s.idfsSite = ut.idfsSite
--			and s.intRowStatus = 0
--inner join	fnInstitution('en') i_s
--on			i_s.idfOffice = s.idfOffice


print	''
print	'----------------------------------------------------------'
print	'Update enable status and password set date of all accounts'
print	''

declare	@datPasswordSet datetime
set	@datPasswordSet = getdate()

update	tstUserTable
set		datPasswordSet = @datPasswordSet,
		blnDisabled = 0
where	intRowStatus = 0
		and (	datPasswordSet <> @datPasswordSet
				or blnDisabled <> 0
			)
set	@N = @@rowcount
print	'Updated accounts (tstUserTable): ' + cast(@N as nvarchar(20))

delete from	tstUserTableLocal
set	@N = @@rowcount
print	'Deleted information about login attemps for accounts (tstUserTableLocal): ' + cast(@N as nvarchar(20))


IF @@ERROR <> 0
	ROLLBACK TRAN
ELSE
	COMMIT TRAN

set XACT_ABORT off
set nocount off

SET ANSI_NULLS on
SET QUOTED_IDENTIFIER on
GO

ALTER	function [dbo].[fnTriggersWork] ()
returns bit
as
begin
return 1 --0
end
GO


