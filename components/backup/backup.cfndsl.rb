CloudFormation do

  Backup_BackupVault(:BackupVault) do
    BackupVaultName FnSub("${StackName}-BackupVault")
  end

  Backup_BackupPlan(:BackupPlan) do 
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
          RecoveryPointTags: [
            { Key: "cfnbackup:type", Value: "daily" }
          ]
        },
        { 
          RuleName: FnSub("${StackName}-WeeklyRule"),
          StartWindowMinutes: 120,
          TargetBackupVault: FnSub("${StackName}-BackupVault"),
          ScheduleExpression: FnSub("cron(${WeeklyCron})"),
          Lifecycle: {
            DeleteAfterDays: Ref("WeeklyRetention")
          },
          RecoveryPointTags: [
            { Key: "cfnbackup:type", Value: "weekly" }
          ]    
        },
        {
          RuleName: FnSub("${StackName}-MonthlyRule"),
          StartWindowMinutes: 120,
          TargetBackupVault: FnSub("${StackName}-BackupVault"),
          ScheduleExpression: FnSub("cron(${MonthlyCron})"),
          Lifecycle: {
            DeleteAfterDays: Ref("MonthlyRetention")
          },
          RecoveryPointTags: [
            { Key: "cfnbackup:type", Value: "monthly" }
          ]
        },
        {
          RuleName: FnSub("${StackName}-YearlyRule"),
          StartWindowMinutes: 120,
          TargetBackupVault: FnSub("${StackName}-BackupVault"),
          ScheduleExpression: FnSub("cron(${YearlyCron})"),
          Lifecycle: {
            DeleteAfterDays: Ref("YearlyRetention")
          },
          RecoveryPointTags: [
            { Key: "cfnbackup:type", Value: "yearly" }
          ]
        }
      ]
    }
  end
  
  Backup_BackupSelection(:BackupSelection) do
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
  
end