using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Extensions;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.SubAreas.Deduplication.ViewModels.PersonDeduplication;
using EIDSS.Web.Areas.Administration.ViewModels.Administration.HumanDiseaseReportDeduplication;
using EIDSS.Web.Components.Administration.Deduplication.HumanDiseaseReport;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Newtonsoft.Json;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Administration.Deduplication.HumanDiseaseReport
{
    public class HumanDiseaseReportDeduplicationDetailsBase : HumanDiseaseReportDeduplicationBaseComponent
    {
		#region Globals

		#region Dependencies

		[Inject]
		private IJSRuntime JsRuntime { get; set; }

		[Inject]
        private IHumanDiseaseReportClient HumanDiseaseReportClient { get; set; }

        [Inject]
        private ILogger<HumanDiseaseReportDeduplicationDetailsBase> Logger { get; set; }

		#endregion

		#region Parameters
		[Parameter]
		public HumanDiseaseReportDeduplicationDetailsViewModel Model { get; set; }

		[Parameter]
		public HumanDiseaseReportDeduplicationTabEnum Tab { get; set; }
		#endregion

		#region Protected and Public Variables

		protected RadzenTemplateForm<HumanDiseaseReportDeduplicationDetailsViewModel> form;

		protected bool shouldRender = true;

        #endregion

        #region Private Variables

        private CancellationTokenSource source;
        private CancellationToken token;
        private object _localizer;

        private const Int16 HumanidfsRayon = 32;
        private const Int16 HumanidfsSettlementType = 33;
        private const Int16 HumanidfsSettlement = 34;
        private const Int16 HumanGeoLocationID = 35;

        private List<Field> SurvivorListInfo = new List<Field>();
        private List<Field> SurvivorListAddress = new List<Field>();
        private List<Field> SurvivorListEmp = new List<Field>();


		#endregion

		#endregion

		#region Protected and Public Methods

		protected override async Task OnInitializedAsync()
		{
			authenticatedUser = _tokenService.GetAuthenticatedUser();

			// Wire up PersonDeduplication state container service
			HumanDiseaseReportDeduplicationService.OnChange += async (property) => await OnStateContainerChangeAsync(property);
			

			await base.OnInitializedAsync();
			await InitializeModelAsync();
            OnChange(0);
        }

		///// <summary>
		///// 
		///// </summary>
		///// <param name="firstRender"></param>
		///// <returns></returns>
		//protected override async Task OnAfterRenderAsync(bool firstRender)
		//{
		//	if (firstRender)
		//	{
		//		//bool enableDeleteButton = false;
		//		//if (Model.Permissions.Delete)
		//		//	enableDeleteButton = true;

		//		await JsRuntime.InvokeAsync<string>("initializeSidebar", Localizer.GetString(ButtonResourceKeyConstants.CancelButton).ToString(), Localizer.GetString(ButtonResourceKeyConstants.SaveButton).ToString(), Localizer.GetString(ButtonResourceKeyConstants.NextButton).ToString(), Localizer.GetString(ButtonResourceKeyConstants.PreviousButton).ToString(), Localizer.GetString(MessageResourceKeyConstants.PleaseWaitWhileWeProcessYourRequestMessage).ToString(), Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage).ToString(), Localizer.GetString(ButtonResourceKeyConstants.PrintButton).ToString(), Localizer.GetString(ButtonResourceKeyConstants.DeleteButton).ToString(), Localizer.GetString(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage).ToString(), enableDeleteButton, Model.StartIndex);
		//		//await SendDotNetInstanceToJS();
		//	}
		//}

		public void Dispose()
        {
            try
            {
                source?.Cancel();
                source?.Dispose();

				HumanDiseaseReportDeduplicationService.OnChange -= async (property) => await OnStateContainerChangeAsync(property);
			}
			catch (Exception)
            {
                throw;
            }
        }

		public void OnChange(int index)
		{
			Tab = (HumanDiseaseReportDeduplicationTabEnum)index;
			OnTabChange(index);
		}

		public void NextClicked()
		{
			switch (Tab)
			{
                case HumanDiseaseReportDeduplicationTabEnum.Summary:
                    Tab = HumanDiseaseReportDeduplicationTabEnum.Notification;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case HumanDiseaseReportDeduplicationTabEnum.Notification:
                    Tab = HumanDiseaseReportDeduplicationTabEnum.Symptoms;
                    showPreviousButton = true;
					showNextButton = true;
					break;
				case HumanDiseaseReportDeduplicationTabEnum.Symptoms:
					Tab = HumanDiseaseReportDeduplicationTabEnum.FacilityDetails;
					showPreviousButton = true;
					showNextButton = true;
					break;
                case HumanDiseaseReportDeduplicationTabEnum.FacilityDetails:
                    Tab = HumanDiseaseReportDeduplicationTabEnum.AntibioticVaccineHistory;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case HumanDiseaseReportDeduplicationTabEnum.AntibioticVaccineHistory:
                    Tab = HumanDiseaseReportDeduplicationTabEnum.Samples;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case HumanDiseaseReportDeduplicationTabEnum.Samples:
                    Tab = HumanDiseaseReportDeduplicationTabEnum.Test;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case HumanDiseaseReportDeduplicationTabEnum.Test:
                    Tab = HumanDiseaseReportDeduplicationTabEnum.CaseInvestigation;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case HumanDiseaseReportDeduplicationTabEnum.CaseInvestigation:
                    Tab = HumanDiseaseReportDeduplicationTabEnum.RiskFactors;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case HumanDiseaseReportDeduplicationTabEnum.RiskFactors:
                    Tab = HumanDiseaseReportDeduplicationTabEnum.ContactList;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case HumanDiseaseReportDeduplicationTabEnum.ContactList:
                    Tab = HumanDiseaseReportDeduplicationTabEnum.FinalOutcome;
                    showPreviousButton = true;
                    showNextButton = false;
                    break;    
            }

			HumanDiseaseReportDeduplicationService.TabChangeIndicator = true;
		}


        public void PreviousClicked()
        {
            switch (Tab)
            {
                case HumanDiseaseReportDeduplicationTabEnum.Summary:
                    Tab = HumanDiseaseReportDeduplicationTabEnum.Notification;
                    showPreviousButton = false;
                    showNextButton = true;
                    break;
                case HumanDiseaseReportDeduplicationTabEnum.Symptoms:
                    Tab = HumanDiseaseReportDeduplicationTabEnum.Notification;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case HumanDiseaseReportDeduplicationTabEnum.FacilityDetails:
                    Tab = HumanDiseaseReportDeduplicationTabEnum.Symptoms;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case HumanDiseaseReportDeduplicationTabEnum.AntibioticVaccineHistory:
                    Tab = HumanDiseaseReportDeduplicationTabEnum.FacilityDetails;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case HumanDiseaseReportDeduplicationTabEnum.Samples:
                    Tab = HumanDiseaseReportDeduplicationTabEnum.AntibioticVaccineHistory;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case HumanDiseaseReportDeduplicationTabEnum.Test:
                    Tab = HumanDiseaseReportDeduplicationTabEnum.Samples;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case HumanDiseaseReportDeduplicationTabEnum.CaseInvestigation:
                    Tab = HumanDiseaseReportDeduplicationTabEnum.Test;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case HumanDiseaseReportDeduplicationTabEnum.RiskFactors:
                    Tab = HumanDiseaseReportDeduplicationTabEnum.CaseInvestigation;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case HumanDiseaseReportDeduplicationTabEnum.ContactList:
                    Tab = HumanDiseaseReportDeduplicationTabEnum.RiskFactors;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case HumanDiseaseReportDeduplicationTabEnum.FinalOutcome:
                    Tab = HumanDiseaseReportDeduplicationTabEnum.ContactList;
                    showPreviousButton = true;
                    showNextButton = false;
                    break;
            }

            HumanDiseaseReportDeduplicationService.TabChangeIndicator = true;
        }

       

        #endregion
        #region Private Methods

        private async Task InitializeModelAsync()
		{
			if (Model == null)
			{
				Model = new HumanDiseaseReportDeduplicationDetailsViewModel()
				{
					LeftHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID,
					RightHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID2,
					NotificationSection = new HumanDiseaseReportDeduplicationNotificationSectionViewModel(),
					SymptomsSection = new HumanDiseaseReportDeduplicationSymptomsSectionViewModel(),
                    FacilityDetailSection=new HumanDiseaseReportDeduplicationFacilityDetailsSectionViewModel(),
                    AntibioticVaccineHistorySection=new HumanDiseaseReportDeduplicationAntibioticVaccineHistorySectionViewModel(),
                    SamplesSection= new HumanDiseaseReportDeduplicationSamplesSectionViewModel(),
                    TestsSection= new HumanDiseaseReportDeduplicationTestsSectionViewModel(),
                    CaseInvestigationDetailsSection=new HumanDiseaseReportDeduplicationCaseInvestigationDetailsSectionViewModel(),
                    CaseInvestigationRiskFactorsSection=new HumanDiseaseReportDeduplicationRiskFactorsSectionViewModel(),
                    ContactsSection=new HumanDiseaseReportDeduplicationContactsSectionViewModel(),
                    FinalOutcomeSection=new HumanDiseaseReportDeduplicationFinalOutcomeSectionViewModel()

				};
			}

			HumanDiseaseReportDeduplicationService.HumanDiseaseReportID = Model.LeftHumanDiseaseReportID;
			HumanDiseaseReportDeduplicationService.HumanDiseaseReportID2 = Model.RightHumanDiseaseReportID;

			await FillDeduplicationDetailsAsync(Model.LeftHumanDiseaseReportID, Model.RightHumanDiseaseReportID);


			HumanDiseaseReportDeduplicationService.OnChange += async (property) => await OnStateContainerChangeAsync(property);

		}

		private async Task OnStateContainerChangeAsync(string property)
		{
			await InvokeAsync(StateHasChanged);
		}

        private async Task FillDeduplicationDetailsAsync(long humanDiseaseReportID, long humanDiseaseReportID2)
        {
            try
            {
                HumanDiseaseReportDeduplicationService.HumanDiseaseReportID = humanDiseaseReportID;
                HumanDiseaseReportDeduplicationService.HumanDiseaseReportID2 = humanDiseaseReportID2;
                var request = new HumanDiseaseReportDetailRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = 10,
                    SearchHumanCaseId = Convert.ToInt64(humanDiseaseReportID),
                    SortColumn = "datEnteredDate",
                    SortOrder = "desc"
                };

                var request2 = new HumanDiseaseReportDetailRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = 10,
                    SearchHumanCaseId = Convert.ToInt64(humanDiseaseReportID2),
                    SortColumn = "datEnteredDate",
                    SortOrder = "desc"
                };

                var record = await HumanDiseaseReportClient.GetHumanDiseaseDetail(request);
                var record2 = await HumanDiseaseReportClient.GetHumanDiseaseDetail(request2);


                HumanDiseaseReportDeduplicationService.idfHuman = record.idfHuman;
                HumanDiseaseReportDeduplicationService.idfHumanActual = record.HumanActualId.Value;
                HumanDiseaseReportDeduplicationService.idfsCaseProgressStatus = record.idfsCaseProgressStatus;
                HumanDiseaseReportDeduplicationService.idfsYNRelatedToOutbreak = record.idfsYNRelatedToOutbreak;
                HumanDiseaseReportDeduplicationService.DiseaseReportTypeID = record.DiseaseReportTypeID;
                HumanDiseaseReportDeduplicationService.strHumanCaseId = record.strCaseId;
                HumanDiseaseReportDeduplicationService.blnClinicalDiagBasis = record.blnClinicalDiagBasis != null ? record.blnClinicalDiagBasis: false;
                HumanDiseaseReportDeduplicationService.blnLabDiagBasis = record.blnLabDiagBasis != null ? record.blnLabDiagBasis : false;
                HumanDiseaseReportDeduplicationService.blnEpiDiagBasis = record.blnEpiDiagBasis != null ? record.blnEpiDiagBasis : false;
                HumanDiseaseReportDeduplicationService.strNote = record.strNote;

                string strBasisOfDiagnosis = string.Empty;
                if ((bool)HumanDiseaseReportDeduplicationService.blnClinicalDiagBasis)
                    strBasisOfDiagnosis = Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportFinalOutcomeClinicalFieldLabel);

                if ((bool)HumanDiseaseReportDeduplicationService.blnEpiDiagBasis)
                {
                    if (string.IsNullOrEmpty(strBasisOfDiagnosis))
                        strBasisOfDiagnosis = Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportFinalOutcomeEpidemiologicalLinksFieldLabel);
                    else
                        strBasisOfDiagnosis += "," + Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportFinalOutcomeEpidemiologicalLinksFieldLabel);
                }

                if ((bool)HumanDiseaseReportDeduplicationService.blnLabDiagBasis)
                {
                    if (string.IsNullOrEmpty(strBasisOfDiagnosis))
                        strBasisOfDiagnosis = Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportFinalOutcomeLaboratoryTestsFieldLabel);
                    else
                        strBasisOfDiagnosis += "," + Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportFinalOutcomeLaboratoryTestsFieldLabel);
                }
                record.strClinicalDiagnosis = strBasisOfDiagnosis;

                HumanDiseaseReportDeduplicationService.idfHuman2 = record2.idfHuman;
                HumanDiseaseReportDeduplicationService.idfHumanActual2 = record.HumanActualId.Value;
                HumanDiseaseReportDeduplicationService.idfsCaseProgressStatus2 = record2.idfsCaseProgressStatus;
                HumanDiseaseReportDeduplicationService.idfsYNRelatedToOutbreak2 = record2.idfsYNRelatedToOutbreak;
                HumanDiseaseReportDeduplicationService.DiseaseReportTypeID2 = record2.DiseaseReportTypeID;
                HumanDiseaseReportDeduplicationService.strHumanCaseId2 = record2.strCaseId;
                HumanDiseaseReportDeduplicationService.blnClinicalDiagBasis2 = record2.blnClinicalDiagBasis != null ? record2.blnClinicalDiagBasis : false;
                HumanDiseaseReportDeduplicationService.blnLabDiagBasis2 = record2.blnLabDiagBasis != null ? record2.blnLabDiagBasis : false;
                HumanDiseaseReportDeduplicationService.blnEpiDiagBasis2 = record2.blnEpiDiagBasis != null ? record2.blnEpiDiagBasis : false;
                HumanDiseaseReportDeduplicationService.strNote2 = record2.strNote;

                strBasisOfDiagnosis = string.Empty;
                if ((bool)HumanDiseaseReportDeduplicationService.blnClinicalDiagBasis2)
                    strBasisOfDiagnosis = Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportFinalOutcomeClinicalFieldLabel);

                if ((bool)HumanDiseaseReportDeduplicationService.blnEpiDiagBasis2)
                {
                    if (string.IsNullOrEmpty(strBasisOfDiagnosis))
                        strBasisOfDiagnosis = Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportFinalOutcomeEpidemiologicalLinksFieldLabel);
                    else
                        strBasisOfDiagnosis += "," + Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportFinalOutcomeEpidemiologicalLinksFieldLabel);
                }

                if ((bool)HumanDiseaseReportDeduplicationService.blnLabDiagBasis2)
                {
                    if (string.IsNullOrEmpty(strBasisOfDiagnosis))
                        strBasisOfDiagnosis = Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportFinalOutcomeLaboratoryTestsFieldLabel);
                    else
                        strBasisOfDiagnosis += "," + Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportFinalOutcomeLaboratoryTestsFieldLabel);
                }
                record2.strClinicalDiagnosis = strBasisOfDiagnosis;

                List<KeyValuePair<string, string>> kvInfo = new List<KeyValuePair<string, string>>();
                List<KeyValuePair<string, string>> kvInfo2 = new List<KeyValuePair<string, string>>();

                Type type = record.GetType();
                PropertyInfo[] props = type.GetProperties();

                Type type2 = record2.GetType();
                PropertyInfo[] props2 = type2.GetProperties();

                string value = string.Empty;

                List<Field> itemListSummary = new List<Field>();
                List<Field> itemListSummary2 = new List<Field>();

                List<Field> itemList = new List<Field>();
                List<Field> itemList2 = new List<Field>();

                List<Field> itemListSymptoms = new List<Field>();
                List<Field> itemListSymptoms2 = new List<Field>();

                List<Field> itemListFacilityDetails = new List<Field>();
                List<Field> itemListFacilityDetails2 = new List<Field>();

                List<Field> itemListAntibioticHistory = new List<Field>();
                List<Field> itemListAntibioticHistory2 = new List<Field>();

                List<Field> itemListVaccineHistory = new List<Field>();
                List<Field> itemListVaccineHistory2 = new List<Field>();

                List<Field> itemListSamples= new List<Field>();
                List<Field> itemListSamples2 = new List<Field>();

                List<Field> itemListTest = new List<Field>();
                List<Field> itemListTest2 = new List<Field>();

                List<Field> itemListCaseInvestigationDetails = new List<Field>();
                List<Field> itemListCaseInvestigationDetails2 = new List<Field>();

                List<Field> itemListRiskFactors = new List<Field>();
                List<Field> itemListRiskFactors2 = new List<Field>();

                List<Field> itemListContactsList = new List<Field>();
                List<Field> itemListContactsList2 = new List<Field>();

                List<Field> itemListFinalOutcome = new List<Field>();
                List<Field> itemListFinalOutcome2 = new List<Field>();

                List<Field> itemListClinicalNotes = new List<Field>();
                List<Field> itemListClinicalNotes2 = new List<Field>();


                for (int index = 0; index <= props.Count() - 1; index++)
                {
                    if (IsInTabSummary(props[index].Name) == true)
                    {
                        FillTabList(props[index].Name, props[index].GetValue(record) == null ? null : props[index].GetValue(record).ToString(), props2[index].Name, props2[index].GetValue(record2) == null ? null : props2[index].GetValue(record2).ToString(), ref itemListSummary, ref itemListSummary2, ref keyDict0, ref labelDict0);
                    }
                    if (IsInTabNotification(props[index].Name) == true)
                    {
                        FillTabList(props[index].Name, props[index].GetValue(record) == null ? null : props[index].GetValue(record).ToString(), props2[index].Name, props2[index].GetValue(record2) == null ? null : props2[index].GetValue(record2).ToString(), ref itemList, ref itemList2, ref keyDict, ref labelDict);
                    }
                    if (IsInTabSymptoms(props[index].Name) == true)
                    {
                        FillTabList(props[index].Name, props[index].GetValue(record) == null ? null : props[index].GetValue(record).ToString(), props2[index].Name, props2[index].GetValue(record2) == null ? null : props2[index].GetValue(record2).ToString(), ref itemListSymptoms, ref itemListSymptoms2, ref keyDict2, ref labelDict2);
                    }
                    if (IsInTabClinicalFacilityDetails(props[index].Name) == true)
                    {
                        FillTabList(props[index].Name, props[index].GetValue(record) == null ? null : props[index].GetValue(record).ToString(), props2[index].Name, props2[index].GetValue(record2) == null ? null : props2[index].GetValue(record2).ToString(), ref itemListFacilityDetails, ref itemListFacilityDetails2, ref keyDict3, ref labelDict3);
                    }
                    if (IsInTabAntibioticHistory(props[index].Name) == true)
                    {
                        FillTabList(props[index].Name, props[index].GetValue(record) == null ? null : props[index].GetValue(record).ToString(), props2[index].Name, props2[index].GetValue(record2) == null ? null : props2[index].GetValue(record2).ToString(), ref itemListAntibioticHistory, ref itemListAntibioticHistory2, ref keyDict4, ref labelDict4);
                    }
                    if (IsInTabVaccineHistory(props[index].Name) == true)
                    {
                        FillTabList(props[index].Name, props[index].GetValue(record) == null ? null : props[index].GetValue(record).ToString(), props2[index].Name, props2[index].GetValue(record2) == null ? null : props2[index].GetValue(record2).ToString(), ref itemListVaccineHistory, ref itemListVaccineHistory2, ref keyDict5, ref labelDict5);
                    }
                    if (IsInTabClinicalNotes(props[index].Name) == true)
                    {
                        FillTabList(props[index].Name, props[index].GetValue(record) == null ? null : props[index].GetValue(record).ToString(), props2[index].Name, props2[index].GetValue(record2) == null ? null : props2[index].GetValue(record2).ToString(), ref itemListClinicalNotes, ref itemListClinicalNotes2, ref keyDict12, ref labelDict12);
                    }
                    if (IsInTabSamples(props[index].Name) == true)
                    {
                        FillTabList(props[index].Name, props[index].GetValue(record) == null ? null : props[index].GetValue(record).ToString(), props2[index].Name, props2[index].GetValue(record2) == null ? null : props2[index].GetValue(record2).ToString(), ref itemListSamples, ref itemListSamples2, ref keyDict6, ref labelDict6);
                    }
                    if (IsInTabTest(props[index].Name) == true)
                    {
                        FillTabList(props[index].Name, props[index].GetValue(record) == null ? null : props[index].GetValue(record).ToString(), props2[index].Name, props2[index].GetValue(record2) == null ? null : props2[index].GetValue(record2).ToString(), ref itemListTest, ref itemListTest2, ref keyDict7, ref labelDict7);
                    }
                    if (IsInTabCaseInvestigationDetails(props[index].Name) == true)
                    {
                        FillTabList(props[index].Name, props[index].GetValue(record) == null ? null : props[index].GetValue(record).ToString(), props2[index].Name, props2[index].GetValue(record2) == null ? null : props2[index].GetValue(record2).ToString(), ref itemListCaseInvestigationDetails, ref itemListCaseInvestigationDetails2, ref keyDict8, ref labelDict8);
                    }
                    if (IsInTabRiskFactors(props[index].Name) == true)
                    {
                        FillTabList(props[index].Name, props[index].GetValue(record) == null ? null : props[index].GetValue(record).ToString(), props2[index].Name, props2[index].GetValue(record2) == null ? null : props2[index].GetValue(record2).ToString(), ref itemListRiskFactors, ref itemListRiskFactors2, ref keyDict9, ref labelDict9);
                    }
                    //if (IsInTabContacts(props[index].Name) == true)
                    //{
                    //    FillTabList(props[index].Name, props[index].GetValue(record) == null ? null : props[index].GetValue(record).ToString(), props2[index].Name, props2[index].GetValue(record2) == null ? null : props2[index].GetValue(record2).ToString(), ref itemListContactsList, ref itemListContactsList2, ref keyDict10, ref labelDict10);
                    //}
                    if (IsInTabFinalOutcome(props[index].Name) == true)
                    {
                        FillTabList(props[index].Name, props[index].GetValue(record) == null ? null : props[index].GetValue(record).ToString(), props2[index].Name, props2[index].GetValue(record2) == null ? null : props2[index].GetValue(record2).ToString(), ref itemListFinalOutcome, ref itemListFinalOutcome2, ref keyDict11, ref labelDict11);
                    }

                }

                //Bind Tab Disease Report Summary
                //HumanDiseaseReportDeduplicationService.SummaryList0 = itemListSummary.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));
                //HumanDiseaseReportDeduplicationService.SummaryList02 = itemListSummary2.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));

                HumanDiseaseReportDeduplicationService.SummaryList = itemListSummary.OrderBy(s => s.Index).ToList();
                HumanDiseaseReportDeduplicationService.SummaryList2 = itemListSummary2.OrderBy(s => s.Index).ToList();

                foreach (Field item in HumanDiseaseReportDeduplicationService.SummaryList)
                {
                    if (item.Checked == true)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                        HumanDiseaseReportDeduplicationService.SummaryList2[item.Index].Checked = true;
                        HumanDiseaseReportDeduplicationService.SummaryList2[item.Index].Disabled = true;
                    }

                    //All fields in Summary except Disease, ReportStatus, and ReportType are non-editable fields
                    if (item.Key != DiseasereportDeduplicationSummaryConstants.Disease
                        && item.Key != DiseasereportDeduplicationSummaryConstants.ReportStatus
                        && item.Key != DiseasereportDeduplicationSummaryConstants.ReportType)
                    {
                        item.Disabled = true;
                        HumanDiseaseReportDeduplicationService.SummaryList2[item.Index].Disabled = true;
                    }
                }

                //HumanDiseaseReportDeduplicationService.SummaryValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SummaryList.Where(s => s.Checked == true).Select(s => s.Index);
                //HumanDiseaseReportDeduplicationService.SummaryValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SummaryList2.Where(s => s.Checked == true).Select(s => s.Index);
                HumanDiseaseReportDeduplicationService.SummaryList0 = HumanDiseaseReportDeduplicationService.SummaryList.Select(a => a.Copy()).ToList();
                HumanDiseaseReportDeduplicationService.SummaryList02 = HumanDiseaseReportDeduplicationService.SummaryList2.Select(a => a.Copy()).ToList();

                //Bind Tab Notification
                //HumanDiseaseReportDeduplicationService.NotificationList0 = itemList.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));
                //HumanDiseaseReportDeduplicationService.NotificationList02 = itemList2.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));

                HumanDiseaseReportDeduplicationService.NotificationList = itemList.OrderBy(s => s.Index).ToList();
                HumanDiseaseReportDeduplicationService.NotificationList2 = itemList2.OrderBy(s => s.Index).ToList();

                foreach (Field item in HumanDiseaseReportDeduplicationService.NotificationList)
                {
                    if (item.Checked == true)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                        HumanDiseaseReportDeduplicationService.NotificationList2[item.Index].Checked = true;
                        HumanDiseaseReportDeduplicationService.NotificationList2[item.Index].Disabled = true;
                    }

                    //Notification Sent by Name and Notification Received by Name are non-editable fields
                    if (item.Key == DiseasereportDeduplicationNotificationConstants.SentByPerson
                        || item.Key == DiseasereportDeduplicationNotificationConstants.ReceivedByPerson)
                    {
                        item.Disabled = true;
                        HumanDiseaseReportDeduplicationService.NotificationList2[item.Index].Disabled = true;
                    }
                }

                HumanDiseaseReportDeduplicationService.NotificationValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList.Where(s => s.Checked == true).Select(s => s.Index);
                HumanDiseaseReportDeduplicationService.NotificationValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList2.Where(s => s.Checked == true).Select(s => s.Index);
                HumanDiseaseReportDeduplicationService.NotificationList0 = HumanDiseaseReportDeduplicationService.NotificationList.Select(a => a.Copy()).ToList();
                HumanDiseaseReportDeduplicationService.NotificationList02 = HumanDiseaseReportDeduplicationService.NotificationList2.Select(a => a.Copy()).ToList();


                //Bind Tab Symptoms
                //HumanDiseaseReportDeduplicationService.SymptomsList0 = itemListSymptoms.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));
                //HumanDiseaseReportDeduplicationService.SymptomsList02 = itemListSymptoms2.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));

                HumanDiseaseReportDeduplicationService.SymptomsList = itemListSymptoms.OrderBy(s => s.Index).ToList();
                HumanDiseaseReportDeduplicationService.SymptomsList2 = itemListSymptoms2.OrderBy(s => s.Index).ToList();

                foreach (Field item in HumanDiseaseReportDeduplicationService.SymptomsList)
                {
                    if (item.Checked == true)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                        HumanDiseaseReportDeduplicationService.SymptomsList2[item.Index].Checked = true;
                        HumanDiseaseReportDeduplicationService.SymptomsList2[item.Index].Disabled = true;
                    }

                    // If two HDR records have different diseases - then the survivor record will dictate which FFD data are to be retained.
                    // Need to lock FFD data to a "survivor" HDR record and disable the corresponding checkbox
                    if (record.idfsFinalDiagnosis != record2.idfsFinalDiagnosis && item.Key == DiseasereportDeduplicationSymptomsConstants.idfCSObservation)
                    {
                        item.Disabled = true;
                        HumanDiseaseReportDeduplicationService.SymptomsList2[item.Index].Disabled = true;
                    }
                }

                HumanDiseaseReportDeduplicationService.SymptomsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SymptomsList.Where(s => s.Checked == true).Select(s => s.Index);
                HumanDiseaseReportDeduplicationService.SymptomsValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SymptomsList2.Where(s => s.Checked == true).Select(s => s.Index);
                HumanDiseaseReportDeduplicationService.SymptomsList0 = HumanDiseaseReportDeduplicationService.SymptomsList.Select(a => a.Copy()).ToList();
                HumanDiseaseReportDeduplicationService.SymptomsList02 = HumanDiseaseReportDeduplicationService.SymptomsList2.Select(a => a.Copy()).ToList();
               
                HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest = new FlexFormQuestionnaireGetRequestModel();
                HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest.idfsFormType = (long?)FlexFormType.HumanDiseaseClinicalSymptoms;
                HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest.idfsDiagnosis = record.idfsFinalDiagnosis;
                HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest.idfObservation = record.idfCSObservation;
                HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest.LangID = GetCurrentLanguage();
              
                HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest2 = new FlexFormQuestionnaireGetRequestModel();
                HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest2.idfsFormType = (long?)FlexFormType.HumanDiseaseClinicalSymptoms;
                HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest2.idfsDiagnosis = record2.idfsFinalDiagnosis;
                HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest2.idfObservation = record2.idfCSObservation;
                HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest2.LangID = GetCurrentLanguage();


                //Bind Tab Facility Details
                //HumanDiseaseReportDeduplicationService.FacilityDetailsList0 = itemListFacilityDetails.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));
                //HumanDiseaseReportDeduplicationService.FacilityDetailsList02 = itemListFacilityDetails2.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));

                HumanDiseaseReportDeduplicationService.FacilityDetailsList = itemListFacilityDetails.OrderBy(s => s.Index).ToList();
                HumanDiseaseReportDeduplicationService.FacilityDetailsList2 = itemListFacilityDetails2.OrderBy(s => s.Index).ToList();

                foreach (Field item in HumanDiseaseReportDeduplicationService.FacilityDetailsList)
                {
                    if (item.Checked == true)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                        HumanDiseaseReportDeduplicationService.FacilityDetailsList2[item.Index].Checked = true;
                        HumanDiseaseReportDeduplicationService.FacilityDetailsList2[item.Index].Disabled = true;
                    }
                }

                HumanDiseaseReportDeduplicationService.FacilityDetailsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.FacilityDetailsList.Where(s => s.Checked == true).Select(s => s.Index);
                HumanDiseaseReportDeduplicationService.FacilityDetailsValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.FacilityDetailsList2.Where(s => s.Checked == true).Select(s => s.Index);
                HumanDiseaseReportDeduplicationService.FacilityDetailsList0 = HumanDiseaseReportDeduplicationService.FacilityDetailsList.Select(a => a.Copy()).ToList();
                HumanDiseaseReportDeduplicationService.FacilityDetailsList02 = HumanDiseaseReportDeduplicationService.FacilityDetailsList2.Select(a => a.Copy()).ToList();

                //Bind Tab Antibiotic History

                HumanAntiviralTherapiesAndVaccinationRequestModel antibioticVaccineRequest = new HumanAntiviralTherapiesAndVaccinationRequestModel();
                antibioticVaccineRequest.idfHumanCase = record.idfHumanCase;
                antibioticVaccineRequest.LangID = GetCurrentLanguage();

                var antiViralTherapiesReponse = await HumanDiseaseReportClient.GetAntiviralTherapisListAsync(antibioticVaccineRequest);
                var vaccinationResponse = await HumanDiseaseReportClient.GetVaccinationListAsync(antibioticVaccineRequest);

                HumanDiseaseReportDeduplicationService.Antibiotics = antiViralTherapiesReponse;
                HumanDiseaseReportDeduplicationService.Vaccinations = vaccinationResponse;
                //HumanDiseaseReportDeduplicationService.antibioticsHistory = antiViralTherapiesReponse;
                //HumanDiseaseReportDeduplicationService.vaccinationHistory = vaccinationResponse;

                HumanAntiviralTherapiesAndVaccinationRequestModel antibioticVaccineRequest2 = new HumanAntiviralTherapiesAndVaccinationRequestModel();
                antibioticVaccineRequest2.idfHumanCase =record2.idfHumanCase;
                antibioticVaccineRequest2.LangID = GetCurrentLanguage();

                var antiViralTherapiesReponse2 = await HumanDiseaseReportClient.GetAntiviralTherapisListAsync(antibioticVaccineRequest2);
                var vaccinationResponse2 = await HumanDiseaseReportClient.GetVaccinationListAsync(antibioticVaccineRequest2);

                HumanDiseaseReportDeduplicationService.Antibiotics2 = antiViralTherapiesReponse2;
                HumanDiseaseReportDeduplicationService.Vaccinations2 = vaccinationResponse2;
                //HumanDiseaseReportDeduplicationService.antibioticsHistory2 = antiViralTherapiesReponse2;
                //HumanDiseaseReportDeduplicationService.vaccinationHistory2 = vaccinationResponse2;

                //HumanDiseaseReportDeduplicationService.AntibioticHistoryList0 = itemListAntibioticHistory.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));
                //HumanDiseaseReportDeduplicationService.AntibioticHistoryList02 = itemListAntibioticHistory2.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));

                HumanDiseaseReportDeduplicationService.AntibioticHistoryList = itemListAntibioticHistory.OrderBy(s => s.Index).ToList();
                HumanDiseaseReportDeduplicationService.AntibioticHistoryList2 = itemListAntibioticHistory2.OrderBy(s => s.Index).ToList();

                foreach (Field item in HumanDiseaseReportDeduplicationService.AntibioticHistoryList)
                {
                    if (item.Checked == true)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                        HumanDiseaseReportDeduplicationService.AntibioticHistoryList2[item.Index].Checked = true;
                        HumanDiseaseReportDeduplicationService.AntibioticHistoryList2[item.Index].Disabled = true;
                    }
                }

                HumanDiseaseReportDeduplicationService.AntibioticHistoryValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticHistoryList.Where(s => s.Checked == true).Select(s => s.Index);
                HumanDiseaseReportDeduplicationService.AntibioticHistoryValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticHistoryList2.Where(s => s.Checked == true).Select(s => s.Index);
                HumanDiseaseReportDeduplicationService.AntibioticHistoryList0 = HumanDiseaseReportDeduplicationService.AntibioticHistoryList.Select(a => a.Copy()).ToList();
                HumanDiseaseReportDeduplicationService.AntibioticHistoryList02 = HumanDiseaseReportDeduplicationService.AntibioticHistoryList2.Select(a => a.Copy()).ToList();

               

                //Bind Tab Vaccine History
                //HumanDiseaseReportDeduplicationService.VaccineHistoryList0 = itemListVaccineHistory.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));
                //HumanDiseaseReportDeduplicationService.VaccineHistoryList02 = itemListVaccineHistory2.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));

                HumanDiseaseReportDeduplicationService.VaccineHistoryList = itemListVaccineHistory.OrderBy(s => s.Index).ToList();
                HumanDiseaseReportDeduplicationService.VaccineHistoryList2 = itemListVaccineHistory2.OrderBy(s => s.Index).ToList();

                foreach (Field item in HumanDiseaseReportDeduplicationService.VaccineHistoryList)
                {
                    if (item.Checked == true)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                        HumanDiseaseReportDeduplicationService.VaccineHistoryList2[item.Index].Checked = true;
                        HumanDiseaseReportDeduplicationService.VaccineHistoryList2[item.Index].Disabled = true;
                    }
                }

                HumanDiseaseReportDeduplicationService.VaccineHistoryValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.VaccineHistoryList.Where(s => s.Checked == true).Select(s => s.Index);
                HumanDiseaseReportDeduplicationService.VaccineHistoryValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.VaccineHistoryList2.Where(s => s.Checked == true).Select(s => s.Index);
                HumanDiseaseReportDeduplicationService.VaccineHistoryList0 = HumanDiseaseReportDeduplicationService.VaccineHistoryList.Select(a => a.Copy()).ToList();
                HumanDiseaseReportDeduplicationService.VaccineHistoryList02 = HumanDiseaseReportDeduplicationService.VaccineHistoryList2.Select(a => a.Copy()).ToList();

                //Bind Tab ClinicalNotes (Additional Information Comments)
                HumanDiseaseReportDeduplicationService.ClinicalNotesList = itemListClinicalNotes.OrderBy(s => s.Index).ToList();
                HumanDiseaseReportDeduplicationService.ClinicalNotesList2 = itemListClinicalNotes2.OrderBy(s => s.Index).ToList();

                foreach (Field item in HumanDiseaseReportDeduplicationService.ClinicalNotesList)
                {
                    if (item.Checked == true)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                        HumanDiseaseReportDeduplicationService.ClinicalNotesList[item.Index].Checked = true;
                        HumanDiseaseReportDeduplicationService.ClinicalNotesList2[item.Index].Disabled = true;
                    }
                }

                HumanDiseaseReportDeduplicationService.ClinicalNotesList0 = HumanDiseaseReportDeduplicationService.ClinicalNotesList.Select(a => a.Copy()).ToList();
                HumanDiseaseReportDeduplicationService.ClinicalNotesList02 = HumanDiseaseReportDeduplicationService.ClinicalNotesList2.Select(a => a.Copy()).ToList();

                //Bind Tab Samples


                var samplesrequest = new HumanDiseaseReportSamplesRequestModel()
                {
                    idfHumanCase = record.idfHumanCase,
                    LangID = GetCurrentLanguage()
                };
                var samplesList = await HumanDiseaseReportClient.GetHumanDiseaseReportSamplesListAsync(samplesrequest);
                List<DiseaseReportSamplePageSampleDetailViewModel> samplesDetailList = new List<DiseaseReportSamplePageSampleDetailViewModel>();
                int i = 0;
                HumanDiseaseReportDeduplicationService.Samples = new List<DiseaseReportSamplePageSampleDetailViewModel>();
                foreach (var item in samplesList)
                {
                    //map the incoming human samples list to the generic list so we can reuse samples component
                    HumanDiseaseReportDeduplicationService.Samples.Add(new DiseaseReportSamplePageSampleDetailViewModel()
                    {
                        RowID = i + 1,
                        NewRecordId = i + 1,
                        AccessionDate = item.datAccession,
                        idfMaterial = item.idfMaterial,
                        AdditionalTestNotes = item.strNote,
                        CollectedByOfficer = item.strFieldCollectedByPerson,
                        CollectedByOfficerID = item.idfFieldCollectedByPerson,
                        CollectedByOrganization = item.strFieldCollectedByOffice,
                        CollectedByOrganizationID = item.idfFieldCollectedByOffice,
                        CollectionDate = item.datFieldCollectionDate,
                        strBarcode = item.strBarcode, //TODO - not available from stored proc
                        LocalSampleId = item.strFieldBarcode, //TODO - not available from stored proc
                        SampleConditionRecieved = item.strCondition,
                        SampleKey = item.idfMaterial.GetValueOrDefault(),
                        SampleType = item.strSampleTypeName,
                        SampleTypeID = item.idfsSampleType,
                        SentDate = item.datFieldSentDate,
                        SentToOrganization = item.strSendToOffice,
                        SentToOrganizationID = item.idfSendToOffice,
                        // SymptomsOnsetDate = _.datOnSetDate,
                        blnAccessioned = item.blnAccessioned,
                        sampleGuid = item.sampleGuid,
                        idfsSiteSentToOrg = item.idfsSite,
                        SampleStatus = item.SampleStatusTypeName,
                        LabSampleID = item.strBarcode,
                        FunctionalAreaName = item.FunctionalAreaName,
                        FunctionalAreaID = item.FunctionalAreaID,
                        strNote = item.strNote,
                        idfHumanCase = record.idfHumanCase,
                        idfDisease=record.idfsFinalDiagnosis

                    });
                    i++;
                }

                var samplesrequest2 = new HumanDiseaseReportSamplesRequestModel()
                {
                    idfHumanCase = record2.idfHumanCase,
                    LangID = GetCurrentLanguage()
                };

                var samplesList2 = await HumanDiseaseReportClient.GetHumanDiseaseReportSamplesListAsync(samplesrequest2);
                List<DiseaseReportSamplePageSampleDetailViewModel> samplesDetailList2 = new List<DiseaseReportSamplePageSampleDetailViewModel>();
                i = 0;
                HumanDiseaseReportDeduplicationService.Samples2 = new List<DiseaseReportSamplePageSampleDetailViewModel>();
                foreach (var item in samplesList2)
                {
                    //map the incoming human samples list to the generic list so we can reuse samples component
                    HumanDiseaseReportDeduplicationService.Samples2.Add(new DiseaseReportSamplePageSampleDetailViewModel()
                    {
                        RowID = i + 1,
                        AccessionDate = item.datAccession,
                        idfMaterial = item.idfMaterial,
                        AdditionalTestNotes = item.strNote,
                        CollectedByOfficer = item.strFieldCollectedByPerson,
                        CollectedByOfficerID = item.idfFieldCollectedByPerson,
                        CollectedByOrganization = item.strFieldCollectedByOffice,
                        CollectedByOrganizationID = item.idfFieldCollectedByOffice,
                        CollectionDate = item.datFieldCollectionDate,
                        strBarcode = item.strBarcode, //TODO - not available from stored proc
                        LocalSampleId = item.strFieldBarcode, //TODO - not available from stored proc
                        SampleConditionRecieved = item.strCondition,
                        SampleKey = item.idfMaterial.GetValueOrDefault(),
                        SampleType = item.strSampleTypeName,
                        SampleTypeID = item.idfsSampleType,
                        SentDate = item.datFieldSentDate,
                        SentToOrganization = item.strSendToOffice,
                        SentToOrganizationID = item.idfSendToOffice,
                        // SymptomsOnsetDate = _.datOnSetDate,
                        blnAccessioned = item.blnAccessioned,
                        sampleGuid = item.sampleGuid,
                        idfsSiteSentToOrg = item.idfsSite,
                        SampleStatus = item.SampleStatusTypeName,
                        LabSampleID = item.strBarcode,
                        FunctionalAreaName = item.FunctionalAreaName,
                        FunctionalAreaID = item.FunctionalAreaID,
                        strNote = item.strNote,
                        idfHumanCase = record2.idfHumanCase,
                        idfDisease=record2.idfsFinalDiagnosis
                    });
                    i++;
                }
                //HumanDiseaseReportDeduplicationService.SamplesList0 = itemListSamples.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));
                //HumanDiseaseReportDeduplicationService.SamplesList02 = itemListSamples2.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));

                HumanDiseaseReportDeduplicationService.SamplesList = itemListSamples.OrderBy(s => s.Index).ToList();
                HumanDiseaseReportDeduplicationService.SamplesList2 = itemListSamples2.OrderBy(s => s.Index).ToList();

                foreach (Field item in HumanDiseaseReportDeduplicationService.SamplesList)
                {
                    if (item.Checked == true)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                        HumanDiseaseReportDeduplicationService.SamplesList2[item.Index].Checked = true;
                        HumanDiseaseReportDeduplicationService.SamplesList2[item.Index].Disabled = true;
                    }
                }

                HumanDiseaseReportDeduplicationService.SamplesValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SamplesList.Where(s => s.Checked == true).Select(s => s.Index);
                HumanDiseaseReportDeduplicationService.SamplesValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SamplesList2.Where(s => s.Checked == true).Select(s => s.Index);
                HumanDiseaseReportDeduplicationService.SamplesList0 = HumanDiseaseReportDeduplicationService.SamplesList.Select(a => a.Copy()).ToList();
                HumanDiseaseReportDeduplicationService.SamplesList02 = HumanDiseaseReportDeduplicationService.SamplesList2.Select(a => a.Copy()).ToList();

                // Bind Tab Test

                var testRequest = new HumanTestListRequestModel()
                {
                    idfHumanCase = record.idfHumanCase,
                    LangID = GetCurrentLanguage(),
                    SearchDiagnosis = null
                };
                HumanDiseaseReportDeduplicationService.Tests = await HumanDiseaseReportClient.GetHumanDiseaseReportTestListAsync(testRequest);
                //HumanDiseaseReportDeduplicationService.testsDetails = await HumanDiseaseReportClient.GetHumanDiseaseReportTestListAsync(testRequest);

                var testRequest2 = new HumanTestListRequestModel()
                {
                    idfHumanCase = record2.idfHumanCase,
                    LangID = GetCurrentLanguage(),
                    SearchDiagnosis = null
                };
                HumanDiseaseReportDeduplicationService.Tests2 = await HumanDiseaseReportClient.GetHumanDiseaseReportTestListAsync(testRequest2);
                //HumanDiseaseReportDeduplicationService.testsDetails2 = await HumanDiseaseReportClient.GetHumanDiseaseReportTestListAsync(testRequest2);



                //HumanDiseaseReportDeduplicationService.TestsList0 = itemListTest.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));
                //HumanDiseaseReportDeduplicationService.TestsList02 = itemListTest2.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));

                HumanDiseaseReportDeduplicationService.TestsList = itemListTest.OrderBy(s => s.Index).ToList();
                HumanDiseaseReportDeduplicationService.TestsList2 = itemListTest2.OrderBy(s => s.Index).ToList();

                foreach (Field item in HumanDiseaseReportDeduplicationService.TestsList)
                {
                    if (item.Checked == true)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                        HumanDiseaseReportDeduplicationService.TestsList[item.Index].Checked = true;
                        HumanDiseaseReportDeduplicationService.TestsList2[item.Index].Disabled = true;
                    }
                }

                HumanDiseaseReportDeduplicationService.TestsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.TestsList.Where(s => s.Checked == true).Select(s => s.Index);
                HumanDiseaseReportDeduplicationService.TestsValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.TestsList2.Where(s => s.Checked == true).Select(s => s.Index);
                HumanDiseaseReportDeduplicationService.TestsList0 = HumanDiseaseReportDeduplicationService.TestsList.Select(a => a.Copy()).ToList();
                HumanDiseaseReportDeduplicationService.TestsList02 = HumanDiseaseReportDeduplicationService.TestsList2.Select(a => a.Copy()).ToList();


                HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList0 = itemListCaseInvestigationDetails.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));
                HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList02 = itemListCaseInvestigationDetails2.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));

                HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList = itemListCaseInvestigationDetails.OrderBy(s => s.Index).ToList();
                HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2 = itemListCaseInvestigationDetails2.OrderBy(s => s.Index).ToList();

                foreach (Field item in HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList)
                {
                    if (item.Checked == true)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                        HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2[item.Index].Checked = true;
                        HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2[item.Index].Disabled = true;
                    }

                    //Fields after Location of Exposure is known are in a group and are non-editable fields
                    if (item.Index > YNExposureLocationKnown)
                    {
                        item.Disabled = true;
                        HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2[item.Index].Disabled = true;
                    }
                }

                HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList.Where(s => s.Checked == true).Select(s => s.Index);
                HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2.Where(s => s.Checked == true).Select(s => s.Index);
                HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList0 = HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList.Select(a => a.Copy()).ToList();
                HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList02 = HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2.Select(a => a.Copy()).ToList();



                //Bind Tab Risk Factors
                //HumanDiseaseReportDeduplicationService.RiskFactorsList0 = itemListRiskFactors.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));
                //HumanDiseaseReportDeduplicationService.RiskFactorsList02 = itemListRiskFactors2.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));

                HumanDiseaseReportDeduplicationService.RiskFactorsList = itemListRiskFactors.OrderBy(s => s.Index).ToList();
                HumanDiseaseReportDeduplicationService.RiskFactorsList2 = itemListRiskFactors2.OrderBy(s => s.Index).ToList();

                foreach (Field item in HumanDiseaseReportDeduplicationService.RiskFactorsList)
                {
                    if (item.Checked == true)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                        HumanDiseaseReportDeduplicationService.RiskFactorsList2[item.Index].Checked = true;
                        HumanDiseaseReportDeduplicationService.RiskFactorsList2[item.Index].Disabled = true;
                    }

                    // If two HDR records have different diseases - then the survivor record will dictate which FFD data are to be retained.
                    // Need to lock FFD data to a "survivor" HDR record
                    if (record.idfsFinalDiagnosis != record2.idfsFinalDiagnosis && item.Key == DiseasereportDeduplicationRiskFactorsConstants.idfEpiObservation)
                    {
                        item.Disabled = true;
                        HumanDiseaseReportDeduplicationService.RiskFactorsList2[item.Index].Disabled = true;
                    }
                }

                HumanDiseaseReportDeduplicationService.RiskFactorsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.RiskFactorsList.Where(s => s.Checked == true).Select(s => s.Index);
                HumanDiseaseReportDeduplicationService.RiskFactorsValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.RiskFactorsList2.Where(s => s.Checked == true).Select(s => s.Index);
                HumanDiseaseReportDeduplicationService.RiskFactorsList0 = HumanDiseaseReportDeduplicationService.RiskFactorsList.Select(a => a.Copy()).ToList();
                HumanDiseaseReportDeduplicationService.RiskFactorsList02 = HumanDiseaseReportDeduplicationService.RiskFactorsList2.Select(a => a.Copy()).ToList();

                HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest = new FlexFormQuestionnaireGetRequestModel();
                HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest.idfsFormType = (long?)FlexFormType.HumanDiseaseQuestionnaire;
                HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest.idfsDiagnosis = record.idfsFinalDiagnosis;
                HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest.idfObservation = record.idfEpiObservation;
                HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest.LangID = GetCurrentLanguage();

                HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest2 = new FlexFormQuestionnaireGetRequestModel();
                HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest2.idfsFormType = (long?)FlexFormType.HumanDiseaseQuestionnaire;
                HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest2.idfsDiagnosis = record2.idfsFinalDiagnosis;
                HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest2.idfObservation = record2.idfEpiObservation;
                HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest2.LangID = GetCurrentLanguage();


                //Bind tab Contacts


                HumanDiseaseContactListRequestModel contactsrequest = new HumanDiseaseContactListRequestModel();
                contactsrequest.idfHumanCase = record.idfHumanCase;
                contactsrequest.LangId = GetCurrentLanguage();
                //HumanDiseaseReportDeduplicationService.contactsDetails = await HumanDiseaseReportClient.GetHumanDiseaseContactListAsync(contactsrequest);
                HumanDiseaseReportDeduplicationService.Contacts = await HumanDiseaseReportClient.GetHumanDiseaseContactListAsync(contactsrequest);

                HumanDiseaseContactListRequestModel contactsrequest2 = new HumanDiseaseContactListRequestModel();
                contactsrequest2.idfHumanCase = record2.idfHumanCase;
                contactsrequest2.LangId = GetCurrentLanguage();
                //HumanDiseaseReportDeduplicationService.contactsDetails2 = await HumanDiseaseReportClient.GetHumanDiseaseContactListAsync(contactsrequest2);
                HumanDiseaseReportDeduplicationService.Contacts2 = await HumanDiseaseReportClient.GetHumanDiseaseContactListAsync(contactsrequest2);


                //HumanDiseaseReportDeduplicationService.ContactsList0 = itemListContactsList.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));
                //HumanDiseaseReportDeduplicationService.ContactsList02 = itemListContactsList2.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));

                //HumanDiseaseReportDeduplicationService.ContactsList = itemListContactsList.OrderBy(s => s.Index).ToList();
                //HumanDiseaseReportDeduplicationService.ContactsList2 = itemListContactsList2.OrderBy(s => s.Index).ToList();

                //foreach (Field item in HumanDiseaseReportDeduplicationService.ContactsList)
                //{
                //    if (item.Checked == true)
                //    {
                //        item.Checked = true;
                //        item.Disabled = true;
                //        HumanDiseaseReportDeduplicationService.ContactsList[item.Index].Checked = true;
                //        HumanDiseaseReportDeduplicationService.ContactsList2[item.Index].Disabled = true;
                //    }
                //}

                //HumanDiseaseReportDeduplicationService.ContactsValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.ContactsList.Where(s => s.Checked == true).Select(s => s.Index);
                //HumanDiseaseReportDeduplicationService.ContactsValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.ContactsList2.Where(s => s.Checked == true).Select(s => s.Index);
                //HumanDiseaseReportDeduplicationService.ContactsList0 = HumanDiseaseReportDeduplicationService.ContactsList.Select(a => a.Copy()).ToList();
                //HumanDiseaseReportDeduplicationService.ContactsList02 = HumanDiseaseReportDeduplicationService.ContactsList2.Select(a => a.Copy()).ToList();

                //Bind tab Final Outcome
                //HumanDiseaseReportDeduplicationService.FinalOutcomeList0 = itemListFinalOutcome.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));
                //HumanDiseaseReportDeduplicationService.FinalOutcomeList02 = itemListFinalOutcome2.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));

                HumanDiseaseReportDeduplicationService.FinalOutcomeList = itemListFinalOutcome.OrderBy(s => s.Index).ToList();
                HumanDiseaseReportDeduplicationService.FinalOutcomeList2 = itemListFinalOutcome2.OrderBy(s => s.Index).ToList();

                foreach (Field item in HumanDiseaseReportDeduplicationService.FinalOutcomeList)
                {
                    if (item.Checked == true)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                        HumanDiseaseReportDeduplicationService.FinalOutcomeList2[item.Index].Checked = true;
                        HumanDiseaseReportDeduplicationService.FinalOutcomeList2[item.Index].Disabled = true;
                    }
                }

                HumanDiseaseReportDeduplicationService.FinalOutcomeValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.FinalOutcomeList.Where(s => s.Checked == true).Select(s => s.Index);
                HumanDiseaseReportDeduplicationService.FinalOutcomeValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.FinalOutcomeList2.Where(s => s.Checked == true).Select(s => s.Index);
                HumanDiseaseReportDeduplicationService.FinalOutcomeList0 = HumanDiseaseReportDeduplicationService.FinalOutcomeList.Select(a => a.Copy()).ToList();
                HumanDiseaseReportDeduplicationService.FinalOutcomeList02 = HumanDiseaseReportDeduplicationService.FinalOutcomeList2.Select(a => a.Copy()).ToList();


            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);

            }
        }

        private void FillTabList(string key, string value, string key2, string value2, ref List<Field> list, ref List<Field> list2, ref Dictionary<string, int> keyDict, ref Dictionary<int, string> labelDict)
        {
            try
            {
                string temp = string.Empty;
                string temp2 = string.Empty;
                Field item = new Field();
                Field item2 = new Field();

                if (keyDict.ContainsKey(key))
                {
                    item.Index = keyDict[key];
                    item.Key = key;
                    item.Value = value;
                    item2.Index = keyDict[key];
                    item2.Key = key;
                    item2.Value = value2;

                    if (value == value2)
                    {
                        if (value != null && value2 != null)
                        {
                            temp = value;
                            temp2 = value2;
                        }
                        else
                        {
                            temp = string.Empty;
                        }

                        //item.Label = "<font style='color:#2C6187;font-size:12px'>" + GetLocalResourceObject(labelDict[item.Index]).ToString + "</font>" + "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + temp + "</font>";
                        //item2.Label = "<font style='color:#2C6187;font-size:12px'>" + GetLocalResourceObject(labelDict[item.Index]).ToString + "</font>" + "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + temp2 + "</font>";
                        //item.Label = "<font style='color:#2C6187;font-size:12px'>" + labelDict[item.Index].ToString() + "</font>" + "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + temp + "</font>";
                        //item.Label = labelDict[item.Index].ToString() + "<br>" + temp;
                       // item.Label = GetLabelResource(labelDict[item.Index].ToString()) + ": " + temp;
                        //item2.Label = "<font style='color:#2C6187;font-size:12px'>" +labelDict[item.Index].ToString() + "</font>" + "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + temp2 + "</font>";
                        //item.Label = labelDict[item.Index].ToString() + "<br>" + temp2;
                       // item2.Label = GetLabelResource(labelDict[item.Index].ToString()) + ": " + temp2;
                        item.Label = GetLabelResource(labelDict[item.Index].ToString());
                        item2.Label = GetLabelResource(labelDict[item.Index].ToString());


                        item.Checked = true;
                        item2.Checked = true;
                        item.Disabled = true;
                        item2.Disabled = true;
                        item.Color = "width:250px;color: #2C6187"; //Blue
                        item2.Color = "width:250px;color: #2C6187";
                    }
                    else
                    {
                        if (value != null)
                        {
                            temp = value;
                        }
                        else
                        {
                            temp = string.Empty;
                        }

                        //item.Label = "<font style='color:#9b1010;font-size:12px'>" + GetLocalResourceObject(labelDict.Item(item.Index)).ToString + "</font>" + "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + temp + "</font>";
                        //item.Label = "<font style='color:#9b1010;font-size:12px'>" + labelDict[item.Index].ToString() + "</font>" + "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + temp + "</font>";
                        //item.Label = labelDict[item.Index].ToString() + "<br>" + temp;
                        item.Label = GetLabelResource(labelDict[item.Index].ToString());
                       // item.Label = GetLabelResource(labelDict[item.Index].ToString()) + ": " + temp;
                        item.Checked = false;
                        item.Disabled = false;
                        item.Color = "width:250px;color: #9b1010"; //Red

                        if (value2 != null)
                        {
                            temp = value2;
                        }
                        else
                        {
                            temp = string.Empty;
                        }

                        //item2.Label = "<font style='color:#9b1010;font-size:12px'>" + GetLocalResourceObject(labelDict.Item(item.Index)).ToString + "</font>" + "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + temp + "</font>";
                        //item2.Label = "<font style='color:#9b1010;font-size:12px'>" + labelDict[item.Index].ToString() + "</font>" + "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + temp + "</font>";
                        //item2.Label = labelDict[item.Index].ToString() +  "<br>" + temp;
                        item2.Label = GetLabelResource(labelDict[item.Index].ToString());
                       // item2.Label = GetLabelResource(labelDict[item.Index].ToString()) + ": " + temp;
                        item2.Checked = false;
                        item2.Disabled = false;
                        item2.Color = "width:250px;color: #9b1010"; //Red
                    }

                    list.Add(item);
                    list2.Add(item2);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }




        #endregion Private Methods

        #region Review
        //protected async Task EditClickAsync(int index)
        //{
        //	showDetails = true;
        //	showReview = false;
        //	switch (index)
        //	{
        //		case 0:
        //			Tab = PersonDeduplicationTabEnum.Information;
        //			OnTabChange(0);
        //			break;
        //		case 1:
        //			Tab = PersonDeduplicationTabEnum.Address;
        //			OnTabChange(1);
        //			break;
        //		case 2:
        //			Tab = PersonDeduplicationTabEnum.Employment;
        //			OnTabChange(2);
        //			break;
        //	}
        //	await InvokeAsync(StateHasChanged);
        //}

        public async Task OnSaveAsync()
        {
            var result = await ShowWarningDialog(MessageResourceKeyConstants.DeduplicationPersonDoyouwanttodeduplicaterecordMessage, null);

            if (result is DialogReturnResult returnResult && returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                await DeduplicateRecordsAsync();
            if (result is DialogReturnResult returnResult2 && returnResult2.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.NoButton))
            {
                //showDetails = true;
                //showReview = false;
                //shouldRender = false;
                //var path = "Administration/Deduplication/PersonDeduplication/Details";
                //var query = $"?humanMasterID={HumanDiseaseReportDeduplicationService.HumanMasterID}&humanMasterID2={HumanDiseaseReportDeduplicationService.HumanMasterID2}";
                //var uri = $"{NavManager.BaseUri}{path}{query}";

                //NavManager.NavigateTo(uri, true);
            }
        }

        private async Task DeduplicateRecordsAsync()
        {
            try
            {
                bool result = await SaveSurvivorRecordAsync();
                if (result == true)
                {
                    //await ReplaceSupersededDiseaseListPersonIDAsync();
                    //await ReplaceSupersededFarmListPersonIDAsync();
                   //await RemoveSupersededRecordAsync();

                    await SaveSuccessMessagedDialog();

                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        public async Task<bool> SaveSurvivorRecordAsync()
        {

            HumanDiseaseReportDedupeRequestModel request = new HumanDiseaseReportDedupeRequestModel();

            HumanDiseaseReportDedupeResponseModel response = new HumanDiseaseReportDedupeResponseModel();

            try
            {
                request.LanguageID = GetCurrentLanguage();
                // var jsonObject = JObject.Parse(data.ToString());
                request.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                request.idfsSite = long.Parse(authenticatedUser.SiteId);
                request.idfHuman = HumanDiseaseReportDeduplicationService.SurvivoridfHuman;
                //request.idfHumanActual = HumanDiseaseReportDeduplicationService.SurvivoridfHumanActual;
                request.idfsYNRelatedToOutbreak = HumanDiseaseReportDeduplicationService.SurvivoridfsYNRelatedToOutbreak;
                //request.idfsCaseProgressStatus = HumanDiseaseReportDeduplicationService.SurvivoridfsCaseProgressStatus;
                //request.DiseaseReportTypeID = HumanDiseaseReportDeduplicationService.SurvivorDiseaseReportTypeID;
                request.SurvivorDiseaseReportID = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                request.SupersededDiseaseReportID = HumanDiseaseReportDeduplicationService.SupersededHumanDiseaseReportID;
                request.strHumanCaseId = HumanDiseaseReportDeduplicationService.SurvivorstrHumanCaseId;
                //request.datCompletionPaperFormDate = HumanDiseaseReportDeduplicationService.SurvivordatCompletionPaperFormDate;
                //request.strLocalIdentifier = HumanDiseaseReportDeduplicationService.SurvivorstrLocalIdentifier;
                request.blnClinicalDiagBasis = HumanDiseaseReportDeduplicationService.SurvivorblnClinicalDiagBasis;
                request.blnLabDiagBasis = HumanDiseaseReportDeduplicationService.SurvivorblnLabDiagBasis;
                request.blnEpiDiagBasis = HumanDiseaseReportDeduplicationService.SurvivorblnEpiDiagBasis;
                //request.strNote = HumanDiseaseReportDeduplicationService.SurvivorstrNote;

                request.AuditUser = authenticatedUser.UserName;
                // Antibiotic Details

                foreach(var item in HumanDiseaseReportDeduplicationService.SurvivorAntibiotics)
                {
                    item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                    item.rowAction = "2";
                }

                var serAntibioticsHistory = JsonConvert.SerializeObject(HumanDiseaseReportDeduplicationService.SurvivorAntibiotics);


                if (serAntibioticsHistory == "[]")
                {
                    request.AntiviralTherapiesParameters = null;
                }
                else
                {
                    request.AntiviralTherapiesParameters = serAntibioticsHistory;
                }


                //Vaccine Details

                foreach (var item in HumanDiseaseReportDeduplicationService.SurvivorVaccinations)
                {
                    item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                    item.rowAction = "2";
                }

                var serVaccineHistory = JsonConvert.SerializeObject(HumanDiseaseReportDeduplicationService.SurvivorVaccinations);
                if (serVaccineHistory == "[]")
                {
                    request.VaccinationsParameters = null;
                }
                else
                {
                    request.VaccinationsParameters = serVaccineHistory;
                }


                //where Local Identifier Goes

                //var sampleModel = jsonObject["sampleModel"].ToString();
                //var parsedSamples = JObject.Parse(sampleModel);
                //request.idfsYNSpecimenCollected = !string.IsNullOrEmpty(parsedSamples["samplesCollectedYN"].ToString()) && long.Parse(parsedSamples["samplesCollectedYN"].ToString()) != 0 ? long.Parse(parsedSamples["samplesCollectedYN"].ToString()) : null;
                //request.idfsNotCollectedReason = !string.IsNullOrEmpty(parsedSamples["reasonID"].ToString()) && long.Parse(parsedSamples["reasonID"].ToString()) != 0 ? long.Parse(parsedSamples["reasonID"].ToString()) : null;

                ////Sample List
                //var sampleDetails = parsedSamples["samplesDetails"];
                List<SampleSaveRequestModel> samples = new List<SampleSaveRequestModel>();

             
                //Sample Details
                
                foreach(var item in HumanDiseaseReportDeduplicationService.SurvivorSamples)
                {
                    SampleSaveRequestModel Sample = new SampleSaveRequestModel();
                    
                    Sample.SampleTypeID = item.SampleTypeID;
                    Sample.EIDSSLocalOrFieldSampleID = item.LocalSampleId;
                    Sample.DiseaseID = item.idfDisease;

                    //var blnNumberingSchema = !string.IsNullOrEmpty(item["blnNumberingSchema"].ToString()) && int.Parse(item["blnNumberingSchema"].ToString()) != 0 ? int.Parse(item["blnNumberingSchema"].ToString()) : 0;
                    //if (blnNumberingSchema == 1 || blnNumberingSchema == 2)
                    //{
                    //    Sample.EIDSSLocalOrFieldSampleID = "";
                    //}
                    //else
                    //{
                    //    Sample.EIDSSLocalOrFieldSampleID = !string.IsNullOrEmpty(item["localSampleId"].ToString()) ? item["localSampleId"].ToString() : null;
                    //}
                    Sample.CollectionDate = item.CollectionDate;
                    Sample.CollectedByOrganizationID = item.CollectedByOrganizationID;
                    Sample.CollectedByPersonID = item.CollectedByOfficerID;
                    Sample.SentDate = item.SentDate;
                    Sample.SentToOrganizationID = item.SentToOrganizationID;
                    Sample.SiteID = !string.IsNullOrEmpty(item.idfsSiteSentToOrg.ToString()) ? long.Parse(item.idfsSiteSentToOrg.ToString()) : 1;
                    Sample.DiseaseID = item.idfDisease;
                    Sample.SampleID = !string.IsNullOrEmpty(item.idfMaterial.ToString()) && long.Parse(item.idfMaterial.ToString()) != 0 ? long.Parse(item.idfMaterial.ToString()) : 0;
                    //Sample.SampleID = !string.IsNullOrEmpty(item["idfMaterial"].ToString()) && long.Parse(item["idfMaterial"].ToString()) != 0 ? long.Parse(item["idfMaterial"].ToString()) : 0;
                    if (Sample.SampleID == 0)
                        Sample.SampleID = item.NewRecordId;
                    Sample.RowStatus = item.intRowStatus;
                    Sample.CurrentSiteID = null;
                    //Sample.HumanMasterID = HumanDiseaseReportDeduplicationService.SurvivoridfHumanActual;
                    Sample.HumanID = HumanDiseaseReportDeduplicationService.SurvivoridfHuman;
                    Sample.HumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                    Sample.RowAction = 2;
                    Sample.ReadOnlyIndicator = false;
                    
                    
                    samples.Add(Sample);
                }

                var serSamplesHistory = JsonConvert.SerializeObject(samples);
                if (serSamplesHistory == "[]")
                {
                    request.SamplesParameters = null;
                }
                else
                {
                    request.SamplesParameters = serSamplesHistory;
                }


                //Test Details

                List<LaboratoryTestSaveRequestModel> tests = new List<LaboratoryTestSaveRequestModel>();
                List<LaboratoryTestInterpretationSaveRequestModel> testInterpretations = new List<LaboratoryTestInterpretationSaveRequestModel>();
                var count = 0;
                foreach (var item in HumanDiseaseReportDeduplicationService.SurvivorTests)
                {
                    LaboratoryTestSaveRequestModel testRequest = new LaboratoryTestSaveRequestModel();
                    LaboratoryTestInterpretationSaveRequestModel interpretationRequest = new LaboratoryTestInterpretationSaveRequestModel();
                    testRequest.SampleID = item.idfMaterial;

                    testRequest.TestID = !string.IsNullOrEmpty(item.idfTesting.ToString()) && long.Parse(item.idfTesting.ToString()) != 0 ? long.Parse(item.idfTesting.ToString()) : 0;
                    //if (testRequest.TestID == 0)
                    //{
                    //    count = count + 1;
                    //    testRequest.TestID = count;
                    //}
                    testRequest.HumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                    testRequest.TestCategoryTypeID = item.idfsTestCategory;
                    testRequest.TestNameTypeID = item.idfsTestName;
                    testRequest.TestResultTypeID =item.idfsTestResult;
                    testRequest.TestStatusTypeID = !string.IsNullOrEmpty(item.idfsTestStatus.ToString()) && long.Parse(item.idfsTestStatus.ToString()) != 0 ? long.Parse(item.idfsTestStatus.ToString()) : 0;
                    if (!string.IsNullOrEmpty(item.datSampleStatusDate.ToString()))
                    {
                        testRequest.ResultDate = item.datSampleStatusDate;
                    }
                    if (!string.IsNullOrEmpty(item.datFieldCollectionDate.ToString()))
                    {
                        testRequest.ReceivedDate = item.datFieldCollectionDate;
                    }
                    testRequest.TestedByPersonID = item.idfTestedByPerson;
                    testRequest.TestedByOrganizationID = item.idfTestedByOffice;
                    testRequest.RowStatus = !string.IsNullOrEmpty(item.intRowStatus.ToString()) && int.Parse(item.intRowStatus.ToString()) != 0 ? int.Parse(item.intRowStatus.ToString()) : 0;


                    testRequest.HumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                    testRequest.RowAction =  2;
                    testRequest.ReadOnlyIndicator = false;
                    testRequest.DiseaseID = !string.IsNullOrEmpty(item.idfsDiagnosis.ToString()) && long.Parse(item.idfsDiagnosis.ToString()) != 0 ? long.Parse(item.idfsDiagnosis.ToString()) : 0;
                    testRequest.NonLaboratoryTestIndicator = item.blnNonLaboratoryTest;

                    //interpretationRequest.TestID = !string.IsNullOrEmpty(item["idfTesting"].ToString()) && long.Parse(item["idfTesting"].ToString()) != 0 ? long.Parse(item["idfTesting"].ToString()) : 0;

                    interpretationRequest.TestID = testRequest.TestID;
                    interpretationRequest.TestInterpretationID = !string.IsNullOrEmpty(item.idfTestValidation.ToString()) && long.Parse(item.idfTestValidation.ToString()) != 0 ? long.Parse(item.idfTestValidation.ToString()) : 0;
                    interpretationRequest.InterpretedByPersonID = !string.IsNullOrEmpty(item.idfInterpretedByPerson.ToString()) && long.Parse(item.idfInterpretedByPerson.ToString()) != 0 ? long.Parse(item.idfInterpretedByPerson.ToString()) : null;
                    interpretationRequest.InterpretedStatusTypeID = !string.IsNullOrEmpty(item.idfsInterpretedStatus.ToString()) && long.Parse(item.idfsInterpretedStatus.ToString()) != 0 ? long.Parse(item.idfsInterpretedStatus.ToString()) : null;
                    if (!string.IsNullOrEmpty(item.datInterpretedDate.ToString()))
                    {
                        interpretationRequest.InterpretedDate = item.datInterpretedDate;
                    }
                    interpretationRequest.InterpretedComment = item.strInterpretedComment;
                    interpretationRequest.ValidatedByPersonID = item.idfValidatedByPerson;

                    //if (!string.IsNullOrEmpty(item.datValidationDate.ToString()))
                    //{
                        interpretationRequest.ValidatedDate = item.datValidationDate;
                    //}
                    interpretationRequest.ValidatedComment = item.strValidateComment;
                    interpretationRequest.RowStatus = !string.IsNullOrEmpty(item.intRowStatus.ToString()) && int.Parse(item.intRowStatus.ToString()) != 0 ? int.Parse(item.intRowStatus.ToString()) : 0;
                    interpretationRequest.ValidatedStatusIndicator = !string.IsNullOrEmpty(item.blnValidateStatus.ToString()) ? Convert.ToBoolean(item.blnValidateStatus.ToString()) : false;
                   // interpretationRequest.DiseaseID = request.idfHumanCase;
                    interpretationRequest.RowAction =  0;
                    interpretationRequest.ReadOnlyIndicator = false;
                    interpretationRequest.DiseaseID = !string.IsNullOrEmpty(item.idfsDiagnosis.ToString()) && long.Parse(item.idfsDiagnosis.ToString()) != 0 ? long.Parse(item.idfsDiagnosis.ToString()) : 0;
                    tests.Add(testRequest);
                    testInterpretations.Add(interpretationRequest);


                }

                var serTestHistory = JsonConvert.SerializeObject(tests);
                if (serTestHistory == "[]")
                {
                    request.TestsParameters = null;
                }
                else
                {
                    request.TestsParameters = serTestHistory;
                }

                var strTestInterpretation = System.Text.Json.JsonSerializer.Serialize(testInterpretations);

                if (strTestInterpretation == "[]")
                {
                    request.TestsInterpretationParameters = null;
                }
                else
                {
                    request.TestsInterpretationParameters = strTestInterpretation;
                }

                //Contact Details

                List<DiseaseReportContactSaveRequestModel> contactList = new List<DiseaseReportContactSaveRequestModel>();
                DiseaseReportContactSaveRequestModel contactRequest = new DiseaseReportContactSaveRequestModel();
                foreach (var item in HumanDiseaseReportDeduplicationService.SurvivorContacts)
                {
                    DiseaseReportContactSaveRequestModel contactItem = new DiseaseReportContactSaveRequestModel();
                    contactItem.CaseOrReportId = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                    contactItem.HumanId = item.idfHuman;
                    contactItem.HumanMasterId = item.idfHumanActual;
                    contactItem.ContactTypeId = (long?)OutbreakContactTypeEnum.Human;
                    contactItem.ContactedCasePersonId = item.idfContactedCasePerson; 
                    contactItem.DateOfLastContact =item.datDateOfLastContact;
                    contactItem.PlaceOfLastContact = item.strPlaceInfo;
                    contactItem.ContactRelationshipTypeId = item.idfsPersonContactType;
                    contactItem.Comments = item.strComments;
                    contactItem.FirstName = item.strFirstName;
                    contactItem.SecondName = item.strSecondName;
                    contactItem.LastName = item.strLastName;
                    contactItem.DateOfBirth = item.datDateofBirth;
                    contactItem.GenderTypeId = item.idfsHumanGender;
                    contactItem.CitizenshipTypeId = item.idfCitizenship;
                    contactItem.ContactPhone = item.strContactPhone;
                    contactItem.ContactPhoneTypeId = item.idfContactPhoneType;
                    var isForiegnAddress = item.blnForeignAddress;
                    if (isForiegnAddress.Value)
                    {
                        contactItem.ForeignAddressString = item.strPatientAddressString;
                        contactItem.LocationId = item.idfsCountry;
                    }
                    else
                    {
                        contactItem.Street = item.strStreetName;
                        contactItem.PostalCode = item.strPostCode;
                        contactItem.House = item.strHouse;
                        contactItem.Building = item.strBuilding;
                        contactItem.Apartment = item.strApartment;
                        //contactItem.Apartment = !string.IsNullOrEmpty(item.strApartment.ToString()) ? item.strApartment.ToString() : null;
                        contactItem.LocationId = !string.IsNullOrEmpty(item.idfsSettlement.ToString()) && long.Parse(item.idfsSettlement.ToString()) != 0 ? long.Parse(item.idfsSettlement.ToString()) : null;
                        if (contactItem.LocationId == null || contactItem.LocationId == 0)
                        {
                            contactItem.LocationId = !string.IsNullOrEmpty(item.idfsRayon.ToString()) && long.Parse(item.idfsRayon.ToString()) != 0 ? long.Parse(item.idfsRayon.ToString()) : null;
                        }
                        if (contactItem.LocationId == null || contactItem.LocationId == 0)
                        {
                            contactItem.LocationId = !string.IsNullOrEmpty(item.idfsRegion.ToString()) && long.Parse(item.idfsRegion.ToString()) != 0 ? long.Parse(item.idfsRegion.ToString()) : null;
                        }
                        if (contactItem.LocationId == null || contactItem.LocationId == 0)
                        {
                            contactItem.LocationId = !string.IsNullOrEmpty(item.idfsCountry.ToString()) && long.Parse(item.idfsCountry.ToString()) != 0 ? long.Parse(item.idfsCountry.ToString()) : null;
                        }

                        }
                        if (contactItem.RowAction == 2)
                            contactItem.AddressId = !string.IsNullOrEmpty(item.AddressID.ToString()) && long.Parse(item.AddressID.ToString()) != 0 ? long.Parse(item.AddressID.ToString()) : null;

                        contactItem.RowStatus = !string.IsNullOrEmpty(item.RowStatus.ToString()) && int.Parse(item.RowStatus.ToString()) != 0 ? int.Parse(item.RowStatus.ToString()) : 0;
                        contactItem.RowAction =  2;
                        contactItem.AuditUserName = authenticatedUser.UserName;
                        contactList.Add(contactItem);
                }

                var serContactHistory = JsonConvert.SerializeObject(contactList);
                if (serContactHistory == "[]")
                {
                    request.ContactsParameters = null;
                }
                else
                {
                    request.ContactsParameters = serContactHistory;
                }


                Type type = request.GetType();
                PropertyInfo[] props = type.GetProperties();
                int index = -1;

                for (int i = 0; i <= props.Count() - 1; i++)
                {
                    // Summary
                    foreach (var item in HumanDiseaseReportDeduplicationService.SurvivorSummaryList)
                    {
                        if (IsInTabSummary(props[i].Name) == true)
                        {
                            index = keyDict0[props[i].Name];
                            string safeValue = HumanDiseaseReportDeduplicationService.SurvivorSummaryList[index].Value;
                            if (safeValue != null)
                            {
                                SetValue(request, props[i].Name, safeValue);
                            }
                            else
                            {
                                props[i].SetValue(request, safeValue);
                            }
                        }
                    }

                    // Notification
                    foreach (var item in HumanDiseaseReportDeduplicationService.SurvivorNotificationList)
                    {
                        if (IsInTabNotification(props[i].Name) == true)
                        {
                            index = keyDict[props[i].Name];
                            string safeValue = HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Value;
                            if (safeValue != null)
                            {
                                SetValue(request, props[i].Name, safeValue);
                            }
                            else
                            {
                                props[i].SetValue(request, safeValue);
                            }
                        }
                    }
                    //Symptoms
                    foreach (var item in HumanDiseaseReportDeduplicationService.SurvivorSymptomsList)
                    {
                        if (IsInTabSymptoms(props[i].Name) == true)
                        {
                            index = keyDict2[props[i].Name];
                            string safeValue = HumanDiseaseReportDeduplicationService.SurvivorSymptomsList[index].Value;
                            if (safeValue != null)
                            {
                                SetValue(request, props[i].Name, safeValue);
                            }
                            else
                            {
                                props[i].SetValue(request, safeValue);
                            }
                        }
                    }
                    //Facility Details
                    foreach (var item in HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList)
                    {
                        if (IsInHumanDiseaseReportDedupeRequestModelClinicalFacilityDetails(props[i].Name) == true)
                        {
                            if (props[i].Name == "idfsNonNotIFiableDiagnosis")
                                index = keyDict3["idfsNonNotifiableDiagnosis"];
                            else
                                index = keyDict3[props[i].Name];

                            string safeValue = HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList[index].Value;
                            if (safeValue != null)
                            {
                                SetValue(request, props[i].Name, safeValue);
                            }
                            else
                            {
                                props[i].SetValue(request, safeValue);
                            }
                        }
                    }

                    //Antibiotic  History
                    foreach (var item in HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList)
                    {
                        if (IsInTabAntibioticHistory(props[i].Name) == true)
                        {
                            index = keyDict4[props[i].Name];
                            string safeValue = HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList[index].Value;
                            if (safeValue != null)
                            {
                                SetValue(request, props[i].Name, safeValue);
                            }
                            else
                            {
                                props[i].SetValue(request, safeValue);
                            }
                        }
                    }

                    // Vaccine History
                    foreach (var item in HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList)
                    {
                        if (IsInTabVaccineHistory(props[i].Name) == true)
                        {
                            index = keyDict5[props[i].Name];
                            string safeValue = HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList[index].Value;
                            if (safeValue != null)
                            {
                                SetValue(request, props[i].Name, safeValue);
                            }
                            else
                            {
                                props[i].SetValue(request, safeValue);
                            }
                        }
                    }

                    // Clinical Notes
                    foreach (var item in HumanDiseaseReportDeduplicationService.SurvivorClinicalNotesList)
                    {
                        if (IsInTabClinicalNotes(props[i].Name) == true)
                        {
                            index = keyDict12[props[i].Name];
                            string safeValue = HumanDiseaseReportDeduplicationService.SurvivorClinicalNotesList[index].Value;
                            if (safeValue != null)
                            {
                                SetValue(request, props[i].Name, safeValue);
                            }
                            else
                            {
                                props[i].SetValue(request, safeValue);
                            }
                        }
                    }

                    // Samples
                    foreach (var item in HumanDiseaseReportDeduplicationService.SurvivorSamplesList)
                    {
                        if (IsInTabSamples(props[i].Name) == true)
                        {
                            index = keyDict6[props[i].Name];
                            string safeValue = HumanDiseaseReportDeduplicationService.SurvivorSamplesList[index].Value;
                            if (safeValue != null)
                            {
                                SetValue(request, props[i].Name, safeValue);
                            }
                            else
                            {
                                props[i].SetValue(request, safeValue);
                            }
                        }
                    }
                    
                    // Test
                    foreach (var item in HumanDiseaseReportDeduplicationService.SurvivorTestsList)
                    {
                        if (IsInTabTest(props[i].Name) == true)
                        {
                            index = keyDict7[props[i].Name];
                            string safeValue = HumanDiseaseReportDeduplicationService.SurvivorTestsList[index].Value;
                            if (safeValue != null)
                            {
                                SetValue(request, props[i].Name, safeValue);
                            }
                            else
                            {
                                props[i].SetValue(request, safeValue);
                            }
                        }
                    }

                    // Case Investigation Details
                    foreach (var item in HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList)
                    {
                        if (IsInHumanDiseaseReportDedupeRequestModelCaseInvestigationDetails(props[i].Name) == true)
                        {
                            if (props[i].Name == "idfsGeoLocationType")
                                index = keyDict8["idfsPointGeoLocationType"];
                            else if (props[i].Name == "idfsLocationCountry")
                                index = keyDict8["idfsPointCountry"];
                            else if (props[i].Name == "idfsLocationRegion")
                                index = keyDict8["idfsPointRegion"];
                            else if (props[i].Name == "idfsLocationRayon")
                                index = keyDict8["idfsPointRayon"];
                            else if (props[i].Name == "idfsLocationSettlement")
                                index = keyDict8["idfsPointSettlement"];
                            else if (props[i].Name == "intLocationLatitude")
                                index = keyDict8["dblPointLatitude"];
                            else if (props[i].Name == "intLocationLongitude")
                                index = keyDict8["dblPointLongitude"];
                            else if (props[i].Name == "intElevation")
                                index = keyDict8["dblPointElevation"];
                            else if (props[i].Name == "idfsLocationGroundType")
                                index = keyDict8["idfsPointGroundType"];
                            else if (props[i].Name == "intLocationDistance")
                                index = keyDict8["dblPointDistance"];
                            else if (props[i].Name == "intLocationDirection")
                                index = keyDict8["dblPointAlignment"];
                            else if (props[i].Name == "strForeignAddress")
                                index = keyDict8["strPointForeignAddress"];
                            else
                                index = keyDict8[props[i].Name];

                            string safeValue = HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList[index].Value;
                            if (safeValue != null)
                            {
                                SetValue(request, props[i].Name, safeValue);
                            }
                            else
                            {
                                props[i].SetValue(request, safeValue);
                            }
                        }
                    }

                    // Risk Factors
                    foreach (var item in HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsList)
                    {
                        if (IsInTabRiskFactors(props[i].Name) == true)
                        {
                            index = keyDict9[props[i].Name];
                            string safeValue = HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsList[index].Value;
                            if (safeValue != null)
                            {
                                SetValue(request, props[i].Name, safeValue);
                            }
                            else
                            {
                                props[i].SetValue(request, safeValue);
                            }
                        }
                    }

                    // Contact Details
                    //foreach (var item in HumanDiseaseReportDeduplicationService.SurvivorContactsList)
                    //{
                    //    if (IsInTabContacts(props[i].Name) == true)
                    //    {
                    //        index = keyDict10[props[i].Name];
                    //        string safeValue = HumanDiseaseReportDeduplicationService.SurvivorContactsList[index].Value;
                    //        if (safeValue != null)
                    //        {
                    //            SetValue(request, props[i].Name, safeValue);
                    //        }
                    //        else
                    //        {
                    //            props[i].SetValue(request, safeValue);
                    //        }
                    //    }
                    //}

                    // Final Outcome
                    foreach (var item in HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList)
                    {
                        if (IsInHumanDiseaseReportDedupeRequestModelFinalOutcome(props[i].Name) == true)
                        {
                            if (props[i].Name == "idfsOutcome")
                                index = keyDict11["idfsOutCome"];
                            else
                                index = keyDict11[props[i].Name];

                            string safeValue = HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList[index].Value;
                            if (safeValue != null)
                            {
                                SetValue(request, props[i].Name, safeValue);
                            }
                            else
                            {
                                props[i].SetValue(request, safeValue);
                            }
                        }
                    }
                }


                response = await HumanDiseaseReportClient.DedupeHumanDiseaseReportRecords(request);
                if (response != null)
                {
                    //Success
                    if (response.ReturnCode == 0)
                    {
                        return true;
                    }
                    else
                    {
                        //ShowErrorMessage(messageType: MessageType.CannotSaveSurvivorRecord, message: GetLocalResourceObject("Lbl_Cannot_Save_Survivor_Record").ToString());
                        return false;
                    }
                }
                else
                {
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return true;
        }

        //private async Task<bool> SaveSurvivorRecordAsync()
        //{
        //    try
        //    {
        //    PersonSaveRequestModel parameters = new PersonSaveRequestModel();
        //    Type type = parameters.GetType();
        //    PropertyInfo[] props = type.GetProperties();
        //    int index = -1;

        //    long? HumanidfsCountry = null;
        //    long? HumanidfsRegion = null;
        //    long? HumanidfsRayon = null;
        //    long? HumanidfsSettlement = null;
        //    long? HumanAltidfsCountry = null;
        //    long? HumanAltidfsRegion = null;
        //    long? HumanAltidfsRayon = null;
        //    long? HumanAltidfsSettlement = null;
        //    long? HumanPermidfsCountry = null;
        //    long? HumanPermidfsRegion = null;
        //    long? HumanPermidfsRayon = null;
        //    long? HumanPermidfsSettlement = null;
        //    long? EmployeridfsCountry = null;
        //    long? EmployeridfsRegion = null;
        //    long? EmployeridfsRayon = null;
        //    long? EmployeridfsSettlement = null;
        //    long? SchoolidfsCountry = null;
        //    long? SchoolidfsRegion = null;
        //    long? SchoolidfsRayon = null;
        //    long? SchoolidfsSettlement = null;

        //    for (int i = 0; i <= props.Count() - 1; i++)
        //    {
        //        //    if (IsInPersonSaveRequestModelInfo(props[i].Name) == true)
        //        //    {
        //        //        if (props[i].Name == "LastName")
        //        //            index = keyDict["LastOrSurname"];
        //        //        else if (props[i].Name == "FirstName")
        //        //            index = keyDict["FirstOrGivenName"];
        //        //        else if (props[i].Name == "HumanGenderTypeID")
        //        //            index = keyDict["GenderTypeID"];
        //        //        else if (props[i].Name == "ReportAgeUOMID")
        //        //            index = keyDict["ReportedAgeUOMID"];
        //        //        else
        //        //            index = keyDict[props[i].Name];

        //        //        string safeValue = HumanDiseaseReportDeduplicationService.SurvivorInfoList[index].Value;
        //        //        if (safeValue != null)
        //        //        {
        //        //            if (props[i].Name == "PersonalIDType" && safeValue == "")
        //        //            {
        //        //                props[i].SetValue(parameters, null);
        //        //            }
        //        //            else if (props[i].Name == "DateOfBirth" && safeValue == "")
        //        //            {
        //        //                props[i].SetValue(parameters, null);
        //        //            }
        //        //            else
        //        //            {
        //        //                SetValue(parameters, props[i].Name, safeValue);
        //        //            }
        //        //        }
        //        //        else
        //        //        {
        //        //            props[i].SetValue(parameters, safeValue);
        //        //        }
        //        //    }
        //        //    else if (IsInTabAddress(props[i].Name) == true)
        //        //    {
        //        //        index = keyDict2[props[i].Name];
        //        //        string safeValue = HumanDiseaseReportDeduplicationService.SurvivorAddressList[index].Value;
        //        //        if (safeValue != null)
        //        //        {
        //        //            if (IsOneOfLocationIDs(props[i].Name) == true && safeValue == "")
        //        //            {
        //        //                props[i].SetValue(parameters, null);
        //        //            }
        //        //            else
        //        //            {
        //        //                SetValue(parameters, props[i].Name, safeValue);
        //        //            }
        //        //        }
        //        //        else
        //        //        {
        //        //            props[i].SetValue(parameters, safeValue);
        //        //        }
        //        //    }
        //        //    else if (IsInTabEmp(props[i].Name) == true)
        //        //    {
        //        //        index = keyDict3[props[i].Name];
        //        //        string safeValue = HumanDiseaseReportDeduplicationService.SurvivorEmpList[index].Value;
        //        //        if (safeValue != null)
        //        //        {
        //        //            if (IsOneOfLocationIDs(props[i].Name) == true && safeValue == "")
        //        //            {
        //        //                props[i].SetValue(parameters, null);
        //        //            }
        //        //            else
        //        //            {
        //        //                SetValue(parameters, props[i].Name, safeValue);
        //        //            }
        //        //        }
        //        //        else
        //        //        {
        //        //            props[i].SetValue(parameters, safeValue);
        //        //        }
        //        //    }
        //        }

        //        //foreach (Field item in HumanDiseaseReportDeduplicationService.SurvivorAddressList)
        //        //{
        //        //    if (item.Key == PersonDeduplicationAddressConstants.HumanidfsCountry && item.Value != null)
        //        //    {
        //        //        HumanidfsCountry = Convert.ToInt64(item.Value);
        //        //    }
        //        //    else if (item.Key == PersonDeduplicationAddressConstants.HumanidfsRegion && item.Value != null)
        //        //    {
        //        //        HumanidfsRegion = Convert.ToInt64(item.Value);
        //        //    }
        //        //    else if (item.Key == PersonDeduplicationAddressConstants.HumanidfsRayon && item.Value != null)
        //        //    {
        //        //        HumanidfsRayon = Convert.ToInt64(item.Value);
        //        //    }
        //        //    else if (item.Key == PersonDeduplicationAddressConstants.HumanidfsSettlement && item.Value != null)
        //        //    {
        //        //        HumanidfsSettlement = Convert.ToInt64(item.Value);
        //        //    }

        //        //    if (item.Key == PersonDeduplicationAddressConstants.HumanAltidfsCountry && item.Value != null)
        //        //    {
        //        //        HumanAltidfsCountry = Convert.ToInt64(item.Value);
        //        //    }
        //        //    else if (item.Key == PersonDeduplicationAddressConstants.HumanAltidfsRegion && item.Value != null)
        //        //    {
        //        //        HumanAltidfsRegion = Convert.ToInt64(item.Value);
        //        //    }
        //        //    else if (item.Key == PersonDeduplicationAddressConstants.HumanAltidfsRayon && item.Value != null)
        //        //    {
        //        //        HumanAltidfsRayon = Convert.ToInt64(item.Value);
        //        //    }
        //        //    else if (item.Key == PersonDeduplicationAddressConstants.HumanAltidfsSettlement && item.Value != null)
        //        //    {
        //        //        HumanAltidfsSettlement = Convert.ToInt64(item.Value);
        //        //    }
        //        //}

        //        //foreach (Field item in HumanDiseaseReportDeduplicationService.SurvivorEmpList)
        //        //{
        //        //    if (item.Key == PersonDeduplicationEmpConstants.EmployeridfsCountry && item.Value != null)
        //        //    {
        //        //        EmployeridfsCountry = Convert.ToInt64(item.Value);
        //        //    }
        //        //    else if (item.Key == PersonDeduplicationEmpConstants.EmployeridfsRegion && item.Value != null)
        //        //    {
        //        //        EmployeridfsRegion = Convert.ToInt64(item.Value);
        //        //    }
        //        //    else if (item.Key == PersonDeduplicationEmpConstants.EmployeridfsRayon && item.Value != null)
        //        //    {
        //        //        EmployeridfsRayon = Convert.ToInt64(item.Value);
        //        //    }
        //        //    else if (item.Key == PersonDeduplicationEmpConstants.EmployeridfsSettlement && item.Value != null)
        //        //    {
        //        //        EmployeridfsSettlement = Convert.ToInt64(item.Value);
        //        //    }

        //        //    if (item.Key == PersonDeduplicationEmpConstants.SchoolidfsCountry && item.Value != null)
        //        //    {
        //        //        SchoolidfsCountry = Convert.ToInt64(item.Value);
        //        //    }
        //        //    else if (item.Key == PersonDeduplicationEmpConstants.SchoolidfsRegion && item.Value != null)
        //        //    {
        //        //        SchoolidfsRegion = Convert.ToInt64(item.Value);
        //        //    }
        //        //    else if (item.Key == PersonDeduplicationEmpConstants.SchoolidfsRayon && item.Value != null)
        //        //    {
        //        //        SchoolidfsRayon = Convert.ToInt64(item.Value);
        //        //    }
        //        //    else if (item.Key == PersonDeduplicationEmpConstants.SchoolidfsSettlement && item.Value != null)
        //        //    {
        //        //        SchoolidfsSettlement = Convert.ToInt64(item.Value);
        //        //    }
        //        //}

        //        //parameters.HumanMasterID = HumanDiseaseReportDeduplicationService.SurvivorHumanMasterID;
        //        //parameters.CopyToHumanIndicator = false;
        //        //parameters.HumanidfsLocation = GetLowestLocationID(HumanidfsCountry, HumanidfsRegion, HumanidfsRayon, HumanidfsSettlement);
        //        //parameters.HumanPermidfsLocation = GetLowestLocationID(HumanPermidfsCountry, HumanPermidfsRegion, HumanPermidfsRayon, HumanPermidfsSettlement);
        //        //parameters.HumanAltidfsLocation = GetLowestLocationID(HumanAltidfsCountry, HumanAltidfsRegion, HumanAltidfsRayon, HumanAltidfsSettlement);
        //        //parameters.EmployeridfsLocation = GetLowestLocationID(EmployeridfsCountry, EmployeridfsRegion, EmployeridfsRayon, EmployeridfsSettlement);
        //        //parameters.SchoolidfsLocation = GetLowestLocationID(SchoolidfsCountry, SchoolidfsRegion, SchoolidfsRayon, SchoolidfsSettlement);
        //        //parameters.AuditUser = authenticatedUser.UserName;

        //        //PersonSaveResponseModel result = await PersonClient.SavePerson(parameters);

        //        //if (result.ReturnCode != null)
        //        //{
        //        //    //Success
        //        //    if (result.ReturnCode == 0)
        //        //    {
        //        //        return true;
        //        //    }
        //        //    else
        //        //    {
        //        //        //ShowErrorMessage(messageType: MessageType.CannotSaveSurvivorRecord, message: GetLocalResourceObject("Lbl_Cannot_Save_Survivor_Record").ToString());
        //        //        return false;
        //        //    }
        //        //}
        //        //else
        //        //{
        //        //}
        //        return true;
        //    }
        //        catch (Exception ex)
        //        {
        //            _logger.LogError(ex.Message);
        //        }
        //    return false;
        //}

            public static void SetValue(object inputObject, string propertyName, object propertyVal)
            {
            //find out the type
            Type type = inputObject.GetType();

            //get the property information based on the type
            System.Reflection.PropertyInfo propertyInfo = type.GetProperty(propertyName);

            //find the property type
            Type propertyType = propertyInfo.PropertyType;
            var t = propertyType;

            //Convert.ChangeType does not handle conversion to nullable types
            //if the property type is nullable, we need to get the underlying type of the property
            object targetType = propertyType == null ? Nullable.GetUnderlyingType(propertyType) : propertyType;

            //if (propertyVal.ToString() == "" && (targetType.GetType().Name == "Int32" || targetType.GetType().Name == "Int64" || targetType.GetType().Name == "Double"))
            //{
            //	propertyVal = "0";
            //}
            if (t.IsGenericType && t.GetGenericTypeDefinition().Equals(typeof(Nullable<>)))
            {
                if (String.IsNullOrEmpty((string)propertyVal))
                    propertyVal = "0";
                else
                {
                    t = Nullable.GetUnderlyingType(t);
                    propertyVal = Convert.ChangeType(propertyVal, t);
                }
            }
            else
            {
                //Returns an System.Object with the specified System.Type and whose value is
                //equivalent to the specified object.
                propertyVal = Convert.ChangeType(propertyVal, (Type)targetType);
            }

            //Set the value of the property
            propertyInfo.SetValue(inputObject, propertyVal, null);

        }

        private async Task ReplaceSupersededDiseaseListPersonIDAsync()
        {
            try
            {
                //PersonDedupeRequestModel request = new PersonDedupeRequestModel();
                //request.SurvivorHumanMasterID = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //request.SupersededHumanMasterID = HumanDiseaseReportDeduplicationService.SupersededHumanDiseaseReportID;
                //APIPostResponseModel result = await PersonClient.DedupePersonHumanDisease(request);
                //if (result.ReturnCode != null)
                //{
                //    if (result.ReturnCode == 0) // Success
                //    {
                //    }
                //    else
                //    {
                //    } // Error
                //}
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        //private async Task ReplaceSupersededFarmListPersonIDAsync()
        //{
        //    try
        //    {
        //        //PersonDedupeRequestModel request = new PersonDedupeRequestModel();
        //        //request.SurvivorHumanMasterID = HumanDiseaseReportDeduplicationService.SurvivorHumanMasterID;
        //        //request.SupersededHumanMasterID = HumanDiseaseReportDeduplicationService.SupersededHumanMasterID;
        //        //APIPostResponseModel result = await PersonClient.DedupePersonFarm(request);
        //        //if (result.ReturnCode != null)
        //        //{
        //        //    if (result.ReturnCode == 0) // Success
        //        //    {
        //        //    }
        //        //    else
        //        //    {
        //        //    } // Error
        //        //}
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex.Message);
        //    }
        //}

        private async Task RemoveSupersededRecordAsync()
        {
            try
            {
                APIPostResponseModel result = await HumanDiseaseReportClient.DeleteHumanDiseaseReport(HumanDiseaseReportDeduplicationService.SupersededHumanDiseaseReportID, Convert.ToInt64(authenticatedUser.EIDSSUserId), Convert.ToInt64(authenticatedUser.SiteId),true);
                if (result.ReturnCode != null)
                {
                    // commented out because we can't build, after the DB restore.
                    // The SP involved doesn't have the return items for the API Results to capture.
                    // Since this code doesn't seem to do anything, commenting out so that the developer involved can reinstate, when corrected.

                    // If result.FirstOrDefault().ReturnCode = 0 Then 'Success
                    // Else 'Error
                    // End If
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        //private long? GetLowestLocationID(long? level0, long? level1, long? level2, long? level3)
        //{
        //	long? idfsLocation = null;

        //	//Get lowest administrative level.
        //	if (level3 != null)
        //		idfsLocation = level3;
        //	else if (level2 != null)
        //		idfsLocation = level2;
        //	else if (level1 != null)
        //		idfsLocation = level1;
        //	else
        //		idfsLocation = level0;

        //	return idfsLocation;
        //}

        protected async Task SaveSuccessMessagedDialog()
        {
            try
            {
                var buttons = new List<DialogButton>();
                var okButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                    ButtonType = DialogButtonType.OK
                };
                buttons.Add(okButton);

                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage));
                var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
                if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                {
                    HumanDiseaseReportDeduplicationService.SelectedRecords = null;
                    NavManager.NavigateTo($"Administration/HumanDiseaseReportDeduplication", true);
                }
            }
            catch (Exception)
            {
                throw;
            }
        }

        protected bool IsInHumanDiseaseReportDedupeRequestModelClinicalFacilityDetails(string strName)
        {
            switch (strName)
            {
                case DiseasereportDeduplicationFacilityDetailsConstants.PreviouslySoughtCare:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.FacilityFirstSoughtCare:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.FirstSoughtCareDate:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.NonNotifiableDiagnosis:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.Hospitalization:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.HospitalizationDate:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.DischargeDate:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.PreviouslySoughtCareID:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.FacilityFirstSoughtCareID:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.idfsNonNotIFiableDiagnosis:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.HospitalizationID:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.HospitalName:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.HospitalID:
                    return true;
            }
            return false;
        }

        protected bool IsInHumanDiseaseReportDedupeRequestModelCaseInvestigationDetails(string strName)
        {
            switch (strName)
            {
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.InvestigatedByOfficeID:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.StartDateofInvestigation:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.OutbreakID:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.Comments:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.ExposureLocationKnownID:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.ExposureDate:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.GeoLocationTypeID:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.LocationCountryID:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.LocationRegionID:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.LocationRayonID:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.LocationSettlementID:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.LocationLatitude:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.LocationLongitude:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.LocationElevation:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.LocationGroundTypeID:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.LocationDistance:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.LocationDirection:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.ForeignAddress:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.LocationID:
                    return true;
            }
            return false;
        }

        protected bool IsInHumanDiseaseReportDedupeRequestModelFinalOutcome(string strName)
        {
            switch (strName)
            {
                case DiseasereportDeduplicationFinalOutcomeConstants.idfsFinalCaseStatus:
                    return true;
                case DiseasereportDeduplicationFinalOutcomeConstants.DateofClassification:
                    return true;
                case DiseasereportDeduplicationFinalOutcomeConstants.BasisofDiagnosis:
                    return true;
                case DiseasereportDeduplicationFinalOutcomeConstants.idfsOutcome:
                    return true;
                //case DiseasereportDeduplicationFinalOutcomeConstants.DateofDeath:
                //  return true;
                case DiseasereportDeduplicationFinalOutcomeConstants.strSummaryNotes:
                    return true;
                case DiseasereportDeduplicationFinalOutcomeConstants.idfInvestigatedByPerson:
                    return true;
            }
            return false;
        }

        private string GetLabelResource(string strName)
        {
            switch (strName)
            {
                case "ReportID":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportSummaryReportIDFieldLabel);
                case "LegacyID":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportSummaryLegacyIDFieldLabel);
                case "ReportStatus":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportSummaryReportStatusFieldLabel);
                case "PersonID":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportSummaryPersonIDFieldLabel);
                case "ReportType":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportSummaryReportTypeFieldLabel);
                case "PersonName":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportSummaryPersonNameFieldLabel);
                case "DateEntered":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportSummaryDateEnteredFieldLabel);
                case "EnteredBy":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportSummaryEnteredByFieldLabel);
                case "EnteredByOrganization":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportSummaryEnteredByOrganizationFieldLabel);
                case "DateLastUpdated":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportSummaryDateLastUpdatedFieldLabel);
                case "CaseClassification":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportSummaryCaseClassificationFieldLabel);
                case "CompletionPaperFormDate":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportNotificationDateOfCompletionOfPaperFormFieldLabel);
                case "LocalIdentifier":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportNotificationLocalIdentifierFieldLabel);
                case "Disease":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportNotificationDiseaseFieldLabel);
                case "DateOfDisease":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportNotificationDateOfDiagnosisFieldLabel);
                case "NotificationDate":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportNotificationDateOfNotificationFieldLabel);
                case "strLocalIdentifier":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportNotificationLocalIdentifierFieldLabel);
                case "PatientStatus":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportNotificationStatusOfPatientAtTimeOfNotificationFieldLabel);
                case "SentByOffice":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportNotificationNotificationSentbyFacilityFieldLabel);
                case "SentByPerson":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportNotificationNotificationSentbyNameFieldLabel);
                case "ReceivedByOffice":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportNotificationNotificationReceivedbyFacilityFieldLabel);
                case "ReceivedByPerson":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportNotificationNotificationReceivedbyNameFieldLabel);
                case "PatientCurrentLocation":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportNotificationCurrentLocationOfPatientFieldLabel);
                case "HospitalName":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportNotificationHospitalNameFieldLabel);
                case "OtherLocation":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportNotificationOtherLocationFieldLabel);
                //Symptoms
                case "datOnSetDate":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiesaseReportSymptomsDateOfSymptomsOnsetFieldLabel);
                case "InitialCaseStatus":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiesaseReportSymptomsInitialCaseClassificationFieldLabel);
                case "idfCSObservation":
                    return Localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportClinicalInformationSymptomsHeading);
               // Facility Details
                case "PreviouslySoughtCare":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportFacilityDetailsPatientPreviouslySoughtCareForSimilarSymptomsFieldLabel);
                case "strSoughtCareFacility":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportFacilityDetailsFacilityPatientFirstSoughtCareFieldLabel);
                case "datFirstSoughtCareDate":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportFacilityDetailsDatePatientFirstSoughtCareFieldLabel);
                case "NonNotifiableDiagnosis":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportFacilityDetailsNonNotifiableDiagnosisFromFacilityWherePatientFirstSoughtCareFieldLabel);
                case "datDischargeDate":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportFacilityDetailsDateOfDischargeFieldLabel);
                case "datHospitalizationDate":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportFacilityDetailsDateOfHospitalizationFieldLabel);
                case "YNHospitalization":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportFacilityDetailsHospitalizationFieldLabel);
                //Antibiotic Vaccine History
                case "YNAntimicrobialTherapy":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportAntibioticVaccineHistoryAntibioticAntiviralTherapyAdministeredFieldLabel);
                case "YNSpecificVaccinationAdministered":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportAntibioticVaccineHistoryWasSpecificVaccinationAdministeredFieldLabel);
                case "idfHumanCase":
                    return "";
                case "strClinicalNotes":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportAntibioticVaccineHistoryAdditionalInformationCommentsFieldLabel);

                //Samples
                case "YNSpecimenCollected":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportSamplesSamplesCollectedFieldLabel);

                // Test
                case "YNTestConducted":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportTestsTestsConductedFieldLabel);

                 
                //Case Investigation Details
                case "InvestigatedByOffice":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportCaseInvestigationInvestigatingOrganizationFieldLabel);
                case "StartDateofInvestigation":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportCaseInvestigationStartDateOfInvestigationFieldLabel);
                case "YNRelatedToOutBreak":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportCaseInvestigationOutbreakIDFieldLabel);
                case "strOutbreakID":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportCaseInvestigationOutbreakIDFieldLabel);
                case "strNote":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportCaseInvestigationCommentsFieldLabel);
                case "YNExposureLocationKnown":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportCaseInvestigationLocationofExposureisknownFieldLabel);
                case "datExposureDate":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportCaseInvestigationDateOfPotentialExposureFieldLabel);
                case "ExposureLocationType":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportCaseInvestigationExposureLocationFieldLabel);
                //case "ExposureLocationDescription":
                //    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportCaseInvestigationExposureLocationFieldLabel);
                case "Country":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.CountryFieldLabel);
                case "Region":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel1FieldLabel);
                case "Rayon":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel2FieldLabel);
                case "Settlement":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel3FieldLabel);
                case "dblPointLatitude":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.AdministrativeUnitDetailsLatitudeFieldLabel);
                case "dblPointLongitude":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.AdministrativeUnitDetailsLongitudeFieldLabel);
                case "dblPointElevation":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.AdministrativeUnitDetailsElevationFieldLabel);
                case "GroundType":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointGroundTypeFieldLabel);
                case "Distance":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointDistancekmFieldLabel);
                case "Direction":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointDirectionFieldLabel);
                case "ForeignAddress":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureForeignAddressAddressFieldLabel);

                //Risk Factors
                case "idfEpiObservation":
                    return Localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportCaseInvestigationRiskFactorsHeading);
                //Final Outcome

        //protected Dictionary<int, string> labelDict11 = new Dictionary<int, string>
        //{{0, "FinalCaseStatus"}, {1, "DateofClassification"}, {2, "BasisofDiagnosis"}, {3, "Outcome"}
        //    ,{4,"strEpidemiologistsName"}, {5,"datDateOfDeath"}, {6,"strSummaryNotes"}
        //    , {7, "FinalCaseStatus"}, {8, "Outcome"}, {9,"strEpidemiologistsName"}};

                case "FinalCaseStatus":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportFinalOutcomeFinalCaseClassificationFieldLabel);
                case "DateofClassification":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportFinalOutcomeDateOfFinalCaseClassificationFieldLabel);
                case "BasisofDiagnosis":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportFinalOutcomeBasisOfDiagnosisFieldLabel);
                case "Outcome":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportFinalOutcomeOutcomeFieldLabel);
                case "strEpidemiologistsName":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportFinalOutcomeEpidemiologistNameFieldLabel);
               // case "datDateOfDeath":
                 //   return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportFinalOutcomeDateOfDeathFieldLabel);
                case "strSummaryNotes":
                    return Localizer.GetString(ColumnHeadingResourceKeyConstants.CampaignInformationCommentsDescriptionsColumnHeading);





            }
            return strName;
        }
        protected async Task CancelMergeClicked()
        {
            try
            {
                var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage, null).ConfigureAwait(false);
                if (result is DialogReturnResult returnResult && returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                {
                    //cancel search and user said yes
                    source?.Cancel();
                    shouldRender = false;
                    var uri = $"{NavManager.BaseUri}Administration/HumanDiseaseReportDeduplication?showSelectedRecordsIndicator=true";
                    NavManager.NavigateTo(uri, true);
                }
                else
                {
                    //cancel search but user said no so leave everything alone and cancel thread
                    source?.Cancel();
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex, ex.Message);
                throw;
            }
        }

        public async Task OnMergeAsync()
        {
            if (AllFieldValuePairsUnmatched() == true)
            {
                //ShowWarningMessage(messageType: MessageType.AllFieldValuePairsUnmatched, isConfirm: false);
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                //hdfCurrentTab.Value = PersonDeduplicationTabConstants.Info;
                //HideIDFieldsinTabs();
                //ScriptManager.RegisterStartupScript(this, GetType(), PAGE_KEY, SET_ACTIVE_TAB_ITEM_SCRIPT, true);
            }
            else
            {
                if (AllFieldValuePairsSelected() == true)
                {
                    foreach (Field item in HumanDiseaseReportDeduplicationService.SurvivorSummaryList)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                    }
                    foreach (Field item in HumanDiseaseReportDeduplicationService.SurvivorNotificationList)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                    }

                    foreach (Field item in HumanDiseaseReportDeduplicationService.SurvivorSymptomsList)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                    }

                    foreach (Field item in HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                    }

                    foreach (Field item in HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                    }

                    foreach (Field item in HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                    }
                    foreach (Field item in HumanDiseaseReportDeduplicationService.SurvivorSamplesList)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                    }
                    foreach (Field item in HumanDiseaseReportDeduplicationService.SurvivorTestsList)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                    }

                    foreach (Field item in HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                    }

                    foreach (Field item in HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsList)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                    }

                    //foreach (Field item in HumanDiseaseReportDeduplicationService.SurvivorContactsList)
                    //{
                    //    item.Checked = true;
                    //    item.Disabled = true;
                    //}

                    foreach (Field item in HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList)
                    {
                        item.Checked = true;
                        item.Disabled = true;
                    }
                    showDetails = false;
                    showReview = true;

                    HumanDiseaseReportDeduplicationService.NotificationValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SurvivorNotificationList.Where(s => s.Checked == true).Select(s => s.Index);
                    HumanDiseaseReportDeduplicationService.SymptomsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SurvivorSymptomsList.Where(s => s.Checked == true).Select(s => s.Index);
                    HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList.Where(s => s.Checked == true).Select(s => s.Index);
                    HumanDiseaseReportDeduplicationService.AntibioticHistoryValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList.Where(s => s.Checked == true).Select(s => s.Index);
                    HumanDiseaseReportDeduplicationService.VaccineHistoryValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList.Where(s => s.Checked == true).Select(s => s.Index);
                    HumanDiseaseReportDeduplicationService.SamplesValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SurvivorSamplesList.Where(s => s.Checked == true).Select(s => s.Index);
                    HumanDiseaseReportDeduplicationService.TestsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SurvivorTestsList.Where(s => s.Checked == true).Select(s => s.Index);
                    HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList.Where(s => s.Checked == true).Select(s => s.Index);
                    HumanDiseaseReportDeduplicationService.RiskFactorsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsList.Where(s => s.Checked == true).Select(s => s.Index);
                    //HumanDiseaseReportDeduplicationService.ContactsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SurvivorContactsList.Where(s => s.Checked == true).Select(s => s.Index);
                    HumanDiseaseReportDeduplicationService.FinalOutcomeValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList.Where(s => s.Checked == true).Select(s => s.Index);

                    ////Contact Details
                    //var idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorContactsList.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                    //var recordIdfHumanCase = HumanDiseaseReportDeduplicationService.ContactsList.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                    //var record2IdfHumanCase = HumanDiseaseReportDeduplicationService.ContactsList2.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                    //if (idfHumanCase == recordIdfHumanCase)
                    //{
                    //    HumanDiseaseReportDeduplicationService.SurvivorContactsDetails = HumanDiseaseReportDeduplicationService.contactsDetails;
                    //}
                    //else
                    //{
                    //    HumanDiseaseReportDeduplicationService.SurvivorContactsDetails = HumanDiseaseReportDeduplicationService.contactsDetails2;
                    //}

                    //HumanDiseaseReportDeduplicationService.SurvivorSamplesDetails.ForEach(o =>
                    //{
                    //    o.intRowStatus = HumanDiseaseReportDeduplicationService.Samples.Union(HumanDiseaseReportDeduplicationService.Samples2)
                    //            .Where(x => x.idfMaterial == o.idfMaterial && x.Selected).FirstOrDefault() != null ? 0 : 1;
                    //});

                    //HumanDiseaseReportDeduplicationService.SurvivorAntibioticsHistoryDetails.ForEach(o =>
                    //{
                    //    o.intRowStatus = HumanDiseaseReportDeduplicationService.antibioticsHistory.Union(HumanDiseaseReportDeduplicationService.antibioticsHistory2)
                    //            .Where(x => x.AntibioticID == o.AntibioticID && x.Selected).FirstOrDefault() != null ? 0 : 1;
                    //});

                }
                else
                {
                    await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonFieldvaluepairsfoundwithnoselectionAllfieldvaluepairsmustcontainaselectedvaluetosurviveMessage, null);

                    //ShowWarningMessage(messageType: MessageType.FieldValuePairFoundNoSelection, isConfirm: false);
                    //HideIDFieldsinTabs();
                    ////ScriptManager.RegisterStartupScript(Me, [GetType](), PAGE_KEY, SET_ACTIVE_TAB_ITEM_SCRIPT, True)
                    //GoBackToTab();
                }
            }
        }

        protected bool AllFieldValuePairsSelected()
        {
            //try
            //{
            foreach (Field item in HumanDiseaseReportDeduplicationService.NotificationList)
            {
                if (item.Checked == false && HumanDiseaseReportDeduplicationService.NotificationList2[item.Index].Checked == false)
                {
                    Tab = HumanDiseaseReportDeduplicationTabEnum.Notification;
                    showNextButton = true;
                    return false;
                }
            }

            foreach (Field item in HumanDiseaseReportDeduplicationService.SymptomsList)
            {
                if (item.Checked == false && HumanDiseaseReportDeduplicationService.SymptomsList2[item.Index].Checked == false)
                {
                    Tab = HumanDiseaseReportDeduplicationTabEnum.Symptoms;
                    showNextButton = true;
                    return false;
                }

            }
            foreach (Field item in HumanDiseaseReportDeduplicationService.FacilityDetailsList)
            {
                if (item.Checked == false && HumanDiseaseReportDeduplicationService.FacilityDetailsList2[item.Index].Checked == false)
                {
                    Tab = HumanDiseaseReportDeduplicationTabEnum.FacilityDetails;
                    showNextButton = true;
                    return false;
                }

            }

            foreach (Field item in HumanDiseaseReportDeduplicationService.AntibioticHistoryList)
            {
                if (item.Checked == false && HumanDiseaseReportDeduplicationService.AntibioticHistoryList2[item.Index].Checked == false)
                {
                    Tab = HumanDiseaseReportDeduplicationTabEnum.AntibioticVaccineHistory;
                    showNextButton = true;
                    return false;
                }

            }
            foreach(Field item in HumanDiseaseReportDeduplicationService.VaccineHistoryList)
            {
                if (item.Checked == false && HumanDiseaseReportDeduplicationService.VaccineHistoryList2[item.Index].Checked == false)
                {
                    Tab = HumanDiseaseReportDeduplicationTabEnum.AntibioticVaccineHistory;
                    showNextButton = true;
                    return false;
                }

            }
            foreach (Field item in HumanDiseaseReportDeduplicationService.SamplesList)
            {
                if (item.Checked == false && HumanDiseaseReportDeduplicationService.SamplesList2[item.Index].Checked == false)
                {
                    Tab = HumanDiseaseReportDeduplicationTabEnum.Samples;
                    showNextButton = true;
                    return false;
                }

            }
            foreach (Field item in HumanDiseaseReportDeduplicationService.TestsList)
            {
                if (item.Checked == false && HumanDiseaseReportDeduplicationService.TestsList2[item.Index].Checked == false)
                {
                    Tab = HumanDiseaseReportDeduplicationTabEnum.Test;
                    showNextButton = true;
                    return false;
                }

            }
            return true;
            //}
            //catch (Exception ex)
            //{
            //	Log.Error(MethodBase.GetCurrentMethod().Name + LoggingConstants.ExceptionWasThrownMessage, ex);
            //	throw ex;
            //	return false;
            //}
        }

        #endregion

        #region Review

        protected async Task EditClickAsync(int index)
        {
            showDetails = true;
            showReview = false;
            switch (index)
            {
                case 0:
                    HumanDiseaseReportDeduplicationService.Tab = HumanDiseaseReportDeduplicationTabEnum.Summary;
                    Tab = HumanDiseaseReportDeduplicationTabEnum.Summary;
                    OnTabChange(0);
                    break;
                case 1:
                    HumanDiseaseReportDeduplicationService.Tab = HumanDiseaseReportDeduplicationTabEnum.Notification;
                    Tab = HumanDiseaseReportDeduplicationTabEnum.Notification;
                    OnTabChange(1);
                    break;
                case 2:
                    HumanDiseaseReportDeduplicationService.Tab = HumanDiseaseReportDeduplicationTabEnum.Symptoms;
                    Tab = HumanDiseaseReportDeduplicationTabEnum.Symptoms;
                    OnTabChange(2);
                    break;
                case 3:
                    HumanDiseaseReportDeduplicationService.Tab = HumanDiseaseReportDeduplicationTabEnum.FacilityDetails;
                    Tab = HumanDiseaseReportDeduplicationTabEnum.FacilityDetails;
                    OnTabChange(3);
                    break;
                case 4:
                    HumanDiseaseReportDeduplicationService.Tab = HumanDiseaseReportDeduplicationTabEnum.AntibioticVaccineHistory;
                    Tab = HumanDiseaseReportDeduplicationTabEnum.AntibioticVaccineHistory;
                    OnTabChange(4);
                    break;
                case 5:
                    HumanDiseaseReportDeduplicationService.Tab = HumanDiseaseReportDeduplicationTabEnum.Samples;
                    Tab = HumanDiseaseReportDeduplicationTabEnum.Samples;
                    OnTabChange(5);
                    break;
                case 6:
                    HumanDiseaseReportDeduplicationService.Tab = HumanDiseaseReportDeduplicationTabEnum.Test;
                    Tab = HumanDiseaseReportDeduplicationTabEnum.Test;
                    OnTabChange(6);
                    break;
                case 7:
                    HumanDiseaseReportDeduplicationService.Tab = HumanDiseaseReportDeduplicationTabEnum.CaseInvestigation;
                    Tab = HumanDiseaseReportDeduplicationTabEnum.CaseInvestigation;
                    OnTabChange(7);
                    break;
                case 8:
                    HumanDiseaseReportDeduplicationService.Tab = HumanDiseaseReportDeduplicationTabEnum.RiskFactors;
                    Tab = HumanDiseaseReportDeduplicationTabEnum.RiskFactors;
                    OnTabChange(8);
                    break;
                case 9:
                    HumanDiseaseReportDeduplicationService.Tab = HumanDiseaseReportDeduplicationTabEnum.ContactList;
                    Tab = HumanDiseaseReportDeduplicationTabEnum.ContactList;
                    OnTabChange(9);
                    break;
                case 10:
                    HumanDiseaseReportDeduplicationService.Tab = HumanDiseaseReportDeduplicationTabEnum.FinalOutcome;
                    Tab = HumanDiseaseReportDeduplicationTabEnum.FinalOutcome;
                    OnTabChange(10);
                    break;
            }
            await InvokeAsync(StateHasChanged);
        }

        protected async Task CancelReviewClicked()
        {
            try
            {
                var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage, null).ConfigureAwait(false);
                if (result is DialogReturnResult returnResult && returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                {
                    //cancel search and user said yes
                    source?.Cancel();
                    shouldRender = false;

                    var uri = string.Empty;
                    //if (Model.ReportType == VeterinaryReportTypeEnum.Avian)
                    //    uri = $"{NavManager.BaseUri}Administration/Deduplication/VeterinaryDiseaseReportDeduplication/AvianDiseaseReportDeduplication?showSelectedRecordsIndicator=true";
                    //else
                        uri = $"{NavManager.BaseUri}Administration/HumanDiseaseReportDeduplication?showSelectedRecordsIndicator=true";
                    

                    NavManager.NavigateTo(uri, true);
                }
                else
                {
                    //cancel search but user said no so leave everything alone and cancel thread
                    source?.Cancel();
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex, ex.Message);
                throw;
            }
        }







        #endregion
    }
}
