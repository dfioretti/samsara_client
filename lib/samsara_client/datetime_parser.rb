module SamsaraClient
  module DateTimeParser
    # Parses a Unix timestamp or a datetime string into a Ruby DateTime in UTC.
    def self.parse(datetime_value)
      dt = nil
      if datetime_value.is_a?(Numeric)
        # Force UTC conversion and set offset to zero.
        dt = Time.at(datetime_value).utc.to_datetime.new_offset(0)
      elsif datetime_value.is_a?(String)
        begin
          dt = DateTime.iso8601(datetime_value)
        rescue ArgumentError
          dt = DateTime.parse(datetime_value)
        end
        dt = dt.new_offset(0) if dt
      end

      if dt
        # Define a singleton override for iso8601 so that it returns a "Z"-based string.
        def dt.iso8601(*args)
          # Use Ruby's own iso8601 then substitute +00:00 with Z.
          super(*args).sub(/\+00:00\z/, 'Z')
        end
      end

      dt
    end

    # Formats an object (Date, Time, DateTime, Numeric, or a date/time string) into an RFC3339 string.
    def self.format(datetime_value)
      if datetime_value.respond_to?(:to_time)
        t = datetime_value.to_time.utc
        if t.respond_to?(:iso8601)
          t.iso8601.sub(/\+00:00\z/, 'Z')
        else
          t.strftime("%Y-%m-%dT%H:%M:%SZ")
        end
      else
        dt = parse(datetime_value)
        if dt
          t = dt.to_time.utc
          if t.respond_to?(:iso8601)
            t.iso8601.sub(/\+00:00\z/, 'Z')
          else
            t.strftime("%Y-%m-%dT%H:%M:%SZ")
          end
        else
          nil
        end
      end
    end

    # Convert a datetime to unix time
    def self.format_unix(datetime_value)
      (datetime_value.to_f * 1000).to_i
    rescue StandardError
      nil
    end
  end
end
