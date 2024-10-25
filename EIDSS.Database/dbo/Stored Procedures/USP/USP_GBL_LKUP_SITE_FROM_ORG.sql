

--*************************************************************
-- Name 				: USP_GBL_LKUP_SITE_FROM_ORG
-- Description			: Returns site details based on the org id passed in
--          
-- Author               : Mandar Kulkarni
-- Revision History
-- Name				Date		Change Detail
-- Steven Verner	1/19/2022	Added strSiteID to result set
--
--
-- Testing code:
/*
--Example of a call of procedure:

EXEC USP_GBL_LKUP_SITE_FROM_ORG 28140000098

*/
--*************************************************************

CREATE PROCEDURE [dbo].[USP_GBL_LKUP_SITE_FROM_ORG]
(
 @idfOffice BIGINT
)
AS
BEGIN
	DECLARE @returnMsg VARCHAR(MAX) = 'Success'
	DECLARE @returnCode BIGINT = 0

	BEGIN TRY  	
		SELECT	st.idfsSite,
				st.strSiteName,
				st.strSiteID

		FROM dbo.tstSite st
		INNER JOIN dbo.tlbOffice tbo ON st.idfOffice = tbo.idfOffice
		AND tbo.idfOffice= @idfOffice
		WHERE st.intRowStatus = 0
		and tbo.intRowStatus=0

		
			
		--SELECT @returnCode, @returnMsg

	END TRY
	BEGIN CATCH
			SET @returnCode = ERROR_NUMBER()
			SET @returnMsg = 
			'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER() ) 
			+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY() )
			+ ' ErrorState: ' + CONVERT(VARCHAR,ERROR_STATE())
			+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE() ,'')
			+ ' ErrorLine: ' +  CONVERT(VARCHAR,ISNULL(ERROR_LINE() ,''))
			+ ' ErrorMessage: '+ ERROR_MESSAGE()

		  --SELECT @returnCode, @returnMsg
	END CATCH
END
