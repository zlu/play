require 'connfu'

module Connfu
  class Offer < Blather::Stanza::Iq
    def self.new
      super(:set)
    end
  end
end

