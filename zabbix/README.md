#Zabbix Monitoring Solution

##Zabbix monitoring integration

**Requirements:**
    
    docker
    docker-compose
    optional: postgresql
    

**Setup and install:**

Go to the directory where ./docker-compose.yml is located and run: 

    cp docker-compose.tpl.yml docker-compose.yml 
    docker-compose up -d

Optionally, for the dev and test purpose you can run to configure local environment.
    
    mkdir -p var/posgresql/data
    mkdir -p var/fluentd/log/access.log
    
All configuration files are located on docker-compose.yml file

**Services and configuration:**

1 Service database: db 

    db:
        build:
            context: ./etc/postgresql
            dockerfile: Dockerfile
            container_name: postgresql
            volumes:
            - "./var/postgresql/data:/bitnami/postgresql/data"
            environment:
            POSTGRES_USER: root
            POSTGRES_PASSWORD: magical_password_for_root
            POSTGRES_DB: zabbix_server_db
            DB_PORT: 5432

Database service on postgresql with default schema zabbix_server_db, running on the port DB_PORT under user POSTGRES_USER, 
the password located on POSTGRES_PASSWORD. The database service is designed to be used only on the dev and the test environment.
For the production, is use a stateful solution.

2 Service postgresql admin: pgadmin

    pgadmin:
        image: dpage/pgadmin4
        environment:
            PGADMIN_DEFAULT_EMAIL: xxx@xxx.com
            PGADMIN_DEFAULT_PASSWORD: magical_password_for_root
            PGADMIN_LISTEN_PORT: 80
        ports:
            - 8083:80
        links:
            - db

The utility used to administrate the postgresql schema zabbix_server_db. Available outside of docker on the address
0.0.0.0:8083. Designed only for test and dev, not for the production.

3 Service zabbix server: zabbix-server

    zabbix-server:
        container_name: zabbix-server
        build: 
          context: ./etc/zabbix
        links:
            - db
        ports:
            - 10051:10051
        environment:
            POSTGRES_USER: root
            POSTGRES_DB : zabbix_server_db
            POSTGRES_PASSWORD: magical_password_for_root
            DB_SERVER_HOST: db
            DB_PORT: 5432

The zabbix core application, linked with database and without any UI functionality. The communication with the service
is available on port 10051, default zabbix server port. This port requires to be available for Zabbix agents and 
zabbix_sender utility.  

4 Service zabbix web: zabbix-web

    zabbix-web:
        container_name: zabbix-web
        image: zabbix/zabbix-web-nginx-pgsql
        ports:
            - 8080:8080
        links:
            - db
         # To fix permission, run:
         # docker exec -it -u root zabbix-web chmod 755 /etc/nginx/ssl
         # docker exec -it -u root zabbix-web chmod 755 /etc/nginx/options-ssl-nginx.conf
         # docker exec -it -u root zabbix-web chmod 755 /etc/ssl/certs/dhparam-2048.pem
         #
         # docker exec -it -u root zabbix-web chown -R zabbix:root /etc/nginx/ssl
         # docker exec -it -u root zabbix-web chmod zabbix:root /etc/nginx/options-ssl-nginx.conf
         # docker exec -it -u root zabbix-web chmod zabbix:root /etc/ssl/certs/dhparam-2048.pemu
         # docker-compose restart zabbix-web
        volumes:
            - ./etc/zabbix-web/nginx.conf:/etc/nginx/conf.d/nginx.conf:ro
            - ./etc/zabbix-web/options-ssl-nginx.conf:/etc/nginx/options-ssl-nginx.conf
            - ./etc/zabbix-web/dhparam-2048.pem:/etc/ssl/certs/dhparam-2048.pem
            - ./etc/certbot/letsencrypt:/etc/nginx/ssl
        environment:
            ZBX_SERVER_HOST: zabbix-server
            DB_SERVER_HOST : db
            DB_SERVER_PORT : 5432
            POSTGRES_USER : root
            POSTGRES_PASSWORD: magical_password_for_root
            POSTGRES_DB: zabbix_server_db

