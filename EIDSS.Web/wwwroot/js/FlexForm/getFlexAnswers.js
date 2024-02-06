$(document).ready(function () {
	//Add javascript to the "Save" of the sidebar navigation
	$("[href='#finish']").attr('onclick', 'getFlexFormAnswers[IDFSFORMTYPE]();' + $('#[SUBMITBUTTONID]').attr('onclick'));
	//Add javascript to the known submit button, by id.
	$('#[SUBMITBUTTONID]').attr('onclick', 'getFlexFormAnswers[IDFSFORMTYPE]();' + $('#[SUBMITBUTTONID]').attr('onclick'));
});
function getFlexFormAnswers[IDFSFORMTYPE]() {
	var inputAnswers = '';
	var selectAnswers = '';
	
	$('#[IDFSFORMTYPE] input[parameter]').each(function (i, j) {
		if (j.type == "checkbox") {
			if (j.checked) {
				inputAnswers += j.id + '☼' + 'true' + '☼' + $(j).attr("idfRow") + '‼';
			}
			else {
				inputAnswers += j.id + '☼' + '☼' + $(j).attr("idfRow") + '‼';
			}
		}
		else {
			inputAnswers += j.id + '☼' + $(j).val() + '☼' + $(j).attr("idfRow") + '‼';
		}
	});

	$('#[IDFSFORMTYPE] select[parameter]').each(function (i, j) {
		selectAnswers += j.id + '☼' + $(j).val() + '☼' + $(j).attr("idfRow") + '‼';
	});

	inputAnswers = (inputAnswers + ".").replace("‼.", "");
	selectAnswers = (selectAnswers + ".").replace("‼.", "");

	$.ajax({
		url: '/CrossCutting/FlexForm/SaveAnswers',
		type: 'POST',
		data:
		{
			inputAnswers: inputAnswers,
			selectAnswers: selectAnswers,
			idfsFormTemplate: [IDFSFORMTEMPLATE],
			idfObservation: [IDFOBSERVATION]
		},
		dataType: 'text',
		async: false,
		success: function (idfObservation) {
			$("[asp-for='[OBSERVATIONFIELDID]']").val(idfObservation);


		},
		complete: function (json) {
		}
	});
};