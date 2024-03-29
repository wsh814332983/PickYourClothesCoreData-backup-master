//
//  MainFunctionViewController.m
//  PickYourClothesCoreData
//
//  Created by Rui Yao on 4/18/14.
//  Copyright (c) 2014 tianxiang zhang. All rights reserved.
//

#import "MainFunctionViewController.h"
#import "WXManager.h"
#import "UIButton+Bootstrap.h"
#import "People.h"
@interface MainFunctionViewController ()
@property (strong,nonatomic) NSArray *clothesArray;
@property (strong,nonatomic) NSArray *pantsArray;
@property (strong,nonatomic) NSMutableArray *clothesFilterArray;
@property (strong,nonatomic) NSMutableArray *pantsFilterArray;
@property (strong,nonatomic) NSMutableArray *shoesFilterArray;
@property (strong,nonatomic) NSMutableArray *umbrellaFilterArray;
@property (strong,nonatomic) NSMutableArray *gloveFilterArray;
@property (nonatomic) NSInteger currentTemperature;
@property (nonatomic,strong) WXCondition *weatherCondition;
@property (nonatomic) BOOL needUmbrella;
@property (nonatomic) BOOL needGlove;
@property (nonatomic) NSInteger cnt;
@property (nonatomic) BOOL lackOfClothes;
@property (nonatomic) BOOL lackOfPants;
@property (nonatomic) BOOL lackOfShoes;
@property (nonatomic) BOOL lackOfUmbrellas;
@property (nonatomic) BOOL lackOfGloves;
@property (nonatomic) NSArray *shouldPickClothes;
@property (nonatomic) NSArray *shouldPickPants;
@property (nonatomic) NSArray *shouldPickShoes;
@property (nonatomic) Clothes *cloth;
@property (nonatomic) Clothes *pant;
@property (nonatomic) Clothes *shoes;
@property (strong,nonatomic) NSString *mailId;
@property (strong,nonatomic) People *peo;
@property (nonatomic) BOOL needPant;
@end

@implementation MainFunctionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}

