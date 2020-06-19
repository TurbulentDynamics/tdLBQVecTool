install:
        swift build -c release
        install .build/release/tdQVec /usr/local/bin/tdQVec
