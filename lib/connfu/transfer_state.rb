module Connfu
  class TransferState
    def self.rejected
      new(:rejected)
    end

    def initialize(state)
      @state = state
    end

    def rejected?
      @state == :rejected
    end
  end
end