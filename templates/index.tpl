{{define "main"}}
<!DOCTYPE html>
<html lang="en">

{{template "head" "Main"}}

<body>

    {{template "navbar" ""}}

    <div class="container-fluid">
        <div class="row col-md-10" id="header">
            <h1 id="main-title">{{.PageTitle}}</h1>
        </div> <!-- row -->

        <div class="row col-sm-10" >
            <br />
            <button type="button" class="btn btn-primary btn-sm" id="new-btn"
                                  data-toggle="modal" data-target="#addModal">
                <span class="fa fa-plus"></span> &nbsp; New Item 
            </button>
            <button type="button" class="btn btn-primary btn-sm" id="import-btn" 
                                  data-toggle="modal" data-target="#importModal">
                <span class="fa fa-upload"></span> &nbsp; Import
            </button>
        </div>

        <div class="row col-sm-10" id="data">
            <br />
    {{if .Items}}

            <div id="data-list">
                <table id="items" class="table table-stripped table-hover small">

                <thead>
            {{template "table-header"}}
                </thead>

                <tfoot>
            {{template "table-header"}}
                </tfoot>

                <tbody>
                    {{range $index, $elem := .Items}}
                    {{$id := add $index 1}}

                    <tr class="tbl-single-row" id="row-{{$elem.ID}}">
                        <td>{{$id}}</td>
                        <td>{{$elem.Title}}</td>
                        <td>{{$elem.Author}}</td>
                        <td>{{$elem.Type}}</td>
                        <td>{{$elem.Library}}</td>
                        <td>{{$elem.Language}}</td>
                        <td>{{$elem.Date}}</td>
                        <td class="text-right">
                            <span data-toggle="tooltip" data-placement="up" title="View Details">
                                <a href="" data-toggle="modal" data-target="#viewModal" 
                                    data-id="{{$elem.ID}}"
                                    data-created="{{$elem.Created}}"
                                    data-modified="{{$elem.Modified}}"
                                    data-title="{{$elem.Title}}"
                                    data-author="{{$elem.Author}}"
                                    data-type="{{$elem.Type}}"
                                    data-library="{{$elem.Library}}"
                                    data-language="{{$elem.Language}}"
                                    data-signature="{{$elem.Signature}}"
                                    data-invnumber="{{$elem.InvNumber}}"
                                    data-dateb="{{$elem.Date}}"
                                    data-publisher="{{$elem.Publisher}}"
                                    data-year="{{$elem.Year}}"
                                    data-isbn="{{$elem.ISBN}}"
                                    data-origtitle="{{$elem.OrigTitle}}"
                                    data-translator="{{$elem.Translator}}"
                                    data-notes="{{$elem.Notes}}">
                                    <span class="fa fa-eye"></span>
                                </a>
                            </span>
                            &nbsp;&nbsp;
                            <span data-toggle="tooltip" data-placement="up" title="Modify">
                                <a href="" data-toggle="modal" data-target="#modifyModal" 
                                    data-id="{{$elem.ID}}"
                                    data-created="{{$elem.Created}}"
                                    data-modified="{{$elem.Modified}}"
                                    data-title="{{$elem.Title}}"
                                    data-author="{{$elem.Author}}"
                                    data-type="{{$elem.Type}}"
                                    data-library="{{$elem.Library}}"
                                    data-language="{{$elem.Language}}"
                                    data-signature="{{$elem.Signature}}"
                                    data-invnumber="{{$elem.InvNumber}}"
                                    data-dateb="{{$elem.Date}}"
                                    data-publisher="{{$elem.Publisher}}"
                                    data-year="{{$elem.Year}}"
                                    data-isbn="{{$elem.ISBN}}"
                                    data-origtitle="{{$elem.OrigTitle}}"
                                    data-translator="{{$elem.Translator}}"
                                    data-notes="{{$elem.Notes}}">   
                                    <span class="fa fa-edit"></span>
                                </a>
                            </span>
                            &nbsp;&nbsp;
                            <span data-toggle="tooltip" data-placement="up" title="Remove">
                                <a href ="" data-toggle="modal" data-target="#removeModal"
                                            data-id="{{$elem.ID}}"
                                            data-title="{{$elem.Title}}"
                                            data-author="{{$elem.Author}}">
                                    <span class="fa fa-trash"></span>
                                </a>
                            </span>
                        </td>
                    </tr>

                    {{end}}
                </tbody>

                </table>
                </ul>
    {{else}}
    <p><strong>No data found.</strong></p>
    {{end}}
            </div> <!-- data-list -->
        </div> <!-- row -->
    </div> <!-- container fluid -->

