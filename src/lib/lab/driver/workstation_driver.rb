require 'vm_driver'

##
## $Id$
##

module Lab
module Drivers

class WorkstationDriver < VmDriver

  def initialize(config)
    super(config)
    
    if !File.exist?(@location)
      raise ArgumentError,"Couldn't find: #{@location}"
    end
  end

  def start
    system_command("vmrun -T ws start " + "\'#{@location}\' nogui")
  end

  def stop
    system_command("vmrun -T ws stop " + "\'#{@location}\' nogui")
  end

  def suspend
    system_command("vmrun -T ws suspend " + "\'#{@location}\' nogui")
  end

  def pause
    system_command("vmrun -T ws pause " + "\'#{@location}\' nogui")
  end

  def reset
    system_command("vmrun -T ws reset " + "\'#{@location}\' nogui")
  end

  def create_snapshot(snapshot)
    snapshot = filter_input(snapshot)
    system_command("vmrun -T ws snapshot " + "\'#{@location}\' \'#{snapshot}\' nogui")
  end

  def revert_snapshot(snapshot)
    snapshot = filter_input(snapshot)
    system_command("vmrun -T ws revertToSnapshot " + "\'#{@location}\' \'#{snapshot}\' nogui")
  end

  def delete_snapshot(snapshot)
    snapshot = filter_input(snapshot)
    system_command("vmrun -T ws deleteSnapshot " + "\'#{@location}\' \'#{snapshot}\' nogui" )
  end

  def run_command(command)

    #
    # Generate a script name
    #
    script_rand_name = rand(1000000)

    #
    # Configure paths for each OS - We really can't filter command, so we're gonna 
    # stick it in a script
    #
    if @os == "windows"
      local_tempfile_path = "/tmp/lab_script_#{script_rand_name}.bat"
      remote_tempfile_path = "C:\\\\lab_script_#{script_rand_name}.bat"
      remote_output_file = "C:\\\\lab_command_output_#{script_rand_name}"
      remote_run_command = remote_tempfile_path
      File.open(local_tempfile_path, 'w') {|f| f.write(command) }
    else
      
      local_tempfile_path = "/tmp/lab_script_#{script_rand_name}.sh"
      remote_tempfile_path = "/tmp/lab_script_#{script_rand_name}.sh"
      remote_output_file = "/tmp/lab_command_output_#{script_rand_name}"
      local_output_file = "/tmp/lab_command_output_#{script_rand_name}"
      
      remote_run_command = remote_tempfile_path
      
      File.open(local_tempfile_path, 'w') {|f| f.write("#!/bin/sh\n#{command}\n")}
    end
    
    if @tools

      #puts "DEBUG: Running w/ tools"

      #
      # Copy our local tempfile to the guest
      #
      vmrunstr = "vmrun -T ws -gu #{@vm_user} -gp #{@vm_pass} " +
          "copyFileFromHostToGuest \'#{@location}\' \'#{local_tempfile_path}\'" +
          " \'#{remote_tempfile_path}\'"
      system_command(vmrunstr)

      if @os == "linux"
        #
        # Now run the command directly on the guest (linux - call w/ /bin/sh)
        #
        vmrunstr = "vmrun -T ws -gu #{@vm_user} -gp #{@vm_pass} " + 
            "runProgramInGuest \'#{@location}\' /bin/sh #{remote_tempfile_path} > #{remote_output_file}"
        system_command(vmrunstr)
      else
        #
        # Now run the command directly on the guest (windows)
        #
        vmrunstr = "vmrun -T ws -gu #{@vm_user} -gp #{@vm_pass} " + 
            "runProgramInGuest \'#{@location}\' #{remote_tempfile_path} > #{remote_output_file}" 
        system_command(vmrunstr)
      end
      
      #
      # Cleanup. Delete it on the guest
      #
      vmrunstr = "vmrun -T ws -gu #{@vm_user} -gp #{@vm_pass} " + 
          "deleteFileInGuest \'#{@location}\' \'#{remote_tempfile_path}\'"
      system_command(vmrunstr)

      #
      # Delete it locally
      #
      local_delete_command = "rm #{local_tempfile_path}"
      system_command(local_delete_command)
    else

      #
      # Use SCP / SSH
      #

      if @os == "linux"
        
        #
        # Copy it over
        #
        scp_to(local_tempfile_path, remote_tempfile_path)

        #
        # And ... execute it
        #
        ssh_exec("/bin/sh #{remote_tempfile_path} > #{remote_output_file}")

        #
        # Now copy the output back to us
        #
        scp_from(remote_output_file, local_output_file)

        # Now, let's look at the output of the command
        output_string = File.open(local_output_file,"r").read

        #
        # And clean up
        #
        ssh_exec("rm #{remote_output_file}")
        ssh_exec("rm #{remote_tempfile_path}")
        
        `rm #{local_output_file}`

      else
        raise "Hey, no tools, and windows? can't do nuttin for ya man."
      end
      
    end
  output_string
  end
  
  def copy_from(from, to)
    from = filter_input(from)
    to = filter_input(to)
    if @tools
      vmrunstr = "vmrun -T ws -gu \'#{@vm_user}\' -gp \'#{@vm_pass}\' copyFileFromGuestToHost " +
          "\'#{@location}\' \'#{from}\' \'#{to}\'" 
    else
      scp_from(from, to)
    end
    system_command(vmrunstr)
  end

  def copy_to(from, to)
    from = filter_input(from)
    to = filter_input(to)
    if @tools
      vmrunstr = "vmrun -T ws -gu #{@vm_user} -gp #{@vm_pass} copyFileFromHostToGuest " +
        "\'#{@location}\' \'#{from}\' \'#{to}\'"
      system_command(vmrunstr)
    else
      scp_to(from, to)
    end
  end

  def check_file_exists(file)
    file = filter_input(file)
    if @tools
      vmrunstr = "vmrun -T ws -gu \'#{@vm_user}\' -gp \'#{@vm_pass}\' fileExistsInGuest " +
        "\'#{@location}\' \'#{file}\'"
      system_command(vmrunstr)
    else
      raise "Unsupported"
    end
  end

  def create_directory(directory)
    directory = filter_input(directory)
    if @tools
      vmrunstr = "vmrun -T ws -gu \'#{@vm_user}\' -gp \'#{@vm_pass}\' createDirectoryInGuest " +
          " \'#{@location}\' \'#{directory}\' "
      system_command(vmrunstr)
    else
      raise "Unsupported"
    end
  end

  def cleanup

  end

  def running?
    ## Get running Vms
    running = `vmrun list`
    running_array = running.split("\n")
    running_array.shift

    running_array.each do |vmx|
      if vmx.to_s == @location.to_s
        return true
      end
    end

    return false
  end

end

end 
end
