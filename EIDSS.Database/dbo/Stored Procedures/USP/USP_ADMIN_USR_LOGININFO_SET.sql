-- ================================================================================================
-- Name: USP_ADMIN_USR_LOGININFO_SET    
-- Description: Insert/Update user login info    
--              
-- Author: Maheshwar D Deo    
-- Revision History:
-- Name                 Date       Change Detail    
-- -------------------- ---------- ---------------------------------------------------------------
-- Arnold Kennedy       08-02-2018 Change input parms from idfPerson to idfEmployee  
-- Steven Verner        12-06-2019 Added suppress select and added idfuserid to output...	
-- Ricky Moss           12-23-2019 Returned @idfUserID value on update 
-- Ricky Moss           03-26-2019 Added idfsPersonSite as a parameter
-- Stephen Long         06-29-2022 Added event subscription set call.
--
-- Testing code:    
--	exec USP_ADMIN_USR_LOGININFO_SET -425, '', null
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_USR_LOGININFO_SET]
(
    @idfEmployee BIGINT = NULL,
    @idfsPersonSite BIGINT,
    @strAccountName NVARCHAR(200) = NULL,
    @binPassword VARBINARY(50) = NULL
)
AS
DECLARE @idfuserID BIGINT = null;
DECLARE @returnCode INT = 0;
DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS';

DECLARE @SuppressSelect TABLE
(
    ReturnCode INT,
    ReturnMessage VARCHAR(2048)
);
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        --------------------------------------------------------------------    
        -- Insert    
        --------------------------------------------------------------------    
        DECLARE @datPasswordSet DATETIME;
        SET @datPasswordSet = GETDATE();

        IF NOT EXISTS
        (
            SELECT idfUserId
            FROM tstUserTable
            WHERE idfPerson = @idfEmployee
        )
        BEGIN
            INSERT INTO @SuppressSelect
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'tstUserTable', @idfUserID OUTPUT;

            -- Insert into user table    
            INSERT INTO dbo.tstUserTable
            (
                idfUserID,
                idfPerson,
                idfsSite,
                strAccountName,
                binPassword,
                datPasswordSet
            )
            VALUES
            (   @idfUserID,
                @idfEmployee,
                @idfsPersonSite,
                @strAccountName,
                @binPassword,
                @datPasswordSet
            );

            INSERT INTO @SuppressSelect
            EXEC dbo.USP_ADMIN_EMPLOYEE_EVENTSUBSCRIPTION_SET @idfUserId = @idfUserID;
        END
        ELSE
        ---------------------------------------------------------------------------------    
        -- Update    
        ---------------------------------------------------------------------------------    
        BEGIN
            SELECT @idfuserID =
            (
                SELECT idfUserId FROM dbo.tstUserTable WHERE idfPerson = @idfEmployee
            );

            UPDATE dbo.tstUserTable
            SET strAccountName = @strAccountName,
                binPassword = @binPassword,
                datPasswordSet = @datPasswordSet
            WHERE idfUserID = @idfUserID;
        END

        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;

        SELECT @returnCode as ReturnCode,
               @returnMsg as ReturnMessage,
               @idfUserID as idfUserID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SET @returnMsg
            = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: '
              + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE())
              + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: '
              + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();

        SET @returnCode = ERROR_NUMBER();
        SELECT @returnCode as ReturnCode,
               @returnMsg as ReturnMessage,
               @idfUserID as idfUserID;
    END CATCH
END
