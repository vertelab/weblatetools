LOG_LEVEL="warning"   # default log level
WITH_DEMO=true        # default installera med demo-data
EXPORT_PO=false       # default: ingen po-export
LANG_CODE="sv"        # default språk
TEST=""

usage() { 
    echo "Usage: checkmodule [-d <database>] [-m <module>,<module>] [-l <log_level>(debug|debug_rpc|debug_sql|debug_rpc_answer|info|warn|test|error|critical|notset)] [-D] [-e] [-L <lang_code>] [-t]" 1>&2
    echo "   -d   Database, new database is createdInstall without demo-data"
    echo "   -D   Install without demo-data"
    echo "   -e   Export PO file(s) after installation"
    echo "   -L   Language code for PO export (default: sv)"
    echo "   -t   Performe tests"
    exit 1
}

while getopts "d:m:l:DeL:t" option; do
    case $option in
        d) ODOODB=${OPTARG} ;;
        m) ODOOMODULES=${OPTARG} ;;
        l)
            LOG_LEVEL=${OPTARG}
            if [[ ! "$LOG_LEVEL" =~ ^(debug|debug_rpc|debug_sql|debug_rpc_answer|info|warn|test|error|critical|notset)$ ]]; then
                echo "Invalid log level: $LOG_LEVEL"
                usage
            fi
            ;;
        D) WITH_DEMO=false ;;
        e) EXPORT_PO=true ;;        
        t) TEST="--test-enable" ;;
        L) LANG_CODE=${OPTARG} ;;
        :) echo "Option -$OPTARG requires an argument" >&2; usage ;;
        \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
    esac
done

if [ -z "$ODOOMODULES" ] || [ -z "$ODOODB" ]; then
    usage
    echo "Both -d (database) and -m (modules) options are required, new database is created" >&2
fi

# Installera moduler
echo "Creating Odoo ${ODOODB} for Odoo ${ODOOMODULES} with log level ${LOG_LEVEL}"
[ "$WITH_DEMO" = false ] && DEMO_OPTION="--without-demo=all" || DEMO_OPTION=""
sudo service odoo stop
sudo su odoo -c "odoo --config ${ODOO_SERVER_CONF} --database ${ODOODB} --init ${ODOOMODULES} ${TEST} --limit-time-cpu=180 --limit-time-real=300 --stop-after-init --log-level=${LOG_LEVEL} ${DEMO_OPTION}"

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
sudo service odoo start
