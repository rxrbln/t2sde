/* Bash (wallclock-time) profiler. Written by Clifford Wolf.
 *
 * Usage:
 *	gcc -shared -fPIC -Wall -o bash_profiler.so bash_profiler.c
 *	enable -f ./bash_profiler.so bprof
 *
 *	bprof a start; idle_in_a; brof a stop
 *	bprof b start; idle_in_b; brof b stop
 *	bprof a start; idle_in_a; brof a stop
 *
 *	bprof all print
 *	enable -d bprof
 */


/* Some declarations copied from bash-2.05b headers */

#include <stdint.h>

typedef struct word_desc {
	char *word;
	int flags;
} WORD_DESC;

typedef struct word_list {
	struct word_list *next;
	WORD_DESC *word;
} WORD_LIST;

typedef int sh_builtin_func_t(WORD_LIST *);

#define BUILTIN_ENABLED 0x1

struct builtin {
	char *name;
	sh_builtin_func_t *function;
	int flags;
	char * const *long_doc;
	const char *short_doc;
	char *handle;
};


/* my hellobash builtin */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/time.h>

long long mytime()
{
	struct timeval tv;
	gettimeofday(&tv, 0);
	return tv.tv_sec*1000 + tv.tv_usec/1000;
}

struct bprofent;

struct bprofent {
	char *id;
	int count;
	long long tv_sum, tv_start;
	struct bprofent *next;
};

struct bprofent *bprofent_list = 0;

int bprof_builtin(WORD_LIST *list)
{
	struct bprofent *this = bprofent_list;
	char *mode, *name;

	if ( !list || !list->next ) {
		fprintf(stderr, "Usage: bprof {id|all} {start|stop|print}\n");
		return 1;
	}

	name = list->word->word;
	mode = list->next->word->word;

	if ( !strcmp(mode, "print") && !strcmp(name, "all") ) {
		while ( this ) {
			printf("%7d %7Ld %10.3f %s\n", this->count, this->tv_sum,
					(float)this->tv_sum/this->count, this->id);
			this = this->next;
		}
		return 0;
	}

	while ( this ) {
		if ( !strcmp(this->id, name) ) break;
		this = this->next;
	}

	if ( !this ) {
		this = calloc(1, sizeof(struct bprofent));
		this->id = strdup(name);
		this->next = bprofent_list;
		bprofent_list = this;
	}

	if ( !strcmp(mode, "start") ) {
		this->tv_start = mytime();
	} else if ( !strcmp(mode, "stop") ) {
		this->tv_sum += mytime() - this->tv_start;
		this->count++;
	} else if ( !strcmp(mode, "print") ) {
		printf("%7d %7Ld %10.3f %s\n", this->count, this->tv_sum,
				(float)this->tv_sum/this->count, this->id);
	}

	return 0;
}

char *bprof_doc[] = {
	"bash profiler",
	0
};

struct builtin bprof_struct = {
	"bprof",
	&bprof_builtin,
	BUILTIN_ENABLED,
	bprof_doc,
	"bash profiler",
	0
};

