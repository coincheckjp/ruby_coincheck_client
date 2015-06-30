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
response = cc.read_balance()
response = cc.read_accounts()
response = cc.read_transactions
response = cc.read_orders
response = cc.create_orders("40001", "0.01", "sell")
response = cc.delete_orders("2503344")
response = cc.create_send_money("136aHpRdd7eezbEusAKS2GyWx9eXZsEuMz", "0.0005")
response = cc.read_ticker
response = cc.read_order_books
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
