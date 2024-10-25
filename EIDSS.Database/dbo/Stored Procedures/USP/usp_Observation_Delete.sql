
--=====================================================================================================
-- Created by:				Joan Li
-- Description:				06/21/2017: Created based on V6 spObservation_Delete :  V7 USP75: call this
--                          delete from tables :tlbActivityParameters(triggers);tflObservationFiltered
-- Revision History:
--		Name       Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
--	Mark Wilson    10/21/2021 added @User and auditing
--  Manickandan Govindarajan 12/06/2022 SAUC30 and 31
/*
----testing code:
DECLARE @idfObservation bigint
EXEC USP_OBSERVATION_DELETE 
	@idfObservation, 
	'parkermason'

----related fact data from
select * from tlbActivityParameters
select * from tflObservationFiltered
*/
--=====================================================================================================

CREATE   PROC	[dbo].[usp_Observation_Delete]
(
	@ID AS BIGINT,
	@User NVARCHAR(100) = NULL,
	@idfDataAuditEvent bigint

)


AS

	declare @idfObjectTable_tlbActivityParameters bigint =75410000000;

	declare @idfObjectTable_tlbObservation bigint =75640000000;

	INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
		SELECT @idfDataAuditEvent, @idfObjectTable_tlbActivityParameters, idfActivityParameters
			from dbo.tlbActivityParameters WHERE idfObservation = @ID

	UPDATE dbo.tlbActivityParameters
	SET intRowStatus = 1,
		AuditUpdateUser = @User,
		AuditUpdateDTM = GETDATE()
	WHERE 	idfObservation = @ID


	DELETE FROM dbo.tflObservationFiltered 
	WHERE idfObservation = @ID

	INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
		SELECT @idfDataAuditEvent, @idfObjectTable_tlbObservation, idfObservation
			from dbo.tlbObservation WHERE idfObservation = @ID

	UPDATE dbo.tlbObservation 
	SET intRowStatus = 1,
		AuditUpdateUser = @User,
		AuditUpdateDTM = GETDATE()
	WHERE 	idfObservation = @ID
	


