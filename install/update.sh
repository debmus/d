#!/bin/bash

git clone https://github.com/debmus/rpifo-web.git
rm -rf /var/www/rpifo
mv rpifo-web /var/www/rpifo

apache2() {
	cat <<conf
<VirtualHost *:9696>

	DocumentRoot /var/www/rpifo
	DirectoryIndex index.html

	<Directory /var/www/rpifo>
		Options FollowSymLinks
		AllowOverride All
		Require all granted
	</Directory>

	ErrorLog /var/log/apache2/error.log
	CustomLog /var/log/apache2/access.log common

</VirtualHost>
conf
}
apache2 >/etc/apache2/sites-available/rpifo.conf
a2ensite rpifo > /dev/null

systemctl reload apache2
bash /var/www/rpifo/etc/export_json.sh

echo "# Exportation des donnés de Rpifo Toutes les 5 minutes
*/5 * * * * root /var/www/rpifo/etc/export_json.sh" >/etc/cron.d/rpifo

echo "
Mise à jour terminé
http://$(ip a show eth0 | awk 'NR == 3 {print substr($2,1, length($2)-3)}'):9696
"