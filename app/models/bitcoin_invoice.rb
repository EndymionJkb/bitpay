# == Schema Information
#
# Table name: bitcoin_invoices
#
#  id                 :integer          not null, primary key
#  price              :decimal(, )
#  currency           :string(3)        default("USD")
#  pos_data           :string(255)
#  notification_url   :string(255)
#  invoice_id         :string(255)
#  invoice_url        :string(255)
#  buyer_name         :string(255)
#  physical           :boolean
#  description        :string(255)
#  transaction_speed  :string(255)
#  full_notifications :boolean
#  btc_price          :decimal(, )
#  invoice_time       :datetime
#  expiration_time    :datetime
#  status             :string(16)       default("new")
#  created_at         :datetime
#  updated_at         :datetime
#  notification_key   :string(255)
#
require 'net/http'

class BitcoinInvoice < ActiveRecord::Base
  include ApplicationHelper
  
  MAX_STATUS_LEN = 16
  
  NEW = 'new'
  PAID = 'paid'
  CONFIRMED = 'confirmed'
  COMPLETE = 'complete'
  EXPIRED = 'expired'
  INVALID = 'invalid'
  
  VALID_STATUSES = [NEW, PAID, CONFIRMED, COMPLETE, EXPIRED, INVALID]
  #attr_accessible :invoice_id, :price, :currency, :expiration_time, :invoice_time, :invoice_url, :notification_url, :pos_data, :btc_price,
  #                :buyer_name, :physical, :description, :transaction_speed, :full_notifications, :notification_key
  validates :status, :presence => true,
                     :inclusion => { :in => VALID_STATUSES }
  #validates :notification_url, :format => { with: URL_REGEX }
                    
  def update_status(status)
    # Update internal state
    self.update_attributes!(:status => status)
    
    # Post status update
    puts "Posting to #{self.notification_url}"
    uri = URI.parse(self.notification_url)    
    headers = {'Content-Type' => "application/json"}
    post_data = {:status => status}
    
    http = Net::HTTP.new(uri.host,uri.port)   # Creates a http object
    puts uri.inspect
    puts post_data
    
    response = http.post(uri.path, post_data.to_json, headers)
    puts response.inspect
    puts response.body.inspect unless response.body.nil?
  end
  #handle_asynchronously :update_status, :run_at => Proc.new { delay.in_time_zone }

private
  # Using a private method to encapsulate the permissible parameters is just a good pattern
  # since you'll be able to reuse the same permit list between create and update. Also, you
  # can specialize this method with per-user checking of permissible attributes.
  def invoice_params
    params.require(:price, :currency, :status, :notification_key).permit(:pos_data, :buyer_name, :physical, :description, :transaction_speed, :full_notifications)
  end
end
