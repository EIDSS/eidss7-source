-- This script clears customizable database values

DECLARE @sql nvarchar(max) = N'';

;WITH x AS 
(
  SELECT DISTINCT obj = 
      QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' 
    + QUOTENAME(OBJECT_NAME(parent_object_id)) 
  FROM sys.foreign_keys
)
SELECT @sql += N'ALTER TABLE ' + obj + N' NOCHECK CONSTRAINT ALL;
' FROM x;

EXEC sys.sp_executesql @sql;



exec sp_msforeachtable 'ALTER TABLE ? DISABLE TRIGGER all';

set nocount on
set XACT_ABORT on

BEGIN TRAN

declare @CustomizationPackage	nvarchar(200)
set	@CustomizationPackage = N'Georgia'

declare	@AdminInfoCustomizationPackage	varchar(10)
set @AdminInfoCustomizationPackage = 'Georgia'


declare	@idfAdminInfoCustomizationPackage	bigint
declare	@AdminInfoCountryHASC	varchar(10)
declare	@AdminInfoCountry bigint
select		@AdminInfoCountryHASC = c.strHASC,
			@AdminInfoCountry = c.idfsCountry,
			@idfAdminInfoCustomizationPackage = cp.idfCustomizationPackage
from		tstCustomizationPackage cp
inner join	gisCountry c
on			c.idfsCountry = cp.idfsCountry
			and c.intRowStatus = 0
inner join	fnGisReference('en', 19000001) r_c	-- Country
on			r_c.idfsReference = c.idfsCountry
where		cp.strCustomizationPackageName = @AdminInfoCustomizationPackage

declare	@DeleteHistoricalRecordsMarkedAsDeleted	bit
set	@DeleteHistoricalRecordsMarkedAsDeleted = 1	-- 1 = Yes, 0 = No

declare	@DeletionFlag	int	-- 0 or 1 = all integer flags, except 0; 
							-- other integer values (..; -2; -1; 2; 3; 4; ...) = specified flag only
set	@DeletionFlag = 1

if	@DeletionFlag = 0
	set	@DeletionFlag = 1

-- Select country
declare	@idfCustomizationPackage	bigint
declare	@Country		bigint
declare	@CountryHASC	varchar(10)
select		@Country = c.idfsCountry,
			@CountryHASC = c.strHASC,
			@idfCustomizationPackage = cp.idfCustomizationPackage
from		gisCountry c
inner join	fnGisReference('en', 19000001) r_c	-- Country
on			r_c.idfsReference = c.idfsCountry
inner join	tstCustomizationPackage cp
on			cp.idfsCountry = c.idfsCountry
where		cp.strCustomizationPackageName = @CustomizationPackage
			and c.intRowStatus = 0

if	(@CustomizationPackage <> 'DTRA')
begin
	set	@AdminInfoCountryHASC = @CountryHASC
	set	@AdminInfoCountry = @Country
	set	@AdminInfoCustomizationPackage = @CustomizationPackage
	set	@idfAdminInfoCustomizationPackage = @idfCustomizationPackage
end


declare	@drop_cmd	nvarchar(4000)

-- Drop temporary tables
if Object_ID('tempdb..#LogTable') is not null
begin
	set	@drop_cmd = N'drop table #LogTable'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#AVRObject_To_MarkAsDel') is not null
begin
	set	@drop_cmd = N'drop table #AVRObject_To_MarkAsDel'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#AVRField_To_MarkAsDel') is not null
begin
	set	@drop_cmd = N'drop table #AVRField_To_MarkAsDel'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#BR_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #BR_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#AggrMatrixPrefix') is not null
begin
	set	@drop_cmd = N'drop table #AggrMatrixPrefix'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#O_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #O_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#Person_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #Person_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#User_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #User_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#EmployeeGroup_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #EmployeeGroup_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#Template_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #Template_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#Section_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #Section_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#Parameter_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #Parameter_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#ParameterType_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #ParameterType_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#Rule_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #Rule_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#P_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #P_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#PT_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #PT_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#L_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #L_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#R_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #R_To_Del'
	execute sp_executesql @drop_cmd
end


create table	#LogTable
(	idfID		bigint not null identity (1, 1) primary key,
	datLog		datetime not null default (getdate()),
	strMessage	nvarchar(3000) collate database_default null
)

declare	@N	bigint
set	@N = 0

insert into	#LogTable (strMessage)
select	N'Delete customized reference values and flexible forms from the database'

insert into	#LogTable (strMessage)
select	N'Delete customized administrative info from the database except default settings (site 1, predefined user groups)'

insert into	#LogTable (strMessage)
select	N'-------------------------------------------------'


-- delete events and notifications
insert into	#LogTable (strMessage)
select	N'Delete events and notifications'

delete		lcc
from		tstLocalConnectionContext lcc
where		lcc.idfEventID is not null
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Connection context with specified events (tstLocalConnectionContext): ' + cast(@N as nvarchar(20))

delete from	tstEventSubscription
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Site alerts'' subscriptions (tstEventSubscription): ' + cast(@N as nvarchar(20))

delete from	tstEventClient
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Events on the sites (tstEventActive): ' + cast(@N as nvarchar(20))

delete from	tstEvent
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Events on the sites (tstEventClient): ' + cast(@N as nvarchar(20))

delete from	tstEventActive
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Events on the sites (tstEvent): ' + cast(@N as nvarchar(20))

delete from	tflNotificationFiltered
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Filtration records linked to the notifications (tflNotificationFiltered): ' + cast(@N as nvarchar(20))

delete from	tstNotificationStatus
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Status of the notifications (tstNotificationStatus): ' + cast(@N as nvarchar(20))

delete from	tstNotification
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Notifications under the filtration rules (tstNotification): ' + cast(@N as nvarchar(20))

delete from	tstNotificationShared
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    General notifications (tstNotificationShared): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

-- delete data audit
insert into	#LogTable (strMessage)
select	N'Delete data audit records'

delete from	tauDataAuditDetailRestore
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Detailed info of restored objects from the data audit (tauDataAuditDetailRestore): ' + cast(@N as nvarchar(20))

delete from tauDataAuditDetailCreate
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Detailed info of the objects'' creation (tauDataAuditDetailCreate): ' + cast(@N as nvarchar(20))

delete from	tauDataAuditDetailUpdate
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Detailed info of the objects'' updates (tauDataAuditDetailUpdate): ' + cast(@N as nvarchar(20))

delete from tauDataAuditDetailDelete
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Detailed info of the objects'' deletion (tauDataAuditDetailDelete): ' + cast(@N as nvarchar(20))


delete lcc from	tstLocalConnectionContext lcc
inner join tauDataAuditEvent daue on
	daue.idfDataAuditEvent = lcc.idfDataAuditEvent
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Connection context with specified data audit event (tstLocalConnectionContext): ' + cast(@N as nvarchar(20))


delete sa from tstSecurityAudit sa
inner join tauDataAuditEvent daue on
	daue.idfDataAuditEvent = sa.idfDataAuditEvent
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Records of security log linked to data audit events (tstSecurityAudit): ' + cast(@N as nvarchar(20))


delete from tflDataAuditEventFiltered
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Filtration records linked to data audit events (tflDataAuditEventFiltered): ' + cast(@N as nvarchar(20))


delete from tauDataAuditEvent
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Data audit events (tauDataAuditEvent): ' + cast(@N as nvarchar(20))

delete from tstSecurityAudit
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Records of security log (tstSecurityAudit): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

-- delete WHO FF references for other countries
insert into	#LogTable (strMessage)
select	N'Delete links from WHO export parameters to FF parameters'

delete	deffr
from	tdeDataExportFFReference deffr
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from WHO export parameters to FF parameters (tdeDataExportFFReference): ' + cast(@N as nvarchar(20))


insert into	#LogTable (strMessage)
select	N''

-- delete aggregate matrixes from other countries
insert into	#LogTable (strMessage)
select	N'Delete aggregate matrixes with their content'
/*TODO: remove--
create table	#AggrMatrixPrefix
(	idfID				bigint not null identity(1, 1) primary key,
	strCountryHASC		nvarchar(100) collate database_default not null,
	strCP				nvarchar(100) collate database_default not null,
	strAggrMatrixPrefix	nvarchar(100) collate database_default not null
)

	insert into	#AggrMatrixPrefix(strAggrMatrixPrefix, strCP, strCountryHASC)	values	(N'1', @CustomizationPackage, @CountryHASC)
	insert into	#AggrMatrixPrefix(strAggrMatrixPrefix, strCP, strCountryHASC)	values	(N'Armenia', @CustomizationPackage, @CountryHASC)
	insert into	#AggrMatrixPrefix(strAggrMatrixPrefix, strCP, strCountryHASC)	values	(N'Azerbaijan', @CustomizationPackage, @CountryHASC)
	insert into	#AggrMatrixPrefix(strAggrMatrixPrefix, strCP, strCountryHASC)	values	(N'Georgia', @CustomizationPackage, @CountryHASC)
	insert into	#AggrMatrixPrefix(strAggrMatrixPrefix, strCP, strCountryHASC)	values	(N'Kazakh', @CustomizationPackage, @CountryHASC)
	insert into	#AggrMatrixPrefix(strAggrMatrixPrefix, strCP, strCountryHASC)	values	(N'Iraq', @CustomizationPackage, @CountryHASC)
	insert into	#AggrMatrixPrefix(strAggrMatrixPrefix, strCP, strCountryHASC)	values	(N'Ukrain', @CustomizationPackage, @CountryHASC)
	insert into	#AggrMatrixPrefix(strAggrMatrixPrefix, strCP, strCountryHASC)	values	(N'Tanzania', @CustomizationPackage, @CountryHASC)
	insert into	#AggrMatrixPrefix(strAggrMatrixPrefix, strCP, strCountryHASC)	values	(N'Lao', @CustomizationPackage, @CountryHASC)
	insert into	#AggrMatrixPrefix(strAggrMatrixPrefix, strCP, strCountryHASC)	values	(N'Vietnam', @CustomizationPackage, @CountryHASC)
	insert into	#AggrMatrixPrefix(strAggrMatrixPrefix, strCP, strCountryHASC)	values	(N'Thai', @CustomizationPackage, @CountryHASC)
*/
delete		ada
from		tlbAggrDiagnosticActionMTX ada
inner join	tlbAggrMatrixVersionHeader amvh
on			amvh.idfVersion = ada.idfVersion
/*TODO: remove--
where		exists	(
				select	*
				from	#AggrMatrixPrefix amp
				where	amvh.MatrixName like amp.strAggrMatrixPrefix + N'%' collate Cyrillic_General_CI_AS
						and amp.strCP = @CustomizationPackage collate Cyrillic_General_CI_AS
					)
			or	(	amvh.intRowStatus <> 0
					and @DeleteHistoricalRecordsMarkedAsDeleted = 1
					and (	amvh.intRowStatus = @DeletionFlag
							or	@DeletionFlag = 1
						)
				)
			*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of aggregate matrixes Diagnostic Investigations (tlbAggrDiagnosticActionMTX): ' + cast(@N as nvarchar(20))

delete		ahc
from		tlbAggrHumanCaseMTX ahc
inner join	tlbAggrMatrixVersionHeader amvh
on			amvh.idfVersion = ahc.idfVersion
/*TODO: remove--
where		exists	(
				select	*
				from	#AggrMatrixPrefix amp
				where	amvh.MatrixName like amp.strAggrMatrixPrefix + N'%' collate Cyrillic_General_CI_AS
						and amp.strCP = @CustomizationPackage collate Cyrillic_General_CI_AS
					)
			or	(	amvh.intRowStatus <> 0
					and @DeleteHistoricalRecordsMarkedAsDeleted = 1
					and (	amvh.intRowStatus = @DeletionFlag
							or	@DeletionFlag = 1
						)
				)
				*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Rows of aggregate matrixes Human Aggregate Case (tlbAggrHumanCaseMTX): ' + cast(@N as nvarchar(20))

delete		apa
from		tlbAggrProphylacticActionMTX apa
inner join	tlbAggrMatrixVersionHeader amvh
on			amvh.idfVersion = apa.idfVersion
/*TODO: remove--
where		exists	(
				select	*
				from	#AggrMatrixPrefix amp
				where	amvh.MatrixName like amp.strAggrMatrixPrefix + N'%' collate Cyrillic_General_CI_AS
						and amp.strCP = @CustomizationPackage collate Cyrillic_General_CI_AS
					)
			or	(	amvh.intRowStatus <> 0
					and @DeleteHistoricalRecordsMarkedAsDeleted = 1
					and (	amvh.intRowStatus = @DeletionFlag
							or	@DeletionFlag = 1
						)
				)
*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of aggregate matrixes Prophylactic Measures (tlbAggrProphylacticActionMTX): ' + cast(@N as nvarchar(20))

delete		asa
from		tlbAggrSanitaryActionMTX asa
inner join	tlbAggrMatrixVersionHeader amvh
on			amvh.idfVersion = asa.idfVersion
/*TODO: remove--
where		exists	(
				select	*
				from	#AggrMatrixPrefix amp
				where	amvh.MatrixName like amp.strAggrMatrixPrefix + N'%' collate Cyrillic_General_CI_AS
						and amp.strCP = @CustomizationPackage collate Cyrillic_General_CI_AS
					)
			or	(	amvh.intRowStatus <> 0
					and @DeleteHistoricalRecordsMarkedAsDeleted = 1
					and (	amvh.intRowStatus = @DeletionFlag
							or	@DeletionFlag = 1
						)
				)
*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Rows of aggregate matrixes Sanitary Measures (tlbAggrSanitaryActionMTX): ' + cast(@N as nvarchar(20))


delete		avc
from		tlbAggrVetCaseMTX avc
inner join	tlbAggrMatrixVersionHeader amvh
on			amvh.idfVersion = avc.idfVersion
/*TODO: remove--
where		exists	(
				select	*
				from	#AggrMatrixPrefix amp
				where	amvh.MatrixName like amp.strAggrMatrixPrefix + N'%' collate Cyrillic_General_CI_AS
						and amp.strCP = @CustomizationPackage collate Cyrillic_General_CI_AS
					)
			or	(	amvh.intRowStatus <> 0
					and @DeleteHistoricalRecordsMarkedAsDeleted = 1
					and (	amvh.intRowStatus = @DeletionFlag
							or	@DeletionFlag = 1
						)
				)
*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of aggregate matrixes Vet Aggregate Case (tlbAggrVetCaseMTX): ' + cast(@N as nvarchar(20))

delete		amvh
from		tlbAggrMatrixVersionHeader amvh
/*TODO: remove--
where		exists	(
				select	*
				from	#AggrMatrixPrefix amp
				where	amvh.MatrixName like amp.strAggrMatrixPrefix + N'%' collate Cyrillic_General_CI_AS
						and amp.strCP = @CustomizationPackage collate Cyrillic_General_CI_AS
					)
			or	(	amvh.intRowStatus <> 0
					and @DeleteHistoricalRecordsMarkedAsDeleted = 1
					and (	amvh.intRowStatus = @DeletionFlag
							or	@DeletionFlag = 1
						)
				)
*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Aggregate matrixes (tlbAggrMatrixVersionHeader): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''


-- Define table with references to delete
create table	#BR_To_Del
(	idfID					bigint not null identity (1, 1),
	idfsBaseReference		bigint not null primary key,
	blnIsOfficeAttribute	bit not null default (0),
	strDescription			nvarchar(3000) collate database_default null
)

-- Update country attribute in offices
insert into	#LogTable (strMessage)
select	N'Update country attribute in organizations and departments'
/*TODO: remove--
update		o
set			o.idfCustomizationPackage = s.idfCustomizationPackage
from		tlbOffice o
inner join	tstSite s
on			s.idfOffice = o.idfOffice
			and s.intRowStatus = 0
--Comment for historical records--where		o.intRowStatus = 0
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Customization Package attribute of organizations that are sites by means of site relation to customization package (tlbOffice): ' + cast(@N as nvarchar(20))

update		gl
set			gl.idfsCountry = cp.idfsCountry
from		tlbOffice o
inner join	tlbGeoLocationShared gl
on			gl.idfGeoLocationShared = o.idfLocation
			--Comment for historical records--and gl.intRowStatus = 0
inner join	tstSite s
on			s.idfOffice = o.idfOffice
			and s.intRowStatus = 0
inner join	tstCustomizationPackage cp
on			cp.idfCustomizationPackage = s.idfCustomizationPackage
--Comment for historical records--where		o.intRowStatus = 0
set	@N = @@rowcount
*/

insert into	#LogTable (strMessage)
select	N'    Country attribute of the addresses of the organizations that are sites by means of site country (tlbGeoLocationShared): ' + cast(@N as nvarchar(20))

-- Disposition Office
update		o
set			o.idfCustomizationPackage = @idfAdminInfoCustomizationPackage
from		tlbOffice o
where		o.idfOffice = -1		-- Disposition
--Comment for historical records--			and o.intRowStatus = 0
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Set Customization Package attribute of the system organization [Disposition] to the value [' + @AdminInfoCustomizationPackage + '] (tlbOffice): ' + cast(@N as nvarchar(20))

update		gl
set			gl.idfsCountry = @AdminInfoCountry
from		tlbOffice o
inner join	tlbGeoLocationShared gl
on			gl.idfGeoLocationShared = o.idfLocation
			--Comment for historical records--and gl.intRowStatus = 0
where		o.idfOffice = -1		-- Disposition
--Comment for historical records--			and o.intRowStatus = 0
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Set country attribute of the addresses of the system organization [Disposition] to the value with HASC [' + @AdminInfoCountryHASC + '] (tlbGeoLocationShared): ' + cast(@N as nvarchar(20))


insert into	#LogTable (strMessage)
select	N''

-- Add office abbreviations and names to deleted BR list 
create table	#O_To_Del
(	idfOffice			bigint not null,
	idfDepartment		bigint null,
	idfsBaseReference	bigint not null primary key
)

insert into	#O_To_Del
(	idfOffice,
	idfDepartment,
	idfsBaseReference
)
select	o.idfOffice,
		null,
		o.idfsOfficeName
from	tlbOffice o
/*TODO: remove--
where	(	o.intRowStatus <> 0
			and @DeleteHistoricalRecordsMarkedAsDeleted = 1
			and (	o.intRowStatus = @DeletionFlag
					or	@DeletionFlag = 1
				)
		)
*/
where	o.idfOffice <> -1 /*Disposition*/

insert into	#O_To_Del
(	idfOffice,
	idfDepartment,
	idfsBaseReference
)
select		d.idfOrganization,
			d.idfDepartment,
			d.idfsDepartmentName
from		tlbDepartment d
/*TODO: remove--
inner join	tlbOffice o
on			o.idfOffice = d.idfOrganization
left join	#O_To_Del o_del
on			o_del.idfsBaseReference = d.idfsDepartmentName
where		(	o.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	o.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
			and o_del.idfsBaseReference is null
*/
left join	#O_To_Del o_del
on			o_del.idfsBaseReference = d.idfsDepartmentName
where		d.idfOrganization <> -1 /*Disposition*/
			and o_del.idfsBaseReference is null


/*TODO: remove--
insert into	#O_To_Del
(	idfOffice,
	idfDepartment,
	idfsBaseReference
)
select		o.idfOffice,
			d.idfDepartment,
			d.idfsDepartmentName
from		tlbDepartment d
inner join	tlbOffice o
on			o.idfOffice = d.idfOrganization
left join	#O_To_Del o_del
on			o_del.idfsBaseReference = d.idfsDepartmentName
where		(	d.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	d.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
			and o_del.idfsBaseReference is null
*/


insert into	#O_To_Del
(	idfOffice,
	idfDepartment,
	idfsBaseReference
)
select		o.idfOffice,
			null,
			o.idfsOfficeAbbreviation
from		tlbOffice o
left join	#O_To_Del o_del
on			o_del.idfsBaseReference = o.idfsOfficeAbbreviation
/*TODO: remove--
where		(	o.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	o.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
			and o.idfsOfficeAbbreviation is not null
			and o_del.idfsBaseReference is null
*/
where		o.idfOffice <> -1 /*Disposition*/
			and o_del.idfsBaseReference is null


/*TODO: remove--
insert into	#O_To_Del
(	idfOffice,
	idfDepartment,
	idfsBaseReference
)
select		o.idfOffice,
			null,
			o.idfsOfficeName
from		tlbOffice o
left join	#O_To_Del o_del
on			o_del.idfsBaseReference = o.idfsOfficeName
where		IsNull(o.idfCustomizationPackage , -1) <> @idfAdminInfoCustomizationPackage
			and o_del.idfsBaseReference is null

insert into	#O_To_Del
(	idfOffice,
	idfDepartment,
	idfsBaseReference
)
select		o.idfOffice,
			null,
			d.idfsDepartmentName
from		tlbDepartment d
inner join	tlbOffice o
on			o.idfOffice = d.idfOrganization
left join	#O_To_Del o_del
on			o_del.idfsBaseReference = d.idfsDepartmentName
where		IsNull(o.idfCustomizationPackage , -1) <> @idfAdminInfoCustomizationPackage
			and o_del.idfsBaseReference is null

insert into	#O_To_Del
(	idfOffice,
	idfDepartment,
	idfsBaseReference
)
select distinct
			o.idfOffice,
			null,
			o.idfsOfficeAbbreviation
from		tlbOffice o
left join	#O_To_Del o_del
on			o_del.idfsBaseReference = o.idfsOfficeAbbreviation
where		IsNull(o.idfCustomizationPackage , -1) <> @idfAdminInfoCustomizationPackage
			and o_del.idfsBaseReference is null
			and o.idfsOfficeAbbreviation is not null
*/

insert into	#LogTable (strMessage)
select	N'Abbreviations and full names of organizations and departments to delete: '

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

