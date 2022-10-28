#!/bin/bash

DATADIR='/var/lib/mysql';

initialize() {

  MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-root}"
  MYSQL_ROOT_HOST="${MYSQL_ROOT_HOST:-%}"

  echo "> Initializing database"
  mkdir -p /var/lib/mysql
  chown -R mysql:mysql /var/lib/mysql

  mysqld --initialize-insecure --user=mysql

  echo "> Starting temporary server";
  if ! mysqld --daemonize --skip-networking --user=mysql; then
    echo "Error starting mysqld"
    exit 1
  fi
  
  echo "> Setting root password";
  echo
  echo "Password: $MYSQL_ROOT_PASSWORD"

  if [ "$MYSQL_ROOT_HOST" != 'localhost' ]; then
    mysql <<EOF 
    CREATE USER 'root'@'${MYSQL_ROOT_HOST}' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    GRANT ALL ON *.* TO 'root'@'${MYSQL_ROOT_HOST}' WITH GRANT OPTION;"
EOF
  fi

  mysql <<EOF
  ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
  GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
  FLUSH PRIVILEGES;
EOF
  if [ -n "$MYSQL_DATABASE" ]; then
   echo "> Creating database $MYSQL_DATABASE";
     mysql -p"$MYSQL_ROOT_PASSWORD" <<< "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;";
  fi

  if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
		echo "> Creating user";
    echo 
    echo "User: $MYSQL_USER"
    echo "Password: $MYSQL_PASSWORD"
    echo 

    mysql -p"$MYSQL_ROOT_PASSWORD" <<< "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"

    echo "> Granting permissions";
		if [ -n "$MYSQL_DATABASE" ]; then
         mysql -p"$MYSQL_ROOT_PASSWORD" <<< "GRANT ALL ON \`${MYSQL_DATABASE}\`.* TO '$MYSQL_USER'@'%';";
		fi
	fi
  echo "> Shutting down temporary server";
  if ! mysqladmin shutdown -uroot -p"$MYSQL_ROOT_PASSWORD"  ; then
      echo "Error shutting down mysqld"
      exit 1
  fi
  echo "> Complete";
}

if [ "$1" = 'mysqld' ]; then
  if [ ! -d "$DATADIR/mysql" ]; then
    initialize;
  fi
fi

exec "$@"