module SquareUp
  class RefreshToken < Base
    attr_reader :refresh_token

    def initialize(refresh_token)
      @refresh_token = refresh_token
    end

    def call
      response = Response.new(make_api_call)
      if response.success?
        response.body
      else
        response.errors
      end
    end

    private

    def path
      "oauth2/token".freeze
    end

    def redirect_uri
      "#{ENV['BASE_URL']}/authenticate"
    end

    def payload
      {
        client_id: ENV.fetch("SQUARE_UP_CLIENT_ID", nil),
        redirect_uri: redirect_uri,
        refresh_token: refresh_token,
        grant_type: "refresh_token"
      }
    end

    def headers
      {
        'Content-Type' => 'application/json',
      }
    end

  end
end
