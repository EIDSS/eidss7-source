using EIDSS.Web.Areas.Administration.SubAreas.Deduplication.ViewModels.VeterinaryDiseaseReportDeduplication;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Administration.Deduplication.VeterinaryDiseaseReport
{
    public class SpeciesInvestigationBase : VeterinaryDiseaseReportDeduplicationBaseComponent, IDisposable
	{
		#region Dependencies

		[Inject]
		private ILogger<SpeciesInvestigationBase> Logger { get; set; }

		#endregion

		#region Parameters
		[Parameter] public VeterinaryDiseaseReportDeduplicationDetailsViewModel Model { get; set; }

		#endregion
		protected FlexForm.FlexForm FarmEpiDetails { get; set; }
		protected FlexForm.FlexForm FarmEpiDetails2 { get; set; }

		#region Private Member Variables

		private CancellationTokenSource source;
		private CancellationToken token;

		#endregion

		protected override async Task OnInitializedAsync()
		{
			// Wire up PersonDeduplication state container service
			VeterinaryDiseaseReportDeduplicationService.OnChange += async (property) => await OnStateContainerChangeAsync(property);

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

				VeterinaryDiseaseReportDeduplicationService.OnChange -= async (property) => await OnStateContainerChangeAsync(property);

			}
			catch (Exception)
			{
				throw;
			}
		}
	}
}