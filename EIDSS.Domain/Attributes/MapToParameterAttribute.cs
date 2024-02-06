using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.Attributes
{
    /// <summary>
    /// Used during repository operations to resolve context method parameter values from request model properties.  
    /// This attribute provides mapping between request model properties
    /// and repository method parameters.
    /// </summary>
    [AttributeUsage(AttributeTargets.Property, AllowMultiple =false)]
    public class MapToParameterAttribute : Attribute
    {
        /// <summary>
        /// The repository method's parameter this property maps to
        /// </summary>
        public string[] ParameterNames { get; set; }

        /// <summary>
        /// Create an instance of the attribute and performs a 1:1 map between the model property and the method parameter
        /// </summary>
        /// <param name="parametername"></param>
        public MapToParameterAttribute( string parametername)
        {
            ParameterNames = new string[] { parametername };
        }

        /// <summary>
        /// Creates a new instance of the attribute and maps multiple method variable names to a single model property.  This is useful for model base classes where 
        /// derived instances of that class will be utilized across various boundaries.
        /// </summary>
        /// <param name="parameternames"></param>
        public MapToParameterAttribute( string[] parameternames)
        {
            ParameterNames = parameternames;
        }
    }
}
