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
    public class CaseInvestigationDetailsBase : HumanDiseaseReportDeduplicationBaseComponent, IDisposable
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

        protected async Task OnCheckAllCaseinvestigationDetailsChangeAsync(bool value)
        {
            if (value == true)
            {
                chkCheckAll = true;
                chkCheckAll2 = false;
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, chkCheckAll, chkCheckAll2, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList, "ValidCaseInvestigationDetails");
                TabCaseInvestigationDetailsValid();
            }
            else
            {
                await BindTabCaseInvestigationDetailsAsync();
            }
        }

        protected async Task OnCheckAllCaseInvestigationDetails2ChangeAsync(bool value)
        {
            if (value == true)
            {
                chkCheckAll = false;
                chkCheckAll2 = true;
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, chkCheckAll2, chkCheckAll, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList, "ValidCaseInvestigationDetails2");
                TabCaseInvestigationDetailsValid();
            }
            else
            {
                await BindTabCaseInvestigationDetailsAsync();
            }
        }

		protected async Task OnDataListCaseInvestigationDetailsSelectionChangeAsync(bool args, int index)
		{
			string value = string.Empty;
			string label = string.Empty;

			if (args == true)
			{
				HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Checked = true;
			}

			if (AllFieldValuePairsUnmatched() == true)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
				HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Checked = false;
				//HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
				HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Checked = false;
				//HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else
			{
				if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Checked)
				{
					HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2[index].Checked = false;
					value = HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Value;

					if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.InvestigatedByOffice)
					{
						SelectAndUnSelectIDfield(idfInvestigatedByOffice, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
					}
                    //else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.Country)
                    //{
                    //    SelectAndUnSelectIDfield(idfsPointCountry, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    //}
                    else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.ExposureLocationKnown)
                    {
                        SelectAllAndUnSelectAll(index, ExposureLocationFIELD, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                        //SelectAndUnSelectIDfield(idfsYNExposureLocationKnown, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    }
                    //else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.LocationType)
                    //{
                    //    SelectAndUnSelectIDfield(idfsPointGeoLocationType, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);              
                    //}
                    else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.Outbreak)
                    {
                        SelectAndUnSelectIDfield(idfOutbreak, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    }
                    //else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.Rayon)
                    //{
                    //    SelectAndUnSelectIDfield(idfsPointRayon, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.Region)
                    //{
                    //    SelectAndUnSelectIDfield(idfsPointRegion, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.Settlement)
                    //{
                    //    SelectAndUnSelectIDfield(idfsPointSettlement, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.RelatedToOutbreakID)
                    //{
                    //    SelectAndUnSelectIDfield(idfHospital, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    //}
                }
				else
				{
					HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2[index].Checked = true;
					value = HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2[index].Value;

					if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.InvestigatedByOffice)
					{
						SelectAndUnSelectIDfield(idfsFinalDiagnosis, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
					}
                    //else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.Country)
                    //{
                    //    SelectAndUnSelectIDfield(idfsPointCountry, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    //}
                    else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.ExposureLocationKnown)
                    {
                        //SelectAndUnSelectIDfield(idfsYNExposureLocationKnown, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                        SelectAllAndUnSelectAll(index, ExposureLocationFIELD, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    }
                    //else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.LocationType)
                    //{
                    //    SelectAndUnSelectIDfield(idfsPointGeoLocationType, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);                      
                    //}
                    else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.Outbreak)
                    {
                        SelectAndUnSelectIDfield(idfOutbreak, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    }
                    //else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.Rayon)
                    //{
                    //    SelectAndUnSelectIDfield(idfsPointRayon, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.Region)
                    //{
                    //    SelectAndUnSelectIDfield(idfsPointRegion, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.Settlement)
                    //{
                    //    SelectAndUnSelectIDfield(idfsPointSettlement, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    //}
                }

				if (HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList != null)
				{
					if (HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList.Count > 0)
					{
						label = HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList[index].Label;

						

						HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList[index].Value = value;
					}
				}

			
				HumanDiseaseReportDeduplicationService.chkCheckAllCaseInvestigation = false;
				HumanDiseaseReportDeduplicationService.chkCheckAllCaseInvestigation2 = false;

				await EnableDisableMergeButtonAsync();
			}
		}

        protected async Task OnDataListCaseInvestigationDetails2SelectionChangeAsync(bool args, int index)
        {
            string value = string.Empty;
            string label = string.Empty;

            if (args == true)
            {
                HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2.Where(s => s.Checked == true).Select(s => s.Index);

            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2.Where(s => s.Checked == true).Select(s => s.Index);
            }
            else
            {
                if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2[index].Checked)
                {
                    HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Checked = false;
                    value = HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2[index].Value;

                    if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.InvestigatedByOffice)
                    {
                        SelectAndUnSelectIDfield(idfInvestigatedByOffice, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    }
                    //else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.Country)
                    //{
                    //    SelectAndUnSelectIDfield(idfsPointCountry, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    //}
                    else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.ExposureLocationKnown)
                    {
                        SelectAllAndUnSelectAll(index, ExposureLocationFIELD, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                        //SelectAndUnSelectIDfield(idfsYNExposureLocationKnown, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    }
                    //else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.LocationType)
                    //{
                    //    SelectAndUnSelectIDfield(idfsPointGeoLocationType, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);                       
                    //}
                    else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.Outbreak)
                    {
                        SelectAndUnSelectIDfield(idfOutbreak, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    }
                    //else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.Rayon)
                    //{
                    //    SelectAndUnSelectIDfield(idfsPointRayon, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.Region)
                    //{
                    //    SelectAndUnSelectIDfield(idfsPointRegion, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.Settlement)
                    //{
                    //    SelectAndUnSelectIDfield(idfsPointSettlement, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    //}
                }
                else
                {
                    HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Checked = true;
                    value = HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Value;

                    if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.InvestigatedByOffice)
                    {
                        SelectAndUnSelectIDfield(idfInvestigatedByOffice, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    }
                    //else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.Country)
                    //{
                    //    SelectAndUnSelectIDfield(idfsPointCountry, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    //}
                    else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.ExposureLocationKnown)
                    {
                        SelectAllAndUnSelectAll(index, ExposureLocationFIELD, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                        //SelectAndUnSelectIDfield(idfsYNExposureLocationKnown, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    }
                    //else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.LocationType)
                    //{
                    //    SelectAndUnSelectIDfield(idfsPointGeoLocationType, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    //}
                    else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.Outbreak)
                    {
                        SelectAndUnSelectIDfield(idfOutbreak, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    }
                    //else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.Rayon)
                    //{
                    //    SelectAndUnSelectIDfield(idfsPointRayon, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.Region)
                    //{
                    //    SelectAndUnSelectIDfield(idfsPointRegion, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[index].Key == DiseasereportDeduplicationCaseInvestigationDetailsConstants.Settlement)
                    //{
                    //    SelectAndUnSelectIDfield(idfsPointSettlement, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList, HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2, HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList);
                    //}
                }

                if (HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList.Count > 0)
                    {
                        label = HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList[index].Label;

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

                        HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList[index].Value = value;
                    }
                }

                //HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList.Where(s => s.Checked == true).Select(s => s.Index);
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2.Where(s => s.Checked == true).Select(s => s.Index);

                HumanDiseaseReportDeduplicationService.chkCheckAllCaseInvestigation = false;
                HumanDiseaseReportDeduplicationService.chkCheckAllCaseInvestigation2 = false;

                await EnableDisableMergeButtonAsync();
            }
        }
    }
}
