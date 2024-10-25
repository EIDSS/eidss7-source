-- ================================================================================================
-- Name: USP_ADMIN_DEPARTMENT_SET
--
-- Description: Adds or updates a department in an organization.
-- Author: Ricky Moss
-- 
-- Change Log:
-- Name 				Date       Description
-- -------------------- ---------- ---------------------------------------------------------------
-- Ricky Moss			12/27/2019 Initial Release
-- Ricky Moss			01/03/2020 Refactored to check Department Name existence
-- Ann Xiong		    11/20/2020 Modified to insert NationalName in trtStringNameTranslation
-- Mark Wilson			08/10/2021 Updated to use E7 artifacts
-- Stephen Long         09/01/2021 Added order and row status parameters and added organization 
--                                 ID to the duplicate department check.  Duplicate check will 
--                                 be performed on both insert and update.
-- Ann Xiong			02/16/2023 Implemented Data Audit
-- Ann Xiong			03/28/2023 Called USSP_GBL_BASE_REFERENCE_SET instead of USP_GBL_BaseReference_SET to use its data auditing
/*
DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_ADMIN_Department_Set]
		@LanguageID = N'en-US',
		@DepartmentID = NULL,
		@OrganizationID = 48120000000,
		@DefaultName = N'DEP199',
		@NationalName = N'DEP1100',
		@CountryID = NULL,
		@UserName = N'rykermase',
		@RowAction = NULL - values are R for read, I for insert, U for update and D for delete.

SELECT	'Return Value' = @return_value

*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_DEPARTMENT_SET] (
	@LanguageID NVARCHAR(50)
	,@DepartmentID BIGINT = NULL
	,@DefaultName NVARCHAR(200)
	,@NationalName NVARCHAR(200)
	,@OrganizationID BIGINT
	,@DepartmentNameTypeID BIGINT
	,@Order INT = 0
	,@UserName VARCHAR(100) = NULL
	,@RowStatus INT = 0
	)
AS
BEGIN
	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS';
	DECLARE @ReturnCode BIGINT = 0;

	--Data Audit--
	declare @idfUserId BIGINT = NULL;
	declare @idfSiteId BIGINT = NULL;
	declare @idfsDataAuditEventType bigint = NULL;
	declare @idfsObjectType bigint = 10017016;                         -- Department
	declare @idfObject bigint = @DepartmentID;
	declare @idfObjectTable_tlbDepartment bigint = 50815890000000;
	declare @idfDataAuditEvent bigint= NULL;
	declare @idfObjectTable_trtBaseReference bigint = 75820000000;
	declare @idfObjectTable_trtStringNameTranslation bigint = 75990000000;

    DECLARE @tlbDepartment_BeforeEdit TABLE
    (
        DepartmentID BIGINT,
        DepartmentNameBaseReferenceID BIGINT,
        OrganizationID BIGINT
    );
    DECLARE @tlbDepartment_AfterEdit TABLE
    (
        DepartmentID BIGINT,
        DepartmentNameBaseReferenceID BIGINT,
        OrganizationID BIGINT
    );

	-- Get and Set UserId and SiteId
	select @idfUserId =userInfo.UserId, @idfSiteId=UserInfo.SiteId from dbo.FN_UserSiteInformation(@UserName) userInfo

	--Data Audit--

	BEGIN TRY
		IF @RowStatus = 1 -- Soft Delete
		BEGIN
			IF @DepartmentNameTypeID IS NULL
			BEGIN
				SELECT @DepartmentNameTypeID = idfsDepartmentName
				FROM dbo.tlbDepartment
				WHERE idfDepartment = @DepartmentID;
			END

			--Data Audit

			-- tauDataAuditEvent Event Type - Delete
			set @idfsDataAuditEventType =10016002;

			-- insert record into tauDataAuditEvent
			EXEC USSP_GBL_DataAuditEvent_GET @idfUserID,@idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable_tlbDepartment, @idfDataAuditEvent OUTPUT

			--Data Audit--

			UPDATE dbo.tlbDepartment
			SET intRowStatus = @RowStatus
				,AuditUpdateDTM = GETDATE()
				,AuditUpdateUser = @UserName
			WHERE idfDepartment = @DepartmentID;

            -- Data audit
			INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
				SELECT @idfDataAuditEvent, @idfObjectTable_tlbDepartment, @idfObject
            -- End data audit

			UPDATE dbo.trtBaseReference
			SET intRowStatus = @RowStatus
			WHERE idfsBaseReference = @DepartmentNameTypeID
				AND intRowStatus = 0;

            -- Data audit
			INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
				SELECT @idfDataAuditEvent, @idfObjectTable_trtBaseReference, @DepartmentNameTypeID
            -- End data audit

			UPDATE dbo.trtStringNameTranslation
			SET intRowStatus = @RowStatus
			WHERE idfsBaseReference = @DepartmentNameTypeID;

            -- Data audit
			INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
				SELECT @idfDataAuditEvent, @idfObjectTable_trtStringNameTranslation, @DepartmentNameTypeID
            -- End data audit
		END
		ELSE
		BEGIN
			IF (
					SELECT COUNT(b.idfsReference)
					FROM dbo.FN_GBL_ReferenceRepair_GET(@LanguageID, 19000164) b
					INNER JOIN dbo.tlbDepartment d ON d.idfsDepartmentName = b.idfsReference
					WHERE b.strDefault = @DefaultName
						AND d.intRowStatus = 0
						AND d.idfOrganization = @OrganizationID
						AND ((d.idfDepartment <> @DepartmentID AND @DepartmentID IS NOT NULL AND @DepartmentID > 0) --Update
						OR (@DepartmentID IS NULL OR @DepartmentID < 0)) --Insert
					) > 0
			BEGIN
				SELECT @ReturnMessage = 'DOES EXIST';
			END

			IF @ReturnMessage <> 'DOES EXIST'
			BEGIN
				IF @DepartmentID IS NULL
					OR @DepartmentID < 0
				BEGIN
					IF (
							UPPER(@LanguageID) = 'EN-US'
							AND ISNULL(@DefaultName, N'') = N''
							)
					BEGIN
						SET @DefaultName = @NationalName;
					END

					--Data Audit--
					-- tauDataAuditEvent Event Type - Create 
					set @idfsDataAuditEventType =10016001;
					-- insert record into tauDataAuditEvent - 
					EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@DepartmentID, @idfObjectTable_tlbDepartment, @idfDataAuditEvent OUTPUT
					--Data Audit--

                    EXECUTE dbo.USSP_GBL_BASE_REFERENCE_SET @DepartmentNameTypeID OUTPUT,
                                                            19000164,
                                                            @LanguageID,
                                                            @DefaultName,
                                                            @NationalName,
                                                            0,
                                                            @Order,
                                                            0,
                                                            @UserName,
                                                            @idfDataAuditEvent,
                                                            NULL;

					EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbDepartment'
						,@DepartmentID OUTPUT;

					INSERT INTO dbo.tlbDepartment (
						idfDepartment
						,idfsDepartmentName
						,idfOrganization
						,strReservedAttribute
						,intRowStatus
						,rowguid
						,SourceSystemNameID
						,SourceSystemKeyValue
						,AuditCreateUser
						,AuditCreateDTM
						,AuditUpdateUser
						,AuditUpdateDTM
						)
					VALUES (
						@DepartmentID
						,@DepartmentNameTypeID
						,@OrganizationID
						,dbo.FN_GBL_DATACHANGE_INFO(@UserName)
						,0
						,NEWID()
						,10519001
						,N'[{"idfDepartment":' + CAST(@DepartmentID AS NVARCHAR(300)) + '}]'
						,@UserName
						,GETDATE()
						,@UserName
						,GETDATE()
						);

					--Data Audit--
					INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject )
						values ( @idfDataAuditEvent, @idfObjectTable_tlbDepartment, @DepartmentID)
					--Data Audit--

				END
				ELSE
				BEGIN
					SELECT @DepartmentNameTypeID = (
							SELECT idfsDepartmentName
							FROM dbo.tlbDepartment
							WHERE idfDepartment = @DepartmentID
							);

                    -- Data audit
			        --  tauDataAuditEvent  Event Type- Edit 
			        set @idfsDataAuditEventType =10016003;
			        -- insert record into tauDataAuditEvent - 
			        EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable_tlbDepartment, @idfDataAuditEvent OUTPUT
                    -- Data audit

                    EXECUTE dbo.USSP_GBL_BASE_REFERENCE_SET @DepartmentNameTypeID OUTPUT,
                                                            19000164,
                                                            @LanguageID,
                                                            @DefaultName,
                                                            @NationalName,
                                                            0,
                                                            @Order,
                                                            0,
                                                            @UserName,
                                                            @idfDataAuditEvent,
                                                            NULL;

                    -- Data audit
                    INSERT INTO @tlbDepartment_BeforeEdit
                    (
                        DepartmentID,
                        DepartmentNameBaseReferenceID,
                        OrganizationID
                    )
                    SELECT idfDepartment,
                           idfsDepartmentName,
                           idfOrganization
                    FROM dbo.tlbDepartment
                    WHERE idfDepartment = @DepartmentID;
                    -- End data audit

					UPDATE dbo.tlbDepartment
					SET idfsDepartmentName = @DepartmentNameTypeID
						,strReservedAttribute = dbo.FN_GBL_DATACHANGE_INFO(@UserName)
						,AuditUpdateUser = @UserName
						,AuditUpdateDTM = GETDATE()
					WHERE idfDepartment = @DepartmentID;

                    -- Data audit
                    INSERT INTO @tlbDepartment_AfterEdit
                    (
                        DepartmentID,
                        DepartmentNameBaseReferenceID,
                        OrganizationID
                    )
                    SELECT idfDepartment,
                           idfsDepartmentName,
                           idfOrganization
                    FROM dbo.tlbDepartment
                    WHERE idfDepartment = @DepartmentID;

                    INSERT INTO dbo.tauDataAuditDetailUpdate
                    (
                        idfDataAuditEvent,
                        idfObjectTable,
                        idfColumn,
                        idfObject,
                        idfObjectDetail,
                        strOldValue,
                        strNewValue
                    )
                    SELECT @idfDataAuditEvent,
                           @idfObjectTable_tlbDepartment,
                           50815910000000,
                           a.DepartmentID,
                           NULL,
                           b.DepartmentNameBaseReferenceID,
                           a.DepartmentNameBaseReferenceID
                    FROM @tlbDepartment_AfterEdit AS a
                        FULL JOIN @tlbDepartment_BeforeEdit AS b
                            ON a.DepartmentID = b.DepartmentID
                    WHERE (a.DepartmentNameBaseReferenceID <> b.DepartmentNameBaseReferenceID)
                          OR (
                                 a.DepartmentNameBaseReferenceID IS NOT NULL
                                 AND b.DepartmentNameBaseReferenceID IS NULL
                             )
                          OR (
                                 a.DepartmentNameBaseReferenceID IS NULL
                                 AND b.DepartmentNameBaseReferenceID IS NOT NULL
                             );
                    -- End data audit
				END
			END
		END;

		SELECT @ReturnCode ReturnCode
			,@ReturnMessage ReturnMessage
			,@DepartmentID KeyId
			,'DepartmentID' KeyName
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;

		THROW;
	END CATCH
END
