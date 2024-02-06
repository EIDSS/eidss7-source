CREATE TABLE [dbo].[gisImportedMap](
	[idfImportedMap] [bigint] NOT NULL,
	[strMapName] [nvarchar](200) NULL,
	[strMapFullFileName] [nvarchar](2048) NULL,
	[idfsSite] [bigint] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[intRowStatus] [int] NOT NULL,
	[strMaintenanceFlag] [nvarchar](20) NULL,
	[strReservedAttribute] [nvarchar](max) NULL,
	[SourceSystemNameID] [bigint] NULL,
	[SourceSystemKeyValue] [nvarchar](max) NULL,
	[AuditCreateUser] [nvarchar](200) NULL,
	[AuditCreateDTM] [datetime] NULL,
	[AuditUpdateUser] [nvarchar](200) NULL,
	[AuditUpdateDTM] [datetime] NULL,
	[geoJson] [nvarchar](max) NULL,
 CONSTRAINT [XPKgisImportedMap] PRIMARY KEY CLUSTERED 
(
	[idfImportedMap] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[gisImportedMap] ADD  CONSTRAINT [newid__gisImportedMap]  DEFAULT (newid()) FOR [rowguid]
GO

ALTER TABLE [dbo].[gisImportedMap] ADD  CONSTRAINT [DF__gisImportedMap__intRo__2819E74A]  DEFAULT ((0)) FOR [intRowStatus]
GO

ALTER TABLE [dbo].[gisImportedMap] ADD  CONSTRAINT [DF_gisImportedMap_CreateDTM]  DEFAULT (getdate()) FOR [AuditCreateDTM]
GO

ALTER TABLE [dbo].[gisImportedMap]  WITH CHECK ADD  CONSTRAINT [FK_gisImportedMap_trtBaseReference_SourceSystemNameID] FOREIGN KEY([SourceSystemNameID])
REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
GO

ALTER TABLE [dbo].[gisImportedMap] CHECK CONSTRAINT [FK_gisImportedMap_trtBaseReference_SourceSystemNameID]
GO

ALTER TABLE [dbo].[gisImportedMap]  WITH NOCHECK ADD  CONSTRAINT [FK_gisImportedMap_tstSite__idfsSite] FOREIGN KEY([idfsSite])
REFERENCES [dbo].[tstSite] ([idfsSite])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[gisImportedMap] CHECK CONSTRAINT [FK_gisImportedMap_tstSite__idfsSite]
GO


