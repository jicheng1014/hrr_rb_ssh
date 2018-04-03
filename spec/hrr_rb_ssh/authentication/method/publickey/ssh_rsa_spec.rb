# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Authentication::Method::Publickey::SshRsa do
  let(:publickey){ described_class.new }

  it "is registered as ssh-rsa in HrrRbSsh::Authentication::Method::Publickey.list" do
    expect( HrrRbSsh::Authentication::Method::Publickey['ssh-rsa'] ).to eq described_class
  end

  it "appears as ssh-rsa in HrrRbSsh::Authentication::Method::Publickey.name_list" do
    expect( HrrRbSsh::Authentication::Method::Publickey.algorithm_name_list ).to include 'ssh-rsa'
  end

  describe "::NAME" do
    it "is \"ssh-rsa\"" do
      expect( described_class::NAME ).to eq 'ssh-rsa'
    end
  end

  describe "::DIGEST" do
    it "is \"sha1\"" do
      expect( described_class::DIGEST ).to eq 'sha1'
    end
  end

  describe '#verify_public_key' do
    let(:public_key_algorithm_name){ 'ssh-rsa' }
    let(:public_key_str){
      <<-'EOB'
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3OnIQcRTdeTZFjhGcx8f
ssCgeqzY47p5KhT/gKMz2nOANNLCBr9e6IGaRePew03St3Cn0ApikuGzPnWxSlBT
H6OpR/EnUmBttlvcL28CGOsZIwYJtAdVsGXpIXtiPLl2eEzaM9aBsS/LGWKgQNo3
86UGa5j20yGJfsL9WIMCVoGvsA06+4VX1/zlWXwVJSNep674bmSWPcVtXWWZIk19
T6b+xuqhfiUpbc/stfdmgDc3B/ZgpFsQh5oWBoAfkL6kAEa4oQBFhqF0QM5ej6h5
wqbQt4paM0aEuypWE+CaizA0I+El7f0y+59sUqTAN/7F9UlXaOBdd9SZkhACBrAR
nQIDAQAB
-----END PUBLIC KEY-----
      EOB
    }
    let(:public_key){
      OpenSSL::PKey::RSA.new(public_key_str)
    }
    let(:public_key_blob){
      [
        HrrRbSsh::Transport::DataType::String.encode('ssh-rsa'),
        HrrRbSsh::Transport::DataType::Mpint.encode(public_key.e.to_i),
        HrrRbSsh::Transport::DataType::Mpint.encode(public_key.n.to_i),
      ].join
    }

    context "with correct arguments" do
      context "when public_key is an instance of String" do
        it "returns true" do
          expect(publickey.verify_public_key public_key_algorithm_name, public_key_str, public_key_blob).to be true
        end
      end

      context "when public_key is an instance of OpenSSL::PKey::RSA" do
        it "returns true" do
          expect(publickey.verify_public_key public_key_algorithm_name, public_key, public_key_blob).to be true
        end
      end
    end

    context "with incorrect arguments" do
      context "when public_key_algorithm_name is incorrect" do
        let(:incorrect_public_key_algorithm_name){ 'incorrect' }

        it "returns false" do
          expect(publickey.verify_public_key incorrect_public_key_algorithm_name, public_key, public_key_blob).to be false
        end
      end

      context "when public_key is not an instance of neither String nor OpenSSL::PKey::RSA" do
        let(:incorrect_public_key){ nil }

        it "returns false" do
          expect(publickey.verify_public_key public_key_algorithm_name, incorrect_public_key, public_key_blob).to be false
        end
      end

      context "when public_key_blob is broken" do
        let(:broken_public_key_blob){ String.new }

        it "returns false" do
          expect(publickey.verify_public_key public_key_algorithm_name, public_key, broken_public_key_blob).to be false
        end
      end
    end
  end

  describe '#verify_signature' do
    let(:private_key_str){
      <<-'EOB'
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA3OnIQcRTdeTZFjhGcx8fssCgeqzY47p5KhT/gKMz2nOANNLC
Br9e6IGaRePew03St3Cn0ApikuGzPnWxSlBTH6OpR/EnUmBttlvcL28CGOsZIwYJ
tAdVsGXpIXtiPLl2eEzaM9aBsS/LGWKgQNo386UGa5j20yGJfsL9WIMCVoGvsA06
+4VX1/zlWXwVJSNep674bmSWPcVtXWWZIk19T6b+xuqhfiUpbc/stfdmgDc3B/Zg
pFsQh5oWBoAfkL6kAEa4oQBFhqF0QM5ej6h5wqbQt4paM0aEuypWE+CaizA0I+El
7f0y+59sUqTAN/7F9UlXaOBdd9SZkhACBrARnQIDAQABAoIBAG72ww895UpHrD97
/u8eiBaKqVFVdxBUfz4DFB/yWj51W8Wsw6cOA0c4qlxGzIM/mQNpg/F89eyfkCBk
j6wrUsWGuKYZXM4E/7bkx2HQGbaYiKTOCJu0P3d+iS63Qi4MXpSozcXSDo0I27Sh
lKtesVIh52quh/SfWOgiW41VKRx30qBVkaPpADrh2STIEHpD/w3XLJXUcFG03Dkk
raouHJJlzAWG2GSSE2YpsBAUcsKOHSpObgaCnyieX+ITF4R7TLtI7eADF5Uv3DcT
HyO39zo5VHeyQ2fpcBADF+drKpJWsGFgOsR9xin8hBbsvqBKzwmp/iuY1t13RmUf
r0Sg2sUCgYEA+sx78J5Q5+W8GwwJkeCUqNn1QzigRp87UZ5K12SCcfPKn+UYG7v+
wt4aL0B48xTqJKtVKtiMafeRfZ+vRsKQfgdtAkV7tEEtOmzg6gt5VVuFxhIJcwCu
XLDb5qZq61YwnFz7Z46i6POBkMP6Kmzm9kScZfS0KtFYwdwvxmJHb+cCgYEA4X6h
+LyKr+sFKpaZzGeeZqdsb4P5//wxRLDL1TsVr8zaVnEhunsfQQ17MhJkVotbgeQ4
ESsi5dbn6/Fdc8A+87j1wvLIME9Hv35ftU4Sw/x9ueytemiUyBKeUVvoQBMXEqPT
5SQtBCEPEtiPvlsq+mtSsj+OQA4PX/JcuAETEdsCgYEA3BqRuz516s7oIySRUYEz
dmyynugXYWNlf9/X9uiywqcecO1yFwUKNKMPf+CpRUxZoQzslcmukWFAQmveO8+N
V83UkWXBhxScSOY9Dao8Nfk4kfhKaq9yVs6wbuAmfZsK1m+UA/JebusmDpKv/oPM
vtzAFYqIg/tuVdST6RtfbokCgYB0HvcgFU/CGeAWN2nKJk4fBPbFUoxqc5+XhQfi
rcOUPYTuYOICmybUJDId7fS30Jn2AOWSick13P6ftTLvyb9hWQ1OMCJBJoKHLXfx
8NufC6ZfGW+YisSbZ2MZ+J9YZ7xJAA69gGyiJLgTd2xGlcJDJQN4AVyqxdLLEQ8I
Pp1oYwKBgQDq6Q6CPMbOHWgIRMoPOOuk1PPlkrKD36cVYhXvKAjhkQFs/yL/Vv4A
mHRfY1PAWtuFc8FJOzwugsUqECqmBPLDIOvCnebBbrCW0YhMlNRZ3wnXaV0V0dYQ
RiRsowkxGlUrp56nZQ0Rj3JNmQeafYplYLNAv3/3vWGiFRUZALIjMg==
-----END RSA PRIVATE KEY-----
      EOB
    }
    let(:algorithm){ OpenSSL::PKey::RSA.new private_key_str }
    let(:public_key_blob){
      [
        HrrRbSsh::Transport::DataType::String.encode('ssh-rsa'),
        HrrRbSsh::Transport::DataType::Mpint.encode(algorithm.e.to_i),
        HrrRbSsh::Transport::DataType::Mpint.encode(algorithm.n.to_i),
      ].join
    }
    let(:session_id){ 'session id' }
    let(:username){ 'username' }
    let(:message){
      {
      'session identifier'        => session_id,
      'message number'            => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
      'user name'                 => username,
      'service name'              => 'ssh-connection',
      'method name'               => 'publickey',
      'with signature'            => true,
      'public key algorithm name' => 'ssh-rsa',
      'public key blob'           => public_key_blob,
      'signature'                 => signature,
      }
    }
    let(:data){
      [
        HrrRbSsh::Transport::DataType::String.encode(session_id),
        HrrRbSsh::Transport::DataType::Byte.encode(HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE),
        HrrRbSsh::Transport::DataType::String.encode(username),
        HrrRbSsh::Transport::DataType::String.encode('ssh-connection'),
        HrrRbSsh::Transport::DataType::String.encode('publickey'),
        HrrRbSsh::Transport::DataType::Boolean.encode(true),
        HrrRbSsh::Transport::DataType::String.encode('ssh-rsa'),
        HrrRbSsh::Transport::DataType::String.encode(public_key_blob),
      ].join
    }

    context "with correct signature" do
      let(:signature_blob){ algorithm.sign('sha1', data) }
      let(:signature){
        [
          HrrRbSsh::Transport::DataType::String.encode('ssh-rsa'),
          HrrRbSsh::Transport::DataType::String.encode(signature_blob),
        ].join
      }

      it "returns true" do
        expect( publickey.verify_signature(session_id, message) ).to be true
      end
    end

    context "with incorrect algorithm" do
      let(:signature_blob){ algorithm.sign('sha1', data) }
      let(:signature){
        [
          HrrRbSsh::Transport::DataType::String.encode('incorrect'),
          HrrRbSsh::Transport::DataType::String.encode(signature_blob),
        ].join
      }

      it "returns false" do
        expect( publickey.verify_signature(session_id, message) ).to be false
      end
    end

    context "with incorrect signature" do
      let(:signature_blob){ algorithm.sign('sha1', data) }
      let(:incorrect_signature_blob){ 'incorrect' + signature_blob }
      let(:signature){
        [
          HrrRbSsh::Transport::DataType::String.encode('ssh-rsa'),
          HrrRbSsh::Transport::DataType::String.encode(incorrect_signature_blob),
        ].join
      }

      it "returns false" do
        expect( publickey.verify_signature(session_id, message) ).to be false
      end
    end
  end
end
