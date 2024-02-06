using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel;

namespace EIDSS.Domain.Enumerations
{
    /// <summary>
    /// Table audit event enumeration
    /// </summary>
    public enum AuditTableEnum : long
    {
        [Description("Decoration Elements")]
        ffDecorElement = 74800000000,

        [Description("Line Decoration Elements")]
        ffDecorElementLine = 74810000000,

        [Description("Label Decoration Elements")]
        ffDecorElementText = 74820000000,

        [Description("Determinant Type")]
        ffDeterminantType = 74830000000,

        [Description("Determinant Values")]
        ffDeterminantValue = 74840000000,

        [Description("Templates")]
        ffFormTemplate = 74850000000,

        [Description("Parameters")]
        ffParameter = 74860000000,

        [Description("Parameter Design Options")]
        ffParameterDesignOption = 74870000000,

        [Description("")]
        ffParameterFixedPresetValue = 74880000000,

        [Description("")]
        ffParameterForAction = 74890000000,

        [Description("Parameters for function")]
        ffParameterForFunction = 74900000000,

        [Description("Parameters for template")]
        ffParameterForTemplate = 74910000000,

        [Description("Parameter types")]
        ffParameterType = 74920000000,

        [Description("Rules")]
        ffRule = 74930000000,

        [Description("")]
        ffRuleConstant = 74940000000,

        [Description("Rule Functions")]
        ffRuleFunction = 74950000000,

        [Description("Sections")]
        ffSection = 74960000000,

        [Description("Section design options")]
        ffSectionDesignOption = 74970000000,

        [Description("")]
        ffSectionForAction = 74980000000,

        [Description("Sections for template")]
        ffSectionForTemplate = 74990000000,

        [Description("Base Reference table for GIS reference values")]
        gisBaseReference = 75000000000,

        [Description("Countries")]
        gisCountry = 75010000000,

        [Description("")]
        gisMetadata = 75020000000,

        [Description("")]
        gisNewID = 75030000000,

        [Description("Rayons")]
        gisRayon = 75040000000,

        [Description("GIS Reference types")]
        gisReferenceType = 75050000000,

        [Description("Regions")]
        gisRegion = 75060000000,

        [Description("Settlements")]
        gisSettlement = 75070000000,

        [Description("Translated values for GIS References")]
        gisStringNameTranslation = 75080000000,

        [Description("")]
        gisWKBCountry = 75090000000,

        [Description("")]
        gisWKBRayon = 75100000000,

        [Description("")]
        gisWKBRegion = 75110000000,

        [Description("")]
        gisWKBSettlement = 75120000000,

        [Description("")]
        locBaseReference = 4573470000000,

        [Description("")]
        locStringNameTranslation = 4573490000000,

        [Description("")]
        tasglLayout = 4573530000000,

        [Description("")]
        tasglLayoutFolder = 4573880000000,

        [Description("")]
        tasglQuery = 4574010000000,

        [Description("")]
        tasglQueryConditionGroup = 4574070000000,

        [Description("")]
        tasglQuerySearchField = 4574140000000,

        [Description("")]
        tasglQuerySearchFieldCondition = 4574200000000,

        [Description("")]
        tasglQuerySearchObject = 4574290000000,

        [Description("Report Layouts")]
        tasLayout = 75170000000,

        [Description("")]
        tasLayoutFolder = 4574680000000,

        [Description("Queries")]
        tasQuery = 75220000000,

        [Description("Query Condition Groups")]
        tasQueryConditionGroup = 75230000000,

        [Description("Query Search Fields")]
        tasQuerySearchField = 75240000000,

        [Description("Query Search Field Conditions")]
        tasQuerySearchFieldCondition = 75250000000,

        [Description("Query Search Objects")]
        tasQuerySearchObject = 75260000000,

        [Description("")]
        tasSearchField = 4579150000000,

        [Description("")]
        tasSearchObject = 4579250000000,

        [Description("")]
        tasSearchObjectToSearchObject = 50815700000000,

        [Description("")]
        tasSearchTable = 75290000000,

        [Description("Table fields for audit")]
        tauColumn = 75300000000,

        [Description("Object Creation Audit ")]
        tauDataAuditDetailCreate = 75310000000,

        [Description("Object Deletion Audit ")]
        tauDataAuditDetailDelete = 75320000000,

        [Description("Object Change Audit ")]
        tauDataAuditDetailUpdate = 75330000000,

        [Description("Audit Events")]
        tauDataAuditEvent = 75340000000,

        [Description("Audit Tables")]
        tauTable = 75350000000,

        [Description("WHO Module exports performed")]
        tdeDataExport = 75360000000,

        [Description("WHO Module export details")]
        tdeDataExportDetail = 75370000000,

        [Description("WHO Module export diagnosis")]
        tdeDataExportDiagnosis = 75380000000,

        [Description("WHO Module export problems")]
        tdeDataExportProblem = 75390000000,

        [Description("")]
        tlbActivityParameters = 75410000000,

        [Description("Aggregate cases")]
        tlbAggrCase = 75420000000,

        [Description("")]
        tlbAggrDiagnosticActionMTX = 75430000000,

        [Description("")]
        tlbAggrHumanCaseMTX = 12666620000000,

        [Description("")]
        tlbAggrMatrixVersionHeader = 707330000000,

        [Description("")]
        tlbAggrProphylacticActionMTX = 75440000000,

        [Description("")]
        tlbAggrSanitaryActionMTX = 12666690000000,

        [Description("")]
        tlbAggrVetCaseMTX = 75450000000,

        [Description("Animals")]
        tlbAnimal = 75460000000,

        [Description("")]
        tlbAntimicrobialTherapy = 75470000000,

        [Description("")]
        tlbBasicSyndromicSurveillance = 50791230000000,

        [Description("")]
        tlbBasicSyndromicSurveillanceAggregateDetail = 50791790000000,

        [Description("")]
        tlbBasicSyndromicSurveillanceAggregateHeader = 50791690000000,

        [Description("Batch test parameters")]
        tlbBatchTest = 75480000000,

        [Description("")]
        tlbCampaign = 706900000000,

        [Description("")]
        tlbCampaignToDiagnosis = 707000000000,

        [Description("")]
        tlbChangeDiagnosisHistory = 706820000000,

        [Description("Case Contact Persons")]
        tlbContactedCasePerson = 75500000000,

        [Description("")]
        tlbDepartment = 50815890000000,

        [Description("Employees")]
        tlbEmployee = 75520000000,

        [Description("Employee Groups")]
        tlbEmployeeGroup = 75530000000,

        [Description("Employee Group Members")]
        tlbEmployeeGroupMember = 75540000000,

        [Description("Farms")]
        tlbFarm = 75550000000,

        [Description("")]
        tlbFarmActual = 4572790000000,

        [Description("Freezers")]
        tlbFreezer = 75560000000,

        [Description("Freezer Subdivisions")]
        tlbFreezerSubdivision = 75570000000,

        [Description("Address/Geo Location")]
        tlbGeoLocation = 75580000000,

        [Description("")]
        tlbGeoLocationShared = 4572590000000,

        [Description("Heards")]
        tlbHerd = 75590000000,

        [Description("")]
        tlbHerdActual = 4573120000000,

        [Description("Human/Patient")]
        tlbHuman = 75600000000,

        [Description("")]
        tlbHumanActual = 4573200000000,

        [Description("Human Cases")]
        tlbHumanCase = 75610000000,

        [Description("Samples collected from human/animal patient")]
        tlbMaterial = 75620000000,

        [Description("")]
        tlbMonitoringSession = 707040000000,

        [Description("")]
        tlbMonitoringSessionAction = 708220000000,

        [Description("")]
        tlbMonitoringSessionSummary = 4578950000000,

        [Description("")]
        tlbMonitoringSessionSummaryDiagnosis = 4579090000000,

        [Description("")]
        tlbMonitoringSessionSummarySample = 4579050000000,

        [Description("")]
        tlbMonitoringSessionToDiagnosis = 707150000000,

        [Description("Flex-form filled out instances")]
        tlbObservation = 75640000000,

        [Description("Offices")]
        tlbOffice = 75650000000,

        [Description("Outbreaks")]
        tlbOutbreak = 75660000000,

        [Description("")]
        tlbOutbreakNote = 707190000000,

        [Description("Penside tests")]
        tlbPensideTest = 75680000000,

        [Description("Staff Persons (Officers)")]
        tlbPerson = 75690000000,

        [Description("Postal Codes")]
        tlbPostalCode = 75700000000,

        [Description("")]
        tlbSpecies = 75710000000,

        [Description("")]
        tlbSpeciesActual = 4573370000000,

        [Description("Statistics")]
        tlbStatistic = 75720000000,

        [Description("Streets")]
        tlbStreet = 75730000000,

        [Description("")]
        tlbTestAmendmentHistory = 4578430000000,

        [Description("Assigned tests information")]
        tlbTesting = 75740000000,

        [Description("Test interpretation/validation results")]
        tlbTestValidation = 75750000000,

        [Description("Container transfers out (to another lab/site)")]
        tlbTransferOUT = 75770000000,

        [Description("")]
        tlbTransferOutMaterial = 4576460000000,

        [Description("Vaccinations")]
        tlbVaccination = 75790000000,

        [Description("")]
        tlbVector = 4575310000000,

        [Description("")]
        tlbVectorSurveillanceSession = 4575210000000,

        [Description("")]
        tlbVectorSurveillanceSessionSummary = 12666920000000,

        [Description("")]
        tlbVectorSurveillanceSessionSummaryDiagnosis = 12667010000000,

        [Description("Veterinary Cases")]
        tlbVetCase = 75800000000,

        [Description("")]
        tlbVetCaseDisplayDiagnosis = 12014680000000,

        [Description("Veterinary Case log")]
        tlbVetCaseLog = 75810000000,

        [Description("Base Reference (translatable) table ")]
        trtBaseReference = 75820000000,

        [Description("")]
        trtBssAggregateColumns = 50815360000000,

        [Description("")]
        trtCollectionMethodForVectorType = 4575710000000,

        [Description("")]
        trtDerivativeForSampleType = 740850000000,

        [Description("Diagnosis")]
        trtDiagnosis = 75840000000,

        [Description("")]
        trtDiagnosisAgeGroup = 12014510000000,

        [Description("")]
        trtDiagnosisAgeGroupToDiagnosis = 12014600000000,

        [Description("")]
        trtDiagnosisAgeGroupToStatisticalAgeGroup = 49545320000000,

        [Description("")]
        trtDiagnosisToDiagnosisGroup = 12675270000000,

        [Description("")]
        trtDiagnosisToGroupForReportType = 749130000000,

        [Description("Event types")]
        trtEventType = 75850000000,

        [Description("")]
        trtFFObjectForCustomReport = 51577140000000,

        [Description("")]
        trtFFObjectToDiagnosisForCustomReport = 51577190000000,

        [Description("")]
        trtFFParameterToDiagnosisForCustomReport = 9295740000000,

        [Description("")]
        trtHACodeList = 75860000000,

        [Description("")]
        trtLanguageToCountry = 12666850000000,

        [Description("Samples recommended for collection in case of a certain diagnosis")]
        trtMaterialForDisease = 75880000000,

        [Description("Links between object type and available operation")]
        trtObjectTypeToObjectOperation = 75890000000,

        [Description("Links between object types")]
        trtObjectTypeToObjectType = 75900000000,

        [Description("")]
        trtPensideTestForDisease = 6617430000000,

        [Description("")]
        trtPensideTestTypeForVectorType = 4575760000000,

        [Description("")]
        trtPensideTestTypeToTestResult = 75910000000,

        [Description("")]
        trtProphilacticAction = 75920000000,

        [Description("Reference types")]
        trtReferenceType = 75930000000,

        [Description("")]
        trtReportDiagnosisGroup = 12675320000000,

        [Description("")]
        trtReportRows = 749170000000,

        [Description("")]
        trtSampleType = 746920000000,

        [Description("")]
        trtSampleTypeForVectorType = 4575660000000,

        [Description("")]
        trtSanitaryAction = 75940000000,

        [Description("")]
        trtSpeciesContentInCustomReport = 51577590000000,

        [Description("")]
        trtSpeciesGroup = 51577510000000,

        [Description("")]
        trtSpeciesToGroupForCustomReport = 51577540000000,

        [Description("")]
        trtSpeciesType = 75960000000,

        [Description("Animal age types for animal species")]
        trtSpeciesTypeToAnimalAge = 75970000000,

        [Description("Statistic data types")]
        trtStatisticDataType = 75980000000,

        [Description("Base reference translated values")]
        trtStringNameTranslation = 75990000000,

        [Description("")]
        trtSystemFunction = 76000000000,

        [Description("Tests recommended for a certain diagnosis")]
        trtTestForDisease = 76010000000,

        [Description("")]
        trtTestTypeForCustomReport = 9294210000000,

        [Description("")]
        trtTestTypeToTestResult = 76020000000,

        [Description("")]
        trtVectorSubType = 4575570000000,

        [Description("")]
        trtVectorType = 4575620000000,

        [Description("")]
        tstAggrSetting = 76030000000,

        [Description("")]
        tstBarcodeLayout = 4575820000000,

        [Description("")]
        tstEvent = 76040000000,

        [Description("")]
        tstEventSubscription = 76050000000,

        [Description("")]
        tstGeoLocationFormat = 51523320000000,

        [Description("")]
        tstGlobalSiteOptions = 76220000000,

        [Description("")]
        tstLocalClient = 76090000000,

        [Description("")]
        tstLocalConnectionContext = 76100000000,

        [Description("")]
        tstLocalSiteOptions = 76110000000,

        [Description("ID Creation table")]
        tstNewID = 76120000000,

        [Description("Next ID Creation rules")]
        tstNextNumbers = 76130000000,

        [Description("Notifications")]
        tstNotification = 76140000000,

        [Description("Notification status")]
        tstNotificationStatus = 76150000000,

        [Description("Object access")]
        tstObjectAccess = 76160000000,

        [Description("")]
        tstSecurityConfiguration = 76230000000,

        [Description("")]
        tstSecurityConfigurationAlphabet = 76240000000,

        [Description("")]
        tstSecurityConfigurationAlphabetParticipation = 76250000000,

        [Description("Sites")]
        tstSite = 76170000000,

        [Description("Site relations")]
        tstSiteRelation = 76180000000,

        [Description("Users")]
        tstUserTable = 76190000000,

        [Description("Old passwords")]
        tstUserTableOldPassword = 76200000000,

        [Description("Valid Version pairs (db/client)")]
        tstVersionCompare = 76210000000

    }

    /// <summary>
    /// Column audit event enumeration
    /// </summary>
    public enum AuditColumnEnum : long
    {
        None=0,
        [Description("Decoration element identifier")]
        ffDecorElement_idfDecorElement = 76240000000,

        [Description("Decoration element type identifier (line or label)")]
        ffDecorElement_idfsDecorElementType = 76250000000,

        [Description("Template identifier")]
        ffDecorElement_idfsFormTemplate = 76260000000,

        [Description("Language identifier")]
        ffDecorElement_idfsLanguage = 76270000000,

        [Description("Section identifier")]
        ffDecorElement_idfsSection = 76280000000,

        [Description("Line orientation (IsVertical : true - vertical, false - horizontal)")]
        ffDecorElementLine_blnOrientation = 76290000000,

        [Description("Line decoration element identifier")]
        ffDecorElementLine_idfDecorElement = 76300000000,

        [Description("Line color")]
        ffDecorElementLine_intColor = 76310000000,

        [Description("")]
        ffDecorElementLine_intHeight = 4577310000000,

        [Description("")]
        ffDecorElementLine_intLeft = 4577280000000,

        [Description("")]
        ffDecorElementLine_intTop = 4577290000000,

        [Description("")]
        ffDecorElementLine_intWidth = 4577300000000,

        [Description("Label decoration element identifier")]
        ffDecorElementText_idfDecorElement = 76330000000,

        [Description("Label translation identifier")]
        ffDecorElementText_idfsBaseReference = 76340000000,

        [Description("Font color")]
        ffDecorElementText_intColor = 76350000000,

        [Description("Font size")]
        ffDecorElementText_intFontSize = 76360000000,

        [Description("Font style")]
        ffDecorElementText_intFontStyle = 76370000000,

        [Description("Label text placeholder height")]
        ffDecorElementText_intHeight = 76380000000,

        [Description("")]
        ffDecorElementText_intLeft = 4577320000000,

        [Description("")]
        ffDecorElementText_intTop = 4577330000000,

        [Description("Label text placeholder width")]
        ffDecorElementText_intWidth = 76390000000,

        [Description("Template type identifier")]
        ffDeterminantType_idfsFormType = 76400000000,

        [Description("Reference type identifier")]
        ffDeterminantType_idfsReferenceType = 76410000000,

        [Description("Order number")]
        ffDeterminantType_intOrder = 76420000000,

        [Description("")]
        ffDeterminantValue_idfDeterminantValue = 4577340000000,

        [Description("")]
        ffDeterminantValue_idfsBaseReference = 4577350000000,

        [Description("Template identifier")]
        ffDeterminantValue_idfsFormTemplate = 76430000000,

        [Description("")]
        ffDeterminantValue_idfsGISBaseReference = 4577360000000,