<!-- Add modals -->
    {{template "add_modal"}}
    {{template "view_modal"}}
    {{template "modify_modal"}}
    {{template "remove_modal"}}
    {{template "import_modal"}}
<!-- End of Add modals -->
 
    </div> <!-- container fluid -->

    {{template "JS-includes"}}
    <script>
    
    // initialize dataTables jQuery plugin for better tables...
    // and validation plugin also...
    $(document).ready( function() {

        $('#items').DataTable({
            stateSave: true
        });
    });

    $('#viewModal').on('show.bs.modal', function (event) {

        var button = $(event.relatedTarget);     // Button that triggered the modal
        var title = button.data('title');
        var id = button.data('id');

        // Update the modal's content. We'll use jQuery here, but you could use a data binding library or other methods instead.
        var modal = $(this)
        modal.find('.modal-title').text('The "' + title + '"');
        modal.find('.modal-body #title').text(title);
        modal.find('.modal-body #author').text(button.data('author'));
        //modal.find('.modal-body #id').text(button.data('id'));
        modal.find('.modal-body #library').text(button.data('library'));
        modal.find('.modal-body #type').text(button.data('type'));
        modal.find('.modal-body #language').text(button.data('language'));
        modal.find('.modal-body #year').text(button.data('year'));
        modal.find('.modal-body #signature').text(button.data('signature'));
        modal.find('.modal-body #invnumber').text(button.data('invnumber'));
        modal.find('.modal-body #dateb').text(button.data('dateb'));
        modal.find('.modal-body #publisher').text(button.data('publisher'));
        modal.find('.modal-body #isbn').text(button.data('isbn'));
        modal.find('.modal-body #translator').text(button.data('translator'));
        modal.find('.modal-body #origtitle').text(button.data('origtitle'));
        modal.find('.modal-body #notes').val(button.data('notes'));
        modal.find('.modal-body #created').text(button.data('created'));
        modal.find('.modal-body #modified').text(button.data('modified'));
    });

    $('#modifyModal').on('show.bs.modal', function (event) {

        var button = $(event.relatedTarget);     // Button that triggered the modal
        var title = button.data('title');
        var created = button.data('created');
        var modified = button.data('modified');

        // Update the modal's content. We'll use jQuery here, but you could use a data binding library or other methods instead.
        var modal = $(this)
        modal.find('.modal-title').text('Modify "' + title + '"');
        modal.find('.modal-body #author').val(button.data('author'));
        modal.find('.modal-body #id').val(button.data('id'));
        modal.find('.modal-body #library').val(button.data('library'));
        modal.find('.modal-body #type').val(button.data('type'));
        modal.find('.modal-body #language').val(button.data('language'));
        modal.find('.modal-body #year').val(button.data('year'));
        modal.find('.modal-body #signature').val(button.data('signature'));
        modal.find('.modal-body #invnumber').val(button.data('invnumber'));
        modal.find('.modal-body #dateb').val(button.data('dateb'));
        modal.find('.modal-body #publisher').val(button.data('publisher'));
        modal.find('.modal-body #isbn').val(button.data('isbn'));
        modal.find('.modal-body #translator').val(button.data('translator'));
        modal.find('.modal-body #origtitle').val(button.data('origtitle'));
        modal.find('.modal-body #title').val(title);
        modal.find('.modal-body #notes').val(button.data('notes'));
        modal.find('.modal-body #created').val(created);
        modal.find('.modal-body #modified').val(modified);
        modal.find('.modal-body #createdm').text(created);
        modal.find('.modal-body #modifiedm').text(modified);
    });

    $('#removeModal').on('show.bs.modal', function (event) {

        var button = $(event.relatedTarget);     // Button that triggered the modal
        var id = button.data('id');
        var t = button.data('title');

        // Update the modal's content. We'll use jQuery here, but you could use a data binding 
        // library or other methods instead.
        var modal = $(this)
        modal.find('.modal-body #itemtitle').text(t);
        modal.find('.modal-body #title').val(t);

        var url = '/biblio/' + id + '/delete';

        // Remove btn on-click event closure
        $('#removebtn').on('click', function(e) {
             postForm('remove_form', url);
             $('#removeModal').modal('hide');
        });
    });

    // Add Case form on-submit validation 
    $('#addbtn').click(function() {
        postForm('add_form', '/biblio');
        $('#addModal').modal('hide');
    });

    // Modify Case form on-submit validation 
    $('#modifybtn').click(function() {
         modifyItem('modify_form', $('#id').val()); 
         $('#modifyModal').modal('hide');
    });

    // Import data button event handler
    $('#importbtn').click( function() {
        postForm('import_form', '/import');
        $('#importModal').modal('hide');
    });

    </script>

