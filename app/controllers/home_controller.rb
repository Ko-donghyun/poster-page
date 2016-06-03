class HomeController < ApplicationController
  require 'net/http'
  require 'nokogiri'
  before_action :authenticate_user!, only: [:mypage, :upload]

  # 메인페이지
  def index
    
    @all_count = Poster.count()
    # @posters = Poster.offset(rand(Poster.count - 4))
    #                 .limit(4)
    
    @posters = Poster.all.sample(4)
  end
  
  # 검색 페이지 - 네이버 API 사용해서 영화 포스터 검색 하도록. 여기서 바로 담기를 할 수 있으면 좋겠다.
  def search
  
    @movie_title = params[:title]
    logger.info(@movie_title)
    
    page = params[:pages] == nil ? 1 : params[:pages]
    pages = ( page.to_i - 1 ) * 5
    
    # movie_title2 = @movie_title.gsub(/\s+/m, ' ').strip.split(" ")
    
    # myWherequery = movie_title2.each do |splited|
                     
    #               end
    
    if user_signed_in?
      @posters = Poster.select('poster.*, ownPoster.poster_id AS own_poster_id')
                       .where("poster.movie_same_title like ?", "%" + params[:title].gsub(/\s+/, "") + "%")
                       .joins("AS poster left outer join own_posters AS ownPoster
                               ON ownPoster.poster_id = poster.id
                               AND ownPoster.user_id = #{current_user.id}")
                       .limit(10)
                       .offset(pages)
                       .order("poster.created_at DESC")
    else
      @posters = Poster.where("movie_same_title like ?", "%" + params[:title].gsub(/\s+/, "") + "%")
                       .limit(10)
                       .offset(pages)
                       .order("created_at DESC")
    end
    
    
    url = URI.parse(URI.encode('https://openapi.naver.com/v1/search/movie.xml?query=' + @movie_title))
    req = Net::HTTP::Get.new(url.to_s)
    
    # params = { :query => 'civil' }
    # url.query = URI.encode_www_form(params)
    
    req.add_field("X-Naver-Client-Id", "N7cIilQToWcoF5yLXjU8")
    req.add_field("X-Naver-Client-Secret", "QcgOYciWRw")
    @res = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') {|http|
      http.request(req)
    }
    puts @res.body
    
    @doc = Nokogiri::XML(@res.body)
    
    # 유일한 값에 대해서
    @total_count = @doc.css("total").text
    
    # @movie = {
    #   title: "",
    #   link: "",
    #   image_url: "",
    # }
    
    @movies = Array.new
    
    @um = @doc.xpath("//item")
    'hello'.gsub(/[eo]/, 'e' => 3, 'o' => '*')    #=> "h3ll*"
    @doc.xpath("//item").each do |movie|
      @movie = Hash.new
      @movie[:title] = movie.css("title").text.gsub('<b>', '').gsub('</b>', '')
      @movie[:link] = movie.css("link").text
      @movie[:image_url] = movie.css("image").text
      
      @movies << @movie
    end
    
    
  end
  
  # 내 포스터 페이지 - 보기, 검색
  def myposter

    @page = params[:pages] == nil ? 1 : params[:pages]
    pages = ( @page.to_i - 1 ) * 6
    
    @movie_title = params[:title] == nil ? '' : params[:title].gsub(/\s+/, "")
    
    @myPostersCount = OwnPoster.where("user_id = ?", current_user.id).count
    @myPosters = OwnPoster.where("own_poster.user_id = ? AND poster.movie_same_title like ?", current_user.id, '%' + @movie_title + '%')
                          .select("own_poster.id as own_poster_id, poster.id as poster_id, poster.movie_title as poster_movie_title, poster.image_url as poster_image_url")
                          .joins("AS own_poster inner join posters AS poster
                                  ON own_poster.poster_id = poster.id")
                          .limit(6)
                          .offset(pages)
                          .order("own_poster.created_at DESC")
                          
    # @myPostersCount = @myPosters.length

  end
   
  # 업로드 페이지 - 추가
  def upload
    
    # page = params[:pages] == nil ? 1 : params[:pages]
    # pages = ( page.to_i - 1 ) * 5
    
    # @registeredPosters = Poster.where("user_id = ?", current_user.id)
    #                           .limit(5)
    #                           .offset(pages)
    #                           .order("created_at DESC")
  
  end
  
  # 다른 사람 페이지 - 구경
  # def others
    
  #   page = params[:pages] == nil ? 1 : params[:pages]
  #   pages = ( page.to_i - 1 ) * 5
    
  #   @othersPosters = OwnPoster.where("own_poster.user_id = ?", params[:user_id])
  #                             .select("own_poster.id as own_poster_id, poster.movie_title as poster_movie_title, poster.image_url as poster_image_url")
  #                             .joins("AS own_poster inner join posters AS poster
  #                                     ON own_poster.poster_id = poster.id")
  #                             .limit(5)
  #                             .offset(pages)
  #                             .order("own_poster.created_at DESC")
                              
                              
  # end
  
  def addPoster
    
    # file = params[:poster_image]
    movie_title = params[:movie_title]
    movie_same_title = params[:movie_title].gsub(/\s+/, "")
    
    uploader = UploadposterUploader.new
    uploader.store!(params[:poster_image])

    logger.info("sdfsdf")
    logger.info(uploader.url)
    
    poster = Poster.new
    poster.movie_title = movie_title
    poster.image_url = uploader.url
    poster.movie_same_title = movie_same_title
    poster.save
    
    
    own_poster = OwnPoster.new
    own_poster.user_id = current_user.id
    own_poster.poster_id = poster.id
    own_poster.save
    
    
    redirect_to '/home/myposter'
  end
  
  def ownPoster
    
    logger.info(params[:poster_id])
    
    
    own_poster = OwnPoster.new
    own_poster.user_id = current_user.id
    own_poster.poster_id = params[:poster_id]
    own_poster.save
    
    render :text => params[:poster_id]
  end
  
  def outPoster
    
    logger.info(params[:poster_id])
    
    own_poster = OwnPoster.where('user_id = ? and poster_id = ?', current_user.id, params[:poster_id] ).take
    own_poster.destroy
    
    # poster = Poster.find(params[:poster_id])
    # poster.get_count -= 1
    # poster.save

    # render :text => ''

    render :text => params[:poster_id]
  end
  
end
