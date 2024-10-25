
-- ================================================================================================
-- Name: USP_ADMIN_FF_ParameterFixedPresetValue_GETList
-- Description: Returns all Fixed Preset Values based on the idfsParameterType if not parameter is entered it will return all. 
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Kishore Kodru    11/28/2018	Initial release for new API.
-- Doug Albanese	12/31/2020	Added Begin Transaction
-- Mike Kornegay	10/26/2021	Added record and page counts (no paging necessary)
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_ParameterFixedPresetValue_GETList] 
(	
	@idfsParameterType BIGINT = NULL
	,@LangID NVARCHAR(50) = NULL
)	
AS
BEGIN	
	SET NOCOUNT ON;

	IF (@LangID IS NULL) 
		SET @LangID = 'en';	

	DECLARE
		@returnCode BIGINT,
		@returnMsg  NVARCHAR(MAX)       
	
	BEGIN TRY
		BEGIN TRANSACTION;

		SELECT FPV.idfsParameterFixedPresetValue 
			   ,FPV.idfsParameterType
			   ,FR.strDefault AS [DefaultName]
			   ,ISNULL(FR.LongName, FR.strDefault) AS [NationalName]
			   ,@LangID AS [langid]
			   ,FR.intOrder
			   ,COUNT(*) OVER() AS TotalRowCount 
		FROM dbo.ffParameterFixedPresetValue FPV
		INNER JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000069 /*'rftParametersFixedPresetValue'*/) FR 
		ON FPV.idfsParameterFixedPresetValue = FR.idfsReference
		WHERE (FPV.idfsParameterType = @idfsParameterType
			   OR @idfsParameterType IS NULL) 
			  AND FPV.intRowStatus = 0
		ORDER BY [intOrder],[NationalName]

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END
