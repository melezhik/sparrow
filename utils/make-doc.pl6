bash "rm -rf README.pod";
bash "markdown2pod README.md > README.pod";
bash 'perl -n -e "print unless /__END__/ .. eof()" lib/Sparrow.pm > /tmp/Sparrow.pm';
bash '(echo __END__; echo; echo; ) >> /tmp/Sparrow.pm';
bash 'cat README.pod >> /tmp/Sparrow.pm';
bash 'diff -u lib/Sparrow.pm /tmp/Sparrow.pm; echo';
bash 'cp /tmp/Sparrow.pm lib/Sparrow.pm';
bash "rm -rf README.pod";