</body>
</html>
{{end}}

{{define "head"}}
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; 
         any other head content must come *after* these tags -->

    <title>Biblio - {{.}}</title>

    <!-- Bootstrap -->
    <link href="static/css/bootstrap.min.css" rel="stylesheet">
    <link href="static/css/dataTables.bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="static/css/font-awesome.min.css">
    <link href="static/css/custom.css" rel="stylesheet">

</head>
{{end}}

{{define "JS-includes"}}
    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="static/js/jquery-2.2.4.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="static/js/bootstrap.min.js"></script>
    <script src="static/js/jquery.dataTables.min.js"></script>
    <script src="static/js/dataTables.bootstrap.min.js"></script>
    <!-- custom -->
    <script src="static/js/biblio.js"></script>
{{end}}

{{define "table-header"}}
                    <tr>
                        <th class="col-sm-1">#</th>
                        <th class="col-sm-3">Title</th>
                        <th class="col-sm-2">Author</th>
                        <th class="col-sm-1">Type</th>
                        <th class="col-sm-2">Library</th>
                        <th class="col-sm-1">Language</th>
                        <th class="col-sm-1">Date</th>
                        <th class="col-sm-1 text-right">Actions</th>
                    </tr>
{{end}}

{{define "add_modal"}}
<div class="modal fade" id="addModal" tabindex="-1" role="dialog" aria-labelledby="addModalLabel">
<div class="modal-dialog modal-lg">
<div class="modal-content">

    <div class="modal-header">
    <div class="container-fluid">
        <div class="row">
            <h4 class="modal-title col-sm-8" id="addModalLabel">Add a New Item</h4>
            <button type="button" id="addbtn" class="btn btn-primary btn-sm col-sm-2">Add</button>
            <button type="button" class="btn btn-default btn-sm col-sm-2" data-dismiss="modal">Cancel</button>
        </div> <!-- row -->
    </div> <!-- container-fluid -->
    </div> <!-- modal-header -->

    <div class="modal-body">
      <form id="add_form" class="form-horizontal" method="post">
          <div class="form-group form-group-sm">
              <label for="title" class="col-sm-2 control-label">Title</label>
              <div class="col-sm-10">
                <input type="text" class="form-control" id="title" name="title" placeholder="Title">
              </div>
          </div>
          <div class="form-group form-group-sm">
              <label for="author" class="col-sm-2 control-label">Author</label>
              <div class="col-sm-10">
                <input type="text" class="form-control" id="author" name="author" placeholder="Author Name">
              </div>
          </div>
          <div class="form-group form-group-sm">
              <label for="origtitle" class="col-sm-2 control-label">Original Title</label>
              <div class="col-sm-10">
                  <input type="text" class="form-control" id="origtitle" name="origtitle" placeholder="Original Title">
              </div>
          </div>
          <div class="form-group form-group-sm">
             <label for="translator" class="col-sm-2 control-label">Translator</label>
             <div class="col-sm-10">
                <input type="text" class="form-control" id="translator" name="translator" placeholder="Translator">
             </div>
         </div>
          <div class="form-group form-group-sm">
             <label for="publisher" class="col-sm-2 control-label">Published by</label>
             <div class="col-sm-10">
                <input type="text" class="form-control" id="publisher" name="publisher" placeholder="Publisher">
             </div>
         </div>
          <div class="form-group form-group-sm">
             <label for="isbn" class="col-sm-2 control-label">ISBN Number</label>
             <div class="col-sm-4">
                <input type="text" class="form-control" id="isbn" name="isbn" placeholder="ISBN Number">
             </div>
             <label for="year" class="col-sm-2 control-label">Year</label>
             <div class="col-sm-4">
                <input type="text" class="form-control" id="year" name="year" placeholder="Year Published">
             </div>
         </div>
          <div class="form-group form-group-sm">
             <label for="library" class="col-sm-2 control-label">Library</label>
             <div class="col-sm-10">
                <input type="text" class="form-control" id="library" name="library" placeholder="Library">
             </div>
         </div>
          <div class="form-group form-group-sm">
             <label for="type" class="col-sm-2 control-label">Type</label>
             <div class="col-sm-4">
                <input type="text" class="form-control" id="type" name="type" placeholder="Media Type">
             </div>
             <label for="language" class="col-sm-2 control-label">Language</label>
             <div class="col-sm-4">
                <input type="text" class="form-control" id="language" name="language" placeholder="Item Language">
             </div>
         </div>
          <div class="form-group form-group-sm">
             <label for="invnumber" class="col-sm-2 control-label">Inv Number</label>
             <div class="col-sm-4">
                <input type="text" class="form-control" id="invnumber" name="invnumber" placeholder="Inventory Number">
             </div>
             <label for="dateb" class="col-sm-2 control-label">Date Borrowed</label>
             <div class="col-sm-4">
                <input type="date" class="form-control" id="dateb" name="dateb" placeholder="Date Borrowed">
             </div>
         </div>
          <div class="form-group form-group-sm">
             <label for="signature" class="col-sm-2 control-label">Signature</label>
             <div class="col-sm-10">
                <input type="text" class="form-control" id="signature" name="signature" placeholder="Signature">
             </div>
         </div>
         <div class="form-group form-group-sm">
             <label for="notes" class="col-sm-2 control-label">Notes</label>
             <div class="col-sm-offset-10">&nbsp;</div>
             <div class="col-sm-12">
                <textarea class="form-control" rows="3" id="notes" name="notes"></textarea>
             </div>
         </div>
      </form>
    </div>

