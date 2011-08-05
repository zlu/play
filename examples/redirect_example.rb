#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

Connfu.start do
  on :offer do |call|
    redirect('sip:16508983130@127.0.0.1')
  end
end