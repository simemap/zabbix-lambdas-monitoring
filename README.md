<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="#">
    <img src="https://github.com/simemap/zabbix-lambdas-monitoring/blob/main/img/Zabbix_Real_Time%20Web_APP.png" alt="Logo">
  </a>

  <h3 align="center">Monitoring system project</h3>

  <p align="center">
    Monitoring solution integrated with AWS Lambda
    <br />
    <a href="https://github.com/Scican-Ltd/zabixx-system-monitoring"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://wsmonitoring.scicanapi.com">View Project</a>
    ·
    <a href="https://github.com/Scican-Ltd/zabixx-system-monitoring">View Repository</a>
    ·
    <a href="https://github.com/Scican-Ltd/zabixx-system-monitoring/issues">Report Bug</a>
    ·
    <a href="https://github.com/Scican-Ltd/zabixx-system-monitoring">Request Feature</a>
    ·
    <a href="https://synergo.atlassian.net/browse/SC-24">AWS MQTT using Watchman approach</a>
    <a href="https://synergo.atlassian.net/browse/SC-24">AWS Lambda Integration using Watchman approach</a>
  </p>
</p>

<!-- ABOUT THE PROJECT -->
## About The Project  

[![Product Name Screen Shot][product-screenshot]](https://wsmonitoring.scicanapi.com)

Here's why:
* Designed to be a custom metrics collector and a graph solution for custom metrics 
* A demo dashboard has been created with AWS lambda minimal resource overview


### Built With

This section should list any major frameworks that you built your project using. Leave any add-ons/plugins for the acknowledgements section. Here are a few examples.
* [Zabbix](https://swagger.io/)
* [Docker](https://www.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Nginx](https://www.nginx.com/)
* [NodeJs](https://www.nodejs.org/) (demo application integrated)
* [Postgresql](https://www.postgresql.com/) (optional, only when is run on local)
* [Fluentd](https://www.fluentd.org/) (demo integration)

<!-- GETTING STARTED -->
## Getting Started

The project is designed to run with minimal resource and isolated with docker for each microservice service.
For production, we recommend to use real a database and not a stateless one (under docker).
The docker orchestration management is done via Docker Compose, a simple docker orchestration tool.

### Architecture
[![Web App Architecture][app-architecture]](https://github.com/simemap/zabbix-lambdas-monitoring/blob/main/img/Zabbix_Real_Time%20Web_APP.png)
* [PROD setup](https://wsmonitoring.scicanapi.com/)
* [Access to PROD admin account](https://s3.console.aws.amazon.com/s3/object/auth-keys-storage?region=us-east-1&prefix=monitoring-system/zabbix-admin-pass.txt)
* [Source](https://github.com/Scican-Ltd/zabixx-system-monitoring)
* [Ec2 - Web App Host](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#InstanceDetails:instanceId=i-04604fbce4fe5c7c8)
* [PosgreSql](https://s3.console.aws.amazon.com/s3/object/auth-keys-storage?region=us-east-1&prefix=monitoring-system/postgresql-zabbix-connects.txt)
* [S3 - credentials and relevant securities](https://s3.console.aws.amazon.com/s3/buckets/auth-keys-storage?prefix=monitoring-system%2F&region=us-east-1)
  
### Prerequisites

This is an example of how to list things you need to use the software and how to install them.
* nodejs
* docker
* docker-compose
* unix


### Installation

1. Get a free account on github, [https://github.com](https://github.com)
2. Get access on https://github.com/Scican-Ltd/zabixx-system-monitoring and clone the repo
   ```sh
   git clone https://github.com/Scican-Ltd/zabixx-system-monitoring.git
   ```
3. Install the project
   ```sh
   cd ./zabbix
   cp docker-compose.tpl.yml docker-compose.yml 
   ```
4. Review the docker-compose parameters
   ```sh
   cat docker-compose.yml 
   ```
5. Start the project locally
   ```sh
   docker-compose up -d
   ```
5. Access project on port:
   ```browser
   http://localhost:8080/
   ```
   



<!-- USAGE EXAMPLES -->
## Usage

The Zabbix is a powerfull monitoring and analyze tool.

_For more examples, please refer to the [Documentation](https://zabbix.com)_



<!-- ROADMAP -->
## Roadmap

See the [open issues](https://github.com/Scican-Ltd/zabixx-system-monitoring/issues) for a list of proposed features (and known issues).



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/othneildrew/Best-README-Template.svg?style=for-the-badge
[contributors-url]: https://github.com/Scican-Ltd/zabixx-system-monitoring/graphs/contributors

[issues-shield]: https://img.shields.io/github/issues/othneildrew/Best-README-Template.svg?style=for-the-badge
[issues-url]: https://github.com/Scican-Ltd/zabixx-system-monitoring/issues

[license-shield]: https://img.shields.io/github/license/othneildrew/Best-README-Template.svg?style=for-the-badge
[license-url]: https://github.com/othneildrew/Best-README-Template/blob/master/LICENSE.txt

[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/company/coltene-whaledent/

[product-screenshot]: zabbix/docs/img/screenshot.png
[app-architecture]: https://github.com/simemap/zabbix-lambdas-monitoring/blob/main/img/Zabbix_Real_Time%20Web_APP.png


The Zabbix documentation and management

See: ./zabbix/README.md

##Requirements
    
    - OS any system that support docker
    - docker up and running
    - docker-compose up and running   
