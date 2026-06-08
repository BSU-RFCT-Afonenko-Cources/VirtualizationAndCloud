#define _GNU_SOURCE
#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

static volatile sig_atomic_t running = 1;
static unsigned long long counter = 0;
static char session_id[80];
static const char *state_dir;
static int journal_fd = -1;

static void stop_running(int sig) { (void)sig; running = 0; }

static void path_join(char *out, size_t size, const char *name) {
    snprintf(out, size, "%s/%s", state_dir, name);
}

static int write_all(int fd, const char *buf, size_t len) {
    while (len > 0) {
        ssize_t n = write(fd, buf, len);
        if (n < 0 && errno == EINTR) continue;
        if (n <= 0) return -1;
        buf += n;
        len -= (size_t)n;
    }
    return 0;
}

static void write_atomic(const char *name, const char *text) {
    char path[512], tmp[520];
    path_join(path, sizeof(path), name);
    snprintf(tmp, sizeof(tmp), "%s.tmp", path);
    int fd = open(tmp, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd < 0) return;
    if (write_all(fd, text, strlen(text)) != 0) { close(fd); unlink(tmp); return; }
    (void)fsync(fd);
    close(fd);
    (void)rename(tmp, path);
}

static unsigned long read_starts(void) {
    char path[512], buf[64] = {0};
    path_join(path, sizeof(path), "starts");
    int fd = open(path, O_RDONLY);
    if (fd < 0) return 0;
    ssize_t n = read(fd, buf, sizeof(buf) - 1);
    close(fd);
    return n > 0 ? strtoul(buf, NULL, 10) : 0;
}

static void publish(void) {
    char text[512];
    snprintf(text, sizeof(text),
             "{\"counter\":%llu,\"session\":\"%s\",\"pid\":%ld,\"starts\":%lu}\n",
             counter, session_id, (long)getpid(), read_starts());
    write_atomic("state.json", text);
    if (journal_fd >= 0) {
        dprintf(journal_fd, "%llu %s %ld\n", counter, session_id, (long)getpid());
        fsync(journal_fd);
    }
}

static int listen_http(int port) {
    int fd = socket(AF_INET, SOCK_STREAM | SOCK_NONBLOCK, 0);
    if (fd < 0) return -1;
    int one = 1;
    setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one));
    struct sockaddr_in addr = {.sin_family = AF_INET, .sin_addr.s_addr = htonl(INADDR_ANY), .sin_port = htons((uint16_t)port)};
    if (bind(fd, (struct sockaddr *)&addr, sizeof(addr)) != 0 || listen(fd, 16) != 0) {
        close(fd); return -1;
    }
    return fd;
}

static void serve_once(int server_fd) {
    if (server_fd < 0) return;
    int client = accept4(server_fd, NULL, NULL, SOCK_NONBLOCK);
    if (client < 0) return;
    char request[512];
    ssize_t request_len = read(client, request, sizeof(request));
    (void)request_len;
    char body[512], response[1024];
    int body_len = snprintf(body, sizeof(body),
        "{\"counter\":%llu,\"session\":\"%s\",\"pid\":%ld,\"starts\":%lu}\n",
        counter, session_id, (long)getpid(), read_starts());
    int n = snprintf(response, sizeof(response),
        "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: %d\r\nConnection: close\r\n\r\n%s",
        body_len, body);
    (void)write_all(client, response, (size_t)n);
    close(client);
}

int main(int argc, char **argv) {
    state_dir = argc > 1 ? argv[1] : "/state";
    int port = argc > 2 ? atoi(argv[2]) : 18080;
    mkdir(state_dir, 0755);
    signal(SIGTERM, stop_running);
    signal(SIGINT, stop_running);
    signal(SIGPIPE, SIG_IGN);

    struct timespec now;
    clock_gettime(CLOCK_REALTIME, &now);
    snprintf(session_id, sizeof(session_id), "%ld-%ld-%ld", (long)now.tv_sec, (long)now.tv_nsec, (long)getpid());

    unsigned long starts = read_starts() + 1;
    char starts_text[64];
    snprintf(starts_text, sizeof(starts_text), "%lu\n", starts);
    write_atomic("starts", starts_text);
    write_atomic("session", session_id);

    char journal_path[512];
    path_join(journal_path, sizeof(journal_path), "journal.log");
    journal_fd = open(journal_path, O_WRONLY | O_CREAT | O_APPEND, 0644);
    int server_fd = listen_http(port);

    while (running) {
        counter++;
        publish();
        for (int i = 0; i < 10 && running; i++) {
            serve_once(server_fd);
            usleep(100000);
        }
    }
    publish();
    if (server_fd >= 0) close(server_fd);
    if (journal_fd >= 0) close(journal_fd);
    return 0;
}
