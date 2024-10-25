CREATE TABLE [dbo].[tlbVectorSurveillanceSession] (
    [idfVectorSurveillanceSession]  BIGINT           NOT NULL,
    [strSessionID]                  NVARCHAR (50)    NOT NULL,
    [strFieldSessionID]             NVARCHAR (50)    NULL,
    [idfsVectorSurveillanceStatus]  BIGINT           NOT NULL,
    [datStartDate]                  DATETIME         NOT NULL,
    [datCloseDate]                  DATETIME         NULL,
    [idfLocation]                   BIGINT           NULL,
    [idfOutbreak]                   BIGINT           NULL,
    [strDescription]                NVARCHAR (500)   NULL,
    [idfsSite]                      BIGINT           CONSTRAINT [DF_tlbVectorSurveillanceSession_idfsSite] DEFAULT ([dbo].[fnSiteID]()) NOT NULL,
    [intRowStatus]                  INT              CONSTRAINT [DF_tlbVectorSurveillanceSession_intRowStatus] DEFAULT ((0)) NOT NULL,
    [rowguid]                       UNIQUEIDENTIFIER CONSTRAINT [DF_tlbVectorSurveillanceSession_rowguid] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [datModificationForArchiveDate] DATETIME         CONSTRAINT [tlbVectorSurveillanceSession_datModificationForArchiveDate] DEFAULT (getdate()) NULL,
    [intCollectionEffort]           INT              NULL,
    [strMaintenanceFlag]            NVARCHAR (20)    NULL,
    [strReservedAttribute]          NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]            BIGINT           CONSTRAINT [DEF_tlbVectorSurveillanceSession_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue]          NVARCHAR (MAX)   NULL,
    [AuditCreateUser]               NVARCHAR (200)   NULL,
    [AuditCreateDTM]                DATETIME         CONSTRAINT [DF_tlbVectorSurveillanceSession_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]               NVARCHAR (200)   NULL,
    [AuditUpdateDTM]                DATETIME         NULL,
    CONSTRAINT [PK_tlbVectorSurveillanceSession] PRIMARY KEY CLUSTERED ([idfVectorSurveillanceSession] ASC),
    CONSTRAINT [FK_tlbVectorSurveillanceSession_tlbGeoLocation_idfLocation] FOREIGN KEY ([idfLocation]) REFERENCES [dbo].[tlbGeoLocation] ([idfGeoLocation]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbVectorSurveillanceSession_tlbOutbreak_idfOutbreak] FOREIGN KEY ([idfOutbreak]) REFERENCES [dbo].[tlbOutbreak] ([idfOutbreak]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbVectorSurveillanceSession_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_tlbVectorSurveillanceSession_trtBaseReference_VectorSurveillanceStatus] FOREIGN KEY ([idfsVectorSurveillanceStatus]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbVectorSurveillanceSession_tstSite_idfsSite] FOREIGN KEY ([idfsSite]) REFERENCES [dbo].[tstSite] ([idfsSite]) NOT FOR REPLICATION
);


GO


