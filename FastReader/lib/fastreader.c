#include <stdio.h>
#include <string.h>

#define DEBUG 0

char *_find_next_header(char* buffer);
int _ends_with_include(char *email_boundary);

/* Storage for the email */
static char *EMAIL_BUFFER = NULL;

/* Amount to increase the buffer by when it fills up */
static unsigned int EMAIL_BUFFER_SIZE_INCREMENT=1000000;

/* The current size of the buffer */
static unsigned int EMAIL_BUFFER_SIZE=0;

/* The current line count */
static long LINE_NUMBER = 0;

/* The last line read */
static char LAST_LINE[1025];

/* The length of the email */
static unsigned int LENGTH_OF_EMAIL = 0;

/* The file pointer */
static FILE *FILE_HANDLE;

/**************************************************************************/

/* Read one email from the file, setting *email to point to it, and
 * email_line to the line in the file on which it appears */

int read_email(char **email,long *email_line)
{
  char *start_of_new_line;
  unsigned int number_characters_read;

  /* Can't read from the end of the file */
  if (feof(FILE_HANDLE))
  {
#if DEBUG==1 || DEBUG==2 || DEBUG==3
    fprintf(stderr,"eof\n");
#endif
    return 0;
  }

  /* If this is the first email, pre-load the email buffer. */
  if (LINE_NUMBER == 0)
    fgets(EMAIL_BUFFER,1024,FILE_HANDLE);
  else
    strcpy(EMAIL_BUFFER,LAST_LINE);

  LENGTH_OF_EMAIL = strlen(EMAIL_BUFFER);
  LINE_NUMBER++;

  /* Set the line number to return */
  *email_line = LINE_NUMBER;

  /* Keep reading lines until we hit the next email or EOF. At this
   * point we have 1 line of the email in the buffer. */
  while (1)
  {
#if DEBUG==3
    fprintf(stderr,".");
#endif

    /* Extend the size of the buffer if necessary to accomodate 1 more
     * line. */
    if (EMAIL_BUFFER_SIZE < LENGTH_OF_EMAIL + 1024)
    {
#if DEBUG==1
      fprintf(stderr,"extending\n");
#endif
      EMAIL_BUFFER_SIZE += EMAIL_BUFFER_SIZE_INCREMENT;
      EMAIL_BUFFER = (char *)realloc(EMAIL_BUFFER,EMAIL_BUFFER_SIZE*sizeof(char));
    }

    /* Read a line from the file and store it at the end of the email
     * buffer. We will move it to LAST_LINE if it turns out to
     * be the start of the next email. */
    start_of_new_line = EMAIL_BUFFER+LENGTH_OF_EMAIL;
    fgets(start_of_new_line,1024,FILE_HANDLE);
    number_characters_read = strlen(start_of_new_line);
    LENGTH_OF_EMAIL += number_characters_read;

    /* If we hit the end of the file, return the email */
    if (feof(FILE_HANDLE))
    {
#if DEBUG==1
      fprintf(stderr,"hit eof\n");
#endif

      *email = EMAIL_BUFFER;
      return 1;
    }

    if (start_of_new_line[number_characters_read-1] == '\n')
      LINE_NUMBER++;

    /* See if the line is the start of a new email. Try to avoid
     * unescaped "From my mother" lines by checking that the last 4
     * characters are numbers. */
    if(start_of_new_line[-1] == '\n' && start_of_new_line[0] == 'F' &&
       start_of_new_line[1]  == 'r'  && start_of_new_line[2] == 'o' &&
       start_of_new_line[3]  == 'm'  && start_of_new_line[4] == ' ' &&
       isdigit(start_of_new_line[number_characters_read-2]) &&
       isdigit(start_of_new_line[number_characters_read-3]) &&
       isdigit(start_of_new_line[number_characters_read-4]) &&
       isdigit(start_of_new_line[number_characters_read-5]))
    {
      /* If the email doesn't end with an included message declaration,
       * then the From line must be the start of a new email. */
      if(!_ends_with_include(start_of_new_line))
      {
#if DEBUG==1
  fprintf(stderr,"found next email\n");
#endif
        strncpy(LAST_LINE,start_of_new_line,1024);
        LENGTH_OF_EMAIL -= strlen(start_of_new_line);
        *start_of_new_line = '\0';
        LINE_NUMBER--;

        *email = EMAIL_BUFFER;
        return 1;
      }
    }
  }
}

void reset_file(FILE *infile)
{
#if DEBUG==1 || DEBUG==2 || DEBUG==3
  fprintf(stderr,"resetting line number\n");
#endif

  /* Initialize the email buffer if it has not been initialized already. */
  if (EMAIL_BUFFER == NULL)
  {
    EMAIL_BUFFER_SIZE = EMAIL_BUFFER_SIZE_INCREMENT;
    EMAIL_BUFFER = (char *)malloc((EMAIL_BUFFER_SIZE)*sizeof(char));
  }

  FILE_HANDLE = infile;
  LINE_NUMBER = 0;
}

int _ends_with_include(char *email_boundary)
{
  char *location;
  int newlines;

  location = strstr(email_boundary-255,"\n----- Begin Included Message -----\n");

  if (location == 0)
    return 0;

  /* Find the last newline after the begin included message */
  newlines = strspn(location + 35,"\n");

  if(location+35+newlines == email_boundary)
    return 1;

  location = strstr(email_boundary-255,"\n-----Original Message-----\n");

  if (location == 0)
    return 0;

  /* Find the last newline after the begin included message */
  newlines = strspn(location + 27,"\n");

  if(location+27+newlines == email_boundary)
    return 1;
  else
    return 0;
}
