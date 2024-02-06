using AutoFixture;
using AutoFixture.AutoMoq;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.Administration.Security;
using System;
using System.Linq;
using System.Collections.Generic;
using Xunit;
using EIDSS.Repository.Repositories;
using EIDSS.Api.xUnitTest.Arrangements;
using MapsterMapper;
using Microsoft.AspNetCore.Mvc.Testing;
using EIDSS.Repository;
using EIDSS.Repository.Interfaces;
using Moq;
using EIDSS.Repository.ReturnModels;
using EIDSS.Domain.ViewModels.Administration;
using System.Collections;
using Microsoft.Extensions.Hosting;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.Outbreak;
using Microsoft.AspNetCore.Http;
using EIDSS.Domain.ResponseModels.Outbreak;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.ResponseModels.Human;
using System.Threading.Tasks;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Repository.Contexts;

namespace EIDSS.Api.xUnitTest
{
    public class TestData
    {
        private static IFixture fixture = new Fixture().Customize(new AutoMoqCustomization());
    }

    public class DataRepositoryTests : IClassFixture<BaseConfig>
    {
        private readonly IHost _host;
        private IMapper _mapper = null;
        private DataRepository _repo = null;
        private static IFixture fixture = new Fixture().Customize(new AutoMoqCustomization());



        public DataRepositoryTests(BaseConfig baseconfig)
        {
            var mockHttpContextAccessor = new Mock<IHttpContextAccessor>();
            var mockModelProcessHelper = new Mock<IModelProcessHelper>();

            var context = new DefaultHttpContext();

            _host = baseconfig.TestHost;

            var m = _host.Services.GetService(typeof(IMapper));
            _mapper = (IMapper)m;

            _repo = new DataRepository(
                new EIDSSContextProceduresMock( new Mock<EIDSSContext>()),
                baseconfig.DBContext,
                _mapper,
                new ModelPropertyMapper(), 
                mockHttpContextAccessor.Object,
                mockModelProcessHelper.Object);

            fixture.Customize<BaseGetRequestModel>(c =>
            c.With(p => p.LanguageId, "en-US")
            .With(p => p.Page, 1)
            .With(p => p.PageSize, 10));
        }
    }
}
