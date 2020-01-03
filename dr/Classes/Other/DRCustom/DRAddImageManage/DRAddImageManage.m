//
//  DRAddImageManage.m
//  dr
//
//  Created by 毛文豪 on 2017/4/17.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRAddImageManage.h"
#import "RSKImageCropper.h"

@interface DRAddImageManage ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate>

@end

@implementation DRAddImageManage

- (void)addImage
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //相机功能是否可用，调用相机
        if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
            [MBProgressHUD showError:@"相机不可用"];
            return;
        }
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = NO;
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.viewController presentViewController:picker animated:YES completion:nil];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //相册功能是否可用，调用相册
        if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary]){
            [MBProgressHUD showError:@"相册不可用"];
            return;
        }
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = NO;
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.viewController presentViewController:picker animated:YES completion:nil];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self.viewController presentViewController:alertController animated:YES completion:nil];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (self.type == 0) {//0不编辑 1圆形 2方形
        UIImage * croppedImage_ = [DRTool imageCompressionWithImage:image];
        if (_delegate && [_delegate respondsToSelector:@selector(imageManageCropImage:)]) {
            [_delegate imageManageCropImage:croppedImage_];
        }
        [picker dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image];
    imageCropVC.delegate = self;
    if (self.type == 1) {
        imageCropVC.cropMode = RSKImageCropModeCircle;
    }else if (self.type == 2)
    {
        imageCropVC.cropMode = RSKImageCropModeSquare;
    }
    [picker pushViewController:imageCropVC animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect
{
    UIImage * croppedImage_ = [DRTool imageCompressionWithImage:croppedImage];
    if (_delegate && [_delegate respondsToSelector:@selector(imageManageCropImage:)]) {
        [_delegate imageManageCropImage:croppedImage_];
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}


@end
