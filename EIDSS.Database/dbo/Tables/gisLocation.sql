CREATE TABLE [dbo].[gisLocation] (
    [idfsLocation]         BIGINT              NOT NULL,
    [node]                 [sys].[hierarchyid] NOT NULL,
    [strHASC]              NVARCHAR (6)        NULL,
    [strCode]              NVARCHAR (200)      NULL,
    [idfsType]             BIGINT              NULL,
    [dblLongitude]         FLOAT (53)          NULL,
    [dblLatitude]          FLOAT (53)          NULL,
    [blnIsCustom]          BIT                 NULL,
    [intElevation]         INT                 NULL,
    [rowguid]              UNIQUEIDENTIFIER    CONSTRAINT [newid_gisLocation] DEFAULT (newid()) NULL,
    [intRowStatus]         INT                 CONSTRAINT [gisLocation_intRowStatus] DEFAULT ((0)) NOT NULL,
    [strMaintenanceFlag]   NVARCHAR (20)       NULL,
    [strReservedAttribute] NVARCHAR (MAX)      NULL,
    [SourceSystemNameID]   BIGINT              CONSTRAINT [DF_gisLocation_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue] NVARCHAR (200)      NULL,
    [AuditCreateUser]      NVARCHAR (200)      NULL,
    [AuditCreateDTM]       DATETIME            CONSTRAINT [DF_gisLocation_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)      NULL,
    [AuditUpdateDTM]       DATETIME            NULL,
    CONSTRAINT [PK_gisLocation] PRIMARY KEY CLUSTERED ([idfsLocation] ASC),
    CONSTRAINT [UQ__gisLocat__6F70382B397A7FD4] UNIQUE NONCLUSTERED ([node] ASC)
);

GO

-- =============================================
-- Author:		Steven Verner
-- Create date: 1/4/2021
-- Description:	Rebuilds gisLocationDenormalized when:
	-- 1.  When a new location is inserted.
	-- 2.  When a location is re-parented (moved)
	-- 3.  When the location is deleted (intRowStatus = 1)
-- History:
--	Date		Developer			Comments
--	03/17/2022	Steven Verner		Fixed the issue where the incorrect level type was specified.
--  10/31/2022  Mani Govindarajan   Update the idfsLocation based on location Node and Node.ToString(), Updated the Final Insert-Selct Condition.
--  01/09/2023  Steven Verner		Modified gisStringNameTranslation joins to use left joins.
-- =============================================
CREATE TRIGGER [dbo].[TR_gisLocation_UpdateDenormalizedHierarchy]
   ON  [dbo].[gisLocation] 
   AFTER INSERT,DELETE,UPDATE
