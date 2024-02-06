--*************************************************************
-- Name 				: USP_ADMIN_FF_ParameterTypeEditorMapping_GetList
-- Description			: For generating mapping information between Parameter Types and Editors for the Flex Form Designer
--          
-- Author               : Doug Albanese
-- Revision History:
-- Name			  Date			 Change Detail
-- Doug Albanese  11/02/2022	 Initial Release
-- Doug Albanese  12/15/2022	 New mapping for numeric type
-- Doug Albanese  01/27/2023	 Added a new mapping for Total/Summing fields to use "Numeric" types
-- Doug Albanese  03/14/2023	 Editor Type mapping correction
-- Testing code:
--
--EXEC	USP_ADMIN_FF_ParameterTypeEditorMapping_GetList @LanguageID = 'en-us', @idfsParameterType = 10067008
--
--*************************************************************
CREATE PROCEDURE[dbo].[USP_ADMIN_FF_ParameterTypeEditorMapping_GetList]
(		
	  @LanguageID		   NVARCHAR(50),
	  @idfsParameterType   BIGINT
)
AS
BEGIN
   BEGIN TRY


	  DECLARE @Mapping TABLE (
		 idfsBaseReference BIGINT,
		 idfsEditor NVARCHAR(200),
		 Editor NVARCHAR(MAX)
	  )

	  INSERT INTO @Mapping (idfsBaseReference, idfsEditor)
	  SELECT
		 BR.idfsBaseReference,
		 COALESCE(BR.strBaseReferenceCode, 'editCombo') AS idfsEditor
	  FROM
		 trtBaseReference BR
	  LEFT JOIN ffParameterType PT
	  ON PT.idfsParameterType = BR.idfsBaseReference
	  WHERE
		 BR.idfsReferenceType in (19000071,19000067) AND
		 (PT.idfsReferenceType IS NOT NULL OR BR.strBaseReferenceCode IS NOT NULL) AND
		 BR.idfsBaseReference = @idfsParameterType

	  UPDATE @Mapping
	  SET
		 idfsEditor = '10067001', 
		 Editor = dbo.FN_GBL_GetBaseReferenceTranslation(@LanguageID,10067001)
	  WHERE 
		 idfsEditor in ('parBoolean','editCheck')

	  UPDATE @Mapping
	  SET
		 idfsEditor = '10067002',
		 Editor = dbo.FN_GBL_GetBaseReferenceTranslation(@LanguageID,10067002)
	  WHERE 
		 idfsEditor in ('editCombo','parDiseaseList','parInvType','parProphAction','parSanAction','parSpecies')

	  UPDATE @Mapping
	  SET 
		 idfsEditor = '10067008,10067006',
		 Editor = dbo.FN_GBL_GetBaseReferenceTranslation(@LanguageID,10067008) + ',' +
				  dbo.FN_GBL_GetBaseReferenceTranslation(@LanguageID,10067006)
	  WHERE idfsEditor IN ('editText','parString')

	  UPDATE @Mapping
	  SET	  
		 idfsEditor = '10067003',
		 Editor = dbo.FN_GBL_GetBaseReferenceTranslation(@LanguageID,10067003)
	  WHERE 
		 idfsEditor in ('editDate','parDate')

	  UPDATE @Mapping
	  SET
		 idfsEditor = '10067004',
		 Editor = dbo.FN_GBL_GetBaseReferenceTranslation(@LanguageID,10067004)
	  WHERE idfsEditor in ('editDateTime','parDatetime')

	  UPDATE @Mapping
	  SET
		 idfsEditor = '217190000000',
		 Editor = dbo.FN_GBL_GetBaseReferenceTranslation(@LanguageID,217190000000)
	  WHERE idfsEditor in ('editEmpty')

	  UPDATE @Mapping
	  SET
		 idfsEditor = '217210000000',
		 Editor = dbo.FN_GBL_GetBaseReferenceTranslation(@LanguageID,217210000000)
	  WHERE idfsEditor in ('editRadio','fpt')

	  UPDATE @Mapping
	  SET
		 idfsEditor = '10067006',
		 Editor = dbo.FN_GBL_GetBaseReferenceTranslation(@LanguageID,10067006)
	  WHERE idfsEditor in ('editMemo')

	  UPDATE @Mapping
	  SET
		 idfsEditor = '10067009,10071061',
		 Editor = dbo.FN_GBL_GetBaseReferenceTranslation(@LanguageID,10067009) + ',' +
				  dbo.FN_GBL_GetBaseReferenceTranslation(@LanguageID,10071061)
	  WHERE idfsEditor in ('editUpDown')

	  	  UPDATE @Mapping
	  SET
		 idfsEditor = '10067009,10067010,10067011',
		 Editor = dbo.FN_GBL_GetBaseReferenceTranslation(@LanguageID,10067009) + ',' +
				  dbo.FN_GBL_GetBaseReferenceTranslation(@LanguageID,10067010) + ',' +
				  dbo.FN_GBL_GetBaseReferenceTranslation(@LanguageID,10067011)
	  WHERE idfsEditor in ('parNumeric','parNumericPositive','parNumericInteger')

	  SELECT 
		 idfsBaseReference,
		 idfsEditor,
		 Editor
	  FROM 
		 @Mapping 

	END TRY  

	BEGIN CATCH 
		THROW;
	END CATCH; 
		
END
