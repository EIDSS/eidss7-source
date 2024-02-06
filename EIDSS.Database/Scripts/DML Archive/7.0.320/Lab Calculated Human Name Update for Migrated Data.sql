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
-- Stephen Long    08/23/2022 Run for build 7.0.287.x
-- ================================================================================================
UPDATE dbo.tlbMaterial SET strCalculatedHumanName = CASE
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
                                                 WHEN HumanFromCase.strLastName IS NULL THEN
                                                     CASE
                                                         WHEN dbo.tlbFarm.strNationalName IS NULL THEN
                                                             dbo.tlbFarm.strFarmCode
                                                         ELSE
                                                             dbo.tlbFarm.strNationalName
                                                     END
                                                 ELSE
                                                     ISNULL(HumanFromCase.strLastName, '')
                                                     + ISNULL(', ' + HumanFromCase.strFirstName + ' ', '')
                                                     + ISNULL(HumanFromCase.strSecondName, '')
                                             END
                                         ELSE
                                             ISNULL(HumanFromCase.strLastName, '')
                                             + ISNULL(', ' + HumanFromCase.strFirstName + ' ', '')
                                             + ISNULL(HumanFromCase.strSecondName, '')
                                     END
        FROM dbo.tlbMaterial a
            LEFT JOIN dbo.tlbAnimal
                ON dbo.tlbAnimal.idfAnimal = a.idfAnimal
                   AND dbo.tlbAnimal.intRowStatus = 0
            LEFT JOIN dbo.tlbSpecies
                ON (
                       dbo.tlbSpecies.idfSpecies = a.idfSpecies
                       OR dbo.tlbSpecies.idfSpecies = dbo.tlbAnimal.idfSpecies
                   )
                   AND dbo.tlbSpecies.intRowStatus = 0
            LEFT JOIN dbo.tlbHerd
                ON dbo.tlbHerd.idfHerd = dbo.tlbSpecies.idfHerd
                   AND dbo.tlbHerd.intRowStatus = 0
            LEFT JOIN dbo.tlbFarm
                ON dbo.tlbFarm.idfFarm = dbo.tlbHerd.idfFarm
                   AND dbo.tlbFarm.intRowStatus = 0
            LEFT JOIN dbo.tlbHuman HumanFromCase
                ON HumanFromCase.idfHuman = tlbFarm.idfHuman
                   OR HumanFromCase.idfHuman = a.idfHuman
				   WHERE a.intRowStatus = 0