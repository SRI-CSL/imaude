#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <pthread.h>
#include <unistd.h>


static void chld_handler(int sig){
  /* not async safe but who cares. */
  fprintf(stderr, "The child died (%d)!\n", sig);
  exit(EXIT_FAILURE);
}

static char* maude_argv[] = {"maude", "-no-tecla", "-interactive", NULL};

typedef struct fdpipe_s {
  int from;
  int to;
} fdpipe_t;

#define BUFFSIZE  1024

static void *echo(void *arg){
  fdpipe_t p = *((fdpipe_t *)arg);
  char buff[BUFFSIZE];
  int bytesread;
  int byteswritten;
  while(1){
    if(p.from == 0){
      fprintf(stderr, "Listening to stdin\n");
    } else {
      fprintf(stderr, "Listening to Maude's %s\n", p.to == 1 ? "stdout" : "stderr");
      bytesread = read(p.from, buff, BUFFSIZE);
      if(bytesread == -1){ break; }
      byteswritten = write(p.to, buff, bytesread);
      if(bytesread != byteswritten){ break; }
    }
  }
  return NULL; 
}

int main(int argc, char** argv){
  int pin[2], pout[2], perr[2];
  
  if((argc != 2)  && (argc != 3)){
    fprintf(stderr, "Usage: %s <maude executable>  [maude module]\n", argv[0]);
    exit(EXIT_FAILURE);
  }

  /* install SIGCHLD handler */
  struct sigaction sigactsignal;
  sigactsignal.sa_handler = chld_handler;
  sigactsignal.sa_flags = SA_NOCLDSTOP;
  sigfillset(&sigactsignal.sa_mask);
  sigaction(SIGCHLD, &sigactsignal, NULL);


  char* maude_exe = argv[1];

  pipe(pin);
  pipe(perr);
  pipe(pout);

  /*it's time to fork */
  pid_t child = fork();

  if(child == 0){
    /* i'm destined to be maude */
    dup2(pin[0],  STDIN_FILENO);
    dup2(perr[1], STDERR_FILENO);
    dup2(pout[1], STDOUT_FILENO);

    close(pin[0]);
    close(perr[1]);
    close(pout[1]);

    /*  this hack is needed to convince maude to move its idea of where it is.  */
    unsetenv("PWD");

    if(execvp(maude_exe, maude_argv) == -1){
      perror("execvp of maude failed.");
      exit(EXIT_FAILURE);
    }

    /* end of child code */
  } else { 
    /* i'm the boss */
    pthread_t thread[2];

    close(pin[0]);
    close(perr[1]);
    close(pout[1]);

    int child_STDIN_FILENO = pin[1];

    fdpipe_t child_in =  { STDIN_FILENO, child_STDIN_FILENO};
    fdpipe_t child_out = { pout[0], STDOUT_FILENO};
    fdpipe_t child_err = { perr[0], STDERR_FILENO};

    
    if(pthread_create(&thread[0], NULL, echo, &child_out)){
      fprintf(stderr, "Could not spawn stdout echo thread\n");
      return -1;
    }
    if(pthread_create(&thread[1], NULL, echo, &child_err)){
      fprintf(stderr, "Could not spawn stdout echo thread\n");
      return -1;
    }

    sleep(30);

    if(argc == 3){
      int len = strlen(argv[2]);
      char* load_cmd = (char *)calloc(len + 10, sizeof(char));
      if(load_cmd == NULL){
	fprintf(stderr, "calloc failed of load_cmd\n");
        exit(EXIT_FAILURE);
      }

      fprintf(stdout, "%s\t:\tloading %s\n", argv[0], argv[2]); 
      
      snprintf(load_cmd, len + 10, "load %s\n", argv[2]);
      
      len = strlen(load_cmd);
      if(write(child_STDIN_FILENO, load_cmd, len) !=  len){
        fprintf(stderr, "write failed of \"%s\" command", load_cmd);
        /* forge on, notify registry, die calmly? */
        exit(EXIT_FAILURE);
      };
      
      fprintf(stdout, "%s\n", load_cmd);
      free(load_cmd);
      
    }
          
    while(1){

      echo(&child_in);
    }
  } /* end of boss code */

  exit(EXIT_SUCCESS);

}



