class SalesController < ApplicationController
  def index
    response = SquareUp::Sales.call(cookies["oauth_access_token"], params)
    render json: { sales: response }
  end
end
