
require 'sinatra'
require 'sinatra/cross_origin'
require './pub_sub'

class SSE < Sinatra::Base

  register Sinatra::CrossOrigin

  enable :logging

  disable :run

  get '/' do
    erb :index
  end

  get '/stream/:channel' do
    cross_origin
    pub_sub = PubSub.new params[:channel]
    content_type 'text/event-stream'
    stream :keep_open do |out|
      pub_sub.subscribe do |message|
        if out.closed?
          pub_sub.unsubscribe
          next
        end
        out << "data: #{message}\n\n"
      end
    end
  end

  post '/' do
    pub_sub = PubSub.new params[:channel]
    pub_sub.publish params[:text]
  end

end