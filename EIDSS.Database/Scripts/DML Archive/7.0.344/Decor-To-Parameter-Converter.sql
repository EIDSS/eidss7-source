/*
	Author: Doug Albanese

	Decor to Parameter Converter

	Needs to be ran on the master DB, as well as all existing DB
*/

DECLARE @LanguageID					NVARCHAR(50) = 'ka-GE'
DECLARE @idfsFormType				BIGINT
DECLARE @idfsFormTemplate			BIGINT
DECLARE @idfsSection				BIGINT
DECLARE @idfsParameter				BIGINT
DECLARE @idfsParameterCaption		BIGINT
DECLARE @ParameterOrder				INT
DECLARE @ParameterDefault			NVARCHAR(400)
DECLARE @ParameterName				NVARCHAR(600)
DECLARE @idfDecorElement			BIGINT
DECLARE @DecorDefault				NVARCHAR(400)
DECLARE @DecorName					NVARCHAR(600)
DECLARE @Counter					INT = 0
DECLARE @RowID						INT
DECLARE @ParameterOrderBefore		INT
DECLARE @ParameterOrderAfter		INT
DECLARE @idfsParameterType			BIGINT
DECLARE @idfsEditor					BIGINT
DECLARE @bExists					BIT
DECLARE @intOrder					INT = 0

DECLARE @Template TABLE (
   RowID				INT,
   idfsSection			BIGINT,
   SectionOrder			INT,
   SectionDefault		NVARCHAR(400),
   SectionName			NVARCHAR(600),
   idfsParameter		BIGINT,
   ParameterOrder		INT,
   ParameterTop			INT,
   ParameterDefault		NVARCHAR(400),
   ParameterName		NVARCHAR(600),
   idfDecorElement		BIGINT,
   DecorDefault			NVARCHAR(400),
   DecorName			NVARCHAR(600)
)

DECLARE @Template_CleanedUp TABLE (
   RowID				INT,
   idfsSection			BIGINT,
   SectionOrder			INT,
   SectionDefault		NVARCHAR(400),
   SectionName			NVARCHAR(600),
   idfsParameter		BIGINT,
   ParameterOrder		INT,
   ParameterTop			INT,
   ParameterDefault		NVARCHAR(400),
   ParameterName		NVARCHAR(600),
   idfDecorElement		BIGINT,
   DecorDefault			NVARCHAR(400),
   DecorName			NVARCHAR(600)
)

DECLARE @Templates TABLE (
   idfsFormTemplate		BIGINT
)

DECLARE @Sections TABLE (
   idfsSection			BIGINT,
   SectionOrder			INT,
   SectionDefault		NVARCHAR(200),
   SectionName			NVARCHAR(200)
)

DECLARE @Parameters TABLE (
   idfsParameter		BIGINT,
   ParameterOrder		INT,
   ParameterTop			INT,
   ParameterDefault		NVARCHAR(200),
   ParameterName		NVARCHAR(200)
)

DECLARE @ReturnParameterValues TABLE (
   returnCode			INT,
   returnMsg			NVARCHAR(200),
   idfsParameter		BIGINT,
   idfsParameterCaption	BIGINT
)


SET NOCOUNT ON

INSERT INTO @Templates
SELECT
   DISTINCT idfsFormTemplate
FROM
   ffDecorElement
WHERE
   intRowStatus = 0
  --and idfsFormTemplate = 9871520000000
   
SELECT @idfsParameterType = idfsBaseReference FROM trtBaseReference WHERE strBaseReferenceCode = 'parStatement' AND idfsReferenceType = 19000071
SELECT @idfsEditor = idfsBaseReference FROM trtBaseReference WHERE strBaseReferenceCode = 'editStatement' AND idfsReferenceType = 19000067

