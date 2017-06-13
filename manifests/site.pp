node 'node-puppet1' {
  include stdlib
  include datacat
  include yum
  include java
  include elasticsearch
  include logstash
  include kibana
}
