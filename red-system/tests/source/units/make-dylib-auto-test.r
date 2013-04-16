REBOL [
  Title:   "Generates Red/System dylib tests"
	Author:  "Peter W A Wood"
	File: 	 %make-dylib-auto-test.r
	Version: 0.1.0
	Rights:  "Copyright (C) 2012-2013 Peter W A Wood. All rights reserved."
	License: "BSD-3 - https://github.com/dockimbel/Red/blob/origin/BSD-3-License.txt"
]

;;; Initialisations
make-dir %auto-tests/
file-out: %auto-tests/dylib-auto-test.reds

;; test script header including the lib definitions
test-script-header: {
Red/System [
	Title:   "Red/System auto-generated float! tests"
	Author:  "Peter W A Wood"
	File: 	 %dylib-auto-test.reds
	License: "BSD-3 - https://github.com/dockimbel/Red/blob/origin/BSD-3-License.txt"
]

;;	This file is generated by make-dylib-auto-test.r
;;	Do not edit this file directly.

;make-length:###make-length### 

#include %../../../../../quick-test/quick-test.reds

~~~start-file~~~ "Auto-generated dylib tests"
}

;; the libs
libs: {

#import [
  "***test-dll1***" cdecl [
    dll1-add-one: "add-one" [
      i       [integer!]
      return: [integer!]
    ]
  ]
]

}

;; the tests
tests: {
===start-group=== "Simple function calls"

	--test-- "dllf1"
	--assert 2 = dll1-add-one 1
  
	--test-- "dllf2"    
	--assert -2147483647 = dll1-add-one -2147483648
  
	--test-- "dllf3"
	--assert -2147483648 = dll1-add-one 2147483647

===end-group===
}

;; test script footer
test-script-footer: {
~~~end-file~~~
}

;; dll target
dll-target: switch/default fourth system/version [
	3 ["WinDLL"]
][
	none
]

;;; Processing

;; update the test header with the current make file length and write it
replace test-script-header "###make-length###" length? read %make-dylib-auto-test.r
write file-out test-script-header

;; update the #include statements, write them and the tests
if dll-target [
	dll1-name: --compile-dll %source/units/test-dll1.reds dll-target
	replace libs "***test-dll1***" dll1-name
	write/append file-out libs
	write/append file-out tests	
]

;; write the test footer
write/append file-out test-script-footer

