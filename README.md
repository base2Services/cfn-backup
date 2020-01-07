# CfnBackup

Generate & manage configuration for the use of [AWS Backup](https://aws.amazon.com/backup/) to manage backup & retention of your resources. Deployed using CloudFormation.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cfn-backup'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cfn-backup

Setup your [AWS credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) by either setting a profile or exporting them as environment variables.

## Usage

```bash
Commands:
  cfn-vpn --version, -v                                                            # Print the version
  cfn-vpn generate  --stack-name --config                                          # Generate the CloudFormation templates
  cfn-vpn publish --stack-name --config --source-bucket                            # Generate & publish the CloudFormation templates to S3
  cfn-vpn help [COMMAND]                                                           # Describe available commands or one specific command
```

Global Options

```bash
p, [--profile=PROFILE]           # AWS Profile
r, [--region=REGION]             # AWS Region
                                 # Default: ENV['AWS_REGION']
    [--verbose], [--no-verbose]  # Set log level to debug
```

## How It Works

Once you have decided upon using the default configuration or you are instead providing your custom configuration, use the generate command to verify the CloudFormation is valid. Then, run the publish command, passing your source bucket to deploy the templates to S3. Ensure you have your AWS credentials and region set up either as environment variables or using the `--profile` flag.

Once published, you will be given the S3 URL to the master template. Launch this in CloudFormation, and this will create the stack and the nessecary resources.

This will create the following:

* Backup Vault - A vault to store the backups in
* Backup Plan - A single backup plan containing the rules and resource selection
* Backup Rules
  * Daily Rule
  * Weekly Rule
  * Monthly Rule
  * Yearly Rule
* Backup Selection - A single backup selection covering the tag key-value pair specified in your default or custom config

Simply ensure any resources you wish to be backed up have the tagged applied correctly and they will be included in the next backup job. You can add/remove tags to resources at any time without altering the CloudFormation to ensure new resources will be picked up. 

The following resources are currently supported by AWS Backup:
* EFS File Systems
* DynamoDB Tables
* EBS Volumes (Tagging EC2 Instances is supported, doing this will backup all volumes attached)
* RDS Instances
* Storage Gateway

## Custom Configuration

You can create a custom config file to override the global defaults by providing the path to a YAML file using the `--config` flag.
This will perform a deep merge on the global config, meaning you only need to provide the values you want to override in your custom config. The global config file looks like this:

```yaml
# Determines what tag key/value the backup selection will look for on resources
tag_key: cfnbackup:enabled
tag_value: true

# The default retention values (in days). Follows the Grandfather-father-son backup
daily_retention: 14 # 14 Days
weekly_retention: 56 # 8 Weeks
monthly_retention: 365 # 12 Months
yearly_retention: 3652 # 10 Years

# The default cron expressions for each rule (Space-seperated, AWS friendly)
daily_cron: 0 0 * * ? * # At 12:00 AM UTC, every day
weekly_cron: 0 0 ? * 1 * # At 12:00 AM UTC, only on Sunday
monthly_cron: 0 0 1 * ? * # At 12:00 AM UTC, on day 1 of the month
yearly_cron: 0 0 1 1 ? * # At 12:00 AM UTC, on day 1 of the month, only in January
```

## Custom Rules

If there are additional rules outside of the default Daily-Weekly-Monthly-Yearly plan, you can define these within your custom configuration file. You must define all properties specified in the example below:

```yaml
rules:
  hourly: # Alphanumeric name describing the rule
    cron: 0 0/1 * * ? * # Space-seperated AWS cron expression
    retention: 3 # Number in days to retain backups taken by this rule
    tag_key: cfnbackup:custom # A tag key that the service will look for on resources
    tag_value: hourly # The tag value that must match on the provided tag key
```

This will create a new Backup Plan, Backup Rule and Backup Selection per custom rule defined here. None of the regular configuration defaults or custom configuration defined in the previous section will have any impact on custom rules.

## AWS Backup Pricing

With AWS Backup, you pay only for the amount of backup storage you use and the amount of backup data you restore in the month. There is no minimum fee and there are no set-up charges. Deploying the CloudFormation is free, and so are the AWS Backup resources.

Pricing for backup storage and restore differentiates between regions and resources. Please see the [AWS Backup pricing guide](https://aws.amazon.com/backup/pricing/) for a detailed breakdown per region for each resource.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/base2services/cfn-backup.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
