module Connfu
  class Call
    attr_accessor :to
    attr_accessor :state

    def self.update_state(node, state)
      from = node.attributes['from'].value
      call = Connfu.outbound_calls[from]
      call.state = state
    end

    def initialize(number)
      @to = number
    end
  end
end