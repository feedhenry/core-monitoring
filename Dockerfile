FROM centos:centos7

EXPOSE 8080

ADD sendEmail-epel-7.repo /etc/yum.repos.d/

RUN yum install -y epel-release && \
    INSTALL_PKGS="httpd telnet supervisor python-jinja2 nagios-plugins-all sendEmail perl-Net-SSLeay perl-IO-Socket-SSL" && \
    yum -y --setopt=tsflags=nodocs install $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all && \
    curl --retry 999 --retry-max-time 0 -sSL https://github.com/openshift/origin/releases/download/v3.10.0/openshift-origin-client-tools-v3.10.0-dd10d17-linux-64bit.tar.gz | tar xzv && \
    mv openshift-origin-*/* /usr/bin/ && \
    mkdir -p /opt/rhmap/ && \
    sed -i -e 's/Listen 80/Listen 8080/' \
           -e 's|DocumentRoot "/var/www/html"|DocumentRoot "/usr/share/nagios/html"|' \
           -e 's|<Directory "/var/www">|<Directory "/usr/share/nagios/html">|' \
           /etc/httpd/conf/httpd.conf && \
    touch /supervisord.log /supervisord.pid && \
    mkdir -p /var/log/nagios/archives /var/log/nagios/rw/ /var/log/nagios/spool/checkresults /opt/rhmap/nagios/plugins/lib && \
    chmod -R 777 /supervisord.log /supervisord.pid  \
                 /etc/httpd /etc/passwd  /var/log  \
                  /run /usr/share/httpd  
COPY ./nagios-4.0.8-2.el7.x86_64.rpm .
RUN yum localinstall -y --nogpgcheck ./nagios-4.0.8-2.el7.x86_64.rpm 
RUN chmod -R 777 /usr/share/nagios /etc/nagios /usr/lib64/nagios /var/log/nagios /var/spool/nagios && \
    sed -i -e 's|cfg_file=/etc/nagios/objects/localhost.cfg||' /etc/nagios/nagios.cfg
COPY supervisord.conf /etc/supervisord.conf
COPY make-nagios-fhservices-cfg make-nagios-commands-cfg fhservices.cfg.j2 commands.cfg.j2 /opt/rhmap/
COPY plugins/default/ /opt/rhmap/nagios/plugins/
COPY scripts/ /opt/rhmap/
RUN chmod -R 755 /opt/rhmap/nagios/plugins/
COPY start /start
COPY snmp-scripts /usr/local/bin/
COPY mibs/ /usr/share/snmp/mibs

CMD ["/start"]
