CREATE TABLE [dbo].[tlbEIDSSVersionControl] (
    [ApplicationVersion]  NVARCHAR (50) NOT NULL,
    [DatabaseVersion]     NVARCHAR (50) NOT NULL,
    [Ver_Start_Timestamp] DATETIME      NOT NULL,
    [Ver_End_Timestamp]   DATETIME      NOT NULL,
    [intRowStatus]        INT           CONSTRAINT [DF_tlbEIDSSVersionControl_intRowStatus] DEFAULT ((0)) NOT NULL
);

