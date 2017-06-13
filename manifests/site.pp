node 'node-puppet1' {
  include stdlib
  include yum
  include java
  include java_ks::config
  include elasticsearch
  include logstash
  include kibana
}
