FROM alpine/ansible:2.18.1

# add openssh server
RUN apk add openssh

# add openjdk 21
RUN apk add openjdk21
# add git
RUN apk add git
# add bash
RUN apk add bash
# add python3
RUN apk add python3
# add pip
RUN apk add py3-pip

# RUN apk update && \
#     apk add --no-cache \
#         openssh \
#         openjdk21 \
#         git \
#         bash \
#         python3 \
#         py3-pip \
#         ansible \
#         ansible-lint