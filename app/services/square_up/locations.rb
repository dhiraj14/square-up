module SquareUp
  class Locations < Base
    attr_reader :token

    def initialize(token)
      @token = token
    end

    private

    def result
      locations_api.list_locations
    end

    def locations_api
      @locations_api ||= client.locations
    end
  end
end
