gce_network { 'puppet-test-instance-network':
  ensure       => present,
  description  => "Network for testing the puppetlabs-gce_compute module instances"
}

gce_address { 'puppet-test-instance-address':
  ensure       => present,
  region       => 'us-central1',
  description  => "Address for testing the puppetlabs-gce_compute module instances"
}

gce_instance { 'puppet-test-instance':
  ensure                   => present,
  zone                     => 'us-central1-a',
  description              => "Instance for testing the puppetlabs-gce_compute module",
  address                  => 'puppet-test-instance-address',
  image                    => 'coreos',
  machine_type             => 'f1-micro',
  network                  => 'puppet-test-instance-network',
  maintenance_policy       => 'TERMINATE',
  can_ip_forward           => true,
  tags                     => ['tag1','tag2'],
  metadata                 => {test-metadata-key => 'test-metadata-value'},
  scopes                   => ['compute-rw','default=storage-rw'],
  startup_script           => '../examples/gce_instance/example-startup-script.sh',
  block_for_startup_script => true,
  puppet_master            => 'master-blaster',
  puppet_service           => present,
  puppet_manifest          => 'class apache ($v = "latest") { ensure => $v }',
  puppet_modules           => ['puppetlabs-gce_compute', 'puppetlabs-mysql'],
  puppet_module_repos      => {puppetlabs-gce_compute => 'git://github.com/puppetlabs/puppetlabs-gce_compute',
                               puppetlabs-mysql       => 'git://github.com/puppetlabs/puppetlabs-mysql'}
}

gce_disk { 'puppet-test-instance-alt-disk':
  ensure       => present,
  zone         => 'us-central1-a',
  description  => "Disk for testing the puppetlabs-gce_compute module instance started from a disk",
  size         => 10,
  image        => 'coreos'
}

gce_instance { 'puppet-test-instance-alt':
  ensure              => present,
  zone                => 'us-central1-a',
  description         => "Instance for testing the puppetlabs-gce_compute module instance alternate options",
  boot_disk           => 'puppet-test-instance-alt-disk'
}
