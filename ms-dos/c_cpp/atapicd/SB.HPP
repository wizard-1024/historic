//****************************************************************************
//                               File SB.HPP
//
//              Sound Blaster card hardware definitions
//
//    Copyright (c) 1996, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BC31/SOURCE/ATAPICD/RCS/sb.hpp $
//  $RCSfile: sb.hpp $
//   $Author: dstef $
//     $Date: 1999/01/02 01:30:53 $
// $Revision: 1.1 $
//   $Locker: dstef $
//
//      $Log: sb.hpp $
//      Revision 1.1  1999/01/02 01:30:53  dstef
//      Initial revision
//
//
//****************************************************************************



#if defined(_SOUNDBLASTER)
//------------------------ DSP commands ---------------------------------------
enum   DSPcmd
{
    dspcmdDirect8DAC  =   0x10,             // DSP Direct 8-bit DAC command
    dspcmdDMADAC      =   0x14,             // DSP 8-bit DMA DAC command
    dspcmdAUTODMADAC  =   0x1C,             // DSP 8-bit ADC Auto-init DMA transfer
    dspcmdDirectADC   =   0x20,             // DSP Direct ADC command
    dspcmdDMAADC      =   0x24,             // DSP 8-bit DMA ADC command
    dspcmdAUTODMAADC  =   0x2C,             // DSP 8-bit ADC Auto-init DMA transfer
    dspcmdHaltDMA8    =   0xD0,             // pause 8-bit DMA
    dspcmdContDMA8    =   0xD4,             // continue 8-bit DMA */
    dspcmdExitAuto8   =   0xDA,             // stop auto-init DMA transfer
    dspcmdHaltDMA16   =   0xD5,             // pause 16-bit DMA
    dspcmdContDMA16   =   0xD6,             // continue 16-bit DMA
    dpscmdExitDMA16   =   0xD9,             // stop 16-bit DMA
    dspcmdSpeakerOn   =   0xD1,             // turn speaker on
    dspcmdSpeakerOff  =   0xD3,             // turn speaker off
    dspcmdSpeakerStat =   0xD8,             // get speaker status
    dspcmdTimeConst   =   0x40,             // Set time constant
    dspcmdDASampRate  =   0x41,             // D/A Sample Rate (SB16 only)
    dspcmdADSampRate  =   0x42,             // A/D Sample Rate (SB16 only)
    dspcmdBlockSize   =   0x48,             // Set block size
    dspSB16DMA16      =   0xB0,             // PARTIAL command for 16-bit DMA on SB16
    dspSB16DMA8       =   0xC0              // PARTIAL command for 8-bit DMA on SB16
};



//-------------------- DSP command bit settings -------------------------------
enum
{
    dspSB16DAC          =  (0 << 3),        // bit for SB16 D/A
    dspSB16ADC          =  (1 << 3),        // bit for SB16 A/D
    dspSB16SC           =  (0 << 2),        // bit for SB16 Single Cycle
    dspSB16AI           =  (1 << 2),        // bit for SB16 Auto Init
    dspSB16FifoOff      =  (0 << 1),        // bit for SB16 FIFO off
    dspSB16FifoOn       =  (1 << 1),        // bit for SB16 FIFO on
    dspSB16ModeMono     =  (0 << 5),        // SB16 mono voice I/O
    dspSB16ModeStereo   =  (1 << 5),        // SB16 stereo voice I/O
    dspSB16ModeUnsigned =  (0 << 4),        // SB16 unsigned voice I/O
    dspSB16ModeSigned   =  (1 << 4)         // SB16 signed voice I/O
};



//---------------------- DSP port address offsets -----------------------------
const  BYTE   dspoffsetWrBuf     =  0x0C;   // DSP Write Buffer address
const  BYTE   dspoffsetReadData  =  0x0A;   // DSP Read Data address
const  BYTE   dspoffsetDataAvail =  0x0E;   // DSP Data Available address
const  BYTE   dspoffsetReset     =  0x06;   // dsp reset port address
const  BYTE   dspoffsetDMA8Ack   =  0x0E;   // 8-bit DMA  interrupt acknowledge (same as read data port)
const  BYTE   dspoffsetDMA16Ack  =  0x0F;   // 16-bit DMA interrupt acknowledge
const  BYTE   dspoffsetMixerAddr =  0x04;   // mixer address (register select) port
const  BYTE   dspoffsetMixerData =  0x05;   // mixer data port



//------------------------- Mixer registers -----------------------------------
const  BYTE   MASTERVOL         =  0x22;
const  BYTE   VOCVOL            =  0x04;
const  BYTE   FMVOL             =  0x26;
const  BYTE   CDVOL             =  0x28;
const  BYTE   MICVOL            =  0x0A;
const  BYTE   ADCSELECT         =  0x0C;
const  BYTE   INTSTATUS         =  0x82;
const  BYTE   SB16OUTPUT        =  0x3C;
const  BYTE   SB16INPUTL        =  0x3D;
const  BYTE   SB16INPUTR        =  0x3E;



//------------------- SB16 Interrupt status bits ------------------------------
enum  SB16IntStat
{
   DMA8IntStatBit   =   1,
   DMA16IntStatBit  =   2,
   MPU401IntStatBit =   4
};



//----------------- SB miscellaneous ------------------------------------------
const  BYTE   dspReady      =    0xAA;      // Byte returned by dsp when ready after reset
const  BYTE   DMAMODEWRITE  =    0x54;      // Partial mode.  fill in with channel
const  BYTE   DMAMODEREAD   =    0x58;      // same.

#endif                                      // #if defined(_SOUNDBLASTER)
