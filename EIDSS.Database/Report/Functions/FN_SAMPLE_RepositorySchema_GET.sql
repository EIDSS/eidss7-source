



-- ================================================================================================
-- Name: report.FN_SAMPLE_RepositorySchema_GET
--
-- Description: Returns Repository info 
--						
-- Author: Mark Wilson
--
-- Revision History:
--		Name       Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Mark Wilson    12/13/2021  Initial version, Converted to E7 standards.
--
-- Testing code:

/*
select * from report.FN_SAMPLE_RepositorySchema_GET('en-US',null,null)
*/

CREATE   FUNCTION [Report].[FN_SAMPLE_RepositorySchema_GET](
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
declare @Level 		int
declare @Inserted 	int

	insert into @Tree
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
	select		
		DISTINCT F.idfFreezer,
		F.idfFreezer,
		F.strFreezerName,
		F.idfsStorageType,
		F.strBarcode,
		F.strNote,
		F.strFreezerName,
		0
	FROM dbo.tlbFreezer F
	LEFT JOIN dbo.tlbFreezerSubdivision FS ON F.idfFreezer = FS.idfFreezer AND FS.intRowStatus = 0
	WHERE (((@idfSubdivision IS NULL) AND (FS.idfParentSubdivision IS NULL)) OR
			((@idfSubdivision IS NOT NULL) AND (FS.idfSubdivision = @idfSubdivision))) AND ((@idfFreezer IS NULL) OR (F.idfFreezer = @idfFreezer))
				AND F.intRowStatus = 0 AND F.idfsSite = dbo.FN_GBL_SITEID_GET())
	set @Inserted = @@ROWCOUNT
	set @Level = 0

	WHILE(@Inserted > 0)
	BEGIN
		set @Inserted = 0
		INSERT INTO @Tree(
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
		INNER JOIN	dbo.tlbFreezer F ON F.idfFreezer = Tree.idfFreezer
		INNER JOIN dbo.tlbFreezerSubdivision FS ON FS.idfParentSubdivision = Tree.idfSubdivision OR (FS.idfParentSubdivision IS NULL AND FS.idfFreezer = Tree.idfFreezer AND 0=@Level)
		WHERE Tree.[Level] = @Level
		AND F.intRowStatus = 0
		AND FS.intRowStatus = 0;
		
		SET @Inserted = @@ROWCOUNT
		SET @Level = @Level + 1

	END
RETURN
END


