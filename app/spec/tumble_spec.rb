describe 'Tumble' do
    include Rack::Test::Methods

    def app
      @app ||= Sinatra::Application
    end

    let(:quoteid) { 'e9e7e4e42e094db9b935450a12071c0f' }
    let(:linkid)  { 'e9e7e4e42e094db9b935450a12071d72' }

    describe 'frontpage' do
      it 'should load the tracker for google analytics' do
        get '/'
        last_response.should be_ok
      end
#      it 'should include quotes from the database'
#      it 'should include links from the database'
#      it 'should include fotos from phlicker'
#      it 'should be able to search links, quotes, and photos'
    end

    describe 'api' do
      describe '_page' do
        it 'should return 10 items at a time' do
          get '/page'
          last_response.should be_ok
          j = JSON.parse(last_response.body)
          j.should be_a(Hash)
          j['rows'].should have(10).items
        end

        it 'should skip items'
        it 'should return items sorted by date with newest first'
      end

      describe '_quote' do
        # 'http://tumble.wcyd.org/quote/?quote=' . "$quote" . "&author=$author")
        it 'should accept a quote post' do
          post '/quote', { :author => 'Yoda', :quote => 'Do or do not, there is no try'}
          last_response.status.should eql(201)
          last_response.headers['ETag'].should_not be_nil
        end

        it 'should retrieve a quote' do
          get "/quote/#{quoteid}"
          last_response.should be_ok
          JSON.parse(last_response.body).should be_a(Hash)
        end

      end

      describe '_irclink' do
        it 'should accept a link' do
          post "/irclink", {:user => 'Aziz Shamim', :url => 'http://www.google.com' }
          last_response.status.should eql(201)
          last_response.headers['ETag'].should_not be_nil
          last_response.body.should_not be_empty
        end

        it 'should redirect to the link' do
          get "/irclink/#{linkid}"
          last_response.status.should eql(301)
          last_response.headers['Location'].should_not be_nil
        end

        it 'should track how many times the link is clicked (redirected)' do
          get "/irclink/#{linkid}"
          pre_click = last_response.headers['clicks'].to_i
          get "/irclink/#{linkid}"
          post_click = last_response.headers['clicks'].to_i
          diff = post_click - pre_click
          diff.should eql(1)
        end

#        it 'should be backwards compatible with the original cgi (specification)'
      end

      describe '_flickr' do
      end

    end

end