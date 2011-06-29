module Connfu
  module Ozone
    def iq_from_command(command)
      command.to_iq
    end

    extend self
  end
end