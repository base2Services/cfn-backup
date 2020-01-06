CloudFormation do

  Backup_BackupVault(:BackupVault) do
    BackupVaultName FnSub("${StackName}-BackupVault")
  end

  Backup_BackupPlan(:BackupPlan) do 
    DependsOn :BackupVault
    BackupPlan {
      BackupPlanName FnSub("${StackName}-Plan")
      BackupPlanRule [
        {
          RuleName: FnSub("${StackName}-DailyRule"),
          StartWindowMinutes: 120,
          TargetBackupVault: FnSub("${StackName}-BackupVault"),
          ScheduleExpression: FnSub("cron(${DailyCron})"),
          Lifecycle: {
            DeleteAfterDays: Ref("DailyRetention")
          },
          RecoveryPointTags: {
            "cfnbackup:type": "daily"
          }
        },
        { 
          RuleName: FnSub("${StackName}-WeeklyRule"),
          StartWindowMinutes: 120,
          TargetBackupVault: FnSub("${StackName}-BackupVault"),
          ScheduleExpression: FnSub("cron(${WeeklyCron})"),
          Lifecycle: {
            DeleteAfterDays: Ref("WeeklyRetention")
          },
          RecoveryPointTags: {
            "cfnbackup:type": "weekly"
          }
        },
        {
          RuleName: FnSub("${StackName}-MonthlyRule"),
          StartWindowMinutes: 120,
          TargetBackupVault: FnSub("${StackName}-BackupVault"),
          ScheduleExpression: FnSub("cron(${MonthlyCron})"),
          Lifecycle: {
            DeleteAfterDays: Ref("MonthlyRetention")
          },
          RecoveryPointTags: {
            "cfnbackup:type": "monthly"
          }
        },
        {
          RuleName: FnSub("${StackName}-YearlyRule"),
          StartWindowMinutes: 120,
          TargetBackupVault: FnSub("${StackName}-BackupVault"),
          ScheduleExpression: FnSub("cron(${YearlyCron})"),
          Lifecycle: {
            DeleteAfterDays: Ref("YearlyRetention")
          },
          RecoveryPointTags: {
            "cfnbackup:type": "yearly"
          }
        }
      ]
    }
  end
  
  Backup_BackupSelection(:BackupSelection) do
    DependsOn :BackupPlan
    BackupPlanId FnGetAtt(:BackupPlan, :BackupPlanId)
    BackupSelection {
      IamRoleArn FnSub("arn:aws:iam::${AWS::AccountId}:role/service-role/AWSBackupDefaultServiceRole")
      ListOfTags [
        {
          ConditionKey: FnSub("${TagKey}"),
          ConditionType: "STRINGEQUALS",
          ConditionValue: FnSub("${TagValue}")
        }
      ]
      SelectionName FnSub("${StackName}-Selection")
    }
  end

  #TODO Figure out how to pass in config list for custom rules here
  custom_rules.each do |rule|

    rule_name = rule[0]
    rule_cron = rule[1]['cron']
    rule_retention = rule[1]['retention']
    rule_tag_key = rule[1]['tag_key']
    rule_tag_value = rule[1]['tag_value']

    Backup_BackupPlan("#{rule_name}BackupPlan") do 
      DependsOn :BackupVault
      BackupPlan {
        BackupPlanName FnSub("${StackName}-#{rule_name}Plan")
        BackupPlanRule [
          {
            RuleName: FnSub("${StackName}-#{rule_name}Rule"),
            StartWindowMinutes: 120,
            TargetBackupVault: FnSub("${StackName}-BackupVault"),
            ScheduleExpression: FnSub("cron(#{rule_cron})"),
            Lifecycle: {
              DeleteAfterDays: FnSub("#{rule_retention}")
            },
            RecoveryPointTags: {
              "cfnbackup:type": "#{rule_name}"
            }
          }
        ]
      }
    end

    Backup_BackupSelection("#{rule_name}BackupSelection") do
      DependsOn "#{rule_name}BackupPlan"
      BackupPlanId FnGetAtt("#{rule_name}BackupPlan", :BackupPlanId)
      BackupSelection {
        IamRoleArn FnSub("arn:aws:iam::${AWS::AccountId}:role/service-role/AWSBackupDefaultServiceRole")
        ListOfTags [
          {
            ConditionKey: FnSub("#{rule_tag_key}"),
            ConditionType: "STRINGEQUALS",
            ConditionValue: FnSub("#{rule_tag_value}")
          }
        ]
        SelectionName FnSub("${StackName}-#{rule_name}Selection")
      }      
    end

  end
  
end