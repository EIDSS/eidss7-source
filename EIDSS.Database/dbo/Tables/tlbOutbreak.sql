CREATE TABLE [dbo].[tlbOutbreak] (
    [idfOutbreak]                   BIGINT           NOT NULL,
    [idfsDiagnosisOrDiagnosisGroup] BIGINT           NULL,
    [idfsOutbreakStatus]            BIGINT           NULL,
    [idfGeoLocation]                BIGINT           NULL,
    [datStartDate]                  DATETIME         NULL,
    [datFinishDate]                 DATETIME         NULL,
    [strOutbreakID]                 NVARCHAR (200)   NULL,
    [strDescription]                NVARCHAR (2000)  NULL,
    [intRowStatus]                  INT              CONSTRAINT [Def_0_2504] DEFAULT ((0)) NOT NULL,
    [rowguid]                       UNIQUEIDENTIFIER CONSTRAINT [newid__2477] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [datModificationForArchiveDate] DATETIME         CONSTRAINT [tlbOutbreak_datModificationForArchiveDate] DEFAULT (getdate()) NULL,
    [idfPrimaryCaseOrSession]       BIGINT           NULL,
    [idfsSite]                      BIGINT           CONSTRAINT [Def_fnSiteID_tlbOutbreak] DEFAULT ([dbo].[fnSiteID]()) NOT NULL,
    [strMaintenanceFlag]            NVARCHAR (20)    NULL,
    [strReservedAttribute]          NVARCHAR (MAX)   NULL,
    [OutbreakTypeID]                BIGINT           NULL,
    [SourceSystemNameID]            BIGINT           CONSTRAINT [DEF_tlbOutbreak_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue]          NVARCHAR (MAX)   NULL,
    [AuditCreateUser]               NVARCHAR (200)   NULL,
    [AuditCreateDTM]                DATETIME         CONSTRAINT [DF_tlbOutbreak_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]               NVARCHAR (200)   NULL,
    [AuditUpdateDTM]                DATETIME         NULL,
    [idfsLocation] BIGINT NULL, 
    CONSTRAINT [XPKtlbOutbreak] PRIMARY KEY CLUSTERED ([idfOutbreak] ASC),
    CONSTRAINT [FK_tlbOutbreak_BaseRef_OutbreakTypeID] FOREIGN KEY ([OutbreakTypeID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_tlbOutbreak_tlbGeoLocation__idfGeoLocation_R_1469] FOREIGN KEY ([idfGeoLocation]) REFERENCES [dbo].[tlbGeoLocation] ([idfGeoLocation]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbOutbreak_trtBaseReference__idfsDiagnosisOrDiagnosisGroup] FOREIGN KEY ([idfsDiagnosisOrDiagnosisGroup]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbOutbreak_trtBaseReference__idfsOutbreakStatus_R_1262] FOREIGN KEY ([idfsOutbreakStatus]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbOutbreak_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_tlbOutbreak_tstSite__idfsSite] FOREIGN KEY ([idfsSite]) REFERENCES [dbo].[tstSite] ([idfsSite]) NOT FOR REPLICATION,
	CONSTRAINT [FK_tlbOutBreak_idfsLocation_gisLocation] FOREIGN KEY ([idfsLocation]) REFERENCES [dbo].[gisLocation] (idfsLocation) NOT FOR REPLICATION
);


GO

CREATE TRIGGER [dbo].[TR_tlbOutbreak_A_Update] ON [dbo].[tlbOutbreak]
FOR UPDATE
NOT FOR REPLICATION
AS
BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1)
	BEGIN
		IF UPDATE(idfOutbreak)
		BEGIN
			RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
			ROLLBACK TRANSACTION
		END

		ELSE
		BEGIN

			UPDATE a
			SET datModificationForArchiveDate = getdate()
			FROM dbo.tlbOutbreak AS a 
			INNER JOIN INSERTED AS b ON a.idfOutbreak = b.idfOutbreak

		END
	
	END

END

GO


CREATE TRIGGER [dbo].[TR_tlbOutbreak_I_Delete] ON [dbo].[tlbOutbreak]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRecords([idfOutbreak]) as
		(
			SELECT [idfOutbreak] FROM deleted
			EXCEPT
			SELECT [idfOutbreak] FROM inserted
		)
		
		UPDATE a
		SET	intRowStatus = 1, 
			datModificationForArchiveDate = getdate()
		FROM	 dbo.tlbOutbreak AS a 
		INNER JOIN cteOnlyDeletedRecords AS b 
			ON a.idfOutbreak = b.idfOutbreak;

	END

END

GO

CREATE TRIGGER [dbo].[TR_tlbOutbreak_Insert_DF] 
   ON  [dbo].[tlbOutbreak]
   for INSERT
   NOT FOR REPLICATION
AS 
BEGIN
	SET NOCOUNT ON;

	declare @guid uniqueidentifier = newid()
	declare @strTableName nvarchar(128) = N'tlbOutbreak' + cast(@guid as nvarchar(36)) collate Cyrillic_General_CI_AS

	insert into [dbo].[tflNewID] 
		(
			[strTableName], 
			[idfKey1], 
			[idfKey2]
		)
	select  
			@strTableName, 
			ins.[idfOutbreak], 
			sg.[idfSiteGroup]
	from  inserted as ins
		inner join [dbo].[tflSiteToSiteGroup] as stsg with(nolock)
		on   stsg.[idfsSite] = ins.[idfsSite]
		
		inner join [dbo].[tflSiteGroup] sg with(nolock)
		on	sg.[idfSiteGroup] = stsg.[idfSiteGroup]
			and sg.[idfsRayon] is null
			and sg.[idfsCentralSite] is null
			and sg.[intRowStatus] = 0
			
		left join [dbo].[tflOutbreakFiltered] as cf
		on  cf.[idfOutbreak] = ins.[idfOutbreak]
			and cf.[idfSiteGroup] = sg.[idfSiteGroup]
	where  cf.[idfOutbreakFiltered] is null

	insert into [dbo].[tflOutbreakFiltered]
		(
			[idfOutbreakFiltered], 
			[idfOutbreak], 
			[idfSiteGroup]
		)
	select 
			nID.[NewID], 
			ins.[idfOutbreak], 
			nID.[idfKey2]
	from  inserted as ins
		inner join [dbo].[tflNewID] as nID
		on  nID.[strTableName] = @strTableName collate Cyrillic_General_CI_AS
			and nID.[idfKey1] = ins.[idfOutbreak]
			and nID.[idfKey2] is not null
		left join [dbo].[tflOutbreakFiltered] as cf
		on   cf.[idfOutbreakFiltered] = nID.[NewID]
	where  cf.[idfOutbreakFiltered] is null

	SET NOCOUNT OFF;
END


