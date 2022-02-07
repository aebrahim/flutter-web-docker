FROM dart:2.16.0-sdk
ARG FLUTTER_VERSION=2.10.0

RUN git clone https://github.com/flutter/flutter.git /usr/lib/flutter \
    -b ${FLUTTER_VERSION} --depth 1
# Trick flutter into using container built-in dart version instead of
# re-downloading the same version again.
RUN mkdir /usr/lib/flutter/bin/cache \
    && mv ${DART_SDK} /usr/lib/flutter/bin/cache/dart-sdk
RUN cp /usr/lib/flutter/bin/internal/engine.version \
    /usr/lib/flutter/bin/cache/engine-dart-sdk.stamp
ENV PATH=${PATH}:/usr/lib/flutter/bin
ENV DART_SDK=/usr/lib/flutter/bin/cache/dart-sdk
# First-run for dart and flutter binaries.
RUN /usr/lib/flutter/bin/cache/dart-sdk/bin/dart --disable-analytics \
    && rm ~/.dart/README.txt dart_setup.log
RUN flutter config --no-analytics --no-enable-android \
    && flutter precache --web \
    && rm -r ~/.pub-cache/_temp
RUN sed -i 's/"is-bot": false/"is-bot": true/g' ~/.config/flutter/tool_state

# To copy flutter functionality into another container, the directories needed
# from this one are (copied ACL'ed to the user from the other container)
# /usr/lib/flutter
# ~/.config
# ~/.dart
# ~/.pub-cache
# Additionally, the file ~/.flutter