        [Description("Flag - template is used by default")]
        ffFormTemplate_blnUNI = 76440000000,

        [Description("Template identifier")]
        ffFormTemplate_idfsFormTemplate = 76450000000,

        [Description("Template type identifier")]
        ffFormTemplate_idfsFormType = 76460000000,

        [Description("Template notes")]
        ffFormTemplate_strNote = 76470000000,

        [Description("Editor type identifier")]
        ffParameter_idfsEditor = 76480000000,

        [Description("Parameter form type identifier (can be used only in a template of this type)")]
        ffParameter_idfsFormType = 76490000000,

        [Description("Parameter identifier")]
        ffParameter_idfsParameter = 76500000000,

        [Description("Parameter caption identifier")]
        ffParameter_idfsParameterCaption = 76510000000,

        [Description("Parameter type identifier")]
        ffParameter_idfsParameterType = 76520000000,

        [Description("Containing Section identifier")]
        ffParameter_idfsSection = 76530000000,

        [Description("Human/Animal code")]
        ffParameter_intHACode = 76540000000,

        [Description("Order in the section")]
        ffParameter_intOrder = 76550000000,

        [Description("Parameter notes")]
        ffParameter_strNote = 76560000000,

        [Description("Parameter design option identifier")]
        ffParameterDesignOption_idfParameterDesignOption = 76570000000,

        [Description("Affected template identifier (null - used by default)")]
        ffParameterDesignOption_idfsFormTemplate = 76580000000,

        [Description("Affected language identifier (default - EN)")]
        ffParameterDesignOption_idfsLanguage = 76590000000,

        [Description("Parameter identifier")]
        ffParameterDesignOption_idfsParameter = 76600000000,

        [Description("Height")]
        ffParameterDesignOption_intHeight = 76610000000,

        [Description("Label size")]
        ffParameterDesignOption_intLabelSize = 76620000000,

        [Description("Left indent")]
        ffParameterDesignOption_intLeft = 76630000000,

        [Description("Order in grid (used only for grid sections)")]
        ffParameterDesignOption_intOrder = 76640000000,

        [Description("Label is on the (0 - left, 1 - right, 2 - top, 3- bottom)")]
        ffParameterDesignOption_intScheme = 76650000000,

        [Description("Top indent")]
        ffParameterDesignOption_intTop = 76660000000,

        [Description("Width")]
        ffParameterDesignOption_intWidth = 76670000000,

        [Description("Translated value identifier")]
        ffParameterFixedPresetValue_idfsParameterFixedPresetValue = 76680000000,

        [Description("Parameter type identifier")]
        ffParameterFixedPresetValue_idfsParameterType = 76690000000,

        [Description("")]
        ffParameterForAction_idfParameterForAction = 4577370000000,

        [Description("Template identifier")]
        ffParameterForAction_idfsFormTemplate = 76700000000,

        [Description("Parameter identifier")]
        ffParameterForAction_idfsParameter = 76710000000,

        [Description("")]
        ffParameterForAction_idfsRule = 4577390000000,

        [Description("")]
        ffParameterForAction_idfsRuleAction = 4577380000000,

        [Description("")]
        ffParameterForFunction_idfParameterForFunction = 4577400000000,

        [Description("Template identifier")]
        ffParameterForFunction_idfsFormTemplate = 76720000000,

        [Description("Paramenter identifier")]
        ffParameterForFunction_idfsParameter = 76730000000,

        [Description("")]
        ffParameterForFunction_idfsRule = 4577410000000,

        [Description("Order in function")]
        ffParameterForFunction_intOrder = 76740000000,

        [Description("")]
        ffParameterForTemplate_blnFreeze = 4577420000000,

        [Description("Edit mode identifier (read-only/mandatory/…)")]
        ffParameterForTemplate_idfsEditMode = 76750000000,

        [Description("Template identifier")]
        ffParameterForTemplate_idfsFormTemplate = 76760000000,

        [Description("Parameter identifier")]
        ffParameterForTemplate_idfsParameter = 76770000000,

        [Description("Parameter type identifier")]
        ffParameterType_idfsParameterType = 76780000000,

        [Description("Reference type identifier")]
        ffParameterType_idfsReferenceType = 76790000000,

        [Description("")]
        ffRule_blnNot = 4577450000000,

        [Description("")]
        ffRule_idfsCheckPoint = 4577430000000,

        [Description("Template identifier")]
        ffRule_idfsFormTemplate = 76800000000,

        [Description("Rule identifier")]
        ffRule_idfsRule = 76810000000,

        [Description("")]
        ffRule_idfsRuleFunction = 4577440000000,

        [Description("Message identifier")]
        ffRule_idfsRuleMessage = 76820000000,

        [Description("")]
        ffRuleConstant_idfRuleConstant = 4577460000000,

        [Description("")]
        ffRuleConstant_idfsRule = 4577470000000,

        [Description("")]
        ffRuleConstant_varConstant = 4577480000000,

        [Description("Function identifier")]
        ffRuleFunction_idfsRuleFunction = 76830000000,

        [Description("Number of accepted parameters")]
        ffRuleFunction_intNumberOfParameters = 76840000000,

        [Description("")]
        ffSection_blnFixedRowSet = 4577490000000,

        [Description("Flag - Is Grid section")]
        ffSection_blnGrid = 76850000000,

        [Description("Template type identifier")]
        ffSection_idfsFormType = 76860000000,

        [Description("")]
        ffSection_idfsMatrixType = 12666760000000,

        [Description("Parent section identifier")]
        ffSection_idfsParentSection = 76870000000,

        [Description("Section identifier")]
        ffSection_idfsSection = 76880000000,

        [Description("Order in tree/list")]
        ffSection_intOrder = 76890000000,

        [Description("Section design option identifier")]
        ffSectionDesignOption_idfSectionDesignOption = 76900000000,

        [Description("Affected template identifier (null - used by default)")]
        ffSectionDesignOption_idfsFormTemplate = 76910000000,

        [Description("Affected language identifier (default - EN)")]
        ffSectionDesignOption_idfsLanguage = 76920000000,

        [Description("Section identifier")]
        ffSectionDesignOption_idfsSection = 76930000000,

        [Description("")]
        ffSectionDesignOption_intCaptionHeight = 749080000000,

        [Description("Section Height")]
        ffSectionDesignOption_intHeight = 76940000000,

        [Description("Left indent")]
        ffSectionDesignOption_intLeft = 76950000000,

        [Description("Order in grid (used only for grid sections)")]
        ffSectionDesignOption_intOrder = 76960000000,

        [Description("Top indent")]
        ffSectionDesignOption_intTop = 76970000000,

        [Description("Section Width")]
        ffSectionDesignOption_intWidth = 76980000000,

        [Description("")]
        ffSectionForAction_idfSectionForAction = 4577500000000,

        [Description("Template identifier")]
        ffSectionForAction_idfsFormTemplate = 76990000000,

        [Description("Rule identifier")]
        ffSectionForAction_idfsRule = 77000000000,

        [Description("")]
        ffSectionForAction_idfsRuleAction = 4577510000000,

        [Description("Section identifier")]
        ffSectionForAction_idfsSection = 77010000000,

        [Description("Flag - Is Freezed (used only for Grid Sections)")]
        ffSectionForTemplate_blnFreeze = 77020000000,

        [Description("Template identifier")]
        ffSectionForTemplate_idfsFormTemplate = 77030000000,

        [Description("Section identifier")]
        ffSectionForTemplate_idfsSection = 77040000000,

        [Description("GIS reference value identifier")]
        gisBaseReference_idfsGISBaseReference = 77050000000,

        [Description("GIS reference type identifier")]
        gisBaseReference_idfsGISReferenceType = 77060000000,

        [Description("Order in lists/lookups")]
        gisBaseReference_intOrder = 77070000000,

        [Description("Legacy string identifier for value")]
        gisBaseReference_strBaseReferenceCode = 77080000000,

        [Description("Default value")]
        gisBaseReference_strDefault = 77090000000,

        [Description("Country identifier")]
        gisCountry_idfsCountry = 77100000000,

        [Description("code")]
        gisCountry_strCode = 77110000000,

        [Description("Country HASC code")]
        gisCountry_strHASC = 77120000000,

        [Description("Country identifier")]
        gisRayon_idfsCountry = 77130000000,

        [Description("Rayon identifier")]
        gisRayon_idfsRayon = 77140000000,

        [Description("Region identifier")]
        gisRayon_idfsRegion = 77150000000,

        [Description("code")]
        gisRayon_strCode = 77160000000,

        [Description("Rayon HASC code")]
        gisRayon_strHASC = 77170000000,

        [Description("GIS reference type identifier")]
        gisReferenceType_idfsGISReferenceType = 77180000000,

        [Description("Legacy GIS reference type string identifier")]
        gisReferenceType_strGISReferenceTypeCode = 77190000000,

        [Description("GIS reference type name")]
        gisReferenceType_strGISReferenceTypeName = 77200000000,

        [Description("Country identifier")]
        gisRegion_idfsCountry = 77210000000,

        [Description("Region identifier")]
        gisRegion_idfsRegion = 77220000000,

        [Description("code")]
        gisRegion_strCode = 77230000000,

        [Description("Region HASC code")]
        gisRegion_strHASC = 77240000000,

        [Description("")]
        gisSettlement_blnIsCustomSettlement = 4579140000000,

        [Description("Latitude")]
        gisSettlement_dblLatitude = 77250000000,

        [Description("Longitude")]
        gisSettlement_dblLongitude = 77260000000,

        [Description("Country identifier")]
        gisSettlement_idfsCountry = 77270000000,

        [Description("Rayon identifier")]
        gisSettlement_idfsRayon = 77280000000,

        [Description("Region identifier")]
        gisSettlement_idfsRegion = 77290000000,

        [Description("Settlement identifier")]
        gisSettlement_idfsSettlement = 77300000000,

        [Description("Settlement type identifier")]
        gisSettlement_idfsSettlementType = 77310000000,

        [Description("")]
        gisSettlement_intElevation = 12675380000000,

        [Description("")]
        gisSettlement_strSettlementCode = 4579130000000,

        [Description("GIS reference value identifier")]
        gisStringNameTranslation_idfsGISBaseReference = 77320000000,

        [Description("Language identifier")]
        gisStringNameTranslation_idfsLanguage = 77330000000,

        [Description("Translated value in specified language ")]
        gisStringNameTranslation_strTextString = 77340000000,

        [Description("")]
        locBaseReference_idflBaseReference = 4573480000000,

        [Description("")]
        locStringNameTranslation_idflBaseReference = 4573500000000,

        [Description("")]
        locStringNameTranslation_idfsLanguage = 4573510000000,

        [Description("")]
        locStringNameTranslation_strTextString = 4573520000000,

        [Description("")]
        tasglLayout_blnApplyPivotGridFilter = 50815610000000,

        [Description("")]
        tasglLayout_blnCompactPivotGrid = 50815630000000,

        [Description("")]
        tasglLayout_blnFreezeRowHeaders = 50815640000000,

        [Description("")]
        tasglLayout_blnReadOnly = 4573590000000,

        [Description("")]
        tasglLayout_blnShareLayout = 4573710000000,

        [Description("")]
        tasglLayout_blnShowColGrandTotals = 4573670000000,

        [Description("")]
        tasglLayout_blnShowColsTotals = 4573650000000,

        [Description("")]
        tasglLayout_blnShowForSingleTotals = 4573690000000,

        [Description("")]
        tasglLayout_blnShowMissedValuesInPivotGrid = 50815660000000,

        [Description("")]
        tasglLayout_blnShowRowGrandTotals = 4573680000000,

        [Description("")]
        tasglLayout_blnShowRowsTotals = 4573660000000,

        [Description("")]
        tasglLayout_blnUseArchivedData = 50815650000000,

        [Description("")]
        tasglLayout_idfsDefaultGroupDate = 50815600000000,

        [Description("")]
        tasglLayout_idfsDescription = 4573580000000,

        [Description("")]
        tasglLayout_idfsLayout = 4573540000000,

        [Description("")]
        tasglLayout_idfsLayoutFolder = 4573560000000,

        [Description("")]
        tasglLayout_idfsQuery = 4573550000000,

        [Description("")]
        tasglLayout_idfUserID = 4573570000000,

        [Description("")]
        tasglLayout_intGisLayerPosition = 50815670000000,

        [Description("")]
        tasglLayout_intPivotGridXmlVersion = 50815620000000,

        [Description("")]
        tasglLayoutFolder_blnReadOnly = 4573920000000,

        [Description("")]
        tasglLayoutFolder_idfsLayoutFolder = 4573890000000,

        [Description("")]
        tasglLayoutFolder_idfsParentLayoutFolder = 4573900000000,

        [Description("")]
        tasglLayoutFolder_idfsQuery = 4573910000000,

        [Description("")]
        tasglQuery_blnAddAllKeyFieldValues = 4574060000000,

        [Description("")]
        tasglQuery_blnReadOnly = 4574050000000,

        [Description("")]
        tasglQuery_blnSubQuery = 50815680000000,

        [Description("")]
        tasglQuery_idfsDescription = 4574040000000,

        [Description("")]
        tasglQuery_idfsQuery = 4574020000000,

        [Description("")]
        tasglQuery_strFunctionName = 4574030000000,

        [Description("")]
        tasglQueryConditionGroup_blnJoinByOr = 4574120000000,

        [Description("")]
        tasglQueryConditionGroup_blnUseNot = 4574130000000,

        [Description("")]
        tasglQueryConditionGroup_idfParentQueryConditionGroup = 4574100000000,

        [Description("")]
        tasglQueryConditionGroup_idfQueryConditionGroup = 4574080000000,

        [Description("")]
        tasglQueryConditionGroup_idfQuerySearchObject = 4574090000000,

        [Description("")]
        tasglQueryConditionGroup_intOrder = 4574110000000,

        [Description("")]
        tasglQuerySearchField_blnShow = 4574170000000,

        [Description("")]
        tasglQuerySearchField_idfQuerySearchField = 4574150000000,

        [Description("")]
        tasglQuerySearchField_idfQuerySearchObject = 4574160000000,

        [Description("")]
        tasglQuerySearchField_idfsParameter = 4574190000000,

        [Description("")]
        tasglQuerySearchField_idfsSearchField = 4574180000000,

        [Description("")]
        tasglQuerySearchFieldCondition_blnUseNot = 4574270000000,

        [Description("")]
        tasglQuerySearchFieldCondition_idfQueryConditionGroup = 4574220000000,

        [Description("")]
        tasglQuerySearchFieldCondition_idfQuerySearchField = 4574230000000,

        [Description("")]
        tasglQuerySearchFieldCondition_idfQuerySearchFieldCondition = 4574210000000,

        [Description("")]
        tasglQuerySearchFieldCondition_intOperatorType = 4574260000000,

        [Description("")]
        tasglQuerySearchFieldCondition_intOrder = 4574250000000,

        [Description("")]
        tasglQuerySearchFieldCondition_strOperator = 4574240000000,

        [Description("")]
        tasglQuerySearchFieldCondition_varValue = 4574280000000,

        [Description("")]
        tasglQuerySearchObject_idfParentQuerySearchObject = 4574330000000,

        [Description("")]
        tasglQuerySearchObject_idfQuerySearchObject = 4574300000000,

        [Description("")]
        tasglQuerySearchObject_idfsQuery = 4574310000000,

        [Description("")]
        tasglQuerySearchObject_idfsSearchObject = 4574320000000,

        [Description("")]
        tasglQuerySearchObject_intOrder = 4574340000000,

        [Description("Flag - Is Read-Only")]
        tasLayout_blnReadOnly = 77350000000,

        [Description("")]
        tasLayout_blnShareLayout = 4574510000000,

        [Description("")]
        tasLayout_blnShowColGrandTotals = 4574470000000,

        [Description("")]
        tasLayout_blnShowColsTotals = 4574450000000,

        [Description("")]
        tasLayout_blnShowForSingleTotals = 4574490000000,

        [Description("")]
        tasLayout_blnShowRowGrandTotals = 4574480000000,

        [Description("")]
        tasLayout_blnShowRowsTotals = 4574460000000,

        [Description("")]
        tasLayout_idflDescription = 4574390000000,

        [Description("")]
        tasLayout_idflLayout = 4574350000000,

        [Description("")]
        tasLayout_idflLayoutFolder = 4574380000000,

        [Description("")]
        tasLayout_idflQuery = 4574370000000,

        [Description("")]
        tasLayout_idfsGlobalLayout = 4574360000000,

        [Description("Identifier of the User who created layout ")]
        tasLayout_idfUserID = 77370000000,

        [Description("")]
        tasLayoutFolder_blnReadOnly = 4574730000000,

        [Description("")]
        tasLayoutFolder_idflLayoutFolder = 4574690000000,

        [Description("")]
        tasLayoutFolder_idflParentLayoutFolder = 4574710000000,

        [Description("")]
        tasLayoutFolder_idflQuery = 4574720000000,

        [Description("")]
        tasLayoutFolder_idfsGlobalLayoutFolder = 4574700000000,

        [Description("")]
        tasQuery_blnAddAllKeyFieldValues = 4574830000000,

        [Description("Flag - Is Read-Only")]
        tasQuery_blnReadOnly = 77480000000,

        [Description("")]
        tasQuery_idflDescription = 4574820000000,

