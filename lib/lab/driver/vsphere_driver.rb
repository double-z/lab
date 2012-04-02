require 'vm_driver'

##
## $Id$
##

# This driver was built against: 
# VMware Vsphere 4.1

module Lab
module Drivers

class VsphereDriver < VmDriver

  def initialize(config)
    unless config['user'] then raise ArgumentError, "Must provide a username" end
    unless config['host'] then raise ArgumentError, "Must provide a hostname" end
    unless config[''] then raise ArgumentError, "Must provide a password" end
    super(config)

    @user = filter_command(config['user'])
    @host = filter_command(config['host'])

    # Soft dependency
    begin
      require 'rbvmomi'
    rescue LoadError
      raise "WARNING: Library rbvmomi not found. Could not create driver!"
    end

    vim = RbVmomi::VIM.connect host: @host, user: @user, password: @pass
    dc = vim.serviceInstance.find_datacenter("datacenter1") or fail "datacenter not found"
    @vm = dc.find_vm("test") or fail "VM not found"
  end

  def start
    @vm.PowerOnVM_Task.wait_for_completion
  end

  def stop
    @vm.PowerOffVM_Task.wait_for_completion
  end

  def suspend
    @vm.SuspendVM_Task.wait_for_completion
  end

  def pause
    raise "Unimplemented"
  end

  def resume
    raise "Unimplemented"
  end

  def reset
    @vm.ResetVM_Task.wait_for_completion
  end

  def create_snapshot(snapshot)
    snapshot = filter_input(snapshot)
    raise "Unimplemented"
  end

  def revert_snapshot(snapshot)
    raise "Unimplemented"
    # If we got here, the snapshot didn't exist
    raise "Invalid Snapshot Name"
  end

  def delete_snapshot(snapshot, remove_children=false)
    raise "Unimplemented"
    # If we got here, the snapshot didn't exist
    raise "Invalid Snapshot Name"
  end
  
  def delete_all_snapshots
    raise "Unimplemented"
  end
    
  def run_command(command)
    raise "Unimplemented"
  end
  
  def copy_from(from, to)
    if @os == "linux"
      scp_from(from, to)
    else
      raise "Unimplemented"
    end
  end

  def copy_to(from, to)
    if @os == "linux"
      scp_to(from, to)
    else
      raise "Unimplemented"
    end
  end

  def check_file_exists(file)
    raise "Unimplemented"
  end

  def create_directory(directory)
    raise "Unimplemented"
  end

  def cleanup
    raise "Unimplemented"
  end

  def running?
    raise "Unimplemented"
  end 

end

end 
end
