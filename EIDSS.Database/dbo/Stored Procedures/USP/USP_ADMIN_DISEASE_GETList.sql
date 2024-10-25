--=================================================================================================
-- Name: USP_ADMIN_DISEASE_GETList
--
-- Description:	Returns list of diseases filtered by object access for use case SAU62.
--							
-- Author:  Stephen Long
--
-- Revision History:
-- Name             Date		Change Detail
-- Stephen Long     05/17/2020	Initial release
-- Doug Albanese	02/03/2021	Alteration on the where clause for the splitcode usage
--
-- Test Code:
-- exec USP_REF_DIAGNOSISREFERENCE_GETList 'en', NULL, NULL
-- exec USP_REF_DIAGNOSISREFERENCE_GETList 'en', 'Hu', NULL
-- exec USP_REF_DIAGNOSISREFERENCE_GETList 'en', NULL, 32
--=================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_DISEASE_GETList] @LanguageID NVARCHAR(50),
	@AccessoryCode BIGINT = NULL,
	@EmployeeID BIGINT,
	@EmployeeGroupList VARCHAR(MAX) = NULL,
	@SiteID BIGINT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
		@ReturnCode BIGINT = 0;
	DECLARE @IDs TABLE (ID BIGINT NOT NULL);

	BEGIN TRY
		INSERT INTO @IDs
		SELECT d.idfsDiagnosis
		FROM dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) AS dbr
		INNER JOIN dbo.trtDiagnosis d
			ON d.idfsDiagnosis = dbr.idfsReference
		OUTER APPLY (
			SELECT TOP 1 d_to_dg.idfsDiagnosisGroup,
				dg.[name] AS strDiagnosesGroupName
			FROM dbo.trtDiagnosisToDiagnosisGroup AS d_to_dg
			INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000156) AS dg
				ON d_to_dg.idfsDiagnosisGroup = dg.idfsReference
			WHERE d_to_dg.intRowStatus = 0
				AND d_to_dg.idfsDiagnosis = d.idfsDiagnosis
			ORDER BY d_to_dg.idfDiagnosisToDiagnosisGroup ASC
			) AS diagnosesGroup
		WHERE (
				dbr.intHACode IS NULL
				OR dbr.intHACode > 0
				)
			AND d.intRowStatus = 0
			AND dbr.intRowStatus = 0;

		-- =======================================================================================
		-- Apply disease filtration rules from use case SAUC62.
		-- =======================================================================================
		-- 
		-- Apply level 0 disease filtration rules for the employee default user group - Denies ONLY
		-- as all records have been pulled above with or without site filtration rules applied.
		--
		DELETE
		FROM @IDs
		WHERE ID IN (
				SELECT oa.idfsObjectID
				FROM dbo.tstObjectAccess oa
				INNER JOIN dbo.trtBaseReference AS br
					ON br.idfsBaseReference = oa.idfActor
				WHERE oa.intRowStatus = 0
					AND oa.intPermission = 1
					AND br.strDefault = 'Default Role'
				);

		--
		-- Apply level 1 disease filtration rules for an employee's associated user group(s).  
		-- Allows and denies will supersede level 0.
		--
		INSERT INTO @IDs
		SELECT idfsObjectID
		FROM dbo.tstObjectAccess
		WHERE intRowStatus = 0
			AND intPermission = 2 -- Allow permission
			AND (
				idfActor IN (
					SELECT CAST([Value] AS BIGINT)
					FROM dbo.FN_GBL_SYS_SplitList(@EmployeeGroupList, NULL, ',')
					)
				);

		DELETE dis
		FROM @IDs dis
		INNER JOIN dbo.tstObjectAccess
			ON idfsObjectID = dis.ID
				AND intRowStatus = 0
		WHERE intPermission = 1 -- Deny permission
			AND (
				idfActor IN (
					SELECT CAST([Value] AS BIGINT)
					FROM dbo.FN_GBL_SYS_SplitList(@EmployeeGroupList, NULL, ',')
					)
				);

		--
		-- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
		-- will supersede level 1.
		--
		INSERT INTO @IDs
		SELECT idfsObjectID
		FROM dbo.tstObjectAccess
		WHERE intRowStatus = 0
			AND intPermission = 2 -- Allow permission
			AND idfActor = @EmployeeID;

		DELETE dis
		FROM @IDs dis
		INNER JOIN dbo.tstObjectAccess
			ON idfsObjectID = dis.ID
				AND intRowStatus = 0
		WHERE intPermission = 1 -- Deny permission
			AND idfActor = @EmployeeID;

		-- ========================================================================================
		-- FINAL QUERY
		-- ========================================================================================
		WITH Data_CTE
		AS (
			SELECT d.idfsDiagnosis,
				dbr.strDefault,
				dbr.[name] AS strName,
				d.strIDC10,
				d.strOIECode,
				d.idfsUsingType,
				dbr.intHACode,
				dbr.intRowStatus,
				blnZoonotic,
				d.blnSyndrome,
				dbr.intOrder
			FROM @IDs AS dis
			INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) AS dbr
				ON dbr.idfsReference = dis.ID
			INNER JOIN dbo.trtDiagnosis d
				ON d.idfsDiagnosis = dbr.idfsReference
			OUTER APPLY (
				SELECT TOP 1 d_to_dg.idfsDiagnosisGroup,
					dg.[name] AS strDiagnosesGroupName
				FROM dbo.trtDiagnosisToDiagnosisGroup AS d_to_dg
				INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000156) AS dg
					ON d_to_dg.idfsDiagnosisGroup = dg.idfsReference
				WHERE d_to_dg.intRowStatus = 0
					AND d_to_dg.idfsDiagnosis = d.idfsDiagnosis
				ORDER BY d_to_dg.idfDiagnosisToDiagnosisGroup ASC
				) AS diagnosesGroup
			WHERE (
					dbr.intHACode IS NULL
					OR dbr.intHACode > 0
					)
				AND d.intRowStatus = 0
				AND dbr.intRowStatus = 0
				AND (
						(
							dbr.intHACode IN (
								SELECT *
								FROM dbo.FN_GBL_SplitHACode(@AccessoryCode, 510)
							)
						)
						OR (@AccessoryCode IS NULL)
					)
				)
		SELECT idfsDiagnosis,
			strDefault,
			strName,
			strIDC10,
			strOIECode,
			idfsUsingType,
			intHACode,
			intRowStatus,
			blnZoonotic,
			blnSyndrome,
			intOrder
		FROM Data_CTE
		ORDER BY strName;

		SELECT @ReturnCode AS ReturnCode,
			@ReturnMessage AS ReturnMessage;
	END TRY

	BEGIN CATCH
		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();

		SELECT @ReturnCode,
			@ReturnMessage;

		THROW;
	END CATCH;
END
