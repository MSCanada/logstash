# This Dockerfile was generated from templates/Dockerfile.j2
FROM centos:7
LABEL maintainer "Elastic Docker Team <docker@elastic.co>"

# Install Java and the "which" command, which is needed by Logstash's shell
# scripts.
RUN yum update -y && yum install -y java-1.8.0-openjdk-devel which &&\
      yum clean all 

# Provide a non-root user to run the process.
RUN groupadd --gid 1000 logstash && \
    adduser --uid 1000 --gid 1000 \
      --home-dir /usr/share/logstash --no-create-home \
      logstash

RUN mkdir /usr/share/logstash && chmod -R 0777 /usr/share/logstash

# Add Logstash itself.
RUN curl -L https://artifacts.elastic.co/downloads/logstash/logstash-5.6.4.tar.gz -o temp.tar.gz && tar -xzvf temp.tar.gz -C /usr/share/ && rm temp.tar.gz && \
    mv /usr/share/logstash-5.6.4/* /usr/share/logstash && \
    chown --recursive logstash:logstash /usr/share/logstash/ && \
    ln -s /usr/share/logstash /opt/logstash

WORKDIR /usr/share/logstash

ENV ELASTIC_CONTAINER true
ENV PATH=/usr/share/logstash/bin:$PATH

# Provide a minimal configuration, so that simple invocations will provide
# a good experience.
ADD config/logstash-oss.yml config/logstash.yml
ADD config/log4j2.properties config/
ADD pipeline/default.conf pipeline/logstash.conf
RUN chown --recursive logstash:logstash config/ pipeline/

# Ensure Logstash gets a UTF-8 locale by default.
ENV LANG='en_US.UTF-8' LC_ALL='en_US.UTF-8'

# Place the startup wrapper script.
ADD bin/docker-entrypoint /usr/local/bin/
RUN chmod 0755 /usr/local/bin/docker-entrypoint
RUN chmod -R 0777 /usr/share/logstash
RUN chmod -R 0777 /usr/local/bin

RUN ls /usr/share/logstash
USER logstash


ADD env2yaml/env2yaml.go /usr/local/bin/

EXPOSE 9600 5044 8080

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
