
-- ================================================================================================
-- Name: USP_SP_GetList_DevOnly
-- Description: Gets a list of stored procedures for the model maker utility.
-- THIS IS A DEVELOPMENT ONLY STORED PROCEDURE.  IT SHOULD NOT BE PUBLISHED TO OTHER ENVIRONMENTS!
--          
-- Revision History:
-- Name             Date         Change
-- ---------------  ----------   --------------------------------------------------------------------
-- Steven Verner    10/21/2021   Creation
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_SP_GetList_DevOnly]
AS
BEGIN	
	SET NOCOUNT ON;

    SELECT name AS procedure_name   
        ,SCHEMA_NAME(schema_id) AS schema_name  
        ,type_desc  
        ,create_date  
        ,modify_date  
    FROM sys.procedures
    where name like 'USP_%'
    ORDER BY modify_date desc

END