</div>
</div>
</div>
{{end}}

{{define "view_modal"}}
<div class="modal fade" id="viewModal" tabindex="-1" role="dialog" aria-labelledby="viewModalLabel">
<div class="modal-dialog modal-lg">
<div class="modal-content">

    <div class="modal-header">
    <div class="container-fluid">
        <div class="row">
            <h4 class="modal-title col-md-10" id="viewModalLabel">Empty Title</h4>
            <button type="button" class="btn btn-default btn-sm col-md-2" data-dismiss="modal">Cancel</button>
        </div> <!-- row -->
    </div> <!-- container-fluid -->
    </div> <!-- modal-header -->

    <div class="modal-body">
      <form id="view_form" class="form-horizontal" >
          <div class="form-group form-group-sm">
              <label for="title" class="col-sm-2 control-label">Title</label>
              <div class="col-sm-10">
                <label class="form-control" id="title" name="title">
              </div>
          </div>
          <div class="form-group form-group-sm">
              <label for="author" class="col-sm-2 control-label">Author</label>
              <div class="col-sm-10">
                <label class="form-control" id="author" name="author">
              </div>
          </div>
          <div class="form-group form-group-sm">
              <label for="origtitle" class="col-sm-2 control-label">Original Title</label>
              <div class="col-sm-10">
                  <label class="form-control" id="origtitle" name="origtitle">
              </div>
          </div>
          <div class="form-group form-group-sm">
             <label for="translator" class="col-sm-2 control-label">Translator</label>
             <div class="col-sm-10">
                <label class="form-control" id="translator" name="translator">
             </div>
         </div>
          <div class="form-group form-group-sm">
             <label for="publisher" class="col-sm-2 control-label">Published by</label>
             <div class="col-sm-10">
                <label class="form-control" id="publisher" name="publisher">
             </div>
         </div>
          <div class="form-group form-group-sm">
             <label for="isbn" class="col-sm-2 control-label">ISBN Number</label>
             <div class="col-sm-4">
                <label class="form-control" id="isbn" name="isbn">
             </div>
             <label for="year" class="col-sm-2 control-label">Year</label>
             <div class="col-sm-4">
                <label class="form-control" id="year" name="year">
             </div>
         </div>
          <div class="form-group form-group-sm">
             <label for="library" class="col-sm-2 control-label">Library</label>
             <div class="col-sm-10">
                <label class="form-control" id="library" name="library">
             </div>
         </div>
          <div class="form-group form-group-sm">
             <label for="type" class="col-sm-2 control-label">Type</label>
             <div class="col-sm-4">
                <label class="form-control" id="type" name="type">
             </div>
             <label for="language" class="col-sm-2 control-label">Language</label>
             <div class="col-sm-4">
                <label class="form-control" id="language" name="language">
             </div>
         </div>
          <div class="form-group form-group-sm">
             <label for="invnumber" class="col-sm-2 control-label">Inv Number</label>
             <div class="col-sm-4">
                <label class="form-control" id="invnumber" name="invnumber">
             </div>
             <label for="dateb" class="col-sm-2 control-label">Date Borrowed</label>
             <div class="col-sm-4">
                <label class="form-control" id="dateb" name="dateb">
             </div>
         </div>
          <div class="form-group form-group-sm">
             <label for="signature" class="col-sm-2 control-label">Signature</label>
             <div class="col-sm-10">
                <label class="form-control" id="signature" name="signature">
             </div>
         </div>
 
          <div class="form-group form-group-sm">
                <label for="notes" class="col-sm-2 control-label">Notes</label>
                <div class="col-sm-offset-10">&nbsp;</div>
                <div class="col-sm-12">
                <textarea class="form-control" rows="3" id="notes" name="notes" readonly></textarea>
                </div>
          </div>
          <div class="form-group form-group-sm small">
                <div class="col-sm-2 text-right"><strong>Created:</strong></div>
                <div id="created" name="created" class="col-sm-3 text-left">Error</div>
                <div class="col-sm-3 text-right"><strong>Modified:</strong></div>
                <div id="modified" name="modified" class="col-sm-3 text-left">Error</div>
          </div>
      </form>
    </div>
