Bitpay::Application.routes.draw do
  root :to => 'static_pages#home'

  get '/api/invoice/:id' => 'bitcoin_invoices#show'
  post '/api/invoice' => 'bitcoin_invoices#create'
  get '/api' => 'bitcoin_invoices#connect'
  
  get '/api/payment/:id' => 'bitcoin_invoices#payment'
end
