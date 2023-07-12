module SquareUp
  class Base < ApplicationService
    def call
      result
    end

    private

    def client
      @client ||= Square::Client.new(
        access_token: token,
        environment: ENV.fetch('SQUARE_UP_ENVIRONMENT', nil)
      )
    end
  end
end