</div>
</div>
</div>
{{end}}

{{define "modify_modal"}}
<div class="modal fade" id="modifyModal" tabindex="-1" role="dialog" aria-labelledby="modifyModalLabel">
<div class="modal-dialog modal-lg">
<div class="modal-content">

    <div class="modal-header">
    <div class="container-fluid">
        <div class="row">
            <h4 class="modal-title col-sm-8" id="modifyModalLabel">Empty Title</h4>
            <button type="button" class="btn btn-primary btn-sm col-sm-2" id="modifybtn">
                    Modify
            </button>
            <button type="button" class="btn btn-default btn-sm col-sm-2" data-dismiss="modal">Cancel</button>
        </div> <!-- row -->
    </div> <!-- container-fluid -->
    </div> <!-- modal-header -->

    <div class="modal-body">
      <form id="modify_form" class="form-horizontal">
          <input type="hidden" id="id" name="id"> 
          <div class="form-group form-group-sm">
              <label for="title" class="col-sm-2 control-label">Title</label>
              <div class="col-sm-10">
                <input type="text" class="form-control" id="title" name="title">
              </div>
          </div>
          <div class="form-group form-group-sm">
              <label for="author" class="col-sm-2 control-label">Author</label>
              <div class="col-sm-10">
                <input type="text" class="form-control" id="author" name="author">
              </div>
          </div>
          <div class="form-group form-group-sm">
              <label for="origtitle" class="col-sm-2 control-label">Original Title</label>
              <div class="col-sm-10">
                  <input type="text" class="form-control" id="origtitle" name="origtitle">
              </div>
          </div>
          <div class="form-group form-group-sm">
             <label for="translator" class="col-sm-2 control-label">Translator</label>
             <div class="col-sm-10">
                <input type="text" class="form-control" id="translator" name="translator">
             </div>
         </div>
          <div class="form-group form-group-sm">
             <label for="publisher" class="col-sm-2 control-label">Published by</label>
             <div class="col-sm-10">
                <input type="text" class="form-control" id="publisher" name="publisher">
             </div>
         </div>
          <div class="form-group form-group-sm">
             <label for="isbn" class="col-sm-2 control-label">ISBN Number</label>
             <div class="col-sm-4">
                <input type="text" class="form-control" id="isbn" name="isbn">
             </div>
             <label for="year" class="col-sm-2 control-label">Year</label>
             <div class="col-sm-4">
                <input type="text" class="form-control" id="year" name="year">
             </div>
         </div>
          <div class="form-group form-group-sm">
             <label for="library" class="col-sm-2 control-label">Library</label>
             <div class="col-sm-10">
                <input type="text" class="form-control" id="library" name="library">
             </div>
         </div>
          <div class="form-group form-group-sm">
             <label for="type" class="col-sm-2 control-label">Type</label>
             <div class="col-sm-4">
                <input type="text" class="form-control" id="type" name="type">
             </div>
             <label for="language" class="col-sm-2 control-label">Language</label>
             <div class="col-sm-4">
                <input type="text" class="form-control" id="language" name="language">
             </div>
         </div>
          <div class="form-group form-group-sm">
             <label for="invnumber" class="col-sm-2 control-label">Inv Number</label>
             <div class="col-sm-4">
                <input type="text" class="form-control" id="invnumber" name="invnumber">
             </div>
             <label for="date" class="col-sm-2 control-label">Date Borrowed</label>
             <div class="col-sm-4">
                <input type="date" class="form-control" id="dateb" name="dateb">
             </div>
         </div>
          <div class="form-group form-group-sm">
             <label for="signature" class="col-sm-2 control-label">Signature</label>
             <div class="col-sm-10">
                <input type="text" class="form-control" id="signature" name="signature">
             </div>
         </div>
         <div class="form-group form-group-sm">
             <label for="notes" class="col-sm-2 control-label">Notes</label>
             <div class="col-sm-offset-10">&nbsp;</div>
             <div class="col-sm-12">
                <textarea class="form-control" rows="3" id="notes" name="notes"></textarea>
             </div>
         </div>
         <div class="form-group form-group-sm small">
                <input type="hidden" name="created" id="created">
                <input type="hidden" name="modified" id="modified">
                <div class="col-sm-2 text-right"><strong>Created:</strong></div>
                <div id="createdm" name="createdm" class="col-sm-3 text-left">Error</div>
                <div class="col-sm-3 text-right"><strong>Modified:</strong></div>
                <div id="modifiedm" name="modifiedm" class="col-sm-3 text-left">Error</div>
         </div>
      </form>
    </div>
