require 'rexml/document'
require 'cucumber-feed/renderer'

module CucumberFeed
  class XML < Renderer
    attr :message, true

    def to_s
      return xml.to_s
    end

    private
    def xml
      raise 'messageが未定義です。' unless @message
      xml = REXML::Document.new
      xml.add(REXML::XMLDecl.new('1.0', 'UTF-8'))
      xml.add_element(REXML::Element.new('result'))
      status = xml.root.add_element('status')
      status.add_text(@message[:response][:status].to_s)
      message = xml.root.add_element('message')
      message.add_text(@message[:response][:message] || 'error')
      return xml
    end
  end
end
