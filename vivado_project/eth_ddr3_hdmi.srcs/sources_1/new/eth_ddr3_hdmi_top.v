`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/05 22:38:27
// Design Name: 
// Module Name: eth_ddr3_hdmi_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module eth_ddr3_hdmi_top
(
    // 基本接口
    input clk_in,
    input rst_n,
    input wr_load,
    
    //ethernet接口
    input              eth_rxc   , //RGMII接收数据时钟
    input              eth_rx_ctl, //RGMII输入数据有效信号
    input       [3:0]  eth_rxd   , //RGMII输入数据
    output             eth_txc   , //RGMII发送数据时钟    
    output             eth_tx_ctl, //RGMII输出数据有效信号
    output      [3:0]  eth_txd   , //RGMII输出数据          
    output             eth_rst_n,   //以太网芯片复位信号，低电平有效 
    
    // DDR3 IO接口 
    inout   [15:0]     ddr3_dq             ,   //DDR3 数据
    inout   [1:0]      ddr3_dqs_n          ,   //DDR3 dqs负
    inout   [1:0]      ddr3_dqs_p          ,   //DDR3 dqs正
    output  [13:0]     ddr3_addr           ,   //DDR3 地址   
    output  [2:0]      ddr3_ba             ,   //DDR3 banck 选择
    output             ddr3_ras_n          ,   //DDR3 行选择
    output             ddr3_cas_n          ,   //DDR3 列选择
    output             ddr3_we_n           ,   //DDR3 读写选择
    output             ddr3_reset_n        ,   //DDR3 复位
    output  [0:0]      ddr3_ck_p           ,   //DDR3 时钟正
    output  [0:0]      ddr3_ck_n           ,   //DDR3 时钟负
    output  [0:0]      ddr3_cke            ,   //DDR3 时钟使能
    output  [0:0]      ddr3_cs_n           ,   //DDR3 片选
    output  [1:0]      ddr3_dm             ,   //DDR3_dm
    output  [0:0]      ddr3_odt            ,   //DDR3_odt 
    
    // HDMI 接口
    output [0:0]    HDMI_OEN,         //HDMI out enable
    output          TMDS_clk_n,       //HDMI differential clock negative
    output          TMDS_clk_p,       //HDMI differential clock positive
    output [2:0]    TMDS_data_n,      //HDMI differential data negative
    output [2:0]    TMDS_data_p      //HDMI differential data positive
    
);

// clk_50m wiz
wire clk_50m, video_clk, video_clk_5x, clk_200m, locked1, locked2;
wire locked = locked1 & locked2;

//eth
wire rec_en;
wire [31:0] rec_data;

//hdmi
wire new_frame, data_req;
wire [15:0] data_in = data_out;
reg [15:0] data_out_d;

//ddr3
wire wr_clk = clk_200m;
wire rd_clk = video_clk;
wire datain_valid = rec_en;
wire [31:0] datain = rec_data;
wire rdata_req = data_req;
wire rd_load = new_frame;
wire [15:0] data_out;
wire ddr3_top_init_ok;
wire [27:0] app_addr_max = 28'd2073600;
wire [7:0] burst_len = 8'd60;

wire all_ok = rst_n & ddr3_top_init_ok & locked;

eth_top eth_top_inst(
    .clk_200m(clk_200m)  , //系统时钟
    .sys_rst_n(locked & rst_n) , //系统复位信号，低电平有效 
    //以太网RGMII接口   
    .eth_rxc(eth_rxc)   , //RGMII接收数据时钟
    .eth_rx_ctl(eth_rx_ctl), //RGMII输入数据有效信号
    .eth_rxd(eth_rxd)   , //RGMII输入数据
    .eth_txc(eth_txc)   , //RGMII发送数据时钟    
    .eth_tx_ctl(eth_tx_ctl), //RGMII输出数据有效信号
    .eth_txd(eth_txd)   , //RGMII输出数据          
    .eth_rst_n(eth_rst_n),   //以太网芯片复位信号，低电平有效   
    
    .rec_en(rec_en),
    .rec_data(rec_data)
    );    

BUFG BUFG_inst(
    .O  (  clk_50m   ),
    .I  (  clk_in    )
);

clk_wiz_0 clk_wiz_0_inst
(
    // Clock out ports
    .video_clk(video_clk),              // output video_clk
    .video_clk_5x(video_clk_5x),        // output video_clk_5x
    
    // Status and control signals
    .reset(~rst_n),                      // input reset
    .locked(locked1),                    // output locked
    
    // Clock in ports
    .clk_in1(clk_50m)                   // input clk_in1
);

clk_wiz_1 clk_wiz_1_inst
(
    .clk_200m(clk_200m),     // output clk_200m
    .reset(~rst_n), // input reset
    .locked(locked2),       // output locked
    
    .clk_in1(clk_50m)
);     

/* img_data_generator img_data_generator_inst
(
    .sys_clk        (clk_50m),
    .sys_reset_n    (rst_n & locked),
    .data_req       (data_req_generator),
    .data_img       (data_img_generator)
);  */

hdmi_top hdmi_top_inst
(
    .video_clk(video_clk),        //pixel clock and 5x pixel clock required for the video
    .video_clk_5x(video_clk_5x),
    .HDMI_reset_n(rst_n & locked),
    
    .HDMI_OEN(HDMI_OEN),         //HDMI out enable
    .TMDS_clk_n(TMDS_clk_n),       //HDMI differential clock negative
    .TMDS_clk_p(TMDS_clk_p),       //HDMI differential clock positive
    .TMDS_data_n(TMDS_data_n),      //HDMI differential data negative
    .TMDS_data_p(TMDS_data_p),      //HDMI differential data positive
    
    .data_req(data_req),         //data_in慢data_req一拍 
    .data_in(data_in),           //RGB565 data
    .new_frame(new_frame)
);

ddr3_top ddr3_top_inst
(
    .clk_200m(clk_200m)            ,   //ddr3参考时钟
    .sys_rst_n(rst_n)           ,   //复位,低有效
    .sys_init_done(locked)       ,   //系统初始化完成 
    //DDR3接口信号                      
    .app_addr_rd_min(28'd0)     ,   //读ddr3的起始地址
    .app_addr_rd_max(app_addr_max)     ,   //读ddr3的结束地址
    .rd_bust_len(burst_len)         ,   //从ddr3中读数据时的突发长度
    .app_addr_wr_min(28'd0)     ,   //读ddr3的起始地址
    .app_addr_wr_max(app_addr_max)     ,   //读ddr3的结束地址
    .wr_bust_len(burst_len)         ,   //从ddr3中读数据时的突发长度
    // DDR3 IO接口
    .ddr3_dq(ddr3_dq)             ,   //DDR3 数据
    .ddr3_dqs_n(ddr3_dqs_n)          ,   //DDR3 dqs负
    .ddr3_dqs_p(ddr3_dqs_p)          ,   //DDR3 dqs正  
    .ddr3_addr(ddr3_addr)           ,   //DDR3 地址   
    .ddr3_ba(ddr3_ba)             ,   //DDR3 banck 选择
    .ddr3_ras_n(ddr3_ras_n)          ,   //DDR3 行选择
    .ddr3_cas_n(ddr3_cas_n)          ,   //DDR3 列选择
    .ddr3_we_n(ddr3_we_n)           ,   //DDR3 读写选择
    .ddr3_reset_n(ddr3_reset_n)        ,   //DDR3 复位
    .ddr3_ck_p(ddr3_ck_p)           ,   //DDR3 时钟正
    .ddr3_ck_n(ddr3_ck_n)           ,   //DDR3 时钟负
    .ddr3_cke(ddr3_cke)            ,   //DDR3 时钟使能
    .ddr3_cs_n(ddr3_cs_n)           ,   //DDR3 片选
    .ddr3_dm(ddr3_dm)             ,   //DDR3_dm
    .ddr3_odt(ddr3_odt)            ,   //DDR3_odt     
    //用户
    .ddr3_read_valid(1'b1)     ,   //DDR3 读使能   
    .ddr3_pingpang_en(1'b0)    ,   //DDR3 乒乓操作使能       
    .wr_clk(wr_clk)              ,   //wfifo时钟   
    .rd_clk(rd_clk)              ,   //rfifo的读时钟      
    .datain_valid(datain_valid)        ,   //数据有效使能信号
    .datain(datain)              ,   //有效数据 
    .rdata_req(rdata_req)           ,   //请求像素点颜色数据输入  
    .rd_load(rd_load)             ,   //输出源更新信号
    .wr_load(~wr_load)             ,   //输入源更新信号
    .dataout(data_out)             ,   //rfifo输出数据
    .ddr3_top_init_ok(ddr3_top_init_ok)     //ddr3初始化完成信号
    );
    


endmodule
