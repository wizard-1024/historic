{$D-,I-,S-}

{       ****************************************************
        *                                                  *
        *         Turbo Pascal 6.0   EMS  Unit             *
        *       Provides access to LIM 3.2 functions       *
	*          Version  2.10      01/09/91             *
        *         written  by   Dima  Stefankov            *
        *                                                  *
        ****************************************************
}

unit TpEms;
  {-EMS memory management routines}

interface

uses
 TpDos;             { other units }

const
  EmsErrorCode = $0FFFF; {Used by several functions to signal an error}


      function EmsInstalled : Boolean;
      function EmsStatusOK : Boolean;
      function EmsPagesAvail : Word;
      function EmsTotalPages : Word;
      function EmsPageFramePtr : Pointer;
      function AllocateEmsPages(NumPages : Word) : Word;
      function MapEmsPage(Handle, LogicalPage : Word; PhysicalPage : Byte) : Boolean;
      function DeallocateEmsHandle(Handle : Word) : Boolean;
      function EmsVersion : Byte;
      function SaveEmsContext(Handle : Word) : Boolean;
      function RestoreEmsContext(Handle : Word) : Boolean;
      function EmsActiveHandles : Word;
      function EmsPagesOwned(Handle : Word) : Word;

implementation

  function EmsInstalled : Boolean;
    {-Returns true if the Expanded Memory Manager is installed.}
  type
    EmmNameType = array[1..8] of Char;
  const
    EmmName : EmmNameType = 'EMMXXXX0';
  var
    Regs : Registers;
    P : Pointer;
    EmmPtr : ^EmmNameType absolute P;
    EPOfs : Word absolute EmmPtr;
  begin                      {EmsInstalled}
    {assume failure}
    EmsInstalled := False;

    {get the address of the EMM's ISR}
    P := GetIntVec($67);

    {point to Seg(EmmPtr^):10}
    EPOfs := 10;

    {see if the device name is in the right place}
    EmsInstalled := (EmmPtr^ = EmmName);
  end;                       {EmsInstalled}

    {$L EMSSTAT.OBJ}
  function EmsStatusOK : Boolean;
    {-Returns true if the EMM reports its status as being OK.}
    external;

    {$L EMSAVAIL.OBJ}
  function EmsPagesAvail : Word;
    {-Returns the number of available pages from the expanded memory manager,
      or EmsErrorCode in case of error.}
    external;

    {$L EMSTOTAL.OBJ}
  function EmsTotalPages : Word;
    {-Returns total number of pages of EMS memory, including allocated pages,
      or EmsErrorCode in case of error.}
    external;

    {$L EMSFRAME.OBJ}
  function EmsPageFramePtr : Pointer;
    {-Returns a pointer to the page frame used by the EMM. Returns nil pointer
      in case of error.}
    external;

    {$L EMSALLOC.OBJ}
  function AllocateEmsPages(NumPages : Word) : Word;
    {-Allocates the indicated number of pages and returns a handle.
      Returns EmsErrorCode in case of error.}
    external;

    {$L EMSMAP.OBJ}
  function MapEmsPage(Handle, LogicalPage : Word; PhysicalPage : Byte) : Boolean;
    {-Maps the specified LogicalPage associated with Handle into PhysicalPage
      (0-3). Returns true if successful.}
    external;

    {$L EMSDEALL.OBJ}
  function DeallocateEmsHandle(Handle : Word) : Boolean;
    {-Deallocates the indicated handle and the memory associated with it.}
    external;

    {$L EMSVERSN.OBJ}
  function EmsVersion : Byte;
    {-Returns a BCD version number of the EMM handle. To check for version 3.2
      or greater for example, use: 'if EmsVersion >= $32 then'. Returns 0 in
      case of error.}
    external;

    {$L EMSSAVE.OBJ}
  function SaveEmsContext(Handle : Word) : Boolean;
    {-Saves the EMM context for resident programs. The handle passed must have
      been allocated with a call to AllocateEmsPages. Returns true if
      successful.}
    external;

    {$L EMSRECOV.OBJ}
  function RestoreEmsContext(Handle : Word) : Boolean;
    {-Restores the mapping context of the EMM driver for the handle specified.
      The handle should the same one used in a prior call to SaveEmsContext.
      Returns true if successful.}
    external;

    {$L EMSACTIV.OBJ}
  function EmsActiveHandles : Word;
    {-Returns the number of active EMS handles, EmsErrorCode in case of error}
    external;

    {$L EMSOWNER.OBJ}
  function EmsPagesOwned(Handle : Word) : Word;
    {-Returns the number of pages owned by Handle, or EmsErrorCode in case of error.}
    external;

 {begin}      { initialization }
  end.
