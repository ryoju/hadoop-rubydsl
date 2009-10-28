require 'init'
require 'core'
require 'log_analysis'

include HadoopDsl::LogAnalysis

describe LogAnalysisMapper do
  it 'should separate data by space' do
    value = 'Lorem ipsum dolor sit amet,'
    mapper = LogAnalysisMapper.new(nil, nil, value)
    mapper.data.separate(' ')

    mapper.column.size.should == 5
  end

  it 'should separate by pattern' do
    value = '127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326'
    mapper = LogAnalysisMapper.new(nil, nil, value)
    mapper.data.pattern /(.*) (.*) (.*) \[(.*)\] (".*") (\d*) (\d*)/

    mapper.column.size.should == 7
  end

  it 'should count uniq column' do
    value = 'count uniq'
    mapper = LogAnalysisMapper.new(nil, nil, value)
    mapper.data.separate(' ')
    mapper.column[1].count_uniq

    mapper.emitted.first["col1\tuniq"].should == 1
  end

  it 'should sum column value' do
    value = 'sum 123'
    mapper = LogAnalysisMapper.new(nil, nil, value)
    mapper.data.separate(' ')
    mapper.column[1].sum

    mapper.emitted.first["col1"].should == 123
  end
end

describe LogAnalysisReducer do
  it 'should create column properly' do
    key = "col1\tuniq"
    values = [1, 1, 1]
    reducer = LogAnalysisReducer.new(nil, key, values)

    reducer.column[1].should_not be_nil
  end

  it 'should count uniq column' do
    key = "col1\tuniq"
    values = [1, 1, 1]
    reducer = LogAnalysisReducer.new(nil, key, values)
    reducer.data.separate(' ')
    reducer.column[1].count_uniq

    reducer.emitted.first["col1\tuniq"].should == 3
  end

  it 'should not count uniq of other column' do
    key = "col2\tuniq"
    values = [1, 1, 1]
    reducer = LogAnalysisReducer.new(nil, key, values)
    reducer.data.separate(' ')
    reducer.column[1].count_uniq

    reducer.emitted.first.should be_nil
  end

  it 'should sum column value' do
    key = "col1\tuniq"
    values = [123, 456, 789]
    reducer = LogAnalysisReducer.new(nil, key, values)
    reducer.data.separate(' ')
    reducer.column[1].sum

    reducer.emitted.first["col1\tuniq"].should == 123+456+789
  end
end
