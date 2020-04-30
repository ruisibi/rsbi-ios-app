/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： ZZZScatterPlotView 图形容器
 * 内容摘要： 图形视图
 * 其它说明： 实现文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月08日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/

#import "ZZZScatterPlotView.h"
#import "CorePlot-CocoaTouch.h"


#import "Common.h"
#import "DetailTipView.h"
#import "KxMenu.h"
#import "PlotButtonListView.h"
#import "ZZZBarPlotView.h"

#import "JYRadarChart.h"

NSString *  const ZZZPLOT1      = @"plot0";// 曲线1
NSString *  const ZZZPLOT2      = @"plot1";// 曲线2
NSString *  const ZZZPLOT3      = @"plot2";// 曲线3
NSString *  const ZZZPLOT4      = @"plot3";// 曲线4
NSString *  const ZZZPLOT5      = @"plot4";// 曲线5
NSString *  const ZZZPLOT6      = @"plot5";// 曲线6



@interface ZZZScatterPlotView()<CPTScatterPlotDataSource,CPTPlotSpaceDelegate,CPTPlotDelegate,CPTScatterPlotDelegate,PlotButtonListViewDelegate,CPTBarPlotDelegate,CPTPieChartDelegate,JYRadarChartDelegate>
{
  
    CPTGraph *graph;// 曲线图，柱状图，面积图
    CPTGraph *graphPie;// 饼状图
    CPTGraph *graphVBar;// 条形图
    NSMutableArray *dataArray;// 数组数据
    NSArray        *xDataArray;//x轴数据
    NSMutableDictionary *showIndexDict;// 需要显示的数据index
    NSArray       *keyArray;// 需要显示的键数组
    CGFloat            maxYcount;// y轴最大值
    CGFloat            maxShowNum;// y显示的最大值
    float            xInterval;// x轴间隔
    float          maxXcout;// x轴最大值
    DetailTipView  *dTipView;// 弹出视图
    NSMutableArray *xLabelArray;//x轴文字数组
    PlotButtonListView *pBtnListView;// 按扭视图
    
    NSInteger     curTmpIdx;//零时点
    float         totalValue;// 总值
    
    JYRadarChart *radaChart;// 雷达图
    
    BOOL         dismisFlag;// 消失提示框标记
}
@property (nonatomic, strong) CPTGraphHostingView *hostView;// 视图

@property (nonatomic, readwrite) NSUInteger offsetIndex;
@property (nonatomic, readwrite) CGFloat sliceOffset;

@end
@implementation ZZZScatterPlotView
@synthesize plotStyle;
@synthesize offsetIndex;
@synthesize sliceOffset;

