#!/usr/bin/env ruby
require 'pry'
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/lab/vm_controller"

@controller = Lab::Controllers::VmController.new
@controller.from_file("#{File.expand_path(File.dirname(__FILE__))}/../config/test_lab.yml")

ENV['SSL_CERT_FILE'] = "/home/jcran/.cacert.pem"

Pry.start(self, :prompt => [proc{"lab (@controller) >"}])
