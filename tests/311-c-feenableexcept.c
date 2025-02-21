#define _GNU_SOURCE
#include <fenv.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void action(int signo, siginfo_t * sip, void *unused) {
    printf("signal: '%s'\n", strsignal(signo));   
    exit(0);
}

int main(void) {
    struct sigaction act = {};
    act.sa_sigaction = action;
    act.sa_flags = SA_SIGINFO;
    sigaction(SIGFPE, &act, NULL);

    feenableexcept(FE_INVALID | FE_DIVBYZERO /*| FE_OVERFLOW  | FE_UNDERFLOW*/);

    float a = 1., b = 0.;
    float c = a/b;
    return (int)c;
}
