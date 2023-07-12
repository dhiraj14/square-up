class SalesController < ApplicationController
  def index
    if cookies['oauth_access_token']
      response = SquareUp::Sales.call(cookies['oauth_refresh_token'], params)

      if response[:error].present?
        response = SquareUp::RefreshToken.call(cookies['oauth_refresh_token'])
        cookies['oauth_access_token'] = response['access_token']
        cookies['oauth_refresh_token'] = response['refresh_token']
        sales = SquareUp::Sales.call(cookies['oauth_access_token'], params)
        render json: { sales: sales }
      else
        render json: { sales: response }
      end
    else
      redirect_to login_path
    end
  end
end
