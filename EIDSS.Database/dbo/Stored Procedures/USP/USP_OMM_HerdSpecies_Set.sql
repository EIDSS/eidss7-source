
--*************************************************************
-- Name: [USP_OMM_HerdSpecies_Set]
-- Description: Insert/Update for Outbreak Case
--          
-- Author: Doug Albanese
-- Revision History
--		Name       Date       Change Detail
--    
--*************************************************************
CREATE PROCEDURE [dbo].[USP_OMM_HerdSpecies_Set]
(    
	@LangID										NVARCHAR(50),
	@idfFarmActual								BIGINT,
	@Herds										NVARCHAR(MAX),
	@Species									NVARCHAR(MAX)
)
AS

BEGIN    

	DECLARE	@returnCode						INT = 0;
	DECLARE @returnMsg						NVARCHAR(MAX) = 'SUCCESS';

	BEGIN TRY
		--Prep json passed Herds
		DECLARE  @herdListing TABLE (
			idfHerdActual					BIGINT,
			strHerdCode						NVARCHAR(200),
			intRowStatus					BIGINT NULL,
			intTotalAnimalQty				BIGINT NULL,
			intDeadAnimalQty				BIGINT NULL,
			intSickAnimalQty				BIGINT NULL
		)

		INSERT INTO @herdListing 
		SELECT 
			* 
		FROM OPENJSON(@Herds) 
		WITH (
			idfHerdActual					BIGINT, 
			strHerdCode						NVARCHAR(200), 
			intRowStatus					BIGINT,
			intTotalAnimalQty				BIGINT, 
			intDeadAnimalQty				BIGINT, 
			intSickAnimalQty				BIGINT
		) 

		--Prep json passed Species
		DECLARE  @speciesListing TABLE (
			idfHerdActual					BIGINT,
			idfSpeciesActual				BIGINT NULL,
			idfsSpeciesType					BIGINT NULL,
			intTotalAnimalQty				BIGINT NULL,
			intDeadAnimalQty				BIGINT NULL,
			intSickAnimalQty				BIGINT NULL,
			datStartOfSignsDate				DATETIME2 NULL,
			strNote							NVARCHAR(200),
			intRowStatus					BIGINT NULL
		)

		INSERT INTO @speciesListing 
		SELECT 
			* 
		FROM OPENJSON(@Species) 
		WITH (
			idfHerdActual					BIGINT,
			idfSpeciesActual				BIGINT,
			idfsSpeciesType					BIGINT,
			intTotalAnimalQty				BIGINT,
			intDeadAnimalQty				BIGINT,
			intSickAnimalQty				BIGINT,
			datStartOfSignsDate				DATETIME2,
			strNote							NVARCHAR(200),
			intRowStatus					BIGINT
		)

		Declare @SupressSelect table
		( retrunCode int,
			returnMsg varchar(200)
		)

		DECLARE @idfActual					BIGINT
		DECLARE @idfHerdActual				BIGINT
		DECLARE @strHerdCode				VARCHAR(200)
		DECLARE @intRowStatus				BIGINT
		DECLARE @intTotalAnimalQty			INT
		DECLARE @intDeadAnimalQty			INT
		DECLARE @intSickAnimalQty			INT

		WHILE (SELECT COUNT(idfHerdActual) FROM @herdListing) > 0  
			BEGIN
				--Determine if the herd is a new record
				SELECT	
						TOP 1	
						@idfActual = idfHerdActual,
						@strHerdCode = strHerdCode,
						@intRowStatus = intRowStatus,
						@intTotalAnimalQty = intTotalAnimalQty,
						@intDeadAnimalQty = intDeadAnimalQty,
						@intSickAnimalQty = intSickAnimalQty

				FROM	
						@herdListing

				--If the value is less than zero, then it is a new record.
				--Update the source of json coming through and insert a new record to the tblHerdActual table
				IF @idfActual < 0
					BEGIN
						INSERT INTO @SupressSelect
						EXEC	dbo.USP_GBL_NEXTKEYID_GET 'tlbHerdActual', @idfHerdActual OUTPUT;

						INSERT INTO @SupressSelect
						EXEC	dbo.USP_GBL_NextNumber_GET 'Animal Group', @strHerdCode OUTPUT , NULL;

						--Update source to replace new records (ids less than zero) with proper ids
						UPDATE
									@herdListing
						SET
									idfHerdActual = @idfHerdActual,
									strHerdCode = @strHerdCode
						WHERE
									idfHerdActual = @idfActual

						UPDATE
									@SpeciesListing
						SET
									idfHerdActual = @idfHerdActual
						WHERE
									idfHerdActual = @idfActual
						
						--Insert a new record for the Herd
						INSERT INTO tlbHerdActual (idfHerdActual, idfFarmActual, strHerdCode, intRowStatus, intSickAnimalQty, intTotalAnimalQty, intDeadAnimalQty)
						VALUES (@idfHerdActual, @idfFarmActual, @strHerdCode, @intRowStatus, @intSickAnimalQty, @intTotalAnimalQty, @intDeadAnimalQty)
					END
				ELSE
					BEGIN
						--Record alrady exists, so update it.
						UPDATE
									tlbHerdActual
						SET
									intTotalAnimalQty = @intTotalAnimalQty,
									intDeadAnimalQty = @intDeadAnimalQty,
									intSickAnimalQty = @intSickAnimalQty,
									intRowStatus = @intRowStatus
						WHERE
									idfHerdActual = @idfActual

						SET @idfHerdActual = @idfActual

					END

				DELETE	
				FROM 
							@herdListing
				WHERE
							idfHerdActual = @idfHerdActual
			END
			
		DECLARE @idfSpeciesActual		BIGINT
		DECLARE @idfsSpeciesType		BIGINT
		DECLARE @datStartOfSignsDate	DATETIME
		DECLARE @strNote				NVARCHAR(200)

		WHILE (SELECT COUNT(idfSpeciesActual) FROM @speciesListing) > 0
			BEGIN
				--Determine if the species is a new record
				SELECT	
						TOP 1	
						@idfActual = idfSpeciesActual,
						@idfsSpeciesType = idfsSpeciesType,
						@idfHerdActual = @idfHerdActual,
						@datStartOfSignsDate = datStartOfSignsDate,
						@intTotalAnimalQty = intTotalAnimalQty,
						@intDeadAnimalQty = intDeadAnimalQty,
						@intSickAnimalQty = intSickAnimalQty,
						@strNote = strNote,
						@intRowStatus = intRowStatus
				FROM	
						@speciesListing
						
				IF @idfActual < 0
					BEGIN
						EXEC	dbo.USP_GBL_NEXTKEYID_GET 'tlbSpeciesActual', @idfSpeciesActual OUTPUT;

						--Update source to replace new records (ids less than zero) with proper ids
						UPDATE
									@speciesListing
						SET
									idfSpeciesActual  = @idfSpeciesActual
						WHERE
									idfSpeciesActual = @idfActual

						--Insert a new record for the Species
						INSERT INTO tlbSpeciesActual (idfSpeciesActual, idfsSpeciesType, idfHerdActual, datStartOfSignsDate, intSickAnimalQty, intDeadAnimalQty, intTotalAnimalQty, strNote, intRowStatus)
						VALUES (@idfSpeciesActual, @idfsSpeciesType, @idfHerdActual, @datStartOfSignsDate, @intSickAnimalQty, @intDeadAnimalQty, @intTotalAnimalQty, @strNote, @intRowStatus)
					END
			ELSE
				BEGIN
					--Record already exists, so update it.
					UPDATE
								tlbSpeciesActual
					SET
								idfsSpeciesType = @idfsSpeciesType, 
								datStartOfSignsDate = @datStartOfSignsDate, 
								intSickAnimalQty = @intSickAnimalQty, 
								intDeadAnimalQty = @intDeadAnimalQty, 
								intTotalAnimalQty = @intTotalAnimalQty, 
								strNote = @strNote,
								intRowStatus = @intRowStatus
					WHERE
								idfSpeciesActual = @idfActual

					SET @idfSpeciesActual = @idfActual
				END

				DELETE	
				FROM 
							@speciesListing
				WHERE
							idfSpeciesActual = @idfSpeciesActual
			END

		--select * from @speciesListing

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT = 1 
			ROLLBACK;
		;throw;
	END CATCH

	SELECT	@returnCode as returnCode, @returnMsg as returnMsg
	
END
