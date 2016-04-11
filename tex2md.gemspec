# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tex2md/version'

Gem::Specification.new do |spec|
  spec.name           = 'tex2md'
  spec.summary        = 'Translate DBP TeX files to markdown'
  spec.description    = %q[Translate Driscoll Brook Press TeX files to markdown]
  spec.platform       = Gem::Platform::RUBY
  spec.version        = TeX2md::VERSION
  spec.authors        = ['Dale Emery']
  spec.email          = ['dale@dhemery.com']
  spec.homepage       = 'https://github.com/driscoll-brook-press/tex2md/'
  spec.license        = 'MIT'

  spec.files          = Dir['bin/**/*', 'lib/**/*', 'data/**/*']
  spec.executables    = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files     = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths  = ['lib']

  spec.add_runtime_dependency 'rake', '~> 11.0'
  spec.add_runtime_dependency 'nokogiri', '~> 1.6'
  spec.add_development_dependency 'minitest-reporters', '~> 1.0', '>= 1.0.8'
end
