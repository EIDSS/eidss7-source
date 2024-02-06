using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Web.Areas.Administration.SubAreas.Deduplication.ViewModels.FarmDeduplication;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Radzen.Blazor;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Administration.Deduplication.Farm
{
    public class AnimalDiseaseReportsBase : FarmDeduplicationBaseComponent, IDisposable
	{
		#region Dependencies

		[Inject]
		private ILogger<AnimalDiseaseReportsBase> Logger { get; set; }

		#endregion

		#region Parameters
		public FarmDeduplicationDetailsViewModel Model { get; set; }

		#endregion

		#region Protected and Public Members
		protected RadzenDataGrid<VeterinaryDiseaseReportViewModel> DiseaseReportGrid;
		protected RadzenDataGrid<VeterinaryDiseaseReportViewModel> DiseaseReportGrid2;
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
	}
}
