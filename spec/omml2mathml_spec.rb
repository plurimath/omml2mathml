require "spec_helper"
require "nokogiri"

RSpec.describe Omml2Mathml do
  it "has a version number" do
    expect(Omml2Mathml::VERSION).not_to be nil
  end

  it "processes a document" do
    input = Omml2Mathml.convert("spec/test.html").sub(/<\?xml[^>]+>/, "").sub(/<!DOCTYPE[^>]+>/, "")

    output = <<~"OUTPUT"
      <html xmlns:v="urn:schemas-microsoft-com:vml"
            xmlns:o="urn:schemas-microsoft-com:office:office"
            xmlns:w="urn:schemas-microsoft-com:office:word"
            xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882"
            xmlns:m="http://schemas.microsoft.com/office/2004/12/omml"
            xmlns="http://www.w3.org/TR/REC-html40">

      <head>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
      <meta name="ProgId" content="Word.Document"/>
      <meta name="Generator" content="Microsoft Word 15"/>
      <meta name="Originator" content="Microsoft Word 15"/>
      <link rel="File-List" href="Part%201_General.fld/filelist.xml"/>
      <link rel="Edit-Time-Data" href="Part%201_General.fld/editdata.mso"/>
      </head>

      <body lang="EL" link="blue" vlink="purple" style="tab-interval:20.0pt" xml:lang="EL">

      <div class="WordSection3">

        <p class="MsoNormal"><span lang="EN-US" style="mso-fareast-font-family:SimSun;&#10;mso-fareast-theme-font:minor-fareast;mso-ansi-language:EN-US;mso-fareast-language:&#10;ZH-CN" xml:lang="EN-US">This standard applies to the elliptic curves over the finite field </span><mml:math>
      <mml:msub>
        <mml:mrow>
          <mml:mrow>
            <mml:mi>F</mml:mi>
          </mml:mrow>
        </mml:mrow>
        <mml:mrow>
          <mml:mrow>
            <mml:mi>p</mml:mi>
          </mml:mrow>
        </mml:mrow>
      </mml:msub>
      </mml:math><span lang="EN-US" style="mso-fareast-font-family:SimSun;mso-fareast-theme-font:minor-fareast;&#10;mso-ansi-language:EN-US;mso-fareast-language:ZH-CN" xml:lang="EN-US"><span style="mso-spacerun:yes">&#xA0;</span>(the prime </span><mml:math>
      <mml:mi>p</mml:mi>
      <mml:mo>&gt;</mml:mo>
      <mml:msup>
        <mml:mrow>
          <mml:mrow>
            <mml:mn>2</mml:mn>
          </mml:mrow>
        </mml:mrow>
        <mml:mrow>
          <mml:mrow>
            <mml:mn>191</mml:mn>
          </mml:mrow>
        </mml:mrow>
      </mml:msup>
      </mml:math><span lang="EN-US" style="mso-fareast-font-family:SimSun;mso-fareast-theme-font:minor-fareast;&#10;mso-ansi-language:EN-US;mso-fareast-language:ZH-CN" xml:lang="EN-US">).<p/></span></p>

      </div>
      </body>
      </html>
    OUTPUT

    if Gem::Version.new(Nokogiri::VERSION) < Gem::Version.new("1.11")
      output.gsub!("\n<mml:mo>&gt;</mml:mo>", "")
      output.gsub!("http://www.w3.org/TR/REC-html40", "http://www.w3.org/1999/xhtml")
    else
      output.gsub!(%r{ xml:lang="[\w-]+"}, "")
    end

    expect(input).to be_equivalent_to output
  end
end
