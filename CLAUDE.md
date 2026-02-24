# CLAUDE.md

Guide for AI assistants working with the `ruby_coincheck_client` gem.

## Project Overview

Ruby client library for the [Coincheck](https://coincheck.com/) cryptocurrency exchange API. Published as a RubyGem (`ruby_coincheck_client`). Current version: **0.3.0**.

The gem wraps Coincheck's REST API with Ruby methods for trading, account management, and market data retrieval. It has zero runtime dependencies — only Ruby stdlib (`net/http`, `uri`, `openssl`, `json`).

## Repository Structure

```
lib/
  ruby_coincheck_client.rb              # Module definition, requires
  ruby_coincheck_client/
    coincheck_client.rb                 # Main CoincheckClient class (all API methods)
    version.rb                          # VERSION constant
spec/
  spec_helper.rb                        # RSpec + WebMock setup
  ruby_coincheck_client_spec.rb         # Module-level tests
  ruby_coincheck_client/
    coincheck_client_spec.rb            # Client integration tests (WebMock stubs)
examples/
  public.rb                             # Public API usage examples
  private.rb                            # Authenticated API usage examples
bin/
  console                               # IRB console with gem loaded
  setup                                 # Runs bundle install
```

## Build & Test Commands

```bash
# Install dependencies
bundle install

# Run tests (default Rake task)
bundle exec rake

# Run tests directly
bundle exec rspec

# Interactive console with gem loaded
bin/console

# Release (update version.rb first)
bundle exec rake release
```

## Test Setup

- **Framework**: RSpec (configured in `.rspec` with `--format documentation --color`)
- **HTTP mocking**: WebMock — all HTTP requests are stubbed in tests
- **Environment**: Dotenv for loading `.env` files (API keys for examples)
- **CI**: CircleCI v2 (`.circle.yml`) using `circleci/ruby:2.4.1-node-browsers`

Tests live in `spec/`. The existing tests cover public API methods (`read_trades`, `read_order_books`, `read_rate`) and one authenticated method (`read_balance`). Tests verify HTTP status codes and JSON response parsing.

## Architecture

### Single class design

All functionality lives in `CoincheckClient` (defined at top level, not namespaced under the module). The `RubyCoincheckClient` module only holds the `VERSION` constant.

### Constructor

```ruby
CoincheckClient.new(key, secret, params = {})
```

- `key`/`secret`: API credentials (nil for public endpoints)
- `params[:base_url]`: Override base URL (default: `https://coincheck.com/`)
- `params[:ssl]`: Toggle SSL (default: `true`)

### Method naming conventions

| Prefix      | HTTP verb | Purpose           |
|-------------|-----------|-------------------|
| `read_`     | GET       | Fetch data        |
| `create_`   | POST      | Create resources  |
| `delete_`   | DELETE    | Remove resources  |
| `cancel_`   | DELETE    | Cancel orders     |

### Public vs private API methods

- **Public methods** (no auth): `read_ticker`, `read_all_trades`, `read_rate`, `read_order_books`, `read_orders_rate`
- **Private methods** (require key/secret): Everything else — balance, orders, sends, bank accounts, withdrawals

### Authentication

Private endpoints use HMAC-SHA256 signatures via three headers:
- `ACCESS-KEY` — API key
- `ACCESS-NONCE` — Microsecond timestamp
- `ACCESS-SIGNATURE` — HMAC-SHA256 of `nonce + uri + body`

The `get_signature` private method handles this.

### HTTP layer

Private helper methods (`request_for_get`, `request_for_post`, `request_for_delete`) handle HTTP transport. All responses are parsed from JSON to Ruby hashes. The `custom_header` method adds `Content-Type: application/json` and a `User-Agent` header.

## Code Conventions

- **Indentation**: 2 spaces
- **Naming**: `snake_case` for methods and variables
- **Strings**: Single quotes preferred; double quotes for interpolation
- **Hash keys**: Symbols in method bodies, string keys in parsed JSON responses
- **Default pair**: Most methods default to `pair: "btc_jpy"`
- **Return values**: All API methods return parsed JSON (Ruby Hash/Array)
- **Class variables**: `@@base_url` and `@@ssl` (shared across instances)
- **No linter configured** — no RuboCop or similar tooling

## Dependencies

### Runtime

None — only Ruby stdlib.

### Development

- `bundler` (~> 1.9)
- `rake` (~> 10.0)
- `rspec`
- `dotenv`
- `webmock`

## Important Notes

- `.env` is gitignored — API keys must never be committed
- `lib/ruby_coincheck_client.rb` is in `.gitignore` (generated/overridden locally)
- SSL verification is disabled (`VERIFY_NONE`) in the HTTP layer
- The `create_orders` method references an undefined `position_id` variable (line 66 of `coincheck_client.rb`) — this is a known bug
- Tests call methods that don't exist on the current client (e.g., `read_trades` vs `read_all_trades`) and assert on raw response objects rather than parsed hashes — the test suite may need updates
