using EIDSS.Localization.Constants;
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
    public class AddressBase : PersonDeduplicationBaseComponent, IDisposable
    {
		#region Globals

		#region Dependencies
		[Inject]
		private ILogger<AddressBase> Logger { get; set; }

		#endregion

		#region Parameters
		public PersonDeduplicationDetailsViewModel Model { get; set; }

		#endregion

		#region Protected and Public Members
		protected bool chkCheckAllAddress { get; set; }
		protected bool chkCheckAllAddress2 { get; set; }

		protected RadzenCheckBoxList<int> rcblAddress;
		protected RadzenCheckBoxList<int> rcblAddress2;

		//protected const Int16 HumanidfsRegion = 31;
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

		protected async Task OnCheckAllAddressChangeAsync(bool value)
		{
			if (value == true)
			{
				chkCheckAllAddress = true;
				chkCheckAllAddress2 = false;
                PersonDeduplicationService.chkCheckAllAddress = true;
                PersonDeduplicationService.chkCheckAllAddress2 = false;
                await CheckAllAsync(PersonDeduplicationService.AddressList, PersonDeduplicationService.AddressList2, chkCheckAllAddress, chkCheckAllAddress2, PersonDeduplicationService.SurvivorAddressList, "ValidAddress");
				TabAddressValid();
				StateHasChanged();
			}
			else
			{
				await BindTabAddressAsync();
				//HideIDFieldsinTabs();
			}
		}

		protected async Task OnCheckAllAddress2ChangeAsync(bool value)
		{
			if (value == true)
			{
				chkCheckAllAddress = false;
				chkCheckAllAddress2 = true;
                PersonDeduplicationService.chkCheckAllAddress = false;
                PersonDeduplicationService.chkCheckAllAddress2 = true;
                await CheckAllAsync(PersonDeduplicationService.AddressList2, PersonDeduplicationService.AddressList, chkCheckAllAddress2, chkCheckAllAddress, PersonDeduplicationService.SurvivorAddressList, "ValidAddress");
				TabAddressValid();
			}
			else
			{
				await BindTabAddressAsync();
				//HideIDFieldsinTabs();
			}
		}

		protected async Task OnCheckBoxListAddressSelectionChangeAsync(IEnumerable<int> values)
		{
			string value = string.Empty;
			string label = string.Empty;
			IEnumerable<int> list = (IEnumerable<int>)PersonDeduplicationService.AddressList.Where(s => s.Checked == true).Select(s => s.Index);
			int index = 0;

			if (values.Count() > list.Count())
			{
				index = values.ElementAt(values.Count() - 1);
				PersonDeduplicationService.AddressList[index].Checked = true;
			}
			else
			{
				IEnumerable<int> difference = list.Except(values);
				index = difference.ElementAt(0);
				PersonDeduplicationService.AddressList[index].Checked = false;
			}

			if (AllFieldValuePairsUnmatched() == true)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.AddressList[index].Checked = false;
				PersonDeduplicationService.AddressValues = (IEnumerable<int>)PersonDeduplicationService.AddressList.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else if (PersonDeduplicationService.RecordSelection == 0 && PersonDeduplicationService.Record2Selection == 0)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.AddressList[index].Checked = false;
				PersonDeduplicationService.AddressValues = (IEnumerable<int>)PersonDeduplicationService.AddressList.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else
			{
				if (PersonDeduplicationService.AddressList[index].Checked)
				{
					value = PersonDeduplicationService.AddressList[index].Value;

					if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.HumanRegion)
					{
						SelectAllAndUnSelectAll(index, HUMANADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.SurvivorAddressList);
						SelectAllAndUnSelectAll(HumanidfsRegion, ADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.SurvivorAddressList);
					}
					else if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.HumanPermRegion)
					{
						SelectAllAndUnSelectAll(index, HUMANALTADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.SurvivorAddressList);
						SelectAllAndUnSelectAll(HumanPermidfsRegion, ADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.SurvivorAddressList);
					}
					else if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.HumanAltRegion)
					{
						SelectAllAndUnSelectAll(index, HUMANALTADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.SurvivorAddressList);
						SelectAllAndUnSelectAll(HumanAltidfsRegion, ADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.SurvivorAddressList);
					}
					else
					{
						PersonDeduplicationService.AddressList2[index].Checked = false;
						PersonDeduplicationService.AddressList[index].Checked = true;
						PersonDeduplicationService.AddressList2[index].Checked = false;

						if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.HumanAltCountry)
						{
							SelectAndUnSelectIDfield(HumanAltidfsCountry, PersonDeduplicationService.AddressList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.SurvivorAddressList);
						}
						//else if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.HumanAltCountry)
						//{
						//	SelectAndUnSelectIDfield(HumanAltidfsCountry, PersonDeduplicationService.AddressList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.SurvivorAddressList);
						//}
						else if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.ContactPhoneTypeName)
						{
							SelectAndUnSelectIDfield(ContactPhoneTypeID, PersonDeduplicationService.AddressList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.SurvivorAddressList);
						}
						else if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.ContactPhone2TypeName)
						{
							SelectAndUnSelectIDfield(ContactPhone2TypeID, PersonDeduplicationService.AddressList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.SurvivorAddressList);
							//ElseIf CType(Session(AddressList), List(Of Field))[index].Key = PersonDeduplicationAddressConstants.YNHumanAltForeignAddress Then
							//    SelectAndUnSelectIDfield(HumanAltGeoLocationID, CheckBoxList3, CheckBoxList4, CType(Session(AddressList), List(Of Field)), CType(Session(AddressList2), List(Of Field)), CType(Session(SURVIVOR_LIST_ADDRESS), List(Of Field)))
							//    SelectAndUnSelectIDfield(HumanAltForeignAddressIndicator, CheckBoxList3, CheckBoxList4, CType(Session(AddressList), List(Of Field)), CType(Session(AddressList2), List(Of Field)), CType(Session(SURVIVOR_LIST_ADDRESS), List(Of Field)))
						}
					}
					//}

					//        if (CheckBoxList3.Items[index].Selected | CheckBoxList4.Items[index].Selected)
					//{
					if (PersonDeduplicationService.SurvivorAddressList != null)
					{
						if ((PersonDeduplicationService.SurvivorAddressList).Count > 0)
						{
							label = PersonDeduplicationService.SurvivorAddressList[index].Label;

							if (value == null)
							{
								PersonDeduplicationService.SurvivorAddressList[index].Label = label.Replace(PersonDeduplicationService.SurvivorAddressList[index].Value, "");
							}
							else if (PersonDeduplicationService.SurvivorAddressList[index].Value == null)
							{
								//PersonDeduplicationService.SurvivorAddressList[index].Label = label.Replace("<br><font style='color:#333;font-size:12px;font-weight:normal'>", "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + value);
								PersonDeduplicationService.SurvivorAddressList[index].Label = label.Replace(": ", ": " + value);
							}
							else if (PersonDeduplicationService.SurvivorAddressList[index].Value == string.Empty)
							{
								//PersonDeduplicationService.SurvivorAddressList[index].Label = label.Replace("<br><font style='color:#333;font-size:12px;font-weight:normal'>", "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + value);
								PersonDeduplicationService.SurvivorAddressList[index].Label = label.Replace(": ", ": " + value);
							}
							else
							{
								PersonDeduplicationService.SurvivorAddressList[index].Label = label.Replace(PersonDeduplicationService.SurvivorAddressList[index].Value, value);
							}

							PersonDeduplicationService.SurvivorAddressList[index].Value = value;
						}
					}
				}

				PersonDeduplicationService.AddressValues = (IEnumerable<int>)PersonDeduplicationService.AddressList.Where(s => s.Checked == true).Select(s => s.Index);
				PersonDeduplicationService.AddressValues2 = (IEnumerable<int>)PersonDeduplicationService.AddressList2.Where(s => s.Checked == true).Select(s => s.Index);
				PersonDeduplicationService.chkCheckAllAddress = false;
				PersonDeduplicationService.chkCheckAllAddress2 = false;

				await EnableDisableMergeButtonAsync();
			}
		}

		protected async Task OnCheckBoxListAddress2SelectionChangeAsync(IEnumerable<int> values)
		{
			string value = string.Empty;
			string label = string.Empty;
			IEnumerable<int> list = (IEnumerable<int>)PersonDeduplicationService.AddressList2.Where(s => s.Checked == true).Select(s => s.Index);
			int index = 0;

			if (values.Count() > list.Count())
			{
				index = values.ElementAt(values.Count() - 1);
				PersonDeduplicationService.AddressList2[index].Checked = true;
			}
			else
			{
				IEnumerable<int> difference = list.Except(values);
				index = difference.ElementAt(0);
				PersonDeduplicationService.AddressList2[index].Checked = false;
			}

			if (AllFieldValuePairsUnmatched() == true)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.AddressList2[index].Checked = false;
				PersonDeduplicationService.AddressValues2 = (IEnumerable<int>)PersonDeduplicationService.AddressList2.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else if (PersonDeduplicationService.RecordSelection == 0 && PersonDeduplicationService.Record2Selection == 0)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.AddressList2[index].Checked = false;
				PersonDeduplicationService.AddressValues2 = (IEnumerable<int>)PersonDeduplicationService.AddressList2.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else
			{
				if (PersonDeduplicationService.AddressList2[index].Checked)
				{
					value = PersonDeduplicationService.AddressList2[index].Value;

					if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.HumanRegion)
					{
						SelectAllAndUnSelectAll(index, HUMANADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.SurvivorAddressList);
						SelectAllAndUnSelectAll(HumanidfsRegion, ADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.SurvivorAddressList);
					}
					else if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.HumanPermRegion)
					{
						SelectAllAndUnSelectAll(index, HUMANALTADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.SurvivorAddressList);
						SelectAllAndUnSelectAll(HumanPermidfsRegion, ADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.SurvivorAddressList);
					}
					else if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.HumanAltRegion)
					{
						SelectAllAndUnSelectAll(index, HUMANALTADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.SurvivorAddressList);
						SelectAllAndUnSelectAll(HumanAltidfsRegion, ADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.SurvivorAddressList);
					}
					else
					{
						//PersonDeduplicationService.AddressList[index].Checked = false;
						PersonDeduplicationService.AddressList[index].Checked = false;
						PersonDeduplicationService.AddressList2[index].Checked = true;

						if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.HumanAltCountry)
						{
							SelectAndUnSelectIDfield(HumanAltidfsCountry, PersonDeduplicationService.AddressList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.SurvivorAddressList);
						}
						//else if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.HumanAltCountry)
						//{
						//	SelectAndUnSelectIDfield(HumanAltidfsCountry, PersonDeduplicationService.AddressList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.SurvivorAddressList);
						//}
						else if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.ContactPhoneTypeName)
						{
							SelectAndUnSelectIDfield(ContactPhoneTypeID, PersonDeduplicationService.AddressList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.SurvivorAddressList);
						}
						else if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.ContactPhone2TypeName)
						{
							SelectAndUnSelectIDfield(ContactPhone2TypeID, PersonDeduplicationService.AddressList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.SurvivorAddressList);
							//ElseIf CType(Session(AddressList), List(Of Field))[index].Key = PersonDeduplicationAddressConstants.YNHumanAltForeignAddress Then
							//    SelectAndUnSelectIDfield(HumanAltGeoLocationID, CheckBoxList4, CheckBoxList3, CType(Session(AddressList2), List(Of Field)), CType(Session(AddressList), List(Of Field)), CType(Session(SURVIVOR_LIST_ADDRESS), List(Of Field)))
							//    SelectAndUnSelectIDfield(HumanAltForeignAddressIndicator, CheckBoxList4, CheckBoxList3, CType(Session(AddressList2), List(Of Field)), CType(Session(AddressList), List(Of Field)), CType(Session(SURVIVOR_LIST_ADDRESS), List(Of Field)))
						}
					}
					//}

					if (PersonDeduplicationService.SurvivorAddressList != null)
					{
						if ((PersonDeduplicationService.SurvivorAddressList).Count > 0)
						{
							label = PersonDeduplicationService.SurvivorAddressList[index].Label;

							if (value == null)
							{
								PersonDeduplicationService.SurvivorAddressList[index].Label = label.Replace(PersonDeduplicationService.SurvivorAddressList[index].Value, "");
							}
							else if (PersonDeduplicationService.SurvivorAddressList[index].Value == null)
							{
								//PersonDeduplicationService.SurvivorAddressList[index].Label = label.Replace("<br><font style='color:#333;font-size:12px;font-weight:normal'>", "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + value);
								PersonDeduplicationService.SurvivorAddressList[index].Label = label.Replace(": ", ": " + value);
							}
							else if (PersonDeduplicationService.SurvivorAddressList[index].Value == string.Empty)
							{
								//PersonDeduplicationService.SurvivorAddressList[index].Label = label.Replace("<br><font style='color:#333;font-size:12px;font-weight:normal'>", "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + value);
								PersonDeduplicationService.SurvivorAddressList[index].Label = label.Replace(": ", ": " + value);
							}
							else
							{
								PersonDeduplicationService.SurvivorAddressList[index].Label = label.Replace(PersonDeduplicationService.SurvivorAddressList[index].Value, value);
							}

							PersonDeduplicationService.SurvivorAddressList[index].Value = value;
						}
					}
				}

				PersonDeduplicationService.AddressValues = (IEnumerable<int>)PersonDeduplicationService.AddressList.Where(s => s.Checked == true).Select(s => s.Index);
				PersonDeduplicationService.AddressValues2 = (IEnumerable<int>)PersonDeduplicationService.AddressList2.Where(s => s.Checked == true).Select(s => s.Index);
				PersonDeduplicationService.chkCheckAllAddress = false;
				PersonDeduplicationService.chkCheckAllAddress2 = false;

				await EnableDisableMergeButtonAsync();
			}
		}

		protected async Task OnDataListAddressSelectionChangeAsync(bool args, int index)
		{
			string value = string.Empty;
			string label = string.Empty;

			if (args == true)
			{
				PersonDeduplicationService.AddressList[index].Checked = true;
			}

			if (AllFieldValuePairsUnmatched() == true)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.AddressList[index].Checked = false;
				//PersonDeduplicationService.AddressValues = (IEnumerable<int>)PersonDeduplicationService.AddressList.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else if (PersonDeduplicationService.RecordSelection == 0 && PersonDeduplicationService.Record2Selection == 0)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.AddressList[index].Checked = false;
				//PersonDeduplicationService.AddressValues = (IEnumerable<int>)PersonDeduplicationService.AddressList.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else
			{
				if (PersonDeduplicationService.AddressList[index].Checked)
				{
					value = PersonDeduplicationService.AddressList[index].Value;

					if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.HumanRegion)
					{
						SelectAllAndUnSelectAll(index, HUMANADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.SurvivorAddressList);
						SelectAllAndUnSelectAll(HumanidfsRegion, ADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.SurvivorAddressList);
					}
					else if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.HumanPermRegion)
					{
						SelectAllAndUnSelectAll(index, HUMANALTADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.SurvivorAddressList);
						SelectAllAndUnSelectAll(HumanPermidfsRegion, ADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.SurvivorAddressList);
					}
					else if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.HumanAltRegion)
					{
						SelectAllAndUnSelectAll(index, HUMANALTADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.SurvivorAddressList);
						SelectAllAndUnSelectAll(HumanAltidfsRegion, ADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.SurvivorAddressList);
					}
					else
					{
						PersonDeduplicationService.AddressList2[index].Checked = false;
						//PersonDeduplicationService.AddressList[index].Checked = true;
						//PersonDeduplicationService.AddressList2[index].Checked = false;

						if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.HumanAltCountry)
						{
							SelectAndUnSelectIDfield(HumanAltidfsCountry, PersonDeduplicationService.AddressList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.SurvivorAddressList);
						}
						else if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.ContactPhoneTypeName)
						{
							SelectAndUnSelectIDfield(ContactPhoneTypeID, PersonDeduplicationService.AddressList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.SurvivorAddressList);
						}
						else if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.ContactPhone2TypeName)
						{
							SelectAndUnSelectIDfield(ContactPhone2TypeID, PersonDeduplicationService.AddressList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.SurvivorAddressList);
						}
					}

					if (PersonDeduplicationService.SurvivorAddressList != null)
					{
						if ((PersonDeduplicationService.SurvivorAddressList).Count > 0)
						{
							label = PersonDeduplicationService.SurvivorAddressList[index].Label;

							//if (value == null)
							//{
							//	PersonDeduplicationService.SurvivorAddressList[index].Label = label.Replace(PersonDeduplicationService.SurvivorAddressList[index].Value, "");
							//}
							//else if (PersonDeduplicationService.SurvivorAddressList[index].Value == null)
							//{
							//	PersonDeduplicationService.SurvivorAddressList[index].Label = label.Replace(": ", ": " + value);
							//}
							//else if (PersonDeduplicationService.SurvivorAddressList[index].Value == string.Empty)
							//{
							//	PersonDeduplicationService.SurvivorAddressList[index].Label = label.Replace(": ", ": " + value);
							//}
							//else
							//{
							//	PersonDeduplicationService.SurvivorAddressList[index].Label = label.Replace(PersonDeduplicationService.SurvivorAddressList[index].Value, value);
							//}

							PersonDeduplicationService.SurvivorAddressList[index].Value = value;
						}
					}
				}

				//PersonDeduplicationService.AddressValues = (IEnumerable<int>)PersonDeduplicationService.AddressList.Where(s => s.Checked == true).Select(s => s.Index);
				//PersonDeduplicationService.AddressValues2 = (IEnumerable<int>)PersonDeduplicationService.AddressList2.Where(s => s.Checked == true).Select(s => s.Index);

                PersonDeduplicationService.chkCheckAllAddress = PersonDeduplicationService.AddressList.Where(x => !x.Checked).Count() == 0;
                PersonDeduplicationService.chkCheckAllAddress2 = PersonDeduplicationService.AddressList2.Where(x => !x.Checked).Count() == 0;

                await EnableDisableMergeButtonAsync();
			}
		}

		protected async Task OnDataListAddress2SelectionChangeAsync(bool args, int index)
		{
			string value = string.Empty;
			string label = string.Empty;

			if (args == true)
			{
				PersonDeduplicationService.AddressList2[index].Checked = true;
			}

			if (AllFieldValuePairsUnmatched() == true)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.AddressList2[index].Checked = false;
				//PersonDeduplicationService.AddressValues2 = (IEnumerable<int>)PersonDeduplicationService.AddressList2.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else if (PersonDeduplicationService.RecordSelection == 0 && PersonDeduplicationService.Record2Selection == 0)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.AddressList2[index].Checked = false;
				//PersonDeduplicationService.AddressValues2 = (IEnumerable<int>)PersonDeduplicationService.AddressList2.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else
			{
				if (PersonDeduplicationService.AddressList2[index].Checked)
				{
					value = PersonDeduplicationService.AddressList2[index].Value;

					if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.HumanRegion)
					{
						SelectAllAndUnSelectAll(index, HUMANADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.SurvivorAddressList);
						SelectAllAndUnSelectAll(HumanidfsRegion, ADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.SurvivorAddressList);
					}
					else if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.HumanPermRegion)
					{
						SelectAllAndUnSelectAll(index, HUMANALTADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.SurvivorAddressList);
						SelectAllAndUnSelectAll(HumanPermidfsRegion, ADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.SurvivorAddressList);
					}
					else if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.HumanAltRegion)
					{
						SelectAllAndUnSelectAll(index, HUMANALTADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.SurvivorAddressList);
						SelectAllAndUnSelectAll(HumanAltidfsRegion, ADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.SurvivorAddressList);
					}
					else
					{
                        PersonDeduplicationService.AddressList[index].Checked = false;
                        //PersonDeduplicationService.AddressList[index].Checked = false;
                        //PersonDeduplicationService.AddressList2[index].Checked = true;

                        if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.HumanAltCountry)
						{
							SelectAndUnSelectIDfield(HumanAltidfsCountry, PersonDeduplicationService.AddressList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.SurvivorAddressList);
						}
						else if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.ContactPhoneTypeName)
						{
							SelectAndUnSelectIDfield(ContactPhoneTypeID, PersonDeduplicationService.AddressList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.SurvivorAddressList);
						}
						else if (PersonDeduplicationService.AddressList[index].Key == PersonDeduplicationAddressConstants.ContactPhone2TypeName)
						{
							SelectAndUnSelectIDfield(ContactPhone2TypeID, PersonDeduplicationService.AddressList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.SurvivorAddressList);
						}
					}

					if (PersonDeduplicationService.SurvivorAddressList != null)
					{
						if ((PersonDeduplicationService.SurvivorAddressList).Count > 0)
						{
							label = PersonDeduplicationService.SurvivorAddressList[index].Label;

							//if (value == null)
							//{
							//	PersonDeduplicationService.SurvivorAddressList[index].Label = label.Replace(PersonDeduplicationService.SurvivorAddressList[index].Value, "");
							//}
							//else if (PersonDeduplicationService.SurvivorAddressList[index].Value == null)
							//{
							//	PersonDeduplicationService.SurvivorAddressList[index].Label = label.Replace(": ", ": " + value);
							//}
							//else if (PersonDeduplicationService.SurvivorAddressList[index].Value == string.Empty)
							//{
							//	PersonDeduplicationService.SurvivorAddressList[index].Label = label.Replace(": ", ": " + value);
							//}
							//else
							//{
							//	PersonDeduplicationService.SurvivorAddressList[index].Label = label.Replace(PersonDeduplicationService.SurvivorAddressList[index].Value, value);
							//}

							PersonDeduplicationService.SurvivorAddressList[index].Value = value;
						}
					}
				}

                //PersonDeduplicationService.AddressValues = (IEnumerable<int>)PersonDeduplicationService.AddressList.Where(s => s.Checked == true).Select(s => s.Index);
                //PersonDeduplicationService.AddressValues2 = (IEnumerable<int>)PersonDeduplicationService.AddressList2.Where(s => s.Checked == true).Select(s => s.Index);

                PersonDeduplicationService.chkCheckAllAddress = PersonDeduplicationService.AddressList.Where(x => !x.Checked).Count() == 0;
                PersonDeduplicationService.chkCheckAllAddress2 = PersonDeduplicationService.AddressList2.Where(x => !x.Checked).Count() == 0;

                await EnableDisableMergeButtonAsync();
			}
		}
	}
}
