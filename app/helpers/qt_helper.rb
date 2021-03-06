module QtHelper
  class NewQt
    def initialize(year, month, day)
      if I18n.locale == :ko
        @doc = Nokogiri::HTML(open("http://su.or.kr/03bible/daily/qtView.do?qtType=QT2&year=#{year}&month=#{month}&day=#{day}"))
        @s_doc = Nokogiri::HTML(open("http://su.or.kr/03bible/daily/qtView.do?qtType=QT6&year=#{year}&month=#{month}&day=#{day}"))
        @j_doc = Nokogiri::HTML(open("http://su.or.kr/03bible/daily/qtView.do?qtType=QT1&year=#{year}&month=#{month}&day=#{day}"))
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
        
        j_info = @j_doc.css(".detail_info").children.map do |t|
          t.text.strip
        end
        j_info.delete("")
        
        last_index = info.index("적용하기")
        info1 = info[1..(last_index - 1)] if last_index
        
        if j_info.index("하나님은 어떤 분입니까?")
          first_index = j_info.index("하나님은 어떤 분입니까?")
          type = 0
        elsif j_info.index("하나님은 어떤 분입니까?")
          first_index = info.index("하나님은 어떤 분입니까?")
          type = 0
        elsif info.index("하나님은 어떤 분입니까?")
          first_index = info.index("하나님은 어떤 분입니까?")
          type = 1
        elsif info.index("예수님은 어떤 분입니까?")
          first_index = info.index("예수님은 어떤 분입니까?")
          type = 1
        elsif s_info.index("하나님은 어떤 분입니까?")
          first_index = s_info.index("하나님은 어떤 분입니까?")
          type = 2
        else
          first_index = false
        end
        
        if first_index
          case type
          when 0
            info2 = j_info[first_index+1]
          when 1
            info2 = info[first_index+1]
          when 2
            info2 = s_info[first_index+1]
          else
            info2 = "오늘은 해설이 없습니다."
          end
        else
          info2 = "오늘은 해설이 없습니다."
        end
        
        if j_info.index("내게 주시는 교훈은 무엇입니까?")
          first_index = j_info.index("내게 주시는 교훈은 무엇입니까?")
          type = 0
        elsif info.index("내게 주시는 교훈은 무엇입니까?")
          first_index = info.index("내게 주시는 교훈은 무엇입니까?")
          type = 1
        elsif s_info.index("내게 주시는 교훈은 무엇입니까?")
          first_index = s_info.index("내게 주시는 교훈은 무엇입니까?")
          type = 2
        else
          first_index = false
        end
        
        info3 = ""
        if first_index
          case type
          when 0
            until_index = j_info.index("기도") if j_info.index("기도") 
            j_info.each_with_index do |value, index|
              if index > first_index
                if until_index
                  if index < until_index-1
                    info3 += j_info[index] + "\n\n" 
                  elsif index == until_index-1
                    info3 += j_info[index]
                  end
                else
                  info3 += j_info[index] + "\n\n"
                end
              end
            end
          when 1
            info3 = info[first_index+1]
          when 2
            info3 = s_info[first_index+1]
          else
            info3 = "오늘은 해설이 없습니다."
          end
        else
          info3 = "오늘은 해설이 없습니다."
        end
        puts info3
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