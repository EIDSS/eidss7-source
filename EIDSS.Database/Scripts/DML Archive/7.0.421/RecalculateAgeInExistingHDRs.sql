SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--##SUMMARY Returns the difference between specified Start Date and End Date in specified units (1 - years, 2 - months, 3 - days).
--##SUMMARY If units are not specified or incorrect, the function returns the difference between days in Years units.
--##SUMMARY If at least of one start or end dates is not specified, the function returns -1000000.

--##REMARKS Author: Olga Mirnaya.
--##REMARKS Create date: 18.08.2015

--##RETURNS Returns int value


/*
--Example of function call:
SELECT dbo.fnExactDateDiff(1, '20120915', '20100101')
SELECT dbo.fnExactDateDiff(1, '20090915', '20100101')
SELECT dbo.fnExactDateDiff(2, '20091001', '20100101')
SELECT dbo.fnExactDateDiff(2, '20091215', '20100101')

*/

CREATE OR ALTER    function [dbo].[fnExactDateDiff]
		(	@DateUnit int,			--##PARAM @DateUnit unit for calulating difference between dates
			@StartDate datetime,	--##PARAM @StartDate start date for calulating difference between dates
			@EndDate datetime		--##PARAM @DateUnit end date for calulating difference between dates
		)
returns int
as
begin

	declare	@diff	int
	if	@StartDate is null or @EndDate is null
		set	@diff = -1000000
	else begin

		declare	@ChangeDateValue datetime
		declare	@StartEndDatesSgn	int = 1
		
		if	@StartDate > @EndDate
		begin
			set	@StartEndDatesSgn = -1

			set	@ChangeDateValue = @EndDate
			set	@EndDate = @StartDate
			set	@StartDate = @ChangeDateValue
		end

		declare	@ddStart int = day(@StartDate)
		declare	@mmStart int = month(@StartDate)
        declare @yyyyStart int = year(@StartDate)

		declare	@ddEnd int = day(@EndDate)
		declare	@mmEnd int = month(@EndDate)
        declare @yyyyEnd int = year(@EndDate)

		declare	@ChangeIntValue int


        if (@ddEnd <= 0) or (@ddStart <= 0) or (@mmEnd <= 0) or (@mmStart <= 0) or (@yyyyEnd <= 0) or (@yyyyStart <= 0)
			set	@diff = -1000000
		else begin
			set	@diff = -1000000

            declare	@sgnY int = 1
            declare	@sgnM int = 1
            declare	@sgnD int = 1

            if (@yyyyEnd < @yyyyStart)
            begin
                set	@sgnY = @sgnY * (-1)
				
				set	@ChangeIntValue = @yyyyEnd
				set	@yyyyEnd = @yyyyStart
				set	@yyyyStart = @ChangeIntValue
            end
            else if (@yyyyEnd = @yyyyStart)
            begin
                set	@sgnY = 0
            end

            if (@mmEnd < @mmStart)
            begin
                set	@sgnM = @sgnM * (-1)
				
				set	@ChangeIntValue = @mmEnd
				set	@mmEnd = @mmStart
				set	@mmStart = @ChangeIntValue
            end
            else if (@mmEnd = @mmStart)
            begin
                set	@sgnM = 0
            end

            if (@ddEnd < @ddStart) 
            begin
                set	@sgnD = @sgnD * (-1)
				
				--set	@ChangeIntValue = @ddEnd
				--set	@ddEnd = @ddStart
				--set	@ddStart = @ChangeIntValue
            end
            else if (@ddEnd = @ddStart)
            begin
                set	@sgnD = 0
            end
            
            declare @sgnYM int = @sgnY + (1 - @sgnY * @sgnY) * @sgnM

			set	@diff = @StartEndDatesSgn *
				case	@DateUnit
					when	1	-- Years
						then	@sgnY * (@yyyyEnd - @yyyyStart + @sgnM * @sgnM * (cast(((@sgnM * @sgnY - 1) / 2) as int)) 
									 + (1 - @sgnM * @sgnM) * @sgnD * @sgnD * (cast(((@sgnD * @sgnY - 1) / 2) as int)))
                    when	2	-- Months
						then	@sgnY * (@yyyyEnd - @yyyyStart) * 12 + @sgnM * (@mmEnd - @mmStart) + 
									@sgnYM * @sgnD * @sgnD * (cast(((@sgnD * @sgnYM - 1) / 2) as int))
                    when	3	-- Days
						then	datediff(dd, @StartDate, @EndDate)
					else	-- Incorrect (Years)
							@sgnY * (@yyyyEnd - @yyyyStart + @sgnM * @sgnM * (cast(((@sgnM * @sgnY - 1) / 2) as int)) 
								 + (1 - @sgnM * @sgnM) * @sgnD * @sgnD * (cast(((@sgnD * @sgnY - 1) / 2) as int)))
				end
		end
	end

    return @diff