insert into	#BR_To_Del
(	idfsBaseReference,
	blnIsOfficeAttribute,
	strDescription
)
select		br.idfsBaseReference,
			1 as blnIsOfficeAttribute,
			case
				when	o_del.idfDepartment is null
						and br.idfsReferenceType = 19000045	-- Organization abbreviation
					then	N'- Organization [' + replace(IsNull(i.[name], N'*'), N'''', N'''''') + N']: abbreviation [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'

				when	o_del.idfDepartment is null
						and br.idfsReferenceType = 19000046	-- Organization full name
					then	N'- Organization [' + replace(IsNull(i.[name], N'*'), N'''', N'''''') + N']: full name [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'

				when	o_del.idfDepartment is not null
						and br.idfsReferenceType in (19000046, 19000164)	-- Department name
					then	N'- Organization [' + replace(IsNull(i.[name], N'*'), N'''', N'''''') + N']: department name [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'

				when	o_del.idfDepartment is not null
						and br.idfsReferenceType = 19000045	-- Organization abbreviation
					then	N'- Organization [' + replace(IsNull(i.[name], N'*'), N'''', N'''''') + N']: department abbreviation [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'
		
				else	N'- ' + replace(IsNull(rt.strReferenceTypeName, N'*'), N'''', N'''''') + N': [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'

			end as strDescription

from		#O_To_Del o_del
inner join	trtBaseReference br
on			br.idfsBaseReference = o_del.idfsBaseReference
inner join	trtReferenceType rt	-- Reference Type Name
on			rt.idfsReferenceType = br.idfsReferenceType
left join	tlbOffice o
on			o.idfOffice = o_del.idfOffice
left join	fnInstitutionRepair('en') i
on			i.idfOffice = o_del.idfOffice
order by	i.[name], o_del.idfOffice, o_del.idfDepartment, br.idfsReferenceType, br.strDefault

insert into	#LogTable (strMessage)
select		br_del.strDescription
from		#BR_To_Del br_del
order by	br_del.idfID

declare	@FirstNumOfRef_To_Del	bigint
select	@FirstNumOfRef_To_Del = max(idfID)
from	#BR_To_Del

if	@FirstNumOfRef_To_Del is null
begin
	set	@FirstNumOfRef_To_Del = 0
end

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

insert into	#LogTable (strMessage)
select	N''

insert into	#LogTable (strMessage)
select	N'Delete administrative info'

-- delete offices with employees (with object access, users and related info), addresses and mark sites as deleted

-- Define tables with employee groups, employees and users to delete
create table	#Person_To_Del
(	idfPerson	bigint not null primary key
)

create table	#User_To_Del
(	idfUserID	bigint not null primary key
)

create table	#EmployeeGroup_To_Del
(	idfEmployeeGroup	bigint not null primary key
)

insert into	#Person_To_Del (idfPerson)
select		p.idfPerson
from		tlbPerson p
/*TODO:remove--
left join	tlbOffice o
on			o.idfOffice = p.idfInstitution
			and (	o.intRowStatus = 0
					or	@DeleteHistoricalRecordsMarkedAsDeleted = 0 -- Add for historical records
				)
where		o.idfOffice is null

insert into	#Person_To_Del (idfPerson)
select		p.idfPerson
from		tlbPerson p
left join	tlbOffice o
on			o.idfOffice = p.idfInstitution
			and IsNull(o.idfCustomizationPackage , -1) = @idfAdminInfoCustomizationPackage
			--Comment for historical records--and o.intRowStatus = 0
left join	#Person_To_Del p_del
on			p_del.idfPerson = p.idfPerson
where		o.idfOffice is null
			and p_del.idfPerson is null
*/

insert into	#Person_To_Del (idfPerson)
select		e.idfEmployee
from		tlbEmployee e
left join	tlbPerson p
on			p.idfPerson = e.idfEmployee
left join	#Person_To_Del p_del
on			p_del.idfPerson = e.idfEmployee
/*TODO:remove--
where		(	(	e.intRowStatus <> 0
					and @DeleteHistoricalRecordsMarkedAsDeleted = 1
					and (	e.intRowStatus = @DeletionFlag
							or	@DeletionFlag = 1
						)
				)
				or	p.idfPerson is null
			)
			and (	e.idfsEmployeeType = 10023002	-- Person
					or	p.idfPerson is not null
				)
			and p_del.idfPerson is null
*/
where		(	e.idfsEmployeeType = 10023002	-- Person
				or	p.idfPerson is not null
			)
			and p_del.idfPerson is null


insert into	#User_To_Del (idfUserID)
select		ut.idfUserID
from		tstUserTable ut
inner join	#Person_To_Del p_del
on			p_del.idfPerson = ut.idfPerson


insert into	#User_To_Del (idfUserID)
select		ut.idfUserID
from		tstUserTable ut
left join	tlbPerson p
on			p.idfPerson = ut.idfPerson
left join	#User_To_Del u_del
on			u_del.idfUserID = ut.idfUserID
/*TODO:remove--
where		(	(	ut.intRowStatus <> 0
					and @DeleteHistoricalRecordsMarkedAsDeleted = 1
					and (	ut.intRowStatus = @DeletionFlag
							or	@DeletionFlag = 1
						)
				)
				or	p.idfPerson is null
			)
			and u_del.idfUserID is null
*/
where		p.idfPerson is null
			and u_del.idfUserID is null

/*TODO:remove--
insert into	#User_To_Del (idfUserID)
select		ut.idfUserID
from		tstUserTable ut
left join	tstSite s
on			s.idfsSite = ut.idfsSite
			and s.intRowStatus = 0
left join	#User_To_Del u_del
on			u_del.idfUserID = ut.idfUserID
where		s.idfsSite is null
			and u_del.idfUserID is null

insert into	#User_To_Del (idfUserID)
select		ut.idfUserID
from		tstUserTable ut
left join	tstSite s
on			s.idfsSite = ut.idfsSite
			and IsNull(s.idfCustomizationPackage , -1) = @idfAdminInfoCustomizationPackage
			and s.intRowStatus = 0
left join	#User_To_Del u_del
on			u_del.idfUserID = ut.idfUserID
where		s.idfsSite is null
			and u_del.idfUserID is null
*/

insert into	#EmployeeGroup_To_Del (idfEmployeeGroup)
select distinct
			eg.idfEmployeeGroup
from		tlbEmployeeGroup eg
/*TODO:remove--
left join	trtBaseReference br
on			br.idfsBaseReference = eg.idfsEmployeeGroupName
			and br.intRowStatus = 0	-- do not belong to historical records
where		br.idfsBaseReference is null
			and eg.idfEmployeeGroup <> -1	-- default
*/
where		eg.idfEmployeeGroup > 0 -- non-default and unpredefined
			or eg.idfEmployeeGroup not in
			(	 -501, --Administrator
				 -502, --Chief Epidemiologist
				 -503, --Chief Epizootologist
				 -504, --Chief of Laboratory (Human)
				 -505, --Chief of Laboratory (Vet)
				 -1, --Default
				 -506, --Default Role
				 -507, --Entomologist
				 -508, --Epidemiologist
				 -509, --Epizootologist
				 -510, -- Lab Technician (Human)
				 -511, --Lab Technician (Vet)
				 -512  --Notifiers
			)

/*TODO:remove--
insert into	#EmployeeGroup_To_Del (idfEmployeeGroup)
select distinct
			eg.idfEmployeeGroup
from		tlbEmployeeGroup eg
inner join	trtBaseReferenceToCP br_to_c
on			br_to_c.idfsBaseReference = eg.idfsEmployeeGroupName
left join	(
	trtBaseReference br
	inner join	trtBaseReferenceToCP br_to_c_correct
	on			br_to_c_correct.idfsBaseReference = br.idfsBaseReference
				and br_to_c_correct.idfCustomizationPackage = @idfCustomizationPackage
			)
on			br.idfsBaseReference = eg.idfsEmployeeGroupName
			and br.intRowStatus = 0
left join	#EmployeeGroup_To_Del eg_del	-- do not belong to historical records
on			eg_del.idfEmployeeGroup = eg.idfEmployeeGroup
where		br.idfsBaseReference is null
			and eg.idfEmployeeGroup <> -1	-- default
			and eg_del.idfEmployeeGroup is null
*/


insert into	#EmployeeGroup_To_Del (idfEmployeeGroup)
select		e.idfEmployee
from		tlbEmployee e
left join	tlbEmployeeGroup eg
on			eg.idfEmployeeGroup = e.idfEmployee
left join	#EmployeeGroup_To_Del eg_del
on			eg_del.idfEmployeeGroup = e.idfEmployee
/*TODO:remove--
where		(	e.intRowStatus <> 0	-- do not belong to historical records
				or	eg.idfEmployeeGroup is null
			)
			and (	e.idfsEmployeeType = 10023001	-- Employee Group
					or	eg.idfEmployeeGroup is not null
				)
			and e.idfEmployee <> -1			-- default
			and eg_del.idfEmployeeGroup is null
*/
where		(	e.idfsEmployeeType = 10023001	-- Employee Group
				or	eg.idfEmployeeGroup is not null
			)
			and (	e.idfEmployee > 0 -- non-default and unpredefined
					or e.idfEmployee not in
					(	 -501, --Administrator
						 -502, --Chief Epidemiologist
						 -503, --Chief Epizootologist
						 -504, --Chief of Laboratory (Human)
						 -505, --Chief of Laboratory (Vet)
						 -1, --Default
						 -506, --Default Role
						 -507, --Entomologist
						 -508, --Epidemiologist
						 -509, --Epizootologist
						 -510, -- Lab Technician (Human)
						 -511, --Lab Technician (Vet)
						 -512  --Notifiers
					)
				)
			and eg_del.idfEmployeeGroup is null


insert into	#LogTable (strMessage)
select	N'    User groups'' names to delete: '

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

insert into	#BR_To_Del (idfsBaseReference, strDescription)
select		eg.idfsEmployeeGroupName,
			N'    - User Group Name: [' + replace(IsNull(egn.[name], N'*'), N'''', N'''''') + N']'
from		tlbEmployeeGroup eg
inner join	#EmployeeGroup_To_Del eg_del
on			eg_del.idfEmployeeGroup = eg.idfEmployeeGroup
inner join	fnReferenceRepair('en', 19000022) egn	-- Employee Group Name
on			egn.idfsReference = eg.idfsEmployeeGroupName
left join	tlbEmployeeGroup eg_min
on			eg_min.idfsEmployeeGroupName = eg.idfsEmployeeGroupName
			and eg_min.idfEmployeeGroup < eg.idfEmployeeGroup
where		eg_min.idfEmployeeGroup is null
order by	egn.[name]

insert into	#LogTable (strMessage)
select		strDescription
from		#BR_To_Del
where		idfID > @FirstNumOfRef_To_Del
order by	idfID

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

select	@FirstNumOfRef_To_Del = max(idfID)
from	#BR_To_Del

if	@FirstNumOfRef_To_Del is null
begin
	set	@FirstNumOfRef_To_Del = 0
end

-- delete permissions on the sites to delete
insert into	#LogTable (strMessage)
select	N'    Delete permissions of employees and/or user groups on the sites to delete'

--TODO: delete AccessRulePermission and AccessRule

delete		ara
from		AccessRuleActor ara
where		ara.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Access Rule Actors marked as deleted (AccessRuleActor): ' + cast(@N as nvarchar(20))


delete		ua
from		UserAccess ua
where		ua.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Permissions of employees and/or user groups marked as deleted (UserAccess): ' + cast(@N as nvarchar(20))


delete		oa
from		tstObjectAccess oa
where		oa.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Permissions of employees and/or user groups marked as deleted (tstObjectAccess): ' + cast(@N as nvarchar(20))

delete		oa
from		tstObjectAccess oa
where		oa.idfsOnSite <> 1	-- default
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Permissions of employees and/or user groups on the sites distinct from default site (tstObjectAccess): ' + cast(@N as nvarchar(20))


delete		lrma
from		LkupRoleMenuAccess lrma
where		lrma.intRowStatus <> 0
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Employees'' permissions to menu items marked as deleted (LkupRoleMenuAccess): ' + cast(@N as nvarchar(20))


delete		lrsfa
from		LkupRoleSystemFunctionAccess lrsfa
where		lrsfa.intRowStatus <> 0
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Employees'' permissions to system functions marked as deleted (LkupRoleSystemFunctionAccess): ' + cast(@N as nvarchar(20))


insert into	#LogTable (strMessage)
select	N''


-- delete users with related info
insert into	#LogTable (strMessage)
select	N'    Delete logins with related info'

delete		utop
from		tstUserTableOldPassword utop
inner join	#User_To_Del u_del
on			u_del.idfUserID = utop.idfUserID
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Historical passwords for user logins (tstUserTableOldPassword): ' + cast(@N as nvarchar(20))

delete		ul
from		gisUserLayer ul
inner join	#User_To_Del u_del
on			u_del.idfUserID = ul.idfUser
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        GIS Layers created by the users (gisUserLayer): ' + cast(@N as nvarchar(20))

delete		gd
from		tlbGridDefinition gd
inner join	#User_To_Del u_del
on			u_del.idfUserID = gd.idfUserID
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Grid Definitions by the users (gisUserLayer): ' + cast(@N as nvarchar(20))

delete		lcc
from		tstLocalConnectionContext lcc
inner join  #User_To_Del u_del
on			u_del.idfUserID = lcc.idfUserID
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Connection context with specified users (tstLocalConnectionContext): ' + cast(@N as nvarchar(20))

delete		utl
from		tstUserTableLocal utl
inner join	#User_To_Del u_del
on			u_del.idfUserID = utl.idfUserID
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Information on failure of users'' login attempts (tstUserTableLocal): ' + cast(@N as nvarchar(20))

delete		ut
from		tstUserTicket ut
inner join	#User_To_Del u_del
on			u_del.idfUserID = ut.idfUserID
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Information on login redirect to AVR web site (tstUserTicket): ' + cast(@N as nvarchar(20))

delete		es
from		EventSubscription es
inner join	#User_To_Del u_del
on			u_del.idfUserID = es.idfUserID
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Information on event subscriptions of the users (EventSubscription): ' + cast(@N as nvarchar(20))


delete		e_to_i
from		EmployeeToInstitution e_to_i
inner join	AspNetUsers aspNetU
on			aspNetU.[Id] = e_to_i.aspNetUserId
inner join	#User_To_Del u_del
on			u_del.idfUserID = aspNetU.idfUserID
set	@N = @@rowcount

delete		e_to_i
from		EmployeeToInstitution e_to_i
inner join	#User_To_Del u_del
on			u_del.idfUserID = e_to_i.idfUserID
set	@N = @N + @@rowcount

insert into	#LogTable (strMessage)
select	N'        Information on links from users to the organizations (EmployeeToInstitution): ' + cast(@N as nvarchar(20))


delete		aspNetPwdHistory
from		ASPNetUserPreviousPasswords aspNetPwdHistory
inner join	AspNetUsers aspNetU
on			aspNetU.[Id] = aspNetPwdHistory.[Id]
inner join	#User_To_Del u_del
on			u_del.idfUserID = aspNetU.idfUserID
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        History of ASP.NET-specific passwords of the logins of the users (ASPNetUserPreviousPasswords): ' + cast(@N as nvarchar(20))


delete		aspNetU
from		AspNetUsers aspNetU
inner join	#User_To_Del u_del
on			u_del.idfUserID = aspNetU.idfUserID
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        ASP.NET-specific information on the logins of the users (AspNetUsers): ' + cast(@N as nvarchar(20))


delete		ut
from		tstUserTable ut
inner join	#User_To_Del u_del
on			u_del.idfUserID = ut.idfUserID
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Users'' logins (tstUserTable): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''


-- delete employees with related info
insert into	#LogTable (strMessage)
select	N'    Delete employees with related info'

update		gll
set			gll.idfPerson = null
from		tasglLayout gll
inner join	#Person_To_Del p_del
on			p_del.idfPerson = gll.idfPerson
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Remove specified employees from not shared published AVR layouts (tasglLayout): ' + cast(@N as nvarchar(20))

update		l
set			l.idfPerson = null
from		tasLayout l
inner join	#Person_To_Del p_del
on			p_del.idfPerson = l.idfPerson
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Remove specified employees from not shared AVR layouts (tasLayout): ' + cast(@N as nvarchar(20))


delete		ua
from		UserAccess ua
inner join	#Person_To_Del p_del
on			p_del.idfPerson = ua.UserEmployeeID
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Employees'' permissions on sites (UserAccess): ' + cast(@N as nvarchar(20))


delete		oa
from		tstObjectAccess oa
inner join	#Person_To_Del p_del
on			p_del.idfPerson = oa.idfActor
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Employees'' permissions on sites (tstObjectAccess): ' + cast(@N as nvarchar(20))


delete		lrma
from		LkupRoleMenuAccess lrma
inner join	#Person_To_Del p_del
on			p_del.idfPerson = lrma.idfEmployee
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Employees'' permissions to menu items (LkupRoleMenuAccess): ' + cast(@N as nvarchar(20))


delete		lrsfa
from		LkupRoleSystemFunctionAccess lrsfa
inner join	#Person_To_Del p_del
on			p_del.idfPerson = lrsfa.idfEmployee
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Employees'' permissions to system functions (LkupRoleSystemFunctionAccess): ' + cast(@N as nvarchar(20))


delete		egm
from		tlbEmployeeGroupMember egm
where		egm.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Employees'' user group membership marked as deleted (tlbEmployeeGroupMember): ' + cast(@N as nvarchar(20))

delete		egm
from		tlbEmployeeGroupMember egm
inner join	#Person_To_Del p_del
on			p_del.idfPerson = egm.idfEmployee
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Employees'' user group membership (tlbEmployeeGroupMember): ' + cast(@N as nvarchar(20))

delete		p
from		tlbPerson p
inner join	#Person_To_Del p_del
on			p_del.idfPerson = p.idfPerson
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Employees (tlbPerson): ' + cast(@N as nvarchar(20))

delete		e
from		tlbEmployee e
inner join	#Person_To_Del p_del
on			p_del.idfPerson = e.idfEmployee
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Employees (tlbEmployee): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

-- delete employees group and related info
insert into	#LogTable (strMessage)
select	N'    Delete user groups with related info'


delete		ua
from		UserAccess ua
inner join	#EmployeeGroup_To_Del eg_del
on			eg_del.idfEmployeeGroup = ua.UserEmployeeID
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        User groups'' permissions on sites (UserAccess): ' + cast(@N as nvarchar(20))

delete		oa
from		tstObjectAccess oa
inner join	#EmployeeGroup_To_Del eg_del
on			eg_del.idfEmployeeGroup = oa.idfActor
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        User groups'' permissions on sites (tstObjectAccess): ' + cast(@N as nvarchar(20))


delete		lrma
from		LkupRoleMenuAccess lrma
inner join	#EmployeeGroup_To_Del eg_del
on			eg_del.idfEmployeeGroup = lrma.idfEmployee
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        User groups'' permissions to menu items (LkupRoleMenuAccess): ' + cast(@N as nvarchar(20))


delete		lrsfa
from		LkupRoleSystemFunctionAccess lrsfa
inner join	#EmployeeGroup_To_Del eg_del
on			eg_del.idfEmployeeGroup = lrsfa.idfEmployee
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'       User groups'' permissions to system functions (LkupRoleSystemFunctionAccess): ' + cast(@N as nvarchar(20))



delete		egm
from		tlbEmployeeGroupMember egm
inner join	#EmployeeGroup_To_Del eg_del
on			eg_del.idfEmployeeGroup = egm.idfEmployeeGroup
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        User group membership (tlbEmployeeGroupMember): ' + cast(@N as nvarchar(20))

delete		eg
from		tlbEmployeeGroup eg
inner join	#EmployeeGroup_To_Del eg_del
on			eg_del.idfEmployeeGroup = eg.idfEmployeeGroup
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        User groups (tlbEmployeeGroup): ' + cast(@N as nvarchar(20))

delete		e
from		tlbEmployee e
inner join	#EmployeeGroup_To_Del eg_del
on			eg_del.idfEmployeeGroup = e.idfEmployee
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        User groups (tlbEmployee): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

-- Delete offices and mark sites as deleted with related info
insert into	#LogTable (strMessage)
select	N'    Delete sites except default one and related info'

update		s
set			s.intRowStatus = 1,
			s.idfOffice = null,
			s.strSiteName = N'Default Site',
			s.idfCustomizationPackage = @idfAdminInfoCustomizationPackage
from		tstSite s
where		s.idfsSite = 1 /*default site*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Mark default site as deleted and update customization package to [' + @AdminInfoCustomizationPackage + N'] (tstSite): ' + cast(@N as nvarchar(20))

update		s
set			s.idfOffice = null,
			s.idfsParentSite = null
from		tstSite s
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Remove links to the organizations and parent sites from all site records (tstSite): ' + cast(@N as nvarchar(20))

delete		arp
from		AccessRulePermission arp
join		AccessRule ar
on			ar.AccessRuleID = arp.AccessRuleID
where		ar.GrantingActorSiteGroupID is not null
			or ar.GrantingActorSiteID is not null
			or ar.intRowStatus <> 0
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Configurable filtration: permissions associated with access rules for sites or group of sites (AccessRulePermission, obsolete): ' + cast(@N as nvarchar(20))

delete		ara
from		AccessRuleActor ara
join		AccessRule ar
on			ar.AccessRuleID = ara.AccessRuleID
where		ar.GrantingActorSiteGroupID is not null
			or ar.GrantingActorSiteID is not null
			or ar.intRowStatus <> 0
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Configurable filtration: actors (groups of sites or users, or individual site or user associated with access rules for sites or group of sites (AccessRulePermission, obsolete): ' + cast(@N as nvarchar(20))

delete		ar
from		AccessRule ar
where		ar.GrantingActorSiteGroupID is not null
			or ar.GrantingActorSiteID is not null
			or ar.intRowStatus <> 0
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Configurable filtration: access rules for sites or group of sites (AccessRule): ' + cast(@N as nvarchar(20))

insert into	#BR_To_Del (idfsBaseReference, strDescription, blnIsOfficeAttribute)
select		br.idfsBaseReference,
			N'    - ' + replace(IsNull(rt.strReferenceTypeName, N'*'), N'''', N'''''') + N': [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']',
			0
from		trtBaseReference br
join		trtReferenceType rt
on			rt.idfsReferenceType = br.idfsReferenceType
left join	AccessRule ar
on			ar.AccessRuleID = br.idfsBaseReference
where		br.idfsReferenceType = 19000537 -- Access Rule
			and ar.AccessRuleID is null

delete		sgr
from		tflSiteGroupRelation sgr
/*TODO:remove--
inner join	tflSiteGroup sg
on			sg.idfSiteGroup = sgr.idfReceiverSiteGroup
			and sg.idfsRayon is null
			and sg.idfsCentralSite is null
			and not exists	(
						select		*
						from		tflSiteToSiteGroup s_to_sg
						inner join	tstSite s
						on			s.idfsSite = s_to_sg.idfsSite
									and IsNull(s.idfCustomizationPackage, -1) = @idfAdminInfoCustomizationPackage
									-- do not check historical records
						where		s_to_sg.idfSiteGroup = sg.idfSiteGroup
							)
*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Configurable filtration: unidirectional rules (tflSiteGroupRelation): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		sgr
from		tflSiteGroupRelation sgr
inner join	tflSiteGroup sg
on			sg.idfSiteGroup = sgr.idfSenderSiteGroup
			and sg.idfsRayon is null
			and sg.idfsCentralSite is null
			and not exists	(
						select		*
						from		tflSiteToSiteGroup s_to_sg
						inner join	tstSite s
						on			s.idfsSite = s_to_sg.idfsSite
									and IsNull(s.idfCustomizationPackage, -1) = @idfAdminInfoCustomizationPackage
									-- do not check historical records
						where		s_to_sg.idfSiteGroup = sg.idfSiteGroup
							)
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Configurable filtration: unidirectional rules for Senders - sites/groups of sites from customization package distinct from [' + @AdminInfoCustomizationPackage + N'] (tflSiteGroupRelation): ' + cast(@N as nvarchar(20))
*/

delete		s_to_sg
from		tflSiteToSiteGroup s_to_sg
/*TODO:remove--
inner join	tflSiteGroup sg
on			sg.idfSiteGroup = s_to_sg.idfSiteGroup
			and sg.idfsRayon is null
			and sg.idfsCentralSite is null
inner join	tstSite s
on			s.idfsSite = s_to_sg.idfsSite
			and IsNull(s.idfCustomizationPackage, -1) <> @idfAdminInfoCustomizationPackage
			-- do not check historical records
*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Configurable filtration: links from sites to the data filtration groups of sites (tflSiteToSiteGroup): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		sg
from		tflSiteGroup sg
where		sg.idfsRayon is null
			and sg.idfsCentralSite is null
			and not exists	(
						select		*
						from		tflSiteToSiteGroup s_to_sg
						inner join	tstSite s
						on			s.idfsSite = s_to_sg.idfsSite
									and IsNull(s.idfCustomizationPackage, -1) = @idfAdminInfoCustomizationPackage
									-- do not check historical records
						where		s_to_sg.idfSiteGroup = sg.idfSiteGroup
							)
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Configurable filtration: bidirectional rules for sites from customization package distinct from [' + @AdminInfoCustomizationPackage + N'] (tflSiteGroup): ' + cast(@N as nvarchar(20))


delete		s_to_sg
from		tflSiteToSiteGroup s_to_sg
inner join	tflSiteGroup sg
on			sg.idfSiteGroup = s_to_sg.idfSiteGroup
			and sg.idfsRayon is not null
inner join	gisRayon ray
on			ray.idfsRayon = sg.idfsRayon
			and ray.idfsCountry <> @AdminInfoCountry

set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Configurable filtration: links from sites to the groups of sites connected to the rayons of the country with HASC distinct from [' + @AdminInfoCountryHASC + N'] (tflSiteToSiteGroup): ' + cast(@N as nvarchar(20))
*/

delete		sg
from		tflSiteGroup sg
/*TODO:remove--
inner join	gisRayon ray
on			ray.idfsRayon = sg.idfsRayon
			and ray.idfsCountry <> @AdminInfoCountry
*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Configurable filtration: groups of sites (tflSiteGroup): ' + cast(@N as nvarchar(20))


/*TODO:remove--
delete		s_to_sg
from		tflSiteToSiteGroup s_to_sg
inner join	tflSiteGroup sg
on			sg.idfSiteGroup = s_to_sg.idfSiteGroup
			and sg.idfsCentralSite is not null
inner join	tstSite s
on			s.idfsSite = sg.idfsCentralSite
			and s.idfCustomizationPackage <> @idfAdminInfoCustomizationPackage

set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Configurable filtration: links from sites to the groups of sites from border areas for the site from customization package distinct from [' + @AdminInfoCustomizationPackage + N'] (tflSiteToSiteGroup): ' + cast(@N as nvarchar(20))

delete		sg
from		tflSiteGroup sg
inner join	tstSite s
on			s.idfsSite = sg.idfsCentralSite
			and s.idfCustomizationPackage <> @idfAdminInfoCustomizationPackage

set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Configurable filtration: groups of sites from border areas for the site from customization package distinct from [' + @AdminInfoCustomizationPackage + N'] (tflSiteToSiteGroup): ' + cast(@N as nvarchar(20))
*/


delete		s
from		tflSite s
where		s.idfsSite <> 1 /*Default Site*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Configurable filtration: information on sites for data filtration (tflSite): ' + cast(@N as nvarchar(20))


delete		lcc
from		tstLocalConnectionContext lcc
inner join	tstSite s
on			s.idfsSite = lcc.idfsSite
			and s.intRowStatus <> 0	-- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Connection context with specified sites marked as deleted (tstLocalConnectionContext): ' + cast(@N as nvarchar(20))

delete		gso
from		tstGlobalSiteOptions gso
inner join	tstSite s
on			s.idfsSite = gso.idfsSite
			and s.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Global options of sited marked as deleted (tstGlobalSiteOptions): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

insert into	#LogTable (strMessage)
select	N'    Delete organizations and departments with related info'

update		o
set			o.idfLocation = null
from		tlbOffice o
inner join	tlbGeoLocationShared gl
on			gl.idfGeoLocationShared = o.idfLocation
/*TODO:remove--
where		(	gl.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	gl.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
			or	(	o.intRowStatus <> 0
					and @DeleteHistoricalRecordsMarkedAsDeleted = 1
					and (	o.intRowStatus = @DeletionFlag
							or	@DeletionFlag = 1
						)
				)
set	@N = @@rowcount

if	@DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'        Remove links to addresses from the organizations marked as deleted (tlbOffice): ' + cast(@N as nvarchar(20))
*/
where		o.idfOffice <> -1 /*Disposition*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Remove links to addresses from all organizations except Disposition organization if exists (tlbOffice): ' + cast(@N as nvarchar(20))

delete		glt
from		tlbGeoLocationSharedTranslation glt
inner join	tlbGeoLocationShared gl
on			gl.idfGeoLocationShared = glt.idfGeoLocationShared
left join	tlbOffice o
on			o.idfLocation = gl.idfGeoLocationShared
			--Comment for historical records--and o.intRowStatus = 0
left join	tlbHumanActual ha_cr
on			ha_cr.idfCurrentResidenceAddress = gl.idfGeoLocationShared
left join	tlbHumanActual ha_ra
on			ha_ra.idfRegistrationAddress = gl.idfGeoLocationShared
left join	tlbHumanActual ha_ea
on			ha_ea.idfEmployerAddress = gl.idfGeoLocationShared
left join	HumanActualAddlInfo haai_aa
on			haai_aa.AltAddressID = gl.idfGeoLocationShared
left join	HumanActualAddlInfo haai_sa
on			haai_sa.SchoolAddressID = gl.idfGeoLocationShared
left join	tlbFarmActual fa
on			fa.idfFarmAddress = gl.idfGeoLocationShared
where		(	(	gl.intRowStatus <> 0
					and @DeleteHistoricalRecordsMarkedAsDeleted = 1
					and (	gl.intRowStatus = @DeletionFlag
							or	@DeletionFlag = 1
						)
				)
				or o.idfOffice is null
			)
			and ha_cr.idfHumanActual is null
			and ha_ea.idfHumanActual is null
			and ha_ra.idfHumanActual is null
			and fa.idfFarmActual is null
			and haai_aa.AltAddressID is null
			and haai_sa.SchoolAddressID is null
set	@N = @@rowcount

/*TODO:remove--
if @DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'        Translations of addresses'' strings marked as deleted or not linked to any object (tlbGeoLocationSharedTranslation): ' + cast(@N as nvarchar(20))
else
	insert into	#LogTable (strMessage)
	select	N'        Translations of addresses'' strings not linked to any object (tlbGeoLocationSharedTranslation): ' + cast(@N as nvarchar(20))
*/
insert into	#LogTable (strMessage)
select	N'        Translations of addresses'' strings marked as deleted or not linked to any object or organization addresses (tlbGeoLocationSharedTranslation): ' + cast(@N as nvarchar(20))


delete		gl
from		tlbGeoLocationShared gl
left join	tlbOffice o
on			o.idfLocation = gl.idfGeoLocationShared
			--Comment for historical records--and o.intRowStatus = 0
left join	tlbHumanActual ha_cr
on			ha_cr.idfCurrentResidenceAddress = gl.idfGeoLocationShared
left join	tlbHumanActual ha_ra
on			ha_ra.idfRegistrationAddress = gl.idfGeoLocationShared
left join	tlbHumanActual ha_ea
on			ha_ea.idfEmployerAddress = gl.idfGeoLocationShared
left join	HumanActualAddlInfo haai_aa
on			haai_aa.AltAddressID = gl.idfGeoLocationShared
left join	HumanActualAddlInfo haai_sa
on			haai_sa.SchoolAddressID = gl.idfGeoLocationShared
left join	tlbFarmActual fa
on			fa.idfFarmAddress = gl.idfGeoLocationShared
where		(	(	gl.intRowStatus <> 0
					and @DeleteHistoricalRecordsMarkedAsDeleted = 1
					and (	gl.intRowStatus = @DeletionFlag
							or	@DeletionFlag = 1
						)
				)
				or o.idfOffice is null
			)
			and ha_cr.idfHumanActual is null
			and ha_ea.idfHumanActual is null
			and ha_ra.idfHumanActual is null
			and fa.idfFarmActual is null
			and haai_aa.AltAddressID is null
			and haai_sa.SchoolAddressID is null
set	@N = @@rowcount

/*TODO:remove--
if @DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'        Organizations'' addresses marked as deleted and/or addresses not linked to any object (tlbGeoLocationShared): ' + cast(@N as nvarchar(20))
else
	insert into	#LogTable (strMessage)
	select	N'        Addresses not linked to any object (tlbGeoLocationShared): ' + cast(@N as nvarchar(20))
*/
insert into	#LogTable (strMessage)
select	N'        Addresses marked as deleted or not linked to any object or organization addresses (tlbGeoLocationSharedTranslation): ' + cast(@N as nvarchar(20))

delete		d
from		tlbDepartment d
/*TODO:remove--
where		(	d.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	d.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
set	@N = @@rowcount

if @DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'        Departments marked as deleted (tlbDepartment): ' + cast(@N as nvarchar(20))
*/
set	@N = @@rowcount
insert into	#LogTable (strMessage)
select	N'        Departments (tlbDepartment): ' + cast(@N as nvarchar(20))

delete		e_to_i
from		EmployeeToInstitution e_to_i
join		tlbOffice o
on			o.idfOffice = e_to_i.idfInstitution
where		o.idfOffice <> -1 /*Disposition*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Links from user accounts to organizations except Disposition organization if exists (EmployeeToInstitution): ' + cast(@N as nvarchar(20))

delete		o
from		tlbOffice o
/*TODO:remove--
where		(	o.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	o.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
set	@N = @@rowcount

if @DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'        Organizations marked as deleted (tlbOffice): ' + cast(@N as nvarchar(20))
*/
where		o.idfOffice <> -1 /*Disposition*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Organizations except Disposition organization if exists (tlbOffice): ' + cast(@N as nvarchar(20))

delete		s
from		tstSite s
where		s.idfsSite <> 1 /*Default Site*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Sites except Default Site (tstSite): ' + cast(@N as nvarchar(20))


insert into	#LogTable (strMessage)
select	N''

/*TODO:remove--

update		o
set			o.idfLocation = null
from		tlbOffice o
inner join	tlbGeoLocation gl
on			gl.idfGeoLocation = o.idfLocation
where		IsNull(o.idfCustomizationPackage , -1) <> @idfAdminInfoCustomizationPackage
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Remove links to addresses from the organizations of customization package distinct from [' + @AdminInfoCustomizationPackage + N'] (tlbOffice): ' + cast(@N as nvarchar(20))

delete		glt
from		tlbGeoLocationSharedTranslation glt
inner join	tlbGeoLocationShared gl
on			gl.idfGeoLocationShared = glt.idfGeoLocationShared
left join	tlbOffice o
on			o.idfLocation = gl.idfGeoLocationShared
left join	tlbHumanActual ha_cr
on			ha_cr.idfCurrentResidenceAddress = gl.idfGeoLocationShared
left join	tlbHumanActual ha_ra
on			ha_ra.idfRegistrationAddress = gl.idfGeoLocationShared
left join	tlbHumanActual ha_ea
on			ha_ea.idfEmployerAddress = gl.idfGeoLocationShared
left join	HumanActualAddlInfo haai_aa
on			haai_aa.AltAddressID = gl.idfGeoLocationShared
left join	HumanActualAddlInfo haai_sa
on			haai_sa.SchoolAddressID = gl.idfGeoLocationShared
left join	tlbFarmActual fa
on			fa.idfFarmAddress = gl.idfGeoLocationShared
where		o.idfOffice is null
			and ha_cr.idfHumanActual is null
			and ha_ea.idfHumanActual is null
			and ha_ra.idfHumanActual is null
			and fa.idfFarmActual is null
			and haai_aa.AltAddressID is null
			and haai_sa.SchoolAddressID is null
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Translations of addresses'' strings of the organizations of customization package distinct from [' + @AdminInfoCustomizationPackage + N'] (tlbGeoLocationSharedTranslation): ' + cast(@N as nvarchar(20))

delete		gl
from		tlbGeoLocationShared gl
left join	tlbOffice o
on			o.idfLocation = gl.idfGeoLocationShared
left join	tlbHumanActual ha_cr
on			ha_cr.idfCurrentResidenceAddress = gl.idfGeoLocationShared
left join	tlbHumanActual ha_ra
on			ha_ra.idfRegistrationAddress = gl.idfGeoLocationShared
left join	tlbHumanActual ha_ea
on			ha_ea.idfEmployerAddress = gl.idfGeoLocationShared
left join	HumanActualAddlInfo haai_aa
on			haai_aa.AltAddressID = gl.idfGeoLocationShared
left join	HumanActualAddlInfo haai_sa
on			haai_sa.SchoolAddressID = gl.idfGeoLocationShared
left join	tlbFarmActual fa
on			fa.idfFarmAddress = gl.idfGeoLocationShared
where		o.idfOffice is null
			and ha_cr.idfHumanActual is null
			and ha_ea.idfHumanActual is null
			and ha_ra.idfHumanActual is null
			and fa.idfFarmActual is null
			and haai_aa.AltAddressID is null
			and haai_sa.SchoolAddressID is null
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Addresses of the organizations of customization package distinct from [' + @AdminInfoCustomizationPackage + N'] (tlbGeoLocationSharedTranslation): ' + cast(@N as nvarchar(20))

delete		d
from		tlbDepartment d
inner join	tlbOffice o
on			o.idfOffice = d.idfOrganization
where		IsNull(o.idfCustomizationPackage , -1) <> @idfAdminInfoCustomizationPackage
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Organizations'' departments of customization package distinct from [' + @AdminInfoCustomizationPackage + N'] (tlbGeoLocationSharedTranslation): ' + cast(@N as nvarchar(20))

delete		o
from		tlbOffice o
where		IsNull(o.idfCustomizationPackage , -1) <> @idfAdminInfoCustomizationPackage
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Organizations of customization package distinct from [' + @AdminInfoCustomizationPackage + N'] (tlbGeoLocationSharedTranslation): ' + cast(@N as nvarchar(20))
*/




insert into	#LogTable (strMessage)
select	N''

-- Delete and/or update settings of mandatory fields and personal data groups
insert into	#LogTable (strMessage)
select	N'    Delete and/or update settings of mandatory fields and personal data groups'

delete		pdg_to_c
from		tstPersonalDataGroupToCP pdg_to_c
/*TODO:remove--
where		pdg_to_c.idfCustomizationPackage <> @idfCustomizationPackage
*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Delete settings of personal data groups specified for customization packages (tstPersonalDataGroupToCP): ' + cast(@N as nvarchar(20))



delete		mf_to_c
from		tstMandatoryFieldsToCP mf_to_c
/*TODO:remove--
where		mf_to_c.idfCustomizationPackage <> @idfCustomizationPackage
*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Delete settings of personal data groups specified for customization packages (tstMandatoryFieldsToCP): ' + cast(@N as nvarchar(20))



insert into	#LogTable (strMessage)
select	N''

-- Delete aggregate settings and statistics
insert into	#LogTable (strMessage)
select	N'    Delete aggregate settings'

delete		ags
from		tstAggrSetting ags
/*TODO:remove--
where		ags.idfCustomizationPackage <> @idfCustomizationPackage-- TODO: check if it is correct--@idfAdminInfoCustomizationPackage
			or ags.intRowStatus <> 0 -- do not nelong to historical records
*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Aggregate settings (tstAggrSetting): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

insert into	#LogTable (strMessage)
select	N'    Delete statistics'' values'

delete		s
from		tlbStatistic s
/*TODO:remove--
left join	gisBaseReference br
on			br.idfsGISBaseReference = s.idfsArea
			and br.intRowStatus = 0
where		br.idfsGISBaseReference is null
			or s.intRowStatus <> 0 -- do not belong to historical records
*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Statistics'' values (tlbStatistic): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		s
from		tlbStatistic s
inner join	gisCountry c
on			c.idfsCountry = s.idfsArea
			and c.intRowStatus = 0
where		c.idfsCountry <> @AdminInfoCountry
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Statistics'' values the countries with HASC distinct from [' + @AdminInfoCountryHASC + N'] (tlbStatistic): ' + cast(@N as nvarchar(20))

delete		s
from		tlbStatistic s
inner join	gisRegion reg
on			reg.idfsRegion = s.idfsArea
			and reg.intRowStatus = 0
where		reg.idfsCountry <> @AdminInfoCountry
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Statistics'' values the region of the country with HASC distinct from [' + @AdminInfoCountryHASC + N'] (tlbStatistic): ' + cast(@N as nvarchar(20))

delete		s
from		tlbStatistic s
inner join	gisRayon ray
on			ray.idfsRayon = s.idfsArea
			and ray.intRowStatus = 0
where		ray.idfsCountry <> @AdminInfoCountry
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Statistics'' values the rayon of the country with HASC distinct from [' + @AdminInfoCountryHASC + N'] (tlbStatistic): ' + cast(@N as nvarchar(20))

delete		s
from		tlbStatistic s
inner join	gisSettlement st
on			st.idfsSettlement = s.idfsArea
			and st.intRowStatus = 0
where		st.idfsCountry <> @AdminInfoCountry
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Statistics'' values the settlement of the country with HASC distinct from [' + @AdminInfoCountryHASC + N'] (tlbStatistic): ' + cast(@N as nvarchar(20))
*/

insert into	#LogTable (strMessage)
select	N''

insert into	#LogTable (strMessage)
select	N''

-- Delete Location String Formats
insert into	#LogTable (strMessage)
select	N'    Delete location/address string formats'

delete		glf
from		tstGeoLocationFormat glf
/*TODO:remove--
where		glf.idfsCountry <> @Country
			and glf.idfsCountry <> @AdminInfoCountry
			and glf.idfsCountry <> 2340000000	-- US0000
*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Location/address string formats (tstGeoLocationFormat): ' + cast(@N as nvarchar(20))

-- Delete geo info (settlements and local data)

-- Delete FF data based on trtBaseReferenceToCP
insert into	#LogTable (strMessage)
select	N'Delete flexible form objects'

create table #Template_To_Del
(	idfsFormTemplate	bigint not null primary key
)

create table	#Section_To_Del
(	idfsSection	bigint not null primary key
)

create table	#Parameter_To_Del
(	idfsParameter	bigint not null primary key
)

create table	#ParameterType_To_Del
(	idfsParameterType	bigint not null primary key
)

create table	#Rule_To_Del
(	idfsRule	bigint not null primary key
)

insert into	#Template_To_Del	(idfsFormTemplate)
select		ft.idfsFormTemplate
from		ffFormTemplate ft
/*TODO:remove--
where		(	ft.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	ft.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
*/
where		ft.idfsFormType not in --Outbreak FF: TODO: check if condition is needed and prepare 
			(	10034501,
				10034502,
				10034503,
				10034504,
				10034505,
				10034506,
				10034507,
				10034508,
				10034509
			)

/*TODO:remove--
insert into	#Template_To_Del	(idfsFormTemplate)
select		ft.idfsFormTemplate
from		ffFormTemplate ft
inner join	trtBaseReference br
on			br.idfsBaseReference = ft.idfsFormTemplate
left join	#Template_To_Del t_del
on			t_del.idfsFormTemplate = br.idfsBaseReference
where		(	br.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	br.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
			and t_del.idfsFormTemplate is null

insert into	#Template_To_Del	(idfsFormTemplate)
select distinct
			ft.idfsFormTemplate
from		ffFormTemplate ft
inner join	trtBaseReference br
on			br.idfsBaseReference = ft.idfsFormTemplate
inner join	trtBaseReferenceToCP br_to_c
on			br_to_c.idfsBaseReference = br.idfsBaseReference
left join	trtBaseReferenceToCP br_to_correct_c
on			br_to_correct_c.idfsBaseReference = br.idfsBaseReference
			and br_to_correct_c.idfCustomizationPackage = @idfCustomizationPackage
left join	#Template_To_Del t_del
on			t_del.idfsFormTemplate = br.idfsBaseReference
where		--Comment for historical records--br.intRowStatus = 0
			--Comment for historical records--and 
			br_to_correct_c.idfsBaseReference is null
			and t_del.idfsFormTemplate is null
*/
insert into	#LogTable (strMessage)
select	N'    FF templates to delete: '

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

insert into	#BR_To_Del	(idfsBaseReference, strDescription)
select		ft.idfsFormTemplate,
			N'    - ' + replace(IsNull(ftype.[name], N'*'), N'''', N'''''') + N': [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'
from		ffFormTemplate ft
inner join	#Template_To_Del t_del
on			t_del.idfsFormTemplate = ft.idfsFormTemplate
left join	fnReferenceRepair('en', 19000034) ftype
on			ftype.idfsReference = ft.idfsFormType
left join	trtBaseReference br
on			br.idfsBaseReference = ft.idfsFormTemplate
left join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ft.idfsFormTemplate
where		br_del.idfsBaseReference is null
order by	ftype.[name], ft.idfsFormType, br.strDefault, br.idfsBaseReference


insert into	#LogTable (strMessage)
select		strDescription
from		#BR_To_Del
where		idfID > @FirstNumOfRef_To_Del
order by	idfID

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

select	@FirstNumOfRef_To_Del = max(idfID)
from	#BR_To_Del

if	@FirstNumOfRef_To_Del is null
begin
	set	@FirstNumOfRef_To_Del = 0
end

insert into	#Section_To_Del	(idfsSection)
select		s.idfsSection
from		ffSection s
/*TODO:remove--
where		(	s.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	s.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
*/
where		s.idfsFormType not in --Outbreak FF: TODO: check if condition is needed and prepare 
			(	10034501,
				10034502,
				10034503,
				10034504,
				10034505,
				10034506,
				10034507,
				10034508,
				10034509
			)
			and s.idfsSection not in
				(	71090000000,	-- VetCase
					71460000000,	-- DiagnosticAction
					71300000000,	-- ProphylacticAction
					71190000000,	-- HumanCase
					71260000000		-- SanitaryAction
				)

/*TODO:remove--
insert into	#Section_To_Del	(idfsSection)
select		s.idfsSection
from		ffSection s
inner join	trtBaseReference br
on			br.idfsBaseReference = s.idfsSection
left join	#Section_To_Del s_del
on			s_del.idfsSection = br.idfsBaseReference
where		(	br.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	br.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
			and s_del.idfsSection is null

insert into	#Section_To_Del	(idfsSection)
select distinct
			s.idfsSection
from		ffSection s
inner join	trtBaseReference br
on			br.idfsBaseReference = s.idfsSection
inner join	trtBaseReferenceToCP br_to_c
on			br_to_c.idfsBaseReference = br.idfsBaseReference
left join	trtBaseReferenceToCP br_to_correct_c
on			br_to_correct_c.idfsBaseReference = br.idfsBaseReference
			and br_to_correct_c.idfCustomizationPackage = @idfCustomizationPackage
left join	(
	ffSectionForTemplate sft
	left join	#Template_To_Del t_del
	on			t_del.idfsFormTemplate = sft.idfsFormTemplate
			)
on			sft.idfsSection = s.idfsSection
			and sft.intRowStatus = 0 -- do not belong to historical records
			and t_del.idfsFormTemplate is null
left join	#Section_To_Del s_del
on			s_del.idfsSection = br.idfsBaseReference
where		--Comment for historical records--br.intRowStatus = 0
			--Comment for historical records--and 
			s.idfsSection not in
				(	71090000000,	-- VetCase
					71460000000,	-- DiagnosticAction
					71300000000,	-- ProphylacticAction
					71190000000,	-- HumanCase
					71260000000		-- SanitaryAction
				)
			and br_to_correct_c.idfsBaseReference is null
			and sft.idfsSection is null
			and s_del.idfsSection is null
*/
insert into	#LogTable (strMessage)
select	N'    FF sections to delete: '

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

insert into	#BR_To_Del	(idfsBaseReference, strDescription)
select		s.idfsSection,
			N'    - ' + replace(IsNull(ftype.[name], N'*'), N'''', N'''''') + N': [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'
from		ffSection s
inner join	#Section_To_Del s_del
on			s_del.idfsSection = s.idfsSection
left join	fnReferenceRepair('en', 19000034) ftype
on			ftype.idfsReference = s.idfsFormType
left join	trtBaseReference br
on			br.idfsBaseReference = s.idfsSection
left join	#BR_To_Del br_del
on			br_del.idfsBaseReference = s.idfsSection
where		br_del.idfsBaseReference is null
order by	ftype.[name], s.idfsFormType, br.strDefault, br.idfsBaseReference

insert into	#LogTable (strMessage)
select		strDescription
from		#BR_To_Del
where		idfID > @FirstNumOfRef_To_Del
order by	idfID

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

select	@FirstNumOfRef_To_Del = max(idfID)
from	#BR_To_Del

if	@FirstNumOfRef_To_Del is null
begin
	set	@FirstNumOfRef_To_Del = 0
end


insert into	#Rule_To_Del	(idfsRule)
select		r.idfsRule
from		ffRule r
where		r.intRowStatus <> 0 -- do not belong to historical records

insert into	#Rule_To_Del	(idfsRule)
select		r.idfsRule
from		ffRule r
inner join	trtBaseReference br
on			br.idfsBaseReference = r.idfsRule
left join	#Rule_To_Del r_del
on			r_del.idfsRule = br.idfsBaseReference
where		br.intRowStatus <> 0 -- do not belong to historical records
			and r_del.idfsRule is null

insert into	#Rule_To_Del	(idfsRule)
select		r.idfsRule
from		ffRule r
inner join	#Template_To_Del t_del
on			t_del.idfsFormTemplate = r.idfsFormTemplate
left join	#Rule_To_Del r_del
on			r_del.idfsRule = r.idfsRule
where		r_del.idfsRule is null

create table	#R_To_Del
(	idfsRule			bigint not null,
	idfsBaseReference	bigint not null primary key
)

insert into	#R_To_Del
(	idfsRule,
	idfsBaseReference
)
select		r.idfsRule,
			r.idfsRuleMessage
from		ffRule r
inner join	#Rule_To_Del r_del
on			r_del.idfsRule = r.idfsRule
left join	#Rule_To_Del r_del_ex
	inner join	ffRule r_ex
	on			r_ex.idfsRule = r_del_ex.idfsRule
on			r_ex.idfsRuleMessage = r.idfsRuleMessage
			and r_del_ex.idfsRule < r.idfsRule
where		r_del_ex.idfsRule is NULL
			AND r.idfsRuleMessage IS NOT NULL


insert into	#R_To_Del
(	idfsRule,
	idfsBaseReference
)
select		r.idfsRule,
			r.idfsRule
from		ffRule r
inner join	#Rule_To_Del r_del
on			r_del.idfsRule = r.idfsRule
left join	#R_To_Del r_del_ex
on			r_del_ex.idfsBaseReference = r.idfsRule
where		r_del_ex.idfsBaseReference is null

insert into	#LogTable (strMessage)
select	N'    FF rules and their messages to delete: '

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

insert into	#BR_To_Del	(idfsBaseReference, strDescription)
select		r_del.idfsBaseReference,
			case
				when	r_del.idfsBaseReference = r.idfsRule
					then	N'    - FF Type [' + replace(IsNull(ftype.[name], N'*'), N'''', N'''''') +
							N'] template [' + replace(IsNull(r_t.[name], N'*'), N'''', N'''''') + 
							N'] rule [' + replace(IsNull(br_r.strDefault, N'*'), N'''', N'''''') +
							N']: name'
				else	N'    - FF Type [' + replace(IsNull(ftype.[name], N'*'), N'''', N'''''') +
						N'] template [' + replace(IsNull(r_t.[name], N'*'), N'''', N'''''') + 
						N'] rule [' + replace(IsNull(br_r.strDefault, N'*'), N'''', N'''''') +
						N']: message [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'
			end as strDescription
from		ffRule r
inner join	#R_To_Del r_del
on			r_del.idfsRule = r.idfsRule
inner join	trtBaseReference br_r
on			br_r.idfsBaseReference = r.idfsRule
inner join	trtBaseReference br
on			br.idfsBaseReference = r_del.idfsBaseReference
left join	fnReferenceRepair('en', 19000033) r_t
	inner join	ffFormTemplate t
	on			t.idfsFormTemplate = r_t.idfsReference
on			r_t.idfsReference = r.idfsFormTemplate
left join	fnReferenceRepair('en', 19000034) ftype
on			ftype.idfsReference = t.idfsFormType
left join	#BR_To_Del br_del
on			br_del.idfsBaseReference = r_del.idfsBaseReference
where		br_del.idfsBaseReference is null
order by	ftype.[name], t.idfsFormType, r_t.[name], r.idfsFormTemplate, br_r.strDefault, r.idfsRule, br.idfsReferenceType, br.strDefault, br.idfsBaseReference

insert into	#LogTable (strMessage)
select		strDescription
from		#BR_To_Del
where		idfID > @FirstNumOfRef_To_Del
order by	idfID

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

select	@FirstNumOfRef_To_Del = max(idfID)
from	#BR_To_Del

if	@FirstNumOfRef_To_Del is null
begin
	set	@FirstNumOfRef_To_Del = 0
end


insert into	#Parameter_To_Del	(idfsParameter)
select		p.idfsParameter
from		ffParameter p
/*TODO:remove--
where		(	p.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	p.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
*/
where		(	p.idfsFormType not in
						(	10034012,	-- Human Aggregate case
							10034021,	-- Vet Aggregate Case
							10034022,	-- Vet Epizootic Action
							10034023,	-- Vet Epizootic Action Diagnosis Inv
							10034024,	-- Vet Epizootic Action Treatment
							-- Outbreak FF Types
							10034501,
							10034502,
							10034503,
							10034504,
							10034505,
							10034506,
							10034507,
							10034508,
							10034509			
						)
				or	(	p.idfsFormType in
						(	10034012,	-- Human Aggregate case
							10034021,	-- Vet Aggregate Case
							10034022,	-- Vet Epizootic Action
							10034023,	-- Vet Epizootic Action Diagnosis Inv
							10034024	-- Vet Epizootic Action Treatment
						)
						and p.idfsSection is not null
					)
			)


/*TODO:remove--
insert into	#Parameter_To_Del	(idfsParameter)
select		p.idfsParameter
from		ffParameter p
inner join	trtBaseReference br
on			br.idfsBaseReference = p.idfsParameter
left join	#Parameter_To_Del p_del
on			p_del.idfsParameter = br.idfsBaseReference
where		(	br.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	br.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
			and p_del.idfsParameter is null

insert into	#Parameter_To_Del	(idfsParameter)
select		p.idfsParameter
from		ffParameter p
inner join	#Section_To_Del s_del
on			s_del.idfsSection = p.idfsSection
left join	#Parameter_To_Del p_del
on			p_del.idfsParameter = p.idfsParameter
where		p_del.idfsParameter is null

insert into	#Parameter_To_Del	(idfsParameter)
select distinct
			p.idfsParameter
from		ffParameter p
inner join	trtBaseReference br
on			br.idfsBaseReference = p.idfsParameter
inner join	trtBaseReferenceToCP br_to_c
on			br_to_c.idfsBaseReference = br.idfsBaseReference
left join	trtBaseReferenceToCP br_to_correct_c
on			br_to_correct_c.idfsBaseReference = br.idfsBaseReference
			and br_to_correct_c.idfCustomizationPackage = @idfCustomizationPackage
left join	(
	ffParameterForTemplate pft
	left join	#Template_To_Del t_del
	on			t_del.idfsFormTemplate = pft.idfsFormTemplate
			)
on			pft.idfsParameter = p.idfsParameter
			and pft.intRowStatus = 0 -- do not belong to historical records
			and t_del.idfsFormTemplate is null
left join	#Parameter_To_Del p_del
on			p_del.idfsParameter = br.idfsBaseReference
where		--Comment for historical records--br.intRowStatus = 0
			--Comment for historical records--and 
				(	p.idfsFormType not in
						(	10034012,	-- Human Aggregate case
							10034021,	-- Vet Aggregate Case
							10034022,	-- Vet Epizootic Action
							10034023,	-- Vet Epizootic Action Diagnosis Inv
							10034024	-- Vet Epizootic Action Treatment
						)
					or	(	p.idfsFormType in
							(	10034012,	-- Human Aggregate case
								10034021,	-- Vet Aggregate Case
								10034022,	-- Vet Epizootic Action
								10034023,	-- Vet Epizootic Action Diagnosis Inv
								10034024	-- Vet Epizootic Action Treatment
							)
							and p.idfsSection is not null
						)
				)
			and br_to_correct_c.idfsBaseReference is null
			and pft.idfsParameter is null
			and p_del.idfsParameter is null
*/

create table	#P_To_Del
(	idfsParameter		bigint not null,
	idfsBaseReference	bigint not null primary key
)

insert into	#P_To_Del
(	idfsParameter,
	idfsBaseReference
)
select		p.idfsParameter,
			p.idfsParameterCaption
from		ffParameter p
inner join	#Parameter_To_Del p_del
on			p_del.idfsParameter = p.idfsParameter
left join	#Parameter_To_Del p_del_ex
	inner join	ffParameter p_ex
	on			p_ex.idfsParameter = p_del_ex.idfsParameter
on			p_ex.idfsParameterCaption = p.idfsParameterCaption
			and p_ex.idfsParameter < p.idfsParameter
where		p_del_ex.idfsParameter is null

insert into	#P_To_Del
(	idfsParameter,
	idfsBaseReference
)
select		p.idfsParameter,
			p.idfsParameter
from		ffParameter p
inner join	#Parameter_To_Del p_del
on			p_del.idfsParameter = p.idfsParameter
left join	#P_To_Del p_del_ex
on			p_del_ex.idfsBaseReference = p.idfsParameter
where		p_del_ex.idfsBaseReference is null


insert into	#LogTable (strMessage)
select	N'    FF parameters'' tooltips and captions to delete: '

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

insert into	#BR_To_Del	(idfsBaseReference, strDescription)
select		p_del.idfsBaseReference,
			case
				when	p_del.idfsBaseReference = p.idfsParameter
					then	N'    - FF Type [' + replace(IsNull(ftype.[name], N'*'), N'''', N'''''') +
							N'] parameter [' + replace(IsNull(br_p.strDefault, N'*'), N'''', N'''''') +
							N']: tooltip'
				else	N'    - FF Type [' + replace(IsNull(ftype.[name], N'*'), N'''', N'''''') +
						N'] parameter [' + replace(IsNull(br_p.strDefault, N'*'), N'''', N'''''') +
						N']: caption [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'
			end as strDescription
from		ffParameter p
inner join	#P_To_Del p_del
on			p_del.idfsParameter = p.idfsParameter
inner join	trtBaseReference br_p
on			br_p.idfsBaseReference = p.idfsParameter
inner join	trtBaseReference br
on			br.idfsBaseReference = p_del.idfsBaseReference
left join	fnReferenceRepair('en', 19000034) ftype
on			ftype.idfsReference = p.idfsFormType
left join	#BR_To_Del br_del
on			br_del.idfsBaseReference = p_del.idfsBaseReference
where		br_del.idfsBaseReference is null
order by	ftype.[name], p.idfsFormType, br_p.strDefault, p.idfsParameter, br.idfsReferenceType, br.strDefault, br.idfsBaseReference

insert into	#LogTable (strMessage)
select		strDescription
from		#BR_To_Del
where		idfID > @FirstNumOfRef_To_Del
order by	idfID

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

select	@FirstNumOfRef_To_Del = max(idfID)
from	#BR_To_Del

if	@FirstNumOfRef_To_Del is null
begin
	set	@FirstNumOfRef_To_Del = 0
end


insert into	#ParameterType_To_Del	(idfsParameterType)
select		pt.idfsParameterType
from		ffParameterType pt

/*TODO:remove--
where		(	pt.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	pt.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
*/
where		pt.idfsParameterType not in--System parameter Type
			(	10071025, -- Boolean
				10071029, -- Date
				10071030, -- DateTime
				10071045, -- String
				10071059, -- Numeric Natural
				10071060, -- Numeric Positive
				10071061, -- Numeric Integer
				10071501, -- Method of measurement, Ref Type: Basic Syndromic Surveillance - Method of Measurement
				10071502, -- Outcome, Ref Type: Case Outcome List
				10071503, -- Lab Test Result, Ref Type: Basic Syndromic Surveillance - Test Result
				10071504, -- Statement
				216820000000, -- Diagnosis List, Ref Type: Disease
				216880000000, -- Investigation Type, Ref Type: Diagnostic Investigation List
				217020000000, -- Prophylactic Action, Ref Type: Prophylactic Measure List
				217030000000, -- Sanitary Action, Ref Type: Sanitary Measure List
				217050000000, -- Species, Ref Type: Species List
				217140000000  -- Y_N_Unk, Ref Type: Yes/No Value List
			)
			and not exists
				(	select		1
					from		ffParameter p
					left join	#Parameter_To_Del p_del
					on			p_del.idfsParameter = p.idfsParameter
					where		p.idfsParameterType = pt.idfsParameterType
								and p_del.idfsParameter is null
				)

/*TODO:remove--
insert into	#ParameterType_To_Del	(idfsParameterType)
select		pt.idfsParameterType
from		ffParameterType pt
inner join	trtBaseReference br
on			br.idfsBaseReference = pt.idfsParameterType
left join	#ParameterType_To_Del pt_del
on			pt_del.idfsParameterType = br.idfsBaseReference
where		(	br.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	br.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
			and pt_del.idfsParameterType is null

insert into	#ParameterType_To_Del	(idfsParameterType)
select distinct
			pt.idfsParameterType
from		ffParameterType pt
inner join	trtBaseReference br
on			br.idfsBaseReference = pt.idfsParameterType
inner join	trtBaseReferenceToCP br_to_c
on			br_to_c.idfsBaseReference = br.idfsBaseReference
left join	trtBaseReferenceToCP br_to_correct_c
on			br_to_correct_c.idfsBaseReference = br.idfsBaseReference
			and br_to_correct_c.idfCustomizationPackage = @idfCustomizationPackage
left join	(
	ffParameter p
	left join	#Parameter_To_Del p_del
	on			p_del.idfsParameter = p.idfsParameter
			)
on			p.idfsParameterType = pt.idfsParameterType
			--Comment for historical records--and p.intRowStatus = 0
			and p_del.idfsParameter is null
left join	#ParameterType_To_Del pt_del
on			pt_del.idfsParameterType = br.idfsBaseReference
where		--Comment for historical records--br.intRowStatus = 0
			--Comment for historical records--and 
			pt.idfsReferenceType = 19000069		-- Flexible Form Parameter Value
			and br.strDefault <> N'Y_N_Unk'
			and br_to_correct_c.idfsBaseReference is null
			and p.idfsParameter is null
			and pt_del.idfsParameterType is null
*/

create table	#PT_To_Del
(	idfsParameterType	bigint not null,
	idfsBaseReference	bigint not null primary key
)

insert into	#PT_To_Del
(	idfsParameterType,
	idfsBaseReference
)
select		pt.idfsParameterType,
			pfpv.idfsParameterFixedPresetValue
from		ffParameterType pt
inner join	#ParameterType_To_Del pt_del
on			pt_del.idfsParameterType = pt.idfsParameterType
inner join	ffParameterFixedPresetValue pfpv
on			pfpv.idfsParameterType = pt.idfsParameterType

insert into	#PT_To_Del
(	idfsParameterType,
	idfsBaseReference
)
select		pt.idfsParameterType,
			pt.idfsParameterType
from		ffParameterType pt
inner join	#ParameterType_To_Del pt_del
on			pt_del.idfsParameterType = pt.idfsParameterType
left join	#PT_To_Del pt_del_ex
on			pt_del_ex.idfsBaseReference = pt.idfsParameterType
where		pt_del_ex.idfsBaseReference is null


insert into	#LogTable (strMessage)
select	N'    FF parameters'' types and their values from drop-down lists to delete: '

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

insert into	#BR_To_Del	(idfsBaseReference, strDescription)
select		pt_del.idfsBaseReference,
			case
				when	pt_del.idfsBaseReference = pt.idfsParameterType
					then	N'    - FF Parameter Type [' + replace(IsNull(br_pt.strDefault, N'*'), N'''', N'''''') +
							N']: name'
				else	N'    - FF Parameter Type [' + replace(IsNull(br_pt.strDefault, N'*'), N'''', N'''''') +
						N']: value [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'
			end as strDescription
from		ffParameterType pt
inner join	#PT_To_Del pt_del
on			pt_del.idfsParameterType = pt.idfsParameterType
inner join	trtBaseReference br_pt
on			br_pt.idfsBaseReference = pt.idfsParameterType
inner join	trtBaseReference br
on			br.idfsBaseReference = pt_del.idfsBaseReference
left join	#BR_To_Del br_del
on			br_del.idfsBaseReference = pt_del.idfsBaseReference
where		br_del.idfsBaseReference is null
order by	br_pt.strDefault asc, pt.idfsParameterType asc, br.idfsReferenceType desc, br.strDefault asc, br.idfsBaseReference asc

insert into	#LogTable (strMessage)
select		strDescription
from		#BR_To_Del
where		idfID > @FirstNumOfRef_To_Del
order by	idfID

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

select	@FirstNumOfRef_To_Del = max(idfID)
from	#BR_To_Del

if	@FirstNumOfRef_To_Del is null
begin
	set	@FirstNumOfRef_To_Del = 0
end

create table	#L_To_Del
(	idfsBaseReference	bigint not null primary key
)

insert into	#L_To_Del	(idfsBaseReference)
select distinct
			det.idfsBaseReference
from		ffFormTemplate ft
inner join	#Template_To_Del t_del
on			t_del.idfsFormTemplate = ft.idfsFormTemplate
inner join	ffDecorElement de
on			de.idfsFormTemplate = t_del.idfsFormTemplate
inner join	ffDecorElementText det
on			det.idfDecorElement = de.idfDecorElement

insert into	#L_To_Del	(idfsBaseReference)
select	distinct
			det.idfsBaseReference
from		ffSection s
inner join	#Section_To_Del s_del
on			s_del.idfsSection = s.idfsSection
inner join	ffDecorElement de
on			de.idfsSection = s_del.idfsSection
inner join	ffDecorElementText det
on			det.idfDecorElement = de.idfDecorElement
left join	#L_To_Del l_del
on			l_del.idfsBaseReference = det.idfsBaseReference
where		l_del.idfsBaseReference is null

insert into	#LogTable (strMessage)
select	N'    FF labels'' text to delete: '

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

insert into	#BR_To_Del	(idfsBaseReference, strDescription)
select		l_del.idfsBaseReference,
			case
				when	de.idfsSection is not null
					then	N'    - FF Type [' + replace(IsNull(ftype.[name], N'*'), N'''', N'''''') +
							N'] template [' + replace(IsNull(r_t.[name], N'*'), N'''', N'''''') + 
							N'] section [' + replace(IsNull(r_s.[name], N'*'), N'''', N'''''') +
							N']: label [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'
				else	N'    - FF Type [' + replace(IsNull(ftype.[name], N'*'), N'''', N'''''') +
						N'] template [' + replace(IsNull(r_t.[name], N'*'), N'''', N'''''') + 
						N']: label [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'
			end as strDescription
from		ffDecorElement de
inner join	ffDecorElementText det
on			det.idfDecorElement = de.idfDecorElement
inner join	#L_To_Del l_del
on			l_del.idfsBaseReference = det.idfsBaseReference
inner join	trtBaseReference br
on			br.idfsBaseReference = l_del.idfsBaseReference
left join	fnReferenceRepair('en', 19000033) r_t
	inner join	ffFormTemplate t
	on			t.idfsFormTemplate = r_t.idfsReference
on			r_t.idfsReference = de.idfsFormTemplate
left join	fnReferenceRepair('en', 19000034) ftype
on			ftype.idfsReference = t.idfsFormType
left join	fnReferenceRepair('en', 19000101) r_s
	inner join	ffSection s
	on			s.idfsSection = r_s.idfsReference
on			r_s.idfsReference = de.idfsSection
left join	ffDecorElement de_min
	inner join	ffDecorElementText det_min
	on			det_min.idfDecorElement = de_min.idfDecorElement
on			det_min.idfsBaseReference = l_del.idfsBaseReference
			and de_min.idfDecorElement < de.idfDecorElement
left join	#BR_To_Del br_del
on			br_del.idfsBaseReference = l_del.idfsBaseReference
where		de_min.idfDecorElement is null
			and	br_del.idfsBaseReference is null
order by	ftype.[name], t.idfsFormType, r_t.[name], de.idfsFormTemplate, r_s.[name], de.idfsSection, br.strDefault, br.idfsBaseReference

insert into	#LogTable (strMessage)
select		strDescription
from		#BR_To_Del
where		idfID > @FirstNumOfRef_To_Del
order by	idfID

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

select	@FirstNumOfRef_To_Del = max(idfID)
from	#BR_To_Del

if	@FirstNumOfRef_To_Del is null
begin
	set	@FirstNumOfRef_To_Del = 0
end

insert into	#LogTable (strMessage)
select	N''

-- Delete selected FF data with related info
delete		sf_to_p
from		tasSearchFieldToFFParameter sf_to_p
inner join	#Parameter_To_Del p_del
on			p_del.idfsParameter = sf_to_p.idfsParameter
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from AVR search fields to FF parameters by FF parameter (tasSearchFieldToFFParameter): ' + cast(@N as nvarchar(20))

delete		deffr
from		tdeDataExportFFReference deffr
inner join	#Parameter_To_Del p_del
on			p_del.idfsParameter = deffr.idfsParameter
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from parameters for export to WHO to FF parameters (tdeDataExportFFReference): ' + cast(@N as nvarchar(20))

delete		ffp_to_d_for_cr
from		trtFFObjectToDiagnosisForCustomReport ffp_to_d_for_cr
inner join	trtFFObjectForCustomReport ffp_for_cr
on			ffp_for_cr.idfFFObjectForCustomReport = ffp_to_d_for_cr.idfFFObjectForCustomReport
inner join	#Parameter_To_Del p_del
on			p_del.idfsParameter = ffp_for_cr.idfsFFObject
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from diagnosis specific parameters of custom reports to FF parameters (trtFFObjectToDiagnosisForCustomReport): ' + cast(@N as nvarchar(20))

delete		ffp_to_d_for_cr
from		trtFFObjectToDiagnosisForCustomReport ffp_to_d_for_cr
inner join	trtFFObjectForCustomReport ffp_for_cr
on			ffp_for_cr.idfFFObjectForCustomReport = ffp_to_d_for_cr.idfFFObjectForCustomReport
inner join	#Section_To_Del s_del
on			s_del.idfsSection = ffp_for_cr.idfsFFObject
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from diagnosis specific parameters of custom reports to FF sections (trtFFObjectToDiagnosisForCustomReport): ' + cast(@N as nvarchar(20))

delete		ffp_to_d_for_cr
from		trtFFObjectToDiagnosisForCustomReport ffp_to_d_for_cr
inner join	trtFFObjectForCustomReport ffp_for_cr
on			ffp_for_cr.idfFFObjectForCustomReport = ffp_to_d_for_cr.idfFFObjectForCustomReport
inner join	ffParameterFixedPresetValue pfpv
on			pfpv.idfsParameterFixedPresetValue = ffp_for_cr.idfsFFObject
inner join	#ParameterType_To_Del pt_del
on			pt_del.idfsParameterType = pfpv.idfsParameterType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from diagnosis specific parameters of custom reports to FF parameters'' values (trtFFObjectToDiagnosisForCustomReport): ' + cast(@N as nvarchar(20))


delete		ffp_for_cr
from		trtFFObjectForCustomReport ffp_for_cr
inner join	#Parameter_To_Del p_del
on			p_del.idfsParameter = ffp_for_cr.idfsFFObject
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from parameters of custom reports to FF parameters (trtFFObjectForCustomReport): ' + cast(@N as nvarchar(20))

delete		ffp_for_cr
from		trtFFObjectForCustomReport ffp_for_cr
inner join	#Section_To_Del s_del
on			s_del.idfsSection = ffp_for_cr.idfsFFObject
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from parameters of custom reports to FF sections (trtFFObjectForCustomReport): ' + cast(@N as nvarchar(20))

delete		ffp_for_cr
from		trtFFObjectForCustomReport ffp_for_cr
inner join	ffParameterFixedPresetValue pfpv
on			pfpv.idfsParameterFixedPresetValue = ffp_for_cr.idfsFFObject
inner join	#ParameterType_To_Del pt_del
on			pt_del.idfsParameterType = pfpv.idfsParameterType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from parameters of custom reports to FF parameters'' values (trtFFObjectForCustomReport): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

delete		det
from		ffDecorElementText det
where		det.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Labels marked as deleted (ffDecorElementText): ' + cast(@N as nvarchar(20))

delete		det
from		ffFormTemplate ft
inner join	#Template_To_Del t_del
on			t_del.idfsFormTemplate = ft.idfsFormTemplate
inner join	ffDecorElement de
on			de.idfsFormTemplate = t_del.idfsFormTemplate
inner join	ffDecorElementText det
on			det.idfDecorElement = de.idfDecorElement
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Labels on FF templates (ffDecorElementText): ' + cast(@N as nvarchar(20))

delete		det
from		ffSection s
inner join	#Section_To_Del s_del
on			s_del.idfsSection = s.idfsSection
inner join	ffDecorElement de
on			de.idfsSection = s_del.idfsSection
inner join	ffDecorElementText det
on			det.idfDecorElement = de.idfDecorElement
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Labels in FF sections (ffDecorElementText): ' + cast(@N as nvarchar(20))

delete		del
from		ffDecorElementLine del
where		del.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Lines marked as deleted (ffDecorElementText): ' + cast(@N as nvarchar(20))

delete		del
from		ffFormTemplate ft
inner join	#Template_To_Del t_del
on			t_del.idfsFormTemplate = ft.idfsFormTemplate
inner join	ffDecorElement de
on			de.idfsFormTemplate = t_del.idfsFormTemplate
inner join	ffDecorElementLine del
on			del.idfDecorElement = de.idfDecorElement
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Lines on FF templates (ffDecorElementLine): ' + cast(@N as nvarchar(20))

delete		del
from		ffSection s
inner join	#Section_To_Del s_del
on			s_del.idfsSection = s.idfsSection
inner join	ffDecorElement de
on			de.idfsSection = s_del.idfsSection
inner join	ffDecorElementLine del
on			del.idfDecorElement = de.idfDecorElement
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Lines in FF sections (ffDecorElementLine): ' + cast(@N as nvarchar(20))

delete		de
from		ffDecorElement de
where		de.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Labels and/or lines marked as deleted (ffDecorElementText): ' + cast(@N as nvarchar(20))

delete		de
from		ffFormTemplate ft
inner join	#Template_To_Del t_del
on			t_del.idfsFormTemplate = ft.idfsFormTemplate
inner join	ffDecorElement de
on			de.idfsFormTemplate = t_del.idfsFormTemplate
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Labels and/or lines on FF templates (ffDecorElement): ' + cast(@N as nvarchar(20))

delete		de
from		ffSection s
inner join	#Section_To_Del s_del
on			s_del.idfsSection = s.idfsSection
inner join	ffDecorElement de
on			de.idfsSection = s_del.idfsSection
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Labels and/or lines in FF sections (ffDecorElement): ' + cast(@N as nvarchar(20))

delete		de
from		ffDecorElement de
left join	ffDecorElementLine del
on			del.idfDecorElement = de.idfDecorElement
left join	ffDecorElementText det
on			det.idfDecorElement = de.idfDecorElement
where		del.idfDecorElement is null
			and det.idfDecorElement is null
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Labels and/or lines (ffDecorElement): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

delete		pfa
from		ffParameterForAction pfa
where		pfa.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Actions, marked as deleted, with FF parameters for FF rules (ffParameterForAction): ' + cast(@N as nvarchar(20))

delete		pfa
from		ffParameterForAction pfa
inner join	#Parameter_To_Del p_del
on			p_del.idfsParameter = pfa.idfsParameter
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Actions with FF parameters for FF rules by FF parameters (ffParameterForAction): ' + cast(@N as nvarchar(20))

delete		pfa
from		ffParameterForAction pfa
inner join	#Template_To_Del t_del
on			t_del.idfsFormTemplate = pfa.idfsFormTemplate
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Actions with FF parameters for FF rules by FF templates (ffParameterForAction): ' + cast(@N as nvarchar(20))

delete		pfa
from		ffParameterForAction pfa
inner join	#Rule_To_Del r_del
on			r_del.idfsRule = pfa.idfsRule
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Actions with FF parameters for FF rules by FF rules (ffParameterForAction): ' + cast(@N as nvarchar(20))

delete		sfa
from		ffSectionForAction sfa
where		sfa.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Actions, marked as deleted, with FF sections for FF rules (ffSectionForAction): ' + cast(@N as nvarchar(20))

delete		sfa
from		ffSectionForAction sfa
inner join	#Section_To_Del s_del
on			s_del.idfsSection = sfa.idfsSection
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Actions with FF sections for FF rules by FF sections (ffSectionForAction): ' + cast(@N as nvarchar(20))

delete		sfa
from		ffSectionForAction sfa
inner join	#Template_To_Del t_del
on			t_del.idfsFormTemplate = sfa.idfsFormTemplate
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Actions with FF sections for FF rules by FF templates (ffSectionForAction): ' + cast(@N as nvarchar(20))

delete		sfa
from		ffSectionForAction sfa
inner join	#Rule_To_Del r_del
on			r_del.idfsRule = sfa.idfsRule
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Actions with FF sections for FF rules by FF rules (ffSectionForAction): ' + cast(@N as nvarchar(20))

delete		pff
from		ffParameterForFunction pff
where		pff.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    FF parameters as variables of FF rules'' functions, marked as deleted (ffParameterForFunction): ' + cast(@N as nvarchar(20))

delete		pff
from		ffParameterForFunction pff
inner join	#Parameter_To_Del p_del
on			p_del.idfsParameter = pff.idfsParameter
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    FF parameters as variables of FF rules'' functions by FF parameters (ffParameterForFunction): ' + cast(@N as nvarchar(20))

delete		pff
from		ffParameterForFunction pff
inner join	#Template_To_Del t_del
on			t_del.idfsFormTemplate = pff.idfsFormTemplate
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    FF parameters as variables of FF rules'' functions by FF templates (ffParameterForFunction): ' + cast(@N as nvarchar(20))

delete		pff
from		ffParameterForFunction pff
inner join	#Rule_To_Del r_del
on			r_del.idfsRule = pff.idfsRule
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    FF parameters as variables of FF rules'' functions by FF rules (ffParameterForFunction): ' + cast(@N as nvarchar(20))

delete		rc
from		ffRuleConstant rc
where		rc.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    FF rules'' constants, marked as deleted (ffRuleConstant): ' + cast(@N as nvarchar(20))

delete		rc
from		ffRuleConstant rc
inner join	#Rule_To_Del r_del
on			r_del.idfsRule = rc.idfsRule
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    FF rules'' constants by FF rule (ffRuleConstant): ' + cast(@N as nvarchar(20))

delete		r
from		ffRule r
inner join	#Rule_To_Del r_del
on			r_del.idfsRule = r.idfsRule
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    FF rules (ffRule): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

delete		dv
from		ffDeterminantValue dv
where		dv.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    FF templates'' determinants, marked as deleted (ffDeterminantValue): ' + cast(@N as nvarchar(20))

delete		dv
from		ffDeterminantValue dv
inner join	#Template_To_Del t_del
on			t_del.idfsFormTemplate = dv.idfsFormTemplate
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    FF templates'' determinants by FF template (ffDeterminantValue): ' + cast(@N as nvarchar(20))

delete		pdo
from		ffParameterDesignOption pdo
where		pdo.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    FF parameters'' design options (default and in FF templates), marked as deleted (ffParameterDesignOption): ' + cast(@N as nvarchar(20))

delete		pdo
from		ffParameterDesignOption pdo
inner join	#Parameter_To_Del p_del
on			p_del.idfsParameter = pdo.idfsParameter
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    FF parameters'' design options (default and in FF templates) by FF parameters (ffParameterDesignOption): ' + cast(@N as nvarchar(20))

delete		pdo
from		ffParameterDesignOption pdo
inner join	#Template_To_Del t_del
on			t_del.idfsFormTemplate = pdo.idfsFormTemplate
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    FF parameters'' design options in FF templates by FF templates (ffParameterDesignOption): ' + cast(@N as nvarchar(20))

delete		sdo
from		ffSectionDesignOption sdo
where		sdo.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    FF sections'' design options, marked as deleted, in FF templates (ffSectionDesignOption): ' + cast(@N as nvarchar(20))

delete		sdo
from		ffSectionDesignOption sdo
inner join	#Section_To_Del s_del
on			s_del.idfsSection = sdo.idfsSection
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    FF sections'' design options in FF templates by FF sections (ffSectionDesignOption): ' + cast(@N as nvarchar(20))

delete		sdo
from		ffSectionDesignOption sdo
inner join	#Template_To_Del t_del
on			t_del.idfsFormTemplate = sdo.idfsFormTemplate
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    FF sections'' design options in FF templates by FF templates (ffSectionDesignOption): ' + cast(@N as nvarchar(20))

delete		pft
from		ffParameterForTemplate pft
where		pft.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Participation of FF parameters in FF templates, marked as deleted (ffParameterForTemplate): ' + cast(@N as nvarchar(20))

delete		pft
from		ffParameterForTemplate pft
inner join	#Parameter_To_Del p_del
on			p_del.idfsParameter = pft.idfsParameter
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Participation of FF parameters in FF templates by FF parameters (ffParameterForTemplate): ' + cast(@N as nvarchar(20))

delete		pft
from		ffParameterForTemplate pft
inner join	#Template_To_Del t_del
on			t_del.idfsFormTemplate = pft.idfsFormTemplate
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Participation of FF parameters in FF templates by FF templates (ffParameterForTemplate): ' + cast(@N as nvarchar(20))

delete		sft
from		ffSectionForTemplate sft
where		sft.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Participation of FF sections in FF templates, marked as deleted (ffSectionForTemplate): ' + cast(@N as nvarchar(20))

delete		sft
from		ffSectionForTemplate sft
inner join	#Section_To_Del s_del
on			s_del.idfsSection = sft.idfsSection
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Participation of FF sections in FF templates by FF sections (ffSectionForTemplate): ' + cast(@N as nvarchar(20))

delete		sft
from		ffSectionForTemplate sft
inner join	#Template_To_Del t_del
on			t_del.idfsFormTemplate = sft.idfsFormTemplate
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Participation of FF sections in FF templates by FF templates (ffSectionForTemplate): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

delete		ft
from		ffFormTemplate ft
inner join	#Template_To_Del t_del
on			t_del.idfsFormTemplate = ft.idfsFormTemplate
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    FF templates (ffFormTemplate): ' + cast(@N as nvarchar(20))

delete		pfpv
from		ffParameterFixedPresetValue pfpv
where		(	pfpv.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	pfpv.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
set	@N = @@rowcount

if	@DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'    FF parameters'' values in drop-down lists, marked as deleted (ffParameterFixedPresetValue): ' + cast(@N as nvarchar(20))


delete		pfpv
from		ffParameterFixedPresetValue pfpv
inner join	#ParameterType_To_Del pt_del
on			pt_del.idfsParameterType = pfpv.idfsParameterType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    FF parameters'' values in drop-down lists by FF parameter type (ffParameterFixedPresetValue): ' + cast(@N as nvarchar(20))

delete		p
from		ffParameter p
inner join	#Parameter_To_Del p_del
on			p_del.idfsParameter = p.idfsParameter
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    FF parameters (ffParameter): ' + cast(@N as nvarchar(20))

delete		pt
from		ffParameterType pt
inner join	#ParameterType_To_Del pt_del
on			pt_del.idfsParameterType = pt.idfsParameterType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    FF parameters'' types /drop-down lists/ (ffParameterType): ' + cast(@N as nvarchar(20))

delete		s
from		ffSection s
inner join	#Section_To_Del s_del
on			s_del.idfsSection = s.idfsSection
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    FF sections (ffSection): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

delete		dv
from		ffDeterminantValue dv
where		dv.idfsGISBaseReference is not null
			and dv.idfsGISBaseReference <> @Country
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    FF templates'' country determinants containing the country with HASC distinct from [' + @CountryHASC + N'] (ffDeterminantValue): ' + cast(@N as nvarchar(20))

if @CustomizationPackage = N'DTRA'
begin
	update		dv
	set			dv.idfsGISBaseReference = @AdminInfoCountry
	from		ffDeterminantValue dv
	where		dv.idfsGISBaseReference = @Country

	insert into	#LogTable (strMessage)
	select	N'    Replace FF templates'' country determinants containing the country with HASC [' + @CountryHASC + N'] by the country with HASC [' + @AdminInfoCountryHASC + N'] (ffDeterminantValue): ' + cast(@N as nvarchar(20))
end

insert into	#LogTable (strMessage)
select	N''

insert into	#LogTable (strMessage)
select	N''


insert into	#BR_To_Del	(idfsBaseReference, strDescription)
select		br.idfsBaseReference,
			N'    - ' + replace(IsNull(rt.strReferenceTypeName, N'*'), N'''', N'''''') + N': [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'
from		trtBaseReference br
inner join	trtReferenceType rt	-- Reference Type Name
on			rt.idfsReferenceType = br.idfsReferenceType
left join	ffFormTemplate ft
on			ft.idfsFormTemplate = br.idfsBaseReference
left join	#BR_To_Del br_del
on			br_del.idfsBaseReference = br.idfsBaseReference
where		br.idfsReferenceType = 19000033		-- Flexible Form Template
			and ft.idfsFormTemplate is null
			and br_del.idfsBaseReference is null
order by	br.strDefault, br.idfsBaseReference

insert into	#BR_To_Del	(idfsBaseReference, strDescription)
select		br.idfsBaseReference,
			N'    - ' + replace(IsNull(rt.strReferenceTypeName, N'*'), N'''', N'''''') + N': [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'
from		trtBaseReference br
inner join	trtReferenceType rt	-- Reference Type Name
on			rt.idfsReferenceType = br.idfsReferenceType
left join	ffSection s
on			s.idfsSection = br.idfsBaseReference
left join	#BR_To_Del br_del
on			br_del.idfsBaseReference = br.idfsBaseReference
where		br.idfsReferenceType = 19000101		-- Flexible Form Section
			and s.idfsSection is null
			and br_del.idfsBaseReference is null
order by	br.strDefault, br.idfsBaseReference

insert into	#BR_To_Del	(idfsBaseReference, strDescription)
select		br.idfsBaseReference,
			N'    - ' + replace(IsNull(rt.strReferenceTypeName, N'*'), N'''', N'''''') + N': [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'
from		trtBaseReference br
inner join	trtReferenceType rt	-- Reference Type Name
on			rt.idfsReferenceType = br.idfsReferenceType
left join	ffParameter p
on			p.idfsParameter = br.idfsBaseReference
left join	#BR_To_Del br_del
on			br_del.idfsBaseReference = br.idfsBaseReference
where		br.idfsReferenceType = 19000066		-- Flexible Form Parameter
			and p.idfsParameter is null
			and br_del.idfsBaseReference is null
order by	br.strDefault, br.idfsBaseReference

insert into	#BR_To_Del	(idfsBaseReference, strDescription)
select		br.idfsBaseReference,
			N'    - ' + replace(IsNull(rt.strReferenceTypeName, N'*'), N'''', N'''''') + N': [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'
from		trtBaseReference br
inner join	trtReferenceType rt	-- Reference Type Name
on			rt.idfsReferenceType = br.idfsReferenceType
left join	ffParameter p
on			p.idfsParameterCaption = br.idfsBaseReference
left join	#BR_To_Del br_del
on			br_del.idfsBaseReference = br.idfsBaseReference
where		br.idfsReferenceType = 19000070		-- Flexible Form Parameter Tooltip
			and p.idfsParameter is null
			and br_del.idfsBaseReference is null
order by	br.strDefault, br.idfsBaseReference

insert into	#BR_To_Del	(idfsBaseReference, strDescription)
select		br.idfsBaseReference,
			N'    - ' + replace(IsNull(rt.strReferenceTypeName, N'*'), N'''', N'''''') + N': [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'
from		trtBaseReference br
inner join	trtReferenceType rt	-- Reference Type Name
on			rt.idfsReferenceType = br.idfsReferenceType
left join	ffDecorElementText det
on			det.idfsBaseReference = br.idfsBaseReference
left join	#BR_To_Del br_del
on			br_del.idfsBaseReference = br.idfsBaseReference
where		br.idfsReferenceType = 19000131		-- Flexible Form Label Text
			and det.idfDecorElement is null
			and br_del.idfsBaseReference is null
order by	br.strDefault, br.idfsBaseReference

insert into	#BR_To_Del	(idfsBaseReference, strDescription)
select		br.idfsBaseReference,
			N'    - ' + replace(IsNull(rt.strReferenceTypeName, N'*'), N'''', N'''''') + N': [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'
from		trtBaseReference br
inner join	trtReferenceType rt	-- Reference Type Name
on			rt.idfsReferenceType = br.idfsReferenceType
left join	ffRule r
on			r.idfsRule = br.idfsBaseReference
left join	#BR_To_Del br_del
on			br_del.idfsBaseReference = br.idfsBaseReference
where		br.idfsReferenceType = 19000029		-- Flexible Form Rule
			and r.idfsRule is null
			and br_del.idfsBaseReference is null
order by	br.strDefault, br.idfsBaseReference

insert into	#BR_To_Del	(idfsBaseReference, strDescription)
select		br.idfsBaseReference,
			N'    - ' + replace(IsNull(rt.strReferenceTypeName, N'*'), N'''', N'''''') + N': [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'
from		trtBaseReference br
inner join	trtReferenceType rt	-- Reference Type Name
on			rt.idfsReferenceType = br.idfsReferenceType
left join	ffRule r
on			r.idfsRuleMessage = br.idfsBaseReference
left join	#BR_To_Del br_del
on			br_del.idfsBaseReference = br.idfsBaseReference
where		br.idfsReferenceType = 19000032		-- Flexible Form Rule Message
			and r.idfsRule is null
			and br_del.idfsBaseReference is null
order by	br.strDefault, br.idfsBaseReference

insert into	#BR_To_Del	(idfsBaseReference, strDescription)
select		br.idfsBaseReference,
			N'    - ' + replace(IsNull(rt.strReferenceTypeName, N'*'), N'''', N'''''') + N': [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'
from		trtBaseReference br
inner join	trtReferenceType rt	-- Reference Type Name
on			rt.idfsReferenceType = br.idfsReferenceType
left join	ffParameterType pt
on			pt.idfsParameterType = br.idfsBaseReference
left join	#BR_To_Del br_del
on			br_del.idfsBaseReference = br.idfsBaseReference
where		br.idfsReferenceType = 19000071		-- Flexible Form Parameter Type
			and pt.idfsParameterType is null
			and br_del.idfsBaseReference is null
order by	br.strDefault, br.idfsBaseReference

insert into	#BR_To_Del	(idfsBaseReference, strDescription)
select		br.idfsBaseReference,
			N'    - ' + replace(IsNull(rt.strReferenceTypeName, N'*'), N'''', N'''''') + N': [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'
from		trtBaseReference br
inner join	trtReferenceType rt	-- Reference Type Name
on			rt.idfsReferenceType = br.idfsReferenceType
left join	ffParameterFixedPresetValue pfpv
on			pfpv.idfsParameterFixedPresetValue = br.idfsBaseReference
left join	#BR_To_Del br_del
on			br_del.idfsBaseReference = br.idfsBaseReference
where		br.idfsReferenceType = 19000069		-- Flexible Form Parameter Value
			and pfpv.idfsParameterFixedPresetValue is null
			and br_del.idfsBaseReference is null
order by	br.strDefault, br.idfsBaseReference

insert into	#LogTable (strMessage)
select	N'    FF reference values not linked to any FF object: '

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

insert into	#LogTable (strMessage)
select		strDescription
from		#BR_To_Del
where		idfID > @FirstNumOfRef_To_Del
order by	idfID

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

select	@FirstNumOfRef_To_Del = max(idfID)
from	#BR_To_Del

if	@FirstNumOfRef_To_Del is null
begin
	set	@FirstNumOfRef_To_Del = 0
end

insert into	#LogTable (strMessage)
select	N''
/*TODO:remove--

-- Update country-specific reference Accessory Code and Order
update		br
set			br.intHACode = br_to_c.intHACode,
			br.intOrder = br_to_c.intOrder
from		trtBaseReference br
inner join	trtBaseReferenceToCP br_to_c
on			br_to_c.idfsBaseReference = br.idfsBaseReference
			and br_to_c.idfCustomizationPackage = @idfCustomizationPackage
where		(	IsNull(br.intHACode, -1) <> IsNull(br_to_c.intHACode, -1)
				or	IsNull(br.intOrder, -1000) <> IsNull(br_to_c.intOrder, -1000)
			)
			-- Apply for those references, which belong to at least two customization packages, only!
			and exists	(
					select	*
					from	trtBaseReferenceToCP br_to_c_another
					where	br_to_c_another.idfsBaseReference = br.idfsBaseReference
							and br_to_c_another.idfCustomizationPackage <> @idfCustomizationPackage
						)
--Comment for historical records--			and	br.intRowStatus = 0
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'Update Accessory Codes and Orders of reference values specific for customization package [' + @CustomizationPackage + N'] (trtBaseReference): ' + cast(@N as nvarchar(20)) 

-- TODO: Update country-specific organization Accessory Code 

update		snt
set			snt.strTextString = snt_c.strTextString,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtStringNameTranslationToCP snt_c
on			snt_c.idfsBaseReference = snt.idfsBaseReference
			and snt_c.idfsLanguage = snt.idfsLanguage
			and snt_c.idfCustomizationPackage = @idfCustomizationPackage
where		(	IsNull(snt.strTextString, N'Not specified') <> IsNull(snt_c.strTextString, N'')
				or	snt.intRowStatus <> 0
			)
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'Update translations of reference values specific for customization package [' + @CustomizationPackage + N'] (trtStringNameTranslation): ' + cast(@N as nvarchar(20)) 
*/

insert into	#LogTable (strMessage)
select	N''

-- Add reference to deleted table
/*TODO:remove--
insert into	#BR_To_Del	(idfsBaseReference, strDescription)
select		br.idfsBaseReference,
			N'    - ' + replace(IsNull(rt.strReferenceTypeName, N'*'), N'''', N'''''') + N': [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'
from		trtBaseReference br
inner join	trtReferenceType rt	-- Reference Type Name
on			rt.idfsReferenceType = br.idfsReferenceType
left join	#BR_To_Del br_del
on			br_del.idfsBaseReference = br.idfsBaseReference
where		(	br.intRowStatus <> 0
				and (	br.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
			-- TODO: Remove from v.6 - start
			and br.idfsReferenceType not in
				(	
					19000025	-- Event Type
				)
			-- TODO: Remove from v.6 - end
			and (	(	not exists	(
							select	*
							from		trtDiagnosis d
							inner join	trtBaseReferenceToCP brc
							on			brc.idfsBaseReference = d.idfsDiagnosis
							inner join	tstCustomizationPackage cp
							on			cp.idfCustomizationPackage = brc.idfCustomizationPackage
										and cp.strCustomizationPackageName = N'Georgia'
							where		d.intRowStatus = 1
										and d.idfsDiagnosis = br.idfsBaseReference
								)
						and @DeletionFlag = 1
					)
					or	IsNull(@CustomizationPackage, N'DTRA') <> N'Georgia'
					or	@DeletionFlag <> 1
				)
			and @DeleteHistoricalRecordsMarkedAsDeleted = 1
			and br_del.idfsBaseReference is null
order by	rt.strReferenceTypeName, br.idfsReferenceType, br.strDefault, br.idfsBaseReference

if	@DeleteHistoricalRecordsMarkedAsDeleted = 1
begin
	insert into	#LogTable (strMessage)
	select	N'Reference values marked as deleted to delete: '

	insert into	#LogTable (strMessage)
	select	N'-----------------------------------'

	insert into	#LogTable (strMessage)
	select		strDescription
	from		#BR_To_Del
	where		idfID > @FirstNumOfRef_To_Del
	order by	idfID

	insert into	#LogTable (strMessage)
	select	N'-----------------------------------'

	select	@FirstNumOfRef_To_Del = max(idfID)
	from	#BR_To_Del

	if	@FirstNumOfRef_To_Del is null
	begin
		set	@FirstNumOfRef_To_Del = 0
	end

	insert into	#LogTable (strMessage)
	select	N''
end
*/
-- TODO: update the list of reference types and values-exceptions
-- TODO: Add types and/or values that should be deleted
insert into	#BR_To_Del	(idfsBaseReference, strDescription)
select		br.idfsBaseReference,
			N'    - ' + replace(IsNull(rt.strReferenceTypeName, N'*'), N'''', N'''''') + N': [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'
from		trtBaseReference br
inner join	trtReferenceType rt	-- Reference Type Name
on			rt.idfsReferenceType = br.idfsReferenceType
/*TODO:remove--
inner join	trtBaseReferenceToCP br_to_c
on			br_to_c.idfsBaseReference = br.idfsBaseReference
left join	trtBaseReferenceToCP br_to_c_min
on			br_to_c_min.idfsBaseReference = br.idfsBaseReference
			and br_to_c_min.idfCustomizationPackage < br_to_c.idfCustomizationPackage
left join	trtBaseReferenceToCP br_to_correct_c
on			br_to_correct_c.idfsBaseReference = br.idfsBaseReference
			and br_to_correct_c.idfCustomizationPackage = @idfCustomizationPackage
*/
left join	#BR_To_Del br_del
on			br_del.idfsBaseReference = br.idfsBaseReference
where		--Comment for historical records--br.intRowStatus = 0
			--Comment for historical records--and 
			br.idfsReferenceType in
			(	19000165, -- Aberration Analysis Method
				--System--19000515, -- Access Permission
				--present above in separate selection--119000537, -- Access Rule
				--System--19000110, -- Accession Condition
				--System--19000040, -- Accessory List
				--System--19000527, -- Account State
				--System--19000003, -- Administrative Level
				19000146, -- Age Groups
				--System--19000102, -- Aggregate Case Type
				19000005, -- Animal Age
				--System--19000007, -- Animal Sex
				19000006, -- Animal/Bird Status

				--System--19000115, -- AS Campaign Status
				--System--19000116, -- AS Campaign Type
				--System--19000128, -- AS Session Action Status
				--System--19000127, -- AS Session Action Type
				--System--19000117, -- AS Session Status
				--System--19000538, -- AS Species Type
				--System--19000009, -- Avian Farm Production Type
				--System--19000008, -- Avian Farm Type
				--System--19000004, -- AVR Aggregate Function

				--System--19000004, -- AVR Aggregate Function
				--Will be processed separately--19000125, -- AVR Chart Name
				--System--19000013, -- AVR Chart Type
				--Will be processed separately--19000123, -- AVR Folder Name
				--System--19000039, -- AVR Group Date
				--Will be processed separately--19000122, -- AVR Layout Description
				--Will be processed separately--19000143, -- AVR Layout Field Name
				--Will be processed separately--19000050, -- AVR Layout Name
				--Will be processed separately--19000126, -- AVR Map Name
				--Will be processed separately--19000121, -- AVR Query Description
				--Will be processed separately--19000075, -- AVR Query Name
				--Will be processed separately--19000124, -- AVR Report Name
				--will be marked as deleted--19000080, -- AVR Search Field
				--System--19000081, -- AVR Search Field Type
				--will be marked as deleted--19000082, -- AVR Search Object
				--System--19000163, -- Basic Syndromic Surveillance - Aggregate Columns
				--System--19000160, -- Basic Syndromic Surveillance - Method of Measurement
				--System--19000161, -- Basic Syndromic Surveillance - Outcome
				--System--19000162, -- Basic Syndromic Surveillance - Test Result
				--System--19000159, -- Basic Syndromic Surveillance - Type
				--System--19000137, -- Basis of record
				--System--19000501, -- Campaign Category
				--System--19000011, -- Case Classification
				19000064, -- Case Outcome List
				--System--19000144, -- Case Report Type
				--System--19000111, -- Case Status
				--System--19000012, -- Case Type
				19000135, -- Collection method
				--System--19000136, -- Collection time period
				--System--19000120, -- Configuration Description
				--System--19000500, -- Contact Phone Type
				19000129, -- Custom Report Type
				--System--19000016, -- Data Audit Event Type
				--System--19000017, -- Data Audit Object Type
				--System--19000018, -- Data Export Detail Status
				--present above in separate selection--19000164, -- Departament Name
				--System--19000157, -- Destruction Method
				19000156, -- Diagnoses Groups
				19000021, -- Diagnostic Investigation List
				--System--19000020, -- Diagnosis Using Type
				19000019, -- Disease
				--System--19000503, -- Disease Report Relationship
				--System--19000510, -- EIDSSAppModuleGroup
				--System--19000506, -- EIDSSAppObjectList
				--System--19000505, -- EIDSSAppObjectType
				--System--19000509, -- EIDSSAppPreference
				--System--19000511, -- EIDSSAuditParameters
				--System--19000508, -- EIDSSModuleConstant
				--System--19000507, -- EIDSSPageTitle
				--System--19000526, -- Employee Category
				--present above in separate selection--19000022, -- Employee Group Name
				--System--19000073, -- Employee Position
				--System--19000023, -- Employee Type
				--System--19000024, -- Event Information String
				--System--19000155, -- Event Subscriptions
				--System--19000025, -- Event Type
				--System--19000037, -- Farm Grazing Pattern
				--System--19000026, -- Farm Intended Use
				--System--19000053, -- Farm Movement Pattern
				--System--19000065, -- Farm Ownership Type
				--System--19000027, -- Farming System

				--System--19000028, -- Flexible Form Check Point
				--System--19000108, -- Flexible Form Decorate Element Type
				--present above in separate selection--19000131, -- Flexible Form Label Text
				--present above in separate selection--19000066, -- Flexible Form Parameter Caption
				--System--19000067, -- Flexible Form Parameter Editor
				--System--19000068, -- Flexible Form Parameter Mode
				--present above in separate selection--19000070, -- Flexible Form Parameter Tooltip
				--present above in separate selection--19000071, -- Flexible Form Parameter Type
				--present above in separate selection--19000069, -- Flexible Form Parameter Value
				--present above in separate selection--19000029, -- Flexible Form Rule
				--System--19000030, -- Flexible Form Rule Action
				--System--19000031, -- Flexible Form Rule Function
				--present above in separate selection--19000032, -- Flexible Form Rule Message
				--present above in separate selection--19000101, -- Flexible Form Section
				--System--19000525, -- Flexible Form Section Type
				--present above in separate selection--19000033, -- Flexible Form Template
				--System--19000034, -- Flexible Form Type

				--System--19000512, -- Freezer Box Size
				--System--19000093, -- Freezer Subdivision Type
				--System--19000036, -- Geo Location Type
				--System--19000038, -- Ground Type
				--System--19000042, -- Human Age Type
				--System--19000043, -- Human Gender
				--System--19000138, -- Identification method
				--System--19000044, -- Information String
				--System--19000049, -- Language
				--System--19000522, -- Legal Form
				--System--19000051, -- Livestock Farm Production Type
				--System--19000523, -- Main Form of Activity
				--System--19000152, -- Matrix Column
				--System--19000151, -- Matrix Type

				19000054, -- Nationality List
				19000149, -- Non-Notifiable Diagnosis

				--System--19000055, -- Notification Object Type
				--System--19000056, -- Notification Type
				--System--19000057, -- Numbering Schema Document Type
				--System--19000060, -- Object Type
				--System--19000109, -- Object Type Relation

				19000061, -- Occupation Type

				--System--19000062, -- Office Type

				--present above in separate selection--19000045, -- Organization Abbreviation
				--present above in separate selection--19000046, -- Organization Name

				--System--19000504, -- Organization Type
				--System--19000520, -- Outbreak Case Status
				--System--19000517, -- Outbreak Contact Status
				--System--19000516, -- Outbreak Contact Type
				--System--19000514, -- Outbreak Species Group
				--System--19000063, -- Outbreak Status
				--System--19000513, -- Outbreak Type
				--System--19000518, -- Outbreak Update Priority
				--System--19000521, -- Ownership Form
				--System--19000072, -- Party Type
				--System--19000014, -- Patient Contact Type
				--System--19000041, -- Patient Location Type
				19000035, -- Patient State
				--System--19000134, -- Penside Test Category
				19000104, -- Penside Test Name
				19000105, -- Penside Test Result
				--System--19000148, -- Personal ID Type

				19000074, -- Prophylactic Measure List

				--System--19000147, -- Reason for Changed Diagnosis
				--System--19000150, -- Reason for not Collecting Sample
				--System--19000076, -- Reference Type Name

				19000132, -- Report Additional Text
				19000130, -- Report Diagnoses Group

				--System--19000502, -- Report/Session Type List
				--System--19000078, -- Resident Type
				--System--19000535, -- Resource Flag
				--System--19000531, -- Resource Type
				--System--19000106, -- Rule In Value for Test Validation
				--System--19000158, -- Sample Kind
				--System--19000015, -- Sample Status

				19000087, -- Sample Type
				19000079, -- Sanitary Measure List

				--System--19000112, -- Security Audit Action
				--System--19000114, -- Security Audit Process Type
				--System--19000113, -- Security Audit Result
				--System--19000118, -- Security Configuration Alphabet Name
				--System--19000119, -- Security Level
				--System--19000536, -- Site Alert Type
				--System--19000524, -- Site Group Type
				--System--19000084, -- Site Relation Type
				--System--19000085, -- Site Type
				--System--19000519, -- Source System Name

				19000166, -- Species Groups
				19000086, -- Species List
				19000145, -- Statistical Age Groups
				--System--19000089, -- Statistical Area Type
				19000090, -- Statistical Data Type
				--System--19000091, -- Statistical Period Type
				--System--19000092, -- Storage Type
				--System--19000139, -- Surrounding
				--System--19000094, -- System Function
				--System--19000059, -- System Function Operation
				--System--19000095, -- Test Category
				19000097, -- Test Name
				19000096, -- Test Result
				--System--19000001, -- Test Status
				--System--19000098, -- Vaccination Route List
				--System--19000099, -- Vaccination Type
				19000141, -- Vector sub type
				--System--19000133, -- Vector Surveillance Session Status
				19000140  -- Vector type
				--System--19000103, -- Vet Case Log Status
				--System--19000100, -- Yes/No Value List
			)
			and	(	br.idfsBaseReference <> 10320001			-- Sample Type: Unknown
					and	(	br.idfsReferenceType <> 19000146	-- Age Groups
							or br.blnSystem <> 1				-- WHO and CDC Groups
						)
					and	br.idfsBaseReference <> 123800000000	-- Employee Group Name: Default
					and	br.idfsBaseReference not in
					-- Orgnaization full name or abbreviation: Disposition
						(	704130000000, 
							704140000000
						)
					and	br.idfsBaseReference <> 39850000000		-- Statistical Data Type: Population
					and	br.idfsBaseReference <> 39860000000		-- Statistical Data Type: Population by Age Groups or Gender
					and	br.idfsBaseReference <> 840900000000	-- Statistical Data Type: Population by Gender
					and	br.idfsBaseReference not in
						(	10071025,		-- Flexible Form Parameter Type: Boolean
							10071029,		-- Flexible Form Parameter Type: Date
							10071030,		-- Flexible Form Parameter Type: DateTime
							10071045,		-- Flexible Form Parameter Type: String
							10071059,		-- Flexible Form Parameter Type: Numeric Natural
							10071060,		-- Flexible Form Parameter Type: Numeric Positive
							10071061,		-- Flexible Form Parameter Type: Numeric Integer
							217140000000,	-- Flexible Form Parameter Type: Y_N_Unk
							216820000000,	-- Flexible Form Parameter Type: Diagnosis List
							216880000000,	-- Flexible Form Parameter Type: Investigation Type
							217020000000,	-- Flexible Form Parameter Type: Prophylactic Action
							217030000000,	-- Flexible Form Parameter Type: Sanitary Action
							217050000000	-- Flexible Form Parameter Type: Species
						)
					and	br.idfsBaseReference not in
						(	25460000000,	-- Flexible Form Parameter Value: Yes
							25640000000,	-- Flexible Form Parameter Value: No
							25660000000		-- Flexible Form Parameter Value: Unknown
						)
				)
/*TODO:remove--
			and br_to_c_min.idfsBaseReference is null
			and br_to_correct_c.idfsBaseReference is null
			and br_del.idfsBaseReference is null
*/
order by	rt.strReferenceTypeName, br.idfsReferenceType, br.strDefault, br.idfsBaseReference




insert into	#LogTable (strMessage)
select	N'Custom reference values: '

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

insert into	#LogTable (strMessage)
select		strDescription
from		#BR_To_Del
where		idfID > @FirstNumOfRef_To_Del
order by	idfID

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

select	@FirstNumOfRef_To_Del = max(idfID)
from	#BR_To_Del

if	@FirstNumOfRef_To_Del is null
begin
	set	@FirstNumOfRef_To_Del = 0
end

insert into	#LogTable (strMessage)
select	N''

-- Delete references and related info
insert into	#LogTable (strMessage)
select	N'Delete reference values and related info'

delete		oa
from		tstObjectAccess oa
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = oa.idfsObjectID
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Permissions to the data linked to diagnoses on sites (tstObjectAccess): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

delete		dv
from		ffDeterminantValue dv
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = dv.idfsBaseReference
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    FF templates determinants by the reference values (ffDeterminantValue): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

delete		ahc
from		tlbAggrHumanCaseMTX ahc
where		(	ahc.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	ahc.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
set	@N = @@rowcount

if	@DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'    Rows of the aggregate matrix Human Aggregate Case, marked as deleted (tlbAggrHumanCaseMTX): ' + cast(@N as nvarchar(20))

delete		ahc
from		tlbAggrHumanCaseMTX ahc
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ahc.idfsDiagnosis
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Rows of the aggregate matrix Human Aggregate Case by diagnoses (tlbAggrHumanCaseMTX): ' + cast(@N as nvarchar(20))

delete		ada
from		tlbAggrDiagnosticActionMTX ada
where		(	ada.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	ada.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
set	@N = @@rowcount

if	@DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'    Rows of the aggregate matrix Diagnostic Investigations, marked as deleted (tlbAggrDiagnosticActionMTX): ' + cast(@N as nvarchar(20))

delete		ada
from		tlbAggrDiagnosticActionMTX ada
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ada.idfsSpeciesType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the aggregate matrix Diagnostic Investigations by species types (tlbAggrDiagnosticActionMTX): ' + cast(@N as nvarchar(20))

delete		ada
from		tlbAggrDiagnosticActionMTX ada
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ada.idfsDiagnosis
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the aggregate matrix Diagnostic Investigations by diagnoses (tlbAggrDiagnosticActionMTX): ' + cast(@N as nvarchar(20))

delete		ada
from		tlbAggrDiagnosticActionMTX ada
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ada.idfsDiagnosticAction
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the aggregate matrix Diagnostic Investigations by diagnostic investigations (tlbAggrDiagnosticActionMTX): ' + cast(@N as nvarchar(20))

delete		apa
from		tlbAggrProphylacticActionMTX apa
where		(	apa.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	apa.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
set	@N = @@rowcount

if	@DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'    Rows of the aggregate matrix Prophylactic Measures, marked as deleted (tlbAggrProphylacticActionMTX): ' + cast(@N as nvarchar(20))

delete		apa
from		tlbAggrProphylacticActionMTX apa
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = apa.idfsSpeciesType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the aggregate matrix Prophylactic Measures by species types (tlbAggrProphylacticActionMTX): ' + cast(@N as nvarchar(20))

delete		apa
from		tlbAggrProphylacticActionMTX apa
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = apa.idfsDiagnosis
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the aggregate matrix Prophylactic Measures by diagnoses (tlbAggrProphylacticActionMTX): ' + cast(@N as nvarchar(20))

delete		apa
from		tlbAggrProphylacticActionMTX apa
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = apa.idfsProphilacticAction
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the aggregate matrix Prophylactic Measures by prophylactic measures (tlbAggrProphylacticActionMTX): ' + cast(@N as nvarchar(20))

delete		asa
from		tlbAggrSanitaryActionMTX asa
where		(	asa.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	asa.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
set	@N = @@rowcount

if	@DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'    Rows of the aggregate matrix Sanitary Measures, marked as deleted (tlbAggrSanitaryActionMTX): ' + cast(@N as nvarchar(20))

delete		asa
from		tlbAggrSanitaryActionMTX asa
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = asa.idfsSanitaryAction
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Rows of the aggregate matrix Sanitary Measures by sanitary measures (tlbAggrSanitaryActionMTX): ' + cast(@N as nvarchar(20))

delete		avc
from		tlbAggrVetCaseMTX avc
where		(	avc.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	avc.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
set	@N = @@rowcount

if	@DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'    Rows of the aggregate matrix Vet Aggregate Case, marked as deleted (tlbAggrVetCaseMTX): ' + cast(@N as nvarchar(20))

delete		avc
from		tlbAggrVetCaseMTX avc
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = avc.idfsSpeciesType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the aggregate matrix Vet Aggregate Case by species types (tlbAggrVetCaseMTX): ' + cast(@N as nvarchar(20))

delete		avc
from		tlbAggrVetCaseMTX avc
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = avc.idfsDiagnosis
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the aggregate matrix Vet Aggregate Case by diagnoses (tlbAggrVetCaseMTX): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''



delete		cm_for_vt_to_c
from		trtCollectionMethodForVectorType cm_for_vt
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = cm_for_vt.idfsCollectionMethod
inner join	trtCollectionMethodForVectorTypeToCP cm_for_vt_to_c
on			cm_for_vt_to_c.idfCollectionMethodForVectorType = cm_for_vt.idfCollectionMethodForVectorType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Vector Type -> Collection Method to customization packages by collection method (trtCollectionMethodForVectorTypeToCP): ' + cast(@N as nvarchar(20))

delete		cm_for_vt_to_c
from		trtCollectionMethodForVectorType cm_for_vt
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = cm_for_vt.idfsVectorType
inner join	trtCollectionMethodForVectorTypeToCP cm_for_vt_to_c
on			cm_for_vt_to_c.idfCollectionMethodForVectorType = cm_for_vt.idfCollectionMethodForVectorType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Vector Type -> Collection Method to customization packages by vector type (trtCollectionMethodForVectorTypeToCP): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		cm_for_vt_to_c
from		trtCollectionMethodForVectorType cm_for_vt
inner join	trtCollectionMethodForVectorTypeToCP cm_for_vt_to_c
on			cm_for_vt_to_c.idfCollectionMethodForVectorType = cm_for_vt.idfCollectionMethodForVectorType
where		cm_for_vt.intRowStatus <> 0 -- do not belong to historical records
			or cm_for_vt_to_c.idfCustomizationPackage <> @idfCustomizationPackage
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Vector Type -> Collection Method to customization packages by customization package (trtCollectionMethodForVectorTypeToCP): ' + cast(@N as nvarchar(20))
*/
delete		cm_for_vt
from		trtCollectionMethodForVectorType cm_for_vt
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = cm_for_vt.idfsCollectionMethod
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Vector Type -> Collection Method by collection method (trtCollectionMethodForVectorType): ' + cast(@N as nvarchar(20))

delete		cm_for_vt
from		trtCollectionMethodForVectorType cm_for_vt
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = cm_for_vt.idfsVectorType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Vector Type -> Collection Method by vector type (trtCollectionMethodForVectorType): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		cm_for_vt
from		trtCollectionMethodForVectorType cm_for_vt
left join	trtCollectionMethodForVectorTypeToCP cm_for_vt_to_c
on			cm_for_vt_to_c.idfCollectionMethodForVectorType = cm_for_vt.idfCollectionMethodForVectorType
			and cm_for_vt_to_c.idfCustomizationPackage = @idfCustomizationPackage
where		cm_for_vt.intRowStatus <> 0 -- do not belong to historical records
			or cm_for_vt_to_c.idfCollectionMethodForVectorType is null
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Vector Type -> Collection Method by customization package (trtCollectionMethodForVectorType): ' + cast(@N as nvarchar(20))
*/
insert into	#LogTable (strMessage)
select	N''



delete		d_for_st_to_c
from		trtDerivativeForSampleType d_for_st
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = d_for_st.idfsSampleType
inner join	trtDerivativeForSampleTypeToCP d_for_st_to_c
on			d_for_st_to_c.idfDerivativeForSampleType = d_for_st.idfDerivativeForSampleType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Sample Type -> Derivative Type to customization packages by sample type (trtDerivativeForSampleTypeToCP): ' + cast(@N as nvarchar(20))

delete		d_for_st_to_c
from		trtDerivativeForSampleType d_for_st
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = d_for_st.idfsDerivativeType
inner join	trtDerivativeForSampleTypeToCP d_for_st_to_c
on			d_for_st_to_c.idfDerivativeForSampleType = d_for_st.idfDerivativeForSampleType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Sample Type -> Derivative Type to customization packages by derivative type (trtDerivativeForSampleTypeToCP): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		d_for_st_to_c
from		trtDerivativeForSampleType d_for_st
inner join	trtDerivativeForSampleTypeToCP d_for_st_to_c
on			d_for_st_to_c.idfDerivativeForSampleType = d_for_st.idfDerivativeForSampleType
where		d_for_st.intRowStatus <> 0 -- do not belong to historical records
			or d_for_st_to_c.idfCustomizationPackage <> @idfCustomizationPackage
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Sample Type -> Derivative Type to customization packages by customization package (trtDerivativeForSampleTypeToCP): ' + cast(@N as nvarchar(20))
*/

delete		d_for_st
from		trtDerivativeForSampleType d_for_st
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = d_for_st.idfsSampleType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Sample Type -> Derivative Type by sample type (trtDerivativeForSampleType): ' + cast(@N as nvarchar(20))

delete		d_for_st
from		trtDerivativeForSampleType d_for_st
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = d_for_st.idfsDerivativeType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Sample Type -> Derivative Type by derivative type (trtDerivativeForSampleType): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		d_for_st
from		trtDerivativeForSampleType d_for_st
left join	trtDerivativeForSampleTypeToCP d_for_st_to_c
on			d_for_st_to_c.idfDerivativeForSampleType = d_for_st.idfDerivativeForSampleType
			and d_for_st_to_c.idfCustomizationPackage = @idfCustomizationPackage
where		d_for_st.intRowStatus <> 0 -- do not belong to historical records
			or d_for_st_to_c.idfDerivativeForSampleType is null
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Sample Type -> Derivative Type by customization package (trtDerivativeForSampleType): ' + cast(@N as nvarchar(20))
*/
insert into	#LogTable (strMessage)
select	N''

delete		ag_to_d_to_c
from		trtDiagnosisAgeGroupToDiagnosis ag_to_d
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ag_to_d.idfsDiagnosisAgeGroup
inner join	trtDiagnosisAgeGroupToDiagnosisToCP ag_to_d_to_c
on			ag_to_d_to_c.idfDiagnosisAgeGroupToDiagnosis = ag_to_d.idfDiagnosisAgeGroupToDiagnosis
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Diagnosis -> Age Group to customization packages by age group (trtDiagnosisAgeGroupToDiagnosisToCP): ' + cast(@N as nvarchar(20))

delete		ag_to_d_to_c
from		trtDiagnosisAgeGroupToDiagnosis ag_to_d
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ag_to_d.idfsDiagnosis
inner join	trtDiagnosisAgeGroupToDiagnosisToCP ag_to_d_to_c
on			ag_to_d_to_c.idfDiagnosisAgeGroupToDiagnosis = ag_to_d.idfDiagnosisAgeGroupToDiagnosis
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Diagnosis -> Age Group to customization packages by diagnosis (trtDiagnosisAgeGroupToDiagnosisToCP): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		ag_to_d_to_c
from		trtDiagnosisAgeGroupToDiagnosis ag_to_d
inner join	trtDiagnosisAgeGroupToDiagnosisToCP ag_to_d_to_c
on			ag_to_d_to_c.idfDiagnosisAgeGroupToDiagnosis = ag_to_d.idfDiagnosisAgeGroupToDiagnosis
where		ag_to_d.intRowStatus <> 0 -- do not belong to historical records
			or ag_to_d_to_c.idfCustomizationPackage <> @idfCustomizationPackage
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Diagnosis -> Age Group to customization packages by customization package (trtDiagnosisAgeGroupToDiagnosisToCP): ' + cast(@N as nvarchar(20))
*/
delete		ag_to_d
from		trtDiagnosisAgeGroupToDiagnosis ag_to_d
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ag_to_d.idfsDiagnosisAgeGroup
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Diagnosis -> Age Group by age group (trtDiagnosisAgeGroupToDiagnosis): ' + cast(@N as nvarchar(20))

delete		ag_to_d
from		trtDiagnosisAgeGroupToDiagnosis ag_to_d
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ag_to_d.idfsDiagnosis
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Diagnosis -> Age Group by diagnosis (trtDiagnosisAgeGroupToDiagnosis): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		ag_to_d
from		trtDiagnosisAgeGroupToDiagnosis ag_to_d
left join	trtDiagnosisAgeGroupToDiagnosisToCP ag_to_d_to_c
on			ag_to_d_to_c.idfDiagnosisAgeGroupToDiagnosis = ag_to_d.idfDiagnosisAgeGroupToDiagnosis
where		ag_to_d.intRowStatus <> 0 -- do not belong to historical records
			or ag_to_d_to_c.idfDiagnosisAgeGroupToDiagnosis is null
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Diagnosis -> Age Group by customization package (trtDiagnosisAgeGroupToDiagnosis): ' + cast(@N as nvarchar(20))
*/

insert into	#LogTable (strMessage)
select	N''

delete		ag_to_sag_to_c
from		trtDiagnosisAgeGroupToStatisticalAgeGroup ag_to_sag
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ag_to_sag.idfsDiagnosisAgeGroup
inner join	trtDiagnosisAgeGroupToStatisticalAgeGroupToCP ag_to_sag_to_c
on			ag_to_sag_to_c.idfDiagnosisAgeGroupToStatisticalAgeGroup = ag_to_sag.idfDiagnosisAgeGroupToStatisticalAgeGroup
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Age Group -> Statistical Age Group to customization packages by age group (trtDiagnosisAgeGroupToStatisticalAgeGroupToCP): ' + cast(@N as nvarchar(20))

delete		ag_to_sag_to_c
from		trtDiagnosisAgeGroupToStatisticalAgeGroup ag_to_sag
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ag_to_sag.idfsStatisticalAgeGroup
inner join	trtDiagnosisAgeGroupToStatisticalAgeGroupToCP ag_to_sag_to_c
on			ag_to_sag_to_c.idfDiagnosisAgeGroupToStatisticalAgeGroup = ag_to_sag.idfDiagnosisAgeGroupToStatisticalAgeGroup
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Age Group -> Statistical Age Group to customization packages by statistical age group (trtDiagnosisAgeGroupToStatisticalAgeGroupToCP): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		ag_to_sag_to_c
from		trtDiagnosisAgeGroupToStatisticalAgeGroup ag_to_sag
inner join	trtDiagnosisAgeGroupToStatisticalAgeGroupToCP ag_to_sag_to_c
on			ag_to_sag_to_c.idfDiagnosisAgeGroupToStatisticalAgeGroup = ag_to_sag.idfDiagnosisAgeGroupToStatisticalAgeGroup
where		ag_to_sag.intRowStatus <> 0 -- do not belong to historical records
			or ag_to_sag_to_c.idfCustomizationPackage <> @idfCustomizationPackage
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Age Group -> Statistical Age Group to customization packages by customization package (trtDiagnosisAgeGroupToStatisticalAgeGroupToCP): ' + cast(@N as nvarchar(20))
*/

delete		ag_to_sag
from		trtDiagnosisAgeGroupToStatisticalAgeGroup ag_to_sag
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ag_to_sag.idfsDiagnosisAgeGroup
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Age Group -> Statistical Age Group by age group (trtDiagnosisAgeGroupToStatisticalAgeGroup): ' + cast(@N as nvarchar(20))

delete		ag_to_sag
from		trtDiagnosisAgeGroupToStatisticalAgeGroup ag_to_sag
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ag_to_sag.idfsStatisticalAgeGroup
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Age Group -> Statistical Age Group by statistical age group (trtDiagnosisAgeGroupToStatisticalAgeGroup): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		ag_to_sag
from		trtDiagnosisAgeGroupToStatisticalAgeGroup ag_to_sag
left join	trtDiagnosisAgeGroupToStatisticalAgeGroupToCP ag_to_sag_to_c
on			ag_to_sag_to_c.idfDiagnosisAgeGroupToStatisticalAgeGroup = ag_to_sag.idfDiagnosisAgeGroupToStatisticalAgeGroup
where		ag_to_sag.intRowStatus <> 0 -- do not belong to historical records
			or ag_to_sag_to_c.idfDiagnosisAgeGroupToStatisticalAgeGroup is null
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Age Group -> Statistical Age Group by customization package (trtDiagnosisAgeGroupToStatisticalAgeGroup): ' + cast(@N as nvarchar(20))
*/

insert into	#LogTable (strMessage)
select	N''

delete		d_to_dg_to_c
from		trtDiagnosisToDiagnosisGroup d_to_dg
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = d_to_dg.idfsDiagnosisGroup
inner join	trtDiagnosisToDiagnosisGroupToCP d_to_dg_to_c
on			d_to_dg_to_c.idfDiagnosisToDiagnosisGroup = d_to_dg.idfDiagnosisToDiagnosisGroup
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Diagnosis Group -> Diagnosis to customization packages by diagnosis group (trtDiagnosisToDiagnosisGroupToCP): ' + cast(@N as nvarchar(20))

delete		d_to_dg_to_c
from		trtDiagnosisToDiagnosisGroup d_to_dg
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = d_to_dg.idfsDiagnosis
inner join	trtDiagnosisToDiagnosisGroupToCP d_to_dg_to_c
on			d_to_dg_to_c.idfDiagnosisToDiagnosisGroup = d_to_dg.idfDiagnosisToDiagnosisGroup
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Diagnosis Group -> Diagnosis to customization packages by diagnosis (trtDiagnosisToDiagnosisGroupToCP): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		d_to_dg_to_c
from		trtDiagnosisToDiagnosisGroup d_to_dg
inner join	trtDiagnosisToDiagnosisGroupToCP d_to_dg_to_c
on			d_to_dg_to_c.idfDiagnosisToDiagnosisGroup = d_to_dg.idfDiagnosisToDiagnosisGroup
where		d_to_dg.intRowStatus <> 0 -- do not belong to historical records
			or d_to_dg_to_c.idfCustomizationPackage <> @idfCustomizationPackage
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Diagnosis Group -> Diagnosis to customization packages by customization package (trtDiagnosisToDiagnosisGroupToCP): ' + cast(@N as nvarchar(20))
*/

delete		d_to_dg
from		trtDiagnosisToDiagnosisGroup d_to_dg
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = d_to_dg.idfsDiagnosisGroup
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Diagnosis Group -> Diagnosis by diagnosis group (trtDiagnosisToDiagnosisGroup): ' + cast(@N as nvarchar(20))

delete		d_to_dg
from		trtDiagnosisToDiagnosisGroup d_to_dg
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = d_to_dg.idfsDiagnosis
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Diagnosis Group -> Diagnosis by diagnosis (trtDiagnosisToDiagnosisGroup): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		d_to_dg
from		trtDiagnosisToDiagnosisGroup d_to_dg
left join	trtDiagnosisToDiagnosisGroupToCP d_to_dg_to_c
on			d_to_dg_to_c.idfDiagnosisToDiagnosisGroup = d_to_dg.idfDiagnosisToDiagnosisGroup
where		d_to_dg.intRowStatus <> 0 -- do not belong to historical records
			or d_to_dg_to_c.idfDiagnosisToDiagnosisGroup is null
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Diagnosis Group -> Diagnosis by customization package (trtDiagnosisToDiagnosisGroup): ' + cast(@N as nvarchar(20))
*/

insert into	#LogTable (strMessage)
select	N''

delete		m_for_d_to_c
from		trtMaterialForDisease m_for_d
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = m_for_d.idfsSampleType
inner join	trtMaterialForDiseaseToCP m_for_d_to_c
on			m_for_d_to_c.idfMaterialForDisease = m_for_d.idfMaterialForDisease
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Diagnosis -> Sample Type to customization packages by sample type (trtMaterialForDiseaseToCP): ' + cast(@N as nvarchar(20))

delete		m_for_d_to_c
from		trtMaterialForDisease m_for_d
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = m_for_d.idfsDiagnosis
inner join	trtMaterialForDiseaseToCP m_for_d_to_c
on			m_for_d_to_c.idfMaterialForDisease = m_for_d.idfMaterialForDisease
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Diagnosis -> Sample Type to customization packages by diagnosis (trtMaterialForDiseaseToCP): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		m_for_d_to_c
from		trtMaterialForDisease m_for_d
inner join	trtMaterialForDiseaseToCP m_for_d_to_c
on			m_for_d_to_c.idfMaterialForDisease = m_for_d.idfMaterialForDisease
where		m_for_d.intRowStatus <> 0 -- do not belong to historical records
			or m_for_d_to_c.idfCustomizationPackage <> @idfCustomizationPackage
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Diagnosis -> Sample Type to customization packages by customization package (trtMaterialForDiseaseToCP): ' + cast(@N as nvarchar(20))
*/

delete		m_for_d
from		trtMaterialForDisease m_for_d
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = m_for_d.idfsSampleType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Diagnosis -> Sample Type by sample type (trtMaterialForDisease): ' + cast(@N as nvarchar(20))

delete		m_for_d
from		trtMaterialForDisease m_for_d
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = m_for_d.idfsDiagnosis
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Diagnosis -> Sample Type by diagnosis (trtMaterialForDisease): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		m_for_d
from		trtMaterialForDisease m_for_d
left join	trtMaterialForDiseaseToCP m_for_d_to_c
on			m_for_d_to_c.idfMaterialForDisease = m_for_d.idfMaterialForDisease
			and m_for_d_to_c.idfCustomizationPackage = @idfCustomizationPackage
where		m_for_d.intRowStatus <> 0 -- do not belong to historical records
			or m_for_d_to_c.idfMaterialForDisease is null
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Diagnosis -> Sample Type by customization package (trtMaterialForDisease): ' + cast(@N as nvarchar(20))
*/

insert into	#LogTable (strMessage)
select	N''

delete		ptt_for_d_to_c
from		trtPensideTestForDisease ptt_for_d
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ptt_for_d.idfsPensideTestName
inner join	trtPensideTestForDiseaseToCP ptt_for_d_to_c
on			ptt_for_d_to_c.idfPensideTestForDisease = ptt_for_d.idfPensideTestForDisease
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Diagnosis -> Field Test to customization packages by field test name (trtPensideTestForDiseaseToCP): ' + cast(@N as nvarchar(20))

delete		ptt_for_d_to_c
from		trtPensideTestForDisease ptt_for_d
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ptt_for_d.idfsDiagnosis
inner join	trtPensideTestForDiseaseToCP ptt_for_d_to_c
on			ptt_for_d_to_c.idfPensideTestForDisease = ptt_for_d.idfPensideTestForDisease
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Diagnosis -> Field Test to customization packages by diagnosis (trtPensideTestForDiseaseToCP): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		ptt_for_d_to_c
from		trtPensideTestForDisease ptt_for_d
inner join	trtPensideTestForDiseaseToCP ptt_for_d_to_c
on			ptt_for_d_to_c.idfPensideTestForDisease = ptt_for_d.idfPensideTestForDisease
where		ptt_for_d.intRowStatus <> 0 -- do not belong to historical records
			or ptt_for_d_to_c.idfCustomizationPackage <> @idfCustomizationPackage
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Diagnosis -> Field Test to customization packages by customization package (trtPensideTestForDiseaseToCP): ' + cast(@N as nvarchar(20))
*/

delete		ptt_for_d
from		trtPensideTestForDisease ptt_for_d
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ptt_for_d.idfsPensideTestName
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Diagnosis -> Field Test by field test type (trtPensideTestForDisease): ' + cast(@N as nvarchar(20))

delete		ptt_for_d
from		trtPensideTestForDisease ptt_for_d
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ptt_for_d.idfsDiagnosis
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Diagnosis -> Field Test by diagnosis (trtPensideTestForDisease): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		ptt_for_d
from		trtPensideTestForDisease ptt_for_d
left join	trtPensideTestForDiseaseToCP ptt_for_d_to_c
on			ptt_for_d_to_c.idfPensideTestForDisease = ptt_for_d.idfPensideTestForDisease
			and ptt_for_d_to_c.idfCustomizationPackage = @idfCustomizationPackage
where		ptt_for_d.intRowStatus <> 0 -- do not belong to historical records
			or ptt_for_d_to_c.idfPensideTestForDisease is null
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Diagnosis -> Field Test by customization package (trtPensideTestForDisease): ' + cast(@N as nvarchar(20))
*/

insert into	#LogTable (strMessage)
select	N''

delete		ptt_for_vt_to_c
from		trtPensideTestTypeForVectorType ptt_for_vt
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ptt_for_vt.idfsPensideTestName
inner join	trtPensideTestTypeForVectorTypeToCP ptt_for_vt_to_c
on			ptt_for_vt_to_c.idfPensideTestTypeForVectorType = ptt_for_vt.idfPensideTestTypeForVectorType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Vector Type -> Field Test to customization packages by field test name (trtPensideTestTypeForVectorTypeToCP): ' + cast(@N as nvarchar(20))

delete		ptt_for_vt_to_c
from		trtPensideTestTypeForVectorType ptt_for_vt
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ptt_for_vt.idfsVectorType
inner join	trtPensideTestTypeForVectorTypeToCP ptt_for_vt_to_c
on			ptt_for_vt_to_c.idfPensideTestTypeForVectorType = ptt_for_vt.idfPensideTestTypeForVectorType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Vector Type -> Field Test to customization packages by vector type (trtPensideTestTypeForVectorTypeToCP): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		ptt_for_vt_to_c
from		trtPensideTestTypeForVectorType ptt_for_vt
inner join	trtPensideTestTypeForVectorTypeToCP ptt_for_vt_to_c
on			ptt_for_vt_to_c.idfPensideTestTypeForVectorType = ptt_for_vt.idfPensideTestTypeForVectorType
where		ptt_for_vt.intRowStatus <> 0 -- do not belong to historical records
			or ptt_for_vt_to_c.idfCustomizationPackage <> @idfCustomizationPackage
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Vector Type -> Field Test to customization packages by customization package (trtPensideTestTypeForVectorTypeToCP): ' + cast(@N as nvarchar(20))
*/

delete		ptt_for_vt
from		trtPensideTestTypeForVectorType ptt_for_vt
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ptt_for_vt.idfsPensideTestName
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Vector Type -> Field Test by field test name (trtPensideTestTypeForVectorType): ' + cast(@N as nvarchar(20))

delete		ptt_for_vt
from		trtPensideTestTypeForVectorType ptt_for_vt
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ptt_for_vt.idfsVectorType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Vector Type -> Field Test by vector type (trtPensideTestTypeForVectorType): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		ptt_for_vt
from		trtPensideTestTypeForVectorType ptt_for_vt
left join	trtPensideTestTypeForVectorTypeToCP ptt_for_vt_to_c
on			ptt_for_vt_to_c.idfPensideTestTypeForVectorType = ptt_for_vt.idfPensideTestTypeForVectorType
			and ptt_for_vt_to_c.idfCustomizationPackage = @idfCustomizationPackage
where		ptt_for_vt.intRowStatus <> 0 -- do not belong to historical records
			or ptt_for_vt_to_c.idfPensideTestTypeForVectorType is null
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Vector Type -> Field Test by customization package (trtPensideTestTypeForVectorType): ' + cast(@N as nvarchar(20))
*/

insert into	#LogTable (strMessage)
select	N''

delete		t_for_d_to_c
from		trtTestForDisease t_for_d
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = t_for_d.idfsTestName
inner join	trtTestForDiseaseToCP t_for_d_to_c
on			t_for_d_to_c.idfTestForDisease = t_for_d.idfTestForDisease
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Diagnosis -> Test Name to customization packages by test name (trtTestForDiseaseToCP): ' + cast(@N as nvarchar(20))

delete		t_for_d_to_c
from		trtTestForDisease t_for_d
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = t_for_d.idfsDiagnosis
inner join	trtTestForDiseaseToCP t_for_d_to_c
on			t_for_d_to_c.idfTestForDisease = t_for_d.idfTestForDisease
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Diagnosis -> Test Name to customization packages by diagnosis (trtTestForDiseaseToCP): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		t_for_d_to_c
from		trtTestForDisease t_for_d
inner join	trtTestForDiseaseToCP t_for_d_to_c
on			t_for_d_to_c.idfTestForDisease = t_for_d.idfTestForDisease
where		t_for_d.intRowStatus <> 0 -- do not belong to historical records
			or t_for_d_to_c.idfCustomizationPackage <> @idfCustomizationPackage
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Diagnosis -> Test Name to customization packages by customization package (trtTestForDiseaseToCP): ' + cast(@N as nvarchar(20))
*/

delete		t_for_d
from		trtTestForDisease t_for_d
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = t_for_d.idfsTestName
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Diagnosis -> Test Name by test name (trtTestForDisease): ' + cast(@N as nvarchar(20))

delete		t_for_d
from		trtTestForDisease t_for_d
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = t_for_d.idfsDiagnosis
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Diagnosis -> Test Name by diagnosis (trtTestForDisease): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		t_for_d
from		trtTestForDisease t_for_d
left join	trtTestForDiseaseToCP t_for_d_to_c
on			t_for_d_to_c.idfTestForDisease = t_for_d.idfTestForDisease
			and t_for_d_to_c.idfCustomizationPackage = @idfCustomizationPackage
where		t_for_d.intRowStatus <> 0 -- do not belong to historical records
			or t_for_d_to_c.idfTestForDisease is null
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Diagnosis -> Test Name by customization package (trtTestForDisease): ' + cast(@N as nvarchar(20))
*/

insert into	#LogTable (strMessage)
select	N''

delete		st_for_vt_to_c
from		trtSampleTypeForVectorType st_for_vt
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = st_for_vt.idfsSampleType
inner join	trtSampleTypeForVectorTypeToCP st_for_vt_to_c
on			st_for_vt_to_c.idfSampleTypeForVectorType = st_for_vt.idfSampleTypeForVectorType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Vector Type -> Sample Type to customization packages by sample type (trtSampleTypeForVectorTypeToCP): ' + cast(@N as nvarchar(20))

delete		st_for_vt_to_c
from		trtSampleTypeForVectorType st_for_vt
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = st_for_vt.idfsVectorType
inner join	trtSampleTypeForVectorTypeToCP st_for_vt_to_c
on			st_for_vt_to_c.idfSampleTypeForVectorType = st_for_vt.idfSampleTypeForVectorType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Vector Type -> Sample Type to customization packages by vector type (trtSampleTypeForVectorTypeToCP): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		st_for_vt_to_c
from		trtSampleTypeForVectorType st_for_vt
inner join	trtSampleTypeForVectorTypeToCP st_for_vt_to_c
on			st_for_vt_to_c.idfSampleTypeForVectorType = st_for_vt.idfSampleTypeForVectorType
where		st_for_vt.intRowStatus <> 0 -- do not belong to historical records
			or st_for_vt_to_c.idfCustomizationPackage <> @idfCustomizationPackage
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Vector Type -> Sample Type to customization packages by customization package (trtSampleTypeForVectorTypeToCP): ' + cast(@N as nvarchar(20))
*/

delete		st_for_vt
from		trtSampleTypeForVectorType st_for_vt
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = st_for_vt.idfsSampleType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Vector Type -> Sample Type by sample type (trtSampleTypeForVectorType): ' + cast(@N as nvarchar(20))

delete		st_for_vt
from		trtSampleTypeForVectorType st_for_vt
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = st_for_vt.idfsVectorType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Vector Type -> Sample Type by vector type (trtSampleTypeForVectorType): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		st_for_vt
from		trtSampleTypeForVectorType st_for_vt
left join	trtSampleTypeForVectorTypeToCP st_for_vt_to_c
on			st_for_vt_to_c.idfSampleTypeForVectorType = st_for_vt.idfSampleTypeForVectorType
			and st_for_vt_to_c.idfCustomizationPackage = @idfCustomizationPackage
where		st_for_vt.intRowStatus <> 0 -- do not belong to historical records
			or st_for_vt_to_c.idfSampleTypeForVectorType is null
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Vector Type -> Sample Type by customization package (trtSampleTypeForVectorType): ' + cast(@N as nvarchar(20))
*/

insert into	#LogTable (strMessage)
select	N''

delete		st_to_aa_to_c
from		trtSpeciesTypeToAnimalAge st_to_aa
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = st_to_aa.idfsSpeciesType
inner join	trtSpeciesTypeToAnimalAgeToCP st_to_aa_to_c
on			st_to_aa_to_c.idfSpeciesTypeToAnimalAge = st_to_aa.idfSpeciesTypeToAnimalAge
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Species Type -> Animal Age to customization packages by species type (trtSpeciesTypeToAnimalAgeToCP): ' + cast(@N as nvarchar(20))

delete		st_to_aa_to_c
from		trtSpeciesTypeToAnimalAge st_to_aa
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = st_to_aa.idfsAnimalAge
inner join	trtSpeciesTypeToAnimalAgeToCP st_to_aa_to_c
on			st_to_aa_to_c.idfSpeciesTypeToAnimalAge = st_to_aa.idfSpeciesTypeToAnimalAge
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Species Type -> Animal Age to customization packages by animal age (trtSpeciesTypeToAnimalAgeToCP): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		st_to_aa_to_c
from		trtSpeciesTypeToAnimalAge st_to_aa
inner join	trtSpeciesTypeToAnimalAgeToCP st_to_aa_to_c
on			st_to_aa_to_c.idfSpeciesTypeToAnimalAge = st_to_aa.idfSpeciesTypeToAnimalAge
where		st_to_aa.intRowStatus <> 0 -- do not belong to historical records
			or st_to_aa_to_c.idfCustomizationPackage <> @idfCustomizationPackage
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Species Type -> Animal Age to customization packages by customization package (trtSpeciesTypeToAnimalAgeToCP): ' + cast(@N as nvarchar(20))
*/

delete		st_to_aa
from		trtSpeciesTypeToAnimalAge st_to_aa
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = st_to_aa.idfsSpeciesType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Species Type -> Animal Age by species type (trtSpeciesTypeToAnimalAge): ' + cast(@N as nvarchar(20))

delete		st_to_aa
from		trtSpeciesTypeToAnimalAge st_to_aa
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = st_to_aa.idfsAnimalAge
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Species Type -> Animal Age by animal age (trtSpeciesTypeToAnimalAge): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		st_to_aa
from		trtSpeciesTypeToAnimalAge st_to_aa
left join	trtSpeciesTypeToAnimalAgeToCP st_to_aa_to_c
on			st_to_aa_to_c.idfSpeciesTypeToAnimalAge = st_to_aa.idfSpeciesTypeToAnimalAge
			and st_to_aa_to_c.idfCustomizationPackage = @idfCustomizationPackage
where		st_to_aa.intRowStatus <> 0 -- do not belong to historical records
			or st_to_aa_to_c.idfSpeciesTypeToAnimalAge is null
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Species Type -> Animal Age by customization package (trtSpeciesTypeToAnimalAge): ' + cast(@N as nvarchar(20))
*/

insert into	#LogTable (strMessage)
select	N''

delete		tt_to_tr_to_c
from		trtTestTypeToTestResult tt_to_tr
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = tt_to_tr.idfsTestName
inner join	trtTestTypeToTestResultToCP tt_to_tr_to_c
on			tt_to_tr_to_c.idfsTestName = tt_to_tr.idfsTestName
			and tt_to_tr_to_c.idfsTestResult = tt_to_tr.idfsTestResult
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Test Name -> Test Result to customization packages by test name (trtTestTypeToTestResultToCP): ' + cast(@N as nvarchar(20))

delete		tt_to_tr_to_c
from		trtTestTypeToTestResult tt_to_tr
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = tt_to_tr.idfsTestResult
inner join	trtTestTypeToTestResultToCP tt_to_tr_to_c
on			tt_to_tr_to_c.idfsTestName = tt_to_tr.idfsTestName
			and tt_to_tr_to_c.idfsTestResult = tt_to_tr.idfsTestResult
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Test Name -> Test Result to customization packages by test result (trtTestTypeToTestResultToCP): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		tt_to_tr_to_c
from		trtTestTypeToTestResult tt_to_tr
inner join	trtTestTypeToTestResultToCP tt_to_tr_to_c
on			tt_to_tr_to_c.idfsTestName = tt_to_tr.idfsTestName
			and tt_to_tr_to_c.idfsTestResult = tt_to_tr.idfsTestResult
where		tt_to_tr.intRowStatus <> 0 -- do not belong to historical records
			or tt_to_tr_to_c.idfCustomizationPackage <> @idfCustomizationPackage
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Test Name -> Test Result to customization packages by customization package (trtTestTypeToTestResultToCP): ' + cast(@N as nvarchar(20))
*/

delete		tt_to_tr
from		trtTestTypeToTestResult tt_to_tr
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = tt_to_tr.idfsTestName
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Test Name -> Test Result by test name (trtTestTypeToTestResult): ' + cast(@N as nvarchar(20))

delete		tt_to_tr
from		trtTestTypeToTestResult tt_to_tr
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = tt_to_tr.idfsTestResult
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Test Name -> Test Result by test result (trtTestTypeToTestResult): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		tt_to_tr
from		trtTestTypeToTestResult tt_to_tr
left join	trtTestTypeToTestResultToCP tt_to_tr_to_c
on			tt_to_tr_to_c.idfsTestName = tt_to_tr.idfsTestName
			and tt_to_tr_to_c.idfsTestResult = tt_to_tr.idfsTestResult
			and tt_to_tr_to_c.idfCustomizationPackage = @idfCustomizationPackage
where		tt_to_tr.intRowStatus <> 0 -- do not belong to historical records
			or tt_to_tr_to_c.idfsTestName is null
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Test Name -> Test Result by customization package (trtTestTypeToTestResult): ' + cast(@N as nvarchar(20))
*/

insert into	#LogTable (strMessage)
select	N''

delete		ptt_to_ptr_to_c
from		trtPensideTestTypeToTestResult ptt_to_ptr
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ptt_to_ptr.idfsPensideTestName
inner join	trtPensideTestTypeToTestResultToCP ptt_to_ptr_to_c
on			ptt_to_ptr_to_c.idfsPensideTestName = ptt_to_ptr.idfsPensideTestName
			and ptt_to_ptr_to_c.idfsPensideTestResult = ptt_to_ptr.idfsPensideTestResult
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Penside/Field Test Name -> Penside/Field Test Result to customization packages by penside/field test name (trtPensideTestTypeToTestResultToCP): ' + cast(@N as nvarchar(20))

delete		ptt_to_ptr_to_c
from		trtPensideTestTypeToTestResult ptt_to_ptr
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ptt_to_ptr.idfsPensideTestResult
inner join	trtPensideTestTypeToTestResultToCP ptt_to_ptr_to_c
on			ptt_to_ptr_to_c.idfsPensideTestName = ptt_to_ptr.idfsPensideTestName
			and ptt_to_ptr_to_c.idfsPensideTestResult = ptt_to_ptr.idfsPensideTestResult
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Penside/Field Test Name -> Penside/Field Test Result to customization packages by penside/field test result (trtPensideTestTypeToTestResultToCP): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		ptt_to_ptr_to_c
from		trtPensideTestTypeToTestResult ptt_to_ptr
inner join	trtPensideTestTypeToTestResultToCP ptt_to_ptr_to_c
on			ptt_to_ptr_to_c.idfsPensideTestName = ptt_to_ptr.idfsPensideTestName
			and ptt_to_ptr_to_c.idfsPensideTestResult = ptt_to_ptr.idfsPensideTestResult
where		ptt_to_ptr.intRowStatus <> 0 -- do not belong to historical records
			or ptt_to_ptr_to_c.idfCustomizationPackage <> @idfCustomizationPackage
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the rows of the matrix Penside/Field Test Name -> Penside/Field Test Result to customization packages by customization package (trtPensideTestTypeToTestResultToCP): ' + cast(@N as nvarchar(20))
*/

delete		ptt_to_ptr
from		trtPensideTestTypeToTestResult ptt_to_ptr
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ptt_to_ptr.idfsPensideTestName
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Penside/Field Test Name -> Penside/Field Test Result by penside/field test name (trtPensideTestTypeToTestResult): ' + cast(@N as nvarchar(20))

delete		ptt_to_ptr
from		trtPensideTestTypeToTestResult ptt_to_ptr
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ptt_to_ptr.idfsPensideTestResult
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Penside/Field Test Name -> Penside/Field Test Result by penside/field test result (trtPensideTestTypeToTestResult): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		ptt_to_ptr
from		trtPensideTestTypeToTestResult ptt_to_ptr
left join	trtPensideTestTypeToTestResultToCP ptt_to_ptr_to_c
on			ptt_to_ptr_to_c.idfsPensideTestName = ptt_to_ptr.idfsPensideTestName
			and ptt_to_ptr_to_c.idfsPensideTestResult = ptt_to_ptr.idfsPensideTestResult
			and ptt_to_ptr_to_c.idfCustomizationPackage = @idfCustomizationPackage
where		ptt_to_ptr.intRowStatus <> 0 -- do not belong to historical records
			or ptt_to_ptr_to_c.idfsPensideTestName is null
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of the matrix Penside/Field Test Name -> Penside/Field Test Result by customization package (trtPensideTestTypeToTestResult): ' + cast(@N as nvarchar(20))
*/

insert into	#LogTable (strMessage)
select	N''

insert into	#LogTable (strMessage)
select	N''


delete		dg_to_g
from		DiagnosisGroupToGender dg_to_g
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = dg_to_g.DisgnosisGroupID
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Diagnoses groups -> Gender by diagnosis group (DiagnosisGroupToGender): ' + cast(@N as nvarchar(20))

delete		dg_to_g
from		DiagnosisGroupToGender dg_to_g
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = dg_to_g.GenderID
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Diagnoses groups -> Gender by gender (DiagnosisGroupToGender): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''


delete		d_to_g_for_rt
from		trtDiagnosisToGroupForReportType d_to_g_for_rt
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = d_to_g_for_rt.idfsCustomReportType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Custom report diagnoses groups'' membership by custom report type (trtDiagnosisToGroupForReportType): ' + cast(@N as nvarchar(20))

delete		d_to_g_for_rt
from		trtDiagnosisToGroupForReportType d_to_g_for_rt
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = d_to_g_for_rt.idfsReportDiagnosisGroup
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Custom report diagnoses groups'' membership by custom report diagnosis group (trtDiagnosisToGroupForReportType): ' + cast(@N as nvarchar(20))

delete		d_to_g_for_rt
from		trtDiagnosisToGroupForReportType d_to_g_for_rt
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = d_to_g_for_rt.idfsDiagnosis
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Custom report diagnoses groups'' membership by diagnosis (trtDiagnosisToGroupForReportType): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

delete		d_to_g_for_rt
from		trtSpeciesToGroupForCustomReport d_to_g_for_rt
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = d_to_g_for_rt.idfsCustomReportType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Custom report species groups'' membership by custom report type (trtSpeciesToGroupForCustomReport): ' + cast(@N as nvarchar(20))

delete		d_to_g_for_rt
from		trtSpeciesToGroupForCustomReport d_to_g_for_rt
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = d_to_g_for_rt.idfsSpeciesGroup
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Custom report species groups'' membership by custom report species group (trtSpeciesToGroupForCustomReport): ' + cast(@N as nvarchar(20))

delete		d_to_g_for_rt
from		trtSpeciesToGroupForCustomReport d_to_g_for_rt
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = d_to_g_for_rt.idfsSpeciesType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Custom report species groups'' membership by species (trtSpeciesToGroupForCustomReport): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

delete		bra_to_c
from		trtBaseReferenceAttribute bra
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = bra.idfsBaseReference
inner join	trtBaseReferenceAttributeToCP bra_to_c
on			bra_to_c.idfBaseReferenceAttribute = bra.idfBaseReferenceAttribute
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the values of reference attributes for custom reports to customization packages by reference (trtBaseReferenceAttributeToCP): ' + cast(@N as nvarchar(20))

delete		bra
from		trtBaseReferenceAttribute bra
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = bra.idfsBaseReference
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Values of reference attributes for custom reports by reference (trtBaseReferenceAttribute): ' + cast(@N as nvarchar(20))

/*TODO:remove--
delete		bra_to_c_another
from		trtBaseReferenceAttribute bra
inner join	trtBaseReferenceAttributeToCP bra_to_c_another
on			bra_to_c_another.idfBaseReferenceAttribute = bra.idfBaseReferenceAttribute
			and bra_to_c_another.idfCustomizationPackage <> @idfCustomizationPackage
where		not exists	(
					select	*
					from	trtBaseReferenceAttributeToCP bra_to_c
					where	bra_to_c.idfBaseReferenceAttribute = bra.idfBaseReferenceAttribute
							and bra_to_c.idfCustomizationPackage = @idfCustomizationPackage
						)
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the values of reference attributes for custom reports to customization packages by customization package (trtBaseReferenceAttributeToCP): ' + cast(@N as nvarchar(20))
*/

delete		bra
from		trtBaseReferenceAttribute bra
left join	trtBaseReferenceAttributeToCP bra_to_c
on			bra_to_c.idfBaseReferenceAttribute = bra.idfBaseReferenceAttribute
			and bra_to_c.idfCustomizationPackage = @idfCustomizationPackage
where		bra_to_c.idfBaseReferenceAttribute is null
			and exists	(
					select	*
					from	trtBaseReferenceAttributeToCP bra_to_c_any
					where	bra_to_c_any.idfBaseReferenceAttribute = bra.idfBaseReferenceAttribute
						)
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Values of reference attributes for custom reports by customization package (trtBaseReferenceAttribute): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

insert into	#LogTable (strMessage)
select	N''

delete		af
from		tasAggregateFunction af
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = af.idfsAggregateFunction
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    AVR aggregate functions (tasAggregateFunction): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''


delete		fs_for_t
from		tasFieldSourceForTable fs_for_t
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = fs_for_t.idfsSearchField
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Source of AVR search fields for the queries (tasFieldSourceForTable): ' + cast(@N as nvarchar(20))

delete		sf_to_p
from		tasSearchFieldToFFParameter sf_to_p
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = sf_to_p.idfsSearchField
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Link from AVR search fields to FF parameters by search field (tasSearchFieldToFFParameter): ' + cast(@N as nvarchar(20))

delete		sf_to_pdg
from		tasSearchFieldToPersonalDataGroup sf_to_pdg
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = sf_to_pdg.idfsSearchField
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Link from AVR search fields to personal data groups by search field (tasSearchFieldToPersonalDataGroup): ' + cast(@N as nvarchar(20))

delete		sf
from		tasSearchField sf
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = sf.idfsSearchField
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    AVR search fields (tasSearchField): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

delete		giso_for_cr
from		trtGISObjectForCustomReport giso_for_cr
where		giso_for_cr.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from GIS objects to custom reports, marked as deleted (trtGISObjectForCustomReport): ' + cast(@N as nvarchar(20))

delete		giso_for_cr
from		trtGISObjectForCustomReport giso_for_cr
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = giso_for_cr.idfsCustomReportType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Links from GIS objects to custom reports by custom report type (trtGISObjectForCustomReport): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

delete		rr
from		trtReportRows rr
where		rr.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of custom reports, marked as deleted (trtReportRows): ' + cast(@N as nvarchar(20))

delete		rr
from		trtReportRows rr
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = rr.idfsCustomReportType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Rows of custom reports by custom report type (trtReportRows): ' + cast(@N as nvarchar(20))

delete		rr
from		trtReportRows rr
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = rr.idfsDiagnosisOrReportDiagnosisGroup
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of custom reports by diagnosis and/or custom report diagnosis group (trtReportRows): ' + cast(@N as nvarchar(20))

delete		rr
from		trtReportRows rr
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = rr.idfsReportAdditionalText
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of custom reports by custom report additional text (trtReportRows): ' + cast(@N as nvarchar(20))

delete		rr
from		trtReportRows rr
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = rr.idfsICDReportAdditionalText
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Rows of custom reports by custom report additional text for diagnosis ICD-10 (trtReportRows): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

delete		rr
from		trtSpeciesContentInCustomReport rr
where		rr.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Species content of custom reports, marked as deleted (trtSpeciesContentInCustomReport): ' + cast(@N as nvarchar(20))

delete		rr
from		trtSpeciesContentInCustomReport rr
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = rr.idfsCustomReportType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'        Species content of custom reports by custom report type (trtSpeciesContentInCustomReport): ' + cast(@N as nvarchar(20))

delete		rr
from		trtSpeciesContentInCustomReport rr
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = rr.idfsSpeciesOrSpeciesGroup
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Species content of custom reports by species and/or custom report species group (trtSpeciesContentInCustomReport): ' + cast(@N as nvarchar(20))

delete		rr
from		trtSpeciesContentInCustomReport rr
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = rr.idfsReportAdditionalText
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Species content of custom reports by custom report additional text (trtSpeciesContentInCustomReport): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''


delete		tt_for_cr
from		trtTestTypeForCustomReport tt_for_cr
where		tt_for_cr.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from test names to custom reports, marked as deleted (trtTestTypeForCustomReport): ' + cast(@N as nvarchar(20))

delete		tt_for_cr
from		trtTestTypeForCustomReport tt_for_cr
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = tt_for_cr.idfsCustomReportType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from test names to custom reports by custom report type (trtTestTypeForCustomReport): ' + cast(@N as nvarchar(20))

delete		tt_for_cr
from		trtTestTypeForCustomReport tt_for_cr
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = tt_for_cr.idfsTestName
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from test names to custom reports by test name (trtTestTypeForCustomReport): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''


delete		ffp_to_d_for_cr
from		trtFFObjectToDiagnosisForCustomReport ffp_to_d_for_cr
where		ffp_to_d_for_cr.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links, marked as deleted, from diagnosis specific parameters of custom reports to FF objects (trtFFObjectToDiagnosisForCustomReport): ' + cast(@N as nvarchar(20))

delete		ffp_to_d_for_cr
from		trtFFObjectToDiagnosisForCustomReport ffp_to_d_for_cr
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ffp_to_d_for_cr.idfsDiagnosis
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from diagnosis specific parameters of custom reports to FF objects by diagnosis (trtFFObjectToDiagnosisForCustomReport): ' + cast(@N as nvarchar(20))

delete		ffp_to_d_for_cr
from		trtFFObjectToDiagnosisForCustomReport ffp_to_d_for_cr
inner join	trtFFObjectForCustomReport ffp_for_cr
on			ffp_for_cr.idfFFObjectForCustomReport = ffp_to_d_for_cr.idfFFObjectForCustomReport
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ffp_for_cr.idfsCustomReportType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from diagnosis specific parameters of custom reports to FF objects by custom report type (trtFFObjectToDiagnosisForCustomReport): ' + cast(@N as nvarchar(20))

delete		ffp_to_d_for_cr
from		trtFFObjectToDiagnosisForCustomReport ffp_to_d_for_cr
inner join	trtFFObjectForCustomReport ffp_for_cr
on			ffp_for_cr.idfFFObjectForCustomReport = ffp_to_d_for_cr.idfFFObjectForCustomReport
where		ffp_for_cr.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from diagnosis specific parameters, marked as deleted, of custom reports to FF objects (trtFFObjectToDiagnosisForCustomReport): ' + cast(@N as nvarchar(20))


delete		ffp_for_cr
from		trtFFObjectForCustomReport ffp_for_cr
where		ffp_for_cr.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links, marked as deleted, from parameters of custom reports to FF objects (trtFFObjectForCustomReport): ' + cast(@N as nvarchar(20))

delete		ffp_for_cr
from		trtFFObjectForCustomReport ffp_for_cr
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ffp_for_cr.idfsCustomReportType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from parameters of custom reports to FF objects by custom report type (trtFFObjectForCustomReport): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

insert into	#LogTable (strMessage)
select	N''

delete		bssac
from		trtBssAggregateColumns bssac
where		(	bssac.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	bssac.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
set	@N = @@rowcount

if	@DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'    Basic Syndromic Surveillance Aggregate Columns marked as deleted (trtBssAggregateColumns): ' + cast(@N as nvarchar(20))

delete		bssac
from		trtBssAggregateColumns bssac
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = bssac.idfsBssAggregateColumn
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Basic Syndromic Surveillance Aggregate Columns (trtBssAggregateColumns): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''


delete		cc
from		trtCaseClassification cc
where		(	cc.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	cc.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
set	@N = @@rowcount

if	@DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'    Case Classifications marked as deleted (trtCaseClassification): ' + cast(@N as nvarchar(20))

delete		cc
from		trtCaseClassification cc
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = cc.idfsCaseClassification
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Case Classifications (trtCaseClassification): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''


-- TODO: Remove GG specific condition
if IsNull(@CustomizationPackage, N'DTRA') <> N'Georgia' and @DeleteHistoricalRecordsMarkedAsDeleted = 1
begin
	delete		d
	from		trtDiagnosis d
	where		d.intRowStatus <> 0
				and	(	d.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
	set	@N = @@rowcount

	insert into	#LogTable (strMessage)
	select	N'    Diagnoses marked as deleted (trtDiagnosis): ' + cast(@N as nvarchar(20))

end

delete		d
from		trtDiagnosis d
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = d.idfsDiagnosis
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Diagnoses (trtDiagnosis): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

delete		ag
from		trtDiagnosisAgeGroup ag
where		(	ag.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	ag.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
set	@N = @@rowcount

if	@DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'    Age Groups marked as deleted (trtDiagnosisAgeGroup): ' + cast(@N as nvarchar(20))

delete		ag
from		trtDiagnosisAgeGroup ag
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ag.idfsDiagnosisAgeGroup
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Age Groups (trtDiagnosisAgeGroup): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

delete		rdg
from		trtReportDiagnosisGroup rdg
where		(	rdg.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	rdg.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
set	@N = @@rowcount

if	@DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'    Custom report diagnoses'' groups marked as deleted (trtReportDiagnosisGroup): ' + cast(@N as nvarchar(20))

delete		rdg
from		trtReportDiagnosisGroup rdg
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = rdg.idfsReportDiagnosisGroup
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Custom report diagnoses'' groups (trtReportDiagnosisGroup): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

insert into	#LogTable (strMessage)
select	N''

delete		rdg
from		trtSpeciesGroup rdg
where		(	rdg.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	rdg.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
set	@N = @@rowcount

if	@DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'    Custom report species'' groups marked as deleted (trtSpeciesGroup): ' + cast(@N as nvarchar(20))

delete		rdg
from		trtSpeciesGroup rdg
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = rdg.idfsSpeciesGroup
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Custom report species'' groups (trtSpeciesGroup): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

delete		pa
from		trtProphilacticAction pa
where		(	pa.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	pa.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
set	@N = @@rowcount

if	@DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'    Prophylactic measures marked as deleted (trtProphilacticAction): ' + cast(@N as nvarchar(20))

delete		pa
from		trtProphilacticAction pa
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = pa.idfsProphilacticAction
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Prophylactic measures (trtProphilacticAction): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''


delete		st
from		trtSampleType st
where		(	st.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	st.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
set	@N = @@rowcount

if	@DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'    Sample Types marked as deleted (trtSampleType): ' + cast(@N as nvarchar(20))

delete		st
from		trtSampleType st
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = st.idfsSampleType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Sample Types (trtSampleType): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''


delete		sa
from		trtSanitaryAction sa
where		(	sa.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	sa.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
set	@N = @@rowcount

if	@DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'    Sanitary measures marked as deleted (trtSanitaryAction): ' + cast(@N as nvarchar(20))

delete		sa
from		trtSanitaryAction sa
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = sa.idfsSanitaryAction
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Sanitary measures (trtSanitaryAction): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

delete		st
from		trtSpeciesType st
where		(	st.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	st.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
set	@N = @@rowcount

if	@DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'    Species Types marked as deleted (trtSpeciesType): ' + cast(@N as nvarchar(20))

delete		st
from		trtSpeciesType st
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = st.idfsSpeciesType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Species Types (trtSpeciesType): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

delete		s
from		tlbStatistic s
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = s.idfsStatisticalAgeGroup
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Statistics'' values by statistical age group (tlbStatistic): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

delete		s
from		tlbStatistic s
inner join	trtStatisticDataType sdt
on			sdt.idfsStatisticDataType = s.idfsStatisticDataType
where		(	sdt.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	sdt.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
set	@N = @@rowcount

if	@DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'    Statistics'' values by statistical data type marked as deleted (tlbStatistic): ' + cast(@N as nvarchar(20))

delete		sdt
from		trtStatisticDataType sdt
where		(	sdt.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	sdt.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
set	@N = @@rowcount

if	@DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'    Statistical Data Types marked as deleted (trtStatisticDataType): ' + cast(@N as nvarchar(20))

delete		s
from		tlbStatistic s
inner join	trtStatisticDataType sdt
on			sdt.idfsStatisticDataType = s.idfsStatisticDataType
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = sdt.idfsStatisticDataType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Statistics'' values by statistical data type (tlbStatistic): ' + cast(@N as nvarchar(20))

delete		sdt
from		trtStatisticDataType sdt
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = sdt.idfsStatisticDataType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Statistical Data Types (trtStatisticDataType): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''


delete		vst
from		trtVectorSubType vst
where		(	vst.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	vst.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
set	@N = @@rowcount

if	@DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'    Vector Species Types marked as deleted (trtVectorSubType): ' + cast(@N as nvarchar(20))

delete		vst
from		trtVectorSubType vst
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = vst.idfsVectorSubType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Vector Species Types (trtVectorSubType): ' + cast(@N as nvarchar(20))

delete		vst
from		trtVectorSubType vst
inner join	trtVectorType vt
on			vt.idfsVectorType = vst.idfsVectorType
where		(	vt.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	vt.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
set	@N = @@rowcount

if	@DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'    Vector Species Types by vector type marked as deleted (trtVectorSubType): ' + cast(@N as nvarchar(20))

delete		vst
from		trtVectorSubType vst
inner join	trtVectorType vt
on			vt.idfsVectorType = vst.idfsVectorType
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = vt.idfsVectorType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Vector Species Types by vector type (trtVectorSubType): ' + cast(@N as nvarchar(20))

delete		vt
from		trtVectorType vt
where		(	vt.intRowStatus <> 0
				and @DeleteHistoricalRecordsMarkedAsDeleted = 1
				and (	vt.intRowStatus = @DeletionFlag
						or	@DeletionFlag = 1
					)
			)
set	@N = @@rowcount

if	@DeleteHistoricalRecordsMarkedAsDeleted = 1
	insert into	#LogTable (strMessage)
	select	N'    Vector Types marked as deleted (trtVectorType): ' + cast(@N as nvarchar(20))

delete		vt
from		trtVectorType vt
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = vt.idfsVectorType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Vector Types (trtVectorType): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''


-- delete incorrect Object Types

delete		oa
from		tstObjectAccess oa
inner join	trtObjectTypeToObjectOperation ot_to_oo
on			ot_to_oo.idfsObjectOperation = oa.idfsObjectOperation
			and ot_to_oo.idfsObjectType = oa.idfsObjectType
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ot_to_oo.idfsObjectType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Permissions with specified type of the object to delete (tstObjectAccess): ' + cast(@N as nvarchar(20))

delete		oa
from		tstObjectAccess oa
inner join	trtSystemFunction sf
on			sf.idfsSystemFunction = oa.idfsObjectID
inner join	trtObjectTypeToObjectOperation ot_to_oo
on			ot_to_oo.idfsObjectOperation = oa.idfsObjectOperation
			and ot_to_oo.idfsObjectType = sf.idfsObjectType
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ot_to_oo.idfsObjectType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Permissions to the object (system function/diagnosis/site) of the type to delete (tstObjectAccess): ' + cast(@N as nvarchar(20))

delete		ot_to_oo
from		trtObjectTypeToObjectOperation ot_to_oo
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = ot_to_oo.idfsObjectType
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the object type to avialable operations with the object (trtObjectTypeToObjectOperation): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

delete		l_to_c
from		trtLanguageToCP l_to_c
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = l_to_c.idfsLanguage
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from countries to languages (trtLanguageToCP): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

insert into	#LogTable (strMessage)
select	N''

-- delete base references

delete		snt
from		trtStringNameTranslation snt
where		snt.intRowStatus <> 0 -- do not belong to historical records
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Translations, marked as deleted, of the reference values (trtStringNameTranslation): ' + cast(@N as nvarchar(20))

delete		snt
from		trtStringNameTranslation snt
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = snt.idfsLanguage
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Translations of the reference values by language (trtStringNameTranslation): ' + cast(@N as nvarchar(20))

delete		snt
from		trtStringNameTranslation snt
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = snt.idfsBaseReference
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Translations of the reference values by reference value (trtStringNameTranslation): ' + cast(@N as nvarchar(20))

delete		br_to_c
from		trtBaseReferenceToCP br_to_c
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = br_to_c.idfsBaseReference
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Links from the reference values to customization packages by reference value (trtBaseReferenceToCP): ' + cast(@N as nvarchar(20))

delete		br
from		trtBaseReference br
inner join	#BR_To_Del br_del
on			br_del.idfsBaseReference = br.idfsBaseReference
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Reference values (trtBaseReference): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''



-- Define table with AVR objects to mark as deleted
create table	#AVRObject_To_MarkAsDel
(	idfID					bigint not null identity (1, 1),
	idfsSearchObject		bigint not null primary key,
	strDescription			nvarchar(3000) collate database_default null
)

-- Define table with AVR fields to mark as deleted
create table	#AVRField_To_MarkAsDel
(	idfID					bigint not null identity (1, 1),
	idfsSearchObject		bigint not null,
	idfsSearchField			bigint not null primary key,
	strDescription			nvarchar(3000) collate database_default null
)

/*TODO:remove--
insert into	#AVRObject_To_MarkAsDel	(idfsSearchObject, strDescription)
select		so.idfsSearchObject,
			N'    - ' + replace(IsNull(rt.strReferenceTypeName, N'*'), N'''', N'''''') + N': [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'
from		trtBaseReference br
inner join	trtReferenceType rt	-- Reference Type Name
on			rt.idfsReferenceType = br.idfsReferenceType
inner join	tasSearchObject so
on			so.idfsSearchObject = br.idfsBaseReference
left join	trtBaseReferenceToCP br_to_correct_c
on			br_to_correct_c.idfsBaseReference = br.idfsBaseReference
			and br_to_correct_c.idfCustomizationPackage = @idfCustomizationPackage
where		br.idfsReferenceType = 19000082 -- AVR Search Object
			and exists	(
					select		*
					from		trtBaseReferenceToCP br_to_c
					where		br_to_c.idfsBaseReference = br.idfsBaseReference
						)
			-- there is at least one link from any search object to current customization package
			and exists	(
					select		*
					from		trtBaseReferenceToCP so_all_to_correct_c
					join		tasSearchObject so_all
					on			so_all.idfsSearchObject = so_all_to_correct_c.idfsBaseReference
					where		so_all_to_correct_c.idfCustomizationPackage = @idfCustomizationPackage
						)
			and	(	br.intRowStatus <> 0
					or	so.intRowStatus <> 0
					or	br_to_correct_c.idfsBaseReference is null
				)
order by	rt.strReferenceTypeName, br.strDefault, so.idfsSearchObject

insert into	#AVRField_To_MarkAsDel	(idfsSearchObject, idfsSearchField, strDescription)
select		sf.idfsSearchObject,
			sf.idfsSearchField,
			N'    - ' + replace(IsNull(rt.strReferenceTypeName, N'*'), N'''', N'''''') + N': [' + replace(IsNull(br_so.strDefault, N'*'), N'''', N'''''') + N'] -> [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'
-- AVR fields of objects to be marked as deleted
from		trtBaseReference br
inner join	trtReferenceType rt	-- Reference Type Name
on			rt.idfsReferenceType = br.idfsReferenceType
inner join	tasSearchField sf
on			sf.idfsSearchObject = br.idfsBaseReference
inner join	#AVRObject_To_MarkAsDel avro_to_del
on			avro_to_del.idfsSearchObject = sf.idfsSearchObject
inner join	trtBaseReference br_so
on			br_so.idfsBaseReference = sf.idfsSearchObject
where		br.idfsReferenceType = 19000080 -- AVR Search Field
order by	rt.strReferenceTypeName, br_so.strDefault, sf.idfsSearchObject, br.strDefault, sf.idfsSearchField


insert into	#AVRField_To_MarkAsDel	(idfsSearchObject, idfsSearchField, strDescription)
select		so.idfsSearchObject,
			sf.idfsSearchField,
			N'    - ' + replace(IsNull(rt.strReferenceTypeName, N'*'), N'''', N'''''') + N': [' + replace(IsNull(br_so.strDefault, N'*'), N'''', N'''''') + N'] -> [' + replace(IsNull(br.strDefault, N'*'), N'''', N'''''') + N']'
from		trtBaseReference br
inner join	trtReferenceType rt	-- Reference Type Name
on			rt.idfsReferenceType = br.idfsReferenceType
inner join	tasSearchField sf
on			sf.idfsSearchObject = br.idfsBaseReference
inner join	tasSearchObject so
on			so.idfsSearchObject = sf.idfsSearchObject
inner join	trtBaseReference br_so
on			br_so.idfsBaseReference = so.idfsSearchObject
left join	trtBaseReferenceToCP br_to_correct_c
on			br_to_correct_c.idfsBaseReference = br.idfsBaseReference
			and br_to_correct_c.idfCustomizationPackage = @idfCustomizationPackage
left join	#AVRField_To_MarkAsDel avrf_to_del
on			avrf_to_del.idfsSearchField = sf.idfsSearchField
where		br.idfsReferenceType = 19000080 -- AVR Search Field
			and exists	(
					select		*
					from		trtBaseReferenceToCP br_to_c
					where		br_to_c.idfsBaseReference = br.idfsBaseReference
						)
			-- there is at least one link from any search field to current customization package
			and exists	(
					select		*
					from		trtBaseReferenceToCP sf_all_to_correct_c
					join		tasSearchField sf_all
					on			sf_all.idfsSearchField = sf_all_to_correct_c.idfsBaseReference
					where		sf_all_to_correct_c.idfCustomizationPackage = @idfCustomizationPackage
						)
			and	(	br.intRowStatus <> 0
					or	sf.intRowStatus <> 0
					or	br_to_correct_c.idfsBaseReference is null
				)
			and avrf_to_del.idfID is null
order by	rt.strReferenceTypeName, br_so.strDefault, so.idfsSearchObject, br.strDefault, sf.idfsSearchField


insert into	#LogTable (strMessage)
select	N'AVR objects to hide for customization package [' + @CustomizationPackage + N']: '

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

insert into	#LogTable (strMessage)
select		strDescription
from		#AVRObject_To_MarkAsDel
order by	idfID

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

insert into	#LogTable (strMessage)
select	N'AVR fields to hide for customization package [' + @CustomizationPackage + N']: '

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

insert into	#LogTable (strMessage)
select		strDescription
from		#AVRField_To_MarkAsDel
order by	idfID

insert into	#LogTable (strMessage)
select	N'-----------------------------------'

insert into	#LogTable (strMessage)
select	N''

-- Delete references and related info
insert into	#LogTable (strMessage)
select	N'Hide AVR objects, fields and related info'

update		sf
set			sf.intRowStatus = 1
from		tasSearchField sf
inner join	#AVRField_To_MarkAsDel avrf_del
on			avrf_del.idfsSearchField = sf.idfsSearchField
where		sf.intRowStatus <> 1
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Hide (mark as deleted) AVR fields (tasSearchField): ' + cast(@N as nvarchar(20))

update		br
set			br.intRowStatus = 1
from		trtBaseReference br
inner join	#AVRField_To_MarkAsDel avrf_del
on			avrf_del.idfsSearchField = br.idfsBaseReference
where		br.intRowStatus <> 1
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Hide (mark as deleted) AVR fields (trtBaseReference): ' + cast(@N as nvarchar(20))

update		so
set			so.intRowStatus = 1
from		tasSearchObject so
inner join	#AVRObject_To_MarkAsDel avro_del
on			avro_del.idfsSearchObject = so.idfsSearchObject
where		so.intRowStatus <> 1
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Hide (mark as deleted) AVR objects (tasSearchObject): ' + cast(@N as nvarchar(20))

update		br
set			br.intRowStatus = 1
from		trtBaseReference br
inner join	#AVRObject_To_MarkAsDel avro_del
on			avro_del.idfsSearchObject = br.idfsBaseReference
where		br.intRowStatus <> 1
set	@N = @@rowcount
*/

insert into	#LogTable (strMessage)
select	N'    Hide (mark as deleted) AVR objects (trtBaseReference): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''


-- Delete matrix headers without matrix content
delete		amvh
from		tlbAggrMatrixVersionHeader amvh
left join	tlbAggrDiagnosticActionMTX ada
on			ada.idfVersion = amvh.idfVersion
left join	tlbAggrHumanCaseMTX ahc
on			ahc.idfVersion = amvh.idfVersion
left join	tlbAggrProphylacticActionMTX apa
on			apa.idfVersion = amvh.idfVersion
left join	tlbAggrSanitaryActionMTX asa
on			asa.idfVersion = amvh.idfVersion
left join	tlbAggrVetCaseMTX avc
on			avc.idfVersion = amvh.idfVersion
where		ada.idfAggrDiagnosticActionMTX is null
			and ahc.idfAggrHumanCaseMTX is null
			and apa.idfAggrProphylacticActionMTX is null
			and asa.idfAggrSanitaryActionMTX is null
			and avc.idfAggrVetCaseMTX is null
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Aggregate matrixes not containing at least one cell (tlbAggrMatrixVersionHeader): ' + cast(@N as nvarchar(20))

insert into	#LogTable (strMessage)
select	N''

insert into	#LogTable (strMessage)
select	N''

insert into	#LogTable (strMessage)
select	N'Remove names of user-defined groups  '

insert into	#LogTable (strMessage)
select	N''


delete brc
from trtBaseReference br
join	trtBaseReferenceToCP brc
on brc.idfsBaseReference = br.idfsBaseReference
where br.idfsBaseReference < -512 /*Last standard user group*/
		and br.idfsReferenceType = 19000022 /*Employee Group Name*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Names of user-defined groups (trtBaseReferenceToCP): ' + cast(@N as nvarchar(20))


delete sntc
from trtBaseReference br
join	trtStringNameTranslationToCP sntc
on sntc.idfsBaseReference = br.idfsBaseReference
where br.idfsBaseReference < -512 /*Last standard user group*/
		and br.idfsReferenceType = 19000022 /*Employee Group Name*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Names of user-defined groups (trtStringNameTranslationToCP): ' + cast(@N as nvarchar(20))


delete snt
from trtBaseReference br
join	trtStringNameTranslation snt
on snt.idfsBaseReference = br.idfsBaseReference
where br.idfsBaseReference < -512 /*Last standard user group*/
		and br.idfsReferenceType = 19000022 /*Employee Group Name*/
		and br.idfsReferenceType = 19000022 /*Employee Group Name*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Names of user-defined groups (trtStringNameTranslation): ' + cast(@N as nvarchar(20))


delete br
from trtBaseReference br
where br.idfsBaseReference < -512 /*Last standard user group*/
		and br.idfsReferenceType = 19000022 /*Employee Group Name*/
set	@N = @@rowcount

insert into	#LogTable (strMessage)
select	N'    Names of user-defined groups (trtBaseReference): ' + cast(@N as nvarchar(20))


insert into	#LogTable (strMessage)
select	N''

insert into	#LogTable (strMessage)
select	N''

insert into	#LogTable (strMessage)
select	N''



if @Country is not null
begin
	--TODO: remove CustomizationCountry - start
	if exists (select * from tstGlobalSiteOptions where strName = N'CustomizationCountry')
		update	tstGlobalSiteOptions
		set		strValue = cast(@Country as nvarchar(200)),
				idfsSite = null,
				intRowStatus = 0
		where	strName = N'CustomizationCountry'
	else
		insert into	tstGlobalSiteOptions (strName, strValue, idfsSite, intRowStatus)
		values (N'CustomizationCountry', @Country, null, 0)

	insert into	#LogTable (strMessage)
	select	N'Set the global option of the database "Customization Country" to the country with HASC [' + @CountryHASC + N']'
	--TODO: remove CustomizationCountry - end
	
	if exists (select * from tstGlobalSiteOptions where strName = N'CustomizationPackage')
		update	tstGlobalSiteOptions
		set		strValue = cast(@idfCustomizationPackage as nvarchar(200)),
				idfsSite = null,
				intRowStatus = 0
		where	strName = N'CustomizationPackage'
	else
		insert into	tstGlobalSiteOptions (strName, strValue, idfsSite, intRowStatus)
		values (N'CustomizationPackage', @idfCustomizationPackage, null, 0)

	insert into	#LogTable (strMessage)
	select	N'Set the global option of the database "Customization Package" to [' + @CustomizationPackage + N']'

	update		gso
	set			strValue = cast(cps.intFirstDayOfWeek as nvarchar(20))
	from		tstGlobalSiteOptions gso
	inner join	tstCustomizationPackageSettings cps
	on			cps.idfCustomizationPackage = @idfAdminInfoCustomizationPackage
	where		strName = N'FirstDayOfWeek'
				and isnull(strValue, N'') <> cast(cps.intFirstDayOfWeek as nvarchar(20))

	if not exists (select * from tstGlobalSiteOptions where strName = N'FirstDayOfWeek')
	insert into	tstGlobalSiteOptions (strName, strValue)
	select		N'FirstDayOfWeek', cast(cps.intFirstDayOfWeek as nvarchar(20))
	from		tstCustomizationPackageSettings cps
	where		cps.idfCustomizationPackage = @idfAdminInfoCustomizationPackage

	insert into	#LogTable (strMessage)
	select	N'Set the global option of the database "FirstDayOfWeek" for administrative customization package [' + @AdminInfoCustomizationPackage + N']'


	update		gso
	set			strValue = cast(cps.intCalendarWeekRule as nvarchar(20))
	from		tstGlobalSiteOptions gso
	inner join	tstCustomizationPackageSettings cps
	on			cps.idfCustomizationPackage = @idfAdminInfoCustomizationPackage
	where		strName = N'CalendarWeekRule'
				and isnull(strValue, N'') <> cast(cps.intCalendarWeekRule as nvarchar(20))

	if not exists (select * from tstGlobalSiteOptions where strName = N'CalendarWeekRule')
	insert into	tstGlobalSiteOptions (strName, strValue)
	select		N'CalendarWeekRule', cast(cps.intCalendarWeekRule as nvarchar(20))
	from		tstCustomizationPackageSettings cps
	where		cps.idfCustomizationPackage = @idfAdminInfoCustomizationPackage

	insert into	#LogTable (strMessage)
	select	N'Set the global option of the database "CalendarWeekRule" for administrative customization package [' + @AdminInfoCustomizationPackage + N']'


	update		gso
	set			strValue = cast(cps.intWhoReportPeriod as nvarchar(20))
	from		tstGlobalSiteOptions gso
	inner join	tstCustomizationPackageSettings cps
	on			cps.idfCustomizationPackage = @idfAdminInfoCustomizationPackage
	where		strName = N'WhoReportPeriod'
				and isnull(strValue, N'') <> cast(cps.intWhoReportPeriod as nvarchar(20))

	if not exists (select * from tstGlobalSiteOptions where strName = N'WhoReportPeriod')
	insert into	tstGlobalSiteOptions (strName, strValue)
	select		N'WhoReportPeriod', cast(cps.intWhoReportPeriod as nvarchar(20))
	from		tstCustomizationPackageSettings cps
	where		cps.idfCustomizationPackage = @idfAdminInfoCustomizationPackage

	insert into	#LogTable (strMessage)
	select	N'Set the global option of the database "WhoReportPeriod" for administrative customization package [' + @AdminInfoCustomizationPackage + N']'


	update		gso
	set			strValue = cast(cps.intForcedReplicationPeriodSlvl as nvarchar(20))
	from		tstGlobalSiteOptions gso
	inner join	tstCustomizationPackageSettings cps
	on			cps.idfCustomizationPackage = @idfAdminInfoCustomizationPackage
	where		strName = N'ForcedReplicationPeriodSlvl'
				and isnull(strValue, N'') <> cast(cps.intForcedReplicationPeriodSlvl as nvarchar(20))

	if not exists (select * from tstGlobalSiteOptions where strName = N'ForcedReplicationPeriodSlvl')
	insert into	tstGlobalSiteOptions (strName, strValue)
	select		N'ForcedReplicationPeriodSlvl', cast(cps.intForcedReplicationPeriodSlvl as nvarchar(20))
	from		tstCustomizationPackageSettings cps
	where		cps.idfCustomizationPackage = @idfAdminInfoCustomizationPackage

	insert into	#LogTable (strMessage)
	select	N'Set the global option of the database "ForcedReplicationPeriodSlvl" for administrative customization package [' + @AdminInfoCustomizationPackage + N']'


	update		gso
	set			strValue = cast(cps.intForcedReplicationPeriodTlvl as nvarchar(20))
	from		tstGlobalSiteOptions gso
	inner join	tstCustomizationPackageSettings cps
	on			cps.idfCustomizationPackage = @idfAdminInfoCustomizationPackage
	where		strName = N'ForcedReplicationPeriodTlvl'
				and isnull(strValue, N'') <> cast(cps.intForcedReplicationPeriodTlvl as nvarchar(20))

	if not exists (select * from tstGlobalSiteOptions where strName = N'ForcedReplicationPeriodTlvl')
	insert into	tstGlobalSiteOptions (strName, strValue)
	select		N'ForcedReplicationPeriodTlvl', cast(cps.intForcedReplicationPeriodTlvl as nvarchar(20))
	from		tstCustomizationPackageSettings cps
	where		cps.idfCustomizationPackage = @idfAdminInfoCustomizationPackage

	insert into	#LogTable (strMessage)
	select	N'Set the global option of the database "ForcedReplicationPeriodTlvl" for administrative customization package [' + @AdminInfoCustomizationPackage + N']'


	update		gso
	set			strValue = cast(cps.intForcedReplicationExpirationPeriodCdr as nvarchar(20))
	from		tstGlobalSiteOptions gso
	inner join	tstCustomizationPackageSettings cps
	on			cps.idfCustomizationPackage = @idfAdminInfoCustomizationPackage
	where		strName = N'ForcedReplicationExpirationPeriodCdr'
				and isnull(strValue, N'') <> cast(cps.intForcedReplicationExpirationPeriodCdr as nvarchar(20))

	if not exists (select * from tstGlobalSiteOptions where strName = N'ForcedReplicationExpirationPeriodCdr')
	insert into	tstGlobalSiteOptions (strName, strValue)
	select		N'ForcedReplicationExpirationPeriodCdr', cast(cps.intForcedReplicationExpirationPeriodCdr as nvarchar(20))
	from		tstCustomizationPackageSettings cps
	where		cps.idfCustomizationPackage = @idfAdminInfoCustomizationPackage

	insert into	#LogTable (strMessage)
	select	N'Set the global option of the database "ForcedReplicationExpirationPeriodCdr" for administrative customization package [' + @AdminInfoCustomizationPackage + N']'


	update		gso
	set			strValue = cast(cps.intForcedReplicationExpirationPeriodSlvl as nvarchar(20))
	from		tstGlobalSiteOptions gso
	inner join	tstCustomizationPackageSettings cps
	on			cps.idfCustomizationPackage = @idfAdminInfoCustomizationPackage
	where		strName = N'ForcedReplicationExpirationPeriodSlvl'
				and isnull(strValue, N'') <> cast(cps.intForcedReplicationExpirationPeriodSlvl as nvarchar(20))

	if not exists (select * from tstGlobalSiteOptions where strName = N'ForcedReplicationExpirationPeriodSlvl')
	insert into	tstGlobalSiteOptions (strName, strValue)
	select		N'ForcedReplicationExpirationPeriodSlvl', cast(cps.intForcedReplicationExpirationPeriodSlvl as nvarchar(20))
	from		tstCustomizationPackageSettings cps
	where		cps.idfCustomizationPackage = @idfAdminInfoCustomizationPackage

	insert into	#LogTable (strMessage)
	select	N'Set the global option of the database "ForcedReplicationExpirationPeriodSlvl" for administrative customization package [' + @AdminInfoCustomizationPackage + N']'


	update		gso
	set			strValue = cast(cps.intForcedReplicationExpirationPeriodTlvl as nvarchar(20))
	from		tstGlobalSiteOptions gso
	inner join	tstCustomizationPackageSettings cps
	on			cps.idfCustomizationPackage = @idfAdminInfoCustomizationPackage
	where		strName = N'ForcedReplicationExpirationPeriodTlvl'
				and isnull(strValue, N'') <> cast(cps.intForcedReplicationExpirationPeriodTlvl as nvarchar(20))

	if not exists (select * from tstGlobalSiteOptions where strName = N'ForcedReplicationExpirationPeriodTlvl')
	insert into	tstGlobalSiteOptions (strName, strValue)
	select		N'ForcedReplicationExpirationPeriodTlvl', cast(cps.intForcedReplicationExpirationPeriodTlvl as nvarchar(20))
	from		tstCustomizationPackageSettings cps
	where		cps.idfCustomizationPackage = @idfAdminInfoCustomizationPackage

	insert into	#LogTable (strMessage)
	select	N'Set the global option of the database "ForcedReplicationExpirationPeriodTlvl" for administrative customization package [' + @AdminInfoCustomizationPackage + N']'

	delete from	tstCustomizationPackageSettings
	where		idfCustomizationPackage <> @idfAdminInfoCustomizationPackage
				and idfCustomizationPackage <> @idfCustomizationPackage

	insert into	#LogTable (strMessage)
	select	N'Remove Settings of customization packages that differ from both [' + @CustomizationPackage + N'] and [' + @AdminInfoCustomizationPackage + N']'
	
end
else begin
	delete from	tstGlobalSiteOptions
	where		strName = N'CustomizationPackage'

	insert into	#LogTable (strMessage)
	select	N'Clear the global option of the database "Customization Package"'
end


-- Print log
select		datLog as 'Date',
			strMessage as 'Message'
from		#LogTable
order by	idfID


-- Drop temporary tables
if Object_ID('tempdb..#LogTable') is not null
begin
	set	@drop_cmd = N'drop table #LogTable'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#AVRObject_To_MarkAsDel') is not null
begin
	set	@drop_cmd = N'drop table #AVRObject_To_MarkAsDel'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#AVRField_To_MarkAsDel') is not null
begin
	set	@drop_cmd = N'drop table #AVRField_To_MarkAsDel'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#BR_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #BR_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#AggrMatrixPrefix') is not null
begin
	set	@drop_cmd = N'drop table #AggrMatrixPrefix'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#O_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #O_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#Person_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #Person_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#User_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #User_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#EmployeeGroup_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #EmployeeGroup_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#Template_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #Template_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#Section_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #Section_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#Parameter_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #Parameter_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#ParameterType_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #ParameterType_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#Rule_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #Rule_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#P_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #P_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#PT_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #PT_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#L_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #L_To_Del'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#R_To_Del') is not null
begin
	set	@drop_cmd = N'drop table #R_To_Del'
	execute sp_executesql @drop_cmd
end



/*TODO:remove--
DECLARE @MandatoryValidationCreationtDate DATETIME
	, @MandatoryValidationModificationDate DATETIME

SELECT @MandatoryValidationCreationtDate = 
		CASE @idfCustomizationPackage
			WHEN 51577380000000 /*Kazakhstan (MoH)*/ THEN '2014-11-01'
			WHEN 51577410000000 /*Azerbaijan*/ THEN '2014-11-17'
			WHEN 51577430000000 /*Georgia*/ THEN '2014-12-15'
			WHEN 51577420000000 /*Iraq*/ THEN '2015-02-24'
			WHEN 51577490000000 /*Thailand*/ THEN '2015-12-01'
			WHEN 51577400000000 /*Armenia*/ THEN '2016-01-01'
			ELSE '2014-12-01'
		END
	
	, @MandatoryValidationModificationDate = 
		CASE @idfCustomizationPackage
			WHEN 51577380000000 /*Kazakhstan (MoH)*/ THEN '2014-11-01'
			WHEN 51577410000000 /*Azerbaijan*/ THEN '2014-11-17'
			WHEN 51577430000000 /*Georgia*/ THEN '2014-12-15'
			WHEN 51577420000000 /*Iraq*/ THEN '2015-02-24'
			WHEN 51577490000000 /*Thailand*/ THEN '2015-12-01'
			WHEN 51577400000000 /*Armenia*/ THEN '2016-01-01'
			ELSE '2014-12-01'
		END


IF NOT EXISTS (SELECT * FROM tstGlobalSiteOptions WHERE strName = 'MandatoryValidationCreationtDate')	
INSERT INTO tstGlobalSiteOptions
(strName, strValue)
VALUES
('MandatoryValidationCreationtDate', @MandatoryValidationCreationtDate),
('MandatoryValidationModificationDate', @MandatoryValidationModificationDate)

*/



set @sql = N'';

;WITH x AS 
(
  SELECT DISTINCT obj = 
      QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' 
    + QUOTENAME(OBJECT_NAME(parent_object_id)) 
  FROM sys.foreign_keys
)
SELECT @sql += N'ALTER TABLE ' + obj + N' WITH CHECK CHECK CONSTRAINT ALL;
' FROM x;

EXEC sys.sp_executesql @sql;

exec sp_msforeachtable 'ALTER TABLE ? ENABLE TRIGGER all';


IF @@ERROR <> 0
	ROLLBACK TRAN
ELSE
	COMMIT TRAN

set XACT_ABORT off
set nocount off

exec sp_msforeachtable 'ALTER TABLE ? ENABLE TRIGGER all';


set @sql = N'';

;WITH x AS 
(
  SELECT DISTINCT obj = 
      QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' 
    + QUOTENAME(OBJECT_NAME(parent_object_id)) 
  FROM sys.foreign_keys
)
SELECT @sql += N'ALTER TABLE ' + obj + N' WITH CHECK CHECK CONSTRAINT ALL;
' FROM x;

EXEC sys.sp_executesql @sql;


