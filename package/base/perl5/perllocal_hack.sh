
# Quick & Dirty hack for the perllocal problem
# .. to be included by packages which do 'share' the perllocal.pod file
#
eval `perl -V:archlib`
hook_add premake 1 "( cd $archlib; mv -v perllocal.pod perllocal.pod.sik || true; )"
hook_add postmake 9 "( cd $archlib; mv -v perllocal.pod $pkg.pod || true;
                       mv -v perllocal.pod.sik perllocal.pod || true; )"
var_append flist''del '|' "${archlib#/}/perllocal.pod"

