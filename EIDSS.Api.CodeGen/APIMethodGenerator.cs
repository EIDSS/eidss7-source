using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Microsoft.CodeAnalysis.Text;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace EIDSS.CodeGenerator
{ 
    [Generator]
    public class APIMethodGenerator : ISourceGenerator
    {
       public void Execute(GeneratorExecutionContext context)
        {
            context.CheckDebugger("EIDSSApiCodeGenMetadata");

            SyntaxReceiver syntaxReceiver = (SyntaxReceiver)context.SyntaxReceiver;

            Generate(context, syntaxReceiver);
        }

        public void Initialize(GeneratorInitializationContext context)
        {
//#if DEBUG
//            if (!Debugger.IsAttached)
//            {
//                Debugger.Launch();
//            }
//#endif

            // Register a syntax receiver that will be created for each generation pass
            context.RegisterForSyntaxNotifications(() => new SyntaxReceiver());

        }

        private void Generate(GeneratorExecutionContext context, SyntaxReceiver receiver)
        {
            bool appending = true;
            string apiclassname = string.Empty;
            string methodname = string.Empty;
            string apireturntype = string.Empty;
            string forwardingparameters = string.Empty;
            string methodparameters = string.Empty;
            string methodverb = string.Empty;
            string reporeturntype = string.Empty;
            string filename = string.Empty;
            string summary = string.Empty;
            string apigroupname = string.Empty;
            Dictionary<string, SourceController> sourceController = new Dictionary<string, SourceController>();
            StringBuilder defaultsource = new StringBuilder($@"
using EIDSS.Api.Abstracts;                    
using EIDSS.Api.Provider;
using EIDSS.Api.Providers;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Serilog;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Api.Controllers
{{
   public partial class [apiclassname] : EIDSSControllerBase
   {{
");
            StringBuilder source = new StringBuilder($@"
[usingsandnamespace]
   public partial class [apiclassname] : EIDSSControllerBase
   {{
");

            try
            {

                foreach (var gen in receiver.Directives)
                {
                    if (gen.APIClassName == null || gen.APIClassName.Trim().Length == 0)
                        continue;

                    //if(!sourceController.Any( a=> a.Key == gen.APIClassName))
                    if (sourceController.Where(w => w.Key == gen.APIClassName).Count() == 0)
                    {
                        sourceController.Add(gen.APIClassName, new SourceController
                        {
                            FileName = gen.APIClassName + ".cs"
                        });
                        appending = false;
                    }
                    else appending = true;

                    // Process forwarding parameters...
                    // Each repo call requires an output parameter prior to the Cancellation Token...
                    methodparameters = gen.MethodParms.Replace('"', ' ').Trim();
                    //methodparameters = gen.MethodParms.Replace("[FromBody]", "");
                    forwardingparameters = ProcessForwardingParms(methodparameters);
                    forwardingparameters = forwardingparameters.Insert(forwardingparameters.IndexOf("cancellationToken", StringComparison.OrdinalIgnoreCase), " null, ").Trim();

                    apiclassname = gen.APIClassName;
                    methodname = gen.MethodName.Trim();
                    apireturntype = gen.APIReturnType;
                    reporeturntype = gen.RepositoryReturnType.Replace("[]", "");
                    summary = gen.SummaryInfo;


                    //Gotta find a better test for this...  Escape chars only...
                    apigroupname = gen.APIGroup.Length == 0 ? apiclassname.Substring(0, apiclassname.IndexOf("Controller", StringComparison.OrdinalIgnoreCase)) : gen.APIGroup;

                    var _ = source.ToString().TrimEnd();
                    _ = _.Replace("[usingsandnamespace]", receiver.ControllerSyntax[apiclassname].ToString());
                    if (gen.MethodVerb.Contains("GET_USING_POST_VERB"))
                    {
                        if (appending == false)
                        {
                            // Pickup the using and namespace statements for this class...
                            if (receiver.ControllerSyntax.ContainsKey(apiclassname))
                                sourceController[gen.APIClassName].Source.Append(_);
                            else
                                sourceController[gen.APIClassName].Source.Append(defaultsource);
                        }
                        sourceController[gen.APIClassName].Source = sourceController[gen.APIClassName].Source.Replace("[apiclassname]", apiclassname);

                        //Select the template that returns either a single result or an array...
                        if (apireturntype.Contains("List<"))
                            sourceController[gen.APIClassName].Source.Append($@"
       [HttpPost(""{methodname}"")]
       [ProducesResponseType(typeof({apireturntype}), StatusCodes.Status200OK)]
       [ProducesResponseType(typeof({apireturntype}), StatusCodes.Status400BadRequest)]
       [ProducesResponseType(typeof({apireturntype}), StatusCodes.Status401Unauthorized)]
       [SwaggerOperation(Summary ={summary},Tags = new[] {{ ""{apigroupname}"" }})]
       public async Task<IActionResult> {methodname}([FromBody] {methodparameters})
       {{
            {apireturntype} results = null;
            try
            {{
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {{Args = new object[] {{ {forwardingparameters} }},
                  MappedReturnType = typeof({apireturntype}),
                  RepoMethodReturnType = typeof({reporeturntype})
                }};

                // Forwards the call to context method:  
                results = await _repository.Get(args) as {apireturntype};
            }}
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {{
                Log.Error(""Process was cancelled"");
            }}
            catch (Exception ex)
            {{
                Log.Error(ex.Message);
                throw;
            }}

            return Ok(results);
        }}
");
                        else
                            sourceController[gen.APIClassName].Source.Append($@"
       [HttpPost(""{methodname}"")]
       [ProducesResponseType(typeof({apireturntype}), StatusCodes.Status200OK)]
       [ProducesResponseType(typeof({apireturntype}), StatusCodes.Status400BadRequest)]
       [ProducesResponseType(typeof({apireturntype}), StatusCodes.Status401Unauthorized)]
       [SwaggerOperation(Summary ={summary},Tags = new[] {{ ""{apigroupname}"" }})]
       public async Task<IActionResult> {methodname}([FromBody] {methodparameters})
       {{
            {apireturntype} results = null;
            try
            {{
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {{Args = new object[] {{ {forwardingparameters} }},
                  MappedReturnType = typeof({apireturntype}),
                  RepoMethodReturnType = typeof(List<{reporeturntype}>)
                }};

                // Forwards the call to context method:  
                var _ = await _repository.Get(args) as List<{apireturntype}>;

                if (_ != null && _.Count > 0)
                results = _.FirstOrDefault();
            }}
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {{
                Log.Error(""Process was cancelled"");
            }}
            catch (Exception ex)
            {{
                Log.Error(ex.Message);
                throw;
            }}

            return Ok(results);
        }}
");

                    }
                    else if (gen.MethodVerb.Contains("GET"))
                    {
                        if (appending == false)
                        {
                            // Pickup the using and namespace statements for this class...
                            if (receiver.ControllerSyntax.ContainsKey(apiclassname))
                                sourceController[gen.APIClassName].Source.Append(_);
                            else
                                sourceController[gen.APIClassName].Source.Append(defaultsource);
                        }
                        sourceController[gen.APIClassName].Source = sourceController[gen.APIClassName].Source.Replace("[apiclassname]", apiclassname);
                        if (apireturntype.Contains("List<"))
                            sourceController[gen.APIClassName].Source.Append($@"
        [HttpGet(""{methodname}"")]
        [ProducesResponseType(typeof({apireturntype}), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof({apireturntype}), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof({apireturntype}), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary ={summary},Tags = new[] {{ ""{apigroupname}"" }})]
        public async Task<IActionResult> {methodname}({methodparameters})
        {{
            {apireturntype} results = null;
            try
            {{
                    //Handled in Global cancellation handler and logs that the request was handled
                    cancellationToken.ThrowIfCancellationRequested();

                    DataRepoArgs args = new()
                    {{Args = new object[] {{ {forwardingparameters} }},
                       MappedReturnType = typeof({apireturntype}),
                       RepoMethodReturnType = typeof({reporeturntype})
                    }};
                    results = await _repository.Get(args) as {apireturntype};
            }}
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {{
                Log.Error(""Process was cancelled"");
            }}
            catch (Exception ex)
            {{
                Log.Error(ex.Message);
                throw;
            }}
            return Ok(results);
        }}
");
                        else
                            sourceController[gen.APIClassName].Source.Append($@"
        [HttpGet(""{methodname}"")]
        [ProducesResponseType(typeof({apireturntype}), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof({apireturntype}), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof({apireturntype}), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary ={summary},Tags = new[] {{ ""{apigroupname}"" }})]
        public async Task<IActionResult> {methodname}({methodparameters})
        {{
            {apireturntype} results = null;
            try
            {{
                    //Handled in Global cancellation handler and logs that the request was handled
                    cancellationToken.ThrowIfCancellationRequested();

                    DataRepoArgs args = new()
                    {{Args = new object[] {{ {forwardingparameters} }},
                       MappedReturnType = typeof({apireturntype}),
                       RepoMethodReturnType = typeof({reporeturntype})
                    }};
                    var _ = await _repository.Get(args) as List<{apireturntype}>;

                    if (_ != null)
                    results = _.FirstOrDefault();
              }}
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {{
                Log.Error(""Process was cancelled"");
            }}
            catch (Exception ex)
            {{
                Log.Error(ex.Message);
                throw;
            }}
            return Ok(results);
        }}
");

                    }
                    else if (gen.MethodVerb.Contains("POST"))
                    {
                        var operation = apireturntype.ToLower() == "apisaveresponsemodel" ? "Save" : "Get";

                        if (appending == false)
                        {
                            // Pickup the using and namespace statements for this class...
                            if (receiver.ControllerSyntax.ContainsKey(apiclassname))
                                sourceController[gen.APIClassName].Source.Append(_);
                            else
                                sourceController[gen.APIClassName].Source.Append(defaultsource);
                        }
                        sourceController[gen.APIClassName].Source = sourceController[gen.APIClassName].Source.Replace("[apiclassname]", apiclassname);

                        sourceController[gen.APIClassName].Source.Append($@"
       [HttpPost(""{methodname}"")]
       [ProducesResponseType(typeof({apireturntype}), StatusCodes.Status200OK)]
       [ProducesResponseType(typeof({apireturntype}), StatusCodes.Status400BadRequest)]
       [ProducesResponseType(typeof({apireturntype}), StatusCodes.Status401Unauthorized)]
       [SwaggerOperation(Summary ={summary},Tags = new[] {{ ""{apigroupname}"" }})]
       public async Task<IActionResult> {methodname}([FromBody] {methodparameters})
       {{
            {apireturntype} results = null;
            try
            {{
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {{Args = new object[] {{ {forwardingparameters} }},
                  MappedReturnType = typeof({apireturntype}),
                  RepoMethodReturnType = typeof(List<{reporeturntype}>)
                }};

                // Forwards the call to context method:  
                var _ = await _repository.{operation}(args) as {apireturntype};

                if (_ != null && _.Count > 0)
                results = _.FirstOrDefault();
            }}
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {{
                Log.Error(""Process was cancelled"");
            }}
            catch (Exception ex)
            {{
                Log.Error(ex.Message);
                throw;
            }}

            return Ok(results);
        }}
");
                    }
                    else if (gen.MethodVerb.Contains("SAVE"))
                    {
                        var operation = apireturntype.ToLower() == "apisaveresponsemodel" ? "Save" : "Get";

                        if (appending == false)
                        {
                            // Pickup the using and namespace statements for this class...
                            if (receiver.ControllerSyntax.ContainsKey(apiclassname))
                                sourceController[gen.APIClassName].Source.Append(_);
                            else
                                sourceController[gen.APIClassName].Source.Append(defaultsource);
                        }
                        sourceController[gen.APIClassName].Source = sourceController[gen.APIClassName].Source.Replace("[apiclassname]", apiclassname);

                        // Make sure api return type isn't an array type...
                        apireturntype = apireturntype.Replace("[]", "");

                        sourceController[gen.APIClassName].Source.Append($@"
       [HttpPost(""{methodname}"")]
       [ProducesResponseType(typeof({apireturntype}), StatusCodes.Status200OK)]
       [ProducesResponseType(typeof({apireturntype}), StatusCodes.Status400BadRequest)]
       [ProducesResponseType(typeof({apireturntype}), StatusCodes.Status401Unauthorized)]
       [SwaggerOperation(Summary ={summary},Tags = new[] {{ ""{apigroupname}"" }})]
       public async Task<IActionResult> {methodname}([FromBody] {methodparameters})
       {{
            {apireturntype} results = null;
            try
            {{
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {{Args = new object[] {{ {forwardingparameters} }},
                  MappedReturnType = typeof(List<{apireturntype}>),
                  RepoMethodReturnType = typeof(List<{reporeturntype}>)
                }};

                // Forwards the call to context method:  
                var _ = await _repository.{operation}(args) as List<{apireturntype}>;

                if (_ != null )
                results = _.FirstOrDefault();
            }}
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {{
                Log.Error(""Process was cancelled"");
            }}
            catch (Exception ex)
            {{
                Log.Error(ex.Message);
                throw;
            }}

            return Ok(results);
        }}
");
                    }
                    else if (gen.MethodVerb.Contains("DELETE"))
                    {
                        if (appending == false)
                        {
                            // Pickup the using and namespace statements for this class...
                            if (receiver.ControllerSyntax.ContainsKey(apiclassname))
                                sourceController[gen.APIClassName].Source.Append(_);
                            else
                                sourceController[gen.APIClassName].Source.Append(defaultsource);
                        }
                        sourceController[gen.APIClassName].Source = sourceController[gen.APIClassName].Source.Replace("[apiclassname]", apiclassname);
                        sourceController[gen.APIClassName].Source.Append($@"
        [HttpDelete(""{methodname}"")]
        [ProducesResponseType(typeof({apireturntype}), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof({apireturntype}), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof({apireturntype}), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary ={summary},Tags = new[] {{ ""{apigroupname}"" }})]
        public async Task<IActionResult> {methodname}({methodparameters})
        {{
            APIPostResponseModel results = null;
            try
            {{
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {{Args = new object[] {{ {forwardingparameters} }},
                  MappedReturnType = typeof(List<APIPostResponseModel>),
                  RepoMethodReturnType = typeof(List<{reporeturntype}>)
                }};

                // Forwards the call to context method:  
                var _ = await _repository.Delete(args) as List<APIPostResponseModel>;

                if (_ != null)
                    results = _.FirstOrDefault();

            }}
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {{
                Log.Error(""Process was cancelled"");
            }}
                catch (Exception ex)
            {{
               Log.Error(ex.Message);
                throw;
            }}
            return Ok(results);
        }}
");

                        //// Diagnostics...
                        //if (string.IsNullOrEmpty(gen.SummaryInfo))
                        //    context.ReportDiagnostic(Diagnostic.Create(MissingSummaryInformation, Location.None, ""));
                    }
                }
                if (sourceController.Count > 0)
                {
                    foreach (var c in sourceController)
                    {
                        if (((SourceController)c.Value).Source.Length > 0)
                        {
                            ((SourceController)c.Value).Source.Append($@"
    }}");
                            ((SourceController)c.Value).Source.Append($@"
}}");
                        }
                        context.AddSource(((SourceController)c.Value).FileName, SourceText.From(((SourceController)c.Value).Source.ToString(), Encoding.UTF8));
                    }
                }
            }
            catch (Exception ex)
            {
                var msg = ex.Message;
                if (ex.InnerException != null) msg += " " + ex.InnerException.Message;
                msg += " Error occurred while generating method {0} for API Class {1}.";

                context.ReportDiagnostic(Diagnostic.Create(
                                new DiagnosticDescriptor(
                                    "API-GEN-ERR0001",
                                    "Generation Error",
                                    msg,
                                    "Error",
                                    DiagnosticSeverity.Error,
                                    true), null, new object[] { methodname, apiclassname }));
            }
        }

        private static string ProcessForwardingParms( string methodParms )
        {
            string ret = string.Empty;
            int idx = 0;
            int i = 0;

            // look for = and if found delete it and the first word after...
            idx = methodParms.IndexOf('=');
            if (idx != -1)
            {
                for ( i = 0; (idx+i) <= methodParms.Length; i++)
                    if (methodParms[i] == ',' || methodParms[i] == ')') 
                        break;
                methodParms = methodParms.Remove(idx, i-1);
            }
            // reset for use below...
            idx = 0;
            var _ = methodParms.Split(' ', ' ');

            foreach (var s in _)
            {
                // if the index divided by 2, doesn't divide equally (has a remainder), then the number is odd
                // This is cool because this gets the comma in that position as well!
                if(idx%2 != 0)
                    ret += s + " ";

                idx++;
            }
         
            return ret;
        }
    }
  
    internal class SyntaxReceiver : ISyntaxReceiver
    {
        StringBuilder codegenBlurb = new StringBuilder($@"
//------------------------------------------------------------------------------
// <auto-generated>
//
//      This code was auto-generated by the EIDSS API Method generation tool.
//      This class cannot be directly modified.  To modify the output of this class
//      edit the Code Generation Directive in the EIDSS.Api namespace that initially 
//      generated this class.
//
// </auto-generated>
//------------------------------------------------------------------------------
");

        public List<GenConstants> Directives { get; private set; } = new List<GenConstants>();

        public Dictionary<string, StringBuilder> ControllerSyntax = new Dictionary<string, StringBuilder>();

        /// <summary>
        /// Called for each SyntaxNode in the compilation
        /// </summary>
        /// <param name="syntaxNode">The current SyntaxNode being visited</param>
        public void OnVisitSyntaxNode(SyntaxNode syntaxNode)
        {
            string prop = string.Empty;
            int idxToken0 = 0;
            int idxToken1 = 0;
            int idx = 0;
            CompilationUnitSyntax usingsection;

            // Look for APIController classes  and get their syntax tree (using statements and namespace declaration)...
            if (syntaxNode is ClassDeclarationSyntax)
            {
                var cls = (syntaxNode as ClassDeclarationSyntax);

                // Look for all controller types...
                var clsname = cls.Identifier.ValueText;

                if (clsname.ToLower().Contains("controller"))
                {
                    if (!ControllerSyntax.ContainsKey(clsname))
                    {
                        ControllerSyntax.Add(clsname, new StringBuilder());
                    }

                    ControllerSyntax[clsname].Append(codegenBlurb);
                    usingsection = cls.SyntaxTree.GetRoot() as CompilationUnitSyntax;
                    foreach (var u in usingsection.Usings)
                        ControllerSyntax[clsname].AppendLine($"using {u.Name.ToString()};");

                    // Get the namespace...
                    if (usingsection.Members.Count > 0)
                    {
                        foreach (var m in usingsection.Members)
                            if (m.Kind().ToString() == "NamespaceDeclaration")
                            {
                                foreach (var s in m.ChildNodes())
                                {
                                    if (s is QualifiedNameSyntax)
                                    {
                                        ControllerSyntax[clsname].Append($"namespace {((QualifiedNameSyntax)s).GetText()}");
                                        ControllerSyntax[clsname].Append("{");
                                    }

                                }
                            }
                    }
                } 
                else if( clsname.ToLower().Contains("directive"))
                {
                }
            }
            // Look for property declarations...
            else if (syntaxNode is PropertyDeclarationSyntax)
            {
                // We're looking for classes that implement the ICodeGenDirective contract but aren't interface declarations...
                var parent = syntaxNode.Parent.GetText();
                if (parent.Container.CurrentText.Lines.Any(a => a.Text.ToString().Contains("ICodeGenDirective")) &&
                    !parent.Container.CurrentText.Lines.Any(a => a.Text.ToString().Contains("public interface")))
                {
                    prop = syntaxNode.GetText().ToString().Trim();

                    // Get the class name...
                    idx = parent.ToString().IndexOf("class") + 6;
                    idxToken1 = parent.ToString().IndexOf(":");
                    var classname = parent.ToString().Substring(idx, idxToken1 - idx);

                    var fidx = Directives.FindIndex(f => f.MethodName == classname);

                    if (fidx == -1)
                    {
                        Directives.Add(new GenConstants
                        {
                            MethodName = classname
                        });
                        fidx = Directives.Count - 1;
                    }

                    if (prop.Contains("APIClassName"))
                    {
                        idxToken0 = prop.IndexOf(".", 0) + 1;
                        idxToken1 = prop.IndexOf(";", idxToken0);
                        Directives[fidx].APIClassName = prop.Substring(idxToken0, idxToken1 - idxToken0).Trim();
                    }
                    else if (prop.Contains("APIGroupName"))
                    {
                        idxToken0 = prop.IndexOf("=>", 0) + 2;
                        idxToken1 = prop.IndexOf(";", idxToken0);
                        Directives[fidx].APIGroup = prop.Substring(idxToken0, idxToken1 - idxToken0).Trim().Replace("\"","");
                    }
                    else if (prop.Contains("APIReturnType"))
                    {
                        idxToken0 = prop.IndexOf("(", 0) + 1;
                        idxToken1 = prop.IndexOf(")", idxToken0);
                        Directives[fidx].APIReturnType = prop.Substring(idxToken0, idxToken1 - idxToken0).Trim();
                    }
                    else if (prop.Contains("FiresEvent"))
                    {
                        idxToken0 = prop.IndexOf("=>", 0) + 2;
                        idxToken1 = prop.IndexOf(";", idxToken0);
                    }
                    else if (prop.Contains("MethodParameters"))
                    {
                        idxToken0 = prop.IndexOf("=>", 0) + 2;
                        idxToken1 = prop.IndexOf(";", idxToken0);
                        Directives[fidx].MethodParms = prop.Substring(idxToken0, idxToken1 - idxToken0).Trim();
                    }
                    else if (prop.Contains("MethodVerb"))
                    {
                        idxToken0 = prop.IndexOf("=>", 0) + 2;
                        idxToken1 = prop.IndexOf(";", idxToken0);
                        Directives[fidx].MethodVerb = prop.Substring(idxToken0, idxToken1 - idxToken0).Trim() ;
                    }
                    else if (prop.Contains("RepositoryReturnType"))
                    {
                        idxToken0 = prop.IndexOf("(", 0) + 1;
                        idxToken1 = prop.IndexOf(")", idxToken0);
                        Directives[fidx].RepositoryReturnType = prop.Substring(idxToken0, idxToken1 - idxToken0).Trim();
                    }
                    else if (prop.Contains("SummaryInfo"))
                    {
                        idxToken0 = prop.IndexOf("=>", 0) + 2;
                        idxToken1 = prop.IndexOf(";", idxToken0);
                        Directives[fidx].SummaryInfo = prop.Substring(idxToken0, idxToken1 - idxToken0).Trim();
                    }
                }
            }
        }
    }
    internal class GenConstants
    { 
        public string APIClassName { get; set; }
        public string APIGroup { get; set; }
        public string APIReturnType { get; set; }
        public string MethodName { get; set; }
        public string MethodParms { get; set; }
        public string MethodVerb { get; set; }
        public string RepositoryReturnType { get; set; }
        public string SummaryInfo { get; set; }

    }

    internal class SourceController
    {
        public StringBuilder Source { get; set; } = new StringBuilder();
        public string FileName { get; set; }
    }
}
