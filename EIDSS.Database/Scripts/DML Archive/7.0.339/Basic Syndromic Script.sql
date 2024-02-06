/*
Mike Kornegay
3/16/2023
Translate migrated basic syndromic surveillance values to new parameter types in EIDSS7 and
create parameter types for BSS Outcomes and BSS Test Results.  

Note:  This script creates the correct parameter types but does not add those types to the flex form template - that step 
must be done by customer.

*/
--set parameter types back to fixed preset values for 
--yes/no and other/axillary/oral
update ffParameterType 
set 
	idfsReferenceType = 19000069,
	SourceSystemNameID = 10519001,
	SourceSystemKeyValue = '[{"idfsParameterType":217140000000}]',
	AuditCreateUser = 'system',
	AuditCreateDTM = '2023-01-05'
where idfsParameterType = 217140000000

update ffParameterType 
set 
	idfsReferenceType = 19000069, 
	SourceSystemNameID = 10519001,
	SourceSystemKeyValue = '[{"idfsParameterType":10071501}]',
	AuditCreateUser = 'system',
	AuditCreateDTM = '2023-01-05'
where idfsParameterType = 10071501

--update the yes no migrated answer values
update	ap
set		varValue = 25460000000 --yes 
from	tlbActivityParameters ap
where strMaintenanceFlag = 'V7Ref.Syndromic'
and SourceSystemNameID = 10519001
and varValue = 10100001

update	ap
set		varValue = 25640000000 --no 
from	tlbActivityParameters ap
where strMaintenanceFlag = 'V7Ref.Syndromic'
and SourceSystemNameID = 10519001
and varValue = 10100002

update	ap
set		varValue = 25660000000 --unknown
from	tlbActivityParameters ap
where strMaintenanceFlag = 'V7Ref.Syndromic'
and SourceSystemNameID = 10519001
and varValue = 10100003

update	ap
set		varValue = 10069502 --oral 
from	tlbActivityParameters ap
where strMaintenanceFlag = 'V7Ref.Syndromic'
and SourceSystemNameID = 10519001
and varValue = 50791940000000

update	ap
set		varValue = 10069501 --axillary
from	tlbActivityParameters ap
where strMaintenanceFlag = 'V7Ref.Syndromic'
and SourceSystemNameID = 10519001
and varValue = 50791950000000

update	ap
set		varValue = 10069503 --other
from	tlbActivityParameters ap
where strMaintenanceFlag = 'V7Ref.Syndromic'
and SourceSystemNameID = 10519001
and varValue = 50791960000000

--10066530 test results parameter from BSS migrated data
--10066513 case outcomes parameter from BSS migrated data

declare @idfsParameterType bigint
declare @idfsSection bigint
declare @SuppressSelect table
(
        ReturnCode int,
        ReturnMessage nvarchar(max),
		idfsParameter bigint,
		idfsParameterCaption bigint
);
declare @idfsParameter bigint = null
declare @idfsParameterCaption bigint = null
		
set @idfsSection = (select idfsSection from ffSection where idfsFormType = 10034010 and strMaintenanceFlag = 'V7 Ref. Syndromic');

-- create a parameter type for reference type 19000064 (BSS Case Outcome)
begin

	-- check for duplicate parameter type before inserting
	if (NOT EXISTS	(SELECT TOP 1 1 FROM dbo.ffParameterType AS PT
				LEFT JOIN FN_GBL_Reference_List_GET('en-US', 19000071 /*'rftParameterType'*/) AS RT
				ON RT.idfsReference = PT.idfsParameterType
				WHERE RT.strDefault = 'Basic Syndromic Surveillance Case Outcome'
				AND PT.idfsReferenceType = 19000064
				AND PT.intRowStatus = 0))
		begin
			-- add or update the parameter type in the base reference table first
			exec dbo.USSP_GBL_BaseReference_SET @idfsParameterType output, 
												19000071/*'rftParameterType'*/,
												'en-US', 
												'Basic Syndromic Surveillance Case Outcome', 
												'Basic Syndromic Surveillance Case Outcome', 
												226,
												0

			insert into dbo.ffParameterType
				(
					[idfsParameterType]
					,[idfsReferenceType]
					,strMaintenanceFlag
					,SourceSystemNameID
					,SourceSystemKeyValue
					,AuditCreateDTM
					,AuditCreateUser
				)
			values
				(
					@idfsParameterType
					,19000064
					,'V7 Ref. Syndromic'
					,10519001
					,'[{"idfsParameterType":'+ convert(nvarchar(20), @idfsParameterType) + '}]'
					,GETDATE()
					,'system'
				)
		end

		set @idfsParameterType =	(select top 1 idfsParameterType 
							from ffParameterType pt
							inner join trtBaseReference br
							on br.idfsBaseReference = pt.idfsParameterType
							where pt.idfsReferenceType = 19000064
							and pt.strMaintenanceFlag = 'V7 Ref. Syndromic'
							and strDefault = 'Basic Syndromic Surveillance Case Outcome'
							and pt.SourceSystemNameID = 10519001
							and pt.intRowStatus = 0)

	-- create the new flex form parameter that points to this new type
	if (NOT EXISTS	(SELECT TOP 1 1 FROM dbo.ffParameter AS p
			INNER JOIN trtBaseReference br ON br.idfsBaseReference = p.idfsParameter
			WHERE br.strDefault = 'BSS Case Outcomes'
			AND p.idfsFormType = 10034010
			AND p.intRowStatus = 0
			AND p.idfsSection = @idfsSection
			AND p.idfsEditor = 10067002))
		begin
			insert into @SuppressSelect
			execute [dbo].[USP_ADMIN_FF_Parameters_SET]
				@LangID = 'en-US',
				@idfsSection = @idfsSection,
				@idfsFormType = 10034010,
				@idfsParameterType = @idfsParameterType,
				@idfsEditor = 10067002,
				@intHACode = 0,
				@intOrder = 0,
				@strNote = NULL,
				@DefaultName = 'BSS Case Outcome',
				@NationalName = 'BSS Case Outcome',
				@DefaultLongName = 'BSS Case Outcome',
				@NationalLongName = 'BSS Case Outcome',
				@idfsParameter = @idfsParameter,
				@idfsParameterCaption = @idfsParameterCaption,
				@User = 'system',
				@intRowStatus = 0,
				@CopyOnly = 0
		end

		set @idfsParameter =	(select top 1 idfsParameter 
									from ffParameter p
									inner join trtBaseReference br
									on br.idfsBaseReference = p.idfsParameter
									where idfsFormType = 10034010
									and idfsEditor = 10067002
									and strDefault = 'BSS Case Outcome'
									and idfsSection = 10101501
									and p.intRowStatus = 0)

		-- update the migrated syndromic surveillance records in tlbActivityParameters with the new parameter
		begin
			update	a
			set		idfsParameter = @idfsParameter --BSS Case Outcomes Parameter
			from	tlbActivityParameters a
			where strMaintenanceFlag = 'V7Ref.Syndromic'
			and SourceSystemNameID = 10519001
			and idfsParameter = 10066513;
		end