        [Description("")]
        tasQuery_idflQuery = 4574800000000,

        [Description("")]
        tasQuery_idfsGlobalQuery = 4574810000000,

        [Description("Physical SQL function name")]
        tasQuery_strFunctionName = 77510000000,

        [Description("Flag - Is join by Or (true - Or, false - And)")]
        tasQueryConditionGroup_blnJoinByOr = 77520000000,

        [Description("Flag - Is Not (true - Not, false - no Not)")]
        tasQueryConditionGroup_blnUseNot = 77530000000,

        [Description("")]
        tasQueryConditionGroup_idfParentQueryConditionGroup = 4574860000000,

        [Description("")]
        tasQueryConditionGroup_idfQueryConditionGroup = 4574840000000,

        [Description("")]
        tasQueryConditionGroup_idfQuerySearchObject = 4574850000000,

        [Description("Order in group")]
        tasQueryConditionGroup_intOrder = 77540000000,

        [Description("")]
        tasQuerySearchField_blnShow = 4574890000000,

        [Description("")]
        tasQuerySearchField_idfQuerySearchField = 4574870000000,

        [Description("")]
        tasQuerySearchField_idfQuerySearchObject = 4574880000000,

        [Description("Flex-form parameter identifier")]
        tasQuerySearchField_idfsParameter = 77550000000,

        [Description("Field identifier")]
        tasQuerySearchField_idfsSearchField = 77560000000,

        [Description("")]
        tasQuerySearchFieldCondition_blnUseNot = 4574960000000,

        [Description("")]
        tasQuerySearchFieldCondition_idfQueryConditionGroup = 4574910000000,

        [Description("")]
        tasQuerySearchFieldCondition_idfQuerySearchField = 4574920000000,

        [Description("")]
        tasQuerySearchFieldCondition_idfQuerySearchFieldCondition = 4574900000000,

        [Description("")]
        tasQuerySearchFieldCondition_intOperatorType = 4574950000000,

        [Description("")]
        tasQuerySearchFieldCondition_intOrder = 4574940000000,

        [Description("")]
        tasQuerySearchFieldCondition_strOperator = 4574930000000,

        [Description("")]
        tasQuerySearchFieldCondition_varValue = 4574970000000,

        [Description("")]
        tasQuerySearchObject_idflQuery = 4574990000000,

        [Description("")]
        tasQuerySearchObject_idfParentQuerySearchObject = 4575010000000,

        [Description("")]
        tasQuerySearchObject_idfQuerySearchObject = 4574980000000,

        [Description("")]
        tasQuerySearchObject_idfsSearchObject = 4575000000000,

        [Description("")]
        tasQuerySearchObject_intOrder = 4575020000000,

        [Description("")]
        tasSearchField_blnAllowMissedReferenceValues = 51523480000000,

        [Description("")]
        tasSearchField_blnGeoLocationString = 4579500000000,

        [Description("")]
        tasSearchField_blnShortAddressString = 51523400000000,

        [Description("")]
        tasSearchField_idfsDefaultAggregateFunction = 51523390000000,

        [Description("")]
        tasSearchField_idfsGISReferenceType = 4579200000000,

        [Description("")]
        tasSearchField_idfsReferenceType = 4579190000000,

        [Description("")]
        tasSearchField_idfsSearchField = 4579160000000,

        [Description("")]
        tasSearchField_idfsSearchFieldType = 4579170000000,

        [Description("")]
        tasSearchField_idfsSearchObject = 4579180000000,

        [Description("")]
        tasSearchField_intIncidenceDisplayOrder = 4579240000000,

        [Description("")]
        tasSearchField_intMapDisplayOrder = 4579230000000,

        [Description("")]
        tasSearchField_strCalculatedFieldText = 4579510000000,

        [Description("")]
        tasSearchField_strLookupAttribute = 51523470000000,

        [Description("")]
        tasSearchField_strLookupFunction = 51523440000000,

        [Description("")]
        tasSearchField_strLookupFunctionIdField = 51523450000000,

        [Description("")]
        tasSearchField_strLookupFunctionNameField = 51523460000000,

        [Description("")]
        tasSearchField_strLookupTable = 4579220000000,

        [Description("")]
        tasSearchField_strSearchFieldAlias = 4579210000000,

        [Description("")]
        tasSearchObject_blnPrimary = 4579280000000,

        [Description("")]
        tasSearchObject_blnShowReportType = 50815690000000,

        [Description("")]
        tasSearchObject_idfsFormType = 4579270000000,

        [Description("")]
        tasSearchObject_idfsSearchObject = 4579260000000,

        [Description("")]
        tasSearchObjectToSearchObject_blnUseForSubQuery = 50815740000000,

        [Description("")]
        tasSearchObjectToSearchObject_idfsParentSearchObject = 50815720000000,

        [Description("")]
        tasSearchObjectToSearchObject_idfsRelatedSearchObject = 50815710000000,

        [Description("")]
        tasSearchObjectToSearchObject_strSubQueryJoinCondition = 50815730000000,

        [Description("Column identifier")]
        tauColumn_idfColumn = 77600000000,

        [Description("Containing Table identifier")]
        tauColumn_idfTable = 77610000000,

        [Description("Column description")]
        tauColumn_strDescription = 77620000000,

        [Description("Column name")]
        tauColumn_strName = 77630000000,

        [Description("Detailed information about object creation identifier")]
        tauDataAuditDetailCreate_idfDataAuditDetailCreate = 77640000000,

        [Description("Audit event identifier")]
        tauDataAuditDetailCreate_idfDataAuditEvent = 77650000000,

        [Description("Object identifier")]
        tauDataAuditDetailCreate_idfObject = 77660000000,

        [Description("Corresponding Created object identifier")]
        tauDataAuditDetailCreate_idfObjectDetail = 77670000000,

        [Description("Table identifier")]
        tauDataAuditDetailCreate_idfObjectTable = 77680000000,

        [Description("Detailed information about object deletion identifier")]
        tauDataAuditDetailDelete_idfDataAuditDetailDelete = 77690000000,

        [Description("Audit event identifier")]
        tauDataAuditDetailDelete_idfDataAuditEvent = 77700000000,

        [Description("Object identifier")]
        tauDataAuditDetailDelete_idfObject = 77710000000,

        [Description("Corresponding Deleted object identifier")]
        tauDataAuditDetailDelete_idfObjectDetail = 77720000000,

        [Description("Table identifier")]
        tauDataAuditDetailDelete_idfObjectTable = 77730000000,

        [Description("Changed column identifier")]
        tauDataAuditDetailUpdate_idfColumn = 77740000000,

        [Description("Detailed information about object change identifier")]
        tauDataAuditDetailUpdate_idfDataAuditDetailUpdate = 77750000000,

        [Description("Audit event identifier")]
        tauDataAuditDetailUpdate_idfDataAuditEvent = 77760000000,

        [Description("Object identifier")]
        tauDataAuditDetailUpdate_idfObject = 77770000000,

        [Description("Corresponding Changed object identifier")]
        tauDataAuditDetailUpdate_idfObjectDetail = 77780000000,

        [Description("Table identifier")]
        tauDataAuditDetailUpdate_idfObjectTable = 77790000000,

        [Description("New value")]
        tauDataAuditDetailUpdate_strNewValue = 77800000000,

        [Description("Old value")]
        tauDataAuditDetailUpdate_strOldValue = 77810000000,

        [Description("Date/time of event creation")]
        tauDataAuditEvent_datEnteringDate = 77820000000,

        [Description("Audit event identifier")]
        tauDataAuditEvent_idfDataAuditEvent = 77830000000,

        [Description("Main audit object identifier")]
        tauDataAuditEvent_idfMainObject = 77840000000,

        [Description("Main audit object table identifier")]
        tauDataAuditEvent_idfMainObjectTable = 77850000000,

        [Description("Audit event type")]
        tauDataAuditEvent_idfsDataAuditEventType = 77860000000,

        [Description("Audit object type")]
        tauDataAuditEvent_idfsDataAuditObjectType = 77870000000,

        [Description("User caused audit event identifier")]
        tauDataAuditEvent_idfUserID = 77890000000,

        [Description("Host name caused event")]
        tauDataAuditEvent_strHostname = 77900000000,

        [Description("Audited table identifier")]
        tauTable_idfTable = 77920000000,

        [Description("Description")]
        tauTable_strDescription = 77930000000,

        [Description("Audited table name")]
        tauTable_strName = 77940000000,

        [Description("Date/time of data export operation")]
        tdeDataExport_datExportDate = 77950000000,

        [Description("Data export operation identifier")]
        tdeDataExport_idfDataExport = 77960000000,

        [Description("User initiated data export operation identifier")]
        tdeDataExport_idfUserID = 77970000000,

        [Description("Data export operation notes")]
        tdeDataExport_strNote = 77980000000,

        [Description("Date/time of export performed")]
        tdeDataExportDetail_datActivityDate = 77990000000,

        [Description("Case exported identifier")]
        tdeDataExportDetail_idfCase = 78000000000,

        [Description("Data export operation identifier ")]
        tdeDataExportDetail_idfDataExport = 78010000000,

        [Description("Detailed information identifier")]
        tdeDataExportDetail_idfDataExportDetail = 78020000000,

        [Description("Data export operation type (deletion/addition/change)")]
        tdeDataExportDetail_idfsDataExportDetailStatus = 78030000000,

        [Description("Exported case Diagnosis identifier")]
        tdeDataExportDetail_idfsDiagnosis = 78040000000,

        [Description("Hash-stamp of the case exported data")]
        tdeDataExportDetail_strXMLActivityHash = 78050000000,

        [Description("Export operation identifier")]
        tdeDataExportDiagnosis_idfDataExport = 78060000000,

        [Description("Diagnosis identifier")]
        tdeDataExportDiagnosis_idfsDiagnosis = 78070000000,

        [Description("Exported case identifier")]
        tdeDataExportProblem_idfCase = 78080000000,

        [Description("Export operation identifier")]
        tdeDataExportProblem_idfDataExport = 78090000000,

        [Description("Data export problem identifier")]
        tdeDataExportProblem_idfDataExportProblem = 78100000000,

        [Description("Text description of the problem")]
        tdeDataExportProblem_strDetail = 78110000000,

        [Description("")]
        tlbActivityParameters_idfActivityParameters = 4576580000000,

        [Description("Flex-Form instance identifier")]
        tlbActivityParameters_idfObservation = 78170000000,

        [Description("")]
        tlbActivityParameters_idfRow = 4576590000000,

        [Description("Flex-Form Parameter identifier")]
        tlbActivityParameters_idfsParameter = 78180000000,

        [Description("Flex-Form parameter value")]
        tlbActivityParameters_varValue = 78190000000,

        [Description("Date/time entered")]
        tlbAggrCase_datEnteredByDate = 78200000000,

        [Description("End of perion Date/time")]
        tlbAggrCase_datFinishDate = 78210000000,

        [Description("Date/time received")]
        tlbAggrCase_datReceivedByDate = 78220000000,

        [Description("Date/time sent")]
        tlbAggrCase_datSentByDate = 78230000000,

        [Description("Beginning of perion Date/time ")]
        tlbAggrCase_datStartDate = 78240000000,

        [Description("Aggregate case identifier")]
        tlbAggrCase_idfAggrCase = 78250000000,

        [Description("")]
        tlbAggrCase_idfCaseObservation = 4577590000000,

        [Description("")]
        tlbAggrCase_idfDiagnosticObservation = 4577600000000,

        [Description("")]
        tlbAggrCase_idfDiagnosticVersion = 4577640000000,

        [Description("")]
        tlbAggrCase_idfEnteredByOffice = 4577570000000,

        [Description("")]
        tlbAggrCase_idfEnteredByPerson = 4577580000000,

        [Description("")]
        tlbAggrCase_idfProphylacticObservation = 4577610000000,

        [Description("")]
        tlbAggrCase_idfProphylacticVersion = 4577650000000,

        [Description("")]
        tlbAggrCase_idfReceivedByOffice = 4577530000000,

        [Description("")]
        tlbAggrCase_idfReceivedByPerson = 4577540000000,

        [Description("")]
        tlbAggrCase_idfsAdministrativeUnit = 4577520000000,

        [Description("Aggregate case type")]
        tlbAggrCase_idfsAggrCaseType = 78260000000,

        [Description("")]
        tlbAggrCase_idfSanitaryObservation = 4577620000000,

        [Description("")]
        tlbAggrCase_idfSanitaryVersion = 4577660000000,

        [Description("")]
        tlbAggrCase_idfSentByOffice = 4577550000000,

        [Description("")]
        tlbAggrCase_idfSentByPerson = 4577560000000,

        [Description("")]
        tlbAggrCase_idfVersion = 4577630000000,

        [Description("")]
        tlbAggrCase_strCaseID = 4577670000000,

        [Description("")]
        tlbAggrDiagnosticActionMTX_idfAggrDiagnosticActionMTX = 4577680000000,

        [Description("")]
        tlbAggrDiagnosticActionMTX_idfsDiagnosis = 4577700000000,

        [Description("")]
        tlbAggrDiagnosticActionMTX_idfsDiagnosticAction = 4577710000000,

        [Description("")]
        tlbAggrDiagnosticActionMTX_idfsSpeciesType = 4577690000000,

        [Description("")]
        tlbAggrDiagnosticActionMTX_idfVersion = 12666600000000,

        [Description("")]
        tlbAggrDiagnosticActionMTX_intNumRow = 12666610000000,

        [Description("")]
        tlbAggrHumanCaseMTX_idfAggrHumanCaseMTX = 12666630000000,

        [Description("")]
        tlbAggrHumanCaseMTX_idfsDiagnosis = 12666650000000,

        [Description("")]
        tlbAggrHumanCaseMTX_idfVersion = 12666640000000,

        [Description("")]
        tlbAggrHumanCaseMTX_intNumRow = 12666660000000,

        [Description("")]
        tlbAggrMatrixVersionHeader_blnIsActive = 707380000000,

        [Description("")]
        tlbAggrMatrixVersionHeader_blnIsDefault = 840870000000,

        [Description("")]
        tlbAggrMatrixVersionHeader_datStartDate = 707370000000,

        [Description("")]
        tlbAggrMatrixVersionHeader_idfsMatrixType = 12666590000000,

        [Description("")]
        tlbAggrMatrixVersionHeader_idfVersion = 707340000000,

        [Description("")]
        tlbAggrMatrixVersionHeader_MatrixName = 707360000000,

        [Description("")]
        tlbAggrProphylacticActionMTX_idfAggrProphylacticActionMTX = 4577720000000,

        [Description("")]
        tlbAggrProphylacticActionMTX_idfsDiagnosis = 4577740000000,

        [Description("")]
        tlbAggrProphylacticActionMTX_idfsProphilacticAction = 4577750000000,

        [Description("")]
        tlbAggrProphylacticActionMTX_idfsSpeciesType = 4577730000000,

        [Description("")]
        tlbAggrProphylacticActionMTX_idfVersion = 12666670000000,

        [Description("")]
        tlbAggrProphylacticActionMTX_intNumRow = 12666680000000,

        [Description("")]
        tlbAggrSanitaryActionMTX_idfAggrSanitaryActionMTX = 12666700000000,

        [Description("")]
        tlbAggrSanitaryActionMTX_idfsSanitaryAction = 12666720000000,

        [Description("")]
        tlbAggrSanitaryActionMTX_idfVersion = 12666710000000,

        [Description("")]
        tlbAggrSanitaryActionMTX_intNumRow = 12666730000000,

        [Description("")]
        tlbAggrVetCaseMTX_idfAggrVetCaseMTX = 4577760000000,

        [Description("")]
        tlbAggrVetCaseMTX_idfsDiagnosis = 4577780000000,

        [Description("")]
        tlbAggrVetCaseMTX_idfsSpeciesType = 4577770000000,

        [Description("")]
        tlbAggrVetCaseMTX_idfVersion = 12666740000000,

        [Description("")]
        tlbAggrVetCaseMTX_intNumRow = 12666750000000,

        [Description("Animal identifier")]
        tlbAnimal_idfAnimal = 78270000000,

        [Description("Assocciated flex-form identifier")]
        tlbAnimal_idfObservation = 78280000000,

        [Description("Animal age identifier")]
        tlbAnimal_idfsAnimalAge = 78290000000,

        [Description("Animal condition identifier")]
        tlbAnimal_idfsAnimalCondition = 78300000000,

        [Description("Animal gender identifier")]
        tlbAnimal_idfsAnimalGender = 78310000000,

        [Description("Animal species identifier")]
        tlbAnimal_idfSpecies = 78320000000,

        [Description("Animal code")]
        tlbAnimal_strAnimalCode = 78330000000,

        [Description("")]
        tlbAnimal_strColor = 4572160000000,

        [Description("Description")]
        tlbAnimal_strDescription = 78340000000,

        [Description("")]
        tlbAnimal_strName = 4572150000000,

        [Description("Date/time of beginning of therapy ")]
        tlbAntimicrobialTherapy_datFirstAdministeredDate = 78350000000,

        [Description("")]
        tlbAntimicrobialTherapy_idfAntimicrobialTherapy = 4577790000000,

        [Description("")]
        tlbAntimicrobialTherapy_idfHumanCase = 4577800000000,

