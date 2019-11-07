
//
//  DRAddMultipleImageView.m
//  dr
//
//  Created by 毛文豪 on 2017/4/17.
//  Copyright © 2017年 JG. All rights reserved.
//
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "DRAddMultipleImageView.h"
#import "DRVideoPlayerViewController.h"
#import "DRGridViewFlowLayout.h"
#import "TZImagePickerController.h"
#import "TZImageManager.h"
#import "TZPhotoPreviewController.h"
#import "TZLocationManager.h"
#import "MBProgressHUD+MJ.h"

@interface DRAddMultipleImageView ()<TZImagePickerControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    CGFloat _itemWH;
}
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;

@end

@implementation DRAddMultipleImageView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupChildViews];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupChildViews];
    }
    return self;
}
- (void)setupChildViews
{
    self.backgroundColor = [UIColor whiteColor];
    self.maxImageCount = 6;
    self.videoMaximumDuration = 10;
    //标题
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 0, self.width, 35)];
    self.titleLabel = titleLabel;
    titleLabel.textColor = DRBlackTextColor;
    titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [self addSubview:titleLabel];
    
    // 如不需要长按排序效果，将LxGridViewFlowLayout类改成UICollectionViewFlowLayout即可
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    _itemWH = (self.width - 5 * DRMargin) / 4;
    layout.itemSize = CGSizeMake(_itemWH, _itemWH);
    layout.minimumInteritemSpacing = DRMargin;
    layout.minimumLineSpacing = DRMargin;
    layout.sectionInset = UIEdgeInsetsMake(0, DRMargin, 0, DRMargin);
    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame), self.width, DRMargin + _itemWH) collectionViewLayout:layout];
    self.collectionView = collectionView;
    collectionView.alwaysBounceVertical = NO;
    collectionView.scrollEnabled = NO;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self addSubview:collectionView];
    [self.collectionView registerClass:[DRAddImageCollectionViewCell class] forCellWithReuseIdentifier:@"AddImageCollectionViewCellID"];
}

#pragma mark UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.supportVideo) {
        return self.images.count + 2;
    }
    return self.images.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DRAddImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddImageCollectionViewCellID" forIndexPath:indexPath];
    cell.deleteBtn.hidden = NO;
    if (self.supportVideo && indexPath.row == 0) {
        if (!DRStringIsEmpty(self.videoURL.absoluteString)) {
            UIImage * thumbnailImage = [DRTool getThumbnailImage:self.videoURL.absoluteString time:0];
            UIImage * playImage = [UIImage imageNamed:@"add_video_mask"];
            cell.imageView.image = [self getImageWithImage1:thumbnailImage image2:playImage];
        }else
        {
            cell.imageView.image = [UIImage imageNamed:@"add_video"];
            cell.deleteBtn.hidden = YES;
        }
    }else if (self.supportVideo + self.images.count == indexPath.row)
    {
        cell.imageView.image = [UIImage imageNamed:@"add_picture"];
        cell.deleteBtn.hidden = YES;
    }else
    {
        id imageObj = self.images[indexPath.row - self.supportVideo];
        if ([imageObj isKindOfClass:[UIImage class]]) {
            cell.imageView.image = imageObj;
        }else
        {
            if ([imageObj containsString:@"http"]) {
                [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", imageObj]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
            }else
            {
                [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, imageObj]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
            }
        }
    }
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.supportVideo && indexPath.row == 0) {
        if (DRStringIsEmpty(self.videoURL.absoluteString)) {
            [self chooseResourceIsVideo:YES];
        }else
        {
            DRVideoPlayerViewController * videoVC = [[DRVideoPlayerViewController alloc] init];
            videoVC.url = self.videoURL;
            [self.viewController.navigationController pushViewController:videoVC animated:YES];
        }
    }else if (self.supportVideo + self.images.count == indexPath.row)
    {
        if (self.images.count >= self.maxImageCount) {
            [MBProgressHUD showError:[NSString stringWithFormat:@"最多选择%d张图片", self.maxImageCount]];
            return;
        }
        [self chooseResourceIsVideo:NO];
    }
}

#pragma mark - 删除照片
- (void)deleteBtnClik:(UIButton *)sender {
    if (self.supportVideo && sender.tag == 0) {
        self.videoURL = nil;
        [self.collectionView reloadData];
    }else
    {
        [self.images removeObjectAtIndex:sender.tag - self.supportVideo];
        [self refreshView];
    }
}

#pragma mark - 选择视频/照片
- (void)chooseResourceIsVideo:(BOOL)isVideo
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSString * action1 = @"拍照";
    if (isVideo) {
        action1 = @"拍摄";
    }
    [alertController addAction:[UIAlertAction actionWithTitle:action1 style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //相机功能是否可用，调用相机
        if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
            [MBProgressHUD showError:@"相机不可用"];
            return;
        }
        [self pushCameraIsVideo:isVideo];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //相册功能是否可用，调用相册
        if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary]){
            [MBProgressHUD showError:@"相册不可用"];
            return;
        }
        [self pushPhotoLibraryIsVideo:isVideo];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self.viewController presentViewController:alertController animated:YES completion:nil];
}

