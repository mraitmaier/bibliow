{{define "imported"}}
<!DOCTYPE html>
<html lang="en">

{{template "head" "Import Status"}}

<body>

    {{template "navbar" ""}}

    <div class="container-fluid">
        <div class="row col-md-10" id="header">
            <h1 id="main-title">Import Status</h1>
        </div> <!-- row -->

        <div class="row col-sm-10" id="data">
            <br />
    {{if .Items}}
            <p>The {{.NumAll}} {{if eq .NumAll 1}}item was{{else}}items were{{end}} parsed from file and 
            {{.NumImported}} of them {{if eq .NumImported 1}}was{{else}}were{{end}} imported.<br>
            Note that known duplicates and invalid items were ignored.</p>

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
                                    data-date="{{$elem.Date}}"
                                    data-publisher="{{$elem.Publisher}}"
                                    data-year="{{$elem.Year}}"
                                    data-isbn="{{$elem.ISBN}}"
                                    data-origtitle="{{$elem.OrigTitle}}"
                                    data-translator="{{$elem.Translator}}"
                                    data-notes="{{$elem.Notes}}">
                                    <span class="fa fa-eye"></span>
                                </a>
                            </span>
                        </td>
                    </tr>

                    {{end}}
                </tbody>

                </table>
                </ul>
    {{else}}
    <p>No items were imported (but {{.NumAll}} {{if eq .NumAll 1}}item was{{else}}items were{{end}} parsed from file).<br>
       Note that known duplicates and invalid items were ignored.</p>
    {{end}}
            </div> <!-- data-list -->
        </div> <!-- row -->
    </div> <!-- container fluid -->

<!-- Add modals -->
    {{template "view_modal"}}
<!-- End of Add modals -->
 
    </div> <!-- container fluid -->

    {{template "JS-includes"}}
    <script>
    
    // initialize dataTables jQuery plugin for better tables...
    // and validation plugin also...
    $(document).ready( function() {

        $('#items').DataTable();

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
        modal.find('.modal-body #date').text(button.data('date'));
        modal.find('.modal-body #publisher').text(button.data('publisher'));
        modal.find('.modal-body #isbn').text(button.data('isbn'));
        modal.find('.modal-body #translator').text(button.data('translator'));
        modal.find('.modal-body #origtitle').text(button.data('origtitle'));
        modal.find('.modal-body #notes').val(button.data('notes')); 
        modal.find('.modal-body #created').text(button.data('created'));
        modal.find('.modal-body #modified').text(button.data('modified'));
    });

    </script>

</body>
</html>
{{end}}
