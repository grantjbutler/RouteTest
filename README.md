RouteTest
=========

RouteTest is a sample app that demonstrates how to get information about an AirPlay device after it's been connected to. I built this in roughly 20 minutes in response to [this StackOverflow question](http://stackoverflow.com/questions/19236962/is-there-an-api-for-retrieving-the-apple-tvs-version) asking how the Netflix app is able to prompt about an AppleTV being out of date. This is all possible thanks to [nto](http://github.com/nto) detailing the [AirPlay spec](http://nto.github.io/AirPlay.html#servicediscovery-airplayservice). Thanks, man.

Note that this is pretty hacky, as we rely on the name of the port to be the same as the name of the AirPlay device. If Apple changes either of those things, this breaks. Alternatively, you can compare the `deviceid` field of the TXT record of the device to the UID of the port, which is the `deviceid` with the string "-airplay" appended to it, as far as I can tell. Again, if that format is changed by Apple, it would break, but at least it's another potential way of checking.
