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
    public class NotificationBase : HumanDiseaseReportDeduplicationBaseComponent, IDisposable
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

        protected async Task OnCheckAllNotificationChangeAsync(bool value)
        {
            if (value == true)
            {
                chkCheckAll = true;
                chkCheckAll2 = false;
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, chkCheckAll, chkCheckAll2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList, "ValidNotification");
                TabNotificationValid();
            }
            else
            {
                await BindTabNotificationAsync();
            }
        }

        protected async Task OnCheckAllNotification2ChangeAsync(bool value)
        {
            if (value == true)
            {
                chkCheckAll = false;
                chkCheckAll2 = true;
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, chkCheckAll2, chkCheckAll, HumanDiseaseReportDeduplicationService.SurvivorNotificationList, "ValidInfo");
                TabNotificationValid();
            }
            else
            {
                await BindTabNotificationAsync();
            }
        }

		protected async Task OnDataListNotificationSelectionChangeAsync(bool args, int index)
		{
			string value = string.Empty;
			string label = string.Empty;

			if (args == true)
			{
				HumanDiseaseReportDeduplicationService.NotificationList[index].Checked = true;
			}

			if (AllFieldValuePairsUnmatched() == true)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
				HumanDiseaseReportDeduplicationService.NotificationList[index].Checked = false;
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
				if (HumanDiseaseReportDeduplicationService.NotificationList[index].Checked)
				{
					HumanDiseaseReportDeduplicationService.NotificationList2[index].Checked = false;
					value = HumanDiseaseReportDeduplicationService.NotificationList[index].Value;

					if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.Disease)
					{
						SelectAndUnSelectIDfield(idfsFinalDiagnosis, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
					}
                    else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.PatientStatus)
                    {
                        SelectAndUnSelectIDfield(idfsHospitalizationStatus, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.ReceivedByOffice)
                    {
                        SelectAndUnSelectIDfield(idfReceivedByOffice, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                        SelectAndUnSelectIDfield(ReceivedByPerson, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                        SelectAndUnSelectIDfield(idfReceivedByPerson, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.ReceivedByPerson)
                    {
                        SelectAndUnSelectIDfield(idfReceivedByPerson, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);              
                    }
                    else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.SentByOffice)
                    {
                        SelectAndUnSelectIDfield(idfSentByOffice, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                        SelectAndUnSelectIDfield(SentByPerson, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                        SelectAndUnSelectIDfield(idfSentByPerson, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    }
                    //else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.SentByPerson)
                    //{
                    //    SelectAndUnSelectIDfield(idfSentByPerson, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.HospitalName)
                    //{
                    //    SelectAndUnSelectIDfield(idfHospital, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    //}
                }
				else
				{
					HumanDiseaseReportDeduplicationService.NotificationList2[index].Checked = true;
					value = HumanDiseaseReportDeduplicationService.NotificationList2[index].Value;

					if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.Disease)
					{
						SelectAndUnSelectIDfield(idfsFinalDiagnosis, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
					}
                    else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.PatientStatus)
                    {
                        SelectAndUnSelectIDfield(idfsHospitalizationStatus, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.ReceivedByOffice)
                    {
                        SelectAndUnSelectIDfield(idfReceivedByOffice, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                        SelectAndUnSelectIDfield(ReceivedByPerson, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                        SelectAndUnSelectIDfield(idfReceivedByPerson, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.ReceivedByPerson)
                    {
                        SelectAndUnSelectIDfield(idfReceivedByPerson, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);                      
                    }
                    else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.SentByOffice)
                    {
                        SelectAndUnSelectIDfield(idfSentByOffice, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                        SelectAndUnSelectIDfield(SentByPerson, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                        SelectAndUnSelectIDfield(idfSentByPerson, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    }
                    //else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.SentByPerson)
                    //{
                    //    SelectAndUnSelectIDfield(idfSentByPerson, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.HospitalName)
                    //{
                    //    SelectAndUnSelectIDfield(idfHospital, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    //}
                }

				if (HumanDiseaseReportDeduplicationService.SurvivorNotificationList != null)
				{
					if (HumanDiseaseReportDeduplicationService.SurvivorNotificationList.Count > 0)
					{
						label = HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Label;

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

						HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Value = value;
					}
				}

				//HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList.Where(s => s.Checked == true).Select(s => s.Index);
				//HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList2.Where(s => s.Checked == true).Select(s => s.Index);

				HumanDiseaseReportDeduplicationService.chkCheckAll = false;
				HumanDiseaseReportDeduplicationService.chkCheckAll2 = false;

				await EableDisableMergeButtonAsync();
			}
		}

        protected async Task OnDataListNotification2SelectionChangeAsync(bool args, int index)
        {
            string value = string.Empty;
            string label = string.Empty;

            if (args == true)
            {
                HumanDiseaseReportDeduplicationService.NotificationList2[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.NotificationList2[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList2.Where(s => s.Checked == true).Select(s => s.Index);

            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.NotificationList2[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList2.Where(s => s.Checked == true).Select(s => s.Index);
            }
            else
            {
                if (HumanDiseaseReportDeduplicationService.NotificationList2[index].Checked)
                {
                    HumanDiseaseReportDeduplicationService.NotificationList[index].Checked = false;
                    value = HumanDiseaseReportDeduplicationService.NotificationList2[index].Value;

                    if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.Disease)
                    {
                        SelectAndUnSelectIDfield(idfsFinalDiagnosis, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.PatientStatus)
                    {
                        SelectAndUnSelectIDfield(idfsHospitalizationStatus, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.ReceivedByOffice)
                    {
                        SelectAndUnSelectIDfield(idfReceivedByOffice, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                        SelectAndUnSelectIDfield(ReceivedByPerson, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                        SelectAndUnSelectIDfield(idfReceivedByPerson, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.ReceivedByPerson)
                    {
                        SelectAndUnSelectIDfield(idfReceivedByPerson, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);                       
                    }
                    else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.SentByOffice)
                    {
                        SelectAndUnSelectIDfield(idfSentByOffice, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                        SelectAndUnSelectIDfield(SentByPerson, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                        SelectAndUnSelectIDfield(idfSentByPerson, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    }
                    //else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.SentByPerson)
                    //{
                    //    SelectAndUnSelectIDfield(idfSentByPerson, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.HospitalName)
                    //{
                    //    SelectAndUnSelectIDfield(idfHospital, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    //}
                }
                else
                {
                    HumanDiseaseReportDeduplicationService.NotificationList[index].Checked = true;
                    value = HumanDiseaseReportDeduplicationService.NotificationList[index].Value;

                    if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.Disease)
                    {
                        SelectAndUnSelectIDfield(idfsFinalDiagnosis, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.PatientStatus)
                    {
                        SelectAndUnSelectIDfield(idfsHospitalizationStatus, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.ReceivedByOffice)
                    {
                        SelectAndUnSelectIDfield(idfReceivedByOffice, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                        SelectAndUnSelectIDfield(ReceivedByPerson, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                        SelectAndUnSelectIDfield(idfReceivedByPerson, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.ReceivedByPerson)
                    {
                        SelectAndUnSelectIDfield(idfReceivedByPerson, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    }
                    else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.SentByOffice)
                    {
                        SelectAndUnSelectIDfield(idfSentByOffice, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                        SelectAndUnSelectIDfield(SentByPerson, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                        SelectAndUnSelectIDfield(idfSentByPerson, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    }
                    //else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.SentByPerson)
                    //{
                    //    SelectAndUnSelectIDfield(idfSentByPerson, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    // }
                    //else if (HumanDiseaseReportDeduplicationService.NotificationList[index].Key == DiseasereportDeduplicationNotificationConstants.HospitalName)
                    //{
                    //    SelectAndUnSelectIDfield(idfHospital, HumanDiseaseReportDeduplicationService.NotificationList, HumanDiseaseReportDeduplicationService.NotificationList2, HumanDiseaseReportDeduplicationService.SurvivorNotificationList);
                    //}
                }

                if (HumanDiseaseReportDeduplicationService.SurvivorNotificationList != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SurvivorNotificationList.Count > 0)
                    {
                        label = HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Label;

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

                        HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Value = value;
                    }
                }

                //HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList.Where(s => s.Checked == true).Select(s => s.Index);
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList2.Where(s => s.Checked == true).Select(s => s.Index);

                HumanDiseaseReportDeduplicationService.chkCheckAll = false;
                HumanDiseaseReportDeduplicationService.chkCheckAll2 = false;

                await EableDisableMergeButtonAsync();
            }
        }
    }
}
