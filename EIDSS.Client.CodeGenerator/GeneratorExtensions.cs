using Microsoft.CodeAnalysis;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;

namespace EIDSS.Client.CodeGenerator
{
    static class GeneratorExtensions
    {
        public static void CheckDebugger(this GeneratorExecutionContext context, string generatorName)
        {
            if (context.AnalyzerConfigOptions.GlobalOptions.TryGetValue("build_property.DebugSourceGenerators", out var debugValue) &&
                bool.TryParse(debugValue, out var shouldDebug) &&
                shouldDebug)
            {
                Debugger.Launch();
            }
            else if (context.AnalyzerConfigOptions.GlobalOptions.TryGetValue("build_property.Debug" + generatorName, out debugValue) &&
                bool.TryParse(debugValue, out shouldDebug) &&
                shouldDebug)
            {
                Debugger.Launch();
            }
        }
    }
}
