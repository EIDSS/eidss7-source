/****** Object:  StoredProcedure [dbo].[spSecurityPolicy_List]    Script Date: 7/18/2022 4:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:
-- Create date:
-- Description:	Retrieves the current security configuration.

-- Ann    07/18/2022      Commented out old scripts and updated to use the same EIDSS7 database table SecurityPolicyConfiguration 
--							so that EIDSS security policies are applied to AVR.
-- =============================================


/*
exec spSecurityPolicy_List 'en'
*/

ALTER PROCEDURE [dbo].[spSecurityPolicy_List]
	@LangID nvarchar(50)
AS
BEGIN
/*	select	*
	from	tstGlobalSiteOptions*/
/*
	Select Policies.*,Ref.name as Description
	from
	(
		select	'AccountLockTimeout' as strName,dbo.fnPolicyValue('AccountLockTimeout') as strValue
		union
		select	'AccountTryCount' as strName,dbo.fnPolicyValue('AccountTryCount') as strValue
		union
		select	'PasswordAge' as strName,dbo.fnPolicyValue('PasswordAge') as strValue
		union
		select	'PasswordHistoryLength' as strName,dbo.fnPolicyValue('PasswordHistoryLength') as strValue
		union
		select	'PasswordMinimalLength' as strName,dbo.fnPolicyValue('PasswordMinimalLength') as strValue
		union
		select	'InactivityTimeout' as strName,dbo.fnPolicyValue('InactivityTimeout') as strValue
		union
		select	'ForcePasswordComplexity' as strName,dbo.fnPolicyValue('ForcePasswordComplexity') as strValue
		union
		select	'PasswordComplexityExpression' as strName,dbo.fnPolicyValue('PasswordComplexityExpression') as strValue
		union
		select	'PasswordComplexityDescription' as strName,dbo.fnPolicyValue('PasswordComplexityDescription') as strValue
	)	Policies
	left join	fnReference(@LangID,19000120) Ref
	on			Policies.strValue=cast(Ref.idfsReference as nvarchar(200))
*/
	
/*
	declare		@scid bigint

	select		@scid=idfSecurityConfiguration
	from		fnPolicyValue()

	select		PolicyList.*,
				[Level].name as SecurityLevel
				--Ref.name as [Description]
	from		fnPolicyValue() PolicyList
	left join	fnReference(@LangID,19000119) [Level]
	on			[Level].idfsReference=PolicyList.idfsSecurityLevel
	--left join	fnReference(@LangID,19000120) Ref
	--on			Ref.idfsReference=PolicyList.idfsSecurityConfigurationDescription
	--where		@cid=PolicyList.idfSecurityConfiguration

	select		tstSecurityConfigurationAlphabet.*
				--Ref.name as [Description]
	from		tstSecurityConfigurationAlphabet
	inner join	tstSecurityConfigurationAlphabetParticipation
	on			tstSecurityConfigurationAlphabetParticipation.intRowStatus=0 and
				tstSecurityConfigurationAlphabet.intRowStatus=0 and
				tstSecurityConfigurationAlphabetParticipation.idfSecurityConfiguration=@scid
	--left join	fnReference(@LangID,19000118) Ref
	--on			Ref.idfsReference=dbo.tstSecurityConfigurationAlphabet.idfsSecurityConfigurationAlphabet
*/

		SELECT TOP  1 
			 [SecurityPolicyConfigurationUID] AS idfSecurityConfiguration
			,10190001 AS idfsSecurityLevel
			,[SesnIdleCloseoutThldMins] AS intAccountLockTimeout
			,[LockoutThld] AS intAccountTryCount
			,[SesnInactivityTimeOutMins] AS intInactivityTimeout
			,[MinPasswordAgeDays] AS intPasswordAge
			,[EnforcePasswordHistoryCount] AS intPasswordHistoryLength
			,[MinPasswordLength] AS intPasswordMinimalLength
			, (case when [ForceUppercaseFlag]=0 and [ForceLowercaseFlag]=0 and [ForceNumberUsageFlag]=0 and  [ForceSpecialCharactersFlag] =0 and [AllowUseOfSpaceFlag] =0 and [PreventSequentialCharacterFlag] =0 and [PreventUsernameUsageFlag]=0  then 0
			else 1 end) as intForcePasswordComplexity
			,'Medium' AS SecurityLevel
		  FROM [dbo].[SecurityPolicyConfiguration]
		  WHERE intRowStatus = 0 
		  ORDER BY SecurityPolicyConfigurationUID Desc
END

GO
