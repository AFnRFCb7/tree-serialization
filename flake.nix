{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    {
                        config-identity ? x : x ,
                        lib-identity ? x : x ,
                        pkgs-identity ? x : x
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
                                                                            bytes ,
                                                                            input ,
                                                                            name ,
                                                                            output
                                                                        } :
                                                                            _config.lazy-shell-application
                                                                                {
                                                                                    mounts =
                                                                                        {
                                                                                            input = { read-only = true ; source = input ; type = "bind" ; } ;
                                                                                            output = { source = "/build/output" ; type = "bind" ; } ;
                                                                                            temporary = { type = "temporary" ; } ;
                                                                                        } ;
                                                                                    name = name ;
                                                                                    post = null ;
                                                                                    runtime-inputs =
                                                                                        pkgs :
                                                                                            [
                                                                                                ( _config.failure { } )
                                                                                                (
                                                                                                    _config.lazy-shell-application
                                                                                                        {
                                                                                                            mounts = { input = { read-only = true ; source = "/mounts/input" ; type = "bind" ; } ; } ;
                                                                                                            name = "readlink-safe" ;
                                                                                                            post = null ;
                                                                                                            runtime-inputs = pkgs : [ pkgs.coreutils ] ;
                                                                                                            text =
                                                                                                                ''
                                                                                                                    if [[ -L /mounts/input ]]
                                                                                                                    then
                                                                                                                        readlink /mounts/input
                                                                                                                    else
                                                                                                                        echo -n ""
                                                                                                                    fi
                                                                                                                '' ;
                                                                                                        }
                                                                                                )
                                                                                                pkgs.coreutils
                                                                                                pkgs.findutils
                                                                                                pkgs.jq
                                                                                            ] ;
                                                                                    text =
                                                                                        ''
                                                                                            find /mounts/input | while read -r INPUT_FILE
                                                                                            do
                                                                                                HASH="$( echo "$INPUT_FILE" | sha512sum | cut --characters 1-128 )" || failure 0195115283959486
                                                                                                PERMISSIONS="$( stat --printf %a "$INPUT_FILE" )" || failure 5743431110033372
                                                                                                TAG="$( echo "$INPUT_FILE" | cut --characters 15- )" || failure 4323730760707892
                                                                                                TARGET="$( readlink-safe "$INPUT_FILE" )" || failure 1577566704508967
                                                                                                TYPE="$( stat --printf %F "$INPUT_FILE" )" || failure 5742797212640718
                                                                                                jq \
                                                                                                    --null-input \
                                                                                                    --arg PERMISSIONS "$PERMISSIONS" \
                                                                                                    --arg TAG "$TAG" \
                                                                                                    --arg TARGET "$TARGET" \
                                                                                                    --arg TYPE "$TYPE" \
                                                                                                    '{
                                                                                                        "permissions" : $PERMISSIONS ,
                                                                                                        "tag" : $TAG ,
                                                                                                        "target" : $TARGET ,
                                                                                                        "type" : $TYPE
                                                                                                    }' >&2
                                                                                                jq \
                                                                                                    --null-input \
                                                                                                    --arg PERMISSIONS "$PERMISSIONS" \
                                                                                                    --arg TAG "$TAG" \
                                                                                                    --arg TARGET "$TARGET" \
                                                                                                    --arg TYPE "$TYPE" \
                                                                                                    '{
                                                                                                        "permissions" : $PERMISSIONS ,
                                                                                                        "tag" : $TAG ,
                                                                                                        "target" : $TARGET ,
                                                                                                        "type" : $TYPE
                                                                                                    }' > "/mounts/temporary/$HASH.json"
                                                                                                if [[ "$TYPE" == "regular file" ]]
                                                                                                then
                                                                                                    mkdir --parents "/mounts/temporary/$HASH"
                                                                                                    cd "/mounts/temporary/$HASH"
                                                                                                    split --bytes ${ bytes } "$INPUT_FILE"
                                                                                                elif [[ "$TYPE" == "directory" ]] || [[ "$TYPE" == "symbolic link" ]]
                                                                                                then
                                                                                                    :
                                                                                                else
                                                                                                    failure 8786988475730505 "$HASH" "$PERMISSIONS" "$TAG" "$TYPE"
                                                                                                fi
                                                                                            done
                                                                                            cp --recursive /mounts/temporary/. /mounts/output
                                                                                        '' ;
                                                                                } ;
                                                                    type = _lib.types.functionTo _lib.types.package ;
                                                                } ;
                                                        implode =
                                                            _lib.mkOption
                                                                {
                                                                    default =
                                                                        {
                                                                            input ,
                                                                            name ,
                                                                            output
                                                                        } :
                                                                            _config.lazy-shell-application
                                                                                {
                                                                                    mounts =
                                                                                        {
                                                                                            input = { read-only = true ; source = input ; type = "bind" ; } ;
                                                                                            output = { source = "/build/observed" ; type = "bind" ; } ;
                                                                                            temporary = { type = "temporary" ; } ;
                                                                                        } ;
                                                                                    name = name ;
                                                                                    post = null ;
                                                                                    runtime-inputs = pkgs : [ ( _config.failure { } ) pkgs.coreutils pkgs.findutils pkgs.jq ] ;
                                                                                    text =
                                                                                        ''
                                                                                            find /mounts/input -mindepth 1 -maxdepth 1 -type f -name "*.json" | sort | while read -r INPUT_FILE
                                                                                            do
                                                                                                PERMISSIONS="$( jq --raw-output ".permissions" "$INPUT_FILE" )" || failure 0537099870175194
                                                                                                TAG="$( jq --raw-output ".tag" "$INPUT_FILE" )" || failure 5311405440579224
                                                                                                TYPE="$( jq --raw-output ".type" "$INPUT_FILE" )" || failure 4647824064526106
                                                                                                OUTPUT_FILE="/mounts/temporary/$TAG"
                                                                                                OUTPUT_DIRECTORY="$( dirname "$OUTPUT_FILE" )" || failure 4175145871150273
                                                                                                mkdir --parents "$OUTPUT_DIRECTORY"
                                                                                                if [[ "$TYPE" == "directory" ]]
                                                                                                then
                                                                                                    mkdir --parents "$OUTPUT_FILE"
                                                                                                elif [[ "$TYPE" == "regular file" ]]
                                                                                                then
                                                                                                    PLUG="{ "$" }{INPUT_FILE%.*}"
                                                                                                    cat "$PLUG/*" > "$OUTPUT_FILE"
                                                                                                elif [[ "$TYPE" == "symbolic link" ]]
                                                                                                then
                                                                                                    TARGET="$( jq --raw-output ".target" "$INPUT_FILE" )" || failure 2203118780634724
                                                                                                    ln --symbolic "$TARGET" "$OUTPUT_FILE"
                                                                                                else
                                                                                                    failure 5539970079890550 "$INPUT_FILE" "$OUTPUT_FILE" "$OUTPUT_DIRECTORY" "$PERMISSIONS" "$TAG" "$TYPE"
                                                                                                fi
                                                                                                chmod "$PERMISSIONS" "$OUTPUT_FILE"
                                                                                            done
                                                                                            cp --recursive /mounts/temporary/. /mounts/output
                                                                                        '' ;
                                                                                } ;
                                                                } ;
                                                    } ;
                                            } ;
                            in
                                {
                                    check =
                                        {
                                            failure ,
                                            lazy-shell-application ,
                                            nixosTest ,
                                            obviated-by ,
                                            visitor
                                        } :
                                            {
                                                bytes ,
                                                expected
                                            } :
                                            {
                                                obviated-by = obviated-by ;
                                                test =
                                                    nixosTest
                                                        {
                                                            name = "tree-serialization" ;
                                                            nodes.client =
                                                                { config , pkgs , ... } :
                                                                    let
                                                                        _config = config-identity config ;
                                                                        _pkgs = pkgs-identity pkgs ;
                                                                        in
                                                                            {
                                                                                environment.systemPackages =
                                                                                    [
                                                                                        (
                                                                                            _pkgs.writeShellApplication
                                                                                                {
                                                                                                    name = "compare" ;
                                                                                                    runtimeInputs = [ _pkgs.coreutils _pkgs.diffutils ] ;
                                                                                                    text =
                                                                                                        ''
                                                                                                            diff --recursive --unified ${ expected } "/build/observed"
                                                                                                        '' ;
                                                                                                }
                                                                                        )
                                                                                        ( _config.tree-serialization.explode { bytes = bytes ; name = "explode" ; input = expected ; output = "/build/output" ; } )
                                                                                        ( _config.tree-serialization.implode { name = "implode" ; input = "/build/output" ; output = "/build/observed" ; } )
                                                                                        (
                                                                                            _pkgs.writeShellApplication
                                                                                                {
                                                                                                    name = "prepare" ;
                                                                                                    runtimeInputs = [ _pkgs.coreutils ] ;
                                                                                                    text =
                                                                                                        ''
                                                                                                            mkdir --parents /build/observed /build/output
                                                                                                        '' ;
                                                                                                }
                                                                                        )
                                                                                    ] ;
                                                                                imports = [ failure implementation lazy-shell-application visitor ] ;
                                                                            } ;
                                                            testScript =
                                                                ''
                                                                    client.wait_for_unit("multi-user.target")
                                                                    client.succeed("prepare")
                                                                    client.succeed("explode")
                                                                    client.succeed("implode")
                                                                    client.succeed("compare")
                                                                '' ;
                                                        } ;
                                                type = "tree-serialization" ;
                                            } ;
                                    implementation = implementation ;
                                } ;
            } ;
}