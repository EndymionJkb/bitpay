class AddNotificationKeyToBitcoinInvoices < ActiveRecord::Migration
  def change
    add_column :bitcoin_invoices, :notification_key, :string
    
    add_index :bitcoin_invoices, :notification_key, :unique => true
  end
end
