/****************************************************************************
 *                             File slalom.c
 *
 *                 Demonstration game program (simple slalom)
 *
 *    Copyright (c) Dmitry V. Stefankov, 2002. All rights reserved.
 *
 *****************************************************************************
 *
 *   $Source: d:/projects/games/slalom/RCS/slalom.c $
 *  $RCSfile: slalom.c $
 *   $Author: dstef $
 *     $Date: 2002/01/15 04:08:28 $
 * $Revision: 1.1 $
 *   $Locker: dstef $
 *
 *      $Log: slalom.c $
 *      Revision 1.1  2002/01/15 04:08:28  dstef
 *      Initial revision
 *
 *****************************************************************************/





/*---------------------------- Standard libraries ---------------------------*/
#include	<stdlib.h>
#include	<stdio.h>
#include	<string.h>
#include	<time.h>
#include	<ctype.h>
#if defined(_MSDOS) || defined(_WIN32)
#include	<conio.h>
#include	<dos.h>
#endif                                      /* #if defined(_MSDOS) || defined(_WIN32) */
#if defined(_UNIX)
#include	<unistd.h>
#include	<curses.h>
#endif                                      /* #if defined(_UNIX) */
#if defined(_WIN32)
#include    <windows.h>
#endif                                      /* #if defined(_WIN32) */




/*----------------------- Functions definitions -----------------------------*/
#if !defined(_UNIX)
#ifndef  printw
#define     printw      printf
#endif
#ifndef  addstr
#define     addstr      printf
#endif
#ifndef  refresh
#define     refresh()   {}
#endif
#ifndef  endwin
#define     endwin()    {}
#endif
#ifndef  mvaddch
#define     mvaddch(y,x,ch)     { move_cursor_xy(x,y); putch(c); }
#endif
#if !defined(_WIN32)
#define     move(y,x)   gotoxy(x,y)
#endif                                      /* #if !defined(_WIN32) */
#endif                                      /* #if defined(_UNIX) */

#if defined(_WIN32)
#ifndef  delay
#define     delay       Sleep
#endif
#endif                                      /* if defined(_WIN32) */

#if defined(_UNIX)
#define    delay(w)     usleep( 1000 * (unsigned long)w )
#endif




/*---------------------------- Miscellaneous --------------------------------*/
#define   KEY_ESCAPE        27              /* Keys definitions */
#define   KEY_QUIT          'Q'
#if defined(_MSDOS) || defined(_DJGPP) || defined(_WIN32)
#define   KEY_LEFT          75
#define   KEY_RIGHT         77
#endif                                      /* #if defined(_MSDOS) || defined(_DJGPP) || defined(_WIN32) */
#define   EXT_KEY_CODE      224

#define   TEXT_WIN_SIZE_X   80
#define   TEXT_WIN_SIZE_Y   25


#define   MAX_NUM_ELEM      5               /* Aliens */

#define   SYM_DEL           ' '             /* Characters */
#define   SYM_BOUND         'S'
#define   SYM_MARKER        'X'
#define   SYM_LEFT          'L'
#define   SYM_RIGHT         'R'

#define   VAL_GOOD          5              /* Scores */
#define   VAL_BAD           5




/*---------------------------- Global data -----------------------------------*/
static  char  rcsid[] = "$Id: slalom.c 1.1 2002/01/15 04:08:28 dstef Exp dstef $";

static int wTEXT_WIN_SIZE_X  =  TEXT_WIN_SIZE_X;
static int wTEXT_WIN_SIZE_Y  =  TEXT_WIN_SIZE_Y;




/*****************************************************************************
 *                            --- wait_delay ---
 *
 * Purpose: Delay by N milliseconds
 *   Input: unsigned int wd - delay value in ms
 *  Output: none
 * Written: by Dmitry V.Stefankov 01-Jan-2002
 *****************************************************************************/
void  wait_delay( unsigned int  wd )
{
    delay( wd );
}



/*****************************************************************************
 *                         --- move_cursor_xy ---
 *
 * Purpose: Move cursor to screen (x,y)
 *   Input: int x - coordinate x
 *          int y - coordinate y
 *  Output: none
 * Written: by Dmitry V.Stefankov 01-Jan-2002
 *****************************************************************************/
void  move_cursor_xy(int x, int y)
{
#if defined(_WIN32)
    COORD  consoleXY = { x-1, y-1 };
    SetConsoleCursorPosition( GetStdHandle(STD_OUTPUT_HANDLE), consoleXY );
#else
    move(y,x);
#endif                                      /* #if defined(_WIN32) */
}



