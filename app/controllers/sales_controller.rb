class SalesController < ApplicationController
  def index
    if cookies['oauth_access_token']
      response = SquareUp::Sales.call(cookies['oauth_access_token'], params)
      if response.success?
        render json: { sales: response.data }
      elsif response.error?
        cookies.delete('oauth_access_token')
        render json: { sales: response.errors }
      end
    else
      redirect_to login_path
    end
  end
end
