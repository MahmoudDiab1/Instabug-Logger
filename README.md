# InstabugLogger 
a logging framework that has an easy interface to log with different levels and fetch logs when needed.

## Setup
--- 
 - [ ] Call  Instabug.shared.Configure( .coreData, limit:1000)

- User configures the max number of logs could be stored at disk.
- Ulso can use the best storage option at disk like *Core data*


## Features
User at attendance app can:
- [ ] Accept a log message and level.
- [ ] Store each log with it's level and timestamp.
- [ ] Store logs on disk e.g. CoreData.  
- [ ] The limit of storage at disk is configured by user.
- [ ] start deleting the earliest logs if reaching the limit.
- [ ] If log message is longer than 1000 character, truncate at 1000 and ... appended.
- [ ] Clean disk store on every app launch.   
