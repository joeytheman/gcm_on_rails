module Gcm
  class Base < ActiveRecord::Base   #nodoc
    self.abstract_class = true
    attr_accessor :api_url, :api_key, :app_name
  end
end