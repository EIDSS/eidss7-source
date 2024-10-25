/*
Author:			Stephen Long
Date:			01/07/2023
Description:	Update strCalculatedCaseID to get the values from HDR, VDR and monitoring sessions for bug 5430.
Note:           -Be sure to wrap your insert statements in "IF NOT EXISTS" in case deploy must be run twice
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

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
                ON tlbHumanCase.idfHumanCase = a.idfHumanCase
            LEFT JOIN dbo.OutbreakCaseReport humOCR
                ON humOCR.idfHumanCase = dbo.tlbHumanCase.idfHumanCase
            LEFT JOIN dbo.tlbVetCase
                ON tlbVetCase.idfVetCase = a.idfVetCase
            LEFT JOIN dbo.OutbreakCaseReport vetOCR
                ON vetOCR.idfVetCase = dbo.tlbVetCase.idfVetCase
            LEFT JOIN dbo.tlbMonitoringSession
                ON dbo.tlbMonitoringSession.idfMonitoringSession = a.idfMonitoringSession
            LEFT JOIN dbo.tlbVectorSurveillanceSession
                ON dbo.tlbVectorSurveillanceSession.idfVectorSurveillanceSession = a.idfVectorSurveillanceSession
    WHERE a.strCalculatedCaseID IS NULL AND (a.idfHumanCase IS NOT NULL OR a.idfVetCase IS NOT NULL OR a.idfMonitoringSession IS NOT NULL OR a.idfVectorSurveillanceSession IS NOT NULL)

    GO
