module SquareUp
  class CreateToken < Base
    attr_reader :params, :code_verifier

    def initialize(params, code_verifier)
      @params = params
      @code_verifier = code_verifier
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
      'oauth2/token'.freeze
    end

    def redirect_uri
      "#{ENV['BASE_URL']}/authenticate"
    end

    def payload
      {
        client_id: ENV.fetch('SQUARE_UP_CLIENT_ID', nil),
        code_verifier: code_verifier,
        redirect_uri: redirect_uri,
        code: params[:code],
        grant_type: 'authorization_code'
      }
    end

    def headers
      {
        'Content-Type' => 'application/json'
      }
    end
  end
end
