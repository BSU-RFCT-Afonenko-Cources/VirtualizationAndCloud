#include <stdio.h>
#include <unistd.h>
#include <sys/prctl.h>
#ifndef PR_GET_NO_NEW_PRIVS
#define PR_GET_NO_NEW_PRIVS 39
#endif
int main(void) {
    int nnp = prctl(PR_GET_NO_NEW_PRIVS, 0, 0, 0, 0);
    printf("ruid=%ld euid=%ld rgid=%ld egid=%ld no_new_privileges=%d\n",
           (long)getuid(), (long)geteuid(), (long)getgid(), (long)getegid(), nnp);
    return (geteuid() == 0) ? 0 : 2;
}