/****************************************************************************
 *                             --- put_sym ---
 *
 * Purpose: Write a character to screen by coordinates x,y
 *   Input: int  x - coordinate X
 *          int  y - coordinate Y
 *          char c - character
 *  Output: none
 * Written: by Dmitry V.Stefankov 01-Jan-2002
 ****************************************************************************/
void  put_sym(int x, int y, char c )
{
#if defined(_WIN32)
    DWORD       numWrite;                   /* Temporary */
    char      buf[2] = { c, '\0' };         /* Characters buffer */

    move_cursor_xy(x,y);
    WriteConsole( GetStdHandle(STD_OUTPUT_HANDLE), buf, 1, &numWrite, NULL );
#else
    mvaddch(y,x,c);
#endif                                      /* #if defined(_WIN32) */
}



/****************************************************************************
 *                       --- new_offset_x ---
 *
 * Purpose: Calculate offset -/+ 1
 *   Input: none
 *  Output: int   - new offset
 * Written: by Dmitry V.Stefankov 14-Jan-2002
 ****************************************************************************/
int  new_offset_x( void )
{
    int  x;                                 /* Temporary */

#if defined(_UNIX)
    x = random() & 0x01;
    if (x == 0) x = -1;
#else
    x = rand() & 0x01;
    if (x == 0) x = -1;
#endif

    return(x);
}



/****************************************************************************
 *                       --- new_delta_x ---
 *
 * Purpose: Calculate offset for delta
 *   Input: none
 *  Output: int   - new offset
 * Written: by Dmitry V.Stefankov 14-Jan-2002
 ****************************************************************************/
int  new_delta_x( void )
{
    int  x;                                 /* Temporary */

#if defined(_UNIX)
    x = random() & 0x03;
    x -= 1;
#else
    x = rand() & 0x03;
    x -= 1;
#endif

    return(x);
}



#if !defined(_UNIX)
/*****************************************************************************
 *                          --- clear ---
 *
 * Purpose: Clear text screen 80x25
 *   Input: none
 *  Output: none
 * Written: by Dmitry V.Stefankov 02-Jan-2002
 *****************************************************************************/
void clear(void)
{
    int    	i;                          /* Counter */
    char   	s[128];                     /* String */

    memset( s, SYM_DEL, wTEXT_WIN_SIZE_X );
    s[wTEXT_WIN_SIZE_X] = '\0';
    for(i=1; i<=wTEXT_WIN_SIZE_Y; i++)
       addstr("%s", s );
}
#endif                                      /* #if !defined(_UNIX) */


#if defined(_WIN32)
void cls( HANDLE hConsole )
{
   COORD coordScreen = { 0, 0 };    // home for the cursor 
   DWORD cCharsWritten;
   CONSOLE_SCREEN_BUFFER_INFO csbi; 
   DWORD dwConSize;

// Get the number of character cells in the current buffer. 

   if( !GetConsoleScreenBufferInfo( hConsole, &csbi ))
   {
      return;
   }

   dwConSize = csbi.dwSize.X * csbi.dwSize.Y;

   // Fill the entire screen with blanks.
   if( !FillConsoleOutputCharacter( hConsole,        // Handle to console screen buffer 
                                    (TCHAR) ' ',     // Character to write to the buffer
                                    dwConSize,       // Number of cells to write 
                                    coordScreen,     // Coordinates of first cell 
                                    &cCharsWritten ))// Receive number of characters written
   {
      return;
   }

   // Get the current text attribute.
   if( !GetConsoleScreenBufferInfo( hConsole, &csbi ))
   {
      return;
   }

   // Set the buffer's attributes accordingly.
   if( !FillConsoleOutputAttribute( hConsole,         // Handle to console screen buffer 
                                    csbi.wAttributes, // Character attributes to use
                                    dwConSize,        // Number of cells to set attribute 
                                    coordScreen,      // Coordinates of first cell 
                                    &cCharsWritten )) // Receive number of characters written
   {
      return;
   }

   // Put the cursor at its home coordinates.
   SetConsoleCursorPosition( hConsole, coordScreen );
}
#endif                                      /* #if defined(_WIN32) */



/****************************************************************************
 *                              --- main ---
 *
 * Purpose: Game "slalom"
 *   Input: int     argc -
 *          char ** argv -
 *  Output: int          -
 * Written: by Dmitry V.Stefankov 14-Jan-2002
 *****************************************************************************/
