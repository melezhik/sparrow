bash "markdown2pod README.md > README.pod";
bash 'perl -n -e "print unless /__END__/ .. eof()" lib/Sparrow.pm > /tmp/Sparrow.pm';
bash '(echo __END__; echo; echo; ) >> /tmp/Sparrow.pm';
bash 'cat README.pod >> /tmp/Sparrow.pm';
