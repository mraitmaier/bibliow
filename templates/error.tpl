{{define "error"}}
<!DOCTYPE html>
<html lang="en">

{{template "head" "Error"}}

<body>

    {{template "navbar" ""}}

    <div class="container-fluid">

    <div class="col-md-10" id="header">
    <h1>Error</h1>
    <h3>{{.}}</h3>
    </div> <!-- row -->

    </div> <!-- container fluid -->

    {{template "JS-includes"}}

</body>
</html>
{{end}}

{{define "err404"}}
<!DOCTYPE html>
<html lang="en">

{{template "head" "Page Not Found"}}

<body>

    {{template "navbar" ""}}

    <div class="container-fluid">

    <div class="col-md-10" id="header">
    <h1>Error 404</h1>
    <h3>Page not found.</h3>
    </div> <!-- row -->

    </div> <!-- container fluid -->

    {{template "JS-includes"}}

</body>
</html>
{{end}}

