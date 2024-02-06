CREATE TABLE [dbo].[AccessRule] (
    [AccessRuleID]                                BIGINT           NOT NULL,
    [GrantingActorSiteGroupID]                    BIGINT           NULL,
    [GrantingActorSiteID]                         BIGINT           NULL,
    [intRowStatus]                                INT              CONSTRAINT [DF_AccessRule_intRowStatus] DEFAULT ((0)) NOT NULL,
    [AuditCreateUser]                             VARCHAR (100)    CONSTRAINT [DF_AccessRule__Audit__21C31603] DEFAULT (user_name()) NOT NULL,
    [AuditCreateDTM]                              DATETIME         NOT NULL,
    [AuditUpdateUser]                             VARCHAR (100)    CONSTRAINT [DF_AccessRule__Audit__23AB5E75] DEFAULT (user_name()) NOT NULL,
    [AuditUpdateDTM]                              DATETIME         CONSTRAINT [DF_AccessRule__Audit__249F82AE] DEFAULT (getdate()) NOT NULL,
    [rowguid]                                     UNIQUEIDENTIFIER CONSTRAINT [DF_AccessRule_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]                          BIGINT           NULL,
    [SourceSystemKeyValue]                        NVARCHAR (MAX)   NULL,
    [ReadPermissionIndicator]                     BIT              CONSTRAINT [DF__tmp_ms_xx__ReadP__018B8EF2] DEFAULT ((0)) NOT NULL,
    [AccessToPersonalDataPermissionIndicator]     BIT              CONSTRAINT [DF__tmp_ms_xx__Acces__027FB32B] DEFAULT ((0)) NOT NULL,
    [AccessToGenderAndAgeDataPermissionIndicator] BIT              CONSTRAINT [DF__tmp_ms_xx__Acces__0373D764] DEFAULT ((0)) NOT NULL,
    [WritePermissionIndicator]                    BIT              CONSTRAINT [DF__tmp_ms_xx__Write__0467FB9D] DEFAULT ((0)) NOT NULL,
    [DeletePermissionIndicator]                   BIT              CONSTRAINT [DF__tmp_ms_xx__Delet__055C1FD6] DEFAULT ((0)) NOT NULL,
    [BorderingAreaRuleIndicator]                  BIT              CONSTRAINT [DF__tmp_ms_xx__Borde__7FA34680] DEFAULT ((0)) NOT NULL,
    [ReciprocalRuleIndicator]                     BIT              CONSTRAINT [DF__tmp_ms_xx__Recip__00976AB9] DEFAULT ((0)) NOT NULL,
    [DefaultRuleIndicator]                        BIT              CONSTRAINT [DF__tmp_ms_xx__Defau__758FCC61] DEFAULT ((0)) NOT NULL,
    [AdministrativeLevelTypeID]                   BIGINT           NULL,
    [CreatePermissionIndicator]                   BIT              CONSTRAINT [DF_AccessRule_CreatePermissionIndicator] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [XPK_AccessRule] PRIMARY KEY CLUSTERED ([AccessRuleID] ASC),
    CONSTRAINT [FK_AccessRule_tflSiteGroup_GrantingActorSiteGroupID] FOREIGN KEY ([GrantingActorSiteGroupID]) REFERENCES [dbo].[tflSiteGroup] ([idfSiteGroup]),
    CONSTRAINT [FK_AccessRule_trtBaseReference] FOREIGN KEY ([AccessRuleID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_AccessRule_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_AccessRule_tstSite_GrantingActorSiteID] FOREIGN KEY ([GrantingActorSiteID]) REFERENCES [dbo].[tstSite] ([idfsSite])
);




GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20211029-132912]
    ON [dbo].[AccessRule]([GrantingActorSiteID] ASC);


GO
CREATE TRIGGER [dbo].[TR_AccessRule_I_Delete] ON [dbo].[AccessRule]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN
	
	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRecords([AccessRuleID]) AS
		(
			SELECT [AccessRuleID] FROM deleted
			EXCEPT
			SELECT [AccessRuleID] FROM inserted
		)

		UPDATE a
		SET  intRowStatus = 1
		FROM dbo.AccessRule AS a 
		INNER JOIN cteOnlyDeletedRecords AS b 
			ON a.AccessRuleID = b.AccessRuleID
	END

END
GO
CREATE  TRIGGER [dbo].[TR_AccessRule_A_Update] ON [dbo].[AccessRule]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN

IF (dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(AccessRuleID) )
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END		

END