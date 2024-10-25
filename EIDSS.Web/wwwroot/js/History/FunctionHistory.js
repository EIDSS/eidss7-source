
var obj = {};
var CurrentGridInEdit="";
/*Method called to Create a local Storage object 
 * of the table data when enterting into edit mode
 */
function StoreInLineRowFunction(functionName, caller, rowParameters,tableCurrentPage) {
    obj.functionName = functionName;
    obj.callerId = caller.id;
    obj.rowParameters = rowParameters;
    obj.currentPage = tableCurrentPage;
    localStorage.setItem(functionName, JSON.stringify(obj));
    
}


function NotificationThatGridInEdit(functionName) {
    CurrentGridInEdit = functionName;
    
}

/*Method Called to return local storage object
 * */
function CallInLineRowFunction(functionName) {
    return localStorage.getItem(functionName);
}


/*Edit a duplicate Record
 * When user wishes to edit a duplicate record, 
 * this method will open the existing table row 
 * for editing -----SHOULD CONSIDER IMPLEMENTING THIS FOR GLOBAL ACCESS
 */
function ReserveRowState(tableId, modalIdToHide) {
    var storageObjectId = tableId + "SetInlineEditRow";
    var obj;
    obj = JSON.parse(CallInLineRowFunction(storageObjectId));
    var table = $('#' + tableId).DataTable();
    $('#' + modalIdToHide).modal("hide"); // Modal to Hide
    // table.page(obj.currentPage).draw('page');
    table.page(obj.currentPage).draw('page');
    setTimeout(function () {
        $("#" + obj.callerId)[0].click();
    }, 500);
}

//Clears an Item from Local Storage
function ClearLocalStorage(localStorageObj) {
    localStorage.removeItem(localStorageObj);
}
//ADDS an Item to Local Storage withought stringifying
function SaveToLocalStorage(storageName, storageValue) {
    localStorage.setItem(storageName, storageValue);
}
//Return From Local Storage
function GetLocalStorage(storageName) {
    return localStorage.getItem(storageName);
}

//ADDS an Item to Local Storage withought stringifying
function SaveToLocalStorageAndStringify(storageName, storageValue) {
    localStorage.setItem(storageName, JSON.stringify(storageValue));
}


//Clears an Item from Local Storage
function ClearTableDataFromLocalStorage(tableId) {
    var storageObjectId = tableId + "SetInlineEditRow";
    localStorage.removeItem(storageObjectId);
    CurrentGridInEdit = "";
}



//Check to see if the table is still in edit mode
function CheckTableMode(tableObjectName) {
    var tablObj = JSON.parse(CallInLineRowFunction(tableObjectName));
}

//Get All Textbox Values in table
$(document).ready(function () {
    $(document).on('click', "#submitButton", function () {
        $('#tableId').find('input[type=text]').each(function () {
            console.log(this.value)
        });
    });
});

///Confirm User Wants to leave the current page while a record is active
window.onbeforeunload = function (e) {
    //Check to see if changes are made to the grid in edit mode
  //  var message = "Changes made to the record will be lost if you leave the page. Do you want to continue?";
   

    if (CurrentGridInEdit != "") {
     //   e.returnValue = message;
       // return message;
    } else {
        ClearLocalStorage(CurrentGridInEdit);//Clear LocalStorage of current edited object;
    }
   
}
//Added for 2776 defect, however message cannot be translated
function SetNavigationAwayNotification(e) {
    $(window).bind('beforeunload', function () { return 'Click OK to exit'; });
}

function TurnOffNavigationNotification() {
   $(window).off('beforeunload');
}
//GRID HISTORY-- for testing 
function SaveColumns(name,val) {
    localStorage.setItem(name, val);
}
function LoadColumns(name) {
    return localStorage.getItem(name);
}

