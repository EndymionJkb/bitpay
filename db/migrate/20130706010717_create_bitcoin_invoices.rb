class CreateBitcoinInvoices < ActiveRecord::Migration
  def change
    create_table :bitcoin_invoices do |t|
      t.decimal :price
      t.string :currency, :limit => 3, :default => 'USD'
      t.string :pos_data
      t.string :notification_url
      t.string :invoice_id
      t.string :invoice_url
      t.string :buyer_name
      t.boolean :physical
      t.string :description
      t.string :transaction_speed
      t.boolean :full_notifications
      t.decimal :btc_price
      t.datetime :invoice_time
      t.datetime :expiration_time
      t.string :status, :limit => BitcoinInvoice::MAX_STATUS_LEN, :default => BitcoinInvoice::NEW

      t.timestamps
    end
  end
end
