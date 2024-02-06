using EIDSS.ClientLibrary.ApiClients.Veterinary;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Administration.SubAreas.Deduplication.ViewModels.FarmDeduplication;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Administration.Deduplication.Farm
{
    public class FarmDeduplicationDetailsBase : FarmDeduplicationBaseComponent
    {
		#region Dependencies

		//[Inject]
		//private IJSRuntime JsRuntime { get; set; }

		[Inject]
		private IVeterinaryClient VeterinaryClient { get; set; }

		[Inject]
		private ILogger<FarmDeduplicationDetailsBase> Logger { get; set; }

		#endregion

		#region Parameters
		[Parameter]
		public FarmDeduplicationDetailsViewModel Model { get; set; }

		[Parameter]
		public FarmDeduplicationTabEnum Tab { get; set; }
		#endregion

		#region Protected and Public Variables

		protected RadzenTemplateForm<FarmDeduplicationDetailsViewModel> form;

		protected bool shouldRender = true;
		//protected int DiseaseReportCount;
		//protected int DiseaseReportCount2;

		protected RadzenDataGrid<VeterinaryDiseaseReportViewModel> ReviewDiseaseReportGrid;

		#endregion

		#region Private Variables

		private CancellationTokenSource source;
		protected CancellationToken token;

		#endregion

		#region Protected and Public Methods

		protected override async Task OnInitializedAsync()
		{
			// reset the cancellation token
			source = new CancellationTokenSource();
			token = source.Token;

			authenticatedUser = _tokenService.GetAuthenticatedUser();

			// Wire up FarmDeduplication state container service
			FarmDeduplicationService.OnChange += async (property) => await OnStateContainerChangeAsync(property);

			await base.OnInitializedAsync();
			await InitializeModelAsync();
			OnChange(0);
			//disableMergeButton = true;
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

		public void OnChange(int index)
		{
			Tab = (FarmDeduplicationTabEnum)index;
			OnTabChange(index);
		}



		#region Details


		public void NextClicked()
		{
			switch (Tab)
			{
				case FarmDeduplicationTabEnum.FarmDetails:
					Tab = FarmDeduplicationTabEnum.AnimalDiseaseReports;
					showPreviousButton = true;
					showNextButton = false;
					break;
				//case FarmDeduplicationTabEnum.AnimalDiseaseReports:
				//	Tab = FarmDeduplicationTabEnum.Employment;
				//	showPreviousButton = true;
				//	showNextButton = false;
				//	break;
			}

			FarmDeduplicationService.TabChangeIndicator = true;
		}

		public void PreviousClicked()
		{
			switch (Tab)
			{
				case FarmDeduplicationTabEnum.AnimalDiseaseReports:
					Tab = FarmDeduplicationTabEnum.FarmDetails;
					showPreviousButton = false;
					showNextButton = true;
					break;
				//case FarmDeduplicationTabEnum.Employment:
				//	Tab = FarmDeduplicationTabEnum.AnimalDiseaseReports;
				//	showPreviousButton = true;
				//	showNextButton = true;
				//	break;
			}

			FarmDeduplicationService.TabChangeIndicator = true;
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
					var uri = $"{NavManager.BaseUri}Administration/Deduplication/FarmDeduplication?showSelectedRecordsIndicator=true";
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
			else if (FarmDeduplicationService.RecordSelection == 0 && FarmDeduplicationService.Record2Selection == 0)
			{
				await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);

				//hdfCurrentTab.Value = FarmDeduplicationTabConstants.Info;
				//HideIDFieldsinTabs();
				//ScriptManager.RegisterStartupScript(this, GetType(), PAGE_KEY, SET_ACTIVE_TAB_ITEM_SCRIPT, true);
			}
			else
			{
				if (AllFieldValuePairsSelected() == true)
				{
					foreach (Field item in FarmDeduplicationService.SurvivorInfoList)
					{
						item.Checked = true;
						item.Disabled = true;
					}

					showDetails = false;
					showReview = true;

					FarmDeduplicationService.SurvivorInfoValues = (IEnumerable<int>)FarmDeduplicationService.SurvivorInfoList.Where(s => s.Checked == true).Select(s => s.Index);

					FillSurvivorDiseaseReports();
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
			foreach (Field item in FarmDeduplicationService.InfoList)
			{
				if (item.Checked == false && FarmDeduplicationService.InfoList2[item.Index].Checked == false)
				{
					Tab = FarmDeduplicationTabEnum.FarmDetails;
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

		protected void FillSurvivorDiseaseReports()
		{
			try
			{
				IList<VeterinaryDiseaseReportViewModel> list = new List<VeterinaryDiseaseReportViewModel>();

				if (FarmDeduplicationService.DiseaseReports != null && FarmDeduplicationService.DiseaseReports.Count > 0)
				{
					foreach (var report in FarmDeduplicationService.DiseaseReports)
					{
						list.Add(report);
					}

					FarmDeduplicationService.SurvivorDiseaseReportCount = FarmDeduplicationService.DiseaseReportCount;
				}
				if (FarmDeduplicationService.DiseaseReports2 != null && FarmDeduplicationService.DiseaseReports2.Count > 0)
				{
					foreach (var report in FarmDeduplicationService.DiseaseReports2)
					{
						list.Add(report);
					}

					FarmDeduplicationService.SurvivorDiseaseReportCount += FarmDeduplicationService.DiseaseReportCount2;
				}

				FarmDeduplicationService.SurvivorDiseaseReports = (List<VeterinaryDiseaseReportViewModel>)list;
			}
			catch (Exception ex)
			{
				Logger.LogError(ex.Message, ex);
				throw;
			}
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
					FarmDeduplicationService.SelectedRecords = null;
					NavManager.NavigateTo($"Administration/Deduplication/FarmDeduplication", true);
				}
			}
			catch (Exception)
			{
				throw;
			}
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
                    FarmDeduplicationService.Tab = FarmDeduplicationTabEnum.FarmDetails;
					Tab = FarmDeduplicationTabEnum.FarmDetails;
					OnTabChange(0);
                    break;
                case 1:
                    FarmDeduplicationService.Tab = FarmDeduplicationTabEnum.AnimalDiseaseReports;
					Tab = FarmDeduplicationTabEnum.AnimalDiseaseReports;
					OnTabChange(1);
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
                    var uri = $"{NavManager.BaseUri}Administration/Deduplication/FarmDeduplication?showSelectedRecordsIndicator=true";
                    NavManager.NavigateTo(uri, true);
                    //showDetails = true;
                    //showReview = false;
                    //FarmDeduplicationService.Tab = FarmDeduplicationTabEnum.FarmDetails;
                    //OnTabChange(0);
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

		public async Task OnSaveAsync()
		{
			var result = await ShowWarningDialog(MessageResourceKeyConstants.DeduplicationPersonDoyouwanttodeduplicaterecordMessage, null);

			if (result is DialogReturnResult returnResult && returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
				await DeduplicateRecordsAsync();
			if (result is DialogReturnResult returnResult2 && returnResult2.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.NoButton))
			{

			}
		}

		private async Task DeduplicateRecordsAsync()
		{
			try
			{
				bool result = await DedupeRecordsAsync();
				if (result == true)
				{
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
			FarmDedupeRequestModel parameters = new FarmDedupeRequestModel();

			Type type = parameters.GetType();
			PropertyInfo[] props = type.GetProperties();
			int index = -1;

			for (int i = 0; i <= props.Count() - 1; i++)
			{
				if (IsInFarmSaveRequestModel(props[i].Name) == true)
				{
					if (props[i].Name == "FarmAddressStreet")
						index = keyDict["FarmAddressStreetName"];
					else if (props[i].Name == "FarmNationalName")
						index = keyDict["FarmName"];
					else if (props[i].Name == "FarmAddressIdfsLocation")
						index = keyDict["FarmAddressLocationID"];
					else
						index = keyDict[props[i].Name];

					string safeValue = FarmDeduplicationService.SurvivorInfoList[index].Value;
					if (safeValue != null)
					{
						SetValue(parameters, props[i].Name, safeValue);
					}
					else
					{
						props[i].SetValue(parameters, safeValue);
					}
				}
			}

			parameters.FarmMasterID = FarmDeduplicationService.SurvivorFarmMasterID;
			parameters.SupersededFarmMasterID = FarmDeduplicationService.SupersededFarmMasterID;
			parameters.FarmCategory = parameters.FarmTypeID;
			parameters.AuditUser = authenticatedUser.UserName;

			var response = await VeterinaryClient.DedupeFarmRecords(parameters, token);

			if (response.ReturnCode != null)
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
				return false;
			}
			//return true;
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



#endregion

#endregion

		#region Private Methods

		private async Task InitializeModelAsync()
		{
			if (Model == null)
			{
				Model = new FarmDeduplicationDetailsViewModel()
				{
					LeftFarmMasterID = FarmDeduplicationService.FarmMasterID,
					RightFarmMasterID = FarmDeduplicationService.FarmMasterID2,
				};
			}

			await FillDeduplicationDetailsAsync(Model.LeftFarmMasterID, Model.RightFarmMasterID);

			FarmDeduplicationService.OnChange += async (property) => await OnStateContainerChangeAsync(property);
		}

		private async Task OnStateContainerChangeAsync(string property)
		{
			await InvokeAsync(StateHasChanged);
		}

		private async Task FillDeduplicationDetailsAsync(long ID, long ID2)
		{
			try
			{
				FarmDeduplicationService.FarmMasterID = ID;
				FarmDeduplicationService.FarmMasterID2 = ID2;

				FarmMasterGetDetailRequestModel request = new FarmMasterGetDetailRequestModel();
				request.LanguageID = GetCurrentLanguage();
				request.FarmMasterID = ID;

				FarmMasterGetDetailRequestModel request2 = new FarmMasterGetDetailRequestModel();
				request2.LanguageID = GetCurrentLanguage();
				request2.FarmMasterID = ID2;

				List<FarmMasterGetDetailViewModel> list = await VeterinaryClient.GetFarmMasterDetail(request);
				List<FarmMasterGetDetailViewModel> list2 = await VeterinaryClient.GetFarmMasterDetail(request2);

				FarmMasterGetDetailViewModel record = list.FirstOrDefault();
				FarmMasterGetDetailViewModel record2 = list2.FirstOrDefault();

				List<KeyValuePair<string, string>> kvInfo = new List<KeyValuePair<string, string>>();
				List<KeyValuePair<string, string>> kvInfo2 = new List<KeyValuePair<string, string>>();

				Type type = record.GetType();
				PropertyInfo[] props = type.GetProperties();

				Type type2 = record2.GetType();
				PropertyInfo[] props2 = type2.GetProperties();

				string value = string.Empty;

				List<Field> itemList = new List<Field>();
				List<Field> itemList2 = new List<Field>();

				for (int index = 0; index <= props.Count() - 1; index++)
				{
					if (IsInTabFarmDetails(props[index].Name) == true)
					{
						FillTabList(props[index].Name, props[index].GetValue(record) == null ? null : props[index].GetValue(record).ToString(), props2[index].Name, props2[index].GetValue(record2) == null ? null : props2[index].GetValue(record2).ToString(), ref itemList, ref itemList2, ref keyDict, ref labelDict);
					}
				}

				//Bind Tab Farm Details
				FarmDeduplicationService.InfoList0 = itemList.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));
				FarmDeduplicationService.InfoList02 = itemList2.OrderBy(s => s.Index).ToList().ConvertAll(x => new Field(x));

				FarmDeduplicationService.InfoList = itemList.OrderBy(s => s.Index).ToList();
				FarmDeduplicationService.InfoList2 = itemList2.OrderBy(s => s.Index).ToList();

				foreach (Field item in FarmDeduplicationService.InfoList)
				{
					if (item.Checked == true)
					{
						item.Checked = true;
						item.Disabled = true;
						FarmDeduplicationService.InfoList2[item.Index].Checked = true;
						FarmDeduplicationService.InfoList2[item.Index].Disabled = true;
					}
					else if (IsInAddressGroup(item.Key) == true)
					{
						item.Disabled = true;
						FarmDeduplicationService.InfoList2[item.Index].Disabled = true;
					}
				}

				foreach (Field item in FarmDeduplicationService.InfoList)
				{
					if (item.Key == FarmDeduplicationFarmDetailsConstants.Region && item.Checked == true)
					{
						if (GroupAllChecked(item.Index, ADDRESSNUMBERFIELD, FarmDeduplicationService.InfoList) == false)
						{
							item.Checked = false;
							item.Disabled = false;
							FarmDeduplicationService.InfoList2[item.Index].Checked = false;
							FarmDeduplicationService.InfoList2[item.Index].Disabled = false;
						}
					}
				}

				FarmDeduplicationService.InfoValues = (IEnumerable<int>)FarmDeduplicationService.InfoList.Where(s => s.Checked == true).Select(s => s.Index);
				FarmDeduplicationService.InfoValues2 = (IEnumerable<int>)FarmDeduplicationService.InfoList2.Where(s => s.Checked == true).Select(s => s.Index);

                await FillDiseaseReportAsync(list, ID, false);
                await FillDiseaseReportAsync(list2, ID2, true);
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

					if (value == value2 || key == FarmDeduplicationFarmDetailsConstants.FarmID)
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
						//item.Label = labelDict[item.Index].ToString() + ": " + temp;
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
						//item.Color = "width:250px;color: #2C6187"; //Blue
						//item2.Color = "width:250px;color: #2C6187";
						item.Color = "color: #2C6187"; //Blue
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
						//item.Color = "width:250px;color: #9b1010"; //Red
						item.Color = "color: #9b1010"; //Red

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

		private async Task FillDiseaseReportAsync(List<FarmMasterGetDetailViewModel> list, long FarmMasterID, bool record2)
		{
			try
			{
				if (list != null)
				{
					var request = new VeterinaryDiseaseReportSearchRequestModel()
					{
						LanguageId = GetCurrentLanguage(),
						FarmMasterID = FarmMasterID,
						Page = 1,
						PageSize = 10,
						SortColumn = "ReportID",
						SortOrder = SortConstants.Descending,
						ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= ((long)SiteTypes.ThirdLevel) ? true : false,
						UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
						UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId),
						UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId)
					};

					if (record2 == false)
					{
						FarmDeduplicationService.DiseaseReports = await VeterinaryClient.GetVeterinaryDiseaseReportListAsync(request, token);
                        FarmDeduplicationService.DiseaseReports = FarmDeduplicationService.DiseaseReports.DistinctBy(r => r.ReportID).ToList();
                        FarmDeduplicationService.DiseaseReportCount = !FarmDeduplicationService.DiseaseReports.Any() ? 0 : FarmDeduplicationService.DiseaseReports.First().TotalRowCount;
					}
					else
					{
						FarmDeduplicationService.DiseaseReports2 = await VeterinaryClient.GetVeterinaryDiseaseReportListAsync(request, token);
                        FarmDeduplicationService.DiseaseReports2 = FarmDeduplicationService.DiseaseReports2.DistinctBy(r => r.ReportID).ToList();
                        FarmDeduplicationService.DiseaseReportCount2 = !FarmDeduplicationService.DiseaseReports2.Any() ? 0 : FarmDeduplicationService.DiseaseReports2.First().TotalRowCount;
					}
				}
			}
			catch (Exception ex)
			{
				_logger.LogError(ex.Message);
			}

		}

		private string GetLabelResource(string strName)
		{
			switch (strName)
			{
				case "FarmType":
					return Localizer.GetString(FieldLabelResourceKeyConstants.FarmInformationFarmTypeFieldLabel);
				case "FarmID":
					return Localizer.GetString(FieldLabelResourceKeyConstants.FarmInformationFarmIDFieldLabel);
				case "FarmName":
					return Localizer.GetString(FieldLabelResourceKeyConstants.FarmInformationFarmNameFieldLabel);
                case "FarmOwnerLastName":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationSearchFarmFarmOwnerLastNameFieldLabel);
                case "FarmOwnerFirstName":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationSearchFarmFarmOwnerFirstNameFieldLabel);
                case "FarmOwnerSecondName":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.AvianDiseaseReportFarmDetailsFarmOwnerMiddleNameFieldLabel);
                case "FarmOwnerID":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.DeduplicationSearchFarmFarmOwnerIDFieldLabel);
                case "Phone":
					return Localizer.GetString(FieldLabelResourceKeyConstants.FarmInformationPhoneFieldLabel);
				case "Fax":
					return Localizer.GetString(FieldLabelResourceKeyConstants.FarmInformationFaxFieldLabel);
				case "Email":
					return Localizer.GetString(FieldLabelResourceKeyConstants.FarmInformationEmailFieldLabel);
				case "ModifiedDate":
					return Localizer.GetString(FieldLabelResourceKeyConstants.FarmInformationDateLastUpdatedFieldLabel);
                case "Country":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.CountryFieldLabel);
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
                case "Apartment":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.ApartmentUnitFieldLabel);
                case "PostalCode":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.PostalCodeFieldLabel);
                case "Latitude":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.FarmAddressLatitudeFieldLabel);
                case "Longitude":
                    return Localizer.GetString(FieldLabelResourceKeyConstants.FarmAddressLongitudeFieldLabel);
				case "AvianFarmTypeID":
					return Localizer.GetString(FieldLabelResourceKeyConstants.FarmInformationAvianFarmTypeIDFieldLabel);
				case "OwnershipStructureTypeID":
					return Localizer.GetString(FieldLabelResourceKeyConstants.OwnershipFormFieldLabel);
				case "NumberOfBuildings":
					return Localizer.GetString(FieldLabelResourceKeyConstants.FarmInformationNumberOfBarnsBuildingsFieldLabel);
				case "NumberOfBirdsPerBuilding":
					return Localizer.GetString(FieldLabelResourceKeyConstants.FarmInformationNumberOfBirdsPerBarnBuildingFieldLabel);
			}
			return strName;
		}

		private bool IsInFarmSaveRequestModel(string strName)
		{
			switch (strName)
			{
				//case FarmDeduplicationFarmDetailsConstants.FarmType:
				//	return true;
				case FarmDeduplicationFarmDetailsConstants.FarmID:
					return true;
				case FarmDeduplicationFarmDetailsConstants.FarmNationalName:
					return true;
				//case FarmDeduplicationFarmDetailsConstants.FarmOwnerLastName:
				//	return true;
				//case FarmDeduplicationFarmDetailsConstants.FarmOwnerFirstName:
				//	return true;
				//case FarmDeduplicationFarmDetailsConstants.FarmOwnerSecondName:
				//	return true;
				case FarmDeduplicationFarmDetailsConstants.FarmOwnerID:
					return true;
				case FarmDeduplicationFarmDetailsConstants.Phone:
					return true;
				case FarmDeduplicationFarmDetailsConstants.Fax:
					return true;
				case FarmDeduplicationFarmDetailsConstants.Email:
					return true;
				//case FarmDeduplicationFarmDetailsConstants.ModifiedDate:
				//	return true;
				//case FarmDeduplicationFarmDetailsConstants.Country:
				//	return true;
				//case FarmDeduplicationFarmDetailsConstants.Region:
				//	return true;
				//case FarmDeduplicationFarmDetailsConstants.Rayon:
				//	return true;
				//case FarmDeduplicationFarmDetailsConstants.SettlementType:
				//	return true;
				//case FarmDeduplicationFarmDetailsConstants.Settlement:
				//	return true;
				case FarmDeduplicationFarmDetailsConstants.FarmAddressStreet:
					return true;
				case FarmDeduplicationFarmDetailsConstants.Building:
					return true;
				case FarmDeduplicationFarmDetailsConstants.Apartment:
					return true;
				case FarmDeduplicationFarmDetailsConstants.House:
					return true;
				case FarmDeduplicationFarmDetailsConstants.PostalCode:
					return true;
				case FarmDeduplicationFarmDetailsConstants.Longitude:
					return true;
				case FarmDeduplicationFarmDetailsConstants.Latitude:
					return true;
				case FarmDeduplicationFarmDetailsConstants.FarmTypeID:
					return true;
				//case FarmDeduplicationFarmDetailsConstants.RegionID:
				//	return true;
				//case FarmDeduplicationFarmDetailsConstants.RayonID:
				//	return true;
				//case FarmDeduplicationFarmDetailsConstants.SettlementTypeID:
				//	return true;
				//case FarmDeduplicationFarmDetailsConstants.SettlementID:
				//	return true;
				//case FarmDeduplicationFarmDetailsConstants.CountryID:
				//	return true;
				case FarmDeduplicationFarmDetailsConstants.FarmAddressID:
					return true;
				//case FarmDeduplicationFarmDetailsConstants.EIDSSFarmOwnerID:
				//	return true;
				case FarmDeduplicationFarmDetailsConstants.FarmAddressIdfsLocation:
					return true;
				case FarmDeduplicationFarmDetailsConstants.AvianFarmTypeID:
					return true;
				case FarmDeduplicationFarmDetailsConstants.AvianProductionTypeID:
					return true;
				case FarmDeduplicationFarmDetailsConstants.OwnershipStructureTypeID:
					return true;
				case FarmDeduplicationFarmDetailsConstants.NumberOfBuildings:
					return true;
				case FarmDeduplicationFarmDetailsConstants.NumberOfBirdsPerBuilding:
					return true;
			}
			return false;

		}

		#endregion



	}
}
