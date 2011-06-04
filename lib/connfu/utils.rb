module Connfu
  module Utils
    def self.disco_items
      di_stanza = Blather::Stanza::DiscoItems.new(:get)
      di_helper(di_stanza)
    end

    def self.disco_info(identity)
      di_stanza = Blather::Stanza::DiscoInfo.new(:get)
      di_stanza.to = identity
      di_helper(di_stanza)
    end

    def self.di_helper(di_stanza)
      l.info 'Sending to server'
      l.info di_stanza
      l.info '==============>'
      write_to_stream(di_stanza)
    end

    def self.underscore(camel_cased_word)
      word = camel_cased_word.to_s.dup
      word.gsub!(/::/, '/')
      word.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end
  end
end
