# lib/samsara_api/client.rb

require "net/http"
require "uri"
require "json"

module SamsaraClient
  class Api
    def initialize(api_key, base_url = "https://api.samsara.com")
      @api_key = api_key
      @base_url = base_url
      @default_headers = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@api_key}"
      }
    end

    # General method for executing HTTP requests.
    def request(method, endpoint, data: nil, params: {}, unwrap: true, path: nil)
      uri = URI.join(@base_url, endpoint)
      uri.query = URI.encode_www_form(params) if params && params.any?

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")

      req = case method.upcase
            when "GET"    then Net::HTTP::Get.new(uri)
            when "POST"   then Net::HTTP::Post.new(uri)
            when "PUT"    then Net::HTTP::Put.new(uri)
            when "DELETE" then Net::HTTP::Delete.new(uri)
            else
              raise ArgumentError, "Unsupported HTTP method: #{method}"
            end

      @default_headers.each { |key, value| req[key] = value }
      req.body = data.to_json if data

      response = http.request(req)
      case response.code.to_i
      when 200...300
        parsed = JSON.parse(response.body)
        Response.new(parsed, unwrap: unwrap, path: path)
      else
        raise "HTTP Error #{response.code}: #{response.body}"
      end
    end

    # Convenience wrapper for GET requests.
    def get(path, params: {}, unwrap: true)
      request("GET", path, params: params, unwrap: unwrap)
    end

    # Convenience wrapper for POST requests.
    def post(path, data: nil, params: {}, unwrap: true)
      request("POST", path, data: data, params: params, unwrap: unwrap)
    end

    # Convenience wrapper for PUT requests.
    def put(path, data: nil, params: {}, unwrap: true)
      request("PUT", path, data: data, params: params, unwrap: unwrap)
    end

    # Convenience wrapper for DELETE requests.
    def delete(path, params: {}, unwrap: true)
      request("DELETE", path, params: params, unwrap: unwrap)
    end

    # Example explicit endpoint wrappers—these are optional.
    def get_drivers(limit: 512, offset: 0, unwrap: true)
      endpoint = "/fleet/drivers"
      params = { limit: limit, offset: offset }
      get(endpoint, params: params, unwrap: unwrap)
    end

    def get_driver(driver_id, unwrap: true)
      endpoint = "/fleet/drivers/#{driver_id}"
      get(endpoint, unwrap: unwrap)
    end

    def get_vehicles(limit: 512, offset: 0, unwrap: true)
      endpoint = "/fleet/vehicles"
      params = { limit: limit, offset: offset }
      get(endpoint, params: params, unwrap: unwrap)
    end

    def get_address(samsara_id, params: {}, unwrap: true)
      endpoint = "/addresses/#{samsara_id}"
      get(endpoint, params: params, unwrap: unwrap)
    end

    def get_vehicle_trips(vehicle_id, start_time, end_time, unwrap: true)
      endpoint = "/v1/fleet/trips"
      params = {
        startMs: DateTimeParser.format_unix(start_time),
        endMs: DateTimeParser.format_unix(end_time),
        vehicleId: vehicle_id
      }

      query = URI.encode_www_form(params)

      get("#{endpoint}?#{query}", params: {}, unwrap: unwrap)["trips"]
    end

    def get_hos_logs(driver_ids, start_time, end_time, unwrap: true)
      endpoint = "/fleet/hos/logs"
      params = {
        driverIds: Array(driver_ids).join(","),
        startTime: DateTimeParser.format(start_time),
        endTime: DateTimeParser.format(end_time)
      }
      get(endpoint, params: params, unwrap: unwrap)
    end
  end
end
