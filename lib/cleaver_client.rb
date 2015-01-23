%w{rest_client json}.each { |lib| require lib }

class Hash
  def not_nils!
    reject! { |k, v| v.nil? }
  end
end

module RestClient2
  include RestClient

  def self.get(url, headers={}, &block)
    Request.execute(:method => :get, :url => url, :headers => headers,
                    :timeout => nil, :open_timeout => nil, &block)
  end

  def self.post(url, payload, headers={}, &block)
    Request.execute(:method => :post, :url => url, :payload => payload, :headers => headers,
                    :timeout => nil, :open_timeout => nil, &block)
  end
end

#This class creates a new cleaver client instance
class CleaverClient

  # Cleaver Api Error class
  class ApiError < StandardError
  end

  # Create a new connector instance
  def initialize(login, password)
    @token = nil
    @api_url = 'https://cleaver.facetz.net/API/REST'
    @login, @password = login, password
  end

  # Perform a login with login and password
  def login
    response = post "login", Username: @login, Password: @password
    @token = response['Token']
  end

  # Perform logout
  def logout(options = {})
    require_auth!
    get "#{@token}/logout", options
  end

  # Get available fields
  def get_fields(options = {})
    require_auth!
    get "person/#{@token}/fields", options
  end

  # Get data
  def get_data(options = {})
    require_auth!
    post "person/#{@token}/reports/Traffic/data/0/10000", options
  end

  # Pass post, get, delete, put and patch to the request method
  def method_missing(method_name, *arguments, &block)
    if method_name.to_s =~ /(post|get|put|patch|delete)/
      request($1.to_sym, *arguments, &block)
    else
      super
    end
  end

  # Let class instance respond to post, get, delete, put and patch
  def respond_to?(method_name, *arguments, &block)
    !!method_name.to_s.match(/(post|get|put|patch|delete)/) || super
  end

  def to_s
    "#{@login}"
  end

  private
  # Generic request method
  def request(strategy, uri, data)
    if strategy == :get
      response = RestClient.get "#{@api_url}/#{uri}", params: data.to_json, :content_type => :json, :accept => :json
    else
      p strategy
      p "#{@api_ur}/#{uri}/"
      p data.to_json
      response = RestClient2.send strategy, "#{@api_url}/#{uri}/", data.to_json, :content_type => :json, :accept => :json
    end
    response = JSON.parse response
    response
  end

  def session_created?
    @token != nil
  end

  def require_auth!
    raise ApiError, "Must be logged in to log out" unless session_created?
  end

end
