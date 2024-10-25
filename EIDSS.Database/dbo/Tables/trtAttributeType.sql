CREATE TABLE [dbo].[trtAttributeType] (
    [idfAttributeType]     BIGINT           NOT NULL,
    [strAttributeTypeName] NVARCHAR (200)   NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [trtAttributeType__newid] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [strMaintenanceFlag]   NVARCHAR (20)    NULL,
    [strReservedAttribute] NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_trtAttributeType_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    [intRowStatus]         BIGINT           CONSTRAINT [Def_trtAttibuteType_intRowStatus] DEFAULT ((0)) NULL,
    CONSTRAINT [XPKtrtAttributeType] PRIMARY KEY CLUSTERED ([idfAttributeType] ASC),
    CONSTRAINT [FK_trtAttributeType_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO

CREATE TRIGGER [dbo].[TR_trtAttributeType_A_Update] ON [dbo].[trtAttributeType]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfAttributeType))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END
