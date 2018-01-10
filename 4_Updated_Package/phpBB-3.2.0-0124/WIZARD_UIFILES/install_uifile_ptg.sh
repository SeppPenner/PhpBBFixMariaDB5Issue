#!/bin/bash

# define main function
MAIN_INSTALL="main_install"
MAIN_UPGRADE="main_upgrade"
MAIN_UNINST="main_uninst"
# define each page's name
PAGE_MARIADB5="page_mariadb5"
PAGE_MARIADB10="page_mariadb10"
PAGE_RESTORE="page_restore"
PAGE_DB="page_db"
PAGE_UNINST="page_uninst"
DEFAULT="enu"
# set out file name
OUTPUT_INSTALL="install_uifile"
OUTPUT_UPGRADE="upgrade_uifile"
OUTPUT_UNINST="uninstall_uifile"
INIT_DB_NAME="" # need to be overwrited
INIT_DB_USER="" # need to be overwrited
INFO_FILE="" # need to be overwrited
BACKUP_PATH="" # need to be overwrited
# here to define what page is necessary for each stage: install, upgrade, and uninstall
PAGE_INST="$PAGE_MARIADB5 $PAGE_RESTORE $PAGE_MARIADB10 $PAGE_DB $MAIN_INSTALL"
PAGE_UPGRADE="$PAGE_MARIADB5 $PAGE_MARIADB10 $PAGE_DB $MAIN_UPGRADE"
PAGE_UNINST="$PAGE_UNINST $MAIN_UNINST"
MIGRATE_DB_VERSION="-1"

