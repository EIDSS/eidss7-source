--*************************************************************
-- Name 				: USSP_HUMAN_DISEASE_ANTIVIRALTHERAPIES_SET
-- Description			: add update Human Disease Report Antiviral Therapies
--          
-- Author               : HAP
-- Revision History
--		Name		Date       Change Detail
-- ---------------- ---------- --------------------------------
-- HAP				20190104     Created
-- HAP				20190109    Update delete of temp table
--
-- Testing code:
-- exec USSP_HUMAN_DISEASE_ANTIVIRALTHERAPIES_SET null
--*************************************************************
CREATE PROCEDURE [dbo].[USSP_HUMAN_DISEASE_ANTIVIRALTHERAPIES_SET]
    @idfHumanCase						BIGINT = NULL,
	@AntiviralTherapiesParameters		NVARCHAR(MAX) = NULL,
	@outbreakCall						INT = 0,
	@User								NVARCHAR(100) = ''
AS
Begin
	SET NOCOUNT ON;
		Declare @SupressSelect table
			( retrunCode int,
			  returnMessage varchar(200)
			)
	DECLARE
	@idfAntimicrobialTherapy			BIGINT = NULL,
	@datFirstAdministeredDate			DATETIME2 = NULL,
	@strAntimicrobialTherapyName	    NVARCHAR(200),
	@strDosage							NVARCHAR(200),
	@RowAction							NVARCHAR(1),
	@intRowStatus						INT = 0

	DECLARE @returnCode	INT = 0;
	DECLARE	@returnMsg	NVARCHAR(MAX) = 'SUCCESS';

	DECLARE  @AntiviralTherapiesTemp TABLE (				
					idfAntimicrobialTherapy				BIGINT NULL, 
					 idfHumanCase						BIGINT NULL, 
					 datFirstAdministeredDate			DATETIME2 NULL,
					 strAntimicrobialTherapyName	    NVARCHAR(200) NULL,
					 strDosage							NVARCHAR(200) NULL,
					 RowAction							NVARCHAR NULL
			)


	INSERT INTO	@AntiviralTherapiesTemp 
	SELECT * FROM OPENJSON(@AntiviralTherapiesParameters) 
			WITH (
					idfAntimicrobialTherapy				BIGINT, 
					 idfHumanCase						BIGINT, 
					 datFirstAdministeredDate			DATETIME2,
					 strAntimicrobialTherapyName	    NVARCHAR(200),
					 strDosage							NVARCHAR(200),
					 RowAction							NVARCHAR(1)
				);

	BEGIN TRY  
		WHILE EXISTS (SELECT * FROM @AntiviralTherapiesTemp)
			BEGIN
				SELECT TOP 1
					@idfAntimicrobialTherapy		= idfAntimicrobialTherapy,
					@datFirstAdministeredDate		= datFirstAdministeredDate,
					@strAntimicrobialTherapyName	= strAntimicrobialTherapyName,
					@strDosage						= strDosage,
					@RowAction						= RowAction
				FROM @AntiviralTherapiesTemp


		IF NOT EXISTS(SELECT TOP 1 idfAntimicrobialTherapy FROM tlbAntimicrobialTherapy WHERE idfAntimicrobialTherapy = @idfAntimicrobialTherapy)
			BEGIN
				IF @outbreakCall = 1
					BEGIN
						EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbAntimicrobialTherapy',  @idfAntimicrobialTherapy OUTPUT;
					END
				ELSE
					BEGIN
						INSERT INTO @SupressSelect
						EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbAntimicrobialTherapy',  @idfAntimicrobialTherapy OUTPUT;
					END

				INSERT 
					INTO	dbo.tlbAntimicrobialTherapy
							(							
								idfAntimicrobialTherapy,
								idfHumanCase,
								datFirstAdministeredDate,
								strAntimicrobialTherapyName,
								strDosage,
								intRowStatus,
								AuditCreateUser,
								AuditCreateDTM
							)
					VALUES (
								@idfAntimicrobialTherapy,
								@idfHumanCase,
								@datFirstAdministeredDate,
								@strAntimicrobialTherapyName,
								@strDosage,
								0,
								@User,
								GETDATE()				
					);
			END
		ELSE
			BEGIN

				IF @RowAction = 'D' 
					BEGIN
						SET @intRowStatus = 1
					END
				ELSE
					BEGIN
						SET @intRowStatus = 0
					END
				
				UPDATE dbo.tlbAntimicrobialTherapy
					SET			
							 idfHumanCase					= @idfHumanCase,
							 datFirstAdministeredDate		= @datFirstAdministeredDate,
							 strAntimicrobialTherapyName	= @strAntimicrobialTherapyName,				
							 strDosage						= @strDosage,
							 intRowStatus					= @intRowStatus,
							 AuditUpdateUser				= @User,
							 AuditUpdateDTM					= GETDATE()

					WHERE	idfAntimicrobialTherapy = @idfAntimicrobialTherapy
					AND		intRowStatus = 0
			END

			SET ROWCOUNT 1
					DELETE FROM @AntiviralTherapiesTemp
					SET ROWCOUNT 0

		END

	END TRY
	BEGIN CATCH
		THROW;
		
	END CATCH
END
