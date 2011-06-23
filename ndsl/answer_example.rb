require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"

class Connfu::Handler
  include Connfu::CallCommands

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

  def say_iq(text)
    iq = Blather::Stanza::Iq.new(:set, Connfu.context.values.first.from.to_s)
    Nokogiri::XML::Builder.with(iq) do |xml|
      xml.say_("xmlns" => "urn:xmpp:ozone:say:1") {
        unless text.match(/^http:\/\/.*(.mp3|.wav)$/).nil?
          xml.audio('src' => text)
        else
          xml.text text
        end
      }
    end

    iq
  end

  def answer
    write answer_iq
  end

  def say(text)
    write say_iq(text)
  end

  private

  def write(iq)
    p iq
    Connfu.connection.write say_iq(iq)
  end
end

class AnswerExample < Connfu::Handler
  def on_offer
    answer
    say "Hello Tom"
  end
end

Connfu.start