MainCreate()
{
	local output="$1"
	local pages="$2"
	local main_function="$3"
	local lan
	for dir in lang/*; do
		lan=$(basename "$dir")
		cat "wizard_common" "wizard_customized" > "${output}_${lan}.sh"
		CustomWizCreate "${output}_${lan}.sh"
		cat "lang/$lan" $pages "$main_function" >> "${output}_${lan}.sh"
	done
	chmod +x "${output}"*.sh
	cp -a "${output}_${DEFAULT}.sh" "${output}.sh"
}

NeedMigrateDB()
{
	return 0
}

CustomHasRunWebsiteSetup()
{
	local path="$1"
	[ -s "$path/$CONF_FILE" ]
}

CustomWizCreate()
{
	:
}

CustomSetBackupPath()
{
	BACKUP_PATH="$(CustomGetBackupPkgPath)"
}

CustomMainInstall()
{
	:
}

CustomGetValueFromMetaFile()
{
	local key="$1"
	local backup_info="/var/packages/.$PKG_DIR.conf"
	local syno_conf="/var/packages/$PKG_NAME/synology.conf"
	local record_file=""

	if [ -s "$INFO_FILE" ]; then
		record_file="$INFO_FILE"
	elif [ -s "$backup_info" ]; then
		record_file="$backup_info"
	elif [ -s "$syno_conf" ]; then
		record_file="$syno_conf"
	fi
	get_key_value "$record_file" "$key"
}

CustomGetBackupPrefix()
{
	local backup_prefix="/$(readlink /var/services/web | cut -d/ -f2)/@appstore/.$PKG_DIR"
	echo "$backup_prefix"
}

CustomGetBackupPkgPath()
{
	local backup_pkg_path="$(CustomGetBackupPrefix)/$PKG_DIR"
	echo "$backup_pkg_path"
}

# we define pages in fuction not in global variables,
# because functions in wizard steps will be merged after calling MainCreate.
CustomSetPages()
{
	NEW_INSTALL_PAGES="$(PageM10),$(PageDB)"
	RESTORE_PAGES="$(PageRestore),$(PageM10),$(PageDB)"
	MIGRATE_PAGES="$(PageM5),$(PageRestore),$(PageM10),$(PageDB)"
}

CustomParseDBConf()
{
	:
}

CustomGetDBName()
{
	:
}

CustomGetDBUser()
{
	:
}

CustomGetDBPass()
{
	:
}

CustomPageActivate()
{
	:
}
#!/bin/bash
# Copyright (c) 2000-2017 Synology Inc. All rights reserved.

PKG_NAME="phpBB"
PKG_DIR="phpbb"
WEBSITE_ROOT="/var/services/web/$PKG_DIR"
CONF_FILE="config.php"
MIGRATE_DB_VERSION="0119"
INIT_DB_NAME="phpbb"
INIT_DB_USER="phpbb_user"
INFO_FILE="/usr/syno/etc/packages/$PKG_NAME/$PKG_DIR.conf"

CustomGetBackupPkgPath()
{
	# old ver: backup data is in .phpbb
	# new ver: backup data is in .phpbb/phpbb
	local backup_pkg_path="$(CustomGetBackupPrefix)/$PKG_DIR"
	local old_bkp_path="$(CustomGetBackupPrefix)"
	if [ ! -d "$backup_pkg_path" ] && [ -s "$old_bkp_path/$CONF_FILE" ]; then
		backup_pkg_path="$old_bkp_path"
	fi
	echo "$backup_pkg_path"
}

CustomParseDBConf()
{
	local path="$1"
	local db_info="$2"
	local grep_info="$3"
	local info_output=$(CustomGetValueFromMetaFile "$db_info")

	if [ -z "$info_output" ] && [ -s "$path/$CONF_FILE" ]; then
		info_output=$(php -r "include('$path/$CONF_FILE'); echo \$$grep_info;")
	fi

	echo "$info_output"
}

CustomGetDBName()
{
	CustomParseDBConf "$1" "db_name" "dbname"
}

CustomGetDBUser()
{
	CustomParseDBConf "$1" "db_user" "dbuser"
}

CustomGetDBPass()
{
	CustomParseDBConf "$1" "db_pass" "dbpasswd"
}
wizard_db_settings="Configurar base de dados do phpBB"
wizard_db_name_desc="Introduza o nome da base de dados para phpBB."
wizard_db_name_label="Nome da base de dados"
wizard_m10_desc="Introduza as credenciais do administrador de MariaDB 10 para continuar as definições da base de dados do phpBB."
wizard_admin_acc="Conta"
wizard_admin_pass="Palavra-passe"
wizard_set_db_desc="Crie uma nova conta de base de dados exclusiva para o phpBB para utilizar os dados existentes/novos."
wizard_set_data_title="Configurar phpBB"
wizard_found_backup="Selecione um método para importar dados."
wizard_decide_restore="phpBB a base de dados já existe.<br>Selecione uma das seguintes ações:"
wizard_restore="Utilizar os dados existentes"
wizard_create_new="Limpar a instalação (todos os dados existentes, incluindo os ficheiros de configuração e a base de dados, serão removidos.)"
wizard_db_user_account_desc="Conta de utilizador de base de dados "
wizard_db_user_password_desc="Palavra-passe do utilizador de base de dados"
wizard_migrate_note="A versão mais recente do phpBB só suporta MariaDB 10.<br>O sistema detetou uma base de dados MariaDB 5 existente.<br>No passo seguinte, a sua base de dados será migrada de MariaDB 5 para MariaDB 10.<br><br>Introduza as credenciais do administrador de MariaDB 5 para continuar com a instalação."
wizard_migrate_title="Migrar a base de dados da phpBB"
wizard_remove_msql_title="Remover base de dados phpBB"
wizard_remove_msql_desc="Se a base de dados do phpBB for removida, todos os dados serão eliminados."
wizard_msql_password_desc_remove="Introduza as credenciais de administrador de base de dados de forma a remover a base de dados phpBB."
wizard_admin_acc="Conta"
wizard_admin_pass="Palavra-passe"
PageM5()
{
cat << EOF
{
	"step_title": "$wizard_migrate_title",
	"items": [{
		"type": "textfield",
		"desc": "$wizard_migrate_note",
		"subitems": [{
			"key": "wizard_m5_acc",
			"desc": "$wizard_admin_acc",
			"defaultValue": "root",
			"validator": {
				"allowBlank": false
			}
		}]
	}, {
		"type": "password",
		"subitems": [{
			"indent": 1,
			"key": "wizard_m5_pass",
			"desc": "$wizard_admin_pass"
		}]
	}]
}
EOF
}

PageRestore()
{
cat << EOF
{
	"step_title": "$wizard_found_backup",
	"items": [{
		"type": "singleselect",
		"desc": "$wizard_decide_restore",
		"subitems": [{
			"key": "restore_backup",
			"desc": "$wizard_restore",
			"defaultValue": true
		}, {
			"desc": "$wizard_create_new",
			"defaultValue": false
		}]
	}]
}
EOF
}

PageM10()
{
cat << EOF
{
	"step_title": "$wizard_set_data_title",
	"items": [{
		"type": "textfield",
		"desc": "$wizard_m10_desc",
		"subitems": [{
			"key": "wizard_m10_acc",
			"desc": "$wizard_admin_acc",
			"defaultValue": "root",
			"validator": {
				"allowBlank": false
			}
		}]
	}, {
		"type": "password",
		"subitems": [{
			"indent": 1,
			"key": "wizard_m10_pass",
			"desc": "$wizard_admin_pass"
		}]
	}]
}
EOF
}
CheckRestore()
{
cat << EOF
// find constructor contains restore page
for (i = arguments[0].ownerCt.items.length-1; i >= 1; i--){
	page = arguments[0].ownerCt.items.items[i];
	if (page.headline == \"${wizard_found_backup}\"){
		// check whether user wants to restore or not
		restore = page.items.items[1].checked;
		break;
	}
}
EOF
}

FindObj()
{
cat << EOF
for (i = 0; i < arguments[0].items.length; i++) {
	item = arguments[0].items.items[i]
	if (\"${1}\" == item.itemId){
		$2 = arguments[0].items.items[i];
		break;
	}
}
EOF
}

Activate()
{
cat << EOF
	"activeate": "{
		restore = $DEFAULT_RESTORE; // user restore or not, set by is_restore
		// will set restore
		$(CheckRestore)

		$(CustomPageActivate)

		if (arguments[0].headline == \"${wizard_db_settings}\") {
			create_db_multiselect = null;
			need_migrate_multiselect = null;
			old_db_textfield= null;
			drop_db_multiselect= null;
			new_db_textfield = null;
			db_user_textfield = null;
			grant_user_multiselect = null;
			mariadb_ver_textfield = null;

			$(FindObj "create_db_flag" "create_db_multiselect")
			$(FindObj "need_migrate" "need_migrate_multiselect")
			$(FindObj "pkgwizard_db_name" "new_db_textfield")
			$(FindObj "old_db_name" "old_db_textfield")
			$(FindObj "drop_db_flag" "drop_db_multiselect")
			$(FindObj "pkgwizard_db_user_account" "db_user_textfield")
			$(FindObj "grant_user_flag" "grant_user_multiselect")
			$(FindObj "mariadb_ver" "mariadb_ver_textfield")

			old_db = \"@OLD_DB@\";

			if (restore) {
				db_name = \"@OLD_DB@\";
				db_user = \"@OLD_USER@\";
			}
			else {
				db_name = \"$INIT_DB_NAME\";
				db_user = \"$INIT_DB_USER\";
			}

			old_db_textfield.setValue(old_db);
			new_db_textfield.setValue(db_name);
			new_db_textfield.setDisabled(restore);
			db_user_textfield.setValue(db_user);
			mariadb_ver_textfield.setValue(\"$MARIADB_VER\");

			need_migrate_multiselect.setVisible(false);
			create_db_multiselect.setVisible(false);
			drop_db_multiselect.setVisible(false);
			grant_user_multiselect.setVisible(false);

		}

	}",
EOF
}

Deactivate()
{
cat << EOF
	"deactivate": "{
		restore = $DEFAULT_RESTORE;
		$(CheckRestore) // if no radio button, will not set restore value
		if (arguments[0].headline == \"${wizard_db_settings}\") {
			create_db_multiselect = null;
			need_migrate_multiselect = null;
			create_db_collision_textfield = null;
			old_db_textfield= null;
			drop_db_multiselect= null;
			new_db_textfield = null;
			grant_user_multiselect = null;

			$(FindObj "create_db_flag" "create_db_multiselect")
			$(FindObj "need_migrate" "need_migrate_multiselect")
			$(FindObj "create_db_collision" "create_db_collision_textfield")
			$(FindObj "old_db_name" "old_db_textfield")
			$(FindObj "drop_db_flag" "drop_db_multiselect")
			$(FindObj "pkgwizard_db_name" "new_db_textfield")
			$(FindObj "grant_user_flag" "grant_user_multiselect")

			table = {
				\"5to10\": {\"migrate\": true, \"create\": false, \"grant_user\": true, \"drop_db\": true, \"create_db_collision\": \"error\"},
				\"new5to10\": {\"migrate\": false, \"create\": true, \"grant_user\": true, \"drop_db\": true, \"create_db_collision\": \"error\"},
				\"restore10\": {\"migrate\": false, \"create\": true, \"grant_user\": true, \"drop_db\": false, \"create_db_collision\": \"skip\"},
				\"new10\": {\"migrate\": false, \"create\": true, \"grant_user\": true, \"drop_db\": old_db_textfield.rawValue && (old_db_textfield.rawValue !== new_db_textfield.rawValue)? true : false, \"create_db_collision\": old_db_textfield.rawValue === new_db_textfield.rawValue? \"replace\" : \"error\"}
			};

			if (restore) {
				if ($NEED_MIGRATE) {
					state = \"5to10\";
				}
				else {
					state = \"restore10\";
				}
			}
			else {
				if ($NEED_MIGRATE) {
					state = \"new5to10\";
				}
				else {
					state = \"new10\";
				}
			}

			need_migrate_multiselect.setValue(table[state][\"migrate\"]);
			create_db_multiselect.setValue(table[state][\"create\"]);
			grant_user_multiselect.setValue(table[state][\"grant_user\"]);
			drop_db_multiselect.setValue(table[state][\"drop_db\"]);
			create_db_collision_textfield.setValue(table[state][\"create_db_collision\"]);
		}
}",
EOF
}

ApplyDBInfo()
{
	local page_db="$1"

	sed "s/@OLD_DB@/$DB_NAME/g;s/@OLD_USER@/$DB_USER/g" <<< "$page_db"
}

PageDB()
{
	local page_db=$(cat << EOF
{
	"step_title": "$wizard_db_settings",
	$(Activate)
	$(Deactivate)
	"items": [{
		"type": "textfield",
		"desc": "$wizard_set_db_desc",
		"subitems": [{
			"key": "pkgwizard_db_name",
			"desc": "$wizard_db_name_label",
			"disabled": true,
			"validator": {
				"allowBlank": false
			}
		}]
	}, {
		"type": "textfield",
		"subitems": [{
			"indent": 1,
			"key": "pkgwizard_db_user_account",
			"desc": "$wizard_db_user_account_desc",
			"validator": {
				"allowBlank": false
			}
		}]
	}, {
		"type": "password",
		"subitems": [{
			"indent": 1,
			"key": "pkgwizard_db_user_password",
			"desc": "$wizard_db_user_password_desc"
		}]
	}, {
		"type": "textfield",
		"subitems": [{
			"key": "create_db_collision",
			"desc": "drop or skip",
			"defaultValue": "skip",
			"hidden": true
		}]
	}, {
		"type": "multiselect",
		"subitems": [{
			"key": "need_migrate",
			"desc": "migrate or not",
			"hidden": true
		}]
	}, {
		"type": "multiselect",
		"subitems": [{
			"key": "create_db_flag",
			"desc": "create db or not",
			"hidden": true
		}]
	}, {
		"type": "textfield",
		"subitems": [{
			"key": "old_db_name",
			"desc": "old db name",
			"hidden": true
		}]
	}, {
		"type": "multiselect",
		"subitems": [{
			"key": "drop_db_flag",
			"desc": "drop old db or not",
			"hidden": true
		}]
	}, {
		"type": "multiselect",
		"subitems": [{
			"key": "grant_user_flag",
			"desc": "must grant user if exist wizard",
			"defaultVaule": true,
			"hidden": true
		}]
	}, {
		"type": "textfield",
		"subitems": [{
			"key": "mariadb_ver",
			"desc": "mariadb version",
			"defaultVaule": "$MARIADB_VER",
			"hidden": true
		}]
	}]
}
EOF
)
	ApplyDBInfo "$page_db"
}
main()
{
	local install_page=""

	CustomSetPages # set: MIGRATE_PAGES RESTORE_PAGES NEW_INSTALL_PAGES
	CustomSetBackupPath # set BACKUP_PATH
	CustomMainInstall

	DEFAULT_RESTORE=false
	NEED_MIGRATE=false
	MARIADB_VER="m10"
	DB_NAME=$(CustomGetDBName "$BACKUP_PATH")
	DB_USER=$(CustomGetDBUser "$BACKUP_PATH")

	if CustomHasRunWebsiteSetup "$BACKUP_PATH"; then
		local version="$(CustomGetValueFromMetaFile "version" | cut -d- -f2)"
		if NeedMigrateDB "$version"; then # check if needing to migrate MariaDB 5
			NEED_MIGRATE=true
			MARIADB_VER="m5"
			install_page="$MIGRATE_PAGES"
		else
			install_page="$RESTORE_PAGES"
		fi
	else
		install_page="$NEW_INSTALL_PAGES"
	fi

	echo "[$install_page]" > "${SYNOPKG_TEMP_LOGFILE}"

	return 0
}

main "$@"
main()
{
	local install_page=""

	CustomSetPages # set: MIGRATE_PAGES RESTORE_PAGES NEW_INSTALL_PAGES
	CustomSetBackupPath # set BACKUP_PATH
	CustomMainInstall

	DEFAULT_RESTORE=false
	NEED_MIGRATE=false
	MARIADB_VER="m10"
	DB_NAME=$(CustomGetDBName "$BACKUP_PATH")
	DB_USER=$(CustomGetDBUser "$BACKUP_PATH")

	if CustomHasRunWebsiteSetup "$BACKUP_PATH"; then
		local version="$(CustomGetValueFromMetaFile "version" | cut -d- -f2)"
		if NeedMigrateDB "$version"; then # check if needing to migrate MariaDB 5
			NEED_MIGRATE=true
			MARIADB_VER="m5"
			install_page="$MIGRATE_PAGES"
		else
			install_page="$RESTORE_PAGES"
		fi
	else
		install_page="$NEW_INSTALL_PAGES"
	fi

	echo "[$install_page]" > "${SYNOPKG_TEMP_LOGFILE}"

	return 0
}

main "$@"
