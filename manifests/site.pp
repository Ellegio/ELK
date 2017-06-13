node 'node-puppet1' {
  include stdlib
  include java
  include elasticsearch
  include logstash
  include kibana
}
