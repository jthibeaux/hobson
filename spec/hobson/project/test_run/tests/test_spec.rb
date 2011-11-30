require 'spec_helper'

describe Hobson::Project::TestRun::Tests::Test do

  subject{ Factory.test('factoried.feature') }
  alias_method :test, :subject

  worker_context do

    %w{job status result runtime est_runtime}.each do |attr|
      it { should respond_to :"#{attr}"  }
      it { should respond_to :"#{attr}=" }
    end

    describe "calculate_estimated_runtime!" do

      context "when this test has never been run before" do
        it "should calculate nil" do
          test.calculate_estimated_runtime!
          test.est_runtime.should == Hobson::Project::TestRun::Tests::Test::MINIMUM_ESTIMATED_RUNTIME
        end
      end

      context "when this test has been run before" do
        before{
          @runtimes = 10.times.map{ rand }
          10.times{ |i|
            test = Factory.test('factoried.feature')
            test.result  = 'PASS'
            test.runtime = @runtimes[i]
          }
        }
        it "should calculate the average runtime" do
          test.est_runtime.should be_nil
          test.calculate_estimated_runtime!
          test.est_runtime.should == @runtimes.inject(&:+) / @runtimes.size
        end
      end

    end

  end

end
