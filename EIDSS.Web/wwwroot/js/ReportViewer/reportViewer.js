﻿
//$(document).ready(function () {
//	_initializeReportViewerControls();

//	$('.FirstPage, .ViewReport, .Refresh').click(function () {
//		if (!$(this).attr('disabled')) {
//			viewReportPage(1);
//		}
//	});

//	$('.PreviousPage').click(function () {
//		if (!$(this).attr('disabled')) {
//			var page = parseInt($('#ReportViewerCurrentPage').val()) - 1;

//			viewReportPage(page);
//		}
//	});

//	$('.NextPage').click(function () {
//		if (!$(this).attr('disabled')) {
//			var page = parseInt($('#ReportViewerCurrentPage').val()) + 1;

//			viewReportPage(page);
//		}
//	});

//	$('.LastPage').click(function () {
//		if (!$(this).attr('disabled')) {
//			var page = parseInt($('#ReportViewerTotalPages').text());

//			viewReportPage(page);
//		}
//	});

//	$('#ReportViewerCurrentPage').change(function () {
//		var page = $(this).val();

//		viewReportPage(page);
//	});

//	$('.ExportXml, .ExportCsv, .ExportPdf, .ExportMhtml, .ExportExcelOpenXml, .ExportTiff, .ExportWordOpenXml').click(function () {
//		exportReport($(this));
//	});

//	$('#ReportViewerSearchText').on("keypress", function (e) {
//		if (e.keyCode == 13) {
//			// Cancel the default action on keypress event
//			e.preventDefault();
//			findText();
//		}
//	});

//	$('.FindTextButton').click(function () {
//		findText();
//	});

//	$('.Print').click(function () {
//		printReport();
//	});
//});

//function _initializeReportViewerControls() {
//	$('select').select2();

//	try {
//		ReportViewer_Register_OnChanges();
//	} catch (e) { }
//}

//function reloadParameters() {
//	var params = $('.ParametersContainer :input').serializeArray();
//	var urlParams = $.param(params);

//	showLoadingProgress("Updating Parameters...");

//    $.get("/Reports/Report/ReloadParameters/?reportPath=@Model.ReportPath.UrlEncode()&" + urlParams).done(function (data) {
//		if (data != null) {
//			$('.Parameters').html(data);
//			_initializeReportViewerControls();

//			if ($('.ReportViewerContent').find('div').length != 1) {
//				$('.ReportViewerContent').html('<div class="ReportViewerInformation">Please fill parameters and run the report...</div>');
//			}
//		}
//		hideLoadingProgress();
//	});
//}

//function showLoadingProgress(message) {
//	hideLoadingProgress();

//	$('.ReportViewerContent').hide();
//	$('.ReportViewerContentContainer').append('<div class="loadingContainer"><div style="margin: 0 auto; width: 100%; text-align: center; vertical-align: middle;"><h2><i class="glyphicon glyphicon-refresh gly-spin"></i>' + message + '</h2></div></div>');
//}

//function hideLoadingProgress() {
//	$('.loadingContainer').remove();
//	$('.ReportViewerContent').show();
//}

//function printReport() {
//	var params = $('.ParametersContainer :input').serializeArray();
//	var urlParams = $.param(params);

//    window.open("/Reports/Report/PrintReport/?reportPath=@Model.ReportPath.UrlEncode()&" + urlParams, "_blank");
//}

//function findText() {
//	$('.ReportViewerContent').removeHighlight();
//	var searchText = $("#ReportViewerSearchText").val();
//	if (searchText != undefined && searchText != null && searchText != "") {
//		showLoadingProgress('Searching Report...');
//		var params = $('.ParametersContainer :input').serializeArray();
//		var urlParams = $.param(params);

//		var page = parseInt($('#ReportViewerCurrentPage').val());

//        $.get("/Reports/Report/FindStringInReport/?reportPath=@Model.ReportPath.UrlEncode()&page=" + page + "&searchText=" + searchText + "&" + urlParams).done(function (data) {
//			if (data > 0) {
//				viewReportPage(data, function () {
//					$('.ReportViewerContent').highlight(searchText);
//					hideLoadingProgress();
//				});
//			} else {
//				$('.ReportViewerContent').highlight(searchText);
//				hideLoadingProgress();
//			}
//		});
//	}
//}

//function viewReportPage(page, afterReportLoadedCallback) {
//	showLoadingProgress('Loading Report Page...');
//	var params = $('.ParametersContainer :input').serializeArray();
//	var urlParams = $.param(params);
//	var totalPages = parseInt($('#ReportViewerTotalPages').text());

//	if (page == undefined || page == null || page < 1) {
//		page = 1;
//	} else if (page > totalPages) {
//		page = totalPages;
//	}

//    $.get("/Reports/Report/ViewReportPage/?reportPath=@Model.ReportPath.UrlEncode()&page=" + page + "&" + urlParams)
//	.done(function (data) {
//		updateReportContent(data);
//		hideLoadingProgress();

//		if (afterReportLoadedCallback && typeof (afterReportLoadedCallback) == "function") {
//			afterReportLoadedCallback();
//		}
//	})
//	.fail(function (data) {
//		$('.ReportViewerContent').html("<div class='ReportViewerError'>Report failed to load, check report parameters...</div>");
//		hideLoadingProgress();
//	});
//}

//function exportReport(element) {
//	var params = $('.ParametersContainer :input').serializeArray();
//	var urlParams = $.param(params);
//	var format = $(element).attr('class').replace("Export", "");

//	window.location.href = "/Reports/Report/ExportReport/?reportPath=@Model.ReportPath.UrlEncode()&format=" + format + "&" + urlParams;
//}

//function updateReportContent(data) {
//	if (data != undefined && data != null) {
//		$('#ReportViewerCurrentPage').val(data.currentPage);
//		$('#ReportViewerTotalPages').text(data.totalPages);
//		$('.ReportViewerContent').html($.parseHTML(data.content));

//		if (data.totalPages <= 1) {
//			$('.FirstPage').attr('disabled', true);
//			$('.PreviousPage').attr('disabled', true);
//			$('.NextPage').attr('disabled', true);
//			$('.LastPage').attr('disabled', true);
//		} else {
//			$('.FirstPage').attr('disabled', false);
//			$('.PreviousPage').attr('disabled', false);
//			$('.NextPage').attr('disabled', false);
//			$('.LastPage').attr('disabled', false);
//		}
//	}
//}
