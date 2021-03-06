/****************************************Copyright (c)**************************************************
**--------------------------------------File Info-----------------------------------------------------
** File name:	        VGA.v
** Last modified Date:	2007-8-05
** Last Version:		1.0
** Descriptions:		vga
**------------------------------------------------------------------------------------------------------
** Created by:	    	
** Created date:		2007-8-05
** Version:				1.0
** Descriptions:		The original version
**
**------------------------------------------------------------------------------------------------------
** Modified by:			
** Modified date:		
** Version:				
** Descriptions:		
**
**------------------------------------------------------------------------------------------------------
********************************************************************************************************/
//按RST复位后，VGA每秒钟切换一次彩色的条纹图片，共2幅图片。
module vgatest(
input             sys_clk   ,
input             sys_rst_n ,
                         
output  reg       Hs        ,
output  reg       Vs        ,
output  wire      VGA_G     ,
output  wire      VGA_B     ,
output  wire      VGA_R      );
                          
reg [7:0] RGB               ;

reg [7:0] regRGB            ;
reg       clk_25M           ;
reg       Hs_carry          ;
reg [3:0] state_vs          ;
reg [3:0] state_hs          ;
reg [9:0] count_y,count_x   ;
reg[26:0] count_xs          ;
reg       flag_array        ;
                            
wire VGA_G0                 ;
wire VGA_G1                 ;
wire VGA_G2                 ;
                        
wire VGA_B0                 ;
wire VGA_B1                 ;
wire VGA_B2                 ;
                        
wire VGA_R0                 ;
wire VGA_R1                 ;
                        

parameter value_areahs=4'b0001,
          h_front     =4'b0010,
          h_sync      =4'b0100,
          h_back      =4'b1000;

parameter value_areavs=4'b0001,
          v_front     =4'b0010,
          v_sync      =4'b0100,
          v_back      =4'b1000;

/******************************************************************
**                              Main Code    
**  
*******************************************************************/

/****************产生VGA点时钟，这里为24M********************/
always@( posedge sys_clk )
begin
  clk_25M <= ~clk_25M;
end

/*********************行信号控制**************************/
always@(posedge clk_25M)
 begin
   if( sys_rst_n == 1'b0 )
     begin
      state_hs<=value_areahs;
      Hs<=1'b1;
      count_y<=10'd0;
      RGB<=8'b0000_0000;
     end
    else
    begin
      case(state_hs)
        value_areahs:
          begin 
           Hs_carry<=1'b0;
           count_y<=count_y+1'b1;
            RGB<=regRGB;
           if(count_y==10'd639)   state_hs<=h_front;
           else state_hs<=value_areahs;
          end
        h_front:
          begin
            count_y<=count_y+1'b1;
            RGB<=8'b0000_0000;
            if(count_y==10'd663)   state_hs<=h_sync;
            else state_hs<=h_front;
          end
        h_sync:
          begin
            count_y<=count_y+1'b1;
            Hs<=1'b0;
            if(count_y==10'd759)   state_hs<=h_back;
            else state_hs<=h_sync;
          end
        h_back:
          begin
            count_y<=count_y+1'b1;
            Hs<=1'b1;
            if(count_y==10'd799)  
              begin
               state_hs<=value_areahs;
               count_y<=10'd0;
               Hs_carry<=1'b1;
              end
            else state_hs<=h_back;
           end
         endcase 
    end
 end
/***************************场信号控制*************************/
always@(posedge clk_25M)
  begin
   if( sys_rst_n == 1'b0 )
     begin
       state_vs<=value_areavs;
       count_x<=0;
       Vs<=1'b1; 
     end
   else if(Hs_carry)
     begin
       case(state_vs)
        value_areavs:
          begin
           count_x<=count_x+1'b1;
           Vs<=1'b1;
           if(count_x==10'd479)  state_vs<=v_front;
           else state_vs<=value_areavs;    
          end
        v_front:
          begin
           count_x<=count_x+1'b1;
           if(count_x==10'd497)  state_vs<=v_sync;
           else state_vs<=v_front;      
          end
        v_sync:
          begin
           count_x<=count_x+1'b1;
           Vs<=1'b0;
           if(count_x==10'd499)  state_vs<=v_back;
           else state_vs<=v_sync;   
          end
        v_back:
          begin
           Vs<=1'b1;
           count_x<=count_x+1'b1;
           if(count_x==10'd524) 
             begin
              state_vs<=value_areavs;
              count_x<=10'd0;
             end
           else state_vs<=v_back;      
          end
         endcase   
     end
  end
//----------产生条纹的RGB数据--------------------
 always@(posedge sys_clk)
   begin
    if(flag_array)
      begin
       if(count_y<=10'd40) regRGB<=8'b0010_0000;                //B
       else if(count_y<=10'd80) regRGB<=8'b0000_0100;           //G
       else if(count_y<=10'd120) regRGB<=8'b0000_0011;          //R 
       else if(count_y<=10'd160) regRGB<=8'b0110_0000;          //B
       else if(count_y<=10'd200) regRGB<=8'b0000_1100;          //G
       else if(count_y<=10'd240) regRGB<=8'b0000_0011;          //R
       else if(count_y<=10'd280) regRGB<=8'b1110_0000;          //B
       else if(count_y<=10'd320) regRGB<=8'b0010_0101;          //G
       else if(count_y<=10'd360) regRGB<=8'b1010_0101;
       else if(count_y<=10'd400) regRGB<=8'b0110_0101;
       else if(count_y<=10'd440) regRGB<=8'b0110_0101;
       else if(count_y<=10'd480) regRGB<=8'b0010_1101;
       else if(count_y<=10'd520) regRGB<=8'b0110_0101;
       else if(count_y<=10'd560) regRGB<=8'b0110_0101;
       else if(count_y<=10'd600) regRGB<=8'b1110_0101;
       else if(count_y<=10'd640) regRGB<=8'b1111_1111;
      end
   else
     begin
       if(count_x<=10'd60) regRGB<=8'b0010_0000;                //B
       else if(count_x<=10'd120) regRGB<=8'b0000_0100;          //G
       else if(count_x<=10'd180) regRGB<=8'b0000_0011;          //R 
       else if(count_x<=10'd240) regRGB<=8'b0110_0000;          //B
       else if(count_x<=10'd300) regRGB<=8'b0000_1100;          //G
       else if(count_x<=10'd360) regRGB<=8'b0000_0011;          //R
       else if(count_x<=10'd420) regRGB<=8'b1110_0000;          //B
       else if(count_x<=10'd480) regRGB<=8'b0010_0101;          //G
     end
    end
    
/*******获取1S的信号*********/
always@(posedge sys_clk)
  begin 
    if(count_xs>27'd9600_0000) 
      begin
       count_xs<=0;
       flag_array<=~flag_array;
      end
    else
      count_xs<=count_xs+1;
  end  

//--------------------assign VGA data-------------------------------------------//
assign VGA_G0 = RGB[5];
assign VGA_G1 = RGB[4];
assign VGA_G2 = RGB[3];

assign VGA_B0 = RGB[7];
assign VGA_B1 = RGB[6];
assign VGA_B2 = RGB[0];

assign VGA_R0 = RGB[2];
assign VGA_R1 = RGB[1];

assign VGA_G = VGA_G0 | VGA_G1 | VGA_G2;
assign VGA_B = VGA_B0 | VGA_B1 | VGA_B2;
assign VGA_R = VGA_R0 | VGA_R1 ;

endmodule  


