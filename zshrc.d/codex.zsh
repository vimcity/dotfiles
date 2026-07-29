# Codex cloud/local launch wrappers (co / col)

_codex_launch() {
    local mode="$1"
    shift
    local -a args=()
    local -a default_args=()
    local parsing_mcps=1
    local token

    case "$mode" in
        cloud) ;;
        local) default_args+=(--profile local) ;;
        *)
            print "unknown codex launcher mode: $mode" >&2
            return 2
            ;;
    esac

    while (( $# )); do
        token=$1
        shift
        case $token in
            -h|--help)
                if [[ "$mode" == local ]]; then
                    command cat <<'EOF'
usage: col [mcp|keyword...] [codex flags/options] [-- prompt...]
 col                              local Codex (oMLX profile)
 col resume --last                resume last local session
 col github jira                  enable named MCPs for this session
 col github resume --last         resume last chat with github MCP
 col playwright                   enable Playwright MCP for this session
 col browser devtools             enable browser plugins/devtools MCP
 col -- -m model "prompt"         pass normal Codex flags/prompt
Keywords: browser, devtools, outlook
MCP names: playwright, github, jira, confluence, slack, context7, datadog,
     service-now, chrome-devtools
EOF
                else
                    command cat <<'EOF'
usage: co [mcp|keyword...] [codex flags/options] [-- prompt...]
 co                               plain Codex cloud session
 co resume --last                 resume last cloud session
 co github jira confluence        enable work MCPs for this session
 co slack                         slack MCP
 co slack resume --last           resume last chat with slack MCP
 co outlook                       outlook-email plugin
 co playwright resume --last      resume last chat with Playwright MCP loaded
 co browser devtools github       combine keywords and MCPs
 co -- -m gpt-5.5 "prompt"        pass normal Codex flags/prompt
Keywords: browser, devtools, outlook
MCP names: playwright, github, jira, confluence, slack, context7, datadog,
     service-now, chrome-devtools
EOF
                fi
                return 0
                ;;
            --)
                parsing_mcps=0
                args+=("$token" "$@")
                break
                ;;
            -*)
                parsing_mcps=0
                args+=("$token")
                ;;
            browser)
                if (( parsing_mcps )); then
                    args+=(
                        -c 'plugins."browser@openai-bundled".enabled=true'
                        -c 'plugins."chrome@openai-bundled".enabled=true'
                        -c 'plugins."computer-use@openai-bundled".enabled=true'
                        -c 'mcp_servers.node_repl.enabled=true'
                    )
                else
                    args+=("$token")
                fi
                ;;
            devtools)
                if (( parsing_mcps )); then
                    args+=(-c 'mcp_servers."chrome-devtools".enabled=true')
                else
                    args+=("$token")
                fi
                ;;
            outlook)
                if (( parsing_mcps )); then
                    args+=(-c 'plugins."outlook-email@openai-curated".enabled=true')
                else
                    args+=("$token")
                fi
                ;;
            slack)
                if (( parsing_mcps )); then
                    args+=(-c 'mcp_servers.slack.enabled=true')
                else
                    args+=("$token")
                fi
                ;;
            slack-mcp)
                print "MCP is named 'slack' now; use: co slack" >&2
                return 2
                ;;
            resume|fork|exec|review|mcp|plugin|login|logout|doctor|app|cloud|archive|delete|unarchive|completion|update|debug|features|sandbox|apply|remote-control|app-server|mcp-server|exec-server|help)
                parsing_mcps=0
                args+=("$token" "$@")
                break
                ;;
            *)
                if (( parsing_mcps )); then
                    args+=(-c "mcp_servers.${token}.enabled=true")
                else
                    args+=("$token")
                fi
                ;;
        esac
    done

    if ((${#default_args[@]})); then
        args=("${default_args[@]}" "${args[@]}")
    fi
    codex "${args[@]}"
}

co() { _codex_launch cloud "$@"; }
col() { _codex_launch local "$@"; }
