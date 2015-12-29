require 'net/http'
require 'uri'
require 'openssl'
require 'json'

class CoincheckClient
  @@base_url = "https://coincheck.jp/"
  @@ssl = true

  def initialize(key, secret, params = {})
    @key = key
    @secret = secret
    if !params[:base_url].nil?
      @@base_url = params[:base_url]
    end
    if !params[:ssl].nil?
      @@ssl = params[:ssl]
    end
  end

  def read_balance
    uri = URI.parse @@base_url + "api/accounts/balance"
    headers = get_signature(uri, @key, @secret)
    request_for_get(uri, headers)
  end

  def read_leverage_balance
    uri = URI.parse @@base_url + "api/accounts/leverage_balance"
    headers = get_signature(uri, @key, @secret)
    request_for_get(uri, headers)
  end

  def read_accounts
    uri = URI.parse @@base_url + "api/accounts"
    headers = get_signature(uri, @key, @secret)
    request_for_get(uri, headers)
  end

  def read_transactions
    uri = URI.parse @@base_url + "api/exchange/orders/transactions"
    headers = get_signature(uri, @key, @secret)
    request_for_get(uri, headers)
  end

  def read_positions(body = {})
    uri = URI.parse @@base_url + "api/exchange/leverage/positions"
    headers = get_signature(uri, @key, @secret, body.to_json)
    request_for_get(uri, headers, body)
  end

  def read_orders
    uri = URI.parse @@base_url + "api/exchange/orders/opens"
    headers = get_signature(uri, @key, @secret)
    request_for_get(uri, headers)
  end

  def create_orders(order_type:, rate: nil, amount: nil, market_buy_amount: nil, position_id: nil, pair: "btc_jpy")
    body = {
      rate: rate,
      amount: amount,
      market_buy_amount: market_buy_amount,
      order_type: order_type,
      position_id: position_id,
      pair: pair
    }
    uri = URI.parse @@base_url + "api/exchange/orders"
    headers = get_signature(uri, @key, @secret, body.to_json)
    request_for_post(uri, headers, body)
  end

  def delete_orders(id: )
    uri = URI.parse @@base_url + "api/exchange/orders/#{id}"
    headers = get_signature(uri, @key, @secret)
    request_for_delete(uri, headers)
  end

  def create_send_money(address:, amount:)
    body = {
      address: address,
      amount: amount,
    }
    uri = URI.parse @@base_url + "api/send_money"
    headers = get_signature(uri, @key, @secret, body.to_json)
    request_for_post(uri, headers, body)
  end

  def read_send_money(currency: "BTC")
    body = { currency: currency }
    uri = URI.parse @@base_url + "api/send_money"
    headers = get_signature(uri, @key, @secret, body.to_json)
    request_for_get(uri, headers, body)
  end

  def read_deposit_money(currency: "BTC")
    body = { currency: currency }
    uri = URI.parse @@base_url + "api/deposit_money"
    headers = get_signature(uri, @key, @secret, body.to_json)
    request_for_get(uri, headers, body)
  end

  def create_deposit_money_fast(id: )
    uri = URI.parse @@base_url + "api/deposit_money/#{id}/fast"
    headers = get_signature(uri, @key, @secret)
    request_for_delete(uri, headers)
  end

  def read_ticker
    uri = URI.parse @@base_url + "api/ticker"
    request_for_get(uri)
  end

  def read_trades
    uri = URI.parse @@base_url + "api/trades"
    request_for_get(uri)
  end

  def read_order_books
    uri = URI.parse @@base_url + "api/order_books"
    request_for_get(uri)
  end

  def read_bank_accounts
    uri = URI.parse @@base_url + "api/bank_accounts"
    headers = get_signature(uri, @key, @secret)
    request_for_get(uri, headers)
  end

  def create_bank_accounts(bank_name:, branch_name:, bank_account_type:, number:, name:)
    body = {
      bank_name: bank_name,
      branch_name: branch_name,
      bank_account_type: bank_account_type,
      number: number,
      name: name
    }
    uri = URI.parse @@base_url + "api/bank_accounts"
    headers = get_signature(uri, @key, @secret, body.to_json)
    request_for_post(uri, headers, body)
  end

  def delete_bank_accounts(id:)
    uri = URI.parse @@base_url + "api/bank_accounts/#{id}"
    headers = get_signature(uri, @key, @secret)
    request_for_delete(uri, headers)
  end

  def read_withdraws
    uri = URI.parse @@base_url + "api/withdraws"
    headers = get_signature(uri, @key, @secret)
    request_for_get(uri, headers)
  end

  def delete_withdraws(id:)
    uri = URI.parse @@base_url + "api/withdraws/#{id}"
    headers = get_signature(uri, @key, @secret)
    request_for_delete(uri, headers)
  end

  def create_borrows(amount:, currency:)
    body = {
      amount: amount,
      currency: currency
    }
    uri = URI.parse @@base_url + "api/lending/borrows"
    headers = get_signature(uri, @key, @secret, body.to_json)
    request_for_post(uri, headers, body)
  end

  def read_borrows
    uri = URI.parse @@base_url + "api/lending/borrows/matches"
    headers = get_signature(uri, @key, @secret)
    request_for_get(uri, headers)
  end

  def delete_borrows(id:)
    body = { id: id}
    uri = URI.parse @@base_url + "api/lending/borrows/#{id}/repay"
    headers = get_signature(uri, @key, @secret, body.to_json)
    request_for_post(uri, headers, body)
  end

  def transfer_to_leverage(amount:, currency: "JPY")
    body = {
      amount: amount,
      currency: currency
    }
    uri = URI.parse @@base_url + "api/exchange/transfers/to_leverage"
    headers = get_signature(uri, @key, @secret, body.to_json)
    request_for_post(uri, headers, body)
  end

  def transfer_from_leverage(amount:, currency: "JPY")
    body = {
      amount: amount,
      currency: currency
    }
    uri = URI.parse @@base_url + "api/exchange/transfers/from_leverage"
    headers = get_signature(uri, @key, @secret, body.to_json)
    request_for_post(uri, headers, body)
  end

  private
    def http_request(uri, request)
      https = Net::HTTP.new(uri.host, uri.port)
      if @@ssl
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      response = https.start do |h|
        h.request(request)
      end
    end

    def request_for_get(uri, headers = {}, body = nil)
      request = Net::HTTP::Get.new(uri.request_uri, initheader = headers)
      request.body = body.to_json if body
      http_request(uri, request)
    end

    def request_for_delete(uri, headers)
      request = Net::HTTP::Delete.new(uri.request_uri, initheader = headers)
      http_request(uri, request)
    end

    def request_for_post(uri, headers, body)
      request = Net::HTTP::Post.new(uri.request_uri, initheader = headers)
      request.body = body.to_json
      http_request(uri, request)
    end

    def get_signature(uri, key, secret, body = "")
      nonce = Time.now.to_i.to_s
      message = nonce + uri.to_s + body
      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), secret, message)
      headers = {
        "Content-Type" => "application/json",
        "ACCESS-KEY" => key,
        "ACCESS-NONCE" => nonce,
        "ACCESS-SIGNATURE" => signature
      }
    end
end
