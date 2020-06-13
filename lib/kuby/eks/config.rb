require 'kube-dsl'

module Kuby
  module EKS
    class Config
      extend ::KubeDSL::ValueFields

      value_fields :region, :credentials, :cluster_name
    end
  end
end
