/*******************************************************
NAME						: [USP_ADMIN_BASEREF_GET_KeyValueByReferenceId]		


Description					: Returns List Of Base Reference Types

Author						: Lamont Mitchell

Revision History
		
			Name							Date								Change Detail
			Lamont Mitchell					04/01/2020				Gets Base Reference Details By Base Reference Id
*******************************************************/
CREATE PROCEDURE [dbo].[USP_ADMIN_BASEREF_GET_KeyValueByReferenceId]
	@referenceId						BIGINT,
	@LangID									NVARCHAR(50)
AS
BEGIN
	
	DECLARE @returnMsg						VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode						BIGINT = 0;
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		
		SELECT 
			[idfsBaseReference], 
			[idfsReferenceType], 
			[strBaseReferenceCode], 
			[strDefault], 
			[intHACode], 
			[intOrder], 
			[blnSystem], 
			[intRowStatus], 
			[rowguid], 
			[strMaintenanceFlag], 
			[strReservedAttribute]
		FROM  dbo.trtBaseReference
		WHERE [idfsBaseReference] = @referenceId

END
