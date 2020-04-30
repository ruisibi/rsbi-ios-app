//
//  ZZZBarPlotView.m
//  Pivot
//
//  Created by djh on 16/3/14.
//  Copyright © 2016年 bos. All rights reserved.
//

#import "ZZZBarPlotView.h"

#import "JYRadarChart.h"

@interface ZZZBarPlotView ()<CPTScatterPlotDataSource,CPTPlotSpaceDelegate,CPTPlotDelegate,CPTBarPlotDelegate,CPTPieChartDelegate,CPTAnimationDelegate>
{
    
    CPTGraph *graph;// 横向柱状图
    CPTGraph *graphPie;// 饼状图
    NSMutableArray *dataArray;// 数组数据
    NSArray        *xDataArray;//x轴数据
    NSMutableDictionary *showIndexDict;// 需要显示的数据index
    int            maxYcount;// y轴最大值
    int            maxShowNum;// y显示的最大值
    float            xInterval;// x轴间隔
    float          maxXcout;// x轴最大值
    NSArray       *keyArray;// 键数组
    NSMutableArray *xLabelArray;//x轴文字数组
    NSInteger     curTmpIdx;//零时点
    float         totalValue;// 总值
    JYRadarChart *radaChart;// 雷达图
    
}
@property (nonatomic, readwrite) NSUInteger offsetIndex;
@property (nonatomic, readwrite) CGFloat sliceOffset;
@end
@implementation ZZZBarPlotView
@synthesize plotStyle;
@synthesize offsetIndex;
@synthesize sliceOffset;

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
        [self addGestureRecognizer:gesTure];
    }
    return self;
}

- (void)singleTap:(UITapGestureRecognizer *)gesTure
{
    CGPoint point = [gesTure locationInView:self];
    
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
        [self.delegate didSelectPie:tmpIndex.integerValue identi:keyStr withX:point.x withY:point.y withRate:rateStr];
    }
    curTmpIdx = -1;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer

{
    
    return YES;
    
}

- (void)reloadByDidSelect:(NSDictionary *)dict
{
    showIndexDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    curTmpIdx = -1;
    totalValue = 0;
    
    switch (plotStyle) {
        case ZZZPLOTSTYLE_VBar:
            self.hostedGraph.hidden = false;
            radaChart.hidden = YES;
            [self configureBars];//加载柱状
            [self reloadAxes:xLabelArray];
            [graph reloadData];
            break;
        case ZZZPLOTSTYLE_Pie:
            self.hostedGraph.hidden = false;
            radaChart.hidden = YES;
            keyArray = [dict allKeys];
            [self configPieChart];//加载饼图
            [graph reloadData];
            break;
        case ZZZPLOTSTYLE_Radar:
            self.hostedGraph.hidden = YES;
            [self configRadarView];
            radaChart.hidden = false;
            [self reloadRadarData];
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
        
       NSString * key = [NSString stringWithFormat:@"barplot%d",i];
        if (plotStyle == ZZZPLOTSTYLE_Radar) {
            key = [NSString stringWithFormat:@"plot%d",i];
        }
       [showIndexDict setObject:[NSNumber numberWithInt:i] forKey:key];
    }
   
    // 加载图形
    
    switch (plotStyle) {
        case ZZZPLOTSTYLE_VBar:
            self.hostedGraph.hidden = false;
            radaChart.hidden = YES;
            [self reloadAxes:xVals];
            [self configureBars];//加载柱状
            [graph reloadData];
            break;
        case ZZZPLOTSTYLE_Pie:
            self.hostedGraph.hidden = false;
            radaChart.hidden = YES;
            keyArray = [showIndexDict allKeys];
            [self configPieChart];
            [graph reloadData];
            break;
        case ZZZPLOTSTYLE_Radar:
            self.hostedGraph.hidden = YES;
            [self configRadarView];
            radaChart.hidden = false;
            
            [self reloadRadarData];
            
            break;
        default:
            break;
    }
 
    
}

