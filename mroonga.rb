# -*- coding: utf-8 -*-

class Mroonga < Formula
  homepage "http://mroonga.org/"
  url "http://packages.groonga.org/source/mroonga/mroonga-10.11.tar.gz"
  sha256 "00427a67f9d50179f6604fa6c583bdf4dabe22dd69852ea788d2a9402fbd9469"

  depends_on "pkg-config" => :build

  option "with-homebrew-mysql", "Use MySQL installed by Homebrew."
  option "with-homebrew-mysql57", "Use MySQL@5.7 installed by Homebrew."
  option "with-homebrew-mysql56", "Use MySQL@5.6 installed by Homebrew."
  option "with-homebrew-mysql55", "Use MySQL@5.5 installed by Homebrew."
  option "with-homebrew-mariadb", "Use MariaDB installed by Homebrew. You can't use this option with with-homebrew-mysql, with-homebrew-mysql57, with-homebrew-mysql56, and with-homebrew-mysql55."
  option "with-mecab", "Use MeCab installed by Homebrew. You can use additional tokenizer - TokenMecab. Note that you need to build Groonga with MeCab"

  if build.with?("mecab")
    depends_on "groonga" => "--with-mecab"
  else
    depends_on "groonga"
  end

  if build.with?("homebrew-mysql")
    depends_on "cmake" => :build
    depends_on "boost" => :build
    depends_on "mysql"
  elsif build.with?("homebrew-mysql57")
    depends_on "cmake" => :build
    depends_on "mysql@5.7"
  elsif build.with?("homebrew-mysql56")
    depends_on "cmake" => :build
    depends_on "mysql@5.6"
  elsif build.with?("homebrew-mysql55")
    depends_on "cmake" => :build
    depends_on "mysql@5.5"
  elsif build.with?("homebrew-mariadb")
    depends_on "cmake" => :build
    depends_on "mariadb"
  end

  def install
    if build.with?("homebrew-mysql")
      mysql_formula_name = "mysql"
    elsif build.with?("homebrew-mysql57")
      mysql_formula_name = "mysql@5.7"
    elsif build.with?("homebrew-mysql56")
      mysql_formula_name = "mysql@5.6"
    elsif build.with?("homebrew-mysql55")
      mysql_formula_name = "mysql@5.5"
    elsif build.with?("homebrew-mariadb")
      mysql_formula_name = "mariadb"
    else
      mysql_formula_name = nil
    end

    if mysql_formula_name
      build_formula(mysql_formula_name) do |formula|
        Dir.chdir(buildpath.to_s) do
          install_mroonga(formula.buildpath.to_s, formula.original_prefix.to_s)
        end
      end
    else
      mysql_source_path = ARGV.value("with-mysql-source")
      if mysql_source_path.nil?
        raise "--with-homebrew-mysql, --with-homebrew-mysql57, --with-homebrew-mysql56, --with-homebrew-mysql55, --with-homebrew-mariadb or --with-mysql-source=PATH is required"
      end
      install_mroonga(mysql_source_path, nil)
    end
  end

  test do
  end

  def caveats
    <<~EOS
      To complete the installation, you must run the following command:
      #{data_path/"finish_install.sh"}
      It creates symlinks of the libraries in the mysql plugin folder and installs them in mysql

      To confirm successfuly installed, run the following command
      and confirm that 'Mroonga' is in the list:

         mysql> SHOW PLUGINS;
         +---------+--------+----------------+---------------+---------+
         | Name    | Status | Type           | Library       | License |
         +---------+--------+----------------+---------------+---------+
         | ...     | ...    | ...            | ...           | ...     |
         | Mroonga | ACTIVE | STORAGE ENGINE | ha_mroonga.so | GPL     |
         +---------+--------+----------------+---------------+---------+
         XX rows in set (0.00 sec)

      To uninstall Mroonga plugin, run the following command:
         mysql -uroot < '#{uninstall_sql_path}'
    EOS
  end

  private

  module Patchable
    def patches
      file_content = path.open do |file|
        file.read
      end
      data_index = file_content.index(/^__END__$/)
      if data_index.nil?
        # Prevent NoMethodError
        return defined?(super) ? super : []
      end

      data = path.open
      data.seek(data_index + "__END__\n".size)
      data
    end
  end

  module DryInstallable
    def name
      if @name =~ /mysql|mariadb/
        "mroonga/#{@name}"
      else
        @name
      end
    end

    def install(options={})
      if options[:dry_run]
        catch do |tag|
          @dry_install_tag = tag
          begin
            super()
          ensure
            @dry_install_tag = tag
          end
        end
      else
        super()
      end
    end

    def original_prefix
      HOMEBREW_CELLAR/@name/pkg_version
    end

    private

    def system(*args)
      if args == ["make", "install"] and @dry_install_tag
        throw @dry_install_tag
      end
      super
    end
  end

  def build_formula(name)
    formula = Formula[name]
    formula.extend(Patchable)
    formula.extend(DryInstallable)
    formula.brew do
      formula.patch
      formula.install(:dry_run => true)
      yield formula
    end
  end

  def install_mroonga(mysql_source_path, mysql_original_path)
    mysql_config_path = mysql_original_path + "/bin/mysql_config"
    puts mysql_source_path
    puts mysql_config_path

    configure_args = [
      "--prefix=#{prefix}",
      "--with-mysql-source=#{mysql_source_path}",
      "--with-mysql-config=#{mysql_config_path}"
    ]

    system("./configure", *configure_args)
    system("make")
    system("make", "install", "plugindir=#{data_path}")

    (data_path/"finish_install.sh").write <<~EOS
      # Symlink libs
      ln -s #{data_path/'ha_mroonga.0.so'} #{mysql_original_path + '/lib/plugin/ha_mroonga.so'}
      ln -s #{data_path/'ha_mroonga.a'} #{mysql_original_path + '/lib/plugin/ha_mroonga.a'}
      ln -s #{data_path/'ha_mroonga.la'} #{mysql_original_path + '/lib/plugin/ha_mroonga.la'}

      # Install mysql mroonga plugin
      mysql -uroot < '#{install_sql_path}' || true
    EOS
  end

  def data_path
    prefix + "share/mroonga"
  end

  def install_sql_path
    data_path + "install.sql"
  end

  def uninstall_sql_path
    data_path + "uninstall.sql"
  end

end
