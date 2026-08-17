/* Lab 02 grader engine.
   Compiles a problem's source, feeds it inputs, and checks the FINAL
   non-empty output line against the contract. Public vectors are printed
   in the lab sheet; random vectors are drawn fresh from each problem's
   GIVEN on every run.
   Usage:  ./grader e1 | e2 | e3 | e4 | e5        exit code = failed vectors
   (Reading this source tells you the formulas — which the specs already
   state. What it cannot give you is tomorrow's random numbers.)          */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#define NPUB 3
#define NRAND 3
static int use_timeout = -1;

static void last_line(const char *path, char *buf, int n) {
    FILE *f = fopen(path, "r"); buf[0] = 0;
    if (!f) return;
    char line[512];
    while (fgets(line, sizeof line, f)) {
        int L = (int)strlen(line);
        while (L > 0 && (line[L-1]=='\n' || line[L-1]=='\r' || line[L-1]==' ')) line[--L]=0;
        if (L > 0) { strncpy(buf, line, n-1); buf[n-1]=0; }
    }
    fclose(f);
}

static int run_one(const char *prog, const char *input, const char *expected, const char *label) {
    FILE *f = fopen(".gin", "w"); if (!f) { printf("  grader: cannot write .gin\n"); return 1; }
    fputs(input, f); fputc('\n', f); fclose(f);
    char cmd[512];
    if (use_timeout)
        snprintf(cmd, sizeof cmd, "timeout 5 ./%s < .gin > .gout 2>&1", prog);
    else
        snprintf(cmd, sizeof cmd, "./%s < .gin > .gout 2>&1", prog);
    int rc = system(cmd);
    if (use_timeout && rc != 0 && (rc == 124*256 || rc/256 == 124)) {
        printf("  TIMEOUT  [%s] input: %s  (5s — is there an accidental infinite wait?)\n", label, input);
        return 1;
    }
    char got[512]; last_line(".gout", got, sizeof got);
    size_t gl = strlen(got), el = strlen(expected);
    /* contract: the final line must END WITH the expected text
       (an unterminated prompt may legally share the line) */
    if (gl >= el && strcmp(got + gl - el, expected) == 0) {
        printf("  PASS     [%s] input: %s\n", label, input);
        return 0;
    }
    printf("  WRONG    [%s] input: %s\n           your final line: \"%s\"\n           expected exactly: \"%s\"\n",
           label, input, got, expected);
    return 1;
}

static int source_contains(const char *file, const char *needle) {
    FILE *f = fopen(file, "r"); if (!f) return 0;
    char buf[8192]; size_t n = fread(buf, 1, sizeof buf - 1, f); buf[n] = 0; fclose(f);
    return strstr(buf, needle) != NULL;
}

/* ---------------- reference formulas (the specs state these anyway) --- */
static void gen_e1(char *in, char *exp) {
    int a = rand()%100+1, b = rand()%100+1, c = rand()%100+1;
    sprintf(in, "%d %d %d", a, b, c);
    sprintf(exp, "sum=%d avg=%.2f", a+b+c, (a+b+c)/3.0);
}
static void gen_e2(char *in, char *exp) {
    float r = (float)((rand()%195+5)/10.0);     /* 0.5 .. 19.9, one decimal */
    sprintf(in, "%.1f", (double)r);
    /* reference mirrors the spec: radius stored in a float */
    sprintf(exp, "area=%.3f circ=%.3f", 3.14159*r*r, 2*3.14159*r);
}
static void gen_e3(char *in, char *exp) {
    int a = rand()%100+1, b = rand()%99+1;
    sprintf(in, "%d %d", a, b);
    sprintf(exp, "q=%d r=%d qf=%.2f", a/b, a%b, (double)a/b);
}
static void gen_e4(char *in, char *exp) {
    int s = rand()%86400;
    sprintf(in, "%d", s);
    sprintf(exp, "%d h %d m %d s", s/3600, (s%3600)/60, s%60);
}
static void gen_e5(char *in, char *exp) {
    int c = rand()%92+33;                        /* '!' .. '|' printable */
    sprintf(in, "%c", (char)c);
    sprintf(exp, "code=%d next=%c", c, (char)(c+1));
}

struct problem {
    const char *name;
    const char *pub_in[NPUB]; const char *pub_exp[NPUB];
    void (*gen)(char*, char*);
    const char *needs;          /* structural requirement, or NULL */
    const char *needs_msg;
};
static struct problem P[] = {
 {"e1", {"12 7 9","1 1 1","100 100 100"},
        {"sum=28 avg=9.33","sum=3 avg=1.00","sum=300 avg=100.00"},
        gen_e1, NULL, NULL},
 {"e2", {"2.0","0.5","10.0"},
        {"area=12.566 circ=12.566","area=0.785 circ=3.142","area=314.159 circ=62.832"},
        gen_e2, "PI", "spec requires a named constant PI (use #define PI 3.14159 or const)"},
 {"e3", {"17 5","100 7","9 9"},
        {"q=3 r=2 qf=3.40","q=14 r=2 qf=14.29","q=1 r=0 qf=1.00"},
        gen_e3, NULL, NULL},
 {"e4", {"7384","0","86399"},
        {"2 h 3 m 4 s","0 h 0 m 0 s","23 h 59 m 59 s"},
        gen_e4, NULL, NULL},
 {"e5", {"A","z","4"},
        {"code=65 next=B","code=122 next={","code=52 next=5"},
        gen_e5, NULL, NULL},
};

int main(int argc, char **argv) {
    if (argc != 2) { printf("usage: ./grader e1|e2|e3|e4|e5\n"); return 2; }
    use_timeout = (system("command -v timeout >/dev/null 2>&1") == 0);
    srand((unsigned)time(NULL) ^ (unsigned)getpid());

    struct problem *p = NULL;
    for (unsigned i = 0; i < sizeof P / sizeof P[0]; i++)
        if (strcmp(argv[1], P[i].name) == 0) p = &P[i];
    if (!p) { printf("grader: unknown problem %s\n", argv[1]); return 2; }

    char src[32]; snprintf(src, sizeof src, "%s.c", p->name);
    FILE *f = fopen(src, "r");
    if (!f) { printf("  MISSING  %s not found — are you inside your workspace? (pwd!)\n", src); return 1; }
    fclose(f);

    char cmd[256];
    snprintf(cmd, sizeof cmd, "gcc %s -o %s 2> .gcc.err", src, p->name);
    if (system(cmd) != 0) {
        printf("  COMPILE-FAIL  %s — the compiler said:\n", src);
        snprintf(cmd, sizeof cmd, "head -5 .gcc.err | sed 's/^/           /'");
        system(cmd);
        return 1;
    }
    if (p->needs && !source_contains(src, p->needs)) {
        printf("  STRUCT-FAIL  %s: %s\n", src, p->needs_msg);
        return 1;
    }

    int failed = 0;
    for (int i = 0; i < NPUB; i++)
        failed += run_one(p->name, p->pub_in[i], p->pub_exp[i], "public");
    for (int i = 0; i < NRAND; i++) {
        char in[128], exp[256];
        p->gen(in, exp);
        failed += run_one(p->name, in, exp, "random");
    }
    return failed;
}
