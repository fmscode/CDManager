//
//  CoreDataManager.m
//  Pods
//
//  Created by Frank Michael on 6/2/14.
//
//

#import "CoreDataManager.h"

@interface CoreDataManager () {
    NSString *dataModel;
    NSString *bundleId;

    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@end

@implementation CoreDataManager

+ (id)sharedInstance{
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p,^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}
- (id)init{
    self = [super init];
    if (self){
        dataModel = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CoreDataModel"];
        NSAssert(dataModel, @"Error: You must supply a CoreDataModel value in your info.plist that matches the Core Data model file. Key was not found.");
        bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        NSAssert(bundleId, @"Error: You must have the bundle id set in your info.plist.");
        
        [self managedObjectContext];
    }
    return self;
}
#pragma mark - Class
- (void)saveContext{
    
#if TARGET_OS_IPHONE
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = _managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
#else
    NSError *error = nil;
    
    if (![_managedObjectContext commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![_managedObjectContext save:&error]) {
        NSAssert(error, error.description);
    }
#endif
}
#pragma mark - Core Data setup
- (NSManagedObjectContext *)managedObjectContext{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
#if !TARGET_OS_IPHONE
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        NSAssert(error, error.description);
#endif
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator{
    if (persistentStoreCoordinator){
        return persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",dataModel]];
    NSError *error = nil;
    
#if !TARGET_OS_IPHONE
    NSDictionary *properties = [storeURL resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [[NSFileManager defaultManager] createDirectoryAtPath:[storeURL path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        NSAssert(!ok, error.description);
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [storeURL path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            NSAssert(error, error.description);
        }
    }
#endif
    
    
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    if (error){
        NSLog(@"%@",error);
    }
    return persistentStoreCoordinator;
}
- (NSManagedObjectModel *)managedObjectModel{
    if (managedObjectModel) {
        return managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:dataModel withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}
- (NSURL *)applicationDirectory{
    NSURL *directory;
#if !TARGET_OS_IPHONE
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    directory = [appSupportURL URLByAppendingPathComponent:bundleId];
#else
    directory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
#endif
    return directory;
}


@end
