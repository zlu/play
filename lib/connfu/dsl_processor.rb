module Connfu
  class DslProcessor < SexpProcessor
    attr_reader :handlers
    def initialize
      super
      self.strict = false
      self.auto_shift_type = false

      @handlers = []
    end

    def process_iter(exp)
      l.debug exp
      l.debug exp[1]
      if exp[1][0] == :fcall && exp[1][1] == :on
        l.debug exp[3]
        if exp[3][0] == :vcall
          @handlers << exp[3][1]
        end
      end

      s(exp.shift, process(exp.shift), exp.shift, process(exp.shift))
    end
  end
end