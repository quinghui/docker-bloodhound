FROM debian:jessie
COPY sources.list /etc/apt/sources.list
RUN apt-get update && apt-get install -y python python-virtualenv python-pip wget vim \
    postgresql python-dev libpq-dev apache2 libapache2-mod-wsgi gcc --no-install-recommends

RUN wget -O- http://mirror.bit.edu.cn/apache/bloodhound/apache-bloodhound-0.8.tar.gz | tar -xvzf-
RUN pip install --upgrade pip; pip install --upgrade virtualenv

copy pg_hba.conf /etc/postgresql/9.4/main/pg_hba.conf
RUN chown postgres:postgres /etc/postgresql/9.4/main/pg_hba.conf; \
    service postgresql start; \
    su - postgres -c "createuser --no-superuser --no-createdb --no-createrole --encrypted --no-password bloodhound"; \
    su - postgres -c "psql -c \"ALTER USER bloodhound PASSWORD 'password';\""; \
    su - postgres -c "createdb --owner=bloodhound --template=template0 --encoding=UTF-8 bloodhound"

RUN ["/bin/bash", "-c", "\
    mkdir -p /opt/bloodhound \
    && useradd --system -m bloodhound \
    && chown bloodhound:bloodhound /opt/bloodhound \
    && service postgresql start \
    && cd apache-bloodhound-0.8/installer \  
    && virtualenv /opt/bloodhound/bhenv \
    && source /opt/bloodhound/bhenv/bin/activate \
    && pip install -r requirements.txt \
    && pip install -r pgrequirements.txt \
    && python bloodhound_setup.py \
    --environments_directory=/opt/bloodhound/environments \
    --default-product-prefix=DEF \
    --database-type=postgres --user=bloodhound --password=password --database-name=bloodhound \
    --admin-user=admin --admin-password=password \
    && trac-admin /opt/bloodhound/environments/main/ deploy /opt/bloodhound/environments/main/site \
"]

COPY bloodhound.conf /etc/apache2/sites-available/bloodhound.conf
COPY ports.conf /etc/apache2/ports.conf
RUN a2enmod wsgi; a2enmod auth_digest; \
    a2ensite bloodhound; apachectl configtest; apachectl graceful; \
    chown -R bloodhound.bloodhound opt/bloodhound

RUN apt-get install -y supervisor
COPY supervisord.conf /etc/supervisord/supervisord.conf

EXPOSE 8080

#CMD ["/bin/bash", "-c", "virtualenv /opt/bloodhound/bhenv; \
#     source /opt/bloodhound/bhenv/bin/activate; \
#     tracd --port=8000 /opt/bloodhound/environments/main"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord/supervisord.conf"]
