//
//  CoreDataManager.h
//  Pods
//
//  Created by Frank Michael on 6/2/14.
//
//

#import <Foundation/Foundation.h>
@import CoreData;

@interface CoreDataManager : NSObject

+ (id)sharedInstance;
- (void)saveContext;

@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;


@end
