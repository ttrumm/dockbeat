FROM golang:1.7
MAINTAINER Ingensi labs <contact@ingensi.com>

# install pyyaml
RUN cd /tmp && wget http://pyyaml.org/download/pyyaml/PyYAML-3.11.tar.gz && tar -zxvf PyYAML-3.11.tar.gz
RUN cd /tmp/PyYAML-3.11 && python setup.py install
# install glide
RUN go get github.com/Masterminds/glide

COPY . $GOPATH/src/github.com/ingensi/dockbeat
RUN cd $GOPATH/src/github.com/ingensi/dockbeat && make && make

RUN mkdir -p /etc/dockbeat/ \
    && cp $GOPATH/src/github.com/ingensi/dockbeat/dockbeat /usr/local/bin/dockbeat \
    && cp $GOPATH/src/github.com/ingensi/dockbeat/dockbeat-docker.yml /etc/dockbeat/dockbeat.yml

ADD logstash-forwarder.crt /etc/pki/tls/certs/logstash-forwarder.crt
ADD logstash-forwarder.key /etc/pki/tls/private/logstash-forwarder.key
ADD dockbeat.yml /etc/dockbeat/dockbeat.yml
ADD init.sh /usr/local/sbin/init.sh
RUN chmod +x /usr/local/sbin/init.sh

WORKDIR /etc/dockbeat
ENTRYPOINT dockbeat

CMD [ "-c", "dockbeat.yml", "-e" ]
