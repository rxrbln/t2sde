/* Bash (wallclock-time) profiler. Written by Clifford Wolf.
 *
 * Usage:
 *	gcc -shared -fPIC -Wall -o config_helper.so config_helper.c
 *	enable -f ./config_helper.so cfghlp
 *
 * Note: This builtin trusts that it is called correctly. If it is
 * called the wrong way, segfaults etc. are possible.
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

struct package;
struct package {
	int status;
	int stages[10];
	char *prio;
	char *repository;
	char *name;
	char *alias;
	char *version;
	char *prefix;
	char *flags;
	struct package *next;
};

struct package *package_list = 0;

int read_pkg_list(const char *file) {
	FILE *f = fopen(file, "r");
	struct package *pkg = package_list;
	struct package *pkg_tmp;
	char line[1024], *tok;
	int i;

	while (pkg) {
		free(pkg->prio);
		free(pkg->repository);
		free(pkg->name);
		free(pkg->alias);
		free(pkg->version);
		free(pkg->prefix);
		free(pkg->flags);
		pkg = (pkg_tmp=pkg)->next;
		free(pkg_tmp);
	}

	pkg = package_list = 0;

	while (fgets(line, 1024, f)) {
		pkg_tmp = calloc(1, sizeof(struct package));

		tok = strtok(line, " ");
		pkg_tmp->status = line[0] == 'X';

		tok = strtok(0, " ");
		for (i=0; i<10; i++)
			pkg_tmp->stages[i] = tok[i] != '-';

		tok = strtok(0, " ");
		pkg_tmp->prio = strdup(tok);

		tok = strtok(0, " ");
		pkg_tmp->repository = strdup(tok);

		tok = strtok(0, " ");
		pkg_tmp->name = strdup(tok);
		pkg_tmp->alias = strdup(tok);

		tok = strtok(0, " ");
		pkg_tmp->version = strdup(tok);

		tok = strtok(0, " ");
		pkg_tmp->prefix = strdup(tok);

		tok = strtok(0, "\n");
		tok[strlen(tok)-2] = 0;
		pkg_tmp->flags = strdup(tok);

		if ( !package_list )
			pkg=package_list=pkg_tmp;
		else
			pkg=pkg->next=pkg_tmp;
	}

	fclose(f);

	return 0;
}

int write_pkg_list(const char *file) {
	FILE *f = fopen(file, "w");
	struct package *pkg = package_list;
	int i;

	while (pkg) {
		fprintf(f, "%c ", pkg->status ? 'X' : 'O');
		for (i=0; i<10; i++)
			fprintf(f, "%c", pkg->stages[i] ? '0'+i : '-');
		fprintf(f, " %s %s %s", pkg->prio, pkg->repository, pkg->name);
		if (strcmp(pkg->name, pkg->alias))
			fprintf(f, "=%s", pkg->alias);
		fprintf(f, " %s %s %s 0\n", pkg->version, pkg->prefix, pkg->flags);
		pkg = pkg->next;
	}

	fclose(f);
	return 0;
}

int pkgcheck(const char *pattern, const char *mode)
{
	struct package *pkg = package_list;
	char *pattern_copy = strdup(pattern);
	char *pat_list[10];
	int i;

	pat_list[0] = strtok(pattern_copy, "|");
	for (i=1; i<10; i++)
		if ( !(pat_list[1] = strtok(0, "|")) ) break;

	while (pkg) {
		for (i=0; i<10 && pat_list[i]; i++)
			if (!strcmp(pkg->alias, pat_list[i]))
				switch (mode[0]) {
					case 'X':
						if (pkg->status) goto found;
						break;
					case 'O':
						if (!pkg->status) goto found;
						break;
					case '.':
						goto found;
				}
		pkg = pkg->next;
	}

	free(pattern_copy);
	return 1;

found:
	free(pattern_copy);
	return 0;
}

int pkgswitch(int mode, char **args)
{
	struct package *pkg = package_list;
	struct package *last_pkg = 0;
	struct package *pkg_tmp = 0;
	int i;

	while (pkg) {
		for (i=0; *args[i]; i++)
			if (!strcmp(pkg->alias, args[i])) {
				if ( !mode ) {
					*(last_pkg ? &(last_pkg->next) : &package_list) = pkg->next;
					free(pkg->prio);
					free(pkg->repository);
					free(pkg->name);
					free(pkg->alias);
					free(pkg->version);
					free(pkg->prefix);
					free(pkg->flags);
					pkg = (pkg_tmp=pkg)->next;
					free(pkg_tmp);
					continue;
				} else
					pkg->status = mode == 1;
			}
		pkg = (last_pkg=pkg)->next;
	}

	return 0;
}

int cfghlp_builtin(WORD_LIST *list)
{
	char *args[10];
	int i;

	for (i=0; i<10 && list; i++) {
		args[i] = list->word->word;
		list = list->next;
	}
	for (; i<10 && list; i++)
		args[i] = "";

	if (!strcmp(args[0],"pkg_in"))
		return read_pkg_list(args[1]);

	if (!strcmp(args[0],"pkg_out"))
		return write_pkg_list(args[1]);

	if (!strcmp(args[0],"pkgcheck"))
		return pkgcheck(args[1], args[2]);

	if (!strcmp(args[0],"pkgremove"))
		return pkgswitch(0, args+1);

	if (!strcmp(args[0],"pkgenable"))
		return pkgswitch(1, args+1);

	if (!strcmp(args[0],"pkgdisable"))
		return pkgswitch(2, args+1);

	return 1;
}

char *cfghlp_doc[] = {
	"ROCK Linux Config Helper",
	0
};

struct builtin cfghlp_struct = {
	"cfghlp",
	&cfghlp_builtin,
	BUILTIN_ENABLED,
	cfghlp_doc,
	"ROCK Linux Config Helper",
	0
};

