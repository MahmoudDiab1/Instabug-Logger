# InstabugLogger 
InstabugLogger is a logging framework that has an easy and configurable interface to log with different levels and fetch logs when needed.

## Configuration 
 At the top of AppDelegate.swift import the **InstabugLogger** then Use Default configuration or custom configuration at AppDelegate.swift inside app didFinishLaunchingWithOptions function.
### 
    import InstabugLogger  


 > Default configuration. 
### 
    InstabugLogger.shared.configure()
 > User custom configuration. 
 
###
    let configurations = StorageConfiguration(storageType: .coreData, limit:150)
    InstabugLogger.shared.configure(configurations: configurations) 

- User configures the max number of logs could be stored at disk.
- Also can use the best storage option at disk like *Core data*.
> Note: For now the framework supports core data option and different storage modules not implemented yet.


## Features
User at attendance app can:
- [ ] Flexible to configure the storage limit and type or use the default configurations.
- [ ] Accept a log message and level.
- [ ] Store each log with it's level and timestamp.
- [ ] Store logs on disk e.g. CoreData.  
- [ ] The limit of storage at disk is configured by user.
- [ ] start deleting the earliest logs if reaching the limit.
- [ ] If log message is longer than 1000 character, truncate at 1000 and ... appended.
- [ ] Clean disk store on every app launch.   
## Requirements 
iOS  13.0 and higher.
