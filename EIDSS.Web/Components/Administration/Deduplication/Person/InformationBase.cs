using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.SubAreas.Deduplication.ViewModels.PersonDeduplication;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Administration.Deduplication.Person
{
    public class InformationBase : PersonDeduplicationBaseComponent, IDisposable
    {
		#region Globals

		#region Dependencies

		[Inject]
		private ILogger<InformationBase> Logger { get; set; }

        #endregion

        #region Parameters
        public PersonDeduplicationDetailsViewModel Model { get; set; }

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
			PersonDeduplicationService.OnChange += async (property) => await OnStateContainerChangeAsync(property);

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

				PersonDeduplicationService.OnChange -= async (property) => await OnStateContainerChangeAsync(property);

			}
			catch (Exception)
			{
				throw;
			}
		}

		protected async Task OnCheckAllInfoChangeAsync(bool value)
        {
            //if (!PersonDeduplicationService.chkCheckAll && !PersonDeduplicationService.chkCheckAll2)
            //{
            //    PersonDeduplicationService.chkCheckAll = true;
            //    return;
            //}
            if (value == true)
            {
                chkCheckAll = true;
                chkCheckAll2 = false;
                PersonDeduplicationService.chkCheckAll = true;
                PersonDeduplicationService.chkCheckAll2 = false;
                await CheckAllAsync(PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, chkCheckAll, chkCheckAll2, PersonDeduplicationService.SurvivorInfoList, "ValidInfo");
				TabInfoValid();
			}
			else
			{
				await BindTabInfoAsync();
			}
		}

		protected async Task OnCheckAllInfo2ChangeAsync(bool value)
		{
			//if(!PersonDeduplicationService.chkCheckAll && !PersonDeduplicationService.chkCheckAll2)
			//{
			//	PersonDeduplicationService.chkCheckAll2 = true;
			//	return;
			//}
			if (value == true)
            {
                chkCheckAll = false;
                chkCheckAll2 = true;
                PersonDeduplicationService.chkCheckAll = false;
                PersonDeduplicationService.chkCheckAll2 = true;
				await CheckAllAsync(PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, chkCheckAll2, chkCheckAll, PersonDeduplicationService.SurvivorInfoList, "ValidInfo");
				TabInfoValid();
			}
			else
			{
				await BindTabInfoAsync();
			}
		}

		protected async Task OnCheckBoxListInfoSelectionChangeAsync(IEnumerable<int> values)
		{
			string value = string.Empty;
			string label = string.Empty;
			IEnumerable<int> list = (IEnumerable<int>)PersonDeduplicationService.InfoList.Where(s => s.Checked == true).Select(s => s.Index);
			int index = 0;

			if (values.Count() > list.Count())
			{
				index = values.ElementAt(values.Count() - 1);
				PersonDeduplicationService.InfoList[index].Checked = true;
			}
			else
			{
				IEnumerable<int> difference = list.Except(values);
				index = difference.ElementAt(0);
				PersonDeduplicationService.InfoList[index].Checked = false;
			}

			if (AllFieldValuePairsUnmatched() == true)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.InfoList[index].Checked = false;
				PersonDeduplicationService.InfoValues = (IEnumerable<int>)PersonDeduplicationService.InfoList.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else if (PersonDeduplicationService.RecordSelection == 0 && PersonDeduplicationService.Record2Selection == 0)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.InfoList[index].Checked = false;
				PersonDeduplicationService.InfoValues = (IEnumerable<int>)PersonDeduplicationService.InfoList.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else
			{
				if (PersonDeduplicationService.InfoList[index].Checked)
				{
					PersonDeduplicationService.InfoList2[index].Checked = false;
					value = PersonDeduplicationService.InfoList[index].Value;
					if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.GenderTypeName)
					{
						SelectAndUnSelectIDfield(GenderTypeID, PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.CitizenshipTypeName)
					{
						SelectAndUnSelectIDfield(CitizenshipTypeID, PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.PersonalIDTypeName)
					{
						SelectAndUnSelectIDfield(PersonalIDType, PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.Age)
					{
						SelectAndUnSelectIDfield(ReportedAge, PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, PersonDeduplicationService.SurvivorInfoList);
						SelectAndUnSelectIDfield(ReportedAgeUOMID, PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, PersonDeduplicationService.SurvivorInfoList);
					}
				}
				else
				{
					PersonDeduplicationService.InfoList2[index].Checked = true;
					value = PersonDeduplicationService.InfoList2[index].Value;
					if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.GenderTypeName)
					{
						SelectAndUnSelectIDfield(GenderTypeID, PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.CitizenshipTypeName)
					{
						SelectAndUnSelectIDfield(CitizenshipTypeID, PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.PersonalIDTypeName)
					{
						SelectAndUnSelectIDfield(PersonalIDType, PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.Age)
					{
						SelectAndUnSelectIDfield(ReportedAge, PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, PersonDeduplicationService.SurvivorInfoList);
						SelectAndUnSelectIDfield(ReportedAgeUOMID, PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, PersonDeduplicationService.SurvivorInfoList);
					}
				}

				if (PersonDeduplicationService.SurvivorInfoList != null)
				{
					if (PersonDeduplicationService.SurvivorInfoList.Count > 0)
					{
						label = PersonDeduplicationService.SurvivorInfoList[index].Label;

						if (value == null)
						{
							PersonDeduplicationService.SurvivorInfoList[index].Label = label.Replace(PersonDeduplicationService.SurvivorInfoList[index].Value, "");
						}
						else if (PersonDeduplicationService.SurvivorInfoList[index].Value == null)
						{
							//PersonDeduplicationService.SurvivorInfoList[index].Label = label.Replace("<br><font style='color:#333;font-size:12px;font-weight:normal'>", "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + value);
							PersonDeduplicationService.SurvivorInfoList[index].Label = label.Replace(": ", ": " + value);
						}
						else if (PersonDeduplicationService.SurvivorInfoList[index].Value == string.Empty)
						{
							//PersonDeduplicationService.SurvivorInfoList[index].Label = label.Replace("<br><font style='color:#333;font-size:12px;font-weight:normal'>", "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + value);
							PersonDeduplicationService.SurvivorInfoList[index].Label = label.Replace(": ", ": " + value);
						}
						else
						{
							PersonDeduplicationService.SurvivorInfoList[index].Label = label.Replace(PersonDeduplicationService.SurvivorInfoList[index].Value, value);
						}

						PersonDeduplicationService.SurvivorInfoList[index].Value = value;
					}
				}

				PersonDeduplicationService.InfoValues = (IEnumerable<int>)PersonDeduplicationService.InfoList.Where(s => s.Checked == true).Select(s => s.Index);
				PersonDeduplicationService.InfoValues2 = (IEnumerable<int>)PersonDeduplicationService.InfoList2.Where(s => s.Checked == true).Select(s => s.Index);

				PersonDeduplicationService.chkCheckAll = false;
				PersonDeduplicationService.chkCheckAll2 = false;

				await EnableDisableMergeButtonAsync();
			}
		}

		protected async Task OnCheckBoxListInfo2SelectionChangeAsync(IEnumerable<int> values)
		{
			string value = string.Empty;
			string label = string.Empty;
			IEnumerable<int> list = (IEnumerable<int>)PersonDeduplicationService.InfoList2.Where(s => s.Checked == true).Select(s => s.Index);
			int index = 0;

			if (values.Count() > list.Count())
			{
				index = values.ElementAt(values.Count() - 1);
				PersonDeduplicationService.InfoList2[index].Checked = true;
			}
			else
			{
				IEnumerable<int> difference = list.Except(values);
				index = difference.ElementAt(0);
				PersonDeduplicationService.InfoList2[index].Checked = false;
			}

			if (AllFieldValuePairsUnmatched() == true)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.InfoList2[index].Checked = false;
				PersonDeduplicationService.InfoValues2 = (IEnumerable<int>)PersonDeduplicationService.InfoList2.Where(s => s.Checked == true).Select(s => s.Index);

			}
			else if (PersonDeduplicationService.RecordSelection == 0 && PersonDeduplicationService.Record2Selection == 0)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.InfoList2[index].Checked = false;
				PersonDeduplicationService.InfoValues2 = (IEnumerable<int>)PersonDeduplicationService.InfoList2.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else
			{
				if (PersonDeduplicationService.InfoList2[index].Checked)
				{
					PersonDeduplicationService.InfoList[index].Checked = false;
					value = PersonDeduplicationService.InfoList2[index].Value;
					if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.GenderTypeName)
					{
						SelectAndUnSelectIDfield(GenderTypeID, PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.CitizenshipTypeName)
					{
						SelectAndUnSelectIDfield(CitizenshipTypeID, PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.PersonalIDTypeName)
					{
						SelectAndUnSelectIDfield(PersonalIDType, PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.Age)
					{
						SelectAndUnSelectIDfield(ReportedAge, PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, PersonDeduplicationService.SurvivorInfoList);
						SelectAndUnSelectIDfield(ReportedAgeUOMID, PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, PersonDeduplicationService.SurvivorInfoList);
					}
				}
				else
				{
					PersonDeduplicationService.InfoList[index].Checked = true;
					value = PersonDeduplicationService.InfoList[index].Value;
					if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.GenderTypeName)
					{
						SelectAndUnSelectIDfield(GenderTypeID, PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.CitizenshipTypeName)
					{
						SelectAndUnSelectIDfield(CitizenshipTypeID, PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.PersonalIDTypeName)
					{
						SelectAndUnSelectIDfield(PersonalIDType, PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.Age)
					{
						SelectAndUnSelectIDfield(ReportedAge, PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, PersonDeduplicationService.SurvivorInfoList);
						SelectAndUnSelectIDfield(ReportedAgeUOMID, PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, PersonDeduplicationService.SurvivorInfoList);
					}
				}

				if (PersonDeduplicationService.SurvivorInfoList != null)
				{
					if (PersonDeduplicationService.SurvivorInfoList.Count > 0)
					{
						label = PersonDeduplicationService.SurvivorInfoList[index].Label;

						if (value == null)
						{
							PersonDeduplicationService.SurvivorInfoList[index].Label = label.Replace(PersonDeduplicationService.SurvivorInfoList[index].Value, "");
						}
						else if (PersonDeduplicationService.SurvivorInfoList[index].Value == null)
						{
							//PersonDeduplicationService.SurvivorInfoList[index].Label = label.Replace("<br><font style='color:#333;font-size:12px;font-weight:normal'>", "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + value);
							PersonDeduplicationService.SurvivorInfoList[index].Label = label.Replace(": ", ": " + value);
						}
						else if (PersonDeduplicationService.SurvivorInfoList[index].Value == string.Empty)
						{
							//PersonDeduplicationService.SurvivorInfoList[index].Label = label.Replace("<br><font style='color:#333;font-size:12px;font-weight:normal'>", "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + value);
							PersonDeduplicationService.SurvivorInfoList[index].Label = label.Replace(": ", ": " + value);
						}
						else
						{
							PersonDeduplicationService.SurvivorInfoList[index].Label = label.Replace(PersonDeduplicationService.SurvivorInfoList[index].Value, value);
						}

						PersonDeduplicationService.SurvivorInfoList[index].Value = value;
					}
				}

				PersonDeduplicationService.InfoValues = (IEnumerable<int>)PersonDeduplicationService.InfoList.Where(s => s.Checked == true).Select(s => s.Index);
				PersonDeduplicationService.InfoValues2 = (IEnumerable<int>)PersonDeduplicationService.InfoList2.Where(s => s.Checked == true).Select(s => s.Index);

				PersonDeduplicationService.chkCheckAll = false;
				PersonDeduplicationService.chkCheckAll2 = false;

				await EnableDisableMergeButtonAsync();
			}
		}

		protected async Task OnDataListInfoSelectionChangeAsync(bool args, int index)
		{
			string value = string.Empty;
			string label = string.Empty;

			if (args == true)
			{
				PersonDeduplicationService.InfoList[index].Checked = true;
			}

			if (AllFieldValuePairsUnmatched() == true)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.InfoList[index].Checked = false;
				//PersonDeduplicationService.InfoValues = (IEnumerable<int>)PersonDeduplicationService.InfoList.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else if (PersonDeduplicationService.RecordSelection == 0 && PersonDeduplicationService.Record2Selection == 0)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.InfoList[index].Checked = false;
				//PersonDeduplicationService.InfoValues = (IEnumerable<int>)PersonDeduplicationService.InfoList.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else
			{
				if (PersonDeduplicationService.InfoList[index].Checked)
				{
					PersonDeduplicationService.InfoList2[index].Checked = false;
					value = PersonDeduplicationService.InfoList[index].Value;

					if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.GenderTypeName)
					{
						SelectAndUnSelectIDfield(GenderTypeID, PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.CitizenshipTypeName)
					{
						SelectAndUnSelectIDfield(CitizenshipTypeID, PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.PersonalIDTypeName)
					{
						SelectAndUnSelectIDfield(PersonalIDType, PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.Age)
					{
						SelectAndUnSelectIDfield(ReportedAge, PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, PersonDeduplicationService.SurvivorInfoList);
						SelectAndUnSelectIDfield(ReportedAgeUOMID, PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, PersonDeduplicationService.SurvivorInfoList);
					}
				}
				else
				{
					PersonDeduplicationService.InfoList2[index].Checked = true;
					value = PersonDeduplicationService.InfoList2[index].Value;

					if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.GenderTypeName)
					{
						SelectAndUnSelectIDfield(GenderTypeID, PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.CitizenshipTypeName)
					{
						SelectAndUnSelectIDfield(CitizenshipTypeID, PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.PersonalIDTypeName)
					{
						SelectAndUnSelectIDfield(PersonalIDType, PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.Age)
					{
						SelectAndUnSelectIDfield(ReportedAge, PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, PersonDeduplicationService.SurvivorInfoList);
						SelectAndUnSelectIDfield(ReportedAgeUOMID, PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, PersonDeduplicationService.SurvivorInfoList);
					}
				}

				if (PersonDeduplicationService.SurvivorInfoList != null)
				{
					if (PersonDeduplicationService.SurvivorInfoList.Count > 0)
					{
						label = PersonDeduplicationService.SurvivorInfoList[index].Label;

						//if (value == null)
						//{
						//	PersonDeduplicationService.SurvivorInfoList[index].Label = label.Replace(PersonDeduplicationService.SurvivorInfoList[index].Value, "");
						//}
						//else if (PersonDeduplicationService.SurvivorInfoList[index].Value == null)
						//{
						//	PersonDeduplicationService.SurvivorInfoList[index].Label = label.Replace(": ", ": " + value);
						//}
						//else if (PersonDeduplicationService.SurvivorInfoList[index].Value == string.Empty)
						//{
						//	PersonDeduplicationService.SurvivorInfoList[index].Label = label.Replace(": ", ": " + value);
						//}
						//else
						//{
						//	PersonDeduplicationService.SurvivorInfoList[index].Label = label.Replace(PersonDeduplicationService.SurvivorInfoList[index].Value, value);
						//}

						PersonDeduplicationService.SurvivorInfoList[index].Value = value;
					}
				}

                //PersonDeduplicationService.InfoValues = (IEnumerable<int>)PersonDeduplicationService.InfoList.Where(s => s.Checked == true).Select(s => s.Index);
                //PersonDeduplicationService.InfoValues2 = (IEnumerable<int>)PersonDeduplicationService.InfoList2.Where(s => s.Checked == true).Select(s => s.Index);

                PersonDeduplicationService.chkCheckAll = PersonDeduplicationService.InfoList.Where(x => !x.Checked).Count() == 0;
                PersonDeduplicationService.chkCheckAll2 = PersonDeduplicationService.InfoList2.Where(x => !x.Checked).Count() == 0;

                await EnableDisableMergeButtonAsync();
			}
		}

		protected async Task OnDataListInfo2SelectionChangeAsync(bool args, int index)
		{
			string value = string.Empty;
			string label = string.Empty;

			if (args == true)
			{
				PersonDeduplicationService.InfoList2[index].Checked = true;
			}

			if (AllFieldValuePairsUnmatched() == true)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.InfoList2[index].Checked = false;
				//PersonDeduplicationService.InfoValues2 = (IEnumerable<int>)PersonDeduplicationService.InfoList2.Where(s => s.Checked == true).Select(s => s.Index);

			}
			else if (PersonDeduplicationService.RecordSelection == 0 && PersonDeduplicationService.Record2Selection == 0)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.InfoList2[index].Checked = false;
				//PersonDeduplicationService.InfoValues2 = (IEnumerable<int>)PersonDeduplicationService.InfoList2.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else
			{
				if (PersonDeduplicationService.InfoList2[index].Checked)
				{
					PersonDeduplicationService.InfoList[index].Checked = false;
					value = PersonDeduplicationService.InfoList2[index].Value;

					if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.GenderTypeName)
					{
						SelectAndUnSelectIDfield(GenderTypeID, PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.CitizenshipTypeName)
					{
						SelectAndUnSelectIDfield(CitizenshipTypeID, PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.PersonalIDTypeName)
					{
						SelectAndUnSelectIDfield(PersonalIDType, PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.Age)
					{
						SelectAndUnSelectIDfield(ReportedAge, PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, PersonDeduplicationService.SurvivorInfoList);
						SelectAndUnSelectIDfield(ReportedAgeUOMID, PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, PersonDeduplicationService.SurvivorInfoList);
					}
				}
				else
				{
					PersonDeduplicationService.InfoList[index].Checked = true;
					value = PersonDeduplicationService.InfoList[index].Value;

					if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.GenderTypeName)
					{
						SelectAndUnSelectIDfield(GenderTypeID, PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.CitizenshipTypeName)
					{
						SelectAndUnSelectIDfield(CitizenshipTypeID, PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.PersonalIDTypeName)
					{
						SelectAndUnSelectIDfield(PersonalIDType, PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, PersonDeduplicationService.SurvivorInfoList);
					}
					else if (PersonDeduplicationService.InfoList[index].Key == PersonDeduplicationInfoConstants.Age)
					{
						SelectAndUnSelectIDfield(ReportedAge, PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, PersonDeduplicationService.SurvivorInfoList);
						SelectAndUnSelectIDfield(ReportedAgeUOMID, PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, PersonDeduplicationService.SurvivorInfoList);
					}
				}

				if (PersonDeduplicationService.SurvivorInfoList != null)
				{
					if (PersonDeduplicationService.SurvivorInfoList.Count > 0)
					{
						label = PersonDeduplicationService.SurvivorInfoList[index].Label;

						//if (value == null)
						//{
						//	PersonDeduplicationService.SurvivorInfoList[index].Label = label.Replace(PersonDeduplicationService.SurvivorInfoList[index].Value, "");
						//}
						//else if (PersonDeduplicationService.SurvivorInfoList[index].Value == null)
						//{
						//	PersonDeduplicationService.SurvivorInfoList[index].Label = label.Replace(": ", ": " + value);
						//}
						//else if (PersonDeduplicationService.SurvivorInfoList[index].Value == string.Empty)
						//{
						//	PersonDeduplicationService.SurvivorInfoList[index].Label = label.Replace(": ", ": " + value);
						//}
						//else
						//{
						//	PersonDeduplicationService.SurvivorInfoList[index].Label = label.Replace(PersonDeduplicationService.SurvivorInfoList[index].Value, value);
						//}

						PersonDeduplicationService.SurvivorInfoList[index].Value = value;
					}
				}

				//PersonDeduplicationService.InfoValues = (IEnumerable<int>)PersonDeduplicationService.InfoList.Where(s => s.Checked == true).Select(s => s.Index);
				//PersonDeduplicationService.InfoValues2 = (IEnumerable<int>)PersonDeduplicationService.InfoList2.Where(s => s.Checked == true).Select(s => s.Index);

				PersonDeduplicationService.chkCheckAll = PersonDeduplicationService.InfoList.Where(x => !x.Checked).Count() == 0;
				PersonDeduplicationService.chkCheckAll2 = PersonDeduplicationService.InfoList2.Where(x => !x.Checked).Count() == 0;

				await EnableDisableMergeButtonAsync();
			}
		}
	}
}
