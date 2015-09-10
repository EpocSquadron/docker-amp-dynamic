# Start with Ubuntu base
FROM ubuntu:14.04

# Credit
MAINTAINER Daniel Poulin

# Install some basics
RUN apt-get update

# Install apache and php5
RUN apt-get install -y apache2 \
	php5 \
	php5-mysql \
	php5-gd \
	php5-curl \
	php5-mcrypt \
	php5-xdebug \
	php5-redis \
	php-apc \
	libapache2-mod-php5 \
	redis-server \
	mysql-server \
	supervisor

# Clean up after install
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

##################
##  Supervisor  ##
##################

# create directory for child images to store configuration in
RUN mkdir -p /var/log/supervisor && \
  mkdir -p /etc/supervisor/conf.d

# supervisor base configuration
ADD assets/supervisor/supervisor.conf /etc/supervisor.conf

##################
## MySQL Setup  ##
##################

# Add a grants file to set up remote user
# and disbale the root user's remote access.
ADD assets/mysql/grants.sql /etc/mysql/

# Add a conf file for correcting "listen"
ADD assets/mysql/listen.cnf /etc/mysql/conf.d/

# Add supervisor file
ADD assets/supervisor/mysql.conf /etc/supervisor/conf.d/mysql.conf


##################
## Apache Setup ##
##################

# Make sure all the desired apache modules are on
RUN a2enmod ssl headers rewrite vhost_alias
RUN php5enmod mcrypt

# Set up remote debugging for xdebug
ADD assets/apache/xdebug.ini /etc/php5/mods-available/xdebug.ini
RUN php5enmod xdebug

# Set the default timezone
ADD assets/apache/timezone.ini /etc/php5/conf.d/timezone.ini

# Make sure we can use .htaccess files
ADD assets/apache/enable-htaccess.conf /etc/apache2/conf-available/htaccess.conf
RUN a2enconf htaccess

# Disable default site and replace with our own
ADD assets/apache/dynamic-vhost.conf /etc/apache2/sites-available/dynamic.conf
ADD assets/apache/setDocRoot.php /etc/apache2/includes/
RUN a2dissite 000-default && a2ensite dynamic

# Add supervisor file
ADD assets/supervisor/apache.conf /etc/supervisor/conf.d/apache.conf

VOLUME ["/var/www", "/var/lib/mysql", "/var/log"]

###################
##  Redis Setup  ##
###################

# Add supervisor file
ADD assets/supervisor/redis.conf /etc/supervisor/conf.d/redis.conf

# Expose apache and mysql on standard ports
EXPOSE 80 443 3306

# default command
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
