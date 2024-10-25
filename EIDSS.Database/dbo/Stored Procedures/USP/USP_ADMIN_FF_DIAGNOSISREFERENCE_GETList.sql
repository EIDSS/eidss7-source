--=================================================================================================
-- Name: USP_REF_DIAGNOSISREFERENCE_GETList
--
-- Description:	Returns list of diagnosis/disease references
--							
-- Author:  Philip Shaffer
--
-- Revision History:
-- Name				 Date		 Change Detail
-- ----------------	 ----------	 -------------------------------------------------------------------
-- Doug Albanese	 07/16/2021	 Initial Release
-- Doug Albanese	 07/07/2022	 Rewrote entire SP for better performance and filtering of correct diagnosises, used for the FFD Determinants
-- Doug Albanese	 09/22/2022	 Rewrite to include other determinant types that aren't disease releated
-- Doug Albanese	 02/08/2023	 Changed how exlucsions are determined for the Determinants list.
-- Doug Albanese	 02/16/2023	 Changing the method on pulling determinanta again. Found another problem that didn't work for all situations
-- Doug Albanese	 03/27/2023	 Added Fiter for "Using Type" (Standard)
--
-- Test Code:
-- exec USP_REF_DIAGNOSISREFERENCE_GETList 'en', NULL, NULL
-- exec USP_REF_DIAGNOSISREFERENCE_GETList 'en', 'Hu', NULL
-- exec USP_REF_DIAGNOSISREFERENCE_GETList 'en', NULL, 32
--=================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_DIAGNOSISREFERENCE_GETList] 
	@LangID				   NVARCHAR(50)
	,@idfsFormTemplate	   BIGINT
	,@idfsFormType		   BIGINT
AS
BEGIN
	DECLARE @AccessoryCode INT = 510
	DECLARE @NonDisease	   BIT = 0

	DECLARE @idfsDiagnosisExclusions TABLE (
		idfsDiagnosis		BIGINT
	)

   DECLARE @Determinants TABLE (
	  idfsDiagnosis BIGINT,
	  strName  NVARCHAR(200)
   )

   BEGIN TRY
	  IF (@idfsFormType = 10034018 or @idfsFormType = 10034019) --Test Details / Test Run
		 BEGIN
			SET @NonDisease = 1

			INSERT INTO @Determinants
			SELECT
			   BR.idfsBaseReference AS idfsDiagnosis,
			   BRT.name AS strName
			FROM 
			   trtBaseReference BR
			INNER JOIN FN_GBL_ReferenceRepair(@LangID, 19000097) BRT
			ON BRT.idfsReference = BR.idfsBaseReference
			WHERE
			   BR.intRowStatus = 0
		 END

	  IF @idfsFormType = 10034025 --Vector type specific data
		 BEGIN
			SET @NonDisease = 1

			INSERT INTO @Determinants
			SELECT
			   VT.idfsVectorType AS idfsDiagnosis,
			   VTT.name AS strName
			FROM 
			   trtVectorType VT
			INNER JOIN FN_GBL_ReferenceRepair(@LangID, 19000140) VTT
			ON VTT.idfsReference = VT.idfsVectorType
			WHERE
			   VT.intRowStatus = 0
		 END

	   DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS',
	   @returnCode BIGINT = 0;
	
	  IF @NonDisease = 0
		 BEGIN
			
			  SELECT
				  @AccessoryCode = intHACode 
			  FROM 
				  trtBaseReference 
			  WHERE 
				  idfsReferenceType = 19000034 AND
				  introwStatus = 0 AND
				  idfsBaseReference = @idfsFormType
		
			  IF (@AccessoryCode IS NULL) SET @AccessoryCode = 510

			  INSERT INTO @idfsDiagnosisExclusions
			  SELECT
				  dv.idfsBaseReference
			  FROM
				  ffDeterminantValue dv
			  WHERE
				  dv.idfsFormTemplate = @idfsFormTemplate AND
				  dv.intRowStatus = 0	
			
			INSERT INTO @Determinants
			  SELECT d.idfsDiagnosis,
				  dbr.[name] AS strName
			  FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS dbr
			  INNER JOIN dbo.trtDiagnosis d
				  ON d.idfsDiagnosis = dbr.idfsReference
			  LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000020) AS ut
				  ON d.idfsUsingType = ut.idfsReference
			  WHERE (
					  dbr.intHACode IS NULL
					  OR dbr.intHACode > 0
					  )
				  AND d.intRowStatus = 0
				  AND dbr.intRowStatus = 0
				  AND (
				  (
					  @AccessoryCode IN (
						  SELECT *
						  FROM dbo.FN_GBL_SplitHACode(dbr.intHaCode, 510)
						  )
					  )
				  OR (@AccessoryCode IS NULL)
				  ) AND
				  idfsDiagnosis NOT IN (
					  SELECT idfsDiagnosis FROM @idfsDiagnosisExclusions
				  ) AND
				  d.idfsUsingType = 10020001
			  ORDER BY dbr.[name];
		 ENd


		 SELECT
			idfsDiagnosis,
			strName
		 FROM
			@Determinants
		 ORDER BY
			strName

	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