end
-- end for BSS Case Outcomes

-- create a parameter type for reference type 19000162 (BSS Test Results)
begin
	set @idfsParameterType = null;
	set @idfsParameter = null;


	--check for duplicate parameter type before inserting
	IF (NOT EXISTS	(SELECT TOP 1 1 FROM dbo.ffParameterType AS PT
				LEFT JOIN FN_GBL_Reference_List_GET('en-US', 19000071 /*'rftParameterType'*/) AS RT
				ON RT.idfsReference = PT.idfsParameterType
				WHERE RT.strDefault = 'Basic Syndromic Surveillance Test Result'
				AND PT.idfsReferenceType = 19000162
				AND PT.intRowStatus = 0))
		begin
			--add or update the parameter type in the base reference table first
			exec dbo.USSP_GBL_BaseReference_SET @idfsParameterType OUTPUT, 
												19000071/*'rftParameterType'*/,
												'en-US', 
												'Basic Syndromic Surveillance Test Result', 
												'Basic Syndromic Surveillance Test Result', 
												226,
												0
			insert into dbo.ffParameterType
				(
					[idfsParameterType]
					,[idfsReferenceType]
					,strMaintenanceFlag
					,SourceSystemNameID
					,SourceSystemKeyValue
					,AuditCreateDTM
					,AuditCreateUser
				)
			values
				(
					@idfsParameterType
					,19000162
					,'V7 Ref. Syndromic'
					,10519001
					,'[{"idfsParameterType":'+ convert(nvarchar(20), @idfsParameterType) + '}]'
					,GETDATE()
					,'system'
				)
		end

		set @idfsParameterType =	(select top 1 idfsParameterType 
							from ffParameterType pt
							inner join trtBaseReference br
							on br.idfsBaseReference = pt.idfsParameterType
							where pt.idfsReferenceType = 19000162
							and pt.strMaintenanceFlag = 'V7 Ref. Syndromic'
							and strDefault = 'Basic Syndromic Surveillance Test Result'
							and pt.SourceSystemNameID = 10519001
							and pt.intRowStatus = 0)

	-- create the new flex form parameter that points to this new type
	if (NOT EXISTS	(SELECT TOP 1 1 FROM dbo.ffParameter AS p
			INNER JOIN trtBaseReference br ON br.idfsBaseReference = p.idfsParameter
			WHERE br.strDefault = 'BSS Test Result'
			AND p.idfsFormType = 10034010
			AND p.intRowStatus = 0
			AND p.idfsSection = @idfsSection
			AND p.idfsEditor = 10067002))
		begin
			insert into @SuppressSelect
			execute [dbo].[USP_ADMIN_FF_Parameters_SET]
				@LangID = 'en-US',
				@idfsSection = @idfsSection,
				@idfsFormType = 10034010,
				@idfsParameterType = @idfsParameterType,
				@idfsEditor = 10067002,
				@intHACode = 0,
				@intOrder = 0,
				@strNote = NULL,
				@DefaultName = 'BSS Test Result',
				@NationalName = 'BSS Test Result',
				@DefaultLongName = 'BSS Test Result',
				@NationalLongName = 'BSS Test Result',
				@idfsParameter = @idfsParameter,
				@idfsParameterCaption = @idfsParameterCaption,
				@User = 'system',
				@intRowStatus = 0,
				@CopyOnly = 0
		end

		set @idfsParameter =	(select top 1 idfsParameter 
									from ffParameter p
									inner join trtBaseReference br
									on br.idfsBaseReference = p.idfsParameter
									where idfsFormType = 10034010
									and idfsEditor = 10067002
									and strDefault = 'BSS Test Result'
									and idfsSection = 10101501
									and p.intRowStatus = 0)

		-- update the migrated syndromic surveillance records in tlbActivityParameters with the new parameter
		begin
			update	a
			set		idfsParameter = @idfsParameter --BSS Test Results Parameter
			from	tlbActivityParameters a
			where strMaintenanceFlag = 'V7Ref.Syndromic'
			and SourceSystemNameID = 10519001
			and idfsParameter = 10066530;
		end

end
