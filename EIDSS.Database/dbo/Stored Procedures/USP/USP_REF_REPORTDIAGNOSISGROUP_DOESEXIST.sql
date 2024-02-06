-- ============================================================================
-- Name: USP_REF_REPORTDIAGNOSISGROUP_DOESEXIST
-- Description:	Check to see if a diagnosis currently exists by name
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss     10/30/2018 Initial release.

-- exec USP_REF_REPORTDIAGNOSISGROUP_DOESEXIST 'Rabies Group'
-- exec USP_REF_REPORTDIAGNOSISGROUP_DOESEXIST 'Untested'
-- ============================================================================
CREATE PROCEDURE [dbo].[USP_REF_REPORTDIAGNOSISGROUP_DOESEXIST]
(
	@strName nvarchar(50)
)as

	DECLARE @returnMsg			VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode			BIGINT = 0;
BEGIN
	BEGIN TRY
	Declare @exists bit
	Declare @idfsReferenceType bigint = (Select idfsReferenceType from trtReferenceType where strReferenceTypeName = 'Report Diagnosis Group')
		IF EXISTS(SELECT idfsBaseReference from trtBaseReference where strDefault = @strName AND idfsReferenceType = @idfsReferenceType)
			BEGIN
				Select @exists = 1

				Select @exists as DoesExist
			END
			ELSE
			BEGIN
				Select @exists = 0

				Select @exists as DoesExist

			END
	END TRY
	BEGIN CATCH		
	THROW
	END CATCH
END
