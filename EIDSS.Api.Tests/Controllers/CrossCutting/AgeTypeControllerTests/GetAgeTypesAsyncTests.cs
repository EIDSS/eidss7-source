using AutoFixture;
using EIDSS.Api.Controllers.CrossCutting;
using EIDSS.Api.Tests.Factories;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc;
using Moq;

namespace EIDSS.Api.Tests.Controllers.CrossCutting.AgeTypeControllerTests
{
    public class GetAgeTypesAsyncTests
    {
        private readonly IFixture _autoFixture;
        private readonly AgeTypeController _controller;
        private readonly Mock<ITrtBaseReferenceRepository> _trtBaseReferenceRepository;

        public GetAgeTypesAsyncTests()
        {
            _autoFixture = AutoFixtureFactory.Create();

            _trtBaseReferenceRepository = _autoFixture.Freeze<Mock<ITrtBaseReferenceRepository>>();

            _controller = _autoFixture.Create<AgeTypeController>();
        }

        [Fact]
        public async Task ReturnsValidDataGivenNonEmptyDataFromRepository()
        {
            // Arrange
            var request = _autoFixture.Create<GetAgeTypesRequestModel>();
            var collection = _autoFixture.CreateMany<TrtBaseReference>();

            _trtBaseReferenceRepository
                .Setup(x => x.GetAgeTypesAsync(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<long[]>()))
                .ReturnsAsync(collection);

            // Act
            var response = await _controller.GetAgeTypesAsync(request);

            // Assert
            _trtBaseReferenceRepository.Verify(x => x.GetAgeTypesAsync(request.LanguageIsoCode, request.AdvancedSearch, request.ExcludeIds), Times.Once);

            var result = response.Result as OkObjectResult;
            result.Should().NotBeNull();

            var data = result.Value as IEnumerable<AgeTypeResponseModel>;
            data.Should().NotBeNull();
            data.Should().HaveSameCount(collection);

            foreach (var item in data)
            {
                collection.Should().Contain(x => x.IdfsBaseReference == item.Id && x.StrDefault == item.Text);
            }
        }
    }
}
