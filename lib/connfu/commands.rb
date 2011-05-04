require 'connfu'

module Connfu
  class Commands
    include Blather::DSL

    def answer
      p "answer is called"
    end

  end
end