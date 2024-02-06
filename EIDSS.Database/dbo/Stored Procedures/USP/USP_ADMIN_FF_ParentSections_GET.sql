

-- ================================================================================================
-- Name: USP_ADMIN_FF_ParentSections_GET
-- Description: Gets all sections and parent sections for the given idfsSection. 
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Kishore Kodru    1/2/2019 Initial release for new API.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_ParentSections_GET] 
(
		@idfsSection BIGINT = NULL,
		@LangID NVARCHAR(50) = NULL,
		@SectionIDs NVARCHAR(MAX) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	--declare @idfsSection Bigint = 9887130000000
	--declare @LangID varchar(50) = 'en'

	BEGIN TRY
		If (@LangID Is Null) 
		Set @LangID = 'en';

		DECLARE @sectionIdTable TABLE
		(
			[num] BIGINT,
			[value] BIGINT
		)

		DECLARE @ResultTable Table
		(
			[SectionName] Nvarchar(Max), 
			[SectionID] BigInt,
			[Order] int 
		)
	
		DECLARE @idfsParentSection BIGINT,  
				@DefaultName NVARCHAR(MAX), 
				@NationalName NVARCHAR(MAX), 
				@Order INT = 1,
				@SectionName NVARCHAR(MAX),
				@SectionID BIGINT
		
		IF @idfsSection IS NOT NULL
			BEGIN
				INSERT INTO @sectionIdTable ([num],[value]) VALUES (@idfsSection,@idfsSection)
			END
		ELSE
			BEGIN
				INSERT INTO @sectionIdTable ([num],[value]) SELECT CAST([num] AS BIGINT), CAST([value] AS BIGINT) FROM FN_GBL_SYS_SplitList(@SectionIDs,1,',')
			END
		
		WHILE ((SELECT COUNT(*) FROM @sectionIdTable) > 0)
			BEGIN
				SELECT TOP 1 @idfsSection = [value] FROM @sectionIdTable

				DELETE FROM @sectionIdTable
				WHERE [value] = @idfsSection

				-- master query 	
				SELECT @idfsParentSection = S.idfsParentSection,  
						@DefaultName = RF.strDefault, 
						@NationalName = RF.[name]
				FROM dbo.ffSection S 
				Inner Join dbo.fnReference(@LangID, 19000101/*'rftSection'*/) RF 
				ON S.idfsSection = RF.idfsReference
				WHERE S.idfsSection = @idfsSection
				AND S.intRowStatus = 0
				
				IF @idfsParentSection IS NOT NULL 
					BEGIN
						SET @Order = 1
						WHILE (@idfsParentSection IS NOT NULL)
							BEGIN
				
								-- refinding the @idfsParentSection so to check if it is null or not 
								SELECT @idfsParentSection = S.idfsParentSection,  
										@DefaultName = RF.strDefault, 
										@NationalName = RF.[name],
										@idfsSection = S.idfsSection
								FROM dbo.ffSection S 
								Inner Join dbo.fnReference(@LangID, 19000101/*'rftSection'*/) RF 
								ON S.idfsSection = RF.idfsReference
								WHERE S.idfsSection = @idfsSection
								AND S.intRowStatus = 0
	
								SELECT @SectionName = ISNULL(@NationalName, @DefaultName), 
										@SectionID = @idfsSection;

								INSERT INTO @ResultTable
								(
									SectionName,
									SectionID,
									[Order]
								)
								VALUES
								(
									@SectionName,
									@SectionID,
									@Order
								)

								--PRINT @SectionName 
								--PRINT @SectionID
								--PRINT @Order 

								SET @idfsSection = @idfsParentSection 
								SET @Order = @Order + 1

							END			
					END
				ELSE
					BEGIN
					
						SELECT @SectionName = ISNULL(@NationalName, @DefaultName), 
								@SectionID = @idfsSection;
     
						INSERT INTO @ResultTable
						(
							SectionName,
							SectionID,
							[Order]
						)
						VALUES
						(
							@SectionName,
							@SectionID,
							@Order
						)

						--PRINT @SectionName 
						--PRINT @SectionID
						--PRINT @Order 

					END


			END

		SELECT DISTINCT * 
		FROM @ResultTable
		ORDER BY [Order] DESC
		-- Order by is a important statement, it is ordered by highest level section first and then child sections. 


	END TRY
	BEGIN CATCH
		--IF @@TRANCOUNT > 0 
		--	ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END

