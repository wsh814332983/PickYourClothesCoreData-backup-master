//
//  CameraViewController.m
//  PickYourClothesCoreData
//
//  Created by tianxiang zhang on 4/5/14.
//  Copyright (c) 2014 tianxiang zhang. All rights reserved.
//

#import "CameraViewController.h"
#import "BrandViewController.h"
#import "People.h"

@interface CameraViewController ()

@property (strong,nonatomic) NSString *brandname;
@property (strong,nonatomic) NSString *mailId;
@property (strong,nonatomic) People *peo;
@property (strong,nonatomic) NSDate *date;
@property (nonatomic)BOOL needType;
@end

@implementation CameraViewController
@synthesize imageView=_imageView;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch=[[event allTouches] anyObject];
    if([_name isFirstResponder] && [touch view]!=_name){
        [_name resignFirstResponder];
    }else if ([_brand isFirstResponder]&&[touch view]!=_brand){
        [_brand resignFirstResponder];
    }else if ([_describe isFirstResponder]&& [touch view]!=_describe){
        [_describe resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //set imageview;
    [self fetchpeople];
    
    _date=[NSDate date];    
    _brandbutton.layer.cornerRadius=8;
    _brandbutton.layer.borderColor=(__bridge CGColorRef)([UIColor grayColor]);
    _brandbutton.layer.borderWidth=2;
    _brandbutton.backgroundColor=[UIColor whiteColor];
    _clothrate.font=[UIFont boldSystemFontOfSize:17];
    _color.font=[UIFont boldSystemFontOfSize:17];
    _type.font=[UIFont boldSystemFontOfSize:17];
    _description.font=[UIFont boldSystemFontOfSize:17];

    _describe.layer.cornerRadius=8;
    _imageView.layer.cornerRadius=8;
    _imageView.layer.masksToBounds=YES;
    _imageView.layer.borderWidth=2;
    _imageView.layer.borderColor=[[UIColor grayColor] CGColor];
    _image.layer.cornerRadius=8;
    _image.contentMode=UIViewContentModeScaleAspectFit;
    _image.frame=_imageView.frame;
    
    TQStarRatingView *starRatingView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(0, 0, 100, 20)
                                                                  numberOfStar:5];
    starRatingView.delegate = self;
    self.ratestar.backgroundColor=[UIColor clearColor];
    [self.ratestar addSubview:starRatingView];
    self.needType=YES;
    NSArray *colorItem=[NSArray arrayWithObjects:@"Black",@"White",@"Red",@"Green",@"Yellow",@"Blue",@"Brown",@"Purple",@"Orange",@"Cyan",@"Pink",@"Mixed", nil];
    self.ColorSelection.items=colorItem;
    if ([self.entitycloth isEqualToString:@"Jacketing"]) {
        NSArray *items=[NSArray arrayWithObjects:@"Sports Long",@"Sports Short",@"T-shirt",@"Sun-top",@"Chiffon",@"Skirt", @"Shirt",@"Dress",@"Sweater", @"Jacket",@"Fleece",@"Down Coat",@"Suit",nil];
        self.TypeSelection.items=items;}
    if ([self.entitycloth isEqualToString:@"Pants"]) {
        NSArray *items=[NSArray arrayWithObjects:@"Sports Long",@"Sports Short",@"Pants Long",@"Pants Middle",@"Pants Short",@"Suit", nil];
        self.TypeSelection.items=items;}
    if ([self.entitycloth isEqualToString:@"Shoes"]) {
        NSArray *items=[NSArray arrayWithObjects:@"Exercise", @"Sandal",@"Plimsolls",@"Warm Shoes",@"High Heel",@"Suit",nil];
        self.TypeSelection.items=items;}
    if([self.entitycloth isEqualToString:@"Umbrella"]||[self.entitycloth isEqualToString:@"Glove"]||[self.entitycloth isEqualToString:@"Belt"]||[self.entitycloth isEqualToString:@"Eyeglass"]){
        self.TypeSelection.hidden=YES;
        self.typeLabel.hidden=YES;
        self.needType=NO;
    }
   
   
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)starRatingView:(TQStarRatingView *)view score:(float)score
{
    _clothrate.text=[NSString stringWithFormat:@"Cloth rate:%0.2f",(score*5)];
    _ratecons=[NSNumber numberWithFloat:(score*5)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
        
    
    
    // Dispose of any resources that can be recreated.
}


#pragma camera;
- (IBAction)takepicture:(id)sender {
    UIActionSheet *photoBtnActionSheet =
    [[UIActionSheet alloc] initWithTitle:nil
                                delegate:self
                       cancelButtonTitle:@"Cancel"
                  destructiveButtonTitle:nil
                       otherButtonTitles:@"Photo Library",@"Take Photo", nil];
    [photoBtnActionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [photoBtnActionSheet showInView:[self.view window]];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeSavedPhotosAlbum])
        {
            UIImagePickerController *imagePicker =
            [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType =
            UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
            imagePicker.allowsEditing = YES;
            [self presentViewController:imagePicker
                               animated:YES completion:nil];
            _newMedia = NO;
        }
    }
    if (buttonIndex == 1) {
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *imagePicker =
            [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType =
            UIImagePickerControllerSourceTypeCamera;
            imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
            imagePicker.allowsEditing = YES;
            [self presentViewController:imagePicker
                               animated:YES completion:nil];
            _newMedia = YES;
        }
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
       // UIImage *ima=info[UIImagePickerControllerEditedImage];
        _image.image= image;
        if (_newMedia)
            UIImageWriteToSavedPhotosAlbum(image,
                                           self,
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        
    }
    CATransition *tran=[CATransition animation];
    NSTimeInterval inter=1;
    tran.duration=inter;
    tran.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    tran.type=@"cameraIrisHollowClose";
    tran.subtype=kCAMediaTimingFunctionEaseIn;
    tran.delegate=self;
    [self.imageView.layer addAnimation:tran forKey:nil];
}

-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}


