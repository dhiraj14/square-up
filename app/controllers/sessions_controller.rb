class SessionsController < ApplicationController
  def login
    redirect_to(sales_path) and return if cookies['oauth_access_token'].present?

    url_generator = SquareUp::AuthorizationUrlGenerator.call
    cookies.delete('code_verifier')
    cookies['code_verifier'] = url_generator[:code_verifier]
    redirect_to url_generator[:url], allow_other_host: true
  end

  def authenticate
    cookies.delete('oauth_access_token')
    cookies.delete('oauth_refresh_token')

    if request.params.key?('error')
      render json: { error: request.params['error_description'] }
    else
      response = SquareUp::CreateToken.call(request.params, cookies['code_verifier'])
      if response.success?
        response = response.data
        cookies['oauth_access_token'] = response['access_token']
        cookies['oauth_refresh_token'] = response['refresh_token']
        redirect_to sales_path
      else
        redirect_to login_path
      end
    end
  end
end
