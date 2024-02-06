var InterfaceEditor = (function () {

    //private variables

    //public
    var module = this;

    module.resourcePartialUrl = "";
    module.languageUploadTemplateUrl = "";

    module.init = function () {
        //select the first tab after dom load
        setInitialState();

        //event bindings
        $(".collapse").on("show.bs.collapse", expandResourceHandler);
        $(".collapse").on("hide.bs.collapse", collapseResourceHandler);
        $("a[name='moduleTab']").on("click", moduleTabClickHandler);
        $("input[name='SearchCriteria_InterfaceEditorTypesCheckbox']").on("change", selectInterfaceEditorType);
        $("#searchForm").on('submit', search);
        $("#btnCloseSearchResults").on("click", closeSearchResults);
        $("#btnClearAllSearchCriteria").on("click", clearAllSearchCriteria);
    };

    module.search = function (event) {
        event.preventDefault();

        var sectionId = $("#SelectedSectionResourceSet").val();

        var model = {};
        model.SearchCriteria = getSearchCriteria();
        if (sectionId) {
            model.IdfsResourceSet = sectionId;
            $(".forSectionEmptying").empty();            
        }        

        var moduleId = $("#SelectedModuleResourceSet").val();
        if (moduleId == "") model.ModuleId = 3; // 'Global' module is selected by default when page is loaded
        else model.ModuleId = moduleId;        

        //console.log(moduleId);

        //if any search criteria are specified, show the filter alert
        toggleFilterAlert();

        //clear the existing selected resources if this is all modules
        if (sectionId && model.SearchCriteria.AllModules) {
            var resourceElement = $("#resource-" + sectionId);
            if (resourceElement != null) {
                resourceElement.empty();
            }
            $("#SelectedSectionResourceSet").val('');
            $(".collapse.show").collapse('hide');
        }

        //console.log(model);

        //if (model.SearchCriteria.AllModules) {
            //show the results tab
            $.ajax({
                url: module.resourcePartialUrl,
                type: 'POST',
                contentType: "application/json: charset=utf-8",
                data: JSON.stringify(model),
                success: function (response) {

                    //setInitialState();

                    $("#searchResultsModule").show();
                    $(".nav-link:not('#searchResultsLink')").addClass('disabled');
                    $("#tab-searchResults").show();

                    //$("#resource-searchResults").empty();
                    
                    $("#resource-searchResults").html(response);
                    $("#searchResultsLink").tab('show');
                },
                error: function (response) {
                    console.log(response);
                }
            });
        //}
        //else {
        //    //refresh any open sections with search filters and
        //    if (sectionId) {
        //        var table = $("#InterfaceEditorResourceGrid").DataTable();
        //        table.draw();
        //    }
        //}
    };

    module.clearSearchText = function() {
        $("#SearchCriteria_SearchText").val('');
        $("#searchForm").submit();
    };

    module.uploadLanguageTemplate = function() {
        var formData = new FormData();

        var languageName = $("#availableCultures option:selected").text();
        var languageCode = $("#availableCultures").val();
        formData.append("LanguageName", languageName);
        formData.append("LanguageCode", languageCode);
        var fileInput = $('#languageFile')[0];
        var file = fileInput.files[0];
        formData.append("LanguageFile", file);
        console.log(module.languageUploadTemplateUrl);

        $.ajax({
            url: module.languageUploadTemplateUrl,
            type: "POST",
            data: formData,
            processData: false,
            contentType: false,
            success: function (response) {
                $("#languagePartialDiv").html(response);
            },
            error: function (response) {
                console.log(response);
            },
            done: function (xhr, textStatus) {
                console.log(textStatus);
            }
        });
    };

    //private functions  
    function moduleTabClickHandler(event) {
        var id = event.currentTarget.dataset.id;
        $("#SelectedModuleResourceSet").val(id);

        //collapse any open accordions
        $(".collapse.show").collapse('hide');
    };

    function setInitialState() {
        $("#searchResultsModule").hide();
        $("#tab-searchResults").hide();
        $(".nav-tabs a:first").tab('show');
        $("#ResultsAreFilteredAlert").hide();
    };

    function expandResourceHandler(event) {
        var id = event.currentTarget.dataset.id;

        var model = {};
        model.SearchCriteria = getSearchCriteria();
        model.IdfsResourceSet = id;

        //if any search criteria are specified, show the filter alert
        toggleFilterAlert();

        $("#SelectedSectionResourceSet").val(id);

        $.ajax({
            url: module.resourcePartialUrl,
            type: 'POST',
            contentType: "application/json: charset=utf-8",
            data: JSON.stringify(model),
            success: function (response) {
                $("#resource-" + id).html(response);
            },
            error: function (response) {
                console.log(response);
            }
        });
    };

    function collapseResourceHandler(event) {
        var id = event.currentTarget.dataset.id;
        var resourceElement = $("#resource-" + id);
        if (resourceElement != null) {
            resourceElement.empty();
        }
    };

    function clearAllSearchCriteria() {
        $("#SearchCriteria_SearchText").val('');
        var types = [];
        $.each($("input[name='SearchCriteria_InterfaceEditorTypesCheckbox']"), function (index, value) {
            $(this).prop('checked', true);
            types.push({
                Value: String($(this).data("id")),
                Text: $(this).data("content"),
                Selected: true
            });
        });

        var typeString = types.map(function (item) {
            return item.Value;
        });

        $("#SearchCriteria_InterfaceEditorSelectedTypes").val(typeString);
        $("#SearchCriteria_Requried").prop('checked', false);
        $("#SearchCriteria_Hidden").prop('checked', false);
        $("#ResultsAreFilteredAlert").hide();
        toggleFilterAlert();
    };

    function closeSearchResults(event) {
        event.preventDefault();
        $(".nav-link:not('#searchResultsLink')").removeClass('disabled');
        setInitialState();
        $("#SearchCriteria_AllModules").prop('checked', false);
        toggleFilterAlert();
    };

    function selectInterfaceEditorType() {
        var types = [];
        $.each($("input[name='SearchCriteria_InterfaceEditorTypesCheckbox']:checked"), function () {
            types.push({
                Value: String($(this).data("id")),
                Text: $(this).data("content"),
                Selected: true
            });
        });

        var typeString = types.map(function (item) {
            return item.Value;
        });

        $("#SearchCriteria_InterfaceEditorSelectedTypes").val(typeString);
    };

    function getSearchCriteria() {
        var types = [];
        $.each($("input[name='SearchCriteria_InterfaceEditorTypesCheckbox']"), function () {
            types.push({
                Value: String($(this).data("id")),
                Text: $(this).data("content"),
                Selected: ($(this).is(":checked")) ? true : false
            });
        });

        var searchCriteria = {
            SearchText: $("#SearchCriteria_SearchText").val(),
            AllModules: $("#SearchCriteria_AllModules").is(":checked"),
            InterfaceEditorTypes: types,
            InterfaceEditorSelectedTypes: $("#SearchCriteria_InterfaceEditorSelectedTypes").val(),
            Required: $("#SearchCriteria_Required").is(":checked"),
            Hidden: $("#SearchCriteria_Hidden").is(":checked")
        }

        return searchCriteria;
    };

    function toggleFilterAlert() {
        var types = [];
        var filteredTypes = [];
        types = $("input[name='SearchCriteria_InterfaceEditorTypesCheckbox']");
        filteredTypes = types.filter(t => t.Selected == false);

        var searchCriteria = {
            SearchText: $("#SearchCriteria_SearchText").val(),
            AllModules: $("#SearchCriteria_AllModules").is(":checked"),
            InterfaceEditorTypes: types,
            InterfaceEditorSelectedTypes: $("#SearchCriteria_InterfaceEditorSelectedTypes").val(),
            Required: $("#SearchCriteria_Required").is(":checked"),
            Hidden: $("#SearchCriteria_Hidden").is(":checked")
        }

        if (searchCriteria.SearchText.length > 0 || filteredTypes.length > 0
            || searchCriteria.Required == true || searchCriteria.Hidden == true) {
            $("#ResultsAreFilteredAlert").removeClass('hide');
            $("#ResultsAreFilteredAlert").show()
        }
        else {
            $("#ResultsAreFilteredAlert").hide()
        }
    };

    return module;
})();

$(document).ready(InterfaceEditor.init());