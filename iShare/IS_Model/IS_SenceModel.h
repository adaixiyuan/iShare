
/**
 *  把握整个场景
    1.保存整个场景数据: A.A1=B1+B2+B3+C1
    2.保存用过的图片数组
    3.
 */

#import "IS_BaseModel.h"

@interface IS_SenceModel : IS_BaseModel
/**
 *  整个场景的id
 */
@property (nonatomic,copy)NSString  * sence_id;
/**
 *  模板风格
 */
@property (nonatomic,assign)NSInteger sence_style;
/**
 *  子模板编号
 */
@property (nonatomic,assign)NSInteger sence_sub_type;
/**
 * 场景加+模板数组
 */
@property (nonatomic,strong)NSMutableArray  * sence_template_array;
/**
 *  图片数组
 */
@property (nonatomic,strong)NSMutableArray * image_array;

@property (nonatomic,copy)NSString * i_image;
@property (nonatomic,copy)NSString * i_title;
@property (nonatomic,copy)NSString * i_detail;


@end
