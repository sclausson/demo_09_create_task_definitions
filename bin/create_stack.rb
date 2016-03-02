#!/usr/bin/env ruby
require 'trollop'
require 'aws-sdk-v1'

@opts = Trollop::options do
  opt :stackname, "Name of this CFN stack we are creating now", :type => String, :required => true, :short => "s"
  opt :template, "Name of the CFN template file", :type => String, :required => true, :short => "t"
  opt :region, "AWS region where the stack will be created", :type => String, :required => true, :short => "r"
end

AWS.config(region: @opts[:region])
cfn = AWS::CloudFormation.new

parameters = {}

def template
  file = "./templates/#{@opts[:template]}"
  body = File.open(file, "r").read
  return body
end

cfn.stacks.create(@opts[:stackname], template, parameters: parameters, capabilities: ["CAPABILITY_IAM"])

print "Waiting for stack #{@opts[:stackname]} to complete"

until cfn.stacks[@opts[:stackname]].status == "CREATE_COMPLETE"
  print "."
  sleep 5
end