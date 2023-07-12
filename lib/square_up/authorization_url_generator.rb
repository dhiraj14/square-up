module SquareUp
  class AuthorizationUrlGenerator
    CHAR_LENGTH = 48
    CODE_CHALLENGE_METHOD = "S256"

    def self.call(...)
      new(...).call
    end

    def call
      { url: generate_uri, code_verifier: code_verifier }
    end

    private

    def generate_uri
      uri = URI(oauth_url)
      uri.query = query_params.to_query
      uri.to_s
    end

    def code_verifier
      @code_verifier ||= generate_base64_encoded_string
    end

    def state
      @state ||= generate_base64_encoded_string
    end

    def code_challenge
      @code_challenge ||= urlsafe_base64(Digest::SHA256.base64digest(code_verifier))
    end

    def generate_base64_encoded_string
      urlsafe_base64(SecureRandom.base64((CHAR_LENGTH * 3) / 4))
    end

    def urlsafe_base64(base64_str)
      base64_str.tr("+/", "-_").tr("=", "")
    end

    def scopes
      ["MERCHANT_PROFILE_READ", "ORDERS_READ"]
    end

    def oauth_url
      "#{ENV['SQUARE_UP_BASE_URL']}/oauth2/authorize"
    end

    def redirect_uri
      "#{ENV['BASE_URL']}/authenticate"
    end

    def query_params
        {
          code_challenge: code_challenge,
          code_challenge_method: CODE_CHALLENGE_METHOD,
          state: state,
          client_id: ENV.fetch("SQUARE_UP_CLIENT_ID", nil),
          redirect_uri: redirect_uri,
          response_type: "code",
          scope: scopes
        }
    end
  end
end
