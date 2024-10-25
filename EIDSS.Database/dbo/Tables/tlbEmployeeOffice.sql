CREATE TABLE [dbo].[tlbEmployeeOffice] (
    [idfEmployee]       BIGINT NOT NULL,
    [idfOffice]         BIGINT NOT NULL,
    [intRowStatus]      INT    CONSTRAINT [DF_tlbEmployeeOffice_intRowStatus] DEFAULT ((0)) NOT NULL,
    [MasteridfEmployee] BIGINT NOT NULL,
    CONSTRAINT [PK_tlbEmployeeOffice] PRIMARY KEY CLUSTERED ([idfEmployee] ASC, [idfOffice] ASC)
);

