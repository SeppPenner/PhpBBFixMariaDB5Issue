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
	local version="$1"
	if [ -z "$version" ] || [ "$version" -le "$MIGRATE_DB_VERSION" ]; then
		return 0
	fi
	return 1
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
wizard_db_settings="Configurar la base de datos de phpBB"
wizard_db_name_desc="Introduzca el nombre de la base de datos de phpBB."
wizard_db_name_label="Nombre de base de datos"
wizard_m10_desc="Introduzca las credenciales de administrador de MariaDB 10 para continuar con la configuración de la base de datos de phpBB."
wizard_admin_acc="Cuenta"
wizard_admin_pass="Contraseña"
wizard_set_db_desc="Cree una nueva cuenta de base de datos exclusiva para que phpBB use los datos nuevos/existentes."
wizard_set_data_title="Configurar phpBB"
wizard_found_backup="Seleccione un método para importar datos."
wizard_decide_restore="phpBB la base de datos ya existe.<br>Seleccione alguna de las siguientes acciones:"
wizard_restore="Utilizar los datos existentes"
wizard_create_new="Instalación limpia (se eliminarán todos los datos existentes, incluidos los archivos de configuración y la base de datos)."
wizard_db_user_account_desc="Cuenta de usuario de base de datos"
wizard_db_user_password_desc="Contraseña de usuario de base de datos"
wizard_migrate_note="La última versión de phpBB solo es compatible con MariaDB 10.<br>El sistema ha detectado una base de datos MariaDB 5 existente.<br>En el próximo paso, se migrará su base de datos de MariaDB 5 a MariaDB 10.<br><br>Introduzca las credenciales de administrador de MariaDB 5 para continuar con la instalación."
wizard_migrate_title="Migrar base de datos de phpBB"
wizard_remove_msql_title="Eliminar base de datos de phpBB"
wizard_remove_msql_desc="Si se elimina la base de datos de phpBB, se eliminarán todos los datos."
wizard_msql_password_desc_remove="Introduzca las credenciales de administrador de base de datos para eliminar la base de datos de phpBB"
wizard_admin_acc="Cuenta"
wizard_admin_pass="Contraseña"
PageUninst()
{
cat << EOF
{
	"step_title": "$wizard_remove_msql_title",
	"items": [{
		"type": "multiselect",
		"desc": "$wizard_remove_msql_desc",
		"subitems": [{
			"key": "pkgwizard_remove_mysql",
			"desc": "$wizard_remove_msql_title"
		}]
	}, {
		"type": "textfield",
		"desc": "$wizard_msql_password_desc_remove",
		"subitems": [{
			"key": "wizard_m10_acc",
			"desc": "$wizard_admin_acc",
			"defaultValue": "root"
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
main()
{
	local uninst_page="$(PageUninst)"
	echo "[$uninst_page]" > "${SYNOPKG_TEMP_LOGFILE}"

	return 0
}

main "$@"
main()
{
	local uninst_page="$(PageUninst)"
	echo "[$uninst_page]" > "${SYNOPKG_TEMP_LOGFILE}"

	return 0
}

main "$@"
