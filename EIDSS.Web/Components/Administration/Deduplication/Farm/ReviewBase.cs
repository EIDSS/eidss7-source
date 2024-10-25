using EIDSS.ClientLibrary.ApiClients.Veterinary;
using EIDSS.Domain.Enumerations;
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
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Administration.Deduplication.Farm
{
    public class ReviewBase : FarmDeduplicationBaseComponent, IDisposable
    {
		#region Dependencies
		[Inject]
		private ILogger<ReviewBase> Logger { get; set; }

		[Inject]
		private IVeterinaryClient VeterinaryClient { get; set; }

		#endregion

		#region Parameters
		[Parameter]
		public FarmDeduplicationDetailsViewModel Model { get; set; }

		#endregion

		#region Protected and Public Members

		protected RadzenDataGrid<VeterinaryDiseaseReportViewModel> ReviewDiseaseReportGrid;

		#endregion

		#region Private Member Variables

		private CancellationTokenSource source;
		private CancellationToken token;

		#endregion

		#region Protected and Public Methods

		protected override async Task OnInitializedAsync()
		{
			// Wire up PersonDeduplication state container service
			FarmDeduplicationService.OnChange += async (property) => await OnStateContainerChangeAsync(property);


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

				FarmDeduplicationService.OnChange -= async (property) => await OnStateContainerChangeAsync(property);
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
					FarmDeduplicationService.Tab = FarmDeduplicationTabEnum.FarmDetails;
					OnTabChange(0);
					break;
				case 1:
					FarmDeduplicationService.Tab = FarmDeduplicationTabEnum.AnimalDiseaseReports;
					OnTabChange(1);
					break;
			}
			await InvokeAsync(StateHasChanged);
		}

		protected async Task CancelReviewClicked()
		{
			try
			{
				//var buttons = new List<DialogButton>();
				//var yesButton = new DialogButton()
				//{
				//	ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
				//	ButtonType = DialogButtonType.Yes
				//};
				//var noButton = new DialogButton()
				//{
				//	ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
				//	ButtonType = DialogButtonType.Yes
				//};
				//buttons.Add(yesButton);
				//buttons.Add(noButton);

				//var dialogParams = new Dictionary<string, object>();
				//dialogParams.Add("DialogType", EIDSSDialogType.Warning);
				//dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
				//dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage));
				//DialogOptions dialogOptions = new DialogOptions()
				//{
				//	ShowTitle = true,
				//	ShowClose = false
				//};
				//var result = await DiagService.OpenAsync<EIDSSDialog>(String.Empty, dialogParams, dialogOptions);
				//var dialogResult = result as DialogReturnResult;

				var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage, null).ConfigureAwait(false);
				if (result is DialogReturnResult returnResult && returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
				{
					//cancel search and user said yes
					source?.Cancel();
					//shouldRender = false;
					//var uri = $"{NavManager.BaseUri}Administration/Deduplication/FarmDeduplication";
					//NavManager.NavigateTo(uri, true);
					showDetails = true;
					showReview = false;
					FarmDeduplicationService.Tab = FarmDeduplicationTabEnum.FarmDetails;
					OnTabChange(0);
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


		}






		#endregion



	}
}