int main( int argc, char ** argv )
{
  int       game_over = 0;                  /* Game end flag */
  int       x_min = 21;                     /* Window definitions */
  int       x_max = 60;
  int       y_min = 2;
  int       y_max = TEXT_WIN_SIZE_Y-1;
  int       x_cur;                          /* Mover coordinates */
  int       y_cur;
  int       xs_min;                         /* Slalom window */
  int       xs_max;
  int       ys_min;
  int       ys_max;
  int       winsize_x;
  int       winsize_y;
  int       c;                              /* Keystroke */
  int       ext_c;
  int       i;                              /* Temporary */
  int       k;
  int       temp_x;
  int       left_xs;                        /* Sides boundary */
  int       right_xs;
  int       center_xs;
  int       delta_left;                     /* Screen zone */
  int       delta_right;
  int       delta_move;
  time_t    t;                              /* Current time */
  long      int  score = 0;
  char      fill_str[TEXT_WIN_SIZE_X+1];
#if defined(_WIN32)
  HANDLE    consoleStdout;                  /* Console screen buffers */
  HANDLE    consoleStdin;
  DWORD     dwMode = 0;
  CONSOLE_SCREEN_BUFFER_INFO  csbiInfo; 
  SMALL_RECT  srctWindow; 
  COORD  ScreenWinSize = {80,25};
#endif                                      /* #if defined(_WIN32) */

#if defined(_WIN32)
    consoleStdout = GetStdHandle(STD_OUTPUT_HANDLE);
    if (! GetConsoleScreenBufferInfo(consoleStdout, &csbiInfo)) 
    {
        printf("GetConsoleScreenBufferInfo (%d)\n", GetLastError()); 
        return 0;
    }
    //wTEXT_WIN_SIZE_Y = csbiInfo.dwMaximumWindowSize.Y;
    SetConsoleDisplayMode(consoleStdout,CONSOLE_WINDOWED_MODE,&ScreenWinSize);
    SetConsoleScreenBufferSize(consoleStdout,ScreenWinSize);
#endif

  y_max = wTEXT_WIN_SIZE_Y-1;

/*--------------------------- Check parameters ------------------------------*/
  if (argc > 1) {
       for(i=1;i<argc; i++) {
          if (strcmp(argv[i],"-h") == 0) {
              printf( "%s\n\n", rcsid );
              printf( "Keys definitions:\n" );
              printf( "Movement:  arrow-left and arrow-right\n" );
              printf( "Action:    escape or <%c> (quit)\n",
                      KEY_QUIT );
              return(0);
          }
       }
  }

/*---------------------------- Init variables -------------------------------*/
  srand((unsigned)time(&t));
  delta_left = 6;
  delta_right = 6;
  delta_move = 5;
  xs_min = x_min;
  ys_min = y_min;
  winsize_x = (x_max - x_min) + 1;
  winsize_y = (y_max - y_min) + 1;
  xs_max = x_min + winsize_x;
  ys_max = y_min + winsize_y;
  center_xs = xs_min + (winsize_x/2);
  memset( fill_str, SYM_DEL, sizeof(fill_str) );
  fill_str[winsize_x+3] = '\0';

/*------------------------ Display initial screen ---------------------------*/
#if defined(_WIN32)
  consoleStdin  = GetStdHandle(STD_INPUT_HANDLE);
  consoleStdout = GetStdHandle(STD_OUTPUT_HANDLE);
  if (consoleStdin == consoleStdout) {
     printf( "ERROR: GetStdHandle() error = %ld\n", GetLastError() );
     return(1);
  }
#if 0
  if (GetConsoleMode(consoleStdout, &dwMode ) == 0) {
    fprintf( stderr, "GetConsoleMode() failed!\n" );
    return 10;
  }
  printf( "dwMode=0x%08X\n", dwMode );
  return 0;
#endif
#if 0
    if (! GetConsoleScreenBufferInfo(consoleStdout, &csbiInfo)) 
    {
        printf("GetConsoleScreenBufferInfo (%d)\n", GetLastError()); 
        return 0;
    }
    printf( "MaX=%d\n", csbiInfo.dwMaximumWindowSize.X );
    printf( "MaY=%d\n", csbiInfo.dwMaximumWindowSize.Y );
    return 0;
#endif
#endif                                      /* defined(_WIN32) */

#if defined(_UNIX)
  initscr();
  cbreak();
  noecho();
  nonl();
  intrflush(stdscr,FALSE);
  keypad(stdscr,TRUE);
  timeout(100);
  scrollok(stdscr,TRUE);
#endif                                      /* #if defined(_UNIX) */

#if defined(_WIN32)
  cls(consoleStdout);
#endif                                      /* defined(_WIN32) */

  //clear();                                  /* Clear screen */

  move_cursor_xy(1,1);
  addstr("<<< SLALOM >>>");

  move_cursor_xy(65,1);
  printw(" SCORE: %ld    ", score);

  for( i=ys_min; i<ys_max; i++) {
     put_sym( xs_min-1, i, SYM_BOUND );
     put_sym( xs_max+1, i, SYM_BOUND );
  }

  for( i=ys_min; i<ys_max; i++) {

     temp_x = new_offset_x();
     center_xs += (temp_x*delta_move);
     if (center_xs <= xs_min) center_xs = xs_min + 2 * delta_move;
     if (center_xs >= xs_max) center_xs = xs_max - 2 * delta_move;
     if (i < ys_max - 5) {
        put_sym( center_xs, i, SYM_MARKER );
        x_cur = center_xs;
        y_cur = i;
     }
     left_xs = center_xs - delta_left;
     for( k=xs_min; k<=left_xs; k++ ) put_sym( k, i, SYM_LEFT );

     right_xs = center_xs + delta_right;
     for( k=right_xs; k<=xs_max; k++ ) put_sym( k, i, SYM_RIGHT );
  }

#if 0
  c = getch();
  exit(0);
#endif

  wait_delay(2000);

/*------------------------------ Main game ----------------------------------*/

  while(1) {

#if defined(_UNIX)
   for( i=0; i<3; i++ ) {
#else
   for( i=0; i<30; i++ ) {
#endif
        /* Now check for user action */
        c = 0;
        ext_c = 0;

#if !defined(_UNIX)
        wait_delay(10);
#endif

    #if defined(_MSDOS) || defined(_DJGPP) || defined(_WIN32)
        if ( kbhit() ) {
          c = getch();
          if (!c)  ext_c = getch();
          if (c == EXT_KEY_CODE) ext_c = getch();
        }
    #endif                                      /* #if defined(_MSDOS) || defined(_DJGPP) || defined(_WIN32) */

    #if defined(_UNIX)
        c = getch();
        if (c == ERR) c = 0;
        else ext_c = c;
    #endif                                      /* #if defined(_UNIX) */

        if ((toupper(c) == KEY_QUIT) || (c == KEY_ESCAPE))  game_over = 1;
        if (game_over == 1) break;

        put_sym( x_cur, y_cur, SYM_DEL );

        if ((ext_c == KEY_LEFT) && (x_cur > xs_min)) x_cur--;
        if ((ext_c == KEY_RIGHT) && (x_cur < xs_max)) x_cur++;

        put_sym( x_cur, y_cur, SYM_MARKER );
        refresh();
    } /*for*/

    /* Bye your game */
    if (game_over == 1) break;

    /* Scroll window up */
#if defined(_UNIX)
    move_cursor_xy(1,1);
    addstr("               ");
    move_cursor_xy(65,1);
    addstr("             ");
#endif
    move_cursor_xy(xs_min-1,ys_min);
    addstr(fill_str);
    put_sym(wTEXT_WIN_SIZE_X,y_max+1,SYM_DEL);
#if defined(_UNIX)
    scroll(stdscr);
#endif


    /* Write again title and score */
    move_cursor_xy(1,1);
    addstr("<<< SLALOM >>>");

    move_cursor_xy(65,1);
    printw(" SCORE: %ld    ", score);

    /* Scroll slalom field up */
    for( i=ys_max-1; i<ys_max; i++) {

       temp_x = new_offset_x();
       center_xs += (temp_x*delta_move);
       if (center_xs <= (xs_min+3*delta_move))
           center_xs = xs_min + 3 * delta_move;
       if (center_xs >= (xs_max-3*delta_move))
           center_xs = xs_max - 3 * delta_move;

       left_xs = center_xs - delta_left;
       right_xs = center_xs + (delta_right);
       if (left_xs >= center_xs) left_xs = center_xs - delta_move;
       if (right_xs <= center_xs) right_xs = center_xs - delta_move;

       put_sym( xs_min-1, i, SYM_BOUND );
       for( k=xs_min; k<=left_xs; k++ ) put_sym( k, i, SYM_LEFT );
       for( k=right_xs; k<=xs_max; k++ ) put_sym( k, i, SYM_RIGHT );
       put_sym( xs_max+1, i, SYM_BOUND );
    }

    refresh();

    score += VAL_GOOD;                      /* Added scores */

  } /*while*/

  endwin();

/*-------------------------- Exit from program ------------------------------*/
  return(0);

}
