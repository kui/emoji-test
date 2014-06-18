#!/usr/bin/env ruby
# -*- coding:utf-8; mode:ruby; -*-

# 絵文字見るためのHTMLを生成する。

require 'kconv'

def main
  print_head
  print_body
end

def print_head
  puts "<style>"
  puts <<STYLE
@font-face {
  font-family: symbola;
  src: url(symbola.woff) format(woff);
}
.symbola {
  font-family: symbola!important;
}
STYLE
  puts "</style>"
end

def print_body
  puts <<HTML
<p>把握している限りで一番絵文字対応してるフォントと、今みてる環境の比較とUTF-8コードの表示
HTML

  [{
      title: 'Enclosed Alphanumerics',
      url: 'http://www.unicode.org/charts/PDF/U2460.pdf',
      offset:"\x00\x00\x24\x60", num: 16*10
    }, {
      title: 'Miscellaneous Symbols',
      url: 'http://www.unicode.org/charts/PDF/U2600.pdf',
      offset:"\x00\x00\x26\x00", num: 16*16
    }, {
      title: 'Dingbats',
      url: 'http://www.unicode.org/charts/PDF/U2700.pdf',
      offset:"\x00\x00\x27\x00", num: 16*12
    }, {
      title: 'Miscellaneous Symbols and Arrows',
      url: 'http://www.unicode.org/charts/PDF/U2B00.pdf',
      offset:"\x00\x00\x2b\x00", num: 16*12
    }, {
      title: 'Mahjong Tiles',
      url: 'http://www.unicode.org/charts/PDF/U1F000.pdf',
      offset:"\x00\x01\xf0\x00", num: 16*3
    }, {
      title: 'Domino Tiles',
      url: 'http://www.unicode.org/charts/PDF/U1F030.pdf',
      offset:"\x00\x01\xf0\x30", num: 16*7
    }, {
      title: 'Playing Cards',
      url: 'http://www.unicode.org/charts/PDF/U1F0A0.pdf',
      offset:"\x00\x01\xf0\xA0", num: 16*6
    }, {
      title: 'Enclosed Alphanumeric Supplement',
      url: 'http://www.unicode.org/charts/PDF/U1F100.pdf',
      offset:"\x00\x01\xf1\x00", num: 16*16
    }, {
      title: 'Enclosed Ideographic Supplement',
      url: 'http://www.unicode.org/charts/PDF/U1F200.pdf',
      offset:"\x00\x01\xf2\x00", num: 16*16
    }, {
      title: 'Miscellaneous Symbols and Pictographs',
      url: 'http://www.unicode.org/charts/PDF/Unicode-7.0/U70-1F300.pdf',
      offset:"\x00\x01\xf3\x00", num: 16*16*3
    }, {
      title: 'Emoticon',
      url: 'http://www.unicode.org/charts/PDF/Unicode-7.0/U70-1F600.pdf',
      offset:"\x00\x01\xf6\x00", num: 16*5
    }, {
      title: 'Transport and Map Symbols',
      url: 'http://www.unicode.org/charts/PDF/Unicode-7.0/U70-1F680.pdf',
      offset:"\x00\x01\xf6\x80", num: 16*8
    }, {
      title: 'Supplemental Arrows-C',
      url: 'http://www.unicode.org/charts/PDF/U1F800.pdf',
      offset:"\x00\x01\xf8\x00", num: 16*16
    }
  ].each do |i|
    print_header i[:title], i[:url]
    print_table i[:offset], i[:num]
  end
end

def print_header h, link
  puts %Q|<h2><a href="#{link}">#{h}</a></h2>|
end

def print_table offset_bytes, num
  offset = Utf32.new(offset_bytes)
  puts '<table class="codes">'
  puts '<tr><th>CODE</th>'
  puts (0..15).map {|i| '<th>+%01x</th>' % i}.join
  puts '</tr>'
  num.times { |i|
    code = offset.add(i)

    if i % 16 == 0
      puts "<tr><th>#{code.to_hex}</th>"
    end

    print_code code

    if i % 16 == 15
      puts '</tr>'
    end
  }
  puts '</table>'
end

def print_code code
  puts '<td><table>'
  puts %Q|<tr>|
  puts %Q|  <td title="Symbola" class="symbola">#{code.to_utf8}</td>|
  puts %Q|  <td title="Native">#{code.to_utf8}</td>|
  puts %Q|</tr>|
  puts %Q!<tr><td class="utf8" colspan="2">#{code.to_hex}</td></tr>!
  puts '</table></td>'
end

class Utf32
  attr_reader :bytes

  def initialize bytes
    bytes.force_encoding('utf-32be')
    @bytes = bytes
  end

  def to_long
    @bytes.unpack('n2').reduce(0){|result, short| (result << 16) + short}
  end

  def to_hex
    @bytes.unpack('H*')[0].sub(/^0*/, '')
  end

  def to_html
    "&#x#{to_hex};"
  end

  def to_utf8
    @bytes.encode('utf-8')
  end

  def add long
    Utf32::from_long(to_long + long)
  end

  class << self
    def from_long long
      short1 = (long >> 16) & 0xffff
      short2 = long & 0xffff
      Utf32.new([short1, short2].pack('n2'))
    end
  end
end

main