//调用相机
- (void)pushCameraIsVideo:(BOOL)isVideo
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerVc.sourceType = sourceType;
        if (isVideo) {
            self.imagePickerVc.mediaTypes = @[(NSString*)kUTTypeMovie];
        }else
        {
            self.imagePickerVc.mediaTypes = @[(NSString*)kUTTypeImage];
        }
        self.imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.viewController presentViewController:self.imagePickerVc animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self.images addObject:[DRTool imageCompressionWithImage:image]];
        [self refreshView];
    }else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        //压缩
        AVURLAsset *avAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
        if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
            AVAssetExportSession * exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld_compressedVideo.mp4",time(NULL)]];
            exportSession.outputURL = [NSURL fileURLWithPath:path];
            exportSession.shouldOptimizeForNetworkUse = true;
            exportSession.outputFileType = AVFileTypeMPEG4;
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.videoURL = [NSURL fileURLWithPath:path];
                    });
                }
            }];
        }else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.videoURL = videoURL;
            });
        }
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//调用相册
- (void)pushPhotoLibraryIsVideo:(BOOL)isVideo {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:self.maxImageCount columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    [self setImagePickerControllerNav];
    
    if (!isVideo) {
        imagePickerVc.needCircleCrop = NO;
    }
    imagePickerVc.allowTakePicture = YES;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.allowPickingVideo = isVideo;
    imagePickerVc.allowPickingImage = !isVideo;
    imagePickerVc.videoMaximumDuration = self.videoMaximumDuration;
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.viewController presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos{
    NSMutableArray * images = [NSMutableArray array];
    for (UIImage * photo in photos) {
        [images addObject:[DRTool imageCompressionWithImage:photo]];
    }
    [self.images addObjectsFromArray:images];
    [self refreshView];
}

// 选择视频的回调
-(void)imagePickerController:(TZImagePickerController *)picker
       didFinishPickingVideo:(UIImage *)coverImage
                sourceAssets:(PHAsset *)asset{
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            AVURLAsset *urlAsset = (AVURLAsset *)asset;
            //压缩
            AVURLAsset *avAsset = [[AVURLAsset alloc] initWithURL:urlAsset.URL options:nil];
            NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
            if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
                AVAssetExportSession * exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
                NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld_compressedVideo.mp4",time(NULL)]];
                exportSession.outputURL = [NSURL fileURLWithPath:path];
                exportSession.shouldOptimizeForNetworkUse = true;
                exportSession.outputFileType = AVFileTypeMPEG4;
                [exportSession exportAsynchronouslyWithCompletionHandler:^{
                    if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.videoURL = [NSURL fileURLWithPath:path];
                        });
                    }
                }];
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.videoURL = urlAsset.URL;
                });
            }
        }];
    }
}

- (void)setImagePickerControllerNav
{
    UINavigationBar *navBar = [UINavigationBar appearance];
    // 设置背景
    [navBar setBackgroundImage:[UIImage ImageFromColor:DRColor(63, 63, 63, 1) WithRect:CGRectMake(0, 0, screenWidth, statusBarH + navBarH)] forBarMetrics:UIBarMetricsDefault];
}

//#pragma mark - 以下三个方法为长按排序相关代码
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)refreshView
{
    [self.collectionView reloadData];
    if (self.supportVideo) {
        self.collectionView.height = ((1 + self.images.count + 4) / 4 ) * (DRMargin + _itemWH);
    }else
    {
        self.collectionView.height = ((self.images.count + 4) / 4 ) * (DRMargin + _itemWH);
    }
    self.height = CGRectGetMaxY(self.collectionView.frame);
    if (_delegate && [_delegate respondsToSelector:@selector(viewHeightchange)]) {
        [_delegate viewHeightchange];
    }
}
- (CGFloat)getViewHeight
{
    return CGRectGetMaxY(self.collectionView.frame);
}

- (void)setImagesWithImage:(NSArray *)images
{
    self.images = [NSMutableArray arrayWithArray:images];
    [self refreshView];
}

- (void)setImagesWithImageUrlStrs:(NSArray *)imageUrlStrs
{
    self.images = [NSMutableArray arrayWithArray:imageUrlStrs];
    [self refreshView];
}

- (void)setVideoURL:(NSURL *)videoURL
{
    _videoURL = videoURL;
    
    [self refreshView];
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
        _imagePickerVc.videoMaximumDuration = self.videoMaximumDuration;
    }
    return _imagePickerVc;
}

#pragma mark - 合成图片
- (UIImage *)getImageWithImage1:(UIImage *)image1 image2:(UIImage *)image2
{
    CGSize size = CGSizeMake(78, 78);
    UIGraphicsBeginImageContext(size);
    [image1 drawInRect:CGRectMake(0, 0, size.width, size.height)];
    [image2 drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
