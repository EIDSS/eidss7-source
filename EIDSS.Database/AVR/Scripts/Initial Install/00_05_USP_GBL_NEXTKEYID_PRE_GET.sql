/****** Object:  StoredProcedure [dbo].[USP_GBL_NEXTKEYID_GET]    Script Date: 4/26/2022 2:27:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ============================================================================
-- Name: USP_GBL_NEXTKEYID_GET
-- Description:	Gets a new ID (primary key) value for a given table
--                   
-- Author: Mandar Kulkarni
-- Date 11/08/2017
--
-- Revision History:
-- Name             Date		Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Steven Verner	03/26/2021	Removed @returnCode and @returnMessage variables and instead
--								throw exception, which floats up to calling SP and handled
--								(I primarily made this change to allow EF Power Tools to generate POCOs for SET operations)
/*
----testing code:
DECLARE	@return_value int,
		@idfsKey bigint
EXEC	@return_value = [dbo].[USP_GBL_NEXTKEYID_GET]
		@tableName = N'lkupconfigparm',
		@idfsKey = @idfsKey OUTPUT
*/
--=====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_GBL_NEXTKEYID_GET] 
(
 @tableName VARCHAR(100),
 @idfsKey	BIGINT = 0 OUTPUT
)
AS
DECLARE @sqlString		NVARCHAR(max) 
DECLARE @increamentBy	INT = 1;

------==================================================
------for local debug 
----DECLARE  @tableName VARCHAR(100), @idfsKey	BIGINT 
--------SET @tableName='trtBaseReference'
----SET @tableName='lkupconfigparm'
------==================================================
BEGIN
	BEGIN TRY  
		----prepare next ID based on returned highest id
		EXEC [dbo].[USP_GBL_NEXTKEYID_PRE_GET] @tableName, @idfsKey OUTPUT
		----PRINT '@idfsKey returned: '+ CONVERT(VARCHAR(20),@idfsKey) 

		SET @idfsKey=@idfsKey+@increamentBy
		----PRINT '@idfsKey for next: '+ CONVERT(VARCHAR(20),@idfsKey) 

		-- Check if table name exists in the Primary Keys table
		IF EXISTS (SELECT * FROM dbo.LKUPNextKey WHERE tableName = @tableName)
		-- If table row exists, update info
		BEGIN
			-- update the last key value in the table for the next time.
			UPDATE	dbo.LKUPNextKey
			SET		LastUsedKey = @idfsKey,
					AuditUpdateDTM=GETDATE()
			WHERE	tableName = @tableName

		END ELSE 
		-- If table row does not exists, insert  a new row. 
		BEGIN
			INSERT
			INTO dbo.LKUPNextKey
			(
			TableName,
			LastUsedKey,
			intRowStatus
			)
			VALUES
			(
			@tableName,
			@idfsKey,
			0
			)
		END
	END TRY  
	BEGIN CATCH 
		THROW
	END CATCH
END
GO


