/*
Author:			Mike Kornegay
Date:			2/27/2023
Description:	1.  Check for AS Species reference type and add if not there 
				2.  Add AS Species type base references
				3.  Update tlbMonitoringSession so all records have a idfsMonitoringSessionSpeciesType
*/

--AS Species Types
--129909620007069 = Avian
--129909620007070 = Livestock

IF NOT EXISTS (SELECT 1 FROM trtReferenceType WHERE idfsReferenceType = 19000538)
BEGIN
	INSERT INTO [dbo].[trtReferenceType]
           ([idfsReferenceType]
           ,[strReferenceTypeCode]
           ,[strReferenceTypeName]
           ,[intStandard]
           ,[idfMinID]
		   ,[idfMaxID]
           ,[rowguid]
		   ,[intRowStatus]
           ,[intHACodeMask]
		   ,[intDefaultHACode]
		   ,[strEditorName]
           ,[strMaintenanceFlag]
           ,[strReservedAttribute]
           ,[SourceSystemNameID]
           ,[SourceSystemKeyValue]
           ,[AuditCreateUser]
           ,[AuditCreateDTM]
           ,[AuditUpdateUser]
           ,[AuditUpdateDTM]
		   ,[strChildTableColumnName]
		   
		   )
     VALUES
          (
			19000538,
			'rftMonitoringSessionSpeciesType',
			'AS Species Type',
			60,
			0,
			0,
			NEWID(),
			0,
			96,
			96,
			'Base Reference Editor',
			N'Add',
			N'EIDSS7 Resources', 
			10519001, 
			N'[{"idfsReferenceType":19000538}]',
			'System', 
			GETDATE(), 
			'System', 
			GETDATE(),
			'idfsMonitoringSessionSpeciesType'
		)
END

IF NOT EXISTS (SELECT 1 FROM trtBaseReference WHERE idfsBaseReference = 129909620007069)
BEGIN
	INSERT INTO [dbo].[trtBaseReference]
           ([idfsBaseReference]
           ,[idfsReferenceType]
           ,[strBaseReferenceCode]
           ,[strDefault]
           ,[intHACode]
           ,[intOrder]
           ,[blnSystem]
           ,[intRowStatus]
           ,[rowguid]
           ,[strMaintenanceFlag]
           ,[strReservedAttribute]
           ,[SourceSystemNameID]
           ,[SourceSystemKeyValue]
           ,[AuditCreateUser]
           ,[AuditCreateDTM]
           ,[AuditUpdateUser]
           ,[AuditUpdateDTM])
     VALUES
          (
			129909620007069,
			19000538,
			'rftMonitoringSessionSpeciesType',
			'Avian',
			96,
			0,
			1,
			0,
			NEWID(),
			N'Add',
			N'EIDSS7 Resources', 
			10519001, 
			N'[{"idfsBaseReference":129909620007069}]',
			'System', 
			GETDATE(), 
			'System', 
			GETDATE()
         )
END
GO

IF NOT EXISTS (SELECT 1 FROM trtBaseReference WHERE idfsBaseReference = 129909620007070)
BEGIN
	INSERT INTO [dbo].[trtBaseReference]
           ([idfsBaseReference]
           ,[idfsReferenceType]
           ,[strBaseReferenceCode]
           ,[strDefault]
           ,[intHACode]
           ,[intOrder]
           ,[blnSystem]
           ,[intRowStatus]
           ,[rowguid]
           ,[strMaintenanceFlag]
           ,[strReservedAttribute]
           ,[SourceSystemNameID]
           ,[SourceSystemKeyValue]
           ,[AuditCreateUser]
           ,[AuditCreateDTM]
           ,[AuditUpdateUser]
           ,[AuditUpdateDTM])
     VALUES
          (
			129909620007070,
			19000538,
			'rftMonitoringSessionSpeciesType',
			'Livestock',
			96,
			0,
			1,
			0,
			NEWID(),
			N'Add',
			N'EIDSS7 Resources', 
			10519001, 
			N'[{"idfsBaseReference":129909620007070}]',
			'System', 
			GETDATE(), 
			'System', 
			GETDATE()
         )
END
GO

declare @Sessions as table 
(
	idfMonitoringSession				bigint,
	intHACode							int,
	idfsMonitoringSessionSpeciesType	bigint
);

insert into	@Sessions
select		msd.idfMonitoringSession,
			br.intHACode,
	(case	br.intHACode 
	when	64 then 129909620007069
	when	32 then 129909620007070
	end)	as idfsMonitoringSessionSpeciesType
from		tlbMonitoringSessionToDiagnosis msd 
join		trtBaseReference br on br.idfsBaseReference = msd.idfsSpeciesType
group by	msd.idfMonitoringSession,
			br.intHACode
order by	msd.idfMonitoringSession

begin tran
update		tlbMonitoringSession
set			idfsMonitoringSessionSpeciesType = s.idfsMonitoringSessionSpeciesType
from		tlbMonitoringSession ms
join		@Sessions s
on			s.idfMonitoringSession = ms.idfMonitoringSession
commit tran