end

GO


SET XACT_ABORT ON 
SET NOCOUNT ON 


declare	@Error	int
set	@Error = 0

declare	@ErrorMsg	nvarchar(MAX)
set	@ErrorMsg = N''



BEGIN TRAN

BEGIN TRY


/*
If <Date of Birth> is not blank, then the following rules are applied.
Let variable D be <Date of Symptoms Onset>, if it is not blank;
if <Date of Symptoms Onset> is blank, then let D be <Date of Notification>, if it is not blank; 
if <Date of Notification> is blank, then let D be <Date of Diagnosis>, if it is not blank;
otherwise let D be <Date Entered>. If <Date of Death> is not blank and less than determined date D, let D be <Date of Death>.
*/

update	hc
set		hc.intPatientAge =
			case
				when	hc.datOnSetDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datOnSetDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datOnSetDate) > 0
					then	dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datOnSetDate)
				when	hc.datOnSetDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datOnSetDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datOnSetDate) <= 0
						and dbo.fnExactDateDiff(2, h.datDateofBirth, hc.datOnSetDate) > 0
					then	dbo.fnExactDateDiff(2, h.datDateofBirth, hc.datOnSetDate)
				when	hc.datOnSetDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datOnSetDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datOnSetDate) <= 0
						and dbo.fnExactDateDiff(2, h.datDateofBirth, hc.datOnSetDate) <= 0
					then	dbo.fnExactDateDiff(3, h.datDateofBirth, hc.datOnSetDate)

				when	hc.datOnSetDate is null
						and hc.datNotificationDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datNotificationDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datNotificationDate) > 0
					then	dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datNotificationDate)
				when	hc.datOnSetDate is null
						and hc.datNotificationDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datNotificationDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datNotificationDate) <= 0
						and dbo.fnExactDateDiff(2, h.datDateofBirth, hc.datNotificationDate) > 0
					then	dbo.fnExactDateDiff(2, h.datDateofBirth, hc.datNotificationDate)
				when	hc.datOnSetDate is null
						and hc.datNotificationDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datNotificationDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datNotificationDate) <= 0
						and dbo.fnExactDateDiff(2, h.datDateofBirth, hc.datNotificationDate) <= 0
					then	dbo.fnExactDateDiff(3, h.datDateofBirth, hc.datNotificationDate)


				when	hc.datOnSetDate is null
						and hc.datNotificationDate is null
						and hc.datTentativeDiagnosisDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datTentativeDiagnosisDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datTentativeDiagnosisDate) > 0
					then	dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datTentativeDiagnosisDate)
				when	hc.datOnSetDate is null
						and hc.datNotificationDate is null
						and hc.datTentativeDiagnosisDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datTentativeDiagnosisDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datTentativeDiagnosisDate) <= 0
						and dbo.fnExactDateDiff(2, h.datDateofBirth, hc.datTentativeDiagnosisDate) > 0
					then	dbo.fnExactDateDiff(2, h.datDateofBirth, hc.datTentativeDiagnosisDate)
				when	hc.datOnSetDate is null
						and hc.datNotificationDate is null
						and hc.datTentativeDiagnosisDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datTentativeDiagnosisDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datTentativeDiagnosisDate) <= 0
						and dbo.fnExactDateDiff(2, h.datDateofBirth, hc.datTentativeDiagnosisDate) <= 0
					then	dbo.fnExactDateDiff(3, h.datDateofBirth, hc.datTentativeDiagnosisDate)


				when	hc.datOnSetDate is null
						and hc.datNotificationDate is null
						and hc.datTentativeDiagnosisDate is null
						and hc.datEnteredDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datEnteredDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datEnteredDate) > 0
					then	dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datEnteredDate)
				when	hc.datOnSetDate is null
						and hc.datNotificationDate is null
						and hc.datTentativeDiagnosisDate is null
						and hc.datEnteredDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datEnteredDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datEnteredDate) <= 0
						and dbo.fnExactDateDiff(2, h.datDateofBirth, hc.datEnteredDate) > 0
					then	dbo.fnExactDateDiff(2, h.datDateofBirth, hc.datEnteredDate)
				when	hc.datOnSetDate is null
						and hc.datNotificationDate is null
						and hc.datTentativeDiagnosisDate is null
						and hc.datEnteredDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datEnteredDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datEnteredDate) <= 0
						and dbo.fnExactDateDiff(2, h.datDateofBirth, hc.datEnteredDate) <= 0
					then	dbo.fnExactDateDiff(3, h.datDateofBirth, hc.datEnteredDate)


				when	h.datDateOfDeath is not null
						and	(	(hc.datOnSetDate is not null and hc.datOnSetDate > h.datDateOfDeath)
								or	(	hc.datOnSetDate is null
										and hc.datNotificationDate is not null
										and hc.datNotificationDate > h.datDateOfDeath
									)
								or	(	hc.datOnSetDate is null
										and hc.datNotificationDate is null
										and hc.datTentativeDiagnosisDate is not null
										and hc.datTentativeDiagnosisDate > h.datDateOfDeath
									)
								or	(	hc.datOnSetDate is null
										and hc.datNotificationDate is null
										and hc.datTentativeDiagnosisDate is null
										and hc.datEnteredDate is not null
										and hc.datEnteredDate > h.datDateOfDeath
									)
							)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, h.datDateOfDeath) > 0
					then	dbo.fnExactDateDiff(1, h.datDateofBirth, h.datDateOfDeath)
				when	h.datDateOfDeath is not null
						and	(	(hc.datOnSetDate is not null and hc.datOnSetDate > h.datDateOfDeath)
								or	(	hc.datOnSetDate is null
										and hc.datNotificationDate is not null
										and hc.datNotificationDate > h.datDateOfDeath
									)
								or	(	hc.datOnSetDate is null
										and hc.datNotificationDate is null
										and hc.datTentativeDiagnosisDate is not null
										and hc.datTentativeDiagnosisDate > h.datDateOfDeath
									)
								or	(	hc.datOnSetDate is null
										and hc.datNotificationDate is null
										and hc.datTentativeDiagnosisDate is null
										and hc.datEnteredDate is not null
										and hc.datEnteredDate > h.datDateOfDeath
									)
							)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, h.datDateOfDeath) <= 0
						and dbo.fnExactDateDiff(2, h.datDateofBirth, h.datDateOfDeath) > 0
					then	dbo.fnExactDateDiff(2, h.datDateofBirth, h.datDateOfDeath)
				when	h.datDateOfDeath is not null
						and	(	(hc.datOnSetDate is not null and hc.datOnSetDate > h.datDateOfDeath)
								or	(	hc.datOnSetDate is null
										and hc.datNotificationDate is not null
										and hc.datNotificationDate > h.datDateOfDeath
									)
								or	(	hc.datOnSetDate is null
										and hc.datNotificationDate is null
										and hc.datTentativeDiagnosisDate is not null
										and hc.datTentativeDiagnosisDate > h.datDateOfDeath
									)
								or	(	hc.datOnSetDate is null
										and hc.datNotificationDate is null
										and hc.datTentativeDiagnosisDate is null
										and hc.datEnteredDate is not null
										and hc.datEnteredDate > h.datDateOfDeath
									)
							)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, h.datDateOfDeath) <= 0
						and dbo.fnExactDateDiff(2, h.datDateofBirth, h.datDateOfDeath) <= 0
					then	dbo.fnExactDateDiff(3, h.datDateofBirth, h.datDateOfDeath)
			end,

		hc.idfsHumanAgeType =
			case
				when	hc.datOnSetDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datOnSetDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datOnSetDate) > 0
					then	10042003 /*Years*/
				when	hc.datOnSetDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datOnSetDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datOnSetDate) <= 0
						and dbo.fnExactDateDiff(2, h.datDateofBirth, hc.datOnSetDate) > 0
					then	10042002 /*Months*/
				when	hc.datOnSetDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datOnSetDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datOnSetDate) <= 0
						and dbo.fnExactDateDiff(2, h.datDateofBirth, hc.datOnSetDate) <= 0
					then	10042001 /*Days*/

				when	hc.datOnSetDate is null
						and hc.datNotificationDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datNotificationDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datNotificationDate) > 0
					then	10042003 /*Years*/
				when	hc.datOnSetDate is null
						and hc.datNotificationDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datNotificationDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datNotificationDate) <= 0
						and dbo.fnExactDateDiff(2, h.datDateofBirth, hc.datNotificationDate) > 0
					then	10042002 /*Months*/
				when	hc.datOnSetDate is null
						and hc.datNotificationDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datNotificationDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datNotificationDate) <= 0
						and dbo.fnExactDateDiff(2, h.datDateofBirth, hc.datNotificationDate) <= 0
					then	10042001 /*Days*/


				when	hc.datOnSetDate is null
						and hc.datNotificationDate is null
						and hc.datTentativeDiagnosisDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datTentativeDiagnosisDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datTentativeDiagnosisDate) > 0
					then	10042003 /*Years*/
				when	hc.datOnSetDate is null
						and hc.datNotificationDate is null
						and hc.datTentativeDiagnosisDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datTentativeDiagnosisDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datTentativeDiagnosisDate) <= 0
						and dbo.fnExactDateDiff(2, h.datDateofBirth, hc.datTentativeDiagnosisDate) > 0
					then	10042002 /*Months*/
				when	hc.datOnSetDate is null
						and hc.datNotificationDate is null
						and hc.datTentativeDiagnosisDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datTentativeDiagnosisDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datTentativeDiagnosisDate) <= 0
						and dbo.fnExactDateDiff(2, h.datDateofBirth, hc.datTentativeDiagnosisDate) <= 0
					then	10042001 /*Days*/


				when	hc.datOnSetDate is null
						and hc.datNotificationDate is null
						and hc.datTentativeDiagnosisDate is null
						and hc.datEnteredDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datEnteredDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datEnteredDate) > 0
					then	10042003 /*Years*/
				when	hc.datOnSetDate is null
						and hc.datNotificationDate is null
						and hc.datTentativeDiagnosisDate is null
						and hc.datEnteredDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datEnteredDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datEnteredDate) <= 0
						and dbo.fnExactDateDiff(2, h.datDateofBirth, hc.datEnteredDate) > 0
					then	10042002 /*Months*/
				when	hc.datOnSetDate is null
						and hc.datNotificationDate is null
						and hc.datTentativeDiagnosisDate is null
						and hc.datEnteredDate is not null
						and (h.datDateOfDeath is null or h.datDateOfDeath > hc.datEnteredDate)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, hc.datEnteredDate) <= 0
						and dbo.fnExactDateDiff(2, h.datDateofBirth, hc.datEnteredDate) <= 0
					then	10042001 /*Days*/


				when	h.datDateOfDeath is not null
						and	(	(hc.datOnSetDate is not null and hc.datOnSetDate > h.datDateOfDeath)
								or	(	hc.datOnSetDate is null
										and hc.datNotificationDate is not null
										and hc.datNotificationDate > h.datDateOfDeath
									)
								or	(	hc.datOnSetDate is null
										and hc.datNotificationDate is null
										and hc.datTentativeDiagnosisDate is not null
										and hc.datTentativeDiagnosisDate > h.datDateOfDeath
									)
								or	(	hc.datOnSetDate is null
										and hc.datNotificationDate is null
										and hc.datTentativeDiagnosisDate is null
										and hc.datEnteredDate is not null
										and hc.datEnteredDate > h.datDateOfDeath
									)
							)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, h.datDateOfDeath) > 0
					then	10042003 /*Years*/
				when	h.datDateOfDeath is not null
						and	(	(hc.datOnSetDate is not null and hc.datOnSetDate > h.datDateOfDeath)
								or	(	hc.datOnSetDate is null
										and hc.datNotificationDate is not null
										and hc.datNotificationDate > h.datDateOfDeath
									)
								or	(	hc.datOnSetDate is null
										and hc.datNotificationDate is null
										and hc.datTentativeDiagnosisDate is not null
										and hc.datTentativeDiagnosisDate > h.datDateOfDeath
									)
								or	(	hc.datOnSetDate is null
										and hc.datNotificationDate is null
										and hc.datTentativeDiagnosisDate is null
										and hc.datEnteredDate is not null
										and hc.datEnteredDate > h.datDateOfDeath
									)
							)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, h.datDateOfDeath) <= 0
						and dbo.fnExactDateDiff(2, h.datDateofBirth, h.datDateOfDeath) > 0
					then	10042002 /*Months*/
				when	h.datDateOfDeath is not null
						and	(	(hc.datOnSetDate is not null and hc.datOnSetDate > h.datDateOfDeath)
								or	(	hc.datOnSetDate is null
										and hc.datNotificationDate is not null
										and hc.datNotificationDate > h.datDateOfDeath
									)
								or	(	hc.datOnSetDate is null
										and hc.datNotificationDate is null
										and hc.datTentativeDiagnosisDate is not null
										and hc.datTentativeDiagnosisDate > h.datDateOfDeath
									)
								or	(	hc.datOnSetDate is null
										and hc.datNotificationDate is null
										and hc.datTentativeDiagnosisDate is null
										and hc.datEnteredDate is not null
										and hc.datEnteredDate > h.datDateOfDeath
									)
							)
						and dbo.fnExactDateDiff(1, h.datDateofBirth, h.datDateOfDeath) <= 0
						and dbo.fnExactDateDiff(2, h.datDateofBirth, h.datDateOfDeath) <= 0
					then	10042001 /*Days*/
			end

