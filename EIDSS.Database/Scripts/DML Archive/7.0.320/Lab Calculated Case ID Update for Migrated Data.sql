-- ================================================================================================
-- Name: UPDATE CALCULATED CASE ID ON MATERIAL TABLE FOR 6.1 DATA TO USE 7.0 ID's
--
-- Description: Execute on all environments.  Updates the calculated case ID for migrated data so 
-- that the new EIDSS 7 ID's are shown instead of the legacy ID's.  This avoids confusion to the 
-- user when accessioning samples created in 6.1 so the report/session ID column data will 
-- remain consistent and not change after accessioning.
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Stephen Long    08/23/2022 Run for build 7.0.287.x
-- ================================================================================================
UPDATE a 
        SET strCalculatedCaseID = CASE
                                      WHEN a.idfMonitoringSession IS NOT NULL THEN
                                          dbo.tlbMonitoringSession.strMonitoringSessionID
                                      WHEN a.idfVectorSurveillanceSession IS NOT NULL THEN
                                          dbo.tlbVectorSurveillanceSession.strSessionID
                                      WHEN a.idfHumanCase IS NOT NULL THEN
                                          CASE
                                              WHEN dbo.tlbHumanCase.idfOutbreak IS NULL THEN
                                                  dbo.tlbHumanCase.strCaseID
                                              ELSE
                                                  humOCR.strOutbreakCaseID
                                          END
                                      WHEN a.idfVetCase IS NOT NULL THEN
                                          CASE
                                              WHEN dbo.tlbVetCase.idfOutbreak IS NULL THEN
                                                  dbo.tlbVetCase.strCaseID
                                              ELSE
                                                  vetOCR.strOutbreakCaseID
                                          END
                                  END
        FROM dbo.tlbMaterial a
            LEFT JOIN dbo.tlbHumanCase
                ON dbo.tlbHumanCase.idfHumanCase = a.idfHumanCase
                   AND dbo.tlbHumanCase.intRowStatus = 0
            LEFT JOIN dbo.OutbreakCaseReport humOCR
                ON humOCR.idfHumanCase = dbo.tlbHumanCase.idfHumanCase
            LEFT JOIN dbo.tlbVetCase
                ON dbo.tlbVetCase.idfVetCase = a.idfVetCase
                   AND dbo.tlbVetCase.intRowStatus = 0
            LEFT JOIN dbo.OutbreakCaseReport vetOCR
                ON vetOCR.idfVetCase = dbo.tlbVetCase.idfVetCase
            LEFT JOIN dbo.tlbMonitoringSession
                ON dbo.tlbMonitoringSession.idfMonitoringSession = a.idfMonitoringSession
                   AND dbo.tlbMonitoringSession.intRowStatus = 0
            LEFT JOIN dbo.tlbVectorSurveillanceSession
                ON dbo.tlbVectorSurveillanceSession.idfVectorSurveillanceSession = a.idfVectorSurveillanceSession
                   AND dbo.tlbVectorSurveillanceSession.intRowStatus = 0
				   WHERE a.intRowStatus = 0