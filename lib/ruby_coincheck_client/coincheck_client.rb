require 'net/http'
require 'uri'
require 'openssl'
require 'json'

class CoincheckClient
  BASE_URL = "https://coincheck.jp/"

  def initialize(key, secret)
    @key = key
    @secret = secret
  end

  def read_balance
    uri = URI.parse BASE_URL + "api/accounts/balance"
    headers = get_signature(uri, @key, @secret)
    request_for_get(uri, headers)
  end

  def read_accounts
    uri = URI.parse BASE_URL + "api/accounts"
    headers = get_signature(uri, @key, @secret)
    request_for_get(uri, headers)
  end

  def read_transactions
    uri = URI.parse BASE_URL + "api/exchange/orders/transactions"
    headers = get_signature(uri, @key, @secret)
    request_for_get(uri, headers)
  end

  def read_orders
    uri = URI.parse BASE_URL + "api/exchange/orders/opens"
    headers = get_signature(uri, @key, @secret)
    request_for_get(uri, headers)
  end

  def create_orders(rate, amount, order_type, pair = "btc_jpy")
    body = {
      rate: rate,
      amount: amount,
      order_type: order_type,
      pair: pair
    }
    uri = URI.parse BASE_URL + "api/exchange/orders"
    headers = get_signature(uri, @key, @secret, body.to_json)
    request_for_post(uri, headers, body)
  end

  def delete_orders(id)
    body = {
      id: id,
    }
    uri = URI.parse BASE_URL + "api/exchange/orders/#{id}"
    headers = get_signature(uri, @key, @secret)
    request_for_delete(uri, headers)
  end

  def create_send_money(address, amount)
    body = {
      address: address,
      amount: amount,
    }
    uri = URI.parse BASE_URL + "api/send_money"
    headers = get_signature(uri, @key, @secret, body.to_json)
    request_for_post(uri, headers, body)
  end

  private
    def http_request(uri, request)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE

      response = https.start do |h|
        h.request(request)
      end
    end

    def request_for_get(uri, headers)
      request = Net::HTTP::Get.new(uri.request_uri, initheader = headers)
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
