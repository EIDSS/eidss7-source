using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Microsoft.CodeAnalysis.Text;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace EIDSS.Client.CodeGenerator
{

    [Generator]
    public class APIClientGenerator : ISourceGenerator
    {
        public void Execute(GeneratorExecutionContext context)
        {
            ClientSyntaxReceiver syntaxReceiver = (ClientSyntaxReceiver)context.SyntaxReceiver;

            bool appending = true;
            string clientclassname = string.Empty;
            string interfacename = string.Empty;
            string methodname = string.Empty;
            string returntype = string.Empty;
            string forwardingparameters = string.Empty;
            string filename = string.Empty;
            int modelidx = -1;
            Dictionary<string, ClientSourceController> sourceController = new Dictionary<string, ClientSourceController>();
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

[usingsandnamespace]
{{

   public partial interface [interfacename]
   {{
       [interfacesource]
   }}

   public partial class [clientclassname] : BaseApiClient, [interfacename]
   {{
");
            StringBuilder source = new StringBuilder($@"
[usingsandnamespace]

   public partial interface [interfacename]
   {{
       [interfacesource]
   }}

   public partial class [clientclassname] : BaseApiClient, [interfacename]
   {{
");
            ClientCodeGenerationDirectiveContainer gencontainer;
            string sourcetext = string.Empty;

            IEnumerable<AdditionalText> jsonFiles = context.AdditionalFiles.Where(
                    w => w.Path.EndsWith("codegenerationdirectives.json", StringComparison.OrdinalIgnoreCase));

            AdditionalText f = jsonFiles.First();

            try
            {
                // Deserialize Json into our model...
                gencontainer = JsonSerializer.Deserialize<ClientCodeGenerationDirectiveContainer>(f.GetText().ToString());

                if (gencontainer == null || gencontainer.ClientDirectives == null || gencontainer.ClientDirectives.Count == 0)
                    return;

                foreach (var m in gencontainer.ClientDirectives)
                {
                    clientclassname = m.Classname;

                    // If we have source in the source dictionary for this class then we append to it...
                    if (sourceController.Where(w => w.Key == m.Classname).Count() == 0)
                    {
                        sourceController.Add(m.Classname, new ClientSourceController
                        {
                            FileName = $"{m.Classname}.cs"
                        });
                        appending = false;
                    }
                    else appending = true;

                    var _ = source.ToString().TrimEnd();
                    _ = _.Replace("[usingsandnamespace]", syntaxReceiver.ClientSyntax[m.Classname].ToString());

                    if (appending == false)
                    {
                        // Pickup the using and namespace statements for this class...
                        if (syntaxReceiver.ClientSyntax.ContainsKey(m.Classname))
                            sourcetext = source.ToString().TrimEnd()
                                .Replace("[usingsandnamespace]", syntaxReceiver.ClientSyntax[m.Classname].ToString());
                        else
                            sourcetext = defaultsource.ToString().TrimEnd()
                                .Replace("[usingsandnamespace]", syntaxReceiver.ClientSyntax[m.Classname].ToString());

                        sourceController[m.Classname].Source.Append(sourcetext);
                    }

                    // Set client class name in source...
                    sourceController[m.Classname].Source = sourceController[m.Classname].Source.Replace("[clientclassname]", m.Classname);

                    // Set the interface name...
                    sourceController[m.Classname].Source = sourceController[m.Classname].Source.Replace("[interfacename]", $"I{m.Classname}");

                    foreach (var meth in m.MethodDirectives)
                    {
                        methodname = meth.Name;
                        returntype = meth.ReturnType;
                        modelidx += 1;

                        forwardingparameters = ProcessForwardingParms(meth.Parameters);

                        // Generate...
                        if (meth.CallType.ToLower() == "get")
                        {

                            // Write out the method...
                            sourceController[m.Classname].Source.Append($@"
        /// <summary>
        /// {meth.SummaryInfo}
        /// </summary>
        /// <returns></returns>
        public async Task<{meth.ReturnType}> {meth.Name}({meth.Parameters})
        {{
            var url = string.Format({meth.URL}, _eidssApiOptions.BaseUrl, {forwardingparameters});
            var httpResponse = await _httpClient.GetAsync(new Uri(url), HttpCompletionOption.ResponseHeadersRead);

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<{meth.ReturnType}>(contentStream, SerializationOptions);
        }}
  ");

                        }
                        else if (meth.CallType.ToLower() == "post")
                        {
                            sourceController[m.Classname].Source.Append($@"
        /// <summary>
        /// {meth.SummaryInfo}
        /// </summary>
        /// <returns></returns>
        public async Task<{meth.ReturnType}> {meth.Name}({meth.Parameters})
        {{
            using (MemoryStream ms = new MemoryStream())
            {{
                var url = string.Format({meth.URL}, _eidssApiOptions.BaseUrl);
                var aj = new MediaTypeWithQualityHeaderValue(""application/json"");

                await JsonSerializer.SerializeAsync(ms, {forwardingparameters});
                ms.Seek(0, SeekOrigin.Begin);

                var requestmessage = new HttpRequestMessage(HttpMethod.Post, url);
                requestmessage.Headers.Accept.Add(aj);

                using (var requestContent = new StreamContent(ms))
                {{
                    requestmessage.Content = requestContent;
                    requestContent.Headers.ContentType = aj;
                    using (var response = await _httpClient.SendAsync(requestmessage, HttpCompletionOption.ResponseHeadersRead))
                    {{
                        response.EnsureSuccessStatusCode();
                        var content = await response.Content.ReadAsStreamAsync();
                        return await JsonSerializer.DeserializeAsync<{meth.ReturnType}>(content, this.SerializationOptions);
                    }}
                }}
            }}
        }}
");
                        }
                        else if (meth.CallType.ToLower() == "delete")
                        {
                            sourceController[m.Classname].Source.Append($@"
        /// <summary>
        /// {meth.SummaryInfo}
        /// </summary>
        /// <returns></returns>
        public async Task<{meth.ReturnType}> {meth.Name}({meth.Parameters})
        {{
            var url = string.Format({meth.URL}, _eidssApiOptions.BaseUrl, {forwardingparameters});
            var httpResponse = await _httpClient.DeleteAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            var response = await JsonSerializer.DeserializeAsync<{meth.ReturnType}>(contentStream,
                new JsonSerializerOptions
                {{
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }});

            return response;
        }}
");
                        }
                        // Interface Members...
                        sourceController[m.Classname].InterfaceMembers.Append($@"
        Task<{meth.ReturnType}> {meth.Name}({meth.Parameters});
");
                    }
                }

                if (sourceController.Count > 0)
                {
                    foreach (var c in sourceController)
                    {
                        if (((ClientSourceController)c.Value).Source.Length > 0)
                        {
                            // Insert interface...
                            ((ClientSourceController)c.Value).Source.Replace("[interfacesource]", ((ClientSourceController)c.Value).InterfaceMembers.ToString());

                            // Close up the namespace and class with closing brackets...
                            ((ClientSourceController)c.Value).Source.Append($@"
   }}");
                            ((ClientSourceController)c.Value).Source.Append($@"
}}");
                        }

                        // Write out each method to the .cs file...
                        context.AddSource(((ClientSourceController)c.Value).FileName, SourceText.From(((ClientSourceController)c.Value).Source.ToString(), Encoding.UTF8));
                    }
                }
            }
            catch (Exception ex)
            {
                var msg = ex.Message;
                if (ex.InnerException != null) msg += " " + ex.InnerException.Message;
                msg += " Error occurred while generating method {0} for API Client Class {1}. Parms:  FileName: {2}, ReturnType:{3}, MethodParameters: {4}, Stack Trace:{5}";

                context.ReportDiagnostic(Diagnostic.Create(
                                new DiagnosticDescriptor(
                                    "CLIENT-GEN-ERR0001",
                                    "Generation Error",
                                    msg,
                                    "Error",
                                    DiagnosticSeverity.Error,
                                    true), null, new object[] {methodname, clientclassname, filename, returntype,
                                            forwardingparameters, ex.StackTrace }));
            }
            modelidx = -1;
        }

        public void Initialize(GeneratorInitializationContext context)
        {
            // may not be necessary...
            context.RegisterForSyntaxNotifications(() => new ClientSyntaxReceiver());
        }

        private static string ProcessForwardingParms(string methodParms)
        {
            string ret = string.Empty;
            int idx = 0;
            int i = 0;

            // look for = and if found delete it and the first word after...
            idx = methodParms.IndexOf('=');
            if (idx != -1)
            {
                for (i = 0; (idx+i) <= methodParms.Length; i++)
                    if (methodParms[i] == ',' || methodParms[i] == ')')
                        break;
                methodParms = methodParms.Remove(idx, i-1);
            }
            // reset for use below...
            idx = 0;
            var _ = methodParms.Split(' ', ' ');

            foreach (var s in _)
            {
                if (idx%2 != 0)
                    ret += s + " ";

                idx++;
            }

            // before returning, remove the cancellation token if it exists...
            ret = Regex.Replace(ret, "cancellationtoken", "", RegexOptions.IgnoreCase,TimeSpan.FromMilliseconds(5));
            ret = ret.TrimEnd();
            if (ret.EndsWith(",")) ret = ret.Substring(0, ret.Length-1);
            return ret;
        }
 
    }


    /// <summary>
    /// Checks all ClientAPIs and gathers up their respective using and namespaces.
    /// </summary>
    class ClientSyntaxReceiver : ISyntaxReceiver
    {
        StringBuilder codegenBlurb = new StringBuilder($@"
//------------------------------------------------------------------------------
// <auto-generated>
//
//      This code was auto-generated by the EIDSS API Client Generation Tool.
//      This class cannot be directly modified.  To modify the output of this class
//      edit the Code Generation Directive in the EIDSS.ClientLibrary namespace that initially 
//      generated this class.
//
// </auto-generated>
//------------------------------------------------------------------------------
");

        public List<ClientGenConstants> Directives { get; private set; } = new List<ClientGenConstants>();

        public Dictionary<string, StringBuilder> ClientSyntax = new Dictionary<string, StringBuilder>();

        /// <summary>
        /// Called for each SyntaxNode in the compilation
        /// </summary>
        /// <param name="syntaxNode">The current SyntaxNode being visited</param>
        public void OnVisitSyntaxNode(SyntaxNode syntaxNode)
        {
            string prop = string.Empty;
            CompilationUnitSyntax usingsection;

            if (!(syntaxNode is ClassDeclarationSyntax) && !(syntaxNode is PropertyDeclarationSyntax)) return;

            // Look for API client classes  and get their syntax tree (using statements and namespace declaration)...
            if (syntaxNode is ClassDeclarationSyntax)
            {
                var tds = (TypeDeclarationSyntax)syntaxNode;

                var cls = (syntaxNode as ClassDeclarationSyntax);

                // Look for all api client types...
                var clsname = cls.Identifier.ValueText;

                if (clsname.ToLower().EndsWith("client"))
                {
                    // Get the using statements off of the class.
                    // Eventually we'll also get all public method declarations to build the client interface...
                    if (tds.BaseList != null)
                    {
                        var bl = tds.BaseList;
                        foreach (var entry in bl.Types)
                        {
                            if (entry is SimpleBaseTypeSyntax basetype)
                            {
                                if (basetype.Type is IdentifierNameSyntax type)
                                {
                                    if (type.Identifier.ValueText == "BaseApiClient")
                                    {
                                        if (!ClientSyntax.ContainsKey(clsname))
                                        {
                                            ClientSyntax.Add(clsname, new StringBuilder());
                                        }

                                        ClientSyntax[clsname].Append(codegenBlurb);
                                        usingsection = cls.SyntaxTree.GetRoot() as CompilationUnitSyntax;
                                        foreach (var u in usingsection.Usings)
                                            ClientSyntax[clsname].AppendLine($"using {u.Name.ToString()};");

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
                                                            ClientSyntax[clsname].Append($"namespace {((QualifiedNameSyntax)s).GetText()}");
                                                            ClientSyntax[clsname].Append("{");
                                                        }

                                                    }
                                                }
                                        }
                                    }

                                }
                            }
                        }
                    }
                }
            }
        }

        private string RemoveEncoding(string input)
        {
            var ibytes = Encoding.UTF8.GetBytes(input);
            var obytes = Encoding.Convert(Encoding.UTF8, Encoding.ASCII, ibytes);

            var ret = Encoding.ASCII.GetString(obytes);

            ret = ret.Replace(@"\", "");
            return ret;
        }
    }

    #region Old

    public class APIClientGeneratorWorking : ISourceGenerator
    {
        public void Execute(GeneratorExecutionContext context)
        {
            ClientSyntaxReceiver syntaxReceiver = (ClientSyntaxReceiver)context.SyntaxReceiver;

            Generate(context, syntaxReceiver);
        }

        public void Initialize(GeneratorInitializationContext context)
        {
            context.RegisterForSyntaxNotifications(() => new ClientSyntaxReceiver());
        }

        private void Generate(GeneratorExecutionContext context, ClientSyntaxReceiver receiver)
        {
            bool appending = true;
            string clientclassname = string.Empty;
            string interfacename = string.Empty;
            string methodname = string.Empty;
            string returntype = string.Empty;
            string forwardingparameters = string.Empty;
            string methodparameters = string.Empty;
            string filename = string.Empty;
            string summary = string.Empty;
            string url = string.Empty;
            Dictionary<string, ClientSourceController> sourceController = new Dictionary<string, ClientSourceController>();
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

   public partial interface [interfacename]
   {{
       [interfacesource]
   }}

   public partial class [clientclassname] : BaseApiClient, [interfacename]
   {{
");
            StringBuilder source = new StringBuilder($@"
[usingsandnamespace]

   public partial interface [interfacename]
   {{
       [interfacesource]
   }}

   public partial class [clientclassname] : BaseApiClient, [interfacename]
   {{
");

            try
            {
                if (receiver.Directives == null || receiver.ClientSyntax == null || receiver.ClientSyntax.Count == 0 )
                    return;

                foreach (var gen in receiver.Directives)
                {
                    if (gen.ClientClassName == null || gen.ClientClassName.Trim().Length == 0)
                        continue;

                    if (sourceController.Where(w => w.Key == gen.ClientClassName).Count() == 0)
                    {
                        sourceController.Add(gen.ClientClassName, new ClientSourceController
                        {
                            FileName = gen.ClientClassName + ".cs"
                        });
                        appending = false;
                    }
                    else appending = true;

                    // Process forwarding parameters...
                    // Each repo call requires an output parameter prior to the Cancellation Token...
                    methodparameters = gen.MethodParms.Replace('"', ' ').Trim();
                    forwardingparameters = ProcessForwardingParms(methodparameters);

                    clientclassname = gen.ClientClassName;
                    interfacename = $"I{gen.ClientClassName}";
                    methodname = gen.MethodName.Trim();
                    returntype = gen.ReturnType;
                    summary = gen.SummaryInfo;
                    url = gen.URL;

                    var _ = source.ToString().TrimEnd();
                    _ = _.Replace("[usingsandnamespace]", receiver.ClientSyntax[clientclassname].ToString());

                    // Generate
                    if (gen.MethodVerb.Contains("GET"))
                    {
                        if (appending == false)
                        {
                            // Pickup the using and namespace statements for this class...
                            if (receiver.ClientSyntax.ContainsKey(clientclassname))
                                sourceController[gen.ClientClassName].Source.Append(_);
                            else
                                sourceController[gen.ClientClassName].Source.Append(defaultsource);
                        }
                        // Set client class name in source...
                        sourceController[gen.ClientClassName].Source = sourceController[gen.ClientClassName].Source.Replace("[clientclassname]", clientclassname);
                        
                        // Set the interface name...
                        sourceController[gen.ClientClassName].Source = sourceController[gen.ClientClassName].Source.Replace("[interfacename]", interfacename);

                        // Write out the method...
                        sourceController[gen.ClientClassName].Source.Append($@"
        /// <summary>
        /// {summary}
        /// </summary>
        /// <returns></returns>
        public async Task<{returntype}> {methodname}({methodparameters})
        {{
            var url = string.Format({url}, _eidssApiOptions.BaseUrl, {forwardingparameters});
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<{returntype}>(contentStream, SerializationOptions);
        }}
  ");

                        // Interface Members...
                        sourceController[gen.ClientClassName].InterfaceMembers.Append($@"
        Task<{returntype}> {methodname}({methodparameters});
");
                    }
                }

                if (sourceController.Count > 0)
                {
                    foreach (var c in sourceController)
                    {
                        if (((ClientSourceController)c.Value).Source.Length > 0)
                        {
                            // Insert interface...
                            ((ClientSourceController)c.Value).Source.Replace("[interfacesource]", ((ClientSourceController)c.Value).InterfaceMembers.ToString());

                            ((ClientSourceController)c.Value).Source.Append($@"
    }}");
                            ((ClientSourceController)c.Value).Source.Append($@"
}}");
                        }

                        // Write out each method to the .cs file...
                        context.AddSource(((ClientSourceController)c.Value).FileName, SourceText.From(((ClientSourceController)c.Value).Source.ToString(), Encoding.UTF8));
                    }
                }
            }
            catch (Exception ex)
            {
                var msg = ex.Message;
                if (ex.InnerException != null) msg += " " + ex.InnerException.Message;
                msg += " Error occurred while generating method {0} for API Client Class {1}. Parms:  FileName: {2}, MethodName:{3}, ReturnType:{4}, MethodParameters: {5}, Stack Trace:{6}";

                context.ReportDiagnostic(Diagnostic.Create(
                                new DiagnosticDescriptor(
                                    "CLIENT-GEN-ERR0001",
                                    "Generation Error",
                                    msg,
                                    "Error",
                                    DiagnosticSeverity.Error,
                                    true), null, new object[] { methodname, clientclassname, filename ,methodname, returntype, methodparameters, ex.StackTrace }));
            }
        }

        private static string ProcessForwardingParms(string methodParms)
        {
            string ret = string.Empty;
            int idx = 0;
            int i = 0;

            // look for = and if found delete it and the first word after...
            idx = methodParms.IndexOf('=');
            if (idx != -1)
            {
                for (i = 0; (idx+i) <= methodParms.Length; i++)
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
                if (idx%2 != 0)
                    ret += s + " ";

                idx++;
            }

            return ret;
        }
    }
    class ClientSyntaxReceiverWorking : ISyntaxReceiver
    {
        StringBuilder codegenBlurb = new StringBuilder($@"
//------------------------------------------------------------------------------
// <auto-generated>
//
//      This code was auto-generated by the EIDSS API Client Generation Tool.
//      This class cannot be directly modified.  To modify the output of this class
//      edit the Code Generation Directive in the EIDSS.ClientLibrary namespace that initially 
//      generated this class.
//
// </auto-generated>
//------------------------------------------------------------------------------
");

        public List<ClientGenConstants> Directives { get; private set; } = new List<ClientGenConstants>();

        public Dictionary<string, StringBuilder> ClientSyntax = new Dictionary<string, StringBuilder>();

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

            if (!(syntaxNode is ClassDeclarationSyntax) && !(syntaxNode is PropertyDeclarationSyntax)) return;

            // Look for API client classes  and get their syntax tree (using statements and namespace declaration)...
            if (syntaxNode is ClassDeclarationSyntax)
            {
                var tds = (TypeDeclarationSyntax)syntaxNode;

                var cls = (syntaxNode as ClassDeclarationSyntax);

                // Look for all api client types...
                var clsname = cls.Identifier.ValueText;

                if (clsname.ToLower().EndsWith("client"))
                {
                    // Get the using statements off of the class.
                    // Eventually we'll also get all public method declarations to build the client interface...
                    if (tds.BaseList != null)
                    {
                        var bl = tds.BaseList;
                        foreach (var entry in bl.Types)
                        {
                            if (entry is SimpleBaseTypeSyntax basetype)
                            {
                                if (basetype.Type is IdentifierNameSyntax type)
                                {
                                    if (type.Identifier.ValueText == "BaseApiClient")
                                    {
                                        if (!ClientSyntax.ContainsKey(clsname))
                                        {
                                            ClientSyntax.Add(clsname, new StringBuilder());
                                        }

                                        ClientSyntax[clsname].Append(codegenBlurb);
                                        usingsection = cls.SyntaxTree.GetRoot() as CompilationUnitSyntax;
                                        foreach (var u in usingsection.Usings)
                                            ClientSyntax[clsname].AppendLine($"using {u.Name.ToString()};");

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
                                                            ClientSyntax[clsname].Append($"namespace {((QualifiedNameSyntax)s).GetText()}");
                                                            ClientSyntax[clsname].Append("{");
                                                        }

                                                    }
                                                }
                                        }
                                    }

                                }
                            }
                        }
                    }
                }
            }
            // Look for property declarations...
            else if (syntaxNode is PropertyDeclarationSyntax)
            {
                // We're looking for classes that implement the ICodeGenDirective contract but aren't interface declarations...
                var parent = syntaxNode.Parent.GetText();
                if (parent.Container.CurrentText.Lines.Any(a => a.Text.ToString().Contains("IAPIClientCodeGenDirective")) &&
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
                        Directives.Add(new ClientGenConstants
                        {
                            MethodName = classname
                        });
                        fidx = Directives.Count - 1;
                    }

                    if (prop.Contains("ClientClassName"))
                    {
                        idxToken0 = prop.IndexOf(".", 0) + 1;
                        idxToken1 = prop.IndexOf(";", idxToken0);
                        var cn = prop.Substring(idxToken0, idxToken1 - idxToken0).Trim();

                        // remove the extension if it exists...
                        if (cn.ToLower().EndsWith(".cs"))
                            cn = cn.Substring(0, cn.Length-3);

                        Directives[fidx].ClientClassName = cn;

                    }
                    else if (prop.Contains("ReturnType"))
                    {
                        idxToken0 = prop.IndexOf("(", 0) + 1;
                        idxToken1 = prop.IndexOf(")", idxToken0);
                        Directives[fidx].ReturnType = this.RemoveEncoding( prop.Substring(idxToken0, idxToken1 - idxToken0).Trim());
                    }
                    else if (prop.Contains("MethodParameters"))
                    {
                        idxToken0 = prop.IndexOf("=>", 0) + 2;
                        idxToken1 = prop.IndexOf(";", idxToken0);
                        Directives[fidx].MethodParms = this.RemoveEncoding(prop.Substring(idxToken0, idxToken1 - idxToken0).Trim());
                    }
                    else if (prop.Contains("MethodVerb"))
                    {
                        idxToken0 = prop.IndexOf("=>", 0) + 2;
                        idxToken1 = prop.IndexOf(";", idxToken0);
                        Directives[fidx].MethodVerb = this.RemoveEncoding( prop.Substring(idxToken0, idxToken1 - idxToken0).Trim());
                    }
                    else if (prop.Contains("Url"))
                    {
                        idxToken0 = prop.IndexOf("=>", 0) + 2;
                        idxToken1 = prop.IndexOf(";", idxToken0);
                        Directives[fidx].URL = this.RemoveEncoding( prop.Substring(idxToken0, idxToken1 - idxToken0).Trim());
                    }
                     else if (prop.Contains("SummaryInfo"))
                    {
                        idxToken0 = prop.IndexOf("=>", 0) + 2;
                        idxToken1 = prop.IndexOf(";", idxToken0);
                        Directives[fidx].SummaryInfo = this.RemoveEncoding( prop.Substring(idxToken0, idxToken1 - idxToken0).Trim());
                    }
                }
            }
        }

        private string RemoveEncoding( string input)
        {
            var ibytes = Encoding.UTF8.GetBytes(input);
            var obytes = Encoding.Convert(Encoding.UTF8, Encoding.ASCII, ibytes);

            var ret = Encoding.ASCII.GetString(obytes);

            ret = ret.Replace(@"\", "");
            return ret;
        }
    }
    class ClientGenConstants
    {
        public string ClientClassName { get; set; }
        public string MethodName { get; set; }
        public string MethodParms { get; set; }
        public string MethodVerb { get; set; }
        public string ReturnType { get; set; }
        public string SummaryInfo { get; set; }
        public string URL { get; set; }

    }
    class ClientSourceController
    {
        public StringBuilder InterfaceMembers { get; set; } = new StringBuilder();
        public StringBuilder Source { get; set; } = new StringBuilder();
        public string FileName { get; set; }
    }
    #endregion

}
