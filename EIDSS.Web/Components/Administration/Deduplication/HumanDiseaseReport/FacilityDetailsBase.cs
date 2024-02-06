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
    public class FacilityDetailsBase : HumanDiseaseReportDeduplicationBaseComponent, IDisposable
    {
		#region Globals

		#region Dependencies

		[Inject]
		private ILogger<FacilityDetailsBase> Logger { get; set; }

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

        protected async Task OnCheckAllFacilityDetailsChangeAsync(bool value)
        {
            if (value == true)
            {
                chkCheckAll = true;
                chkCheckAll2 = false;
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.FacilityDetailsList, HumanDiseaseReportDeduplicationService.FacilityDetailsList2, chkCheckAll, chkCheckAll2, HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList, "ValidFacilityDetails");
                TabFacilityDetailsValid();
            }
            else
            {
                await BindTabFacilityDetailsAsync();
            }
        }

        protected async Task OnCheckAllFacilityDetails2ChangeAsync(bool value)
        {
            if (value == true)
            {
                chkCheckAll = false;
                chkCheckAll2 = true;
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.FacilityDetailsList2, HumanDiseaseReportDeduplicationService.FacilityDetailsList, chkCheckAll2, chkCheckAll, HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList, "ValidFacilityDetails");
                TabFacilityDetailsValid();
            }
            else
            {
                await BindTabFacilityDetailsAsync();
            }
        }

        protected async Task OnDataListNotificationSelectionChangeAsync(bool args, int index)
		{
			string value = string.Empty;
			string label = string.Empty;

			if (args == true)
			{
				HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Checked = true;
			}

			if (AllFieldValuePairsUnmatched() == true)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
				HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Checked = false;
				//HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
				HumanDiseaseReportDeduplicationService.NotificationList[index].Checked = false;
				//HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else
			{
				if (HumanDiseaseReportDeduplicationService.FacilityDetailsList2[index].Checked)
				{
					HumanDiseaseReportDeduplicationService.FacilityDetailsList2[index].Checked = false;
					value = HumanDiseaseReportDeduplicationService.FacilityDetailsList2[index].Value;

					if (HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Key == DiseasereportDeduplicationFacilityDetailsConstants.Hospitalization)
					{
						SelectAndUnSelectIDfield(idfsYNHospitalization, HumanDiseaseReportDeduplicationService.FacilityDetailsList, HumanDiseaseReportDeduplicationService.FacilityDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList);
					}
                    else if (HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Key == DiseasereportDeduplicationFacilityDetailsConstants.FacilityFirstSoughtCare)
                    {
                        SelectAndUnSelectIDfield(idfSoughtCareFacility, HumanDiseaseReportDeduplicationService.FacilityDetailsList, HumanDiseaseReportDeduplicationService.FacilityDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Key == DiseasereportDeduplicationFacilityDetailsConstants.NonNotifiableDiagnosis)
                    {
                        SelectAndUnSelectIDfield(idfsNonNotifiableDiagnosis, HumanDiseaseReportDeduplicationService.FacilityDetailsList, HumanDiseaseReportDeduplicationService.FacilityDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Key == DiseasereportDeduplicationFacilityDetailsConstants.PreviouslySoughtCare)
                    {
                        SelectAndUnSelectIDfield(idfsYNPreviouslySoughtCare, HumanDiseaseReportDeduplicationService.FacilityDetailsList, HumanDiseaseReportDeduplicationService.FacilityDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList);              
                    }
                    else if (HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Key == DiseasereportDeduplicationFacilityDetailsConstants.HospitalName)
                    {
                        SelectAndUnSelectIDfield(idfHospital, HumanDiseaseReportDeduplicationService.FacilityDetailsList, HumanDiseaseReportDeduplicationService.FacilityDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList);
                    }
                }
				else
				{
					HumanDiseaseReportDeduplicationService.FacilityDetailsList2[index].Checked = true;
					value = HumanDiseaseReportDeduplicationService.FacilityDetailsList2[index].Value;

					if (HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Key == DiseasereportDeduplicationFacilityDetailsConstants.Hospitalization)
					{
						SelectAndUnSelectIDfield(idfsYNHospitalization, HumanDiseaseReportDeduplicationService.FacilityDetailsList2, HumanDiseaseReportDeduplicationService.FacilityDetailsList, HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList);
					}
                    else if (HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Key == DiseasereportDeduplicationFacilityDetailsConstants.FacilityFirstSoughtCare)
                    {
                        SelectAndUnSelectIDfield(idfSoughtCareFacility, HumanDiseaseReportDeduplicationService.FacilityDetailsList2, HumanDiseaseReportDeduplicationService.FacilityDetailsList, HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Key == DiseasereportDeduplicationFacilityDetailsConstants.NonNotifiableDiagnosis)
                    {
                        SelectAndUnSelectIDfield(idfsNonNotifiableDiagnosis, HumanDiseaseReportDeduplicationService.FacilityDetailsList2, HumanDiseaseReportDeduplicationService.FacilityDetailsList, HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Key == DiseasereportDeduplicationFacilityDetailsConstants.PreviouslySoughtCare)
                    {
                        SelectAndUnSelectIDfield(idfsYNPreviouslySoughtCare, HumanDiseaseReportDeduplicationService.FacilityDetailsList2, HumanDiseaseReportDeduplicationService.FacilityDetailsList, HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList);                      
                    }
                    else if (HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Key == DiseasereportDeduplicationFacilityDetailsConstants.HospitalName)
                    {
                        SelectAndUnSelectIDfield(idfHospital, HumanDiseaseReportDeduplicationService.FacilityDetailsList2, HumanDiseaseReportDeduplicationService.FacilityDetailsList, HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList);
                    }

                }

				if (HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList != null)
				{
					if (HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList.Count > 0)
					{
						label = HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList[index].Label;

						//if (value == null)
						//{
						//	HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Label = label.Replace(HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Value, "");
						//}
						//else if (HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Value == null)
						//{
						//	HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Label = label.Replace(": ", ": " + value);
						//}
						//else if (HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Value == string.Empty)
						//{
						//	HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Label = label.Replace(": ", ": " + value);
						//}
						//else
						//{
						//	HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Label = label.Replace(HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Value, value);
						//}

						HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList[index].Value = value;
					}
				}

				//HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList.Where(s => s.Checked == true).Select(s => s.Index);
				//HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList2.Where(s => s.Checked == true).Select(s => s.Index);

				HumanDiseaseReportDeduplicationService.chkCheckAllFacilityDetails = false;
				HumanDiseaseReportDeduplicationService.chkCheckAllFacilityDetails2 = false;

				await EableDisableMergeButtonAsync();
			}
		}

        protected async Task OnDataListNotification2SelectionChangeAsync(bool args, int index)
        {
            string value = string.Empty;
            string label = string.Empty;

            if (args == true)
            {
                HumanDiseaseReportDeduplicationService.FacilityDetailsList2[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.FacilityDetailsList2[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList2.Where(s => s.Checked == true).Select(s => s.Index);

            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.FacilityDetailsList2[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList2.Where(s => s.Checked == true).Select(s => s.Index);
            }
            else
            {
                if (HumanDiseaseReportDeduplicationService.FacilityDetailsList2[index].Checked)
                {
                    HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Checked = false;
                    value = HumanDiseaseReportDeduplicationService.FacilityDetailsList2[index].Value;

                    if (HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Key == DiseasereportDeduplicationFacilityDetailsConstants.Hospitalization)
                    {
                        SelectAndUnSelectIDfield(idfsYNHospitalization, HumanDiseaseReportDeduplicationService.FacilityDetailsList2, HumanDiseaseReportDeduplicationService.FacilityDetailsList, HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Key == DiseasereportDeduplicationFacilityDetailsConstants.FacilityFirstSoughtCare)
                    {
                        SelectAndUnSelectIDfield(idfSoughtCareFacility, HumanDiseaseReportDeduplicationService.FacilityDetailsList2, HumanDiseaseReportDeduplicationService.FacilityDetailsList, HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Key == DiseasereportDeduplicationFacilityDetailsConstants.NonNotifiableDiagnosis)
                    {
                        SelectAndUnSelectIDfield(idfsNonNotifiableDiagnosis, HumanDiseaseReportDeduplicationService.FacilityDetailsList2, HumanDiseaseReportDeduplicationService.FacilityDetailsList, HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Key == DiseasereportDeduplicationFacilityDetailsConstants.PreviouslySoughtCare)
                    {
                        SelectAndUnSelectIDfield(idfsYNPreviouslySoughtCare, HumanDiseaseReportDeduplicationService.FacilityDetailsList2, HumanDiseaseReportDeduplicationService.FacilityDetailsList, HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList);                       
                    }
                    else if (HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Key == DiseasereportDeduplicationFacilityDetailsConstants.HospitalName)
                    {
                        SelectAndUnSelectIDfield(idfHospital, HumanDiseaseReportDeduplicationService.FacilityDetailsList2, HumanDiseaseReportDeduplicationService.FacilityDetailsList, HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList);
                    }
                }
                else
                {
                    HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Checked = true;
                    value = HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Value;

                    if (HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Key == DiseasereportDeduplicationFacilityDetailsConstants.Hospitalization)
                    {
                        SelectAndUnSelectIDfield(idfsFinalDiagnosis, HumanDiseaseReportDeduplicationService.FacilityDetailsList, HumanDiseaseReportDeduplicationService.FacilityDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Key == DiseasereportDeduplicationFacilityDetailsConstants.FacilityFirstSoughtCare)
                    {
                        SelectAndUnSelectIDfield(idfSoughtCareFacility, HumanDiseaseReportDeduplicationService.FacilityDetailsList, HumanDiseaseReportDeduplicationService.FacilityDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Key == DiseasereportDeduplicationFacilityDetailsConstants.NonNotifiableDiagnosis)
                    {
                        SelectAndUnSelectIDfield(idfsNonNotifiableDiagnosis, HumanDiseaseReportDeduplicationService.FacilityDetailsList, HumanDiseaseReportDeduplicationService.FacilityDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Key == DiseasereportDeduplicationFacilityDetailsConstants.PreviouslySoughtCare)
                    {
                        SelectAndUnSelectIDfield(idfsYNPreviouslySoughtCare, HumanDiseaseReportDeduplicationService.FacilityDetailsList, HumanDiseaseReportDeduplicationService.FacilityDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.FacilityDetailsList[index].Key == DiseasereportDeduplicationFacilityDetailsConstants.HospitalName)
                    {
                        SelectAndUnSelectIDfield(idfHospital, HumanDiseaseReportDeduplicationService.FacilityDetailsList, HumanDiseaseReportDeduplicationService.FacilityDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList);
                    }
                }

                if (HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList.Count > 0)
                    {
                        label = HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList[index].Label;

                        //if (value == null)
                        //{
                        //	HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Label = label.Replace(HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Value, "");
                        //}
                        //else if (HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Value == null)
                        //{
                        //	HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Label = label.Replace(": ", ": " + value);
                        //}
                        //else if (HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Value == string.Empty)
                        //{
                        //	HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Label = label.Replace(": ", ": " + value);
                        //}
                        //else
                        //{
                        //	HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Label = label.Replace(HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Value, value);
                        //}

                        HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList[index].Value = value;
                    }
                }

                //HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList.Where(s => s.Checked == true).Select(s => s.Index);
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList2.Where(s => s.Checked == true).Select(s => s.Index);

                HumanDiseaseReportDeduplicationService.chkCheckAllFacilityDetails = false;
                HumanDiseaseReportDeduplicationService.chkCheckAllFacilityDetails2 = false;

                await EableDisableMergeButtonAsync();
            }
        }
    }
}
