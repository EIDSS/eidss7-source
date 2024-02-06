CREATE TABLE [dbo].[gisLocationDenormalized] (
    [Level1ID]     BIGINT              NOT NULL,
    [Level2ID]     BIGINT              NULL,
    [Level3ID]     BIGINT              NULL,
    [Level4ID]     BIGINT              NULL,
    [Level5ID]     BIGINT              NULL,
    [Level6ID]     BIGINT              NULL,
    [Level7ID]     BIGINT              NULL,
    [Level1Name]   NVARCHAR (200)      NULL,
    [Level2Name]   NVARCHAR (200)      NULL,
    [Level3Name]   NVARCHAR (200)      NULL,
    [Level4Name]   NVARCHAR (200)      NULL,
    [Level5Name]   NVARCHAR (200)      NULL,
    [Level6Name]   NVARCHAR (200)      NULL,
    [Level7Name]   NVARCHAR (200)      NULL,
    [Node]         [sys].[hierarchyid] NOT NULL,
    [Level]        INT                 NOT NULL,
    [idfsLocation] BIGINT              NOT NULL,
    [LevelType]    NVARCHAR (100)      NOT NULL,
    [idfsLanguage] BIGINT              NOT NULL,
    CONSTRAINT [PK_gisLocationDenormalized] PRIMARY KEY CLUSTERED ([idfsLocation] ASC, [idfsLanguage] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_gisLocationDenormalized_idfsLanguage]
    ON [dbo].[gisLocationDenormalized]([idfsLanguage] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_gisLocationDenormalized_idfsLocation]
    ON [dbo].[gisLocationDenormalized]([idfsLocation] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_gisLocationDenormalized_Node]
    ON [dbo].[gisLocationDenormalized]([Node] ASC);

