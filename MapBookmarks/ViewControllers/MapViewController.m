//
//  MapViewController.m
//  MapBookmarks
//
//  Created by Borys Khliebnikov on 10/15/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

#import "MapViewController.h"
#import "MyCustomAnnotation.h"
#import <WYPopoverController.h>
#import <WYStoryboardPopoverSegue.h>
#import "BookmarksTableViewController.h"
#import "DetailsTableViewController.h"
#import "PopoverTableViewController.h"
#import "Bookmark.h"

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate, WYPopoverControllerDelegate,
                                    NSFetchedResultsControllerDelegate, PopoverTableViewControllerDelegate>
{
    WYPopoverController* popoverController;
}

// Outlets.
@property (weak, nonatomic) IBOutlet MKMapView       *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *routeButton;

// Private props.
@property (strong, nonatomic) CLLocationManager          *manager;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) Bookmark                   *bookmarkForDetailFromCallout;
@property (nonatomic)         BOOL                        routeMode;

@end

@implementation MapViewController

#pragma mark - Lazy instantiation

- (CLLocationManager *)manager
{
    if (!_manager) {
        _manager = [[CLLocationManager alloc] init];
        _manager.delegate = self;
    }
    return _manager;
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
    NSFetchedResultsController *oldfrc = _fetchedResultsController;
    if (fetchedResultsController != oldfrc) {
        _fetchedResultsController = fetchedResultsController;
        fetchedResultsController.delegate = self;
    }
    if (fetchedResultsController) {
        [self performFetch];
    } else {
        [self reloadAnnotations];
    }
}


#pragma mark - VCLC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // about navigation bar
    
    // Manages user location
    [self settingManager];
    
    self.mapView.delegate = self;
    self.routeMode = NO;
    
    // Loading data
    // Initialize Fetch Request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Bookmark"];
    // Add Sort Descriptors
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    
    // Initialize Fetched Results Controller
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:
                                     self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    // Adds popover dismissal observer
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissPopover) name:@"dismiss" object:nil];
    
    // Gesture recognizers.
    // Long GR. Creates bookmark.
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.mapView addGestureRecognizer:longPress];
    [longPress setCancelsTouchesInView:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //NSLog(@"TEST MSG: VWA called");
    //[self reloadAnnotations];
}

#pragma mark - PopoverTableViewControllerDelegate

- (void)turnRouteWithBookmark:(Bookmark *)bookmark {
    NSLog(@"TEST MSG: PopoverTBV delegate works");
    if (bookmark) {
        MyCustomAnnotation *new;
        // Search for annotation
        if ([self.fetchedResultsController.fetchedObjects count]) {
            CLLocation *loc = bookmark.location;
            for (MyCustomAnnotation *temp in self.mapView.annotations) {
                if (loc.coordinate.latitude == temp.coordinate.latitude && loc.coordinate.longitude == temp.coordinate.longitude) {
                    NSLog(@"TEST MSG: Annotation matched for route");
                    new = temp;
                    [self.mapView removeAnnotations:self.mapView.annotations];
                    [self.mapView addAnnotation:new];
                }
            }
        }
        //NSLog(@"TEST MSG: New annotation is %@", new);
        [self.routeButton setTitle:@"Clear route"];
        self.routeMode = YES;
        [self showDirectionWithBookmark:bookmark];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"TEST MSG: Content WILL change");
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"TEST MSG: Content DID changed");
    [self reloadAnnotations];
}

#pragma mark - NSFRC

- (void)performFetch
{
    if (self.fetchedResultsController) {
        NSError *error;
        BOOL success = [self.fetchedResultsController performFetch:&error];
        if (!success) NSLog(@"[%@ %@] performFetch: failed", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        if (error) NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
    }
    [self reloadAnnotations];
}

#pragma mark - Helper methods

// For observer method
- (void)dismissPopover {
    [popoverController dismissPopoverAnimated:NO completion:^{
        [self popoverControllerDidDismissPopover:popoverController];
    }];
}


- (void)reloadAnnotations {
    [self.mapView removeAnnotations:self.mapView.annotations];
    if ([self.fetchedResultsController.fetchedObjects count]) {
        for (Bookmark *temp in self.fetchedResultsController.fetchedObjects) {
            CLLocation *location = temp.location;
            MyCustomAnnotation *annotation = [[MyCustomAnnotation alloc] initWithLocation:location.coordinate andTitle:temp.name];
            [self.mapView addAnnotation:annotation];
        }
    }
}

// Request for access to user location. Shows current location.
- (void)settingManager
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        NSLog(@"TEST MSG: CLAccess denied");
        // Informs user that location services disabled or restricted.
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Access to geolocation is prohibited"
                                              message:@"Please open settings to allow MapBookmarks to use your location"
                                              preferredStyle:UIAlertControllerStyleAlert];
        // Allows to turn it on from settings
        UIAlertAction     *settingsAction  = [UIAlertAction actionWithTitle:@"Settings"
                                                                      style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                                        BOOL canOpenSettings = (UIApplicationOpenSettingsURLString != NULL);
                                                                        if (canOpenSettings) {
                                                                            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                            [[UIApplication sharedApplication] openURL:url];
                                                                        }
                                                                    }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:settingsAction];
        [alertController addAction:cancel];
        // General pattern for alertController.
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        NSLog(@"TEST MSG: CLStatus is not determined");
        [self.manager requestWhenInUseAuthorization];
        // If user presses yes.
        [self.manager startUpdatingLocation];
        self.mapView.showsUserLocation = YES;
    }
    else
    {
        NSLog(@"TEST MSG: CLAccess granted");
        [self.manager startUpdatingLocation];
        self.mapView.showsUserLocation = YES;
    }
}

