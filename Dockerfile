FROM almalinux:8

WORKDIR /var/www/shirasagi

RUN dnf -y install epel-release && \
    dnf -y install which procps-ng gcc make git openssl-devel openldap-devel && \
    dnf -y install ImageMagick ImageMagick-devel && \
    dnf clean all

# rvm
RUN gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
    \curl -sSL https://get.rvm.io | bash -s stable

# ruby
ENV MY_RUBY_VERSION=2.6.9
RUN /bin/bash -l -c "rvm install $MY_RUBY_VERSION && rvm use $MY_RUBY_VERSION --default"

# bundle install
COPY Gemfile Gemfile.lock ./
RUN /bin/bash -l -c "gem install bundler -v 2.4.22"
RUN /bin/bash -l -c "bundle install"
