{{define "navbar"}}
    <!--<nav class="navbar navbar-default navbar-fixed-top" data-spy="affix" data-offset-top="55555" >-->
    <nav class="navbar navbar-default navbar-fixed-top" data-spy="affix" >
        <div class="container-fluid">
            <!-- Brand and toggle get grouped for better mobile display -->
            <div class="navbar-header">
            &nbsp;
            <a class="navbar-brand" href="/index" data-toggle="tooltip" data-placement="top" title="Home">
                <span class="fa fa-university" ></span> &nbsp; <strong>BIBLIO</strong>
            </a>
            &nbsp;
            </div>

            <!-- Collect the nav links, forms, and other content for toggling -->
            <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">

                <form class="navbar-form navbar-left" role="search" method="post" action="/search">
                    <div class="form-group">
                        <input type="text" name="search-string" class="form-control" placeholder="Enter search string">
                    </div>
                    <button type="submit" class="btn btn-primary">Submit</button>
                </form>

           </div><!-- /.navbar-collapse -->
        </div><!-- /.container-fluid -->
    </nav>
{{end}}
