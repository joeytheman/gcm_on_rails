
module Gcm
  class Configuration
    attr_accessor :api_url, :api_key, :app_name

  end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield configuration if block_given?

  end

end