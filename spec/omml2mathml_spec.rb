RSpec.describe Omml2Mathml do
  it "has a version number" do
    expect(Omml2Mathml::VERSION).not_to be nil
  end

  it "processes a document" do
    html = Html2Doc.process(html_input("spec/test.html"), filename: "test")
    expect(guid_clean(File.read("test.doc", encoding: "utf-8"))).
      to be_equivalent_to <<~"OUTPUT"
    xxx
    OUTPUT
  end
end
