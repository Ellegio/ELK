node 'node-puppet1' {
  include elasticsearch
}

class { 'elasticsearch':
  java_install => true,
  manage_repo  => true,
  repo_version => '5.x',
}
