
-- run on any Georgian database to make sure alll GG roles are enabled

UPDATE dbo.trtBaseReference 
SET intRowStatus = 0
WHERE idfsBaseReference BETWEEN -529 AND -513 
OR idfsBaseReference IN (-501,-506)
AND dbo.FN_GBL_CURRENTCOUNTRY_GET() = 780000000 -- GG

