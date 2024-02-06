function renderDiagnosisDropDown(data, type, row, meta) {
    var sel = "<select class='diagnosisSelect' id='" + meta.row + "'><option></option></select>";
    return sel;
}

function LoadDataTable() {
    $(document).ready(function () {
        alert("");
        $('#ReferenceEditorDynamic').DataTable({
            "columnDefs": [{
                "targets": [0],
                "visible": false,
                "searchable": false
            }],
            "ajax": {
                "url": "/DemoGrid/LoadData",
                "type": "POST",
                "datatype": "json"
            }  




        });
    });

}