-(void) findClothes{
    [[RACObserve([WXManager sharedManager], currentCondition)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(WXCondition *newCondition) {
         _currentTemperature = newCondition.temperature.intValue;
         _weatherCondition=newCondition;
     }];
    [[WXManager sharedManager] findCurrentLocation];

    self.fetchrearch=nil;
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    NSManagedObjectContext *moc=kAppDelegate.managedObjectContext;
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Clothes" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    NSSortDescriptor *sortDescriptor=[[NSSortDescriptor alloc]initWithKey:@"name" ascending:NO];
    NSArray *sortDescription=[NSArray arrayWithObjects:sortDescriptor,nil];
    [fetchRequest setSortDescriptors:sortDescription];
    NSFetchedResultsController *aFetched=[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:@"name" cacheName:nil];
    aFetched.delegate=self;
    self.fetchrearch=aFetched;
    NSError *error=nil;
    if (![self.fetchrearch performFetch:&error]) {
        abort();
    }
    _clothesArray=[self.fetchrearch fetchedObjects];
    
    

    
    if([self.purpose isEqualToString:@"Formal Occasion"]){
        _shouldPickClothes=[NSArray arrayWithObjects:@"Suit", nil];_shouldPickPants=[NSArray arrayWithObjects:@"Suit", nil];_shouldPickShoes=[NSArray arrayWithObjects:@"Suit", nil];
    }
    if([self.purpose isEqualToString:@"Exercise,Gym,Sports"]){
       if (_currentTemperature<50) {
           _shouldPickClothes =[NSArray arrayWithObjects:@"Sports Long", nil];_shouldPickPants = [NSArray arrayWithObjects:@"Sports Long", nil];_shouldPickShoes=[NSArray arrayWithObjects:@"Exercise", nil];
       }
       else{
           _shouldPickClothes =[NSArray arrayWithObjects:@"Sports Short", nil]; _shouldPickPants = [NSArray arrayWithObjects:@"Sports Short", nil];_shouldPickShoes=[NSArray arrayWithObjects:@"Exercise", nil];
       }
    }
    if([self.purpose isEqualToString:@"Others"]){
        if (_currentTemperature<50) {
            _shouldPickClothes =[NSArray arrayWithObjects:@"Jacket", @"Fleece",@"Down Coat",nil] ; _shouldPickPants = [NSArray arrayWithObjects:@"Pants Long", nil];_shouldPickShoes=[NSArray arrayWithObjects:@"Warm Shoes", @"Exercise",@"High Heel",nil];
        }
        else if(_currentTemperature<60){
            _shouldPickClothes =[NSArray arrayWithObjects:@"Sweater",@"Fleece", nil] ; _shouldPickPants = [NSArray arrayWithObjects:@"Pants Long", nil];_shouldPickShoes=[NSArray arrayWithObjects:@"Warm Shoes", @"Exercise",@"High Heel",nil];
        }
        else if (_currentTemperature<70){
            _shouldPickClothes =[NSArray arrayWithObjects:@"Shirt", @"Dress",nil] ; _shouldPickPants = [NSArray arrayWithObjects:@"Pants Middle", nil];_shouldPickShoes=[NSArray arrayWithObjects:@"Plimsolls",@"Exercise",@"High Heel", nil];
        }else{
            _shouldPickClothes =[NSArray arrayWithObjects: @"T-shirt", @"Sun-top",@"Chiffon",@"Skirt",nil]; _shouldPickPants = [NSArray arrayWithObjects:@"Pants Short", nil];_shouldPickShoes=[NSArray arrayWithObjects:@"Sandal",@"Exercise", @"High Heel",nil];
        }
    }
    
    _clothesFilterArray=[[NSMutableArray alloc]initWithCapacity:50];
    _pantsFilterArray=[[NSMutableArray alloc]initWithCapacity:50];
    _shoesFilterArray=[[NSMutableArray alloc]initWithCapacity:50];
    _umbrellaFilterArray=[[NSMutableArray alloc]initWithCapacity:50];
    _gloveFilterArray=[[NSMutableArray alloc]initWithCapacity:50];
    
    
        for(Clothes *cloth in _clothesArray){
            if ([_shouldPickClothes containsObject:cloth.type]&&[cloth.kindOf isEqualToString:@"Jacketing"]) {
                [_clothesFilterArray addObject:cloth];
            }
            if ([_shouldPickPants containsObject:cloth.type]&&[cloth.kindOf isEqualToString:@"Pants"]) {
                [_pantsFilterArray addObject:cloth];
            }
            if ([_shouldPickShoes containsObject:cloth.type]&&[cloth.kindOf isEqualToString:@"Shoes"]) {
                [_shoesFilterArray addObject:cloth];
            }
            if ([cloth.kindOf isEqualToString:@"Umbrella"]) {
                [_umbrellaFilterArray addObject:cloth];
            }
            if ([cloth.kindOf isEqualToString:@"Glove"]) {
                [_gloveFilterArray addObject:cloth];
            }
        }
  

    if ([[_weatherCondition imageName] isEqualToString:@"weather-rain-night" ] ||  [[_weatherCondition imageName] isEqualToString:@"weather-rain" ] ||  [[_weatherCondition imageName] isEqualToString:@"weather-shower" ]||[[_weatherCondition imageName] isEqualToString:@"weather-snow" ]) {
        _needUmbrella=YES;
    }else{
        _needUmbrella=NO;
    }
    if (_currentTemperature<50) {
        _needGlove=YES;
    }else{
        _needGlove=NO;
    }
    

}
-(NSMutableArray *)generateFilterArray:(NSMutableArray *)initialArray{
    NSMutableArray *initialArray2=[[NSMutableArray alloc]init];
    for(Clothes *cloth in initialArray){
        if ([cloth.useTime intValue]<5) {
           [initialArray2 addObject:cloth];
        }
    }
    NSMutableArray *filterArray=[[NSMutableArray alloc]init];
    if([initialArray2 count]!=0){
    int count=0;
    for (int i=0; i<[initialArray2 count]; i++) {
        Clothes *cloth=initialArray2[i];
        for (int j=0; j<cloth.rate.intValue+1; j++) {
            filterArray[count]=initialArray2[i];
            count++;
        }
    }
    }
    return filterArray;
}
-(void)showSelectionOfClothes{
    _cloth=[Clothes alloc];
    unsigned indexOfClothes;
    NSMutableArray *clothesFilterArray2=[self generateFilterArray:_clothesFilterArray];
    if ([clothesFilterArray2 count]!=0) {
        self.PickedClothes.enabled=YES;
        self.lackOfClothes=NO;
        indexOfClothes =arc4random() % [clothesFilterArray2 count];
        _cloth=clothesFilterArray2[indexOfClothes];
        NSData *clothesImageData= _cloth.image;
        [self.PickedClothes setImage:[UIImage imageWithData:clothesImageData] forState:UIControlStateNormal] ;
        if ((!([_cloth.type isEqualToString:@"Dress"]||[_cloth.type isEqualToString:@"Skirt"]))&&!self.PickedPants.enabled) {
            self.PickedPants.enabled=YES;
            [self showSelectionOfPants];
        }
        if ([_cloth.type isEqualToString:@"Dress"]||[_cloth.type isEqualToString:@"Skirt"]) {
            [self.PickedPants setImage:nil forState:UIControlStateNormal];
            [self.PickedPants setTitle:@"NO NEED" forState:UIControlStateNormal];
            [self.PickedPants setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.PickedPants.enabled=NO;
        }
    }else{
        self.lackOfClothes=YES;
        self.PickedClothes.enabled=NO;
    }
}
-(void)showSelectionOfPants{
    _pant=[Clothes alloc];
    unsigned indexOfPants;
    NSMutableArray *pantsFilterArray2=[self generateFilterArray:_pantsFilterArray];
    if ([pantsFilterArray2 count]!=0) {
        self.PickedPants.enabled=YES;
        self.lackOfPants=NO;
        if([self.purpose isEqualToString:@"Formal Occasion"]){
            _needPant=YES;
            NSMutableArray *sameColorPants=[[NSMutableArray alloc]init];
            for(Clothes *possibleClothes in pantsFilterArray2){
                if ([possibleClothes.color isEqualToString:_cloth.color]) {
                    [sameColorPants addObject:possibleClothes];
                }
            }
            indexOfPants=arc4random() % [sameColorPants count];
            _pant=sameColorPants[indexOfPants];
         }else if([self.purpose isEqualToString:@"Others"]){
            if ([_cloth.type isEqualToString:@"Dress"]||[_cloth.type isEqualToString:@"Skirt"]) {
                _needPant=NO;
                [self.PickedPants setImage:nil forState:UIControlStateNormal];
                [self.PickedPants setTitle:@"NO NEED" forState:UIControlStateNormal];
                [self.PickedPants setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                self.PickedPants.enabled=NO;
            }else{
             _needPant=YES;
             indexOfPants =arc4random() % [pantsFilterArray2 count];
             _pant=pantsFilterArray2[indexOfPants];
            }
         }else{
             _needPant=YES;
            indexOfPants =arc4random() % [pantsFilterArray2 count];
            _pant=pantsFilterArray2[indexOfPants];
        }
        if(_needPant){
            NSData *pantsImageData=_pant.image;
            [self.PickedPants setImage:[UIImage imageWithData:pantsImageData] forState:UIControlStateNormal];
        }
    }else{
        self.lackOfPants=YES;
        self.PickedPants.enabled=NO;
    }
}
-(void)showSelectionOfShoes{
    _shoes=[Clothes alloc];
    unsigned indexOfShoes;
    NSMutableArray *shoesFilterArray2=[self generateFilterArray:_shoesFilterArray];
    if ([shoesFilterArray2 count]!=0) {
        self.PickedShoes.enabled=YES;
        self.lackOfShoes=NO;
        indexOfShoes =arc4random() % [shoesFilterArray2 count];
        _shoes=shoesFilterArray2[indexOfShoes];
        NSData *shoesImageData=_shoes.image;
        [self.PickedShoes setImage:[UIImage imageWithData:shoesImageData] forState:UIControlStateNormal];
    }else{
        self.lackOfShoes=YES;
        self.PickedShoes.enabled=NO;
    }
}
-(void)showSelectionOfUmbrella{
    Clothes *umbrella=[Clothes alloc];
    NSMutableArray *umbrellaFilterArray2=[self generateFilterArray:_umbrellaFilterArray];
    if([umbrellaFilterArray2 count]!=0){
        self.PickedUmbrella.enabled=YES;
        self.lackOfUmbrellas=NO;
        unsigned indexOfUmbrella =arc4random() % [umbrellaFilterArray2 count];
        umbrella=umbrellaFilterArray2[indexOfUmbrella];
        NSData *umbrellaImageData=umbrella.image;
        [self.PickedUmbrella setImage:[UIImage imageWithData:umbrellaImageData] forState:UIControlStateNormal];
    }else{
        self.lackOfUmbrellas=YES;
        self.PickedUmbrella.enabled=NO;
    }
}
-(void)showSelectionOfGlove{
    Clothes *glove=[Clothes alloc];
    NSMutableArray *gloveFilterArray2=[self generateFilterArray:_gloveFilterArray];
    if([gloveFilterArray2 count]!=0){
        self.PickedGlove.enabled=YES;
        self.lackOfGloves=NO;
        unsigned indexOfGlove =arc4random() % [gloveFilterArray2 count];
        glove=gloveFilterArray2[indexOfGlove];
        NSData *gloveImageData=glove.image;
        [self.PickedGlove setImage:[UIImage imageWithData:gloveImageData] forState:UIControlStateNormal];
    }else{
        self.lackOfGloves=YES;
        self.PickedGlove.enabled=NO;
    }
}
-(void)showOriginal{
    [self.PickedClothes setImage:[UIImage imageNamed:@"originalShow_jacket"] forState:UIControlStateNormal];
    [self.PickedPants setImage:[UIImage imageNamed:@"originalShow_pant"] forState:UIControlStateNormal];
    [self.PickedShoes setImage:[UIImage imageNamed:@"originalShow_shoes"] forState:UIControlStateNormal];
    [self.PickedUmbrella setImage:[UIImage imageNamed:@"originalShow_umbrella"] forState:UIControlStateNormal];
    [self.PickedGlove setImage:[UIImage imageNamed:@"originalShow_glove"] forState:UIControlStateNormal];
}
-(void)showAllSelection{
    [self findClothes];
    if(_cnt!=0){
        [self.PickClothes setTitle:@"Change" forState:UIControlStateNormal];
        [self showSelectionOfClothes];
        [self showSelectionOfPants];
        [self showSelectionOfShoes];
        if (_needUmbrella) {
            [self showSelectionOfUmbrella];
        }else{
             self.PickedUmbrella.enabled=YES;
            [self.PickedUmbrella setImage:nil forState:UIControlStateNormal];
            [self.PickedUmbrella setTitle:@"NO NEED" forState:UIControlStateNormal];
            [self.PickedUmbrella setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

            self.PickedUmbrella.enabled=NO;
        }
        if (_needGlove) {
            [self showSelectionOfGlove];
        }else{
             self.PickedGlove.enabled=YES;
            [self.PickedGlove setImage:nil forState:UIControlStateNormal];
            [self.PickedGlove setTitle:@"NO NEED" forState:UIControlStateNormal];
            [self.PickedGlove setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

            self.PickedGlove.enabled=NO;
        }
    }else{
        self.PickedClothes.enabled=NO;
        self.PickedPants.enabled=NO;
        self.PickedShoes.enabled=NO;
        self.PickedUmbrella.enabled=NO;
        self.PickedGlove.enabled=NO;
        [self showOriginal];
        [self.PickClothes setTitle:@"Pick One" forState:UIControlStateNormal];

    }
    _cnt++;
}
- (void) viewWillAppear:(BOOL)animated{
    self.lackOfClothes=YES;
    self.lackOfPants=YES;
    self.lackOfShoes=YES;
    [self fetchpeople];
    _imagehead.image=[UIImage imageWithData:_peo.image];
    _imagehead.layer.cornerRadius=8;
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.PickedClothes.layer.cornerRadius=20;
    self.PickedClothes.contentEdgeInsets=UIEdgeInsetsMake(5, 5, 5, 5);
    self.PickedPants.layer.cornerRadius=20;
    self.PickedPants.contentEdgeInsets=UIEdgeInsetsMake(5, 5, 5, 5);
    self.PickedShoes.layer.cornerRadius=20;
    self.PickedShoes.contentEdgeInsets=UIEdgeInsetsMake(5, 5, 5, 5);
    self.PickedGlove.layer.cornerRadius=20;
    self.PickedGlove.contentEdgeInsets=UIEdgeInsetsMake(5, 5, 5, 5);
    self.PickedUmbrella.layer.cornerRadius=20;
    self.PickedUmbrella.contentEdgeInsets=UIEdgeInsetsMake(5, 5, 5, 5);
    _imagehead.layer.cornerRadius=20;
    _imagehead.layer.borderWidth=0.1;
    _imagehead.layer.backgroundColor=(__bridge CGColorRef)([UIColor grayColor]);
    _imagehead.layer.masksToBounds=YES;
    
   // self.tabBarController.tabBar.hidden=NO;
  //  self.navigationController.navigationBar.alpha=1;
    _cnt=0;
    [self showAllSelection];
    [self.button primaryStyle];
    [self.button addAwesomeIcon:FAIconBriefcase beforeTitle:YES];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)PickClothes:(id)sender {
    [self showAllSelection];
    if (self.lackOfClothes || (self.lackOfGloves && _needGlove) || self.lackOfPants || self.lackOfShoes || (self.lackOfUmbrellas && _needUmbrella)) {
        NSString *clothes=[[NSString alloc]init];
        if(self.lackOfClothes) {clothes=@" Suitable Clothes,";}else{ clothes=@"";}
        NSString *gloves=[[NSString alloc]init];
        if(self.lackOfGloves && _needGlove) {gloves=@"gloves,";}else{ gloves=@"";}
        NSString *pants=[[NSString alloc]init];
        if(self.lackOfPants ) {pants=@" Suitable Pants,";}else{ pants=@"";}
        NSString *shoe=[[NSString alloc]init];
        if(self.lackOfShoes) {shoe=@" Suitable Shoes  ";}else{ shoe=@"";}
        NSString *umbrellas=[[NSString alloc]init];
        if(self.lackOfUmbrellas && _needUmbrella) {umbrellas=@"umbrellas";}else{ umbrellas=@"";}
        NSString *errormessage=[[NSString alloc]initWithFormat:@"%@%@%@%@%@",clothes,gloves,pants,shoe,umbrellas];
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Oops,Lack of" message:errormessage delegate:self cancelButtonTitle:@"Please add some" otherButtonTitles: nil];
        [alert show];
    }
      //[self.PickedClothes setImage:[UIImage imageWithData:imageData]];
}

- (IBAction)confirmChoice:(id)sender {
    if (!(self.lackOfClothes && self.lackOfPants && self.lackOfShoes)) {
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Want Choose?" message:@"make a decision" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alert show];
    }
//    NSDate *now=[NSDate date];
//    if(!self.lackOfClothes){
//    _cloth.selectTime=now;
//    }
//    if(!self.lackOfPants){
//    _pant.selectTime=now;
//    }
//    if(!self.lackOfShoes){
//    _shoes.selectTime=now;
//    }
}

- (IBAction)changeClothes:(id)sender {
    [self showSelectionOfClothes];
}

- (IBAction)changePants:(id)sender {
    [self showSelectionOfPants];
}

- (IBAction)changeShoes:(id)sender {
    [self showSelectionOfShoes];
}

- (IBAction)changeGloves:(id)sender {
    if (_needGlove) {
        [self showSelectionOfGlove];
    }
}

- (IBAction)changeUmbrellas:(id)sender {
    if (_needUmbrella) {
        [self showSelectionOfUmbrella];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
        { NSDate *now=[NSDate date];
            if(!self.lackOfClothes){
                [self save:_cloth atTime:now];
            }
            if(!self.lackOfPants){
                [self save:_pant atTime:now];
            }
            if(!self.lackOfShoes){
                [self save:_shoes atTime:now];
            }
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
            break;
    }
}
-(void)save:(Clothes *)cloth atTime:(NSDate *)date{
    NSManagedObjectID *clothID=[[NSManagedObjectID alloc]init];
    clothID=[cloth objectID];
    NSManagedObjectContext *moc=[kAppDelegate managedObjectContext];
    NSManagedObject *object=[kAppDelegate.managedObjectContext objectWithID:clothID];
    [object setValue:date forKeyPath:@"selectTime"];
    [object setValue:[NSNumber numberWithInt:1+[cloth.useTime intValue]] forKeyPath:@"useTime"];
    NSError *error;
    [moc save:&error];
}

-(void) takePeople{
    
    NSFileManager *manage=[NSFileManager defaultManager];
    NSString *docsDir;
    NSArray *dirPath;
    dirPath=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir=dirPath[0];
    NSString *p=[[NSString alloc] initWithString:[docsDir stringByAppendingString:@"/Username.archve"]];
    if ([manage fileExistsAtPath:p]) {
        NSMutableArray *dataArray=[[NSMutableArray alloc] init];
        dataArray =[NSKeyedUnarchiver unarchiveObjectWithFile:p];
        if (dataArray!=nil) {
            _mailId=[dataArray objectAtIndex:0];
        }
    }
}
-(void) fetchpeople
{   [self takePeople];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    NSManagedObjectContext *context=kAppDelegate.managedObjectContext;
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"People" inManagedObjectContext:context];
    [request setEntity:entity];
    NSPredicate *pre=[NSPredicate predicateWithFormat:@"mail =%@",_mailId];
    [request setPredicate:pre];
    NSError *error=nil;
    NSArray *ps= [context executeFetchRequest:request error:&error];
    People *tem=[ps objectAtIndex:0];
    _peo=tem;
    
    
    
}
- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue {}
@end