- (void)configRadarView
{
    if (radaChart == nil) {
        //添加雷达图
        radaChart = [[JYRadarChart alloc]initWithFrame:CGRectMake(30, 20, self.frame.size.height - 50, self.frame.size.height - 50)];
        radaChart.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        radaChart.hidden = YES;
        radaChart.showStepText = NO;
        radaChart.fillArea = NO;
        radaChart.showStepText = YES;
        radaChart.drawPoints = YES;
        radaChart.steps = 4;
        radaChart.minValue = 0;
        [self.superview addSubview:radaChart];
    }

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
    float  maxValue = 0;
    NSArray *keys = [showIndexDict allKeys];
    for (int i=0; i<keys.count;i++) {
        NSNumber *tIndex = [showIndexDict objectForKey:keys[i]];
        NSDictionary *tmpDict = [dataArray objectAtIndex:tIndex.intValue];
        NSArray *ttArr = [tmpDict objectForKey:@"Entry"];
        NSMutableArray *tEntry = [[NSMutableArray alloc]init];
        for (NSDictionary *tttdict in ttArr) {
            NSNumber *valRadar = [tttdict objectForKey:@"value"];
            if (valRadar.floatValue > maxValue) {
                maxValue = valRadar.floatValue;
            }
            [tEntry addObject:@(valRadar.floatValue)];
        }
        [dataSource addObject:tEntry];
        [attrArray addObject:[tmpDict objectForKey:@"label"]];
    }
    
    radaChart.dataSeries = dataSource;
    radaChart.attributes = xLabelArray;
    radaChart.maxValue   = maxValue;
    
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
 
    
    [self configureGraph];
    
}

