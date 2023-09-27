FROM ubuntu
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y apache2
CMD apachectl -D FOREGROUND
COPY . /var/www/html