The zabbix web application, linked with database,implement the UI for zabbix server application. The communication with the service
is available on 0.0.0.0:8080, it is a standard php application running with nginx and php service.
The application is designed to manage zabbix. The access is protected. 
The admin account can reset using postgresql command: update users set passwd=md5('xxxxxxxx') where alias='Admin';

5 Service cronjob: nodejs-cronjob

    nodejs-cronjob:
        build:
          context: ./etc/nodejs
          dockerfile: Dockerfile
        links:
            - zabbix-server
        environment:
            ZABBIX_SERVER: zabbix-server
            ZABBIX_HOSTNAME: dev.Simulator.LambdaFunction
        volumes:
            - "./app/cronjob:/usr/src/app" 


A small nodejs application designed to simulate a nodejs function that is able to communicated with Zabbix. 
The ZABBIX_SERVER indicate where is installed the service zabbix server, default port is 10051, in our case, 
zabbix service is zabbix-server:10051. The variable ZABBIX_HOSTNAME is the hostname defined manually on Zabbix.
On this host must be defined the trapper items:
    
Logs trappers 
***
    inf: type text/log
    
    war: type text/log
    
    err: type text/log
    
    deb: type text/log
***

The data can be sent on those items using watchdog library

    watchdog.info('This is a info message sent to zabbix on the host defined on ZABBIX_HOSTNAME'); -> inf

    watchdog.warning('This is a warning message sent to zabbix on the host defined on ZABBIX_HOSTNAME'); -> war

    watchdog.error('This is a error message sent to zabbix on the host defined on ZABBIX_HOSTNAME'); -> err

    watchdog.debug('This is a debug message sent to zabbix on the host defined on ZABBIX_HOSTNAME'); -> deb


Working with trapper items:
***
    inf.svc: type integer, status 1 is ok, 0 is error 

    inf.mdb: type integer, status 1 is ok, 0 is error 

    inf.tim: type integer, execution time storage, designed to collect the time execution for the function

    inf.mem: type integer, execution memory storage, designed to collect the used execution memory for the function
***


To send data to the tripper item key inf.svc
    
    watchdog.info(0, 'svc'); -> inf.svc
    watchdog.info(1, 'svc'); -> inf.svc
    watchdog.info(1.2, 'mem'); -> inf.mem
    watchdog.info(1.2, 'tim'); -> inf.tim


How to add a new item?
On Zabbix web application, add new trapper item on the host or a linked template.
For example, a new key err.msg, than it is available from watchdog library using: 

    watchdog.error('Message or value', 'msg') -> error.msg

Debug
    
    docker-compose logs -f nodejs-cron

    Successful entries looks like:

    nodejs-cronjob_1  | Added key no 2984:inf.mdb, value: 0
    nodejs-cronjob_1  | Added key no 2985:inf.svc, value: 0
    nodejs-cronjob_1  | Added key no 2986:cron.run.ok, value: 40
    nodejs-cronjob_1  | Added key no 2987:cron.run.not_ok, value: 36
    nodejs-cronjob_1  | Added key no 2988:inf.tim, value: 0.2076
    nodejs-cronjob_1  | Added key no 2989:inf.mem, value: 0.7034
    nodejs-cronjob_1  | Sent metrics successfull
    nodejs-cronjob_1  | {
    nodejs-cronjob_1  |   response: 'success',
    nodejs-cronjob_1  |   info: 'processed: 5; failed: 2; total: 7; seconds spent: 0.000257'
    nodejs-cronjob_1  | }

5 Service fluentd log distribution: fluentd
    
    fluentd:
        build: 
          context: ./etc/fluentd
          dockerfile: Dockerfile
        environment:
            ZABBIX_SERVER: zabbix-server
            ZABBIX_HOSTNAME: nodejs-cronjob
        volumes:
          - "./etc/fluentd/conf:/fluentd/etc"
          - "./var/fluentd/log/:/var/log/"
        ports:
          - "24224:24224"
          - "24224:24224/udp"

