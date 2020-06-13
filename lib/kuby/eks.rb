require 'kuby'
require 'kuby/eks/provider'

module Kuby
  module EKS
    autoload :Config, 'kuby/eks/config'
  end
end

Kuby.register_provider(:eks, Kuby::EKS::Provider)
