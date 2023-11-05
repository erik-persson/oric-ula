//----------------------------------------------------------------------------
//
//  Oric ULA
//
//  Copyright (c) 2023 Erik Persson
//
//----------------------------------------------------------------------------

module oric_ula
(
  input  wire       CLK,    // 12 MHz clock
  input  wire       nRESET, // Asynchronous reset
  input  wire [7:0] AH,     // Address bits 15:8 from 6502
  input  wire [7:0] D,      // Data bus
  input  wire       RnW,    // 6502 read signal indicator
  input  wire       nMAP,   // From expansion bus
  output wire [7:0] RC,     // Row/column address to 4164 RAMs
  output wire       MXSEL,  // DRAM mux select
  output wire       nROM,   // ROM chip select
  output wire       PHI,    // Output clock
  output wire       CAS,    // DRAM Column Access Strobe, active high
  output wire       RAS,    // DRAM Row Access Strobe, active high
  output wire       WE,     // DRAM Write Enable, active high
  output wire       nIO,    // 6522 chip select
  output wire       SYNC,   // Composite sync signal
  output wire       RED,    // Red video output
  output wire       GREEN,  // Green video output
  output wire       BLUE    // Blue video output
);

  // Counters
  reg  [3:0]  rg_cnt;
  reg  [5:0]  rg_hcnt;
  reg         rg_hsync;
  reg  [8:0]  rg_vcnt;
  reg  [4:0]  rg_fcnt;
  wire        nx_hsync;
  wire        en_hsync;
  wire        en_hcnt;
  wire        en_vcnt;
  wire        vcnt_wrap;
  wire        vsync;

  // Memory addressing
  reg         rg_alow;
  reg         rg_ras;
  reg         rg_casa;
  wire        hires_line;
  wire        nx_casa;
  wire        en_casa;
  wire [7:0]  row;
  wire        overflow;
  wire [15:0] a_dma0;
  wire [15:0] a_dma1;
  wire [15:0] a_dma;
  wire [7:0]  ah_out;

  // Data capture
  reg  [7:0]  rg_dbuf;
  reg  [5:0]  rg_shift;
  reg         rg_sload_n;
  wire [7:0]  nx_dbuf;
  wire        en_dbuf;
  wire        nx_sload_n;
  wire [5:0]  nx_shift;

  // Video
  reg         rg_mode_60hz;
  reg         rg_mode_text;
  reg         rg_attr_alt;
  reg         rg_attr_tall;
  reg         rg_attr_blink;
  reg  [2:0]  rg_ink;
  reg  [2:0]  rg_paper;
  reg         rg_invert;
  reg         rg_hactive;
  wire        en_ctrl;
  wire        en_mode;
  wire        nx_mode_60hz;
  wire        nx_mode_text;
  wire        en_attr;
  wire        en_ink;
  wire        en_paper;
  wire        attr_reset;
  wire        nx_attr_alt;
  wire        nx_attr_tall;
  wire        nx_attr_blink;
  wire [2:0]  nx_ink;
  wire [2:0]  nx_paper;
  wire        nx_invert;
  wire        hactive;
  wire        vactive;
  wire        active;
  wire        nx_hactive;
  wire        blink_pixel;

  //--------------------------------------------------------------------------
  // Counters
  //--------------------------------------------------------------------------

  assign en_hcnt   = rg_cnt[2:0] == 3'd7;
  assign en_hsync  = en_hcnt && rg_hcnt[1:0] == 2'd1; // opposite phase wrt rg_hcnt[2]
  assign nx_hsync  = rg_hcnt[5:2] != 4'b1100;
  assign en_vcnt   = en_hsync && rg_hsync && !nx_hsync;
  assign vcnt_wrap = rg_vcnt == (rg_mode_60hz ? 9'd263 : 9'd311);
  assign vsync     = rg_vcnt[8:2] != (rg_mode_60hz ? 7'd59 : 7'd64);

  always @(posedge CLK or negedge nRESET)
    if (!nRESET) begin
      rg_cnt   <= 4'b0;
      rg_hcnt  <= 6'd0;
      rg_hsync <= 1'b0;
      rg_vcnt  <= 9'd0;
      rg_fcnt  <= 5'd1;
    end else begin
      rg_cnt   <= rg_cnt == 4'd11 ? 4'd0 : rg_cnt + 1'b1;
      rg_hcnt  <= en_hcnt ? rg_hcnt + 1'b1 : rg_hcnt;
      rg_hsync <= en_hsync ? nx_hsync : rg_hsync;
      rg_vcnt  <= !en_vcnt ? rg_vcnt :
                  vcnt_wrap ? 9'd0 :
                  rg_vcnt + 1'b1;
      rg_fcnt  <= rg_fcnt + (en_vcnt && vcnt_wrap);
    end

  //--------------------------------------------------------------------------
  // Memory addressing
  //--------------------------------------------------------------------------

  assign hires_line = rg_vcnt < 9'd200 && !nx_mode_text;

  assign row = hires_line ? rg_vcnt[7:0] : 8'hb0 + rg_vcnt[7:3];

  // Condition for when DMA address 0 overflows from 0xbfff to 0xc000
  // Occurs on rg_vcnt[7:3]=28 (just off screen), last 8 char cols
  assign overflow = row==8'd204 && rg_hcnt[5];

  // DMA address 0
  assign a_dma0 =
    16'ha000 +
    { overflow,
      { {2'b00,row[7:0]} + {row[7:0],2'b00} + rg_hcnt[5:3]},
      rg_hcnt[2:0]
    };

  // DMA address 1
  assign a_dma1 =
    (nx_mode_text ? 16'hb400 : 16'h9800) +
    { rg_attr_alt,
      rg_dbuf[6:0],
      (rg_attr_tall? rg_vcnt[3:1] : rg_vcnt[2:0])
    };

  assign a_dma  = (!rg_cnt[2] || hires_line) ? a_dma0 : a_dma1;
  assign ah_out = rg_cnt[3] ? AH : a_dma[15:8];
  assign RC     = rg_alow   ? a_dma[7:0] : ah_out;

  assign nx_casa = (nMAP ^ (&ah_out[7:6])) && (nIO || !rg_cnt[3]);
  assign en_casa = !rg_cnt[0];

  always @(posedge CLK or negedge nRESET)
    if (!nRESET) begin
      rg_ras  <= 1'b1;
      rg_casa <= 1'b0;
    end else begin
      rg_ras  <= !rg_cnt[1];
      rg_casa <= en_casa ? nx_casa : rg_casa;
    end

  // The only occurrence of neg edge CLK so far
  // Because of our reset and clock sequence the corresponding
  // flip flop in the extracted reference picks up the value 1,
  // we mimic that here by resetting to 1.
  always @(negedge CLK or negedge nRESET) // Neg edge
    if (!nRESET) begin
      rg_alow <= 1'b1;
    end else begin
      rg_alow <= rg_cnt[1:0] == 2'b00;
    end

  assign PHI   = rg_cnt[3];
  assign RAS   = rg_ras;
  assign CAS   = rg_casa && rg_cnt[1:0] != 2'b01;
  assign WE    = !RnW && rg_cnt[3];
  assign MXSEL = rg_alow && rg_cnt[3];
  assign nROM  = !(RnW && nMAP && AH[7] & AH[6]);
  assign nIO   = AH != 8'h03;

  //--------------------------------------------------------------------------
  // Data capture
  //--------------------------------------------------------------------------

  // Data latch enable
  assign en_dbuf = rg_cnt[3:1] == 3'b001;
  assign nx_dbuf = en_dbuf ? D : rg_dbuf;

  // Shift register
  assign nx_sload_n = !(rg_cnt[2:1]==2'b11 && rg_dbuf[6:5]!=2'b00);
  assign nx_shift   = !rg_cnt[0]  ? rg_shift :
                      rg_sload_n  ? {rg_shift[4:0],1'b0} :
                      D[5:0];


  always @(posedge CLK or negedge nRESET)
    if (!nRESET) begin
      rg_dbuf       <= 8'b0;
      rg_sload_n    <= 1'b0;
      rg_shift      <= 6'b0;
    end else begin
      rg_dbuf       <= nx_dbuf;
      rg_sload_n    <= nx_sload_n;
      rg_shift      <= nx_shift;
    end

  //--------------------------------------------------------------------------
  // Video
  //--------------------------------------------------------------------------

  assign hactive = rg_hcnt < 6'd40;
  assign vactive = rg_vcnt < 9'd224;

  // Control code decoding
  assign en_ctrl  = rg_cnt[2:0] == 3'b111 && hactive && vactive;
  assign en_mode  = en_ctrl && rg_dbuf[6:3] == 4'b0011;
  assign en_attr  = en_ctrl && rg_dbuf[6:3] == 4'b0001;
  assign en_ink   = en_ctrl && rg_dbuf[6:3] == 4'b0000;
  assign en_paper = en_ctrl && rg_dbuf[6:3] == 4'b0010;

  assign nx_mode_60hz = en_mode ? !rg_dbuf[1] : rg_mode_60hz;
  assign nx_mode_text = en_mode ? !rg_dbuf[2] : rg_mode_text;

  assign attr_reset    = (en_hsync && !nx_hsync) || !rg_hsync;
  assign nx_attr_alt   = attr_reset ? 1'b0 : en_attr ? rg_dbuf[0] : rg_attr_alt;
  assign nx_attr_tall  = attr_reset ? 1'b0 : en_attr ? rg_dbuf[1] : rg_attr_tall;
  assign nx_attr_blink = attr_reset ? 1'b0 : en_attr ? rg_dbuf[2] : rg_attr_blink;

  assign nx_ink     = attr_reset ? 3'd7 : en_ink   ? rg_dbuf[2:0] : rg_ink;
  assign nx_paper   = attr_reset ? 3'd0 : en_paper ? rg_dbuf[2:0] : rg_paper;

  assign nx_invert  = rg_cnt[2:0] == 3'b111 ? rg_dbuf[7] : rg_invert;
  assign nx_hactive = rg_cnt[2:0] == 3'b111 ? hactive : rg_hactive;

  always @(posedge CLK or negedge nRESET)
    if (!nRESET) begin
      rg_mode_60hz  <= 1'b0;
      rg_mode_text  <= 1'b0;
      rg_attr_alt   <= 1'b0;
      rg_attr_tall  <= 1'b0;
      rg_attr_blink <= 1'b0;
      rg_ink        <= 3'd0;
      rg_paper      <= 3'd0;
      rg_invert     <= 1'b0;
      rg_hactive    <= 1'b0;
    end else begin
      rg_mode_60hz  <= nx_mode_60hz;
      rg_mode_text  <= nx_mode_text;
      rg_attr_alt   <= nx_attr_alt;
      rg_attr_tall  <= nx_attr_tall;
      rg_attr_blink <= nx_attr_blink;
      rg_ink        <= nx_ink;
      rg_paper      <= nx_paper;
      rg_invert     <= nx_invert;
      rg_hactive    <= nx_hactive;
    end

  assign active      = vactive && rg_hactive;
  assign blink_pixel = (!rg_fcnt[4] || !rg_attr_blink) && rg_shift[5];

  assign SYNC  = rg_hsync && vsync;
  assign RED   = active && (rg_invert ^ (blink_pixel ? rg_ink[0] : rg_paper[0]));
  assign GREEN = active && (rg_invert ^ (blink_pixel ? rg_ink[1] : rg_paper[1]));
  assign BLUE  = active && (rg_invert ^ (blink_pixel ? rg_ink[2] : rg_paper[2]));

endmodule
