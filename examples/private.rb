require_relative '../lib/ruby_coincheck_client'
require 'dotenv'
Dotenv.load ".env"

cc = CoincheckClient.new(ENV['API_KEY'], ENV['SECRET_KEY'])
puts cc.read_balance.body
puts cc.read_leverage_balance.body
puts cc.read_accounts.body
puts cc.read_transactions.body
puts cc.read_positions(status: 'open').body
puts cc.read_positions.body
puts cc.read_trades().body
puts cc.read_page_transactions.body
puts cc.read_page_transactions(limit: 5, order: "asc", starting_after: 100, ending_before: 50).body
