using AutoFixture;
using AutoFixture.AutoMoq;
using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace EIDSS.Api.Tests.Factories
{
    internal static class AutoFixtureFactory
    {
        internal static IFixture Create()
        {
            var fixture = new Fixture()
                .Customize(new AutoMoqCustomization { ConfigureMembers = true });
            fixture.Behaviors.OfType<ThrowingRecursionBehavior>().ToList()
                .ForEach(b => fixture.Behaviors.Remove(b));
            fixture.Behaviors.Add(new OmitOnRecursionBehavior());
            fixture.Customize<BindingInfo>(c => c.OmitAutoProperties());

            return fixture;
        }
    }
}
