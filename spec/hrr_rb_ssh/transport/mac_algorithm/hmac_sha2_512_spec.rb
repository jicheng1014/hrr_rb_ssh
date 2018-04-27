# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::MacAlgorithm::HmacSha2_512 do
  let(:name){ 'hmac-sha2-512' }
  let(:digest){ 'sha512' }
  let(:digest_length){ 64 }
  let(:key_length){ 64 }
  let(:key){ [Array.new(key_length){ |i| "%02x" % i }.join].pack("H*") }
  let(:mac_algorithm){ described_class.new key }
  let(:sequence_number){ 0 }
  let(:unencrypted_packet){ "testing" }

  it "can be looked up in HrrRbSsh::Transport::MacAlgorithm dictionary" do
    expect( HrrRbSsh::Transport::MacAlgorithm[name] ).to eq described_class
  end       

  it "is registered in HrrRbSsh::Transport::MacAlgorithm.list_supported" do
    expect( HrrRbSsh::Transport::MacAlgorithm.list_supported ).to include name
  end         

  it "appears in HrrRbSsh::Transport::MacAlgorithm.list_preferred" do
    expect( HrrRbSsh::Transport::MacAlgorithm.list_preferred ).to include name
  end           

  describe '#digest_length' do
    it "returns expected digest length" do
      expect( mac_algorithm.digest_length ).to eq digest_length
    end
  end

  describe '#key_length' do
    it "returns expected key length" do
      expect( mac_algorithm.key_length ).to eq key_length
    end
  end

  describe '#compute' do
    it "returns expected digest" do
      expect( mac_algorithm.compute sequence_number, unencrypted_packet ).to eq OpenSSL::HMAC.digest(digest, key, ([sequence_number].pack("N") + unencrypted_packet))[0, digest_length]
    end
  end
end
