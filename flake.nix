{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    {
                        config-identity ? x : x ,
                        lib-identity ? x : x
                    } :
                        let
                            implementation =
                                { config , lib , ... } :
                                    let
                                        _config = config-identity config ;
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
                                                                            _config.lazy-shell-application
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