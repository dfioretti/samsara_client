module SamsaraClient
  class Response
    def initialize(raw_response, unwrap: true, path: nil)
      @raw = raw_response
      @unwrap = unwrap
      @path = path
    end

    # If a path is specified, traverse the nested structure
    # Otherwise, use the original unwrapping behavior
    def payload
      return @raw unless @unwrap

      if @path
        current_data = @raw
        @path.split(".").each do |key|
          # Handle array indices
          current_data = if /^\d+$/.match?(key)
                           current_data[key.to_i]
                         # Handle hash keys
                         else
                           current_data[key] || current_data[key.to_sym]
                         end
          return nil if current_data.nil?
        end
        current_data
      elsif @raw.is_a?(Hash) && @raw.key?("data")
        @raw["data"]
      else
        @raw
      end
    end

    # Enables hash-style access.
    delegate :[], to: :payload

    # Delegate missing method calls to the payload.
    def method_missing(method, *args, &block)
      if payload.respond_to?(method)
        payload.send(method, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      payload.respond_to?(method, include_private) || super
    end

    def to_h
      payload
    end

    # Returns the full raw response (bypassing any auto-unwrapping).
    attr_reader :raw
  end
end
