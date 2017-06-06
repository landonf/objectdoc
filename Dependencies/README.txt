GRMustache
    Description:
      Mustache templating engine.

    Version:
      6.8.2 downloaded from https://github.com/groue/GRMustache/releases/tag/v6.8.2

    License:
      MIT

LLVM
    Description:
      LLVM and Clang sources.

    Version:
      4.0 downloaded from http://releases.llvm.org/download.html

    License:
      "UIUC" BSD-Style license

    Modifications:
      - Added clang_Cursor_isImplicit()
      - Added clang_Cursor_getObjCPropertyGetter()
      - Added clang_Cursor_getObjCPropertySetter()
      - Added clang_Type_getNullability()
      - Added clang_Type_removeOuterNullability()
