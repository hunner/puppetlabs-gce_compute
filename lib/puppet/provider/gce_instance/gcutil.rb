require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gce'))

Puppet::Type.type(:gce_instance).provide(
  :gcutil,
  :parent => Puppet::Provider::Gce
) do

  commands :gcutil => 'gcutil'

  def self.subcommand
    'instance'
  end

  def subcommand
    self.class.subcommand
  end

  def create
    raise(Puppet::Error, "Did not specify required param machine_type") unless resource[:machine]
    raise(Puppet::Error, "Did not specify required param zone") unless resource[:zone]
    raise(Puppet::Error, "Did not specify required param image") unless resource[:image]
    args = parameter_list.collect do |attr|
      resource[attr] && "--#{attr}=#{resource[attr]}"
    end.compact
    if resource[:classes]
      # TODO - this needs to be better tested
      # it would be awesome if I can pass entire class manifests to
      # instead of a hash (b/c transforing a hash in bash is going to be
      # a nightmare
      # this will not work as well for puppet agent, but I can look into that later
      manifest = to_manifest(resource[:classes])
      args.push("--metadata=puppet_classes:#{parse_refs_from_manifest(manifest)}")
    end
    if resource[:modules]
      args.push("--metadata=puppet_modules:#{resource[:modules]}")
    end
    if resource[:module_repos]
      args.push("--metadata=puppet_repos:#{resource[:module_repos]}")
    end
    # always install puppet
    gcutilcmd("add#{subcommand}", resource[:name], args, '--wait_until_running')
  end

  def parameter_list
    [
      'authorized_ssh_keys',
      'description',
      'disk',
      'external_ip_address',
      'internal_ip_address',
      'image',
      'machine',
      'network',
      'service_account',
      'service_account_scopes',
      'tags',
      'use_compute_key',
      'zone'
    ]
  end
  def external_ip_address
    # rebuild the cache if we do not find the property that we are looking for
    # this is b/c I did not implement create to rebuild elements on the cache
    # I may reimplemet this to use flush or something...
    instance = all_compute_objects(gce_device)[resource[:name]]
    (instance && instance[:external_ip]) ||
      (
        self.class.clear_device_objects(gce_device) &&
        all_compute_objects(gce_device)[resource[:name]][:external_ip]
      )
  end

  def external_ip_address=(value)
    raise(Puppet::Error, "External ip address is a read-only property, it cannot be updated")
  end

  def internal_ip_address
    instance = all_compute_objects(gce_device)[resource[:name]]
    (instance && instance[:network_ip]) ||
      (
        self.class.clear_device_objects(gce_device) &&
        all_compute_objects(gce_device)[resource[:name]][:network_ip]
      )
  end

  def internal_ip_address=(value)
    raise(Puppet::Error, "Internal ip address is a read-only property, it cannot be updated")
  end

end