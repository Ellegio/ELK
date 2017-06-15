node 'master-puppet' {
  class { 'filebeat':
    outputs => {
      'logstash' => {
        'hosts' => [
          'node-puppet:5044',
        ],
        'index' => 'filebeat',
      },
    },
  }

  filebeat::prospector { 'syslogs':
    paths    => [
      '/var/log/auth.log',
      '/var/log/syslog',
    ],
    doc_type => 'syslog-beat',
  }
}

node 'node-puppet1' {
#include stdlib
#include yum
#include java
#include elasticsearch
#include logstash
#include nginx
#include kibana

  $myconfig =  @("MYCONFIG"/L)
input {
  beats {
    port => 5044
  }
}
output {
  elasticsearch {
    hosts => "localhost:9200"
    sniffing => true
    manage_template => false
    index => "%{[@metadata][beat]}-%{+YYYY.MM.dd}"
    document_type => "%{[@metadata][type]}"
  }
  stdout { codec => rubydebug }
}

| MYCONFIG
  class { 'elasticsearch':
    java_install => true,
    manage_repo  => true,
    repo_version => '5.x',
    restart_on_change => true,
  }

  elasticsearch::instance { 'es-01':
    config => {
      'network.host' => 'localhost',
    },
  }

  class { 'logstash':
    settings => {
      'http.host' => 'node-puppet',
    }
  }

  logstash::configfile { '02-beats-input.conf':
    content => $myconfig,
  }

  logstash::plugin { 'logstash-input-beats': }

  class { 'kibana' :
      config => {
      'server.host'       => 'localhost',
      'elasticsearch.url' => 'http://localhost:9200',
      'server.port'       => '5601',
    }
  }

  class { 'nginx' :  }

#  file { /etc/nginx/sites-available/kibana
#    mode => 0644
#    source => "puppet:///files/default"
#  }

}
