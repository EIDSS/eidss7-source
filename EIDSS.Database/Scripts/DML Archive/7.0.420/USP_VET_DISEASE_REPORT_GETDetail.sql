UPDATE hc
-- 9 (character tabulation), 10 (line tabulation), 13 (carriage return)
SET hc.strHospitalizationPlace = rtrim(ltrim(replace(replace(replace(hc.strHospitalizationPlace, char(9), ''), char(10), ''), char(13), '')))
FROM dbo.tlbHumanCase hc
WHERE hc.strHospitalizationPlace IS NOT NULL
  AND hc.strHospitalizationPlace != ''