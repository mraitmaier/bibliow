/*
 * biblio.js - custom JS code dealing with the Cases application
 *
 */

// send a HTTP request (GET, POST, DELETE, PUT...)
function sendRequest(method, url, data) {

    var req = new XMLHttpRequest();
    req.open(method, url, true);
    req.send(data);
}

// View an item with given DB ID: send a HTTP GET request to appropriate URL. 
function viewItem(item, id) {
    var url = "/" + item + "/" + id;
    sendRequest('GET', url, "");
    window.location.href = url;
}

// Delete an item with given DB ID: send a HTTP DELETE request to appropriate URL.
function deleteItem(name, id) {

    var url = '/biblio/' + id + '/delete';
    sendRequest('POST', url, null);
    $("#removeModal").modal("hide");
}

/*
//
function addItem() {

    //if ( $('#add_case_form')[0].checkValidity() && $('#add_case_form')[1].checkValidity() ) {
//    if(validateForm()) {
        postForm("add_form", "/biblio");
        $("#addModal").modal("hide");
  //      return true;
 //   }
  //  return false;
  //  
  return;
}
*/

//
function modifyItem(form_id, id) {

    var url = "/biblio/" + id + '/put';
    postForm(form_id, url);
}

// Process import data from CSV...
function importData(form_id) {
    var url = "/import";
    postForm(form_id, url);
}

// submit form as POST to a given URL
function postForm(form_id, url) {

    var form = document.getElementById(form_id);
    form.setAttribute("action", url)
    form.setAttribute("method", "post")
    form.submit();
}

// helper function
var isEmptyText = function(txt) {
    if (!txt) {
        return true;
    }
    return false;
}

/*
//
function validateInput(txt, name) {
    if (!txt) { 
        alert("The '" + name + "' is mandatory field. Must not be left empty."); 
        return false;
    }
    return true;
}

//
function validateForm() {
    if (!validateInput($("#caseid").val(), "Test Case ID"))  {
        return false
    }
    if  (!validateInput($("#casename").val(), "Test Case Name")) {
        return false
    }
    return true
}

function validateReqForm(frm) {
    if (validateInput($("#reqid").val(), "Requirement Short Name"))  {
        return false
    }
    if  (!validateInput($("#reqname").val(), "Requirement Name")) {
        return false
    }
    return true
}
*/
