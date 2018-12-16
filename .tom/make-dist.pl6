bash "perl Makefile.PL";
bash "make clean";
bash "perl Makefile.PL";
bash "make";
file-delete "MANIFEST";
bash "rm -rf *.tar.gz";
bash "make manifest";
bash "make dist";
