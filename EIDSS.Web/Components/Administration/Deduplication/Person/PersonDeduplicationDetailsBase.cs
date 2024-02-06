using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.SubAreas.Deduplication.ViewModels.PersonDeduplication;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Administration.Deduplication.Person
{
    public class PersonDeduplicationDetailsBase : PersonDeduplicationBaseComponent
    {
		#region Globals

		#region Dependencies

		[Inject]
		private IJSRuntime JsRuntime { get; set; }

		[Inject]
        private IPersonClient PersonClient { get; set; }

        [Inject]
        private ILogger<PersonDeduplicationDetailsBase> Logger { get; set; }

		#endregion

		#region Parameters
		[Parameter]
		public PersonDeduplicationDetailsViewModel Model { get; set; }

		[Parameter]
		public PersonDeduplicationTabEnum Tab { get; set; }
		#endregion

		#region Protected and Public Variables

		protected RadzenTemplateForm<PersonDeduplicationDetailsViewModel> form;

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
			PersonDeduplicationService.OnChange += async (property) => await OnStateContainerChangeAsync(property);
			

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

				PersonDeduplicationService.OnChange -= async (property) => await OnStateContainerChangeAsync(property);
			}
			catch (Exception)
            {
                throw;
            }
        }

		public void OnChange(int index)
		{
			Tab = (PersonDeduplicationTabEnum)index;
			OnTabChange(index);
		}

		public void NextClicked()
		{
			switch (Tab)
			{
				case PersonDeduplicationTabEnum.Information:
                    Tab = PersonDeduplicationTabEnum.Address;
                    showPreviousButton = true;
					showNextButton = true;
					break;
				case PersonDeduplicationTabEnum.Address:
					Tab = PersonDeduplicationTabEnum.Employment;
					showPreviousButton = true;
					showNextButton = false;
					break;
			}

			PersonDeduplicationService.TabChangeIndicator = true;
		}

		public void PreviousClicked()
		{
			switch (Tab)
			{
				case PersonDeduplicationTabEnum.Address:
					Tab = PersonDeduplicationTabEnum.Information;
					showPreviousButton = false;
					showNextButton = true;
					break;
                case PersonDeduplicationTabEnum.Employment:
                    Tab = PersonDeduplicationTabEnum.Address;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
            }

			PersonDeduplicationService.TabChangeIndicator = true;
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
					var uri = $"{NavManager.BaseUri}Administration/Deduplication/PersonDeduplication?showSelectedRecordsIndicator=true";
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
			else if (PersonDeduplicationService.RecordSelection == 0 && PersonDeduplicationService.Record2Selection == 0)
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
					foreach (Field item in PersonDeduplicationService.SurvivorInfoList)
					{
						item.Checked = true;
						item.Disabled = true;
					}

					foreach (Field item in PersonDeduplicationService.SurvivorAddressList)
					{
						item.Checked = true;
						item.Disabled = true;
					}

					foreach (Field item in PersonDeduplicationService.SurvivorEmpList)
					{
						item.Checked = true;
						item.Disabled = true;
					}

					showDetails = false;
					showReview = true;

					PersonDeduplicationService.SurvivorInfoValues = (IEnumerable<int>)PersonDeduplicationService.SurvivorInfoList.Where(s => s.Checked == true).Select(s => s.Index);
					PersonDeduplicationService.SurvivorAddressValues = (IEnumerable<int>)PersonDeduplicationService.SurvivorAddressList.Where(s => s.Checked == true).Select(s => s.Index);
					PersonDeduplicationService.SurvivorEmpValues = (IEnumerable<int>)PersonDeduplicationService.SurvivorEmpList.Where(s => s.Checked == true).Select(s => s.Index);
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

		#endregion
		#region Private Methods

		private async Task InitializeModelAsync()
		{
			if (Model == null)
			{
				Model = new PersonDeduplicationDetailsViewModel()
				{
					LeftHumanMasterID = PersonDeduplicationService.HumanMasterID,
					RightHumanMasterID = PersonDeduplicationService.HumanMasterID2,
					InformationSection = new PersonDeduplicationInformationSectionViewModel(),
					AddressSection = new PersonDeduplicationAddressSectionViewModel(),
					EmploymentSection = new PersonDeduplicationEmploymentSectionViewModel()
				};
			}
			//PersonDeduplicationService.HumanMasterID = Model.LeftHumanMasterID;
			//PersonDeduplicationService.HumanMasterID2 = Model.RightHumanMasterID;
			await FillDeduplicationDetailsAsync(Model.LeftHumanMasterID, Model.RightHumanMasterID);


			PersonDeduplicationService.OnChange += async (property) => await OnStateContainerChangeAsync(property);

		}

		private async Task OnStateContainerChangeAsync(string property)
		{
			await InvokeAsync(StateHasChanged);
		}

		private async Task FillDeduplicationDetailsAsync(long humanID, long humanID2)
		{
			try
			{
				PersonDeduplicationService.HumanMasterID = humanID;
				PersonDeduplicationService.HumanMasterID2 = humanID2;

				HumanPersonDetailsRequestModel request = new HumanPersonDetailsRequestModel();
				request.LangID = GetCurrentLanguage();
				request.HumanMasterID = humanID;

				HumanPersonDetailsRequestModel request2 = new HumanPersonDetailsRequestModel();
				request2.LangID = GetCurrentLanguage();
				request2.HumanMasterID = humanID2;

				List<DiseaseReportPersonalInformationViewModel> list = await PersonClient.GetHumanDiseaseReportPersonInfoAsync(request);
				List<DiseaseReportPersonalInformationViewModel> list2 = await PersonClient.GetHumanDiseaseReportPersonInfoAsync(request2);

				DiseaseReportPersonalInformationViewModel record = list.FirstOrDefault();
				DiseaseReportPersonalInformationViewModel record2 = list2.FirstOrDefault();

				List<KeyValuePair<string, string>> kvInfo = new List<KeyValuePair<string, string>>();
				List<KeyValuePair<string, string>> kvInfo2 = new List<KeyValuePair<string, string>>();

				Type type = record.GetType();
				PropertyInfo[] props = type.GetProperties();

				Type type2 = record2.GetType();
				PropertyInfo[] props2 = type2.GetProperties();

				string value = string.Empty;

				List<Field> itemList = new List<Field>();
				List<Field> itemList2 = new List<Field>();

				List<Field> itemListAddress = new List<Field>();
				List<Field> itemListAddress2 = new List<Field>();

				List<Field> itemListEmp = new List<Field>();
				List<Field> itemListEmp2 = new List<Field>();

				for (int index = 0; index <= props.Count() - 1; index++)
				{
					if (IsInTabInfo(props[index].Name) == true)
					{
						FillTabList(props[index].Name, props[index].GetValue(record) == null ? null : props[index].GetValue(record).ToString(), props2[index].Name, props2[index].GetValue(record2) == null ? null : props2[index].GetValue(record2).ToString(), ref itemList, ref itemList2, ref keyDict, ref labelDict);
					}
					if (IsInTabAddress(props[index].Name) == true)
					{
						FillTabList(props[index].Name, props[index].GetValue(record) == null ? null : props[index].GetValue(record).ToString(), props2[index].Name, props2[index].GetValue(record2) == null ? null : props2[index].GetValue(record2).ToString(), ref itemListAddress, ref itemListAddress2, ref keyDict2, ref labelDict2);
					}
					if (IsInTabEmp(props[index].Name) == true)
					{
						FillTabList(props[index].Name, props[index].GetValue(record)== null ? null : props[index].GetValue(record).ToString(), props2[index].Name, props2[index].GetValue(record2) == null ? null : props2[index].GetValue(record2).ToString(), ref itemListEmp, ref itemListEmp2, ref keyDict3, ref labelDict3);
					}
				}

                //Bind Tab Person Information 
                PersonDeduplicationService.InfoList0 = itemList.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));
                PersonDeduplicationService.InfoList02 = itemList2.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));

                PersonDeduplicationService.InfoList = itemList.OrderBy(s => s.Index).ToList();
				PersonDeduplicationService.InfoList2 = itemList2.OrderBy(s => s.Index).ToList();

				foreach (Field item in PersonDeduplicationService.InfoList)
				{
                    if (item.Checked == true)
                    {
						item.Checked = true;
						item.Disabled = true;
						PersonDeduplicationService.InfoList2[item.Index].Checked = true;
						PersonDeduplicationService.InfoList2[item.Index].Disabled = true;
					}
                }

				PersonDeduplicationService.InfoValues = (IEnumerable<int>)PersonDeduplicationService.InfoList.Where(s => s.Checked == true).Select(s => s.Index);
				PersonDeduplicationService.InfoValues2 = (IEnumerable<int>)PersonDeduplicationService.InfoList2.Where(s => s.Checked == true).Select(s => s.Index);

                //PersonDeduplicationService.InfoList0 = PersonDeduplicationService.InfoList.Select(a => a.Copy()).ToList();
                //PersonDeduplicationService.InfoList02 = PersonDeduplicationService.InfoList2.Select(a => a.Copy()).ToList();

                //Bind Tab Person Current Residence 
                PersonDeduplicationService.AddressList0 = itemListAddress.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));
                PersonDeduplicationService.AddressList02 = itemListAddress2.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));

                PersonDeduplicationService.AddressList = itemListAddress.OrderBy(s => s.Index).ToList();
				PersonDeduplicationService.AddressList2 = itemListAddress2.OrderBy(s => s.Index).ToList();

				foreach (Field item in PersonDeduplicationService.AddressList)
				{
					if (item.Checked == true)
					{
						item.Checked = true;
						item.Disabled = true;
						PersonDeduplicationService.AddressList2[item.Index].Checked = true;
						PersonDeduplicationService.AddressList2[item.Index].Disabled = true;
					}
					else if (IsInHumanAddressGroup(item.Key) == true)
					{
						item.Disabled = true;
						PersonDeduplicationService.AddressList2[item.Index].Disabled = true;
					}
					else if (IsInHumanAltAddressGroup(item.Key) == true)
					{
						item.Disabled = true;
						PersonDeduplicationService.AddressList2[item.Index].Disabled = true;
					}
				}

				//foreach (Field item in PersonDeduplicationService.AddressList2)
				//{
				//	if (IsInHumanAddressGroup(item.Key) == true)
				//		item.Disabled = true;
				//	else if (IsInHumanAltAddressGroup(item.Key) == true)
				//		item.Disabled = true;
				//}

				foreach (Field item in PersonDeduplicationService.AddressList)
				{
                    if (item.Key == PersonDeduplicationAddressConstants.HumanRegion && item.Checked == true)
                    {
                        if (GroupAllChecked(item.Index, HUMANADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList) == false)
                        {
							item.Checked = false;
							item.Disabled = false;
							PersonDeduplicationService.AddressList2[item.Index].Checked = false;
							PersonDeduplicationService.AddressList2[item.Index].Disabled = false;
						}
                    }
                    else if (item.Key == PersonDeduplicationAddressConstants.HumanAltRegion && item.Checked == true)
                    {
                        if (GroupAllChecked(item.Index, HUMANALTADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList) == false)
                        {
							item.Checked = false;
							item.Disabled = false;
							PersonDeduplicationService.AddressList2[item.Index].Checked = false;
							PersonDeduplicationService.AddressList2[item.Index].Disabled = false;
						}
                    }
                }

				//foreach (Field item in PersonDeduplicationService.AddressList2)
				//{
				//	if (item.Key == PersonDeduplicationAddressConstants.HumanRegion && item.Checked == true)
				//	{
				//		if (GroupAllChecked(item.Index, HUMANADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList2) == false)
				//		{
				//			item.Checked = false;
				//			item.Disabled = false;
				//		}
				//	}
				//	else if (item.Key == PersonDeduplicationAddressConstants.HumanAltRegion && item.Checked == true)
				//	{
				//		if (GroupAllChecked(item.Index, HUMANALTADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList2) == false)
				//		{
				//			item.Checked = false;
				//			item.Disabled = false;
				//		}
				//	}
				//}

				PersonDeduplicationService.AddressValues = (IEnumerable<int>)PersonDeduplicationService.AddressList.Where(s => s.Checked == true).Select(s => s.Index);
				PersonDeduplicationService.AddressValues2 = (IEnumerable<int>)PersonDeduplicationService.AddressList2.Where(s => s.Checked == true).Select(s => s.Index);

                //PersonDeduplicationService.AddressList0 = PersonDeduplicationService.AddressList.Select(a => a.Copy()).ToList();
                //PersonDeduplicationService.AddressList02 = PersonDeduplicationService.AddressList2.Select(a => a.Copy()).ToList();

                //Bind Tab Person Employment/School Information 
                PersonDeduplicationService.EmpList0 = itemListEmp.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));
                PersonDeduplicationService.EmpList02 = itemListEmp2.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));

                PersonDeduplicationService.EmpList = itemListEmp.OrderBy(s => s.Index).ToList();
				PersonDeduplicationService.EmpList2 = itemListEmp2.OrderBy(s => s.Index).ToList();

				foreach (Field item in PersonDeduplicationService.EmpList)
				{
					if (item.Checked == true)
					{
						item.Checked = true;
						item.Disabled = true;
						PersonDeduplicationService.EmpList2[item.Index].Checked = true;
						PersonDeduplicationService.EmpList2[item.Index].Disabled = true;
					}
					else if (IsInEmployerAddressGroup(item.Key) == true)
					{
						item.Disabled = true;
						PersonDeduplicationService.EmpList2[item.Index].Disabled = true;
					}
					else if (IsInSchoolAddressGroup(item.Key) == true)
					{
						item.Disabled = true;
						PersonDeduplicationService.EmpList2[item.Index].Disabled = true;
					}
				}

				//foreach (Field item in PersonDeduplicationService.EmpList2)
				//{
				//	if (IsInEmployerAddressGroup(item.Key) == true)
				//		item.Disabled = true;
				//	else if (IsInSchoolAddressGroup(item.Key) == true)
				//		item.Disabled = true;
				//}

				foreach (Field item in PersonDeduplicationService.EmpList)
				{
                    if (item.Key == PersonDeduplicationEmpConstants.EmployerRegion && item.Checked == true)
                    {
                        if (GroupAllChecked(item.Index, EMPLOYERADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList) == false)
                        {
							item.Checked = false;
							item.Disabled = false;
							PersonDeduplicationService.EmpList2[item.Index].Checked = false;
							PersonDeduplicationService.EmpList2[item.Index].Disabled = false;
						}
                    }
                    else if (item.Key == PersonDeduplicationEmpConstants.SchoolRegion && item.Checked == true)
                    {
                        if (GroupAllChecked(item.Index, SCHOOLADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList) == false)
                        {
							item.Checked = false;
							item.Disabled = false;
							PersonDeduplicationService.EmpList2[item.Index].Checked = false;
							PersonDeduplicationService.EmpList2[item.Index].Disabled = false;
						}
                    }
                }

				//foreach (Field item in PersonDeduplicationService.EmpList2)
				//{
				//	if (item.Key == PersonDeduplicationEmpConstants.EmployerRegion && item.Checked == true)
				//	{
				//		if (GroupAllChecked(item.Index, EMPLOYERADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList2) == false)
				//		{
				//			item.Checked = false;
				//			item.Disabled = false;
				//		}
				//	}
				//	else if (item.Key == PersonDeduplicationEmpConstants.SchoolRegion && item.Checked == true)
				//	{
				//		if (GroupAllChecked(item.Index, SCHOOLADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList2) == false)
				//		{
				//			item.Checked = false;
				//			item.Disabled = false;
				//		}
				//	}
				//}

				PersonDeduplicationService.EmpValues = (IEnumerable<int>)PersonDeduplicationService.EmpList.Where(s => s.Checked == true).Select(s => s.Index);
				PersonDeduplicationService.EmpValues2 = (IEnumerable<int>)PersonDeduplicationService.EmpList2.Where(s => s.Checked == true).Select(s => s.Index);

				//PersonDeduplicationService.EmpList0 = PersonDeduplicationService.EmpList.Select(a => a.Copy()).ToList();
				//PersonDeduplicationService.EmpList02 = PersonDeduplicationService.EmpList2.Select(a => a.Copy()).ToList();
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

					if (value == value2 || key == PersonDeduplicationInfoConstants.EIDSSPersonID)
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
						//item.Label = GetLabelResource(labelDict[item.Index].ToString()) + ": " + temp;
						item.Label = GetLabelResource(labelDict[item.Index].ToString()) + ": ";
						//item2.Label = "<font style='color:#2C6187;font-size:12px'>" +labelDict[item.Index].ToString() + "</font>" + "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + temp2 + "</font>";
						//item.Label = labelDict[item.Index].ToString() + "<br>" + temp2;
						//item2.Label = GetLabelResource(labelDict[item.Index].ToString()) + ": " + temp2;
						item2.Label = GetLabelResource(labelDict[item.Index].ToString()) + ": ";
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
						//item.Label = GetLabelResource(labelDict[item.Index].ToString()) + ": " + temp;
						item.Label = GetLabelResource(labelDict[item.Index].ToString()) + ": ";
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
						//item2.Label = GetLabelResource(labelDict[item.Index].ToString()) + ": " + temp;
						item2.Label = GetLabelResource(labelDict[item.Index].ToString()) + ": ";
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

		protected bool AllFieldValuePairsSelected()
		{
			//try
			//{
			foreach (Field item in PersonDeduplicationService.InfoList)
			{
				if (item.Checked == false && PersonDeduplicationService.InfoList2[item.Index].Checked == false)
				{
					Tab = PersonDeduplicationTabEnum.Information;
					showNextButton = true;
					return false;
				}
			}

			foreach (Field item in PersonDeduplicationService.AddressList)
			{
				if (item.Checked == false && PersonDeduplicationService.AddressList2[item.Index].Checked == false)
				{
					if (PersonDeduplicationService.AddressList[item.Index].Key == PersonDeduplicationAddressConstants.HumanGeoLocationID)
					{
						if (PersonDeduplicationService.AddressList[item.Index - 4].Checked == true && PersonDeduplicationService.AddressList2[item.Index - 4].Checked == true)
						{
							if (PersonDeduplicationService.SurvivorHumanMasterID == PersonDeduplicationService.HumanMasterID)
								item.Checked = true;
							else
								PersonDeduplicationService.AddressList2[item.Index].Checked = true;
						}
						else if (PersonDeduplicationService.AddressList[item.Index - 4].Key == PersonDeduplicationAddressConstants.HumanidfsRegion && PersonDeduplicationService.AddressList[item.Index - 4].Checked == true)
							item.Checked = true;
						else if (PersonDeduplicationService.AddressList[item.Index - 4].Key == PersonDeduplicationAddressConstants.HumanidfsRegion && PersonDeduplicationService.AddressList2[item.Index - 4].Checked == true)
							PersonDeduplicationService.AddressList2[item.Index].Checked = true;
						else
						{
							Tab = PersonDeduplicationTabEnum.Address;
							showNextButton = true;
							return false;
						}
					}
					else if (PersonDeduplicationService.AddressList[item.Index].Key == PersonDeduplicationAddressConstants.HumanPermGeoLocationID)
					{
						if (PersonDeduplicationService.AddressList[item.Index - 4].Checked == true && PersonDeduplicationService.AddressList2[item.Index - 4].Checked == true)
						{
							if (PersonDeduplicationService.SurvivorHumanMasterID == PersonDeduplicationService.HumanMasterID)
								item.Checked = true;
							else
								PersonDeduplicationService.AddressList2[item.Index].Checked = true;
						}
						else if (PersonDeduplicationService.AddressList[item.Index - 4].Key == PersonDeduplicationAddressConstants.HumanPermidfsRegion && PersonDeduplicationService.AddressList[item.Index - 4].Checked == true)
							item.Checked = true;
						else if (PersonDeduplicationService.AddressList[item.Index - 4].Key == PersonDeduplicationAddressConstants.HumanPermidfsRegion && PersonDeduplicationService.AddressList2[item.Index - 4].Checked == true)
							PersonDeduplicationService.AddressList2[item.Index].Checked = true;
						else
						{
							Tab = PersonDeduplicationTabEnum.Address;
							showNextButton = true;
							return false;
						}
					}
					else if (PersonDeduplicationService.AddressList[item.Index].Key == PersonDeduplicationAddressConstants.HumanAltGeoLocationID)
					{
						if (PersonDeduplicationService.AddressList[item.Index - 4].Checked == true && PersonDeduplicationService.AddressList2[item.Index - 4].Checked == true)
						{
							if (PersonDeduplicationService.SurvivorHumanMasterID == PersonDeduplicationService.HumanMasterID)
								item.Checked = true;
							else
								PersonDeduplicationService.AddressList2[item.Index].Checked = true;
						}
						else if (PersonDeduplicationService.AddressList[item.Index - 4].Key == PersonDeduplicationAddressConstants.HumanAltidfsRegion && PersonDeduplicationService.AddressList[item.Index - 4].Checked == true)
							item.Checked = true;
						else if (PersonDeduplicationService.AddressList[item.Index - 4].Key == PersonDeduplicationAddressConstants.HumanAltidfsRegion && PersonDeduplicationService.AddressList2[item.Index - 4].Checked == true)
							PersonDeduplicationService.AddressList2[item.Index].Checked = true;
						else
						{
							Tab = PersonDeduplicationTabEnum.Address;
							showNextButton = true;
							return false;
						}
					}
					else
					{
						Tab = PersonDeduplicationTabEnum.Address;
						showNextButton = true;
						return false;
					}
				}
			}

			foreach (Field item in PersonDeduplicationService.EmpList)
			{
				if (item.Checked == false && PersonDeduplicationService.EmpList2[item.Index].Checked == false)
				{
					if (PersonDeduplicationService.EmpList[item.Index].Key == PersonDeduplicationEmpConstants.EmployerGeoLocationID)
					{
						if (PersonDeduplicationService.EmpList[item.Index - 4].Checked == true && PersonDeduplicationService.EmpList2[item.Index - 4].Checked == true)
						{
							if (PersonDeduplicationService.SurvivorHumanMasterID == PersonDeduplicationService.HumanMasterID)
								item.Checked = true;
							else
								PersonDeduplicationService.EmpList2[item.Index].Checked = true;
						}
						else if (PersonDeduplicationService.EmpList[item.Index - 4].Key == PersonDeduplicationEmpConstants.EmployeridfsRegion && PersonDeduplicationService.EmpList[item.Index - 4].Checked == true)
							item.Checked = true;
						else if (PersonDeduplicationService.EmpList[item.Index - 4].Key == PersonDeduplicationEmpConstants.EmployeridfsRegion && PersonDeduplicationService.EmpList2[item.Index - 4].Checked == true)
							PersonDeduplicationService.EmpList2[item.Index].Checked = true;
						else
						{
							Tab = PersonDeduplicationTabEnum.Employment;
							showNextButton = true;
							return false;
						}
					}
					else if (PersonDeduplicationService.EmpList[item.Index].Key == PersonDeduplicationEmpConstants.SchoolGeoLocationID)
					{
						if (PersonDeduplicationService.EmpList[item.Index - 4].Checked == true && PersonDeduplicationService.EmpList2[item.Index - 4].Checked == true)
						{
							if (PersonDeduplicationService.SurvivorHumanMasterID == PersonDeduplicationService.HumanMasterID)
								item.Checked = true;
							else
								PersonDeduplicationService.EmpList2[item.Index].Checked = true;
						}
						else if (PersonDeduplicationService.EmpList[item.Index - 4].Key == PersonDeduplicationEmpConstants.SchoolidfsRegion && PersonDeduplicationService.EmpList[item.Index - 4].Checked == true)
							item.Checked = true;
						else if (PersonDeduplicationService.EmpList[item.Index - 4].Key == PersonDeduplicationEmpConstants.SchoolidfsRegion && PersonDeduplicationService.EmpList2[item.Index - 4].Checked == true)
							PersonDeduplicationService.EmpList2[item.Index].Checked = true;
						else
						{
							Tab = PersonDeduplicationTabEnum.Employment;
							showNextButton = true;
							return false;
						}
					}
					else
					{
						Tab = PersonDeduplicationTabEnum.Employment;
						showNextButton = true;
						return false;
					}
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


		#endregion Private Methods

		#region Review
		protected async Task EditClickAsync(int index)
		{
			showDetails = true;
			showReview = false;
			switch (index)
			{
				case 0:
					Tab = PersonDeduplicationTabEnum.Information;
					OnTabChange(0);
					break;
				case 1:
					Tab = PersonDeduplicationTabEnum.Address;
					OnTabChange(1);
					break;
				case 2:
					Tab = PersonDeduplicationTabEnum.Employment;
					OnTabChange(2);
					break;
			}
			await InvokeAsync(StateHasChanged);
		}

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
				//var query = $"?humanMasterID={PersonDeduplicationService.HumanMasterID}&humanMasterID2={PersonDeduplicationService.HumanMasterID2}";
				//var uri = $"{NavManager.BaseUri}{path}{query}";

				//NavManager.NavigateTo(uri, true);
			}
		}

		private async Task DeduplicateRecordsAsync()
		{
			try
			{
				bool result = await DedupeRecordsAsync();
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

		private async Task<bool> DedupeRecordsAsync()
		{
			//try
			//{
			//PersonSaveRequestModel parameters = new PersonSaveRequestModel();
			PersonRecordsDedupeRequestModel parameters = new PersonRecordsDedupeRequestModel();
			Type type = parameters.GetType();
			PropertyInfo[] props = type.GetProperties();
			int index = -1;

			long? HumanidfsCountry = null;
			long? HumanidfsRegion = null;
			long? HumanidfsRayon = null;
			long? HumanidfsSettlement = null;
			long? HumanAltidfsCountry = null;
			long? HumanAltidfsRegion = null;
			long? HumanAltidfsRayon = null;
			long? HumanAltidfsSettlement = null;
			long? HumanPermidfsCountry = null;
			long? HumanPermidfsRegion = null;
			long? HumanPermidfsRayon = null;
			long? HumanPermidfsSettlement = null;
			long? EmployeridfsCountry = null;
			long? EmployeridfsRegion = null;
			long? EmployeridfsRayon = null;
			long? EmployeridfsSettlement = null;
			long? SchoolidfsCountry = null;
			long? SchoolidfsRegion = null;
			long? SchoolidfsRayon = null;
			long? SchoolidfsSettlement = null;

			for (int i = 0; i <= props.Count() - 1; i++)
			{
				if (IsInPersonSaveRequestModelInfo(props[i].Name) == true)
				{
					if (props[i].Name == "LastName")
						index = keyDict["LastOrSurname"];
					else if(props[i].Name == "FirstName")
						index = keyDict["FirstOrGivenName"];
					else if (props[i].Name == "HumanGenderTypeID")
						index = keyDict["GenderTypeID"];
					else if (props[i].Name == "ReportAgeUOMID")
						index = keyDict["ReportedAgeUOMID"];
					else
						index = keyDict[props[i].Name];

					string safeValue = PersonDeduplicationService.SurvivorInfoList[index].Value;
					if (safeValue != null)
					{
						if (props[i].Name == "PersonalIDType" && safeValue == "")
						{
							props[i].SetValue(parameters, null);
						}
						else if (props[i].Name == "DateOfBirth" && safeValue == "")
						{
							props[i].SetValue(parameters, null);
						}
						else
						{
							SetValue(parameters, props[i].Name, safeValue);
						}
					}
					else
					{
						props[i].SetValue(parameters, safeValue);
					}
				}
				else if (IsInTabAddress(props[i].Name) == true)
				{
					index = keyDict2[props[i].Name];
					string safeValue = PersonDeduplicationService.SurvivorAddressList[index].Value;
					if (safeValue != null)
					{
						if (IsOneOfLocationIDs(props[i].Name) == true && safeValue == "")
						{
							props[i].SetValue(parameters, null);
						}
						else
						{
							SetValue(parameters, props[i].Name, safeValue);
						}
					}
					else
					{
						props[i].SetValue(parameters, safeValue);
					}
				}
				else if (IsInTabEmp(props[i].Name) == true)
				{
					index = keyDict3[props[i].Name];
					string safeValue = PersonDeduplicationService.SurvivorEmpList[index].Value;
					if (safeValue != null)
					{
						if (IsOneOfLocationIDs(props[i].Name) == true && safeValue == "")
						{
							props[i].SetValue(parameters, null);
						}
						else
						{
							SetValue(parameters, props[i].Name, safeValue);
						}
					}
					else
					{
						props[i].SetValue(parameters, safeValue);
					}
				}
			}

			foreach (Field item in PersonDeduplicationService.SurvivorAddressList)
			{
				if (item.Key == PersonDeduplicationAddressConstants.HumanidfsCountry && item.Value != null)
				{
					HumanidfsCountry = Convert.ToInt64(item.Value);
				}
				else if (item.Key == PersonDeduplicationAddressConstants.HumanidfsRegion && item.Value != null)
				{
					HumanidfsRegion = Convert.ToInt64(item.Value);
				}
				else if (item.Key == PersonDeduplicationAddressConstants.HumanidfsRayon && item.Value != null)
				{
					HumanidfsRayon = Convert.ToInt64(item.Value);
				}
				else if (item.Key == PersonDeduplicationAddressConstants.HumanidfsSettlement && item.Value != null)
				{
					HumanidfsSettlement = Convert.ToInt64(item.Value);
				}

				if (item.Key == PersonDeduplicationAddressConstants.HumanAltidfsCountry && item.Value != null)
				{
					HumanAltidfsCountry = Convert.ToInt64(item.Value);
				}
				else if (item.Key == PersonDeduplicationAddressConstants.HumanAltidfsRegion && item.Value != null)
				{
					HumanAltidfsRegion = Convert.ToInt64(item.Value);
				}
				else if (item.Key == PersonDeduplicationAddressConstants.HumanAltidfsRayon && item.Value != null)
				{
					HumanAltidfsRayon = Convert.ToInt64(item.Value);
				}
				else if (item.Key == PersonDeduplicationAddressConstants.HumanAltidfsSettlement && item.Value != null)
				{
					HumanAltidfsSettlement = Convert.ToInt64(item.Value);
				}
			}

			foreach (Field item in PersonDeduplicationService.SurvivorEmpList)
			{
				if (item.Key == PersonDeduplicationEmpConstants.EmployeridfsCountry && item.Value != null)
				{
					EmployeridfsCountry = Convert.ToInt64(item.Value);
				}
				else if (item.Key == PersonDeduplicationEmpConstants.EmployeridfsRegion && item.Value != null)
				{
					EmployeridfsRegion = Convert.ToInt64(item.Value);
				}
				else if (item.Key == PersonDeduplicationEmpConstants.EmployeridfsRayon && item.Value != null)
				{
					EmployeridfsRayon = Convert.ToInt64(item.Value);
				}
				else if (item.Key == PersonDeduplicationEmpConstants.EmployeridfsSettlement && item.Value != null)
				{
					EmployeridfsSettlement = Convert.ToInt64(item.Value);
				}

				if (item.Key == PersonDeduplicationEmpConstants.SchoolidfsCountry && item.Value != null)
				{
					SchoolidfsCountry = Convert.ToInt64(item.Value);
				}
				else if (item.Key == PersonDeduplicationEmpConstants.SchoolidfsRegion && item.Value != null)
				{
					SchoolidfsRegion = Convert.ToInt64(item.Value);
				}
				else if (item.Key == PersonDeduplicationEmpConstants.SchoolidfsRayon && item.Value != null)
				{
					SchoolidfsRayon = Convert.ToInt64(item.Value);
				}
				else if (item.Key == PersonDeduplicationEmpConstants.SchoolidfsSettlement && item.Value != null)
				{
					SchoolidfsSettlement = Convert.ToInt64(item.Value);
				}
			}

			parameters.HumanMasterID = PersonDeduplicationService.SurvivorHumanMasterID;
			parameters.SupersededHumanMasterID = PersonDeduplicationService.SupersededHumanMasterID;
			parameters.CopyToHumanIndicator = false;
			parameters.HumanidfsLocation = GetLowestLocationID(HumanidfsCountry, HumanidfsRegion, HumanidfsRayon, HumanidfsSettlement);
			parameters.HumanPermidfsLocation = GetLowestLocationID(HumanPermidfsCountry, HumanPermidfsRegion, HumanPermidfsRayon, HumanPermidfsSettlement);
			parameters.HumanAltidfsLocation = GetLowestLocationID(HumanAltidfsCountry, HumanAltidfsRegion, HumanAltidfsRayon, HumanAltidfsSettlement);
			parameters.EmployeridfsLocation = GetLowestLocationID(EmployeridfsCountry, EmployeridfsRegion, EmployeridfsRayon, EmployeridfsSettlement);
			parameters.SchoolidfsLocation = GetLowestLocationID(SchoolidfsCountry, SchoolidfsRegion, SchoolidfsRayon, SchoolidfsSettlement);
			parameters.AuditUser = authenticatedUser.UserName;

			PersonSaveResponseModel result = await PersonClient.DedupePersonRecords(parameters);

			if (result.ReturnCode != null)
			{
				//Success
				if (result.ReturnCode == 0)
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
			return true;
			//}
			//catch (Exception ex)
			//{
			//	_logger.LogError(ex.Message);
			//}
		}

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

		//private async Task ReplaceSupersededDiseaseListPersonIDAsync()
		//{
		//	try
		//	{
		//		PersonDedupeRequestModel request = new PersonDedupeRequestModel();
		//		request.SurvivorHumanMasterID = PersonDeduplicationService.SurvivorHumanMasterID;
		//		request.SupersededHumanMasterID = PersonDeduplicationService.SupersededHumanMasterID;
		//		APIPostResponseModel result = await PersonClient.DedupePersonHumanDisease(request);
		//		if (result.ReturnCode != null)
		//		{
		//			if (result.ReturnCode == 0) // Success
		//			{
		//			}
		//			else
		//			{
		//			} // Error
		//		}
		//	}
		//	catch (Exception ex)
		//	{
		//		_logger.LogError(ex.Message);
		//	}
		//}

		//private async Task ReplaceSupersededFarmListPersonIDAsync()
		//{
		//	try
		//	{
		//		PersonDedupeRequestModel request = new PersonDedupeRequestModel();
		//		request.SurvivorHumanMasterID = PersonDeduplicationService.SurvivorHumanMasterID;
		//		request.SupersededHumanMasterID = PersonDeduplicationService.SupersededHumanMasterID;
		//		APIPostResponseModel result = await PersonClient.DedupePersonFarm(request);
		//		if (result.ReturnCode != null)
		//		{
		//			if (result.ReturnCode == 0) // Success
		//			{
		//			}
		//			else
		//			{
		//			} // Error
		//		}
		//	}
		//	catch (Exception ex)
		//	{
		//		_logger.LogError(ex.Message);
		//	}
		//}

		//private async Task RemoveSupersededRecordAsync()
		//{
		//	try
		//	{
		//		APIPostResponseModel result = await PersonClient.DeletePerson(PersonDeduplicationService.SupersededHumanMasterID);
		//		if (result.ReturnCode != null)
		//		{
		//			// commented out because we can't build, after the DB restore.
		//			// The SP involved doesn't have the return items for the API Results to capture.
		//			// Since this code doesn't seem to do anything, commenting out so that the developer involved can reinstate, when corrected.

		//			// If result.FirstOrDefault().ReturnCode = 0 Then 'Success
		//			// Else 'Error
		//			// End If
		//		}
		//	}
		//	catch (Exception ex)
		//	{
		//		_logger.LogError(ex.Message);
		//	}
		//}

		private long? GetLowestLocationID(long? level0, long? level1, long? level2, long? level3)
		{
			long? idfsLocation = null;

			//Get lowest administrative level.
			if (level3 != null)
				idfsLocation = level3;
			else if (level2 != null)
				idfsLocation = level2;
			else if (level1 != null)
				idfsLocation = level1;
			else
				idfsLocation = level0;

			return idfsLocation;
		}

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
				var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSSuccessModalHeading), dialogParams);
				if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
				{
					PersonDeduplicationService.SelectedRecords = null;
					NavManager.NavigateTo($"Administration/Deduplication/PersonDeduplication", true);
				}
			}
			catch (Exception)
			{
				throw;
			}
		}

		protected bool IsInPersonSaveRequestModelInfo(string strName)
		{
			switch (strName)
			{
				case PersonDeduplicationInfoConstants.EIDSSPersonID:
					return true;
				case PersonDeduplicationInfoConstants.PersonalIDType:
					return true;
				case PersonDeduplicationInfoConstants.PersonalID:
					return true;
				case PersonDeduplicationInfoConstants.LastName:
					return true;
				case PersonDeduplicationInfoConstants.SecondName:
					return true;
				case PersonDeduplicationInfoConstants.FirstName:
					return true;
				case PersonDeduplicationInfoConstants.DateOfBirth:
					return true;
				case PersonDeduplicationInfoConstants.ReportedAge:
					return true;
				case PersonDeduplicationInfoConstants.HumanGenderTypeID:
					return true;
				case PersonDeduplicationInfoConstants.CitizenshipTypeID:
					return true;
				case PersonDeduplicationInfoConstants.PassportNumber:
					return true;
				case PersonDeduplicationInfoConstants.GenderTypeName:
					return true;
				case PersonDeduplicationInfoConstants.CitizenshipTypeName:
					return true;
				case PersonDeduplicationInfoConstants.PersonalIDTypeName:
					return true;
				case PersonDeduplicationInfoConstants.Age:
					return true;
				case PersonDeduplicationInfoConstants.ReportAgeUOMID:
					return true;
			}
			return false;
		}

		private string GetLabelResource(string strName)
		{
			switch (strName)
			{
				case "Person_ID":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonInformationPersonIDFieldLabel);
				case "Personal_ID_Type":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonInformationPersonalIDTypeFieldLabel);
				case "Personal_ID":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonInformationPersonalIDFieldLabel);
				case "Last_Name":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonInformationLastNameFieldLabel);
				case "Middle_Name":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonInformationMiddleNameFieldLabel);
				case "First_Name":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonInformationFirstNameFieldLabel);
				case "Date_Of_Birth":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonInformationDateOfBirthFieldLabel);
				case "Age":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonInformationAgeFieldLabel);
				case "Gender":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonInformationGenderFieldLabel);
				case "Citizenship":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonInformationCitizenshipFieldLabel);
				case "Passport_Number":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonInformationPassportNumberFieldLabel);
				//Current Address
				case "Region":
					return Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel1FieldLabel);
				case "Rayon":
					return Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel2FieldLabel);
				case "SettlementType":
					return Localizer.GetString(FieldLabelResourceKeyConstants.SettlementTypeFieldLabel);
				case "Settlement":
					return Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel3FieldLabel);
				case "Street":
					return Localizer.GetString(FieldLabelResourceKeyConstants.StreetFieldLabel);
				case "House":
					return Localizer.GetString(FieldLabelResourceKeyConstants.HouseFieldLabel);
				case "Building":
					return Localizer.GetString(FieldLabelResourceKeyConstants.BuildingFieldLabel);
				case "Apartment/Unit":
					return Localizer.GetString(FieldLabelResourceKeyConstants.ApartmentUnitFieldLabel);
				case "PostalCode":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PostalCodeFieldLabel);
				case "Latitude":
					return Localizer.GetString(FieldLabelResourceKeyConstants.FarmAddressLatitudeFieldLabel);
				case "Longitude":
					return Localizer.GetString(FieldLabelResourceKeyConstants.FarmAddressLongitudeFieldLabel);

				case "AnotherAddress":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonAddressIsThereAnotherAddressWhereThisPersonCanResideFieldLabel);
				case "ForeignAddress":
					return Localizer.GetString(FieldLabelResourceKeyConstants.ForeignAddressLabel);
				case "ForeignAddressCountry":
					return Localizer.GetString(FieldLabelResourceKeyConstants.CountryFieldLabel);
				case "AltOtherForeignAddress":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonAddressAlternateAddressOtherForeignAddressFieldLabel);
				//Alternate Address
				case "AltRegion":
					return Localizer.GetString(HeadingResourceKeyConstants.PersonAddressAlternateAddressHeading) + " " + Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel1FieldLabel);
				case "AltRayon":
					return Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel2FieldLabel);
				case "AltSettlementType":
					return Localizer.GetString(FieldLabelResourceKeyConstants.SettlementTypeFieldLabel);
				case "AltSettlement":
					return Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel3FieldLabel);
				case "AltStreet":
					return Localizer.GetString(FieldLabelResourceKeyConstants.StreetFieldLabel);
				case "AltHouse":
					return Localizer.GetString(FieldLabelResourceKeyConstants.HouseFieldLabel);
				case "AltBuilding":
					return Localizer.GetString(FieldLabelResourceKeyConstants.BuildingFieldLabel);
				case "AltApartment/Unit":
					return Localizer.GetString(FieldLabelResourceKeyConstants.ApartmentUnitFieldLabel);
				case "AltPostalCode":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PostalCodeFieldLabel);


				case "CountryCode":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonAddressCurrentAddressCountryCodeAndNumberFieldLabel);
				case "PhoneNumber":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PhoneFieldLabel);
				case "PhoneType":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonAddressCurrentAddressPhoneTypeFieldLabel);

				case "AnotherPhone":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonAddressIsThereAnotherPhoneNumberForThisPersonFieldLabel);

				case "AltCountryCode":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonAddressCurrentAddressCountryCodeAndNumberFieldLabel);
				case "AltPhoneNumber":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PhoneFieldLabel);
				case "AltPhoneType":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonAddressCurrentAddressPhoneTypeFieldLabel);

					//Permanent Address
				case "PermanentSameAddress":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonAddressPermanentAddressSameAsCurrentAddressFieldLabel);

				case "HumanPermRegion":
					return Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel1FieldLabel);
				case "HumanPermRayon":
					return Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel2FieldLabel);
				case "HumanPermSettlementType":
					return Localizer.GetString(FieldLabelResourceKeyConstants.SettlementTypeFieldLabel);
				case "HumanPermSettlement":
					return Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel3FieldLabel);
				case "HumanPermStreet":
					return Localizer.GetString(FieldLabelResourceKeyConstants.StreetFieldLabel);
				case "HumanPermHouse":
					return Localizer.GetString(FieldLabelResourceKeyConstants.HouseFieldLabel);
				case "HumanPermBuilding":
					return Localizer.GetString(FieldLabelResourceKeyConstants.BuildingFieldLabel);
				case "HumanPermApartment/Unit":
					return Localizer.GetString(FieldLabelResourceKeyConstants.ApartmentUnitFieldLabel);
				case "HumanPermPostalCode":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PostalCodeFieldLabel);

				//case "HumanGeoLocationID":
				//	return Localizer.GetString(FieldLabelResourceKeyConstants.CountryFieldLabel);

				case "Employed":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonEmploymentSchoolInformationIsThisPersonCurrentlyEmployedFieldLabel);
				case "Occupation":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonEmploymentSchoolInformationOccupationFieldLabel);
				case "EmployerName":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonEmploymentSchoolInformationEmployerNameFieldLabel);
				case "EmployedDate":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonEmploymentSchoolInformationDateofLastPresenceatWorkFieldLabel);
				case "SameWorkAddress":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonEmploymentSchoolInformationWorkAddresssameasCurrentAddressFieldLabel);
				case "WorkForeignAddressIndicator":
					return Localizer.GetString(FieldLabelResourceKeyConstants.ForeignAddressLabel);
				case "WorkCountry":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonEmployerSchoolInformationWorkAddressCountryFieldLabel);
				case "WorkForeignAddress":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonEmployerSchoolInformationWorkAddressAddressFieldLabel);

				//Work Address
				case "WorkRegion":
					return Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel1FieldLabel);
				case "WorkRayon":
					return Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel2FieldLabel);
				case "WorkSettlementType":
					return Localizer.GetString(FieldLabelResourceKeyConstants.SettlementTypeFieldLabel);
				case "WorkSettlement":
					return Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel3FieldLabel);
				case "WorkStreet":
					return Localizer.GetString(FieldLabelResourceKeyConstants.StreetFieldLabel);
				case "WorkHouse":
					return Localizer.GetString(FieldLabelResourceKeyConstants.HouseFieldLabel);
				case "WorkBuilding":
					return Localizer.GetString(FieldLabelResourceKeyConstants.BuildingFieldLabel);
				case "WorkApartment/Unit":
					return Localizer.GetString(FieldLabelResourceKeyConstants.ApartmentUnitFieldLabel);
				case "WorkPostalCode":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PostalCodeFieldLabel);

				case "WorkPhoneNumber":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonEmployerSchoolInformationWorkAddressCountryCodeAndNumberFieldLabel);

				case "CurrentlyInSchool":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonEmploymentSchoolInformationDoesthePersonCurrentlyAttendCchoolFieldLabel);
				case "SchoolName":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonEmploymentSchoolInformationSchoolNameFieldLabel);
				case "SchoolDate":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonEmploymentSchoolInformationDateofLastPresenceatSchoolFieldLabel);
				case "SchoolForeignAddressIndicator":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonEmployerSchoolInformationSchoolAddressForeignAddressFieldLabel);
				case "SchoolCountry":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonEmployerSchoolInformationSchoolAddressCountryFieldLabel);
				case "SchoolForeignAddress":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonEmployerSchoolInformationSchoolAddressAddressFieldLabel);

				//School Address
				case "SchoolRegion":
					return Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel1FieldLabel);
				case "SchoolRayon":
					return Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel2FieldLabel);
				case "SchoolSettlementType":
					return Localizer.GetString(FieldLabelResourceKeyConstants.SettlementTypeFieldLabel);
				case "SchoolSettlement":
					return Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel3FieldLabel);
				case "SchoolStreet":
					return Localizer.GetString(FieldLabelResourceKeyConstants.StreetFieldLabel);
				case "SchoolHouse":
					return Localizer.GetString(FieldLabelResourceKeyConstants.HouseFieldLabel);
				case "SchoolBuilding":
					return Localizer.GetString(FieldLabelResourceKeyConstants.BuildingFieldLabel);
				case "SchoolApartment/Unit":
					return Localizer.GetString(FieldLabelResourceKeyConstants.ApartmentUnitFieldLabel);
				case "SchoolPostalCode":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PostalCodeFieldLabel);

				case "SchoolPhoneNumber":
					return Localizer.GetString(FieldLabelResourceKeyConstants.PersonEmployerSchoolInformationSchoolAddressCountryCodeAndNumberFieldLabel);

			}
			return strName;
		}


		#endregion
	}
}