        [Description("Therapy name")]
        tlbAntimicrobialTherapy_strAntimicrobialTherapyName = 78360000000,

        [Description("")]
        tlbAntimicrobialTherapy_strDosage = 4577810000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_blnAsthma = 50791550000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_blnCardiovascular = 50791570000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_blnDiabetes = 50791560000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_blnImmunodeficiency = 50791620000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_blnLiver = 50791600000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_blnNeurological = 50791610000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_blnObesity = 50791580000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_blnRenal = 50791590000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_blnRespiratorySystem = 50791540000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_blnUnknownEtiology = 50791630000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_datDateEntered = 50791260000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_datDateLastSaved = 50791270000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_datDateOfCare = 50791460000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_datDateOfSymptomsOnset = 50791390000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_datDateReceivedAntiviralMedication = 50791530000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_datReportDate = 50791310000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_datSampleCollectionDate = 50791640000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_datTestResultDate = 50791670000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_idfBasicSyndromicSurveillance = 50791240000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_idfEnteredBy = 50791280000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_idfHospital = 50791300000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_idfHuman = 50791680000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_idfsBasicSyndromicSurveillanceType = 50791290000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_idfsMethodOfMeasurement = 50791410000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_idfsOutcome = 50791480000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_idfsTestResult = 50791660000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_idfsYNAdministratedAntiviralMedication = 50791510000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_idfsYNCough = 50791430000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_idfsYNFever = 50791400000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_idfsYNPatientWasHospitalized = 50791470000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_idfsYNPatientWasInER = 50791490000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_idfsYNPostpartumPeriod = 50791380000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_idfsYNPregnant = 50791370000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_idfsYNSeasonalFluVaccine = 50791450000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_idfsYNShortnessOfBreath = 50791440000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_idfsYNTreatment = 50791500000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_intAgeFullMonth = 50791350000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_intAgeFullYear = 50791340000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_intAgeMonth = 50791330000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_intAgeYear = 50791320000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_strFormID = 50791250000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_strMethod = 50791420000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_strNameOfMedication = 50791520000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_strPersonalID = 50791360000000,

        [Description("")]
        tlbBasicSyndromicSurveillance_strSampleID = 50791650000000,

        [Description("")]
        tlbBasicSyndromicSurveillanceAggregateDetail_idfAggregateDetail = 50791800000000,

        [Description("")]
        tlbBasicSyndromicSurveillanceAggregateDetail_idfAggregateHeader = 50791810000000,

        [Description("")]
        tlbBasicSyndromicSurveillanceAggregateDetail_idfHospital = 50791820000000,

        [Description("")]
        tlbBasicSyndromicSurveillanceAggregateDetail_intAge0_4 = 50791830000000,

        [Description("")]
        tlbBasicSyndromicSurveillanceAggregateDetail_intAge15_29 = 50791850000000,

        [Description("")]
        tlbBasicSyndromicSurveillanceAggregateDetail_intAge30_64 = 50791860000000,

        [Description("")]
        tlbBasicSyndromicSurveillanceAggregateDetail_intAge5_14 = 50815350000000,

        [Description("")]
        tlbBasicSyndromicSurveillanceAggregateDetail_intAge65 = 50791870000000,

        [Description("")]
        tlbBasicSyndromicSurveillanceAggregateDetail_intILISamples = 50791900000000,

        [Description("")]
        tlbBasicSyndromicSurveillanceAggregateDetail_inTotalILI = 50791880000000,

        [Description("")]
        tlbBasicSyndromicSurveillanceAggregateDetail_intTotalAdmissions = 50791890000000,

        [Description("")]
        tlbBasicSyndromicSurveillanceAggregateHeader_datDateEntered = 50791720000000,

        [Description("")]
        tlbBasicSyndromicSurveillanceAggregateHeader_datDateLastSaved = 50791730000000,

        [Description("")]
        tlbBasicSyndromicSurveillanceAggregateHeader_datFinishDate = 50791780000000,

        [Description("")]
        tlbBasicSyndromicSurveillanceAggregateHeader_datStartDate = 50791770000000,

        [Description("")]
        tlbBasicSyndromicSurveillanceAggregateHeader_idfAggregateHeader = 50791700000000,

        [Description("")]
        tlbBasicSyndromicSurveillanceAggregateHeader_idfEnteredBy = 50791740000000,

        [Description("")]
        tlbBasicSyndromicSurveillanceAggregateHeader_intWeek = 50791760000000,

        [Description("")]
        tlbBasicSyndromicSurveillanceAggregateHeader_intYear = 50791750000000,

        [Description("")]
        tlbBasicSyndromicSurveillanceAggregateHeader_strFormID = 50791710000000,

        [Description("")]
        tlbBatchTest_datPerformedDate = 4577850000000,

        [Description("Date/time of the Batch test results validation")]
        tlbBatchTest_datValidatedDate = 78370000000,

        [Description("Batch test identifier")]
        tlbBatchTest_idfBatchTest = 78380000000,

        [Description("Flex-form assocciated with batch identifier")]
        tlbBatchTest_idfObservation = 78390000000,

        [Description("")]
        tlbBatchTest_idfPerformedByOffice = 4577830000000,

        [Description("")]
        tlbBatchTest_idfPerformedByPerson = 4577840000000,

        [Description("")]
        tlbBatchTest_idfResultEnteredByOffice = 6617400000000,

        [Description("")]
        tlbBatchTest_idfResultEnteredByPerson = 6617390000000,

        [Description("")]
        tlbBatchTest_idfsBatchStatus = 4577820000000,

        [Description("")]
        tlbBatchTest_idfsTestName = 49545490000000,

        [Description("Institution validated test results identifier")]
        tlbBatchTest_idfValidatedByOffice = 78410000000,

        [Description("Officer validated test results identifier")]
        tlbBatchTest_idfValidatedByPerson = 78420000000,

        [Description("")]
        tlbBatchTest_strBarcode = 4577860000000,

        [Description("")]
        tlbCampaign_datCampaignDateEnd = 706950000000,

        [Description("")]
        tlbCampaign_datCampaignDateStart = 706940000000,

        [Description("")]
        tlbCampaign_idfCampaign = 706910000000,

        [Description("")]
        tlbCampaign_idfsCampaignStatus = 706930000000,

        [Description("")]
        tlbCampaign_idfsCampaignType = 706920000000,

        [Description("")]
        tlbCampaign_strCampaignAdministrator = 706980000000,

        [Description("")]
        tlbCampaign_strCampaignID = 706960000000,

        [Description("")]
        tlbCampaign_strCampaignName = 706970000000,

        [Description("")]
        tlbCampaign_strComments = 706990000000,

        [Description("")]
        tlbCampaignToDiagnosis_idfCampaign = 707010000000,

        [Description("")]
        tlbCampaignToDiagnosis_idfCampaignToDiagnosis = 749070000000,

        [Description("")]
        tlbCampaignToDiagnosis_idfsDiagnosis = 707020000000,

        [Description("")]
        tlbCampaignToDiagnosis_idfsSampleType = 51586580000000,

        [Description("")]
        tlbCampaignToDiagnosis_idfsSpeciesType = 4578710000000,

        [Description("")]
        tlbCampaignToDiagnosis_intOrder = 707030000000,

        [Description("")]
        tlbCampaignToDiagnosis_intPlannedNumber = 4578660000000,

        [Description("")]
        tlbChangeDiagnosisHistory_datChangedDate = 706880000000,

        [Description("")]
        tlbChangeDiagnosisHistory_idfChangeDiagnosisHistory = 706830000000,

        [Description("")]
        tlbChangeDiagnosisHistory_idfHumanCase = 706840000000,

        [Description("")]
        tlbChangeDiagnosisHistory_idfPerson = 51586560000000,

        [Description("")]
        tlbChangeDiagnosisHistory_idfsChangeDiagnosisReason = 12014640000000,

        [Description("")]
        tlbChangeDiagnosisHistory_idfsCurrentDiagnosis = 706870000000,

        [Description("")]
        tlbChangeDiagnosisHistory_idfsPreviousDiagnosis = 706860000000,

        [Description("")]
        tlbChangeDiagnosisHistory_strReason = 706890000000,

        [Description("Date of last contact")]
        tlbContactedCasePerson_datDateOfLastContact = 78500000000,

        [Description("")]
        tlbContactedCasePerson_idfContactedCasePerson = 4566370000000,

        [Description("Human identifier")]
        tlbContactedCasePerson_idfHuman = 78510000000,

        [Description("")]
        tlbContactedCasePerson_idfHumanCase = 4566380000000,

        [Description("Type of contact identifier")]
        tlbContactedCasePerson_idfsPersonContactType = 78520000000,

        [Description("")]
        tlbContactedCasePerson_strComments = 12675390000000,

        [Description("")]
        tlbContactedCasePerson_strPlaceInfo = 4566390000000,

        [Description("")]
        tlbDepartment_idfDepartment = 50815900000000,

        [Description("")]
        tlbDepartment_idfOrganization = 50815920000000,

        [Description("")]
        tlbDepartment_idfsDepartmentName = 50815910000000,

        [Description("Employee/group identifier")]
        tlbEmployee_idfEmployee = 78640000000,

        [Description("Employee/group type identifier")]
        tlbEmployee_idfsEmployeeType = 78650000000,

        [Description("Group identifier")]
        tlbEmployeeGroup_idfEmployeeGroup = 78670000000,

        [Description("Translated Group name identifier")]
        tlbEmployeeGroup_idfsEmployeeGroupName = 78680000000,

        [Description("Group description")]
        tlbEmployeeGroup_strDescription = 78700000000,

        [Description("Group name")]
        tlbEmployeeGroup_strName = 78710000000,

        [Description("")]
        tlbEmployeeGroupMember_idfEmployee = 4577870000000,

        [Description("Group identifier")]
        tlbEmployeeGroupMember_idfEmployeeGroup = 78720000000,

        [Description("")]
        tlbFarm_datModificationDate = 51389480000000,

        [Description("Farm identifier")]
        tlbFarm_idfFarm = 78750000000,

        [Description("")]
        tlbFarm_idfFarmActual = 4572170000000,

        [Description("Farm address identifier")]
        tlbFarm_idfFarmAddress = 78760000000,

        [Description("Farm owner identifier")]
        tlbFarm_idfHuman = 78780000000,

        [Description("")]
        tlbFarm_idfMonitoringSession = 4572180000000,

        [Description("Farm assocciated flex-form identifier")]
        tlbFarm_idfObservation = 78790000000,

        [Description("Avian farm type identifier")]
        tlbFarm_idfsAvianFarmType = 78800000000,

        [Description("Avian production type identifier")]
        tlbFarm_idfsAvianProductionType = 78810000000,

        [Description("Farm category identifier")]
        tlbFarm_idfsFarmCategory = 78820000000,

        [Description("Grazing patter identifier")]
        tlbFarm_idfsGrazingPattern = 78830000000,

        [Description("Farm Production intended use identifier ")]
        tlbFarm_idfsIntendedUse = 78840000000,

        [Description("Livestock production type identifier")]
        tlbFarm_idfsLivestockProductionType = 78850000000,

        [Description("Movement Patter identifier")]
        tlbFarm_idfsMovementPattern = 78860000000,

        [Description("Ownership structure identifier")]
        tlbFarm_idfsOwnershipStructure = 78870000000,

        [Description("")]
        tlbFarm_intAvianDeadAnimalQty = 4572240000000,

        [Description("")]
        tlbFarm_intAvianSickAnimalQty = 4572220000000,

        [Description("")]
        tlbFarm_intAvianTotalAnimalQty = 4572200000000,

        [Description("")]
        tlbFarm_intBirdsPerBuilding = 4572260000000,

        [Description("")]
        tlbFarm_intBuidings = 4572250000000,

        [Description("")]
        tlbFarm_intHACode = 51389470000000,

        [Description("")]
        tlbFarm_intLivestockDeadAnimalQty = 4572230000000,

        [Description("")]
        tlbFarm_intLivestockSickAnimalQty = 4572210000000,

        [Description("")]
        tlbFarm_intLivestockTotalAnimalQty = 4572190000000,

        [Description("phone number")]
        tlbFarm_strContactPhone = 78900000000,

        [Description("e-mail address")]
        tlbFarm_strEmail = 78910000000,

        [Description("Alphanumeric farm code")]
        tlbFarm_strFarmCode = 78920000000,

        [Description("Fax number")]
        tlbFarm_strFax = 78930000000,

        [Description("Internation (english) name of the farm")]
        tlbFarm_strInternationalName = 78940000000,

        [Description("Translated name of the farm")]
        tlbFarm_strNationalName = 78950000000,

        [Description("")]
        tlbFarm_strNote = 4572270000000,

        [Description("")]
        tlbFarmActual_datModificationDate = 51389500000000,

        [Description("")]
        tlbFarmActual_idfFarmActual = 4572800000000,

        [Description("")]
        tlbFarmActual_idfFarmAddress = 4572900000000,

        [Description("")]
        tlbFarmActual_idfHumanActual = 4572890000000,

        [Description("")]
        tlbFarmActual_idfsAvianFarmType = 4572810000000,

        [Description("")]
        tlbFarmActual_idfsAvianProductionType = 4572820000000,

        [Description("")]
        tlbFarmActual_idfsFarmCategory = 4572830000000,

        [Description("")]
        tlbFarmActual_idfsGrazingPattern = 4572870000000,

        [Description("")]
        tlbFarmActual_idfsIntendedUse = 4572860000000,

        [Description("")]
        tlbFarmActual_idfsLivestockProductionType = 4572880000000,

        [Description("")]
        tlbFarmActual_idfsMovementPattern = 4572850000000,

        [Description("")]
        tlbFarmActual_idfsOwnershipStructure = 4572840000000,

        [Description("")]
        tlbFarmActual_intAvianDeadAnimalQty = 4573060000000,

        [Description("")]
        tlbFarmActual_intAvianSickAnimalQty = 4573040000000,

        [Description("")]
        tlbFarmActual_intAvianTotalAnimalQty = 4573020000000,

        [Description("")]
        tlbFarmActual_intBirdsPerBuilding = 4573080000000,

        [Description("")]
        tlbFarmActual_intBuidings = 4573070000000,

        [Description("")]
        tlbFarmActual_intHACode = 51389490000000,

        [Description("")]
        tlbFarmActual_intLivestockDeadAnimalQty = 4573050000000,

        [Description("")]
        tlbFarmActual_intLivestockSickAnimalQty = 4573030000000,

        [Description("")]
        tlbFarmActual_intLivestockTotalAnimalQty = 4573010000000,

        [Description("")]
        tlbFarmActual_strContactPhone = 4572970000000,

        [Description("")]
        tlbFarmActual_strEmail = 4572960000000,

        [Description("")]
        tlbFarmActual_strFarmCode = 4572940000000,

        [Description("")]
        tlbFarmActual_strFax = 4572950000000,

        [Description("")]
        tlbFarmActual_strInternationalName = 4572920000000,

        [Description("")]
        tlbFarmActual_strNationalName = 4572930000000,

        [Description("")]
        tlbFarmActual_strNote = 4573090000000,

        [Description("")]
        tlbFreezer_idfFreezer = 4577880000000,

        [Description("Storage type identifier")]
        tlbFreezer_idfsStorageType = 79000000000,

        [Description("Barcode (alphanumeric inventory code)")]
        tlbFreezer_strBarcode = 79010000000,

        [Description("Storage name")]
        tlbFreezer_strFreezerName = 79020000000,

        [Description("Storage notes")]
        tlbFreezer_strNote = 79030000000,

        [Description("")]
        tlbFreezerSubdivision_idfFreezer = 749100000000,

        [Description("")]
        tlbFreezerSubdivision_idfParentSubdivision = 749110000000,

        [Description("Freezer subdivision type identifier")]
        tlbFreezerSubdivision_idfsSubdivisionType = 79050000000,

        [Description("")]
        tlbFreezerSubdivision_idfSubdivision = 749090000000,

        [Description("")]
        tlbFreezerSubdivision_intCapacity = 749120000000,

        [Description("Subdivision Barcode (alphanumeric inventory code)")]
        tlbFreezerSubdivision_strBarcode = 79060000000,

        [Description("Subdivision name")]
        tlbFreezerSubdivision_strNameChars = 79070000000,

        [Description("Subdivision notes")]
        tlbFreezerSubdivision_strNote = 79080000000,

        [Description("")]
        tlbGeoLocation_blnForeignAddress = 4578780000000,

        [Description("Accuracy")]
        tlbGeoLocation_dblAccuracy = 79090000000,

        [Description("Alignment (used in relative point)")]
        tlbGeoLocation_dblAlignment = 79100000000,

        [Description("Distance from settlement (used in relative point)")]
        tlbGeoLocation_dblDistance = 79110000000,

        [Description("Latitude")]
        tlbGeoLocation_dblLatitude = 79120000000,

        [Description("Longitude")]
        tlbGeoLocation_dblLongitude = 79130000000,

        [Description("Geo location/address identifier")]
        tlbGeoLocation_idfGeoLocation = 79140000000,

        [Description("Country identifier")]
        tlbGeoLocation_idfsCountry = 79150000000,

        [Description("Geo location/address type identifier (exact point/relative point/address)")]
        tlbGeoLocation_idfsGeoLocationType = 79160000000,

