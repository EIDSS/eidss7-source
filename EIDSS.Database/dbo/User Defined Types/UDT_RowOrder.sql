CREATE TYPE [dbo].[UDT_RowOrder] AS TABLE (
    [KeyId]    BIGINT NOT NULL,
    [RowOrder] INT    NOT NULL,
    PRIMARY KEY CLUSTERED ([KeyId] ASC));

