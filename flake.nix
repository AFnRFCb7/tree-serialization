{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    {
                        lib-identity ? x : x
                    } :
                        let
                            implementation =
                                { lib , ... } :
                                    let
                                        _lib = lib-identity lib ;
                                        in
                                            {
                                                options.tree-serialization =
                                                    {
                                                        explode =
                                                            _lib.mkOption
                                                                {
                                                                    default =
                                                                        {
                                                                            name
                                                                        } :
                                                                            _conf.lazy-shell-application
                                                                                {
                                                                                    mounts = { } ;
                                                                                    name = name ;
                                                                                    post = null ;
                                                                                    runtime-inputs = pkgs : [ ] ;
                                                                                    text =
                                                                                        ''
                                                                                        '' ;
                                                                                } ;
                                                                    type = _lib.types.functionTo _lib.types.package ;
                                                                } ;
                                                    } ;
                                            } ;
                            in
                                {
                                    check = null ;
                                    implementation = implementation ;
                                } ;
            } ;
}