# RubyCoincheckClient

This is ruby client implementation for Coincheck API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby_coincheck_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby_coincheck_client

## Usage

```ruby
#!/usr/bin/env ruby -Ilib
require 'ruby_coincheck_client'

cc = CoincheckClient.new("YOUR API KEY", "YOUR SECRET KEY")
response = cc.read_balance
response = cc.read_leverage_balance
response = cc.read_accounts
response = cc.read_transactions
response = cc.read_positions
response = cc.read_orders
response = cc.create_orders(rate: "40001", amount: "0.01", order_type: "buy")
response = cc.create_orders(rate: "50001", amount: "0.001", order_type: "sell")
response = cc.create_orders(market_buy_amount: 100, order_type: "market_buy")
response = cc.create_orders(amount: "0.001", order_type: "market_sell")
response = cc.create_orders(rate: "40000", amount: "0.001", order_type: "leverage_buy")
response = cc.create_orders(rate: "60000", amount: "0.001", order_type: "leverage_sell")
response = cc.create_orders(rate: "60000", amount: "0.001", position_id: "2222", order_type: "close_long")
response = cc.create_orders(rate: "40000", amount: "0.001", position_id: "2222", order_type: "close_short")
response = cc.delete_orders(id: "2503344")
response = cc.create_send_money(address: "136aHpRdd7eezbEusAKS2GyWx9eXZsEuMz", amount: "0.0005")
response = cc.read_send_money
response = cc.read_deposit_money
response = cc.create_deposit_money_fast(id: "2222")
response = cc.read_ticker
response = cc.read_trades
response = cc.read_order_books
response = cc.read_bank_accounts
response = cc.delete_bank_accounts(id: "2222")
response = cc.read_withdraws
response = cc.delete_withdraws
response = cc.create_borrows(amount: "0.001", currency: "BTC")
response = cc.read_borrows
response = cc.delete_borrows(id: "58606")
response = cc.transfer_to_leverage(amount: "1000")
response = cc.transfer_from_leverage(amount: "1000")
JSON.parse(response.body)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/yuma300/ruby_coincheck_client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
