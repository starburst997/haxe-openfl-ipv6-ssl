# haxe-openfl-ipv6-ssl
Testing IPV6 / SSL connectivity

Test URLs (both http and https) using various methods.

Includes 3 projects, identical except for a few minor edit on some std haxe classes.

Test under native target:
```
openfl test windows
```

Also includes a CA cert to fix IOS SSL issue.

Http, Http "async", [Akifox](https://github.com/yupswing/akifox-asynchttp) and URLLoader

To test IPV6 you can setup a network using [Mac Internet Sharing](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/NetworkingOverview/UnderstandingandPreparingfortheIPv6Transition/UnderstandingandPreparingfortheIPv6Transition.html#//apple_ref/doc/uid/TP40010220-CH213-SW16)

My results are as follow: