require 'square'

module SquareUp
  class CreateToken < Base
    attr_reader :params, :code_verifier

    def initialize(params, code_verifier)
      @params = params
      @code_verifier = code_verifier
    end

    private

    def result
      @result ||= o_auth_api.obtain_token(body: payload)
    end

    def o_auth_api
      @o_auth_api ||= client.o_auth
    end

    def redirect_uri
      "#{ENV['BASE_URL']}/authenticate"
    end

    def payload
      {
        client_id: ENV.fetch('SQUARE_UP_CLIENT_ID', nil),
        redirect_uri: redirect_uri,
        code: params[:code],
        grant_type: 'authorization_code',
        code_verifier: code_verifier
      }
    end

    def token
      ENV.fetch('SQUARE_UP_APPLICATION_TOKEN', nil)
    end
  end
end
