require "nokogiri"

module Omml2Mathml
  module_function

  def convert(filename)
    @tags = %w{
      acc
      accPr
      aln
      alnScr
      argPr
      argSz
      bar
      barPr
      baseJc
      begChr
      borderBox
      borderBoxPr
      box
      boxPr
      brk
      brkBin
      brkBinSub
      cGp
      cGpRule
      chr
      count
      cSp
      ctrlPr
      d
      defJc
      deg
      degHide
      den
      diff
      dispDef
      dPr
      e
      endChr
      eqArr
      eqArrPr
      f
      fName
      fPr
      func
      funcPr
      groupChr
      groupChrPr
      grow
      hideBot
      hideLeft
      hideRight
      hideTop
      interSp
      intLim
      intraSp
      jc
      lim
      limLoc
      limLow
      limLowPr
      limUpp
      limUppPr
      lit
      lMargin
      m
      mathFont
      mathPr
      maxDist
      mc
      mcJc
      mcPr
      mcs
      mPr
      mr
      nary
      naryLim
      naryPr
      noBreak
      nor
      num
      objDist
      oMath
      oMathPara
      oMathParaPr
      opEmu
      phant
      phantPr
      plcHide
      pos
      postSp
      preSp
      r
      rad
      radPr
      rMargin
      rPr
      rSp
      rSpRule
      scr
      sepChr
      show
      shp
      smallFrac
      sPre
      sPrePr
      sSub
      sSubPr
      sSubSup
      sSubSupPr
      sSup
      sSupPr
      strikeBLTR
      strikeH
      strikeTLBR
      strikeV
      sty
      sub
      subHide
      sup
      supHide
      t
      transp
      type
      vertJc
      wrapIndent
      wrapRight
      zeroAsc
      zeroDesc
      zeroWid
    }

    @mathml = {}
    @tags.each do |t|
      @mathml["m_#{t.downcase}"] = t
    end

    html = Nokogiri::HTML.parse(File.read(filename, encoding: "utf-8")
                                .gsub(/\r/, "").gsub(/<m:/, "<m_")
                                .gsub(/<\/m:/, "</m_")
      .gsub(/<!\[endif\]>/, "<!--endif-->")
      .gsub(/<!\[endif\]-->/, "<!--endif-- -->")
                                .gsub(/<!\[if !msEquation\]>/,
                                      "<!--if !msEquation-->"))
    @xslt = Nokogiri::XSLT(File.open(
                             File.join(File.dirname(__FILE__),
                                       "xhtml-mathml.xsl"), "rb"
                           ))
    html.traverse do |n|
      if n.comment?
        if /^\[if gte msEquation 12\]>/.match? n.text
          n.replace(n.text.sub(/\[if gte msEquation 12\]>/, "")
                    .sub(/<!--endif-->/, ""))
        elsif /^if !msEquation/.match? n.text
          n.next.remove
          n.remove
        else
          n.remove
        end
      end
    end
    xml = Nokogiri::XML(html.to_xhtml)
    ns = xml.root.add_namespace "m", "http://schemas.microsoft.com/office/2004/12/omml"
    xml.traverse do |t|
      if t.element? && @mathml.has_key?(t.name)
        t.name = @mathml[t.name]
        t.namespace = ns
      end
    end
    # xml.xpath("//xmlns:link | //xmlns:style | //*[@class = 'MsoToc1'] | //*[@class = 'MsoToc2'] |//*[@class = 'MsoToc3'] |//*[@class = 'MsoToc4'] |//*[@class = 'MsoToc5'] |//*[@class = 'MsoToc6'] |//*[@class = 'MsoToc7'] |//*[@class = 'MsoToc8'] |//*[@class = 'MsoToc9'] ").each { |x| x.remove }
    xml.xpath("//*[local-name()='oMath' or local-name()='oMathPara']").each do |x|
      # prepare input: delete xmlns & change
      input = Nokogiri::XML(x.to_xml.sub(/<m:(oMath|oMathPara)>/,
                                         "<m:\\1 xmlns:m='http://schemas.openxmlformats.org/officeDocument/2006/math'>"))
      out = @xslt.transform(input)
      mml = out.to_xml.gsub(/<\?xml[^>]+>/, "")
        .gsub(%r{<([^:/! >]+ xmlns="http://www.w3.org/1998/Math/MathML")},
              "<mml:\\1")
        .gsub(%r{<([^:/!>]+)>}, "<mml:\\1>")
        .gsub(%r{</([^:/!>]+)>}, "</mml:\\1>")
        .gsub(%r{ xmlns="http://www.w3.org/1998/Math/MathML"}, "")
        .gsub(%r{ xmlns:mml="http://www.w3.org/1998/Math/MathML"}, "")
        .gsub(%r{ xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"}, "")
        .gsub(%r{ xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"}, "")
      x.replace("<mml:math>#{mml}</mml:math>")
    end
    xml.to_s
  end
end
