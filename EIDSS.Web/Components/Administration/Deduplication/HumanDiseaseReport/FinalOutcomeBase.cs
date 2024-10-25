using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.SubAreas.Deduplication.ViewModels.PersonDeduplication;
using EIDSS.Web.Areas.Administration.ViewModels.Administration.HumanDiseaseReportDeduplication;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Administration.Deduplication.HumanDiseaseReport
{
    public class FinalOutcomeBase : HumanDiseaseReportDeduplicationBaseComponent, IDisposable
    {
		#region Globals

		#region Dependencies

		[Inject]
		private ILogger<NotificationBase> Logger { get; set; }

        #endregion

        #region Parameters
        public HumanDiseaseReportDeduplicationDetailsViewModel Model { get; set; }

		#endregion

		#region Protected and Public Members
		protected RadzenRadioButtonList<int?> rboRecord;
		protected int? value { get; set; }
		protected RadzenRadioButtonList<int?> rboRecord2;
		protected int? value2 { get; set; }
		protected bool chkCheckAll { get; set; }
		protected bool chkCheckAll2 { get; set; }


        protected RadzenCheckBoxList<int> rcblInfo;
		protected RadzenCheckBoxList<int> rcblInfo2;

		#endregion

		#region Private Member Variables

		private CancellationTokenSource source;
		private CancellationToken token;



		#endregion

		#endregion

		protected override async Task OnInitializedAsync()
		{
			// Wire up PersonDeduplication state container service
			HumanDiseaseReportDeduplicationService.OnChange += async (property) => await OnStateContainerChangeAsync(property);

			await base.OnInitializedAsync();
			StateHasChanged();
		}
		private async Task OnStateContainerChangeAsync(string property)
		{
			await InvokeAsync(StateHasChanged);
		}

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

        protected async Task OnCheckAllFinalOutcomeChangeAsync(bool value)
        {
            if (value == true)
            {
                chkCheckAll = true;
                chkCheckAll2 = false;
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.FinalOutcomeList, HumanDiseaseReportDeduplicationService.FinalOutcomeList2, chkCheckAll, chkCheckAll2, HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList, "ValidCaseInvestigationDetails");
                TabFinalOutcomeValid();
            }
            else
            {
                await BindTabFinalOutcomeAsync();
            }
        }

        protected async Task OnCheckAllFinalOutcome2ChangeAsync(bool value)
        {
            if (value == true)
            {
                chkCheckAll = false;
                chkCheckAll2 = true;
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.FinalOutcomeList2, HumanDiseaseReportDeduplicationService.FinalOutcomeList, chkCheckAll2, chkCheckAll, HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList, "ValidCaseInvestigationDetails2");
                TabFinalOutcomeValid();
            }
            else
            {
                await BindTabFinalOutcomeAsync();
            }
        }

		protected async Task OnDataListFinalOutcomeSelectionChangeAsync(bool args, int index)
		{
			string value = string.Empty;
			string label = string.Empty;

			if (args == true)
			{
				HumanDiseaseReportDeduplicationService.FinalOutcomeList[index].Checked = true;
			}

			if (AllFieldValuePairsUnmatched() == true)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
				HumanDiseaseReportDeduplicationService.FinalOutcomeList[index].Checked = false;
				//HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.FinalOutcomeList.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
				HumanDiseaseReportDeduplicationService.FinalOutcomeList[index].Checked = false;
				//HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.FinalOutcomeList.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else
			{
				if (HumanDiseaseReportDeduplicationService.FinalOutcomeList[index].Checked)
				{
					HumanDiseaseReportDeduplicationService.FinalOutcomeList2[index].Checked = false;
					value = HumanDiseaseReportDeduplicationService.FinalOutcomeList[index].Value;

					if (HumanDiseaseReportDeduplicationService.FinalOutcomeList[index].Key == DiseasereportDeduplicationFinalOutcomeConstants.FinalCaseStatus)
					{
						SelectAndUnSelectIDfield(idfsFinalCaseStatus, HumanDiseaseReportDeduplicationService.FinalOutcomeList, HumanDiseaseReportDeduplicationService.FinalOutcomeList2, HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList);
					}
                    else if (HumanDiseaseReportDeduplicationService.FinalOutcomeList[index].Key == DiseasereportDeduplicationFinalOutcomeConstants.Outcome)
                    {
                        SelectAndUnSelectIDfield(idfsOutcome, HumanDiseaseReportDeduplicationService.FinalOutcomeList, HumanDiseaseReportDeduplicationService.FinalOutcomeList2, HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.FinalOutcomeList[index].Key == DiseasereportDeduplicationFinalOutcomeConstants.strEpidemiologistsName)
                    {
                        SelectAndUnSelectIDfield(idfInvestigatedByPerson, HumanDiseaseReportDeduplicationService.FinalOutcomeList, HumanDiseaseReportDeduplicationService.FinalOutcomeList2, HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList);
                    }
                   
                }
				else
				{
					HumanDiseaseReportDeduplicationService.FinalOutcomeList2[index].Checked = true;
					value = HumanDiseaseReportDeduplicationService.FinalOutcomeList2[index].Value;

					if (HumanDiseaseReportDeduplicationService.FinalOutcomeList[index].Key == DiseasereportDeduplicationFinalOutcomeConstants.FinalCaseStatus)
					{
						SelectAndUnSelectIDfield(idfsFinalCaseStatus, HumanDiseaseReportDeduplicationService.FinalOutcomeList2, HumanDiseaseReportDeduplicationService.FinalOutcomeList, HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList);
					}
                    else if (HumanDiseaseReportDeduplicationService.FinalOutcomeList[index].Key == DiseasereportDeduplicationFinalOutcomeConstants.Outcome)
                    {
                        SelectAndUnSelectIDfield(idfsOutcome, HumanDiseaseReportDeduplicationService.FinalOutcomeList2, HumanDiseaseReportDeduplicationService.FinalOutcomeList, HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.FinalOutcomeList[index].Key == DiseasereportDeduplicationFinalOutcomeConstants.strEpidemiologistsName)
                    {
                        SelectAndUnSelectIDfield(idfInvestigatedByPerson, HumanDiseaseReportDeduplicationService.FinalOutcomeList2, HumanDiseaseReportDeduplicationService.FinalOutcomeList, HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList);
                    }
                   
                }

				if (HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList != null)
				{
					if (HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList.Count > 0)
					{
						label = HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList[index].Label;

						

						HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList[index].Value = value;
					}
				}

			
				HumanDiseaseReportDeduplicationService.chkCheckAllFinalOutcome = false;
				HumanDiseaseReportDeduplicationService.chkCheckAllFinalOutcome2 = false;

				await EnableDisableMergeButtonAsync();
			}
		}

        protected async Task OnDataListFinalOutcome2SelectionChangeAsync(bool args, int index)
        {
            string value = string.Empty;
            string label = string.Empty;

            if (args == true)
            {
                HumanDiseaseReportDeduplicationService.FinalOutcomeList2[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.FinalOutcomeList2[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.FinalOutcomeList2.Where(s => s.Checked == true).Select(s => s.Index);

            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.FinalOutcomeList2[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.FinalOutcomeList2.Where(s => s.Checked == true).Select(s => s.Index);
            }
            else
            {
                if (HumanDiseaseReportDeduplicationService.FinalOutcomeList2[index].Checked)
                {
                    HumanDiseaseReportDeduplicationService.FinalOutcomeList[index].Checked = false;
                    value = HumanDiseaseReportDeduplicationService.FinalOutcomeList2[index].Value;

                    if (HumanDiseaseReportDeduplicationService.FinalOutcomeList[index].Key == DiseasereportDeduplicationFinalOutcomeConstants.FinalCaseStatus)
                    {
                        SelectAndUnSelectIDfield(idfsFinalCaseStatus, HumanDiseaseReportDeduplicationService.FinalOutcomeList2, HumanDiseaseReportDeduplicationService.FinalOutcomeList, HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.FinalOutcomeList[index].Key == DiseasereportDeduplicationFinalOutcomeConstants.Outcome)
                    {
                        SelectAndUnSelectIDfield(idfsOutcome, HumanDiseaseReportDeduplicationService.FinalOutcomeList2, HumanDiseaseReportDeduplicationService.FinalOutcomeList, HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.FinalOutcomeList[index].Key == DiseasereportDeduplicationFinalOutcomeConstants.strEpidemiologistsName)
                    {
                        SelectAndUnSelectIDfield(idfInvestigatedByPerson, HumanDiseaseReportDeduplicationService.FinalOutcomeList2, HumanDiseaseReportDeduplicationService.FinalOutcomeList, HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList);
                    }
                    
                }
                else
                {
                    HumanDiseaseReportDeduplicationService.FinalOutcomeList[index].Checked = true;
                    value = HumanDiseaseReportDeduplicationService.FinalOutcomeList[index].Value;

                    if (HumanDiseaseReportDeduplicationService.FinalOutcomeList[index].Key == DiseasereportDeduplicationFinalOutcomeConstants.FinalCaseStatus)
                    {
                        SelectAndUnSelectIDfield(idfsFinalCaseStatus, HumanDiseaseReportDeduplicationService.FinalOutcomeList, HumanDiseaseReportDeduplicationService.FinalOutcomeList2, HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.FinalOutcomeList[index].Key == DiseasereportDeduplicationFinalOutcomeConstants.Outcome)
                    {
                        SelectAndUnSelectIDfield(idfsOutcome, HumanDiseaseReportDeduplicationService.FinalOutcomeList, HumanDiseaseReportDeduplicationService.FinalOutcomeList2, HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.FinalOutcomeList[index].Key == DiseasereportDeduplicationFinalOutcomeConstants.strEpidemiologistsName)
                    {
                        SelectAndUnSelectIDfield(idfInvestigatedByPerson, HumanDiseaseReportDeduplicationService.FinalOutcomeList, HumanDiseaseReportDeduplicationService.FinalOutcomeList2, HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList);
                    }
                    
                }

                if (HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList.Count > 0)
                    {
                        label = HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList[index].Label;

                        //if (value == null)
                        //{
                        //	HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList[index].Label = label.Replace(HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList[index].Value, "");
                        //}
                        //else if (HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList[index].Value == null)
                        //{
                        //	HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList[index].Label = label.Replace(": ", ": " + value);
                        //}
                        //else if (HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList[index].Value == string.Empty)
                        //{
                        //	HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList[index].Label = label.Replace(": ", ": " + value);
                        //}
                        //else
                        //{
                        //	HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList[index].Label = label.Replace(HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList[index].Value, value);
                        //}

                        HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList[index].Value = value;
                    }
                }

                //HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.FinalOutcomeList.Where(s => s.Checked == true).Select(s => s.Index);
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.FinalOutcomeList2.Where(s => s.Checked == true).Select(s => s.Index);

                HumanDiseaseReportDeduplicationService.chkCheckAllFinalOutcome = false;
                HumanDiseaseReportDeduplicationService.chkCheckAllFinalOutcome2 = false;

                await EnableDisableMergeButtonAsync();
            }
        }
    }
}
