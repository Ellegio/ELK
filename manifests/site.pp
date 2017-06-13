node 'node-puppet1' {
  include stdlib
  include java
  include java_ks
  include elasticsearch
  include logstash
  include kibana
}
