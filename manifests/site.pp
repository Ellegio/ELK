node 'node-puppet1' {
  include stdlib
  include yum
  include java
  include elasticsearch
  include logstash
  include nginx
  include kibana
}
