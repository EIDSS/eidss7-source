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
    public class PensideTestsBase : VeterinaryDiseaseReportDeduplicationBaseComponent, IDisposable
	{
		#region Dependencies

		[Inject]
		private ILogger<PensideTestsBase> Logger { get; set; }

		#endregion

		#region Parameters
		[Parameter] public VeterinaryDiseaseReportDeduplicationDetailsViewModel Model { get; set; }

		#endregion

		#region Protected and Public Members

		protected RadzenDataGrid<PensideTestGetListViewModel> PensideTestsGrid;
		protected RadzenDataGrid<PensideTestGetListViewModel> PensideTestsGrid2;

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
                TestNameColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportPensideTestsTestNameColumnHeading);
                FieldSampleIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportPensideTestsFieldSampleIDColumnHeading);
                SampleTypeColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportPensideTestsSampleTypeColumnHeading);
                SpeciesColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportPensideTestsSpeciesColumnHeading);
                ResultColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportPensideTestsResultColumnHeading);
            }
            else
            {
                TestNameColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportPensideTestsTestNameColumnHeading);
                FieldSampleIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportPensideTestsFieldSampleIDColumnHeading);
                SampleTypeColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportPensideTestsSampleTypeColumnHeading);
                AnimalIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportPensideTestsAnimalIDColumnHeading);
                ResultColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportPensideTestsResultColumnHeading);
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
