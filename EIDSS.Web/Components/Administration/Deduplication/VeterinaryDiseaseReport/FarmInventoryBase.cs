using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Administration.SubAreas.Deduplication.ViewModels.VeterinaryDiseaseReportDeduplication;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen.Blazor;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Administration.Deduplication.VeterinaryDiseaseReport
{
    public class FarmInventoryBase : VeterinaryDiseaseReportDeduplicationBaseComponent, IDisposable
	{
		#region Dependencies

		[Inject]
		private ILogger<FarmInventoryBase> Logger { get; set; }

		#endregion

		#region Parameters
		[Parameter] public VeterinaryDiseaseReportDeduplicationDetailsViewModel Model { get; set; }

        #endregion

        #region Protected and Public Members
        protected RadzenDataGrid<FarmInventoryGetListViewModel> FarmInventoryGrid;
        protected RadzenDataGrid<FarmInventoryGetListViewModel> FarmInventoryGrid2;

		#endregion

		#region Private Member Variables

		private CancellationTokenSource source;
        private CancellationToken token;

        #endregion

        protected override async Task OnInitializedAsync()
		{
			// Wire up PersonDeduplication state container service
			VeterinaryDiseaseReportDeduplicationService.OnChange += async (property) => await OnStateContainerChangeAsync(property);

            if (Model.ReportType == VeterinaryReportTypeEnum.Avian)
            {
                SpeciesColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportFarmFlockSpeciesSpeciesColumnHeading);
                TotalColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportFarmFlockSpeciesTotalColumnHeading);
                SickColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportFarmFlockSpeciesSickColumnHeading);
                DeadColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportFarmFlockSpeciesDeadColumnHeading);
                StartOfSignsDateColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportFarmFlockSpeciesStartOfSignsColumnHeading);
                AverageAgeColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportFarmFlockSpeciesAverageAgeWeeksColumnHeading);
            }
            else
            {
                SpeciesColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportFarmHerdSpeciesSpeciesColumnHeading);
                TotalColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportFarmHerdSpeciesTotalColumnHeading);
                SickColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportFarmHerdSpeciesSickColumnHeading);
                DeadColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportFarmHerdSpeciesDeadColumnHeading);
                StartOfSignsDateColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportFarmHerdSpeciesStartOfSignsColumnHeading);
                NoteColumnHeadingResourceKey = Localizer.GetString(FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportFarmHerdSpeciesNoteIncludeBreedFieldLabel);
            }

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
