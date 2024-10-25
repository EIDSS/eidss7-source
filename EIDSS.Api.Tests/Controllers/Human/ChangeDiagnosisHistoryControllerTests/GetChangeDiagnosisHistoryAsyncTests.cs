using AutoFixture;
using EIDSS.Api.Controllers.Human;
using EIDSS.Api.Tests.Factories;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels.Custom;
using FluentAssertions;
using MapsterMapper;
using Microsoft.AspNetCore.Mvc;
using Moq;

namespace EIDSS.Api.Tests.Controllers.Human.ChangeDiagnosisHistoryControllerTests;

public class GetChangeDiagnosisHistoryAsyncTests
{
    private readonly IFixture _autoFixture;
    private readonly ChangeDiagnosisHistoryController _controller;
    private readonly Mock<ITlbChangeDiagnosisHistoryRepository> _tlbChangeDiagnosisHistoryRepository;
    private readonly IMapper _mapper;

    public GetChangeDiagnosisHistoryAsyncTests()
    {
        _autoFixture = AutoFixtureFactory.Create();

        _tlbChangeDiagnosisHistoryRepository = _autoFixture.Freeze<Mock<ITlbChangeDiagnosisHistoryRepository>>();
        _mapper = new Mapper();
        _autoFixture.Inject(_mapper);

        _controller = _autoFixture.Create<ChangeDiagnosisHistoryController>();
    }

    [Fact]
    public async Task ReturnsValidDataGivenNonEmptyDataFromRepository()
    {
        // Arrange
        var humanCaseId = _autoFixture.Create<long>();
        var languageIsoCode = _autoFixture.Create<string>();
        var collection = _autoFixture.CreateMany<ChangeDiagnosisHistoryReturnModel>();

        _tlbChangeDiagnosisHistoryRepository.Setup(x => x.GetChangeDiagnosisHistoryAsync(humanCaseId, languageIsoCode))
            .ReturnsAsync(collection);

        // Act
        var response = await _controller.GetChangeDiagnosisHistoryAsync(humanCaseId, languageIsoCode);

        // Assert
        _tlbChangeDiagnosisHistoryRepository.Verify(x => x.GetChangeDiagnosisHistoryAsync(humanCaseId, languageIsoCode), Times.Once());

        var result = response.Result as OkObjectResult;
        result.Should().NotBeNull();

        var data = result.Value as IEnumerable<ChangeDiagnosisHistoryResponseModel>;
        data.Should().NotBeNull();
        data.Should().HaveSameCount(collection);

        foreach (var item in data)
        {
            collection.Should().Contain(x => x.ChangedByOrganization == item.ChangedByOrganization && x.ChangedByPerson == item.ChangedByPerson && x.ChangedDisease == item.ChangedDisease && x.DateOfChange == item.DateOfChange && x.PreviousDisease == item.PreviousDisease && x.Reason == item.Reason);
        }
    }
}
