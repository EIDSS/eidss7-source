function ShowSaveComplete() {
    $('#saveSuccessModal').modal('show');
}
function HideSaveComplete() {
    $('#saveSuccessModal').modal('hide');
}
function cancelSearch() {
    $('#cancelSearchModal').modal('show');
}
function cloaseSearchModal() {
    $('#cancelSearchModal').modal('hide');
}
function cancelAddEdit() {
    $('#cancelAddEditModal').modal('show');
}
function closeCancelAddEdit() {
    $('#cancelAddEditModal').modal('hide');
}
function deleteRecord() {
    $('#deleteSearchModal').modal('show');
}

function cancelDeleteRecord() {
    $('#deleteSearchModal').modal('hide');
}

function showPermissionsWarning() {
    $('#permissionsModal').modal('show');
}

function hidePermissionsWarning() {
    $('#permissionsModal').modal('hide');
}
function showImportMessage() {
    $('#importStatusModal').modal('show');
}
function hideImportMessage() {
    $('#importStatusModal').modal('hide');
}

function ShowFileFinishedModal() {
    $('#informationVisibility').hide();
    $('#resultsVisibility').show();
}