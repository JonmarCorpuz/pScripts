#!/bin/bash

# ==== INSTALL DEPENDENCIES ===================================================================================================================================================

sudo apt -y update
sudo apt -y install apache2 ghostscript libapache2-mod-php mysql-server php php-bcmath php-curl php-imagick php-intl php-json php-mbstring php-mysql php-xml php-zip

# ==== INSTALL WORDPRESS ======================================================================================================================================================

sudo mkdir -p /srv/www
sudo chown www-data: /srv/www
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www

# ==== CONFIGURE APACHE =======================================================================================================================================================

touch ~/wordpress.conf
echo """
<VirtualHost *:80>
    DocumentRoot /srv/www/wordpress
    <Directory /srv/www/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/www/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>
""" > ~/wordpress.conf
sudo mv ~/wordpress.conf /etc/apache2/sites-available/wordpress.conf

sudo a2ensite wordpress
sudo a2enmod rewrite
sudo a2dissite 000-default
sudo systemctl reload apache2

# ==== CONFIGURE DATABASE =====================================================================================================================================================

sudo mysql -u root <<EOF
CREATE DATABASE wordpress;
CREATE USER wordpress@localhost IDENTIFIED BY 'V1ct1mAdm1n!';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON wordpress.* TO wordpress@localhost;
FLUSH PRIVILEGES;
quit
EOF

# ==== CONFIGURE WORDPRESS ====================================================================================================================================================

sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php

sudo -u www-data sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/password_here/V1ct1mAdm1n!/' /srv/www/wordpress/wp-config.php

# ==== REFERENCES =============================================================================================================================================================

# https://ubuntu.com/tutorials/install-and-configure-wordpress#6-configure-wordpress-to-connect-to-the-database