CREATE TRIGGER [dbo].[TR_tlbVectorSurveillanceSession_I_Delete] ON [dbo].[tlbVectorSurveillanceSession]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRecords([idfVectorSurveillanceSession]) as
		(
			SELECT [idfVectorSurveillanceSession] FROM deleted
			EXCEPT
			SELECT [idfVectorSurveillanceSession] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1,
			datModificationForArchiveDate = GETDATE()
		FROM dbo.tlbVectorSurveillanceSession AS a 
		INNER JOIN cteOnlyDeletedRecords AS b 
			ON a.idfVectorSurveillanceSession = b.idfVectorSurveillanceSession;

	END

END

GO

CREATE  TRIGGER [dbo].[TR_tlbVectorSurveillanceSession_ChangeArchiveDate] ON [dbo].[tlbVectorSurveillanceSession]	
FOR INSERT, UPDATE, DELETE
NOT FOR REPLICATION
AS	

IF (dbo.FN_GBL_TriggersWork ()=1)
BEGIN
	
	DECLARE @dateModify DATETIME
	DECLARE @idfOutbreakOld BIGINT
	DECLARE @idfOutbreakNew BIGINT
	
	SELECT
		@idfOutbreakOld = ISNULL(idfOutbreak, 0)
	FROM DELETED
	
	SELECT
		@idfOutbreakNew = ISNULL(idfOutbreak, 0)
	FROM INSERTED
	
	SET @dateModify = GETDATE()
						
	IF @idfOutbreakOld > 0
		UPDATE tlbOutbreak
		SET datModificationForArchiveDate = @dateModify
		WHERE idfOutbreak = @idfOutbreakOld
			
	IF @idfOutbreakNew > 0
		UPDATE tlbOutbreak
		SET datModificationForArchiveDate = @dateModify
		WHERE idfOutbreak = @idfOutbreakNew
		
END

GO

CREATE TRIGGER [dbo].[TR_tlbVectorSurveillanceSession_Insert_DF] 
   ON  [dbo].[tlbVectorSurveillanceSession]
   for INSERT
   NOT FOR REPLICATION
AS 
BEGIN
	SET NOCOUNT ON;

	declare @guid uniqueidentifier = newid()
	declare @strTableName nvarchar(128) = N'tlbVectorSurveillanceSession' + cast(@guid as nvarchar(36)) collate Cyrillic_General_CI_AS

	insert into [dbo].[tflNewID] 
		(
			[strTableName], 
			[idfKey1], 
			[idfKey2]
		)
	select  
			@strTableName, 
			ins.[idfVectorSurveillanceSession], 
			sg.[idfSiteGroup]
	from  inserted as ins
		inner join [dbo].[tflSiteToSiteGroup] as stsg with(nolock)
		on   stsg.[idfsSite] = ins.[idfsSite]
		
		inner join [dbo].[tflSiteGroup] sg with(nolock)
		on	sg.[idfSiteGroup] = stsg.[idfSiteGroup]
			and sg.[idfsRayon] is null
			and sg.[idfsCentralSite] is null
			and sg.[intRowStatus] = 0
			
		left join [dbo].[tflVectorSurveillanceSessionFiltered] as cf
		on  cf.[idfVectorSurveillanceSession] = ins.[idfVectorSurveillanceSession]
			and cf.[idfSiteGroup] = sg.[idfSiteGroup]
	where  cf.[idfVectorSurveillanceSessionFiltered] is null

	insert into [dbo].[tflVectorSurveillanceSessionFiltered]
		(
			[idfVectorSurveillanceSessionFiltered], 
			[idfVectorSurveillanceSession], 
			[idfSiteGroup]
		)
	select 
			nID.[NewID], 
			ins.[idfVectorSurveillanceSession], 
			nID.[idfKey2]
	from  inserted as ins
		inner join [dbo].[tflNewID] as nID
		on  nID.[strTableName] = @strTableName collate Cyrillic_General_CI_AS
			and nID.[idfKey1] = ins.[idfVectorSurveillanceSession]
			and nID.[idfKey2] is not null
		left join [dbo].[tflVectorSurveillanceSessionFiltered] as cf
		on   cf.[idfVectorSurveillanceSessionFiltered] = nID.[NewID]
	where  cf.[idfVectorSurveillanceSessionFiltered] is null

	SET NOCOUNT OFF;
END

GO

CREATE TRIGGER [dbo].[TR_tlbVectorSurveillanceSession_A_Update] ON [dbo].[tlbVectorSurveillanceSession]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1)
	BEGIN
		IF UPDATE(idfVectorSurveillanceSession)
		BEGIN
			RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
			ROLLBACK TRANSACTION
		END

		ELSE
		BEGIN

			UPDATE a
			SET datModificationForArchiveDate = GETDATE()
			FROM dbo.tlbVectorSurveillanceSession AS a 
			INNER JOIN INSERTED AS b ON a.idfVectorSurveillanceSession = b.idfVectorSurveillanceSession

		END
	
	END

END
