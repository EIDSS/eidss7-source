-- ================================================================================================
-- Name: USP_ADMIN_FF_Templates_GET
-- Description: Return list of Templates
--          
-- Revision History:
-- Name            Date			Change
-- --------------- ----------	--------------------------------------------------------------------
-- Kishore Kodru    11/28/2018	Initial release for new API.
-- Stephen Long     10/02/2019	Removed commit transaction.
-- Doug Albanese	09/21/2021	Added Disease Id for filtering by Outbreak/FFD connection
-- Doug Albanese	09/29/2021	Corrected the joins to return query by idfsFormType
-- Mark Wilson		09/30/2021	Updated to use FN_GBL_ReferenceRepair_GET
-- Doug Albanese	10/28/2021	Removed disease query
-- Doug Albanese	01/20/2023	Added the determinate value on return
-- Doug Albnaese	05/08/2023	Added ability to capture Outbreak assigned Templates, with an Outbreak ID
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_Templates_GET]
(
	@LangID								NVARCHAR(50)
	,@idfsFormTemplate					BIGINT = NULL
	,@idfsFormType						BIGINT = NULL
	,@idfOUtbreak					    BIGINT = NULL
)	
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE @Outbreak	   BIT = 0

	BEGIN TRY
	  
	  IF @idfOUtbreak IS NULL or @idfOUtbreak = -1
		 BEGIN
			IF @idfsFormType BETWEEN 10034501 AND 10034503
			   BEGIN
				  SET @Outbreak = 1

				  SELECT
					 DISTINCT
					 FT.idfsFormTemplate,
					 FT.idfsFormType,
					 FT.blnUNI,
					 FT.rowguid,
					 FT.intRowStatus,
					 FT.strNote,
					 RF.strDefault AS DefaultName,
					 O.strOutbreakID AS NationalName,
					 RF.[LongName] AS NationalLongName,
					 NULL AS idfsDiagnosisOrDiagnosisGroup
				  FROM 
					 OutbreakSpeciesParameter OSP
				  INNER JOIN ffFormTemplate FT
					 ON FT.idfsFormTemplate = OSP.CaseQuestionaireTemplateID
				  INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000033) RF 
					 ON FT.idfsFormTemplate = RF.idfsReference
				  INNER JOIN tlbOUtbreak O
					 ON O.idfOutbreak = OSP.idfOutbreak
				  WHERE
					 FT.idfsFormType = @idfsFormType AND 
					 RF.strDefault IS NOT NULL
		 
			   END
  
			IF @idfsFormType BETWEEN 10034504 AND 10034506
			   BEGIN
				  SET @Outbreak = 1

				  SELECT
					 DISTINCT
					 FT.idfsFormTemplate,
					 FT.idfsFormType,
					 FT.blnUNI,
					 FT.rowguid,
					 FT.intRowStatus,
					 FT.strNote,
					 RF.strDefault AS DefaultName,
					 O.strOutbreakID AS NationalName,
					 RF.[LongName] AS NationalLongName,
					 NULL AS idfsDiagnosisOrDiagnosisGroup
				  FROM 
					 OutbreakSpeciesParameter OSP
				  INNER JOIN ffFormTemplate FT
					 ON FT.idfsFormTemplate = OSP.CaseMonitoringTemplateID
				  INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000033) RF 
					 ON FT.idfsFormTemplate = RF.idfsReference
				  INNER JOIN tlbOUtbreak O
					 ON O.idfOutbreak = OSP.idfOutbreak
				  WHERE
					 FT.idfsFormType = @idfsFormType AND 
					 RF.strDefault IS NOT NULL
			   END

			IF @idfsFormType BETWEEN 10034507 AND 10034509
			   BEGIN
				  SET @Outbreak = 1

				  SELECT
					 DISTINCT
					 FT.idfsFormTemplate,
					 FT.idfsFormType,
					 FT.blnUNI,
					 FT.rowguid,
					 FT.intRowStatus,
					 FT.strNote,
					 RF.strDefault AS DefaultName,
					 O.strOutbreakID AS NationalName,
					 RF.[LongName] AS NationalLongName,
					 NULL AS idfsDiagnosisOrDiagnosisGroup
				  FROM 
					 OutbreakSpeciesParameter OSP
				  INNER JOIN ffFormTemplate FT
					 ON FT.idfsFormTemplate = OSP.ContactTracingTemplateID
				  INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000033) RF 
					 ON FT.idfsFormTemplate = RF.idfsReference
				  INNER JOIN tlbOUtbreak O
					 ON O.idfOutbreak = OSP.idfOutbreak
				  WHERE
					 FT.idfsFormType = @idfsFormType AND 
					 RF.strDefault IS NOT NULL
			   END

			   IF @Outbreak = 0
				  BEGIN
					 SELECT
						DISTINCT
						FT.idfsFormTemplate,
						FT.idfsFormType,
						FT.blnUNI,
						FT.rowguid,
						FT.intRowStatus,
						FT.strNote,
						RF.strDefault AS DefaultName,
						RF.[name] AS NationalName,
						RF.[LongName] AS NationalLongName,
						NULL AS idfsDiagnosisOrDiagnosisGroup
		
					FROM [dbo].[ffFormTemplate] FT
					INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000033) RF ON FT.idfsFormTemplate = RF.idfsReference
					WHERE ((FT.idfsFormTemplate = @idfsFormTemplate ) OR (@idfsFormTemplate IS NULL))
					AND ((FT.idfsFormType  = @idfsFormType) OR (@idfsFormType  IS NULL))	  
					AND (FT.intRowStatus = 0)
					ORDER BY NationalName;
				  END
			   
		 END
	  ELSE
		 BEGIN
			  SELECT 
				  DISTINCT
				  FT.idfsFormTemplate,
				  FT.idfsFormType,
				  FT.blnUNI,
				  FT.rowguid,
				  FT.intRowStatus,
				  FT.strNote,
				  RF.strDefault AS DefaultName,
				  RF.[name] AS NationalName,
				  RF.[LongName] AS NationalLongName,
				  DV.idfsBaseReference AS idfsDiagnosisOrDiagnosisGroup
		
			  FROM [dbo].[ffFormTemplate] FT
			  LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000033) RF ON FT.idfsFormTemplate = RF.idfsReference
			  LEFT JOIN dbo.ffDeterminantValue DV ON DV.idfsFormTemplate = FT.idfsFormTemplate
			  WHERE ((FT.idfsFormTemplate = @idfsFormTemplate ) OR (@idfsFormTemplate IS NULL))
			  AND ((FT.idfsFormType  = @idfsFormType) OR (@idfsFormType  IS NULL))	  
			  AND (FT.intRowStatus = 0)
			  ORDER BY NationalName;
		 END

	END TRY 
	BEGIN CATCH
		THROW;
	END CATCH;
END

