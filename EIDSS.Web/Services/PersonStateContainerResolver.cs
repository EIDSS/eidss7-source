using System.Collections.Concurrent;

namespace EIDSS.Web.Services;

public interface IPersonStateContainerResolver
{
    PersonStateContainer GetContainerFor(string personContainerScopeName);
}

public class PersonStateContainerResolver : IPersonStateContainerResolver
{
    private readonly ConcurrentDictionary<string, PersonStateContainer?> _dictionaryContainer = new();

    public PersonStateContainer GetContainerFor(string personContainerScopeName)
    {
        if (_dictionaryContainer.ContainsKey(personContainerScopeName))
        {
            return _dictionaryContainer[personContainerScopeName]!;
        }
        
        var personStateContainer = new PersonStateContainer();
        _dictionaryContainer[personContainerScopeName] = personStateContainer;
        return personStateContainer;
    }
}