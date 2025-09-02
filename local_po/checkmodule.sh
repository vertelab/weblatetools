LOG_LEVEL="warn"   # default log level
WITH_DEMO=true        # default installera med demo-data
EXPORT_PO=false       # default: ingen po-export
LANG_CODE="sv"        # default språk
TEST=""
DROP_DB=false
MULTI_USER=""

ask_yes_no() {
    local prompt="$1"
    local answer
    while true; do
        read -p "$prompt (yes/no): " answer
        case "$answer" in
            yes|YES|y|Y)
                return 0  # success, yes
                ;;
            no|NO|n|N)
                return 1  # failure, no
                ;;
            *)
                echo "Invalid response. Please answer yes or no."
                ;;
        esac
    done
}

usage() {
    echo "Usage: checkmodule [-d <database>] [-m <module>,<module>] [-l <log_level>(debug|debug_rpc|debug_sql|debug_rpc_answer|info|warn|test|error|critical|notset)] [-D] [-e] [-L <lang_code>] [-t] [--drop] [--multi-user]" 1>&2
    echo "   -d           Database, new database is createdInstall without demo-data"
    echo "   -D           No demo-data"
    echo "   -m           Module list (comma separated)"
    echo "   -e           Export PO file(s) after installation"
    echo "   -L           Language code for PO export (default: sv)"
    echo "   -t           Perform tests"
    echo "   --drop       Drop database after completion"
    echo "   --multi-user Multi-user mode, runs odoo on port 4444 in parallel"
    exit 1
}

OPTIONS=$(getopt -o d:m:l:DeL:t -l drop,multi-user -- "$@")
if [ $? -ne 0 ]; then
    usage
fi

eval set -- "$OPTIONS"

while true; do
    case "$1" in
        -d) ODOODB="$2"; shift 2 ;;
        -m) ODOOMODULES="$2"; shift 2 ;;
        -l)
            LOG_LEVEL="$2"
            if [[ ! "$LOG_LEVEL" =~ ^(debug|debug_rpc|debug_sql|debug_rpc_answer|info|warn|test|error|critical|notset)$ ]]; then
                echo "Invalid log level: $LOG_LEVEL"
                usage
            fi
            shift 2
            ;;
        -D) WITH_DEMO=false; shift ;;
        -e) EXPORT_PO=true; shift ;;
        -L) LANG_CODE="$2"; shift 2 ;;
        -t) TEST="--test-enable"; shift ;;
        --drop) DROP_DB=true; shift ;;
        --multi-user) MULTI_USER="-p 4444"; shift ;;
        --) shift; break ;;
        *) echo "Invalid option: $1"; usage ;;
    esac
done

if [ -z "$ODOOMODULES" ] || [ -z "$ODOODB" ]; then
    usage
    echo "Both -d (database) and -m (modules) options are required, new database is created" >&2
fi

# Installera moduler
echo "Creating Odoo ${ODOODB} for Odoo ${ODOOMODULES} with log level ${LOG_LEVEL}"
[ "$WITH_DEMO" = false ] && DEMO_OPTION="--without-demo=all" || DEMO_OPTION=""

if [ -z "$MULTI_USER" ]; then
    sudo service odoo stop
fi

sudo su odoo -c "odoo --config ${ODOO_SERVER_CONF} --database ${ODOODB} --init ${ODOOMODULES} ${MULTI_USER} ${TEST} --limit-time-cpu=180 --limit-time-real=300 --stop-after-init --log-level=${LOG_LEVEL} ${DEMO_OPTION}"

# Exportera PO-filer om flaggan är satt
if [ "$EXPORT_PO" = true ]; then
    echo "Exporting PO file(s) for language: $LANG_CODE"
    IFS=',' read -ra MODULE_LIST <<< "$ODOOMODULES"
    for module in "${MODULE_LIST[@]}"; do
        PO_FILE="${module}-${LANG_CODE}.po"
        echo "Exporting: $PO_FILE"
        sudo su odoo -c "odoo --config ${ODOO_SERVER_CONF} --database ${ODOODB} --modules ${module} --i18n-export=/tmp/$$.po --lang=${LANG_CODE}"
        sudo mv /tmp/$$.po ${PO_FILE}
    done
fi

if [ "$DROP_DB" = true ]; then
    if [ -n "$MULTI_USER" ] && ask_yes_no "In order to drop the database odoo needs to be turn off. Do you want to turn off odoo?"; then
        sudo service odoo stop
        MULTI_USER=""
    fi
    sudo -u postgres dropdb $ODOODB
fi

if [ -z "$MULTI_USER" ]; then
    sudo service odoo start
fi



