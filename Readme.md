# PhpBBFixMariaDB5Issue

[![Build status](https://ci.appveyor.com/api/projects/status/2eyyigxnfl79ur0t?svg=true)](https://ci.appveyor.com/project/SeppPenner/phpbbfixmariadb5issue)
[![GitHub issues](https://img.shields.io/github/issues/SeppPenner/PhpBBFixMariaDB5Issue.svg)](https://github.com/SeppPenner/PhpBBFixMariaDB5Issue/issues)
[![GitHub forks](https://img.shields.io/github/forks/SeppPenner/PhpBBFixMariaDB5Issue.svg)](https://github.com/SeppPenner/PhpBBFixMariaDB5Issue/network)
[![GitHub stars](https://img.shields.io/github/stars/SeppPenner/PhpBBFixMariaDB5Issue.svg)](https://github.com/SeppPenner/PhpBBFixMariaDB5Issue/stargazers)
[![GitHub license](https://img.shields.io/badge/license-AGPL-blue.svg)](https://raw.githubusercontent.com/SeppPenner/PhpBBFixMariaDB5Issue/master/License.txt)

PhpBBFixMariaDB5Issue is the standard Synology phpBB package from https://archive.synology.com/download/Package/spk/phpBB/ but modified to not check for an existing MariaDB5 database.

## Why?
The reason/ issue for this is described here: https://www.phpbb.com/community/viewtopic.php?f=556&t=2441286&p=14902771
Mainly, it's because phpBB finds an already deinstalled MariaDB5 version and wants to upgrade it.

## How?
1. I downloaded the package from https://archive.synology.com/download/Package/spk/phpBB/3.2.0-0124/
2. I renamed the package from phpBB-3.2.0-0124.spk to phpBB-3.2.0-0124.tar
3. I unzipped the package to a folder
4. I adjusted the following lines:

```bash
NeedMigrateDB()
{
	local version="$1"
	if [ -z "$version" ] || [ "$version" -le "$MIGRATE_DB_VERSION" ]; then
		return 0
	fi
	return 1
}
```

to 

```bash
NeedMigrateDB()
{
	return 0
}
```

5. I ran 
```bash
tar -cvf phpBB-3.2.0-0124.spk *
```
to build the new spk file with packing all the stuff together.

6. It doesn't work...
7. Stackoverflow.com issue: https://stackoverflow.com/questions/48195610/phpbb-fails-after-upgrade-from-mariadb5-to-mariadb10-custom-synology-package --> Help appreciated :)

Change history
--------------
* **Version 1.0.0.0 (2018-01-10)** : 1.0 release.
