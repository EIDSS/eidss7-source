
-- ================================================================================================
-- Name: USP_SP_GetList_DevOnly
-- Description: Gets parameters for the given stored procedure for the model maker utility.
-- THIS IS A DEVELOPMENT ONLY STORED PROCEDURE.  IT SHOULD NOT BE PUBLISHED TO OTHER ENVIRONMENTS!
--          
-- Revision History:
-- Name             Date         Change
-- ---------------  ----------   --------------------------------------------------------------------
-- Steven Verner    10/21/2021   Creation
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_SP_Parameters_Get_DevOnly]
(
	@spName						NVARCHAR(225) = NULL	
)	
AS
BEGIN	
	SET NOCOUNT ON;

    SELECT SCHEMA_NAME(schema_id) AS schema_name  
        ,o.name AS object_name  
        ,o.type_desc  
        ,p.parameter_id  
        ,p.name AS parameter_name  
        ,TYPE_NAME(p.user_type_id) AS parameter_type  
        ,p.max_length  
        ,p.precision  
        ,p.scale  
        ,p.is_output  
        ,o.object_id
    FROM sys.objects AS o  
    INNER JOIN sys.parameters AS p ON o.object_id = p.object_id  
    WHERE o.name = @spName
    ORDER BY schema_name, object_name, p.parameter_id;  
END


