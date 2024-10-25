-- =============================================
-- Author:		Name
-- Create date: 12/17/2021
-- Description:	Sets the logged in user's session context.
-- This information is primarily used by the auditing infrastructure.



-- =============================================
CREATE PROCEDURE [dbo].[USP_ASPNetUserSetSessionContext] 
	-- Add the parameters for the stored procedure here
	@username nvarchar(255) = 0
AS
BEGIN
	DECLARE @blnDiagnosisDenied  bit
	DECLARE @blnSiteDenied  bit
	DECLARE @localSite bigint      
	DECLARE @person BIGINT 
	DECLARE @userSite BIGINT
	DECLARE @userId BIGINT
	DECLARE @returnCode						INT = 0;
	DECLARE	@returnMsg						NVARCHAR(MAX) = 'SUCCESS';


	BEGIN TRY
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;

		DECLARE @SupressSelect table
			( 
				retrunCode int,
				returnMessage varchar(200)
			)
	 
		 SELECT @localSite=strValue      
		 FROM  tstLocalSiteOptions       
		 WHERE strName='SiteID' 

		 SELECT @person = ut.idfPerson, @userSite = s.idfsSite, @UserID = ut.idfUserID
		 FROM aspnetusers u 
		 JOIN tstUserTable ut ON ut.idfUserID = u.idfUserID
		 JOIN tlbPerson p ON p.idfPerson = ut.idfPerson
		 LEFT JOIN tstSite s ON s.idfOffice = p.idfInstitution
		 WHERE u.UserName = @username

		 SET @userSite = COALESCE(@userSite,@localSite)

		 -- Site calculation...
		IF EXISTS( SELECT * FROM tstObjectAccess oa_diag_user_deny
					INNER JOIN trtDiagnosis d on d.idfsDiagnosis = oa_diag_user_deny.idfsObjectID
					WHERE
						oa_diag_user_deny.intPermission = 1						-- deny
						AND oa_diag_user_deny.idfActor = @person
						AND oa_diag_user_deny.idfsObjectOperation = 10059003	-- Read
						AND oa_diag_user_deny.idfsOnSite = dbo.fnPermissionSite()
						AND oa_diag_user_deny.intRowStatus = 0 )
			SET @blnDiagnosisDenied = 1
		ELSE
			SET @blnDiagnosisDenied = 0

		IF EXISTS( SELECT * FROM tstObjectAccess oa_diag_user_deny
						INNER JOIN trtDiagnosis d ON d.idfsDiagnosis = oa_diag_user_deny.idfsObjectID
						WHERE
							oa_diag_user_deny.intPermission = 1						-- deny
							AND oa_diag_user_deny.idfActor = @person
							AND oa_diag_user_deny.idfsObjectOperation = 10059003	-- Read
							AND oa_diag_user_deny.idfsOnSite = dbo.fnPermissionSite()
							AND oa_diag_user_deny.intRowStatus = 0 )
			OR
			EXISTS(
							SELECT		*
							FROM		tstObjectAccess oa_diag_group_deny
							INNER JOIN	tlbEmployeeGroupMember egm_diag_group_deny
							ON			egm_diag_group_deny.idfEmployee = @person
										AND egm_diag_group_deny.intRowStatus = 0
										AND oa_diag_group_deny.idfActor = egm_diag_group_deny.idfEmployeeGroup
							INNER JOIN	tlbEmployee eg_diag_group_deny
							ON			eg_diag_group_deny.idfEmployee = egm_diag_group_deny.idfEmployeeGroup
										AND eg_diag_group_deny.intRowStatus = 0
							INNER JOIN trtDiagnosis d 
								ON d.idfsDiagnosis = oa_diag_group_deny.idfsObjectID
							WHERE		oa_diag_group_deny.intPermission = 1					-- deny
										AND oa_diag_group_deny.idfsObjectOperation = 10059003	-- Read
										AND oa_diag_group_deny.idfsOnSite = dbo.fnPermissionSite()
										AND oa_diag_group_deny.intRowStatus = 0
					)
			SET @blnDiagnosisDenied = 1
		ELSE
			SET @blnDiagnosisDenied = 0

		IF EXISTS(
							SELECT		*
							FROM		tstObjectAccess oa_site_user_deny
							INNER JOIN	tstSite s
							ON			s.idfsSite = oa_site_user_deny.idfsObjectID
										AND s.intRowStatus = 0
							WHERE		oa_site_user_deny.intPermission = 1						-- deny
										AND oa_site_user_deny.idfActor = @person
										AND oa_site_user_deny.idfsObjectOperation = 10059003	-- Read
										AND oa_site_user_deny.idfsOnSite = dbo.fnPermissionSite()
										AND oa_site_user_deny.intRowStatus = 0
								)
				OR EXISTS	(
							SELECT		*
							FROM		tstObjectAccess oa_site_group_deny
							INNER JOIN	tlbEmployeeGroupMember egm_site_group_deny
							ON			egm_site_group_deny.idfEmployee = @person
										AND oa_site_group_deny.idfActor = egm_site_group_deny.idfEmployeeGroup
										AND egm_site_group_deny.intRowStatus = 0
							INNER JOIN	tlbEmployee eg_site_group_deny
							ON			eg_site_group_deny.idfEmployee = egm_site_group_deny.idfEmployeeGroup
										AND eg_site_group_deny.intRowStatus = 0
							INNER JOIN	tstSite s
							ON			s.idfsSite = oa_site_group_deny.idfsObjectID
										AND s.intRowStatus = 0
							WHERE		oa_site_group_deny.intPermission = 1					-- deny
										AND oa_site_group_deny.idfsObjectOperation = 10059003	-- Read
										AND oa_site_group_deny.idfsOnSite = dbo.fnPermissionSite()
										AND oa_site_group_deny.intRowStatus = 0
								)
 			SET @blnSiteDenied = 1
		ELSE
			SET @blnSiteDenied = 0

		--INSERT INTO @SupressSelect
		EXEC USP_GBL_LoginContext_SET @userID, @userSite, @blnDiagnosisDenied, @blnSiteDenied

		--INSERT INTO @SupressSelect
		EXEC USP_GBL_LogSecurityEvent @UserID,10110000,1

		SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage', @UserId 'idfUser'
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH

	   	  
END
