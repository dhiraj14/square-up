module SquareUp
  class Sales < Base
    attr_reader :token, :params

    def initialize(token, params)
      @token = token
      @params = params
    end

    private

    def result
      orders_api.search_orders(body: request_body)
    end

    def orders_api
      @orders_api ||= client.orders
    end

    def request_body
      query.merge({ location_ids: location_ids })
    end

    def location_ids
      location_response = SquareUp::Locations.call(token)
      if location_response.success?
        location_response.data['locations'].map { |location| location[:id] }
      elsif location_response.error?
        []
      end
    end

    def query
      {
        filter: {
          date_time_filter: {
            closed_at: {
              start_at: params[:start_at]&.to_datetime || 10.days.ago,
              end_at: params[:end_at]&.to_datetime || DateTime.now
            }
          },
          state_filter: {
            states: ['COMPLETED']
          }
        },
        sort: {
          sort_field: 'CLOSED_AT',
          sort_order: 'DESC'
        }
      }
    end
  end
end
