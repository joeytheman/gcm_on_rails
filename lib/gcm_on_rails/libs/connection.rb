require 'net/https'
require 'uri'

module Gcm
  module Connection
    class << self
      def send_notification(notification, api_key)
        url_string = configatron.gcm_on_rails.api_url
        url = URI.parse url_string
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        headers = {"Authorization" => "key=#{api_key}", "Content-Type" => "application/json"}

        data = {}
        data[:data] = notification.data
        data[:collapse_key] = notification.collapse_key if notification.collapse_key
        data[:delay_while_idle] = notification.delay_while_idle if notification.delay_while_idle
        data[:time_to_live] = notification.time_to_live if notification.time_to_live
        data[:registration_ids] = notification.not_sent_devices.pluck(:registration_id)
        resp = http.post(url.path, data.to_json, headers)

        {code: resp.code.to_i, message: resp.body }
      end

      def open
        configatron.gcm_on_rails.api_key
      end
    end
  end
end