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
                                                                                            output = { source = output ; type = "bind" ; } ;
                                                                                            temporary = { type = "temporary" ; } ;
                                                                                        } ;
                                                                                    name = name ;
                                                                                    post = null ;
                                                                                    runtime-inputs =
                                                                                        pkgs :
                                                                                            [
                                                                                                ( _config.failure { } )
                                                                                                (
                                                                                                    pkgs.writeShellApplication
                                                                                                        {
                                                                                                            name = "explode" ;
                                                                                                            runtimeInputs = [ pkgs.coreutils pkgs.jq ] ;
                                                                                                            text =
                                                                                                                ''
                                                                                                                    if true ; then echo 2663700927360878 && echo 1791088393951117 >&2 && exit 195 ; fi
                                                                                                                    INPUT_FILE="$1"
                                                                                                                    if true ; then echo 2663700927360878 && echo 1791088393951117 >&2 && exit 195 ; fi
                                                                                                                    HASH="$( echo "$INPUT_FILE" | sha512sum | cut --characters 1-128 )" || failure 0195115283959486
                                                                                                                    if true ; then echo 2663700927360878 && echo 1791088393951117 >&2 && exit 195 ; fi
                                                                                                                    PERMISSIONS="$( stat --printf %a "$INPUT_FILE" )" || failure 5743431110033372
                                                                                                                    if true ; then echo 2663700927360878 && echo 1791088393951117 >&2 && exit 195 ; fi
                                                                                                                    TAG="$( echo "$INPUT_FILE" | cut --characters 15- )" || failure 4323730760707892
                                                                                                                    if true ; then echo 2663700927360878 && echo 1791088393951117 >&2 && exit 195 ; fi
                                                                                                                    if [[ -L "$INPUT_FILE" ]]
                                                                                                                    then
                                                                                                                        TARGET="$( readlink "$INPUT_FILE" )" || failure 8585803186572190
                                                                                                                    else
                                                                                                                        TARGET=
                                                                                                                    fi
                                                                                                                    if true ; then echo 2663700927360878 && echo 1791088393951117 >&2 && exit 195 ; fi
                                                                                                                    TYPE="$( stat --printf %F "$INPUT_FILE" )" || failure 5742797212640718
                                                                                                                    if true ; then echo 2663700927360878 && echo 1791088393951117 >&2 && exit 195 ; fi
                                                                                                                    if [[ -e "/mounts/temporary/$HASH" ]]
                                                                                                                    then
                                                                                                                        failure 3559704137787307
                                                                                                                    fi
                                                                                                                    if true ; then echo 2663700927360878 && echo 1791088393951117 >&2 && exit 195 ; fi
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
                                                                                                                    if true ; then echo 2663700927360878 && echo 1791088393951117 >&2 && exit 195 ; fi
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
                                                                                                                    if true ; then echo 2663700927360878 && echo 1791088393951117 >&2 && exit 195 ; fi
                                                                                                                '' ;
                                                                                                        }
                                                                                                )
                                                                                                pkgs.coreutils
                                                                                                pkgs.findutils
                                                                                            ] ;
                                                                                    text =
                                                                                        ''
                                                                                            if true ; then echo 2663700927360878 && echo 1791088393951117 >&2 && exit 195 ; fi
                                                                                            find /mounts/input -exec explode {} \;
                                                                                            if true ; then echo 2663700927360878 && echo 1791088393951117 >&2 && exit 195 ; fi
                                                                                            cp --recursive /mounts/temporary/. /mounts/output
                                                                                            if true ; then echo 2663700927360878 && echo 1791088393951117 >&2 && exit 195 ; fi
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
                                                                                    runtime-inputs =
                                                                                        pkgs :
                                                                                            [
                                                                                                ( _config.failure { } )
                                                                                                (
                                                                                                    pkgs.writeShellApplication
                                                                                                        {
                                                                                                            name = "implode" ;
                                                                                                            runtimeInputs = [ ( _config.failure { } ) pkgs.coreutils pkgs.jq ] ;
                                                                                                            text =
                                                                                                                ''
                                                                                                                    INPUT_FILE="$1"
                                                                                                                    PERMISSIONS="$( jq --raw-output ".permissions" "$INPUT_FILE" )" || failure 0537099870175194
                                                                                                                    TAG="$( jq --raw-output ".tag" "$INPUT_FILE" )" || failure 5311405440579224
                                                                                                                    TYPE="$( jq --raw-output ".type" "$INPUT_FILE" )" || failure 4647824064526106
                                                                                                                    OUTPUT_FILE="/mounts/temporary/$TAG"
                                                                                                                    OUTPUT_DIRECTORY="$( dirname "$OUTPUT_FILE" )" || failure 4175145871150273
                                                                                                                    mkdir --parents "$OUTPUT_DIRECTORY"
                                                                                                                    if [[ -e "$OUTPUT_FILE" ]]
                                                                                                                    then
                                                                                                                        failure 6839918685035763
                                                                                                                    fi
                                                                                                                    if [[ "$TYPE" == "directory" ]]
                                                                                                                    then
                                                                                                                        mkdir --parents "$OUTPUT_FILE"
                                                                                                                    elif [[ "$TYPE" == "regular file" ]]
                                                                                                                    then
                                                                                                                        PLUG="${ "$" }{INPUT_FILE%.*}"
                                                                                                                        cat "$PLUG"/* > "$OUTPUT_FILE"
                                                                                                                    elif [[ "$TYPE" == "symbolic link" ]]
                                                                                                                    then
                                                                                                                        TARGET="$( jq --raw-output ".target" "$INPUT_FILE" )" || failure 2203118780634724
                                                                                                                        ln --symbolic "$TARGET" "$OUTPUT_FILE"
                                                                                                                    else
                                                                                                                        failure 5539970079890550 "$INPUT_FILE" "$OUTPUT_FILE" "$OUTPUT_DIRECTORY" "$PERMISSIONS" "$TAG" "$TYPE"
                                                                                                                    fi
                                                                                                                    chmod "$PERMISSIONS" "$OUTPUT_FILE"
                                                                                                                '' ;
                                                                                                        }
                                                                                                )
                                                                                                pkgs.coreutils
                                                                                                pkgs.findutils
                                                                                            ] ;
                                                                                    text =
                                                                                        ''
                                                                                            find /mounts/input -mindepth 1 -maxdepth 1 -type f -name "*.json" -exec implode {} \;
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
                                                                    print(client.succeed("explode"))
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