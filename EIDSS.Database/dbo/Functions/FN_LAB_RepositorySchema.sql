

/*
select * from dbo.FN_LAB_RepositorySchema('en-US',null,null)
*/

CREATE FUNCTION [dbo].[FN_LAB_RepositorySchema]
(
	@LangID AS NVARCHAR(50),
	@idfFreezer AS BIGINT, 
	@idfSubdivision AS BIGINT
)
RETURNS @Tree TABLE
(
	ID					BIGINT NOT NULL,
	idfFreezer			BIGINT,
	strFreezerName		NVARCHAR(200) COLLATE DATABASE_DEFAULT,
	idfsStorageType		BIGINT,
	idfsSubdivisionType	BIGINT,
	FreezerBarcode		NVARCHAR(200) COLLATE DATABASE_DEFAULT,
	idfSubdivision		BIGINT,
	idfParentSubdivision BIGINT,
	SubdivisionBarcode	NVARCHAR(200) COLLATE DATABASE_DEFAULT,
	SubdivisionName		NVARCHAR(200) COLLATE DATABASE_DEFAULT,
	FreezerNote			NVARCHAR(200) COLLATE DATABASE_DEFAULT,
	SubdivisionNote		NVARCHAR(200) COLLATE DATABASE_DEFAULT,
	[Path]				NVARCHAR(200) COLLATE DATABASE_DEFAULT,
	[Level]				INT,
	intCapacity			INT
)
AS
BEGIN
	--declare @Path 		varchar(200)
	DECLARE @Level INT
	DECLARE @Inserted INT
	--declare @LevelID 	varchar(36)

	INSERT INTO @Tree
	(
		ID,
		idfFreezer,
		strFreezerName,
		idfsStorageType,
		FreezerBarcode,
		FreezerNote,
		[Path],
		[Level]
	)
	(
	SELECT 
		DISTINCT F.idfFreezer,
		F.idfFreezer,
		F.strFreezerName,
		F.idfsStorageType,
		F.strBarcode,
		F.strNote,
		F.strFreezerName,-- + N'.' + tlbFreezerSubdivision.strNameChars,
		0
	FROM dbo.tlbFreezer F
	LEFT JOIN dbo.tlbFreezerSubdivision FS ON FS.idfFreezer = FS.idfFreezer AND FS.intRowStatus=0
	WHERE
	(
		((@idfSubdivision is null) and (FS.idfParentSubdivision is null))
		or
		((@idfSubdivision is not null) and (FS.idfSubdivision = @idfSubdivision))
	)
	AND 
		((@idfFreezer is null) or (F.idfFreezer = @idfFreezer))
		and F.intRowStatus = 0
		and F.idfsSite = dbo.FN_GBL_SITEID_GET()
	)
	SET @Inserted = @@ROWCOUNT
	SET @Level = 0

	WHILE(@Inserted > 0)
	BEGIN
		SET @Inserted = 0
		INSERT INTO @Tree
		(
			ID,
			idfFreezer,
			strFreezerName,
			FreezerNote,
			idfsStorageType,
			idfsSubdivisionType,
			FreezerBarcode,
			idfSubdivision,
			idfParentSubdivision,
			SubdivisionBarcode,
			SubdivisionName,
			SubdivisionNote,
			[Path],
			[Level],
			intCapacity
		)
		(
		SELECT
			FS.idfSubdivision,
			F.idfFreezer,
			F.strFreezerName,
			F.strNote,
			F.idfsStorageType,
			FS.idfsSubdivisionType,
			F.strBarcode,
			FS.idfSubdivision,
			ISNULL(FS.idfParentSubdivision,F.idfFreezer),
			FS.strBarcode,
			FS.strNameChars,
			FS.strNote,
			Tree.[Path] + N'.' + FS.strNameChars,
			@Level + 1,
			FS.intCapacity
		FROM @Tree AS Tree
		INNER JOIN dbo.tlbFreezer F ON F.idfFreezer = Tree.idfFreezer
		INNER JOIN dbo.tlbFreezerSubdivision FS ON FS.idfParentSubdivision = Tree.idfSubdivision OR
					(FS.idfParentSubdivision IS NULL AND FS.idfFreezer=Tree.idfFreezer AND 0 = @Level)
		WHERE Tree.[Level] = @Level
		AND F.intRowStatus = 0
		AND FS.intRowStatus = 0
		)
		SET @Inserted = @@ROWCOUNT
		SET @Level = @Level + 1

	END
RETURN
END