AS
BEGIN
	SET NOCOUNT ON;

		DECLARE 
			@current INT, 
			@max INT, 
			@languageId BIGINT, 
			@hi HIERARCHYID ,
			@hiString varchar(255);


		DECLARE @t TABLE(
			L1ID BIGINT, L2ID BIGINT, L3ID BIGINT, L4ID BIGINT, L5ID BIGINT, L6ID BIGINT, L7ID BIGINT,
			L1NAME NVARCHAR(255),L2NAME NVARCHAR(255),L3NAME NVARCHAR(255),L4NAME NVARCHAR(255),L5NAME NVARCHAR(255),L6NAME NVARCHAR(255),L7NAME NVARCHAR(255),
			Node HIERARCHYID, 
			[Level] INT,
			idfsLocation BIGINT,
			LanguageId BIGINT )
		
		DECLARE @Languages TABLE(id INT IDENTITY, idfsLanguage BIGINT)
		INSERT INTO @Languages(idfsLanguage)
		SELECT idfsLanguage
		FROM dbo.gisLocationDenormalized ld
		GROUP BY idfsLanguage 
		
		DECLARE @idfsLocation BIGINT = NULL,
			@newParent HIERARCHYID,
			@oldParent HIERARCHYID,
			@newDeleted BIT,
			@oldDeleted BIT

			-- The following use cases must be captured:
			-- 1.  When a new location is inserted.
			-- 2.  When a location is re-parented (moved)
			-- 3.  When the location is deleted (intRowStatus = 1)
			-- 4.  When the location name changes...  (This use case cannot be captured here; it must be captured on the trtBaseReference table trigger...

	IF EXISTS(SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted) -- This is an update
	BEGIN

		--	====================================================
		--  Test to see if the location moved...
		--	====================================================
		SELECT 
		 @idfsLocation = idfsLocation
		,@newDeleted = CASE WHEN intRowStatus=1 THEN 1 ELSE 0 END
		,@newParent = NODE.GetAncestor(1)
		FROM Inserted 

		SELECT @oldDeleted = intRowStatus,  @oldParent = Node.GetAncestor(1) 
		FROM DELETED

		-- We always remove all references of the location in the gislocationDenormalized table,
		-- then generate a new entry...
		-- This handles both when a record was deleted (intRowStatus=1) and the need to remove the existing recordsprior to generating a new one for reparenting...

		-- When the location has moved or the record is reactivated (intRowStatus = 0)...
		IF(@newParent != @oldParent) 
		BEGIN 
			DELETE FROM gisLocationDenormalized WHERE idfsLocation = @idfsLocation
			GOTO GenerateNewReference
		END ELSE IF( @newDeleted = 1 )
			DELETE FROM gisLocationDenormalized WHERE idfsLocation = @idfsLocation

		ELSE IF(@oldDeleted =1 and @newDeleted = 0 )
			BEGIN
				DELETE FROM gisLocationDenormalized WHERE idfsLocation = @idfsLocation
				GOTO GenerateNewReference
			END

		GOTO Fini
	END

	IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted) -- This is an insert
	BEGIN
		-- New location was inserted...
		SELECT @idfsLocation = idfsLocation FROM inserted;
		GOTO GenerateNewReference
	END

	IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS(SELECT * FROM inserted) -- this is a delete
	BEGIN
		-- Location was deleted...
		SELECT @idfsLocation = idfsLocation FROM deleted;
		DELETE FROM dbo.gisLocationDenormalized WHERE idfsLocation = @idfsLocation
	END

	GOTO Fini
	
	GenerateNewReference:  
	--	====================================================


		SELECT @current = 1, @max= COUNT(*) FROM @Languages
		
		SELECT @hi = Node, @hiString=Node.ToString()  FROM gisLocation l WHERE l.idfsLocation = @idfsLocation


		-- iterate thru all the languages and insert the hierarchy record for each...
		WHILE (@current <= @max)
		BEGIN
			
			--	Select a language...
			SELECT @languageId = idfsLanguage FROM @Languages WHERE id = @current

			-- Perform the insert...
			-- 1st into table variable...
			INSERT INTO @t(
						 L1ID
						,L2ID
						,L3ID
						,L4ID
						,L5ID
						,L6ID
						,L7ID
						,L1NAME
						,L2NAME
						,L3NAME
						,L4NAME
						,L5NAME
						,L6NAME
						,L7NAME
						,Node
						,[Level]
						--,idfsLocation
						,LanguageId)

			-- PIVOT!!!!!
			-- Flatten the hierarchy and insert into gisLocationDenormalized...
			SELECT 
				-- LevelIDs 1 thru 7...
				MAX(CASE WHEN [Level]=1 THEN idfsLocation END ),
				MAX(CASE WHEN [Level]=2 THEN idfsLocation END ),
				MAX(CASE WHEN [Level]=3 THEN idfsLocation END ),
				MAX(CASE WHEN [Level]=4 THEN idfsLocation END ),
				MAX(CASE WHEN [Level]=5 THEN idfsLocation END ),
				MAX(CASE WHEN [Level]=6 THEN idfsLocation END ),
				MAX(CASE WHEN [Level]=7 THEN idfsLocation END ),
				-- LevelNames 1 thru 7...
				MAX(CASE WHEN [Level]=1 THEN LevelName END ),
				MAX(CASE WHEN [Level]=2 THEN LevelName END ),
				MAX(CASE WHEN [Level]=3 THEN LevelName END ),
				MAX(CASE WHEN [Level]=4 THEN LevelName END ),
				MAX(CASE WHEN [Level]=5 THEN LevelName END ),
				MAX(CASE WHEN [Level]=6 THEN LevelName END ),
				MAX(CASE WHEN [Level]=7 THEN LevelName END ),
				-- Node...
				MAX(Node),
				MAX(level),
				--MAX(idfsLocation),
				@languageId
			FROM 
				(
				SELECT 
					l.Node.GetLevel() [Level]
					,COALESCE(snt.strTextString, b.strDefault) [LevelName]
					,b.strDefault [LevelNameDefault]
					,idfsLocation
					,Node
					--,LevelType.strTextString
					 ,rn=ROW_NUMBER() OVER (PARTITION BY 0 ORDER BY node.GetLevel())
				FROM gisLocation l
				JOIN gisBaseReference b ON b.idfsGISBaseReference = l.idfsLocation
				LEFT JOIN dbo.gisStringNameTranslation snt ON snt.idfsGISBaseReference = l.idfsLocation AND 
					snt.idfsLanguage = @languageId
				WHERE @hi.IsDescendantOf(node) = 1
				) a

				-- Reset...
				SET @current = @current+1
				SELECT @languageId = NULL
		END

		-- Update the idfsLocation...
		UPDATE @t 
		SET idfsLocation = 
		CASE
			WHEN level =1 AND  Node =@hiString THEN L1ID
			WHEN level =2 AND  Node =@hiString THEN L2ID
			WHEN level =3 AND  Node =@hiString THEN L3ID
			WHEN level =4 AND  Node =@hiString THEN  L4ID
			WHEN level =5 AND  Node =@hiString THEN   L5ID 
			WHEN level =6 AND  Node =@hiString THEN   L6ID
			WHEN level =7 AND  Node =@hiString THEN   L7ID 
		END
		

		-- Finally, insert into gis table...
		INSERT INTO dbo.gisLocationDenormalized
			(
				Level1ID, 
				Level2ID, 
				Level3ID, 
				Level4ID, 
				Level5ID, 
				Level6ID, 
				Level7ID,
				Level1Name,
				Level2Name, 
				Level3Name, 
				Level4Name, 
				Level5Name, 
				Level6Name, 
				Level7Name,
				Node,
				Level,
				idfsLocation,
				LevelType,
				idfsLanguage
			)
		SELECT  L1ID,L2ID,L3ID,L4ID,L5ID,L6ID,L7ID,
				L1NAME,L2NAME,L3NAME,L4NAME,L5NAME,L6NAME,L7NAME,
				node,[level],l.idfsLocation,COALESCE(lt.strTextString, T.strGISReferenceTypeName),l.LanguageId
		FROM @t l
		JOIN gisBaseReference b ON b.idfsGISBaseReference = l.idfsLocation
		JOIN gisReferenceType t ON t.idfsGISReferenceType = b.idfsGISReferenceType
		LEFT JOIN dbo.trtStringNameTranslation lt ON 
		lt.idfsLanguage = l.LanguageId AND lt.idfsBaseReference = 
		case l.level
			WHEN 1 THEN 10003001 
			WHEN 2 THEN 10003003
			WHEN 3 THEN 10003002 
			WHEN 4 THEN 10003004 
			WHEN 5 THEN 0
			WHEN 6 THEN 0
			WHEN 7 THEN 0
		ELSE 0 END



	Fini:
		-- Bye!
		RETURN

END

GO


CREATE TRIGGER [dbo].[TR_gisLocation_I_Delete] ON [dbo].[gisLocation]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRecords([idfsLocation]) AS
		(
			SELECT [idfsLocation] FROM deleted
			EXCEPT
			SELECT [idfsLocation] FROM inserted
		)
		
		UPDATE a
		SET intRowStatus = 1
		FROM dbo.gisLocation AS a 
		INNER JOIN cteOnlyDeletedRecords AS b 
			ON a.idfsLocation = b.idfsLocation;
		

	END

END
