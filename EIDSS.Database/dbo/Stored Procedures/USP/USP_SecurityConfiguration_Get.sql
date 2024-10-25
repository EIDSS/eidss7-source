-- =============================================
-- Author:		Steven Verner
-- Create date: 03.27.2019
-- Description:	Retrieves the current security configuration.

-- Mani     08/13/2021      Added [SesnInactivityTimeOutMins] field
-- =============================================
CREATE PROCEDURE [dbo].[USP_SecurityConfiguration_Get] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--IF NOT EXISTS( SELECT TOP 1 SecurityPolicyConfigurationUID FROM SecurityPolicyConfiguration ) 
	-- SELECT	 [SecurityPolicyConfigurationUID] = 1
	--		,[MinPasswordLength] = 8
	--		,[EnforcePasswordHistoryCount] = 12
	--		,[MinPasswordAgeDays] = 60
	--		,[ForceUppercaseFlag] = 1
	--		,[ForceLowercaseFlag] = 1
	--		,[ForceNumberUsageFlag] = 1
	--		,[ForceSpecialCharactersFlag] = 1
	--		,[AllowUseOfSpaceFlag] = 1
	--		,[PreventSequentialCharacterFlag] = 1
	--		,[PreventUsernameUsageFlag] = 1
	--		,[LockoutThld] = 3
	--		,[LockoutDurationMinutes] = 5
	--		,[MaxSessionLength] = 2
	--		,[SesnIdleTimeoutWarnThldMins] = 15
	--		,[SesnIdleCloseoutThldMins] = 5
	--		,[intRowStatus] = 0
	--		,[rowguid] = NEWID()
	--		,[AuditCreateUser] = 'SYSTEM'
	--		,[AuditCreateDTM] = GETDATE()
	--		,[AuditUpdateUser] = 'SYSTEM'
	--		,[AuditUpdateDTM] = GETDATE()
	--		,[SourceSystemNameID] = NULL
	--		,[SourceSystemKeyValue] = NULL
	--ELSE
		SELECT TOP  1 
			 [SecurityPolicyConfigurationUID]
			,[MinPasswordLength]
			,[EnforcePasswordHistoryCount]
			,[MinPasswordAgeDays]
			,[ForceUppercaseFlag]
			,[ForceLowercaseFlag]
			,[ForceNumberUsageFlag]
			,[ForceSpecialCharactersFlag]
			,[AllowUseOfSpaceFlag]
			,[PreventSequentialCharacterFlag]
			,[PreventUsernameUsageFlag]
			,[LockoutThld]
			,[LockoutDurationMinutes]
			,[MaxSessionLength]
			,[SesnIdleTimeoutWarnThldMins]
			,[SesnIdleCloseoutThldMins]
			,[SesnInactivityTimeOutMins]
			,[intRowStatus]
			,[rowguid]
			,[AuditCreateUser]
			,[AuditCreateDTM]
			,[AuditUpdateUser]
			,[AuditUpdateDTM]
			,[SourceSystemNameID]
			,[SourceSystemKeyValue]
		  FROM [dbo].[SecurityPolicyConfiguration]
		  WHERE intRowStatus = 0 
		  ORDER BY SecurityPolicyConfigurationUID Desc
  
END
