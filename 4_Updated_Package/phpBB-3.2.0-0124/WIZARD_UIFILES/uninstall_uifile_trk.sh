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
wizard_db_settings="phpBB Veritabanını Kur"
wizard_db_name_desc="Lütfen phpBB veritabanı için veritabanı adını girin. "
wizard_db_name_label="Veritabanı adı"
wizard_m10_desc="Lütfen MariaDB 10'un yönetici bilgilerini girerek phpBB veritabanı ayarlarına geçin."
wizard_admin_acc="Hesap"
wizard_admin_pass="Parola"
wizard_set_db_desc="Mevcut/yeni verileri kullanmak üzere phpBB için yeni bir özel veritabanı hesabı oluşturun."
wizard_set_data_title="phpBB kur"
wizard_found_backup="Lütfen verileri içeri aktarmak için bir yöntem seçin."
wizard_decide_restore="phpBB veritabanı zaten mevcut.<br>Lütfen aşağıdaki eylemlerden birisini seçin:"
wizard_restore="Mevcut verileri kullan"
wizard_create_new="Kurulumu kaldır (Tüm mevcut veriler, yapılandırma dosyaları ve veritabanı dahil, kaldırılacaktır.)"
wizard_db_user_account_desc="Veritabanı kullanıcı hesabı"
wizard_db_user_password_desc="Veritabanı kullanıcı parolası"
wizard_migrate_note="phpBB son sürümü sadece MariaDB 10 destekler.<br>Sistem mevcut bir MariaDB 5 veritabanını algıladı.<br>Sonraki adımda, veritabanınız MariaDB 5'den MariaDB 10'a taşınacaktır.<br><br>Lütfen kuruluma geçmek için MariaDB 5 yönetici bilgilerini girin."
wizard_migrate_title="phpBB Veritabanını Taşı"
wizard_remove_msql_title="phpBB veritabanını kaldır"
wizard_remove_msql_desc="phpBB veritabanı kaldırılırsa, tüm veriler silinecektir."
wizard_msql_password_desc_remove="phpBB veritabanını kaldırmak için lütfen veritabanı yöneticisinin bilgilerini girin."
wizard_admin_acc="Hesap"
wizard_admin_pass="Parola"
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
