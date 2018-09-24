sub generator {

my $str = <<'HERE';

validator: use test; \
[ \
    -f sparrow_root."/plugins/public/foo-generic/sparrow.json" ,      \
     sparrow_root."/plugins/public/foo-generic/sparrow.json exists"   \
] \

begin:

    regexp: type\s+name
    :blank_line
    regexp: public\s+foo-generic

end:
HERE

return $ENV{run_slow_test} ? [ split /\n/, $str ] : [ "OK" , "run_slow_test not set, so skip this test" ];

}
