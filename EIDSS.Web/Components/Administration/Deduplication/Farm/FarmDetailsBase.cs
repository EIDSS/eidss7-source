using EIDSS.Web.Areas.Administration.SubAreas.Deduplication.ViewModels.FarmDeduplication;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using System;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;
using EIDSS.Localization.Constants;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Administration.Deduplication.Farm
{
    public class FarmDetailsBase : FarmDeduplicationBaseComponent, IDisposable
    {
        #region Dependencies

        [Inject]
        private ILogger<FarmDetailsBase> Logger { get; set; }

        #endregion

        #region Parameters
        public FarmDeduplicationDetailsViewModel Model { get; set; }

        #endregion

        #region Protected and Public Members

        #endregion

        #region Private Member Variables

        private CancellationTokenSource source;
        private CancellationToken token;

        #endregion

        protected override async Task OnInitializedAsync()
		{
			// Wire up PersonDeduplication state container service
			FarmDeduplicationService.OnChange += async (property) => await OnStateContainerChangeAsync(property);

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

				FarmDeduplicationService.OnChange -= async (property) => await OnStateContainerChangeAsync(property);

			}
			catch (Exception)
			{
				throw;
			}
		}

		protected async Task OnCheckAllInfoChangeAsync(bool value)
		{
			if (value == true)
			{
                await CheckAllAsync(FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2, true, false, FarmDeduplicationService.SurvivorInfoList, "ValidInfo");
                TabFarmDetailsValid();
                //await EableDisableMergeButtonAsync();
                disableMergeButton = false;

                //await InvokeAsync(StateHasChanged);
            }
            else
			{
				await BindTabFarmDetailsAsync();
			}
		}

		protected async Task OnCheckAllInfo2ChangeAsync(bool value)
		{
			if (value == true)
			{
                await CheckAllAsync(FarmDeduplicationService.InfoList2, FarmDeduplicationService.InfoList, true, false, FarmDeduplicationService.SurvivorInfoList, "ValidInfo");
                TabFarmDetailsValid();
                //await EableDisableMergeButtonAsync();
                disableMergeButton = false;

                //await InvokeAsync(StateHasChanged);
			}
            else
			{
				await BindTabFarmDetailsAsync();
			}
		}

		protected async Task OnCheckBoxListInfoSelectionChangeAsync(IEnumerable<int> values)
		{
			string value = string.Empty;
			string label = string.Empty;
			IEnumerable<int> list = (IEnumerable<int>)FarmDeduplicationService.InfoList.Where(s => s.Checked == true).Select(s => s.Index);
			int index = 0;

			if (values.Count() > list.Count())
			{
				index = values.ElementAt(values.Count() - 1);
				FarmDeduplicationService.InfoList[index].Checked = true;
			}
			else
			{
				IEnumerable<int> difference = list.Except(values);
				index = difference.ElementAt(0);
				FarmDeduplicationService.InfoList[index].Checked = false;
			}

			if (AllFieldValuePairsUnmatched() == true)
			{
				await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
				FarmDeduplicationService.InfoList[index].Checked = false;
				FarmDeduplicationService.InfoValues = (IEnumerable<int>)FarmDeduplicationService.InfoList.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else if (FarmDeduplicationService.RecordSelection == 0 && FarmDeduplicationService.Record2Selection == 0)
			{
				await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
				FarmDeduplicationService.InfoList[index].Checked = false;
				FarmDeduplicationService.InfoValues = (IEnumerable<int>)FarmDeduplicationService.InfoList.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else
			{
				if (FarmDeduplicationService.InfoList[index].Checked)
				{
					FarmDeduplicationService.InfoList2[index].Checked = false;
					value = FarmDeduplicationService.InfoList[index].Value;
					if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.FarmType)
					{
						SelectAndUnSelectIDfield(FarmTypeID, FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2, FarmDeduplicationService.SurvivorInfoList);
					}
					else if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.Country)
					{
						SelectAndUnSelectIDfield(FarmCountryID, FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2, FarmDeduplicationService.SurvivorInfoList);
					}
					else if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.EIDSSFarmOwnerID)
					{
						SelectAndUnSelectIDfield(FarmOwnerID, FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2, FarmDeduplicationService.SurvivorInfoList);
					}
					else if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.Region)
					{
						SelectAllAndUnSelectAll(index, ADDRESSNUMBERFIELD, FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2, FarmDeduplicationService.SurvivorInfoList);
						SelectAllAndUnSelectAll(RegionID, ADDRESSIDNUMBERFIELD, FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2, FarmDeduplicationService.SurvivorInfoList);
						//SelectAllAndUnSelectAll(RegionID, ADDRESSIDNUMBERFIELD, FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2, FarmDeduplicationService.SurvivorInfoList);
					}
				}
				else
				{
					FarmDeduplicationService.InfoList2[index].Checked = true;
					value = FarmDeduplicationService.InfoList2[index].Value;
					if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.FarmType)
					{
						SelectAndUnSelectIDfield(FarmTypeID, FarmDeduplicationService.InfoList2, FarmDeduplicationService.InfoList, FarmDeduplicationService.SurvivorInfoList);
					}
					else if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.Country)
					{
						SelectAndUnSelectIDfield(FarmCountryID, FarmDeduplicationService.InfoList2, FarmDeduplicationService.InfoList, FarmDeduplicationService.SurvivorInfoList);
					}
					else if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.EIDSSFarmOwnerID)
					{
						SelectAndUnSelectIDfield(FarmOwnerID, FarmDeduplicationService.InfoList2, FarmDeduplicationService.InfoList, FarmDeduplicationService.SurvivorInfoList);
					}
					else if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.Region)
					{
						SelectAllAndUnSelectAll(index, ADDRESSNUMBERFIELD, FarmDeduplicationService.InfoList2, FarmDeduplicationService.InfoList, FarmDeduplicationService.SurvivorInfoList);
						SelectAllAndUnSelectAll(RegionID, ADDRESSIDNUMBERFIELD, FarmDeduplicationService.InfoList2, FarmDeduplicationService.InfoList, FarmDeduplicationService.SurvivorInfoList);
						//SelectAllAndUnSelectAll(RegionID, ADDRESSIDNUMBERFIELD, FarmDeduplicationService.InfoList2, FarmDeduplicationService.InfoList, FarmDeduplicationService.SurvivorInfoList);
					}
				}

				if (FarmDeduplicationService.SurvivorInfoList != null)
				{
					if (FarmDeduplicationService.SurvivorInfoList.Count > 0)
					{
						label = FarmDeduplicationService.SurvivorInfoList[index].Label;

						if (value == null)
						{
							FarmDeduplicationService.SurvivorInfoList[index].Label = label.Replace(FarmDeduplicationService.SurvivorInfoList[index].Value, "");
						}
						else if (FarmDeduplicationService.SurvivorInfoList[index].Value == null)
						{
							//FarmDeduplicationService.SurvivorInfoList[index].Label = label.Replace("<br><font style='color:#333;font-size:12px;font-weight:normal'>", "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + value);
							FarmDeduplicationService.SurvivorInfoList[index].Label = label.Replace(": ", ": " + value);
						}
						else if (FarmDeduplicationService.SurvivorInfoList[index].Value == string.Empty)
						{
							//FarmDeduplicationService.SurvivorInfoList[index].Label = label.Replace("<br><font style='color:#333;font-size:12px;font-weight:normal'>", "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + value);
							FarmDeduplicationService.SurvivorInfoList[index].Label = label.Replace(": ", ": " + value);
						}
						else
						{
							FarmDeduplicationService.SurvivorInfoList[index].Label = label.Replace(FarmDeduplicationService.SurvivorInfoList[index].Value, value);
						}

						FarmDeduplicationService.SurvivorInfoList[index].Value = value;
					}
				}

				FarmDeduplicationService.InfoValues = (IEnumerable<int>)FarmDeduplicationService.InfoList.Where(s => s.Checked == true).Select(s => s.Index);
				FarmDeduplicationService.InfoValues2 = (IEnumerable<int>)FarmDeduplicationService.InfoList2.Where(s => s.Checked == true).Select(s => s.Index);

				FarmDeduplicationService.chkCheckAll = false;
				FarmDeduplicationService.chkCheckAll2 = false;

				TabFarmDetailsValid();
				await EnableDisableMergeButtonAsync();
			}
		}

		protected async Task OnCheckBoxListInfo2SelectionChangeAsync(IEnumerable<int> values)
		{
			string value = string.Empty;
			string label = string.Empty;
			IEnumerable<int> list = (IEnumerable<int>)FarmDeduplicationService.InfoList2.Where(s => s.Checked == true).Select(s => s.Index);
			int index = 0;

			if (values.Count() > list.Count())
			{
				index = values.ElementAt(values.Count() - 1);
				FarmDeduplicationService.InfoList2[index].Checked = true;
			}
			else
			{
				IEnumerable<int> difference = list.Except(values);
				index = difference.ElementAt(0);
				FarmDeduplicationService.InfoList2[index].Checked = false;
			}

			if (AllFieldValuePairsUnmatched() == true)
			{
				await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
				FarmDeduplicationService.InfoList2[index].Checked = false;
				FarmDeduplicationService.InfoValues2 = (IEnumerable<int>)FarmDeduplicationService.InfoList2.Where(s => s.Checked == true).Select(s => s.Index);

			}
			else if (FarmDeduplicationService.RecordSelection == 0 && FarmDeduplicationService.Record2Selection == 0)
			{
				await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
				FarmDeduplicationService.InfoList2[index].Checked = false;
				FarmDeduplicationService.InfoValues2 = (IEnumerable<int>)FarmDeduplicationService.InfoList2.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else
			{
				if (FarmDeduplicationService.InfoList2[index].Checked)
				{
					FarmDeduplicationService.InfoList[index].Checked = false;
					value = FarmDeduplicationService.InfoList2[index].Value;
					if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.FarmType)
					{
						SelectAndUnSelectIDfield(FarmTypeID, FarmDeduplicationService.InfoList2, FarmDeduplicationService.InfoList, FarmDeduplicationService.SurvivorInfoList);
					}
					else if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.Country)
					{
						SelectAndUnSelectIDfield(FarmCountryID, FarmDeduplicationService.InfoList2, FarmDeduplicationService.InfoList, FarmDeduplicationService.SurvivorInfoList);
					}
					else if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.Region)
					{
						SelectAllAndUnSelectAll(index, ADDRESSNUMBERFIELD, FarmDeduplicationService.InfoList2, FarmDeduplicationService.InfoList, FarmDeduplicationService.SurvivorInfoList);
						SelectAllAndUnSelectAll(RegionID, ADDRESSIDNUMBERFIELD, FarmDeduplicationService.InfoList2, FarmDeduplicationService.InfoList, FarmDeduplicationService.SurvivorInfoList);
					}
				}
				else
				{
					FarmDeduplicationService.InfoList[index].Checked = true;
					value = FarmDeduplicationService.InfoList[index].Value;
					if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.FarmType)
					{
						SelectAndUnSelectIDfield(FarmTypeID, FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2, FarmDeduplicationService.SurvivorInfoList);
					}
					else if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.Country)
					{
						SelectAndUnSelectIDfield(FarmCountryID, FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2, FarmDeduplicationService.SurvivorInfoList);
					}
					else if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.Region)
					{
						SelectAllAndUnSelectAll(index, ADDRESSNUMBERFIELD, FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2, FarmDeduplicationService.SurvivorInfoList);
						SelectAllAndUnSelectAll(RegionID, ADDRESSIDNUMBERFIELD, FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2, FarmDeduplicationService.SurvivorInfoList);
						//SelectAllAndUnSelectAll(RegionID, ADDRESSIDNUMBERFIELD, FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2, FarmDeduplicationService.SurvivorInfoList);
					}
				}

				if (FarmDeduplicationService.SurvivorInfoList != null)
				{
					if (FarmDeduplicationService.SurvivorInfoList.Count > 0)
					{
						label = FarmDeduplicationService.SurvivorInfoList[index].Label;

						if (value == null)
						{
							FarmDeduplicationService.SurvivorInfoList[index].Label = label.Replace(FarmDeduplicationService.SurvivorInfoList[index].Value, "");
						}
						else if (FarmDeduplicationService.SurvivorInfoList[index].Value == null)
						{
							//FarmDeduplicationService.SurvivorInfoList[index].Label = label.Replace("<br><font style='color:#333;font-size:12px;font-weight:normal'>", "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + value);
							FarmDeduplicationService.SurvivorInfoList[index].Label = label.Replace(": ", ": " + value);
						}
						else if (FarmDeduplicationService.SurvivorInfoList[index].Value == string.Empty)
						{
							//FarmDeduplicationService.SurvivorInfoList[index].Label = label.Replace("<br><font style='color:#333;font-size:12px;font-weight:normal'>", "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + value);
							FarmDeduplicationService.SurvivorInfoList[index].Label = label.Replace(": ", ": " + value);
						}
						else
						{
							FarmDeduplicationService.SurvivorInfoList[index].Label = label.Replace(FarmDeduplicationService.SurvivorInfoList[index].Value, value);
						}

						FarmDeduplicationService.SurvivorInfoList[index].Value = value;
					}
				}

				FarmDeduplicationService.InfoValues = (IEnumerable<int>)FarmDeduplicationService.InfoList.Where(s => s.Checked == true).Select(s => s.Index);
				FarmDeduplicationService.InfoValues2 = (IEnumerable<int>)FarmDeduplicationService.InfoList2.Where(s => s.Checked == true).Select(s => s.Index);

				FarmDeduplicationService.chkCheckAll = false;
				FarmDeduplicationService.chkCheckAll2 = false;

				await EnableDisableMergeButtonAsync();
			}
		}

		protected async Task OnDataListSelectionChangeAsync(bool args, int index)
		{
			string value = string.Empty;
			string label = string.Empty;

			if (args == true)
			{
				FarmDeduplicationService.InfoList[index].Checked = true;
			}

			if (AllFieldValuePairsUnmatched() == true)
			{
				await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
				FarmDeduplicationService.InfoList[index].Checked = false;
				//FarmDeduplicationService.InfoValues = (IEnumerable<int>)FarmDeduplicationService.InfoList.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else if (FarmDeduplicationService.RecordSelection == 0 && FarmDeduplicationService.Record2Selection == 0)
			{
				await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
				FarmDeduplicationService.InfoList[index].Checked = false;
				//FarmDeduplicationService.InfoValues = (IEnumerable<int>)FarmDeduplicationService.InfoList.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else
			{
				if (FarmDeduplicationService.InfoList[index].Checked)
				{
					FarmDeduplicationService.InfoList2[index].Checked = false;
					value = FarmDeduplicationService.InfoList[index].Value;
					if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.FarmType)
					{
						SelectAndUnSelectIDfield(FarmTypeID, FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2, FarmDeduplicationService.SurvivorInfoList);
					}
					else if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.Country)
					{
						SelectAndUnSelectIDfield(FarmCountryID, FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2, FarmDeduplicationService.SurvivorInfoList);
					}
					else if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.EIDSSFarmOwnerID)
					{
						SelectAndUnSelectIDfield(FarmOwnerID, FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2, FarmDeduplicationService.SurvivorInfoList);
					}
					else if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.Region)
					{
						SelectAllAndUnSelectAll(index, ADDRESSNUMBERFIELD, FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2, FarmDeduplicationService.SurvivorInfoList);
						SelectAllAndUnSelectAll(RegionID, ADDRESSIDNUMBERFIELD, FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2, FarmDeduplicationService.SurvivorInfoList);
					}
				}
				else
				{
					FarmDeduplicationService.InfoList2[index].Checked = true;
					value = FarmDeduplicationService.InfoList2[index].Value;
					if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.FarmType)
					{
						SelectAndUnSelectIDfield(FarmTypeID, FarmDeduplicationService.InfoList2, FarmDeduplicationService.InfoList, FarmDeduplicationService.SurvivorInfoList);
					}
					else if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.Country)
					{
						SelectAndUnSelectIDfield(FarmCountryID, FarmDeduplicationService.InfoList2, FarmDeduplicationService.InfoList, FarmDeduplicationService.SurvivorInfoList);
					}
					else if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.EIDSSFarmOwnerID)
					{
						SelectAndUnSelectIDfield(FarmOwnerID, FarmDeduplicationService.InfoList2, FarmDeduplicationService.InfoList, FarmDeduplicationService.SurvivorInfoList);
					}
					else if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.Region)
					{
						SelectAllAndUnSelectAll(index, ADDRESSNUMBERFIELD, FarmDeduplicationService.InfoList2, FarmDeduplicationService.InfoList, FarmDeduplicationService.SurvivorInfoList);
						SelectAllAndUnSelectAll(RegionID, ADDRESSIDNUMBERFIELD, FarmDeduplicationService.InfoList2, FarmDeduplicationService.InfoList, FarmDeduplicationService.SurvivorInfoList);
					}
				}

				if (FarmDeduplicationService.SurvivorInfoList != null)
				{
					if (FarmDeduplicationService.SurvivorInfoList.Count > 0)
					{
						label = FarmDeduplicationService.SurvivorInfoList[index].Label;

						//if (value == null)
						//{
						//	FarmDeduplicationService.SurvivorInfoList[index].Label = label.Replace(FarmDeduplicationService.SurvivorInfoList[index].Value, "");
						//}
						//else if (FarmDeduplicationService.SurvivorInfoList[index].Value == null)
						//{
						//	FarmDeduplicationService.SurvivorInfoList[index].Label = label.Replace(": ", ": " + value);
						//}
						//else if (FarmDeduplicationService.SurvivorInfoList[index].Value == string.Empty)
						//{
						//	FarmDeduplicationService.SurvivorInfoList[index].Label = label.Replace(": ", ": " + value);
						//}
						//else
						//{
						//	FarmDeduplicationService.SurvivorInfoList[index].Label = label.Replace(FarmDeduplicationService.SurvivorInfoList[index].Value, value);
						//}

						FarmDeduplicationService.SurvivorInfoList[index].Value = value;
					}
				}

				//FarmDeduplicationService.InfoValues = (IEnumerable<int>)FarmDeduplicationService.InfoList.Where(s => s.Checked == true).Select(s => s.Index);
				//FarmDeduplicationService.InfoValues2 = (IEnumerable<int>)FarmDeduplicationService.InfoList2.Where(s => s.Checked == true).Select(s => s.Index);

				FarmDeduplicationService.chkCheckAll = false;
				FarmDeduplicationService.chkCheckAll2 = false;

				TabFarmDetailsValid();
				await EnableDisableMergeButtonAsync();
			}
		}

		protected async Task OnDataList2SelectionChangeAsync(bool args, int index)
		{
			string value = string.Empty;
			string label = string.Empty;

			if (args == true)
			{
				FarmDeduplicationService.InfoList2[index].Checked = true;
			}

			if (AllFieldValuePairsUnmatched() == true)
			{
				await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
				FarmDeduplicationService.InfoList2[index].Checked = false;
				//FarmDeduplicationService.InfoValues2 = (IEnumerable<int>)FarmDeduplicationService.InfoList2.Where(s => s.Checked == true).Select(s => s.Index);

			}
			else if (FarmDeduplicationService.RecordSelection == 0 && FarmDeduplicationService.Record2Selection == 0)
			{
				await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
				FarmDeduplicationService.InfoList2[index].Checked = false;
				//FarmDeduplicationService.InfoValues2 = (IEnumerable<int>)FarmDeduplicationService.InfoList2.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else
			{
				if (FarmDeduplicationService.InfoList2[index].Checked)
				{
					FarmDeduplicationService.InfoList[index].Checked = false;
					value = FarmDeduplicationService.InfoList2[index].Value;
					if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.FarmType)
					{
						SelectAndUnSelectIDfield(FarmTypeID, FarmDeduplicationService.InfoList2, FarmDeduplicationService.InfoList, FarmDeduplicationService.SurvivorInfoList);
					}
					else if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.Country)
					{
						SelectAndUnSelectIDfield(FarmCountryID, FarmDeduplicationService.InfoList2, FarmDeduplicationService.InfoList, FarmDeduplicationService.SurvivorInfoList);
					}
					else if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.Region)
					{
						SelectAllAndUnSelectAll(index, ADDRESSNUMBERFIELD, FarmDeduplicationService.InfoList2, FarmDeduplicationService.InfoList, FarmDeduplicationService.SurvivorInfoList);
						SelectAllAndUnSelectAll(RegionID, ADDRESSIDNUMBERFIELD, FarmDeduplicationService.InfoList2, FarmDeduplicationService.InfoList, FarmDeduplicationService.SurvivorInfoList);
					}
				}
				else
				{
					FarmDeduplicationService.InfoList[index].Checked = true;
					value = FarmDeduplicationService.InfoList[index].Value;
					if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.FarmType)
					{
						SelectAndUnSelectIDfield(FarmTypeID, FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2, FarmDeduplicationService.SurvivorInfoList);
					}
					else if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.Country)
					{
						SelectAndUnSelectIDfield(FarmCountryID, FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2, FarmDeduplicationService.SurvivorInfoList);
					}
					else if (FarmDeduplicationService.InfoList[index].Key == FarmDeduplicationFarmDetailsConstants.Region)
					{
						SelectAllAndUnSelectAll(index, ADDRESSNUMBERFIELD, FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2, FarmDeduplicationService.SurvivorInfoList);
						SelectAllAndUnSelectAll(RegionID, ADDRESSIDNUMBERFIELD, FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2, FarmDeduplicationService.SurvivorInfoList);
					}
				}

				if (FarmDeduplicationService.SurvivorInfoList != null)
				{
					if (FarmDeduplicationService.SurvivorInfoList.Count > 0)
					{
						label = FarmDeduplicationService.SurvivorInfoList[index].Label;

						//if (value == null)
						//{
						//	FarmDeduplicationService.SurvivorInfoList[index].Label = label.Replace(FarmDeduplicationService.SurvivorInfoList[index].Value, "");
						//}
						//else if (FarmDeduplicationService.SurvivorInfoList[index].Value == null)
						//{
						//	FarmDeduplicationService.SurvivorInfoList[index].Label = label.Replace(": ", ": " + value);
						//}
						//else if (FarmDeduplicationService.SurvivorInfoList[index].Value == string.Empty)
						//{
						//	FarmDeduplicationService.SurvivorInfoList[index].Label = label.Replace(": ", ": " + value);
						//}
						//else
						//{
						//	FarmDeduplicationService.SurvivorInfoList[index].Label = label.Replace(FarmDeduplicationService.SurvivorInfoList[index].Value, value);
						//}

						FarmDeduplicationService.SurvivorInfoList[index].Value = value;
					}
				}

				//FarmDeduplicationService.InfoValues = (IEnumerable<int>)FarmDeduplicationService.InfoList.Where(s => s.Checked == true).Select(s => s.Index);
				//FarmDeduplicationService.InfoValues2 = (IEnumerable<int>)FarmDeduplicationService.InfoList2.Where(s => s.Checked == true).Select(s => s.Index);

				FarmDeduplicationService.chkCheckAll = false;
				FarmDeduplicationService.chkCheckAll2 = false;

				TabFarmDetailsValid();
				await EnableDisableMergeButtonAsync();
			}
		}




	}
}
