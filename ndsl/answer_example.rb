require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"

class Connfu::Handler
  ['accept', 'answer', 'hangup', 'reject'].each do |call_command|
    define_method :"#{call_command}_iq" do
      iq = Blather::Stanza::Iq.new(:set, Connfu.context.values.first.from)
      iq['from'] = Connfu.context.values.first.to
      Nokogiri::XML::Builder.with(iq) do |xml|
        xml.send call_command, {"xmlns" => "urn:xmpp:ozone:1"}
      end

      iq
    end
  end

  def say_iq(saying)
    # p Connfu.context.values
    iq = Blather::Stanza::Iq.new(:set, Connfu.context.values.first.from.to_s)
    Nokogiri::XML::Builder.with(iq) do |xml|
      xml.say_("xmlns" => "urn:xmpp:ozone:say:1") {
        xml.text saying
      }
    end

    iq
  end

  def answer
    write answer_iq 
  end

  def say(saying)
    write say_iq(saying)
    wait
  end
  
  def continue
    if c = continuations.pop
      c.call
    end
  end

  private

  def continuations
    @continuations ||= []
  end

  def wait
    callcc do |cc|
      continuations << cc
      throw :finished
    end
  end

  def write(iq)
    p :sending, iq
    Connfu.connection.write iq
  end
end

class AnswerExample < Connfu::Handler
  def on_offer
    answer
    say "Turn the volume up a little bit now"
    puts "Finished"
  end
end

Connfu.start