if ($ENV{run_slow_test}){
    print `sparrow plg search foo-generic`;
    print `sparrow plg remove foo-generic`;
    print `sparrow plg install foo-generic`;
}else{
    print "OK\n";
    print "run_slow_test not set, so skip this test\n";
}

