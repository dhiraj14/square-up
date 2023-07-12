module SquareUp
  class Sales < Base
    attr_reader :token, :params

    def initialize(token, params)
      @token = token
      @params = params
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
      "v2/orders/search".freeze
    end

    def query
      {
       filter: {
          date_time_filter: {
            closed_at: {
              start_at: params[:start_at] || 10.days.ago,
              end_at: params[:end_at] || DateTime.now,
            }
          },
          state_filter: {
            states: ["COMPLETED"]
          }
        },
        sort: {
          sort_field: "CLOSED_AT",
          sort_order: "DESC"
        }
      }
    end

    def location_ids
      Locations.call(token)
    end

    def payload

      {
        location_ids: location_ids,
        query: query,
      }
    end
  end
end
