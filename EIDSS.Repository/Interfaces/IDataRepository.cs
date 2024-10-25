using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Repository.Interfaces
{

    public interface IDataRepository
    {
        Task<object> Delete(DataRepoArgs args);

        Task<object> Get(DataRepoArgs args);

        object GetSynchronously(DataRepoArgs args);


        Task<object> Save(DataRepoArgs args);

    }
    /// <summary>
    /// Container used to pass arguments to data repository data operation methods.
    /// </summary>
    public class DataRepoArgs
    {
        /// <summary>
        /// A DTO domain model that maps to the associated context model.
        /// </summary>
        public Type MappedReturnType { get; set; }

        /// <summary>
        /// The context model type used to determine the method to call on the context class and subsequently
        /// the type returned after the call.
        /// </summary>
        public Type RepoMethodReturnType { get; set; }

        /// <summary>
        /// An array of parameters that satisfy the call to the context method.
        /// </summary>
        public object[] Args { get; set; }
    }
}