-- ================================================================================================
-- Name: UPDATE CALCULATED Human Name ON MATERIAL TABLE FOR 6.1 DATA TO USE 7.0 FORMAT
--
-- Description: Execute on all environments.  Updates the calculated human name for migrated data 
-- so that the new EIDSS 7 format is shown (LAST NAME, FIRST NAME SECOND NAME).  Currently the 
-- format is LAST NAME FIRST NAME SECOND NAME.  Comma is the new addition.
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Stephen Long    03/09/2023 Run for build 7.0.338.x
-- ================================================================================================
UPDATE dbo.tlbMaterial
SET strCalculatedHumanName = CASE
                                 WHEN a.idfSpecies IS NOT NULL
                                      AND a.idfVetCase IS NULL
                                      AND a.idfMonitoringSession IS NULL THEN
                                     CASE
                                         WHEN dbo.tlbFarm.idfHuman IS NULL THEN
                                             CASE
                                                 WHEN dbo.tlbFarm.strNationalName IS NULL THEN
                                                     dbo.tlbFarm.strFarmCode
                                                 ELSE
                                                     dbo.tlbFarm.strNationalName
                                             END
                                         WHEN SampleHuman.strLastName IS NULL THEN
                                             CASE
                                                 WHEN dbo.tlbFarm.strNationalName IS NULL THEN
                                                     dbo.tlbFarm.strFarmCode
                                                 ELSE
                                                     dbo.tlbFarm.strNationalName
                                             END
                                         ELSE
                                             ISNULL(SampleHuman.strLastName, '')
                                             + ISNULL(', ' + SampleHuman.strFirstName + ' ', '')
                                             + ISNULL(SampleHuman.strSecondName, '')
                                     END
                                 WHEN a.idfSpecies IS NOT NULL
                                      AND a.idfVetCase IS NOT NULL
                                      OR a.idfMonitoringSession IS NOT NULL THEN
                                     CASE
                                         WHEN dbo.tlbFarm.idfHuman IS NULL THEN
                                             CASE
                                                 WHEN dbo.tlbFarm.strNationalName IS NULL THEN
                                                     dbo.tlbFarm.strFarmCode
                                                 ELSE
                                                     dbo.tlbFarm.strNationalName
                                             END
                                         WHEN SampleHuman.strLastName IS NULL THEN
                                             CASE
                                                 WHEN dbo.tlbFarm.strNationalName IS NULL THEN
                                                     dbo.tlbFarm.strFarmCode
                                                 ELSE
                                                     dbo.tlbFarm.strNationalName
                                             END
                                         ELSE
                                             ISNULL(SampleHuman.strLastName, '')
                                             + ISNULL(', ' + SampleHuman.strFirstName + ' ', '')
                                             + ISNULL(SampleHuman.strSecondName, '')
                                     END
                                 WHEN a.idfAnimal IS NOT NULL
                                      AND a.idfSpecies IS NULL
                                      AND a.idfVetCase IS NOT NULL
                                      OR a.idfMonitoringSession IS NOT NULL THEN
                                     CASE
                                         WHEN dbo.tlbFarm.idfHuman IS NULL THEN
                                             CASE
                                                 WHEN dbo.tlbFarm.strNationalName IS NULL THEN
                                                     dbo.tlbFarm.strFarmCode
                                                 ELSE
                                                     dbo.tlbFarm.strNationalName
                                             END
                                         WHEN SampleHuman.strLastName IS NULL THEN
                                             CASE
                                                 WHEN dbo.tlbFarm.strNationalName IS NULL THEN
                                                     dbo.tlbFarm.strFarmCode
                                                 ELSE
                                                     dbo.tlbFarm.strNationalName
                                             END
                                         ELSE
                                             ISNULL(SampleHuman.strLastName, '')
                                             + ISNULL(', ' + SampleHuman.strFirstName + ' ', '')
                                             + ISNULL(SampleHuman.strSecondName, '')
                                     END
                                 WHEN a.idfHumanCase IS NOT NULL THEN
                                     ISNULL(CaseHuman.strLastName, '')
                                     + ISNULL(', ' + CaseHuman.strFirstName + ' ', '')
                                     + ISNULL(CaseHuman.strSecondName, '')
                                 ELSE
                                     ISNULL(SampleHuman.strLastName, '')
                                     + ISNULL(', ' + SampleHuman.strFirstName + ' ', '')
                                     + ISNULL(SampleHuman.strSecondName, '')
                             END
FROM dbo.tlbMaterial a
    LEFT JOIN dbo.tlbAnimal
        ON dbo.tlbAnimal.idfAnimal = a.idfAnimal
    LEFT JOIN dbo.tlbSpecies
        ON (
               dbo.tlbSpecies.idfSpecies = a.idfSpecies
               OR dbo.tlbSpecies.idfSpecies = dbo.tlbAnimal.idfSpecies
           )
    LEFT JOIN dbo.tlbHerd
        ON dbo.tlbHerd.idfHerd = dbo.tlbSpecies.idfHerd
    LEFT JOIN dbo.tlbFarm
        ON dbo.tlbFarm.idfFarm = dbo.tlbHerd.idfFarm
    LEFT JOIN dbo.tlbHuman SampleHuman
        ON SampleHuman.idfHuman = tlbFarm.idfHuman
           OR SampleHuman.idfHuman = a.idfHuman
    LEFT JOIN dbo.tlbHumanCase HumanCase
        ON HumanCase.idfHumanCase = a.idfHumanCase
    LEFT JOIN dbo.tlbHuman CaseHuman
        ON CaseHuman.idfHuman = CaseHuman.idfHuman

GO