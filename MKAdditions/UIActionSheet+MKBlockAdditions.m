//
//  UIActionSheet+MKBlockAdditions.m
//  UIKitCategoryAdditions
//
//  Created by Mugunth on 21/03/11.
//  Copyright 2011 Steinlogic All rights reserved.
//

#import "UIActionSheet+MKBlockAdditions.h"

static DismissBlock _dismissBlock;
static CancelBlock _cancelBlock;
static PhotoPickedBlock _photoPickedBlock;
static UIViewController *_presentVC;

@implementation UIActionSheet (MKBlockAdditions)

+(void) actionSheetWithTitle:(NSString*) title
                     message:(NSString*) message
                     buttons:(NSArray*) buttonTitles
                  showInView:(UIView*) view
                   onDismiss:(DismissBlock) dismissed                   
                    onCancel:(CancelBlock) cancelled
{    
    [UIActionSheet actionSheetWithTitle:title 
                                message:message 
                 destructiveButtonTitle:nil 
                                buttons:buttonTitles 
                             showInView:view 
                              onDismiss:dismissed 
                               onCancel:cancelled];
}

+ (void) actionSheetWithTitle:(NSString*) title                     
                      message:(NSString*) message          
       destructiveButtonTitle:(NSString*) destructiveButtonTitle
                      buttons:(NSArray*) buttonTitles
                   showInView:(UIView*) view
                    onDismiss:(DismissBlock) dismissed                   
                     onCancel:(CancelBlock) cancelled
{
    _cancelBlock = nil;
    _cancelBlock  = cancelled;
    
    _dismissBlock = nil;
    _dismissBlock  = dismissed;

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title 
                                                             delegate:[self class] 
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:destructiveButtonTitle 
                                                    otherButtonTitles:nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    for(NSString* thisButtonTitle in buttonTitles)
        [actionSheet addButtonWithTitle:thisButtonTitle];
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    actionSheet.cancelButtonIndex = [buttonTitles count];
    
    if(destructiveButtonTitle)
        actionSheet.cancelButtonIndex ++;
    
    if([view isKindOfClass:[UIView class]])
        [actionSheet showInView:view];
    
    if([view isKindOfClass:[UITabBar class]])
        [actionSheet showFromTabBar:(UITabBar*) view];
    
    if([view isKindOfClass:[UIBarButtonItem class]])
        [actionSheet showFromBarButtonItem:(UIBarButtonItem*) view animated:YES];
}

+ (void) photoPickerWithTitle:(NSString*) title
                   showInView:(UIView*) view
                    presentVC:(UIViewController*) presentVC
                onPhotoPicked:(PhotoPickedBlock) photoPicked                   
                     onCancel:(CancelBlock) cancelled
{
    _cancelBlock = nil;
    _cancelBlock  = cancelled;
    
    _photoPickedBlock = nil;
    _photoPickedBlock  = photoPicked;
    
    _presentVC = nil;
    _presentVC = presentVC;
    
    int cancelButtonIndex = -1;

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title 
                                                             delegate:[self class] 
													cancelButtonTitle:nil
											   destructiveButtonTitle:nil
													otherButtonTitles:nil];
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		[actionSheet addButtonWithTitle:NSLocalizedString(@"Camera", @"")];
		cancelButtonIndex ++;
	}
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
	{
		[actionSheet addButtonWithTitle:NSLocalizedString(@"Photo library", @"")];
		cancelButtonIndex ++;
	}
    
	[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
	cancelButtonIndex ++;
	
    actionSheet.tag = kPhotoActionSheetTag;
	actionSheet.cancelButtonIndex = cancelButtonIndex;		 

	if([view isKindOfClass:[UIView class]])
        [actionSheet showInView:view];
    
    if([view isKindOfClass:[UITabBar class]])
        [actionSheet showFromTabBar:(UITabBar*) view];
    
    if([view isKindOfClass:[UIBarButtonItem class]])
        [actionSheet showFromBarButtonItem:(UIBarButtonItem*) view animated:YES];
}


+ (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *editedImage = (UIImage*) [info valueForKey:UIImagePickerControllerEditedImage];
    if(!editedImage)
        editedImage = (UIImage*) [info valueForKey:UIImagePickerControllerOriginalImage];
    
    _photoPickedBlock(editedImage);
	[picker dismissModalViewControllerAnimated:YES];	
}


+ (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // Dismiss the image selection and close the program
    [_presentVC dismissModalViewControllerAnimated:YES];
    if (_cancelBlock) {
        _cancelBlock();
    }
    
}

+(void)actionSheet:(UIActionSheet*) actionSheet didDismissWithButtonIndex:(NSInteger) buttonIndex
{
	if(buttonIndex == [actionSheet cancelButtonIndex])
	{
		if (_cancelBlock) {
            _cancelBlock();
        }
	}
    else
    {
        if(actionSheet.tag == kPhotoActionSheetTag)
        {
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                buttonIndex ++;
            }
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                buttonIndex ++;
            }
            
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = [self class];
            picker.allowsEditing = YES;
            
            if(buttonIndex == 1) 
            {                
                picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
            else if(buttonIndex == 2)
            {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;;
            }
            
            [_presentVC presentModalViewController:picker animated:YES];
        }
        else
        {
            if (_dismissBlock) {
                _dismissBlock(buttonIndex);
            }
        }
    }
}
@end
