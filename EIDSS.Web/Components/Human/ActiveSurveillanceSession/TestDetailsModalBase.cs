using Microsoft.AspNetCore.Components;
using EIDSS.Web.Areas.Human.ViewModels.ActiveSurveillanceSession;
using Microsoft.AspNetCore.Components.Forms;
using EIDSS.ClientLibrary.Services;
using EIDSS.ClientLibrary.ApiClients.Human;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Domain.ResponseModels.Human;
using System.Linq;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels.Administration;
using System.Collections.Generic;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Human.ActiveSurveillanceSession
{
    public class TestDetailsModalBase : ParentComponent, IDisposable
    {
        #region Globals

        [Parameter]
        public ActiveSurveillanceSessionViewModel model { get; set; }

        [Inject]
        ITokenService TokenService { get; set; }

        [Inject]
        public IHumanActiveSurveillanceSessionClient _humanActiveSurveillanceSessionClient { get; set; }

        [Inject]
        protected DialogService DialogService { get; set; }

        [Inject]
        private ITestNameTestResultsMatrixClient TestNameTestResultsMatrixClient { get; set; }
        public bool IsLoading { get; set; }
        protected bool TestNameDisabled { get; set; } = true;
        protected bool TestResultDisabled { get; set; } = true;

        public EditContext EditContext { get; set; }
        private ILogger<TestDetailsModalBase> Logger { get; set; }
        private CancellationTokenSource source;
        private CancellationToken token;

        public RadzenTemplateForm<ActiveSurveillanceSessionViewModel> _form { get; set; }

        #endregion

        protected override async Task OnInitializedAsync()
        {
            try
            {
                IsLoading = true;
                EditContext = new(model);

                if (!string.IsNullOrEmpty(model.TestsInformation.FieldSampleID))
                {
                    await FieldSampleSelected(model.TestsInformation.FieldSampleID);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

            await base.OnInitializedAsync();
        }

        protected async Task FieldSampleSelected(object value)
        {
            try
            {
                await ClearTestModal(value == null);

                if (value != null)
                {
                    long idfsSampleType = 0;

                    if (!string.IsNullOrEmpty(model.DetailedInformation.List.Where(x => x.FieldSampleID == value.ToString()).FirstOrDefault().ToString()))
                    {
                        idfsSampleType = long.Parse(model.DetailedInformation.List.Where(x => x.FieldSampleID == value.ToString()).FirstOrDefault().idfsSampleType.ToString());
                    }

                    if (value != null)
                    {
                        if (authenticatedUser == null)
                        {
                            authenticatedUser = _tokenService.GetAuthenticatedUser();
                        }

                        ActiveSurveillanceFilteredDisease disease = new ActiveSurveillanceFilteredDisease();
                        List<ActiveSurveillanceFilteredDisease> diseases = new List<ActiveSurveillanceFilteredDisease>();

                        foreach (ActiveSurveillanceSessionDiseaseSampleType diseaseSampleType in model.DiseasesSampleTypesUnfiltered.Where(x => x.SampleTypeID == idfsSampleType))
                        {
                            disease = new ActiveSurveillanceFilteredDisease();

                            disease.DiseaseID = (long)diseaseSampleType.DiseaseID;
                            disease.DiseaseName = diseaseSampleType.DiseaseName;

                            diseases.Add(disease);
                        }

                        model.TestsInformation.Diseases = diseases;

                        ActiveSurveillanceSessionDetailedInformationResponseModel detailedInformation;
                        detailedInformation = model.DetailedInformation.List.Where(x => x.FieldSampleID == value.ToString()).First();

                        model.TestsInformation.SampleType = detailedInformation.SampleType;
                        model.TestsInformation.PersonID = long.Parse(detailedInformation.PersonID.ToString());
                        model.TestsInformation.EIDSSPersonID = detailedInformation.EIDSSPersonID;

                        TestNameDisabled = model.TestsInformation.TestDiseaseID == null || model.TestsInformation.TestDiseaseID == -1;
                        TestResultDisabled = model.TestsInformation.TestNameID == null || model.TestsInformation.TestNameID == -1;
                    }

                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        protected async Task GetFilteredTestNames(object args)
        {
            try
            {
                model.TestsInformation.TestNameID = null;

                if (args != null)
                {
                    if (model.TestsInformation.FilterByDisease)
                    {  
                        if (model.TestsInformation.TestDiseaseID != null)
                        {
                            args = model.TestsInformation.TestDiseaseID;
                        }

                        //if (model.TestsInformation.Diseases != null)
                        //{
                        //    foreach (BaseReferenceEditorsViewModel TestNameDisease in model.TestsInformation.Diseases)
                        //    {
                        //        args += TestNameDisease.KeyId + ",";
                        //    }

                        //    args = (args + ".").Replace(",.", "");
                        //}
                    }
                    else
                    {
                        args = -1;
                    }


                    ActiveSurveillanceSessionTestNameRequestModel request = new ActiveSurveillanceSessionTestNameRequestModel()
                    {
                        LanguageId = GetCurrentLanguage(),
                        DiseaseIDList = args.ToString() == "-1" ? null: args.ToString(),
                        Page = 1,
                        PageSize = 10000,
                        SortColumn = "TestNameTypeName",
                        SortOrder = "desc"
                    };

                    var response = await _humanActiveSurveillanceSessionClient.GetActiveSurveillanceSessionTestNames(request);

                    model.TestsInformation.TestNames = response.AsEnumerable();

                    TestNameDisabled = !(model.TestsInformation.TestNames.Count() > 0);
                    
                    await InvokeAsync(StateHasChanged);
                }
                else
                {
                    model.TestsInformation.TestNames = null;
                    model.TestsInformation.TestResults = null;

                    model.TestsInformation.TestNameID = -1;
                    model.TestsInformation.TestResultID = -1;

                    TestNameDisabled = true;
                    TestResultDisabled = true;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        protected async Task FilterByDiseaseSelected(object value)
        {
            try
            {
                model.TestsInformation.TestNameID = null;
                model.TestsInformation.TestResultID = null;
                model.TestsInformation.FilterByDisease = bool.Parse(value.ToString());
                await GetFilteredTestNames(0);
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }
        protected async Task FilterByTestName(object value)
        {
            try
            {
                if (value != null)
                {
                    var request = new TestNameTestResultsMatrixGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        idfsTestName = long.Parse(value.ToString()),
                        idfsTestResultRelation = BaseReferenceTypeIds.LabTest,
                        Page = 1,
                        PageSize = 100,
                        SortColumn = "strTestResultDefault",
                        SortOrder = "asc",
                    };

                    model.TestsInformation.TestResults = await TestNameTestResultsMatrixClient.GetTestNameTestResultsMatrixList(request);
                    TestResultDisabled = !(model.TestsInformation.TestResults.Count() > 0);
                }
                else
                {
                    model.TestsInformation.TestResults = null;
                    model.TestsInformation.TestResultID = -1;
                    TestResultDisabled = true;
                }
            }
            catch(Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        protected async Task HandleValidSubmit(ActiveSurveillanceSessionViewModel model)
        {
            try
            {
                if (_form.IsValid)
                {
                    string strTestCategory = string.Empty;

                    if (model.TestsInformation.TestCategoryID != null)
                    {
                        strTestCategory = TestCategories.Where(x => x.IdfsBaseReference == model.TestsInformation.TestCategoryID).First().Name;
                    }

                    ActiveSurveillanceSessionTestsResponseModel testInformation = new ActiveSurveillanceSessionTestsResponseModel()
                    {
                        FieldSampleID = model.TestsInformation.FieldSampleID,
                        LabSampleID = model.TestsInformation.LabSampleID,
                        SampleType = model.TestsInformation.SampleType,
                        PersonID = model.TestsInformation.PersonID,
                        EIDSSPersonID = model.TestsInformation.EIDSSPersonID,
                        TestName = model.TestsInformation.TestNames.Where(x => x.TestNameTypeID == model.TestsInformation.TestNameID).First().TestNameTypeName,
                        TestNameID = long.Parse(model.TestsInformation.TestNameID.ToString()),
                        TestCategory = strTestCategory,
                        TestCategoryID = model.TestsInformation.TestCategoryID,
                        TestResult = model.TestsInformation.TestResults.Where(x => x.idfsTestResult == model.TestsInformation.TestResultID).First().strTestResultName,
                        TestResultID = model.TestsInformation.TestResultID,
                        ResultDate = model.TestsInformation.ResultDate,
                        DiseaseID = model.TestsInformation.TestDiseaseID,
                        SampleTypeID = model.TestsInformation.SampleTypeID,
                        TestStatusID = model.TestsInformation.TestStatusID,
                        Diagnosis = model.TestsInformation.Diseases.Where(x => x.DiseaseID == model.TestsInformation.TestDiseaseID).FirstOrDefault().DiseaseName,
                        SampleID = model.DetailedInformation.UnfilteredList.Where(x => x.FieldSampleID == model.TestsInformation.FieldSampleID).FirstOrDefault().ID
                    };

                    if (model.TestsInformation.List == null)
                    {
                        model.TestsInformation.List = new List<ActiveSurveillanceSessionTestsResponseModel>();
                    }

                    if (model.TestsInformation.ID == null)
                    {
                        testInformation.ID = testInformation.ID ?? model.TestsInformation.NewRecordId--;
                        model.TestsInformation.List.Add(testInformation);
                        model.TestsInformation.List = model.TestsInformation.List.Where(x => x.RowAction != EIDSSConstants.UserAction.Delete).ToList();
                    }
                    else
                    {
                        int iIndex = model.TestsInformation.List.FindIndex(x => x.ID == model.TestsInformation.ID);
                        testInformation.ID = model.TestsInformation.ID;
                        model.TestsInformation.List[iIndex] = testInformation;
                    }

                    model.TestsInformation.UnfilteredList = model.TestsInformation.List;

                    await InvokeAsync(StateHasChanged);
                    DialogService.Close();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        protected async Task HandleInvalidSubmit(FormInvalidSubmitEventArgs args)
        {
            try
            {
                string test = "";
            }
            catch (Exception)
            {
                throw;
            }
        }

        public void Dispose()
        {

        }
    }
}
