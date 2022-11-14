 require "bundler/setup"
 Bundler.require

require 'json'

set :allow_origin, "http://localhost:3000 https://burauza.vercel.app"
set :allow_methods, "GET,HEAD,POST,OPTIONS"
set :allow_headers, "content-type,if-modified-since"
set :expose_headers, "location,link"

if Sinatra::Base.development?
	set :port, 9801
end

before do
  headers "Content-Type" => "text/plain; charset=utf-8"
end

SUBJECT_URL = 'https://jbbs.shitaraba.net/bbs/subject.cgi/game/59121/'.freeze
THREADS_URL = 'https://jbbs.shitaraba.net/game/59121/subject.txt'.freeze
THREAD_URL = 'https://jbbs.shitaraba.net/bbs/rawmode.cgi/game/59121/'.freeze
WRITE_URL = 'https://jbbs.shitaraba.net/bbs/write.cgi/'.freeze
# test ita
# https://jbbs.shitaraba.net/bbs/read.cgi/internet/11583/1302532578/
REFERER_URL = 'https://jbbs.shitaraba.net/bbs/read.cgi/internet/11583/1302532578/'

def encode_body(body)
	body.encode('utf-8', 'euc-jp', 
	  :invalid => :replace,
	  :undef   => :replace,
	  :replace => ' ',
	)
end

get '/' do
  'Hello world!'
end

get '/threads' do
	conn = Faraday.new(
		url: THREADS_URL
	)
	response = conn.get
	encode_body response.body
end

get '/thread/:id' do
	url = THREAD_URL + params[:id]
	conn = Faraday.new(
		url: url
	)
	response = conn.get
	encode_body response.body
end

post '/test' do
	"OK"
end

post '/write' do
	# prepare message
	msg = params.key?(:msg) ? params[:msg] : 'テスト'

	msg = msg.encode('euc-jp', 'utf-8',
	  :invalid => :replace,
	  :undef   => :replace,
	  :replace => ' ',
	)

	if params.key?(:id)
		pid = params[:id]
		xparams = {
			'DIR': 'game',
			'BBS': '59121',
			'KEY': pid,
			'NAME': '',
			'MAIL': 'sage',
			'MESSAGE': msg
		}
		ref_url = "https://jbbs.shitaraba.net/bbs/read.cgi/game/59121/#{pid}/"
	else
		xparams = {
			'DIR': 'internet',
			'BBS': '11583',
			'KEY': '1302532578',
			'NAME': '',
			'MAIL': 'sage',
			'MESSAGE': msg
		}
		ref_url = REFERER_URL
	end

	conn = Faraday.new(
		WRITE_URL,
		params: xparams,
		headers: {
			'Referer': ref_url
		}
	)

	response = conn.post
	encode_body response.body
	# puts msg
	# "OK"
end