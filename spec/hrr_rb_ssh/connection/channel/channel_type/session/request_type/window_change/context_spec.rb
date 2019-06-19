# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Connection::Channel::ChannelType::Session::RequestType::WindowChange::Context do
  let(:proc_chain){ "proc_chain" }
  let(:username){ "username" }
  let(:io){ 'dummy' }
  let(:variables){ Hash.new }
  let(:message){
    {
      :'message number'          => HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::VALUE,
      :'recipient channel'       => 1,
      :'request type'            => 'window-change',
      :'want reply'              => false,
      :'terminal width, columns' => 80,
      :'terminal height, rows'   => 24,
      :'terminal width, pixels'  => 400,
      :'terminal height, pixels' => 120,
    }
  }
  let(:session){ double('session') }
  let(:context){ described_class.new proc_chain, username, io, variables, message, session }

  describe ".new" do
    it "takes 6 arguments" do
      expect { context }.not_to raise_error
    end
  end

  describe "#chain_proc" do
    context "with block" do
      let(:chain_proc){
        Proc.new {}
      }

      it "receives a block and returns a proc based on the block" do
        context.chain_proc &chain_proc
        expect(context.chain_proc).to be chain_proc
      end
    end

    context "with no block" do
      it "returns nil" do
        context.chain_proc
        expect(context.chain_proc).to be nil
      end
    end
  end

  describe "#close_session" do
    it "closes session" do
      expect(session).to receive(:close).once
      context.close_session
    end
  end

  describe "#logger" do
    it "returns an instance of HrrRbSsh::Logger" do
      expect(context.logger).to be_an_instance_of HrrRbSsh::Logger
    end
  end

  describe "#io" do
    it "returns 'io' object" do
      expect(context.io).to be io
    end
  end

  describe "#variables" do
    it "returns 'variables' object" do
      expect(context.variables).to be variables
    end
  end

  describe "#vars" do
    it "returns 'variables' object" do
      expect(context.vars).to be variables
    end
  end

  describe "#terminal_width_columns" do
    it "returns message[:'terminal width, columns']" do
      expect(context.terminal_width_columns).to be message[:'terminal width, columns']
    end
  end

  describe "#terminal_height_rows" do
    it "returns message[:'terminal height, rows']" do
      expect(context.terminal_height_rows).to be message[:'terminal height, rows']
    end
  end

  describe "#terminal_width_pixels" do
    it "returns message[:'terminal width, pixels']" do
      expect(context.terminal_width_pixels).to be message[:'terminal width, pixels']
    end
  end

  describe "#terminal_height_pixels" do
    it "returns message[:'terminal height, pixels']" do
      expect(context.terminal_height_pixels).to be message[:'terminal height, pixels']
    end
  end
end
