## kuby-eks

Amazon EKS provider for [Kuby](https://github.com/getkuby/kuby-core).

## Intro

In Kuby parlance, a "provider" is an [adapter](https://en.wikipedia.org/wiki/Adapter_pattern) that enables Kuby to deploy apps to a specific cloud provider. In this case, we're talking about Amazon's Elastic Kubernetes Service, or EKS.

All providers adhere to a specific interface, meaning you can swap out one provider for another without having to change your code.

## Usage

Enable the EKS provider like so:

```ruby
require 'aws-sdk-eks'

Kuby.define(:production) do
  kubernetes do

    provider :eks do
      region 'us-west-2'
      cluster_name 'my-cluster'

      credentials(
        Aws::Credentials.new(
          'my-access-key-id',
          'my-secret-access-key'
        )
      )
    end

  end
end
```

The `credentials` method should be passed an instance of [`Aws::Credentials`](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Credentials.html) or one of the other `Aws::CredentialProvider` subclasses, eg. [`Aws::SharedCredentials`](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SharedCredentials.html), [`Aws::InstanceProfileCredentials`](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/InstanceProfileCredentials.html), etc.

Once configured, you should be able to run all the Kuby rake tasks as you would with any provider.

## License

Licensed under the MIT license. See LICENSE for details.

## Authors

* Cameron C. Dutro: http://github.com/camertron
