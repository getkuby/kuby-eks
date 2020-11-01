require 'kube-dsl'
require 'digest'

module Kuby
  module EKS
    class Config
      extend ::KubeDSL::ValueFields

      value_fields :region, :credentials, :cluster_name

      # Double .credentials call here to convert instance into
      # a Credentials object, which contains an access key ID
      # and a secret access key. All the various credentials
      # objects respond to this method, including
      # SharedCredentials, InstanceProfileCredentials, etc.
      #
      # See: https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Credentials.html
      #
      def hash_value
        parts = [
          region,
          cluster_name,
          credentials.credentials.secret_access_key,
          credentials.credentials.access_key_id,
        ]

        Digest::SHA256.hexdigest(parts.join(':'))
      end
    end
  end
end