#pragma save;
- (IBAction)save:(id)sender {
    _brandname=_brandbutton.titleLabel.text;
       if (_image.image!=nil&&![_name.text isEqualToString:@""]&&!([self.TypeSelection.text isEqualToString:@""]&&self.needType)&&!([_ratecons intValue]==0)&&![self.ColorSelection.text isEqualToString:@""]) {
           NSString *choice=_entitycloth;
           NSManagedObjectContext *moc=[kAppDelegate managedObjectContext];
        
           NSManagedObject *newCloth=[NSEntityDescription insertNewObjectForEntityForName:@"Clothes" inManagedObjectContext:moc];
           
           NSData *imageSave=UIImageJPEGRepresentation(_image.image, 1.0);
  
           [newCloth setValue:imageSave forKey:@"image"];
           [newCloth setValue:_name.text forKey:@"name"];
           [newCloth setValue:choice forKey:@"kindOf"];
           [newCloth setValue:_ratecons forKeyPath:@"rate"];
           [newCloth setValue:_describe.text forKeyPath:@"describe"];
           [newCloth setValue:_brand.text forKeyPath:@"describe"];
           [newCloth setValue:0 forKeyPath:@"useTime"];
           [newCloth setValue:_brandname forKey:@"brand"];
           [newCloth setValue:self.ColorSelection.text forKey:@"color"];
           [newCloth setValue:self.TypeSelection.text forKeyPath:@"type"];
           [newCloth setValue:_peo forKey:@"belong"];
           [newCloth setValue:_date forKey:@"addTime"];
    NSError *mocSaveError=nil;
    if ([moc save:&mocSaveError]) {
        
        [self performSegueWithIdentifier:@"backToMain" sender:self];
    }
    
}
    else if([_describe.text length]>150||[_name.text length]>15){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Oops" message:@"too long describe" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];

    }
    else{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Oops" message:@"Lack of Necessity(*)" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];}

}
#pragma takeuserInfo
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
    _peo=[ps objectAtIndex:0];
    

}

- (IBAction)cancel:(id)sender {
    [self performSegueWithIdentifier:@"backToMain" sender:self];
}
#pragma keyboard;
-(void) textViewDidBeginEditing:(UITextView *)textView
{
    textView.text=nil;
    CGRect frame = textView.frame;
    int offset = frame.origin.y + 80 - (self.view.frame.size.height - 216.0);
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];

}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{   
    textField.text=nil;
    CGRect frame = textField.frame;
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 216.0);
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toBrand"]) {
        BrandViewController *brandco=(BrandViewController *)[segue destinationViewController];
        brandco.label=_brandbutton.titleLabel.text;
    }
}
- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue {}
@end
