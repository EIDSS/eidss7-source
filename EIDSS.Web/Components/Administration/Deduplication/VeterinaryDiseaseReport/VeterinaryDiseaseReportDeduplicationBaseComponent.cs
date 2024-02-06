using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Veterinary;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.SubAreas.Deduplication.ViewModels.VeterinaryDiseaseReportDeduplication;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Administration.Deduplication.VeterinaryDiseaseReport
{
    public class VeterinaryDiseaseReportDeduplicationBaseComponent : BaseComponent
    {
        #region Dependencies

        [Inject]
        protected VeterinaryDiseaseReportDeduplicationSessionStateContainerService
            VeterinaryDiseaseReportDeduplicationService { get; set; }

        [Inject] private ILogger<VeterinaryDiseaseReportDeduplicationBaseComponent> Logger { get; set; }

        [Inject] private IVeterinaryClient VeterinaryClient { get; set; }

        #endregion

        #region Protected and Public Variables

        protected bool DisableMergeButton;
        protected bool ShowNextButton;
        protected bool ShowPreviousButton;
        protected bool ShowDetails = true;
        protected bool ShowReview;

        protected Dictionary<string, int> KeyDict = new()
        {
            {
                "EIDSSReportID",
                0
            },
            {
                "ReportStatusTypeName",
                1
            },
            {
                "ClassificationTypeName",
                2
            },
            {
                "LegacyID",
                3
            },
            {
                "EIDSSFieldAccessionID",
                4
            },
            {
                "EIDSSOutbreakID",
                5
            },
            {
                "EIDSSParentMonitoringSessionID",
                6
            },
            {
                "ReportTypeName",
                7
            },
            {
                "DiagnosisDate",
                8
            },
            {
                "DiseaseName",
                9
            },
            {
                "EIDSSFarmID",
                10
            },
            {
                "FarmName",
                11
            },
            {
                "FarmOwnerLastName",
                12
            },
            {
                "FarmOwnerFirstName",
                13
            },
            {
                "FarmOwnerSecondName",
                14
            },
            {
                "EIDSSFarmOwnerID",
                15
            },
            {
                "Phone",
                16
            },
            {
                "Email",
                17
            },
            {
                "ModifiedDate",
                18
            },
            {
                "FarmAddressAdministrativeLevel0Name",
                19
            },
            {
                "FarmAddressAdministrativeLevel1Name",
                20
            },
            {
                "FarmAddressAdministrativeLevel2Name",
                21
            },
            {
                "FarmAddressSettlementTypeName",
                22
            },
            {
                "FarmAddressAdministrativeLevel3Name",
                23
            },
            {
                "FarmAddressStreetName",
                24
            },
            {
                "FarmAddressHouse",
                25
            },
            {
                "FarmAddressBuilding",
                26
            },
            {
                "FarmAddressApartment",
                27
            },
            {
                "FarmAddressPostalCode",
                28
            },
            {
                "FarmAddressLatitude",
                29
            },
            {
                "FarmAddressLongitude",
                30
            },
            {
                "ReportStatusTypeID",
                31
            },
            {
                "ClassificationTypeID",
                32
            },
            {
                "ReportTypeID",
                33
            },
            {
                "DiseaseID",
                34
            },
            {
                "FarmOwnerID",
                35
            },
            {
                "OutbreakID",
                36
            },
            {
                "ParentMonitoringSessionID",
                37
            },
            {
                "FarmID",
                38
            },
            {
                "FarmMasterID",
                39
            },
            {
                "ReceivedByOrganizationID",
                40
            },
            {
                "ReceivedByPersonID",
                41
            },
            {
                "ReportCategoryTypeID",
                42
            },
            {
                "FarmEpidemiologicalObservationID",
                43
            },
            {
                "ControlMeasuresObservationID",
                44
            },
            {
                "TestsConductedIndicator",
                45
            },
            {
                "OutbreakCaseIndicator",
                46
            }
        };

        protected Dictionary<int, string> LabelDict = new()
        {
            {
                0,
                "ReportID"
            },
            {
                1,
                "ReportStatus"
            },
            {
                2,
                "CaseClassification"
            },
            {
                3,
                "LegacyID"
            },
            {
                4,
                "FieldAccessionID"
            },
            {
                5,
                "OutbreakID"
            },
            {
                6,
                "SessionID"
            },
            {
                7,
                "ReportType"
            },
            {
                8,
                "DiagnosisDate"
            },
            {
                9,
                "Disease"
            },
            {
                10,
                "FarmID"
            },
            {
                11,
                "FarmName"
            },
            {
                12,
                "FarmOwnerLastName"
            },
            {
                13,
                "FarmOwnerFirstName"
            },
            {
                14,
                "FarmOwnerSecondName"
            },
            {
                15,
                "FarmOwnerID"
            },
            {
                16,
                "Phone"
            },
            {
                17,
                "Email"
            },
            {
                18,
                "ModifiedDate"
            },
            {
                19,
                "Country"
            },
            {
                20,
                "Region"
            },
            {
                21,
                "Rayon"
            },
            {
                22,
                "SettlementType"
            },
            {
                23,
                "Settlement"
            },
            {
                24,
                "Street"
            },
            {
                25,
                "House"
            },
            {
                26,
                "Building"
            },
            {
                27,
                "Apartment"
            },
            {
                28,
                "PostalCode"
            },
            {
                29,
                "Latitude"
            },
            {
                30,
                "Longitude"
            },
            {
                31,
                "ReportStatus"
            },
            {
                32,
                "CaseClassification"
            },
            {
                33,
                "ReportType"
            },
            {
                34,
                "Disease"
            },
            {
                35,
                "FarmOwnerID"
            },
            {
                36,
                "OutbreakID"
            },
            {
                37,
                "ParentMonitoringSessionID"
            },
            {
                38,
                "FarmID"
            },
            {
                39,
                "FarmMasterID"
            },
            {
                40,
                "ReceivedByOrganizationID"
            },
            {
                41,
                "ReceivedByPersonID"
            },
            {
                42,
                "ReportCategoryTypeID"
            },
            {
                43,
                "FarmEpidemiologicalObservationID"
            },
            {
                44,
                "ControlMeasuresObservationID"
            },
            {
                45,
                "TestsConductedIndicator"
            },
            {
                46,
                "OutbreakCaseIndicator"
            }
        };

        protected Dictionary<string, int> KeyDict2 = new()
        {
            {
                "ReportedByOrganizationName",
                0
            },
            {
                "ReportedByPersonName",
                1
            },
            {
                "ReportDate",
                2
            },
            {
                "InvestigatedByOrganizationName",
                3
            },
            {
                "InvestigatedByPersonName",
                4
            },
            {
                "AssignedDate",
                5
            },
            {
                "InvestigationDate",
                6
            },
            {
                "SiteName",
                7
            },
            {
                "EnteredByPersonName",
                8
            },
            {
                "EnteredDate",
                9
            },
            {
                "ReportedByOrganizationID",
                10
            },
            {
                "ReportedByPersonID",
                11
            },
            {
                "InvestigatedByOrganizationID",
                12
            },
            {
                "InvestigatedByPersonID",
                13
            },
            {
                "SiteID",
                14
            }
        };

        protected Dictionary<int, string> LabelDict2 = new()
        {
            {
                0,
                "ReportedByOrganization"
            },
            {
                1,
                "ReportedByPerson"
            },
            {
                2,
                "ReportDate"
            },
            {
                3,
                "InvestigatedByOrganization"
            },
            {
                4,
                "InvestigatedByPerson"
            },
            {
                5,
                "AssignedDate"
            },
            {
                6,
                "InvestigationDate"
            },
            {
                7,
                "Site"
            },
            {
                8,
                "EnteredByPerson"
            },
            {
                9,
                "EnteredDate"
            },
            {
                10,
                "ReportedByOrganization"
            },
            {
                11,
                "ReportedByPerson"
            },
            {
                12,
                "InvestigatedByOrganization"
            },
            {
                13,
                "InvestigatedByPerson"
            },
            {
                14,
                "Site"
            }
        };

        protected const int ReportStatusTypeId = 31;
        protected const int ReportedByOrganizationId = 10;

        public string FarmInventoryHeadingResourceKey { get; set; }
        public string SpeciesColumnHeadingResourceKey { get; set; }
        public string TotalColumnHeadingResourceKey { get; set; }
        public string SickColumnHeadingResourceKey { get; set; }
        public string DeadColumnHeadingResourceKey { get; set; }
        public string StartOfSignsDateColumnHeadingResourceKey { get; set; }
        public string AverageAgeColumnHeadingResourceKey { get; set; }
        public string NoteColumnHeadingResourceKey { get; set; }

        public string LabSampleIdColumnHeadingResourceKey { get; set; }
        public string SampleTypeColumnHeadingResourceKey { get; set; }
        public string FieldSampleIdColumnHeadingResourceKey { get; set; }

        public string AnimalIdColumnHeadingResourceKey { get; set; }

        //public string SpeciesColumnHeadingResourceKey { get; set; }
        public string BirdStatusColumnHeadingResourceKey { get; set; }
        public string CollectionDateColumnHeadingResourceKey { get; set; }
        public string SentDateColumnHeadingResourceKey { get; set; }
        public string SentToOrganizationColumnHeadingResourceKey { get; set; }

        public string TestNameColumnHeadingResourceKey { get; set; }
        public string ResultColumnHeadingResourceKey { get; set; }

        public string LabTestsSubSectionHeadingResourceKey { get; set; }
        public string ResultsSummaryAndInterpretationSubSectionResourceKey { get; set; }
        public string LaboratoryTestsFieldSampleIdColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestsSpeciesColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestsAnimalIdColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestsTestDiseaseColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestsTestNameColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestsResultObservationColumnHeadingResourceKey { get; set; }
        public string LabSampleIdFieldLabelResourceKey { get; set; }
        public string SampleTypeFieldLabelResourceKey { get; set; }
        public string TestStatusFieldLabelResourceKey { get; set; }
        public string TestCategoryFieldLabelResourceKey { get; set; }
        public string ResultDateFieldLabelResourceKey { get; set; }
        public string DiseaseColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsSpeciesColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsAnimalIdColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsDiseaseColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsTestNameColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsTestCategoryColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsTestResultColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsLabSampleIdColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsSampleTypeColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsFieldSampleIdColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsRuleOutRuleInColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsRuleOutRuleInCommentColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsDateInterpretedColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsInterpretedByColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsValidatedColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsValidatedCommentColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsDateValidatedColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsValidatedByColumnHeadingResourceKey { get; set; }

        #endregion

        #region Private Member Variables


        private readonly CancellationToken _token;

        #endregion

        #region Protected and Public Methods

        public async Task<List<FarmInventoryGetListViewModel>> GetFarmInventory(long diseaseReportId, long farmMasterId,
            long? farmId)
        {
            var request = new FarmInventoryGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                DiseaseReportID = diseaseReportId,
                FarmID = diseaseReportId > 0 ? farmId : null, // For existing disease reports.
                FarmMasterID =
                    diseaseReportId == 0 ? farmMasterId : null, // For disease reports that have not been saved.
                Page = 1,
                PageSize = int.MaxValue - 1,
                SortColumn = "RecordID",
                SortOrder = SortConstants.Ascending
            };

            return await VeterinaryClient.GetFarmInventoryList(request, _token);
        }

        public async Task<List<VaccinationGetListViewModel>> GetVaccinations(long diseaseReportId, int page,
            int pageSize, string sortColumn, string sortOrder)
        {
            var request = new VaccinationGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                DiseaseReportID = diseaseReportId,
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder
            };

            return await VeterinaryClient.GetVaccinationList(request, _token).ConfigureAwait(false);
        }

        public async Task<List<AnimalGetListViewModel>> GetAnimals(long diseaseReportId, int page, int pageSize,
            string sortColumn, string sortOrder)
        {
            var request = new AnimalGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                DiseaseReportID = diseaseReportId,
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder
            };

            return await VeterinaryClient.GetAnimalList(request, _token).ConfigureAwait(false);
        }

        public async Task<List<SampleGetListViewModel>> GetSamples(long diseaseReportId, int page, int pageSize,
            string sortColumn, string sortOrder)
        {
            var request = new SampleGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                DiseaseReportID = diseaseReportId,
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder
            };

            var list = await VeterinaryClient.GetSampleList(request, _token).ConfigureAwait(false);

            for (var index = 0; index < list.Count; index++)
                if (string.IsNullOrEmpty(list[index].EIDSSLocalOrFieldSampleID))
                    list[index].EIDSSLocalOrFieldSampleID = "(" +
                                                            Localizer.GetString(FieldLabelResourceKeyConstants
                                                                .CommonLabelsNewFieldLabel) + " " + (index + 1) + ")";

            return list;
        }

        public async Task<List<PensideTestGetListViewModel>> GetPensideTests(long diseaseReportId, int page,
            int pageSize, string sortColumn, string sortOrder)
        {
            if (diseaseReportId <= 0) return new List<PensideTestGetListViewModel>();

            var request = new PensideTestGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                DiseaseReportID = diseaseReportId,
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder
            };

            return await VeterinaryClient.GetPensideTestList(request, _token).ConfigureAwait(false);
        }

        public async Task<List<LaboratoryTestGetListViewModel>> GetLaboratoryTests(long diseaseReportId, int page,
            int pageSize, string sortColumn, string sortOrder)
        {
            if (diseaseReportId <= 0) return new List<LaboratoryTestGetListViewModel>();

            var request = new LaboratoryTestGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                DiseaseReportID = diseaseReportId,
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder
            };

            return await VeterinaryClient.GetLaboratoryTestList(request, _token).ConfigureAwait(false);
        }

        public async Task<List<LaboratoryTestInterpretationGetListViewModel>> GetLaboratoryTestInterpretations(
            long diseaseReportId, int page, int pageSize, string sortColumn, string sortOrder)
        {
            if (diseaseReportId <= 0) return new List<LaboratoryTestInterpretationGetListViewModel>();

            var request = new LaboratoryTestInterpretationGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                DiseaseReportID = diseaseReportId,
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder
            };

            return await VeterinaryClient.GetLaboratoryTestInterpretationList(request, _token).ConfigureAwait(false);
        }

        public async Task<List<CaseLogGetListViewModel>> GetCaseLogs(long diseaseReportId, int page, int pageSize,
            string sortColumn, string sortOrder)
        {
            var request = new CaseLogGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                DiseaseReportID = diseaseReportId,
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder
            };

            return await VeterinaryClient.GetCaseLogList(request, _token).ConfigureAwait(false);
        }

        public void OnTabChange(int index)
        {
            switch (index)
            {
                case 0:
                    VeterinaryDiseaseReportDeduplicationService.Tab =
                        VeterinaryDiseaseReportDeduplicationTabEnum.FarmDetails;
                    ShowPreviousButton = false;
                    ShowNextButton = true;
                    break;
                case 1:
                    VeterinaryDiseaseReportDeduplicationService.Tab =
                        VeterinaryDiseaseReportDeduplicationTabEnum.Notification;
                    ShowPreviousButton = true;
                    ShowNextButton = true;
                    break;
                case 2:
                    VeterinaryDiseaseReportDeduplicationService.Tab =
                        VeterinaryDiseaseReportDeduplicationTabEnum.FarmInventory;
                    ShowPreviousButton = true;
                    ShowNextButton = true;
                    break;
                case 3:
                    VeterinaryDiseaseReportDeduplicationService.Tab =
                        VeterinaryDiseaseReportDeduplicationTabEnum.FarmEpiInformation;
                    ShowPreviousButton = true;
                    ShowNextButton = true;
                    break;
                case 4:
                    VeterinaryDiseaseReportDeduplicationService.Tab =
                        VeterinaryDiseaseReportDeduplicationTabEnum.SpeciesInvestigation;
                    ShowPreviousButton = true;
                    ShowNextButton = true;
                    break;
                case 5:
                    VeterinaryDiseaseReportDeduplicationService.Tab =
                        VeterinaryDiseaseReportDeduplicationTabEnum.Vaccination;
                    ShowPreviousButton = true;
                    ShowNextButton = true;
                    break;
                case 6:
                    VeterinaryDiseaseReportDeduplicationService.Tab =
                        VeterinaryDiseaseReportDeduplicationTabEnum.ControlMeasures;
                    ShowPreviousButton = true;
                    ShowNextButton = true;
                    break;
                case 7:
                    VeterinaryDiseaseReportDeduplicationService.Tab =
                        VeterinaryDiseaseReportDeduplicationTabEnum.Animals;
                    ShowPreviousButton = true;
                    ShowNextButton = true;
                    break;
                case 8:
                    VeterinaryDiseaseReportDeduplicationService.Tab =
                        VeterinaryDiseaseReportDeduplicationTabEnum.Samples;
                    ShowPreviousButton = true;
                    ShowNextButton = true;
                    break;
                case 9:
                    VeterinaryDiseaseReportDeduplicationService.Tab =
                        VeterinaryDiseaseReportDeduplicationTabEnum.PensideTests;
                    ShowPreviousButton = true;
                    ShowNextButton = true;
                    break;
                case 10:
                    VeterinaryDiseaseReportDeduplicationService.Tab =
                        VeterinaryDiseaseReportDeduplicationTabEnum.LabTests;
                    ShowPreviousButton = true;
                    ShowNextButton = true;
                    break;
                case 11:
                    VeterinaryDiseaseReportDeduplicationService.Tab =
                        VeterinaryDiseaseReportDeduplicationTabEnum.CaseLog;
                    ShowPreviousButton = true;
                    ShowNextButton = false;
                    break;
            }

            VeterinaryDiseaseReportDeduplicationService.TabChangeIndicator = true;
        }

        protected bool IsInTabFarmDetails(string strName)
        {
            return strName switch
            {
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.EIDSSReportID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.ReportStatus => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.CaseClassification => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.LegacyID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.EIDSSFieldAccessionID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.EIDSSOutbreakID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.EIDSSParentMonitoringSessionID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.ReportType => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.DiagnosisDate => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.Disease => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.EIDSSFarmID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.FarmName => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.FarmOwnerLastName => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.FarmOwnerFirstName => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.FarmOwnerSecondName => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.FarmOwnerID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.EIDSSFarmOwnerID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.Phone => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.Fax => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.Email => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.ModifiedDate => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.Country => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.Region => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.Rayon => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.SettlementType => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.Settlement => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.Street => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.Building => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.Apartment => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.House => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.PostalCode => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.Longitude => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.Latitude => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.ReportStatusTypeID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.ClassificationTypeID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.ReportTypeID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.DiseaseID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.OutbreakID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.ParentMonitoringSessionID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.FarmID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.FarmMasterID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.ReceivedByOrganizationID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.ReceivedByPersonID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.ReportCategoryTypeID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.FarmEpidemiologicalObservationID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.ControlMeasuresObservationID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.TestsConductedIndicator => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.OutbreakCaseIndicator => true,
                _ => false
            };
        }

        protected bool IsInTabNotification(string strName)
        {
            switch (strName)
            {
                case VeterinaryDiseaseReportDeduplicationNotificationConstants.ReportedByOrganizationName:
                    return true;
                case VeterinaryDiseaseReportDeduplicationNotificationConstants.ReportedByPersonName:
                    return true;
                case VeterinaryDiseaseReportDeduplicationNotificationConstants.ReportDate:
                    return true;
                case VeterinaryDiseaseReportDeduplicationNotificationConstants.InvestigatedByOrganizationName:
                    return true;
                case VeterinaryDiseaseReportDeduplicationNotificationConstants.InvestigatedByPersonName:
                    return true;
                case VeterinaryDiseaseReportDeduplicationNotificationConstants.AssignedDate:
                    return true;
                case VeterinaryDiseaseReportDeduplicationNotificationConstants.InvestigationDate:
                    return true;
                case VeterinaryDiseaseReportDeduplicationNotificationConstants.SiteName:
                    return true;
                case VeterinaryDiseaseReportDeduplicationNotificationConstants.EnteredByPersonName:
                    return true;
                case VeterinaryDiseaseReportDeduplicationNotificationConstants.EnteredDate:
                    return true;
                case VeterinaryDiseaseReportDeduplicationNotificationConstants.ReportedByOrganizationID:
                    return true;
                case VeterinaryDiseaseReportDeduplicationNotificationConstants.ReportedByPersonID:
                    return true;
                case VeterinaryDiseaseReportDeduplicationNotificationConstants.InvestigatedByOrganizationID:
                    return true;
                case VeterinaryDiseaseReportDeduplicationNotificationConstants.InvestigatedByPersonID:
                    return true;
                case VeterinaryDiseaseReportDeduplicationNotificationConstants.SiteID:
                    return true;
            }

            return false;
        }


        protected bool AllFieldValuePairsUnmatched()
        {
            try
            {
                return !VeterinaryDiseaseReportDeduplicationService.InfoList.Any(item =>
                           item.Value == VeterinaryDiseaseReportDeduplicationService.InfoList2[item.Index].Value &&
                           !string.IsNullOrEmpty(item.Value)) &&
                       VeterinaryDiseaseReportDeduplicationService.NotificationList.All(item =>
                           item.Value != VeterinaryDiseaseReportDeduplicationService.NotificationList2[item.Index]
                               .Value ||
                           string.IsNullOrEmpty(item.Value));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }

            return false;
        }

        protected void UnCheckAll()
        {
            VeterinaryDiseaseReportDeduplicationService.chkCheckAll = false;
            VeterinaryDiseaseReportDeduplicationService.chkCheckAll2 = false;
            VeterinaryDiseaseReportDeduplicationService.chkCheckAllVaccination = false;
            VeterinaryDiseaseReportDeduplicationService.chkCheckAllVaccination2 = false;
            VeterinaryDiseaseReportDeduplicationService.chkCheckAllAnimals = false;
            VeterinaryDiseaseReportDeduplicationService.chkCheckAllAnimals2 = false;
            VeterinaryDiseaseReportDeduplicationService.chkCheckAllSamples = false;
            VeterinaryDiseaseReportDeduplicationService.chkCheckAllSamples2 = false;
            VeterinaryDiseaseReportDeduplicationService.chkCheckAllCaseLog = false;
            VeterinaryDiseaseReportDeduplicationService.chkCheckAllCaseLog2 = false;
        }

        protected bool TabFarmDetailsValid()
        {
            return IsFarmDetailsValid();
        }

        protected async Task BindTabFarmDetailsAsync()
        {
            VeterinaryDiseaseReportDeduplicationService.InfoList = VeterinaryDiseaseReportDeduplicationService.InfoList0
                .Select(a => a.Copy()).ToList();
            VeterinaryDiseaseReportDeduplicationService.InfoList2 = VeterinaryDiseaseReportDeduplicationService
                .InfoList02.Select(a => a.Copy()).ToList();

            foreach (var item in VeterinaryDiseaseReportDeduplicationService.InfoList)
            {
                if (!item.Checked) continue;
                item.Checked = true;
                item.Disabled = true;
                VeterinaryDiseaseReportDeduplicationService.InfoList2[item.Index].Checked = true;
                VeterinaryDiseaseReportDeduplicationService.InfoList2[item.Index].Disabled = true;
            }

            await EnableDisableMergeButtonAsync();
            TabFarmDetailsValid();
        }

        protected async Task EnableDisableMergeButtonAsync()
        {
            if (AllTabValid())
            {
                DisableMergeButton = false;
                await InvokeAsync(StateHasChanged);
            }
            else
            {
                DisableMergeButton = true;
            }

            await InvokeAsync(StateHasChanged);
        }

        protected bool AllTabValid()
        {
            if (IsFarmDetailsValid() == false) return false;

            return IsNotificationValid();
        }

        protected async Task CheckAllAsync(IList<Field> list, IList<Field> list2, bool check, bool check2,
            IList<Field> survivorList, string strValidTabName)
        {
            try
            {
                if (AllFieldValuePairsUnmatched())
                {
                    await ShowInformationalDialog(
                        MessageResourceKeyConstants
                            .DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage,
                        null);
                    UnCheckAll();
                }
                else if (VeterinaryDiseaseReportDeduplicationService.RecordSelection == 0 &&
                         VeterinaryDiseaseReportDeduplicationService.Record2Selection == 0)
                {
                    await ShowInformationalDialog(
                        MessageResourceKeyConstants
                            .DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage,
                        null);
                    UnCheckAll();
                }
                else
                {
                    if (check)
                    {
                        foreach (var item in list)
                            if (item.Checked == false)
                            {
                                item.Checked = true;
                                list2[item.Index].Checked = false;
                                var value = item.Value;
                                if (survivorList is {Count: > 0})
                                {
                                    var label = survivorList[item.Index].Label;

                                    if (value == null)
                                        survivorList[item.Index].Label = survivorList[item.Index].Value == null
                                            ? label.Replace(": ", ": " + string.Empty)
                                            : label.Replace(survivorList[item.Index].Value, "");
                                    else
                                        switch (survivorList[item.Index].Value)
                                        {
                                            case null:
                                            case "":
                                                survivorList[item.Index].Label = label.Replace(": ", ": " + value);
                                                break;
                                            default:
                                                survivorList[item.Index].Label =
                                                    label.Replace(survivorList[item.Index].Value, value);
                                                break;
                                        }

                                    survivorList[item.Index].Value = value;
                                }
                            }

                        foreach (var item in list)
                            if (item.Checked && list2[item.Index].Checked)
                                item.Disabled = true;
                    }
                }

                //await EnableDisableMergeButtonAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        protected async Task OnRecordSelectionChangeAsync(VeterinaryReportTypeEnum reportType, int value)
        {
            var bFirst = VeterinaryDiseaseReportDeduplicationService.SurvivorInfoList == null;

            UnCheckAll();
            if (bFirst == false)
                ReloadTabs();

            switch (value)
            {
                case 1:
                    VeterinaryDiseaseReportDeduplicationService.RecordSelection = 1;
                    VeterinaryDiseaseReportDeduplicationService.Record2Selection = 2;
                    VeterinaryDiseaseReportDeduplicationService.SurvivorVeterinaryDiseaseReportID =
                        VeterinaryDiseaseReportDeduplicationService.VeterinaryDiseaseReportID;
                    VeterinaryDiseaseReportDeduplicationService.SupersededVeterinaryDiseaseReportID =
                        VeterinaryDiseaseReportDeduplicationService.VeterinaryDiseaseReportID2;

                    VeterinaryDiseaseReportDeduplicationService.SurvivorInfoList =
                        VeterinaryDiseaseReportDeduplicationService.InfoList0.Select(a => a.Copy()).ToList();
                    VeterinaryDiseaseReportDeduplicationService.SurvivorNotificationList =
                        VeterinaryDiseaseReportDeduplicationService.NotificationList0.Select(a => a.Copy()).ToList();

                    CheckAllSurvivorFields(VeterinaryDiseaseReportDeduplicationService.InfoList,
                        VeterinaryDiseaseReportDeduplicationService.InfoList2,
                        VeterinaryDiseaseReportDeduplicationService.NotificationList,
                        VeterinaryDiseaseReportDeduplicationService.NotificationList2);
                    SelectAllSurvivorRowsAndFlexForm(reportType, false);
                    break;
                case 2:
                    VeterinaryDiseaseReportDeduplicationService.RecordSelection = 2;
                    VeterinaryDiseaseReportDeduplicationService.Record2Selection = 1;
                    VeterinaryDiseaseReportDeduplicationService.SurvivorVeterinaryDiseaseReportID =
                        VeterinaryDiseaseReportDeduplicationService.VeterinaryDiseaseReportID2;
                    VeterinaryDiseaseReportDeduplicationService.SupersededVeterinaryDiseaseReportID =
                        VeterinaryDiseaseReportDeduplicationService.VeterinaryDiseaseReportID;

                    VeterinaryDiseaseReportDeduplicationService.SurvivorInfoList =
                        VeterinaryDiseaseReportDeduplicationService.InfoList02.Select(a => a.Copy()).ToList();
                    VeterinaryDiseaseReportDeduplicationService.SurvivorNotificationList =
                        VeterinaryDiseaseReportDeduplicationService.NotificationList02.Select(a => a.Copy()).ToList();
                    CheckAllSurvivorFields(VeterinaryDiseaseReportDeduplicationService.InfoList2,
                        VeterinaryDiseaseReportDeduplicationService.InfoList,
                        VeterinaryDiseaseReportDeduplicationService.NotificationList2,
                        VeterinaryDiseaseReportDeduplicationService.NotificationList);
                    SelectAllSurvivorRowsAndFlexForm(reportType, true);
                    break;
            }

            await InvokeAsync(StateHasChanged);
        }

        protected async Task OnRecord2SelectionChangeAsync(VeterinaryReportTypeEnum reportType, int value)
        {
            var bFirst = VeterinaryDiseaseReportDeduplicationService.SurvivorInfoList == null;

            UnCheckAll();
            if (bFirst == false)
                ReloadTabs();

            switch (value)
            {
                case 1:
                    VeterinaryDiseaseReportDeduplicationService.RecordSelection = 2;
                    VeterinaryDiseaseReportDeduplicationService.Record2Selection = 1;
                    VeterinaryDiseaseReportDeduplicationService.SurvivorVeterinaryDiseaseReportID =
                        VeterinaryDiseaseReportDeduplicationService.VeterinaryDiseaseReportID2;
                    VeterinaryDiseaseReportDeduplicationService.SupersededVeterinaryDiseaseReportID =
                        VeterinaryDiseaseReportDeduplicationService.VeterinaryDiseaseReportID;

                    VeterinaryDiseaseReportDeduplicationService.SurvivorInfoList =
                        VeterinaryDiseaseReportDeduplicationService.InfoList02.Select(a => a.Copy()).ToList();
                    VeterinaryDiseaseReportDeduplicationService.SurvivorNotificationList =
                        VeterinaryDiseaseReportDeduplicationService.NotificationList02.Select(a => a.Copy()).ToList();

                    CheckAllSurvivorFields(VeterinaryDiseaseReportDeduplicationService.InfoList2,
                        VeterinaryDiseaseReportDeduplicationService.InfoList,
                        VeterinaryDiseaseReportDeduplicationService.NotificationList2,
                        VeterinaryDiseaseReportDeduplicationService.NotificationList);
                    SelectAllSurvivorRowsAndFlexForm(reportType, true);
                    break;
                case 2:
                    VeterinaryDiseaseReportDeduplicationService.RecordSelection = 1;
                    VeterinaryDiseaseReportDeduplicationService.Record2Selection = 2;
                    VeterinaryDiseaseReportDeduplicationService.SurvivorVeterinaryDiseaseReportID =
                        VeterinaryDiseaseReportDeduplicationService.VeterinaryDiseaseReportID;
                    VeterinaryDiseaseReportDeduplicationService.SupersededVeterinaryDiseaseReportID =
                        VeterinaryDiseaseReportDeduplicationService.VeterinaryDiseaseReportID2;

                    VeterinaryDiseaseReportDeduplicationService.SurvivorInfoList =
                        VeterinaryDiseaseReportDeduplicationService.InfoList0.Select(a => a.Copy()).ToList();
                    VeterinaryDiseaseReportDeduplicationService.SurvivorNotificationList =
                        VeterinaryDiseaseReportDeduplicationService.NotificationList0.Select(a => a.Copy()).ToList();

                    CheckAllSurvivorFields(VeterinaryDiseaseReportDeduplicationService.InfoList,
                        VeterinaryDiseaseReportDeduplicationService.InfoList2,
                        VeterinaryDiseaseReportDeduplicationService.NotificationList,
                        VeterinaryDiseaseReportDeduplicationService.NotificationList2);
                    SelectAllSurvivorRowsAndFlexForm(reportType, false);
                    break;
            }

            await InvokeAsync(StateHasChanged);
        }

        protected void ReloadTabs()
        {
            //Bind Tab Info
            VeterinaryDiseaseReportDeduplicationService.InfoList = VeterinaryDiseaseReportDeduplicationService.InfoList0
                .Select(a => a.Copy()).ToList();
            VeterinaryDiseaseReportDeduplicationService.InfoList2 = VeterinaryDiseaseReportDeduplicationService
                .InfoList02.Select(a => a.Copy()).ToList();

            foreach (var item in VeterinaryDiseaseReportDeduplicationService.InfoList)
            {
                if (item.Checked)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    VeterinaryDiseaseReportDeduplicationService.InfoList2[item.Index].Checked = true;
                    VeterinaryDiseaseReportDeduplicationService.InfoList2[item.Index].Disabled = true;
                }

                //LegacyID, OutbreakID, SessionID are non-editable fields
                if (item.Key is not (VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.LegacyID
                    or VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.EIDSSOutbreakID
                    or VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.EIDSSParentMonitoringSessionID))
                    continue;
                item.Disabled = true;
                VeterinaryDiseaseReportDeduplicationService.InfoList2[item.Index].Disabled = true;
            }

            //Bind Tab Notification
            VeterinaryDiseaseReportDeduplicationService.NotificationList = VeterinaryDiseaseReportDeduplicationService
                .NotificationList0.Select(a => a.Copy()).ToList();
            VeterinaryDiseaseReportDeduplicationService.NotificationList2 = VeterinaryDiseaseReportDeduplicationService
                .NotificationList02.Select(a => a.Copy()).ToList();

            foreach (var item in VeterinaryDiseaseReportDeduplicationService.NotificationList)
            {
                if (item.Checked)
                {
                    item.Checked = true;
                    VeterinaryDiseaseReportDeduplicationService.NotificationList2[item.Index].Checked = true;
                }

                //Notification fields are non-editable fields
                item.Disabled = true;
                VeterinaryDiseaseReportDeduplicationService.NotificationList2[item.Index].Disabled = true;
            }

            VeterinaryDiseaseReportDeduplicationService.SelectedVaccinations = null;
            VeterinaryDiseaseReportDeduplicationService.SelectedAnimals = null;
            VeterinaryDiseaseReportDeduplicationService.SelectedSamples = null;
            VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests = null;
            VeterinaryDiseaseReportDeduplicationService.SelectedLabTests = null;
            VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations = null;
            VeterinaryDiseaseReportDeduplicationService.SelectedCaseLogs = null;
            VeterinaryDiseaseReportDeduplicationService.SelectedVaccinations2 = null;
            VeterinaryDiseaseReportDeduplicationService.SelectedAnimals2 = null;
            VeterinaryDiseaseReportDeduplicationService.SelectedSamples2 = null;
            VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests2 = null;
            VeterinaryDiseaseReportDeduplicationService.SelectedLabTests2 = null;
            VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations2 = null;
            VeterinaryDiseaseReportDeduplicationService.SelectedCaseLogs2 = null;

            //ClearTabs();
        }

        protected void CheckAllSurvivorFields(IList<Field> list, IList<Field> list2, IList<Field> listNotification,
            IList<Field> listNotification2)
        {
            foreach (var item in list)
            {
                item.Checked = true;
                list2[item.Index].Checked = false;
            }

            foreach (var item in listNotification)
            {
                item.Checked = true;
                listNotification2[item.Index].Checked = false;
            }
        }

        protected void SelectAllSurvivorRowsAndFlexForm(VeterinaryReportTypeEnum reportType, bool record2)
        {
            if (record2 == false)
            {
                VeterinaryDiseaseReportDeduplicationService.SurvivorFarmInventory =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.FarmInventory);

                VeterinaryDiseaseReportDeduplicationService.SurvivorFarmEpiFlexFormRequest =
                    VeterinaryDiseaseReportDeduplicationService.FarmEpiFlexFormRequest;
                VeterinaryDiseaseReportDeduplicationService.SurvivorControlMeasuresFlexFormRequest =
                    VeterinaryDiseaseReportDeduplicationService.ControlMeasuresFlexFormRequest;
                VeterinaryDiseaseReportDeduplicationService.SurvivorSpeciesFlexFormRequest =
                    VeterinaryDiseaseReportDeduplicationService.SpeciesFlexFormRequest;
                VeterinaryDiseaseReportDeduplicationService.SurvivorSpecies =
                    VeterinaryDiseaseReportDeduplicationService.Species;

                VeterinaryDiseaseReportDeduplicationService.SelectedVaccinations =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.Vaccinations);
                VeterinaryDiseaseReportDeduplicationService.SelectedAnimals =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.Animals);
                VeterinaryDiseaseReportDeduplicationService.SelectedSamples =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.Samples);
                VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.PensideTests);
                VeterinaryDiseaseReportDeduplicationService.SelectedLabTests =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.LabTests);
                VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.Interpretations);
                VeterinaryDiseaseReportDeduplicationService.SelectedCaseLogs =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.CaseLogs);

                VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.Vaccinations);
                VeterinaryDiseaseReportDeduplicationService.SurvivorAnimals =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.Animals);
                VeterinaryDiseaseReportDeduplicationService.SurvivorSamples =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.Samples);
                VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.PensideTests);
                VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.LabTests);
                VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.Interpretations);
                VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogs =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.CaseLogs);
            }
            else
            {
                VeterinaryDiseaseReportDeduplicationService.SurvivorFarmInventory =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.FarmInventory2);

                VeterinaryDiseaseReportDeduplicationService.SurvivorFarmEpiFlexFormRequest =
                    VeterinaryDiseaseReportDeduplicationService.FarmEpiFlexFormRequest2;
                VeterinaryDiseaseReportDeduplicationService.SurvivorControlMeasuresFlexFormRequest =
                    VeterinaryDiseaseReportDeduplicationService.ControlMeasuresFlexFormRequest2;
                VeterinaryDiseaseReportDeduplicationService.SurvivorSpeciesFlexFormRequest =
                    VeterinaryDiseaseReportDeduplicationService.SpeciesFlexFormRequest2;
                VeterinaryDiseaseReportDeduplicationService.SurvivorSpecies =
                    VeterinaryDiseaseReportDeduplicationService.Species2;

                VeterinaryDiseaseReportDeduplicationService.SelectedVaccinations2 =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.Vaccinations2);
                VeterinaryDiseaseReportDeduplicationService.SelectedAnimals2 =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.Animals2);
                VeterinaryDiseaseReportDeduplicationService.SelectedSamples2 =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.Samples2);
                VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests2 =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.PensideTests2);
                VeterinaryDiseaseReportDeduplicationService.SelectedLabTests2 =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.LabTests2);
                VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations2 =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.Interpretations2);
                VeterinaryDiseaseReportDeduplicationService.SelectedCaseLogs2 =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.CaseLogs2);

                VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.Vaccinations2);
                VeterinaryDiseaseReportDeduplicationService.SurvivorAnimals =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.Animals2);
                VeterinaryDiseaseReportDeduplicationService.SurvivorSamples =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.Samples2);
                VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.PensideTests2);
                VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.LabTests2);
                VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.Interpretations2);
                VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogs =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.CaseLogs2);
            }

            VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinationsCount =
                VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations?.Count ?? 0;
            if (reportType == VeterinaryReportTypeEnum.Livestock)
                VeterinaryDiseaseReportDeduplicationService.SurvivorAnimalsCount =
                    VeterinaryDiseaseReportDeduplicationService.SurvivorAnimals?.Count ?? 0;

            VeterinaryDiseaseReportDeduplicationService.SurvivorSamplesCount =
                VeterinaryDiseaseReportDeduplicationService.SurvivorSamples?.Count ?? 0;
            VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTestsCount =
                VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests?.Count ?? 0;
            VeterinaryDiseaseReportDeduplicationService.SurvivorLabTestsCount =
                VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests?.Count ?? 0;
            VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretationsCount =
                VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations?.Count ?? 0;
            VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogsCount =
                VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogs?.Count ?? 0;
        }

        protected IList<TModel> CopyAllInList<TModel>(IList<TModel> listToCopy)
        {
            return listToCopy?.ToList();
        }

        protected IList<TModel> AddListToList<TModel>(IList<TModel> list, IList<TModel> listToAdd)
        {
            list ??= new List<TModel>();

            foreach (var row in listToAdd) list.Add(row);

            return list;
        }

        protected IList<TModel> RemoveListFromList<TModel>(IList<TModel> list, IList<TModel> listToRemove)
        {
            if (list == null) return null;
            foreach (var row in listToRemove) list.Remove(row);

            return list;
        }

        public async Task<dynamic> ShowWarningMessage(string message, string localizedMessage)
        {
            List<DialogButton> buttons = new();
            var okButton = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                ButtonType = DialogButtonType.OK
            };
            buttons.Add(okButton);

            Dictionary<string, object> dialogParams = new()
            {
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {nameof(EIDSSDialog.Message), string.IsNullOrEmpty(message) ? null : Localizer.GetString(message)},
                {nameof(EIDSSDialog.LocalizedMessage), localizedMessage},
                {nameof(EIDSSDialog.DialogType), EIDSSDialogType.Warning}
            };

            return await DiagService.OpenAsync<EIDSSDialog>(null, dialogParams);
        }

        protected bool AllFieldValuePairsSelected()
        {
            try
            {
                if (VeterinaryDiseaseReportDeduplicationService.InfoList.Any(item => !item.Checked &&
                        !VeterinaryDiseaseReportDeduplicationService.InfoList2[item.Index].Checked))
                {
                    VeterinaryDiseaseReportDeduplicationService.AvianTab =
                        AvianDiseaseReportDeduplicationTabEnum.FarmDetails;
                    VeterinaryDiseaseReportDeduplicationService.Tab =
                        VeterinaryDiseaseReportDeduplicationTabEnum.FarmDetails;
                    ShowPreviousButton = false;
                    ShowNextButton = true;
                    return false;
                }

                if (VeterinaryDiseaseReportDeduplicationService.NotificationList.Any(item => !item.Checked &&
                        !VeterinaryDiseaseReportDeduplicationService.NotificationList2[item.Index].Checked))
                {
                    VeterinaryDiseaseReportDeduplicationService.AvianTab =
                        AvianDiseaseReportDeduplicationTabEnum.Notification;
                    VeterinaryDiseaseReportDeduplicationService.Tab =
                        VeterinaryDiseaseReportDeduplicationTabEnum.Notification;
                    ShowPreviousButton = true;
                    ShowNextButton = true;
                    return false;
                }

                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }

            return false;
        }

        protected void AddSamplesToSurvivorList(IList<SampleGetListViewModel> listToAdd)
        {
            VeterinaryDiseaseReportDeduplicationService.SurvivorSamples ??= new List<SampleGetListViewModel>();
            foreach (var row in listToAdd)
            {
                var list = VeterinaryDiseaseReportDeduplicationService.SurvivorSamples
                    .Where(x => x.SampleID == row.SampleID).ToList();
                if (list.Count == 0)
                    VeterinaryDiseaseReportDeduplicationService.SurvivorSamples.Add(row);
            }
        }

        protected void AddPensideTestsToSurvivorList(IList<PensideTestGetListViewModel> listToAdd)
        {
            VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests ??=
                new List<PensideTestGetListViewModel>();
            foreach (var row in listToAdd)
            {
                var list = VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests
                    .Where(x => x.PensideTestID == row.PensideTestID).ToList();
                if (list.Count == 0)
                    VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests.Add(row);
            }
        }

        protected void AddLabTestsToSurvivorList(IList<LaboratoryTestGetListViewModel> listToAdd)
        {
            VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests ??= new List<LaboratoryTestGetListViewModel>();
            foreach (var row in listToAdd)
            {
                var list = VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests
                    .Where(x => x.TestID == row.TestID).ToList();
                if (list.Count == 0)
                    VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests.Add(row);
            }
        }

        protected void AddInterpretationsToSurvivorList(IList<LaboratoryTestInterpretationGetListViewModel> listToAdd)
        {
            VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations ??=
                new List<LaboratoryTestInterpretationGetListViewModel>();
            foreach (var row in listToAdd)
            {
                var list = VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations
                    .Where(x => x.TestInterpretationID == row.TestInterpretationID).ToList();
                if (list.Count == 0)
                    VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations.Add(row);
            }
        }

        protected void AddPensideTestsToSelectedList(IList<PensideTestGetListViewModel> listToAdd, bool record2)
        {
            foreach (var row in listToAdd)
                if (record2 == false)
                {
                    VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests ??=
                        new List<PensideTestGetListViewModel>();
                    var list = VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests
                        .Where(x => x.PensideTestID == row.PensideTestID).ToList();
                    if (list.Count == 0)
                        VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests.Add(row);
                }
                else
                {
                    VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests2 ??=
                        new List<PensideTestGetListViewModel>();
                    var list = VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests2
                        .Where(x => x.PensideTestID == row.PensideTestID).ToList();
                    if (list.Count == 0)
                        VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests2.Add(row);
                }
        }

        protected void AddLabTestsToSelectedList(IList<LaboratoryTestGetListViewModel> listToAdd, bool record2)
        {
            foreach (var row in listToAdd)
                if (record2 == false)
                {
                    VeterinaryDiseaseReportDeduplicationService.SelectedLabTests ??=
                        new List<LaboratoryTestGetListViewModel>();
                    var list = VeterinaryDiseaseReportDeduplicationService.SelectedLabTests
                        .Where(x => x.TestID == row.TestID).ToList();
                    if (list.Count == 0)
                        VeterinaryDiseaseReportDeduplicationService.SelectedLabTests.Add(row);
                }
                else
                {
                    VeterinaryDiseaseReportDeduplicationService.SelectedLabTests2 ??=
                        new List<LaboratoryTestGetListViewModel>();
                    var list = VeterinaryDiseaseReportDeduplicationService.SelectedLabTests2
                        .Where(x => x.TestID == row.TestID).ToList();
                    if (list.Count == 0)
                        VeterinaryDiseaseReportDeduplicationService.SelectedLabTests2.Add(row);
                }
        }

        protected void AddInterpretationsToSelectedList(IList<LaboratoryTestInterpretationGetListViewModel> listToAdd,
            bool record2)
        {
            foreach (var row in listToAdd)
                if (record2 == false)
                {
                    VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations ??=
                        new List<LaboratoryTestInterpretationGetListViewModel>();
                    var list = VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations
                        .Where(x => x.TestInterpretationID == row.TestInterpretationID).ToList();
                    if (list.Count == 0)
                        VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations.Add(row);
                }
                else
                {
                    VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations2 ??=
                        new List<LaboratoryTestInterpretationGetListViewModel>();
                    var list = VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations2
                        .Where(x => x.TestInterpretationID == row.TestInterpretationID).ToList();
                    if (list.Count == 0)
                        VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations2.Add(row);
                }
        }

        #endregion

        #region Private Methods

        private bool IsFarmDetailsValid()
        {
            return VeterinaryDiseaseReportDeduplicationService.InfoList.All(item =>
                item.Checked || VeterinaryDiseaseReportDeduplicationService.InfoList2[item.Index].Checked);
        }

        private bool IsNotificationValid()
        {
            return VeterinaryDiseaseReportDeduplicationService.NotificationList.All(item =>
                item.Checked || VeterinaryDiseaseReportDeduplicationService.NotificationList2[item.Index].Checked);
        }

        #endregion

        #region Common Methods

        protected async Task FillDeduplicationDetailsAsync(VeterinaryDiseaseReportDeduplicationDetailsViewModel model,
            long id, long id2)
        {
            try
            {
                VeterinaryDiseaseReportDeduplicationService.VeterinaryDiseaseReportID = id;
                VeterinaryDiseaseReportDeduplicationService.VeterinaryDiseaseReportID2 = id2;

                var request = new DiseaseReportGetDetailRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    DiseaseReportID = id,
                    SortColumn = "EIDSSReportID",
                    SortOrder = SortConstants.Ascending
                };

                var request2 = new DiseaseReportGetDetailRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    DiseaseReportID = id2,
                    SortColumn = "EIDSSReportID",
                    SortOrder = SortConstants.Ascending
                };

                var list = await VeterinaryClient.GetDiseaseReportDetail(request, _token);
                var list2 = await VeterinaryClient.GetDiseaseReportDetail(request2, _token);

                var record = list.FirstOrDefault();
                var record2 = list2.FirstOrDefault();

                var type = record?.GetType();
                var props = type?.GetProperties();

                var type2 = record2?.GetType();
                var props2 = type2?.GetProperties();

                var itemList = new List<Field>();
                var itemList2 = new List<Field>();

                var itemListNotification = new List<Field>();
                var itemListNotification2 = new List<Field>();

                if (props != null)
                    for (var index = 0; index <= props.Length - 1; index++)
                    {
                        if (IsInTabFarmDetails(props[index].Name))
                            if (props2 != null)
                                FillTabList(props[index].Name,
                                    props[index].GetValue(record) == null
                                        ? null
                                        : props[index].GetValue(record)?.ToString(), props2[index].Name,
                                    props2[index].GetValue(record2) == null
                                        ? null
                                        : props2[index].GetValue(record2)?.ToString(), ref itemList, ref itemList2,
                                    ref KeyDict, ref LabelDict);

                        if (IsInTabNotification(props[index].Name))
                            if (props2 != null)
                                FillTabList(props[index].Name,
                                    props[index].GetValue(record) == null
                                        ? null
                                        : props[index].GetValue(record)?.ToString(), props2[index].Name,
                                    props2[index].GetValue(record2) == null
                                        ? null
                                        : props2[index].GetValue(record2)?.ToString(), ref itemListNotification,
                                    ref itemListNotification2, ref KeyDict2, ref LabelDict2);
                    }

                //Bind Tab Farm Details
                VeterinaryDiseaseReportDeduplicationService.InfoList0 =
                    itemList.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));
                VeterinaryDiseaseReportDeduplicationService.InfoList02 =
                    itemList2.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));

                VeterinaryDiseaseReportDeduplicationService.InfoList = itemList.OrderBy(s => s.Index).ToList();
                VeterinaryDiseaseReportDeduplicationService.InfoList2 = itemList2.OrderBy(s => s.Index).ToList();

                foreach (var item in VeterinaryDiseaseReportDeduplicationService.InfoList)
                {
                    if (item.Checked)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                        VeterinaryDiseaseReportDeduplicationService.InfoList2[item.Index].Checked = true;
                        VeterinaryDiseaseReportDeduplicationService.InfoList2[item.Index].Disabled = true;
                    }

                    //LegacyID, OutbreakID, SessionID are non-editable fields
                    if (item.Key is not (VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.LegacyID
                        or VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.EIDSSOutbreakID
                        or VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.EIDSSParentMonitoringSessionID))
                        continue;
                    item.Disabled = true;
                    VeterinaryDiseaseReportDeduplicationService.InfoList2[item.Index].Disabled = true;
                }

                //Bind Tab Notification
                VeterinaryDiseaseReportDeduplicationService.NotificationList0 = itemListNotification
                    .OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));
                VeterinaryDiseaseReportDeduplicationService.NotificationList02 = itemListNotification2
                    .OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));

                VeterinaryDiseaseReportDeduplicationService.NotificationList =
                    itemListNotification.OrderBy(s => s.Index).ToList();
                VeterinaryDiseaseReportDeduplicationService.NotificationList2 =
                    itemListNotification2.OrderBy(s => s.Index).ToList();

                foreach (var item in VeterinaryDiseaseReportDeduplicationService.NotificationList)
                {
                    if (item.Checked)
                    {
                        item.Checked = true;
                        //item.Disabled = true;
                        VeterinaryDiseaseReportDeduplicationService.NotificationList2[item.Index].Checked = true;
                        //VeterinaryDiseaseReportDeduplicationService.NotificationList2[item.Index].Disabled = true;
                    }

                    //Notification fields are non-editable fields
                    item.Disabled = true;
                    VeterinaryDiseaseReportDeduplicationService.NotificationList2[item.Index].Disabled = true;
                }

                await FillFarmInventoryAsync(record, false);
                await FillFarmInventoryAsync(record2, true);

                if (model.ReportType == VeterinaryReportTypeEnum.Avian)
                {
                    VeterinaryDiseaseReportDeduplicationService.FarmEpiFlexFormRequest =
                        new FlexFormQuestionnaireGetRequestModel
                        {
                            idfObservation = record?.FarmEpidemiologicalObservationID,
                            idfsDiagnosis = record?.DiseaseID,
                            idfsFormType = (long) FlexibleFormTypeEnum.AvianFarmEpidemiologicalInfo,
                            LangID = GetCurrentLanguage()
                        };

                    VeterinaryDiseaseReportDeduplicationService.FarmEpiFlexFormRequest2 =
                        new FlexFormQuestionnaireGetRequestModel
                        {
                            idfObservation = record2?.FarmEpidemiologicalObservationID,
                            idfsDiagnosis = record2?.DiseaseID,
                            idfsFormType = (long) FlexibleFormTypeEnum.AvianFarmEpidemiologicalInfo,
                            LangID = GetCurrentLanguage()
                        };
                }
                else
                {
                    VeterinaryDiseaseReportDeduplicationService.FarmEpiFlexFormRequest =
                        new FlexFormQuestionnaireGetRequestModel
                        {
                            idfObservation = record?.FarmEpidemiologicalObservationID,
                            idfsDiagnosis = record?.DiseaseID,
                            idfsFormType = (long) FlexibleFormTypeEnum.LivestockFarmFarmEpidemiologicalInfo,
                            LangID = GetCurrentLanguage()
                        };

                    VeterinaryDiseaseReportDeduplicationService.FarmEpiFlexFormRequest2 =
                        new FlexFormQuestionnaireGetRequestModel
                        {
                            idfObservation = record2?.FarmEpidemiologicalObservationID,
                            idfsDiagnosis = record2?.DiseaseID,
                            idfsFormType = (long) FlexibleFormTypeEnum.LivestockFarmFarmEpidemiologicalInfo,
                            LangID = GetCurrentLanguage()
                        };

                    VeterinaryDiseaseReportDeduplicationService.ControlMeasuresFlexFormRequest =
                        new FlexFormQuestionnaireGetRequestModel
                        {
                            idfObservation = record?.ControlMeasuresObservationID,
                            idfsDiagnosis = record?.DiseaseID,
                            idfsFormType = (long) FlexibleFormTypeEnum.LivestockControlMeasures,
                            LangID = GetCurrentLanguage()
                        };

                    VeterinaryDiseaseReportDeduplicationService.ControlMeasuresFlexFormRequest2 =
                        new FlexFormQuestionnaireGetRequestModel
                        {
                            idfObservation = record2?.ControlMeasuresObservationID,
                            idfsDiagnosis = record2?.DiseaseID,
                            idfsFormType = (long) FlexibleFormTypeEnum.LivestockControlMeasures,
                            LangID = GetCurrentLanguage()
                        };
                }

                var speciesList = VeterinaryDiseaseReportDeduplicationService.FarmInventory
                    .Where(x => x.RecordType == RecordTypeConstants.Species).ToList();
                var speciesList2 = VeterinaryDiseaseReportDeduplicationService.FarmInventory2
                    .Where(x => x.RecordType == RecordTypeConstants.Species).ToList();

                if (speciesList is {Count: > 0})
                {
                    VeterinaryDiseaseReportDeduplicationService.SpeciesFlexFormRequest =
                        new FlexFormQuestionnaireGetRequestModel
                        {
                            idfObservation = speciesList[0].ObservationID,
                            idfsDiagnosis = record?.DiseaseID,
                            idfsFormType = model.ReportType == VeterinaryReportTypeEnum.Avian
                                ? (long) FlexibleFormTypeEnum.AvianSpeciesClinicalInvestigation
                                : (long) FlexibleFormTypeEnum.LivestockSpeciesClinicalInvestigation,
                            LangID = GetCurrentLanguage()
                        };
                    VeterinaryDiseaseReportDeduplicationService.Species = speciesList[0].Species;
                }

                if (speciesList2 is {Count: > 0})
                {
                    VeterinaryDiseaseReportDeduplicationService.SpeciesFlexFormRequest2 =
                        new FlexFormQuestionnaireGetRequestModel
                        {
                            idfObservation = speciesList2[0].ObservationID,
                            idfsDiagnosis = record2?.DiseaseID,
                            idfsFormType = model.ReportType == VeterinaryReportTypeEnum.Avian
                                ? (long) FlexibleFormTypeEnum.AvianSpeciesClinicalInvestigation
                                : (long) FlexibleFormTypeEnum.LivestockSpeciesClinicalInvestigation,
                            LangID = GetCurrentLanguage()
                        };
                    VeterinaryDiseaseReportDeduplicationService.Species2 = speciesList2[0].Species;
                }

                await FillVaccinationsAsync(record, false);
                await FillVaccinationsAsync(record2, true);

                if (model.ReportType == VeterinaryReportTypeEnum.Livestock)
                {
                    await FillAnimalsAsync(record, false);
                    await FillAnimalsAsync(record2, true);
                }

                await FillSamplesAsync(record, false);
                await FillSamplesAsync(record2, true);

                await FillPensideTestsAsync(record, false);
                await FillPensideTestsAsync(record2, true);

                await FillLabTestsAsync(record, false);
                await FillLabTestsAsync(record2, true);

                await FillInterpretationsAsync(record, false);
                await FillInterpretationsAsync(record2, true);

                await FillCaseLogsAsync(record, false);
                await FillCaseLogsAsync(record2, true);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        protected void FillTabList(string key, string value, string key2, string value2, ref List<Field> list,
            ref List<Field> list2, ref Dictionary<string, int> keyDict, ref Dictionary<int, string> labelDict)
        {
            try
            {
                var item = new Field();
                var item2 = new Field();

                if (!keyDict.ContainsKey(key)) return;
                item.Index = keyDict[key];
                item.Key = key;
                item.Value = value;
                item2.Index = keyDict[key];
                item2.Key = key;
                item2.Value = value2;

                if (value == value2 || key == VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.EIDSSReportID)
                {
                    item.Label = GetLabelResource(labelDict[item.Index]) + ": ";
                    item2.Label = GetLabelResource(labelDict[item.Index]) + ": ";
                    item.Checked = true;
                    item2.Checked = true;
                    item.Disabled = true;
                    item2.Disabled = true;
                    item.Color = "color: #2C6187"; //Blue
                }
                else
                {
                    item.Label = GetLabelResource(labelDict[item.Index]) + ": ";
                    item.Checked = false;
                    item.Disabled = false;
                    item.Color = "color: #9b1010"; //Red

                    item2.Label = GetLabelResource(labelDict[item.Index]) + ": ";
                    item2.Checked = false;
                    item2.Disabled = false;
                    item2.Color = "width:250px;color: #9b1010"; //Red
                }

                list.Add(item);
                list2.Add(item2);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        private string GetLabelResource(string strName)
        {
            return strName switch
            {
                //Summary
                "ReportID" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSummaryReportIDFieldLabel),
                "ReportStatus" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSummaryReportStatusFieldLabel),
                "CaseClassification" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSummaryCaseClassificationFieldLabel),
                "LegacyID" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSummaryLegacyIDFieldLabel),
                "FieldAccessionID" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSummaryFieldAccessionIDFieldLabel),
                "OutbreakID" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSummaryOutbreakIDFieldLabel),
                "SessionID" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSummarySessionIDFieldLabel),
                "ReportType" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSummaryReportTypeFieldLabel),
                "DiagnosisDate" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSummaryDateOfDiagnosisFieldLabel),
                "Disease" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSummaryDiseaseFieldLabel),
                // Farm Details
                "FarmType" => Localizer.GetString(FieldLabelResourceKeyConstants.FarmInformationFarmTypeFieldLabel),
                "FarmID" => Localizer.GetString(FieldLabelResourceKeyConstants.FarmInformationFarmIDFieldLabel),
                "FarmName" => Localizer.GetString(FieldLabelResourceKeyConstants.FarmInformationFarmNameFieldLabel),
                "FarmOwnerLastName" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .DeduplicationSearchFarmFarmOwnerLastNameFieldLabel),
                "FarmOwnerFirstName" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .DeduplicationSearchFarmFarmOwnerFirstNameFieldLabel),
                "FarmOwnerSecondName" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .AvianDiseaseReportFarmDetailsFarmOwnerMiddleNameFieldLabel),
                "FarmOwnerID" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .DeduplicationSearchFarmFarmOwnerIDFieldLabel),
                "Phone" => Localizer.GetString(FieldLabelResourceKeyConstants.FarmInformationPhoneFieldLabel),
                "Fax" => Localizer.GetString(FieldLabelResourceKeyConstants.FarmInformationFaxFieldLabel),
                "Email" => Localizer.GetString(FieldLabelResourceKeyConstants.FarmInformationEmailFieldLabel),
                "ModifiedDate" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .FarmInformationDateLastUpdatedFieldLabel),
                "Country" => Localizer.GetString(FieldLabelResourceKeyConstants.CountryFieldLabel),
                "Region" => Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel1FieldLabel),
                "Rayon" => Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel2FieldLabel),
                "SettlementType" => Localizer.GetString(FieldLabelResourceKeyConstants.SettlementTypeFieldLabel),
                "Settlement" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .LocationAdministrativeLevel3FieldLabel),
                "Street" => Localizer.GetString(FieldLabelResourceKeyConstants.StreetFieldLabel),
                "House" => Localizer.GetString(FieldLabelResourceKeyConstants.HouseFieldLabel),
                "Building" => Localizer.GetString(FieldLabelResourceKeyConstants.BuildingFieldLabel),
                "Apartment" => Localizer.GetString(FieldLabelResourceKeyConstants.ApartmentUnitFieldLabel),
                "PostalCode" => Localizer.GetString(FieldLabelResourceKeyConstants.PostalCodeFieldLabel),
                "Latitude" => Localizer.GetString(FieldLabelResourceKeyConstants.FarmAddressLatitudeFieldLabel),
                "Longitude" => Localizer.GetString(FieldLabelResourceKeyConstants.FarmAddressLongitudeFieldLabel),
                "AvianFarmTypeID" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .FarmInformationAvianFarmTypeIDFieldLabel),
                "OwnershipStructureTypeID" => Localizer.GetString(
                    FieldLabelResourceKeyConstants.OwnershipFormFieldLabel),
                "NumberOfBuildings" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .FarmInformationNumberOfBarnsBuildingsFieldLabel),
                "NumberOfBirdsPerBuilding" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .FarmInformationNumberOfBirdsPerBarnBuildingFieldLabel),
                //Notification
                "ReportedByOrganization" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .AvianDiseaseReportNotificationOrganizationFieldLabel),
                "ReportedByPerson" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .AvianDiseaseReportNotificationReportedByFieldLabel),
                "ReportDate" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .AvianDiseaseReportNotificationInitialReportDateFieldLabel),
                "InvestigatedByOrganization" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .AvianDiseaseReportNotificationInvestigationOrganizationFieldLabel),
                "InvestigatedByPerson" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .AvianDiseaseReportNotificationInvestigatorNameFieldLabel),
                "AssignedDate" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .AvianDiseaseReportNotificationAssignedDateFieldLabel),
                "InvestigationDate" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .AvianDiseaseReportNotificationInvestigationDateFieldLabel),
                "Site" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .AvianDiseaseReportNotificationDataEntrySiteFieldLabel),
                "EnteredByPerson" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .AvianDiseaseReportNotificationDataEntryOfficerFieldLabel),
                "EnteredDate" => Localizer.GetString(FieldLabelResourceKeyConstants
                    .AvianDiseaseReportNotificationDataEntryDateFieldLabel),
                _ => strName
            };
        }

        private async Task FillFarmInventoryAsync(DiseaseReportGetDetailViewModel record, bool record2)
        {
            try
            {
                if (record != null)
                {
                    if (record2 == false)
                        VeterinaryDiseaseReportDeduplicationService.FarmInventory =
                            await GetFarmInventory(record.DiseaseReportID, record.DiseaseReportID, record.FarmID);
                    else
                        VeterinaryDiseaseReportDeduplicationService.FarmInventory2 =
                            await GetFarmInventory(record.DiseaseReportID, record.DiseaseReportID, record.FarmID);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        private async Task FillVaccinationsAsync(DiseaseReportGetDetailViewModel record, bool record2)
        {
            try
            {
                if (record != null)
                {
                    if (record2 == false)
                    {
                        VeterinaryDiseaseReportDeduplicationService.Vaccinations =
                            await GetVaccinations(record.DiseaseReportID, 1, 10, "TestNameTypeName",
                                SortConstants.Ascending);
                        VeterinaryDiseaseReportDeduplicationService.VaccinationsCount =
                            !VeterinaryDiseaseReportDeduplicationService.Vaccinations.Any()
                                ? 0
                                : VeterinaryDiseaseReportDeduplicationService.Vaccinations.First().TotalRowCount;
                    }
                    else
                    {
                        VeterinaryDiseaseReportDeduplicationService.Vaccinations2 =
                            await GetVaccinations(record.DiseaseReportID, 1, 10, "TestNameTypeName",
                                SortConstants.Ascending);
                        VeterinaryDiseaseReportDeduplicationService.VaccinationsCount2 =
                            !VeterinaryDiseaseReportDeduplicationService.Vaccinations2.Any()
                                ? 0
                                : VeterinaryDiseaseReportDeduplicationService.Vaccinations2.First().TotalRowCount;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        private async Task FillAnimalsAsync(DiseaseReportGetDetailViewModel record, bool record2)
        {
            try
            {
                if (record != null)
                {
                    if (record2 == false)
                    {
                        VeterinaryDiseaseReportDeduplicationService.Animals = await GetAnimals(record.DiseaseReportID,
                            1, 10, "EIDSSAnimalID", SortConstants.Ascending);
                        VeterinaryDiseaseReportDeduplicationService.AnimalsCount =
                            !VeterinaryDiseaseReportDeduplicationService.Animals.Any()
                                ? 0
                                : VeterinaryDiseaseReportDeduplicationService.Animals.First().TotalRowCount;
                    }
                    else
                    {
                        VeterinaryDiseaseReportDeduplicationService.Animals2 = await GetAnimals(record.DiseaseReportID,
                            1, 10, "EIDSSAnimalID", SortConstants.Ascending);
                        VeterinaryDiseaseReportDeduplicationService.AnimalsCount2 =
                            !VeterinaryDiseaseReportDeduplicationService.Animals2.Any()
                                ? 0
                                : VeterinaryDiseaseReportDeduplicationService.Animals2.First().TotalRowCount;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        private async Task FillSamplesAsync(DiseaseReportGetDetailViewModel record, bool record2)
        {
            try
            {
                if (record != null)
                {
                    if (record2 == false)
                    {
                        VeterinaryDiseaseReportDeduplicationService.Samples = await GetSamples(record.DiseaseReportID,
                            1, 10, "SampleTypeName", SortConstants.Ascending);
                        VeterinaryDiseaseReportDeduplicationService.SamplesCount =
                            !VeterinaryDiseaseReportDeduplicationService.Samples.Any()
                                ? 0
                                : VeterinaryDiseaseReportDeduplicationService.Samples.First().TotalRowCount;
                    }
                    else
                    {
                        VeterinaryDiseaseReportDeduplicationService.Samples2 = await GetSamples(record.DiseaseReportID,
                            1, 10, "SampleTypeName", SortConstants.Ascending);
                        VeterinaryDiseaseReportDeduplicationService.SamplesCount2 =
                            !VeterinaryDiseaseReportDeduplicationService.Samples2.Any()
                                ? 0
                                : VeterinaryDiseaseReportDeduplicationService.Samples2.First().TotalRowCount;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        private async Task FillPensideTestsAsync(DiseaseReportGetDetailViewModel record, bool record2)
        {
            try
            {
                if (record != null)
                {
                    if (record2 == false)
                    {
                        VeterinaryDiseaseReportDeduplicationService.PensideTests =
                            await GetPensideTests(record.DiseaseReportID, 1, 10, "TestNameTypeName",
                                SortConstants.Ascending);
                        VeterinaryDiseaseReportDeduplicationService.PensideTestsCount =
                            !VeterinaryDiseaseReportDeduplicationService.PensideTests.Any()
                                ? 0
                                : VeterinaryDiseaseReportDeduplicationService.PensideTests.First().TotalRowCount;
                    }
                    else
                    {
                        VeterinaryDiseaseReportDeduplicationService.PensideTests2 =
                            await GetPensideTests(record.DiseaseReportID, 1, 10, "TestNameTypeName",
                                SortConstants.Ascending);
                        VeterinaryDiseaseReportDeduplicationService.PensideTestsCount2 =
                            !VeterinaryDiseaseReportDeduplicationService.PensideTests2.Any()
                                ? 0
                                : VeterinaryDiseaseReportDeduplicationService.PensideTests2.First().TotalRowCount;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        private async Task FillLabTestsAsync(DiseaseReportGetDetailViewModel record, bool record2)
        {
            try
            {
                if (record != null)
                {
                    if (record2 == false)
                    {
                        VeterinaryDiseaseReportDeduplicationService.LabTests =
                            await GetLaboratoryTests(record.DiseaseReportID, 1, 10, "TestNameTypeName",
                                SortConstants.Ascending);
                        VeterinaryDiseaseReportDeduplicationService.LabTestsCount =
                            !VeterinaryDiseaseReportDeduplicationService.LabTests.Any()
                                ? 0
                                : VeterinaryDiseaseReportDeduplicationService.LabTests.First().TotalRowCount;
                    }
                    else
                    {
                        VeterinaryDiseaseReportDeduplicationService.LabTests2 =
                            await GetLaboratoryTests(record.DiseaseReportID, 1, 10, "TestNameTypeName",
                                SortConstants.Ascending);
                        VeterinaryDiseaseReportDeduplicationService.LabTestsCount2 =
                            !VeterinaryDiseaseReportDeduplicationService.LabTests2.Any()
                                ? 0
                                : VeterinaryDiseaseReportDeduplicationService.LabTests2.First().TotalRowCount;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        private async Task FillInterpretationsAsync(DiseaseReportGetDetailViewModel record, bool record2)
        {
            try
            {
                if (record != null)
                {
                    if (record2 == false)
                    {
                        VeterinaryDiseaseReportDeduplicationService.Interpretations =
                            await GetLaboratoryTestInterpretations(record.DiseaseReportID, 1, 10, "TestNameTypeName",
                                SortConstants.Ascending);
                        VeterinaryDiseaseReportDeduplicationService.InterpretationsCount =
                            !VeterinaryDiseaseReportDeduplicationService.Interpretations.Any()
                                ? 0
                                : VeterinaryDiseaseReportDeduplicationService.Interpretations.First().TotalRowCount;
                    }
                    else
                    {
                        VeterinaryDiseaseReportDeduplicationService.Interpretations2 =
                            await GetLaboratoryTestInterpretations(record.DiseaseReportID, 1, 10, "TestNameTypeName",
                                SortConstants.Ascending);
                        VeterinaryDiseaseReportDeduplicationService.InterpretationsCount2 =
                            !VeterinaryDiseaseReportDeduplicationService.Interpretations2.Any()
                                ? 0
                                : VeterinaryDiseaseReportDeduplicationService.Interpretations2.First().TotalRowCount;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        private async Task FillCaseLogsAsync(DiseaseReportGetDetailViewModel record, bool record2)
        {
            try
            {
                if (record != null)
                {
                    if (record2 == false)
                    {
                        VeterinaryDiseaseReportDeduplicationService.CaseLogs = await GetCaseLogs(record.DiseaseReportID,
                            1, 10, "ActionRequired", SortConstants.Ascending);
                        VeterinaryDiseaseReportDeduplicationService.CaseLogsCount =
                            !VeterinaryDiseaseReportDeduplicationService.CaseLogs.Any()
                                ? 0
                                : VeterinaryDiseaseReportDeduplicationService.CaseLogs.First().TotalRowCount;
                    }
                    else
                    {
                        VeterinaryDiseaseReportDeduplicationService.CaseLogs2 =
                            await GetCaseLogs(record.DiseaseReportID, 1, 10, "ActionRequired", SortConstants.Ascending);
                        VeterinaryDiseaseReportDeduplicationService.CaseLogsCount2 =
                            !VeterinaryDiseaseReportDeduplicationService.CaseLogs2.Any()
                                ? 0
                                : VeterinaryDiseaseReportDeduplicationService.CaseLogs2.First().TotalRowCount;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        private static bool IsInVetDiseaseReportSaveRequestModel(string strName)
        {
            return strName switch
            {
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.EIDSSReportID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.EIDSSFieldAccessionID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.OutbreakID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.MonitoringSessionID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.DiagnosisDate => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.FarmOwnerID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.FarmLongitude => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.FarmLatitude => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.StatusTypeID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.ClassificationTypeID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.ReportTypeID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.DiseaseID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.FarmID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.FarmMasterID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.ReceivedByOrganizationID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.ReceivedByPersonID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.ReportCategoryTypeID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.FarmEpidemiologicalObservationID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.ControlMeasuresObservationID => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.TestsConductedIndicator => true,
                VeterinaryDiseaseReportDeduplicationFarmDetailsConstants.OutbreakCaseIndicator => true,
                _ => false
            };
        }

        /// <summary>
        /// </summary>
        /// <param name="farmInventory"></param>
        /// <param name="createConnectedDiseaseReportIndicator"></param>
        /// <returns></returns>
        private static List<FarmInventoryGroupSaveRequestModel> BuildFlocksOrHerdsParameters(
            IList<FarmInventoryGetListViewModel> farmInventory, bool createConnectedDiseaseReportIndicator)
        {
            List<FarmInventoryGroupSaveRequestModel> requests = new();

            if (farmInventory is null)
                return new List<FarmInventoryGroupSaveRequestModel>();

            foreach (var farmInventoryModel in farmInventory)
            {
                var request = new FarmInventoryGroupSaveRequestModel();
                {
                    request.DeadAnimalQuantity = farmInventoryModel.DeadAnimalQuantity;
                    request.EIDSSFlockOrHerdID = farmInventoryModel.EIDSSFlockOrHerdID;
                    request.FarmID = farmInventoryModel.FarmID;
                    if (farmInventoryModel.FlockOrHerdID != null)
                        request.FlockOrHerdID = (long) farmInventoryModel.FlockOrHerdID;
                    request.FlockOrHerdMasterID = farmInventoryModel.FlockOrHerdMasterID;
                    if (farmInventoryModel.RowAction != null)
                        request.RowAction = createConnectedDiseaseReportIndicator
                            ? (int) RowActionTypeEnum.Insert
                            : (int) farmInventoryModel.RowAction;
                    request.RowStatus = farmInventoryModel.RowStatus;
                    request.SickAnimalQuantity = farmInventoryModel.SickAnimalQuantity;
                    request.TotalAnimalQuantity = farmInventoryModel.TotalAnimalQuantity;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        /// </summary>
        /// <param name="farmInventory"></param>
        /// <param name="createConnectedDiseaseReportIndicator"></param>
        /// <returns></returns>
        private static List<FarmInventorySpeciesSaveRequestModel> BuildSpeciesParameters(
            IList<FarmInventoryGetListViewModel> farmInventory, bool createConnectedDiseaseReportIndicator)
        {
            List<FarmInventorySpeciesSaveRequestModel> requests = new();

            if (farmInventory is null)
                return new List<FarmInventorySpeciesSaveRequestModel>();

            foreach (var farmInventoryModel in farmInventory)
            {
                var request = new FarmInventorySpeciesSaveRequestModel();
                {
                    request.AverageAge = farmInventoryModel.AverageAge;
                    request.DeadAnimalQuantity = farmInventoryModel.DeadAnimalQuantity;
                    if (farmInventoryModel.FlockOrHerdID != null)
                        request.FlockOrHerdID = (long) farmInventoryModel.FlockOrHerdID;
                    request.ObservationID = farmInventoryModel.ObservationID;
                    request.RelatedToSpeciesID = createConnectedDiseaseReportIndicator == false
                        ? null
                        : farmInventoryModel.SpeciesID;
                    request.RelatedToObservationID = createConnectedDiseaseReportIndicator == false
                        ? null
                        : farmInventoryModel.ObservationID;
                    if (farmInventoryModel.RowAction != null)
                        request.RowAction = createConnectedDiseaseReportIndicator
                            ? (int) RowActionTypeEnum.Insert
                            : (int) farmInventoryModel.RowAction;
                    request.RowStatus = farmInventoryModel.RowStatus;
                    request.SickAnimalQuantity = farmInventoryModel.SickAnimalQuantity;
                    if (farmInventoryModel.SpeciesID != null) request.SpeciesID = (long) farmInventoryModel.SpeciesID;
                    request.SpeciesMasterID = farmInventoryModel.SpeciesMasterID;
                    if (farmInventoryModel.SpeciesTypeID != null)
                        request.SpeciesTypeID = (long) farmInventoryModel.SpeciesTypeID;
                    request.StartOfSignsDate = farmInventoryModel.StartOfSignsDate;
                    request.TotalAnimalQuantity = farmInventoryModel.TotalAnimalQuantity;
                    request.Comments = farmInventoryModel.Note;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        /// </summary>
        /// <param name="animals"></param>
        /// <param name="createConnectedDiseaseReportIndicator"></param>
        /// <returns></returns>
        private List<AnimalSaveRequestModel> BuildAnimalParameters(IList<AnimalGetListViewModel> animals,
            bool createConnectedDiseaseReportIndicator)
        {
            List<AnimalSaveRequestModel> requests = new();

            if (animals is null)
                return new List<AnimalSaveRequestModel>();

            foreach (var animalModel in animals)
            {
                var request = new AnimalSaveRequestModel();
                {
                    request.AgeTypeID = animalModel.AgeTypeID;
                    request.AnimalDescription = animalModel.AnimalDescription;
                    request.AnimalID = animalModel.AnimalID;
                    request.AnimalName = animalModel.AnimalName;
                    request.ClinicalSignsIndicator = animalModel.ClinicalSignsIndicator;
                    request.Color = animalModel.Color;
                    request.ConditionTypeID = animalModel.ConditionTypeID;
                    request.EIDSSAnimalID =
                        animalModel.EIDSSAnimalID.Contains(
                            Localizer.GetString(FieldLabelResourceKeyConstants.CommonLabelsNewFieldLabel))
                            ? string.Empty
                            : animalModel.EIDSSAnimalID;
                    request.SexTypeID = animalModel.SexTypeID;
                    request.ObservationID = animalModel.ObservationID;
                    request.RelatedToAnimalID =
                        createConnectedDiseaseReportIndicator == false ? null : animalModel.AnimalID;
                    request.RelatedToObservationID = createConnectedDiseaseReportIndicator == false
                        ? null
                        : animalModel.ObservationID;
                    request.RowAction = createConnectedDiseaseReportIndicator
                        ? (int) RowActionTypeEnum.Insert
                        : animalModel.RowAction;
                    request.RowStatus = animalModel.RowStatus;
                    request.SpeciesID = animalModel.SpeciesID;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        /// </summary>
        /// <param name="vaccinations"></param>
        /// <param name="createConnectedDiseaseReportIndicator"></param>
        /// <returns></returns>
        private static List<VaccinationSaveRequestModel> BuildVaccinationParameters(
            IList<VaccinationGetListViewModel> vaccinations, bool createConnectedDiseaseReportIndicator)
        {
            List<VaccinationSaveRequestModel> requests = new();

            if (vaccinations is null)
                return new List<VaccinationSaveRequestModel>();

            foreach (var vaccinationModel in vaccinations)
            {
                var request = new VaccinationSaveRequestModel();
                {
                    request.Comments = vaccinationModel.Comments;
                    request.DiseaseID = vaccinationModel.DiseaseID;
                    request.LotNumber = vaccinationModel.LotNumber;
                    request.Manufacturer = vaccinationModel.Manufacturer;
                    request.NumberVaccinated = vaccinationModel.NumberVaccinated;
                    request.RouteTypeID = vaccinationModel.RouteTypeID;
                    request.RowAction = createConnectedDiseaseReportIndicator
                        ? (int) RowActionTypeEnum.Insert
                        : vaccinationModel.RowAction;
                    request.RowStatus = vaccinationModel.RowStatus;
                    request.SpeciesID = vaccinationModel.SpeciesID;
                    request.VaccinationDate = vaccinationModel.VaccinationDate;
                    request.VaccinationID = vaccinationModel.VaccinationID;
                    request.VaccinationTypeID = vaccinationModel.VaccinationTypeID;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        /// </summary>
        /// <param name="samples"></param>
        /// <param name="createConnectedDiseaseReportIndicator"></param>
        /// <returns></returns>
        private List<SampleSaveRequestModel> BuildSampleParameters(IList<SampleGetListViewModel> samples,
            bool createConnectedDiseaseReportIndicator)
        {
            List<SampleSaveRequestModel> requests = new();

            if (samples is null)
                return new List<SampleSaveRequestModel>();

            foreach (var sampleModel in samples)
            {
                var request = new SampleSaveRequestModel();
                {
                    request.AnimalID = sampleModel.AnimalID;
                    request.BirdStatusTypeID = sampleModel.BirdStatusTypeID;
                    request.CurrentSiteID = sampleModel.CurrentSiteID;
                    request.DiseaseID = sampleModel.DiseaseID;

                    if (sampleModel.EIDSSLocalOrFieldSampleID is null)
                        request.EIDSSLocalOrFieldSampleID = sampleModel.EIDSSLaboratorySampleID;
                    else
                        request.EIDSSLocalOrFieldSampleID =
                            sampleModel.EIDSSLocalOrFieldSampleID.Contains(
                                Localizer.GetString(FieldLabelResourceKeyConstants.CommonLabelsNewFieldLabel))
                                ? string.Empty
                                : sampleModel.EIDSSLaboratorySampleID;

                    request.EnteredDate = sampleModel.EnteredDate;
                    request.CollectedByOrganizationID = sampleModel.CollectedByOrganizationID;
                    request.CollectedByPersonID = sampleModel.CollectedByPersonID;
                    request.CollectionDate = sampleModel.CollectionDate;
                    request.SentDate = sampleModel.SentDate;
                    request.SentToOrganizationID = sampleModel.SentToOrganizationID;
                    request.HumanDiseaseReportID = sampleModel.HumanDiseaseReportID;
                    request.HumanMasterID = sampleModel.HumanMasterID;
                    request.HumanID = sampleModel.HumanID;
                    request.MonitoringSessionID = sampleModel.MonitoringSessionID;
                    request.LabModuleSourceIndicator = sampleModel.LabModuleSourceIndicator;
                    request.Comments = sampleModel.Comments;
                    request.ParentSampleID = sampleModel.ParentSampleID;
                    request.ReadOnlyIndicator = sampleModel.ReadOnlyIndicator;
                    request.RootSampleID = sampleModel.RootSampleID;
                    request.RowAction = createConnectedDiseaseReportIndicator
                        ? (int) RowActionTypeEnum.Insert
                        : sampleModel.RowAction;
                    request.RowStatus = sampleModel.RowStatus;
                    request.SampleID = sampleModel.SampleID;
                    request.SampleStatusTypeID = sampleModel.SampleStatusTypeID;
                    request.SampleTypeID = sampleModel.SampleTypeID;
                    request.SiteID = sampleModel.SiteID;
                    request.SpeciesID = sampleModel.SpeciesID;
                    request.VectorID = sampleModel.VectorID;
                    request.VectorSessionID = sampleModel.VectorSessionID;
                    request.VeterinaryDiseaseReportID = sampleModel.VeterinaryDiseaseReportID;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        /// </summary>
        /// <param name="pensideTests"></param>
        /// <param name="createConnectedDiseaseReportIndicator"></param>
        /// <returns></returns>
        private static List<PensideTestSaveRequestModel> BuildPensideTestParameters(
            IList<PensideTestGetListViewModel> pensideTests,
            bool createConnectedDiseaseReportIndicator)
        {
            List<PensideTestSaveRequestModel> requests = new();

            if (pensideTests is null)
                return new List<PensideTestSaveRequestModel>();

            foreach (var pensideTestModel in pensideTests)
            {
                var request = new PensideTestSaveRequestModel();
                {
                    request.DiseaseID = pensideTestModel.DiseaseID;
                    request.PensideTestCategoryTypeID = pensideTestModel.PensideTestCategoryTypeID;
                    request.PensideTestID = pensideTestModel.PensideTestID;
                    request.PensideTestNameTypeID = pensideTestModel.PensideTestNameTypeID;
                    request.PensideTestResultTypeID = pensideTestModel.PensideTestResultTypeID;
                    request.RowAction = createConnectedDiseaseReportIndicator
                        ? (int) RowActionTypeEnum.Insert
                        : pensideTestModel.RowAction;
                    request.RowStatus = pensideTestModel.RowStatus;
                    if (pensideTestModel.SampleID != null) request.SampleID = (long) pensideTestModel.SampleID;
                    request.TestDate = pensideTestModel.TestDate;
                    request.TestedByOrganizationID = pensideTestModel.TestedByOrganizationID;
                    request.TestedByPersonID = pensideTestModel.TestedByPersonID;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        /// </summary>
        /// <param name="laboratoryTests"></param>
        /// <param name="connectedDiseaseReportTestId"></param>
        /// <returns></returns>
        private static List<LaboratoryTestSaveRequestModel> BuildLaboratoryTestParameters(
            IList<LaboratoryTestGetListViewModel> laboratoryTests,
            long? connectedDiseaseReportTestId)
        {
            List<LaboratoryTestSaveRequestModel> requests = new();
            LaboratoryTestSaveRequestModel request;

            if (laboratoryTests is null)
                return new List<LaboratoryTestSaveRequestModel>();

            if (connectedDiseaseReportTestId is null)
            {
                foreach (var laboratoryTestModel in laboratoryTests)
                {
                    request = new LaboratoryTestSaveRequestModel();
                    {
                        request.BatchTestID = laboratoryTestModel.BatchTestID;
                        request.Comments = laboratoryTestModel.Comments;
                        request.ContactPersonName = laboratoryTestModel.ContactPersonName;
                        request.DiseaseID = (long) laboratoryTestModel.DiseaseID;
                        request.ExternalTestIndicator = laboratoryTestModel.ExternalTestIndicator;
                        request.HumanDiseaseReportID = laboratoryTestModel.HumanDiseaseReportID;
                        request.MonitoringSessionID = laboratoryTestModel.MonitoringSessionID;
                        request.NonLaboratoryTestIndicator = laboratoryTestModel.NonLaboratoryTestIndicator;
                        request.ObservationID = laboratoryTestModel.ObservationID;
                        request.PerformedByOrganizationID = laboratoryTestModel.PerformedByOrganizationID;
                        request.ReadOnlyIndicator = laboratoryTestModel.ReadOnlyIndicator;
                        request.ReceivedDate = laboratoryTestModel.ReceivedDate;
                        request.ResultDate = laboratoryTestModel.ResultDate;
                        request.ResultEnteredByOrganizationID = laboratoryTestModel.ResultEnteredByOrganizationID;
                        request.ResultEnteredByPersonID = laboratoryTestModel.ResultEnteredByPersonID;
                        request.RowAction = laboratoryTestModel.RowAction;
                        request.RowStatus = laboratoryTestModel.RowStatus;
                        request.SampleID = laboratoryTestModel.SampleID;
                        request.StartedDate = laboratoryTestModel.StartedDate;
                        request.TestCategoryTypeID = laboratoryTestModel.TestCategoryTypeID;
                        request.TestedByOrganizationID = laboratoryTestModel.TestedByOrganizationID;
                        request.TestedByPersonID = laboratoryTestModel.TestedByPersonID;
                        request.TestID = laboratoryTestModel.TestID;
                        request.TestNameTypeID = laboratoryTestModel.TestNameTypeID;
                        request.TestNumber = laboratoryTestModel.TestNumber;
                        request.TestResultTypeID = laboratoryTestModel.TestResultTypeID;
                        request.TestStatusTypeID = laboratoryTestModel.TestStatusTypeID;
                        request.ValidatedByOrganizationID = laboratoryTestModel.ValidatedByOrganizationID;
                        request.ValidatedByPersonID = laboratoryTestModel.ValidatedByPersonID;
                        request.VectorID = laboratoryTestModel.VectorID;
                        request.VectorSessionID = laboratoryTestModel.VectorSessionID;
                        request.VeterinaryDiseaseReportID = laboratoryTestModel.VeterinaryDiseaseReportID;
                    }

                    requests.Add(request);
                }
            }
            else
            {
                var laboratoryTestModel = laboratoryTests.First(x => x.TestID == connectedDiseaseReportTestId);
                request = new LaboratoryTestSaveRequestModel();
                {
                    request.BatchTestID = laboratoryTestModel.BatchTestID;
                    request.Comments = laboratoryTestModel.Comments;
                    request.ContactPersonName = laboratoryTestModel.ContactPersonName;
                    if (laboratoryTestModel.DiseaseID != null) request.DiseaseID = (long) laboratoryTestModel.DiseaseID;
                    request.ExternalTestIndicator = laboratoryTestModel.ExternalTestIndicator;
                    request.HumanDiseaseReportID = laboratoryTestModel.HumanDiseaseReportID;
                    request.MonitoringSessionID = laboratoryTestModel.MonitoringSessionID;
                    request.NonLaboratoryTestIndicator = laboratoryTestModel.NonLaboratoryTestIndicator;
                    request.ObservationID = laboratoryTestModel.ObservationID;
                    request.PerformedByOrganizationID = laboratoryTestModel.PerformedByOrganizationID;
                    request.ReadOnlyIndicator = laboratoryTestModel.ReadOnlyIndicator;
                    request.ReceivedDate = laboratoryTestModel.ReceivedDate;
                    request.ResultDate = laboratoryTestModel.ResultDate;
                    request.ResultEnteredByOrganizationID = laboratoryTestModel.ResultEnteredByOrganizationID;
                    request.ResultEnteredByPersonID = laboratoryTestModel.ResultEnteredByPersonID;
                    request.RowAction = (int) RowActionTypeEnum.Update;
                    request.RowStatus = laboratoryTestModel.RowStatus;
                    request.SampleID = laboratoryTestModel.SampleID;
                    request.StartedDate = laboratoryTestModel.StartedDate;
                    request.TestCategoryTypeID = laboratoryTestModel.TestCategoryTypeID;
                    request.TestedByOrganizationID = laboratoryTestModel.TestedByOrganizationID;
                    request.TestedByPersonID = laboratoryTestModel.TestedByPersonID;
                    request.TestID = laboratoryTestModel.TestID;
                    request.TestNameTypeID = laboratoryTestModel.TestNameTypeID;
                    request.TestNumber = laboratoryTestModel.TestNumber;
                    request.TestResultTypeID = laboratoryTestModel.TestResultTypeID;
                    request.TestStatusTypeID = laboratoryTestModel.TestStatusTypeID;
                    request.ValidatedByOrganizationID = laboratoryTestModel.ValidatedByOrganizationID;
                    request.ValidatedByPersonID = laboratoryTestModel.ValidatedByPersonID;
                    request.VectorID = laboratoryTestModel.VectorID;
                    request.VectorSessionID = laboratoryTestModel.VectorSessionID;
                    request.VeterinaryDiseaseReportID = laboratoryTestModel.VeterinaryDiseaseReportID;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        /// </summary>
        /// <param name="laboratoryTestInterpretations"></param>
        /// <param name="connectedDiseaseReportTestId"></param>
        /// <returns></returns>
        private static List<LaboratoryTestInterpretationSaveRequestModel>
            BuildLaboratoryTestInterpretationParameters(
                IList<LaboratoryTestInterpretationGetListViewModel> laboratoryTestInterpretations,
                long? connectedDiseaseReportTestId)
        {
            List<LaboratoryTestInterpretationSaveRequestModel> requests = new();
            LaboratoryTestInterpretationSaveRequestModel request;

            if (laboratoryTestInterpretations is null)
                return new List<LaboratoryTestInterpretationSaveRequestModel>();

            if (connectedDiseaseReportTestId is null)
            {
                foreach (var laboratoryTestInterpretationModel in laboratoryTestInterpretations)
                {
                    request = new LaboratoryTestInterpretationSaveRequestModel();
                    {
                        request.DiseaseID = laboratoryTestInterpretationModel.DiseaseID;
                        request.InterpretedByOrganizationID =
                            laboratoryTestInterpretationModel.InterpretedByOrganizationID;
                        request.InterpretedByPersonID = laboratoryTestInterpretationModel.InterpretedByPersonID;
                        request.InterpretedComment = laboratoryTestInterpretationModel.InterpretedComment;
                        request.InterpretedDate = laboratoryTestInterpretationModel.InterpretedDate;
                        request.InterpretedStatusTypeID = laboratoryTestInterpretationModel.InterpretedStatusTypeID;
                        request.ReadOnlyIndicator = laboratoryTestInterpretationModel.ReadOnlyIndicator;
                        request.ReportSessionCreatedIndicator =
                            laboratoryTestInterpretationModel.ReportSessionCreatedIndicator;
                        request.RowAction = laboratoryTestInterpretationModel.RowAction;
                        request.RowStatus = laboratoryTestInterpretationModel.RowStatus;
                        request.TestID = laboratoryTestInterpretationModel.TestID;
                        request.TestInterpretationID = laboratoryTestInterpretationModel.TestInterpretationID;
                        request.ValidatedByOrganizationID = laboratoryTestInterpretationModel.ValidatedByOrganizationID;
                        request.ValidatedByPersonID = laboratoryTestInterpretationModel.ValidatedByPersonID;
                        request.ValidatedComment = laboratoryTestInterpretationModel.ValidatedComment;
                        request.ValidatedDate = laboratoryTestInterpretationModel.ValidatedDate;
                        request.ValidatedStatusIndicator = laboratoryTestInterpretationModel.ValidatedStatusIndicator;
                    }

                    requests.Add(request);
                }
            }
            else
            {
                var laboratoryTestInterpretationModel =
                    laboratoryTestInterpretations.First(x => x.TestID == connectedDiseaseReportTestId);
                request = new LaboratoryTestInterpretationSaveRequestModel();
                {
                    request.DiseaseID = laboratoryTestInterpretationModel.DiseaseID;
                    request.InterpretedByOrganizationID = laboratoryTestInterpretationModel.InterpretedByOrganizationID;
                    request.InterpretedByPersonID = laboratoryTestInterpretationModel.InterpretedByPersonID;
                    request.InterpretedComment = laboratoryTestInterpretationModel.InterpretedComment;
                    request.InterpretedDate = laboratoryTestInterpretationModel.InterpretedDate;
                    request.InterpretedStatusTypeID = laboratoryTestInterpretationModel.InterpretedStatusTypeID;
                    request.ReadOnlyIndicator = laboratoryTestInterpretationModel.ReadOnlyIndicator;
                    request.ReportSessionCreatedIndicator =
                        laboratoryTestInterpretationModel.ReportSessionCreatedIndicator;
                    request.RowAction = (int) RowActionTypeEnum.Update;
                    request.RowStatus = laboratoryTestInterpretationModel.RowStatus;
                    request.TestID = laboratoryTestInterpretationModel.TestID;
                    request.TestInterpretationID = laboratoryTestInterpretationModel.TestInterpretationID;
                    request.ValidatedByOrganizationID = laboratoryTestInterpretationModel.ValidatedByOrganizationID;
                    request.ValidatedByPersonID = laboratoryTestInterpretationModel.ValidatedByPersonID;
                    request.ValidatedComment = laboratoryTestInterpretationModel.ValidatedComment;
                    request.ValidatedDate = laboratoryTestInterpretationModel.ValidatedDate;
                    request.ValidatedStatusIndicator = laboratoryTestInterpretationModel.ValidatedStatusIndicator;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        /// </summary>
        /// <param name="caseLogs"></param>
        /// <param name="createConnectedDiseaseReportIndicator"></param>
        /// <returns></returns>
        private static List<CaseLogSaveRequestModel> BuildCaseLogParameters(IList<CaseLogGetListViewModel> caseLogs,
            bool createConnectedDiseaseReportIndicator)
        {
            List<CaseLogSaveRequestModel> requests = new();

            if (caseLogs is null)
                return new List<CaseLogSaveRequestModel>();

            foreach (var caseLogModel in caseLogs)
            {
                var request = new CaseLogSaveRequestModel();
                {
                    request.CaseLogID = caseLogModel.DiseaseReportLogID;
                    request.ActionRequired = caseLogModel.ActionRequired;
                    request.Comments = caseLogModel.Comments;
                    request.LogDate = caseLogModel.LogDate;
                    request.LoggedByPersonID = caseLogModel.EnteredByPersonID;
                    request.LogStatusTypeID = caseLogModel.LogStatusTypeID;
                    request.RowAction = createConnectedDiseaseReportIndicator
                        ? (int) RowActionTypeEnum.Insert
                        : caseLogModel.RowAction;
                    request.RowStatus = caseLogModel.RowStatus;
                }

                requests.Add(request);
            }

            return requests;
        }

        public async Task OnMergeAsync()
        {
            if (AllFieldValuePairsUnmatched())
            {
                await ShowWarningMessage(
                    MessageResourceKeyConstants
                        .DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage,
                    null);
            }
            else if (VeterinaryDiseaseReportDeduplicationService.RecordSelection == 0 &&
                     VeterinaryDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(
                    MessageResourceKeyConstants
                        .DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage,
                    null);
            }
            else
            {
                if (AllFieldValuePairsSelected())
                {
                    ShowDetails = false;
                    ShowReview = true;

                    foreach (var item in VeterinaryDiseaseReportDeduplicationService.SurvivorInfoList)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                    }

                    foreach (var item in VeterinaryDiseaseReportDeduplicationService.SurvivorNotificationList)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                    }

                    var herdFlockList = VeterinaryDiseaseReportDeduplicationService.SurvivorFarmInventory
                        .Where(x => x.RecordType == RecordTypeConstants.Herd).ToList();
                    var speciesList = VeterinaryDiseaseReportDeduplicationService.SurvivorFarmInventory
                        .Where(x => x.RecordType == RecordTypeConstants.Species).ToList();

                    if (herdFlockList.Count == 0 && speciesList.Count == 0)
                    {
                        if (VeterinaryDiseaseReportDeduplicationService.ReportType == VeterinaryReportTypeEnum.Avian &&
                            VeterinaryDiseaseReportDeduplicationService.SurvivorSamples.Count > 0)
                            CopyFlocksOrHerdsAndSpeciesToSurvivor();
                        if (VeterinaryDiseaseReportDeduplicationService.ReportType ==
                            VeterinaryReportTypeEnum.Livestock &&
                            VeterinaryDiseaseReportDeduplicationService.SurvivorAnimals.Count > 0)
                            CopyFlocksOrHerdsAndSpeciesToSurvivor();
                    }
                }
                else
                {
                    await ShowWarningMessage(
                        MessageResourceKeyConstants
                            .DeduplicationPersonFieldvaluepairsfoundwithnoselectionAllfieldvaluepairsmustcontainaselectedvaluetosurviveMessage,
                        null);
                }
            }
        }

        protected void CopyFlocksOrHerdsAndSpeciesToSurvivor()
        {
            if (VeterinaryDiseaseReportDeduplicationService.RecordSelection == 1)
            {
                VeterinaryDiseaseReportDeduplicationService.SurvivorFarmInventory =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.FarmInventory2);
                VeterinaryDiseaseReportDeduplicationService.SurvivorSpecies =
                    VeterinaryDiseaseReportDeduplicationService.Species2;
                VeterinaryDiseaseReportDeduplicationService.SurvivorSpeciesFlexFormRequest =
                    VeterinaryDiseaseReportDeduplicationService.SpeciesFlexFormRequest2;
            }
            else
            {
                VeterinaryDiseaseReportDeduplicationService.SurvivorFarmInventory =
                    CopyAllInList(VeterinaryDiseaseReportDeduplicationService.FarmInventory);
                VeterinaryDiseaseReportDeduplicationService.SurvivorSpecies =
                    VeterinaryDiseaseReportDeduplicationService.Species;
                VeterinaryDiseaseReportDeduplicationService.SurvivorSpeciesFlexFormRequest =
                    VeterinaryDiseaseReportDeduplicationService.SpeciesFlexFormRequest;
            }
        }

        protected async Task SaveSuccessMessagedDialog(VeterinaryReportTypeEnum reportType)
        {
            var buttons = new List<DialogButton>();
            var okButton = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                ButtonType = DialogButtonType.OK
            };
            buttons.Add(okButton);

            var dialogParams = new Dictionary<string, object>
            {
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {
                    nameof(EIDSSDialog.Message),
                    Localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage)
                }
            };
            var result =
                await DiagService.OpenAsync<EIDSSDialog>(
                    Localizer.GetString(HeadingResourceKeyConstants.EIDSSSuccessModalHeading), dialogParams);
            if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText ==
                Localizer.GetString(ButtonResourceKeyConstants.OKButton))
            {
                VeterinaryDiseaseReportDeduplicationService.SelectedRecords = null;
                var uri = reportType == VeterinaryReportTypeEnum.Livestock
                    ? $"{NavManager.BaseUri}Administration/Deduplication/VeterinaryDiseaseReportDeduplication/LivestockDiseaseReportDeduplication"
                    : $"{NavManager.BaseUri}Administration/Deduplication/VeterinaryDiseaseReportDeduplication/AvianDiseaseReportDeduplication";

                NavManager.NavigateTo(uri, true);
            }
        }

        public static void SetValue(object inputObject, string propertyName, object propertyVal)
        {
            //find out the type
            var type = inputObject.GetType();

            //get the property information based on the type
            var propertyInfo = type.GetProperty(propertyName);

            //find the property type
            if (propertyInfo != null)
            {
                var propertyType = propertyInfo.PropertyType;
                var t = propertyType;

                //Convert.ChangeType does not handle conversion to nullable types
                //if the property type is nullable, we need to get the underlying type of the property
                object targetType = propertyType;

                if (t.IsGenericType && t.GetGenericTypeDefinition() == typeof(Nullable<>))
                {
                    if (string.IsNullOrEmpty((string) propertyVal))
                    {
                        propertyVal = "0";
                    }
                    else
                    {
                        t = Nullable.GetUnderlyingType(t);
                        if (t != null) propertyVal = Convert.ChangeType(propertyVal, t);
                    }
                }
                else
                {
                    //Returns an System.Object with the specified System.Type and whose value is
                    //equivalent to the specified object.
                    propertyVal = Convert.ChangeType(propertyVal, (Type) targetType);
                }
            }

            //Set the value of the property
            if (propertyInfo != null) propertyInfo.SetValue(inputObject, propertyVal, null);
        }

        public async Task OnSaveAsync(VeterinaryReportTypeEnum reportType)
        {
            var result =
                await ShowWarningDialog(
                    MessageResourceKeyConstants.DeduplicationPersonDoyouwanttodeduplicaterecordMessage, null);

            if (result is DialogReturnResult returnResult && returnResult.ButtonResultText ==
                Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                await DeduplicateRecordsAsync(reportType);
            if (result is DialogReturnResult returnResult2 && returnResult2.ButtonResultText ==
                Localizer.GetString(ButtonResourceKeyConstants.NoButton))
            {
            }
        }

        private async Task DeduplicateRecordsAsync(VeterinaryReportTypeEnum reportType)
        {
            try
            {
                var result = await DedupeRecordsAsync();
                if (result) await SaveSuccessMessagedDialog(reportType);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        private async Task<bool> DedupeRecordsAsync()
        {
            try
            {
                var request = new VeterinaryDiseaseReportDedupeRequestModel();
                var type = request.GetType();
                var props = type.GetProperties();

                for (var i = 0; i <= props.Length - 1; i++)
                {
                    int index;
                    if (IsInVetDiseaseReportSaveRequestModel(props[i].Name))
                    {
                        index = props[i].Name switch
                        {
                            "StatusTypeID" => KeyDict["ReportStatusTypeID"],
                            "MonitoringSessionID" => KeyDict["ParentMonitoringSessionID"],
                            "FarmLatitude" => KeyDict["FarmAddressLatitude"],
                            "FarmLongitude" => KeyDict["FarmAddressLongitude"],
                            _ => KeyDict[props[i].Name]
                        };

                        var safeValue = VeterinaryDiseaseReportDeduplicationService.SurvivorInfoList[index].Value;
                        if (safeValue != null)
                            SetValue(request, props[i].Name, safeValue);
                        else
                            props[i].SetValue(request, null);
                    }
                    else if (IsInTabNotification(props[i].Name))
                    {
                        index = KeyDict2[props[i].Name];
                        var safeValue = VeterinaryDiseaseReportDeduplicationService.SurvivorNotificationList[index]
                            .Value;
                        if (safeValue != null)
                            SetValue(request, props[i].Name, safeValue);
                        else
                            props[i].SetValue(request, null);
                    }
                }

                request.SurvivorVeterinaryDiseaseReportID =
                    VeterinaryDiseaseReportDeduplicationService.SurvivorVeterinaryDiseaseReportID;
                request.SupersededVeterinaryDiseaseReportID =
                    VeterinaryDiseaseReportDeduplicationService.SupersededVeterinaryDiseaseReportID;
                request.RelatedToDiseaseReportID = null;
                request.RowStatus = 0;
                request.FarmTotalAnimalQuantity =
                    VeterinaryDiseaseReportDeduplicationService.SurvivorFarmInventory.Any()
                        ? VeterinaryDiseaseReportDeduplicationService.SurvivorFarmInventory
                            .First(x => x.RecordType == HerdSpeciesConstants.Farm)
                            .TotalAnimalQuantity
                        : 0;
                request.FarmSickAnimalQuantity = VeterinaryDiseaseReportDeduplicationService.SurvivorFarmInventory.Any()
                    ? VeterinaryDiseaseReportDeduplicationService.SurvivorFarmInventory
                        .First(x => x.RecordType == HerdSpeciesConstants.Farm)
                        .SickAnimalQuantity
                    : 0;
                request.FarmDeadAnimalQuantity = VeterinaryDiseaseReportDeduplicationService.SurvivorFarmInventory.Any()
                    ? VeterinaryDiseaseReportDeduplicationService.SurvivorFarmInventory
                        .First(x => x.RecordType == HerdSpeciesConstants.Farm)
                        .DeadAnimalQuantity
                    : 0;
                request.User = authenticatedUser.UserName;
                request.FlocksOrHerds = JsonConvert.SerializeObject(BuildFlocksOrHerdsParameters(
                    VeterinaryDiseaseReportDeduplicationService.SurvivorFarmInventory
                        .Where(x => x.RecordType == RecordTypeConstants.Herd).ToList(),
                    false));
                request.Species = JsonConvert.SerializeObject(BuildSpeciesParameters(
                    VeterinaryDiseaseReportDeduplicationService.SurvivorFarmInventory
                        .Where(x => x.RecordType == RecordTypeConstants.Species)
                        .ToList(), false));
                request.Animals = JsonConvert.SerializeObject(BuildAnimalParameters(
                    VeterinaryDiseaseReportDeduplicationService.SurvivorAnimals,
                    false));
                request.Vaccinations = JsonConvert.SerializeObject(
                    BuildVaccinationParameters(VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations,
                        false));
                request.Samples = JsonConvert.SerializeObject(BuildSampleParameters(
                    VeterinaryDiseaseReportDeduplicationService.SurvivorSamples,
                    false));
                request.PensideTests = JsonConvert.SerializeObject(BuildPensideTestParameters(
                    VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests,
                    false));
                request.LaboratoryTests = JsonConvert.SerializeObject(BuildLaboratoryTestParameters(
                    VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests,
                    null));
                request.LaboratoryTestInterpretations = JsonConvert.SerializeObject(
                    BuildLaboratoryTestInterpretationParameters(
                        VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations,
                        null));
                request.CaseLogs = JsonConvert.SerializeObject(BuildCaseLogParameters(
                    VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogs,
                    false));
                request.UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId);

                var response = await VeterinaryClient.DedupeVeterinaryDiseaseReportRecords(request, _token);

                if (response.ReturnCode != null)
                    //Success
                    return response.ReturnCode == 0;
                //ShowErrorMessage(messageType: MessageType.CannotSaveSurvivorRecord, message: GetLocalResourceObject("Lbl_Cannot_Save_Survivor_Record").ToString());
                return false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }

            return false;
        }

        #endregion
    }
}