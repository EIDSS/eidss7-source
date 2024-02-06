using EIDSS.Domain.Enumerations;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Administration.Deduplication.Farm
{
    public class FarmDeduplicationBaseComponent : BaseComponent
    {
        #region Dependencies

        [Inject]
        protected FarmDeduplicationSessionStateContainerService FarmDeduplicationService { get; set; }

        [Inject]
        private ILogger<FarmDeduplicationBaseComponent> Logger { get; set; }
		#endregion

		#region Protected and Public Variables

		protected bool disableMergeButton = false;
		protected bool showNextButton;
		protected bool showPreviousButton;
		protected bool showDetails = true;
		protected bool showReview = false;

		protected Dictionary<string, int> keyDict = new Dictionary<string, int>() {
	{
		"FarmTypeName",
		0
	},
	{
		"EIDSSFarmID",
		1
	},
	{
		"FarmName",
		2
	},
	{
		"FarmOwnerLastName",
		3
	},
	{
		"FarmOwnerFirstName",
		4
	},
	{
		"FarmOwnerSecondName",
		5
	},
	{
		"EIDSSFarmOwnerID",
		6
	},
	{
		"Phone",
		7
	},
	{
		"Fax",
		8
	},
	{
		"Email",
		9
	},
	{
		"ModifiedDate",
		10
	},
	{
		"FarmAddressAdministrativeLevel0Name",
		11
	},
	{
		"FarmAddressAdministrativeLevel1Name",
		12
	},
	{
		"FarmAddressAdministrativeLevel2Name",
		13
	},
	{
		"FarmAddressSettlementTypeName",
		14
	},
	{
		"FarmAddressAdministrativeLevel3Name",
		15
	},
	{
		"FarmAddressStreetName",
		16
	},
	{
		"FarmAddressHouse",
		17
	},
	{
		"FarmAddressBuilding",
		18
	},
	{
		"FarmAddressApartment",
		19
	},
	{
		"FarmAddressPostalCode",
		20
	},
	{
		"FarmAddressLatitude",
		21
	},
	{
		"FarmAddressLongitude",
		22
	},
	{
		"FarmAddressAdministrativeLevel1ID",
		23
	},
	{
		"FarmAddressAdministrativeLevel2ID",
		24
	},
	{
		"FarmAddressSettlementTypeID",
		25
	},
	{
		"FarmAddressAdministrativeLevel3ID",
		26
	},
	{
		"FarmAddressLocationID",
		27
	},
	{
		"FarmAddressID",
		28
	},
	{
		"AvianFarmTypeID",
		29
	},
	{
		"AvianProductionTypeID",
		30
	},
	{
		"OwnershipStructureTypeID",
		31
	},
	{
		"NumberOfBuildings",
		32
	},
	{
		"NumberOfBirdsPerBuilding",
		33
	},
	{
		"FarmAddressAdministrativeLevel0ID",
		34
	},
	{
		"FarmOwnerID",
		35
	},
	{
		"FarmTypeID",
		36
	}
};

		protected Dictionary<int, string> labelDict = new Dictionary<int, string>(){
	{
		0,
		"FarmType"
	},
	{
		1,
		"FarmID"
	},
	{
		2,
		"FarmName"
	},
	{
		3,
		"FarmOwnerLastName"
	},
	{
		4,
		"FarmOwnerFirstName"
	},
	{
		5,
		"FarmOwnerSecondName"
	},
	{
		6,
		"FarmOwnerID"
	},
	{
		7,
		"Phone"
	},
	{
		8,
		"Fax"
	},
	{
		9,
		"Email"
	},
	{
		10,
		"ModifiedDate"
	},
	{
		11,
		"Country"
	},
	{
		12,
		"Region"
	},
	{
		13,
		"Rayon"
	},
	{
		14,
		"SettlementType"
	},
	{
		15,
		"Settlement"
	},
	{
		16,
		"Street"
	},
	{
		17,
		"House"
	},
	{
		18,
		"Building"
	},
	{
		19,
		"Apartment"
	},
	{
		20,
		"PostalCode"
	},
	{
		21,
		"Latitude"
	},
	{
		22,
		"Longitude"
	},
	{
		23,
		"RegionID"
	},
	{
		24,
		"RayonID"
	},
	{
		25,
		"SettlementTypeID"
	},
	{
		26,
		"SettlementID"
	},
	{
		27,
		"FarmAddressLocationID"
	},
	{
		28,
		"FarmAddressID"
	},
	{
		29,
		"AvianFarmTypeID"
	},
	{
		30,
		"AvianProductionTypeID"
	},
	{
		31,
		"OwnershipStructureTypeID"
	},
	{
		32,
		"NumberOfBuildings"
	},
	{
		33,
		"NumberOfBirdsPerBuilding"
	},
	{
		34,
		"CountryID"
	},
	{
		35,
		"FarmOwnerID"
	},
	{
		36,
		"FarmTypeID"
	}
};

		protected const int ADDRESSNUMBERFIELD = 11;
		protected const int ADDRESSIDNUMBERFIELD = 11;

		protected const int FarmTypeID = 36;
		protected const int RegionID = 23;
		protected const int FarmCountryID = 34;
		protected const int FarmOwnerID = 35;

        #endregion

        #region Protected and Public Methods
        public void OnTabChange(int index)
        {
            switch (index)
            {
                case 0:
                    FarmDeduplicationService.Tab = FarmDeduplicationTabEnum.FarmDetails;
                    showPreviousButton = false;
                    showNextButton = true;
                    break;
                case 1:
                    FarmDeduplicationService.Tab = FarmDeduplicationTabEnum.AnimalDiseaseReports;
                    showPreviousButton = true;
                    showNextButton = false;
                    break;
            }

            FarmDeduplicationService.TabChangeIndicator = true;
        }

        protected bool AllFieldValuePairsUnmatched()
		{
			//try
			//{
			foreach (Field item in FarmDeduplicationService.InfoList)
			{
				if (item.Value == FarmDeduplicationService.InfoList2[item.Index].Value && item.Value != null && item.Value != "")
				{
					return false;
				}
			}

			return true;
			//}
			//catch (Exception ex)
			//{
			//	_logger.LogError(ex.Message);
			//}
		}

		protected bool IsInTabFarmDetails(string strName)
		{
			switch (strName)
			{
				case FarmDeduplicationFarmDetailsConstants.FarmType:
					return true;
				case FarmDeduplicationFarmDetailsConstants.FarmID:
					return true;
				case FarmDeduplicationFarmDetailsConstants.FarmName:
					return true;
				case FarmDeduplicationFarmDetailsConstants.FarmOwnerLastName:
					return true;
				case FarmDeduplicationFarmDetailsConstants.FarmOwnerFirstName:
					return true;
				case FarmDeduplicationFarmDetailsConstants.FarmOwnerSecondName:
					return true;
				case FarmDeduplicationFarmDetailsConstants.FarmOwnerID:
					return true;
				case FarmDeduplicationFarmDetailsConstants.Phone:
					return true;
				case FarmDeduplicationFarmDetailsConstants.Fax:
					return true;
				case FarmDeduplicationFarmDetailsConstants.Email:
					return true;
				case FarmDeduplicationFarmDetailsConstants.ModifiedDate:
					return true;
				case FarmDeduplicationFarmDetailsConstants.Country:
					return true;
				case FarmDeduplicationFarmDetailsConstants.Region:
					return true;
				case FarmDeduplicationFarmDetailsConstants.Rayon:
					return true;
				case FarmDeduplicationFarmDetailsConstants.SettlementType:
					return true;
				case FarmDeduplicationFarmDetailsConstants.Settlement:
					return true;
				case FarmDeduplicationFarmDetailsConstants.Street:
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
				case FarmDeduplicationFarmDetailsConstants.RegionID:
					return true;
				case FarmDeduplicationFarmDetailsConstants.RayonID:
					return true;
				case FarmDeduplicationFarmDetailsConstants.SettlementTypeID:
					return true;
				case FarmDeduplicationFarmDetailsConstants.SettlementID:
					return true;
				case FarmDeduplicationFarmDetailsConstants.CountryID:
					return true;
				case FarmDeduplicationFarmDetailsConstants.FarmAddressID:
					return true;
				case FarmDeduplicationFarmDetailsConstants.EIDSSFarmOwnerID:
					return true;
				case FarmDeduplicationFarmDetailsConstants.FarmAddressLocationID:
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

		protected bool IsInAddressGroup(string strName)
		{
			switch (strName)
			{
				case FarmDeduplicationFarmDetailsConstants.Rayon:
					return true;
				case FarmDeduplicationFarmDetailsConstants.SettlementType:
					return true;
				case FarmDeduplicationFarmDetailsConstants.Settlement:
					return true;
				case FarmDeduplicationFarmDetailsConstants.Street:
					return true;
				case FarmDeduplicationFarmDetailsConstants.Building:
					return true;
				case FarmDeduplicationFarmDetailsConstants.Apartment:
					return true;
				case FarmDeduplicationFarmDetailsConstants.House:
					return true;
				case FarmDeduplicationFarmDetailsConstants.PostalCode:
					return true;
				case FarmDeduplicationFarmDetailsConstants.Latitude:
					return true;
				case FarmDeduplicationFarmDetailsConstants.Longitude:
					return true;
				case FarmDeduplicationFarmDetailsConstants.FarmAddressID:
					return true;
				case FarmDeduplicationFarmDetailsConstants.FarmAddressLocationID:
					return true;
			}
			return false;

		}

		protected bool GroupAllChecked(int index, int length, IList<Field> list)
		{
			bool AllChecked = true;

			foreach (Field item in list)
			{
				if (item.Index > index && item.Index <= index + length - 1 && item.Checked == false)
				{
					AllChecked = false;
					//return false;
				}
			}

			return AllChecked;
		}

		protected void UnCheckAll()
		{
			FarmDeduplicationService.chkCheckAll = false;
			FarmDeduplicationService.chkCheckAll2 = false;
		}

		protected async Task CheckAllAsync(IList<Field> list, IList<Field> list2, bool check, bool check2, IList<Field> survivorList, string strValidTabName)
		{
			try
			{
				string value = string.Empty;
				string label = string.Empty;

				if (AllFieldValuePairsUnmatched() == true)
				{
					await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
					UnCheckAll();
				}
				else if (FarmDeduplicationService.RecordSelection == 0 && FarmDeduplicationService.Record2Selection == 0)
				{
					await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
					UnCheckAll();
				}
				else
				{
					if (check == true)
					{
						check2 = false;
						foreach (Field item in list)
						{
							if (item.Checked == false)
							{
								item.Checked = true;
								list2[item.Index].Checked = false;
								value = item.Value;
								if (survivorList != null)
								{
									if (survivorList.Count > 0)
									{
										label = survivorList[item.Index].Label;

										if (value == null)
										{
											if (survivorList[item.Index].Value == null)
												survivorList[item.Index].Label = label.Replace(": ", ": " + string.Empty);
											else
												survivorList[item.Index].Label = label.Replace(survivorList[item.Index].Value, "");
										}
										else if (survivorList[item.Index].Value == null)
										{
											//survivorList[item.Index].Label = label.Replace("<br><font style='color:#333;font-size:12px;font-weight:normal'>", "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + value);
											survivorList[item.Index].Label = label.Replace(": ", ": " + value);
										}
										else if (survivorList[item.Index].Value == string.Empty)
										{
											//survivorList[item.Index].Label = label.Replace("<br><font style='color:#333;font-size:12px;font-weight:normal'>", "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + value);
											survivorList[item.Index].Label = label.Replace(": ", ": " + value);
										}
										else
										{
											survivorList[item.Index].Label = label.Replace(survivorList[item.Index].Value, value);
										}

										survivorList[item.Index].Value = value;
									}
								}
							}
						}

						foreach (Field item in list)
						{
							if (item.Checked == true && list2[item.Index].Checked == true)
							{
								item.Disabled = true;
							}
						}
					}
				}

				//await EableDisableMergeButtonAsync();

			}
			catch (Exception ex)
			{
				_logger.LogError(ex.Message);
			}
		}

		protected async Task EableDisableMergeButtonAsync()
		{
			if (AllTabValid() == true)
			{
				disableMergeButton = false;
				await InvokeAsync(StateHasChanged);
			}
			else
				disableMergeButton = true;

			await InvokeAsync(StateHasChanged);
		}

		protected bool AllTabValid()
		{
			if (IsFarmDetailsValid() == false)
			{
				//spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
				return false;
			}
			else
			{
				//spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
			}

			//if (IsDiseaseReportValid() == false)
			//{
			//	//spAddress.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
			//	return false;
			//}
			//else
			//{
			//	//spAddress.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
			//}

			return true;
		}

		protected bool TabFarmDetailsValid()
		{
			if (IsFarmDetailsValid() == false)
			{
				//spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
				return false;
			}
			else
			{
				//spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
			}
			return true;
		}

		protected async Task BindTabFarmDetailsAsync()
		{
			FarmDeduplicationService.InfoList = FarmDeduplicationService.InfoList0.Select(a => a.Copy()).ToList();
			FarmDeduplicationService.InfoList2 = FarmDeduplicationService.InfoList02.Select(a => a.Copy()).ToList();

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

			await EableDisableMergeButtonAsync();
			TabFarmDetailsValid();
		}

		protected void SelectAndUnSelectIDfield(int i, IList<Field> list, IList<Field> list2, IList<Field> listSurvivor)
		{
			//try
			//{
			string value = string.Empty;
			string label = string.Empty;

			list[i].Checked = true;
			list2[i].Checked = false;
			//value = control.Items(i).Value;
			value = list[i].Value;
			if (listSurvivor != null)
			{
				if (listSurvivor.Count > 0)
				{
					listSurvivor[i].Checked = true;
					label = listSurvivor[i].Label;
					if (value == null)
					{
						listSurvivor[i].Label = label.Replace(listSurvivor[i].Value, "");
					}
					else if (listSurvivor[i].Value == null)
					{
						listSurvivor[i].Label = label.Replace(": ", ": " + value);
						//listSurvivor[i].Label = label.Replace("</font>", value + "</font>");
					}
					else if (listSurvivor[i].Value == value)
					{
						listSurvivor[i].Label = label;
					}
					else if (listSurvivor[i].Value == "")
					{
						listSurvivor[i].Label = label.Replace(": ", ": " + value);
						//listSurvivor[i].Label = label.Replace("</font>", value + "</font>");
					}
					else
					{
						listSurvivor[i].Label = label.Replace(listSurvivor[i].Value, value);
					}
					listSurvivor[i].Value = value;
				}
			}

			//control.Items(i).Selected = true;
			//control2.Items(i).Selected = false;

			//BindCheckBoxList(control, list)
			//BindCheckBoxList(control2, list2)
			//}
			//catch (Exception ex)
			//{
			//	Log.Error(MethodBase.GetCurrentMethod().Name + LoggingConstants.ExceptionWasThrownMessage, ex);
			//	throw ex;
			//}
		}

		protected void SelectAllAndUnSelectAll(int index, int length, IList<Field> list, IList<Field> list2, IList<Field> listSurvivor)
		{
			try
			{
				string value = string.Empty;
				string label = string.Empty;

				for (int i = index; i <= index + length - 1; i++)
				{
					list[i].Checked = true;
					list2[i].Checked = false;
					value = list[i].Value;
					if (listSurvivor != null)
					{
						if (listSurvivor.Count > 0)
						{
							listSurvivor[i].Checked = true;
							label = listSurvivor[i].Label;
							if (value == null)
							{
								if (listSurvivor[i].Value == null)
									listSurvivor[i].Label = label.Replace(": ", ": " + string.Empty);
								else
									listSurvivor[i].Label = label.Replace(listSurvivor[i].Value, "");

								//listSurvivor[i].Label = label.Replace(listSurvivor[i].Value, "");
							}
							else if (listSurvivor[i].Value == null)
							{
								listSurvivor[i].Label = label.Replace(": ", ": " + value);
								//listSurvivor[i].Label = label.Replace("</font>", value + "</font>");
							}
							else if (listSurvivor[i].Value == value)
							{
								listSurvivor[i].Label = label;
							}
							else if (listSurvivor[i].Value == "")
							{
								//listSurvivor[i].Label = label.Replace("</font>", value + "</font>");
								listSurvivor[i].Label = label.Replace(": ", ": " + value);
							}
							else
							{
								listSurvivor[i].Label = label.Replace(listSurvivor[i].Value, value);
							}
							listSurvivor[i].Value = value;
						}
					}
				}

				BindCheckBoxList(index, length, list);
				BindCheckBoxList(index, length, list2);

				for (int i = 0; i <= list.Count - 1; i++)
				{
					if (list[i].Checked == true && list2[i].Checked == true)
					{
						//control.Items(i).Enabled = false;
						//control2.Items(i).Enabled = false;
						list[i].Disabled = true;
						list2[i].Disabled = true;
					}
				}
			}
			catch (Exception ex)
			{
				_logger.LogError(ex.Message);
			}
		}

		protected async Task OnRecordSelectionChangeAsync(int value)
		{ 
			Boolean bFirst = false;
			if (FarmDeduplicationService.SurvivorInfoList == null)
				bFirst = true;

			UnCheckAll();
			if (bFirst == false)
				ReloadTabs();

			switch (value)
			{
				case 1:
					FarmDeduplicationService.RecordSelection = 1;
					FarmDeduplicationService.Record2Selection = 2;
					FarmDeduplicationService.SurvivorFarmMasterID = FarmDeduplicationService.FarmMasterID;
					FarmDeduplicationService.SupersededFarmMasterID = FarmDeduplicationService.FarmMasterID2;

					FarmDeduplicationService.SurvivorInfoList = FarmDeduplicationService.InfoList0.Select(a => a.Copy()).ToList();
					CheckAllSurvivorfields(FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2);
					break;
				case 2:
					FarmDeduplicationService.RecordSelection = 2;
					FarmDeduplicationService.Record2Selection = 1;
					FarmDeduplicationService.SurvivorFarmMasterID = FarmDeduplicationService.FarmMasterID2;
					FarmDeduplicationService.SupersededFarmMasterID = FarmDeduplicationService.FarmMasterID;

					FarmDeduplicationService.SurvivorInfoList = FarmDeduplicationService.InfoList02.Select(a => a.Copy()).ToList();
					CheckAllSurvivorfields(FarmDeduplicationService.InfoList2, FarmDeduplicationService.InfoList);
					break;
				default:
					break;
			}

			await InvokeAsync(StateHasChanged);
		}
		protected async Task OnRecord2SelectionChangeAsync(int value)
		{
			Boolean bFirst = false;
			if (FarmDeduplicationService.SurvivorInfoList == null)
				bFirst = true;

			UnCheckAll();
			if (bFirst == false)
				ReloadTabs();

			switch (value)
			{
				case 1:
					FarmDeduplicationService.RecordSelection = 2;
					FarmDeduplicationService.Record2Selection = 1;
					FarmDeduplicationService.SurvivorFarmMasterID = FarmDeduplicationService.FarmMasterID2;
					FarmDeduplicationService.SupersededFarmMasterID = FarmDeduplicationService.FarmMasterID;

					FarmDeduplicationService.SurvivorInfoList = FarmDeduplicationService.InfoList02.Select(a => a.Copy()).ToList();
					CheckAllSurvivorfields(FarmDeduplicationService.InfoList2, FarmDeduplicationService.InfoList);
					break;
				case 2:
					FarmDeduplicationService.RecordSelection = 1;
					FarmDeduplicationService.Record2Selection = 2;
					FarmDeduplicationService.SurvivorFarmMasterID = FarmDeduplicationService.FarmMasterID;
					FarmDeduplicationService.SupersededFarmMasterID = FarmDeduplicationService.FarmMasterID2;

					FarmDeduplicationService.SurvivorInfoList = FarmDeduplicationService.InfoList0.Select(a => a.Copy()).ToList();
					CheckAllSurvivorfields(FarmDeduplicationService.InfoList, FarmDeduplicationService.InfoList2);
					break;
				default:
					break;
			}

			await InvokeAsync(StateHasChanged);
		}

		protected void CheckAllSurvivorfields(IList<Field> list, IList<Field> list2)
		{
			foreach (Field item in list)
			{
				item.Checked = true;
				list2[item.Index].Checked = false;
			}
		}

		protected void ReloadTabs()
		{
			//if (FarmDeduplicationService.RecordSelection != 0 && FarmDeduplicationService.Record2Selection != 0)
			//{
			//Bind Tab Info
			FarmDeduplicationService.InfoList = null;
			FarmDeduplicationService.InfoList2 = null;
			FarmDeduplicationService.InfoList = FarmDeduplicationService.InfoList0.Select(a => a.Copy()).ToList();
			FarmDeduplicationService.InfoList2 = FarmDeduplicationService.InfoList02.Select(a => a.Copy()).ToList();

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

			ClearTabs();
		}

		public async Task<dynamic> ShowWarningMessage(string message, string localizedMessage)
		{
			List<DialogButton> buttons = new();
			var okButton = new DialogButton()
			{
				ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
				ButtonType = DialogButtonType.OK
			};
			buttons.Add(okButton);

			Dictionary<string, object> dialogParams = new()
			{
				{ nameof(EIDSSDialog.DialogButtons), buttons },
				{ nameof(EIDSSDialog.Message), string.IsNullOrEmpty(message) ? null : Localizer.GetString(message) },
				{ nameof(EIDSSDialog.LocalizedMessage), localizedMessage },
				{ nameof(EIDSSDialog.DialogType), EIDSSDialogType.Warning }
			};

			return await DiagService.OpenAsync<EIDSSDialog>(null, dialogParams);
		}

		#endregion
		#region Private Methods
		private bool IsFarmDetailsValid()
		{
			foreach (Field item in FarmDeduplicationService.InfoList)
			{
				if (item.Checked == false && FarmDeduplicationService.InfoList2[item.Index].Checked == false)
				{
					return false;
				}
			}
			return true;
		}

		private void BindCheckBoxList(int index, int length, IList<Field> list)
		{
			try
			{

				for (int i = index; i <= index + length - 1; i++)
				{
					if (list[i].Checked == true)
					{
						if (list[i].Key == FarmDeduplicationFarmDetailsConstants.Region)
						{
							list[i].Checked = true;
							//list[i].Disabled = true;
						}
						else
						{
							list[i].Checked = true;
							list[i].Disabled = true;
						}
					}
					else if (IsInAddressGroup(list[i].Key) == true)
					{
						list[i].Disabled = true;
					}
				}
			}
			catch (Exception ex)
			{
				_logger.LogError(ex.Message);
			}
		}

		private void ClearTabs()
		{
			//spFarmDetails.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
			//spDiseaseReport.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
		}

		#endregion
	}
}
