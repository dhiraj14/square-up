module SquareUp
  class Base < ApplicationService
    private

    def base_url
      ENV["SQUARE_UP_BASE_URL"]
    end

    def url
      base_url + path
    end

    def path
      raise "Implement in child class"
    end

    def payload
      raise "Implement in child class"
    end

    def method
      :post
    end

    def make_api_call
      api_call.execute
    end

    def api_call
      ::ApiCall.new(
        url: url,
        method: method,
        body: request_body,
        headers: headers
      )
    end

    def request_body
      payload.to_json
    end

    def headers
      {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "Authorization" => "Bearer #{token}"
      }
    end
  end
end
