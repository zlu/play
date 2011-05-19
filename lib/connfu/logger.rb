require 'logger'

module Kernel
  def l
    @logger ||= Logger.new(STDOUT)
  end
end