        [Description("Landscape type identifier")]
        tlbGeoLocation_idfsGroundType = 79170000000,

        [Description("Rayon identifier")]
        tlbGeoLocation_idfsRayon = 79180000000,

        [Description("Region identifier")]
        tlbGeoLocation_idfsRegion = 79190000000,

        [Description("Residence type identifier")]
        tlbGeoLocation_idfsResidentType = 79200000000,

        [Description("Settlement identifier")]
        tlbGeoLocation_idfsSettlement = 79210000000,

        [Description("")]
        tlbGeoLocation_strApartment = 4577890000000,

        [Description("Building number")]
        tlbGeoLocation_strBuilding = 79230000000,

        [Description("Geo location description")]
        tlbGeoLocation_strDescription = 79240000000,

        [Description("")]
        tlbGeoLocation_strForeignAddress = 4578790000000,

        [Description("House number")]
        tlbGeoLocation_strHouse = 79250000000,

        [Description("Postal code")]
        tlbGeoLocation_strPostCode = 79260000000,

        [Description("")]
        tlbGeoLocation_strShortAddressString = 51523680000000,

        [Description("Street name")]
        tlbGeoLocation_strStreetName = 79270000000,

        [Description("")]
        tlbGeoLocationShared_blnForeignAddress = 4578800000000,

        [Description("")]
        tlbGeoLocationShared_dblAccuracy = 4572770000000,

        [Description("")]
        tlbGeoLocationShared_dblAlignment = 4572780000000,

        [Description("")]
        tlbGeoLocationShared_dblDistance = 4572740000000,

        [Description("")]
        tlbGeoLocationShared_dblLatitude = 4572750000000,

        [Description("")]
        tlbGeoLocationShared_dblLongitude = 4572760000000,

        [Description("")]
        tlbGeoLocationShared_idfGeoLocationShared = 4572600000000,

        [Description("")]
        tlbGeoLocationShared_idfsCountry = 4572640000000,

        [Description("")]
        tlbGeoLocationShared_idfsGeoLocationType = 4572630000000,

        [Description("")]
        tlbGeoLocationShared_idfsGroundType = 4572620000000,

        [Description("")]
        tlbGeoLocationShared_idfsRayon = 4572660000000,

        [Description("")]
        tlbGeoLocationShared_idfsRegion = 4572650000000,

        [Description("")]
        tlbGeoLocationShared_idfsResidentType = 4572610000000,

        [Description("")]
        tlbGeoLocationShared_idfsSettlement = 4572670000000,

        [Description("")]
        tlbGeoLocationShared_strApartment = 4572720000000,

        [Description("")]
        tlbGeoLocationShared_strBuilding = 4572710000000,

        [Description("")]
        tlbGeoLocationShared_strDescription = 4572730000000,

        [Description("")]
        tlbGeoLocationShared_strForeignAddress = 4578810000000,

        [Description("")]
        tlbGeoLocationShared_strHouse = 4572700000000,

        [Description("")]
        tlbGeoLocationShared_strPostCode = 4572680000000,

        [Description("")]
        tlbGeoLocationShared_strShortAddressString = 51523690000000,

        [Description("")]
        tlbGeoLocationShared_strStreetName = 4572690000000,

        [Description("Farm identifier")]
        tlbHerd_idfFarm = 79280000000,

        [Description("Herd identifier")]
        tlbHerd_idfHerd = 79290000000,

        [Description("")]
        tlbHerd_idfHerdActual = 4572280000000,

        [Description("Dead animal quantity")]
        tlbHerd_intDeadAnimalQty = 79300000000,

        [Description("")]
        tlbHerd_intSickAnimalQty = 4572290000000,

        [Description("Total animal quantity")]
        tlbHerd_intTotalAnimalQty = 79310000000,

        [Description("Herd code")]
        tlbHerd_strHerdCode = 79320000000,

        [Description("")]
        tlbHerd_strNote = 4572300000000,

        [Description("")]
        tlbHerdActual_idfFarmActual = 4573140000000,

        [Description("")]
        tlbHerdActual_idfHerdActual = 4573130000000,

        [Description("")]
        tlbHerdActual_intDeadAnimalQty = 4573180000000,

        [Description("")]
        tlbHerdActual_intSickAnimalQty = 4573160000000,

        [Description("")]
        tlbHerdActual_intTotalAnimalQty = 4573170000000,

        [Description("")]
        tlbHerdActual_strHerdCode = 4573150000000,

        [Description("")]
        tlbHerdActual_strNote = 4573190000000,

        [Description("")]
        tlbHuman_blnPermantentAddressAsCurrent = 12675400000000,

        [Description("Date of birth")]
        tlbHuman_datDateofBirth = 79330000000,

        [Description("Date of death")]
        tlbHuman_datDateOfDeath = 79340000000,

        [Description("")]
        tlbHuman_datEnteredDate = 51389530000000,

        [Description("")]
        tlbHuman_datModificationDate = 51389540000000,

        [Description("Current residence address identifier")]
        tlbHuman_idfCurrentResidenceAddress = 79350000000,

        [Description("Employer address identifier")]
        tlbHuman_idfEmployerAddress = 79360000000,

        [Description("Human identifier")]
        tlbHuman_idfHuman = 79370000000,

        [Description("")]
        tlbHuman_idfHumanActual = 4572310000000,

        [Description("Registration address identifier")]
        tlbHuman_idfRegistrationAddress = 79380000000,

        [Description("Human gender identifier")]
        tlbHuman_idfsHumanGender = 79390000000,

        [Description("Nationality identifier")]
        tlbHuman_idfsNationality = 79400000000,

        [Description("Occupation type identifier")]
        tlbHuman_idfsOccupationType = 79410000000,

        [Description("")]
        tlbHuman_idfsPersonIDType = 12014460000000,

        [Description("Employer's Name")]
        tlbHuman_strEmployerName = 79420000000,

        [Description("First name")]
        tlbHuman_strFirstName = 79430000000,

        [Description("Home phone number")]
        tlbHuman_strHomePhone = 79440000000,

        [Description("Last name")]
        tlbHuman_strLastName = 79450000000,

        [Description("")]
        tlbHuman_strPersonID = 12014470000000,

        [Description("Registration phone number")]
        tlbHuman_strRegistrationPhone = 79460000000,

        [Description("Middle name")]
        tlbHuman_strSecondName = 79470000000,

        [Description("Work phone number")]
        tlbHuman_strWorkPhone = 79480000000,

        [Description("")]
        tlbHumanActual_datDateofBirth = 4573280000000,

        [Description("")]
        tlbHumanActual_datDateOfDeath = 4573290000000,

        [Description("")]
        tlbHumanActual_datEnteredDate = 51389550000000,

        [Description("")]
        tlbHumanActual_datModificationDate = 51389560000000,

        [Description("")]
        tlbHumanActual_idfCurrentResidenceAddress = 4573250000000,

        [Description("")]
        tlbHumanActual_idfEmployerAddress = 4573260000000,

        [Description("")]
        tlbHumanActual_idfHumanActual = 4573210000000,

        [Description("")]
        tlbHumanActual_idfRegistrationAddress = 4573270000000,

        [Description("")]
        tlbHumanActual_idfsHumanGender = 4573240000000,

        [Description("")]
        tlbHumanActual_idfsNationality = 4573230000000,

        [Description("")]
        tlbHumanActual_idfsOccupationType = 4573220000000,

        [Description("")]
        tlbHumanActual_idfsPersonIDType = 12527780000000,

        [Description("")]
        tlbHumanActual_strEmployerName = 4573340000000,

        [Description("")]
        tlbHumanActual_strFirstName = 4573320000000,

        [Description("")]
        tlbHumanActual_strHomePhone = 4573350000000,

        [Description("")]
        tlbHumanActual_strLastName = 4573300000000,

        [Description("")]
        tlbHumanActual_strPersonID = 12527790000000,

        [Description("")]
        tlbHumanActual_strRegistrationPhone = 4573330000000,

        [Description("")]
        tlbHumanActual_strSecondName = 4573310000000,

        [Description("")]
        tlbHumanActual_strWorkPhone = 4573360000000,

        [Description("Flag - disgnosis based on clinical picture")]
        tlbHumanCase_blnClinicalDiagBasis = 79490000000,

        [Description("Flag - disgnosis based on epi investigation")]
        tlbHumanCase_blnEpiDiagBasis = 79500000000,

        [Description("Flag - disgnosis based on lab results")]
        tlbHumanCase_blnLabDiagBasis = 79510000000,

        [Description("Date case paper form was completed")]
        tlbHumanCase_datCompletionPaperFormDate = 79520000000,

        [Description("Date of discharge")]
        tlbHumanCase_datDischargeDate = 79530000000,

        [Description("")]
        tlbHumanCase_datEnteredDate = 12665420000000,

        [Description("Date of exposure")]
        tlbHumanCase_datExposureDate = 79540000000,

        [Description("Date of the last visit of health care facility")]
        tlbHumanCase_datFacilityLastVisit = 79550000000,

        [Description("")]
        tlbHumanCase_datFinalCaseClassificationDate = 51389570000000,

        [Description("Final diagnosis date")]
        tlbHumanCase_datFinalDiagnosisDate = 79560000000,

        [Description("")]
        tlbHumanCase_datFirstSoughtCareDate = 855750000000,

        [Description("Date of hospitalization")]
        tlbHumanCase_datHospitalizationDate = 79570000000,

        [Description("Investigation start date")]
        tlbHumanCase_datInvestigationStartDate = 79580000000,

        [Description("Last case modification date")]
        tlbHumanCase_datModificationDate = 79590000000,

        [Description("")]
        tlbHumanCase_datNotificationDate = 855740000000,

        [Description("")]
        tlbHumanCase_datOnSetDate = 855760000000,

        [Description("Tentative diagnosis date")]
        tlbHumanCase_datTentativeDiagnosisDate = 79600000000,

        [Description("")]
        tlbHumanCase_idfCSObservation = 855720000000,

        [Description("")]
        tlbHumanCase_idfDeduplicationResultCase = 855730000000,

        [Description("")]
        tlbHumanCase_idfEpiObservation = 855710000000,

        [Description("")]
        tlbHumanCase_idfHospital = 51523420000000,

        [Description("")]
        tlbHumanCase_idfHuman = 4577900000000,

        [Description("Human case identifier")]
        tlbHumanCase_idfHumanCase = 79610000000,

        [Description("Case investigated by office identifier")]
        tlbHumanCase_idfInvestigatedByOffice = 79620000000,

        [Description("")]
        tlbHumanCase_idfInvestigatedByPerson = 4578410000000,

        [Description("")]
        tlbHumanCase_idfOutbreak = 12665410000000,

        [Description("")]
        tlbHumanCase_idfPersonEnteredBy = 4577910000000,

        [Description("Case Geo location (exact point) identifier")]
        tlbHumanCase_idfPointGeoLocation = 79630000000,

        [Description("Case received by office identifier")]
        tlbHumanCase_idfReceivedByOffice = 79640000000,

        [Description("")]
        tlbHumanCase_idfReceivedByPerson = 4578400000000,

        [Description("")]
        tlbHumanCase_idfsCaseProgressStatus = 12665440000000,

        [Description("")]
        tlbHumanCase_idfSentByOffice = 855700000000,

        [Description("")]
        tlbHumanCase_idfSentByPerson = 4578390000000,

        [Description("")]
        tlbHumanCase_idfsFinalCaseStatus = 855690000000,

        [Description("Final diagnosis identifier")]
        tlbHumanCase_idfsFinalDiagnosis = 79660000000,

        [Description("Human final state identifier")]
        tlbHumanCase_idfsFinalState = 79670000000,

        [Description("Hospitalization status identifier")]
        tlbHumanCase_idfsHospitalizationStatus = 79680000000,

        [Description("Human age type identifier (years/months/days)")]
        tlbHumanCase_idfsHumanAgeType = 79690000000,

        [Description("Initial case status identifier")]
        tlbHumanCase_idfsInitialCaseStatus = 79700000000,

        [Description("")]
        tlbHumanCase_idfsNonNotifiableDiagnosis = 12014660000000,

        [Description("")]
        tlbHumanCase_idfsNotCollectedReason = 12014670000000,

        [Description("")]
        tlbHumanCase_idfSoughtCareFacility = 12014650000000,

        [Description("Case outcome identifier")]
        tlbHumanCase_idfsOutcome = 79710000000,

        [Description("Tentative diagnosis identifier")]
        tlbHumanCase_idfsTentativeDiagnosis = 79720000000,

        [Description("Flag - yes/no Antimicrabial Therapy")]
        tlbHumanCase_idfsYNAntimicrobialTherapy = 79730000000,

        [Description("Flag - yes/no Hospitalization")]
        tlbHumanCase_idfsYNHospitalization = 79740000000,

        [Description("Flag - yes/no Case related to outbreak")]
        tlbHumanCase_idfsYNRelatedToOutbreak = 79750000000,

        [Description("Flag - yes/no Specimen Collected")]
        tlbHumanCase_idfsYNSpecimenCollected = 79760000000,

        [Description("")]
        tlbHumanCase_idfsYNTestsConducted = 4578420000000,

        [Description("Patient age (in patient age type units)")]
        tlbHumanCase_intPatientAge = 79770000000,

        [Description("")]
        tlbHumanCase_strCaseID = 12665430000000,

        [Description("Clinical Diagnosis")]
        tlbHumanCase_strClinicalDiagnosis = 79780000000,

        [Description("")]
        tlbHumanCase_strClinicalNotes = 855770000000,

        [Description("Current location")]
        tlbHumanCase_strCurrentLocation = 79790000000,

        [Description("Epidemiologists' Name")]
        tlbHumanCase_strEpidemiologistsName = 79800000000,

        [Description("Hospitalization Place")]
        tlbHumanCase_strHospitalizationPlace = 79810000000,

        [Description("Case Local Text code (legacy/office record system)")]
        tlbHumanCase_strLocalIdentifier = 79820000000,

        [Description("Reason for not collecting case samples")]
        tlbHumanCase_strNotCollectedReason = 79830000000,

        [Description("Case notes")]
        tlbHumanCase_strNote = 79840000000,

        [Description("Case paper form received by First name")]
        tlbHumanCase_strReceivedByFirstName = 79850000000,

        [Description("Case paper form received by Last name")]
        tlbHumanCase_strReceivedByLastName = 79860000000,

        [Description("Case paper form received by Middle name")]
        tlbHumanCase_strReceivedByPatronymicName = 79870000000,

        [Description("")]
        tlbHumanCase_strSampleNotes = 12665450000000,

        [Description("Case paper form sent by First name")]
        tlbHumanCase_strSentByFirstName = 79880000000,

        [Description("Case paper form sent by Last name")]
        tlbHumanCase_strSentByLastName = 79890000000,

        [Description("Case paper form sent by Middle name")]
        tlbHumanCase_strSentByPatronymicName = 79900000000,

        [Description("Facility patient sought care")]
        tlbHumanCase_strSoughtCareFacility = 79910000000,

        [Description("")]
        tlbHumanCase_strSummaryNotes = 855780000000,

        [Description("")]
        tlbHumanCase_uidOfflineCaseID = 12665460000000,

        [Description("")]
        tlbMaterial_blnAccessioned = 49545580000000,

        [Description("")]
        tlbMaterial_blnReadOnly = 4578730000000,

        [Description("")]
        tlbMaterial_blnShowInAccessionInForm = 49545610000000,

        [Description("")]
        tlbMaterial_blnShowInCaseOrSession = 49545590000000,

        [Description("")]
        tlbMaterial_blnShowInDispositionList = 49545620000000,

        [Description("")]
        tlbMaterial_blnShowInLabList = 49545600000000,

        [Description("")]
        tlbMaterial_datAccession = 12666880000000,

        [Description("")]
        tlbMaterial_datDestructionDate = 4576400000000,

        [Description("")]
        tlbMaterial_datEnteringDate = 4576390000000,

        [Description("Date of collection")]
        tlbMaterial_datFieldCollectionDate = 79920000000,

        [Description("Date of sending")]
        tlbMaterial_datFieldSentDate = 79930000000,

        [Description("")]
        tlbMaterial_datOutOfRepositoryDate = 51528570000000,

        [Description("")]
        tlbMaterial_datSampleStatusDate = 51528580000000,

        [Description("")]
        tlbMaterial_idfAccesionByPerson = 12666910000000,

        [Description("")]
        tlbMaterial_idfAnimal = 4572450000000,

        [Description("")]
        tlbMaterial_idfDestroyedByPerson = 4576370000000,

        [Description("Material collected by Institution identifier")]
        tlbMaterial_idfFieldCollectedByOffice = 79940000000,

        [Description("Material collected by Officer identifier")]
        tlbMaterial_idfFieldCollectedByPerson = 79950000000,

        [Description("")]
        tlbMaterial_idfHuman = 4572430000000,

        [Description("")]
        tlbMaterial_idfHumanCase = 12665570000000,

        [Description("")]
        tlbMaterial_idfInDepartment = 4576360000000,

        [Description("")]
        tlbMaterial_idfMainTest = 49545410000000,

        [Description("")]
        tlbMaterial_idfMarkedForDispositionByPerson = 51523600000000,

        [Description("Material identifier")]
        tlbMaterial_idfMaterial = 79960000000,

