

-- ================================================================================================
-- Name: USP_ADMIN_FF_SectionForAggregateCase_GET
--
-- Description:	Select actual special section for Aggregate case
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Kishore Kodru    11/28/2018 Initial release for new API.
-- Stephen Long     08/22/2019 Commented call to actual template get.  Currently set to never 
--                             return any data.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_SectionForAggregateCase_GET] 
(	
	@idfsFormTemplate BIGINT = NULL
	,@idfsFormType BIGINT = NULL	
	,@idfsSection Bigint Output
	,@idfsMatrixType Bigint Output
)
AS
BEGIN	
	SET NOCOUNT ON;
	

	BEGIN TRY
	
	declare @idfsCountry bigint
	declare @idfsActualFormTemplate bigint 
	declare @idfFormType_ Bigint
	
	Select @idfsSection = Null, @idfsMatrixType = null;
	
	select @idfsCountry = dbo.fnCurrentCountry()
	
	--if @idfsFormTemplate is null
	--	exec spFFGetActualTemplate @idfsCountry, null, @idfsFormType, @idfsFormTemplate output, 0
	
	If (@idfsFormTemplate Is Not null) Begin
	    Select @idfFormType_ = idfsFormType From dbo.ffFormTemplate Where idfsFormTemplate = @idfsFormTemplate
	    Select Top 1 @idfsSection = S.idfsSection, @idfsMatrixType = S.idfsMatrixType from dbo.ffSection S
		Inner Join dbo.trtMatrixType MT On S.idfsMatrixType = MT.idfsMatrixType And MT.idfsFormType = @idfFormType_ And MT.intRowStatus = 0
		Inner Join dbo.ffSectionForTemplate ST On S.idfsSection = ST.idfsSection And ST.idfsFormTemplate = @idfsFormTemplate And ST.intRowStatus = 0
		Where S.idfsParentSection is Null
	end
	END TRY
	BEGIN CATCH

		THROW;
	END CATCH
END


