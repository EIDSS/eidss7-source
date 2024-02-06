CREATE TABLE [dbo].[tlbMonitoringSession] (
    [idfMonitoringSession]             BIGINT           NOT NULL,
    [idfsMonitoringSessionStatus]      BIGINT           NULL,
    [idfsCountry]                      BIGINT           NULL,
    [idfsRegion]                       BIGINT           NULL,
    [idfsRayon]                        BIGINT           NULL,
    [idfsSettlement]                   BIGINT           NULL,
    [idfPersonEnteredBy]               BIGINT           NULL,
    [idfCampaign]                      BIGINT           NULL,
    [idfsSite]                         BIGINT           CONSTRAINT [Def_fnSiteID_tlbMonitoringSession] DEFAULT ([dbo].[fnSiteID]()) NOT NULL,
    [datEnteredDate]                   DATETIME         NULL,
    [strMonitoringSessionID]           NVARCHAR (50)    NULL,
    [intRowStatus]                     INT              CONSTRAINT [Def_0_2639] DEFAULT ((0)) NOT NULL,
    [rowguid]                          UNIQUEIDENTIFIER CONSTRAINT [newid__2512] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [datModificationForArchiveDate]    DATETIME         CONSTRAINT [tlbMonitoringSession_datModificationForArchiveDate] DEFAULT (getdate()) NULL,
    [datStartDate]                     DATETIME         NULL,
    [datEndDate]                       DATETIME         NULL,
    [strMaintenanceFlag]               NVARCHAR (20)    NULL,
    [strReservedAttribute]             NVARCHAR (MAX)   NULL,
    [SessionCategoryID]                BIGINT           NULL,
    [LegacySessionID]                  VARCHAR (50)     NULL,
    [SourceSystemNameID]               BIGINT           CONSTRAINT [DEF_tlbMonitoringSession_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue]             NVARCHAR (MAX)   NULL,
    [AuditCreateUser]                  NVARCHAR (200)   NULL,
    [AuditCreateDTM]                   DATETIME         CONSTRAINT [DF_tlbMonitoringSession_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]                  NVARCHAR (200)   NULL,
    [AuditUpdateDTM]                   DATETIME         NULL,
    [idfsLocation]                     BIGINT           NULL,
    [idfsMonitoringSessionSpeciesType] BIGINT           NULL,
    CONSTRAINT [XPKtlbMonitoringSession] PRIMARY KEY CLUSTERED ([idfMonitoringSession] ASC),
    CONSTRAINT [FK_tlbMonitoringSession_gisCountry__idfsCountry_R_1741] FOREIGN KEY ([idfsCountry]) REFERENCES [dbo].[gisCountry] ([idfsCountry]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbMonitoringSession_gisLocation_idfsLocation] FOREIGN KEY ([idfsLocation]) REFERENCES [dbo].[gisLocation] ([idfsLocation]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbMonitoringSession_gisRayon__idfsRayon_R_1743] FOREIGN KEY ([idfsRayon]) REFERENCES [dbo].[gisRayon] ([idfsRayon]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbMonitoringSession_gisRegion__idfsRegion_R_1742] FOREIGN KEY ([idfsRegion]) REFERENCES [dbo].[gisRegion] ([idfsRegion]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbMonitoringSession_gisSettlement__idfsSettlement_R_1744] FOREIGN KEY ([idfsSettlement]) REFERENCES [dbo].[gisSettlement] ([idfsSettlement]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbMonitoringSession_idfsMonitoringSessionSpeciesType] FOREIGN KEY ([idfsMonitoringSessionSpeciesType]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_tlbMonitoringSession_tlbCampaign__idfCampaign_R_1748] FOREIGN KEY ([idfCampaign]) REFERENCES [dbo].[tlbCampaign] ([idfCampaign]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbMonitoringSession_tlbPerson__idfPersonEnteredBy_R_1745] FOREIGN KEY ([idfPersonEnteredBy]) REFERENCES [dbo].[tlbPerson] ([idfPerson]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbMonitoringSession_trtBaseRef_SessionCategoryID] FOREIGN KEY ([SessionCategoryID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_tlbMonitoringSession_trtBaseReference__idfsMonitoringSessionStatus_R_1740] FOREIGN KEY ([idfsMonitoringSessionStatus]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbMonitoringSession_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_tlbMonitoringSession_tstSite__idfsSite_R_1746] FOREIGN KEY ([idfsSite]) REFERENCES [dbo].[tstSite] ([idfsSite]) NOT FOR REPLICATION
);




GO
CREATE NONCLUSTERED INDEX [IX_tlbMonitoringSession_LegacySessionID]
    ON [dbo].[tlbMonitoringSession]([LegacySessionID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tlbMonitoringSession_datEnteredDate]
    ON [dbo].[tlbMonitoringSession]([datEnteredDate] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tlbMonitoringSession_idfsMonitoringSessionStatus]
    ON [dbo].[tlbMonitoringSession]([idfsMonitoringSessionStatus] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tlbMonitoringSession_idfsRayon]
    ON [dbo].[tlbMonitoringSession]([idfsRayon] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tlbMonitoringSession_idfsRegion]
    ON [dbo].[tlbMonitoringSession]([idfsRegion] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tlbMonitoringSession_idfsSettlement]
    ON [dbo].[tlbMonitoringSession]([idfsSettlement] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tlbMonitoringSession_strMonitoringSessionID]
    ON [dbo].[tlbMonitoringSession]([strMonitoringSessionID] ASC);


GO

CREATE TRIGGER [dbo].[TR_tlbMonitoringSession_A_Update] ON [dbo].[tlbMonitoringSession]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1)
	BEGIN
		IF UPDATE(idfMonitoringSession)
		BEGIN
			RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
			ROLLBACK TRANSACTION
		END

		ELSE
		BEGIN

			UPDATE a
			SET datModificationForArchiveDate = getdate()
			FROM dbo.tlbMonitoringSession AS a 
			INNER JOIN inserted AS b ON a.idfMonitoringSession = b.idfMonitoringSession

		END
	
	END

END

GO


CREATE TRIGGER [dbo].[TR_tlbMonitoringSession_I_Delete] on [dbo].[tlbMonitoringSession]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRecords([idfMonitoringSession]) as
		(
			SELECT [idfMonitoringSession] FROM deleted
			EXCEPT
			SELECT [idfMonitoringSession] FROM inserted
		)
		
		UPDATE a
		SET intRowStatus = 1, 
			datModificationForArchiveDate = getdate()
		FROM dbo.tlbMonitoringSession as a 
		INNER JOIN cteOnlyDeletedRecords as b 
			ON a.idfMonitoringSession = b.idfMonitoringSession;

	END

END

GO

-- =============================================
-- Author:		Romasheva Svetlana
-- Create date: May 19 2014  2:45PM
-- Description:	Trigger for correct problems 
--              with replication and checkin in the same time
-- =============================================
CREATE TRIGGER [dbo].[trtMonitoringSessionReplicationUp] 
   ON  [dbo].[tlbMonitoringSession]
   for INSERT
   NOT FOR REPLICATION
AS 
BEGIN
	SET NOCOUNT ON;
	
	--DECLARE @context VARCHAR(50)
	--SET @context = dbo.fnGetContext()

	delete  nID
	from  dbo.tflNewID as nID
		inner join inserted as ins
		on   ins.idfMonitoringSession = nID.idfKey1
	where  nID.strTableName = 'tflMonitoringSessionFiltered'

	insert into dbo.tflNewID 
		(
			strTableName, 
			idfKey1, 
			idfKey2
		)
	select  
			'tflMonitoringSessionFiltered', 
			ins.idfMonitoringSession, 
			sg.idfSiteGroup
	from  inserted as ins
		inner join dbo.tflSiteToSiteGroup as stsg
		on   stsg.idfsSite = ins.idfsSite
		
		inner join dbo.tflSiteGroup sg
		on	sg.idfSiteGroup = stsg.idfSiteGroup
			and sg.idfsRayon is null
			and sg.idfsCentralSite is null
			and sg.intRowStatus = 0
			
		left join dbo.tflMonitoringSessionFiltered as btf
		on  btf.idfMonitoringSession = ins.idfMonitoringSession
			and btf.idfSiteGroup = sg.idfSiteGroup
	where  btf.idfMonitoringSessionFiltered is null

	insert into dbo.tflMonitoringSessionFiltered
		(
			idfMonitoringSessionFiltered, 
			idfMonitoringSession, 
			idfSiteGroup
		)
	select 
			nID.NewID, 
			ins.idfMonitoringSession, 
			nID.idfKey2
	from  inserted as ins
		inner join dbo.tflNewID as nID
		on  nID.strTableName = 'tflMonitoringSessionFiltered'
			and nID.idfKey1 = ins.idfMonitoringSession
			and nID.idfKey2 is not null
		left join dbo.tflMonitoringSessionFiltered as btf
		on   btf.idfMonitoringSessionFiltered = nID.NewID
	where  btf.idfMonitoringSessionFiltered is null

	delete  nID
	from  dbo.tflNewID as nID
		inner join inserted as ins
		on   ins.idfMonitoringSession = nID.idfKey1
	where  nID.strTableName = 'tflMonitoringSessionFiltered'

	SET NOCOUNT OFF;
END


