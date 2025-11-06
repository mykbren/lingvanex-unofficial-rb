# Lingvanex (Unofficial Ruby Gem)

An unofficial Ruby gem for the [Lingvanex Translation API](https://lingvanex.com/products/translationapi/). Translate text between 109+ languages with automatic language detection, HTML translation, and transliteration support.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lingvanex-unofficial-rb'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install lingvanex-unofficial-rb
```

## Getting Started

### Obtaining an API Key

1. Sign up for an account at [Lingvanex](https://lingvanex.com/)
2. Navigate to the Cloud API tab
3. Fill out the billing address data
4. Complete the payment process to generate your API key

### Configuration

You can configure Lingvanex globally:

```ruby
require 'lingvanex'

Lingvanex.configure do |config|
  config.api_key = 'your_api_key_here'
  config.timeout = 30  # optional, defaults to 30 seconds
end
```

Or configure per-client:

```ruby
client = Lingvanex::Client.new(api_key: 'your_api_key_here')

# Or with a block
client = Lingvanex::Client.new do |config|
  config.api_key = 'your_api_key_here'
  config.timeout = 60
end
```

## Usage

### Translating Text

Basic translation with automatic language detection:

```ruby
client = Lingvanex.client(api_key: 'your_api_key')

result = client.translate('Hello, world!', to: 'es_ES')
puts result['result']  # => "¡Hola, mundo!"
```

Specify source language:

```ruby
result = client.translate('Hello, world!', from: 'en_GB', to: 'fr_FR')
puts result['result']  # => "Bonjour, le monde!"
```

Translate multiple texts at once:

```ruby
texts = ['Hello', 'Goodbye', 'Thank you']
result = client.translate(texts, to: 'de_DE')
# Returns translations for all texts
```

### HTML Translation

Preserve HTML structure while translating:

```ruby
html = '<h1>Welcome</h1><p>This is a <strong>paragraph</strong>.</p>'
result = client.translate(html, to: 'it_IT', translate_mode: 'html')
# HTML tags remain intact, only text content is translated
```

### Transliteration

Enable transliteration in the response:

```ruby
result = client.translate('Hello', to: 'uk_UA', enable_transliteration: true)
# Response includes transliteration fields
```

### Getting Available Languages

Fetch the list of supported languages:

```ruby
result = client.get_languages
puts result['result']
# => [
#   {"full_code"=>"en_GB", "name"=>"English"},
#   {"full_code"=>"es_ES", "name"=>"Spanish"},
#   ...
# ]
```

Get language names in a specific language:

```ruby
# Get language names in German
result = client.get_languages(code: 'de_DE')
```

## Language Codes

Language codes follow the format `language_COUNTRY`, for example:

- `en_GB` - English (UK)
- `en_US` - English (US)
- `es_ES` - Spanish (Spain)
- `fr_FR` - French (France)
- `de_DE` - German (Germany)
- `uk_UA` - Ukrainian (Ukraine)
- `zh_CN` - Chinese (Simplified)
- `ja_JP` - Japanese (Japan)

See the [Lingvanex documentation](https://docs.lingvanex.com/) for the complete list of supported languages.

## Error Handling

The gem provides specific error classes for different scenarios:

```ruby
begin
  client.translate('Hello', to: 'invalid_code')
rescue Lingvanex::AuthenticationError => e
  # Handle authentication errors (401)
  puts "Authentication failed: #{e.message}"
rescue Lingvanex::RateLimitError => e
  # Handle rate limiting (429)
  puts "Rate limit exceeded: #{e.message}"
rescue Lingvanex::InvalidRequestError => e
  # Handle invalid requests (400-499)
  puts "Invalid request: #{e.message}"
rescue Lingvanex::APIError => e
  # Handle other API errors
  puts "API error: #{e.message}"
  puts "Status code: #{e.status_code}"
  puts "Response body: #{e.response_body}"
end
```

Error hierarchy:

- `Lingvanex::Error` - Base error class
  - `Lingvanex::ConfigurationError` - Configuration errors
  - `Lingvanex::APIError` - API-related errors
    - `Lingvanex::AuthenticationError` - Authentication failures (401)
    - `Lingvanex::RateLimitError` - Rate limit exceeded (429)
    - `Lingvanex::InvalidRequestError` - Invalid request parameters (400-499)

## Advanced Configuration

### Custom Base URL

If you need to use a different API endpoint:

```ruby
Lingvanex.configure do |config|
  config.api_key = 'your_api_key'
  config.base_url = 'https://custom.api.endpoint'
end
```

### Timeout Configuration

Set custom timeout for API requests:

```ruby
client = Lingvanex::Client.new do |config|
  config.api_key = 'your_api_key'
  config.timeout = 60  # seconds
end
```

### Platform Configuration

The platform parameter is set to "api" by default, but can be customized:

```ruby
Lingvanex.configure do |config|
  config.api_key = 'your_api_key'
  config.platform = 'api'  # default value
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

### Running Tests

```bash
bundle exec rspec
```

### Running RuboCop

```bash
bundle exec rubocop
```

### Running All Checks

```bash
bundle exec rake  # runs both specs and rubocop
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mykbren/lingvanex-unofficial-rb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Resources

- [Lingvanex API Documentation](https://docs.lingvanex.com/)
- [Lingvanex Website](https://lingvanex.com/)

## Examples

### Simple Translation Script

```ruby
#!/usr/bin/env ruby
require 'lingvanex'

# Configure the gem
Lingvanex.configure do |config|
  config.api_key = ENV['LINGVANEX_API_KEY']
end

# Create a client
client = Lingvanex.client

# Translate some text
puts "Translating 'Hello, world!' to Spanish..."
result = client.translate('Hello, world!', to: 'es_ES')
puts result['result']

# Get available languages
puts "\nFetching available languages..."
languages = client.get_languages
puts "Total languages available: #{languages['result'].length}"
```

### Rails Integration

```ruby
# config/initializers/lingvanex.rb
Lingvanex.configure do |config|
  config.api_key = Rails.application.credentials.lingvanex_api_key
  config.timeout = 30
end

# app/services/translation_service.rb
class TranslationService
  def self.translate(text, target_language)
    client = Lingvanex.client
    result = client.translate(text, to: target_language)
    result['result']
  rescue Lingvanex::Error => e
    Rails.logger.error("Translation failed: #{e.message}")
    nil
  end
end
```

### Batch Translation

```ruby
require 'lingvanex'

client = Lingvanex.client(api_key: 'your_api_key')

# Translate multiple phrases
phrases = [
  'Good morning',
  'Good afternoon',
  'Good evening',
  'Good night'
]

result = client.translate(phrases, to: 'ja_JP')
puts result
```