        [Description("")]
        tlbMaterial_idfMonitoringSession = 4572470000000,

        [Description("Immediate source of the material identifier")]
        tlbMaterial_idfParentMaterial = 79970000000,

        [Description("")]
        tlbMaterial_idfRootMaterial = 49545400000000,

        [Description("")]
        tlbMaterial_idfsAccessionCondition = 12666890000000,

        [Description("")]
        tlbMaterial_idfsBirdStatus = 12014480000000,

        [Description("")]
        tlbMaterial_idfsCurrentSite = 49545560000000,

        [Description("")]
        tlbMaterial_idfsDestructionMethod = 12675260000000,

        [Description("")]
        tlbMaterial_idfSendToOffice = 4578720000000,

        [Description("")]
        tlbMaterial_idfSpecies = 4572440000000,

        [Description("")]
        tlbMaterial_idfsSampleKind = 49545570000000,

        [Description("")]
        tlbMaterial_idfsSampleStatus = 49545420000000,

        [Description("")]
        tlbMaterial_idfsSampleType = 49545390000000,

        [Description("")]
        tlbMaterial_idfSubdivision = 4576340000000,

        [Description("")]
        tlbMaterial_idfVector = 4575200000000,

        [Description("")]
        tlbMaterial_idfVectorSurveillanceSession = 4575190000000,

        [Description("")]
        tlbMaterial_idfVetCase = 12665580000000,

        [Description("")]
        tlbMaterial_strBarcode = 4576410000000,

        [Description("")]
        tlbMaterial_strCalculatedCaseID = 4572480000000,

        [Description("")]
        tlbMaterial_strCalculatedHumanName = 4572490000000,

        [Description("")]
        tlbMaterial_strCondition = 12666900000000,

        [Description("Field barcode assigned to material")]
        tlbMaterial_strFieldBarcode = 80030000000,

        [Description("")]
        tlbMaterial_strNote = 4576420000000,

        [Description("")]
        tlbMonitoringSession_datEndDate = 4578680000000,

        [Description("")]
        tlbMonitoringSession_datEnteredDate = 707130000000,

        [Description("")]
        tlbMonitoringSession_datStartDate = 4578670000000,

        [Description("")]
        tlbMonitoringSession_idfCampaign = 707120000000,

        [Description("")]
        tlbMonitoringSession_idfMonitoringSession = 707050000000,

        [Description("")]
        tlbMonitoringSession_idfPersonEnteredBy = 707110000000,

        [Description("")]
        tlbMonitoringSession_idfsCountry = 707070000000,

        [Description("")]
        tlbMonitoringSession_idfsMonitoringSessionStatus = 707060000000,

        [Description("")]
        tlbMonitoringSession_idfsRayon = 707090000000,

        [Description("")]
        tlbMonitoringSession_idfsRegion = 707080000000,

        [Description("")]
        tlbMonitoringSession_idfsSettlement = 707100000000,

        [Description("")]
        tlbMonitoringSession_strMonitoringSessionID = 707140000000,

        [Description("")]
        tlbMonitoringSessionAction_datActionDate = 708280000000,

        [Description("")]
        tlbMonitoringSessionAction_idfMonitoringSession = 708240000000,

        [Description("")]
        tlbMonitoringSessionAction_idfMonitoringSessionAction = 708230000000,

        [Description("")]
        tlbMonitoringSessionAction_idfPersonEnteredBy = 708250000000,

        [Description("")]
        tlbMonitoringSessionAction_idfsMonitoringSessionActionStatus = 708270000000,

        [Description("")]
        tlbMonitoringSessionAction_idfsMonitoringSessionActionType = 708260000000,

        [Description("")]
        tlbMonitoringSessionAction_strComments = 708290000000,

        [Description("")]
        tlbMonitoringSessionSummary_datCollectionDate = 4579030000000,

        [Description("")]
        tlbMonitoringSessionSummary_idfFarm = 4578980000000,

        [Description("")]
        tlbMonitoringSessionSummary_idfMonitoringSession = 4578970000000,

        [Description("")]
        tlbMonitoringSessionSummary_idfMonitoringSessionSummary = 4578960000000,

        [Description("")]
        tlbMonitoringSessionSummary_idfsAnimalSex = 4579000000000,

        [Description("")]
        tlbMonitoringSessionSummary_idfSpecies = 4578990000000,

        [Description("")]
        tlbMonitoringSessionSummary_intPositiveAnimalsQty = 4579040000000,

        [Description("")]
        tlbMonitoringSessionSummary_intSampledAnimalsQty = 4579010000000,

        [Description("")]
        tlbMonitoringSessionSummary_intSamplesQty = 4579020000000,

        [Description("")]
        tlbMonitoringSessionSummaryDiagnosis_blnChecked = 4579480000000,

        [Description("")]
        tlbMonitoringSessionSummaryDiagnosis_idfMonitoringSessionSummary = 4579110000000,

        [Description("")]
        tlbMonitoringSessionSummaryDiagnosis_idfsDiagnosis = 4579120000000,

        [Description("")]
        tlbMonitoringSessionSummarySample_blnChecked = 4579490000000,

        [Description("")]
        tlbMonitoringSessionSummarySample_idfMonitoringSessionSummary = 4579070000000,

        [Description("")]
        tlbMonitoringSessionSummarySample_idfsSampleType = 4579080000000,

        [Description("")]
        tlbMonitoringSessionToDiagnosis_idfMonitoringSession = 707160000000,

        [Description("")]
        tlbMonitoringSessionToDiagnosis_idfMonitoringSessionToDiagnosis = 749060000000,

        [Description("")]
        tlbMonitoringSessionToDiagnosis_idfsDiagnosis = 707170000000,

        [Description("")]
        tlbMonitoringSessionToDiagnosis_idfsSampleType = 51586590000000,

        [Description("")]
        tlbMonitoringSessionToDiagnosis_idfsSpeciesType = 4578860000000,

        [Description("")]
        tlbMonitoringSessionToDiagnosis_intOrder = 707180000000,

        [Description("Flex-Form instance identifier")]
        tlbObservation_idfObservation = 80060000000,

        [Description("Flex-form template identifier")]
        tlbObservation_idfsFormTemplate = 80070000000,

        [Description("")]
        tlbOffice_idfCustomizationPackage = 51577490000000,

        [Description("")]
        tlbOffice_idfLocation = 4577920000000,

        [Description("Office identifier")]
        tlbOffice_idfOffice = 80080000000,

        [Description("Office abbreviation identifier")]
        tlbOffice_idfsOfficeAbbreviation = 80110000000,

        [Description("Office name identifier")]
        tlbOffice_idfsOfficeName = 80120000000,

        [Description("")]
        tlbOffice_intHACode = 50815930000000,

        [Description("Office Contact phone number")]
        tlbOffice_strContactPhone = 80150000000,

        [Description("")]
        tlbOffice_strOrganizationID = 51523430000000,

        [Description("")]
        tlbOutbreak_datFinishDate = 746520000000,

        [Description("")]
        tlbOutbreak_datStartDate = 746510000000,

        [Description("Geo location identifier")]
        tlbOutbreak_idfGeoLocation = 80160000000,

        [Description("Outbreak identifier")]
        tlbOutbreak_idfOutbreak = 80170000000,

        [Description("")]
        tlbOutbreak_idfPrimaryCaseOrSession = 12675370000000,

        [Description("")]
        tlbOutbreak_idfsDiagnosisOrDiagnosisGroup = 12675310000000,

        [Description("Outbreak status identifier")]
        tlbOutbreak_idfsOutbreakStatus = 80190000000,

        [Description("")]
        tlbOutbreak_strDescription = 746540000000,

        [Description("")]
        tlbOutbreak_strOutbreakID = 746530000000,

        [Description("")]
        tlbOutbreakNote_datNoteDate = 707230000000,

        [Description("")]
        tlbOutbreakNote_idfOutbreak = 707210000000,

        [Description("")]
        tlbOutbreakNote_idfOutbreakNote = 707200000000,

        [Description("")]
        tlbOutbreakNote_idfPerson = 707240000000,

        [Description("")]
        tlbOutbreakNote_strNote = 707220000000,

        [Description("")]
        tlbPensideTest_datTestDate = 4575170000000,

        [Description("")]
        tlbPensideTest_idfMaterial = 4575130000000,

        [Description("Penside test identifier")]
        tlbPensideTest_idfPensideTest = 80230000000,

        [Description("")]
        tlbPensideTest_idfsDiagnosis = 4575160000000,

        [Description("")]
        tlbPensideTest_idfsPensideTestCategory = 4578380000000,

        [Description("")]
        tlbPensideTest_idfsPensideTestName = 49545450000000,

        [Description("Penside test result identifier")]
        tlbPensideTest_idfsPensideTestResult = 80240000000,

        [Description("")]
        tlbPensideTest_idfTestedByOffice = 4575150000000,

        [Description("")]
        tlbPensideTest_idfTestedByPerson = 4578630000000,

        [Description("Department identifier")]
        tlbPerson_idfDepartment = 80260000000,

        [Description("Institution identifier")]
        tlbPerson_idfInstitution = 80270000000,

        [Description("Officer identifier")]
        tlbPerson_idfPerson = 80280000000,

        [Description("Staff position identifier")]
        tlbPerson_idfsStaffPosition = 80290000000,

        [Description("Barcode (alphanumeric badge code)")]
        tlbPerson_strBarcode = 80300000000,

        [Description("Officer contact phone number")]
        tlbPerson_strContactPhone = 80310000000,

        [Description("Officer Last name")]
        tlbPerson_strFamilyName = 80320000000,

        [Description("Officer First name")]
        tlbPerson_strFirstName = 80330000000,

        [Description("Officer Middle name")]
        tlbPerson_strSecondName = 80340000000,

        [Description("")]
        tlbPostalCode_idfPostalCode = 4576560000000,

        [Description("Settlement identifier")]
        tlbPostalCode_idfsSettlement = 80350000000,

        [Description("Postal code")]
        tlbPostalCode_strPostCode = 80360000000,

        [Description("")]
        tlbSpecies_datStartOfSignsDate = 4572370000000,

        [Description("")]
        tlbSpecies_idfHerd = 4572350000000,

        [Description("")]
        tlbSpecies_idfObservation = 4572360000000,

        [Description("")]
        tlbSpecies_idfSpecies = 4572320000000,

        [Description("")]
        tlbSpecies_idfSpeciesActual = 4572330000000,

        [Description("")]
        tlbSpecies_idfsSpeciesType = 4572340000000,

        [Description("")]
        tlbSpecies_intDeadAnimalQty = 4572410000000,

        [Description("")]
        tlbSpecies_intSickAnimalQty = 4572390000000,

        [Description("")]
        tlbSpecies_intTotalAnimalQty = 4572400000000,

        [Description("")]
        tlbSpecies_strAverageAge = 4572380000000,

        [Description("")]
        tlbSpecies_strNote = 4572420000000,

        [Description("")]
        tlbSpeciesActual_datStartOfSignsDate = 4573410000000,

        [Description("")]
        tlbSpeciesActual_idfHerdActual = 4573400000000,

        [Description("")]
        tlbSpeciesActual_idfSpeciesActual = 4573380000000,

        [Description("")]
        tlbSpeciesActual_idfsSpeciesType = 4573390000000,

        [Description("")]
        tlbSpeciesActual_intDeadAnimalQty = 4573450000000,

        [Description("")]
        tlbSpeciesActual_intSickAnimalQty = 4573430000000,

        [Description("")]
        tlbSpeciesActual_intTotalAnimalQty = 4573440000000,

        [Description("")]
        tlbSpeciesActual_strAverageAge = 4573420000000,

        [Description("")]
        tlbSpeciesActual_strNote = 4573460000000,

        [Description("Statistic value related period end date")]
        tlbStatistic_datStatisticFinishDate = 80370000000,

        [Description("Statistic value related period start date")]
        tlbStatistic_datStatisticStartDate = 80380000000,

        [Description("Statistic Value Related Area identifier")]
        tlbStatistic_idfsArea = 80390000000,

        [Description("")]
        tlbStatistic_idfsMainBaseReference = 4577930000000,

        [Description("")]
        tlbStatistic_idfsStatisticalAgeGroup = 12014500000000,

        [Description("Statistic value related Area type")]
        tlbStatistic_idfsStatisticAreaType = 80400000000,

        [Description("Statistic data type identifier")]
        tlbStatistic_idfsStatisticDataType = 80410000000,

        [Description("Statistic value related Period type")]
        tlbStatistic_idfsStatisticPeriodType = 80420000000,

        [Description("Statistic value identifier")]
        tlbStatistic_idfStatistic = 80430000000,

        [Description("Statistic value ")]
        tlbStatistic_varValue = 80440000000,

        [Description("Settlement identifier")]
        tlbStreet_idfsSettlement = 80450000000,

        [Description("")]
        tlbStreet_idfStreet = 4576570000000,

        [Description("Street name")]
        tlbStreet_strStreetName = 80460000000,

        [Description("")]
        tlbTestAmendmentHistory_datAmendmentDate = 4578480000000,

        [Description("")]
        tlbTestAmendmentHistory_idfAmendByOffice = 4578460000000,

        [Description("")]
        tlbTestAmendmentHistory_idfAmendByPerson = 4578470000000,

        [Description("")]
        tlbTestAmendmentHistory_idfsNewTestResult = 4578500000000,

        [Description("")]
        tlbTestAmendmentHistory_idfsOldTestResult = 4578490000000,

        [Description("")]
        tlbTestAmendmentHistory_idfTestAmendmentHistory = 4578440000000,

        [Description("")]
        tlbTestAmendmentHistory_idfTesting = 4578450000000,

        [Description("")]
        tlbTestAmendmentHistory_strNewNote = 4578520000000,

        [Description("")]
        tlbTestAmendmentHistory_strOldNote = 4578510000000,

        [Description("")]
        tlbTestAmendmentHistory_strReason = 4578530000000,

        [Description("")]
        tlbTesting_blnExternalTest = 50815850000000,

        [Description("")]
        tlbTesting_blnNonLaboratoryTest = 4578760000000,

        [Description("")]
        tlbTesting_blnReadOnly = 4578740000000,

        [Description("")]
        tlbTesting_datConcludedDate = 4578550000000,

        [Description("")]
        tlbTesting_datReceivedDate = 50815870000000,

        [Description("")]
        tlbTesting_datStartedDate = 4578540000000,

        [Description("Test Batch identifier")]
        tlbTesting_idfBatchTest = 80470000000,

        [Description("")]
        tlbTesting_idfMaterial = 4576430000000,

        [Description("Flexform instance identifier")]
        tlbTesting_idfObservation = 80500000000,

        [Description("")]
        tlbTesting_idfPerformedByOffice = 50815860000000,

        [Description("")]
        tlbTesting_idfResultEnteredByOffice = 4578580000000,

        [Description("")]
        tlbTesting_idfResultEnteredByPerson = 4578590000000,

        [Description("")]
        tlbTesting_idfsDiagnosis = 4572520000000,

        [Description("")]
        tlbTesting_idfsTestCategory = 49545440000000,

        [Description("")]
        tlbTesting_idfsTestName = 49545430000000,

        [Description("Test Result identifier")]
        tlbTesting_idfsTestResult = 80510000000,

        [Description("")]
        tlbTesting_idfsTestStatus = 4572510000000,

        [Description("")]
        tlbTesting_idfTestedByOffice = 4578560000000,

        [Description("")]
        tlbTesting_idfTestedByPerson = 4578570000000,

        [Description("Test identifier")]
        tlbTesting_idfTesting = 80530000000,

        [Description("")]
        tlbTesting_idfValidatedByOffice = 4578600000000,

        [Description("")]
        tlbTesting_idfValidatedByPerson = 4578610000000,

        [Description("Number of test in batch")]
        tlbTesting_intTestNumber = 80540000000,

        [Description("")]
        tlbTesting_strContactPerson = 50815880000000,

        [Description("")]
        tlbTesting_strNote = 4572540000000,

        [Description("")]
        tlbTestValidation_blnCaseCreated = 4572560000000,

        [Description("")]
        tlbTestValidation_blnReadOnly = 6617410000000,

        [Description("Interpretation validated (Flag - yes/no)")]
        tlbTestValidation_blnValidateStatus = 80550000000,

        [Description("")]
        tlbTestValidation_datInterpretationDate = 4572580000000,

        [Description("")]
        tlbTestValidation_datValidationDate = 4572570000000,

        [Description("Interpreted by office identifier")]
        tlbTestValidation_idfInterpretedByOffice = 80560000000,

        [Description("Interpreted by officer identifier")]
        tlbTestValidation_idfInterpretedByPerson = 80570000000,

        [Description("Diagnosis identifier")]
        tlbTestValidation_idfsDiagnosis = 80580000000,

        [Description("Status identifier (confirmed/rejected)")]
        tlbTestValidation_idfsInterpretedStatus = 80590000000,

        [Description("Test (interpreted/validated) identifier")]
        tlbTestValidation_idfTesting = 80600000000,

        [Description("")]
        tlbTestValidation_idfTestValidation = 4572550000000,

        [Description("Validated by office identifier")]
        tlbTestValidation_idfValidatedByOffice = 80610000000,

        [Description("Validated by officer identifier")]
        tlbTestValidation_idfValidatedByPerson = 80620000000,

