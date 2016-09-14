module QtHelper
  class NewQt
    def initialize(year, month, day)
      @doc = Nokogiri::HTML(open("http://su.or.kr/03bible/daily/qtView.do?qtType=QT2&year=#{year}&month=#{month}&day=#{day}"))
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
      
      if info.index("하나님은 어떤 분입니까?")
        first_index = info.index("하나님은 어떤 분입니까?")+1
      elsif info.index("예수님은 어떤 분입니까?")
        first_index = info.index("예수님은 어떤 분입니까?")+1
      else
        first_index = false
      end
      
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