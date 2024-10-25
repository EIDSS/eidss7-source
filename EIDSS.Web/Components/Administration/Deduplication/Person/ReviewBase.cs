using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Administration.SubAreas.Deduplication.ViewModels.PersonDeduplication;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
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
    public class ReviewBase : PersonDeduplicationBaseComponent, IDisposable
	{
		#region Globals

		#region Dependencies
		[Inject]
		private ILogger<ReviewBase> Logger { get; set; }

		[Inject]
		private IPersonClient PersonClient { get; set; }

		#endregion

		#region Parameters
		public PersonDeduplicationDetailsViewModel Model { get; set; }

		#endregion
		#region Private Member Variables

		private CancellationTokenSource source;
		private CancellationToken token;




		#endregion

		protected RadzenCheckBoxList<int> rcblReviewInfo;
		#endregion

		protected override async Task OnInitializedAsync()
		{
			// Wire up PersonDeduplication state container service
			PersonDeduplicationService.OnChange += async (property) => await OnStateContainerChangeAsync(property);


			await base.OnInitializedAsync();
			//StateHasChanged();
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

		protected async Task EditClickAsync(int index)
		{
			showDetails = true;
			showReview = false;
			switch (index)
			{
				case 0:
					PersonDeduplicationService.Tab = PersonDeduplicationTabEnum.Information;
                    OnTabChange(0);
                    break;
				case 1:
					PersonDeduplicationService.Tab = PersonDeduplicationTabEnum.Address;
					OnTabChange(1);
					break;
				case 2:
					PersonDeduplicationService.Tab = PersonDeduplicationTabEnum.Employment;
					OnTabChange(2);
					break;
			}
			await InvokeAsync(StateHasChanged);
		}

		public async Task OnSaveAsync()
		{
			var result = await ShowWarningDialog("Do you want to deduplicate record?", null);

			if (result is DialogReturnResult returnResult && returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
				await DeduplicateRecordsAsync();
			if (result is DialogReturnResult returnResult2 && returnResult2.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.NoButton))
			{
				showDetails = true;
				showReview = false;
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
				bool result = SaveSurvivorRecordAsync().Result;
				if (result == true)
                {
					await ReplaceSupersededDiseaseListPersonIDAsync();
					await ReplaceSupersededFarmListPersonIDAsync();
					await RemoveSupersededRecordAsync();

					await SaveSuccessMessagedDialog();

				}
            }
            catch (Exception ex)
            {
				_logger.LogError(ex.Message);
			}
        }

		private async Task<bool> SaveSurvivorRecordAsync()
		{
			//try
			//{
			PersonSaveRequestModel parameters = new PersonSaveRequestModel();
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
				if (IsInTabInfo(props[i].Name) == true)
				{
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
			parameters.CopyToHumanIndicator = false;
			parameters.HumanidfsLocation = GetLowestLocationID(HumanidfsCountry, HumanidfsRegion, HumanidfsRayon, HumanidfsSettlement);
			parameters.HumanPermidfsLocation = GetLowestLocationID(HumanPermidfsCountry, HumanPermidfsRegion, HumanPermidfsRayon, HumanPermidfsSettlement);
			parameters.HumanAltidfsLocation = GetLowestLocationID(HumanAltidfsCountry, HumanAltidfsRegion, HumanAltidfsRayon, HumanAltidfsSettlement);
			parameters.EmployeridfsLocation = GetLowestLocationID(EmployeridfsCountry, EmployeridfsRegion, EmployeridfsRayon, EmployeridfsSettlement);
			parameters.SchoolidfsLocation = GetLowestLocationID(SchoolidfsCountry, SchoolidfsRegion, SchoolidfsRayon, SchoolidfsSettlement);

			PersonSaveResponseModel result = await PersonClient.SavePerson(parameters);

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

		private async Task ReplaceSupersededDiseaseListPersonIDAsync()
		{
			try
			{
				PersonDedupeRequestModel request = new PersonDedupeRequestModel();
				request.SurvivorHumanMasterID = PersonDeduplicationService.SurvivorHumanMasterID;
				request.SupersededHumanMasterID = PersonDeduplicationService.SupersededHumanMasterID;
				APIPostResponseModel result = await PersonClient.DedupePersonHumanDisease(request);
                if (result.ReturnCode != null)
                {
                    if (result.ReturnCode == 0) // Success
                    {
                    }
                    else
                    {
                    } // Error
                }
            }
			catch (Exception ex)
			{
				_logger.LogError(ex.Message);
			}
		}

		private async Task ReplaceSupersededFarmListPersonIDAsync()
		{
			try
			{
				PersonDedupeRequestModel request = new PersonDedupeRequestModel();
				request.SurvivorHumanMasterID = PersonDeduplicationService.SurvivorHumanMasterID;
				request.SupersededHumanMasterID = PersonDeduplicationService.SupersededHumanMasterID;
				APIPostResponseModel result = await PersonClient.DedupePersonFarm(request);
				if (result.ReturnCode != null)
				{
					if (result.ReturnCode == 0) // Success
					{
					}
					else
					{
					} // Error
				}
			}
			catch (Exception ex)
			{
				_logger.LogError(ex.Message);
			}
		}

		private async Task RemoveSupersededRecordAsync()
		{
			try
			{
				APIPostResponseModel result = await PersonClient.DeletePerson(PersonDeduplicationService.SupersededHumanMasterID, null, authenticatedUser.UserName);
                if (result.ReturnCode != null)
                {
                    // commented out because we can't build, after the DB restore.
                    // The SP involved doesn't have the return items for the API Results to capture.
                    // Since this code doesn't seem to do anything, commenting out so that the developer involved can reinstate, when corrected.

                    // If result.FirstOrDefault().ReturnCode = 0 Then 'Success
                    // Else 'Error
                    // End If
                }
            }
            catch (Exception ex)
			{
				_logger.LogError(ex.Message);
			}
		}

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
				var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
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

	}
}
