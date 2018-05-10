#include <syslog.h>
#include <unistd.h>
int main(void) {
    openlog("WARN", LOG_PID|LOG_CONS, LOG_USER);
    syslog(LOG_EMERG, "Dangerous !!!\n");
    closelog();
    return 0;
}
