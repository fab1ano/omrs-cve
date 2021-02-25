FROM puppeteer1337/wphp7

RUN apt-get update

RUN apt-get install -y php php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-fpm

RUN apt-get install -y nginx

ADD omrs/omrs /var/www/html
RUN chown www-data /var/www/html -R

RUN rm -f /etc/nginx/sites-enabled/default
ADD nginx.conf /etc/nginx/sites-enabled/omrs

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ADD ["omrs/SQL File/omrsdb.sql", "/tmp/omrs.sql"]
RUN /etc/init.d/mysql start && mysql -e "CREATE DATABASE omrsdb;"
RUN /etc/init.d/mysql start && mysql -D omrsdb < /tmp/omrs.sql
RUN rm -f /tmp/omrs.sql

ADD ./exploit.py /exploit.py


WORKDIR /home/wc
COPY lib_mysqludf_sys/install.sh lib_mysqludf_sys/lib_mysqludf_sys.sql ./
COPY lib_mysqludf_sys/lib_mysqludf_sys.so /usr/lib/mysql/plugin/
RUN chmod 500 install.sh
RUN bash install.sh


EXPOSE 8080:8080

ENTRYPOINT /entrypoint.sh
