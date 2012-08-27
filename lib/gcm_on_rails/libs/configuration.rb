
module Gcm
  module Configuration
    attr_accessor :api_url, :api_key, :app_name

    def configure
      yield self
    end

  end
end