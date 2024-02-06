using AutoFixture;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Components;
using EIDSS.Web.xUnitTest.Abstracts;
using EIDSS.Web.xUnitTest.Arrangements.Client_Mocks;
using EIDSS.Web.xUnitTest.Arrangements.Service_Mocks;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.Mvc.ViewComponents;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xunit;

namespace EIDSS.Web.xUnitTest.Web.Components
{
    public class LocationViewComponentTests
    {
        LocationViewComponent _lvc = null;
        public LocationViewComponentTests()
        {

            _lvc = new LocationViewComponent
            (
                new CrossCuttingClientMock(),
                new SettlementClientMock(),
                BaseArrangement.Configuration,
                new TokenServiceMock()
            );
        }
        
        /// <summary>
        /// Tests the location view component
        /// </summary>
        [Fact]
        public async void LocationViewComponent_Loads_AdminLists_Correctly()
        {
            ViewDataDictionary viewdata = null;
            LocationViewModel model = null;

               var c = LocationArrangements.Country;
            var result = await _lvc.InvokeAsync(BaseArrangement.AuthenticatedUserLocation);


            try { viewdata = ((ViewViewComponentResult)result).ViewData; } catch { };
            try { model = (LocationViewModel)viewdata.Model; } catch { };

            Assert.Equal("Wakanda", model.DefaultCountry);
            Assert.NotNull(model.AdminLevel0List);
            Assert.NotNull(model.AdminLevel1List);
            Assert.NotNull(model.AdminLevel2List);
            Assert.NotNull(model.AdminLevel3List);
            Assert.All(model.AdminLevel0List, a => Assert.Equal( "Country", a.strGISReferenceTypeName));

            // LocationViewComponent Fill methods inserts a blank model to each list...
            // Let's test that...
            Assert.Null(model.AdminLevel1List[0].idfsGISReferenceType);
            Assert.Null(model.AdminLevel2List[0].idfsGISReferenceType);
            Assert.Null(model.AdminLevel3List[0].idfsGISReferenceType);

            // Remove the blank models and test to ensure the lists were populated correctly...
            model.AdminLevel1List.RemoveAt(0);
            model.AdminLevel2List.RemoveAt(0);
            model.AdminLevel3List.RemoveAt(0);

            Assert.All(model.AdminLevel1List, a => Assert.Equal("Region", a.strGISReferenceTypeName));
            Assert.All(model.AdminLevel2List, a => Assert.Equal("Rayon", a.strGISReferenceTypeName));
            Assert.All(model.AdminLevel3List, a => Assert.Equal("Settlement", a.strGISReferenceTypeName));

        }
    }
}
