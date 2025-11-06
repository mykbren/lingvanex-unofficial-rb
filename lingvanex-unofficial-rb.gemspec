# frozen_string_literal: true

require_relative 'lib/lingvanex/version'

Gem::Specification.new do |spec|
  spec.name = 'lingvanex-unofficial-rb'
  spec.version = Lingvanex::VERSION
  spec.authors = ['mykbren']
  spec.email = ['myk.bren@gmail.com']

  spec.summary = 'Unofficial Ruby wrapper for the Lingvanex Translation API'
  spec.description = 'An unofficial, simple Ruby gem for interacting with the Lingvanex Translation API. ' \
                     'Supports text translation, language detection, and HTML translation with 109+ languages.'
  spec.homepage = 'https://github.com/mykbren/lingvanex-unofficial-rb'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/mykbren/lingvanex-unofficial-rb'
  spec.metadata['changelog_uri'] = 'https://github.com/mykbren/lingvanex-unofficial-rb/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.glob('lib/**/*') + ['README.md', 'CHANGELOG.md', 'LICENSE', 'Rakefile']
  spec.require_paths = ['lib']
end
