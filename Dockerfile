FROM centos:8

RUN yum install httpd -y
RUN yum install php -y

COPY * /var/www/html/

EXPOSE 80

CMD /usr/sbin/httpd -DFOREGROUND
