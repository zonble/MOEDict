# 3 Piggies (三隻小豬) for iOS

* Weizhong Yang a.k.a *zonble*
* zonble at gmail.com

## Introduction

**3 Piggies** is a stand-alone iOS app which lets you search within
the Chinese dictionary, that comes from Ministry of Education (MOE) of
Taiwan, without Internet connection.

The project adopts the database file generated from the works of the
3du.tw project. 3du.tw is a project built by a group of hackers and
information activists who aim to provide better and richer online
resources for education. One of the goals of 3du.tw is to make the MOE
dictionary much more easier to be accessed.

You may see there are also many applications based on 3du.tw's work,
using various technology for various platform. Among them, the project
is implemented with pure Objective-C language and standard Cocoa Touch
framework,

For further information, please visit [3du.tw](http://3du.tw).

## How to build the project?

* Clone the project.
* Run `sh get_db.sh` to download database file.
* Run `git submodule init; git submodule update;` to update submodules.
* Launch Xcode. Open `MOEDict.xcodeproj` located in the project folder.
* Build and run.
* Done!