from	dbo.tlbHumanCase hc
join	dbo.tlbHuman h
on		h.idfHuman = hc.idfHuman
where	hc.intRowStatus = 0
		and h.datDateofBirth is not null
		and (	hc.datOnSetDate is not null
				or hc.datNotificationDate is not null
				or hc.datTentativeDiagnosisDate is not null
				or hc.datEnteredDate is not null
				or h.datDateOfDeath is not null
			)

update	hai
set		hai.ReportedAge = hc.intPatientAge,
		hai.ReportedAgeUOMID = hc.idfsHumanAgeType
from	dbo.tlbHumanCase hc
join	dbo.tlbHuman h
on		h.idfHuman = hc.idfHuman
join	dbo.HumanAddlInfo hai
on		hai.HumanAdditionalInfo = h.idfHuman
where	hc.intRowStatus = 0
		and h.datDateofBirth is not null
		and (	hc.datOnSetDate is not null
				or hc.datNotificationDate is not null
				or hc.datTentativeDiagnosisDate is not null
				or hc.datEnteredDate is not null
				or h.datDateOfDeath is not null
			)


update	haai
set		haai.ReportedAge = null,
		haai.ReportedAgeUOMID = null
from	dbo.HumanActualAddlInfo haai
where	haai.intRowStatus = 0

print N'Age in Existing HDRs has been recalculated successfully.'

END TRY
BEGIN CATCH
    set @Error = ERROR_NUMBER()
	set	@ErrorMsg = 
		  N' ErrorSeverity: ' + CONVERT(NVARCHAR, ERROR_SEVERITY())
		+ N' ErrorState: ' + CONVERT(NVARCHAR, ERROR_STATE())
		+ N' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), N'')
		+ N' ErrorLine: ' +  CONVERT(NVARCHAR, ISNULL(ERROR_LINE(), N''))
		+ N' ErrorMessage: ' + ERROR_MESSAGE();
	
	if	@Error <> 0
	begin
			
		RAISERROR (N'Error %d: %s.', -- Message text.
			   16, -- Severity,
			   1, -- State,
			   @Error,
			   @ErrorMsg) WITH SETERROR; -- Second argument.
	end
    
END CATCH;


IF @@ERROR <> 0
	IF @@TRANCOUNT > 0 ROLLBACK TRAN
ELSE
	IF @@TRANCOUNT > 0 COMMIT TRAN

SET NOCOUNT OFF 
SET XACT_ABORT OFF 







