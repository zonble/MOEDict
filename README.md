# MOE Dict for iOS

* Weizhong Yang a.k.a *zonble*
* zonble at gmail.com

## Introduction

**MOE Dict** is a stand-alone iOS app which lets you search within the
Chinese dictionary, that comes from Ministry of Education (MOE) of
Taiwan, without Internet connection.

The project adopts the database file generated from the works of the
3du.tw project. 3du.tw is a project built by a group of hackers and
information activists who aim to provide better and richer online
resources for education. One of the goals of 3du.tw is to make the MOE
dictionary much more easier to be accessed.

You may see there are also many applications based on 3du.tw's work,
using various technology for various platform. Among them, the project
is implemented with pure Objective-C language and Cocoa Touch
framework,

For further information, please visit [3du.tw](http://3du.tw).

## How to build the project?

* Run `sh get_db.sh` to download database file.
* Run `git submodule init; git submodule update;` to update submodules.
* Launch Xcode. Open 'MOEDict.xcodeproj'.
* Build and run.
* Done!
