require 'bitcoin_ticker'

class BitcoinInvoicesController < ApplicationController
  http_basic_authenticate_with name: BITPAY_API_KEY, password: "", :only => :connect
  
  respond_to :html, :json
  
  def create
    puts params.inspect
    if params['notificationURL'] =~ /.*\/(.*)/
      key = $1
    else
      key = nil
    end

    invoice = BitcoinInvoice.create(:invoice_id => SecureRandom.base64(32), 
                                    :price => params['price'],
                                    :currency => params['currency'],
                                    :pos_data => params['posData'],
                                    :invoice_url => "http://localhost:3030/api/payment/#{key}",
                                    :expiration_time => 15.minutes.from_now,
                                    :invoice_time => 30.seconds.ago,
                                    :notification_url => params['notificationURL'],
                                    :notification_key => key,
                                    :description => params['itemDesc'],
                                    :buyer_name => params['buyerName'],
                                    :physical => params['physical'],
                                    :transaction_speed => params['transactionSpeed'],
                                    :full_notifications => params['fullNotifications'],
                                    :btc_price => params['price'].to_f / BitcoinTicker.instance.current_rate)
    
    if invoice.save
      schedule_updates(invoice)
      
      render :json => get_json(invoice)
    else
      render :json => { :error => {:type => 'creation', :message => invoice.errors.full_messages.flatten } }      
    end                                
  end
  
  # Return status
  def show
    puts params.inspect
    
    invoice = BitcoinInvoice.find_by_invoice_id(params['id'])
    
    if invoice.nil?
      render :json => { :error => {:type => 'search', :message => "Invoice #{params['id']} not found" } }      
    else
      render :json => get_json(invoice)
    end
  end
  
  # Log in
  def connect
    render :text => 'Connected!'
  end
  
  # Display Bitcoin payment frame
  def payment
    @invoice = BitcoinInvoice.find_by_notification_key(params[:id])
    #if @invoice.status != BitcoinInvoice::NEW
    #  redirect_to root_path, :alert => 'Cannot pay more than once!' and return
    #end
  end
  
private
  def get_json(invoice)
    { 'id' => invoice.invoice_id,
      'url' => invoice.invoice_url,      
      #'url' => "http://localhost:3030/api/payment/#{invoice.notification_key}",
      'posData' => invoice.pos_data,
      'status' => invoice.status,
      'price' => invoice.price,
      'currency' => invoice.currency,
      'btcPrice' => invoice.btc_price,
      'invoiceTime' => invoice.invoice_time.to_i * 1000,
      'expirationTime' => invoice.expiration_time.to_i * 1000,
      'currentTime' => Time.now.to_i * 1000
    }.to_json    
  end
  
  def schedule_updates(invoice)
    if EXPIRED_STATUS_RESPONSE_AMT == invoice.price
      puts "Expiring #{invoice.notification_key}"
      invoice.update_status(BitcoinInvoice::EXPIRED)
    elsif INVALID_STATUS_RESPONSE_AMT == invoice.price
      puts "Invalidating #{invoice.notification_key}"
      invoice.update_status(BitcoinInvoice::INVALID)
    else
      if 'true' == invoice.full_notifications
        case invoice.transaction_speed
        when 'medium'
          invoice.delay.update_status(BitcoinInvoice::PAID)
          invoice.delay.update_status(BitcoinInvoice::CONFIRMED)
        when 'high'
          invoice.delay.update_status(BitcoinInvoice::CONFIRMED)
        else # default to 'low' if wrong
          puts "Paid #{invoice.notification_key}"
          invoice.delay.update_status(BitcoinInvoice::PAID)
        end
      end
      
      puts "Complete #{invoice.notification_key}"
      invoice.delay.update_status(BitcoinInvoice::COMPLETE)
    end
  end
end