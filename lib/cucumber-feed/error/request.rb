module CucumberFeed
  class RequestError < ::StandardError
    def status
      return 400
    end
  end
end
