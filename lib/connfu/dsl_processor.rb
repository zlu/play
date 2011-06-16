require 'parse_tree_extensions'

module Connfu
  class DslProcessor < SexpProcessor
    attr_accessor :handlers
    attr_accessor :ask_handler

    def initialize
      super
      self.strict = false
      self.auto_shift_type = false
      @handlers = []
      @ask_handler = []
    end

    def process_iter(exp)
      if exp[1][0] == :call && exp[1][2] == :on && !!exp[3]
        case exp[3][0]
          when :call
            arglist = exp[3][3][1]
            @handlers << (arglist.nil? ? exp[3][2] : {exp[3][2] => exp[3][3][1][1]})
          when :block
            size = exp[3].length - 1
            (1..size).each do |i|
              unless exp[3][i][0] == :iter
                @handlers << (exp[3][i][3][1].nil? ? exp[3][i][2] : {exp[3][i][2] => exp[3][i][3][1][1]})
              end
            end
          else
        end
      elsif exp[1][2] != :on
        exp[1][2]
        method = exp[1]
        method_name = method[2]
        prompt = method[3][1][1]
        lasgn = exp[2][1]
        body = Ruby2Ruby.new.process(exp[3])
        @handlers << {method_name => prompt}
        @ask_handler = {lasgn.to_s => body}
      end

      first = exp.shift
      second = exp.shift
      third = exp.shift
      exp.shift if exp == s(s())
      four = exp.shift
      s(first, process(second), third, process(four))
    end
  end
end
