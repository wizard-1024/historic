/****************************************************************************
 *                             File SHOOTER.C
 *
 *                 Demonstration game program (simple hunter)
 *
 *  Copyright (c) Dmitry V. Stefankov, 2001-2002. All rights reserved.
 *
 *****************************************************************************
 *
 *   $Source: d:/projects/games/shooter/RCS/shooter.c $
 *  $RCSfile: shooter.c $
 *   $Author: dstef $
 *     $Date: 2002/01/02 17:12:50 $
 * $Revision: 1.6 $
 *   $Locker: dstef $
 *
 *      $Log: shooter.c $
 *      Revision 1.6  2002/01/02 17:12:50  dstef
 *      Added more portability and readability
 *      Removed more platfrom-dependent code
 *
 *      Revision 1.5  2002/01/02 04:37:32  dstef
 *      Replaced cprintf to printf during verbose option
 *
 *      Revision 1.4  2002/01/02 04:24:48  dstef
 *      Added support for Windows compilers (MSVC,Mingw32)
 *      Added checks for boundaries
 *      Some fixes
 *
 *      Revision 1.3  2002/01/01 21:44:22  dstef
 *      Added support for DJGPP C/C++ compiler
 *
 *      Revision 1.2  2002/01/01 20:53:03  dstef
 *      Added auto-playing mode
 *      Fixed some logic bugs
 *
 *      Revision 1.1  2002/01/01 05:41:13  dstef
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
#define   DIR_DOWN          0               /* Direction */
#define   DIR_UP            1

#define   KEY_ESCAPE        27              /* Keys definitions */
#define   KEY_QUIT          'Q'
#define   KEY_AUTO          'A'
#define   KEY_MANUAL        'M'
#define   KEY_KILL          ' '
#if defined(_MSDOS) || defined(_DJGPP) || defined(_WIN32)
#define   KEY_UP            72
#define   KEY_DOWN          80
#endif                                      /* #if defined(_MSDOS) || defined(_DJGPP) || defined(_WIN32) */
#define   EXT_KEY_CODE      224

#define   TEXT_WIN_SIZE_X   80
#define   TEXT_WIN_SIZE_Y   25


#define   MAX_NUM_ELEM      5               /* Aliens */

#define   SYM_DEL           ' '             /* Characters */
#define   SYM_SHOT          '='
#define   SYM_YOU           'S'
#define   SYM_ELEM          'R'

#define   VAL_GOOD          10              /* Scores */
#define   VAL_ESCAPE        10
#define   VAL_BAD           5
#define   VAL_BLOOD         20




/*---------------------------- Global data -----------------------------------*/
static  char  rcsid[] = "$Id: shooter.c 1.6 2002/01/02 17:12:50 dstef Exp dstef $";





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
 *                              --- shot_by_1 ---
 *
 * Purpose: Display a short by with delay 10 ms
 *   Input: int x - coordinate X
 *          int y - coordinate Y
 *  Output: none
 * Written: by Dmitry V.Stefankov 01-Jan-2002
 ****************************************************************************/
void  shot_by_1(int x, int y)
{
    put_sym(x,y,SYM_SHOT);
    wait_delay(10);
    put_sym(x,y,SYM_DEL);
    refresh();
}



/****************************************************************************
 *                            --- new_coord_y ---
 *
 * Purpose: Calculate new screen coordinate
 *   Input: int d - zone factor
 *          int k - zone multiply
 *  Output: int   - new coordinate
 * Written: by Dmitry V.Stefankov 01-Jan-2002
 ****************************************************************************/
