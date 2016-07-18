//
//  HSClusterMapView.m
//  HotSchedules
//
//  Created by Alan Bouzek on 3/30/15.
//  Adapted from OCMapView.m - Created by Botond Kis on 14.07.11.
//  Copyright (c) 2015 HotSchedules. All rights reserved.
//

#import "HSClusterMapView.h"
#import <MapKit/MapKit.h>
#import "HSClusterMarker.h"
#import "HSDistanceUtil.h"
#import "HSClusterAlgorithm.h"

@interface HSClusterMapView ()

/**
 * The set of HSClusterMarkers currently on the map.
 */
@property (strong, nonatomic) NSMutableSet *clusterMarkers;

/**
 * The renderer used for custom HSClusterMarker images
 */
@property (strong, nonatomic) id<HSClusterRenderer> renderer;

@end


@implementation HSClusterMapView


#pragma mark - initalization/setup

-(instancetype)initWithRenderer:(id<HSClusterRenderer>)renderer {
    if (self = [super init]) {
        self.renderer = renderer;
        [self sharedInit];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame renderer:(id<HSClusterRenderer>)renderer {
    if (self = [super initWithFrame:frame]) {
        self.renderer = renderer;
        [self sharedInit];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
                               renderer:(id<HSClusterRenderer>)renderer {
  if (self = [super initWithCoder:aDecoder]) {
    self.renderer = renderer;
    [self sharedInit];
  }
  return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self sharedInit];
    }
    return self;
}

-(void)sharedInit {
    _clusterMarkers = [NSMutableSet new];
    _clusterSize = 0.2;
    _minimumMarkerCountPerCluster = 3;
    _clusteringEnabled = YES;
}


#pragma mark - HSMapView overrides

-(void)addMarker:(GMSMarker *)marker{
    if ([marker isKindOfClass:[HSClusterMarker class]]) {
        // Track visible clusters
        [self.clusterMarkers addObject:marker];
    }
    
    [super addMarker:marker];
}

-(void)addMarkers:(NSArray *)markers{
    [super addMarkers:markers];
}

-(void)removeMarker:(GMSMarker *)marker {
    if ([marker isKindOfClass:[HSClusterMarker class]]) {
        // Track visible clusters
        [self.clusterMarkers removeObject:marker];
    }
    else if (![self.displayedMarkers containsObject:marker]) {
        // Marker may be within a cluster
        [self removeMarkerFromCluster:marker];
    }
    
    [super removeMarker:marker];
}

-(void)removeMarkers:(NSArray *)markers{
    [super removeMarkers:markers];
}

-(void)removeMarkerFromCluster:(GMSMarker *)marker {
    for (HSClusterMarker *clusterMarker in self.clusterMarkers) {
        if ([clusterMarker.markersInCluster containsObject:marker]) {
            [clusterMarker removeMarker:marker];
            break;
        }
    }
}


#pragma mark - utility

-(NSArray *)filterMarkersForVisibleMap:(NSArray *)markersToFilter {
    NSMutableArray *filteredMarkers = [[NSMutableArray alloc] initWithCapacity:markersToFilter.count];
    
    // Border calculation
    CLLocationDistance a = self.visibleSpan.latitudeDelta / 2.0;
    CLLocationDistance b = self.visibleSpan.longitudeDelta / 2.0;
    CLLocationDistance radius = sqrt(pow(a, 2.0) + pow(b, 2.0));
    
    for (GMSMarker *marker in markersToFilter) {
        // If marker is not inside the camera, filter it out
        if ((CLLocationCoordinateDistance(marker.position, self.camera.target) <= radius)) {
            [filteredMarkers addObject:marker];
        }
    }
    
    return filteredMarkers;
}

-(NSArray *)unclusteredMarkers {
    NSMutableArray *unclusteredMarkers = [NSMutableArray new];
    [self.displayedMarkers enumerateObjectsUsingBlock:^(GMSMarker *marker, NSUInteger idx, BOOL *stop) {
        
        if ([marker isKindOfClass:[HSClusterMarker class]]) {
            // Unwrap clustered markers
            HSClusterMarker *clusterMarker = (HSClusterMarker *)marker;
            for (GMSMarker *markerInCluster in clusterMarker.markersInCluster) {
                [unclusteredMarkers addObject:markerInCluster];
            }
        }
        else {
            // Marker not in a cluster, just add it
            [unclusteredMarkers addObject:marker];
        }
        
    }];
    return unclusteredMarkers;
}


#pragma mark - clustering

-(void)cluster {
    NSMutableArray *markersToCluster = [self.unclusteredMarkers mutableCopy];
    NSArray *clusteredMarkers = markersToCluster;
    if (_clusteringEnabled) {
        // Calculate clusters
        CLLocationDistance clusterRadius = self.visibleSpan.longitudeDelta * _clusterSize;
        clusteredMarkers = [HSClusterAlgorithm bubbleClustersFromMarkers:markersToCluster
                                                           clusterRadius:clusterRadius];
    }
    
    NSMutableArray *markersToDisplay = [clusteredMarkers mutableCopy];
    
    // Check minumum cluster size
    for (NSInteger i = 0; i < markersToDisplay.count; ++i) {
        HSClusterMarker *clusterMarker = markersToDisplay[i];
        
        if ([clusterMarker isKindOfClass:[HSClusterMarker class]]) {
            if (clusterMarker.markersInCluster.count < self.minimumMarkerCountPerCluster) {
                // Uncluster markers which do not meet the minimum requirement
                [markersToDisplay removeObject:clusterMarker];
                for (GMSMarker *markerInCluster in clusterMarker.markersInCluster) {
                    [markersToDisplay addObject:markerInCluster];
                }
                // Removed one object, go back one index to account for it
                i--;
            }
            else if (self.renderer) {
                // Render the cluster using the specified renderer
                clusterMarker.icon = [self.renderer imageForClusterWithCount:clusterMarker.markersInCluster.count];
            }
        }
    }

    // Update visible markers
    for (GMSMarker *marker in self.displayedMarkers) {
        // Remove old markers
        if (![markersToDisplay containsObject:marker]) {
            // Marker shouldn't be on map anymore, remove it
            [super removeMarker:marker];
        }
        else {
            // Marker already displayed on map, no need to display it
            [markersToDisplay removeObject:marker];
        }
    }

    // Add markers which were not previously visible
    [super addMarkers:markersToDisplay];
}

@end
