CREATE TABLE [dbo].[tauAuditControl] (
    [strUpdateOperation] NVARCHAR (100) NULL,
    [strParameterName]   NVARCHAR (255) NULL,
    [idfTable]           BIGINT         NOT NULL,
    [idfColumn]          BIGINT         NOT NULL,
    [blnKeyColumn]       BIT            NOT NULL,
    [StaticValue]        SQL_VARIANT    NULL,
    [intRowStatus]       INT            NOT NULL
);