        [Description("Interpretation comments")]
        tlbTestValidation_strInterpretedComment = 80630000000,

        [Description("Validation comments")]
        tlbTestValidation_strValidateComment = 80640000000,

        [Description("Date sent")]
        tlbTransferOUT_datSendDate = 80720000000,

        [Description("Person sent by identifier")]
        tlbTransferOUT_idfSendByPerson = 80730000000,

        [Description("Transfer out of office identifier")]
        tlbTransferOUT_idfSendFromOffice = 80740000000,

        [Description("Transfer out to office identifier")]
        tlbTransferOUT_idfSendToOffice = 80750000000,

        [Description("")]
        tlbTransferOUT_idfsTransferStatus = 4577940000000,

        [Description("Transfer out identifier")]
        tlbTransferOUT_idfTransferOut = 80760000000,

        [Description("")]
        tlbTransferOUT_strBarcode = 4577950000000,

        [Description("Comment")]
        tlbTransferOUT_strNote = 80770000000,

        [Description("")]
        tlbTransferOutMaterial_idfMaterial = 4576470000000,

        [Description("")]
        tlbTransferOutMaterial_idfTransferOut = 4576480000000,

        [Description("Vaccination date")]
        tlbVaccination_datVaccinationDate = 80780000000,

        [Description("Diagnosis identifier")]
        tlbVaccination_idfsDiagnosis = 80790000000,

        [Description("")]
        tlbVaccination_idfSpecies = 4577970000000,

        [Description("")]
        tlbVaccination_idfsVaccinationRoute = 4577980000000,

        [Description("Vaccination type identifier")]
        tlbVaccination_idfsVaccinationType = 80800000000,

        [Description("Vaccination identifier")]
        tlbVaccination_idfVaccination = 80810000000,

        [Description("")]
        tlbVaccination_idfVetCase = 4577960000000,

        [Description("Number of vaccinations")]
        tlbVaccination_intNumberVaccinated = 80820000000,

        [Description("Quantity")]
        tlbVaccination_strLotNumber = 80830000000,

        [Description("Vaccine manufacturer")]
        tlbVaccination_strManufacturer = 80840000000,

        [Description("")]
        tlbVaccination_strNote = 4577990000000,

        [Description("")]
        tlbVector_datCollectionDateTime = 4575430000000,

        [Description("")]
        tlbVector_datIdentifiedDateTime = 4575530000000,

        [Description("")]
        tlbVector_idfCollectedByOffice = 4575410000000,

        [Description("")]
        tlbVector_idfCollectedByPerson = 4575420000000,

        [Description("")]
        tlbVector_idfHostVector = 4575340000000,

        [Description("")]
        tlbVector_idfIdentifiedByOffice = 4575510000000,

        [Description("")]
        tlbVector_idfIdentifiedByPerson = 4575520000000,

        [Description("")]
        tlbVector_idfLocation = 4575370000000,

        [Description("")]
        tlbVector_idfObservation = 4575550000000,

        [Description("")]
        tlbVector_idfsBasisOfRecord = 4575460000000,

        [Description("")]
        tlbVector_idfsCollectionMethod = 4575450000000,

        [Description("")]
        tlbVector_idfsDayPeriod = 4578000000000,

        [Description("")]
        tlbVector_idfsEctoparasitesCollected = 6618110000000,

        [Description("")]
        tlbVector_idfsIdentificationMethod = 4575540000000,

        [Description("")]
        tlbVector_idfsSex = 4575500000000,

        [Description("")]
        tlbVector_idfsSurrounding = 4575390000000,

        [Description("")]
        tlbVector_idfsVectorSubType = 4575480000000,

        [Description("")]
        tlbVector_idfsVectorType = 4575470000000,

        [Description("")]
        tlbVector_idfVector = 4575320000000,

        [Description("")]
        tlbVector_idfVectorSurveillanceSession = 4575330000000,

        [Description("")]
        tlbVector_intElevation = 4575380000000,

        [Description("")]
        tlbVector_intQuantity = 4575490000000,

        [Description("")]
        tlbVector_strComment = 4578700000000,

        [Description("")]
        tlbVector_strFieldVectorID = 4575360000000,

        [Description("")]
        tlbVector_strGEOReferenceSources = 4575400000000,

        [Description("")]
        tlbVector_strVectorID = 4575350000000,

        [Description("")]
        tlbVectorSurveillanceSession_datCloseDate = 4575270000000,

        [Description("")]
        tlbVectorSurveillanceSession_datStartDate = 4575260000000,

        [Description("")]
        tlbVectorSurveillanceSession_idfLocation = 4575280000000,

        [Description("")]
        tlbVectorSurveillanceSession_idfOutbreak = 4575290000000,

        [Description("")]
        tlbVectorSurveillanceSession_idfsVectorSurveillanceStatus = 4575250000000,

        [Description("")]
        tlbVectorSurveillanceSession_idfVectorSurveillanceSession = 4575220000000,

        [Description("")]
        tlbVectorSurveillanceSession_intCollectionEffort = 6751020000000,

        [Description("")]
        tlbVectorSurveillanceSession_strDescription = 4575300000000,

        [Description("")]
        tlbVectorSurveillanceSession_strFieldSessionID = 4575240000000,

        [Description("")]
        tlbVectorSurveillanceSession_strSessionID = 4575230000000,

        [Description("")]
        tlbVectorSurveillanceSessionSummary_datCollectionDateTime = 12666970000000,

        [Description("")]
        tlbVectorSurveillanceSessionSummary_idfGeoLocation = 12666960000000,

        [Description("")]
        tlbVectorSurveillanceSessionSummary_idfsSex = 12666990000000,

        [Description("")]
        tlbVectorSurveillanceSessionSummary_idfsVectorSubType = 12666980000000,

        [Description("")]
        tlbVectorSurveillanceSessionSummary_idfsVSSessionSummary = 12666930000000,

        [Description("")]
        tlbVectorSurveillanceSessionSummary_idfVectorSurveillanceSession = 12666940000000,

        [Description("")]
        tlbVectorSurveillanceSessionSummary_intQuantity = 12667000000000,

        [Description("")]
        tlbVectorSurveillanceSessionSummary_strVSSessionSummaryID = 12666950000000,

        [Description("")]
        tlbVectorSurveillanceSessionSummaryDiagnosis_idfsDiagnosis = 12667040000000,

        [Description("")]
        tlbVectorSurveillanceSessionSummaryDiagnosis_idfsVSSessionSummary = 12667030000000,

        [Description("")]
        tlbVectorSurveillanceSessionSummaryDiagnosis_idfsVSSessionSummaryDiagnosis = 12667020000000,

        [Description("")]
        tlbVectorSurveillanceSessionSummaryDiagnosis_intPositiveQuantity = 12667050000000,

        [Description("Assignment date")]
        tlbVetCase_datAssignedDate = 80850000000,

        [Description("")]
        tlbVetCase_datEnteredDate = 12665500000000,

        [Description("Final diagnosis date")]
        tlbVetCase_datFinalDiagnosisDate = 80860000000,

        [Description("")]
        tlbVetCase_datInvestigationDate = 4566330000000,

        [Description("Reporting date")]
        tlbVetCase_datReportDate = 80870000000,

        [Description("Tentative diagnosis 1 date")]
        tlbVetCase_datTentativeDiagnosis1Date = 80880000000,

        [Description("Tentative diagnosis 2 date")]
        tlbVetCase_datTentativeDiagnosis2Date = 80890000000,

        [Description("Tentative diagnosis date")]
        tlbVetCase_datTentativeDiagnosisDate = 80900000000,

        [Description("")]
        tlbVetCase_idfFarm = 4575810000000,

        [Description("")]
        tlbVetCase_idfInvestigatedByOffice = 6618100000000,

        [Description("")]
        tlbVetCase_idfObservation = 4566320000000,

        [Description("")]
        tlbVetCase_idfOutbreak = 12665490000000,

        [Description("")]
        tlbVetCase_idfParentMonitoringSession = 12665540000000,

        [Description("Case created by person identifier")]
        tlbVetCase_idfPersonEnteredBy = 80910000000,

        [Description("Investigated by person identifier")]
        tlbVetCase_idfPersonInvestigatedBy = 80920000000,

        [Description("Case reported by person identifier")]
        tlbVetCase_idfPersonReportedBy = 80930000000,

        [Description("")]
        tlbVetCase_idfReportedByOffice = 6618090000000,

        [Description("")]
        tlbVetCase_idfsCaseClassification = 12665470000000,

        [Description("")]
        tlbVetCase_idfsCaseProgressStatus = 12665520000000,

        [Description("")]
        tlbVetCase_idfsCaseReportType = 6618120000000,

        [Description("")]
        tlbVetCase_idfsCaseType = 12665560000000,

        [Description("Final diagnosis identifier")]
        tlbVetCase_idfsFinalDiagnosis = 80940000000,

        [Description("")]
        tlbVetCase_idfsShowDiagnosis = 12665480000000,

        [Description("Tentative diagnosis identifier")]
        tlbVetCase_idfsTentativeDiagnosis = 80960000000,

        [Description("Tentative diagnosis 1 identifier")]
        tlbVetCase_idfsTentativeDiagnosis1 = 80970000000,

        [Description("Tentative diagnosis 2 identifier")]
        tlbVetCase_idfsTentativeDiagnosis2 = 80980000000,

        [Description("")]
        tlbVetCase_idfsYNTestsConducted = 4578870000000,

        [Description("Veterinary case identifier")]
        tlbVetCase_idfVetCase = 80990000000,

        [Description("")]
        tlbVetCase_strCaseID = 12665510000000,

        [Description("Clinical notes")]
        tlbVetCase_strClinicalNotes = 81000000000,

        [Description("")]
        tlbVetCase_strDefaultDisplayDiagnosis = 12014720000000,

        [Description("")]
        tlbVetCase_strFieldAccessionID = 4566340000000,

        [Description("")]
        tlbVetCase_strSampleNotes = 12665530000000,

        [Description("Summary notes")]
        tlbVetCase_strSummaryNotes = 81020000000,

        [Description("Test notes")]
        tlbVetCase_strTestNotes = 81030000000,

        [Description("")]
        tlbVetCase_uidOfflineCaseID = 12665550000000,

        [Description("")]
        tlbVetCaseDisplayDiagnosis_idfsLanguage = 12014700000000,

        [Description("")]
        tlbVetCaseDisplayDiagnosis_idfVetCase = 12014690000000,

        [Description("")]
        tlbVetCaseDisplayDiagnosis_strDisplayDiagnosis = 12014710000000,

        [Description("Date")]
        tlbVetCaseLog_datCaseLogDate = 81040000000,

        [Description("Officer identifier")]
        tlbVetCaseLog_idfPerson = 81050000000,

        [Description("")]
        tlbVetCaseLog_idfsCaseLogStatus = 4578020000000,

        [Description("")]
        tlbVetCaseLog_idfVetCase = 4578030000000,

        [Description("")]
        tlbVetCaseLog_idfVetCaseLog = 4578010000000,

        [Description("")]
        tlbVetCaseLog_strActionRequired = 4578040000000,

        [Description("Notes")]
        tlbVetCaseLog_strNote = 81060000000,

        [Description("")]
        trtBaseReference_blnSystem = 747460000000,

        [Description("Base reference value identifier")]
        trtBaseReference_idfsBaseReference = 81070000000,

        [Description("Reference type identifier")]
        trtBaseReference_idfsReferenceType = 81080000000,

        [Description("Human/Animal Code")]
        trtBaseReference_intHACode = 81090000000,

        [Description("Listing order")]
        trtBaseReference_intOrder = 81100000000,

        [Description("Base reference code (from version 2)")]
        trtBaseReference_strBaseReferenceCode = 81110000000,

        [Description("Default value")]
        trtBaseReference_strDefault = 81120000000,

        [Description("")]
        trtBssAggregateColumns_idfColumn = 50815380000000,

        [Description("")]
        trtBssAggregateColumns_idfsBssAggregateColumn = 50815370000000,

        [Description("")]
        trtCollectionMethodForVectorType_idfCollectionMethodForVectorType = 4575720000000,

        [Description("")]
        trtCollectionMethodForVectorType_idfsCollectionMethod = 4575730000000,

        [Description("")]
        trtCollectionMethodForVectorType_idfsVectorType = 4575740000000,

        [Description("")]
        trtDerivativeForSampleType_idfDerivativeForSampleType = 740860000000,

        [Description("")]
        trtDerivativeForSampleType_idfsDerivativeType = 740880000000,

        [Description("")]
        trtDerivativeForSampleType_idfsSampleType = 740870000000,

        [Description("")]
        trtDiagnosis_blnZoonotic = 51389460000000,

        [Description("Diagnosis identifier")]
        trtDiagnosis_idfsDiagnosis = 81150000000,

        [Description("")]
        trtDiagnosis_idfsUsingType = 4578050000000,

        [Description("IDC10 Code")]
        trtDiagnosis_strIDC10 = 81160000000,

        [Description("OIE Code")]
        trtDiagnosis_strOIECode = 81170000000,

        [Description("")]
        trtDiagnosisAgeGroup_idfsAgeType = 12014550000000,

        [Description("")]
        trtDiagnosisAgeGroup_idfsDiagnosisAgeGroup = 12014520000000,

        [Description("")]
        trtDiagnosisAgeGroup_intLowerBoundary = 12014530000000,

        [Description("")]
        trtDiagnosisAgeGroup_intUpperBoundary = 12014540000000,

        [Description("")]
        trtDiagnosisAgeGroupToDiagnosis_idfDiagnosisAgeGroupToDiagnosis = 12014610000000,

        [Description("")]
        trtDiagnosisAgeGroupToDiagnosis_idfsDiagnosis = 12014620000000,

        [Description("")]
        trtDiagnosisAgeGroupToDiagnosis_idfsDiagnosisAgeGroup = 12014630000000,

        [Description("")]
        trtDiagnosisAgeGroupToStatisticalAgeGroup_idfDiagnosisAgeGroupToStatisticalAgeGroup = 49545330000000,

        [Description("")]
        trtDiagnosisAgeGroupToStatisticalAgeGroup_idfsDiagnosisAgeGroup = 49545340000000,

        [Description("")]
        trtDiagnosisAgeGroupToStatisticalAgeGroup_idfsStatisticalAgeGroup = 49545350000000,

        [Description("")]
        trtDiagnosisToDiagnosisGroup_idfDiagnosisToDiagnosisGroup = 50815470000000,

        [Description("")]
        trtDiagnosisToDiagnosisGroup_idfsDiagnosis = 12675300000000,

        [Description("")]
        trtDiagnosisToDiagnosisGroup_idfsDiagnosisGroup = 12675290000000,

        [Description("")]
        trtDiagnosisToGroupForReportType_idfDiagnosisToGroupForReportType = 51577260000000,

        [Description("")]
        trtDiagnosisToGroupForReportType_idfsCustomReportType = 51577240000000,

        [Description("")]
        trtDiagnosisToGroupForReportType_idfsDiagnosis = 749160000000,

        [Description("")]
        trtDiagnosisToGroupForReportType_idfsReportDiagnosisGroup = 51577250000000,

        [Description("")]
        trtEventType_blnDisplayInLog = 12666780000000,

        [Description("")]
        trtEventType_blnSubscription = 12666770000000,

        [Description("")]
        trtEventType_idfsEventSubscription = 12666790000000,

        [Description("")]
        trtEventType_idfsEventTypeID = 4579290000000,

        [Description("")]
        trtFFObjectForCustomReport_idfFFObjectForCustomReport = 51577150000000,

        [Description("")]
        trtFFObjectForCustomReport_idfsCustomReportType = 51577160000000,

        [Description("")]
        trtFFObjectForCustomReport_idfsFFObject = 51577180000000,

        [Description("")]
        trtFFObjectForCustomReport_strFFObjectAlias = 51577170000000,

        [Description("")]
        trtFFObjectToDiagnosisForCustomReport_idfFFObjectForCustomReport = 51577220000000,

        [Description("")]
        trtFFObjectToDiagnosisForCustomReport_idfFFObjectToDiagnosisForCustomReport = 51577200000000,

        [Description("")]
        trtFFObjectToDiagnosisForCustomReport_idfsDiagnosis = 51577210000000,

        [Description("")]
        trtFFParameterToDiagnosisForCustomReport_idfFFParameterForCustomReport = 9295770000000,

        [Description("")]
        trtFFParameterToDiagnosisForCustomReport_idfFFParameterToDiagnosisForCustomReport = 9295750000000,

        [Description("")]
        trtFFParameterToDiagnosisForCustomReport_idfsDiagnosis = 9295760000000,

        [Description("")]
        trtHACodeList_idfsCodeName = 4579320000000,

        [Description("")]
        trtHACodeList_intHACode = 4579310000000,

        [Description("")]
        trtHACodeList_strNote = 4579330000000,

        [Description("")]
        trtLanguageToCountry_idfsCountry = 12666870000000,

        [Description("")]
        trtLanguageToCountry_idfsLanguage = 12666860000000,

        [Description("")]
        trtMaterialForDisease_idfMaterialForDisease = 4578060000000,

        [Description("Diagnosis identifier")]
        trtMaterialForDisease_idfsDiagnosis = 81200000000,