/***********************************************************************
 * 方法名称： -- (instancetype)initWithFrame:(CGRect)frame withDataDict:(NSDictionary *)dict
 * 功能描述： 实例化视图
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (instancetype)initWithFrame:(CGRect)frame withDataDict:(NSDictionary *)dict
{
    self = [super initWithFrame: frame];
    if (self) {
        
        [self  initPlot];
     
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self) {
        maxYcount = 0;
        xInterval = 1;
        maxXcout  = MAX_XAXES;
        maxShowNum = 400;
        plotStyle = ZZZPLOTSTYLE_Scatter;
        xLabelArray = [[NSMutableArray alloc]init];
        [self  initPlot];
        UITapGestureRecognizer *gesTure = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
        [self.hostView addGestureRecognizer:gesTure];
    }
    return self;
}

/**********************添加点击事件*************************/
- (void)singleTap:(UITapGestureRecognizer *)gesTure
{
    
    CGPoint point = [gesTure locationInView:self.hostView];
    
   
//    NSLog(@"handleSingleTap!pointx:%f,y:%f",point.x,point.y);
    if (curTmpIdx != -1 && totalValue!=0) {
        
        
        NSString *keyStr = [keyArray objectAtIndex:curTmpIdx];
        NSNumber  *tmpIndex = [showIndexDict objectForKey:keyStr];
        totalValue = 0;
        for (NSString *ttkey in keyArray) {
            NSNumber  *ttidx= [showIndexDict objectForKey:ttkey];
            NSDictionary *ttDict = [dataArray objectAtIndex:ttidx.integerValue];
            NSNumber *  num22 = [ttDict objectForKey:@"value"];
            totalValue = totalValue + num22.floatValue;
        }
        NSDictionary *tDict = [dataArray objectAtIndex:tmpIndex.integerValue];
        NSNumber *  num = [tDict objectForKey:@"value"];
        NSString *rateStr = [NSString stringWithFormat:@"%0.2f%%",num.floatValue*100/totalValue];
        [self didSelectPie:tmpIndex.integerValue identi:keyStr withX:point.x withY:point.y withRate:rateStr];
    }else{
        if (dismisFlag != YES) {
            [dTipView disMissMenu];
        }
    }
    curTmpIdx = -1;
    dismisFlag = false;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer

{
    
    return YES;
    
}


/***********************************************************************
 * 方法名称： - (void)initPlotWithDict:(NSDictionary *)dict
 * 功能描述： 初始化数据
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)initPlotWithDict:(NSDictionary *)dict
{
        NSArray *xVals = [dict objectForKey:@"xVals"];
        NSArray *yVals = [dict objectForKey:@"yVals"];
        xLabelArray = [NSMutableArray arrayWithArray:xVals];
        dataArray    = [[NSMutableArray alloc]initWithArray:yVals];
        showIndexDict    = [NSMutableDictionary dictionaryWithCapacity:6];
     
        //解析数据
        for (int i=0; i<yVals.count; i++) {
            if (i > 5) {
                break;
            }
           
            NSString *key = [NSString stringWithFormat:@"plot%d",i];
           
            if (plotStyle == ZZZPLOTSTYLE_HBar || plotStyle == ZZZPLOTSTYLE_VBar || plotStyle == ZZZPLOTSTYLE_Pie) {
                key = [NSString stringWithFormat:@"barplot%d",i];
            }
            [showIndexDict setObject:[NSNumber numberWithInt:i] forKey:key];
        }
        
        //配置按扭 列表
        if (pBtnListView == nil) {
            pBtnListView = [[PlotButtonListView alloc]initWithFrame:CGRectMake(self.frame.size.width - 98, 10, 96, self.frame.size.height - 60)];
            pBtnListView.delegate = self;
            [self addSubview:pBtnListView];
        }
        pBtnListView.curStyle = self.plotStyle;
    
    if (plotStyle == ZZZPLOTSTYLE_Pie) {
        [pBtnListView reloadSelectedCell:showIndexDict total:xLabelArray];
    }else{
        [pBtnListView reloadSelectedCell:showIndexDict total:yVals];
    }
    
    
}

/***********************************************************************
 * 方法名称： 改变按扭的代理方法
 * 功能描述： 重载数据
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)didChangeSelected:(NSDictionary *)dict
{
    [dTipView disMissMenu];
    showIndexDict= [NSMutableDictionary dictionaryWithDictionary:dict];
    curTmpIdx = -1;
    totalValue = 0;
    keyArray = [showIndexDict allKeys];
    
    switch (plotStyle) {
        case ZZZPLOTSTYLE_VBar:
            [self reloadVBarAxes:xLabelArray];//配置xy轴
            [self configureBarsWith:graphVBar];//加载柱状
            [graphVBar reloadData];
            break;
        case ZZZPLOTSTYLE_Pie:
            
            [self configPieChart];
            [graphPie reloadData];
            break;
        case ZZZPLOTSTYLE_Radar:
            [self configRadarView];
            [self reloadRadarData];
            break;
        case ZZZPLOTSTYLE_HBar:
            
            [self reloadAxes:xLabelArray];
            [self configureBarsWith:graph];//加载柱状
            [graph reloadData];
            break;
        case ZZZPLOTSTYLE_Scatter:
            
        case ZZZPLOTSTYLE_Area:
            [self reloadAxes:xLabelArray];
            
            [self configurePlots];//加载线条
            [graph reloadData];
            break;
        default:
            break;
    }
    
    
}

- (void)reloadPlotWithStyle:(ZZZPLOTSTYLE)style withData:(NSDictionary *)dict
{
    plotStyle = style;
    
    curTmpIdx = -1;
    totalValue = 0;
    
    //重载数据
    [self initPlotWithDict:dict];
    
    keyArray = [showIndexDict allKeys];
    // 隐藏提示
    [dTipView disMissMenu];
    
    // 重置视图
    [self resetShowGraph];
    
    switch (plotStyle) {
        case ZZZPLOTSTYLE_VBar:
            [self reloadVBarAxes:xLabelArray];//配置xy轴
            [self configureBarsWith:graphVBar];//加载柱状
            [graphVBar reloadData];
            break;
        case ZZZPLOTSTYLE_Pie:
            
            [self configPieChart];
            [graphPie reloadData];
            break;
        case ZZZPLOTSTYLE_Radar:
            [self reloadRadarData];
            break;
        case ZZZPLOTSTYLE_HBar:
            
            [self reloadAxes:xLabelArray];
            [self configureBarsWith:graph];//加载柱状
            [graph reloadData];
            break;
        case ZZZPLOTSTYLE_Scatter:
        
        case ZZZPLOTSTYLE_Area:
            [self reloadAxes:xLabelArray];
            
            [self configurePlots];//加载线条
            [graph reloadData];
            break;
        default:
            break;
    }
}


/***********************************************************************
 * 方法名称： configRadarView
 * 功能描述： 配置雷达视图
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)configRadarView
{
    if (radaChart == nil) {
        //添加雷达图
        radaChart = [[JYRadarChart alloc]initWithFrame:CGRectMake(30, 20, self.frame.size.width - 100, self.frame.size.height)];
        radaChart.center = CGPointMake(self.hostView.frame.size.width/2, self.frame.size.height/2);
        radaChart.hidden = YES;
        radaChart.showStepText = NO;
        radaChart.delegate = self;
        radaChart.fillArea = NO;
        radaChart.showStepText = YES;
        radaChart.drawPoints = YES;
        radaChart.steps = 2;
        radaChart.minValue = 0;
        [self insertSubview:radaChart belowSubview:dTipView];

    }
    
}

/***********************************************************************
 * 方法名称： resetShowGraph
 * 功能描述： 重置展示视图
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)resetShowGraph
{
    switch (plotStyle) {
        case ZZZPLOTSTYLE_Scatter://折线图
        case ZZZPLOTSTYLE_Area://面积图
        case ZZZPLOTSTYLE_HBar://柱状图
            self.hostView.hidden = false;
            radaChart.hidden = YES;
            self.hostView.hostedGraph = graph;
            break;
        case ZZZPLOTSTYLE_VBar://条形图
            self.hostView.hidden = false;
            radaChart.hidden = YES;
            self.hostView.hostedGraph = graphVBar;
            break;
        case ZZZPLOTSTYLE_Pie://饼状图
            self.hostView.hidden = false;
            radaChart.hidden = YES;
            self.hostView.hostedGraph = graphPie;
            break;
        case ZZZPLOTSTYLE_Radar://雷达图
            self.hostView.hidden = YES;
            [self configRadarView];
            radaChart.hidden = false;
            
            break;
        default:
            break;
    }
}


/***********************************************************************
 * 方法名称： - (void)radarViewDidSelectAt:(int)groupIndex index:(int)index withPoint:(CGPoint)point
 * 功能描述： 选中雷达图
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)radarViewDidSelectAt:(int)groupIndex index:(int)index withPoint:(CGPoint)point
{
    NSString *title = radaChart.attributes[index];
    NSString *ltitle = radaChart.lineNames[groupIndex];
    NSString *ttnumber = radaChart.dataSeries[groupIndex][index];
 
    [dTipView reloadDetailView:ltitle detail:[NSString stringWithFormat:@"%@：%@ %@",title,ttnumber,self.yUnit]];
    
    [dTipView showTipView:point];
    
}

/***********************************************************************
 * 方法名称： reloadRadarData
 * 功能描述： 刷新雷达图
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)reloadRadarData
{
    NSMutableArray *dataSource = [[NSMutableArray alloc]init];
    NSMutableArray *attrArray  = [[NSMutableArray alloc]init];
    NSMutableArray *dataIndex  = [[NSMutableArray alloc]init];
    float  maxValue = 0;
    NSArray *keys = [NSArray arrayWithArray:keyArray];
    for (int i=0; i<keys.count;i++) {
        NSString *ttKey =  [keys[i] substringFromIndex:4];
        NSNumber *tIndex = [showIndexDict objectForKey:keys[i]];
        NSDictionary *tmpDict = [dataArray objectAtIndex:tIndex.intValue];
        NSArray *ttArr = [tmpDict objectForKey:@"Entry"];
        NSMutableArray *tEntry = [[NSMutableArray alloc]init];
        for (NSDictionary *tttdict in ttArr) {
            NSNumber *valRadar = [tttdict objectForKey:@"value"];
            if (valRadar.floatValue > maxValue) {
                maxValue = valRadar.floatValue;
            }
            [tEntry addObject:valRadar];
        }
        [dataIndex addObject:ttKey];
        [dataSource addObject:tEntry];
        [attrArray addObject:[tmpDict objectForKey:@"label"]];
    }
   
    radaChart.dataSeries = [dataSource copy];
    radaChart.attributes = [xLabelArray copy];
    radaChart.dataIndex  = [dataIndex copy];
    radaChart.lineNames  = [attrArray copy];
    
    CGFloat ttMax = [Common getYMax:maxValue];
    CGFloat tYmax = ttMax/4;
    if (maxYcount <= 1) {
        ttMax = [Common getYMaxFloat:maxYcount];
        tYmax = ttMax/4;
    }
    
    radaChart.maxValue   = ttMax;
    
    [radaChart setNeedsDisplay];
}


/***********************************************************************
 * 方法名称： initPlot
 * 功能描述： 初始化试图
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
-(void)initPlot {
    dTipView = [[DetailTipView alloc]init];
    dTipView.hidden = true;
    dismisFlag = false;
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
    
    [self addSubview:dTipView];
}

-(void)configureHost {
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 100, self.frame.size.height)];

    self.hostView.allowPinchScaling = YES;
    [self addSubview:self.hostView];
}

-(void)configureGraph {
    // 创建折线图graph
    graph = [[CPTXYGraph alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 100, self.frame.size.height)];
 
    [graph  setPaddingBottom:0];
    [graph  setPaddingRight:0];
    [graph  setPaddingLeft:10];
    [graph  setPaddingTop:10];
    graph.plotAreaFrame.borderLineStyle = nil;
 
    // 4 - Set padding for plot area
    [graph.plotAreaFrame setPaddingTop:10];
    [graph.plotAreaFrame setPaddingLeft:55.0f];
    [graph.plotAreaFrame setPaddingRight:0];
    [graph.plotAreaFrame setPaddingBottom:60.0f];
    // 5 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.delegate = self;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromFloat(maxXcout)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(MAX_YAXES)];
    
    // 创建条形图
    graphVBar = [[CPTXYGraph alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width- 100, self.frame.size.height)];
 
    [graphVBar  setPaddingBottom:0];
    [graphVBar  setPaddingRight:0];
    [graphVBar  setPaddingLeft:10];
    [graphVBar  setPaddingTop:0];
    graphVBar.plotAreaFrame.borderLineStyle = nil;
  
    // 4 - Set padding for plot area
    [graphVBar.plotAreaFrame setPaddingTop:10];
    [graphVBar.plotAreaFrame setPaddingLeft:55.0f];
    [graphVBar.plotAreaFrame setPaddingRight:0];
    [graphVBar.plotAreaFrame setPaddingBottom:60.0f];
    // 5 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace2 = (CPTXYPlotSpace *) graphVBar.defaultPlotSpace;
    plotSpace2.delegate = self;
    plotSpace2.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromFloat(maxXcout)];
    plotSpace2.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(10)];
    
    // 创建饼状图
    graphPie = [[CPTXYGraph alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width- 100, self.frame.size.height)];
    [graphPie  setPaddingBottom:0];
    [graphPie  setPaddingRight:0];
    [graphPie  setPaddingLeft:0];
    [graphPie  setPaddingTop:0];
     graphPie.plotAreaFrame.borderLineStyle = nil;
    // 4 - Set padding for plot area
    [graphPie.plotAreaFrame setPaddingTop:0];
    [graphPie.plotAreaFrame setPaddingLeft:30.0f];
    [graphPie.plotAreaFrame setPaddingRight:0];
    [graphPie.plotAreaFrame setPaddingBottom:30.0f];
}

/***********************************************************************
 * 方法名称： 配置饼状图
 * 功能描述： 选择样式刷新视图
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)configPieChart
{
    [graphPie removePlotWithIdentifier:@"pieplot"];
    self.offsetIndex = NSNotFound;
    
    graphPie.plotAreaFrame.masksToBorder = NO;
    graphPie.axisSet                     = nil;
    graphPie.defaultPlotSpace.delegate   =self;
    
    // Add pie chart
    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    piePlot.dataSource = self;
    piePlot.pieRadius  = MIN( CPTFloat(0.7) * (self.frame.size.height - CPTFloat(2.0) * graphPie.paddingLeft) / CPTFloat(2.0),
                             CPTFloat(0.7) * (self.frame.size.width - CPTFloat(2.0) * graphPie.paddingTop) / CPTFloat(2.0) );
    piePlot.identifier     = @"pieplot";
    piePlot.delegate       = self;
    piePlot.startAngle     = CPTFloat(M_PI_4);
    piePlot.sliceDirection = CPTPieDirectionCounterClockwise;
    //    piePlot.overlayFill    = [CPTFill fillWithGradient:overlayGradient];
   
    
    //饼图文字展示方向和位置
    piePlot.labelRotationRelativeToRadius = YES;//文字是否顺着图形的方向
    
    piePlot.labelRotation                 = CPTFloat(-M_PI_2);
    piePlot.labelOffset                   = 10.0;
    
    
    [graphPie addPlot:piePlot];
    
}


/***********************************************************************
 * 方法名称：-(void)configureBars
 * 功能描述： 配置柱状图
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/

- (void)configureBarsWith:(CPTGraph *)cGraph
{
    // 清楚所以线
    [cGraph removePlotWithIdentifier:ZZZBARPLOT1];
    [cGraph removePlotWithIdentifier:ZZZBARPLOT2];
    [cGraph removePlotWithIdentifier:ZZZBARPLOT3];
    [cGraph removePlotWithIdentifier:ZZZBARPLOT4];
    [cGraph removePlotWithIdentifier:ZZZBARPLOT5];
    [cGraph removePlotWithIdentifier:ZZZBARPLOT6];
    
    // 1 - Get graph and plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) cGraph.defaultPlotSpace;
   
    // 创建颜色
    CPTColor *aaplColor = [CPTColor colorWithComponentRed:69/255.0 green:114/255.0 blue:167/255.0 alpha:1];
    CPTColor *aaplColor2 = [CPTColor colorWithComponentRed:170/255.0 green:70/255.0 blue:67/255.0 alpha:1];
    CPTColor *aaplColor3 = [CPTColor colorWithComponentRed:137/255.0 green:165/255.0 blue:77/255.0 alpha:1];
    CPTColor *aaplColor4 = [CPTColor colorWithComponentRed:128/255.0 green:105/255.0 blue:155/255.0 alpha:1];
    CPTColor *aaplColor5 = [CPTColor colorWithComponentRed:61/255.0 green:150/255.0 blue:174/255.0 alpha:1];
    CPTColor *aaplColor6 = [CPTColor colorWithComponentRed:219/255.0 green:132/255.0 blue:61/255.0 alpha:1];
    
    
    int sCount = [showIndexDict count];
    if (sCount == 0) {
        return;
    }
    
    float max_width = xInterval * 0.8;
    if (max_width >= MAX_BAR_WIDTH) {
        max_width = MAX_BAR_WIDTH;
    }
    float barWith = max_width / [showIndexDict count];
    
    // 2 - 创建6个柱子
    //第一个柱子
    
    CPTBarPlot *barPlot1 = [[CPTBarPlot alloc]init];
    barPlot1.dataSource= self;
    barPlot1.delegate= self;
    //柱子的宽度显示
    barPlot1.fill = [CPTFill fillWithColor:aaplColor];
    CPTMutableLineStyle *aaplLineStyle = [barPlot1.lineStyle mutableCopy];
    aaplLineStyle.lineWidth = 0.0;
    aaplLineStyle.lineColor = aaplColor;
    barPlot1.lineStyle = aaplLineStyle;
    barPlot1.barWidth=CPTDecimalFromFloat(barWith);
    barPlot1.baseValue=CPTDecimalFromString(@"0");
    barPlot1.barOffset=CPTDecimalFromString(@"0.5"); //x轴位置偏移量(每个柱子之间的距离包括第一次的距离)
    barPlot1.identifier = ZZZBARPLOT1;
    if (plotStyle == ZZZPLOTSTYLE_VBar) {
        barPlot1.barsAreHorizontal = YES;
    }else{
        barPlot1.barsAreHorizontal = NO;
    }
    [cGraph addPlot:barPlot1 toPlotSpace:plotSpace];
    
    CPTBarPlot *barPlot2 = [[CPTBarPlot alloc]init];
    barPlot2.dataSource= self;
    barPlot2.delegate= self;
    //柱子的宽度显示
    barPlot2.lineStyle = aaplLineStyle;
    barPlot2.fill = [CPTFill fillWithColor:aaplColor2];
    barPlot2.barWidth=CPTDecimalFromFloat(barWith);
    barPlot2.baseValue=CPTDecimalFromString(@"0");
    barPlot2.barOffset=CPTDecimalFromString(@"0.5"); //x轴位置偏移量(每个柱子之间的距离包括第一次的距离)
    barPlot2.identifier = ZZZBARPLOT2;
    if (plotStyle == ZZZPLOTSTYLE_VBar) {
        barPlot2.barsAreHorizontal = YES;
    }else{
        barPlot2.barsAreHorizontal = NO;
    }
    [cGraph addPlot:barPlot2 toPlotSpace:plotSpace];
    
    
    CPTBarPlot *barPlot3 = [[CPTBarPlot alloc]init];
    barPlot3.dataSource= self;
    barPlot3.delegate= self;
    //柱子的宽度显示
    barPlot3.lineStyle = aaplLineStyle;
    barPlot3.fill = [CPTFill fillWithColor:aaplColor3];
    barPlot3.barWidth=CPTDecimalFromFloat(barWith);
    barPlot3.baseValue=CPTDecimalFromString(@"0");
    barPlot3.barOffset=CPTDecimalFromString(@"0.5"); //x轴位置偏移量(每个柱子之间的距离包括第一次的距离)
    barPlot3.identifier = ZZZBARPLOT3;
    if (plotStyle == ZZZPLOTSTYLE_VBar) {
        barPlot3.barsAreHorizontal = YES;
    }else{
        barPlot3.barsAreHorizontal = NO;
    }
    [cGraph addPlot:barPlot3 toPlotSpace:plotSpace];

    CPTBarPlot *barPlot4 = [[CPTBarPlot alloc]init];
    barPlot4.dataSource= self;
    barPlot4.delegate= self;
    //柱子的宽度显示
    barPlot4.lineStyle = aaplLineStyle;
    barPlot4.fill = [CPTFill fillWithColor:aaplColor4];
    barPlot4.barWidth=CPTDecimalFromFloat(barWith);
    barPlot4.baseValue=CPTDecimalFromString(@"0");
    barPlot4.barOffset=CPTDecimalFromString(@"0.5"); //x轴位置偏移量(每个柱子之间的距离包括第一次的距离)
    barPlot4.identifier = ZZZBARPLOT4;
    if (plotStyle == ZZZPLOTSTYLE_VBar) {
        barPlot4.barsAreHorizontal = YES;
    }else{
        barPlot4.barsAreHorizontal = NO;
    }
    [cGraph addPlot:barPlot4 toPlotSpace:plotSpace];
    
    CPTBarPlot *barPlot5 = [[CPTBarPlot alloc]init];
    barPlot5.dataSource= self;
    barPlot5.delegate= self;
    //柱子的宽度显示
    barPlot5.lineStyle = aaplLineStyle;
    barPlot5.fill = [CPTFill fillWithColor:aaplColor5];
    barPlot5.barWidth=CPTDecimalFromFloat(barWith);
    barPlot5.baseValue=CPTDecimalFromString(@"0");
    barPlot5.barOffset=CPTDecimalFromString(@"0.5"); //x轴位置偏移量(每个柱子之间的距离包括第一次的距离)
    barPlot5.identifier = ZZZBARPLOT5;
    if (plotStyle == ZZZPLOTSTYLE_VBar) {
        barPlot5.barsAreHorizontal = YES;
    }else{
        barPlot5.barsAreHorizontal = NO;
    }
    [cGraph addPlot:barPlot5 toPlotSpace:plotSpace];
    
    CPTBarPlot *barPlot6 = [[CPTBarPlot alloc]init];
    barPlot6.dataSource= self;
    barPlot6.delegate= self;
    //柱子的宽度显示
    barPlot6.lineStyle = aaplLineStyle;
    barPlot6.fill = [CPTFill fillWithColor:aaplColor6];
    barPlot6.barWidth=CPTDecimalFromFloat(barWith);
    barPlot6.baseValue=CPTDecimalFromString(@"0");
    barPlot6.barOffset=CPTDecimalFromString(@"0.5"); //x轴位置偏移量(每个柱子之间的距离包括第一次的距离)
    barPlot6.identifier = ZZZBARPLOT6;
    if (plotStyle == ZZZPLOTSTYLE_VBar) {
        barPlot6.barsAreHorizontal = YES;
    }else{
        barPlot6.barsAreHorizontal = NO;
    }
    [cGraph addPlot:barPlot6 toPlotSpace:plotSpace];
    
    //动态设置柱状图
    [self setBarOffsetDay:cGraph];
}

/***********************************************************************
 * 方法名称：-(void)setBarOffsetDay
 * 功能描述： 动态设置柱状图
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)setBarOffsetDay:(CPTGraph *)cGraph
{
    int sCount = [showIndexDict count];
    
    float max_width = xInterval * 0.8;
    if (max_width >= MAX_BAR_WIDTH) {
        max_width = MAX_BAR_WIDTH;
    }
    NSArray *arrKey = [showIndexDict allKeys];
    float barWith = max_width / [showIndexDict count];
    
    switch (sCount) {
        case 1:{
            CPTBarPlot *barPlot =(CPTBarPlot *)[cGraph plotWithIdentifier:[arrKey firstObject]];
            barPlot.barOffset=CPTDecimalFromString(@"0.5");
            break;
        }
        case 2:
            for (int i=0; i<arrKey.count; i++) {
                CPTBarPlot *barPlot =(CPTBarPlot *)[cGraph plotWithIdentifier:arrKey[i]];
                if (i == 0) {
                    barPlot.barOffset = CPTDecimalFromFloat(0.5 - barWith/2);
                    
                }else{
                    barPlot.barOffset = CPTDecimalFromFloat(0.5+barWith/2);
                }
            }
            break;
        case 3:
            for (int i=0; i<arrKey.count; i++) {
                CPTBarPlot *barPlot =(CPTBarPlot *)[cGraph plotWithIdentifier:arrKey[i]];
                if (i == 0) {
                    barPlot.barOffset=CPTDecimalFromFloat(0.5  - barWith);
                    
                }else if(i == 1){
                    barPlot.barOffset = CPTDecimalFromFloat(0.5);
                }else{
                    barPlot.barOffset=CPTDecimalFromFloat(0.5 + barWith);
                }
            }
            
            break;
        case 4:
            for (int i=0; i<arrKey.count; i++) {
                CPTBarPlot *barPlot =(CPTBarPlot *)[cGraph plotWithIdentifier:arrKey[i]];
                if (i == 0) {
                   barPlot.barOffset=CPTDecimalFromFloat(0.5 - barWith/2 - barWith);
                    
                }else if(i == 1){
                    barPlot.barOffset = CPTDecimalFromFloat(0.5 - barWith/2);
                }else if(i == 2){
                   barPlot.barOffset=CPTDecimalFromFloat(0.5 + barWith/2);
                }else{
                     barPlot.barOffset = CPTDecimalFromFloat(0.5 + barWith + barWith/2);
                }
            }
           
            break;
        case 5:
            for (int i=0; i<arrKey.count; i++) {
                CPTBarPlot *barPlot =(CPTBarPlot *)[cGraph plotWithIdentifier:arrKey[i]];
                if (i == 0) {
                    barPlot.barOffset=CPTDecimalFromFloat(0.5   - barWith*2);
                    
                }else if(i == 1){
                    barPlot.barOffset = CPTDecimalFromFloat(0.5 - barWith);
                }else if(i == 2){
                    barPlot.barOffset=CPTDecimalFromFloat(0.5 );
                }else if(i == 3){
                    barPlot.barOffset = CPTDecimalFromFloat(0.5 + barWith );
                }else{
                    barPlot.barOffset = CPTDecimalFromFloat(0.5 + barWith*2);
                }
            }
           
            break;
        case 6:
            for (int i=0; i<arrKey.count; i++) {
                CPTBarPlot *barPlot =(CPTBarPlot *)[cGraph plotWithIdentifier:arrKey[i]];
                if (i == 0) {
                    barPlot.barOffset=CPTDecimalFromFloat(0.5   - barWith*2 - barWith/2);
                    
                }else if(i == 1){
                    barPlot.barOffset = CPTDecimalFromFloat(0.5 - barWith/2 - barWith);
                }else if(i == 2){
                    barPlot.barOffset=CPTDecimalFromFloat(0.5  - barWith/2);
                }else if(i == 3){
                    barPlot.barOffset = CPTDecimalFromFloat(0.5 + barWith/2 );
                }else if(i == 4){
                    barPlot.barOffset = CPTDecimalFromFloat(0.5 + barWith + barWith/2);
                }else{
                    barPlot.barOffset = CPTDecimalFromFloat(0.5 + barWith*2 + barWith/2);
                }
            }
            
            break;
        default:
            break;
    }
    
}

/***********************************************************************
 * 方法名称：-(void)removePlotAndBar
 * 功能描述： 移除图形
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)removePlotAndBar
{
    // 重置graph
    [graph removePlotWithIdentifier:ZZZPLOT1];
    [graph removePlotWithIdentifier:ZZZPLOT2];
    [graph removePlotWithIdentifier:ZZZPLOT3];
    [graph removePlotWithIdentifier:ZZZPLOT4];
    [graph removePlotWithIdentifier:ZZZPLOT5];
    [graph removePlotWithIdentifier:ZZZPLOT6];
    
    [graph removePlotWithIdentifier:ZZZBARPLOT1];
    [graph removePlotWithIdentifier:ZZZBARPLOT2];
    [graph removePlotWithIdentifier:ZZZBARPLOT3];
    [graph removePlotWithIdentifier:ZZZBARPLOT4];
    [graph removePlotWithIdentifier:ZZZBARPLOT5];
    [graph removePlotWithIdentifier:ZZZBARPLOT6];
}

/***********************************************************************
 * 方法名称：-(void)configurePlots
 * 功能描述： 配置折线
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/

-(void)configurePlots {
    
    // 清楚所以线
    [self removePlotAndBar];
    
    // 1 - Get graph and plot space
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
 
    
    
    // 2 - 创建6个线条
    // 线条1
    CPTScatterPlot *aaplPlot1 = [[CPTScatterPlot alloc] init];
    aaplPlot1.dataSource = self;
    aaplPlot1.delegate   = self;
    aaplPlot1.identifier = ZZZPLOT1;
    
    [graph addPlot:aaplPlot1 toPlotSpace:plotSpace];
    
    // 线条2
    CPTScatterPlot *aaplPlot2 = [[CPTScatterPlot alloc] init];
    aaplPlot2.dataSource = self;
    aaplPlot2.delegate   = self;
    aaplPlot2.identifier = ZZZPLOT2;
    
    [graph addPlot:aaplPlot2 toPlotSpace:plotSpace];
    
    // 线条3
    CPTScatterPlot *aaplPlot3 = [[CPTScatterPlot alloc] init];
    aaplPlot3.dataSource = self;
    aaplPlot3.delegate   = self;
    aaplPlot3.identifier = ZZZPLOT3;
    
    [graph addPlot:aaplPlot3 toPlotSpace:plotSpace];
    
    // 线条4
    CPTScatterPlot *aaplPlot4 = [[CPTScatterPlot alloc] init];
    aaplPlot4.dataSource = self;
    aaplPlot4.delegate   = self;
    aaplPlot4.identifier = ZZZPLOT4;
    
    [graph addPlot:aaplPlot4 toPlotSpace:plotSpace];
    
    // 线条5
    CPTScatterPlot *aaplPlot5 = [[CPTScatterPlot alloc] init];
    aaplPlot5.dataSource = self;
    aaplPlot5.delegate   = self;
    aaplPlot5.identifier = ZZZPLOT5;
    
    [graph addPlot:aaplPlot5 toPlotSpace:plotSpace];
    
    // 线条6
    CPTScatterPlot *aaplPlot6 = [[CPTScatterPlot alloc] init];
    aaplPlot6.dataSource = self;
    aaplPlot6.delegate   = self;
    aaplPlot6.identifier = ZZZPLOT6;
    
    [graph addPlot:aaplPlot6 toPlotSpace:plotSpace];
    
    
    // 3 - 线条样式
    // 线条1颜色
    CPTColor *aaplColor = [CPTColor colorWithComponentRed:69/255.0 green:114/255.0 blue:167/255.0 alpha:1];
    CPTMutableLineStyle *aaplLineStyle = [aaplPlot1.dataLineStyle mutableCopy];
    aaplLineStyle.lineWidth = 3.0;
    aaplLineStyle.lineColor = aaplColor;
    aaplPlot1.dataLineStyle = aaplLineStyle;
    CPTMutableLineStyle *aaplSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    aaplSymbolLineStyle.lineColor = aaplColor;
    CPTPlotSymbol *aaplSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    aaplSymbol.fill = [CPTFill fillWithColor:aaplColor];
    aaplSymbol.lineStyle = aaplSymbolLineStyle;
    aaplSymbol.size = CGSizeMake(8.0f, 8.0f);
    aaplPlot1.plotSymbol = aaplSymbol;
    aaplPlot1.opacity = 0.0f;
    aaplPlot1.plotSymbolMarginForHitDetection = 12;// 增加点击区域
    
    if (plotStyle == ZZZPLOTSTYLE_Area) {// 是面积就增加区域
        // 创建一个颜色渐变：从 建变色 1 渐变到 无色
        CPTGradient *areaGradient = [ CPTGradient gradientWithBeginningColor :aaplColor endingColor :[CPTColor colorWithComponentRed:69/255.0 green:114/255.0 blue:167/255.0 alpha:0.2]];
        // 渐变角度： -90 度（顺时针旋转）
        areaGradient.angle = -90.0f ;
        // 创建一个颜色填充：以颜色渐变进行填充
        CPTFill *areaGradientFill = [ CPTFill fillWithGradient :areaGradient];
        // 为图形设置渐变区
        aaplPlot1.areaFill = areaGradientFill;
        aaplPlot1.areaBaseValue = CPTDecimalFromString ( @"0.0" );
        aaplPlot1.interpolation = CPTScatterPlotInterpolationLinear ;
    }
    
    
    
    // 线条2颜色
    CPTColor *aaplColor2 = [CPTColor colorWithComponentRed:170/255.0 green:70/255.0 blue:67/255.0 alpha:1];
    CPTMutableLineStyle *aaplLineStyle2 = [aaplPlot2.dataLineStyle mutableCopy];
    aaplLineStyle2.lineWidth = 3.0;
    aaplLineStyle2.lineColor = aaplColor2;
    aaplPlot2.dataLineStyle = aaplLineStyle2;
    CPTMutableLineStyle *aaplSymbolLineStyle2 = [CPTMutableLineStyle lineStyle];
    aaplSymbolLineStyle2.lineColor = aaplColor2;
    CPTPlotSymbol *aaplSymbol2 = [CPTPlotSymbol diamondPlotSymbol];
    aaplSymbol2.fill = [CPTFill fillWithColor:aaplColor2];
    aaplSymbol2.lineStyle = aaplSymbolLineStyle2;
    aaplSymbol2.size = CGSizeMake(8.0f, 8.0f);
    aaplPlot2.plotSymbol = aaplSymbol2;
    aaplPlot2.opacity = 0.0f;
    aaplPlot2.plotSymbolMarginForHitDetection = 12;// 增加点击区域
    
    if (plotStyle == ZZZPLOTSTYLE_Area) {// 是面积就增加区域
        // 创建一个颜色渐变：从 建变色 1 渐变到 无色
        CPTGradient *areaGradient = [ CPTGradient gradientWithBeginningColor :aaplColor2 endingColor :[CPTColor colorWithComponentRed:170/255.0 green:70/255.0 blue:67/255.0 alpha:0.2]];
        // 渐变角度： -90 度（顺时针旋转）
        areaGradient.angle = -90.0f ;
        // 创建一个颜色填充：以颜色渐变进行填充
        CPTFill *areaGradientFill = [ CPTFill fillWithGradient :areaGradient];
        // 为图形设置渐变区
        aaplPlot2.areaFill = areaGradientFill;
        aaplPlot2.areaBaseValue = CPTDecimalFromString ( @"0.0" );
        aaplPlot2.interpolation = CPTScatterPlotInterpolationLinear ;
    }
    
    // 线条3颜色
    CPTColor *aaplColor3 = [CPTColor colorWithComponentRed:137/255.0 green:165/255.0 blue:77/255.0 alpha:1];
    CPTMutableLineStyle *aaplLineStyle3 = [aaplPlot3.dataLineStyle mutableCopy];
    aaplLineStyle3.lineWidth = 3.0;
    aaplLineStyle3.lineColor = aaplColor3;
    aaplPlot3.dataLineStyle = aaplLineStyle3;
    CPTMutableLineStyle *aaplSymbolLineStyle3 = [CPTMutableLineStyle lineStyle];
    aaplSymbolLineStyle3.lineColor = aaplColor3;
    CPTPlotSymbol *aaplSymbol3 = [CPTPlotSymbol rectanglePlotSymbol];
    aaplSymbol3.fill = [CPTFill fillWithColor:aaplColor3];
    aaplSymbol3.lineStyle = aaplSymbolLineStyle3;
    aaplSymbol3.size = CGSizeMake(8.0f, 8.0f);
    aaplPlot3.plotSymbol = aaplSymbol3;
    aaplPlot3.opacity = 0.0f;
    aaplPlot3.plotSymbolMarginForHitDetection = 12;// 增加点击区域
    
    if (plotStyle == ZZZPLOTSTYLE_Area) {// 是面积就增加区域
        // 创建一个颜色渐变：从 建变色 1 渐变到 无色
        CPTGradient *areaGradient = [ CPTGradient gradientWithBeginningColor :aaplColor3 endingColor :[CPTColor colorWithComponentRed:137/255.0 green:165/255.0 blue:77/255.0 alpha:0.2]];
        // 渐变角度： -90 度（顺时针旋转）
        areaGradient.angle = -90.0f ;
        // 创建一个颜色填充：以颜色渐变进行填充
        CPTFill *areaGradientFill = [ CPTFill fillWithGradient :areaGradient];
        // 为图形设置渐变区
        aaplPlot3.areaFill = areaGradientFill;
        aaplPlot3.areaBaseValue = CPTDecimalFromString ( @"0.0" );
        aaplPlot3.interpolation = CPTScatterPlotInterpolationLinear ;
    }
    
    
    
    // 线条4颜色
    CPTColor *aaplColor4 = [CPTColor colorWithComponentRed:128/255.0 green:105/255.0 blue:155/255.0 alpha:1];
    CPTMutableLineStyle *aaplLineStyle4 = [aaplPlot4.dataLineStyle mutableCopy];
    aaplLineStyle4.lineWidth = 3.0;
    aaplLineStyle4.lineColor = aaplColor4;
    aaplPlot4.dataLineStyle = aaplLineStyle4;
    CPTMutableLineStyle *aaplSymbolLineStyle4 = [CPTMutableLineStyle lineStyle];
    aaplSymbolLineStyle4.lineColor = aaplColor4;
    CPTPlotSymbol *aaplSymbol4 = [CPTPlotSymbol trianglePlotSymbol];
    aaplSymbol4.fill = [CPTFill fillWithColor:aaplColor4];
    aaplSymbol4.lineStyle = aaplSymbolLineStyle4;
    aaplSymbol4.size = CGSizeMake(8.0f, 8.0f);
    aaplPlot4.plotSymbol = aaplSymbol4;
    aaplPlot4.opacity = 0.0f;
    aaplPlot4.plotSymbolMarginForHitDetection = 12;// 增加点击区域
    
    if (plotStyle == ZZZPLOTSTYLE_Area) {// 是面积就增加区域
        // 创建一个颜色渐变：从 建变色 1 渐变到 无色
        CPTGradient *areaGradient = [ CPTGradient gradientWithBeginningColor :aaplColor4 endingColor :[CPTColor colorWithComponentRed:128/255.0 green:105/255.0 blue:155/255.0 alpha:0.2]];
        // 渐变角度： -90 度（顺时针旋转）
        areaGradient.angle = -90.0f ;
        // 创建一个颜色填充：以颜色渐变进行填充
        CPTFill *areaGradientFill = [ CPTFill fillWithGradient :areaGradient];
        // 为图形设置渐变区
        aaplPlot4.areaFill = areaGradientFill;
        aaplPlot4.areaBaseValue = CPTDecimalFromString ( @"0.0" );
        aaplPlot4.interpolation = CPTScatterPlotInterpolationLinear ;
    }
    
    
    // 线条5颜色
    CPTColor *aaplColor5 = [CPTColor colorWithComponentRed:61/255.0 green:150/255.0 blue:174/255.0 alpha:1];
    CPTMutableLineStyle *aaplLineStyle5 = [aaplPlot1.dataLineStyle mutableCopy];
    aaplLineStyle5.lineWidth = 3.0;
    aaplLineStyle5.lineColor = aaplColor5;
    aaplPlot5.dataLineStyle = aaplLineStyle5;
    CPTMutableLineStyle *aaplSymbolLineStyle5 = [CPTMutableLineStyle lineStyle];
    aaplSymbolLineStyle5.lineColor = aaplColor5;
    CPTPlotSymbol *aaplSymbol5 = [CPTPlotSymbol pentagonPlotSymbol];
    aaplSymbol5.fill = [CPTFill fillWithColor:aaplColor5];
    aaplSymbol5.lineStyle = aaplSymbolLineStyle5;
    aaplSymbol5.size = CGSizeMake(8.0f, 8.0f);
    aaplPlot5.plotSymbol = aaplSymbol5;
    aaplPlot5.opacity = 0.0f;
    aaplPlot5.plotSymbolMarginForHitDetection = 12;// 增加点击区域
    
    if (plotStyle == ZZZPLOTSTYLE_Area) {// 是面积就增加区域
        // 创建一个颜色渐变：从 建变色 1 渐变到 无色
        CPTGradient *areaGradient = [ CPTGradient gradientWithBeginningColor :aaplColor5 endingColor :[CPTColor colorWithComponentRed:61/255.0 green:150/255.0 blue:174/255.0 alpha:0.2]];
        // 渐变角度： -90 度（顺时针旋转）
        areaGradient.angle = -90.0f ;
        // 创建一个颜色填充：以颜色渐变进行填充
        CPTFill *areaGradientFill = [ CPTFill fillWithGradient :areaGradient];
        // 为图形设置渐变区
        aaplPlot5.areaFill = areaGradientFill;
        aaplPlot5.areaBaseValue = CPTDecimalFromString ( @"0.0" );
        aaplPlot5.interpolation = CPTScatterPlotInterpolationLinear ;
    }
    
    
    // 线条6颜色
    CPTColor *aaplColor6 = [CPTColor colorWithComponentRed:219/255.0 green:132/255.0 blue:61/255.0 alpha:1];
    CPTMutableLineStyle *aaplLineStyle6 = [aaplPlot1.dataLineStyle mutableCopy];
    aaplLineStyle6.lineWidth = 3.0;
    aaplLineStyle6.lineColor = aaplColor6;
    aaplPlot6.dataLineStyle = aaplLineStyle6;
    CPTMutableLineStyle *aaplSymbolLineStyle6 = [CPTMutableLineStyle lineStyle];
    aaplSymbolLineStyle6.lineColor = aaplColor6;
    CPTPlotSymbol *aaplSymbol6 = [CPTPlotSymbol hexagonPlotSymbol];
    aaplSymbol6.fill = [CPTFill fillWithColor:aaplColor6];
    aaplSymbol6.lineStyle = aaplSymbolLineStyle6;
    aaplSymbol6.size = CGSizeMake(8.0f, 8.0f);
    aaplPlot6.plotSymbol = aaplSymbol6;
    aaplPlot6.opacity = 0.0f;
    aaplPlot6.plotSymbolMarginForHitDetection = 12;// 增加点击区域
    
    if (plotStyle == ZZZPLOTSTYLE_Area) {// 是面积就增加区域
        // 创建一个颜色渐变：从 建变色 1 渐变到 无色
        CPTGradient *areaGradient = [ CPTGradient gradientWithBeginningColor :aaplColor6 endingColor :[CPTColor colorWithComponentRed:219/255.0 green:132/255.0 blue:61/255.0 alpha:0.2]];
        // 渐变角度： -90 度（顺时针旋转）
        areaGradient.angle = -90.0f ;
        // 创建一个颜色填充：以颜色渐变进行填充
        CPTFill *areaGradientFill = [ CPTFill fillWithGradient :areaGradient];
        // 为图形设置渐变区
        aaplPlot6.areaFill = areaGradientFill;
        aaplPlot6.areaBaseValue = CPTDecimalFromString ( @"0.0" );
        aaplPlot6.interpolation = CPTScatterPlotInterpolationLinear ;
    }
    
    
    
}

// 点击某个饼状图
- (void)didSelectPie:(NSUInteger)idx identi:(NSString *)identi withX:(CGFloat)xVal withY:(CGFloat)yVal withRate:(NSString *)rate
{
    dismisFlag = YES;
    
    NSString *xTitle = [xLabelArray objectAtIndex:idx];
   
    NSNumber   *num = 0;
    NSNumber *tmpIndex = [showIndexDict objectForKey:identi];
    if (tmpIndex != nil) {
        NSDictionary *tDict = [dataArray objectAtIndex:tmpIndex.integerValue];
        num = [tDict objectForKey:@"value"];
    }
    NSString *tmpTitle = [NSString stringWithFormat:@"%@:%@ %@",xTitle,num,self.yUnit];
    [dTipView reloadDetailView:tmpTitle detail:[NSString stringWithFormat:@"占比：%@",rate]];
    
    [dTipView showTipView:CGPointMake(xVal ,yVal)];
}

// 点击某个水平柱状图
- (void)didSelectBar:(NSUInteger)idx identi:(NSString *)identi withX:(CGFloat)xVal withY:(CGFloat)yVal
{
    dismisFlag = YES;
    NSString *xTitle = [xLabelArray objectAtIndex:idx];
    ;
    NSString *plotNammm = @"";
    NSNumber   *num = 0;
    NSNumber *tmpIndex = [showIndexDict objectForKey:identi];
    if (tmpIndex != nil) {
        NSDictionary *tDict = [dataArray objectAtIndex:tmpIndex.integerValue];
        NSArray *entryArr = [tDict objectForKey:@"Entry"];
        plotNammm = [tDict objectForKey:@"label"];
        NSDictionary *ttDict = [entryArr objectAtIndex:idx];
        num = [ttDict objectForKey:@"value"];
    }
    
    [dTipView reloadDetailView:plotNammm detail:[NSString stringWithFormat:@"%@：%@ %@",xTitle,num,self.yUnit]];
    
    [dTipView showTipView:CGPointMake(xVal ,yVal)];
}
// 点击某个柱状图
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx
{
    dismisFlag = YES;
    if (plotStyle == ZZZPLOTSTYLE_VBar) {
        NSNumber *nnn = [plot cachedNumberForField:CPTScatterPlotFieldY recordIndex:idx];
        NSNumber *mmm = [plot cachedNumberForField:CPTScatterPlotFieldX recordIndex:idx];
        
        // 获取当前的偏亮
        float ofnum = CPTDecimalCGFloatValue(plot.barOffset);
        float llValue = ofnum + mmm.floatValue;
        
        float xval = nnn.floatValue*(self.hostView.frame.size.width-65)/10 + 65;
        float yVal = self.hostView.frame.size.height - 70 + 0 + 10 - llValue*(self.hostView.frame.size.height-70)/maxXcout ;
        [self didSelectBar:idx identi:(NSString *)plot.identifier withX:xval withY:yVal];
        return;
    }
    
    NSString *xTitle = [xLabelArray objectAtIndex:idx];
    ;
    NSString *plotNammm = @"";
    NSNumber   *num = 0;
    NSNumber *tmpIndex = [showIndexDict objectForKey:plot.identifier];
    if (tmpIndex != nil) {
        NSDictionary *tDict = [dataArray objectAtIndex:tmpIndex.integerValue];
        NSArray *entryArr = [tDict objectForKey:@"Entry"];
        plotNammm = [tDict objectForKey:@"label"];
        NSDictionary *ttDict = [entryArr objectAtIndex:idx];
        num = [ttDict objectForKey:@"value"];
    }
    
    [dTipView reloadDetailView:plotNammm detail:[NSString stringWithFormat:@"%@：%@ %@",xTitle,num,self.yUnit]];
    NSNumber *nnn = [plot cachedNumberForField:CPTScatterPlotFieldY recordIndex:idx];
    NSNumber *mmm = [plot cachedNumberForField:CPTScatterPlotFieldX recordIndex:idx];
    
    // 获取当前的偏亮
    float ofnum = CPTDecimalCGFloatValue(plot.barOffset);
    float llValue = ofnum + mmm.floatValue;
    
    [dTipView showTipView:CGPointMake(llValue*(self.hostView.hostedGraph.frame.size.width-65)/maxXcout + 65 ,self.hostView.frame.size.height - 80 + 7 + 10 - nnn.floatValue*(self.hostView.frame.size.height-80)/MAX_YAXES )];
}

// 点击某个点
-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx withEvent:(CPTNativeEvent *)event
{
    dismisFlag = YES;
    NSString *xTitle = [xLabelArray objectAtIndex:idx];
    ;
    NSString *plotNammm = @"";
    NSNumber   *num = 0;
    NSNumber *tmpIndex = [showIndexDict objectForKey:plot.identifier];
    if (tmpIndex != nil) {
        NSDictionary *tDict = [dataArray objectAtIndex:tmpIndex.integerValue];
        NSArray *entryArr = [tDict objectForKey:@"Entry"];
        plotNammm = [tDict objectForKey:@"label"];
        NSDictionary *ttDict = [entryArr objectAtIndex:idx];
        num = [ttDict objectForKey:@"value"];
    }
    
    [dTipView reloadDetailView:plotNammm detail:[NSString stringWithFormat:@"%@：%@ %@",xTitle,num,self.yUnit]];
    NSNumber *nnn = [plot cachedNumberForField:CPTScatterPlotFieldY recordIndex:idx];
    NSNumber *mmm = [plot cachedNumberForField:CPTScatterPlotFieldX recordIndex:idx];
    [dTipView showTipView:CGPointMake(mmm.floatValue*(self.hostView.hostedGraph.frame.size.width-65)/maxXcout + 65,self.hostView.frame.size.height - 80 + 3 + 10 - nnn.floatValue*(self.hostView.frame.size.height-80)/MAX_YAXES )];
 
}


/***********************************************************************
 * 方法名称：-(void)reloadVBarAxes
 * 功能描述： 配置条形图
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)reloadVBarAxes:(NSArray *)tArray
{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) graphVBar.axisSet ;
    //自定义x轴
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:10];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:10];
    NSMutableArray *xArray = [NSMutableArray arrayWithArray:tArray];
    [xArray insertObject:@"" atIndex:0];
    
    int xCount = xArray.count;
    if (xCount == 0) {
        return;
    }
    float aaa   = maxXcout*1.0/xCount;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graphVBar.defaultPlotSpace;
    // 大刻度线间距： 50 单位
    if (aaa < 1) {
        aaa = 1;
        maxXcout = xCount;
    }
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromFloat(maxXcout)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromFloat(10)];
    
    xInterval = aaa;
    
    CPTXYAxis *y = axisSet.yAxis ;
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor colorWithComponentRed:79/255.0 green:79/255.0 blue:79/255.0 alpha:1];
    
    y.labelTextStyle = axisTitleStyle;
    // 坐标原点： 0
    y.orthogonalCoordinateDecimal = CPTDecimalFromString (@"0");
    // 大刻度线长度
    y.majorTickLength = 3;
    y.minorTickLength = 1;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    //y 轴：不显示小刻度线
    y.majorIntervalLength = CPTDecimalFromString(@"1");
    CPTMutableLineStyle *axisLineStyle1 = [CPTMutableLineStyle lineStyle];
    axisLineStyle1.lineWidth = 1.0f;
    axisLineStyle1.lineColor = [CPTColor lightGrayColor];
    
    y.minorTickLineStyle = nil ;
    y.minorTickLength    = 0;
    y.majorTickLineStyle = axisLineStyle1;
    NSInteger i = 0;
    for (NSString *date in xArray) {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:date  textStyle:y.labelTextStyle];
        CGFloat location = i++;
        label.tickLocation = CPTDecimalFromCGFloat(location*aaa);
        label.offset = 5;
     //   label.rotation=0.9;
        
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location*aaa]];
        }
    }
    
    y.axisLabels = xLabels;
    y.majorTickLocations = xLocations;
    y.majorTickLength    = 3;
    y.majorIntervalLength = CPTDecimalFromFloat(aaa);
    
    
    // 自定义Y轴
    // 选出最大的Y值
    NSMutableArray *lblTextArray = [[NSMutableArray alloc]init];
    NSArray *keys = [showIndexDict allKeys];
    maxYcount = 0;
    for (int i=0; i<keys.count; i++) {
        NSString *key = [keys objectAtIndex:i];
        
        NSNumber *numIndex = [showIndexDict objectForKey:key];
        NSDictionary *entryDict = dataArray[numIndex.intValue];
        NSArray *entryArr = [entryDict objectForKey:@"Entry"];
        [lblTextArray addObject:[entryDict objectForKey:@"label"]];
        for (int j=0; j<entryArr.count; j++) {
            NSDictionary *ttDict = [entryArr objectAtIndex:j];
            NSNumber *value = [ttDict objectForKey:@"value"];
            if (value.floatValue > maxYcount) {
                maxYcount = value.floatValue;
            }
        }
    }
//    NSLog(@"得到匹配值%d",[Common getYMax:maxYcount]/4);
    CGFloat ttMax = [Common getYMax:maxYcount];
    CGFloat tYmax = ttMax/4;
    if (maxYcount <= 1) {
        ttMax = [Common getYMaxFloat:maxYcount];
        tYmax = ttMax/4;
    }
    maxShowNum = ttMax;
    
    // 配置X轴
    CPTXYAxis *x = axisSet.xAxis ;
    x.majorTickLength = 5;
    x.majorIntervalLength = CPTDecimalFromFloat(MAX_YAXES_INT);
    // 坐标原点： 0
    x.orthogonalCoordinateDecimal = CPTDecimalFromString (@"0");
    x.titleOffset = -60.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 1.0f;
    axisLineStyle.lineColor = [CPTColor lightGrayColor];
    
    CPTMutableLineStyle *clearStyle = [CPTMutableLineStyle lineStyle];
    clearStyle.lineWidth = 1.0f;
    clearStyle.lineColor = [CPTColor clearColor];
    
    x.axisLineStyle = clearStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.majorGridLineStyle = axisLineStyle;
    x.majorGridLineStyle = axisLineStyle;
    x.minorTickLineStyle = clearStyle;
    x.majorTickLineStyle = clearStyle;
    x.minorTickLength = 0;
    x.tickDirection = CPTSignPositive;
    x.labelTextStyle  = axisTitleStyle;
    
    NSMutableSet *xLocations2 = [NSMutableSet setWithCapacity:10];
    NSMutableArray *labelArray2=[NSMutableArray arrayWithCapacity:20];
    NSMutableArray *labelName2=[[NSMutableArray alloc]initWithObjects:@"",[Common getStringByInt:tYmax withMax:ttMax],[Common getStringByInt:tYmax*2 withMax:ttMax],[Common getStringByInt:tYmax*3 withMax:ttMax],[Common getStringByInt:tYmax*4 withMax:ttMax],@"",nil];
    for (int i=0;i<=5;i++){
        CPTAxisLabel *newLabel;
        
        newLabel=[[CPTAxisLabel alloc] initWithText:[labelName2 objectAtIndex:i] textStyle:x.labelTextStyle];
        newLabel.tickLocation=[[NSNumber numberWithFloat:i*10/5] decimalValue];
        newLabel.rotation = 0.9;
        newLabel.offset = -40;
        [labelArray2 addObject:newLabel];
        if (i != 5) {
            [xLocations2 addObject:[NSNumber numberWithFloat:i*10/5]];
        }
        
        
    }
    
    
    x.axisLabels = [NSSet setWithArray:labelArray2];
    x.majorTickLocations = xLocations2;
    
    x.title      = [NSString stringWithFormat:@"%@(%@)",self.yTitle,self.yUnit];
    
}


- (void)reloadBarAxes:(NSArray *)tArray
{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) graph.axisSet ;
    
    //自定义x轴
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:10];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:10];
    NSMutableArray *xArray = [NSMutableArray arrayWithArray:tArray];
    [xArray insertObject:@"" atIndex:0];
    
    int xCount = xArray.count;
    if (xCount == 0) {
        return;
    }
    float aaa   = maxXcout*1.0/xCount;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    // 大刻度线间距： 50 单位
    if (aaa < 1) {
        aaa = 1;
        maxXcout = xCount;
    }
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromFloat(maxXcout)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromFloat(10)];
    
    xInterval = aaa;
    
    CPTXYAxis *y = axisSet.yAxis ;
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor colorWithComponentRed:79/255.0 green:79/255.0 blue:79/255.0 alpha:1];
    
    y.labelTextStyle = axisTitleStyle;
    // 坐标原点： 0
    y.orthogonalCoordinateDecimal = CPTDecimalFromString (@"0");
    // 大刻度线长度
    y.majorTickLength = 3;
    y.minorTickLength = 1;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    //y 轴：不显示小刻度线
    y.majorIntervalLength = CPTDecimalFromString(@"1");
    CPTMutableLineStyle *axisLineStyle1 = [CPTMutableLineStyle lineStyle];
    axisLineStyle1.lineWidth = 1.0f;
    axisLineStyle1.lineColor = [CPTColor lightGrayColor];
    
    y.minorTickLineStyle = axisLineStyle1 ;
    y.minorTickLength    = 1;
    y.majorTickLineStyle = axisLineStyle1;
    NSInteger i = 0;
    for (NSString *date in xArray) {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:date  textStyle:y.labelTextStyle];
        CGFloat location = i++;
        label.tickLocation = CPTDecimalFromCGFloat(location*aaa);
        label.offset = 5;
        label.rotation=0.9;
        
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location*aaa]];
        }
    }
    
    y.axisLabels = xLabels;
    y.majorTickLocations = xLocations;
    y.majorTickLength    = 3;
    y.majorIntervalLength = CPTDecimalFromFloat(aaa);
    
    
    // 自定义Y轴
    // 选出最大的Y值
    NSMutableArray *lblTextArray = [[NSMutableArray alloc]init];
    NSArray *keys = [showIndexDict allKeys];
    maxYcount = 0;
    for (int i=0; i<keys.count; i++) {
        NSString *key = [keys objectAtIndex:i];
        
        NSNumber *numIndex = [showIndexDict objectForKey:key];
        NSDictionary *entryDict = dataArray[numIndex.intValue];
        NSArray *entryArr = [entryDict objectForKey:@"Entry"];
        [lblTextArray addObject:[entryDict objectForKey:@"label"]];
        for (int j=0; j<entryArr.count; j++) {
            NSDictionary *ttDict = [entryArr objectAtIndex:j];
            NSNumber *value = [ttDict objectForKey:@"value"];
            if (value.floatValue > maxYcount) {
                maxYcount = value.floatValue;
            }
        }
    }
//    NSLog(@"得到匹配值%d",[Common getYMax:maxYcount]/4);
    CGFloat ttMax = [Common getYMax:maxYcount];
    CGFloat tYmax = ttMax/4;
    if (maxYcount <= 1) {
        ttMax = [Common getYMaxFloat:maxYcount];
        tYmax = ttMax/4;
    }
    maxShowNum = ttMax;
    
    // 配置X轴
    CPTXYAxis *x = axisSet.xAxis ;
    x.majorTickLength = 5;
    x.majorIntervalLength = CPTDecimalFromInt(2);
    // 坐标原点： 0
    x.orthogonalCoordinateDecimal = CPTDecimalFromString (@"0");
    x.titleOffset = -60.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 1.0f;
    axisLineStyle.lineColor = [CPTColor lightGrayColor];
    
    CPTMutableLineStyle *clearStyle = [CPTMutableLineStyle lineStyle];
    clearStyle.lineWidth = 1.0f;
    clearStyle.lineColor = [CPTColor clearColor];
    
    x.axisLineStyle = clearStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.majorGridLineStyle = axisLineStyle;
    x.majorGridLineStyle = axisLineStyle;
    x.minorTickLineStyle = clearStyle;
    x.majorTickLineStyle = clearStyle;
    x.minorTickLength = 0;
    x.tickDirection = CPTSignPositive;
    x.labelTextStyle  = axisTitleStyle;
    
    NSMutableSet *xLocations2 = [NSMutableSet setWithCapacity:10];
    NSMutableArray *labelArray2=[NSMutableArray arrayWithCapacity:20];
    NSMutableArray *labelName2=[[NSMutableArray alloc]initWithObjects:@"",[Common getStringByInt:tYmax withMax:ttMax],[Common getStringByInt:tYmax*2 withMax:ttMax],[Common getStringByInt:tYmax*3 withMax:ttMax],[Common getStringByInt:tYmax*4 withMax:ttMax],@"",nil];
    for (int i=0;i<=5;i++){
        CPTAxisLabel *newLabel;
        
        newLabel=[[CPTAxisLabel alloc] initWithText:[labelName2 objectAtIndex:i] textStyle:x.labelTextStyle];
        newLabel.tickLocation=[[NSNumber numberWithFloat:i*10/5] decimalValue];
        newLabel.rotation = 0.9;
        newLabel.offset = -40;
        [labelArray2 addObject:newLabel];
        if (i != 5) {
            [xLocations2 addObject:[NSNumber numberWithFloat:i*10/5]];
        }
        
        
    }
    
    x.axisLabels = [NSSet setWithArray:labelArray2];
    x.majorTickLocations = xLocations2;
    
    x.title      = [NSString stringWithFormat:@"%@(%@)",self.yTitle,self.yUnit];
    
}


- (void)reloadAxes:(NSArray *)tArray
{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) graph.axisSet ;
   
     
    CPTXYAxis *x = axisSet.xAxis ;
    
    //自定义x轴
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:10];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:10];
    NSMutableArray *xArray = [NSMutableArray arrayWithArray:tArray];
    [xArray insertObject:@"" atIndex:0];
    
    int xCount = xArray.count;
    if (xCount == 0) {
        return;
    }
    float aaa   = maxXcout*1.0/xCount;
    // 大刻度线间距： 50 单位
    if (aaa < 1) {
        aaa = 1;
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
        maxXcout = xCount;
        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromFloat(xCount)];
    }
    xInterval = aaa;
    NSInteger i = 0;
    for (NSString *date in xArray) {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:date  textStyle:x.labelTextStyle];
        CGFloat location = i++;
        label.tickLocation = CPTDecimalFromCGFloat(location*aaa);
        label.offset = 5;
        label.rotation=0.9;
        
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location*aaa]];
        }
    }
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    x.majorTickLength    = 5;
 
    x.majorIntervalLength = CPTDecimalFromFloat(aaa);
    
    // 自定义Y轴
    // 选出最大的Y值
    NSMutableArray *lblTextArray = [[NSMutableArray alloc]init];
    NSArray *keys = [showIndexDict allKeys];
    maxYcount = 0;
    for (int i=0; i<keys.count; i++) {
        NSString *key = [keys objectAtIndex:i];
        
        NSNumber *numIndex = [showIndexDict objectForKey:key];
        NSDictionary *entryDict = dataArray[numIndex.intValue];
        NSArray *entryArr = [entryDict objectForKey:@"Entry"];
        [lblTextArray addObject:[entryDict objectForKey:@"label"]];
        for (int j=0; j<entryArr.count; j++) {
            NSDictionary *ttDict = [entryArr objectAtIndex:j];
            NSNumber *value = [ttDict objectForKey:@"value"];
            if (value.floatValue > maxYcount) {
                maxYcount = value.floatValue;
            }
        }
    }
//    NSLog(@"得到匹配值%d",[Common getYMax:maxYcount]/4);
    CGFloat ttMax = maxYcount < 1 ? 1 : [Common getYMax:maxYcount];
    CGFloat tYmax = ttMax/4;
    if (maxYcount <= 1) {
        ttMax = [Common getYMaxFloat:maxYcount];
        tYmax = ttMax/4;
    }
    NSLog(@"最多的ttmax :%f",ttMax);
    maxShowNum = ttMax;
    CPTXYAxis *y = axisSet.yAxis ;
    NSMutableArray *labelArray2=[NSMutableArray arrayWithCapacity:20];
    NSMutableArray *labelName2=[[NSMutableArray alloc]initWithObjects:@"",[Common getStringByInt:tYmax withMax:ttMax],[Common getStringByInt:tYmax*2 withMax:ttMax],[Common getStringByInt:tYmax*3 withMax:ttMax],[Common getStringByInt:tYmax*4 withMax:ttMax],nil];
    for (int i=0;i<=4;i++){
        CPTAxisLabel *newLabel;
        
        newLabel=[[CPTAxisLabel alloc] initWithText:[labelName2 objectAtIndex:i] textStyle:y.labelTextStyle];
        newLabel.tickLocation=[[NSNumber numberWithFloat:i*MAX_YAXES/4] decimalValue];
//        NSDecimal location = CPTDecimalFromInteger(i*MAX_YAXES_INT);
//        newLabel.tickLocation = location;
        newLabel.offset = -y.majorTickLength - y.labelOffset;
        [labelArray2 addObject:newLabel];
        
    }
    
    y.axisLabels = [NSSet setWithArray:labelArray2];
    y.title      = [NSString stringWithFormat:@"%@(%@)",self.yTitle,self.yUnit];
     
}

-(void)configureAxes {
    //设置坐标刻度大小
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) graph.axisSet ;

    CPTXYAxis *x = axisSet.xAxis ;
    
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor colorWithComponentRed:79/255.0 green:79/255.0 blue:79/255.0 alpha:1];
    
    // 大刻度线间距： 50 单位
    x.majorIntervalLength = CPTDecimalFromString(@"1");
   
    // 坐标原点： 0
    x.orthogonalCoordinateDecimal = CPTDecimalFromString (@"0");
    x.labelTextStyle = axisTitleStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    CPTMutableLineStyle *axisLineStyle1 = [CPTMutableLineStyle lineStyle];
    axisLineStyle1.lineWidth = 1.0f;
    axisLineStyle1.lineColor = [CPTColor lightGrayColor];
    x.axisLineStyle = axisLineStyle1;
    x.minorTickLineStyle = axisLineStyle1 ;

    //自定义x轴
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:10];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:10];
    NSArray *xArray = [NSArray arrayWithObjects: @"",@"", nil];
    NSInteger i = 0;
    for (NSString *date in xArray) {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:date  textStyle:x.labelTextStyle];
        CGFloat location = i++;
        label.tickLocation = CPTDecimalFromCGFloat(location*10);
        label.offset = 10;
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    // 大刻度线长度
    x.majorTickLength = 3;
    x.minorTickLength = 0;
    x.majorTickLineStyle = axisLineStyle1;
    //固定y轴，也就是在你水平移动时，y轴是固定在左/右边不动的，以此类推x轴
    x.axisConstraints = [CPTConstraints constraintWithLowerOffset:0];//这里是固定y坐标轴在最
    
    axisSet.xAxis.separateLayers              = YES;
    axisSet.xAxis.minorTicksPerInterval       = 1;
    axisSet.xAxis.tickDirection               = CPTSignNegative;
  
    
    CPTXYAxis *y = axisSet.yAxis ;
    //y 轴：不显示小刻度线
    y. minorTickLineStyle = nil ;
    // 大刻度线间距： 50 单位
    y.majorIntervalLength = CPTDecimalFromFloat(MAX_YAXES_INT);
    // 坐标原点： 0
    y. orthogonalCoordinateDecimal = CPTDecimalFromString (@"0");
    //固定y轴，也就是在你水平移动时，y轴是固定在左/右边不动的，以此类推x轴
    y.axisConstraints = [CPTConstraints constraintWithLowerOffset:0];//这里是固定y坐标轴在最
    
//    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 1.0f;
    axisLineStyle.lineColor = [CPTColor clearColor];
    
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor lightGrayColor];
 
    axisTextStyle.fontSize = 11.0f;
    y.title = @"";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -55.0f;
    gridLineStyle.lineColor = [CPTColor lightGrayColor];
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTitleStyle;
    y.labelOffset = 30.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
//    CGFloat majorIncrement = MAX_YAXES;
//    CGFloat minorIncrement = MAX_YAXES_INT/2;
//    CGFloat yMax = MAX_YAXES;  // should determine dynamically based on max price
//    NSMutableSet *yLabels = [NSMutableSet set];
//    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
//    for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
//        NSUInteger mod = j % majorIncrement;
//        if (mod == 0) {
//            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)j] textStyle:y.labelTextStyle];
//            NSDecimal location = CPTDecimalFromInteger(j);
//            label.tickLocation = location;
//            label.offset = -y.majorTickLength - y.labelOffset;
//            if (label) {
//                [yLabels addObject:label];
//            }
//            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
//        } else {
//            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
//        }
//    }
//    
//    y.axisLabels = yLabels;
    [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromFloat(MAX_YAXES_INT)]];
    [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromFloat(MAX_YAXES_INT*2)]];
    [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromFloat(MAX_YAXES_INT*3)]];
    [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromFloat(MAX_YAXES_INT*4)]];
    y.majorTickLocations = yMinorLocations;
//    y.minorTickLocations = yMinorLocations;
}

/**************饼状图代理***************/
-(CGFloat)radialOffsetForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    return index == self.offsetIndex ? self.sliceOffset : 0.0;
}

