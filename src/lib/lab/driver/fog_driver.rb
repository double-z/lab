require 'vm_driver'

##
## $Id$
##

module Lab
module Drivers
class FogDriver < VmDriver

  def initialize(config,fog_config)
    
    super(config)
    @fog_config = fog_config

    # Soft dependency
    begin
      require 'fog'
    rescue LoadError
      raise "WARNING: Library fog not found. Could not create driver"
    end

    if @fog_config['fog_type'] == "ec2"

      # AWS / EC2 Base Credential Configuration
      @aws_cert_file = IO.read(fog_config['fog_aws_cert_file']).chomp if fog_config['fog_aws_cert_file']
      @aws_private_key_file = IO.read(fog_config['fog_aws_private_key_file']).chomp if fog_config['fog_aws_private_key_file']
      @ec2_access_key_file = IO.read(fog_config['fog_ec2_access_key_file']).chomp if fog_config['fog_ec2_access_key_file']
      @ec2_secret_access_key_file = IO.read(fog_config['fog_ec2_secret_access_key_file']).chomp if fog_config['fog_ec2_secret_access_key_file']
      
      # Instance Keys
      @ec2_instance_public_key_file = IO.read(fog_config['fog_ec2_instance_public_key_file']).chomp if fog_config['fog_ec2_instance_public_key_file']
      @ec2_instance_private_key_file = IO.read(fog_config['fog_ec2_instance_private_key_file']).chomp if fog_config['fog_ec2_instance_private_key_file']
      
      # Instance Details
      @ec2_base_ami = fog_config['fog_ec2_base_ami']
      @ec2_flavor = fog_config['fog_ec2_flavor']
      @ec2_user = fog_config['fog_ec2_user']
      @ec2_region = fog_config['fog_ec2_region']
          
      # Set up a connection
      @compute = Fog::Compute.new(
        :provider => "Aws",
        :aws_access_key_id => @aws_access_key_file,
        :aws_secret_access_key => @aws_secret_access_key_file )
    else
      raise "Unsupported fog type"
    end
  end

  def start
    ec2_settings = {
      :image_id => @ec2_base_ami,
      :flavor_id =>  @ec2_flavor,
      :public_key_path => @ec2_instance_public_key_file,
      :private_key_path => @ec2_instance_private_key_file,
      :username => @ec2_user}
    begin
      @fog_server = @compute.servers.bootstrap(ec2_settings)
    rescue Fog::Compute::AWS::Error => e
      raise "Couldn't authenticate to AWS - did you place keys in the creds/ directory?"
      exit
    end
  end

  def stop
    @fog_server.destroy
  end

  def suspend
    raise "unimplemented"
  end

  def pause
    raise "unimplemented"
  end

  def reset
    raise "unimplemented"
  end

  def create_snapshot(snapshot)
    raise "unimplemented"
  end

  def revert_snapshot(snapshot)
    raise "unimplemented"
  end

  def delete_snapshot(snapshot)
    raise "unimplemented"
  end

  def cleanup
    @fog_server.destroy
  end

  def running?
    return true #TODO
  end

end
end 
end
