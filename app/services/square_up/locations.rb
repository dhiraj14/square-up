module SquareUp
  class Locations < Base
    attr_reader :token

    def initialize(token)
      @token = token
    end

    def call
      response = Response.new(make_api_call)

      if response.success?
        response.body["locations"].map{|location| location["id"]}
      else
        response.errors
      end
    end

    private

    def method
      :get
    end

    def path
      "v2/locations".freeze
    end

    def payload
      {}
    end
  end
end