        [Description("")]
        trtMaterialForDisease_idfsSampleType = 49545460000000,

        [Description("Recommended Quantity")]
        trtMaterialForDisease_intRecommendedQty = 81220000000,

        [Description("Object Operation identifier")]
        trtObjectTypeToObjectOperation_idfsObjectOperation = 81230000000,

        [Description("Object Type identifier")]
        trtObjectTypeToObjectOperation_idfsObjectType = 81240000000,

        [Description("Parent object type identifier")]
        trtObjectTypeToObjectType_idfsParentObjectType = 81250000000,

        [Description("Child object type identifier")]
        trtObjectTypeToObjectType_idfsRelatedObjectType = 81260000000,

        [Description("Status identifier ")]
        trtObjectTypeToObjectType_idfsStatus = 81270000000,

        [Description("")]
        trtPensideTestForDisease_idfPensideTestForDisease = 6617440000000,

        [Description("")]
        trtPensideTestForDisease_idfsDiagnosis = 6617460000000,

        [Description("")]
        trtPensideTestForDisease_idfsPensideTestName = 49545550000000,

        [Description("")]
        trtPensideTestTypeForVectorType_idfPensideTestTypeForVectorType = 4575770000000,

        [Description("")]
        trtPensideTestTypeForVectorType_idfsPensideTestName = 49545540000000,

        [Description("")]
        trtPensideTestTypeForVectorType_idfsVectorType = 4575790000000,

        [Description("")]
        trtPensideTestTypeToTestResult_blnIndicative = 6617420000000,

        [Description("")]
        trtPensideTestTypeToTestResult_idfsPensideTestName = 49545530000000,

        [Description("")]
        trtPensideTestTypeToTestResult_idfsPensideTestResult = 4578080000000,

        [Description("")]
        trtProphilacticAction_idfsProphilacticAction = 4578090000000,

        [Description("")]
        trtProphilacticAction_strActionCode = 4578100000000,

        [Description("Maximum identifier value reserved ")]
        trtReferenceType_idfMaxID = 81280000000,

        [Description("Minimum identifier value reserved ")]
        trtReferenceType_idfMinID = 81290000000,

        [Description("Reference type identifier")]
        trtReferenceType_idfsReferenceType = 81300000000,

        [Description("")]
        trtReferenceType_intDefaultHACode = 12665220000000,

        [Description("")]
        trtReferenceType_intHACodeMask = 12665210000000,

        [Description("")]
        trtReferenceType_intStandard = 12665200000000,

        [Description("Reference type code")]
        trtReferenceType_strReferenceTypeCode = 81310000000,

        [Description("Reference type name")]
        trtReferenceType_strReferenceTypeName = 81320000000,

        [Description("")]
        trtReportDiagnosisGroup_idfsReportDiagnosisGroup = 12675330000000,

        [Description("")]
        trtReportDiagnosisGroup_strCode = 12675340000000,

        [Description("")]
        trtReportDiagnosisGroup_strDiagnosisGroupAlias = 12675350000000,

        [Description("")]
        trtReportRows_idfReportRows = 51541520000000,

        [Description("")]
        trtReportRows_idfsCustomReportType = 51577230000000,

        [Description("")]
        trtReportRows_idfsDiagnosisOrReportDiagnosisGroup = 12675360000000,

        [Description("")]
        trtReportRows_idfsICDReportAdditionalText = 6816320000000,

        [Description("")]
        trtReportRows_idfsReportAdditionalText = 952260000000,

        [Description("")]
        trtReportRows_intNullValueInsteadZero = 9842280000000,

        [Description("")]
        trtReportRows_intRowOrder = 749220000000,

        [Description("")]
        trtSampleType_idfsSampleType = 746930000000,

        [Description("")]
        trtSampleType_strSampleCode = 746940000000,

        [Description("")]
        trtSampleTypeForVectorType_idfSampleTypeForVectorType = 4575670000000,

        [Description("")]
        trtSampleTypeForVectorType_idfsSampleType = 4575680000000,

        [Description("")]
        trtSampleTypeForVectorType_idfsVectorType = 4575690000000,

        [Description("")]
        trtSanitaryAction_idfsSanitaryAction = 4578110000000,

        [Description("")]
        trtSanitaryAction_strActionCode = 4578120000000,

        [Description("")]
        trtSpeciesContentInCustomReport_idfsCustomReportType = 51577610000000,

        [Description("")]
        trtSpeciesContentInCustomReport_idfSpeciesContentInCustomReport = 51577600000000,

        [Description("")]
        trtSpeciesContentInCustomReport_idfsReportAdditionalText = 51577630000000,

        [Description("")]
        trtSpeciesContentInCustomReport_idfsSpeciesOrSpeciesGroup = 51577620000000,

        [Description("")]
        trtSpeciesContentInCustomReport_intItemOrder = 51577640000000,

        [Description("")]
        trtSpeciesContentInCustomReport_intNullValueInsteadZero = 51577650000000,

        [Description("")]
        trtSpeciesGroup_idfsSpeciesGroup = 51577520000000,

        [Description("")]
        trtSpeciesGroup_strSpeciesGroupAlias = 51577530000000,

        [Description("")]
        trtSpeciesToGroupForCustomReport_idfsCustomReportType = 51577560000000,

        [Description("")]
        trtSpeciesToGroupForCustomReport_idfSpeciesToGroupForCustomReport = 51577550000000,

        [Description("")]
        trtSpeciesToGroupForCustomReport_idfsSpeciesGroup = 51577570000000,

        [Description("")]
        trtSpeciesToGroupForCustomReport_idfsSpeciesType = 51577580000000,

        [Description("")]
        trtSpeciesType_idfsSpeciesType = 4578130000000,

        [Description("")]
        trtSpeciesType_strCode = 4578140000000,

        [Description("Animal age identifier")]
        trtSpeciesTypeToAnimalAge_idfsAnimalAge = 81330000000,

        [Description("")]
        trtSpeciesTypeToAnimalAge_idfSpeciesTypeToAnimalAge = 749050000000,

        [Description("Specie type identifier")]
        trtSpeciesTypeToAnimalAge_idfsSpeciesType = 81340000000,

        [Description("")]
        trtStatisticDataType_blnRelatedWithAgeGroup = 12014490000000,

        [Description("Base reference type identifier")]
        trtStatisticDataType_idfsReferenceType = 81350000000,

        [Description("")]
        trtStatisticDataType_idfsStatisticAreaType = 4578150000000,

        [Description("Statistical data type identifier")]
        trtStatisticDataType_idfsStatisticDataType = 81360000000,

        [Description("")]
        trtStatisticDataType_idfsStatisticPeriodType = 4578160000000,

        [Description("Base reference value identifier")]
        trtStringNameTranslation_idfsBaseReference = 81370000000,

        [Description("Language identifier")]
        trtStringNameTranslation_idfsLanguage = 81380000000,

        [Description("Translated value in specified language ")]
        trtStringNameTranslation_strTextString = 81390000000,

        [Description("")]
        trtSystemFunction_idfsObjectType = 4579350000000,

        [Description("")]
        trtSystemFunction_idfsSystemFunction = 4579340000000,

        [Description("")]
        trtSystemFunction_intNumber = 4579360000000,

        [Description("Diagnosis identifier")]
        trtTestForDisease_idfsDiagnosis = 81400000000,

        [Description("")]
        trtTestForDisease_idfsSampleType = 49545470000000,

        [Description("")]
        trtTestForDisease_idfsTestCategory = 49545480000000,

        [Description("")]
        trtTestForDisease_idfsTestName = 49545500000000,

        [Description("Test for disease identifier")]
        trtTestForDisease_idfTestForDisease = 81440000000,

        [Description("Recommended Quantity")]
        trtTestForDisease_intRecommendedQty = 81450000000,

        [Description("")]
        trtTestTypeForCustomReport_idfsCustomReportType = 51577270000000,

        [Description("")]
        trtTestTypeForCustomReport_idfsTestName = 49545520000000,

        [Description("")]
        trtTestTypeForCustomReport_idfTestTypeForCustomReport = 9294220000000,

        [Description("")]
        trtTestTypeForCustomReport_intRowOrder = 9294250000000,

        [Description("")]
        trtTestTypeToTestResult_blnIndicative = 4578170000000,

        [Description("")]
        trtTestTypeToTestResult_idfsTestName = 49545510000000,

        [Description("Test Result identifier")]
        trtTestTypeToTestResult_idfsTestResult = 81460000000,

        [Description("")]
        trtVectorSubType_idfsVectorSubType = 4575580000000,

        [Description("")]
        trtVectorSubType_idfsVectorType = 4575590000000,

        [Description("")]
        trtVectorSubType_strCode = 4575600000000,

        [Description("")]
        trtVectorType_bitCollectionByPool = 4575650000000,

        [Description("")]
        trtVectorType_idfsVectorType = 4575630000000,

        [Description("")]
        trtVectorType_strCode = 4575640000000,

        [Description("")]
        tstAggrSetting_idfCustomizationPackage = 51577500000000,

        [Description("")]
        tstAggrSetting_idfsAggrCaseType = 4578180000000,

        [Description("")]
        tstAggrSetting_idfsStatisticAreaType = 4578190000000,

        [Description("")]
        tstAggrSetting_idfsStatisticPeriodType = 4578200000000,

        [Description("Value")]
        tstAggrSetting_strValue = 81490000000,

        [Description("")]
        tstBarcodeLayout_idfsNumberName = 4575830000000,

        [Description("")]
        tstEventSubscription_idfsEventTypeID = 4575030000000,

        [Description("")]
        tstEventSubscription_strClient = 4575040000000,

        [Description("")]
        tstGeoLocationFormat_idfsCountry = 51523330000000,

        [Description("")]
        tstGeoLocationFormat_strAddressString = 51523340000000,

        [Description("")]
        tstGeoLocationFormat_strExactPointString = 51523350000000,

        [Description("")]
        tstGeoLocationFormat_strForeignAddress = 51523370000000,

        [Description("")]
        tstGeoLocationFormat_strRelativePointString = 51523360000000,

        [Description("")]
        tstGeoLocationFormat_strShortAddress = 51523380000000,

        [Description("")]
        tstGlobalSiteOptions_strName = 82260000000,

        [Description("")]
        tstGlobalSiteOptions_strValue = 82270000000,

        [Description("")]
        tstLocalSiteOptions_strName = 4575050000000,

        [Description("")]
        tstLocalSiteOptions_strValue = 4575060000000,

        [Description("Use alphanumeric (true/false)")]
        tstNextNumbers_blnUseAlphaNumericValue = 81740000000,

        [Description("Use HASC code (true/false)")]
        tstNextNumbers_blnUseHACSCodeSite = 81750000000,

        [Description("Use prefix (true/false)")]
        tstNextNumbers_blnUsePrefix = 81760000000,

        [Description("Use site ID (true/false)")]
        tstNextNumbers_blnUseSiteID = 81770000000,

        [Description("Use year (true/false)")]
        tstNextNumbers_blnUseYear = 81780000000,

        [Description("Numbering rule identifier")]
        tstNextNumbers_idfsNumberName = 81790000000,

        [Description("Minimum number length")]
        tstNextNumbers_intMinNumberLength = 81800000000,

        [Description("Number value")]
        tstNextNumbers_intNumberValue = 81810000000,

        [Description("Year")]
        tstNextNumbers_intYear = 81820000000,

        [Description("Document name")]
        tstNextNumbers_strDocumentName = 81840000000,

        [Description("Prefix")]
        tstNextNumbers_strPrefix = 81850000000,

        [Description("Suffix")]
        tstNextNumbers_strSuffix = 81860000000,

        [Description("Notification creation date")]
        tstNotification_datCreationDate = 81870000000,

        [Description("Notification entering date")]
        tstNotification_datEnteringDate = 81880000000,

        [Description("Notification identifier")]
        tstNotification_idfNotification = 81890000000,

        [Description("Notification object identifier")]
        tstNotification_idfNotificationObject = 81900000000,

        [Description("Notification object type identifier")]
        tstNotification_idfsNotificationObjectType = 81910000000,

        [Description("")]
        tstNotification_idfsNotificationType = 4575070000000,

        [Description("Notification target site identifier")]
        tstNotification_idfsTargetSite = 81930000000,

        [Description("")]
        tstNotification_idfsTargetSiteType = 4575080000000,

        [Description("Notification target user identifier")]
        tstNotification_idfTargetUserID = 81940000000,

        [Description("User identifier")]
        tstNotification_idfUserID = 81950000000,

        [Description("")]
        tstNotification_strPayload = 4575090000000,

        [Description("Notification identifier")]
        tstNotificationStatus_idfNotification = 81960000000,

        [Description("Is Notification processed (0/1)")]
        tstNotificationStatus_intProcessed = 81970000000,

        [Description("")]
        tstNotificationStatus_intSessionID = 12137920000000,

        [Description("Actor identifier")]
        tstObjectAccess_idfActor = 81980000000,

        [Description("")]
        tstObjectAccess_idfObjectAccess = 4578210000000,

        [Description("Object identifier")]
        tstObjectAccess_idfsObjectID = 81990000000,

        [Description("Object Operation identifier")]
        tstObjectAccess_idfsObjectOperation = 82000000000,

        [Description("Object Type identifier")]
        tstObjectAccess_idfsObjectType = 82010000000,

        [Description("Site identifier")]
        tstObjectAccess_idfsOnSite = 82020000000,

        [Description("Permission (0/1)")]
        tstObjectAccess_intPermission = 82030000000,

        [Description("")]
        tstSecurityConfiguration_blnPredefined = 82380000000,

        [Description("")]
        tstSecurityConfiguration_idfParentSecurityConfiguration = 82290000000,

        [Description("")]
        tstSecurityConfiguration_idfSecurityConfiguration = 82280000000,

        [Description("")]
        tstSecurityConfiguration_idfsSecurityLevel = 82300000000,

        [Description("")]
        tstSecurityConfiguration_intAccountLockTimeout = 82320000000,

        [Description("")]
        tstSecurityConfiguration_intAccountTryCount = 82330000000,

        [Description("")]
        tstSecurityConfiguration_intAlphabetCount = 707850000000,

        [Description("")]
        tstSecurityConfiguration_intForcePasswordComplexity = 707860000000,

        [Description("")]
        tstSecurityConfiguration_intInactivityTimeout = 82340000000,

        [Description("")]
        tstSecurityConfiguration_intPasswordAge = 82350000000,

        [Description("")]
        tstSecurityConfiguration_intPasswordHistoryLength = 82360000000,

        [Description("")]
        tstSecurityConfiguration_intPasswordMinimalLength = 82370000000,

        [Description("")]
        tstSecurityConfigurationAlphabet_idfsSecurityConfigurationAlphabet = 708130000000,

        [Description("")]
        tstSecurityConfigurationAlphabet_strAlphabet = 707870000000,

        [Description("")]
        tstSecurityConfigurationAlphabetParticipation_idfSecurityConfiguration = 82430000000,

        [Description("")]
        tstSecurityConfigurationAlphabetParticipation_idfsSecurityConfigurationAlphabet = 708140000000,

        [Description("")]
        tstSite_blnIsWEB = 4578820000000,

        [Description("Office identifier")]
        tstSite_idfOffice = 82040000000,

        [Description("Country identifier")]
        tstSite_idfsCountry = 82050000000,

        [Description("")]
        tstSite_idfsParentSite = 4578830000000,

        [Description("Site type identifier")]
        tstSite_idfsSiteType = 82070000000,

        [Description("")]
        tstSite_intFlags = 869070000000,

        [Description("Site HASC code")]
        tstSite_strHASCsiteID = 82080000000,

        [Description("Server name")]
        tstSite_strServerName = 82090000000,

        [Description("")]
        tstSite_strSiteID = 869060000000,

        [Description("Site name")]
        tstSite_strSiteName = 82100000000,

        [Description("")]
        tstSiteRelation_idfSiteRelation = 4578220000000,

        [Description("")]
        tstSiteRelation_idfsReceiverSite = 4578850000000,

        [Description("")]
        tstSiteRelation_idfsSenderSite = 4578840000000,

        [Description("")]
        tstUserTable_binPassword = 4578260000000,

        [Description("")]
        tstUserTable_datPasswordSet = 4578240000000,

        [Description("")]
        tstUserTable_datTryDate = 4578230000000,

        [Description("Person identifier")]
        tstUserTable_idfPerson = 82140000000,

        [Description("User identifier")]
        tstUserTable_idfUserID = 82160000000,

        [Description("")]
        tstUserTable_intTry = 4578270000000,

        [Description("")]
        tstUserTable_strAccountName = 4578250000000,

        [Description("")]
        tstUserTableOldPassword_binOldPassword = 4579390000000,

        [Description("")]
        tstUserTableOldPassword_datExpiredDate = 4579380000000,

        [Description("")]
        tstUserTableOldPassword_idfUserID = 4579370000000,

        [Description("Old Password identifier")]
        tstUserTableOldPassword_idfUserOldPassword = 82210000000,

        [Description("Database version")]
        tstVersionCompare_strDatabaseVersion = 82230000000,

        [Description("Module name")]
        tstVersionCompare_strModuleName = 82240000000,

        [Description("Module version")]
        tstVersionCompare_strModuleVersion = 82250000000
    }
}