</div>
</div>
</div>
{{end}}

{{define "remove_modal"}}
<div class="modal fade" id="removeModal" tabindex="-1" role="dialog" aria-labelledby="removeModalLabel">
<div class="modal-dialog">
<div class="modal-content">

    <div class="modal-header">
    <div class="container-fluid">
        <div class="row">
            <h4 class="modal-title col-sm-8" id="removeModalLabel">Remove</h4>
            <button type="button" class="btn btn-primary btn-sm col-sm-2" id="removebtn">Remove</button>
            <button type="button" class="btn btn-default btn-sm col-sm-2" data-dismiss="modal">Cancel</button>
        </div> <!-- row -->
    </div> <!-- container-fluid -->
    </div> <!-- modal-header -->

    <div class="modal-body">
    <p> Would you really like to remove the item '<span id="itemtitle"></span>'?</p>
    <form id="remove_form">
        <input type="hidden" name="title" id="title" />
        <input type="hidden" name="author" id="author" />
    </form>
    </div>

</div>
</div>
</div>
{{end}}

{{define "import_modal"}}
<div class="modal fade" id="importModal" tabindex="-1" role="dialog" aria-labelledby="importModalLabel">
<div class="modal-dialog">
<div class="modal-content">

    <div class="modal-header">
    <div class="container-fluid">
        <div class="row">
            <h4 class="modal-title col-sm-8" id="importModalLabel">Import New Data</h4>
            <button type="button" class="btn btn-primary btn-sm col-sm-2" id="importbtn">Import</button>
            <button type="button" class="btn btn-default btn-sm col-sm-2" data-dismiss="modal">Cancel</button>
        </div> <!-- row -->
    </div> <!-- container-fluid -->
    </div> <!-- modal-header -->

    <div class="modal-body">
    <div class="container-fluid">
        <div class="row">
            <p>Please browse to the import file (must be CSV format)</p>
        </div>
            <div class="row">
            <form id="import_form" enctype="multipart/form-data">
                <input type="file" name="importfile" id="importfile" />
            </form>
        </div>
    </div>
    </div>

</div>
</div>
</div>
{{end}}
