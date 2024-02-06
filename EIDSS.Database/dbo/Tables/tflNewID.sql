CREATE TABLE [dbo].[tflNewID] (
    [NewID]                BIGINT           IDENTITY (10000000, 10000000) NOT NULL,
    [strTableName]         [sysname]        NULL,
    [idfKey1]              BIGINT           NULL,
    [idfKey2]              BIGINT           NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [DF_tflNewID_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]   BIGINT           CONSTRAINT [DEF_tflNewID_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_tflNewID_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [FK_tflNewID_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);

