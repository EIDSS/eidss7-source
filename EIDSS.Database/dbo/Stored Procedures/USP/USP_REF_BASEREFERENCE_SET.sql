-- ================================================================================================
-- Name: USP_REF_BASEREFERENCE_SET
--
-- Description:	Creates or saves a base reference
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		02/10/2018 Initial release.
-- Ricky Moss		02/19/2018 Updated the portion of the query to see if there reference 
--                             currently exists
-- Ricky Moss		09/30/2019 Reference duplicate check
-- Ann Xiong		11/20/2020 Modified to insert strName in trtStringNameTranslation
-- Mark Wilson		06/17/2021 Updated to check for dupes, etc.
-- Mark Wilson		07/07/2021 updated to use FN_GBL_LanguageCode_GET()
-- Mark Wilson		08/13/2021 updated to remove strDefault from USSP_GBL_StringTranslation_SET
-- Stephen Long     07/16/2022 Added site alert logic.
-- Doug Albanese	11/30/2022 Added LOINC
--
-- exec USP_REF_BASEREFERENCE_SET NULL, 19000005, 'en-US', 'ABCDEFGhij', 'ABC123', 32, 0
-- exec USP_REF_BASEREFERENCE_SET 389445040004019, 19000005, 'ka-GE', 'ABCDEFGhij', 'ABC123GG to ka', 34, 1
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_BASEREFERENCE_SET] 
   @idfsBaseReference BIGINT = NULL
   ,@idfsReferenceType BIGINT
   ,@LangID NVARCHAR(50)
   ,@strDefault VARCHAR(200)
   ,@strName NVARCHAR(200)
   ,@HACode INT = NULL
   ,@Order INT = NULL
   ,@EventTypeId BIGINT
   ,@SiteId BIGINT
   ,@UserId BIGINT
   ,@LocationId BIGINT
   ,@AuditUserName NVARCHAR(200)
   ,@LOINC NVARCHAR(200) = NULL
AS
BEGIN
	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS'
		,@ReturnCode BIGINT = 0
		,@DuplicateDefault INT = 0
		,-- updated to capture 0 or 1. 1 indicates a duplicate and will not execute the set.
		@idfCustomizationPackage BIGINT
		,@idfsLanguage BIGINT = (
			SELECT dbo.FN_GBL_LanguageCode_GET(@LangID)
			);-- capture the idfsLanguage for the translation
	DECLARE @SuppressSelect TABLE (
		ReturnCode INT
		,ReturnMessage NVARCHAR(MAX)
		);
		
