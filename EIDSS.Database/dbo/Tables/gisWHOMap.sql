CREATE TABLE [dbo].[gisWHOMap](
	[idfsLocation] [BIGINT] NOT NULL,
	[AreaID] [NVARCHAR](100) NULL,
	[WHOAreaID] [NVARCHAR](100) NULL,
	[intRowStatus] [INT] NOT NULL,
	[rowguid] [UNIQUEIDENTIFIER] ROWGUIDCOL  NOT NULL,
	[strMaintenanceFlag] [NVARCHAR](20) NULL,
	[strReservedAttribute] [NVARCHAR](MAX) NULL,
	[SourceSystemNameID] [BIGINT] NULL,
	[SourceSystemKeyValue] [NVARCHAR](MAX) NULL,
	[AuditCreateUser] [NVARCHAR](200) NULL,
	[AuditCreateDTM] [DATETIME] NULL,
	[AuditUpdateUser] [NVARCHAR](200) NULL,
	[AuditUpdateDTM] [DATETIME] NULL,
 CONSTRAINT [XPKgisWHOMap] PRIMARY KEY CLUSTERED 
(
	[idfsLocation] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[gisWHOMap] ADD  CONSTRAINT [DF_IntRowStatus_gisWHOMap]  DEFAULT ((0)) FOR [intRowStatus]
GO

ALTER TABLE [dbo].[gisWHOMap] ADD  CONSTRAINT [newid_gisWHOMap]  DEFAULT (NEWID()) FOR [rowguid]
GO

ALTER TABLE [dbo].[gisWHOMap] ADD  CONSTRAINT [DF_gisWHOMap_CreateDTM]  DEFAULT (GETDATE()) FOR [AuditCreateDTM]
GO

ALTER TABLE [dbo].[gisWHOMap]  WITH CHECK ADD  CONSTRAINT [FK_gisWHOMap_trtBaseReference_SourceSystemNameID] FOREIGN KEY([SourceSystemNameID])
REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
GO

ALTER TABLE [dbo].[gisWHOMap] CHECK CONSTRAINT [FK_gisWHOMap_trtBaseReference_SourceSystemNameID]
GO

ALTER TABLE [dbo].[gisWHOMap]  WITH NOCHECK ADD  CONSTRAINT [FK_idfsLocation_gisLocation] FOREIGN KEY([idfsLocation])
REFERENCES [dbo].[gisLocation] ([idfsLocation])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[gisWHOMap] CHECK CONSTRAINT [FK_idfsLocation_gisLocation]
GO
