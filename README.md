# The Homebrew formula for Mroonga

Type the following command to install Mroonga (10.11) by Homebrew:

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

To complete the installation, you must run script "mroonga_finish_install.sh" generated in install folder.
It creates symlinks of the libraries in the mysql plugin folder and installs them in mysql.