-(void)setSliceOffset:(CGFloat)newOffset
{
    if ( newOffset != sliceOffset ) {
        sliceOffset = newOffset;
        
        [graphPie reloadData];
        
        if ( newOffset == CPTFloat(0.0) ) {
            self.offsetIndex = NSNotFound;
        }
    }
}

-(CPTLayer*)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index

{
    if (plotStyle == ZZZPLOTSTYLE_Pie) {// 饼状图
        NSString *keyStr = [keyArray objectAtIndex:index];
        NSNumber  *tmpIndex = [showIndexDict objectForKey:keyStr];
        NSString  *name = [xLabelArray objectAtIndex:tmpIndex.integerValue];
        totalValue = 0;
        for (NSString *ttkey in keyArray) {
            NSNumber  *ttidx= [showIndexDict objectForKey:ttkey];
            NSDictionary *ttDict = [dataArray objectAtIndex:ttidx.integerValue];
            NSNumber *  num22 = [ttDict objectForKey:@"value"];
            totalValue = totalValue + num22.floatValue;
        }
        NSDictionary *tDict = [dataArray objectAtIndex:tmpIndex.integerValue];
        NSNumber *  num = [tDict objectForKey:@"value"];
        NSString *rateStr = [NSString stringWithFormat:@"%0.1f%%",num.floatValue*100/totalValue];
        
        CPTTextLayer *label    = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%@ %@",name,rateStr]];
        
        CPTMutableTextStyle *textStyle =[label.textStyle mutableCopy];
        
        textStyle.color = [CPTColor colorWithComponentRed:79/255.0 green:79/255.0 blue:79/255.0 alpha:1];
        
        label.textStyle = textStyle;
        return label;
    }
    return nil;
    
}
-(void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index
{
    
    [CPTAnimation animate:self
                 property:@"sliceOffset"
                     from:(index == self.offsetIndex ? (CGFloat)NAN : 0.0)
                       to:(index == self.offsetIndex ? 0.0 : 20.0)
                 duration:0.5
           animationCurve:CPTAnimationCurveCubicOut
                 delegate:nil];
    curTmpIdx = index;
    self.offsetIndex = index;
}
-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx
{
    
    NSString *keyVal = [[keyArray objectAtIndex:idx] substringFromIndex:7];
    int keyInt = [keyVal intValue];
    
    switch (keyInt) {
        case 0:
            return [CPTFill fillWithColor:[CPTColor colorWithComponentRed:69/255.0 green:114/255.0 blue:167/255.0 alpha:1]];
            break;
        case 1:
            return [CPTFill fillWithColor:[CPTColor colorWithComponentRed:170/255.0 green:70/255.0 blue:67/255.0 alpha:1]];
            break;
        case 2:
            return [CPTFill fillWithColor:[CPTColor colorWithComponentRed:137/255.0 green:165/255.0 blue:77/255.0 alpha:1]];
            break;
        case 3:
            return [CPTFill fillWithColor:[CPTColor colorWithComponentRed:128/255.0 green:105/255.0 blue:155/255.0 alpha:1]];
            break;
        case 4:
            return [CPTFill fillWithColor:[CPTColor colorWithComponentRed:61/255.0 green:150/255.0 blue:174/255.0 alpha:1]];
            break;
        case 5:
            return [CPTFill fillWithColor:[CPTColor colorWithComponentRed:219/255.0 green:132/255.0 blue:61/255.0 alpha:1]];
            break;
        default:
            break;
    }
    return [CPTFill fillWithColor:[CPTColor clearColor]];
}
/**************饼状图代理end***************/


-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    
    if (plotStyle == ZZZPLOTSTYLE_Pie) {
        return [showIndexDict count];
    }
    NSNumber *tmpIndex = [showIndexDict objectForKey:plot.identifier];
    if (tmpIndex != nil) {
        NSDictionary *tDict = [dataArray objectAtIndex:tmpIndex.integerValue];
        NSArray *entryArr = [tDict objectForKey:@"Entry"];
        return entryArr.count;
    }
   
    return 0;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
  
 
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.duration            = 1.0f;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.fillMode            = kCAFillModeForwards;
    fadeInAnimation.toValue             = [NSNumber numberWithFloat:1.0];
    [plot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    
   
    
    NSNumber *tmpIndex = [showIndexDict objectForKey:plot.identifier];
    
    // 饼状图特殊处理
    if (plotStyle == ZZZPLOTSTYLE_Pie) {// 饼状图
        NSNumber *num;
        
        NSString *keyStr = [keyArray objectAtIndex:index];
        tmpIndex = [showIndexDict objectForKey:keyStr];
        if ( fieldEnum == CPTPieChartFieldSliceWidth ) {
            NSDictionary *tDict = [dataArray objectAtIndex:tmpIndex.integerValue];
            
            num = [tDict objectForKey:@"value"];
            totalValue = totalValue + num.floatValue;
        }
        else {
            num = @(index);
        }
        return num;
    }
    
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            
            return [NSNumber numberWithFloat:index*xInterval + xInterval];
            
            break;
            
        case CPTScatterPlotFieldY:
            if (tmpIndex != nil) {
                NSDictionary *tDict = [dataArray objectAtIndex:tmpIndex.integerValue];
                NSArray *entryArr = [tDict objectForKey:@"Entry"];
                NSDictionary *ttDict = [entryArr objectAtIndex:index];
                NSNumber   *num = [ttDict objectForKey:@"value"];
                float tt = maxShowNum/4.0;
                float intervFloat = MAX_YAXES_INT;
                if (plotStyle == ZZZPLOTSTYLE_VBar) {
                    intervFloat = 2;
                }
                float lastNum = intervFloat * num.floatValue / tt;
//                NSLog(@"最大左边:%f--%f",tt,lastNum);
                return [NSNumber numberWithFloat:lastNum];
            }
            
            break;
    }
    
    return [NSDecimalNumber zero];
}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [dTipView disMissMenu];
}


@end
