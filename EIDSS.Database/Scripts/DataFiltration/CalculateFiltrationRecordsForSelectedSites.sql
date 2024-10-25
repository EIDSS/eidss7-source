-- This script calculates filtration records for the data predefined from the outside of the procedure by means of adding to the temporary tables),
-- or that data which has been added or modified within specified date interval.
-- It is possible to process data from any of four modules: Human, Veterinary, VSS, BSS.
-- Number of new calculated filtration records that can be inserted to the database tables per script execution is limited by the specified maximum amount of records.
-- If it exceeds the maximum amount, then it will require several iterations of the script execution. 
-- In other words, this script may be executed several times until all missing filtration records will be inserted.

-- This script has a prerequisite: all bidirectional, unidirectional and border area rules shall be configured in advance.

set nocount on

-- Variables - start

-- Define whether data and/or list of sites for calculation has been predefined and added to the temporary tables from the outside
declare	@UsePredefinedData		bit = 0 -- 1 - data/sites are predefined from outside, 
										-- 0 - all data matching date criteria shall fall under calculation

-- Define modules which data you want to calculate
declare	@CalculateHumanData		bit = 1 -- 1 - calculate filtration records for human data, 
										-- 0 - skip calculation for human data

declare	@CalculateVetData		bit = 1 -- 1 - calculate filtration records for veterinary data, 
										-- 0 - skip calculation for veterinary data

declare	@CalculateVSSData		bit = 1 -- 1 - calculate filtration records for vector surveillance data, 
										-- 0 - skip calculation for vector surveillance data

declare	@CalculateBSSData		bit = 1 -- 1 - calculate filtration records for basic syndromic surveillance data, 
										-- 0 - skip calculation for basic syndromic surveillance data

declare	@ApplyCFRules			bit = 1 -- 1 - apply configurable filtration rules, 
										-- 0 - do not apply configurable filtration rules


-- Define start of the date interval for added or modified data that shall fall under calculation of filtration records
-- If start date is not specified or null is selected, then all data from the corresponding modules will fall under the calculation of the filtration records
declare	@StartDate				datetime

-- Define maximum number of new filtration records to be inserted during execution of the script
declare	@MaxNumberOfNewFiltrationRecords	int = 1000000

-- Define maximum number of the objects from any module to be processed during execution of the script
declare	@MaxNumberOfProcessedObjects	int = 1000000

-- Variables - end


exec [dbo].[DF_CalculateRecords_All] 
	@UsePredefinedData=@UsePredefinedData,
	@StartDate=@StartDate,
	@MaxNumberOfProcessedObjects=@MaxNumberOfProcessedObjects,
	@MaxNumberOfNewFiltrationRecords=@MaxNumberOfNewFiltrationRecords,
	@CalculateHumanData=@CalculateHumanData,
	@CalculateVetData=@CalculateVetData,
	@CalculateVSSData=@CalculateVSSData,
	@CalculateBSSData=@CalculateBSSData,
	@ApplyCFRules=@ApplyCFRules

set nocount off

