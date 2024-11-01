/****** Object:  UserDefinedFunction [dbo].[fnEvaluatePermissions]    Script Date: 5/23/2022 10:11:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--================================================================================================
-- Author: Edgard Torres
-- Create date: 5/16/2022
-- Description:	Retrieve a list of Roles and Permissions for the given user from EIDSS7 to AVR user
-- 
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Edgard Torres    2/9/2023  Added mapping of EIDSS7 system functions to AVR system functions
-- Edgard Torres    5/16/2022 function modified
--

-- ================================================================================================

ALTER   FUNCTION [dbo].[fnEvaluatePermissions]
(	
	@idfEmployee bigint
)
RETURNS TABLE 
AS
RETURN 
(
select	(
		case SystemFunctionID
			when 10094510 then 10094027 -- permission to Human Disease Report >> Human Disease Report idfSystemFunction 10094027 (remap to object's idfSystemFunction in tasSearchObjectToSystemFunction table)
			when 10094546 then 10094051 -- permission to ILI Aggregate Form Data >> ILI Aggregate Form (10094051)
			else SystemFunctionID
		end
		) as idfsSystemFunction,
	strBaseReferenceCode, SystemFunctionOperationID as idfsObjectOperation, intPermission = 
	case LkupRoleSystemFunctionAccess.intRowStatus
		when 0 then 2
		when 1 then 1
	end
from LkupRoleSystemFunctionAccess
left join	trtBaseReference 
on			trtBaseReference.idfsBaseReference = LkupRoleSystemFunctionAccess.SystemFunctionID
where idfEmployee = @idfEmployee
)

GO