-(void)configureGraph {
    // 1 - Create the graph
    graph = [[CPTXYGraph alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    //    [graph applyTheme:[CPTTheme themeNamed:kCPTSlateTheme]];
    self.hostedGraph = graph;
    [graph  setPaddingBottom:0];
    [graph  setPaddingRight:0];
    [graph  setPaddingLeft:10];
    [graph  setPaddingTop:0];
    graph.plotAreaFrame.borderLineStyle = nil;
    //    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    //    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    // 4 - Set padding for plot area
    [graph.plotAreaFrame setPaddingTop:10];
    [graph.plotAreaFrame setPaddingLeft:55.0f];
    [graph.plotAreaFrame setPaddingRight:0];
    [graph.plotAreaFrame setPaddingBottom:60.0f];
    // 5 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.delegate = self;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromFloat(maxXcout)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(10)];
    
    
    // 1 - Create the graph
    graphPie = [[CPTXYGraph alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
   
    
    [graphPie  setPaddingBottom:0];
    [graphPie  setPaddingRight:0];
    [graphPie  setPaddingLeft:0];
    [graphPie  setPaddingTop:0];
    graphPie.plotAreaFrame.borderLineStyle = nil;
    //    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    //    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    // 4 - Set padding for plot area
    [graphPie.plotAreaFrame setPaddingTop:0];
    [graphPie.plotAreaFrame setPaddingLeft:30.0f];
    [graphPie.plotAreaFrame setPaddingRight:0];
    [graphPie.plotAreaFrame setPaddingBottom:30.0f];
    
    
    
//    p.dataSeries = @[a1, a2];
//    p.steps = 1;
//    p.showStepText = YES;
//    p.backgroundColor = [UIColor whiteColor];
//    p.r = 60;
//    p.minValue = 20;
//    p.maxValue = 120;
//    p.fillArea = YES;
//    p.colorOpacity = 0.7;
//    p.backgroundFillColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
//    p.attributes = @[@"Attack", @"Defense", @"Speed", @"HP", @"MP", @"IQ"];
//    p.showLegend = YES;
//    [p setTitles:@[@"archer", @"footman"]];
//    [p setColors:@[[UIColor yellowColor], [UIColor purpleColor]]];
    
    
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
    [self removePlotAndBar];
    self.offsetIndex = NSNotFound;
    self.hostedGraph = graphPie;
    
    graphPie.plotAreaFrame.masksToBorder = NO;
    graphPie.axisSet                     = nil;
    graphPie.defaultPlotSpace.delegate   =self;
  
    // Add pie chart
    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    piePlot.dataSource = self;
    piePlot.pieRadius  = MIN( CPTFloat(0.7) * (self.frame.size.height - CPTFloat(2.0) * graph.paddingLeft) / CPTFloat(2.0),
                             CPTFloat(0.7) * (self.frame.size.width - CPTFloat(2.0) * graph.paddingTop) / CPTFloat(2.0) );
    piePlot.identifier     = @"pieplot";
    piePlot.delegate       = self;
    piePlot.startAngle     = CPTFloat(M_PI_4);
    piePlot.sliceDirection = CPTPieDirectionCounterClockwise;
//    piePlot.overlayFill    = [CPTFill fillWithGradient:overlayGradient];
    
    piePlot.labelRotationRelativeToRadius = YES;
    piePlot.labelRotation                 = CPTFloat(-M_PI_2);
    piePlot.labelOffset                   = -50.0;
   
    
    [graphPie addPlot:piePlot];
    
}

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


-(void)animationDidFinish:(CPTAnimationOperation *)operation
{
    
}




-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(UIEvent *)event atPoint:(CGPoint)point
{
    
    
    return YES;
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


- (void)reloadAxes:(NSArray *)tArray
{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) graph.axisSet ;
    self.hostedGraph = graph;
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
    
    y.minorTickLineStyle = nil ;
    y.minorTickLength    = 0;
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
            if (value.intValue > maxYcount) {
                maxYcount = value.intValue;
            }
        }
    }
//    NSLog(@"得到匹配值%d",[Common getYMax:maxYcount]/4);
    int ttMax = [Common getYMax:maxYcount];
    int tYmax = ttMax/4;
    if (ttMax <= 8) {
        ttMax = 8;
        tYmax = 2;
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


/***********************************************************************
 * 方法名称：-(void)configureBars
 * 功能描述： 配置柱状图
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/

- (void)configureBars
{
    // 清楚所以线
    [self removePlotAndBar];
    
    // 1 - Get graph and plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
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
    barPlot1.barsAreHorizontal = YES;
    [graph addPlot:barPlot1 toPlotSpace:plotSpace];
    
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
    barPlot2.barsAreHorizontal = YES;
    [graph addPlot:barPlot2 toPlotSpace:plotSpace];
    
    
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
    barPlot3.barsAreHorizontal = YES;
    [graph addPlot:barPlot3 toPlotSpace:plotSpace];
    
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
    barPlot4.barsAreHorizontal = YES;
    [graph addPlot:barPlot4 toPlotSpace:plotSpace];
    
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
    barPlot5.barsAreHorizontal = YES;
    [graph addPlot:barPlot5 toPlotSpace:plotSpace];
    
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
    barPlot6.barsAreHorizontal = YES;
    [graph addPlot:barPlot6 toPlotSpace:plotSpace];
    
    //动态设置柱状图
    [self setBarOffsetDay];
}

/***********************************************************************
 * 方法名称：-(void)setBarOffsetDay
 * 功能描述： 动态设置柱状图
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)setBarOffsetDay
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
            CPTBarPlot *barPlot =(CPTBarPlot *)[graph plotWithIdentifier:[arrKey firstObject]];
            barPlot.barOffset=CPTDecimalFromString(@"0.5");
            break;
        }
        case 2:
            for (int i=0; i<arrKey.count; i++) {
                CPTBarPlot *barPlot =(CPTBarPlot *)[graph plotWithIdentifier:arrKey[i]];
                if (i == 0) {
                    barPlot.barOffset = CPTDecimalFromFloat(0.5 - barWith/2);
                    
                }else{
                    barPlot.barOffset = CPTDecimalFromFloat(0.5+barWith/2);
                }
            }
            break;
        case 3:
            for (int i=0; i<arrKey.count; i++) {
                CPTBarPlot *barPlot =(CPTBarPlot *)[graph plotWithIdentifier:arrKey[i]];
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
                CPTBarPlot *barPlot =(CPTBarPlot *)[graph plotWithIdentifier:arrKey[i]];
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
                CPTBarPlot *barPlot =(CPTBarPlot *)[graph plotWithIdentifier:arrKey[i]];
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
                CPTBarPlot *barPlot =(CPTBarPlot *)[graph plotWithIdentifier:arrKey[i]];
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
    [graph removePlotWithIdentifier:ZZZBARPLOT1];
    [graph removePlotWithIdentifier:ZZZBARPLOT2];
    [graph removePlotWithIdentifier:ZZZBARPLOT3];
    [graph removePlotWithIdentifier:ZZZBARPLOT4];
    [graph removePlotWithIdentifier:ZZZBARPLOT5];
    [graph removePlotWithIdentifier:ZZZBARPLOT6];
    [graphPie removePlotWithIdentifier:@"pieplot"];
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    
    NSNumber *tmpIndex = [showIndexDict objectForKey:plot.identifier];
    if (plotStyle == ZZZPLOTSTYLE_Pie) {
        return [showIndexDict count];
    }
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
    switch (fieldEnum) {// 横向柱形图
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
                float lastNum = 2 * num.floatValue /tt;
//                NSLog(@"最大左边:%f--%f",tt,lastNum);
                return [NSNumber numberWithFloat:lastNum];
            }
            
            break;
    }
    
    return [NSDecimalNumber zero];
}

// 点击某个柱状图
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx
{
    if (self.delegate) {
        NSNumber *nnn = [plot cachedNumberForField:CPTScatterPlotFieldY recordIndex:idx];
        NSNumber *mmm = [plot cachedNumberForField:CPTScatterPlotFieldX recordIndex:idx];
        
        // 获取当前的偏亮
        float ofnum = CPTDecimalCGFloatValue(plot.barOffset);
        float llValue = ofnum + mmm.floatValue;
        
        float xval = nnn.floatValue*(self.frame.size.width-65)/10 + 65;
        float yVal = self.frame.size.height - 70 + 0 + 10 - llValue*(self.frame.size.height-70)/maxXcout ;
        [self.delegate didSelectBar:idx identi:(NSString *)plot.identifier withX:xval withY:yVal];
    }
}

@end
