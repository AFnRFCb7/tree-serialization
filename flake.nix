{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    { input ? null , output ? null } :
                        let
                            implementation =
                                { config , lib , ... } @module :
                                    let
                                        identified =
                                            if builtins.typeOf input == "lambda" then input module
                                            else if builtins.typeOf input == "null" then module
                                            else builtins.throw "0282144462275529" ;
                                        in
                                            with identified ;
                                                {
                                                    options.tree-serialization =
                                                        {
                                                            explode =
                                                                lib.mkOption
                                                                    {
                                                                        default =
                                                                            {
                                                                                bytes ,
                                                                                input ,
                                                                                name ,
                                                                                output
                                                                            } :
                                                                                config.lazy-shell-application
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
                                                                                            { pkgs , ... } :
                                                                                                [
                                                                                                    ( config.failure { } )
                                                                                                    (
                                                                                                        pkgs.writeShellApplication
                                                                                                            {
                                                                                                                name = "explode" ;
                                                                                                                runtimeInputs = [ pkgs.coreutils pkgs.jq ] ;
                                                                                                                text =
                                                                                                                    ''
                                                                                                                        INPUT_FILE="$1"
                                                                                                                        HASH="$( echo "$INPUT_FILE" | sha512sum | cut --characters 1-128 )" || failure 0195115283959486
                                                                                                                        PERMISSIONS="$( stat --printf %a "$INPUT_FILE" )" || failure 5743431110033372
                                                                                                                        TAG="$( echo "$INPUT_FILE" | cut --characters 15- )" || failure 4323730760707892
                                                                                                                        if [[ -L "$INPUT_FILE" ]]
                                                                                                                        then
                                                                                                                            TARGET="$( readlink "$INPUT_FILE" )" || failure 8585803186572190
                                                                                                                        else
                                                                                                                            TARGET=
                                                                                                                        fi
                                                                                                                        TYPE="$( stat --printf %F "$INPUT_FILE" )" || failure 5742797212640718
                                                                                                                        if [[ -e "/mounts/temporary/$HASH" ]]
                                                                                                                        then
                                                                                                                            failure 3559704137787307
                                                                                                                        fi
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
                                                                                                                    '' ;
                                                                                                            }
                                                                                                    )
                                                                                                    pkgs.coreutils
                                                                                                    pkgs.findutils
                                                                                                ] ;
                                                                                        text =
                                                                                            ''
                                                                                                find /mounts/input -exec explode {} \;
                                                                                                cp --recursive /mounts/temporary/. /mounts/output
                                                                                            '' ;
                                                                                        variables = { } ;
                                                                                    } ;
                                                                        type = lib.types.functionTo lib.types.package ;
                                                                    } ;
                                                            implode =
                                                                lib.mkOption
                                                                    {
                                                                        default =
                                                                            {
                                                                                input ,
                                                                                name ,
                                                                                output
                                                                            } :
                                                                                config.lazy-shell-application
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
                                                                                            { pkgs , ... } :
                                                                                                [
                                                                                                    ( config.failure { } )
                                                                                                    (
                                                                                                        pkgs.writeShellApplication
                                                                                                            {
                                                                                                                name = "implode" ;
                                                                                                                runtimeInputs = [ ( config.failure { } ) pkgs.coreutils pkgs.jq ] ;
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
                                                                                        variables = { } ;
                                                                                    } ;
                                                                    } ;
                                                        } ;
                                                } ;
                            in
                                {
                                    check =
                                        {
                                            failure ?
                                                { pkgs , ... } @module :
                                                    let
                                                        identified =
                                                            if builtins.typeOf input == "lambda" then input module
                                                            else if builtins.typeOf input == "null" then module
                                                            else builtins.throw "3089158225937633" ;
                                                        in
                                                            with identified ;
                                                                {
                                                                    options.failure =
                                                                        lib.mkOption
                                                                            {
                                                                                default =
                                                                                    ignore :
                                                                                        pkgs.writeShellApplication
                                                                                            {
                                                                                                name = "failure" ;
                                                                                                runtimeInputs = [ pkgs.coreutils ] ;
                                                                                                text =
                                                                                                    ''
                                                                                                        cat "$@" >&2
                                                                                                        exit 120
                                                                                                    '' ;
                                                                                            } ;
                                                                                type = lib.types.functionTo lib.types.package ;
                                                                            } ;
                                                                } ,
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
                                                                { config , pkgs , ... } @module :
                                                                    let
                                                                        identified =
                                                                            if builtins.typeOf input == "lambda" then input module
                                                                            else if builtins.typeOf input == "null" then module
                                                                            else builtins.throw "3566151178267785" ;
                                                                        in
                                                                            with identified ;
                                                                                {
                                                                                    environment.systemPackages =
                                                                                        [
                                                                                            (
                                                                                                pkgs.writeShellApplication
                                                                                                    {
                                                                                                        name = "compare" ;
                                                                                                        runtimeInputs = [ pkgs.coreutils pkgs.diffutils ] ;
                                                                                                        text =
                                                                                                            ''
                                                                                                                diff --recursive --unified ${ expected } "/build/observed"
                                                                                                            '' ;
                                                                                                    }
                                                                                            )
                                                                                            ( config.tree-serialization.explode { bytes = bytes ; name = "explode" ; input = expected ; output = "/build/output" ; } )
                                                                                            ( config.tree-serialization.implode { name = "implode" ; input = "/build/output" ; output = "/build/observed" ; } )
                                                                                            (
                                                                                                pkgs.writeShellApplication
                                                                                                    {
                                                                                                        name = "prepare" ;
                                                                                                        runtimeInputs = [ pkgs.coreutils ] ;
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
                                    implementation =
                                        if builtins.typeOf output == "lambda" then output implementation
                                        else if builtins.typeOf output == "null" then implementation
                                        else builtins.throw "8011313636355332" ;
                                } ;
            } ;
}