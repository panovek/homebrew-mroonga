# The Homebrew formula for Mroonga

Type the following command to install Mroonga by Homebrew:

With MySQL 8.0:

    % brew tap panovek/homebrew-mroonga https://github.com/panovek/homebrew-mroonga.git
    % brew install mroonga --with-homebrew-mysql

With MySQL 5.7:

    % brew tap panovek/homebrew-mroonga https://github.com/panovek/homebrew-mroonga.git
    % brew install mroonga --with-homebrew-mysql57

With MySQL 5.6:

    % brew tap panovek/homebrew-mroonga https://github.com/panovek/homebrew-mroonga.git
    % brew install mroonga --with-homebrew-mysql56

With MySQL 5.5:

    % brew tap panovek/homebrew-mroonga https://github.com/panovek/homebrew-mroonga.git
    % brew install mroonga --with-homebrew-mysql55

With MariaDB:

    % brew tap panovek/homebrew-mroonga https://github.com/panovek/homebrew-mroonga.git
    % brew install mroonga --with-homebrew-mariadb

If you have an old formulae, please unlink to the old formulae version:

    % brew services stop [formulae]
    % brew unlink [formulae]
    % mv /usr/local/var/[formulae] /usr/local/var/[formulae_version]

If you want to use this formula with MySQL built by yourself instead of MySQL installed by Homebrew:

    % curl -O http://ftp.jaist.ac.jp/pub/mysql/Downloads/MySQL-5.5/mysql-5.5.24.tar.gz
    % tar xvzf mysql-5.5.24.tar.gz
    % cd mysql-5.5.24
    % curl http://bazaar.launchpad.net/~mysql/mysql-server/5.5/diff/3806 | patch -p0
    % cmake -DCMAKE_INSTALL_PREFIX=$HOME/local/mysql-5.5.24
    % make -j$(/usr/sbin/sysctl -n hw.ncpu)
    % make install
    % cd ~/local/mysql-5.5.24
    % scripts/mysql_install_db
    % bin/mysqld_safe &
    % cd -
    % brew tap panovek/homebrew-mroonga https://github.com/panovek/homebrew-mroonga.git
    % PATH="$HOME/local/mysql-5.5.24/bin:$PATH" brew install mroonga --with-mysql-source=$(pwd)
