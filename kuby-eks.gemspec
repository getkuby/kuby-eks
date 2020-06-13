$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'kuby/eks/version'

Gem::Specification.new do |s|
  s.name     = 'kuby-eks'
  s.version  = ::Kuby::EKS::VERSION
  s.authors  = ['Cameron Dutro']
  s.email    = ['camertron@gmail.com']
  s.homepage = 'http://github.com/getkuby/kuby-eks'

  s.description = s.summary = 'Amazon EKS provider for Kuby.'

  s.platform = Gem::Platform::RUBY

  s.add_dependency 'kube-dsl', '~> 0.1'
  s.add_dependency 'aws-sdk-eks', '~> 1.38'

  s.require_path = 'lib'
  s.files = Dir['{lib,spec}/**/*', 'Gemfile', 'LICENSE', 'CHANGELOG.md', 'README.md', 'Rakefile', 'kuby-eks.gemspec']
end
