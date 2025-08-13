


 
odoo --config ${ODOO_SERVER_CONF} --database ${ODOOREPO} --init ${ODOOMODULES} --stop-after-init

"odoo -c /etc/odoo/odoo.conf --modules='${MODULES}' -d ${DATABASES} ${LCMD} --stop-after-init --i18n-export='${FILE}'"
