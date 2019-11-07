//
//  DRAddMultipleImageManage.m
//  dr
//
//  Created by 毛文豪 on 2017/7/27.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "DRAddMultipleImageManage.h"
#import "TZImagePickerController.h"
#import "TZImageManager.h"
#import "TZPhotoPreviewController.h"
#import "TZLocationManager.h"
#import "MBProgressHUD+MJ.h"

@interface DRAddMultipleImageManage ()<TZImagePickerControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    NSMutableArray *_selectedAssets;
}

@property (nonatomic, strong) UIImagePickerController *imagePickerVc;

@end

@implementation DRAddMultipleImageManage

- (void)addImage
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //相机功能是否可用，调用相机
        if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
            [MBProgressHUD showError:@"相机不可用"];
            return;
        }
        [self pushImagePickerController];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //相册功能是否可用，调用相册
        if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary]){
            [MBProgressHUD showError:@"相册不可用"];
            return;
        }
        [self pushTZImagePickerController];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self.viewController presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - 调用相册
- (void)pushTZImagePickerController
{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:self.maxImageCount columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    [self setImagePickerControllerNav];
    
    if (self.maxImageCount > 1) {
        imagePickerVc.selectedAssets = _selectedAssets;
    }
    imagePickerVc.allowTakePicture = YES;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.allowCrop = YES;
    imagePickerVc.needCircleCrop = NO;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.viewController presentViewController:imagePickerVc animated:YES completion:nil];
}
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    NSMutableArray * images = [NSMutableArray array];
    for (UIImage * photo in photos) {
        [images addObject:[DRTool imageCompressionWithImage:photo]];
    }
    self.images = [NSMutableArray arrayWithArray:images];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    [self refreshImages];
}
#pragma mark - 调用相机
- (void)pushImagePickerController
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerVc.sourceType = sourceType;
        self.imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.viewController presentViewController:self.imagePickerVc animated:YES completion:nil];
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        TZImagePickerController *tzImagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
        [self setImagePickerControllerNav];
        [tzImagePickerVc showProgressHUD];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        image = [DRTool imageCompressionWithImage:image];
        
        // save photo and get asset / 保存图片，获取到asset
        [[TZImageManager manager] savePhotoWithImage:image completion:^(PHAsset *asset, NSError *error) {
            if (error) {
                [tzImagePickerVc hideProgressHUD];
            } else {
                [[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES needFetchAssets:NO completion:^(TZAlbumModel *model) {
                        [tzImagePickerVc hideProgressHUD];
                        TZAssetModel *assetModel = [model.models firstObject];
                        if (tzImagePickerVc.sortAscendingByModificationDate) {
                            assetModel = [model.models lastObject];
                        }
                        TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initCropTypeWithAsset:assetModel.asset photo:image completion:^(UIImage *cropImage, id asset) {
                            [self refreshCollectionViewWithAddedAsset:asset image:cropImage];
                        }];
                        imagePicker.needCircleCrop = NO;
                        imagePicker.allowTakePicture = YES;
                        imagePicker.allowPickingOriginalPhoto = NO;
                        imagePicker.allowCrop = YES;
                        imagePicker.allowPickingVideo = NO;
                        imagePicker.statusBarStyle = YES;
                        imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
                        [self.viewController presentViewController:imagePicker animated:YES completion:nil];
                }];
            }
        }];
    }
}

- (void)refreshCollectionViewWithAddedAsset:(id)asset image:(UIImage *)image {
    [_selectedAssets addObject:asset];
    [self.images addObject:[DRTool imageCompressionWithImage:image]];
    [self refreshImages];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)setImagePickerControllerNav
{
    UINavigationBar *navBar = [UINavigationBar appearance];
    // 设置背景
    [navBar setBackgroundImage:[UIImage ImageFromColor:DRColor(63, 63, 63, 1) WithRect:CGRectMake(0, 0, screenWidth, statusBarH + navBarH)] forBarMetrics:UIBarMetricsDefault];
}
#pragma mark - 以下三个方法为长按排序相关代码
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.item < self.images.count;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath canMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    return (sourceIndexPath.item < self.images.count && destinationIndexPath.item < self.images.count);
}
- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath didMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    UIImage *image = self.images[sourceIndexPath.item];
    [self.images removeObjectAtIndex:sourceIndexPath.item];
    [self.images insertObject:image atIndex:destinationIndexPath.item];
    
    if (_selectedAssets.count == self.images.count) {
        id asset = _selectedAssets[sourceIndexPath.item];
        [_selectedAssets removeObjectAtIndex:sourceIndexPath.item];
        [_selectedAssets insertObject:asset atIndex:destinationIndexPath.item];
    }
}

- (void)refreshImages
{
    if (_delegate && [_delegate respondsToSelector:@selector(imageManageAddImages:)]) {
        [_delegate imageManageAddImages:self.images];
    }
}
#pragma mark - 初始化
- (NSMutableArray *)images
{
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}
- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
    }
    return _imagePickerVc;
}

@end