WHILE EXISTS (SELECT 1 FROM @Templates)
   BEGIN
	  SELECT TOP 1 @idfsFormTemplate = idfsFormTemplate FROM @Templates
	  SELECT TOP 1 @idfsFormType = idfsFormType FROM ffFormTemplate WHERE idfsFormTemplate = @idfsFormTemplate

	  INSERT INTO @Sections 
	  SELECT
		 DISTINCT
		 SFT.idfsSection,
		 SDO.intOrder,
		 SN.strDefault,
		 SN.name
	  FROM
		 ffSectionForTemplate SFT
	  INNER JOIN ffSectionDesignOption SDO
	  ON SDO.idfsSection = SFT.idfsSection AND SDO.intRowStatus = 0
	  INNER JOIN FN_GBL_ReferenceRepair_GET(@LanguageID,19000101) SN
	  ON SN.idfsReference = SFT.idfsSection
	  WHERE
		 SFT.idfsFormTemplate = @idfsFormTemplate AND
		 SDO.idfsFormTemplate = @idfsFormTemplate AND
		 SFT.intRowStatus = 0

	  DECLARE Section_Cursor CURSOR STATIC LOCAL FOR
		 SELECT idfsSection from @Sections order by SectionOrder

	  OPEN Section_Cursor
	  FETCH NEXT FROM Section_Cursor INTO @idfsSection

	  
	  WHILE @@FETCH_STATUS = 0
		 BEGIN
			INSERT INTO @Template (   
			   idfsSection,
			   SectionOrder,
			   SectionDefault,
			   SectionName,
			   idfsParameter,
			   ParameterOrder,
			   ParameterTop,
			   ParameterDefault,
			   ParameterName
			)
			SELECT
			   DISTINCT
			   S.idfsSection,
			   S.SectionOrder,
			   S.SectionDefault,
			   S.SectionName,
			   P.idfsParameter,
			   PDO.intOrder,
			   PDO.intTop,
			   PN.strDefault,
			   PN.name
			FROM
			   ffParameterForTemplate PFT
			INNER JOIN ffParameter P
			   ON P.idfsParameter = PFT.idfsParameter AND P.intRowStatus = 0
			INNER JOIN ffParameterDesignOption PDO
			   ON PDO.idfsParameter = PFT.idfsParameter AND PDO.idfsFormTemplate = @idfsFormTemplate AND PDO.intRowStatus = 0 AND PDO.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
			INNER JOIN @Sections S
			   ON S.idfsSection = P.idfsSection
			INNER JOIN FN_GBL_ReferenceRepair_GET(@LanguageID,19000070) PN
			   ON PN.idfsReference = P.idfsParameterCaption
			WHERE
			   P.idfsSection = @idfsSection AND
			   PFT.idfsFormTemplate = @idfsFormTemplate AND
			   PFT.intRowStatus = 0 
			   
			IF EXISTS (select 1 from ffDecorElement where idfsFormTemplate = @idfsFormTemplate and idfsSection = @idfsSection and intRowStatus = 0)
			   BEGIN
				  INSERT INTO @Template (
					 idfsSection,
					 SectionName,
					 SectionOrder,
					 idfDecorElement,
					 ParameterTop,
					 DecorDefault,
					 DecorName
				  )
				  SELECT
					 DISTINCT
					 DE.idfsSection,
					 SN.name,
					 SDO.intOrder,
					 DET.idfsBaseReference,
					 DET.intTop,
					 DN.strDefault,
					 DN.name
				  FROM
					 ffDecorElement DE
				  INNER JOIN ffDecorElementText DET
					 ON DET.idfDecorElement = DE.idfDecorElement AND DET.intRowStatus = 0
				  INNER JOIN FN_GBL_ReferenceRepair_GET(@LanguageID,19000131) DN
					 ON DN.idfsReference = DET.idfsBaseReference
				  INNER JOIN ffSectionDesignOption SDO
					 ON SDO.idfsSection = DE.idfsSection AND SDO.idfsFormTemplate = DE.idfsFormTemplate AND SDO.intRowStatus = 0
				  INNER JOIN FN_GBL_ReferenceRepair_GET(@LanguageID,19000101) SN
					 ON SN.idfsReference = DE.idfsSection
				  WHERE 
					 DE.idfsFormTemplate = @idfsFormTemplate AND 
					 DE.idfsSection = @idfsSection ANd
					 DE.intRowStatus = 0

			   END
			
			FETCH NEXT FROM Section_Cursor INTO @idfsSection
		 END

	  CLOSE Section_Cursor
	  DEALLOCATE Section_Cursor

	  SET @Counter = 0
	  
	  DECLARE Template_Cursor CURSOR STATIC LOCAL FOR
		 SELECT idfsParameter, idfDecorElement FROM @Template ORDER BY SectionOrder, ParameterTop
		 
	  OPEN Template_Cursor
	  FETCH NEXT FROM Template_Cursor INTO @idfsParameter, @idfDecorElement

	  WHILE @@FETCH_STATUS = 0
		 BEGIN
			SET @Counter = @Counter + 1

			IF @idfsParameter IS NOT NULL
			   BEGIN
				  UPDATE @Template
				  SET RowID = @Counter
				  WHERE idfsParameter = @idfsParameter
			   END
			ELSE
			   BEGIN
				  UPDATE @Template
				  SET RowID = @Counter
				  WHERE idfDecorElement = @idfDecorElement
			   END
			FETCH NEXT FROM Template_Cursor INTO @idfsParameter, @idfDecorElement
		 END

	  CLOSE Template_Cursor
	  DEALLOCATE Template_Cursor
	  
	  WHILE EXISTS (SELECT TOP 1 1 from @Template WHERE idfsParameter IS NULL)
		 BEGIN
			SET @intOrder = @intOrder + 1
			--select * from @Template order by SectionOrder, ParameterOrder
			
			SELECT 
			   TOP 1
			   @RowID = RowId,
			   @idfDecorElement = idfDecorElement,
			   @DecorDefault = DecorDefault,
			   @DecorName = DecorName
			FROM
			   @Template
			WHERE
			   idfsParameter IS NULL
			ORDER BY
			   RowID
			
			IF @RowID = 1
			   BEGIN
				  SELECT 
					 @ParameterOrderAfter = COALESCE(ParameterOrder, 0)
				  FROM
					 @Template
				  WHERE
					 RowID = @RowID + 1
				  
				  UPDATE @Template
				  SET ParameterOrder = @ParameterOrderAfter / 2
				  WHERE RowId = @RowId
			   END
			ELSE
			   BEGIN
				  SELECT 
					 @ParameterOrderBefore = COALESCE(ParameterOrder, 0)
				  FROM
					 @Template
				  WHERE
					 RowID = @RowID - 1

			   	  SELECT 
					 @ParameterOrderAfter = COALESCE(ParameterOrder, 0)
				  FROM
					 @Template
				  WHERE
					 RowID = @RowID + 1

				  UPDATE @Template
				  SET ParameterOrder = (@ParameterOrderAfter + @ParameterOrderBefore) / 2
				  WHERE RowId = @RowId
			   END

			SELECT
			   @idfsSection = idfsSection
			FROM
			   @Template
			WHERE
			   RowID = @RowID

			UPDATE @Template
			SET idfsParameter = @idfDecorElement , ParameterDefault = @DecorDefault, ParameterName = @DecorName
			WHERE RowId = @RowID 

			SELECT
			   @ParameterOrder = COALESCE(ParameterOrder,0)
			FROM
			   @Template
			WHERE
			   RowId = @RowId
   			   --select * from @Template order by RowID
			DELETE FROM @ReturnParameterValues
			SET @bExists = 0

			IF EXISTS (select 1 from trtBaseReference where strDefault = @DecorDefault and idfsReferenceType = 19000066 and intRowStatus = 0 and intOrder = @intOrder)
			   BEGIN
				  SELECT
					 @idfsParameter = idfsBaseReference
				  FROM
					 trtBaseReference
				  WHERE
					 strDefault = @DecorDefault and idfsReferenceType = 19000066 and intRowStatus = 0

				  SET @bExists = 1
			   END
			ELSE
			   BEGIN
				  SET @idfsParameter = NULL
			   END

			IF EXISTS (select 1 from trtBaseReference where strDefault = @DecorDefault and idfsReferenceType = 19000070 and intRowStatus = 0  and intOrder = @intOrder)
			   BEGIN
				  SELECT
					 @idfsParameterCaption = idfsBaseReference
				  FROM
					 trtBaseReference
				  WHERE
					 strDefault = @DecorDefault and idfsReferenceType = 19000070 and intRowStatus = 0

				  SET @bExists = 1
			   END
			ELSE
			   BEGIN
				  SET @idfsParameterCaption = NULL
			   END
			
			IF @bExists = 0
			   BEGIN
				  INSERT INTO @ReturnParameterValues
				  EXEC USP_ADMIN_FF_Parameters_SET 
					 @LangId = @LanguageID, 
					 @idfsSection = @idfsSection,
					 @idfsFormType = @idfsFormType,
					 @idfsParameterType = @idfsParameterType,
					 @idfsEditor = @idfsEditor,
					 @intHACode = 0,
					 @intOrder = @ParameterOrder,
					 @strNote = NULL,
					 @DefaultName = @DecorDefault,
					 @NationalName = @DecorName,
					 @DefaultLongName = @DecorDefault,
					 @NationalLongName = @DecorName,
					 @idfsParameter = @idfsParameter,
					 @idfsParameterCaption = @idfsParameterCaption,
					 @User = 'System',
					 @intRowStatus = 0,
					 @CopyOnly = 0
					 
					 SELECT @idfsParameter = idfsParameter, @idfsParameterCaption = idfsParameterCaption
					 FROM @ReturnParameterValues

					 --EXEC USP_ADMIN_FF_ParameterDesignOptions_SET @idfsParameter, @idfsFormTemplate, 0,0,0,0,0,0,@ParameterOrder, @LanguageID, 'System', 0

					 UPDATE trtBaseReference 
					    set intOrder = @intOrder 
					 WHERE 
					    idfsBaseReference IN (@idfsParameter, @idfsParameterCaption)
			   END

			

			IF NOT EXISTS (SELECT 1 FROM ffParameterForTemplate WHERE idfsFormTemplate = @idfsFormTemplate AND idfsParameter = @idfsParameter and intRowStatus = 0)
			   BEGIN
				  INSERT INTO [dbo].[ffParameterForTemplate]
					   (
           				   [idfsParameter]
           				   ,[idfsFormTemplate]			  	   
						   ,[idfsEditMode]		
						   ,[blnFreeze]
						   ,AuditCreateDTM
						   ,AuditCreateUser
					   )
				   VALUES
					   (
           				   @idfsParameter
           				   ,@idfsFormTemplate
						   ,10068001	
						   ,0	
						   ,GETDATE()
						   ,'System'	
					   )        
					
				  EXEC dbo.[USP_ADMIN_FF_ParameterDesignOptions_SET] 
					 @idfsParameter
					 ,@idfsFormTemplate
					 ,0
					 ,0
					 ,0
					 ,0			
					 ,0
					 ,0
					 ,@ParameterOrder
					 ,@LanguageId
					 ,'System'
					 ,0

			   END

		 END
		 --select * from @Template order by SectionOrder, ParameterOrder
	  DELETE FROM @Sections

	  DELETE FROM @Templates WHERE idfsFormTemplate = @idfsFormTemplate
   END