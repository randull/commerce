#!/bin/bash
#
####    Prompt user to enter Site Name                          ####
read -p "Site Name: " sitename
####    Prompt user to enter Domain Name                        ####
read -p "Domain Name: " domain
####    Prompt user to enter Password for User1(Hackrobats)     ####
while true
do
    read -s -p "User1 Password: " drupalpass
    echo
    read -s -p "User1 Password (again): " drupalpass2
    echo
    [ "$drupalpass" = "$drupalpass2" ] && break
    echo "Please try again"
done
echo "Password Matches"
# Create variables from Domain Name
hosts=/etc/apache2/sites-available    # Set variable for Apache Host config
www=/var/www                          # Set variable for Drupal root directory
tld=`echo $domain  |cut -d"." -f2,3`  # Generate tld (eg .com)
name=`echo $domain |cut -f1 -d"."`    # Remove last for characters (eg .com) 
longname=`echo $name |tr '-' '_'`     # Change hyphens (-) to underscores (_)
shortname=`echo $name |cut -c -16`    # Shorten name to 16 characters for MySQL
machine=`echo $shortname |tr '-' '_'` # Replace hyphens in shortname to underscores
dbpw=$(pwgen -n 16)                   # Generate 16 character alpha-numeric password
####    Print DB Password for reference                         ####
echo "$dbpw"
####    Notify user of MySQL password requirement               ####
echo "MySQL verification required."
####    Create database and user                                ####
db="CREATE DATABASE IF NOT EXISTS $machine;GRANT ALL PRIVILEGES ON $machine.* TO $machine@localhost IDENTIFIED BY '$dbpw';"
db2="GRANT ALL PRIVILEGES ON $machine.* TO $machine@dev.hackrobats.net IDENTIFIED BY '$dbpw';FLUSH PRIVILEGES;"
mysql -u deploy -p -e "$db"
mysql -u deploy -p -e "$db2"
####    Create directories necessary for Drupal installation    ####
#sudo -u deploy mkdir $www/$domain $www/$domain/html $www/$domain/html/sites $www/$domain/html/sites/default $www/$domain/html/sites/default/files
#chmod a+w $www/$domain/html/sites/default/files
#chgrp -R www-data $www/$domain
#cd $www/$domain/html/sites/default/files
####    Create Private directory and setup Backup directories   ####
#sudo -u deploy mkdir -p $www/$domain/private/backup_migrate/scheduled $www/$domain/private/backup_migrate/manual
#chmod 6774 -R $www/$domain/private
#chown -R deploy:www-data $www/$domain/private
####    Download favicon.ico                                    ####
#sudo -u deploy curl -o $www/$domain/html/sites/default/files/favicon.ico 'http://hackrobats.net/sites/default/files/favicon.ico'
####    Create Public & Temp files directory                           ####
#mkdir $www/$domain/public $www/$domain/tmp
#chmod 6775 -R $www/$domain/public $www/$domain/tmp
#chown -R deploy:www-data $www/$domain/public $www/$domain/tmp
####    Create log files and folders, as well as info.php       ####
#sudo -u deploy mkdir $www/$domain/logs
#touch $www/$domain/logs/access.log $www/$domain/logs/error.log
####    Create virtual host file, enable and restart apache     ####
#echo "<VirtualHost *:80>
#        ServerName $domain
#        Redirect 301 / http://www.$domain
#</VirtualHost>        
#
#<VirtualHost *:80>
#        ServerAdmin maintenance@hackrobats.net
#        ServerName www.$domain
#        ServerAlias *.$domain $name.510interactive.com $name.hackrobats.net
#        ServerAlias $name.5ten.co $name.cascadiacollective.net $name.cascadiaweb.net $name.hackrotasks.com
#        DocumentRoot $www/$domain/html
#        ErrorLog $www/$domain/logs/error.log
#        CustomLog $www/$domain/logs/access.log combined
#        DirectoryIndex index.php
#</VirtualHost>" > /etc/apache2/sites-available/$machine.conf
#a2ensite $machine.conf && service apache2 reload
####    Create /etc/cron.hourly entry                           ####
#echo "#!/bin/bash
#
#/usr/bin/wget -O - -q -t 1 http://$domain/sites/all/modules/elysia_cron/cron.php?cron_key=$machine" > /etc/cron.hourly/$machine
####    Drupal Install Profile choice NEEDED here               ####
####                                                            ####
####    Create site structure using Drush Make                  ####
cd $www/$domain/html
drush make https://raw.github.com/randull/createsite/master/createsite.make -y
####    Deploy site using Drush Site-Install                    ####
drush si createsite --db-url="mysql://$machine:$dbpw@localhost/$machine" --site-name="$sitename" --account-name="hackrobats" --account-pass="$drupalpass" --account-mail="maintenance@hackrobats.net" -y
####    Remove Drupal Install files after installation          ####
cd $www/$domain/html
rm CHANGELOG.txt COPYRIGHT.txt install.php INSTALL.mysql.txt INSTALL.pgsql.txt INSTALL.sqlite.txt INSTALL.txt LICENSE.txt MAINTAINERS.txt README.txt UPGRADE.txt
cd $www/$domain/html/sites
rm README.txt all/modules/README.txt all/themes/README.txt
sudo chown -R deploy:www-data all default
rm -R all/libraries/plupload/examples
####    Create omega 4 sub-theme and set default                ####
drush cc all
drush omega-subtheme "Hackrobats Omega Subtheme" --machine-name="omega_hackrobats"
drush omega-subtheme "$sitename" --machine-name="omega_$machine" --basetheme="omega_hackrobats" --set-default
drush omega-export "omega_$machine" --revert -y
####    Initialize Git directory                                ####
cd $www/$domain/html
sudo -u deploy git init
####    Set owner of entire directory to deploy:www-data        ####
cd $www
sudo chown -R deploy:www-data $domain
sudo chown -R deploy:www-data /home/deploy
####    Set Cron Key & Private File Path
cd $www/$domain/html
drush vset cron_key $machine
drush vset cron_safe_threshold 0
drush vset file_private_path $www/$domain/private
