//
//  HSClusterMapView.h
//  HotSchedules
//
//  Created by Alan Bouzek on 3/30/15.
//  Adapted from OCMapView.h - Created by Botond Kis on 14.07.11.
//  Copyright (c) 2015 HotSchedules. All rights reserved.
//

#import "HSMapView.h"
#import "HSClusterRenderer.h"

@interface HSClusterMapView : HSMapView

/**
 * A read-only array of markers which are present on the map, unwrapped from their cluster markers.
 */
@property (nonatomic, readonly) NSArray *unclusteredMarkers;

/**
 * Determines whether clustering is enabled.
 * Defaults to YES.
 */
@property (nonatomic, assign) BOOL clusteringEnabled;

/**
 * The size of each cluster as a decimal percentage of the current region's longitudeDelta.
 * Defaults to 0.2.
 */
@property (nonatomic, assign) CLLocationDistance clusterSize;

/**
 * The minimum amount of markers required to form a cluster.
 * Defaults to 3.
 */
@property (nonatomic, assign) NSUInteger minimumMarkerCountPerCluster;


/**
 * Initializes an instance of HSClusterMapView with a specified HSClusterRenderer.
 * @param renderer - the HSClusterRenderer to use for rendering cluster marker images
 * @return an instance of HSClusterMapView
 */
-(instancetype)initWithRenderer:(id<HSClusterRenderer>)renderer;

/**
 * Initializes an instance of HSClusterMapView with a specified frame and HSClusterRenderer.
 * @param frame - the frame of the HSClusterMapView
 * @param renderer - the HSClusterRenderer to use for rendering cluster marker images
 * @return an instance of HSClusterMapView
 */
-(instancetype)initWithFrame:(CGRect)frame
                    renderer:(id<HSClusterRenderer>)renderer;

/**
 * Initializes an instance of HSClusterMapView with a specified coder and HSClusterRenderer.
 * @param aDecoder - the decoder of the HSClusterMapView
 * @param renderer - the HSClusterRenderer to use for rendering cluster marker images
 * @return an instance of HSClusterMapView
 */
-(instancetype)initWithCoder:(NSCoder *)aDecoder
                    renderer:(id<HSClusterRenderer>)renderer;


/**
 * Updates the map's state by running the clustering algorithm. 
 * Needs to be called after the number of displayed markers on the map changes.
 */
-(void)cluster;

@end
