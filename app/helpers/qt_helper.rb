module QtHelper
  class NewQt
    def initialize(year, month, day)
      if I18n.locale == :ko
        @doc = Nokogiri::HTML(open("http://su.or.kr/03bible/daily/qtView.do?qtType=QT2&year=#{year}&month=#{month}&day=#{day}"))
        @s_doc = Nokogiri::HTML(open("http://su.or.kr/03bible/daily/qtView.do?qtType=QT6&year=#{year}&month=#{month}&day=#{day}"))
      else
        @doc = Nokogiri::HTML(open("http://su.or.kr/03bible/daily/qtView.do?qtType=QT5&year=#{year}&month=#{month}&day=#{day}"))
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

      
      if I18n.locale == :ko
        s_info = @s_doc.css(".detail_info").children.map do |t|
          t.text.strip
        end
        s_info.delete("")
        
        last_index =  info.index("적용하기")
        info1 = info[1..(last_index - 1)] if last_index
        
        if info.index("하나님은 어떤 분입니까?")
          first_index = info.index("하나님은 어떤 분입니까?")
          
        elsif info.index("예수님은 어떤 분입니까?")
          first_index = info.index("예수님은 어떤 분입니까?")
        else
          first_index = false
        end
        first_index += 1 if first_index
        
        if first_index
          info2 = info[first_index]
        else
          first_index = s_info.index("하나님은 어떤 분입니까?")
          info2 = first_index ? s_info[first_index+1] : "오늘은 해설이 없습니다."
        end
        
        first_index = info.index("내게 주시는 교훈은 무엇입니까?") ? info.index("내게 주시는 교훈은 무엇입니까?")+1 : false
        
        if first_index
          info3 = info[first_index]
        else
          first_index = s_info.index("내게 주시는 교훈은 무엇입니까?")+1
          info3 = first_index ? s_info[first_index] : "오늘은 해설이 없습니다."
        end
        
      else
        last_index = info.index("Who is God?") ? info.index("Who is God?") : info.index("What lesson is God teaching me?")
        info1 = info[1..(last_index - 1)] if last_index
        
        first_index = info.index("Who is God?") ? info.index("Who is God?")+1 : false
        
        info2 = first_index ? info[first_index] : "There is no commentary today."
        
        first_index = info.index("What lesson is God teaching me?") ? info.index("What lesson is God teaching me?")+1 : false
        info3 = first_index ? info[first_index] : "There is no commentary today."
      end

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