module Connfu
  class Call
    attr_accessor :to
    attr_accessor :state

    def initialize(number)
      @to = number
    end
  end
end