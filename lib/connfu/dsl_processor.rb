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
        case exp[3][0]
          when :vcall
            @handlers << exp[3][1]
          when :block
            size = exp[3].length - 1
            (1..size).each do |i|
              case exp[3][i][0]
                when :vcall
                  l.debug ':vcall'
                  @handlers << exp[3][i][1]
                when :fcall
                  l.debug ':fcall'
                  @handlers << {exp[3][i][1] => exp[3][i][2][1][1]}
                else
                  l.debug 'default'
              end
            end
        end
      end

      l.debug @handlers
      s(exp.shift, process(exp.shift), exp.shift, process(exp.shift))
    end
  end
end