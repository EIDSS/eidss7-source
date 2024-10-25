ALTER TABLE dbo.tasSearchTable DISABLE TRIGGER ALL
ALTER TABLE dbo.tasFieldSourceForTable DISABLE TRIGGER ALL
 update tasFieldSourceForTable set strFieldText =N'campaignStatus{0}.idfsReference' where idfsSearchField = 10081318 and idfSearchTable = 4582550000000
 update tasFieldSourceForTable set strFieldText =N'as_cam{0}.datCampaignDateStart' where idfsSearchField = 10081319 and idfSearchTable = 4582550000000
 update tasFieldSourceForTable set strFieldText =N'as_cam{0}.datCampaignDateEnd' where idfsSearchField = 10081320 and idfSearchTable = 4582550000000
 update tasFieldSourceForTable set strFieldText =N'as_cam{0}.strCampaignAdministrator' where idfsSearchField = 10081321 and idfSearchTable = 4582550000000
 update tasSearchTable set strFrom = N'{(} tlbCampaign AS as_cam{0}  LEFT JOIN dbo.tlbCampaignToDiagnosis cd{0} ON cd{0}.idfCampaign = as_cam{0}.idfCampaign LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000115) campaignStatus{0}  ON as_cam{0}.idfsCampaignStatus = campaignStatus{0}.idfsReference LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000116) campaignType{0}  ON as_cam{0}.idfsCampaignType = campaignType{0}.idfsReference {1}{)}'
 where idfSearchTable = 4582550000000
ALTER TABLE dbo.tasFieldSourceForTable ENABLE TRIGGER ALL
ALTER TABLE dbo.tasSearchTable ENABLE TRIGGER ALL