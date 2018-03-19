RSpec.describe Omml2Mathml do
  it "has a version number" do
    expect(Omml2Mathml::VERSION).not_to be nil
  end

  it "processes a document" do
    html = Omml2Mathml.convert("spec/test.html")
    expect(html).to be_equivalent_to <<~"OUTPUT"
    xxx
    OUTPUT
  end
end
