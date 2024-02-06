--=================================================================================================
-- Name: USP_SecurityConfiguration_Set
-- 
-- Created by:				Manickandan Govindarajan
-- Last modified date:		07/05/2021
-- Last modified by:		Manickandan Govindarajan
-- Description:				Update security policy 
-- Testing code:
--
-- Revision History:
-- Name                        Date       Change Detail
-- --------------------------- ---------- --------------------------------------------------------
-- Manickandan Govindarajan    08/13/2021 Added [SesnInactivityTimeOutMins] field
-- Stephen Long                07/12/2022 Added site alert logic.
-- Mani Govindarajan           03/12/2023 Added Data Audit

--=================================================================================================
CREATE PROCEDURE [dbo].[USP_SecurityConfiguration_Set]
    @Id int,
    @MinPasswordLength int,
    @EnforcePasswordHistoryCount int,
    @MinPasswordAgeDays int,
    @ForceUppercaseFlag bit,
    @ForceLowercaseFlag bit,
    @ForceNumberUsageFlag bit,
    @ForceSpecialCharactersFlag bit,
    @AllowUseOfSpaceFlag bit,
    @PreventSequentialCharacterFlag bit,
    @PreventUsernameUsageFlag bit,
    @LockoutThld int,
    @MaxSessionLength int,
    @SesnIdleTimeoutWarnThldMins int,
    @SesnIdleCloseoutThldMins int,
    @SesnInactivityTimeOutMins int,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT, 
    @AuditUserName NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
            @ReturnCode BIGINT = 0,
            @EventId BIGINT = -1,
            @EventSiteId BIGINT = @SiteId,
            @EventObjectId BIGINT = @Id,
            @EventUserId BIGINT = @UserId,
            @EventDiseaseId BIGINT = NULL,
            @EventLocationId BIGINT = @LocationId,
            @EventInformationString NVARCHAR(MAX) = NULL,
            @EventLoginSiteId BIGINT = @SiteId;

		--Data Audit--
		declare @idfsDataAuditEventType bigint = 10016003; -- Edut
		declare @idfsObjectType bigint = 10017064;         -- Security Policy
		declare @idfObject bigint = @Id;
		declare @idfDataAuditEvent bigint= NULL;
		declare @idfObjectTable_SecurityPolicy bigint = 53577790000005;


		DECLARE @SecurityPolicyConfiguration_BeforeEdit TABLE
		(
        	[SecurityPolicyConfigurationUID] [int] NOT NULL,
			[MinPasswordLength] [int] NULL,
			[EnforcePasswordHistoryCount] [int] NULL,
			[MinPasswordAgeDays] [int] NULL,
			[ForceUppercaseFlag] [bit] NULL,
			[ForceLowercaseFlag] [bit] NULL,
			[ForceNumberUsageFlag] [bit] NULL,
			[ForceSpecialCharactersFlag] [bit] NULL,
			[AllowUseOfSpaceFlag] [bit] NULL,
			[PreventSequentialCharacterFlag] [bit] NULL,
			[PreventUsernameUsageFlag] [bit] NULL,
			[LockoutThld] [int] NULL,
			[LockoutDurationMinutes] [int] NULL,
			[MaxSessionLength] [int] NULL,
			[SesnIdleTimeoutWarnThldMins] [int] NULL,
			[SesnIdleCloseoutThldMins] [int] NULL,
			[SesnInactivityTimeOutMins] [int] NULL
		);

		DECLARE @SecurityPolicyConfiguration_AfterEdit TABLE
		(
        	[SecurityPolicyConfigurationUID] [int] NOT NULL,
			[MinPasswordLength] [int] NULL,
			[EnforcePasswordHistoryCount] [int] NULL,
			[MinPasswordAgeDays] [int] NULL,
			[ForceUppercaseFlag] [bit] NULL,
			[ForceLowercaseFlag] [bit] NULL,
			[ForceNumberUsageFlag] [bit] NULL,
			[ForceSpecialCharactersFlag] [bit] NULL,
			[AllowUseOfSpaceFlag] [bit] NULL,
			[PreventSequentialCharacterFlag] [bit] NULL,
			[PreventUsernameUsageFlag] [bit] NULL,
			[LockoutThld] [int] NULL,
			[LockoutDurationMinutes] [int] NULL,
			[MaxSessionLength] [int] NULL,
			[SesnIdleTimeoutWarnThldMins] [int] NULL,
			[SesnIdleCloseoutThldMins] [int] NULL,
			[SesnInactivityTimeOutMins] [int] NULL
		);

		--Data Audit--
		 EXEC USSP_GBL_DataAuditEvent_GET @UserId, @SiteId, @idfsDataAuditEventType,@idfsObjectType,@id, @idfObjectTable_SecurityPolicy, @idfDataAuditEvent OUTPUT
        INSERT INTO @SecurityPolicyConfiguration_BeforeEdit
        (
            [SecurityPolicyConfigurationUID],
			[MinPasswordLength],
			[EnforcePasswordHistoryCount],
			[MinPasswordAgeDays],
			[ForceUppercaseFlag],
			[ForceLowercaseFlag],
			[ForceNumberUsageFlag],
			[ForceSpecialCharactersFlag],
			[AllowUseOfSpaceFlag],
			[PreventSequentialCharacterFlag],
			[PreventUsernameUsageFlag],
			[LockoutThld],
			[LockoutDurationMinutes],
			[MaxSessionLength],
			[SesnIdleTimeoutWarnThldMins],
			[SesnIdleCloseoutThldMins],
			[SesnInactivityTimeOutMins]
		)
         SELECT 
            [SecurityPolicyConfigurationUID],
			[MinPasswordLength],
			[EnforcePasswordHistoryCount],
			[MinPasswordAgeDays],
			[ForceUppercaseFlag],
			[ForceLowercaseFlag],
			[ForceNumberUsageFlag],
			[ForceSpecialCharactersFlag],
			[AllowUseOfSpaceFlag],
			[PreventSequentialCharacterFlag],
			[PreventUsernameUsageFlag],
			[LockoutThld],
			[LockoutDurationMinutes],
			[MaxSessionLength],
			[SesnIdleTimeoutWarnThldMins],
			[SesnIdleCloseoutThldMins],
			[SesnInactivityTimeOutMins]
		FROM SecurityPolicyConfiguration 
		where [SecurityPolicyConfigurationUID] = @id

        -- End data audit



    UPDATE dbo.SecurityPolicyConfiguration
    SET MinPasswordLength = @MinPasswordLength,
        EnforcePasswordHistoryCount = @EnforcePasswordHistoryCount,
        MinPasswordAgeDays = @MinPasswordAgeDays,
        ForceUppercaseFlag = @ForceUppercaseFlag,
        ForceLowercaseFlag = @ForceLowercaseFlag,
        ForceNumberUsageFlag = @ForceNumberUsageFlag,
        ForceSpecialCharactersFlag = @ForceSpecialCharactersFlag,
        AllowUseOfSpaceFlag = @AllowUseOfSpaceFlag,
        PreventSequentialCharacterFlag = @PreventSequentialCharacterFlag,
        PreventUsernameUsageFlag = @PreventUsernameUsageFlag,
        LockoutThld = @LockoutThld,
        MaxSessionLength = @MaxSessionLength,
        SesnIdleTimeoutWarnThldMins = @SesnIdleTimeoutWarnThldMins,
        SesnIdleCloseoutThldMins = @SesnIdleCloseoutThldMins,
        SesnInactivityTimeOutMins = @SesnInactivityTimeOutMins,
        AuditUpdateDTM = GETDATE(),
        AuditUpdateUser = @AuditUserName
    WHERE SecurityPolicyConfigurationUID = @Id;

	--Data Audit--

	 INSERT INTO @SecurityPolicyConfiguration_AfterEdit
        (
            [SecurityPolicyConfigurationUID],
			[MinPasswordLength],
			[EnforcePasswordHistoryCount],
			[MinPasswordAgeDays],
			[ForceUppercaseFlag],
			[ForceLowercaseFlag],
			[ForceNumberUsageFlag],
			[ForceSpecialCharactersFlag],
			[AllowUseOfSpaceFlag],
			[PreventSequentialCharacterFlag],
			[PreventUsernameUsageFlag],
			[LockoutThld],
			[LockoutDurationMinutes],
			[MaxSessionLength],
			[SesnIdleTimeoutWarnThldMins],
			[SesnIdleCloseoutThldMins],
			[SesnInactivityTimeOutMins]
		)
         SELECT 
            [SecurityPolicyConfigurationUID],
			[MinPasswordLength],
			[EnforcePasswordHistoryCount],
			[MinPasswordAgeDays],
			[ForceUppercaseFlag],
			[ForceLowercaseFlag],
			[ForceNumberUsageFlag],
			[ForceSpecialCharactersFlag],
			[AllowUseOfSpaceFlag],
			[PreventSequentialCharacterFlag],
			[PreventUsernameUsageFlag],
			[LockoutThld],
			[LockoutDurationMinutes],
			[MaxSessionLength],
			[SesnIdleTimeoutWarnThldMins],
			[SesnIdleCloseoutThldMins],
			[SesnInactivityTimeOutMins]
		FROM SecurityPolicyConfiguration 
		where [SecurityPolicyConfigurationUID] = @id

		--MinPasswordLength
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
                @idfObjectTable_SecurityPolicy,
                51586990000050,
                a.SecurityPolicyConfigurationUID,
                NULL,
                b.MinPasswordLength,
                a.MinPasswordLength
        FROM @SecurityPolicyConfiguration_AfterEdit AS a
            FULL JOIN @SecurityPolicyConfiguration_BeforeEdit AS b
                ON a.SecurityPolicyConfigurationUID = b.SecurityPolicyConfigurationUID
        WHERE (a.MinPasswordLength <> b.MinPasswordLength)

		--EnforcePasswordHistoryCount
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
                @idfObjectTable_SecurityPolicy,
                51586990000051,
                a.SecurityPolicyConfigurationUID,
                NULL,
                b.EnforcePasswordHistoryCount,
                a.EnforcePasswordHistoryCount
        FROM @SecurityPolicyConfiguration_AfterEdit AS a
            FULL JOIN @SecurityPolicyConfiguration_BeforeEdit AS b
                ON a.SecurityPolicyConfigurationUID = b.SecurityPolicyConfigurationUID
        WHERE (a.EnforcePasswordHistoryCount <> b.EnforcePasswordHistoryCount)

		--MinPasswordAgeDays
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
                @idfObjectTable_SecurityPolicy,
                51586990000052,
                a.SecurityPolicyConfigurationUID,
                NULL,
                b.MinPasswordAgeDays,
                a.MinPasswordAgeDays
        FROM @SecurityPolicyConfiguration_AfterEdit AS a
            FULL JOIN @SecurityPolicyConfiguration_BeforeEdit AS b
                ON a.SecurityPolicyConfigurationUID = b.SecurityPolicyConfigurationUID
        WHERE (a.MinPasswordAgeDays <> b.MinPasswordAgeDays)

		--ForceUppercaseFlag
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
                @idfObjectTable_SecurityPolicy,
                51586990000053,
                a.SecurityPolicyConfigurationUID,
                NULL,
                b.ForceUppercaseFlag,
                a.ForceUppercaseFlag
        FROM @SecurityPolicyConfiguration_AfterEdit AS a
            FULL JOIN @SecurityPolicyConfiguration_BeforeEdit AS b
                ON a.SecurityPolicyConfigurationUID = b.SecurityPolicyConfigurationUID
        WHERE (a.ForceUppercaseFlag <> b.ForceUppercaseFlag)                         
           -- End data audit

	--ForceLowercaseFlag
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
                @idfObjectTable_SecurityPolicy,
                51586990000054,
                a.SecurityPolicyConfigurationUID,
                NULL,
                b.ForceLowercaseFlag,
                a.ForceLowercaseFlag
        FROM @SecurityPolicyConfiguration_AfterEdit AS a
            FULL JOIN @SecurityPolicyConfiguration_BeforeEdit AS b
                ON a.SecurityPolicyConfigurationUID = b.SecurityPolicyConfigurationUID
        WHERE (a.ForceLowercaseFlag <> b.ForceLowercaseFlag)      

		--ForceNumberUsageFlag
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
                @idfObjectTable_SecurityPolicy,
                51586990000055,
                a.SecurityPolicyConfigurationUID,
                NULL,
                b.ForceNumberUsageFlag,
                a.ForceNumberUsageFlag
        FROM @SecurityPolicyConfiguration_AfterEdit AS a
            FULL JOIN @SecurityPolicyConfiguration_BeforeEdit AS b
                ON a.SecurityPolicyConfigurationUID = b.SecurityPolicyConfigurationUID
        WHERE (a.ForceNumberUsageFlag <> b.ForceNumberUsageFlag)      
		
		--ForceSpecialCharactersFlag
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
                @idfObjectTable_SecurityPolicy,
                51586990000056,
                a.SecurityPolicyConfigurationUID,
                NULL,
                b.ForceSpecialCharactersFlag,
                a.ForceSpecialCharactersFlag
        FROM @SecurityPolicyConfiguration_AfterEdit AS a
            FULL JOIN @SecurityPolicyConfiguration_BeforeEdit AS b
                ON a.SecurityPolicyConfigurationUID = b.SecurityPolicyConfigurationUID
        WHERE (a.ForceSpecialCharactersFlag <> b.ForceSpecialCharactersFlag)  

		--AllowUseOfSpaceFlag
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
                @idfObjectTable_SecurityPolicy,
                51586990000057,
                a.SecurityPolicyConfigurationUID,
                NULL,
                b.AllowUseOfSpaceFlag,
                a.AllowUseOfSpaceFlag
        FROM @SecurityPolicyConfiguration_AfterEdit AS a
            FULL JOIN @SecurityPolicyConfiguration_BeforeEdit AS b
                ON a.SecurityPolicyConfigurationUID = b.SecurityPolicyConfigurationUID
        WHERE (a.AllowUseOfSpaceFlag <> b.AllowUseOfSpaceFlag)  

		--PreventSequentialCharacterFlag
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
                @idfObjectTable_SecurityPolicy,
                51586990000058,
                a.SecurityPolicyConfigurationUID,
                NULL,
                b.PreventSequentialCharacterFlag,
                a.PreventSequentialCharacterFlag
        FROM @SecurityPolicyConfiguration_AfterEdit AS a
            FULL JOIN @SecurityPolicyConfiguration_BeforeEdit AS b
                ON a.SecurityPolicyConfigurationUID = b.SecurityPolicyConfigurationUID
        WHERE (a.PreventSequentialCharacterFlag <> b.PreventSequentialCharacterFlag)  

		--PreventUsernameUsageFlag
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
                @idfObjectTable_SecurityPolicy,
                51586990000059,
                a.SecurityPolicyConfigurationUID,
                NULL,
                b.PreventUsernameUsageFlag,
                a.PreventUsernameUsageFlag
        FROM @SecurityPolicyConfiguration_AfterEdit AS a
            FULL JOIN @SecurityPolicyConfiguration_BeforeEdit AS b
                ON a.SecurityPolicyConfigurationUID = b.SecurityPolicyConfigurationUID
        WHERE (a.PreventUsernameUsageFlag <> b.PreventUsernameUsageFlag)  

		--LockoutThld
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
                @idfObjectTable_SecurityPolicy,
                51586990000060,
                a.SecurityPolicyConfigurationUID,
                NULL,
                b.LockoutThld,
                a.LockoutThld
        FROM @SecurityPolicyConfiguration_AfterEdit AS a
            FULL JOIN @SecurityPolicyConfiguration_BeforeEdit AS b
                ON a.SecurityPolicyConfigurationUID = b.SecurityPolicyConfigurationUID
        WHERE (a.LockoutThld <> b.LockoutThld)  

		--LockoutDurationMinutes
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
                @idfObjectTable_SecurityPolicy,
                51586990000061,
                a.SecurityPolicyConfigurationUID,
                NULL,
                b.LockoutDurationMinutes,
                a.LockoutDurationMinutes
        FROM @SecurityPolicyConfiguration_AfterEdit AS a
            FULL JOIN @SecurityPolicyConfiguration_BeforeEdit AS b
                ON a.SecurityPolicyConfigurationUID = b.SecurityPolicyConfigurationUID
        WHERE (a.LockoutDurationMinutes <> b.LockoutDurationMinutes)  

		--MaxSessionLength
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
                @idfObjectTable_SecurityPolicy,
                51586990000062,
                a.SecurityPolicyConfigurationUID,
                NULL,
                b.MaxSessionLength,
                a.MaxSessionLength
        FROM @SecurityPolicyConfiguration_AfterEdit AS a
            FULL JOIN @SecurityPolicyConfiguration_BeforeEdit AS b
                ON a.SecurityPolicyConfigurationUID = b.SecurityPolicyConfigurationUID
        WHERE (a.MaxSessionLength <> b.MaxSessionLength)  

		--SesnIdleTimeoutWarnThldMins
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
                @idfObjectTable_SecurityPolicy,
                51586990000063,
                a.SecurityPolicyConfigurationUID,
                NULL,
                b.SesnIdleTimeoutWarnThldMins,
                a.SesnIdleTimeoutWarnThldMins
        FROM @SecurityPolicyConfiguration_AfterEdit AS a
            FULL JOIN @SecurityPolicyConfiguration_BeforeEdit AS b
                ON a.SecurityPolicyConfigurationUID = b.SecurityPolicyConfigurationUID
        WHERE (a.SesnIdleTimeoutWarnThldMins <> b.SesnIdleTimeoutWarnThldMins)  

			--SesnIdleCloseoutThldMins
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
                @idfObjectTable_SecurityPolicy,
                51586990000064,
                a.SecurityPolicyConfigurationUID,
                NULL,
                b.SesnIdleCloseoutThldMins,
                a.SesnIdleCloseoutThldMins
        FROM @SecurityPolicyConfiguration_AfterEdit AS a
            FULL JOIN @SecurityPolicyConfiguration_BeforeEdit AS b
                ON a.SecurityPolicyConfigurationUID = b.SecurityPolicyConfigurationUID
        WHERE (a.SesnIdleCloseoutThldMins <> b.SesnIdleCloseoutThldMins)  

			--SesnIdleCloseoutThldMins
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
                @idfObjectTable_SecurityPolicy,
                51586990000065,
                a.SecurityPolicyConfigurationUID,
                NULL,
                b.SesnInactivityTimeOutMins,
                a.SesnInactivityTimeOutMins
        FROM @SecurityPolicyConfiguration_AfterEdit AS a
            FULL JOIN @SecurityPolicyConfiguration_BeforeEdit AS b
                ON a.SecurityPolicyConfigurationUID = b.SecurityPolicyConfigurationUID
        WHERE (a.SesnInactivityTimeOutMins <> b.SesnInactivityTimeOutMins)  

           -- End data audit
    EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                    @EventTypeId,
                                    @EventUserId,
                                    @EventObjectId,
                                    @EventDiseaseId,
                                    @EventSiteId,
                                    @EventInformationString,
                                    @EventLoginSiteId,
                                    @EventLocationId,
                                    @AuditUserName;

    SELECT @ReturnCode 'ReturnCode',
           @ReturnMessage 'ReturnMessage';
END