declare @idfUserId BIGINT =NULL;
declare @idfSiteId BIGINT = NULL;
declare @idfsDataAuditEventType bigint;
declare @idfsObjectType bigint = 10017042;
declare @idfObject bigint;
declare @idfObjectTable_tlbTestMatrix bigint = 75820000000;
declare @idfDataAuditEvent bigint= NULL; 
DECLARE @tlbBaseReference_BeforeEdit TABLE
(
	idfsBaseReference BIGINT
	,idfsReferenceType BIGINT 
	,strDefault VARCHAR(200) 
	,HACode INT
	,[Order] INT
	,intRowStatus INT
)
DECLARE @tlbBaseReference_AfterEdit TABLE
(
	idfsBaseReference BIGINT
	,idfsReferenceType BIGINT 
	,strDefault VARCHAR(200) 
	,HACode INT
	,[Order] INT
	,intRowStatus INT
)
-- Get and Set UserId and SiteId
select @idfUserId =userInfo.UserId, @idfSiteId=UserInfo.SiteId from dbo.FN_UserSiteInformation(@AuditUserName) userInfo

	BEGIN TRY
		IF @idfsBaseReference IS NULL
		BEGIN -- this is an insert.  check if the strDefault is a duplicate
			IF EXISTS (
					SELECT *
					FROM dbo.trtBaseReference
					WHERE strDefault = @strDefault
						AND idfsReferenceType = @idfsReferenceType
						AND trtBaseReference.intRowStatus = 0
					)
			BEGIN
				SELECT @ReturnMessage = 'DOES EXIST';

				SELECT @DuplicateDefault = 1
			END
		END
		ELSE
		BEGIN -- this is an update.  check if the strDefault is a duplicate
			IF EXISTS (
					SELECT *
					FROM dbo.trtBaseReference
					WHERE idfsBaseReference <> @idfsBaseReference -- check all the other strDefaults of that reference type
						AND strDefault = @strDefault
						AND idfsReferenceType = @idfsReferenceType
						AND trtBaseReference.intRowStatus = 0
					)
			BEGIN
				SELECT @ReturnMessage = 'DOES EXIST';

				SELECT @DuplicateDefault = 1
			END
		END

		IF @DuplicateDefault = 1 -- No need to go any further, as the strDefault is a duplicate
		BEGIN
			SELECT @ReturnMessage = 'DOES EXIST';
		END
		ELSE
		BEGIN
			IF @idfsBaseReference IS NULL -- there is no duplicate and this is an insert
			BEGIN
				INSERT INTO @SuppressSelect
				EXEC dbo.USP_GBL_NEXTKEYID_GET 'trtBaseReference'
					,@idfsBaseReference OUTPUT;

				INSERT INTO dbo.trtBaseReference (
					idfsBaseReference
					,idfsReferenceType
					,intHACode
					,strDefault
					,intOrder
					,rowguid
					,intRowStatus
					,SourceSystemNameID
					,SourceSystemKeyValue
					,AuditCreateDTM
					,AuditCreateUser
					)
				VALUES (
					@idfsBaseReference
					,@idfsReferenceType
					,@HACode
					,@strDefault
					,@Order
					,NEWID()
					,0
					,10519001
					,'[{"idfsBaseReference":' + CAST(@idfsBaseReference AS NVARCHAR(300)) + '}]'
					,GETDATE()
					,@AuditUserName
					);

				EXEC dbo.USSP_GBL_StringTranslation_SET @idfsBaseReference
					,@LangID
					,@strName
					,@User = @AuditUserName;

				SELECT @idfCustomizationPackage = dbo.FN_GBL_CustomizationPackage_GET();

				IF @idfCustomizationPackage IS NOT NULL
					AND @idfCustomizationPackage <> 51577300000000 --The USA
				BEGIN
					EXEC dbo.USP_GBL_BaseReferenceToCP_SET @idfsBaseReference
						,@idfCustomizationPackage
						,@User = @AuditUserName;
				END

				INSERT INTO @SuppressSelect
				EXECUTE dbo.USP_ADMIN_EVENT_SET - 1
					,@EventTypeId
					,@UserId
					,@idfsBaseReference
					,NULL
					,@SiteId
					,NULL
					,@SiteId
					,@LocationId
					,@AuditUserName;

					
				--Data Audit--
				-- tauDataAuditEvent Event Type - Create 
				set @idfObject = @idfsBaseReference;
				set @idfObjectTable_tlbTestMatrix =76020000000;
				set @idfsDataAuditEventType =10016001;
						-- insert record into tauDataAuditEvent - 
				INSERT INTO @SuppressSelect
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable_tlbTestMatrix, @idfDataAuditEvent OUTPUT

				INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject)
					values ( @idfDataAuditEvent, @idfObjectTable_tlbTestMatrix, @idfObject)
				--Data Audit--
			END
			ELSE -- There is no duplicate and this is an update
			BEGIN		
				insert into @tlbBaseReference_BeforeEdit (idfsBaseReference,idfsReferenceType, strDefault, HACode, [Order], intRowStatus)
				select idfsBaseReference,idfsReferenceType, strDefault, intHACode, intOrder, intRowStatus
					from trtBaseReference WHERE idfsBaseReference = @idfsBaseReference

				UPDATE dbo.trtBaseReference
				SET idfsReferenceType = @idfsReferenceType
					,strDefault = @strDefault
					,intHACode = ISNULL(@HACode, intHACode)
					,intOrder = ISNULL(@Order, intOrder)
					,intRowStatus = 0
					,SourceSystemNameID = ISNULL(SourceSystemNameID, 10519001)
					,SourceSystemKeyValue = '[{"idfsBaseReference":' + CAST(@idfsBaseReference AS NVARCHAR(300)) + '}]'
					,AuditUpdateDTM = GETDATE()
					,AuditUpdateUser = @AuditUserName
				WHERE idfsBaseReference = @idfsBaseReference;

				EXEC dbo.USSP_GBL_StringTranslation_SET @idfsBaseReference
					,@LangID
					,@strName
					,@User = @AuditUserName;

				INSERT INTO @SuppressSelect
				EXECUTE dbo.USP_ADMIN_EVENT_SET - 1
					,@EventTypeId
					,@UserId
					,@idfsBaseReference
					,NULL
					,@SiteId
					,NULL
					,@SiteId
					,@LocationId
					,@AuditUserName;

				--DataAudit-- 
				insert into @tlbBaseReference_AfterEdit (idfsBaseReference,idfsReferenceType, strDefault, HACode, [Order], intRowStatus)
				select idfsBaseReference,idfsReferenceType, strDefault, intHACode, intOrder, intRowStatus
					from trtBaseReference WHERE idfsBaseReference = @idfsBaseReference

				IF EXISTS 
				(
					select *
					from @tlbBaseReference_BeforeEdit a  inner join @tlbBaseReference_AfterEdit b on a.idfsBaseReference = b.idfsBaseReference
					where (ISNULL(a.idfsReferenceType,'') <> ISNULL(b.idfsReferenceType,'')) OR (ISNULL(a.strDefault,'') <> ISNULL(b.strDefault,''))
						OR (ISNULL(a.HACode,'') <> ISNULL(b.HACode,'')) OR (ISNULL(a.[Order],'') <> ISNULL(b.[Order],'')) OR (ISNULL(a.intRowStatus,'') <> ISNULL(b.intRowStatus,''))
				)
				BEGIN
					--  tauDataAuditEvent  Event Type- Edit 
					set @idfsDataAuditEventType = 10016003;
					Set @idfObject = @idfsBaseReference
					-- insert record into tauDataAuditEvent - 
					INSERT INTO @SuppressSelect
					EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable_tlbTestMatrix, @idfDataAuditEvent OUTPUT

					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, idfObjectTable, idfColumn, 
						idfObject, idfObjectDetail, 
						strOldValue, strNewValue)
					select @idfDataAuditEvent,@idfObjectTable_tlbTestMatrix, 81080000000,
						@idfObject,null,
						a.idfsReferenceType,b.idfsReferenceType 
					from @tlbBaseReference_BeforeEdit a  inner join @tlbBaseReference_AfterEdit b on a.idfsBaseReference = b.idfsBaseReference
					where (ISNULL(a.idfsReferenceType,'') <> ISNULL(b.idfsReferenceType,'')) 

					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, idfObjectTable, idfColumn, 
						idfObject, idfObjectDetail, 
						strOldValue, strNewValue)
					select @idfDataAuditEvent,@idfObjectTable_tlbTestMatrix, 81120000000,
						@idfObject,null,
						a.strDefault,b.strDefault 
					from @tlbBaseReference_BeforeEdit a  inner join @tlbBaseReference_AfterEdit b on a.idfsBaseReference = b.idfsBaseReference
					where (ISNULL(a.strDefault,'') <> ISNULL(b.strDefault,'')) 

					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, idfObjectTable, idfColumn, 
						idfObject, idfObjectDetail, 
						strOldValue, strNewValue)
					select @idfDataAuditEvent,@idfObjectTable_tlbTestMatrix, 81090000000,
						@idfObject,null,
						a.HACode,b.HACode 
					from @tlbBaseReference_BeforeEdit a  inner join @tlbBaseReference_AfterEdit b on a.idfsBaseReference = b.idfsBaseReference
					where (ISNULL(a.HACode,'') <> ISNULL(b.HACode,'')) 

					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, idfObjectTable, idfColumn, 
						idfObject, idfObjectDetail, 
						strOldValue, strNewValue)
					select @idfDataAuditEvent,@idfObjectTable_tlbTestMatrix, 81100000000,
						@idfObject,null,
						a.[Order],b.[Order] 
					from @tlbBaseReference_BeforeEdit a  inner join @tlbBaseReference_AfterEdit b on a.idfsBaseReference = b.idfsBaseReference
					where (ISNULL(a.[Order],'') <> ISNULL(b.[Order],''))  
				END
			END
		END

		 --Adding new feature to the Base Reference Editor
		 --LOINC saving to remote mapping table: LOINCEidssMapping
		 IF EXISTS (
				  SELECT *
				  FROM dbo.LOINCEidssMapping
				  WHERE idfsBaseReference = @idfsBaseReference
		 )
			BEGIN
				  UPDATE dbo.LOINCEidssMapping
				  SET LOINC_NUM = @LOINC
					 ,AuditUpdateDTM = GETDATE()
					 ,AuditUpdateUser = @AuditUserName
					 ,intRowStatus = 0
					 ,SourceSystemKeyValue = N'[{"idfsBaseReference":' + CAST(@idfsBaseReference AS NVARCHAR(300)) + '}]'
				  WHERE idfsBaseReference = @idfsBaseReference;
			END
		 ELSE
			BEGIN
				  IF @LOINC <> ''
					 BEGIN
						INSERT INTO dbo.LOINCEidssMapping (
						   idfsBaseReference
						   ,idfsReferenceType
						   ,LOINC_NUM
						   ,intRowStatus
						   ,rowguid
						   ,SourceSystemNameID
						   ,SourceSystemKeyValue
						   ,AuditCreateUser
						   ,AuditCreateDTM
						   )
						VALUES (
						   @idfsBaseReference,
						   @idfsReferenceType,
						   @LOINC,
						   0,
						   NEWID(),
						   10519001,
						   N'[{"idfsBaseReference":' + CAST(@idfsBaseReference AS NVARCHAR(300)) + '}]',
						   @AuditUserName,
						   GETDATE()
						);
					 END
			END

	  	 SELECT @ReturnCode AS 'ReturnCode'
		 ,@ReturnMessage AS 'ReturnMessage'
		 ,@idfsBaseReference AS 'idfsBaseReference';

	END TRY
	BEGIN CATCH
		THROW;
	END CATCH;
END