// Direction methods.
- (void)showDirectionWithBookmark:(Bookmark *)bookmark {
    
    CLLocation  *location = bookmark.location;
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:location.coordinate addressDictionary:nil];
    MKMapItem   *new = [[MKMapItem alloc] initWithPlacemark:placemark];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    request.source = [MKMapItem mapItemForCurrentLocation];
    
    request.destination = new;
    request.requestsAlternateRoutes = NO;
    MKDirections *directions =
    [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             // Handle Error. (+alert todo)
             NSLog(@"ERROR MSG: showDirectionsWB error\n message: %@, %@",error, error.localizedDescription);
             [self.mapView removeOverlays:self.mapView.overlays];
             [self reloadAnnotations];
         } else {
             [self drawRoute:response];
         }
     }];
}

- (void)drawRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes)
    {
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation {
    
    // Handle user location arrow.
    if ([annotation isKindOfClass:[MKUserLocation class]]) return nil;
    
    // Handle custom annotations.
    if ([annotation isKindOfClass:[MyCustomAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.pinTintColor = [UIColor redColor];
            pinView.animatesDrop = NO;
            pinView.canShowCallout = YES;
            pinView.userInteractionEnabled = YES;
#warning Not recommended by Human Interface Guidelines
            // Customizes the callout by adding accessory view.
            /*************************************************
             *USES ARROW INDICATOR INSDEAD OF INFO iOS7 STYLE*
             *       like requested in test assignment       *
             *************************************************/
            
            // Other maybe more appropriate solutions:
            /*-------------------------------------------------
              1) Subclass MKAnnotationView and add UITableView 
                 + one static cell/conform tv delegate
                 and use method of accessory button tapped
              2) Just replace the picture of info button
                 Or even replace it in code by iteration over
                 views for cell and button (not recommended)
             -------------------------------------------------*/
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIButton *tempButtonForBounds = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            UITableViewCell *disclosure = [[UITableViewCell alloc] init];
            [rightButton addSubview:disclosure];
            rightButton.frame = tempButtonForBounds.frame;
            disclosure.frame = tempButtonForBounds.frame;
            disclosure.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            disclosure.userInteractionEnabled = NO;
            pinView.rightCalloutAccessoryView = rightButton;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    NSLog(@"TEST MSG: calloutAccessory tapped");
    MyCustomAnnotation *ann = (MyCustomAnnotation *)view.annotation;
    // Shows BookmarkDetails screen
    if ([self.fetchedResultsController.fetchedObjects count]) {
        for (Bookmark *temp in self.fetchedResultsController.fetchedObjects) {
            CLLocation *loc = temp.location;
            if (loc.coordinate.latitude == ann.coordinate.latitude && loc.coordinate.longitude == ann.coordinate.longitude) {
                NSLog(@"TEST MSG: MATCHED");
                self.bookmarkForDetailFromCallout = temp;
            }
        }
    }
    
    [self performSegueWithIdentifier:@"bookmarkDetails" sender:self];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer =
    [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 5.0;
    return renderer;
}

#pragma mark - IBActions
// Places bookmark on longPress/
- (IBAction)longPressGestureRecognized:(id)sender {
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint locationToPlace = [longPress locationInView:self.mapView];
    if (state == UIGestureRecognizerStateRecognized) {
        CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:locationToPlace toCoordinateFromView:self.mapView];
        Bookmark *bookmarkCD   = [NSEntityDescription insertNewObjectForEntityForName:@"Bookmark" inManagedObjectContext:self.managedObjectContext];
        bookmarkCD.name = @"Unnamed";
        bookmarkCD.location = [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude];
        
        // Saving Context
        NSError *errorForSave = nil;
        if (![self.managedObjectContext save:&errorForSave]) {
            NSLog(@"Unable to save Bookmarks.");
            NSLog(@"%@, %@", errorForSave, errorForSave.localizedDescription);
        } else {
            NSLog(@"TEST MSG: bookmark saved scfly");
        }
    }
}

- (IBAction)unwindSegueFromDetails:(UIStoryboardSegue *)sender {
    NSLog(@"TEST MSG: unwindSegueFromDetails");
}
- (IBAction)centerInMap:(UIStoryboardSegue *)sender {
    NSLog(@"TEST MSG: Center in map. Unwind segue.");
    DetailsTableViewController *vc = sender.sourceViewController;
    if (vc.bookmark) {
        CLLocation *location = vc.bookmark.location;
        [self.mapView setRegion: MKCoordinateRegionMakeWithDistance(location.coordinate, (1609.344f * 100.0f), (1609.344f * 100.0f)) animated:YES];
    }
}

- (IBAction)showRoute:(UIStoryboardSegue *)sender {
    [self.mapView removeOverlays:self.mapView.overlays];
    self.routeMode = YES;
    NSLog(@"TEST MSG: Show route. Unwind segue.");
    if ([sender.identifier isEqualToString:@"showRoute"]) {
        DetailsTableViewController *vc = sender.sourceViewController;
        if (vc.bookmark) {
            MyCustomAnnotation *new;
            // Search for annotation
            if ([self.mapView.annotations count]) {
                CLLocation *loc = vc.bookmark.location;
                for (MyCustomAnnotation *temp in self.mapView.annotations) {
                    if (loc.coordinate.latitude == temp.coordinate.latitude && loc.coordinate.longitude == temp.coordinate.longitude) {
                        NSLog(@"TEST MSG: Annotation matched for route");
                        new = temp;
                        [self.mapView removeAnnotations:self.mapView.annotations];
                        [self.mapView addAnnotation:new];
                    }
                }
            }
            //NSLog(@"TEST MSG: New annotation is %@", new);
            [self.routeButton setTitle:@"Clear route"];
            [self showDirectionWithBookmark:vc.bookmark];
        }
    }
}

- (IBAction)switchRouteMode:(UIBarButtonItem *)sender {
    NSLog(@"TEST MSG: switchRouteMode called");
    if (self.routeMode == YES) {
        NSLog(@"TEST MSG: switchRouteMode called for yes");
        self.routeMode = NO;
        [self.routeButton setTitle:@"Route"];
        [self.mapView removeOverlays:self.mapView.overlays];
        [self reloadAnnotations];
    } else {
        [self performSegueWithIdentifier:@"popoverSegue" sender:self.routeButton];
    }
}

#pragma mark - WYPopoverControllerDelegate

// Changing "routeButton" title here.
- (void)popoverControllerDidPresentPopover:(WYPopoverController *)controller
{
    NSLog(@"TEST MSG: popoverControllerDidPresentPopover");
    
    [self.routeButton setTitle:@"Clear route"];
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

// Cleaning.
- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    NSLog(@"TEST MSG: popoverControllerDidDismissPopover");
    if (self.routeMode == NO) {
        [self.routeButton setTitle:@"Route"];
    }
    popoverController.delegate = nil;
    popoverController = nil;
}

- (BOOL)popoverControllerShouldIgnoreKeyboardBounds:(WYPopoverController *)popoverController
{
    return YES;
}

#pragma mark - APLC

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Cleaning.
- (void)dealloc {
    self.mapView.delegate = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"popoverSegue"])
    {
        WYStoryboardPopoverSegue *popoverSegue = (WYStoryboardPopoverSegue *)segue;
        PopoverTableViewController *vc = (PopoverTableViewController *)segue.destinationViewController;
        vc.bookmarksContext = self.managedObjectContext;
        vc.delegate = self;
        popoverController = [popoverSegue popoverControllerWithSender:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
        popoverController.delegate = self;
        self.routeMode = YES;
    }
    else if ([segue.identifier isEqualToString:@"bookmarksList"])
    {
        BookmarksTableViewController *vc = (BookmarksTableViewController *)segue.destinationViewController;
        vc.bookmarksContext = self.managedObjectContext;
    }
    else if ([segue.identifier isEqualToString:@"bookmarkDetails"])
    {
        DetailsTableViewController *vc = (DetailsTableViewController *)segue.destinationViewController;
        vc.bookmark = self.bookmarkForDetailFromCallout;
        vc.detailsContext = self.managedObjectContext;
        vc.segueFromMap = YES;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if ([identifier isEqualToString:@"popoverSegue"]) {
        if (self.routeMode == YES) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return YES;
    }
}


@end
