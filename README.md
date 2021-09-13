Kaleidoscope in Swift
=====================

Installation
------------

- Download this repo.

    ```shell
    git clone https://github.com/kkshinkai/kaleidoscope-swift.git
    ```

- Run it!

    ```shell
    cd /path/to/kaleidoscope-swift
    swift run
    ```

> ⚠️ I highly recommend you **do not use  Xcode** to open the REPL in this
> project. Xcode's inner terminal can't handle the parentheses paired by the
> editor. You may meet weird errors because of this. In addition, Xcode may not
> be able to read the files in the search path correctly, which can cause
> LLVMSwift to fail to compile.
>
> If you insist on using Xcode, please at least set "Product → Scheme → Edit
> Scheme → Options → Console" to "Use Terminal" instead of "Use Xcode" for all
> targets before you start and good luck.