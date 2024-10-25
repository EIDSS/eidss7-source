--*************************************************************
-- Name 				: USP_ADMIN_STAT_GETCOUNT
-- Description			: Returns a number of statistical data records that 
--          
-- Author               : Ricky Moss
--
-- Revision History
-- Name				Date		Change Detail
-- Ricky Moss		11/15/2019	Initial Release
-- Ricky Moss	    01/21/2020	Added Region and Rayon fields to search
-- Ricky Moss	    03/19/2020  Added Settlement fields to search
--
-- Testing code:
-- execute USP_ADMIN_STAT_GETCOUNT 'en', null, null, '01/01/2000', '01/01/2020', null, null, null
--*************************************************************

CREATE PROCEDURE	[dbo].[USP_ADMIN_STAT_GETCOUNT]
(
  @LangID						NVARCHAR(50)--##PARAM @LangID - language ID
 ,@idfsStatisticalDataType		BIGINT = NULL
 ,@idfsArea						BIGINT = NULL
 ,@datStatisticStartDateFrom	DATETIME = NULL
 ,@datStatisticStartDateTo		DATETIME = NULL
 ,@idfsRegion					BIGINT = NULL
 ,@idfsRayon					BIGINT = NULL
 ,@idfsSettlement				BIGINT = NULL
)

AS
BEGIN	
	BEGIN TRY
		 SELECT COUNT(*) AS StatisticalDataCount
						  FROM   FN_ADMIN_STAT_GetList(@LangID) 			
						  WHERE  ISNULL(idfsStatisticDataType, '') = IIF(@idfsStatisticalDataType IS NOT NULL,  @idfsStatisticalDataType, ISNULL(idfsStatisticDataType, ''))
							AND  ISNULL(idfsArea, '') = IIF(@idfsArea IS NOT NULL, @idfsArea, ISNULL(idfsArea, '')) 
							AND datStatisticStartDate BETWEEN @datStatisticStartDateFrom AND @datStatisticStartDateTo
							AND ISNULL(idfsRegion, '') = IIF(@idfsRegion IS NOT NULL, @idfsRegion, ISNULL(idfsRegion, ''))
							AND ISNULL(idfsRayon, '') = IIF(@idfsRayon IS NOT NULL, @idfsRayon, ISNULL(idfsRayon, ''))
							AND ISNULL(idfsSettlement, '') = IIF(@idfsSettlement IS NOT NULL, @idfsSettlement, ISNULL(idfsSettlement, ''))
	END TRY  

	BEGIN CATCH 
			THROW
	END CATCH;
END
