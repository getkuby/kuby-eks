require 'fileutils'
require 'aws-sdk-eks'
require 'aws-iam-authenticator-rb'
require 'tmpdir'
require 'yaml'

module Kuby
  module EKS
    class Provider < Kuby::Kubernetes::Provider
      STORAGE_CLASS_NAME = 'gp2'.freeze

      attr_reader :config

      def configure(&block)
        config.instance_eval(&block)
      end

      def kubeconfig_path
        @kubeconfig_path ||= File.join(
          kubeconfig_dir, "#{definition.app_name.downcase}-kubeconfig.yaml"
        )
      end

      def storage_class_name
        STORAGE_CLASS_NAME
      end

      private

      def after_initialize
        @config = Config.new

        kubernetes_cli.before_execute do
          refresh_kubeconfig
        end
      end

      # Double .credentials call here to convert instance into
      # a Credentials object, which contains an access key ID
      # and a secret access key. All the various credentials
      # objects respond to this method, including
      # SharedCredentials, InstanceProfileCredentials, etc.
      #
      # See: https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Credentials.html
      #
      def credentials
        config.credentials.credentials
      end

      def client
        @client ||= ::Aws::EKS::Client.new(
          region: config.region,
          credentials: config.credentials
        )
      end

      def refresh_kubeconfig
        return unless should_refresh_kubeconfig?
        FileUtils.mkdir_p(kubeconfig_dir)
        Kuby.logger.info('Refreshing kubeconfig...')
        File.write(kubeconfig_path, YAML.dump(kubeconfig))
        Kuby.logger.info('Successfully refreshed kubeconfig!')
      end

      def kubeconfig
        @kubeconfig ||= {
          'apiVersion' => 'v1',
          'clusters' => [{
            'cluster' => {
              'server' => cluster.endpoint,
              'certificate-authority-data' => cluster.certificate_authority.data
            },

            'name' => 'kubernetes'
          }],
          'contexts' => [{
            'context' => {
              'cluster' => 'kubernetes',
              'user' => 'aws'
            },

            'name' => 'aws'
          }],
          'current-context' => 'aws',
          'kind' => 'Config',
          'preferences' => {},
          'users' => [{
            'name' => 'aws',
            'user' => {
              'exec' => {
                'apiVersion' => 'client.authentication.k8s.io/v1alpha1',
                'command' => AwsIamAuthenticatorRb.executable,
                'args' => ['token', '-i', config.cluster_name],
                'env' => [
                  { 'name' => 'AWS_ACCESS_KEY_ID', 'value' => credentials.access_key_id },
                  { 'name' => 'AWS_SECRET_ACCESS_KEY', 'value' => credentials.secret_access_key }
                ]
              }
            }
          }]
        }
      end

      def cluster
        @cluster ||= client.describe_cluster(name: config.cluster_name).cluster
      end

      def should_refresh_kubeconfig?
        !File.exist?(kubeconfig_path) || !can_communicate_with_cluster?
      end

      def can_communicate_with_cluster?
        cmd = [kubernetes_cli.executable, '--kubeconfig', kubeconfig_path, 'get', 'ns']
        `#{cmd.join(' ')}`
        $?.success?
      end

      def kubeconfig_dir
        @kubeconfig_dir ||= File.join(
          Dir.tmpdir, 'kuby-eks'
        )
      end
    end
  end
end
