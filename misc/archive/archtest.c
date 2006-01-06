#include <stdio.h>

char * isbigendian () {
	/* Are we little or big endian?  From Harbison&Steele.  */
	union { long l; char c[sizeof (long)]; } u;
	u.l=1; return (u.c[0] == 1)?"no":"yes";
}
                    
int main() {
	printf("arch_sizeof_short=%d\n",sizeof(short));
	printf("arch_sizeof_int=%d\n",sizeof(int));
	printf("arch_sizeof_long=%d\n",sizeof(long));
	printf("arch_sizeof_long_long=%d\n",sizeof(long long));
	printf("arch_sizeof_char_p=%d\n",sizeof(char *));
	printf("arch_bigendian=%s\n",isbigendian());
	printf("arch_machine="); fflush(stdout); system("uname -m");
	system("echo arch_target=`uname -m -p | tr ' ' -`-linux");
	return 0;
}
