Red/System [
	Title:	"Windows fonts management"
	Author: "Nenad Rakocevic"
	File: 	%font.reds
	Tabs: 	4
	Rights: "Copyright (C) 2015 Nenad Rakocevic. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

set-font: func [
	hWnd   [handle!]
	face   [red-object!]
	values [red-value!]
	/local
		font [red-object!]
		int	 [red-integer!]
		value	[red-value!]
		bool	[red-logic!]
		word	[red-word!]
		str		[red-string!]
		height	[integer!]
		angle	[integer!]
		quality [integer!]
		name	[c-string!]
		italic? [logic!]
		under?	[logic!]
		strike? [logic!]
		hFont	[handle!]
][
	font: as red-object! values + FACE_OBJ_FONT
	if TYPE_OF(font) <> TYPE_OBJECT [
		SendMessage hWnd WM_SETFONT as-integer default-font 1
		exit
	]
	
	italic?: no
	under?:  no
	strike?: no
	
	values: get-values font/ctx
	
	int: as red-integer! values + FONT_OBJ_SIZE
	height: either TYPE_OF(int) = TYPE_INTEGER [int/value][0]
	
	int: as red-integer! values + FONT_OBJ_ANGLE
	angle: either TYPE_OF(int) = TYPE_INTEGER [int/value * 10][0]	;-- in tenth of degrees
	
	value: values + FONT_OBJ_ANTI-ALIAS?
	switch TYPE_OF(value) [
		TYPE_LOGIC [
			bool: as red-logic! value
			quality: either bool/value [4][0]			;-- ANTIALIASED_QUALITY
		]
		TYPE_WORD [
			word: as red-word! value
			either ClearType = symbol/resolve word/symbol [
				quality: 5								;-- CLEARTYPE_QUALITY
			][
				quality: 0
				;fire error ?
			]
		]
		default [quality: 0]							;-- DEFAULT_QUALITY
	]
	
	str: as red-string! values + FONT_OBJ_NAME
	name: either TYPE_OF(str) = TYPE_STRING [unicode/to-utf16 str][null]
	
	hFont: CreateFont
		height
		0												;-- nWidth
		0												;-- nEscapement
		angle											;-- nOrientation
		0 ;weight
		as-integer italic?
		as-integer under?
		as-integer strike?
		1												;-- DEFAULT_CHARSET
		0												;-- OUT_DEFAULT_PRECIS
		0												;-- CLIP_DEFAULT_PRECIS
		quality
		0												;-- DEFAULT_PITCH
		name
	
	SendMessage hWnd WM_SETFONT as-integer hFont 1
]
