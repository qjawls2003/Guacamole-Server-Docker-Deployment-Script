#/bin/bash

if test -z "$1"
then
	echo "Input new MySQL root password"
	exit 1
fi

sudo docker run --name some-guacd -d guacamole/guacd
id=$(sudo docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=$1 -d mysql)
ip=$(sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${id})
sudo docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql > initdb.sql
echo "Waiting for MySQL container"
sleep 10
echo "Enter MySQL password for database creation"
echo "create database guacamole_db" | mysql --host=${ip} --user=root -p
echo "Enter MySQL password for guac sql script"
cat initdb.sql | mysql --host=${ip} -u root -p guacamole_db
sudo docker run --name some-guacamole --link some-guacd:guacd --link some-mysql:mysql -e MYSQL_DATABASE=guacamole_db -e MYSQL_USER=root -e MYSQL_PASSWORD=mypassword -d -p 8080:8080 guacamole/guacamole
sudo docker ps