int  new_coord_y(int d, int k, int min_val, int max_val)
{
    int  y = d;                             /* Temporary */

    while( y >= d)  { y = rand()&0x0F; }
    y += (d*k);

    if (y < min_val)  y = min_val;
    if (y > max_val)  y = max_val;

    return( y );
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

    memset( s, SYM_DEL, TEXT_WIN_SIZE_X );
    s[TEXT_WIN_SIZE_X] = '\0';
    for(i=1; i<=TEXT_WIN_SIZE_Y; i++)
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
 * Purpose: Game "shooter"
 *   Input: int     argc -
 *          char ** argv -
 *  Output: int          -
 * Written: by Dmitry V.Stefankov 31-Dec-2001
 *****************************************************************************/
int main( int argc, char ** argv )
{
  int       game_over = 0;                  /* Game end flag */
  int       x_min = 2;                      /* Window definitions */
  int       x_max = TEXT_WIN_SIZE_X-1;
  int       y_min = 2;
  int       y_max = TEXT_WIN_SIZE_Y-1;
  int       x_cur;                          /* Hunter coordinates */
  int       y_cur;
  int       dir = DIR_DOWN;                 /* Hunter moving direction */
  int       c;                              /* Keystroke */
  int       ext_c;
  int       i;                              /* Temporary */
  int       j;
  int       k;
  int       temp_x;
  int       shooted;                        /* Killed flag */
  int       delta;                          /* Screen zone */
  time_t    t;                              /* Current time */
  int       goods = 0;                      /* Results */
  int       bads = 0;
  int       escaped = 0;
  long      int  score = 0;
  int       auto_play_mode = 0;             /* Auto play */
  int       elements[MAX_NUM_ELEM][2];      /* Runnings */
#if defined(_WIN32)
  HANDLE    consoleStdout;                  /* Console screen buffers */
  HANDLE    consoleStdin;
#endif                                      /* #if defined(_WIN32) */

/*--------------------------- Check parameters ------------------------------*/
  if (argc > 1) {
       for(i=1;i<argc; i++) {
          if (strcmp(argv[i],"-a") == 0) auto_play_mode = 1;
          if (strcmp(argv[i],"-h") == 0) {
              printf( "%s\n\n", rcsid );
              printf( "Keys definitions:\n" );
              printf( "Movement:  arrow-up and arrow-down\n" );
              printf( "Modes:     <%c> (auto), <%c> (manual)\n",
                      KEY_AUTO, KEY_MANUAL );
              printf( "Action:    'space bar' (kill), escape or <%c> (quit)\n",
                      KEY_QUIT );
              return(0);
          }
       }
  }

/*---------------------------- Init variables -------------------------------*/
  srand((unsigned)time(&t));
  delta = (y_max+1)/5;

  x_cur = y_min;
  y_cur = new_coord_y(delta,3,y_min,y_max);;

  for(i=0;i<MAX_NUM_ELEM;i++) {
    elements[i][0] = x_max;
    elements[i][1] = new_coord_y(delta,i,y_min,y_max);
  }

/*------------------------ Display initial screen ---------------------------*/
#if defined(_WIN32)
  consoleStdin  = GetStdHandle(STD_INPUT_HANDLE);
  consoleStdout = GetStdHandle(STD_OUTPUT_HANDLE);
  if (consoleStdin == consoleStdout) {
     printf( "ERROR: GetStdHandle() error = %ld\n", GetLastError() );
     return(1);
  }
#endif                                      /* defined(_WIN32) */

#if defined(_UNIX)
  initscr();
  cbreak();
  noecho();
  nonl();
  intrflush(stdscr,FALSE);
  keypad(stdscr,TRUE);
  timeout(100);
#endif                                      /* #if defined(_UNIX) */

#if defined(_WIN32)
  cls(consoleStdout);
#endif                                      /* defined(_WIN32) */

  clear();                                  /* Clear screen */

  move_cursor_xy(1,1);
  addstr("<<< SHOOTER >>>");

/*------------------------------ Main game ----------------------------------*/

  while(1) {

    /* Display current results */
    move_cursor_xy(20,1);
    c = 'M';
    if (auto_play_mode) c = 'A';
    printw("Mode: %c  Score: %ld  Goods: %d  Bads: %d  Escaped: %d     ",
            c, score, goods, bads, escaped );

    /* Update heroes */
    put_sym( x_cur, y_cur, SYM_YOU );
    for(i=0; i<MAX_NUM_ELEM; i++)
         put_sym( elements[i][0], elements[i][1], SYM_ELEM );

    refresh();

    /* Waiting loop */
    wait_delay(200);

    /* Now check for user action */
    c = 0;
    ext_c = 0;

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

    if (auto_play_mode && (c == 0) && (ext_c == 0)) {
        for(i=0; i<MAX_NUM_ELEM; i++)
          if (elements[i][1] == y_cur) c = KEY_KILL;
    }
    if ((toupper(c) == KEY_QUIT) || (c == KEY_ESCAPE))  game_over = 1;
    if (toupper(c) == KEY_AUTO)    auto_play_mode = 1;
    if (toupper(c) == KEY_MANUAL)  auto_play_mode = 0;

    if ((ext_c == KEY_UP) && (y_cur > y_min))    dir = DIR_UP;
    if ((ext_c == KEY_DOWN) && (y_cur < y_max))  dir = DIR_DOWN;

    if (c == KEY_KILL) {
        shooted = 0;
        temp_x = x_max;
        for(i=0; i<MAX_NUM_ELEM; i++) {
            if (elements[i][1] == y_cur) {
               if (elements[i][0] <= temp_x) {
                  temp_x = elements[i][0];
                  k = i;
                  shooted = 1;
               }
            }
        }
        if (shooted == 1) {
            goods++;
            score += VAL_GOOD;
            for(j=x_cur+1;j<=elements[k][0];j++)
                shot_by_1(j,y_cur);
            elements[k][0] = x_max;
            elements[k][1] = new_coord_y(delta,k,y_min,y_max);
            wait_delay(100);
        }
        if (shooted == 0) {
            bads++;
            score -= VAL_BAD;
            for(j=x_cur+1;j<x_max;j++)
                shot_by_1(j,y_cur);
        }
    }

    /* Update heroes */
    put_sym(x_cur,y_cur,SYM_DEL );

    for(i=0; i<MAX_NUM_ELEM; i++) {
        put_sym( elements[i][0], elements[i][1], SYM_DEL );
        elements[i][0]--;
        if (elements[i][0] == x_min) {
            if (y_cur == elements[i][1])
                score -= VAL_BLOOD;
            else
                score -= VAL_ESCAPE;
            escaped++;
            elements[i][0] = x_max;
            elements[i][1] = new_coord_y(delta,i,y_min,y_max);
        }
    }
    refresh();

    /* Bye your game */
    if (game_over == 1) break;

    /* Change hunter moving */
    if (dir == DIR_DOWN) y_cur++;
    if (dir == DIR_UP)   y_cur--;
    if (y_cur == y_max)  dir = DIR_UP;
    if (y_cur == y_min)  dir = DIR_DOWN;

    /* Space to search for hunter */
    if (auto_play_mode && (y_cur != y_max) && (y_cur != y_min)) {
       j=0;
       k=0;
       for(i=0; i<MAX_NUM_ELEM; i++) {
          if (y_cur > elements[i][1]) j++;
          if (y_cur < elements[i][1]) k++;
       }
       if ((j == 0) && (dir == DIR_UP)) dir = DIR_DOWN;
       if ((k == 0) && (dir == DIR_DOWN)) dir = DIR_UP;
    }

  }

  endwin();

/*-------------------- destroy physical/logical terminal --------------------*/
#if defined(_WIN32)
#endif                                      /* #if defined(_MSDOS) || defined(_DJGPP) || defined(_WIN32) */

/*-------------------------- Exit from program ------------------------------*/
  return(0);

}