This service is used to send data from various sources to Zabbix. 

    <system>
        log_level trace
    </system>
        
    <source>
      @type tail
      path /var/log/access.log #...or where you placed your Apache access log
      pos_file /var/log/access.log.pos # This is where you record file position
      tag zabbix.nginx.stdout
      <parse>
        @type regexp
        expression /^(?<host>[^ ]*) (?<remote>[^ ]*) (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^\"]*?)(?: +\S*)?)?" (?<code>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)"(?:\s+(?<http_x_forwarded_for>[^ ]+))?)?$/
        time_format %d/%b/%Y:%H:%M:%S %z
      </parse>
    </source>
    
    <filter zabbix.nginx.**>
        @type record_transformer
        <record>
            msg ${record["time"]} ${record["remote"]} ${record["method"]} ${record["code"]} ${record["agent"]}
        </record>
    </filter>
    
    <match zabbix.nginx.**>
        @type zabbix
        zabbix_server "zabbix-server"
        host      "nodejs-cronjob"
        add_key_prefix "nginx.log"
        name_keys  msg
    </match>

In our case, it sends a log file generated by a nginx server to Zabbix.
In our case, on the host nodejs-cronjob, must exist on the trapper item key nginx.log.msg .
This implementation sends logs on realtime to the Zabbix server. The current setup is designed to 
collect the log entries from the ./var/fluentd/log/access.log and send it to Zabbix server

**Debug and tips:**

To access the logs

    docker-compose logs -f
    docker-compose logs -f ${fluentd}
    
To access the docker image 
    
    docker exec -it ${fluentd} sh|bash

On the docker image nodejs-cronjob you can connect and send metrics:

    docker exec -it nodejs-cronjob bash
    # zabbix_sender -z zabbix-server -p 10051 -s "nodejs-cronjob" -k cron.run.ok -o "5" -vv


**Production setup:**

The project is running on:
    
    ec2-3-239-93-151.compute-1.amazonaws.com
    Zabbix web http://ec2-3-239-93-151.compute-1.amazonaws.com:443
    Zabbix web http://ec2-3-239-93-151.compute-1.amazonaws.com:80
    Zabbix web http://ec2-3-239-93-151.compute-1.amazonaws.com:8080
    Zabbix web http://ec2-3-239-93-151.compute-1.amazonaws.com
    Zabbix web https://wsmonitoring.scicanapi.com/index.php
    login: Admin
    password: see https://s3.console.aws.amazon.com/s3/object/auth-keys-storage?region=us-east-1&prefix=monitoring-system%2Fzabbix-admin-pass.txt&tab=details
    https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#InstanceDetails:instanceId=i-04604fbce4fe5c7c8
    Internal hostname (ZABBIX_SERVER):  ip-172-31-87-224.ec2.internal
    Opened ports: 10051 (zabbix incoming), 22 ssh, 8080 http zabbix web, 8083 for pgadmin only when is required
    

The access is granted with PEM key: https://s3.console.aws.amazon.com/s3/object/auth-keys-storage?region=us-east-1&prefix=monitoring-system/system-monitoring.pem


The database is installed on (small postgresql db):

    db-zabbix-server.c4uox5aiqnk3.us-east-1.rds.amazonaws.com
    
To access the postgresql database using pgadmin:
 - start the pgadmin service from docker compose
 - open 8083 port to from security group
 - access the pgadmin on http://ec2-3-239-93-151.compute-1.amazonaws.com:8083  

Credentials are stored on https://s3.console.aws.amazon.com/s3/object/auth-keys-storage?region=us-east-1&prefix=monitoring-system/postgresql-zabbix-connects.txt
The email for the pgadmin is located on docker-compose.yml and can be changed.   


**SSL certificate**

The project is configured to works with ssl certificate as default. This is recommended for production only.
 
To renew the certificate, just run the script:
    
    chmod 750 .renew.cert.sh 
    ./renew.cert.sh

For production a cronjob has been configured.

THe cronjob script: 
         
    #Every 2 months
    30 03 01 */2  *  /home/ubuntu/system-monitoring/zabbix/renew.cert.sh > /tmp/renew.cert.log

The cronjob can be easily managed on Ubuntu using command:
    
    export EDITOR=mcedit
    cronjob -e 

