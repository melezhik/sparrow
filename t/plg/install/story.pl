if ($ENV{run_slow_test}){
    print `sparrow plg search foo-test`;
    print `sparrow plg remove foo-test`;
    print `sparrow plg install foo-test`;
}else{
    print "OK\n";
    print "run_slow_test not set, so skip this test\n";
}

