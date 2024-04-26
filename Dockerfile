FROM ruby:3.3.0
WORKDIR /usr/src/app 
COPY Gemfile Gemfile.lock ./ 
RUN bundle _2.5.3_ install 
ADD . /usr/src/app/ 
EXPOSE 3000 
CMD rails s -b 0.0.0.0
