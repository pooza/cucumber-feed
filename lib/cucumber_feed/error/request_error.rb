module CucumberFeed
  class RequestError < Error
    def status
      return 400
    end
  end
end
