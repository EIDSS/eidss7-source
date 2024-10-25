CREATE TABLE [dbo].[tauApplicationEventLog] (
    [Id]              BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Message]         NVARCHAR (MAX) NULL,
    [MessageTemplate] NVARCHAR (MAX) NULL,
    [Level]           NVARCHAR (128) NULL,
    [TimeStamp]       DATETIME       NOT NULL,
    [Exception]       NVARCHAR (MAX) NULL,
    [Properties]      NVARCHAR (MAX) NULL,
    [UserName]        NVARCHAR (200) NULL,
    [IP]              VARCHAR (200)  NULL,
    CONSTRAINT [PK_tauApplicationEventLog] PRIMARY KEY CLUSTERED ([Id] ASC)
);

