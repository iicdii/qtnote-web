require 'capybara/poltergeist'
#require 'phantomjs'

module QtHelper
  class NewQt
    def initialize(year, month, day)
      #오늘 날짜 qt를 불러올땐 Nokogiri로 파싱하고 아니면 Phantom으로 파싱한다.
      if Time.current.year == year && Time.current.month == month && Time.current.day == day
        @doc = Nokogiri::HTML(open("http://su.or.kr/03bible/daily/qtView.do?qtType=QT2"))
      else
        Capybara.register_driver :poltergeist do |app|
          Capybara::Poltergeist::Driver.new(app)
          #:phantomjs => Phantomjs.path
        end
        
        Capybara.default_selector = :xpath
        session = Capybara::Session.new(:poltergeist)
        session.driver.headers = { 'User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X)" }
        session.visit "http://su.or.kr/03bible/daily/qtView.do?qtType=QT2"
        session.execute_script("document.all['Form'].action = '/03bible/daily/qtView.do'; document.all['Form'].year.value=#{year}; document.all['Form'].month.value=#{month}; document.all['Form'].day.value=#{day}; document.all['Form'].submit(); ")
        sleep 1
        @doc = Nokogiri::HTML.parse(session.html)
      end
    end
    
    def get_title
      @doc.css(".story_view").css(".subject").inner_text
    end
    
    def get_book_line
      @doc.css(".story_view").css(".book_line").inner_text
    end
    
    def get_words
      words = Array.new
      @doc.css(".story_view").css("tr").each do |x|
        words << [x.css("th").inner_text, x.css("td").inner_text]
      end
      words
    end
    
    def get_info
      info = @doc.css(".detail_info").children.map do |t|
        t.text.strip
      end
      info.delete("")
      last_index = info.index("적용하기")
      info1 = info[1..(last_index - 1)] if last_index
      
      first_index = info.index("하나님은 어떤 분입니까?") ? info.index("하나님은 어떤 분입니까?")+1 : false
      info2 = first_index ? info[first_index] : "오늘은 해설이 없습니다."
      
      first_index = info.index("내게 주시는 교훈은 무엇입니까?") ? info.index("내게 주시는 교훈은 무엇입니까?")+1 : false
      info3 = first_index ? info[first_index] : "오늘은 해설이 없습니다."
      result = {
        :explanation => info1,
        :whois => info2,
        :lesson => info3
      }
      return result
    end
    
    def to_h
      info = get_info
      return data = {
        :title => get_title,
        :book_line => get_book_line,
        :words => get_words,
        :explanation => info[:explanation] || [],
        :whois => info[:whois] || [],
        :lesson => info[:lesson] || [],
        :created_at => Time.zone.now
      }
    end
  end
end