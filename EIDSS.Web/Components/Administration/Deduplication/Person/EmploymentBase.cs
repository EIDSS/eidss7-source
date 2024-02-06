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
    public class EmploymentBase : PersonDeduplicationBaseComponent, IDisposable
	{
		#region Globals

		#region Dependencies
		[Inject]
		private ILogger<EmploymentBase> Logger { get; set; }

		#endregion

		#region Parameters
		public PersonDeduplicationDetailsViewModel Model { get; set; }

		#endregion

		#region Protected and Public Members
		protected bool chkCheckAllEmp { get; set; }
		protected bool chkCheckAllEmp2 { get; set; }

		protected RadzenCheckBoxList<int> rcblEmp;
		protected RadzenCheckBoxList<int> rcblEmp2;

		//protected const Int16 IsEmployedTypeID = 33;
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

		protected async Task OnCheckAllEmpChangeAsync(bool value)
		{
			if (value == true)
			{
				chkCheckAllEmp = true;
				chkCheckAllEmp2 = false;
                PersonDeduplicationService.chkCheckAllEmp = true;
                PersonDeduplicationService.chkCheckAllEmp2 = false;
                await CheckAllAsync(PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2, chkCheckAllEmp, chkCheckAllEmp2, PersonDeduplicationService.SurvivorEmpList, "ValidEmp");
				TabEmpValid();
				StateHasChanged();
			}
			else
			{
				await BindTabEmpAsync();
				//HideIDFieldsinTabs();
			}
		}

		protected async Task OnCheckAllEmp2ChangeAsync(bool value)
		{
			if (value == true)
			{
				chkCheckAllEmp = false;
				chkCheckAllEmp2 = true;
                PersonDeduplicationService.chkCheckAllEmp = false;
                PersonDeduplicationService.chkCheckAllEmp2 = true;
                await CheckAllAsync(PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList, chkCheckAllEmp2, chkCheckAllEmp, PersonDeduplicationService.SurvivorEmpList, "ValidEmp");
				TabEmpValid();
			}
			else
			{
				await BindTabEmpAsync();
				//HideIDFieldsinTabs();
			}
		}

		protected async Task OnCheckBoxListEmpSelectionChangeAsync(IEnumerable<int> values)
		{
			string value = string.Empty;
			string label = string.Empty;
			IEnumerable<int> list = (IEnumerable<int>)PersonDeduplicationService.EmpList.Where(s => s.Checked == true).Select(s => s.Index);
			int index = 0;

			if (values.Count() > list.Count())
			{
				index = values.ElementAt(values.Count() - 1);
				PersonDeduplicationService.EmpList[index].Checked = true;
			}
			else
			{
				IEnumerable<int> difference = list.Except(values);
				index = difference.ElementAt(0);
				PersonDeduplicationService.EmpList[index].Checked = false;
			}

			if (AllFieldValuePairsUnmatched() == true)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.EmpList[index].Checked = false;
				PersonDeduplicationService.EmpValues = (IEnumerable<int>)PersonDeduplicationService.EmpList.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else if (PersonDeduplicationService.RecordSelection == 0 && PersonDeduplicationService.Record2Selection == 0)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.EmpList[index].Checked = false;
				PersonDeduplicationService.EmpValues = (IEnumerable<int>)PersonDeduplicationService.EmpList.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else
			{
				if (PersonDeduplicationService.EmpList[index].Checked)
				{
					value = PersonDeduplicationService.EmpList[index].Value;
					if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.EmployerRegion)
					{
						SelectAllAndUnSelectAll(index, EMPLOYERADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2, PersonDeduplicationService.SurvivorEmpList);
						SelectAllAndUnSelectAll(EmployeridfsRegion, ADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2, PersonDeduplicationService.SurvivorEmpList);
					}
					else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.SchoolRegion)
					{
						SelectAllAndUnSelectAll(index, SCHOOLADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2, PersonDeduplicationService.SurvivorEmpList);
						SelectAllAndUnSelectAll(SchoolidfsRegion, ADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2, PersonDeduplicationService.SurvivorEmpList);
					}
					else
					{
						//PersonDeduplicationService.EmpList2[index].Checked = false;
						PersonDeduplicationService.EmpList[index].Checked = true;
						PersonDeduplicationService.EmpList2[index].Checked = false;

						if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.IsEmployedTypeName)
						{
							SelectAndUnSelectIDfield(IsEmployedTypeID, PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2, PersonDeduplicationService.SurvivorEmpList);
						}
						else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.EmployerCountry)
						{
							SelectAndUnSelectIDfield(EmployeridfsCountry, PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2, PersonDeduplicationService.SurvivorEmpList);
						}
						else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.IsStudentTypeName)
						{
							SelectAndUnSelectIDfield(IsStudentTypeID, PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2, PersonDeduplicationService.SurvivorEmpList);
						}
						else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.SchoolCountry)
						{
							SelectAndUnSelectIDfield(SchoolidfsCountry, PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2, PersonDeduplicationService.SurvivorEmpList);
						}
						else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.OccupationTypeName)
						{
							SelectAndUnSelectIDfield(OccupationTypeID, PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2, PersonDeduplicationService.SurvivorEmpList);
						}
						//else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.YNEmployerForeignAddress)
						//{
						//	//SelectAndUnSelectIDfield(EmployerForeignAddressIndicator, CheckBoxList5, CheckBoxList6, CType(Session(EmpList), List(Of Field)), CType(Session(EmpList2), List(Of Field)), CType(Session(SURVIVOR_LIST_EMP), List(Of Field)))
						//	SelectAndUnSelectIDfield(EmployerGeoLocationID, PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2, PersonDeduplicationService.SurvivorEmpList);
						//}
						//else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.YNSchoolForeignAddress)
						//{
						//	//SelectAndUnSelectIDfield(SchoolForeignAddressIndicator, CheckBoxList5, CheckBoxList6, CType(Session(EmpList), List(Of Field)), CType(Session(EmpList2), List(Of Field)), CType(Session(SURVIVOR_LIST_EMP), List(Of Field)))
						//	SelectAndUnSelectIDfield(SchoolGeoLocationID, PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2, PersonDeduplicationService.SurvivorEmpList);
						//}
					}
					//}

					//if (PersonDeduplicationService.EmpList[index].Selected | CheckBoxList6.Items(index).Selected)

					if (PersonDeduplicationService.SurvivorEmpList != null)
					{
						if (PersonDeduplicationService.SurvivorEmpList.Count > 0)
						{
							label = PersonDeduplicationService.SurvivorEmpList[index].Label;

							if (value == null)
							{
								PersonDeduplicationService.SurvivorEmpList[index].Label = label.Replace(PersonDeduplicationService.SurvivorEmpList[index].Value, "");
							}
							else if (PersonDeduplicationService.SurvivorEmpList[index].Value == null)
							{
								//PersonDeduplicationService.SurvivorEmpList[index].Label = label.Replace("<br><font style='color:#333;font-size:12px;font-weight:normal'>", "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + value);
								PersonDeduplicationService.SurvivorEmpList[index].Label = label.Replace(": ", ": " + value);
							}
							else if (PersonDeduplicationService.SurvivorEmpList[index].Value == string.Empty)
							{
								//PersonDeduplicationService.SurvivorEmpList[index].Label = label.Replace("<br><font style='color:#333;font-size:12px;font-weight:normal'>", "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + value);
								PersonDeduplicationService.SurvivorEmpList[index].Label = label.Replace(": ", ": " + value);
							}
							else
							{
								PersonDeduplicationService.SurvivorEmpList[index].Label = label.Replace(PersonDeduplicationService.SurvivorEmpList[index].Value, value);
							}

							PersonDeduplicationService.SurvivorEmpList[index].Value = value;
						}
					}
				}

				PersonDeduplicationService.EmpValues = (IEnumerable<int>)PersonDeduplicationService.EmpList.Where(s => s.Checked == true).Select(s => s.Index);
				PersonDeduplicationService.EmpValues2 = (IEnumerable<int>)PersonDeduplicationService.EmpList2.Where(s => s.Checked == true).Select(s => s.Index);

				PersonDeduplicationService.chkCheckAllEmp = false;
				PersonDeduplicationService.chkCheckAllEmp2 = false;

				await EableDisableMergeButtonAsync();
			}
		}

		protected async Task OnCheckBoxListEmp2SelectionChangeAsync(IEnumerable<int> values)
		{
			string value = string.Empty;
			string label = string.Empty;
			IEnumerable<int> list = (IEnumerable<int>)PersonDeduplicationService.EmpList2.Where(s => s.Checked == true).Select(s => s.Index);
			int index = 0;

			if (values.Count() > list.Count())
			{
				index = values.ElementAt(values.Count() - 1);
				PersonDeduplicationService.EmpList2[index].Checked = true;
			}
			else
			{
				IEnumerable<int> difference = list.Except(values);
				index = difference.ElementAt(0);
				PersonDeduplicationService.EmpList2[index].Checked = false;
			}

			if (AllFieldValuePairsUnmatched() == true)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.EmpList2[index].Checked = false;
				PersonDeduplicationService.EmpValues2 = (IEnumerable<int>)PersonDeduplicationService.EmpList2.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else if (PersonDeduplicationService.RecordSelection == 0 && PersonDeduplicationService.Record2Selection == 0)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.EmpList2[index].Checked = false;
				PersonDeduplicationService.EmpValues2 = (IEnumerable<int>)PersonDeduplicationService.EmpList2.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else
			{
				if (PersonDeduplicationService.EmpList2[index].Checked)
				{
					value = PersonDeduplicationService.EmpList2[index].Value;
					if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.EmployerRegion)
					{
						SelectAllAndUnSelectAll(index, EMPLOYERADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList, PersonDeduplicationService.SurvivorEmpList);
						SelectAllAndUnSelectAll(EmployeridfsRegion, ADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList, PersonDeduplicationService.SurvivorEmpList);
					}
					else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.SchoolRegion)
					{
						SelectAllAndUnSelectAll(index, SCHOOLADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList, PersonDeduplicationService.SurvivorEmpList);
						SelectAllAndUnSelectAll(SchoolidfsRegion, ADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList, PersonDeduplicationService.SurvivorEmpList);
					}
					else
					{
						//PersonDeduplicationService.EmpList[index].Checked = false;
						PersonDeduplicationService.EmpList[index].Checked = false;
						PersonDeduplicationService.EmpList2[index].Checked = true;

						if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.IsEmployedTypeName)
						{
							SelectAndUnSelectIDfield(IsEmployedTypeID, PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList, PersonDeduplicationService.SurvivorEmpList);
						}
						else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.EmployerCountry)
						{
							SelectAndUnSelectIDfield(EmployeridfsCountry, PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList, PersonDeduplicationService.SurvivorEmpList);
						}
						else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.IsStudentTypeName)
						{
							SelectAndUnSelectIDfield(IsStudentTypeID, PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList, PersonDeduplicationService.SurvivorEmpList);
						}
						else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.SchoolCountry)
						{
							SelectAndUnSelectIDfield(SchoolidfsCountry, PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList, PersonDeduplicationService.SurvivorEmpList);
						}
						else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.OccupationTypeName)
						{
							SelectAndUnSelectIDfield(OccupationTypeID, PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList, PersonDeduplicationService.SurvivorEmpList);
						}
						//else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.YNEmployerForeignAddress)
						//{
						//	//SelectAndUnSelectIDfield(EmployerForeignAddressIndicator, CType(Session(EmpList2), List(Of Field)), CType(Session(EmpList), List(Of Field)), CType(Session(SURVIVOR_LIST_EMP), List(Of Field)))
						//	SelectAndUnSelectIDfield(EmployerGeoLocationID, PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList, PersonDeduplicationService.SurvivorEmpList);
						//}
						//else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.YNSchoolForeignAddress)
						//{
						//	//SelectAndUnSelectIDfield(SchoolForeignAddressIndicator, CType(Session(EmpList2), List(Of Field)), CType(Session(EmpList), List(Of Field)), CType(Session(SURVIVOR_LIST_EMP), List(Of Field)))
						//	SelectAndUnSelectIDfield(SchoolGeoLocationID, PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList, PersonDeduplicationService.SurvivorEmpList);
						//}
					}
					//}

					if (PersonDeduplicationService.SurvivorEmpList != null)
					{
						if (PersonDeduplicationService.SurvivorEmpList.Count > 0)
						{
							label = PersonDeduplicationService.SurvivorEmpList[index].Label;

							if (value == null)
							{
								PersonDeduplicationService.SurvivorEmpList[index].Label = label.Replace(PersonDeduplicationService.SurvivorEmpList[index].Value, "");
							}
							else if (PersonDeduplicationService.SurvivorEmpList[index].Value == null)
							{
								//PersonDeduplicationService.SurvivorEmpList[index].Label = label.Replace("<br><font style='color:#333;font-size:12px;font-weight:normal'>", "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + value);
								PersonDeduplicationService.SurvivorEmpList[index].Label = label.Replace(": ", ": " + value);
							}
							else if (PersonDeduplicationService.SurvivorEmpList[index].Value == string.Empty)
							{
								//PersonDeduplicationService.SurvivorEmpList[index].Label = label.Replace("<br><font style='color:#333;font-size:12px;font-weight:normal'>", "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + value);
								PersonDeduplicationService.SurvivorEmpList[index].Label = label.Replace(": ", ": " + value);
							}
							else
							{
								PersonDeduplicationService.SurvivorEmpList[index].Label = label.Replace(PersonDeduplicationService.SurvivorEmpList[index].Value, value);
							}

							PersonDeduplicationService.SurvivorEmpList[index].Value = value;
						}
					}
				}

				PersonDeduplicationService.EmpValues = (IEnumerable<int>)PersonDeduplicationService.EmpList.Where(s => s.Checked == true).Select(s => s.Index);
				PersonDeduplicationService.EmpValues2 = (IEnumerable<int>)PersonDeduplicationService.EmpList2.Where(s => s.Checked == true).Select(s => s.Index);

				PersonDeduplicationService.chkCheckAllEmp = false;
				PersonDeduplicationService.chkCheckAllEmp2 = false;

				await EableDisableMergeButtonAsync();
			}
		}

		protected async Task OnDataListEmpSelectionChangeAsync(bool args, int index)
		{
			string value = string.Empty;
			string label = string.Empty;

			if (args == true)
			{
				PersonDeduplicationService.EmpList[index].Checked = true;
			}

			if (AllFieldValuePairsUnmatched() == true)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.EmpList[index].Checked = false;
				//PersonDeduplicationService.EmpValues = (IEnumerable<int>)PersonDeduplicationService.EmpList.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else if (PersonDeduplicationService.RecordSelection == 0 && PersonDeduplicationService.Record2Selection == 0)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.EmpList[index].Checked = false;
				//PersonDeduplicationService.EmpValues = (IEnumerable<int>)PersonDeduplicationService.EmpList.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else
			{
				if (PersonDeduplicationService.EmpList[index].Checked)
				{
					value = PersonDeduplicationService.EmpList[index].Value;

					if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.EmployerRegion)
					{
						SelectAllAndUnSelectAll(index, EMPLOYERADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2, PersonDeduplicationService.SurvivorEmpList);
						SelectAllAndUnSelectAll(EmployeridfsRegion, ADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2, PersonDeduplicationService.SurvivorEmpList);
					}
					else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.SchoolRegion)
					{
						SelectAllAndUnSelectAll(index, SCHOOLADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2, PersonDeduplicationService.SurvivorEmpList);
						SelectAllAndUnSelectAll(SchoolidfsRegion, ADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2, PersonDeduplicationService.SurvivorEmpList);
					}
					else
					{
                        PersonDeduplicationService.EmpList2[index].Checked = false;
                        //PersonDeduplicationService.EmpList[index].Checked = true;
                        //PersonDeduplicationService.EmpList2[index].Checked = false;

                        if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.IsEmployedTypeName)
						{
							SelectAndUnSelectIDfield(IsEmployedTypeID, PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2, PersonDeduplicationService.SurvivorEmpList);
						}
						else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.EmployerCountry)
						{
							SelectAndUnSelectIDfield(EmployeridfsCountry, PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2, PersonDeduplicationService.SurvivorEmpList);
						}
						else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.IsStudentTypeName)
						{
							SelectAndUnSelectIDfield(IsStudentTypeID, PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2, PersonDeduplicationService.SurvivorEmpList);
						}
						else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.SchoolCountry)
						{
							SelectAndUnSelectIDfield(SchoolidfsCountry, PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2, PersonDeduplicationService.SurvivorEmpList);
						}
						else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.OccupationTypeName)
						{
							SelectAndUnSelectIDfield(OccupationTypeID, PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2, PersonDeduplicationService.SurvivorEmpList);
						}
					}

					if (PersonDeduplicationService.SurvivorEmpList != null)
					{
						if (PersonDeduplicationService.SurvivorEmpList.Count > 0)
						{
							label = PersonDeduplicationService.SurvivorEmpList[index].Label;

							//if (value == null)
							//{
							//	PersonDeduplicationService.SurvivorEmpList[index].Label = label.Replace(PersonDeduplicationService.SurvivorEmpList[index].Value, "");
							//}
							//else if (PersonDeduplicationService.SurvivorEmpList[index].Value == null)
							//{
							//	PersonDeduplicationService.SurvivorEmpList[index].Label = label.Replace(": ", ": " + value);
							//}
							//else if (PersonDeduplicationService.SurvivorEmpList[index].Value == string.Empty)
							//{
							//	PersonDeduplicationService.SurvivorEmpList[index].Label = label.Replace(": ", ": " + value);
							//}
							//else
							//{
							//	PersonDeduplicationService.SurvivorEmpList[index].Label = label.Replace(PersonDeduplicationService.SurvivorEmpList[index].Value, value);
							//}

							PersonDeduplicationService.SurvivorEmpList[index].Value = value;
						}
					}
				}

				//PersonDeduplicationService.EmpValues = (IEnumerable<int>)PersonDeduplicationService.EmpList.Where(s => s.Checked == true).Select(s => s.Index);
				//PersonDeduplicationService.EmpValues2 = (IEnumerable<int>)PersonDeduplicationService.EmpList2.Where(s => s.Checked == true).Select(s => s.Index);

                PersonDeduplicationService.chkCheckAllEmp = PersonDeduplicationService.EmpList.Where(x => !x.Checked).Count() == 0;
                PersonDeduplicationService.chkCheckAllEmp2 = PersonDeduplicationService.EmpList2.Where(x => !x.Checked).Count() == 0;

                await EableDisableMergeButtonAsync();
			}
		}

		protected async Task OnDataListEmp2SelectionChangeAsync(bool args, int index)
		{
			string value = string.Empty;
			string label = string.Empty;

			if (args == true)
			{
				PersonDeduplicationService.EmpList2[index].Checked = true;
			}

			if (AllFieldValuePairsUnmatched() == true)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.EmpList2[index].Checked = false;
				//PersonDeduplicationService.EmpValues2 = (IEnumerable<int>)PersonDeduplicationService.EmpList2.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else if (PersonDeduplicationService.RecordSelection == 0 && PersonDeduplicationService.Record2Selection == 0)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
				PersonDeduplicationService.EmpList2[index].Checked = false;
				//PersonDeduplicationService.EmpValues2 = (IEnumerable<int>)PersonDeduplicationService.EmpList2.Where(s => s.Checked == true).Select(s => s.Index);
			}
			else
			{
				if (PersonDeduplicationService.EmpList2[index].Checked)
				{
					value = PersonDeduplicationService.EmpList2[index].Value;

					if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.EmployerRegion)
					{
						SelectAllAndUnSelectAll(index, EMPLOYERADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList, PersonDeduplicationService.SurvivorEmpList);
						SelectAllAndUnSelectAll(EmployeridfsRegion, ADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList, PersonDeduplicationService.SurvivorEmpList);
					}
					else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.SchoolRegion)
					{
						SelectAllAndUnSelectAll(index, SCHOOLADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList, PersonDeduplicationService.SurvivorEmpList);
						SelectAllAndUnSelectAll(SchoolidfsRegion, ADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList, PersonDeduplicationService.SurvivorEmpList);
					}
					else
					{
                        PersonDeduplicationService.EmpList[index].Checked = false;
                        //PersonDeduplicationService.EmpList[index].Checked = false;
                        //PersonDeduplicationService.EmpList2[index].Checked = true;

                        if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.IsEmployedTypeName)
						{
							SelectAndUnSelectIDfield(IsEmployedTypeID, PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList, PersonDeduplicationService.SurvivorEmpList);
						}
						else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.EmployerCountry)
						{
							SelectAndUnSelectIDfield(EmployeridfsCountry, PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList, PersonDeduplicationService.SurvivorEmpList);
						}
						else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.IsStudentTypeName)
						{
							SelectAndUnSelectIDfield(IsStudentTypeID, PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList, PersonDeduplicationService.SurvivorEmpList);
						}
						else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.SchoolCountry)
						{
							SelectAndUnSelectIDfield(SchoolidfsCountry, PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList, PersonDeduplicationService.SurvivorEmpList);
						}
						else if (PersonDeduplicationService.EmpList[index].Key == PersonDeduplicationEmpConstants.OccupationTypeName)
						{
							SelectAndUnSelectIDfield(OccupationTypeID, PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList, PersonDeduplicationService.SurvivorEmpList);
						}
					}

					if (PersonDeduplicationService.SurvivorEmpList != null)
					{
						if (PersonDeduplicationService.SurvivorEmpList.Count > 0)
						{
							label = PersonDeduplicationService.SurvivorEmpList[index].Label;

							//if (value == null)
							//{
							//	PersonDeduplicationService.SurvivorEmpList[index].Label = label.Replace(PersonDeduplicationService.SurvivorEmpList[index].Value, "");
							//}
							//else if (PersonDeduplicationService.SurvivorEmpList[index].Value == null)
							//{
							//	PersonDeduplicationService.SurvivorEmpList[index].Label = label.Replace(": ", ": " + value);
							//}
							//else if (PersonDeduplicationService.SurvivorEmpList[index].Value == string.Empty)
							//{
							//	PersonDeduplicationService.SurvivorEmpList[index].Label = label.Replace(": ", ": " + value);
							//}
							//else
							//{
							//	PersonDeduplicationService.SurvivorEmpList[index].Label = label.Replace(PersonDeduplicationService.SurvivorEmpList[index].Value, value);
							//}

							PersonDeduplicationService.SurvivorEmpList[index].Value = value;
						}
					}
				}

                //PersonDeduplicationService.EmpValues = (IEnumerable<int>)PersonDeduplicationService.EmpList.Where(s => s.Checked == true).Select(s => s.Index);
                //PersonDeduplicationService.EmpValues2 = (IEnumerable<int>)PersonDeduplicationService.EmpList2.Where(s => s.Checked == true).Select(s => s.Index);

                PersonDeduplicationService.chkCheckAllEmp = PersonDeduplicationService.EmpList.Where(x => !x.Checked).Count() == 0;
                PersonDeduplicationService.chkCheckAllEmp2 = PersonDeduplicationService.EmpList2.Where(x => !x.Checked).Count() == 0;

                await EableDisableMergeButtonAsync();
			}
		}
	}
}
