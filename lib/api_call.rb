class ApiCall
  attr_accessor :state, :request_method, :headers, :request_body, :available_attempts, :url,
                :error_message, :success_message, :response

  REQUEST_OPEN_READ_TIMEOUT_IN_SECONDS = 300
  STATES_FOR_EXECUTION = %i[retry new].freeze

  def initialize(args = {})
    @state = :new
    @url = args[:url]
    @request_method = args[:method]
    @request_body = args[:body]
    @available_attempts = args[:available_attempts] || 1
    @headers = args[:headers] || default_headers
  end

  def retry
    return unless available_attempts?

    @state = :retry
    @available_attempts = available_attempts - 1
  end

  def available_attempts?
    available_attempts.to_i.positive?
  end

  def execute(options = {})
    return unless STATES_FOR_EXECUTION.include?(state.try(:to_sym))

    @response = faraday(options).run_request(
      request_method.to_sym,
      path,
      request_body,
      headers
    )

    handle_response
    @response
  rescue StandardError => e
    write_error "#{e.message}\n\n#{e.backtrace.join("\n")}"
  end

  private

  def faraday(options = {})
    params = if Rails.env.test? || Rails.env.development?
               { timeout: 10, open_timeout: 10 }
             else
               { timeout: REQUEST_OPEN_READ_TIMEOUT_IN_SECONDS }
             end

    @faraday ||= Faraday.new(options.merge(url: host, request: params))
    @faraday
  end

  def default_headers
    {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end

  def host
    @host ||= URI.join(url, '/').to_s
  end

  def path
    @path = uri(url).path
    query_params = uri(url).query
    @path += "?#{query_params}" if query_params.present?
    @path
  end

  def query_params
    params = URI(url).query
    params.nil? ? nil : "?#{params}"
  end

  def uri(url)
    @uri ||= URI(url)
  end

  def write_error(message)
    @error_message = message
    @state = :failed
  end

  def write_success(message)
    @state = :sent
    @success_message = message
  end

  def handle_response
    response_success = response.status >= 200 && response.status <= 299
    response_body = response.body
    response_status = response.status
    if response_success
      write_success response_body.to_s
    else
      write_error "Server returned #{response_status}:\n\n#{response_body}"
    end
  end
end
