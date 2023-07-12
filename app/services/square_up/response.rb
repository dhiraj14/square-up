module SquareUp
  class Response
    attr_reader :raw_body

    def initialize(response)
      @response = response
      @raw_body = response.body
    end

    def body
      @body ||= @response.success? && parse
    end

    def success?
      @response.success?
    end

    def errors
      { error: parse['message'] || parse['errors'] }
    end

    def original_response
      @response
    end

    private

    def parse
      JSON.parse(@raw_body)
    end
  end
end
